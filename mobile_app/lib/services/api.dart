import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android emulator: use 'http://10.0.2.2:8000'
  // For iOS simulator: use 'http://localhost:8000'
  // For physical device: use your computer's local IP address (e.g., 'http://192.168.1.100:8000')
  static String baseUrl = const String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.29.96:8000');

  static String? _token;
  static Map<String, dynamic>? _me;

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    int? age,
    String? gender,
    required String role,
    required String subRole,
    String? educationalQualification,
    String? preferredLanguage,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? aadharCard,
    String? accountDetails,
    DateTime? dob,
    String? maritalStatus,
    int? yearOfExperience,
    String? parentsContactDetails,
    String? parentsEmail,
    String? sellerType,
    String? companyId,
    String? sellerRecord,
    String? companyDetails,
    bool isTeacher = false,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'age': age,
          'gender': gender,
          'role': role,
          'sub_role': subRole,
          'educational_qualification': educationalQualification,
          'preferred_language': preferredLanguage,
          'phone_number': phoneNumber,
          'address': address,
          'emergency_contact': emergencyContact,
          'aadhar_card': aadharCard,
          'account_details': accountDetails,
          'dob': dob?.toIso8601String(),
          'marital_status': maritalStatus,
          'year_of_experience': yearOfExperience,
          'parents_contact_details': parentsContactDetails,
          'parents_email': parentsEmail,
          'seller_type': sellerType,
          'company_id': companyId,
          'seller_record': sellerRecord,
          'company_details': companyDetails,
          'is_teacher': isTeacher,
        }));
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
    final res = await http.get(Uri.parse('$baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $_token'});
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
    final res = await http.get(Uri.parse('$baseUrl/api/courses/mine'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return [];
  }

  Future<bool> createCourse(String title, String desc) async {
    if (_token == null) return false;
    final res = await http.post(Uri.parse('$baseUrl/api/courses/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({'title': title, 'description': desc}));
    return res.statusCode == 201;
  }

  Future<bool> createAdmin({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String gender,
    required String role,
    required String subRole,
  }) async {
    if (_token == null) return false;
    final res = await http.post(Uri.parse('$baseUrl/api/auth/admin/create-admin'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'age': age,
          'gender': gender,
          'role': role,
          'sub_role': subRole,
          'educational_qualification': null,
          'preferred_language': null,
          'is_teacher': false,
        }));
    return res.statusCode == 201;
  }

  Future<List<dynamic>> listUsers() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/auth/admin/users'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<bool> deleteUser(int userId) async {
    if (_token == null) return false;
    final res = await http.delete(Uri.parse('$baseUrl/api/auth/admin/users/\$userId'),
        headers: {'Authorization': 'Bearer $_token'});
    return res.statusCode == 200;
  }

  // Teacher Dashboard API methods
  Future<List<dynamic>> availableCourses() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/courses/available'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<bool> selectCourse(int courseId) async {
    if (_token == null) return false;
    final res = await http.post(Uri.parse('$baseUrl/api/courses/$courseId/select'),
        headers: {'Authorization': 'Bearer $_token'});
    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>> teacherStats() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/courses/teacher/stats'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<dynamic>> upcomingClasses() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/courses/teacher/upcoming-classes'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> studentQueries() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/courses/teacher/student-queries'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<bool> logout() async {
    if (_token == null) return false;
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/auth/logout'),
          headers: {'Authorization': 'Bearer $_token'});
      // Clear local token regardless of server response
      _token = null;
      _me = null;
      return res.statusCode == 200;
    } catch (e) {
      // Clear local token even if server call fails
      _token = null;
      _me = null;
      return true;
    }
  }

  // Enrollment API methods
  Future<bool> enrollInCourse(int courseId) async {
    if (_token == null) return false;
    final res = await http.post(Uri.parse('$baseUrl/api/courses/enroll'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'course_id': courseId}));
    return res.statusCode == 201;
  }

  Future<List<dynamic>> getEnrolledCourses() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/courses/enrolled'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<bool> unenrollFromCourse(int courseId) async {
    if (_token == null) return false;
    final res = await http.delete(Uri.parse('$baseUrl/api/courses/enroll/$courseId'),
        headers: {'Authorization': 'Bearer $_token'});
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getAvailableCoursesForEnrollment() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/courses/available-for-enrollment'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> getCourseDetails(int courseId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/courses/$courseId/details'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  // Profile update API method
  Future<bool> updateProfile({
    String? fullName,
    int? age,
    String? gender,
    String? phoneNumber,
    String? address,
    String? educationalQualification,
    String? preferredLanguage,
  }) async {
    if (_token == null) return false;
    final updateData = {
      if (fullName != null) 'full_name': fullName,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (address != null) 'address': address,
      if (educationalQualification != null) 'educational_qualification': educationalQualification,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
    };

    final res = await http.put(Uri.parse('$baseUrl/api/auth/me'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(updateData));

    if (res.statusCode == 200) {
      // Update local user data
      final updatedUser = jsonDecode(res.body);
      _me = updatedUser;
      return true;
    }
    return false;
  }
}
