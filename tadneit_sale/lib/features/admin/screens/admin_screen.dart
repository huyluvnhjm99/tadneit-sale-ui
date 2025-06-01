import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/core/utils/language_service.dart';
import 'package:tadneit_sale/features/admin/providers/category_provider.dart';
import 'package:tadneit_sale/features/admin/providers/item_provider.dart';

import '../widgets/language_selector.dart';
import '../widgets/category_management/category_count_item_card.dart';
import '../widgets/item_management/item_count_item_card.dart';

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
              ref.invalidate(countItemProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildAdminDashboard(context, ref),
            ),
          ),
        ),
      ),
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
          spacing: 10.0,
          runSpacing: 10.0,
          children: [
            categoryCountItemCard(context, ref),
            itemCountItemCard(context, ref),
          ],
        ),
      ],
    );
  }
}