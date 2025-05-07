import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/features/auth/base_state.dart';
import '../../../data/providers/auth_provider.dart';

class LoginState extends BaseState {
  final bool isLoggedIn;

  LoginState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.isLoggedIn = false,
  });

  @override
  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isLoggedIn,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;  // Changed from AuthProvider to AuthService

  LoginNotifier(this._authService) : super(LoginState());

  Future<void> login(String username, String password) async {
    // Start loading
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Perform login
      final success = await _authService.login(username, password);

      if (success) {
        state = state.copyWith(isLoading: false, isLoggedIn: true);
        clearError();
      } else {
        // Login failed
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid username or password',
        );
      }
    } catch (e) {
      // Handle errors
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      state = state.copyWith(isLoading: false, isLoggedIn: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Logout failed: ${e.toString()}',
      );
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await _authService.getAccessToken();
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: token != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
      );
    }
  }
}

// Login providers
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);  // Updated to use authServiceProvider
  return LoginNotifier(authService);
});

// Auto-login provider to check existing tokens on app start
final autoLoginProvider = FutureProvider<void>((ref) async {
  final loginNotifier = ref.read(loginProvider.notifier);
  await loginNotifier.checkAuthStatus();
});