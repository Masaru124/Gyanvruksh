import 'package:flutter/material.dart';
import '../repositories/courses_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  final CoursesRepository _coursesRepository = CoursesRepository();

  bool _isLoading = false;
  Map<String, dynamic>? _courseProgress;
  Map<String, dynamic>? _userPreferences;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get courseProgress => _courseProgress;
  Map<String, dynamic>? get userPreferences => _userPreferences;
  String? get error => _error;

  Future<void> loadCourseProgress(int courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courseProgress = await _coursesRepository.getCourseProgress(courseId);
    } catch (e) {
      _error = 'Failed to load course progress: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLessonProgress(int courseId, int lessonId, double progressPercentage,
      {bool completed = false, int timeSpentMinutes = 0}) async {
    try {
      final success = await _coursesRepository.updateLessonProgress(
          courseId, lessonId, progressPercentage,
          completed: completed, timeSpentMinutes: timeSpentMinutes);
      if (success) {
        // Reload course progress after update
        await loadCourseProgress(courseId);
      } else {
        _error = 'Failed to update lesson progress';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update lesson progress: $e';
      notifyListeners();
    }
  }

  Future<void> loadUserPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userPreferences = await _coursesRepository.getUserPreferences();
    } catch (e) {
      _error = 'Failed to load user preferences: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserPreferences({
    List<String>? preferredCategories,
    String? skillLevel,
    List<String>? learningGoals,
    int? dailyStudyTime,
    bool? notificationsEnabled,
  }) async {
    try {
      final success = await _coursesRepository.updateUserPreferences(
        preferredCategories: preferredCategories,
        skillLevel: skillLevel,
        learningGoals: learningGoals,
        dailyStudyTime: dailyStudyTime,
        notificationsEnabled: notificationsEnabled,
      );
      if (success) {
        // Reload preferences after update
        await loadUserPreferences();
      } else {
        _error = 'Failed to update user preferences';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update user preferences: $e';
      notifyListeners();
    }
  }
}
