import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'auth_storage.dart';

/// API Response wrapper class for consistent error handling
class ApiResponse {
  final bool isSuccess;
  final String userMessage;
  final String technicalMessage;
  final String operation;
  final dynamic data;

  ApiResponse._({
    required this.isSuccess,
    required this.userMessage,
    required this.technicalMessage,
    required this.operation,
    this.data,
  });

  factory ApiResponse.success(String message, {dynamic data}) {
    return ApiResponse._(
      isSuccess: true,
      userMessage: message,
      technicalMessage: 'Success',
      operation: 'API Call',
      data: data,
    );
  }

  factory ApiResponse.error({
    required String userMessage,
    required String technicalMessage,
    required String operation,
    dynamic data,
  }) {
    return ApiResponse._(
      isSuccess: false,
      userMessage: userMessage,
      technicalMessage: technicalMessage,
      operation: operation,
      data: data,
    );
  }

  /// Get the appropriate color for UI feedback
  Color get feedbackColor {
    return isSuccess ? Colors.green : Colors.red;
  }

  /// Get the appropriate icon for UI feedback
  IconData get feedbackIcon {
    return isSuccess ? Icons.check_circle : Icons.error;
  }
}

/// Enhanced API Service with comprehensive error handling and user feedback
class ApiService {
  // Local API URL for development
  static String baseUrl = const String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://gyanvruksh.onrender.com');

  static String? _token;
  static Map<String, dynamic>? _me;

  // Initialize service and load stored auth data
  static Future<void> initialize() async {
    _token = await AuthStorage.getToken();
    _me = await AuthStorage.getUserData();
  }

  /// Enhanced error handling with user-friendly messages
  static ApiResponse _handleError(dynamic error, String operation) {
    if (error is ApiResponse) {
      return error; // Already processed error
    }

    String userMessage = _getUserFriendlyErrorMessage(error, operation);
    String technicalMessage = error.toString();

    return ApiResponse.error(
      userMessage: userMessage,
      technicalMessage: technicalMessage,
      operation: operation,
    );
  }

