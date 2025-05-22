import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import 'package:tadneit_sale/core/utils/language_service.dart';
import 'package:tadneit_sale/features/admin/providers/category_provider.dart';
import 'package:tadneit_sale/features/admin/widgets/admin_item_card.dart';

import '../../home/widgets/language_selector.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.translate('admin')),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Adding padding for better spacing
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(countCategoryProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildAdminDashboard(context, ref),
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigation or action to add new category
      //   },
      //   tooltip: LanguageService.translate('add_new'),
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildAdminDashboard(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LanguageSelector(),
        Text(
          LanguageService.translate('dataManagement'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8.0,),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.start,
          children: [
            _buildCategoryCard(context, ref),
            // Add more admin cards here as needed
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> categoryCounting = ref.watch(countCategoryProvider);
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
}