import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'language_service.dart';

class ApiErrorHandler {
  // Main method to extract error message from DioException
  static String getErrorMessage(String error) {
    return LanguageService.translate(error);
  }

  // Helper method for Dio error types
  static String _getDioErrorTypeMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return LanguageService.translate('errorConnectionTimeout');
      case DioExceptionType.sendTimeout:
        return LanguageService.translate('errorSendTimeout');
      case DioExceptionType.receiveTimeout:
        return LanguageService.translate('errorReceiveTimeout');
      case DioExceptionType.connectionError:
        return LanguageService.translate('errorNoConnection');
      case DioExceptionType.badResponse:
        return LanguageService.translate('errorBadResponse');
      case DioExceptionType.cancel:
        return LanguageService.translate('errorRequestCancelled');
      case DioExceptionType.unknown:
      default:
        return LanguageService.translate('errorUnexpected');
    }
  }

  // Helper method for HTTP status codes
  static String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return LanguageService.translate('error400');
      case 401:
        return LanguageService.translate('error401');
      case 403:
        return LanguageService.translate('error403');
      case 404:
        return LanguageService.translate('error404');
      case 500:
        return LanguageService.translate('error500');
      case 502:
        return LanguageService.translate('error502');
      case 503:
        return LanguageService.translate('error503');
      default:
        return LanguageService.translate('errorHttpGeneric',
            params: {'code': statusCode?.toString() ?? 'unknown'});
    }
  }

  // Show error message to user
  static void showErrorSnackBar(BuildContext context, String error) {
    final message = getErrorMessage(error);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: LanguageService.translate('dismiss'),
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }

// Keep the other methods (getErrorDetails, logError, hasErrorMessage) as they were
// but update to use LanguageService
}