import 'package:flutter/material.dart';
import '../repositories/progress_repository.dart';
import '../services/enhanced_api_service.dart';

class ProgressViewModel extends ChangeNotifier {
  final ProgressRepository _progressRepository = ProgressRepository();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingDetailed = false;
  String? _error;

  // Overall progress
  double _overallProgress = 0.0;
  int _totalLessonsCompleted = 0;
  int _totalLessonsAvailable = 0;
  int _totalTimeSpentMinutes = 0;

  // Category/Skill progress
  List<Map<String, dynamic>> _skillProgress = [];
  List<Map<String, dynamic>> _categoryProgress = [];

  // Detailed progress tracking
  List<Map<String, dynamic>> _lessonProgress = [];
  List<Map<String, dynamic>> _courseProgress = [];
  Map<String, dynamic> _weeklyProgress = {};
  Map<String, dynamic> _monthlyProgress = {};

  // Learning analytics
  Map<String, dynamic> _learningAnalytics = {};
  List<Map<String, dynamic>> _learningPatterns = [];
  List<String> _strengthAreas = [];
  List<String> _improvementAreas = [];

  // Gamification integration
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalPoints = 0;
  int _totalBadges = 0;
  List<Map<String, dynamic>> _recentAchievements = [];
  List<Map<String, dynamic>> _badges = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingDetailed => _isLoadingDetailed;
  String? get error => _error;

  double get overallProgress => _overallProgress;
  int get totalLessonsCompleted => _totalLessonsCompleted;
  int get totalLessonsAvailable => _totalLessonsAvailable;
  int get totalTimeSpentMinutes => _totalTimeSpentMinutes;

  List<Map<String, dynamic>> get skillProgress => _skillProgress;
  List<Map<String, dynamic>> get categoryProgress => _categoryProgress;
  List<Map<String, dynamic>> get lessonProgress => _lessonProgress;
  List<Map<String, dynamic>> get courseProgress => _courseProgress;
  Map<String, dynamic> get weeklyProgress => _weeklyProgress;
  Map<String, dynamic> get monthlyProgress => _monthlyProgress;

  Map<String, dynamic> get learningAnalytics => _learningAnalytics;
  List<Map<String, dynamic>> get learningPatterns => _learningPatterns;
  List<String> get strengthAreas => _strengthAreas;
  List<String> get improvementAreas => _improvementAreas;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalPoints => _totalPoints;
  int get totalBadges => _totalBadges;
  List<Map<String, dynamic>> get recentAchievements => _recentAchievements;
  List<Map<String, dynamic>> get badges => _badges;

  // Computed properties
  double get completionRate => _totalLessonsAvailable > 0
      ? (_totalLessonsCompleted / _totalLessonsAvailable) * 100
      : 0.0;

