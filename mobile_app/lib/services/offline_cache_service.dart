import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Offline Cache Service using Hive
/// Handles local storage of courses, lessons, progress, and other data for offline access
class OfflineCacheService {
  static const String _coursesBoxName = 'courses';
  static const String _lessonsBoxName = 'lessons';
  static const String _progressBoxName = 'progress';
  static const String _userDataBoxName = 'user_data';
  static const String _cacheMetadataBoxName = 'cache_metadata';

  static Box? _coursesBox;
  static Box? _lessonsBox;
  static Box? _progressBox;
  static Box? _userDataBox;
  static Box? _cacheMetadataBox;

  static bool _isInitialized = false;

  /// Initialize Hive and open all boxes
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Open boxes
      _coursesBox = await Hive.openBox(_coursesBoxName);
      _lessonsBox = await Hive.openBox(_lessonsBoxName);
      _progressBox = await Hive.openBox(_progressBoxName);
      _userDataBox = await Hive.openBox(_userDataBoxName);
      _cacheMetadataBox = await Hive.openBox(_cacheMetadataBoxName);

      _isInitialized = true;
      print('OfflineCacheService: Initialized successfully');
    } catch (e) {
      print('OfflineCacheService: Initialization failed: $e');
    }
  }

  /// Cache a course for offline access
  static Future<void> cacheCourse(Map<String, dynamic> courseData) async {
    if (!_isInitialized || _coursesBox == null) await initialize();

    try {
      final courseId = courseData['id'].toString();
      await _coursesBox?.put(courseId, {
        'data': jsonEncode(courseData),
        'cached_at': DateTime.now().toIso8601String(),
        'type': 'course'
      });
    } catch (e) {
      print('OfflineCacheService: Failed to cache course: $e');
    }
  }

  /// Get cached course
  static Future<Map<String, dynamic>?> getCachedCourse(int courseId) async {
    if (!_isInitialized || _coursesBox == null) await initialize();

    try {
      final cached = _coursesBox?.get(courseId.toString());
      if (cached == null) return null;

      // Check if cache is still valid (24 hours)
      final cachedAt = DateTime.parse(cached['cached_at']);
      if (DateTime.now().difference(cachedAt).inHours > 24) {
        await _coursesBox?.delete(courseId.toString());
        return null;
      }

      return jsonDecode(cached['data']);
    } catch (e) {
      print('OfflineCacheService: Failed to get cached course: $e');
      return null;
    }
  }

  /// Cache multiple courses
  static Future<void> cacheCourses(List<Map<String, dynamic>> courses) async {
    if (!_isInitialized || _coursesBox == null) await initialize();

    for (final course in courses) {
      await cacheCourse(course);
    }
  }

  /// Get all cached courses
  static Future<List<Map<String, dynamic>>> getCachedCourses() async {
    if (!_isInitialized || _coursesBox == null) await initialize();

    final courses = <Map<String, dynamic>>[];

    try {
      for (final key in _coursesBox?.keys ?? []) {
        final cached = _coursesBox?.get(key);
        if (cached != null) {
          final course = jsonDecode(cached['data']);
          courses.add(course);
        }
      }
    } catch (e) {
      print('OfflineCacheService: Failed to get cached courses: $e');
    }

    return courses;
  }

  /// Cache a lesson for offline access
  static Future<void> cacheLesson(Map<String, dynamic> lessonData) async {
    if (!_isInitialized || _lessonsBox == null) await initialize();

    try {
      final lessonId = lessonData['id'].toString();
      await _lessonsBox?.put(lessonId, {
        'data': jsonEncode(lessonData),
        'cached_at': DateTime.now().toIso8601String(),
        'type': 'lesson'
      });
    } catch (e) {
      print('OfflineCacheService: Failed to cache lesson: $e');
    }
  }

  /// Get cached lesson
  static Future<Map<String, dynamic>?> getCachedLesson(int lessonId) async {
    if (!_isInitialized || _lessonsBox == null) await initialize();

    try {
      final cached = _lessonsBox?.get(lessonId.toString());
      if (cached == null) return null;

      // Check if cache is still valid (24 hours)
      final cachedAt = DateTime.parse(cached['cached_at']);
      if (DateTime.now().difference(cachedAt).inHours > 24) {
        await _lessonsBox?.delete(lessonId.toString());
        return null;
      }

      return jsonDecode(cached['data']);
    } catch (e) {
      print('OfflineCacheService: Failed to get cached lesson: $e');
      return null;
    }
  }

  /// Cache user progress
  static Future<void> cacheProgress(Map<String, dynamic> progressData) async {
    if (!_isInitialized || _progressBox == null) await initialize();

    try {
      final key = '${progressData['user_id']}_${progressData['course_id']}_${progressData['lesson_id'] ?? 'course'}';
      await _progressBox?.put(key, {
        'data': jsonEncode(progressData),
        'cached_at': DateTime.now().toIso8601String(),
        'type': 'progress'
      });
    } catch (e) {
      print('OfflineCacheService: Failed to cache progress: $e');
    }
  }

  /// Get cached progress
  static Future<Map<String, dynamic>?> getCachedProgress(int userId, int courseId, {int? lessonId}) async {
    if (!_isInitialized || _progressBox == null) await initialize();

    try {
      final key = '${userId}_$courseId${lessonId != null ? '_$lessonId' : '_course'}';
      final cached = _progressBox?.get(key);

      if (cached == null) return null;
      return jsonDecode(cached['data']);
    } catch (e) {
      print('OfflineCacheService: Failed to get cached progress: $e');
      return null;
    }
  }

  /// Cache user data
  static Future<void> cacheUserData(Map<String, dynamic> userData) async {
    if (!_isInitialized || _userDataBox == null) await initialize();

    try {
      await _userDataBox?.put('user_data', {
        'data': jsonEncode(userData),
        'cached_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('OfflineCacheService: Failed to cache user data: $e');
    }
  }

  /// Get cached user data
  static Future<Map<String, dynamic>?> getCachedUserData() async {
    if (!_isInitialized || _userDataBox == null) await initialize();

    try {
      final cached = _userDataBox?.get('user_data');
      if (cached == null) return null;

      return jsonDecode(cached['data']);
    } catch (e) {
      print('OfflineCacheService: Failed to get cached user data: $e');
      return null;
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    if (!_isInitialized) await initialize();

    try {
      await _coursesBox?.clear();
      await _lessonsBox?.clear();
      await _progressBox?.clear();
      await _userDataBox?.clear();
      await _cacheMetadataBox?.clear();

      print('OfflineCacheService: All cache cleared');
    } catch (e) {
      print('OfflineCacheService: Failed to clear cache: $e');
    }
  }

  /// Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    if (!_isInitialized || _coursesBox == null) await initialize();

    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];

      // Check courses
      for (final key in _coursesBox?.keys ?? []) {
        final cached = _coursesBox?.get(key);
        if (cached != null) {
          final cachedAt = DateTime.parse(cached['cached_at']);
          if (now.difference(cachedAt).inHours > 24) {
            expiredKeys.add(key);
          }
        }
      }

      // Clear expired entries
      for (final key in expiredKeys) {
        await _coursesBox?.delete(key);
      }

      print('OfflineCacheService: Cleared ${expiredKeys.length} expired entries');
    } catch (e) {
      print('OfflineCacheService: Failed to clear expired cache: $e');
    }
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) await initialize();

    return {
      'courses_count': _coursesBox?.length ?? 0,
      'lessons_count': _lessonsBox?.length ?? 0,
      'progress_count': _progressBox?.length ?? 0,
      'total_size': (_coursesBox?.length ?? 0) + (_lessonsBox?.length ?? 0) + (_progressBox?.length ?? 0),
      'last_cache_clear': _cacheMetadataBox?.get('last_clear') ?? 'Never'
    };
  }

  /// Check if device has enough space for caching
  static Future<bool> hasEnoughSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      // Allow caching if at least 100MB free
      return stat.size < 100 * 1024 * 1024;
    } catch (e) {
      return true; // Assume enough space if we can't check
    }
  }

  /// Enable/disable offline mode
  static Future<void> setOfflineMode(bool enabled) async {
    if (!_isInitialized || _cacheMetadataBox == null) await initialize();

    try {
      await _cacheMetadataBox?.put('offline_mode', enabled);
      await _cacheMetadataBox?.put('offline_mode_updated', DateTime.now().toIso8601String());
    } catch (e) {
      print('OfflineCacheService: Failed to set offline mode: $e');
    }
  }

  /// Check if offline mode is enabled
  static Future<bool> isOfflineMode() async {
    if (!_isInitialized || _cacheMetadataBox == null) await initialize();

    try {
      return _cacheMetadataBox?.get('offline_mode', defaultValue: false) ?? false;
    } catch (e) {
      print('OfflineCacheService: Failed to get offline mode: $e');
      return false;
    }
  }
}
