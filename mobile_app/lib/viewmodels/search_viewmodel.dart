import 'package:flutter/material.dart';
import '../services/api.dart';
import '../repositories/search_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SearchRepository _searchRepository = SearchRepository();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingSuggestions = false;
  bool _isLoadingFilters = false;
  String? _error;

  // Search state
  String _searchQuery = '';
  String _lastSearchQuery = '';
  List<String> _searchHistory = [];
  List<String> _popularSearches = [];

  // Search results
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic> _searchMetadata = {};
  int _currentPage = 1;
  bool _hasMoreResults = false;
  int _totalResults = 0;

  // Filters and sorting
  Map<String, dynamic> _activeFilters = {};
  String _sortBy = 'relevance';
  String _sortOrder = 'desc';

  // Content type filters
  List<String> _selectedContentTypes = [];
  final List<String> availableContentTypes = [
    'course',
    'lesson',
    'quiz',
    'assignment',
    'article',
    'video',
    'audio',
    'interactive',
  ];

  // Category filters
  List<String> _selectedCategories = [];
  List<Map<String, dynamic>> _availableCategories = [];

  // Difficulty filters
  List<String> _selectedDifficulties = [];
  final List<String> availableDifficulties = [
    'beginner',
    'intermediate',
    'advanced',
    'expert',
  ];

  // Duration filters
  RangeValues _durationRange = const RangeValues(0, 300); // minutes
  List<String> _selectedDurations = [];

  // Language filters
  List<String> _selectedLanguages = [];
  final List<String> availableLanguages = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
  ];

  // Search suggestions
  List<String> _searchSuggestions = [];
  List<Map<String, dynamic>> _trendingTopics = [];

  // Recent searches and bookmarks
  List<Map<String, dynamic>> _recentSearches = [];
  List<Map<String, dynamic>> _bookmarkedResults = [];

  // Advanced search options
  bool _includeArchived = false;
  bool _exactMatch = false;
  bool _searchInContent = true;
  bool _searchInTitles = true;
  bool _searchInDescriptions = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  bool get isLoadingFilters => _isLoadingFilters;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String get lastSearchQuery => _lastSearchQuery;
  List<String> get searchHistory => _searchHistory;
  List<String> get popularSearches => _popularSearches;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  Map<String, dynamic> get searchMetadata => _searchMetadata;
  int get currentPage => _currentPage;
  bool get hasMoreResults => _hasMoreResults;
  int get totalResults => _totalResults;

  Map<String, dynamic> get activeFilters => _activeFilters;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;

  List<String> get selectedContentTypes => _selectedContentTypes;
  List<String> get selectedCategories => _selectedCategories;
  List<Map<String, dynamic>> get availableCategories => _availableCategories;

  List<String> get selectedDifficulties => _selectedDifficulties;
  RangeValues get durationRange => _durationRange;
  List<String> get selectedDurations => _selectedDurations;

  List<String> get selectedLanguages => _selectedLanguages;

  List<String> get searchSuggestions => _searchSuggestions;
  List<Map<String, dynamic>> get trendingTopics => _trendingTopics;

  List<Map<String, dynamic>> get recentSearches => _recentSearches;
  List<Map<String, dynamic>> get bookmarkedResults => _bookmarkedResults;

  bool get includeArchived => _includeArchived;
  bool get exactMatch => _exactMatch;
  bool get searchInContent => _searchInContent;
  bool get searchInTitles => _searchInTitles;
  bool get searchInDescriptions => _searchInDescriptions;

  // Computed properties
  bool get hasActiveFilters => _activeFilters.isNotEmpty;
  bool get hasSearchQuery => _searchQuery.isNotEmpty;
  bool get hasResults => _searchResults.isNotEmpty;

  int get activeFilterCount {
    int count = 0;
    if (_selectedContentTypes.isNotEmpty) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedDifficulties.isNotEmpty) count++;
    if (_selectedLanguages.isNotEmpty) count++;
    if (_selectedDurations.isNotEmpty) count++;
    if (_includeArchived) count++;
    if (_exactMatch) count++;
    return count;
  }

  // Initialize search
  Future<void> initialize() async {
    await Future.wait([
      loadSearchHistory(),
      loadPopularSearches(),
      loadAvailableCategories(),
      loadTrendingTopics(),
      loadRecentSearches(),
      loadBookmarkedResults(),
    ]);
  }

  // Search functionality
  Future<void> search(String query, {bool append = false}) async {
    if (query.trim().isEmpty) return;

    _searchQuery = query.trim();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _searchRepository.search(
        query: _searchQuery,
        filters: _buildSearchFilters(),
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: append ? _currentPage + 1 : 1,
        limit: 20,
      );

      if (append) {
        _searchResults.addAll(List<Map<String, dynamic>>.from(results['results'] ?? []));
        _currentPage++;
      } else {
        _searchResults = List<Map<String, dynamic>>.from(results['results'] ?? []);
        _currentPage = 1;
        _lastSearchQuery = _searchQuery;
        await _addToSearchHistory(_searchQuery);
      }

      _searchMetadata = results['metadata'] ?? {};
      _totalResults = results['total'] ?? 0;
      _hasMoreResults = (_currentPage * 20) < _totalResults;

    } catch (e) {
      _error = 'Search failed: $e';
      _searchResults = [];
      _totalResults = 0;
      _hasMoreResults = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreResults() async {
    if (!hasMoreResults || isLoading) return;
    await search(_searchQuery, append: true);
  }

  // Search suggestions
  Future<void> getSearchSuggestions(String query) async {
    if (query.length < 2) {
      _searchSuggestions = [];
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      _searchSuggestions = await _searchRepository.getSearchSuggestions(query);
    } catch (e) {
      _searchSuggestions = [];
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  // Filter management
  Future<void> loadAvailableCategories() async {
    _isLoadingFilters = true;
    notifyListeners();

    try {
      _availableCategories = await _searchRepository.getAvailableCategories();
    } catch (e) {
      _availableCategories = [];
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }
  }

  void toggleContentType(String contentType) {
    if (_selectedContentTypes.contains(contentType)) {
      _selectedContentTypes.remove(contentType);
    } else {
      _selectedContentTypes.add(contentType);
    }
    _updateActiveFilters();
    notifyListeners();
  }

  void toggleCategory(String categoryId) {
    if (_selectedCategories.contains(categoryId)) {
      _selectedCategories.remove(categoryId);
    } else {
      _selectedCategories.add(categoryId);
    }
    _updateActiveFilters();
    notifyListeners();
  }

  void toggleDifficulty(String difficulty) {
    if (_selectedDifficulties.contains(difficulty)) {
      _selectedDifficulties.remove(difficulty);
    } else {
      _selectedDifficulties.add(difficulty);
    }
    _updateActiveFilters();
    notifyListeners();
  }

  void toggleLanguage(String language) {
    if (_selectedLanguages.contains(language)) {
      _selectedLanguages.remove(language);
    } else {
      _selectedLanguages.add(language);
    }
    _updateActiveFilters();
    notifyListeners();
  }

  void setDurationRange(RangeValues range) {
    _durationRange = range;
    _updateActiveFilters();
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setSortOrder(String sortOrder) {
    _sortOrder = sortOrder;
    notifyListeners();
  }

  void setIncludeArchived(bool include) {
    _includeArchived = include;
    _updateActiveFilters();
    notifyListeners();
  }

  void setExactMatch(bool exact) {
    _exactMatch = exact;
    _updateActiveFilters();
    notifyListeners();
  }

  void setSearchScopes({bool? inContent, bool? inTitles, bool? inDescriptions}) {
    if (inContent != null) _searchInContent = inContent;
    if (inTitles != null) _searchInTitles = inTitles;
    if (inDescriptions != null) _searchInDescriptions = inDescriptions;
    _updateActiveFilters();
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedContentTypes.clear();
    _selectedCategories.clear();
    _selectedDifficulties.clear();
    _selectedLanguages.clear();
    _selectedDurations.clear();
    _durationRange = const RangeValues(0, 300);
    _includeArchived = false;
    _exactMatch = false;
    _searchInContent = true;
    _searchInTitles = true;
    _searchInDescriptions = true;
    _activeFilters.clear();
    notifyListeners();
  }

  void _updateActiveFilters() {
    _activeFilters = {
      if (_selectedContentTypes.isNotEmpty) 'content_types': _selectedContentTypes,
      if (_selectedCategories.isNotEmpty) 'categories': _selectedCategories,
      if (_selectedDifficulties.isNotEmpty) 'difficulties': _selectedDifficulties,
      if (_selectedLanguages.isNotEmpty) 'languages': _selectedLanguages,
      if (_selectedDurations.isNotEmpty) 'durations': _selectedDurations,
      'duration_range': {'min': _durationRange.start, 'max': _durationRange.end},
      'include_archived': _includeArchived,
      'exact_match': _exactMatch,
      'search_scopes': {
        'content': _searchInContent,
        'titles': _searchInTitles,
        'descriptions': _searchInDescriptions,
      },
    };
  }

  Map<String, dynamic> _buildSearchFilters() {
    final filters = Map<String, dynamic>.from(_activeFilters);
    filters['sort_by'] = _sortBy;
    filters['sort_order'] = _sortOrder;
    return filters;
  }

  // Search history management
  Future<void> loadSearchHistory() async {
    try {
      _searchHistory = await _searchRepository.getSearchHistory();
    } catch (e) {
      _searchHistory = [];
    }
  }

  Future<void> loadPopularSearches() async {
    try {
      _popularSearches = await _searchRepository.getPopularSearches();
    } catch (e) {
      _popularSearches = [];
    }
  }

  Future<void> loadTrendingTopics() async {
    try {
      _trendingTopics = await _searchRepository.getTrendingTopics();
    } catch (e) {
      _trendingTopics = [];
    }
  }

  Future<void> loadRecentSearches() async {
    try {
      _recentSearches = await _searchRepository.getRecentSearches();
    } catch (e) {
      _recentSearches = [];
    }
  }

  Future<void> loadBookmarkedResults() async {
    try {
      _bookmarkedResults = await _searchRepository.getBookmarkedResults();
    } catch (e) {
      _bookmarkedResults = [];
    }
  }

  Future<void> _addToSearchHistory(String query) async {
    try {
      await _searchRepository.addToSearchHistory(query);
      await loadSearchHistory();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> removeFromSearchHistory(String query) async {
    try {
      await _searchRepository.removeFromSearchHistory(query);
      await loadSearchHistory();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await _searchRepository.clearSearchHistory();
      _searchHistory.clear();
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  // Bookmark management
  Future<void> toggleBookmark(Map<String, dynamic> result) async {
    try {
      final isBookmarked = await _searchRepository.toggleBookmark(result);
      if (isBookmarked) {
        _bookmarkedResults.add(result);
      } else {
        _bookmarkedResults.removeWhere((item) => item['id'] == result['id']);
      }
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  bool isBookmarked(String resultId) {
    return _bookmarkedResults.any((item) => item['id'] == resultId);
  }

  // Advanced search
  Future<void> advancedSearch(Map<String, dynamic> advancedFilters) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _searchRepository.advancedSearch(
        query: _searchQuery,
        filters: advancedFilters,
      );

      _searchResults = List<Map<String, dynamic>>.from(results['results'] ?? []);
      _searchMetadata = results['metadata'] ?? {};
      _totalResults = results['total'] ?? 0;
      _hasMoreResults = false; // Advanced search doesn't support pagination

    } catch (e) {
      _error = 'Advanced search failed: $e';
      _searchResults = [];
      _totalResults = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Voice search
  Future<void> voiceSearch(String transcribedText) async {
    _searchQuery = transcribedText;
    await search(_searchQuery);
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    _searchMetadata.clear();
    _totalResults = 0;
    _hasMoreResults = false;
    _currentPage = 1;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh search
  Future<void> refreshSearch() async {
    if (_lastSearchQuery.isNotEmpty) {
      await search(_lastSearchQuery);
    }
  }
}
