import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/item/category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    this.iconSize,
    this.fontSize,
    required this.categoryDTO,
    required this.callBackFunction,
  });

  final double? iconSize;
  final double? fontSize;
  final CategoryDTO categoryDTO;
  final Function() callBackFunction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 5.0,
      children: [
        _buildIcon(),
        Expanded(
          child: Center(
            child: Text(
              categoryDTO.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    if (categoryDTO.img?.url == null || categoryDTO.img!.url!.isEmpty) {
      return SizedBox(child: Icon(Icons.category, size: iconSize ?? 70));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: categoryDTO.img!.url!,
        width: iconSize ?? 70,
        height: iconSize ?? 70,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),

        // Smaller, faster loading placeholder
        placeholder:
            (context, url) => Container(
              width: iconSize ?? 70,
              height: iconSize ?? 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),

        errorWidget:
            (context, url, error) => Container(
              width: iconSize ?? 70,
              height: iconSize ?? 70,
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
}
