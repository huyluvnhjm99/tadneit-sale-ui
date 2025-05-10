import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AuthService authService;  // Changed from AuthProvider to AuthService

  AuthInterceptor(this.dio, this.authService);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final String? token = await authService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) { // Token expired or UnAuthorize request
      try {
        await authService.logout();
        // Retry the request with new token
        // final options = err.requestOptions;
        // final token = await authService.getAccessToken();
        // options.headers['Authorization'] = 'Bearer $token';
        // final response = await dio.fetch(options);
        // return handler.resolve(response);
      } catch (e) {
        // Refresh token failed, logout user
        await authService.logout();
      }
    }
    return handler.next(err);
  }
}