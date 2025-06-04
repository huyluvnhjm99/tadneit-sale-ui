import 'package:flutter/material.dart';

import '../../../data/models/item/category.dart';
import '../../admin/providers/category_provider.dart';
import 'category_card.dart';

class HomeCategorySelection extends StatefulWidget {
  const HomeCategorySelection ({super.key, required this.categoryState});
  final CategoryState categoryState;

  @override
  State<HomeCategorySelection> createState() => _HomeCategorySelectionState();
}

class _HomeCategorySelectionState extends State<HomeCategorySelection> {
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _categoryScrollController,
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            spacing: 5.0,
            children: [
              if (widget.categoryState.isLoading || widget.categoryState.categories.isEmpty)
                const CircularProgressIndicator()
              else
                ...widget.categoryState.categories.map(
                      (CategoryDTO category) => SizedBox(
                    width: 80,
                    height: 110,
                    child: CategoryCard(
                      categoryDTO: category,
                      callBackFunction: () {},
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
