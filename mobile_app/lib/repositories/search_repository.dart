import 'package:gyanvruksh/services/enhanced_api_service.dart';

class SearchRepository {
  Future<Map<String, dynamic>> search({
    required String query,
    Map<String, dynamic>? filters,
    String sortBy = 'relevance',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.post('/api/search', {
        'query': query,
        'filters': filters ?? {},
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page,
        'limit': limit,
      });
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'results': [],
        'metadata': {},
        'total': 0,
      };
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
      final response = await ApiService.get('/api/search/suggestions?q=$query');
      return response.isSuccess ? List<String>.from(response.data['suggestions'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableCategories() async {
    try {
      final response = await ApiService.get('/api/search/categories');
      return response.isSuccess ? List<Map<String, dynamic>>.from(response.data['categories'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getSearchHistory() async {
    try {
      final response = await ApiService.get('/api/search/history');
      return response.isSuccess ? List<String>.from(response.data['history'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getPopularSearches() async {
    try {
      final response = await ApiService.get('/api/search/popular');
      return response.isSuccess ? List<String>.from(response.data['popular'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingTopics() async {
    try {
      final response = await ApiService.get('/api/search/trending');
      return response.isSuccess ? List<Map<String, dynamic>>.from(response.data['trending'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentSearches() async {
    try {
      final response = await ApiService.get('/api/search/recent');
      return response.isSuccess ? List<Map<String, dynamic>>.from(response.data['recent'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarkedResults() async {
    try {
      final response = await ApiService.get('/api/search/bookmarks');
      return response.isSuccess ? List<Map<String, dynamic>>.from(response.data['bookmarks'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  Future<void> addToSearchHistory(String query) async {
    try {
      await ApiService.post('/api/search/history/add', {'query': query});
    } catch (e) {
      // silently fail
    }
  }

  Future<void> removeFromSearchHistory(String query) async {
    try {
      await ApiService.post('/api/search/history/remove', {'query': query});
    } catch (e) {
      // silently fail
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await ApiService.post('/api/search/history/clear', {});
    } catch (e) {
      // silently fail
    }
  }

  Future<bool> toggleBookmark(Map<String, dynamic> result) async {
    try {
      final response = await ApiService.post('/api/search/bookmarks/toggle', {'result': result});
      return response.isSuccess ? (response.data['bookmarked'] ?? false) : false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> advancedSearch({
    required String query,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final response = await ApiService.post('/api/search/advanced', {
        'query': query,
        'filters': filters,
      });
      return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {
        'results': [],
        'metadata': {},
        'total': 0,
      };
    } catch (e) {
      return {
        'results': [],
        'metadata': {},
        'total': 0,
      };
    }
  }
}
