import '../services/api.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _apiService.login(email, password);
    } catch (e) {
      return {'success': false, 'error': 'Login failed: ${e.toString()}'};
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String subRole,
  }) async {
    return await handleApiCall(() => _apiService.register(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
          subRole: subRole,
        ));
  }

  Map<String, dynamic>? getCurrentUser() {
    return _apiService.me();
  }

  Future<void> logout() async {
    await handleApiCall(() async {
      // Clear any cached data if needed
    });
  }
}
