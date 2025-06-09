import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/data/models/item/banner.dart';
import 'package:tadneit_sale/features/base_state.dart';

import '../../../core/errors/api_exception.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/providers/api_service_provider.dart';

class BannerState extends BaseState {
  final List<BannerDTO> banners;

  BannerState({
    super.errorMessage,
    super.successMessage,
    super.isLoading = false,
    required this.banners,
  });

  @override
  BannerState copyWith({
    List<BannerDTO>? banners,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
  }) {
    return BannerState(
      banners: banners ?? this.banners,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BannerNotifier extends StateNotifier<BannerState> {
  final ApiService _apiService;

  BannerNotifier(this._apiService) : super(BannerState(banners: <BannerDTO>[]));

  Future<void> fetchBanners() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final List<BannerDTO> banners = await _apiService.getBanners();
      state = state.copyWith(banners: banners, isLoading: false);
    } on ApiException {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<int> countBanner() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final int count = await _apiService.getBannerCount();
      state = state.copyWith(isLoading: false);
      return count;
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> saveBanner(BannerDTO banner) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.saveBanner(banner);
      await fetchBanners();
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateBanner(BannerDTO bannerDTO) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.updateBanner(bannerDTO);
      await fetchBanners();
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteBanner(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.deleteBanner(id);
      await fetchBanners();
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final StateNotifierProvider<BannerNotifier, BannerState> bannerProvider = StateNotifierProvider<BannerNotifier, BannerState>((Ref ref) {
  final ApiService apiService = ref.watch(apiServiceProvider);
  return BannerNotifier(apiService);
});

final Provider<List<BannerDTO>?> bannersProvider = Provider<List<BannerDTO>?>((Ref ref) {
  return ref.watch(bannerProvider).banners;
});

final FutureProvider<int> countBannerProvider = FutureProvider<int>((Ref ref) async {
  final ApiService apiService = ref.watch(apiServiceProvider);
  int count = await BannerNotifier(apiService).countBanner();
  return count;
});
