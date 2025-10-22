import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'enhanced_api_service.dart';
import 'offline_cache_service.dart';
import 'auth_storage.dart';

/// Offline Sync Service
/// Handles downloading content for offline use and syncing when online
class OfflineSyncService {
  static const Duration _syncInterval = Duration(minutes: 30);
  static Timer? _syncTimer;
  static bool _isOnline = true;

  // Stream for sync status updates
  static final StreamController<String> _syncStatusController =
      StreamController<String>.broadcast();
  static Stream<String> get syncStatusStream => _syncStatusController.stream;

  /// Initialize offline sync service
  static Future<void> initialize() async {
    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);

    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    // Start periodic sync if online
    if (_isOnline) {
      _startPeriodicSync();
    }

    print('OfflineSyncService: Initialized');
  }

  /// Handle connectivity changes
  static void _handleConnectivityChange(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = result.first != ConnectivityResult.none;

    if (!wasOnline && _isOnline) {
      // Just came online - start syncing
      _syncStatusController.add('online');
      _startPeriodicSync();
      syncAll(); // Immediate sync
    } else if (wasOnline && !_isOnline) {
      // Just went offline
      _syncStatusController.add('offline');
      _stopPeriodicSync();
    }
  }

  /// Start periodic sync when online
  static void _startPeriodicSync() {
    _stopPeriodicSync();
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      if (_isOnline) {
        syncAll();
      }
    });
  }

  /// Stop periodic sync
  static void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Sync all user data for offline access
  static Future<void> syncAll() async {
    if (!_isOnline) {
      print('OfflineSyncService: Cannot sync while offline');
      return;
    }

    _syncStatusController.add('syncing');

    try {
      // Sync user enrolled courses
      await _syncEnrolledCourses();

      // Sync recent lessons
      await _syncRecentLessons();

      // Sync progress data
      await _syncProgressData();

      // Sync user data
      await _syncUserData();

      _syncStatusController.add('synced');

      print('OfflineSyncService: Full sync completed');

    } catch (e) {
      print('OfflineSyncService: Sync failed: $e');
      _syncStatusController.add('sync_failed');
    }
  }

  /// Sync enrolled courses for offline access
  static Future<void> _syncEnrolledCourses() async {
    try {
      final coursesResult = await ApiService.getEnrolledCourses();
      final courses = coursesResult.isSuccess ? (coursesResult.data as List<dynamic>?) ?? [] : [];

      if (courses.isNotEmpty) {
        await OfflineCacheService.cacheCourses(courses.cast<Map<String, dynamic>>());
        print('OfflineSyncService: Synced ${courses.length} enrolled courses');
      }
    } catch (e) {
      print('OfflineSyncService: Failed to sync enrolled courses: $e');
    }
  }

  /// Sync recent lessons for offline access
  static Future<void> _syncRecentLessons() async {
    try {
      final coursesResult = await ApiService.getEnrolledCourses();
      final enrolledCourses = coursesResult.isSuccess ? (coursesResult.data as List<dynamic>?) ?? [] : [];

      for (final course in enrolledCourses) {
        final courseId = course['id'];
        if (courseId != null) {
          final lessonsResult = await ApiService.getLessons(courseId: courseId);
          final lessons = lessonsResult.isSuccess ? (lessonsResult.data as List<dynamic>?) ?? [] : [];
          for (final lesson in lessons) {
            await OfflineCacheService.cacheLesson(lesson);
          }
        }
      }

      print('OfflineSyncService: Synced lessons for ${enrolledCourses.length} courses');

    } catch (e) {
      print('OfflineSyncService: Failed to sync lessons: $e');
    }
  }

  /// Sync progress data
  static Future<void> _syncProgressData() async {
    try {
      final coursesResult = await ApiService.getEnrolledCourses();
      final enrolledCourses = coursesResult.isSuccess ? (coursesResult.data as List<dynamic>?) ?? [] : [];

      // Sync course progress
      for (final course in enrolledCourses) {
        final courseId = course['id'];
        if (courseId != null) {
          final progressResult = await ApiService.getCourseProgress(courseId);
          final progress = progressResult.isSuccess ? progressResult.data : null;
          if (progress != null) {
            await OfflineCacheService.cacheProgress(progress as Map<String, dynamic>);
          }
        }
      }

      print('OfflineSyncService: Synced progress data');

    } catch (e) {
      print('OfflineSyncService: Failed to sync progress: $e');
    }
  }

  /// Sync user data
  static Future<void> _syncUserData() async {
    try {
      final userData = await AuthStorage.getUserData();
      if (userData != null) {
        await OfflineCacheService.cacheUserData(userData);
      }

      print('OfflineSyncService: Synced user data');

    } catch (e) {
      print('OfflineSyncService: Failed to sync user data: $e');
    }
  }

  /// Download specific course for offline use
  static Future<bool> downloadCourseForOffline(int courseId) async {
    if (!_isOnline) {
      print('OfflineSyncService: Cannot download while offline');
      return false;
    }

    try {
      _syncStatusController.add('downloading_course');

      // Get course details
      final courseResult = await ApiService.getCourseDetails(courseId);
      final course = courseResult.isSuccess ? courseResult.data as Map<String, dynamic>? : null;
      if (course == null) {
        print('OfflineSyncService: Course not found');
        return false;
      }

      // Cache course
      await OfflineCacheService.cacheCourse(course);

      // Get and cache lessons
      final lessonsResult = await ApiService.getLessons(courseId: courseId);
      final lessons = lessonsResult.isSuccess ? (lessonsResult.data as List<dynamic>?) ?? [] : [];
      for (final lesson in lessons) {
        await OfflineCacheService.cacheLesson(lesson);
      }

      // Get and cache course videos and notes if available
      try {
        // TODO: Implement getCourseVideos method in ApiService or use existing method
        // final videos = await apiService.getCourseVideos(courseId);
        // Cache videos data
        // for (final video in videos) {
        //   await OfflineCacheService.cacheLesson(video); // Treat as lesson-like content
        // }
        print('OfflineSyncService: Course videos sync not implemented yet');
      } catch (e) {
        print('OfflineSyncService: No videos found for course $courseId');
      }

      try {
        final notesResult = await ApiService.getCourseNotes(courseId);
        final notes = notesResult.isSuccess ? (notesResult.data as List<dynamic>?) ?? [] : [];
        // Cache notes data
        for (final note in notes) {
          await OfflineCacheService.cacheLesson(note); // Treat as lesson-like content
        }
      } catch (e) {
        print('OfflineSyncService: No notes found for course $courseId');
      }

      _syncStatusController.add('course_downloaded');

      print('OfflineSyncService: Course $courseId downloaded for offline use');
      return true;

    } catch (e) {
      print('OfflineSyncService: Failed to download course: $e');
      _syncStatusController.add('download_failed');
      return false;
    }
  }

  /// Check if course is available offline
  static Future<bool> isCourseAvailableOffline(int courseId) async {
    final cachedCourse = await OfflineCacheService.getCachedCourse(courseId);
    return cachedCourse != null;
  }

  /// Get offline available courses
  static Future<List<Map<String, dynamic>>> getOfflineAvailableCourses() async {
    return await OfflineCacheService.getCachedCourses();
  }

  /// Remove course from offline cache
  static Future<void> removeCourseFromOffline(int courseId) async {
    // This would need implementation to remove course and related lessons
    print('OfflineSyncService: Remove course from offline cache (not implemented)');
  }

  /// Force sync specific data type
  static Future<void> syncDataType(String dataType) async {
    switch (dataType) {
      case 'courses':
        await _syncEnrolledCourses();
        break;
      case 'lessons':
        await _syncRecentLessons();
        break;
      case 'progress':
        await _syncProgressData();
        break;
      case 'user':
        await _syncUserData();
        break;
    }
  }

  /// Check if currently online
  static bool get isOnline => _isOnline;

  /// Get current sync status
  static String get currentSyncStatus {
    if (!_isOnline) return 'offline';
    return 'online'; // Could be more detailed based on _syncStatusController
  }

  /// Clean up resources
  static void dispose() {
    _stopPeriodicSync();
    _syncStatusController.close();
  }
}
