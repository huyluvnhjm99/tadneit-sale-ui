import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/features/admin/providers/banner_provider.dart';

import '../../../../core/utils/api_error_handler.dart';
import '../../../../core/utils/language_service.dart';
import '../admin_item_card.dart';

Widget bannerCountItemCard(BuildContext context, WidgetRef ref) {
   AsyncValue<int> bannerCounting = ref.watch(countBannerProvider);
  return bannerCounting.when(
    data: (int count) => AdminItemCard(
      count: count,
      callBackFunction: () => context.push('/banner-mng'),
      label: LanguageService.translate('banner'),
      icon: Icons.announcement_outlined,
      iconBgColor: Colors.deepPurpleAccent,
    ),
    error: (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ApiErrorHandler.showErrorSnackBar(context, error.toString());
      });
      return _buildErrorPlaceholder(context, () {
        bannerCounting = ref.refresh(countBannerProvider);
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