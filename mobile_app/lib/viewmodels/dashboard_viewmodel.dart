import 'package:flutter/material.dart';
import '../repositories/courses_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _courses = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<dynamic> get courses => _courses;
  String? get error => _error;

  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await CoursesRepository.getMyCourses();
    } catch (e) {
      _error = 'Failed to load courses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
