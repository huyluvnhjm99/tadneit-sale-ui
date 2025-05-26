import 'package:tadneit_sale/data/models/base_model.dart';
import 'package:tadneit_sale/data/models/file/file.dart';

import 'category.dart';

class ItemDTO extends BaseDTO {
  String? id;
  String name;
  String brand;
  String description;
  double? price;
  List<FileDTO>? images;
  List<CategoryDTO> categories;

  ItemDTO({
    this.id,
    required this.name,
    required this.brand,
    required this.description,
    this.price,
    this.images,
    required this.categories
  }) : super();

  factory ItemDTO.fromJson(Map<String, dynamic> json) {
    return ItemDTO(
      id: json['id'],
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      images: json['images'] != null ? (json['images'] as List)
          .map((item) => FileDTO.fromJson(item as Map<String, dynamic>))
          .toList() : null,
      categories: json['categories'] != null ? (json['categories'] as List)
          .map((item) => CategoryDTO.fromJson(item as Map<String, dynamic>))
          .toList() : <CategoryDTO>[],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['brand'] = brand;
    data['description'] = description;
    data['price'] = price;
    if (images != null && images!.isNotEmpty) {
      data['images'] = images?.map((item) => item.toJson()).toList();
    }
    data['categories'] = categories.map((category) => category.toJson()).toList();
    return data;
  }
}