import 'package:flutter/material.dart';
import '../repositories/personalization_repository.dart';
import '../services/api.dart';

class PersonalizationViewModel extends ChangeNotifier {
  final PersonalizationRepository _repository = PersonalizationRepository();
  final ApiService _apiService = ApiService();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingRecommendations = false;
  bool _isLoadingAnalytics = false;
  String? _error;

  // Available options
  final List<String> availableInterests = [
    'Mathematics',
    'Science',
    'Languages',
    'Programming',
    'Design',
    'Music',
    'Dance',
    'Sports',
    'Art',
    'Literature',
    'History',
    'Geography',
  ];

  final List<String> availableSkillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  final List<String> availableGoals = [
    'Academic Excellence',
    'Skill Development',
    'Career Advancement',
    'Personal Growth',
    'Certification',
    'Competition Preparation',
    'Creative Expression',
    'Physical Fitness',
  ];

  final List<String> availableLearningStyles = [
    'Visual',
    'Auditory',
    'Reading/Writing',
    'Kinesthetic',
  ];

  final List<String> availablePacePreferences = [
    'Slow and Steady',
    'Moderate',
    'Fast-paced',
    'Intensive',
  ];

  // User selections
  List<String> _selectedInterests = [];
  Map<String, String> _skillLevels = {};
  List<String> _learningGoals = [];
  List<String> _learningStyles = [];
  String _pacePreference = 'Moderate';
  int _dailyStudyTime = 30; // minutes
  bool _notificationsEnabled = true;
  String _preferredLanguage = 'English';
  Map<String, dynamic> _schedulePreferences = {};

  // Adaptive learning data
  Map<String, dynamic> _learningAnalytics = {};
  List<Map<String, dynamic>> _learningPatterns = [];
  Map<String, dynamic> _performanceMetrics = {};
  List<String> _strengthAreas = [];
  List<String> _improvementAreas = [];

  // Recommendations
  List<Map<String, dynamic>> _courseRecommendations = [];
  List<Map<String, dynamic>> _lessonRecommendations = [];
  List<Map<String, dynamic>> _skillGapRecommendations = [];
  Map<String, dynamic> _adaptiveSuggestions = {};

  // User behavior tracking
  Map<String, dynamic> _engagementMetrics = {};
  List<Map<String, dynamic>> _contentInteractions = [];
  Map<String, dynamic> _timeAnalytics = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get error => _error;

  List<String> get selectedInterests => _selectedInterests;
  Map<String, String> get skillLevels => _skillLevels;
  List<String> get learningGoals => _learningGoals;
  List<String> get learningStyles => _learningStyles;
  String get pacePreference => _pacePreference;
  int get dailyStudyTime => _dailyStudyTime;
  bool get notificationsEnabled => _notificationsEnabled;
  String get preferredLanguage => _preferredLanguage;
  Map<String, dynamic> get schedulePreferences => _schedulePreferences;

  Map<String, dynamic> get learningAnalytics => _learningAnalytics;
  List<Map<String, dynamic>> get learningPatterns => _learningPatterns;
  Map<String, dynamic> get performanceMetrics => _performanceMetrics;
  List<String> get strengthAreas => _strengthAreas;
  List<String> get improvementAreas => _improvementAreas;

  List<Map<String, dynamic>> get courseRecommendations => _courseRecommendations;
  List<Map<String, dynamic>> get lessonRecommendations => _lessonRecommendations;
  List<Map<String, dynamic>> get skillGapRecommendations => _skillGapRecommendations;
  Map<String, dynamic> get adaptiveSuggestions => _adaptiveSuggestions;

  Map<String, dynamic> get engagementMetrics => _engagementMetrics;
  List<Map<String, dynamic>> get contentInteractions => _contentInteractions;
  Map<String, dynamic> get timeAnalytics => _timeAnalytics;

  // Computed properties
  double get personalizationScore {
    int score = 0;
    if (_selectedInterests.isNotEmpty) score += 25;
    if (_learningGoals.isNotEmpty) score += 25;
    if (_learningStyles.isNotEmpty) score += 25;
    if (_schedulePreferences.isNotEmpty) score += 25;
    return score.toDouble();
  }

  String get personalizationLevel {
    final score = personalizationScore;
    if (score >= 90) return 'Highly Personalized';
    if (score >= 70) return 'Well Personalized';
    if (score >= 50) return 'Moderately Personalized';
    if (score >= 25) return 'Basic Personalization';
    return 'Not Personalized';
  }

  // Initialize with default skill levels
  PersonalizationViewModel() {
    _initializeSkillLevels();
  }

  void _initializeSkillLevels() {
    for (final interest in availableInterests) {
      _skillLevels[interest] = 'Beginner';
    }
  }

  // Load user preferences from backend
  Future<void> loadUserPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final preferences = await _repository.getUserPreferences();

      _selectedInterests = List<String>.from(preferences['interests'] ?? []);
      _skillLevels = Map<String, String>.from(preferences['skill_levels'] ?? {});
      _learningGoals = List<String>.from(preferences['goals'] ?? []);
      _learningStyles = List<String>.from(preferences['learning_styles'] ?? []);
      _pacePreference = preferences['pace_preference'] ?? 'Moderate';
      _dailyStudyTime = preferences['daily_study_time'] ?? 30;
      _notificationsEnabled = preferences['notifications_enabled'] ?? true;
      _preferredLanguage = preferences['preferred_language'] ?? 'English';
      _schedulePreferences = preferences['schedule_preferences'] ?? {};

