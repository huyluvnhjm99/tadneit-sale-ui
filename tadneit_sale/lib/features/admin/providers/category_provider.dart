import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/data/models/item/category.dart';
import 'package:tadneit_sale/features/base_state.dart';

import '../../../core/errors/api_exception.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/providers/api_service_provider.dart';

class CategoryState extends BaseState {
  final List<CategoryDTO> categories;

  CategoryState({
    super.errorMessage,
    super.successMessage,
    super.isLoading = false,
    required this.categories,
  });

  @override
  CategoryState copyWith({
    List<CategoryDTO>? categories,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final ApiService _apiService;

  CategoryNotifier(this._apiService) : super(CategoryState(categories: <CategoryDTO>[]));

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final List<CategoryDTO> categories = await _apiService.getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<int> countCategory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final int count = await _apiService.getCount();
      state = state.copyWith(isLoading: false);
      return count;
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> saveCategory(CategoryDTO category) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.saveCategory(category);
      await fetchCategories();
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryDTO category) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.updateCategory(category);
      await fetchCategories();
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.deleteCategory(id);
      await fetchCategories();
    } on ApiException {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final StateNotifierProvider<CategoryNotifier, CategoryState> categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((Ref ref) {
  final ApiService apiService = ref.watch(apiServiceProvider);
  return CategoryNotifier(apiService);
});

final Provider<List<CategoryDTO>?> categoriesProvider = Provider<List<CategoryDTO>?>((Ref ref) {
  return ref.watch(categoryProvider).categories;
});

final FutureProvider<int> countCategoryProvider = FutureProvider<int>((Ref ref) async {
  final ApiService apiService = ref.watch(apiServiceProvider);
  int count = await CategoryNotifier(apiService).countCategory();
  return count;
});
