import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import 'package:tadneit_sale/core/utils/language_service.dart';
import 'package:tadneit_sale/data/models/item/category.dart';
import 'package:tadneit_sale/features/admin/providers/category_provider.dart';
import 'package:tadneit_sale/features/admin/widgets/category_form.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  void toggleEditMode() {
    setState(() {
      _isEditable = !_isEditable;
    });
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
            icon:
                !_isEditable
                    ? const Icon(Icons.edit)
                    : const Icon(Icons.cancel, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            categoryState.isLoading
                ? const Flexible(
                  child: Center(child: CircularProgressIndicator()),
                )
                : categoryState.categories.isEmpty
                ? const Text('No data')
                : RefreshIndicator(
                  onRefresh:
                      () =>
                          ref.read(categoryProvider.notifier).fetchCategories(),
                  child: ListView.builder(
                    itemCount: categoryState.categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CategoryDTO category =
                          categoryState.categories[index];
                      return ListTile(
                        leading:
                            category.img != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: category.img?.url ?? '',
                                    fit: BoxFit.fitWidth,
                                    width: 70,
                                    placeholder:
                                        (context, url) => const SizedBox(
                                          width: 70,
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) =>
                                            const Icon(Icons.error),
                                  ),
                                )
                                : const SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Icon(Icons.category),
                                ),
                        title: Text(category.name),
                        subtitle: Text(category.description),
                        trailing:
                            _isEditable
                                ? SizedBox(
                                  width: 96,
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          // Popup edit
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => ConfirmDialog.show(
                                              context,
                                              message:
                                                  'Are you sure you want to delete category \'${category.name}\'?',
                                              confirmText: 'OK',
                                              cancelText:
                                                  LanguageService.translate(
                                                    'cancel',
                                                  ),
                                              onConfirm: () async {
                                                if (category.id != null) {
                                                  ref
                                                      .read(
                                                        categoryProvider
                                                            .notifier,
                                                      )
                                                      .deleteCategory(
                                                        category.id ?? '',
                                                      );
                                                }

                                                ApiErrorHandler.showSuccessSnackBar(
                                                  context,
                                                  LanguageService.translate(
                                                    'successfully',
                                                  ),
                                                );
                                              },
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                                : null,
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        tooltip: LanguageService.translate('addNewCategory'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return AddCategoryForm(ref);
      },
    );
  }
}
