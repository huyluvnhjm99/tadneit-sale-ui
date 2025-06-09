import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/language_service.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../data/models/item/category.dart';
import '../../../../presentation/widgets/common/image_carousel.dart';
import '../../../admin/providers/item_provider.dart';

class HomeCategoryItemView extends ConsumerStatefulWidget {
  const HomeCategoryItemView(this.categories, {super.key});
  final List<CategoryDTO> categories;

  @override
  ConsumerState<HomeCategoryItemView> createState() => _HomeCategoryItemViewState();
}

class _HomeCategoryItemViewState extends ConsumerState<HomeCategoryItemView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _buildProductViewGroupByCategory(widget.categories), // your async method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Top Picks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 10),
              ...snapshot.data!,
            ],
          ),
        );
      },
    );
  }

  Future<List<Widget>> _buildProductViewGroupByCategory(List<CategoryDTO> categories) async {
    final futures = categories.map((categoryDTO) async {
      final items = await ref.read(itemProvider.notifier).findItemByCategory(categoryDTO.id ?? '');
      if (items.isNotEmpty) {
        return Card(
          color: Colors.white,
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
                  child: Text(categoryDTO.name, style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              LayoutBuilder(
                  builder: (context, constraints) {
                    double maxWidth = constraints.maxWidth;
                    double spacing = 6.0;
                    double cardWidth = (maxWidth - spacing * 2) / 3; // Max 3 card per row

                    return Wrap(
                      children: [
                        ...items.map(
                              (item) => Card(
                            elevation: 1,
                            color: Colors.white,
                            margin: const EdgeInsets.all(2),
                            child: SizedBox(
                              height: 231,
                              width: cardWidth,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 120,
                                    width: 120,
                                    child:
                                    item.images != null
                                        ? NetworkImageCarouselWidget(
                                          imageUrls: item.images!.map((img) => img.url ?? '').toList(),
                                          height: 120,
                                          width: 120,
                                        )
                                        : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        color: Colors.grey[300],
                                      ),
                                      child: const Center(
                                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey)
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: Center(
                                          child: Text(item.name, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, maxLines: 2),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          StringUtils.formatCurrency(item.price ?? 0),
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                                onPressed: () {},
                                                child: Text(LanguageService.translate('buy'),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                                            ),
                                          ),
                                          Container(
                                            height: 15,
                                            width: 1,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.add_shopping_cart_outlined, color: Theme.of(context).primaryColor,),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
              ),
              Center(
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: '${'${LanguageService.translate('viewMore')} ${LanguageService.translate('item')}'} ',
                                  style: const TextStyle(fontSize: 16, color: Colors.black)
                              ),
                              TextSpan(
                                  text: categoryDTO.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  )
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.navigate_next)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox();
    });

    return await Future.wait(futures);
  }
}
