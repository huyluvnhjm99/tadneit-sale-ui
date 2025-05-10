import 'package:dio/src/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/api_service.dart';
import '../../app/app_config.dart';
import 'dio_provider.dart';

final Provider<ApiService> apiServiceProvider = Provider<ApiService>((ProviderRef<ApiService> ref) {
  final Dio dio = ref.watch(dioProvider);
  return ApiService(dio, baseUrl: AppConfig.apiBaseUrl);
});