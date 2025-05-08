import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/data/models/auth/login_request.dart';
import 'api_service_provider.dart';

// Rename this provider to authServiceProvider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

// Also rename the class to AuthService for consistency
class AuthService {
  final Ref ref;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService(this.ref);

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> saveTokens(String accessToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
  }

  // Future<void> refreshToken() async {
  //   final refreshToken = await _secureStorage.read(key: 'refresh_token');
  //   if (refreshToken == null) {
  //     throw Exception('No refresh token');
  //   }
  //
  //   final apiService = ref.read(apiServiceProvider);
  //   final response = await apiService.refreshToken(
  //     RefreshTokenRequest(refreshToken: refreshToken),
  //   );
  //
  //   await saveTokens(response.accessToken, response.refreshToken);
  // }

  Future<bool> login(String username, String password) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login(
        LoginRequestDTO(username: username, password: password),
      );
      await saveTokens(response);

      // Load Profile


      return true;
    } on DioException catch (e) {
      throw ApiException(e);
    }
  }

  Future<void> loadProfile() async {

  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
}