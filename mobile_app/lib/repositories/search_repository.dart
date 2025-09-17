import '../services/api.dart';

class SearchRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> search({
    required String query,
    Map<String, dynamic>? filters,
    String sortBy = 'relevance',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.post('/api/search', {
        'query': query,
        'filters': filters ?? {},
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page,
        'limit': limit,
      });
      return response;
    } catch (e) {
      return {
        'results': [],
        'metadata': {},
        'total': 0,
      };
    }
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final response = await _apiService.get('/api/search/suggestions?q=$query');
      return List<String>.from(response['suggestions'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableCategories() async {
    try {
      final response = await _apiService.get('/api/search/categories');
      return List<Map<String, dynamic>>.from(response['categories'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getSearchHistory() async {
    try {
      final response = await _apiService.get('/api/search/history');
      return List<String>.from(response['history'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getPopularSearches() async {
    try {
      final response = await _apiService.get('/api/search/popular');
      return List<String>.from(response['popular'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingTopics() async {
    try {
      final response = await _apiService.get('/api/search/trending');
      return List<Map<String, dynamic>>.from(response['trending'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentSearches() async {
    try {
      final response = await _apiService.get('/api/search/recent');
      return List<Map<String, dynamic>>.from(response['recent'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarkedResults() async {
    try {
      final response = await _apiService.get('/api/search/bookmarks');
      return List<Map<String, dynamic>>.from(response['bookmarks'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<void> addToSearchHistory(String query) async {
    try {
      await _apiService.post('/api/search/history/add', {'query': query});
    } catch (e) {
      // silently fail
    }
  }

  Future<void> removeFromSearchHistory(String query) async {
    try {
      await _apiService.post('/api/search/history/remove', {'query': query});
    } catch (e) {
      // silently fail
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await _apiService.post('/api/search/history/clear', {});
    } catch (e) {
      // silently fail
    }
  }

  Future<bool> toggleBookmark(Map<String, dynamic> result) async {
    try {
      final response = await _apiService.post('/api/search/bookmarks/toggle', {'result': result});
      return response['bookmarked'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> advancedSearch({
    required String query,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final response = await _apiService.post('/api/search/advanced', {
        'query': query,
        'filters': filters,
      });
      return response;
    } catch (e) {
      return {
        'results': [],
        'metadata': {},
        'total': 0,
      };
    }
  }
}
