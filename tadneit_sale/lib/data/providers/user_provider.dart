import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/data/datasources/api_service.dart';
import '../models/auth/user_profile.dart';
import 'api_service_provider.dart';

final Provider<UserService> userServiceProvider = Provider<UserService>((Ref<UserService> ref) {
  return UserService(ref);
});

class UserService {
  final Ref ref;
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserService(this.ref);

  Future<UserProfileDTO> getUserProfile() async {
    try {
      final ApiService apiService = ref.read(apiServiceProvider);
      final UserProfileDTO response = await apiService.getUserProfile();
      return response;
    } on DioException catch (e) {
      throw ApiException(e);
    }
  }

  Future<UserProfileDTO> saveUserProfile(UserProfileDTO userProfileDTO) async {
    try {
      final ApiService apiService = ref.read(apiServiceProvider);
      final UserProfileDTO response = await apiService.saveUserProfile(userProfileDTO);
      return response;
    } on DioException catch (e) {
      throw ApiException(e);
    }
  }
}