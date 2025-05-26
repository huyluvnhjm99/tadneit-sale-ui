import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import 'package:tadneit_sale/core/utils/language_service.dart';
import 'package:tadneit_sale/features/admin/providers/item_provider.dart';

import '../../providers/category_provider.dart';
import '../admin_item_card.dart';


Widget itemCountItemCard(BuildContext context, WidgetRef ref) {
  final AsyncValue<int> itemCounting = ref.watch(countItemProvider);
  return itemCounting.when(
    data: (int count) => AdminItemCard(
      count: count,
      callBackFunction: () => context.push('/item-mng'),
      label: LanguageService.translate('item'),
      icon: Icons.add_shopping_cart,
      iconBgColor: Colors.orangeAccent,
    ),
    error: (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ApiErrorHandler.showErrorSnackBar(context, error.toString());
      });
      return _buildErrorPlaceholder(context, () {
        ref.refresh(countCategoryProvider);
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