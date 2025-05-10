import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/auth_interceptor.dart';
import '../datasources/error_interceptor.dart'; // Add import
import '../../app/app_config.dart';
import 'auth_provider.dart';

final Provider<Dio> dioProvider = Provider<Dio>((Ref<Dio> ref) {
  final Dio dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add logging interceptor
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  // Add error interceptor - add this before auth interceptor
  dio.interceptors.add(ErrorInterceptor());

  // Add auth interceptor
  final AuthService authService = ref.read(authServiceProvider);
  dio.interceptors.add(AuthInterceptor(dio, authService));

  return dio;
});