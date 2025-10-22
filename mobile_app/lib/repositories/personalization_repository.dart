import 'package:gyanvruksh/repositories/base_repository.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';

class PersonalizationRepository extends BaseRepository {
  // User interests (Academics, Skills, Sports, Creativity)
  Future<List<String>> getUserInterests() async {
    try {
      final response = await ApiService.getPersonalizationData();
      if (response.isSuccess && response.data != null) {
        return List<String>.from(response.data['interests'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user interests: $e');
    }
  }

  Future<void> updateUserInterests(List<String> interests) async {
    try {
      final response = await ApiService.updatePersonalizationData({'interests': interests});
      if (!response.isSuccess) {
        throw Exception('Failed to update interests');
      }
    } catch (e) {
      throw Exception('Failed to update user interests: $e');
    }
  }

  // Skill levels for each category
  Future<Map<String, String>> getSkillLevels() async {
    try {
      final response = await ApiService.getPersonalizationData();
      if (response.isSuccess && response.data != null) {
        return Map<String, String>.from(response.data['skill_levels'] ?? {});
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get skill levels: $e');
    }
  }

  Future<void> updateSkillLevels(Map<String, String> skillLevels) async {
    try {
      final response = await ApiService.updatePersonalizationData({'skill_levels': skillLevels});
      if (!response.isSuccess) {
        throw Exception('Failed to update skill levels');
      }
    } catch (e) {
      throw Exception('Failed to update skill levels: $e');
    }
  }

  // Learning goals
  Future<List<String>> getLearningGoals() async {
    try {
      final response = await ApiService.getPersonalizationData();
      if (response.isSuccess && response.data != null) {
        return List<String>.from(response.data['learning_goals'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get learning goals: $e');
    }
  }

  Future<void> updateLearningGoals(List<String> goals) async {
    try {
      final response = await ApiService.updatePersonalizationData({'learning_goals': goals});
      if (!response.isSuccess) {
        throw Exception('Failed to update learning goals');
      }
    } catch (e) {
      throw Exception('Failed to update learning goals: $e');
    }
  }

  // Get personalized course recommendations
  Future<List<dynamic>> getRecommendedCourses() async {
    try {
      final response = await ApiService.getRecommendedCourses();
      return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  // Update user preferences during onboarding
  Future<void> setupUserPreferences({
    required List<String> interests,
    required Map<String, String> skillLevels,
    required List<String> goals,
  }) async {
    try {
      final response = await ApiService.updatePersonalizationData({
        'interests': interests,
        'skill_levels': skillLevels,
        'learning_goals': goals,
      });
      if (!response.isSuccess) {
        throw Exception('Failed to setup preferences');
      }
    } catch (e) {
      throw Exception('Failed to setup user preferences: $e');
    }
  }

  // Get complete user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final response = await ApiService.getPersonalizationData();
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {};
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  // Save complete user preferences
  Future<bool> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await ApiService.updatePersonalizationData(preferences);
      return response.isSuccess;
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  // Get learning analytics
  Future<Map<String, dynamic>> getLearningAnalytics() async {
    try {
      final response = await ApiService.get('/api/personalization/analytics');
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'analytics': {
          'total_study_time': 0,
          'average_session_length': 0,
          'preferred_study_times': [],
          'learning_streak': 0,
          'completion_rate': 0.0,
        },
        'patterns': [],
        'performance': {
          'strengths': [],
          'weaknesses': [],
          'improvement_trend': 'stable',
        },
        'strengths': [],
        'improvements': [],
      };
    } catch (e) {
      // Return default analytics if API fails
      return {
        'analytics': {
          'total_study_time': 0,
          'average_session_length': 0,
          'preferred_study_times': [],
          'learning_streak': 0,
          'completion_rate': 0.0,
        },
        'patterns': [],
        'performance': {
          'strengths': [],
          'weaknesses': [],
          'improvement_trend': 'stable',
        },
        'strengths': [],
        'improvements': [],
      };
    }
  }

  // Get personalized recommendations
  Future<Map<String, dynamic>> getPersonalizedRecommendations() async {
    try {
      final response = await ApiService.get('/api/personalization/recommendations');
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'courses': [],
        'lessons': [],
        'skill_gaps': [],
        'adaptive': {},
      };
    } catch (e) {
      // Return default recommendations if API fails
      return {
        'courses': [],
        'lessons': [],
        'skill_gaps': [],
        'adaptive': {},
      };
    }
  }

  // Track user interaction
  Future<void> trackUserInteraction(String contentType, String contentId,
      String interactionType, {Map<String, dynamic>? metadata}) async {
    try {
      await ApiService.post('/api/personalization/track', {
        'content_type': contentType,
        'content_id': contentId,
        'interaction_type': interactionType,
        'metadata': metadata ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      // Success is handled silently for tracking
    } catch (e) {
      // Silently fail for tracking - don't throw exception
      // User interaction tracking failed: $e
    }
  }

  // Get personalized study plan
  Future<Map<String, dynamic>> getStudyPlan() async {
    try {
      final response = await ApiService.get('/api/personalization/study-plan');
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'daily_goals': [
          {'type': 'lessons', 'target': 2, 'completed': 0},
          {'type': 'practice', 'target': 30, 'completed': 0}, // minutes
        ],
        'weekly_targets': [
          {'type': 'courses', 'target': 1, 'completed': 0},
          {'type': 'quizzes', 'target': 3, 'completed': 0},
        ],
        'skill_focus': [],
        'recommended_schedule': {
          'morning': ['theory_lessons'],
          'afternoon': ['practice_sessions'],
          'evening': ['review_quizzes'],
        },
      };
    } catch (e) {
      // Return default study plan if API fails
      return {
        'daily_goals': [
          {'type': 'lessons', 'target': 2, 'completed': 0},
          {'type': 'practice', 'target': 30, 'completed': 0}, // minutes
        ],
        'weekly_targets': [
          {'type': 'courses', 'target': 1, 'completed': 0},
          {'type': 'quizzes', 'target': 3, 'completed': 0},
        ],
        'skill_focus': [],
        'recommended_schedule': {
          'morning': ['theory_lessons'],
          'afternoon': ['practice_sessions'],
          'evening': ['review_quizzes'],
        },
      };
    }
  }

  // Update learning preferences
  Future<bool> updateLearningPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await ApiService.updatePersonalizationData({
        'learning_preferences': preferences,
      });
      return response.isSuccess;
    } catch (e) {
      throw Exception('Failed to update learning preferences: $e');
    }
  }

  // Get user learning style assessment
  Future<Map<String, dynamic>> getLearningStyleAssessment() async {
    try {
      final response = await ApiService.get('/api/personalization/learning-style');
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'primary_style': 'visual',
        'secondary_style': 'auditory',
        'style_scores': {
          'visual': 0.7,
          'auditory': 0.6,
          'reading': 0.4,
          'kinesthetic': 0.5,
        },
        'recommendations': [
          'Use more diagrams and visual aids',
          'Incorporate audio explanations',
        ],
      };
    } catch (e) {
      return {
        'primary_style': 'visual',
        'secondary_style': 'auditory',
        'style_scores': {
          'visual': 0.7,
          'auditory': 0.6,
          'reading': 0.4,
          'kinesthetic': 0.5,
        },
        'recommendations': [
          'Use more diagrams and visual aids',
          'Incorporate audio explanations',
        ],
      };
    }
  }

  // Get adaptive difficulty suggestions
  Future<Map<String, dynamic>> getAdaptiveDifficulty(String contentId) async {
    try {
      final response = await ApiService.get('/api/personalization/adaptive-difficulty/$contentId');
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'suggested_difficulty': 'intermediate',
        'reasoning': 'Based on your current skill level and performance',
        'adjustments': [],
      };
    } catch (e) {
      return {
        'suggested_difficulty': 'intermediate',
        'reasoning': 'Based on your current skill level and performance',
        'adjustments': [],
      };
    }
  }

  // Get content pacing recommendations
  Future<Map<String, dynamic>> getContentPacing() async {
    try {
      final response = await ApiService.get('/api/personalization/pacing');
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'recommended_pace': 'moderate',
        'session_length': 25, // minutes
        'break_frequency': 25, // minutes
        'daily_limit': 120, // minutes
      };
    } catch (e) {
      return {
        'recommended_pace': 'moderate',
        'session_length': 25, // minutes
        'break_frequency': 25, // minutes
        'daily_limit': 120, // minutes
      };
    }
  }
}