      // Initialize skill levels if empty
      if (_skillLevels.isEmpty) {
        _initializeSkillLevels();
      }
    } catch (e) {
      _error = 'Failed to load preferences: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user preferences to backend
  Future<bool> saveUserPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.saveUserPreferences({
        'interests': _selectedInterests,
        'skill_levels': _skillLevels,
        'goals': _learningGoals,
        'learning_styles': _learningStyles,
        'pace_preference': _pacePreference,
        'daily_study_time': _dailyStudyTime,
        'notifications_enabled': _notificationsEnabled,
        'preferred_language': _preferredLanguage,
        'schedule_preferences': _schedulePreferences,
      });

      if (success) {
        await _updateRecommendations();
      }

      return success;
    } catch (e) {
      _error = 'Failed to save preferences: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load learning analytics
  Future<void> loadLearningAnalytics() async {
    _isLoadingAnalytics = true;
    notifyListeners();

    try {
      final analytics = await _repository.getLearningAnalytics();
      _learningAnalytics = analytics['analytics'] ?? {};
      _learningPatterns = List<Map<String, dynamic>>.from(analytics['patterns'] ?? []);
      _performanceMetrics = analytics['performance'] ?? {};
      _strengthAreas = List<String>.from(analytics['strengths'] ?? []);
      _improvementAreas = List<String>.from(analytics['improvements'] ?? []);
    } catch (e) {
      debugPrint('Error loading learning analytics: $e');
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  // Load recommendations
  Future<void> loadRecommendations() async {
    _isLoadingRecommendations = true;
    notifyListeners();

    try {
      await _updateRecommendations();
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  Future<void> _updateRecommendations() async {
    try {
      final recommendations = await _repository.getPersonalizedRecommendations();

      _courseRecommendations = List<Map<String, dynamic>>.from(
          recommendations['courses'] ?? []);
      _lessonRecommendations = List<Map<String, dynamic>>.from(
          recommendations['lessons'] ?? []);
      _skillGapRecommendations = List<Map<String, dynamic>>.from(
          recommendations['skill_gaps'] ?? []);
      _adaptiveSuggestions = recommendations['adaptive'] ?? {};
    } catch (e) {
      debugPrint('Error updating recommendations: $e');
    }
  }

  // Toggle interest selection
  void toggleInterest(String interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
    notifyListeners();
  }

  // Set skill level for a category
  void setSkillLevel(String category, String level) {
    _skillLevels[category] = level;
    notifyListeners();
  }

  // Toggle learning goal
  void toggleGoal(String goal) {
    if (_learningGoals.contains(goal)) {
      _learningGoals.remove(goal);
    } else {
      _learningGoals.add(goal);
    }
    notifyListeners();
  }

  // Toggle learning style
  void toggleLearningStyle(String style) {
    if (_learningStyles.contains(style)) {
      _learningStyles.remove(style);
    } else {
      _learningStyles.add(style);
    }
    notifyListeners();
  }

  // Set pace preference
  void setPacePreference(String pace) {
    _pacePreference = pace;
    notifyListeners();
  }

  // Set daily study time
  void setDailyStudyTime(int minutes) {
    _dailyStudyTime = minutes;
    notifyListeners();
  }

  // Toggle notifications
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Set preferred language
  void setPreferredLanguage(String language) {
    _preferredLanguage = language;
    notifyListeners();
  }

  // Update schedule preferences
  void updateSchedulePreferences(Map<String, dynamic> preferences) {
    _schedulePreferences = preferences;
    notifyListeners();
  }

  // Track user interaction
  Future<void> trackInteraction(String contentType, String contentId,
      String interactionType, {Map<String, dynamic>? metadata}) async {
    try {
      await _repository.trackUserInteraction(
        contentType,
        contentId,
        interactionType,
        metadata: metadata,
      );

      // Update local analytics
      await loadLearningAnalytics();
      await loadRecommendations();
    } catch (e) {
      debugPrint('Error tracking interaction: $e');
    }
  }

  // Get adaptive content suggestions
  Map<String, dynamic> getAdaptiveSuggestionsForContent(String contentId) {
    return _adaptiveSuggestions[contentId] ?? {};
  }

  // Get personalized study plan
  Future<Map<String, dynamic>> getPersonalizedStudyPlan() async {
    try {
      return await _repository.getStudyPlan();
    } catch (e) {
      return {
        'daily_goals': [],
        'weekly_targets': [],
        'skill_focus': [],
        'recommended_schedule': {},
      };
    }
  }

  // Reset to defaults
  void resetToDefaults() {
    _selectedInterests.clear();
    _initializeSkillLevels();
    _learningGoals.clear();
    _learningStyles.clear();
    _pacePreference = 'Moderate';
    _dailyStudyTime = 30;
    _notificationsEnabled = true;
    _preferredLanguage = 'English';
    _schedulePreferences.clear();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize all data
  Future<void> initialize() async {
    await loadUserPreferences();
    await loadLearningAnalytics();
    await loadRecommendations();
  }
}
