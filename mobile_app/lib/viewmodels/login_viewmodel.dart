import 'package:flutter/material.dart';
import 'package:gyanvruksh/repositories/auth_repository.dart';
import 'package:gyanvruksh/utils/error_handler.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();

  bool isLoading = false;
  String? error;
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  Future<bool> login() async {
    final emailError = validateEmail(emailController.text);
    final passwordError = validatePassword(passwordController.text);

    if (emailError != null || passwordError != null) {
      error = emailError ?? passwordError;
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(emailController.text.trim(), passwordController.text.trim());
      final success = result['success'] as bool;

      if (success) {
        notifyListeners();
        return true;
      } else {
        error = result['error'] as String? ?? 'Login failed. Please check your credentials.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      error = ErrorHandler.getErrorMessage(e);
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
