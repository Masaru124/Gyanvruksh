import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class ErrorHandler {
  // Handle API errors
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is HttpException) {
      return 'Server error occurred. Please try again later.';
    } else if (error is FormatException) {
      return 'Invalid data format received from server.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else {
      return error.toString().contains('Exception:')
          ? error.toString().split('Exception:')[1].trim()
          : 'An unexpected error occurred. Please try again.';
    }
  }

  // Show error dialog
  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Announce content changes to screen readers
  static void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // Handle async operations with loading and error states
  static Future<T?> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> operation, {
    String? loadingMessage,
    String? errorTitle,
    bool showErrorDialog = true,
    bool showLoadingOverlay = true,
  }) async {
    try {
      if (showLoadingOverlay) {
        // Show loading dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      final result = await operation;

      if (showLoadingOverlay) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      return result;
    } catch (error) {
      if (showLoadingOverlay) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      final errorMessage = ErrorHandler.getErrorMessage(error);

      if (showErrorDialog) {
        ErrorHandler.showErrorDialog(
          context,
          errorTitle ?? 'Error',
          errorMessage,
        );
      } else {
        ErrorHandler.showErrorSnackBar(context, errorMessage);
      }

      return null;
    }
  }
}

// Custom exception classes
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
