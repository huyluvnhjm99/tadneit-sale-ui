import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if the error has a response
    if (err.response != null) {
      try {
        // Try to extract the error message from the response
        final responseData = err.response?.data;

        // Check if the response data contains an error message in the format you specified
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {

          // Create a new error with the extracted message
          final errorMessage = responseData['message'] as String;
          final newError = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: errorMessage, // Use the extracted message as the error
          );

          return handler.next(newError);
        }
      } catch (e) {
        // If there's an error parsing the response, just continue with the original error
        print('Error parsing error response: $e');
      }
    }

    // If we can't extract a specific message, just continue with the original error
    return handler.next(err);
  }
}