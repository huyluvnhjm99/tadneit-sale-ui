import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiErrorHandler {
  // Method to extract error message from DioException
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      // Check if there's a custom error message set by our interceptor
      if (error.error is String) {
        return error.error.toString();
      }

      // Handle different types of Dio errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        case DioExceptionType.badResponse:
        // Extract status code
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Unauthorized. Please login again.';
          } else if (statusCode == 403) {
            return 'Access forbidden.';
          } else if (statusCode == 404) {
            return 'Resource not found.';
          } else if (statusCode == 500) {
            return 'Server error. Please try again later.';
          }
          return 'Server error occurred.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
        default:
          return 'An unexpected error occurred.';
      }
    }
    return error?.toString() ?? 'An unknown error occurred.';
  }

  // Safely show error message using post-frame callback
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);

    // Use a post-frame callback to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    });
  }
}