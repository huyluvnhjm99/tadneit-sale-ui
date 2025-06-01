import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/api_error_handler.dart';
import '../../../../core/utils/language_service.dart';
import '../../providers/category_provider.dart';
import '../admin_item_card.dart';

Widget categoryCountItemCard(BuildContext context, WidgetRef ref) {
   AsyncValue<int> categoryCounting = ref.watch(countCategoryProvider);
  return categoryCounting.when(
    data: (int count) => AdminItemCard(
      count: count,
      callBackFunction: () => context.push('/category'),
      label: LanguageService.translate('category'),
      icon: Icons.category,
      iconBgColor: Colors.cyan,
    ),
    error: (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ApiErrorHandler.showErrorSnackBar(context, error.toString());
      });
      return _buildErrorPlaceholder(context, () {
        categoryCounting = ref.refresh(countCategoryProvider);
      });
    },
    loading: () => const Center(
      child: SizedBox(
        height: 100,
        width: 100,
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ),
  );
}

Widget _buildErrorPlaceholder(BuildContext context, VoidCallback onRetry) {
  return SizedBox(
    height: 100,
    width: 160,
    child: Card(
      color: Colors.red.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(LanguageService.translate('retry')),
          ),
        ],
      ),
    ),
  );
}