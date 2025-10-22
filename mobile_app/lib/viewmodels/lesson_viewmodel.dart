import 'package:flutter/material.dart';
import '../repositories/courses_repository.dart';

class LessonViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _lessons = [];
  Map<String, dynamic>? _currentLesson;
  String? _error;

  bool get isLoading => _isLoading;
  List<dynamic> get lessons => _lessons;
  Map<String, dynamic>? get currentLesson => _currentLesson;
  String? get error => _error;

  Future<void> loadLessons({int? courseId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lessons = await CoursesRepository.getLessons(courseId: courseId);
    } catch (e) {
      _error = 'Failed to load lessons: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLesson(int lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLesson = await CoursesRepository.getLesson(lessonId);
    } catch (e) {
      _error = 'Failed to load lesson: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLesson(int courseId, String title, String description, String contentType,
      {String? contentUrl, String? contentText, int durationMinutes = 0, int orderIndex = 0, bool isFree = false}) async {
    try {
      final success = await CoursesRepository.createLesson(courseId, title, description, contentType,
          contentUrl: contentUrl, contentText: contentText, durationMinutes: durationMinutes,
          orderIndex: orderIndex, isFree: isFree);
      if (success) {
        // Reload lessons after creation
        await loadLessons(courseId: courseId);
      }
      return success;
    } catch (e) {
      _error = 'Failed to create lesson: $e';
      notifyListeners();
      return false;
    }
  }
}