  /// Convert technical errors to user-friendly messages
  static String _getUserFriendlyErrorMessage(dynamic error, String operation) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is HttpException) {
      return 'Server connection failed. Please try again later.';
    }

    if (error is FormatException) {
      return 'Received invalid data from server. Please try again.';
    }

    if (error is ApiResponse) {
      return error.userMessage;
    }

    // Default fallback
    return '$operation failed. Please try again.';
  }

  /// Show toast notification based on API response
  static void showToastFromResponse(ApiResponse response) {
    Fluttertoast.showToast(
      msg: response.userMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: response.isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Enhanced login with better error handling
  static Future<ApiResponse> login(String email, String password) async {
    try {
      // Clean the input to remove any unwanted characters
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': cleanEmail, 'password': cleanPassword}),
      );

      final responseData = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final tokenData = responseData;
        _token = tokenData['access_token'];

        // Fetch user data
        final userResponse = await _fetchMe();
        if (!userResponse.isSuccess) {
          return ApiResponse.error(
            userMessage: 'Login successful but failed to load profile. Please restart the app.',
            technicalMessage: 'Profile fetch failed after login',
            operation: 'Login + Profile Fetch',
          );
        }

        // Save auth data persistently
        if (_me != null) {
          await AuthStorage.saveAuthData(_token!, _me!);
        }

        showToastFromResponse(ApiResponse.success('Login successful!'));

        return ApiResponse.success('Login successful!', data: {
          'token': _token,
          'user': _me,
        });
      } else {
        // Handle specific error codes
        String userMessage = _getErrorMessageFromResponse(responseData, res.statusCode);
        return ApiResponse.error(
          userMessage: userMessage,
          technicalMessage: 'HTTP ${res.statusCode}: ${res.body}',
          operation: 'Login',
        );
      }
    } catch (e) {
      return _handleError(e, 'Login');
    }
  }

  /// Get current user profile
  static Future<ApiResponse> me() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/auth/me'),
          headers: _getAuthHeaders(),
        );
      },
      'Profile Fetch',
    );
  }

  /// Enhanced logout with cleanup
  static Future<ApiResponse> logout() async {
    if (_token == null) {
      return ApiResponse.success('Already logged out');
    }

    try {
      // Try to logout from server
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      // Clear local token regardless of server response
      _token = null;
      _me = null;
      await AuthStorage.clearAuthData();

      if (res.statusCode == 200) {
        showToastFromResponse(ApiResponse.success('Logged out successfully'));
        return ApiResponse.success('Logged out successfully');
      } else {
        showToastFromResponse(ApiResponse.success('Logged out locally'));
        return ApiResponse.success('Logged out locally');
      }
    } catch (e) {
      // Clear local token even if server call fails
      _token = null;
      _me = null;
      await AuthStorage.clearAuthData();

      showToastFromResponse(ApiResponse.success('Logged out locally'));
      return ApiResponse.success('Logged out locally');
    }
  }

  /// Enhanced API call wrapper with automatic error handling
  static Future<ApiResponse> _apiCall(
    Future<http.Response> Function() apiFunction,
    String operation, {
    bool showToast = true,
    bool autoRefreshToken = true,
  }) async {
    try {
      final response = await apiFunction();

      if (response.statusCode == 401 && autoRefreshToken) {
        // Try to refresh token
        final refreshResult = await _refreshTokenIfNeeded();
        if (refreshResult.isSuccess) {
          // Retry the original request
          final retryResponse = await apiFunction();
          return _processHttpResponse(retryResponse, operation, showToast);
        } else {
          return refreshResult;
        }
      }

      return _processHttpResponse(response, operation, showToast);
    } catch (e) {
      final errorResponse = _handleError(e, operation);
      if (showToast) {
        showToastFromResponse(errorResponse);
      }
      return errorResponse;
    }
  }

  /// Process HTTP response and convert to ApiResponse
  static ApiResponse _processHttpResponse(
    http.Response response,
    String operation,
    bool showToast,
  ) {
    try {
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final successResponse = ApiResponse.success(
          _getSuccessMessage(operation),
          data: responseData,
        );
        if (showToast) {
          showToastFromResponse(successResponse);
        }
        return successResponse;
      } else {
        String userMessage = _getErrorMessageFromResponse(responseData, response.statusCode);
        final errorResponse = ApiResponse.error(
          userMessage: userMessage,
          technicalMessage: 'HTTP ${response.statusCode}: ${response.body}',
          operation: operation,
        );
        if (showToast) {
          showToastFromResponse(errorResponse);
        }
        return errorResponse;
      }
    } catch (e) {
      // JSON parsing failed
      String userMessage = _getErrorMessageFromStatusCode(response.statusCode, operation);
      final errorResponse = ApiResponse.error(
        userMessage: userMessage,
        technicalMessage: 'HTTP ${response.statusCode} - Invalid JSON response',
        operation: operation,
      );
      if (showToast) {
        showToastFromResponse(errorResponse);
      }
      return errorResponse;
    }
  }

  /// Get user-friendly error messages from API response
  static String _getErrorMessageFromResponse(dynamic responseData, int statusCode) {
    if (responseData is Map && responseData.containsKey('error')) {
      final errorInfo = responseData['error'];
      if (errorInfo is Map && errorInfo.containsKey('message')) {
        return errorInfo['message'];
      }
    }

    return _getErrorMessageFromStatusCode(statusCode, 'API Call');
  }

  /// Get error messages based on HTTP status codes
  static String _getErrorMessageFromStatusCode(int statusCode, String operation) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with existing data.';
      case 422:
        return 'Invalid data provided. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error occurred. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return '$operation failed with status $statusCode. Please try again.';
    }
  }

  /// Get success messages for operations
  static String _getSuccessMessage(String operation) {
    switch (operation.toLowerCase()) {
      case 'login':
        return 'Login successful!';
      case 'register':
        return 'Account created successfully!';
      case 'update profile':
        return 'Profile updated successfully!';
      case 'create course':
        return 'Course created successfully!';
      case 'enroll in course':
        return 'Successfully enrolled in course!';
      case 'submit assignment':
        return 'Assignment submitted successfully!';
      case 'mark attendance':
        return 'Attendance recorded successfully!';
      default:
        return 'Operation completed successfully!';
    }
  }

  /// Token refresh logic
  static Future<ApiResponse> _refreshTokenIfNeeded() async {
    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null) {
        return ApiResponse.error(
          userMessage: 'Session expired. Please login again.',
          technicalMessage: 'No refresh token available',
          operation: 'Token Refresh',
        );
      }

      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (res.statusCode == 200) {
        final tokenData = jsonDecode(res.body);
        _token = tokenData['access_token'];
        final newRefreshToken = tokenData['refresh_token'];

        // Update stored tokens
        if (_me != null) {
          await AuthStorage.saveTokens(_token!, newRefreshToken);
        }

        return ApiResponse.success('Token refreshed successfully');
      } else {
        // Refresh failed, clear tokens
        _token = null;
        _me = null;
        await AuthStorage.clearAuthData();

        return ApiResponse.error(
          userMessage: 'Session expired. Please login again.',
          technicalMessage: 'Token refresh failed',
          operation: 'Token Refresh',
        );
      }
    } catch (e) {
      return _handleError(e, 'Token Refresh');
    }
  }

  /// Register a new user
  static Future<ApiResponse> register({
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
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/auth/register'),
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
          }),
        );
      },
      'User Registration',
    );
  }

  /// Get today's schedule
  static Future<ApiResponse> getTodaySchedule() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/teacher/upcoming-classes'),
          headers: _getAuthHeaders(),
        );
      },
      'Today Schedule',
    );
  }

  /// Get student progress report
  static Future<ApiResponse> getStudentProgressReport() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/progress/report'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Progress Report',
    );
  }

  /// Get student queries for teachers
  static Future<ApiResponse> studentQueries() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/teacher/student-queries'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Queries',
    );
  }

  /// List all users
  static Future<ApiResponse> listUsers() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/users'),
          headers: _getAuthHeaders(),
        );
      },
      'List Users',
    );
  }

  /// Get all available courses
  static Future<ApiResponse> listCourses() async {
    return _apiCall(
      () async {
        return await http.get(Uri.parse('$baseUrl/api/courses/'));
      },
      'List Courses',
    );
  }

  /// Get user's enrolled courses
  static Future<ApiResponse> myCourses() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/mine'),
          headers: _getAuthHeaders(),
        );
      },
      'My Courses',
    );
  }

  /// Create a new course
  static Future<ApiResponse> createCourse(String title, String description) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/courses/'),
          headers: _getAuthHeaders(),
          body: jsonEncode({'title': title, 'description': description}),
        );
      },
      'Create Course',
    );
  }

  /// Get available courses for enrollment
  static Future<ApiResponse> availableCourses() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/available'),
          headers: _getAuthHeaders(),
        );
      },
      'Available Courses',
    );
  }

  /// Select a course (for teachers)
  static Future<ApiResponse> selectCourse(int courseId) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/courses/$courseId/select'),
          headers: _getAuthHeaders(),
        );
      },
      'Select Course',
    );
  }

  /// Get teacher dashboard statistics
  static Future<ApiResponse> teacherStats() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/teacher/stats'),
          headers: _getAuthHeaders(),
        );
      },
      'Teacher Stats',
    );
  }

  /// Get upcoming classes for teachers
  static Future<ApiResponse> upcomingClasses() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/teacher/upcoming-classes'),
          headers: _getAuthHeaders(),
        );
      },
      'Upcoming Classes',
    );
  }

  /// Enhanced course enrollment with error handling
  static Future<ApiResponse> enrollInCourse(int courseId) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/student/courses/$courseId/enroll'),
          headers: _getAuthHeaders(),
        );
      },
      'Course Enrollment',
    );
  }

  /// Get enrolled courses
  static Future<ApiResponse> getEnrolledCourses() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/enrolled'),
          headers: _getAuthHeaders(),
        );
      },
      'Enrolled Courses',
    );
  }

  /// Unenroll from a course
  static Future<ApiResponse> unenrollFromCourse(int courseId) async {
    return _apiCall(
      () async {
        return await http.delete(
          Uri.parse('$baseUrl/api/courses/enroll/$courseId'),
          headers: _getAuthHeaders(),
        );
      },
      'Unenroll from Course',
    );
  }

  /// Get courses available for enrollment
  static Future<ApiResponse> getAvailableCoursesForEnrollment() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/available-for-enrollment'),
          headers: _getAuthHeaders(),
        );
      },
      'Available for Enrollment',
    );
  }

  /// Get course details
  static Future<ApiResponse> getCourseDetails(int courseId) async {
    return _apiCall(
      () async {
        return await http.get(Uri.parse('$baseUrl/api/courses/$courseId/details'));
      },
      'Course Details',
    );
  }

  /// Get course notes
  static Future<ApiResponse> getCourseNotes(int courseId) async {
    return _apiCall(
      () async {
        return await http.get(Uri.parse('$baseUrl/api/courses/$courseId/notes'));
      },
      'Course Notes',
    );
  }

  /// Get categories
  static Future<ApiResponse> getCategories() async {
    return _apiCall(
      () async {
        return await http.get(Uri.parse('$baseUrl/api/categories/'));
      },
      'Categories',
    );
  }

  /// Get lessons for a course
  static Future<ApiResponse> getLessons({int? courseId}) async {
    return _apiCall(
      () async {
        final uri = Uri.parse('$baseUrl/api/lessons/').replace(queryParameters: {
          if (courseId != null) 'course_id': courseId.toString(),
        });
        return await http.get(uri);
      },
      'Course Lessons',
    );
  }

  /// Get lesson details
  static Future<ApiResponse> getLesson(int lessonId) async {
    return _apiCall(
      () async {
        return await http.get(Uri.parse('$baseUrl/api/lessons/$lessonId'));
      },
      'Lesson Details',
    );
  }

  /// Create a lesson
  static Future<ApiResponse> createLesson(int courseId, String title, String description, String contentType,
      {String? contentUrl, String? contentText, int durationMinutes = 0, int orderIndex = 0, bool isFree = false}) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/lessons/'),
          headers: _getAuthHeaders(),
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
          }),
        );
      },
      'Create Lesson',
    );
  }

  /// Get quizzes for a course
  static Future<ApiResponse> getQuizzes({int? courseId}) async {
    return _apiCall(
      () async {
        final uri = Uri.parse('$baseUrl/api/quizzes/').replace(queryParameters: {
          if (courseId != null) 'course_id': courseId.toString(),
        });
        return await http.get(uri);
      },
      'Course Quizzes',
    );
  }

  /// Get quiz details
  static Future<ApiResponse> getQuiz(int quizId) async {
    return _apiCall(
      () async {
        return await http.get(Uri.parse('$baseUrl/api/quizzes/$quizId'));
      },
      'Quiz Details',
    );
  }

  /// Get quiz questions
  static Future<ApiResponse> getQuizQuestions(int quizId) async {
    return _apiCall(
      () async {
        return await http.get(Uri.parse('$baseUrl/api/quizzes/$quizId/questions'));
      },
      'Quiz Questions',
    );
  }

  /// Submit quiz attempt
  static Future<ApiResponse> submitQuizAttempt(int quizId, Map<String, dynamic> answers) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/quizzes/$quizId/attempt'),
          headers: _getAuthHeaders(),
          body: jsonEncode({'answers': answers}),
        );
      },
      'Submit Quiz',
    );
  }

  /// Get quiz attempts
  static Future<ApiResponse> getQuizAttempts(int quizId) async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/quizzes/$quizId/attempts'),
          headers: _getAuthHeaders(),
        );
      },
      'Quiz Attempts',
    );
  }

  /// Get course progress
  static Future<ApiResponse> getCourseProgress(int courseId) async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/progress/courses/$courseId'),
          headers: _getAuthHeaders(),
        );
      },
      'Course Progress',
    );
  }

  /// Update lesson progress
  static Future<ApiResponse> updateLessonProgress(int courseId, int lessonId, double progressPercentage,
      {bool completed = false, int timeSpentMinutes = 0}) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/progress/courses/$courseId/lessons/$lessonId'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'progress_percentage': progressPercentage,
            'completed': completed,
            'time_spent_minutes': timeSpentMinutes,
          }),
        );
      },
      'Update Lesson Progress',
    );
  }

  /// Get user preferences
  static Future<ApiResponse> getUserPreferences() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/progress/preferences'),
          headers: _getAuthHeaders(),
        );
      },
      'User Preferences',
    );
  }

  /// Update user preferences
  static Future<ApiResponse> updateUserPreferences({
    List<String>? preferredCategories,
    String? skillLevel,
    List<String>? learningGoals,
    int? dailyStudyTime,
    bool? notificationsEnabled,
  }) async {
    final updateData = <String, dynamic>{};
    if (preferredCategories != null) updateData['preferred_categories'] = jsonEncode(preferredCategories);
    if (skillLevel != null) updateData['skill_level'] = skillLevel;
    if (learningGoals != null) updateData['learning_goals'] = jsonEncode(learningGoals);
    if (dailyStudyTime != null) updateData['daily_study_time'] = dailyStudyTime;
    if (notificationsEnabled != null) updateData['notifications_enabled'] = notificationsEnabled;

    return _apiCall(
      () async {
        return await http.put(
          Uri.parse('$baseUrl/api/progress/preferences'),
          headers: _getAuthHeaders(),
          body: jsonEncode(updateData),
        );
      },
      'Update User Preferences',
    );
  }

  /// Get recommended courses for student
  static Future<ApiResponse> getRecommendedCourses() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/recommended'),
          headers: _getAuthHeaders(),
        );
      },
      'Recommended Courses',
    );
  }

  /// Update course details
  static Future<ApiResponse> updateCourseDetails({
    required int courseId,
    required String title,
    required String description,
    int? totalHours,
    String? difficulty,
    String? thumbnailUrl,
    bool? isPublished,
  }) async {
    final updateData = <String, dynamic>{
      'title': title,
      'description': description,
    };

    if (totalHours != null) updateData['total_hours'] = totalHours;
    if (difficulty != null) updateData['difficulty'] = difficulty;
    if (thumbnailUrl != null) updateData['thumbnail_url'] = thumbnailUrl;
    if (isPublished != null) updateData['is_published'] = isPublished;

    return _apiCall(
      () async {
        return await http.put(
          Uri.parse('$baseUrl/api/courses/$courseId'),
          headers: _getAuthHeaders(),
          body: jsonEncode(updateData),
        );
      },
      'Update Course Details',
    );
  }

  /// Update course
  static Future<ApiResponse> updateCourse(
    int courseId,
    String title,
    String description,
  ) async {
    return _apiCall(
      () async {
        return await http.put(
          Uri.parse('$baseUrl/api/courses/$courseId'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'title': title,
            'description': description,
          }),
        );
      },
      'Update Course',
    );
  }

  /// Delete course
  static Future<ApiResponse> deleteCourse(int courseId) async {
    return _apiCall(
      () async {
        return await http.delete(
          Uri.parse('$baseUrl/api/courses/$courseId'),
          headers: _getAuthHeaders(),
        );
      },
      'Delete Course',
    );
  }

  /// Delete user
  static Future<ApiResponse> deleteUser(int userId) async {
    return _apiCall(
      () async {
        return await http.delete(
          Uri.parse('$baseUrl/api/users/$userId'),
          headers: _getAuthHeaders(),
        );
      },
      'Delete User',
    );
  }

  /// Assign teacher to course
  static Future<ApiResponse> assignTeacherToCourse(int courseId, int teacherId) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/courses/$courseId/assign-teacher'),
          headers: _getAuthHeaders(),
          body: jsonEncode({'teacher_id': teacherId}),
        );
      },
      'Assign Teacher',
    );
  }

  /// Upload course video
  static Future<ApiResponse> uploadCourseVideo(
    int courseId,
    String title,
    String url, {
    String? description,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'url': url,
    };
    if (description != null) data['description'] = description;

    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/courses/$courseId/videos'),
          headers: _getAuthHeaders(),
          body: jsonEncode(data),
        );
      },
      'Upload Course Video',
    );
  }

  /// Upload course note
  static Future<ApiResponse> uploadCourseNote(
    int courseId,
    String title,
    String content,
  ) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/courses/$courseId/notes'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'title': title,
            'content': content,
          }),
        );
      },
      'Upload Course Note',
    );
  }

  /// Update course video
  static Future<ApiResponse> updateCourseVideo(
    int courseId,
    int videoId,
    String title,
    String url, {
    String? description,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'url': url,
    };
    if (description != null) data['description'] = description;

    return _apiCall(
      () async {
        return await http.put(
          Uri.parse('$baseUrl/api/courses/$courseId/videos/$videoId'),
          headers: _getAuthHeaders(),
          body: jsonEncode(data),
        );
      },
      'Update Course Video',
    );
  }

  /// Delete course video
  static Future<ApiResponse> deleteCourseVideo(int courseId, int videoId) async {
    return _apiCall(
      () async {
        return await http.delete(
          Uri.parse('$baseUrl/api/courses/$courseId/videos/$videoId'),
          headers: _getAuthHeaders(),
        );
      },
      'Delete Course Video',
    );
  }

  /// Update course note
  static Future<ApiResponse> updateCourseNote(
    int courseId,
    int noteId,
    String title,
    String content,
  ) async {
    return _apiCall(
      () async {
        return await http.put(
          Uri.parse('$baseUrl/api/courses/$courseId/notes/$noteId'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'title': title,
            'content': content,
          }),
        );
      },
      'Update Course Note',
    );
  }

  /// Delete course note
  static Future<ApiResponse> deleteCourseNote(int courseId, int noteId) async {
    return _apiCall(
      () async {
        return await http.delete(
          Uri.parse('$baseUrl/api/courses/$courseId/notes/$noteId'),
          headers: _getAuthHeaders(),
        );
      },
      'Delete Course Note',
    );
  }

  /// Get notifications
  static Future<ApiResponse> getNotifications() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/notifications'),
          headers: _getAuthHeaders(),
        );
      },
      'Notifications',
    );
  }

  /// Get leaderboard
  static Future<ApiResponse> getLeaderboard() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/gyanvruksh/leaderboard'),
          headers: _getAuthHeaders(),
        );
      },
      'Leaderboard',
    );
  }

  /// Get user profile
  static Future<ApiResponse> getProfile() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/gyanvruksh/profile'),
          headers: _getAuthHeaders(),
        );
      },
      'User Profile',
    );
  }

  /// Enhanced profile update with error handling
  static Future<ApiResponse> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (email != null) updateData['email'] = email;
    if (phone != null) updateData['phone'] = phone;
    if (bio != null) updateData['bio'] = bio;

    if (updateData.isEmpty) {
      return ApiResponse.error(
        userMessage: 'No changes to update',
        technicalMessage: 'Empty update data',
        operation: 'Profile Update',
      );
    }

    return _apiCall(
      () async {
        return await http.patch(
          Uri.parse('$baseUrl/api/users/profile'),
          headers: _getAuthHeaders(),
          body: jsonEncode(updateData),
        );
      },
      'Profile Update',
    );
  }

  /// Get student dashboard statistics
  static Future<ApiResponse> getStudentDashboard() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/student/dashboard/stats'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Dashboard',
    );
  }

  /// Generic GET request
  static Future<ApiResponse> get(String endpoint) async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: _getAuthHeaders(),
        );
      },
      'GET Request',
    );
  }

  /// Generic POST request
  static Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: _getAuthHeaders(),
          body: jsonEncode(data),
        );
      },
      'POST Request',
    );
  }

  /// Get personalization data
  static Future<ApiResponse> getPersonalizationData() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/gyanvruksh/personalization'),
          headers: _getAuthHeaders(),
        );
      },
      'Personalization Data',
    );
  }

  /// Update personalization data
  static Future<ApiResponse> updatePersonalizationData(Map<String, dynamic> data) async {
    return _apiCall(
      () async {
        return await http.put(
          Uri.parse('$baseUrl/api/gyanvruksh/personalization'),
          headers: _getAuthHeaders(),
          body: jsonEncode(data),
        );
      },
      'Update Personalization Data',
    );
  }

  /// Get teacher performance analytics
  static Future<ApiResponse> getTeacherPerformanceAnalytics() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/teacher/performance-analytics'),
          headers: _getAuthHeaders(),
        );
      },
      'Teacher Performance Analytics',
    );
  }

  /// Get student management data for teachers
  static Future<ApiResponse> getStudentManagementData() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/teacher/student-management'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Management Data',
    );
  }

  /// Get teacher messages
  static Future<ApiResponse> getTeacherMessages() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/teacher/messages'),
          headers: _getAuthHeaders(),
        );
      },
      'Teacher Messages',
    );
  }

  /// Get content library for teachers
  static Future<ApiResponse> getContentLibrary() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/teacher/content-library'),
          headers: _getAuthHeaders(),
        );
      },
      'Content Library',
    );
  }

  /// Create announcement
  static Future<ApiResponse> createAnnouncement(String title, String content, {int? courseId, int? classId}) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/teacher/announcements'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'title': title,
            'content': content,
            'course_id': courseId,
            'class_id': classId,
          }),
        );
      },
      'Create Announcement',
    );
  }

  /// Get student assignments
  static Future<ApiResponse> getStudentAssignments() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/teacher/assignments'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Assignments',
    );
  }

  /// Grade assignment
  static Future<ApiResponse> gradeAssignment(int assignmentId, int studentId, double grade, {String? feedback}) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/teacher/assignments/$assignmentId/grade'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'student_id': studentId,
            'grade': grade,
            'feedback': feedback,
          }),
        );
      },
      'Grade Assignment',
    );
  }

  /// Create assignment
  static Future<ApiResponse> createAssignment(String title, String description, String courseId, DateTime dueDate) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/teacher/assignments'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'title': title,
            'description': description,
            'course_id': courseId,
            'due_date': dueDate.toIso8601String(),
          }),
        );
      },
      'Create Assignment',
    );
  }

  /// Upload content
  static Future<ApiResponse> uploadContent(String title, String description, String contentType, {int? courseId}) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/teacher/upload-content'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'title': title,
            'description': description,
            'content_type': contentType,
            'course_id': courseId,
          }),
        );
      },
      'Upload Content',
    );
  }

  /// Get teacher quizzes
  static Future<ApiResponse> getTeacherQuizzes() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/teacher/quizzes'),
          headers: _getAuthHeaders(),
        );
      },
      'Get Teacher Quizzes',
    );
  }

  /// Create quiz
  static Future<ApiResponse> createQuiz({
    required String title,
    required String description,
    required int courseId,
    required int timeLimit,
    required List<dynamic> questions,
  }) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/teacher/quizzes'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'title': title,
            'description': description,
            'course_id': courseId,
            'time_limit': timeLimit,
            'questions': questions,
          }),
        );
      },
      'Create Quiz',
    );
  }

  /// Update quiz status
  static Future<ApiResponse> updateQuizStatus(int quizId, bool isPublished) async {
    return _apiCall(
      () async {
        return await http.patch(
          Uri.parse('$baseUrl/api/teacher/quizzes/$quizId/status'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'is_published': isPublished,
          }),
        );
      },
      'Update Quiz Status',
    );
  }

  /// Helper method to get authentication headers
  static Map<String, String> _getAuthHeaders() {
    return {
      'Authorization': 'Bearer ${_token ?? ''}',
      'Content-Type': 'application/json',
    };
  }

  /// Enhanced fetchMe with error handling
  static Future<ApiResponse> _fetchMe() async {
    if (_token == null) {
      return ApiResponse.error(
        userMessage: 'No authentication token found',
        technicalMessage: 'Token is null during profile fetch',
        operation: 'Profile Fetch',
      );
    }

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (res.statusCode == 200) {
        _me = jsonDecode(res.body);
        return ApiResponse.success('Profile loaded successfully', data: _me);
      } else if (res.statusCode == 401) {
        // Token expired or invalid
        _token = null;
        _me = null;
        return ApiResponse.error(
          userMessage: 'Session expired. Please login again.',
          technicalMessage: 'Token validation failed',
          operation: 'Profile Fetch',
        );
      } else {
        return ApiResponse.error(
          userMessage: 'Failed to load profile. Please try again.',
          technicalMessage: 'HTTP ${res.statusCode}: ${res.body}',
          operation: 'Profile Fetch',
        );
      }
    } catch (e) {
      return _handleError(e, 'Profile Fetch');
    }
  }

  // Getter for current user data
  static Map<String, dynamic>? get currentUser => _me;

  // Getter for current token
  static String? get currentToken => _token;

  /// Get student statistics
  static Future<ApiResponse> getStudentStats() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/student/stats'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Stats',
    );
  }

  /// Get student recommended courses
  static Future<ApiResponse> getStudentRecommendedCourses() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/student/recommended-courses'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Recommended Courses',
    );
  }

  /// Get learning path for student
  static Future<ApiResponse> getLearningPath() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/student/learning-path'),
          headers: _getAuthHeaders(),
        );
      },
      'Learning Path',
    );
  }

  /// Get student achievements
  static Future<ApiResponse> getStudentAchievements() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/student/achievements'),
          headers: _getAuthHeaders(),
        );
      },
      'Student Achievements',
    );
  }

  /// Get upcoming deadlines for student
  static Future<ApiResponse> getUpcomingDeadlines() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/student/upcoming-deadlines'),
          headers: _getAuthHeaders(),
        );
      },
      'Upcoming Deadlines',
    );
  }

  /// Get student progress report
  static Future<ApiResponse> getProgressReport() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/student/progress-report'),
          headers: _getAuthHeaders(),
        );
      },
      'Progress Report',
    );
  }

  /// Get study groups
  static Future<ApiResponse> getStudyGroups() async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/study-groups'),
          headers: _getAuthHeaders(),
        );
      },
      'Study Groups',
    );
  }

  /// Enhanced course enrollment with detailed response
  static Future<ApiResponse> enrollInCourseDetailed(int courseId) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/student/courses/$courseId/enroll-detailed'),
          headers: _getAuthHeaders(),
        );
      },
      'Detailed Course Enrollment',
    );
  }

  /// Generate study plan
  static Future<ApiResponse> generateStudyPlan(int courseId, DateTime targetDate, int dailyStudyHours) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/student/generate-study-plan'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'course_id': courseId,
            'target_date': targetDate.toIso8601String(),
            'daily_study_hours': dailyStudyHours,
          }),
        );
      },
      'Generate Study Plan',
    );
  }

  /// Join study group
  static Future<ApiResponse> joinStudyGroup(int groupId) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/study-groups/$groupId/join'),
          headers: _getAuthHeaders(),
        );
      },
      'Join Study Group',
    );
  }

  /// Ask doubt
  static Future<ApiResponse> askDoubt(String question, int courseId) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/student/ask-doubt'),
          headers: _getAuthHeaders(),
          body: jsonEncode({
            'question': question,
            'course_id': courseId,
          }),
        );
      },
      'Ask Doubt',
    );
  }

  /// Get course enrollments
  static Future<ApiResponse> getCourseEnrollments(int courseId) async {
    return _apiCall(
      () async {
        return await http.get(
          Uri.parse('$baseUrl/api/courses/$courseId/enrollments'),
          headers: _getAuthHeaders(),
        );
      },
      'Course Enrollments',
    );
  }
}
