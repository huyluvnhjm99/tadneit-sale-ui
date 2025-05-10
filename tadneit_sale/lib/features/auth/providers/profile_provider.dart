import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/data/models/auth/user_profile.dart';
import 'package:tadneit_sale/data/providers/user_provider.dart';
import 'package:tadneit_sale/features/auth/base_state.dart';
import 'package:tadneit_sale/features/auth/providers/login_provider.dart';

import '../../../core/errors/api_exception.dart';

class ProfileState extends BaseState {
  final UserProfileDTO? profile;

  ProfileState({
    super.errorMessage,
    super.successMessage,
    this.profile,
    super.isLoading = false,
  });

  @override
  ProfileState copyWith({
    UserProfileDTO? profile,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserService _userService;

  ProfileNotifier(this._userService) : super(ProfileState());

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final UserProfileDTO profile = await _userService.getUserProfile();
      state = state.copyWith(isLoading: false, profile: profile);
    } on ApiException {
      state = state.copyWith(
          isLoading: false
      );
      rethrow;
    }
  }

  Future<void> saveProfile(UserProfileDTO userProfileDTO) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final UserProfileDTO profile = await _userService.saveUserProfile(userProfileDTO);
      state = state.copyWith(isLoading: false, profile: profile);
    } on ApiException {
      state = state.copyWith(
          isLoading: false
      );
      rethrow;
    }
  }

  void clearProfile() {
    state = ProfileState();
  }
}

// Profile provider that watches login state
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((Ref ref) {
  final UserService userService = ref.watch(userServiceProvider);
  final LoginState loginState = ref.watch(loginProvider);

  // Create the notifier
  final ProfileNotifier notifier = ProfileNotifier(userService);

  // Watch for login state changes
  ref.listen(loginProvider, (LoginState? previous, LoginState current) {
    // If user just logged in, fetch profile
    if (previous?.isLoggedIn == false && current.isLoggedIn == true) {
      notifier.fetchProfile();
    }

    // If user logged out, clear profile
    if (previous?.isLoggedIn == true && current.isLoggedIn == false) {
      notifier.clearProfile();
    }
  });

  // Initial fetch if already logged in
  if (loginState.isLoggedIn) {
    // Use Future.microtask to avoid calling async code during build
    Future.microtask(() => notifier.fetchProfile());
  }

  return notifier;
});

// Convenience provider that exposes just the profile
final Provider<UserProfileDTO?> userProfileProvider = Provider<UserProfileDTO?>((Ref<UserProfileDTO?> ref) {
  final ProfileState profileState = ref.watch(profileProvider);
  return profileState.profile;
});