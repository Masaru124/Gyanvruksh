import '../services/api.dart';

class GamificationRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getPointsAndLevel() async {
    try {
      final response = await _apiService.get('/api/gamification/points');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'total_points': 0,
        'current_level': 1,
        'points_to_next': 100,
        'weekly_points': 0,
        'monthly_points': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getStreaks() async {
    try {
      final response = await _apiService.get('/api/gamification/streaks');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'current_streak': 0,
        'longest_streak': 0,
        'freeze_count': 0,
        'streak_active': false,
        'last_activity': null,
      };
    }
  }

  Future<Map<String, dynamic>> getBadges() async {
    try {
      final response = await _apiService.get('/api/gamification/badges');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'earned': [],
        'available': [
          {
            'id': 'first_lesson',
            'name': 'First Steps',
            'description': 'Complete your first lesson',
            'icon': 'school',
            'rarity': 'common',
            'points_required': 10,
          },
          {
            'id': 'week_warrior',
            'name': 'Week Warrior',
            'description': 'Complete lessons for 7 consecutive days',
            'icon': 'local_fire_department',
            'rarity': 'rare',
            'points_required': 100,
          },
        ],
        'recent': [],
        'progress': {},
      };
    }
  }

  Future<Map<String, dynamic>> getLeaderboards() async {
    try {
      final response = await _apiService.get('/api/gamification/leaderboard');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'global': [],
        'friends': [],
        'user_rank': {'global_rank': 0, 'friends_rank': 0},
      };
    }
  }

  Future<Map<String, dynamic>> getChallenges() async {
    try {
      final response = await _apiService.get('/api/gamification/challenges');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'daily': [
          {
            'id': 'daily_lesson',
            'title': 'Complete 1 Lesson',
            'description': 'Finish at least one lesson today',
            'points_reward': 50,
            'status': 'active',
            'progress': 0,
            'target': 1,
          },
        ],
        'weekly': [
          {
            'id': 'weekly_streak',
            'title': 'Maintain Streak',
            'description': 'Keep your learning streak alive for 7 days',
            'points_reward': 200,
            'status': 'active',
            'progress': 0,
            'target': 7,
          },
        ],
        'progress': {},
      };
    }
  }

  Future<Map<String, dynamic>> getRewards() async {
    try {
      final response = await _apiService.get('/api/gamification/rewards');
      return response;
    } catch (e) {
      // Return default values if API fails
      return {
        'available': [
          {
            'id': 'streak_freeze',
            'name': 'Streak Freeze',
            'description': 'Save your streak for one day',
            'cost': 100,
            'type': 'power_up',
            'icon': 'ac_unit',
          },
        ],
        'claimed': [],
      };
    }
  }

  Future<bool> addPoints(int points, String reason, {String? metadata}) async {
    try {
      final response = await _apiService.post('/api/gamification/points/add', {
        'points': points,
        'reason': reason,
        'metadata': metadata,
      });
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> checkAchievements() async {
    try {
      final response = await _apiService.get('/api/gamification/achievements/check');
      return List<Map<String, dynamic>>.from(response['new_achievements'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateStreak(bool activityCompleted) async {
    try {
      final response = await _apiService.post('/api/gamification/streak/update', {
        'activity_completed': activityCompleted,
      });
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> useStreakFreeze() async {
    try {
      final response = await _apiService.post('/api/gamification/streak/freeze', {});
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeChallenge(String challengeId) async {
    try {
      final response = await _apiService.post('/api/gamification/challenges/$challengeId/complete', {});
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> claimReward(String rewardId) async {
    try {
      final response = await _apiService.post('/api/gamification/rewards/$rewardId/claim', {});
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.get('/api/gamification/stats');
      return response;
    } catch (e) {
      return {
        'total_points_earned': 0,
        'badges_earned': 0,
        'challenges_completed': 0,
        'longest_streak': 0,
        'average_daily_points': 0,
        'favorite_category': 'N/A',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getAchievementHistory({int limit = 20}) async {
    try {
      final response = await _apiService.get('/api/gamification/achievements/history?limit=$limit');
      return List<Map<String, dynamic>>.from(response['achievements'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getLevelInfo(int level) async {
    try {
      final response = await _apiService.get('/api/gamification/levels/$level');
      return response;
    } catch (e) {
      return {
        'level': level,
        'min_points': (level - 1) * 100,
        'max_points': level * 100,
        'title': 'Level $level',
        'description': 'Reach level $level to unlock new features!',
        'unlocks': [],
      };
    }
  }
}
