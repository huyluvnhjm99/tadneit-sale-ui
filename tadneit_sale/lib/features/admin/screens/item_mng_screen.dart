import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/data/models/file/file.dart';
import 'package:tadneit_sale/data/models/item/category.dart';
import 'package:tadneit_sale/data/models/item/item.dart';
import 'package:tadneit_sale/features/admin/providers/item_provider.dart';
import 'package:tadneit_sale/features/admin/widgets/item_management/item_add_form.dart';
import 'package:tadneit_sale/presentation/widgets/common/image_carousel.dart';

import '../../../core/utils/api_error_handler.dart';
import '../../../core/utils/language_service.dart';
import '../providers/category_provider.dart';

class ItemMngScreen extends ConsumerStatefulWidget {
  const ItemMngScreen({super.key});

  @override
  ConsumerState<ItemMngScreen> createState() => _ItemMngScreenState();
}

class _ItemMngScreenState extends ConsumerState<ItemMngScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itemProvider.notifier).loadItems(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(itemProvider.notifier).loadItems();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final ItemState itemState = ref.watch(itemProvider);

    ref.listen<ItemState>(itemProvider, (previous, current) {
      if (current.errorMessage != null) {
        ApiErrorHandler.showErrorSnackBar(context, current.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.translate('item')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSearchItem(),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(itemProvider.notifier).loadItems(refresh: true),
        child: _buildBody(itemState),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        tooltip: LanguageService.translate('addNewItem'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchItem() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            ref.read(itemProvider.notifier).clearSearch();
          },
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onSubmitted: (value) {
        ref.read(itemProvider.notifier).searchItems(value);
      },
    );
  }

  Widget _buildBody(ItemState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty && !state.isLoading) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: state.hasReachedMax
          ? state.items.length
          : state.items.length + 1,
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = state.items[index];
        return _buildProductItem(product);
      },
    );
  }

  Widget _buildProductItem(ItemDTO item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            children: [
              SizedBox(height: 120, width: 120, child:item.images != null
                  ? ImageCarouselWidget(
                imageUrls: item.images!.map((FileDTO img) => img.url ?? '').toList(),
                height: 120,
                width: 120,
              ) : Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[300]
                ),
                child: const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ))
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '${LanguageService.translate('itemBrand')}: ${item.brand}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)
                      ),
                      Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price.toString()} ₫',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (item.categories.isNotEmpty)
                        Wrap(
                          runSpacing: 5,
                          children: [
                            ...item.categories.map((category) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(fontSize: 8, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ))
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ]
          ),
      ),
      );
  }

  void _showAddItemDialog(BuildContext context) async {
    await ref.read(categoryProvider.notifier).fetchCategories();
    List<CategoryDTO> categories = ref.watch(categoryProvider).categories;

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return AddItemForm(ref, categories: categories);
        },
      );
    }
  }
}