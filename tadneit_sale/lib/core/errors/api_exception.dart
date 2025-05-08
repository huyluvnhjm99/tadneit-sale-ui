import 'package:dio/dio.dart';
import 'dart:convert';

class ErrorResponse {
  final String error;
  final String message;
  final int status;

  ErrorResponse({
    required this.error,
    required this.message,
    required this.status,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  // Helper method to create from dynamic data
  static ErrorResponse? fromDynamic(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map<String, dynamic>) {
        return ErrorResponse.fromJson(data);
      } else if (data is String) {
        return ErrorResponse.fromJson(json.decode(data));
      }
    } catch (e) {
      print('Error parsing ErrorResponse: $e');
    }

    return null;
  }
}

class ApiException implements Exception {
  final DioException originalException;
  final ErrorResponse? errorResponse;

  ApiException(this.originalException)
      : errorResponse = ErrorResponse.fromDynamic(originalException.response?.data);

  String get message {
    return errorResponse?.message ?? 'An unknown error occurred';
  }

  int get statusCode {
    return errorResponse?.status ?? originalException.response?.statusCode ?? 0;
  }

  @override
  String toString() {
    return message;
  }
}