import 'package:flutter/material.dart';
import '../services/api.dart';
import '../repositories/gamification_repository.dart';

class GamificationViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final GamificationRepository _gamificationRepository = GamificationRepository();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingAchievements = false;
  String? _error;

  // Points and scoring
  int _totalPoints = 0;
  int _currentLevel = 1;
  int _pointsToNextLevel = 100;
  int _weeklyPoints = 0;
  int _monthlyPoints = 0;

  // Streaks
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _streakFreezeCount = 0;
  bool _streakActive = false;
  DateTime? _lastActivityDate;

  // Badges and achievements
  List<Map<String, dynamic>> _earnedBadges = [];
  List<Map<String, dynamic>> _availableBadges = [];
  List<Map<String, dynamic>> _recentAchievements = [];
  Map<String, dynamic> _badgeProgress = {};

  // Leaderboards
  List<Map<String, dynamic>> _globalLeaderboard = [];
  List<Map<String, dynamic>> _friendsLeaderboard = [];
  Map<String, dynamic> _userRank = {};

  // Daily/Weekly challenges
  List<Map<String, dynamic>> _dailyChallenges = [];
  List<Map<String, dynamic>> _weeklyChallenges = [];
  Map<String, dynamic> _challengeProgress = {};

  // Rewards and unlocks
  List<Map<String, dynamic>> _availableRewards = [];
  List<Map<String, dynamic>> _claimedRewards = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingAchievements => _isLoadingAchievements;
  String? get error => _error;

  int get totalPoints => _totalPoints;
  int get currentLevel => _currentLevel;
  int get pointsToNextLevel => _pointsToNextLevel;
  int get weeklyPoints => _weeklyPoints;
  int get monthlyPoints => _monthlyPoints;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get streakFreezeCount => _streakFreezeCount;
  bool get streakActive => _streakActive;
  DateTime? get lastActivityDate => _lastActivityDate;

  List<Map<String, dynamic>> get earnedBadges => _earnedBadges;
  List<Map<String, dynamic>> get availableBadges => _availableBadges;
  List<Map<String, dynamic>> get recentAchievements => _recentAchievements;
  Map<String, dynamic> get badgeProgress => _badgeProgress;

  List<Map<String, dynamic>> get globalLeaderboard => _globalLeaderboard;
  List<Map<String, dynamic>> get friendsLeaderboard => _friendsLeaderboard;
  Map<String, dynamic> get userRank => _userRank;

  List<Map<String, dynamic>> get dailyChallenges => _dailyChallenges;
  List<Map<String, dynamic>> get weeklyChallenges => _weeklyChallenges;
  Map<String, dynamic> get challengeProgress => _challengeProgress;

  List<Map<String, dynamic>> get availableRewards => _availableRewards;
  List<Map<String, dynamic>> get claimedRewards => _claimedRewards;

  // Computed properties
  double get levelProgress => _pointsToNextLevel > 0
      ? (_totalPoints % 100) / 100.0
      : 1.0;

  int get nextLevelPoints => _currentLevel * 100;
  int get currentLevelMinPoints => (_currentLevel - 1) * 100;

  bool get canUseStreakFreeze => _streakFreezeCount > 0;
  bool get isStreakAtRisk => _currentStreak > 0 && !_streakActive;

  // Initialize and load gamification data
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadPointsAndLevel(),
        loadStreaks(),
        loadBadges(),
        loadLeaderboards(),
        loadChallenges(),
        loadRewards(),
      ]);
    } catch (e) {
      _error = 'Failed to load gamification data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPointsAndLevel() async {
    try {
      final pointsData = await _gamificationRepository.getPointsAndLevel();
      _totalPoints = pointsData['total_points'] ?? 0;
      _currentLevel = pointsData['current_level'] ?? 1;
      _pointsToNextLevel = pointsData['points_to_next'] ?? 100;
      _weeklyPoints = pointsData['weekly_points'] ?? 0;
      _monthlyPoints = pointsData['monthly_points'] ?? 0;
    } catch (e) {
      debugPrint('Error loading points and level: $e');
    }
  }

  Future<void> loadStreaks() async {
    try {
      final streakData = await _gamificationRepository.getStreaks();
      _currentStreak = streakData['current_streak'] ?? 0;
      _longestStreak = streakData['longest_streak'] ?? 0;
      _streakFreezeCount = streakData['freeze_count'] ?? 0;
      _streakActive = streakData['streak_active'] ?? false;
      _lastActivityDate = streakData['last_activity'] != null
          ? DateTime.parse(streakData['last_activity'])
          : null;
    } catch (e) {
      debugPrint('Error loading streaks: $e');
    }
  }

  Future<void> loadBadges() async {
    _isLoadingAchievements = true;
    notifyListeners();

    try {
      final badgesData = await _gamificationRepository.getBadges();
      _earnedBadges = List<Map<String, dynamic>>.from(badgesData['earned'] ?? []);
      _availableBadges = List<Map<String, dynamic>>.from(badgesData['available'] ?? []);
      _recentAchievements = List<Map<String, dynamic>>.from(badgesData['recent'] ?? []);
      _badgeProgress = badgesData['progress'] ?? {};
    } catch (e) {
      debugPrint('Error loading badges: $e');
    } finally {
      _isLoadingAchievements = false;
      notifyListeners();
    }
  }

  Future<void> loadLeaderboards() async {
    try {
      final leaderboardData = await _gamificationRepository.getLeaderboards();
      _globalLeaderboard = List<Map<String, dynamic>>.from(leaderboardData['global'] ?? []);
      _friendsLeaderboard = List<Map<String, dynamic>>.from(leaderboardData['friends'] ?? []);
      _userRank = leaderboardData['user_rank'] ?? {};
    } catch (e) {
      debugPrint('Error loading leaderboards: $e');
    }
  }

  Future<void> loadChallenges() async {
    try {
      final challengesData = await _gamificationRepository.getChallenges();
      _dailyChallenges = List<Map<String, dynamic>>.from(challengesData['daily'] ?? []);
      _weeklyChallenges = List<Map<String, dynamic>>.from(challengesData['weekly'] ?? []);
      _challengeProgress = challengesData['progress'] ?? {};
    } catch (e) {
      debugPrint('Error loading challenges: $e');
    }
  }

  Future<void> loadRewards() async {
    try {
      final rewardsData = await _gamificationRepository.getRewards();
      _availableRewards = List<Map<String, dynamic>>.from(rewardsData['available'] ?? []);
      _claimedRewards = List<Map<String, dynamic>>.from(rewardsData['claimed'] ?? []);
    } catch (e) {
      debugPrint('Error loading rewards: $e');
    }
  }

  // Points and leveling
  Future<bool> addPoints(int points, String reason, {String? metadata}) async {
    try {
      final success = await _gamificationRepository.addPoints(points, reason, metadata: metadata);
      if (success) {
        await loadPointsAndLevel();
        await checkForNewAchievements();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to add points: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> checkForNewAchievements() async {
    try {
      final newAchievements = await _gamificationRepository.checkAchievements();
      if (newAchievements.isNotEmpty) {
        _recentAchievements.insertAll(0, newAchievements);
        await loadBadges();
        // TODO: Show achievement notification
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  // Streak management
  Future<bool> updateStreak(bool activityCompleted) async {
    try {
      final success = await _gamificationRepository.updateStreak(activityCompleted);
      if (success) {
        await loadStreaks();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to update streak: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> useStreakFreeze() async {
    if (!canUseStreakFreeze) return false;

    try {
      final success = await _gamificationRepository.useStreakFreeze();
      if (success) {
        await loadStreaks();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to use streak freeze: $e';
      notifyListeners();
      return false;
    }
  }

  // Challenge management
  Future<bool> completeChallenge(String challengeId) async {
    try {
      final success = await _gamificationRepository.completeChallenge(challengeId);
      if (success) {
        await loadChallenges();
        await addPoints(50, 'challenge_completed', metadata: challengeId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to complete challenge: $e';
      notifyListeners();
      return false;
    }
  }

  // Reward management
  Future<bool> claimReward(String rewardId) async {
    try {
      final success = await _gamificationRepository.claimReward(rewardId);
      if (success) {
        await loadRewards();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to claim reward: $e';
      notifyListeners();
      return false;
    }
  }

  // Badge utilities
  bool hasBadge(String badgeId) {
    return _earnedBadges.any((badge) => badge['id'] == badgeId);
  }

  Map<String, dynamic>? getBadge(String badgeId) {
    return _earnedBadges.firstWhere(
      (badge) => badge['id'] == badgeId,
      orElse: () => _availableBadges.firstWhere(
        (badge) => badge['id'] == badgeId,
        orElse: () => {},
      ),
    );
  }

  double getBadgeProgress(String badgeId) {
    final progress = _badgeProgress[badgeId];
    if (progress == null) return 0.0;
    return (progress['current'] ?? 0) / (progress['target'] ?? 1);
  }

  // Leaderboard utilities
  int getUserGlobalRank() {
    return _userRank['global_rank'] ?? 0;
  }

  int getUserFriendsRank() {
    return _userRank['friends_rank'] ?? 0;
  }

  // Challenge utilities
  List<Map<String, dynamic>> getActiveChallenges() {
    return [..._dailyChallenges, ..._weeklyChallenges]
        .where((challenge) => challenge['status'] == 'active')
        .toList();
  }

  Map<String, dynamic>? getChallengeProgress(String challengeId) {
    return _challengeProgress[challengeId];
  }

  // Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await initialize();
  }
}
