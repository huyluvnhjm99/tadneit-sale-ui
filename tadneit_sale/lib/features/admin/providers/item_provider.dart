import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/data/models/item/item.dart';
import 'package:tadneit_sale/data/models/item/itemFilter.dart';
import 'package:tadneit_sale/features/base_state.dart';

import '../../../core/errors/api_exception.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/models/base_page_response.dart';
import '../../../data/providers/api_service_provider.dart';

class ItemState extends BaseState {
  final List<ItemDTO> items;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;
  final String? searchKey;

  ItemState({
    this.items = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.totalPages = 0,
    this.searchKey,
    super.isLoading = false,
  }) : super();

  @override
  ItemState copyWith({
    List<ItemDTO>? items,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    int? totalPages,
    String? searchKey,
  }) {
    return ItemState(
      items: items ?? [],
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      searchKey: searchKey ?? this.searchKey,
    );
  }
}

class ItemNotifier extends StateNotifier<ItemState> {
  final ApiService _apiService;
  static const int _pageSize = 20;

  ItemNotifier(this._apiService) : super(ItemState(items: []));

  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 0,
        hasReachedMax: false,
      );
    } else if (state.isLoadingMore || state.hasReachedMax) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);
    }

    try {
      final int pageToLoad = refresh ? 0 : state.currentPage + 1;

      ItemFilter filter = ItemFilter();
      filter.page = pageToLoad;
      filter.size = _pageSize;
      filter.searchKey = state.searchKey;
      final PageResponseDTO<ItemDTO> response = await _apiService.getItemPaging(filter);

      final List<ItemDTO> newItems = refresh
          ? response.content
          : [...state.items, ...response.content];

      state = state.copyWith(
        items: newItems,
        isLoading: false,
        isLoadingMore: false,
        currentPage: response.pageNumber,
        totalPages: response.totalPages,
        hasReachedMax: response.isLast,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<int> countItems() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final int count = await _apiService.getItemCount();
      state = state.copyWith(isLoading: false);
      return count;
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> searchItems(String query) async {
    state = state.copyWith(
      searchKey: query,
      currentPage: 0,
      hasReachedMax: false,
    );
    await loadItems(refresh: true);
  }

  void clearSearch() {
    state = state.copyWith(searchKey: '');
    loadItems(refresh: true);
  }

  Future<void> saveItem(ItemDTO newItem) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.saveItem(newItem);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      throw ApiException(e);
    } finally {
      loadItems(refresh: true);
    }
  }

// Future<void> updateCategory(CategoryDTO category) async {
//   state = state.copyWith(isLoading: true, errorMessage: null);
//   try {
//     await _apiService.updateCategory(category);
//     await fetchCategories();
//   } on ApiException {
//     state = state.copyWith(isLoading: false);
//     rethrow;
//   }
// }

// Future<void> deleteCategory(String id) async {
//   state = state.copyWith(isLoading: true, errorMessage: null);
//   try {
//     await _apiService.deleteCategory(id);
//     await fetchCategories();
//   } on ApiException {
//     state = state.copyWith(isLoading: false);
//     rethrow;
//   }
// }
}

final StateNotifierProvider<ItemNotifier, ItemState> itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((Ref ref) {
  final ApiService apiService = ref.watch(apiServiceProvider);
  return ItemNotifier(apiService);
});

final Provider<List<ItemDTO>?> itemsProvider = Provider<List<ItemDTO>?>((Ref ref) {
  return ref.watch(itemProvider).items;
});

final FutureProvider<int> countItemProvider = FutureProvider<int>((Ref ref) async {
  final ApiService apiService = ref.watch(apiServiceProvider);
  int count = await ItemNotifier(apiService).countItems();
  return count;
});
