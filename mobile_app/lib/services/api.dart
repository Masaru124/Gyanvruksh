import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiService {
  // Flexible API configuration for different environments
  static String get baseUrl {
    // Check for environment variable first (never null, but could be empty)
    const String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // For development, try localhost first, then fallback to common IPs
    const String defaultLocalUrl = 'http://10.0.2.2:8000'; // Android emulator uses 10.0.2.2 for host

    // You can also configure this based on platform or other conditions
    return defaultLocalUrl;
  }

  // Alternative configuration for different environments
  static const Map<String, String> _environmentUrls = {
    'development': 'http://10.0.2.2:8000', // Android emulator host
    'development_local': 'http://localhost:8000', // Direct localhost for web/desktop
    'staging': 'https://staging.gyanvruksh.com',
    'production': 'https://gyanvruksh.onrender.com',
  };

  // Helper method to get URL for specific environment
  static String getUrlForEnvironment(String environment) {
    return _environmentUrls[environment] ?? _environmentUrls['development']!;
  }

  // Helper method to check if we're in development mode
  static bool get isDevelopment {
    return baseUrl.contains('10.0.2.2') || baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');
  }

  // Helper method to check if we're using Android emulator
  static bool get isAndroidEmulator {
    return baseUrl.contains('10.0.2.2');
  }

  // Helper method to check if we're using direct localhost (web/desktop)
  static bool get isDirectLocalhost {
    return baseUrl.contains('localhost:8000');
  }

  // Helper method to check if we're in production
  static bool get isProduction {
    return baseUrl.contains('render.com') || baseUrl.contains('gyanvruksh.com');
  }

  // Network connectivity helper
  static Future<bool> checkNetworkConnectivity() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/healthz')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Runtime URL switching for testing
  static void setBaseUrl(String newUrl) {
    // This would require making baseUrl non-const, but for now we'll use environment variables
    print('⚠️  To change base URL, use --dart-define=API_BASE_URL=<new_url> when running the app');
    print('Example: flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000');
  }

  // Get helpful error message for network issues
  static String getNetworkErrorMessage(dynamic error) {
    if (error is SocketException) {
      if (isDevelopment) {
        return 'Cannot connect to development server at $baseUrl. Make sure the backend is running and accessible from your device.';
      } else {
        return 'No internet connection. Please check your network and try again.';
      }
    }
    if (error is HttpException) {
      return 'Server connection failed. Please try again later.';
    }
    return 'Network error occurred. Please try again.';
  }

  // Debug helper for development
  static void printDebugInfo() {
    print('🔧 API Debug Info:');
    print('Base URL: $baseUrl');
    print('Environment: ${isDevelopment ? 'Development' : 'Production'}');
    print('Token: ${_token != null ? 'Present' : 'Not present'}');
  }

  // Helper for local development setup
  static void printLocalDevelopmentInstructions() {
    print('🚀 Local Development Setup Instructions:');
    print('1. Make sure your backend server is running:');
    print('   cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload');
    print('');
    print('2. Find your computer\'s IP address:');
    print('   Windows: ipconfig (look for IPv4 Address)');
    print('   Mac/Linux: ifconfig or ip addr (look for inet)');
    print('');
    print('3. Update your Flutter app to use your IP:');
    print('   flutter run --dart-define=API_BASE_URL=http://YOUR_IP_ADDRESS:8000');
    print('');
    print('4. Common IP addresses to try:');
    print('   - 192.168.1.xxx (most common for home networks)');
    print('   - 10.0.2.2 (Android emulator localhost)');
    print('   - 127.0.0.1 (computer localhost - won\'t work on mobile)');
    print('');
    print('Current configuration: $baseUrl');
  }

  static String? _token;
  static Map<String, dynamic>? _me;

  // Initialize service and load stored auth data
  static Future<void> initialize() async {
    _token = await AuthStorage.getToken();
    _me = await AuthStorage.getUserData();
  }

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

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Clean the input to remove any unwanted characters
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      final res = await http.post(Uri.parse('$baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': cleanEmail, 'password': cleanPassword}));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['access_token'];

        // Fetch user data
        await _fetchMe();

        // Save auth data persistently
        if (_me != null) {
          await AuthStorage.saveAuthData(_token!, _me!);
        }

        return {'success': true};
      } else if (res.statusCode == 401) {
        return {'success': false, 'error': 'Invalid email or password'};
      } else if (res.statusCode == 422) {
        return {'success': false, 'error': 'Invalid input data'};
      } else {
        return {'success': false, 'error': 'Login failed. Please try again.'};
      }
    } on SocketException catch (e) {
      return {'success': false, 'error': getNetworkErrorMessage(e)};
    } on HttpException catch (e) {
      return {'success': false, 'error': getNetworkErrorMessage(e)};
    } on FormatException {
      return {'success': false, 'error': 'Invalid response from server'};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
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

  // Student convenience methods
  Future<Map<String, dynamic>> getStudentDashboard() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/dashboard/stats'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      final raw = jsonDecode(res.body) as Map<String, dynamic>;
      // Map backend structure to UI-expected flat keys
      final enrollments = raw['enrollments'] as Map<String, dynamic>? ?? {};
      final progress = raw['progress'] as Map<String, dynamic>? ?? {};
      final attendance = raw['attendance'] as Map<String, dynamic>? ?? {};
      final assignments = raw['assignments'] as Map<String, dynamic>? ?? {};

      return {
        'enrolled_courses': enrollments['total'] ?? 0,
        'completed_courses': progress['completed_courses'] ?? 0,
        'total_study_hours': raw['total_study_hours'] ?? 0,
        'current_streak': (raw['gyan_coins'] != null) ? 0 : 0, // placeholder; use getLearningStreak for streak
        // Optionally include extra sections if UI wants them later
        'enrollments_section': enrollments,
        'progress_section': progress,
        'attendance_section': attendance,
        'assignments_section': assignments,
      };
    }
    return {};
  }

  Future<List<dynamic>> getTodaySchedule() async {
    if (_token == null) return [];
    final uri = Uri.parse('$baseUrl/api/student/upcoming-deadlines?days_ahead=1');
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final deadlines = (data['upcoming_deadlines'] as List<dynamic>? ?? []);
      // Map to UI-friendly structure: title, time, type
      return deadlines.map((d) {
        if (d['type'] == 'assignment') {
          return {
            'title': d['title'] ?? 'Assignment',
            'time': (d['due_date'] ?? '').toString(),
            'type': 'assignment',
          };
        } else {
          return {
            'title': d['title'] ?? 'Lesson',
            'time': (d['scheduled_at'] ?? '').toString(),
            'type': 'live_class',
          };
        }
      }).toList();
    }
    return [];
  }

  Future<List<dynamic>> getStudentAssignments() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/assignments/'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> createAssignment({
    required String title,
    required String description,
    required int courseId,
    int? lessonId,
    required DateTime dueDate,
    int maxScore = 100,
    String? instructions,
    String? attachmentUrl,
  }) async {
    if (_token == null) return null;
    final body = {
      'title': title,
      'description': description,
      'course_id': courseId,
      if (lessonId != null) 'lesson_id': lessonId,
      'due_date': dueDate.toIso8601String(),
      'max_score': maxScore,
      if (instructions != null && instructions.isNotEmpty) 'instructions': instructions,
      if (attachmentUrl != null && attachmentUrl.isNotEmpty) 'attachment_url': attachmentUrl,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/api/assignments/'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> gradeAssignmentNewInternal({
    required int assignmentId,
    required int studentId,
    required int score,
    String? feedback,
  }) async {
    if (_token == null) return null;
    final res = await http.post(
      Uri.parse('$baseUrl/api/assignments/$assignmentId/grade'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'assignment_id': assignmentId,
        'student_id': studentId,
        'score': score,
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<dynamic>> getAssignmentGrades(int assignmentId) async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/api/assignments/$assignmentId/grades'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  // Course enrollment (new method)
  Future<bool> enrollInCourseNew(int courseId) async {
    if (_token == null) return false;
    final res = await http.post(
      Uri.parse('$baseUrl/api/student/enroll'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode({'course_id': courseId}),
    );
    return res.statusCode == 200;
  }

  // Notifications
  Future<List<dynamic>> getNotifications() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<bool> markNotificationRead(int notificationId) async {
    if (_token == null) return false;
    final res = await http.patch(
      Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    return res.statusCode == 200;
  }

  // Profile update
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
  }) async {
    if (_token == null) return false;
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    
    final res = await http.patch(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return res.statusCode == 200;
  }

  // Attendance management
  Future<List<dynamic>> getCourseAttendanceSessions(int courseId) async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/api/courses/$courseId/attendance/sessions'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  // Quiz management for teachers
  Future<List<dynamic>> getTeacherQuizzes() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/api/teacher/quizzes'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> createQuiz({
    required String title,
    required String description,
    required int courseId,
    required int timeLimit,
    required List<Map<String, dynamic>> questions,
  }) async {
    if (_token == null) return null;
    final res = await http.post(
      Uri.parse('$baseUrl/api/quizzes'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'course_id': courseId,
        'time_limit': timeLimit,
        'questions': questions,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> updateQuizStatus(int quizId, bool isPublished) async {
    if (_token == null) return false;
    final res = await http.patch(
      Uri.parse('$baseUrl/api/quizzes/$quizId'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode({'is_published': isPublished}),
    );
    return res.statusCode == 200;
  }

  // Fix enrollment issues
  Future<bool> enrollInCourseFixed(int courseId) async {
    if (_token == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/courses/$courseId/enroll'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'course_id': courseId}),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('Enrollment error: $e');
      return false;
    }
  }

  // Get course enrollments for teachers
  Future<List<dynamic>> getCourseEnrollments(int courseId) async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/api/courses/$courseId/enrollments'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  // Get all enrollments for a teacher's courses
  Future<Map<String, dynamic>> getTeacherEnrollmentStats() async {
    if (_token == null) return {};
    final res = await http.get(
      Uri.parse('$baseUrl/api/teacher/enrollment-stats'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>?> createAttendanceSession({
    required int courseId,
    required String sessionName,
    required DateTime sessionDate,
  }) async {
    if (_token == null) return null;
    final res = await http.post(
      Uri.parse('$baseUrl/api/courses/$courseId/attendance/sessions'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_name': sessionName,
        'session_date': sessionDate.toIso8601String(),
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> markAttendance({
    required int sessionId,
    required int studentId,
    required bool isPresent,
  }) async {
    if (_token == null) return false;
    final res = await http.post(
      Uri.parse('$baseUrl/api/attendance/mark'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'student_id': studentId,
        'is_present': isPresent,
      }),
    );
    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>> getLearningStreak() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/progress-report'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final current = data['study_streak'] ?? 0;
      // Backend does not provide longest; mirror current as a placeholder
      return {
        'current_streak': current,
        'longest_streak': current,
      };
    }
    return {'current_streak': 0, 'longest_streak': 0};
  }

  Future<Map<String, dynamic>> getStudentProgressReport() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/progress-report'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

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

  Future<bool> createCourseWithDetails({
    required String title,
    required String description,
    int? totalHours,
    String? difficulty,
    String? thumbnailUrl,
    bool? isPublished,
  }) async {
    if (_token == null) {
      return false;
    }

    final body = <String, dynamic>{
      'title': title,
      'description': description,
      if (totalHours != null) 'total_hours': totalHours,
      if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) 'thumbnail_url': thumbnailUrl,
      if (isPublished != null) 'is_published': isPublished,
    };

    final res = await http.post(
      Uri.parse('$baseUrl/api/courses/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(body),
    );

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

  // Admin course management API methods (legacy - see admin section below for new implementation)

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

  Future<bool> updateCourseDetails({
    required int courseId,
    String? title,
    String? description,
    int? totalHours,
    String? difficulty,
    String? thumbnailUrl,
    bool? isPublished,
  }) async {
    if (_token == null) return false;
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (totalHours != null) 'total_hours': totalHours,
      if (difficulty != null) 'difficulty': difficulty,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (isPublished != null) 'is_published': isPublished,
    };
    if (body.isEmpty) return true; // nothing to update

    final res = await http.put(
      Uri.parse('$baseUrl/api/courses/admin/$courseId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(body),
    );
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

  // Profile update API method (legacy)
  Future<bool> updateProfileLegacy({
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

  // Personalization API methods
  Future<Map<String, dynamic>?> getPersonalizationData() async {
    if (_token == null) return null;
    final res = await http.get(Uri.parse('$baseUrl/api/gyanvruksh/profile'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> updatePersonalizationData(Map<String, dynamic> data) async {
    if (_token == null) return false;
    final res = await http.put(Uri.parse('$baseUrl/api/gyanvruksh/profile'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(data));
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getRecommendedCourses() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/courses/recommended'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  // Dashboard API methods
  Future<List<dynamic>> getRecentCourses() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/dashboard/student/recent-courses'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> getTeacherDashboardStats() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/dashboard/teacher/dashboard-stats'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<dynamic>> getRecommendations() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/dashboard/recommendations'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getNotificationsLegacy() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/dashboard/notifications'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  // Generic HTTP methods for new endpoints
  Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = <String, String>{};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    final res = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $endpoint failed: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    final res = await http.post(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: jsonEncode(data));
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $endpoint failed: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    final res = await http.put(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: jsonEncode(data));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('PUT $endpoint failed: ${res.statusCode}');
  }

  Future<bool> delete(String endpoint) async {
    final headers = <String, String>{};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    final res = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // Admin endpoints
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/admin/dashboard/stats'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<dynamic>> getAllUsers({String? role, int skip = 0, int limit = 100}) async {
    if (_token == null) return [];
    String url = '$baseUrl/api/admin/users?skip=$skip&limit=$limit';
    if (role != null) url += '&role=$role';
    
    final res = await http.get(Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getPendingTeachers() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/admin/teachers/pending'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> approveTeacher(int teacherId, bool approved) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/admin/teachers/approve'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'teacher_id': teacherId,
        'approved': approved,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<dynamic>> getUnassignedCourses() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/admin/courses/unassigned'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> assignTeacherToCourse(int courseId, int teacherId) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/admin/courses/assign-teacher'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_id': courseId,
        'teacher_id': teacherId,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> updateCourseStatus(int courseId, bool isPublished) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/admin/courses/update-status'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_id': courseId,
        'is_published': isPublished,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Attendance endpoints (legacy - use newer methods above)

  Future<Map<String, dynamic>> getLessonAttendanceDetails(int lessonId) async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/attendance/lesson/$lessonId/details'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getStudentAttendanceHistory(int studentId, {int? courseId}) async {
    if (_token == null) return {};
    String url = '$baseUrl/api/attendance/student/$studentId/history';
    if (courseId != null) url += '?course_id=$courseId';
    
    final res = await http.get(Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getCourseAttendanceAnalytics(int courseId) async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/attendance/analytics/course/$courseId'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Enhanced admin endpoints
  Future<Map<String, dynamic>> bulkUserAction(List<int> userIds, String action) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/admin/users/bulk-action'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_ids': userIds,
        'action': action,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getSystemHealth() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/admin/system/health'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> bulkPublishCourses(List<int> courseIds, bool publish) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/admin/courses/bulk-publish'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_ids': courseIds,
        'publish': publish,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Student-specific endpoints
  Future<Map<String, dynamic>> getStudentStats() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/dashboard/stats'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<dynamic>> getStudentRecommendedCourses({int limit = 10}) async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/student/courses/recommended?limit=$limit'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getLearningPath() async {
    if (_token == null) return [];
    final res = await http.get(Uri.parse('$baseUrl/api/student/learning-path'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> getStudentAchievements() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/achievements'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getUpcomingDeadlines({int daysAhead = 7}) async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/upcoming-deadlines?days_ahead=$daysAhead'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> generateStudyPlan(int courseId, DateTime targetDate, int dailyHours) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/student/study-plan/generate'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_id': courseId,
        'target_completion_date': targetDate.toIso8601String(),
        'daily_study_hours': dailyHours,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Progress report endpoint
  Future<Map<String, dynamic>> getProgressReport() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/progress-report'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Study groups endpoints
  Future<Map<String, dynamic>> getStudyGroups() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/study-groups'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> joinStudyGroup(int groupId) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/student/study-groups/$groupId/join'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Doubts endpoints
  Future<Map<String, dynamic>> getStudentDoubts() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/student/doubts'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> askDoubt(String question, int courseId) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/student/doubts'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'question': question,
        'course_id': courseId,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Course enrollment endpoint (detailed response)
  Future<Map<String, dynamic>> enrollInCourseDetailed(int courseId) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/student/courses/$courseId/enroll'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Teacher-specific endpoints
  Future<Map<String, dynamic>> getTeacherAdvancedStats() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/teacher/dashboard/stats'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getTeacherPerformanceAnalytics() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/teacher/analytics/performance'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getStudentManagementData() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/teacher/students/management'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> createAnnouncement(int courseId, String title, String message) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/teacher/communication/announcement'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_id': courseId,
        'title': title,
        'message': message,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getTeacherMessages() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/teacher/communication/messages'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> gradeAssignment(int studentId, int courseId, int assignmentId, double grade, String feedback) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/teacher/grading/assignment'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'course_id': courseId,
        'assignment_id': assignmentId,
        'grade': grade,
        'feedback': feedback,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> getContentLibrary() async {
    if (_token == null) return {};
    final res = await http.get(Uri.parse('$baseUrl/api/teacher/content/library'),
        headers: {'Authorization': 'Bearer $_token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> uploadContent(String title, String contentType, String description) async {
    if (_token == null) return {};
    final res = await http.post(
      Uri.parse('$baseUrl/api/teacher/content/upload'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content_type': contentType,
        'description': description,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Generic GET method for flexibility
  Future<dynamic> apiGet(String endpoint) async {
    if (_token == null) return null;
    final res = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  // Generic POST method for flexibility
  Future<dynamic> apiPost(String endpoint, Map<String, dynamic> data) async {
    if (_token == null) return null;
    final res = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    return null;
  }
}
