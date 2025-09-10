abstract class BaseRepository {
  Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      // Log error or handle it appropriately
      rethrow;
    }
  }
}
