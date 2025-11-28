import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiErrorHandler {
  /// Parse and handle API error responses
  static String parseError(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    final body = response['body'];

    if (body == null) {
      return 'Unknown error occurred';
    }

    // Handle Laravel validation errors (422)
    if (statusCode == 422 && body['errors'] != null) {
      final errors = body['errors'] as Map<String, dynamic>;
      final errorMessages = <String>[];

      errors.forEach((key, value) {
        if (value is List) {
          errorMessages.addAll(value.map((e) => e.toString()));
        } else {
          errorMessages.add(value.toString());
        }
      });

      return errorMessages.join(', ');
    }

    // Handle Laravel exceptions (500, 400, etc.)
    if (body['message'] != null) {
      String message = body['message'].toString();

      // Make Laravel errors more user-friendly
      if (message.contains('RequestGuard::login does not exist')) {
        return 'Authentication service is temporarily unavailable. Please try again later.';
      }

      if (message.contains('Unauthenticated') || statusCode == 401) {
        return 'Your session has expired. Please login again.';
      }

      if (message.contains('Forbidden') || statusCode == 403) {
        return 'You do not have permission to perform this action.';
      }

      if (statusCode == 404) {
        return 'The requested resource was not found.';
      }

      if (statusCode >= 500) {
        return 'Server error occurred. Please try again later.';
      }

      return message;
    }

    // Fallback based on status code
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Authentication required. Please login.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Show user-friendly error message
  static void showError(Map<String, dynamic> response) {
    final errorMessage = parseError(response);

    if (kDebugMode) {
      print('🚨 API Error: $errorMessage');
      print('📊 Status Code: ${response['statusCode']}');
      print('📄 Response Body: ${response['body']}');
    }

    // Show snackbar to user
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE74C3C),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 4),
    );
  }

  /// Check if the response indicates success
  static bool isSuccess(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if the response indicates authentication failure
  static bool isAuthError(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    return statusCode == 401;
  }

  /// Check if the response indicates validation failure
  static bool isValidationError(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    return statusCode == 422;
  }

  /// Check if the response indicates server error
  static bool isServerError(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    return statusCode >= 500;
  }

  /// Handle logout if authentication error
  static void handleAuthError() {
    if (kDebugMode) {
      print('🚪 Authentication error - logging out user');
    }

    // Clear stored tokens
    // SharedPrefHelper.clearToken(); // Implement this method

    // Navigate to login screen
    // Get.offAllNamed('/login'); // Adjust route as needed
  }
}
