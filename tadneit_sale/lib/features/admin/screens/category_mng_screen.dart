import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import 'package:tadneit_sale/core/utils/language_service.dart';
import 'package:tadneit_sale/data/models/item/category.dart';
import 'package:tadneit_sale/features/admin/providers/category_provider.dart';
import 'package:tadneit_sale/features/admin/widgets/category_management/category_add_form.dart';

import '../../../presentation/widgets/common/confirmation_dialog.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        ref.read(categoryProvider.notifier).fetchCategories();
      } on ApiException catch (e) {
        if (mounted) {
          ApiErrorHandler.showErrorSnackBar(context, e.message);
        }
      }
    });
  }

  void toggleEditMode() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

  // Preload images that are about to come into view
  void _preloadImages(List<CategoryDTO> categories, int currentIndex) {
    final int preloadRange = 5; // Preload 5 items ahead
    for (int i = currentIndex; i < (currentIndex + preloadRange).clamp(0, categories.length); i++) {
      final String? imageUrl = categories[i].img?.url;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Preload image into cache
        precacheImage(CachedNetworkImageProvider(imageUrl), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final CategoryState categoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.translate('category')),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: toggleEditMode,
            icon: !_isEditable
                ? const Icon(Icons.edit)
                : const Icon(Icons.cancel, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: categoryState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : categoryState.categories.isEmpty
            ? const Center(child: Text('No data'))
            : RefreshIndicator(
          onRefresh: () => ref.read(categoryProvider.notifier).fetchCategories(),
          child: ListView.builder(
            // Add caching for better performance
            cacheExtent: 1000, // Cache 1000 pixels ahead
            itemCount: categoryState.categories.length,
            itemBuilder: (BuildContext context, int index) {
              final CategoryDTO category = categoryState.categories[index];

              if (index % 10 == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _preloadImages(categoryState.categories, index);
                });
              }

              return _CategoryListItem(
                category: category,
                isEditable: _isEditable,
                onEdit: () => _handleEdit(category),
                onDelete: () => _showCategoryDeleteConfirmationDialog(category),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        tooltip: LanguageService.translate('addNewCategory'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleEdit(CategoryDTO category) {
    // Handle edit logic here
    print('Edit category: ${category.name}');
  }

  void _showCategoryDeleteConfirmationDialog(CategoryDTO category) {
    ConfirmDialog.show(
      context,
      message: 'Are you sure you want to delete category \'${category.name}\'?',
      confirmText: 'OK',
      cancelText: LanguageService.translate('cancel'),
      onConfirm: () async {
        if (category.id != null) {
          ref.read(categoryProvider.notifier).deleteCategory(category.id ?? '');
        }
        ApiErrorHandler.showSuccessSnackBar(
            context,
            LanguageService.translate('successfully')
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) => AddCategoryForm(ref),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final CategoryDTO category;
  final bool isEditable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryListItem({
    required this.category,
    required this.isEditable,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingImage(),
      title: Text(category.name),
      subtitle: Text(category.description),
      trailing: isEditable ? _buildTrailingActions() : null,
    );
  }

  Widget _buildLeadingImage() {
    if (category.img?.url == null || category.img!.url!.isEmpty) {
      return const SizedBox(
        width: 70,
        height: 70,
        child: Icon(Icons.category, size: 40),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: category.img!.url!,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),

        // Smaller, faster loading placeholder
        placeholder: (context, url) => Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.image, color: Colors.grey),
        ),

        errorWidget: (context, url, error) => Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),

        // Memory cache configuration
        memCacheWidth: 140, // 2x the display size for sharp images
        memCacheHeight: 140,
        maxWidthDiskCache: 200,
        maxHeightDiskCache: 200,
      ),
    );
  }

  Widget _buildTrailingActions() {
    return SizedBox(
      width: 96,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
            tooltip: 'Edit',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}