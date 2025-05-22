import 'package:dio/src/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_config.dart';
import '../datasources/api_service.dart';
import 'dio_provider.dart';

final Provider<ApiService> apiServiceProvider = Provider<ApiService>((Ref ref) {
  final Dio dio = ref.watch(dioProvider);
  return ApiService(dio, baseUrl: AppConfig.apiBaseUrl);
});