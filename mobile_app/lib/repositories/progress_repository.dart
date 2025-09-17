import '../services/api.dart';

class ProgressRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getOverallProgress() async {
    try {
      final response = await _apiService.get('/api/progress/overall');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'overall_progress': 0.0,
        'completed_lessons': 0,
        'total_lessons': 0,
        'time_spent_minutes': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getDetailedProgress() async {
    try {
      final response = await _apiService.get('/api/progress/detailed');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'lesson_progress': [],
        'course_progress': [],
        'weekly_progress': {},
        'monthly_progress': {},
        'analytics': {},
        'patterns': [],
        'strengths': [],
        'improvements': [],
      };
    }
  }

  Future<Map<String, dynamic>> getSkillProgress() async {
    try {
      final response = await _apiService.get('/api/progress/skills');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'skills': [
          {'name': 'Mathematics', 'progress': 0, 'completed': 0, 'total': 0},
          {'name': 'Science', 'progress': 0, 'completed': 0, 'total': 0},
          {'name': 'Language', 'progress': 0, 'completed': 0, 'total': 0},
          {'name': 'Programming', 'progress': 0, 'completed': 0, 'total': 0},
        ],
        'categories': [
          {'name': 'Academics', 'progress': 0, 'completed': 0, 'total': 0},
          {'name': 'Skills', 'progress': 0, 'completed': 0, 'total': 0},
          {'name': 'Creativity', 'progress': 0, 'completed': 0, 'total': 0},
        ],
      };
    }
  }

  Future<Map<String, dynamic>> getGamificationData() async {
    try {
      final response = await _apiService.get('/api/gamification/progress');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'current_streak': 0,
        'longest_streak': 0,
        'total_points': 0,
        'total_badges': 0,
        'recent_achievements': [],
        'badges': [],
      };
    }
  }

  Future<bool> markCourseCompleted(int courseId) async {
    try {
      final response = await _apiService.post('/api/progress/course/$courseId/complete', {});
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateStreak(bool learningActivity) async {
    try {
      await _apiService.post('/api/gamification/streak', {
        'learning_activity': learningActivity,
      });
    } catch (e) {
      // Silently fail for streak updates
    }
  }

  Future<List<Map<String, dynamic>>> getLessonHistory({int limit = 50}) async {
    try {
      final response = await _apiService.get('/api/progress/lessons?limit=$limit');
      return List<Map<String, dynamic>>.from(response['lessons'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getProgressAnalytics() async {
    try {
      final response = await _apiService.get('/api/progress/analytics');
      return response;
    } catch (e) {
      return {
        'total_study_time': 0,
        'average_session_length': 0,
        'most_productive_day': 'N/A',
        'most_productive_time': 'N/A',
        'completion_rate': 0.0,
        'consistency_score': 0.0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyProgress() async {
    try {
      final response = await _apiService.get('/api/progress/weekly');
      return List<Map<String, dynamic>>.from(response['weekly_data'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyProgress() async {
    try {
      final response = await _apiService.get('/api/progress/monthly');
      return List<Map<String, dynamic>>.from(response['monthly_data'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<bool> resetProgress() async {
    try {
      final response = await _apiService.post('/api/progress/reset', {});
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
