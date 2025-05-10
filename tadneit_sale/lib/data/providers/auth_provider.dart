import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/core/utils/language_service.dart';
import 'package:tadneit_sale/data/datasources/api_service.dart';
import 'package:tadneit_sale/data/models/auth/login_request.dart';
import 'package:tadneit_sale/data/providers/message_provider.dart';
import 'package:tadneit_sale/features/auth/providers/login_provider.dart';
import 'api_service_provider.dart';

final Provider<AuthService> authServiceProvider = Provider<AuthService>((Ref<AuthService> ref) {
  return AuthService(ref);
});

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
      final ApiService apiService = ref.read(apiServiceProvider);
      final String response = await apiService.login(
        LoginRequestDTO(username: username, password: password),
      );
      await saveTokens(response);

      return true;
    } on DioException catch (e) {
      throw ApiException(e);
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    ref.read(loginProvider.notifier).clearIsLoggedIn();
    ref.read(messageProvider.notifier).state = LanguageService.translate('unauthorized');
  }
}