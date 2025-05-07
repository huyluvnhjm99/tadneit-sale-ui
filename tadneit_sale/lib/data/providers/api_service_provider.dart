import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/api_service.dart';
import '../../app/app_config.dart';
import 'dio_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio, baseUrl: AppConfig.apiBaseUrl);
});