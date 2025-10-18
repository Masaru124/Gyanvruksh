import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'auth_storage.dart';

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

  // Existing methods with enhanced error handling would go here...
  // For brevity, I'll show the pattern with a few key methods

  /// Enhanced course enrollment with error handling
  static Future<ApiResponse> enrollInCourse(int courseId) async {
    return _apiCall(
      () async {
        return await http.post(
          Uri.parse('$baseUrl/api/student/courses/$courseId/enroll'),
          headers: {
            'Authorization': 'Bearer ${_token ?? ''}',
            'Content-Type': 'application/json',
          },
        );
      },
      'Course Enrollment',
    );
  }

  /// Enhanced assignment submission with error handling
  static Future<ApiResponse> submitAssignment({
    required int assignmentId,
    required String content,
    String? attachmentPath,
  }) async {
    return _apiCall(
      () async {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/assignments/$assignmentId/submit'),
        );

        request.headers['Authorization'] = 'Bearer ${_token ?? ''}';
        request.fields['content'] = content;

        if (attachmentPath != null) {
          request.files.add(
            await http.MultipartFile.fromPath('file', attachmentPath),
          );
        }

        final streamedResponse = await request.send();
        return await http.Response.fromStream(streamedResponse);
      },
      'Assignment Submission',
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
          headers: {
            'Authorization': 'Bearer ${_token ?? ''}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(updateData),
        );
      },
      'Profile Update',
    );
  }

  // Getter for current user data
  static Map<String, dynamic>? get currentUser => _me;

  // Getter for current token
  static String? get currentToken => _token;

  // Check if user is authenticated
  static bool get isAuthenticated => _token != null && _me != null;
}

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
