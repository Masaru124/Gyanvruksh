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

    final res = await http.post(Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': cleanEmail, 'password': cleanPassword}));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['access_token'];
      await _fetchMe();
      return true;
    }
    return false;
  }

  Future<void> _fetchMe() async {
    if (_token == null) {
      return;
    }
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
    if (_token == null) {
      return false;
    }

    final res = await http.post(Uri.parse('$baseUrl/api/courses/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({'title': title, 'description': desc}));

    final success = res.statusCode == 201;
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
      return false;
    }

    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/api/courses/admin/$courseId/assign-teacher').replace(queryParameters: {
      'teacher_id': teacherId.toString(),
    });

    final res = await http.post(uri,
        headers: {'Authorization': 'Bearer $_token'});

    final success = res.statusCode == 200;
    return success;
  }

  Future<bool> uploadCourseVideo(int courseId, String title, String url, {String? description}) async {
    if (_token == null) {
      return false;
    }

    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/api/courses/admin/$courseId/upload-video').replace(queryParameters: {
      'title': title,
      'url': url,
      if (description != null) 'description': description,
    });

    final res = await http.post(uri,
        headers: {'Authorization': 'Bearer $_token'});

    final success = res.statusCode == 200;
    return success;
  }

  Future<bool> uploadCourseNote(int courseId, String title, String content) async {
    if (_token == null) {
      return false;
    }

    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/api/courses/admin/$courseId/upload-note').replace(queryParameters: {
      'title': title,
      'content': content,
    });

    final res = await http.post(uri,
        headers: {'Authorization': 'Bearer $_token'});

    final success = res.statusCode == 200;
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

  // Admin course management API methods - additional
  Future<bool> deleteCourse(int courseId) async {
    if (_token == null) return false;
    final res = await http.delete(Uri.parse('$baseUrl/api/courses/admin/$courseId'),
        headers: {'Authorization': 'Bearer $_token'});
    return res.statusCode == 200;
  }

  Future<bool> updateCourse(int courseId, String title, String description) async {
    if (_token == null) return false;
    final res = await http.put(Uri.parse('$baseUrl/api/courses/admin/$courseId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'title': title, 'description': description}));
    return res.statusCode == 200;
  }

  Future<bool> deleteCourseVideo(int courseId, int videoId) async {
    if (_token == null) return false;
    final res = await http.delete(Uri.parse('$baseUrl/api/courses/admin/$courseId/videos/$videoId'),
        headers: {'Authorization': 'Bearer $_token'});
    return res.statusCode == 200;
  }

  Future<bool> updateCourseVideo(int courseId, int videoId, String title, String url, {String? description}) async {
    if (_token == null) return false;
    final res = await http.put(Uri.parse('$baseUrl/api/courses/admin/$courseId/videos/$videoId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'title': title, 'url': url, 'description': description}));
    return res.statusCode == 200;
  }

  Future<bool> deleteCourseNote(int courseId, int noteId) async {
    if (_token == null) return false;
    final res = await http.delete(Uri.parse('$baseUrl/api/courses/admin/$courseId/notes/$noteId'),
        headers: {'Authorization': 'Bearer $_token'});
    return res.statusCode == 200;
  }

  Future<bool> updateCourseNote(int courseId, int noteId, String title, String content) async {
    if (_token == null) return false;
    final res = await http.put(Uri.parse('$baseUrl/api/courses/admin/$courseId/notes/$noteId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'title': title, 'content': content}));
    return res.statusCode == 200;
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

  // Categories API methods
  Future<List<dynamic>> getCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/api/categories/'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> getCategory(int categoryId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/categories/$categoryId'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  // Lessons API methods
  Future<List<dynamic>> getLessons({int? courseId}) async {
    final uri = Uri.parse('$baseUrl/api/lessons/').replace(queryParameters: {
      if (courseId != null) 'course_id': courseId.toString(),
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> getLesson(int lessonId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/lessons/$lessonId'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> createLesson(int courseId, String title, String description, String contentType,
      {String? contentUrl, String? contentText, int durationMinutes = 0, int orderIndex = 0, bool isFree = false}) async {
    if (_token == null) return false;
    final res = await http.post(Uri.parse('$baseUrl/api/lessons/'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({
          'course_id': courseId,
          'title': title,
          'description': description,
          'content_type': contentType,
          'content_url': contentUrl,
          'content_text': contentText,
          'duration_minutes': durationMinutes,
          'order_index': orderIndex,
          'is_free': isFree,
        }));
    return res.statusCode == 201;
  }

  // Quizzes API methods
  Future<List<dynamic>> getQuizzes({int? courseId}) async {
    final uri = Uri.parse('$baseUrl/api/quizzes/').replace(queryParameters: {
      if (courseId != null) 'course_id': courseId.toString(),
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> getQuiz(int quizId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/quizzes/$quizId'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<dynamic>> getQuizQuestions(int quizId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/quizzes/$quizId/questions'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> submitQuizAttempt(int quizId, Map<String, dynamic> answers) async {
    if (_token == null) return null;
    final res = await http.post(Uri.parse('$baseUrl/api/quizzes/$quizId/attempt'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'answers': answers}));
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<dynamic>> getQuizAttempts(int quizId) async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/quizzes/$quizId/attempts'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  // Progress API methods
  Future<Map<String, dynamic>?> getCourseProgress(int courseId) async {
    if (_token == null) return null;
    final res = await http.get(Uri.parse('$baseUrl/api/progress/courses/$courseId'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> updateLessonProgress(int courseId, int lessonId, double progressPercentage,
      {bool completed = false, int timeSpentMinutes = 0}) async {
    if (_token == null) return false;
    final res = await http.post(Uri.parse('$baseUrl/api/progress/courses/$courseId/lessons/$lessonId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({
          'progress_percentage': progressPercentage,
          'completed': completed,
          'time_spent_minutes': timeSpentMinutes,
        }));
    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (_token == null) return null;
    final res = await http.get(Uri.parse('$baseUrl/api/progress/preferences'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> updateUserPreferences({
    List<String>? preferredCategories,
    String? skillLevel,
    List<String>? learningGoals,
    int? dailyStudyTime,
    bool? notificationsEnabled,
  }) async {
    if (_token == null) return false;
    final updateData = {
      if (preferredCategories != null) 'preferred_categories': jsonEncode(preferredCategories),
      if (skillLevel != null) 'skill_level': skillLevel,
      if (learningGoals != null) 'learning_goals': jsonEncode(learningGoals),
      if (dailyStudyTime != null) 'daily_study_time': dailyStudyTime,
      if (notificationsEnabled != null) 'notifications_enabled': notificationsEnabled,
    };

    final res = await http.put(Uri.parse('$baseUrl/api/progress/preferences'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(updateData));
    return res.statusCode == 200;
  }
}
