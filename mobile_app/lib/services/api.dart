import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android emulator: use 'http://10.0.2.2:8000'
  // For iOS simulator: use 'http://localhost:8000' 
  // For physical device: use your computer's local IP address (e.g., 'http://192.168.1.100:8000')
  static String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

  static String? _token;
  static Map<String, dynamic>? _me;

  Future<bool> register(String email, String password, String fullName, bool isTeacher) async {
    final res = await http.post(Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'full_name': fullName, 'is_teacher': isTeacher}));
    return res.statusCode == 201;
  }

  Future<bool> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['access_token'];
      await _fetchMe();
      return true;
    }
    return false;
  }

  Future<void> _fetchMe() async {
    if (_token == null) return;
    final res = await http.get(Uri.parse('$baseUrl/api/auth/me'), headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      _me = jsonDecode(res.body);
    }
  }

  Map<String, dynamic>? me() => _me;

  Future<List<dynamic>> listCourses() async {
    final res = await http.get(Uri.parse('$baseUrl/api/courses/'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> myCourses() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/courses/mine'), headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return [];
  }

  Future<bool> createCourse(String title, String desc) async {
    if (_token == null) return false;
    final res = await http.post(Uri.parse('$baseUrl/api/courses/'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'title': title, 'description': desc}));
    return res.statusCode == 201;
  }
}
