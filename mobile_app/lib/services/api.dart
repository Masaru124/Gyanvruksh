import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Hosted API URL
  static String baseUrl = const String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://gyanvruksh.onrender.com');

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
    // Clean the input to remove any unwanted characters
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    print("🌐 Making login request to: $baseUrl/api/auth/login");
    print("📤 Request body: ${jsonEncode({'email': cleanEmail, 'password': cleanPassword})}");

    final res = await http.post(Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': cleanEmail, 'password': cleanPassword}));

    print("📥 Response status: ${res.statusCode}");
    print("📥 Response body: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['access_token'];
      print("✅ Token received: ${_token != null ? 'Yes' : 'No'}");
      await _fetchMe();
      return true;
    }
    return false;
  }

  Future<void> _fetchMe() async {
    if (_token == null) {
      print("⚠️ No token available for _fetchMe");
      return;
    }
    print("👤 Fetching user data from: $baseUrl/api/auth/me");
    final res = await http.get(Uri.parse('$baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $_token'});
    print("👤 _fetchMe response status: ${res.statusCode}");
    print("👤 _fetchMe response body: ${res.body}");
    if (res.statusCode == 200) {
      _me = jsonDecode(res.body);
      print("✅ User data fetched successfully: $_me");
    } else {
      print("❌ Failed to fetch user data");
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
    if (_token == null) {
      print("❌ No token available for createCourse");
      return false;
    }

    print("📚 Making createCourse request to: $baseUrl/api/courses/");
    print("📤 Request body: ${jsonEncode({'title': title, 'description': desc})}");
    print("🔑 Using token: ${_token != null ? 'Yes' : 'No'}");

    final res = await http.post(Uri.parse('$baseUrl/api/courses/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({'title': title, 'description': desc}));

    print("📥 Create course response status: ${res.statusCode}");
    print("📥 Create course response body: ${res.body}");

    final success = res.statusCode == 201;
    print("📚 Create course result: $success");

    return success;
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

  Future<List<dynamic>> getLeaderboard() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/gyanvruksh/leaderboard'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (_token == null) return null;
    final res = await http.get(Uri.parse('$baseUrl/api/gyanvruksh/profile'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  // Admin course management API methods
  Future<bool> assignTeacherToCourse(int courseId, int teacherId) async {
    if (_token == null) {
      print("❌ No token available for assignTeacherToCourse");
      return false;
    }

    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/api/courses/admin/$courseId/assign-teacher').replace(queryParameters: {
      'teacher_id': teacherId.toString(),
    });

    print("👨‍🏫 Making assignTeacherToCourse request to: $uri");
    print("📤 Query parameters: teacher_id=$teacherId");
    print("🔑 Using token: ${_token != null ? 'Yes' : 'No'}");

    final res = await http.post(uri,
        headers: {'Authorization': 'Bearer $_token'});

    print("📥 Assign teacher response status: ${res.statusCode}");
    print("📥 Assign teacher response body: ${res.body}");

    final success = res.statusCode == 200;
    print("👨‍🏫 Assign teacher result: $success");

    return success;
  }

  Future<bool> uploadCourseVideo(int courseId, String title, String url, {String? description}) async {
    if (_token == null) {
      print("❌ No token available for uploadCourseVideo");
      return false;
    }

    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/api/courses/admin/$courseId/upload-video').replace(queryParameters: {
      'title': title,
      'url': url,
      if (description != null) 'description': description,
    });

    print("🎥 Making uploadCourseVideo request to: $uri");
    print("📤 Query parameters: title=$title, url=$url, description=$description");
    print("🔑 Using token: ${_token != null ? 'Yes' : 'No'}");

    final res = await http.post(uri,
        headers: {'Authorization': 'Bearer $_token'});

    print("📥 Upload video response status: ${res.statusCode}");
    print("📥 Upload video response body: ${res.body}");

    final success = res.statusCode == 200;
    print("🎥 Upload video result: $success");

    return success;
  }

  Future<bool> uploadCourseNote(int courseId, String title, String content) async {
    if (_token == null) {
      print("❌ No token available for uploadCourseNote");
      return false;
    }

    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/api/courses/admin/$courseId/upload-note').replace(queryParameters: {
      'title': title,
      'content': content,
    });

    print("📝 Making uploadCourseNote request to: $uri");
    print("📤 Query parameters: title=$title, content=$content");
    print("🔑 Using token: ${_token != null ? 'Yes' : 'No'}");

    final res = await http.post(uri,
        headers: {'Authorization': 'Bearer $_token'});

    print("📥 Upload note response status: ${res.statusCode}");
    print("📥 Upload note response body: ${res.body}");

    final success = res.statusCode == 200;
    print("📝 Upload note result: $success");

    return success;
  }

  Future<List<dynamic>> getCourseVideos(int courseId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/courses/$courseId/videos'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getCourseNotes(int courseId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/courses/$courseId/notes'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getChatMessages() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/chat/messages'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
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