  String get formattedTimeSpent {
    final hours = _totalTimeSpentMinutes ~/ 60;
    final minutes = _totalTimeSpentMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Initialize and load progress data
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadOverallProgress(),
        loadDetailedProgress(),
        loadSkillProgress(),
        loadGamificationData(),
      ]);
    } catch (e) {
      _error = 'Failed to load progress: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOverallProgress() async {
    try {
      final progressData = await _progressRepository.getOverallProgress();
      _overallProgress = progressData['overall_progress'] ?? 0.0;
      _totalLessonsCompleted = progressData['completed_lessons'] ?? 0;
      _totalLessonsAvailable = progressData['total_lessons'] ?? 0;
      _totalTimeSpentMinutes = progressData['time_spent_minutes'] ?? 0;
    } catch (e) {
      debugPrint('Error loading overall progress: $e');
    }
  }

  Future<void> loadDetailedProgress() async {
    _isLoadingDetailed = true;
    notifyListeners();

    try {
      final detailedData = await _progressRepository.getDetailedProgress();

      _lessonProgress = List<Map<String, dynamic>>.from(
          detailedData['lesson_progress'] ?? []);
      _courseProgress = List<Map<String, dynamic>>.from(
          detailedData['course_progress'] ?? []);
      _weeklyProgress = detailedData['weekly_progress'] ?? {};
      _monthlyProgress = detailedData['monthly_progress'] ?? {};

      _learningAnalytics = detailedData['analytics'] ?? {};
      _learningPatterns = List<Map<String, dynamic>>.from(
          detailedData['patterns'] ?? []);
      _strengthAreas = List<String>.from(detailedData['strengths'] ?? []);
      _improvementAreas = List<String>.from(detailedData['improvements'] ?? []);

    } catch (e) {
      debugPrint('Error loading detailed progress: $e');
    } finally {
      _isLoadingDetailed = false;
      notifyListeners();
    }
  }

  Future<void> loadSkillProgress() async {
    try {
      final skillData = await _progressRepository.getSkillProgress();
      _skillProgress = List<Map<String, dynamic>>.from(skillData['skills'] ?? []);
      _categoryProgress = List<Map<String, dynamic>>.from(skillData['categories'] ?? []);
    } catch (e) {
      debugPrint('Error loading skill progress: $e');
    }
  }

  Future<void> loadGamificationData() async {
    try {
      final gamificationData = await _progressRepository.getGamificationData();
      _currentStreak = gamificationData['current_streak'] ?? 0;
      _longestStreak = gamificationData['longest_streak'] ?? 0;
      _totalPoints = gamificationData['total_points'] ?? 0;
      _totalBadges = gamificationData['total_badges'] ?? 0;
      _recentAchievements = List<Map<String, dynamic>>.from(
          gamificationData['recent_achievements'] ?? []);
      _badges = List<Map<String, dynamic>>.from(gamificationData['badges'] ?? []);
    } catch (e) {
      debugPrint('Error loading gamification data: $e');
    }
  }

  // Lesson progress updates
  Future<bool> updateLessonProgress(int courseId, int lessonId, double progressPercentage,
      {bool completed = false, int timeSpentMinutes = 0, String? skillArea}) async {
    try {
      final response = await ApiService.updateLessonProgress(
        courseId,
        lessonId,
        progressPercentage,
        completed: completed,
        timeSpentMinutes: timeSpentMinutes,
      );

      final success = response.isSuccess;

      if (success) {
        // Update local state
        if (completed && !_lessonProgress.any((lp) =>
            lp['course_id'] == courseId && lp['lesson_id'] == lessonId && lp['completed'] == true)) {
          _totalLessonsCompleted += 1;
        }

        _totalTimeSpentMinutes += timeSpentMinutes;

        // Update skill progress if skill area provided
        if (skillArea != null) {
          _updateSkillProgress(skillArea, completed);
        }

        // Recalculate overall progress
        await loadOverallProgress();
        await loadDetailedProgress();

        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = 'Failed to update lesson progress: $e';
      notifyListeners();
      return false;
    }
  }

  void _updateSkillProgress(String skillArea, bool completed) {
    final skillIndex = _skillProgress.indexWhere((skill) => skill['name'] == skillArea);
    if (skillIndex != -1) {
      final skill = _skillProgress[skillIndex];
      if (completed) {
        skill['completed'] = (skill['completed'] ?? 0) + 1;
      }
      skill['progress'] = ((skill['completed'] ?? 0) / (skill['total'] ?? 1)) * 100;
      _skillProgress[skillIndex] = skill;
    }
  }

  // Course completion tracking
  Future<bool> markCourseCompleted(int courseId) async {
    try {
      final success = await _progressRepository.markCourseCompleted(courseId);
      if (success) {
        await loadOverallProgress();
        await loadDetailedProgress();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to mark course completed: $e';
      notifyListeners();
      return false;
    }
  }

  // Streak management
  Future<void> updateStreak(bool learningActivity) async {
    try {
      await _progressRepository.updateStreak(learningActivity);
      await loadGamificationData();
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  // Analytics methods
  Map<String, dynamic> getProgressForSkill(String skillName) {
    return _skillProgress.firstWhere(
      (skill) => skill['name'] == skillName,
      orElse: () => {'name': skillName, 'progress': 0, 'completed': 0, 'total': 0},
    );
  }

  List<Map<String, dynamic>> getRecentLessons({int limit = 10}) {
    return _lessonProgress
        .where((lesson) => lesson['last_accessed'] != null)
        .toList()
      ..sort((a, b) => (b['last_accessed'] ?? '').compareTo(a['last_accessed'] ?? ''))
      ..take(limit)
      .toList();
  }

  Map<String, dynamic> getWeeklyStats() {
    return {
      'lessons_completed': _weeklyProgress['lessons_completed'] ?? 0,
      'time_spent': _weeklyProgress['time_spent_minutes'] ?? 0,
      'average_daily': (_weeklyProgress['time_spent_minutes'] ?? 0) / 7,
      'streak_maintained': _weeklyProgress['streak_maintained'] ?? false,
    };
  }

  // Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Legacy methods for backward compatibility
  void updateLessonProgressSync(double progress) {
    _overallProgress = progress;
    notifyListeners();
  }
}
