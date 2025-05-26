import 'package:tadneit_sale/data/models/base_model.dart';
import 'package:tadneit_sale/data/models/file/file.dart';

class CategoryDTO extends BaseDTO {
  String? id;
  String name;
  String description;
  FileDTO? img;

  CategoryDTO({
    this.id,
    required this.name,
    required this.description,
    this.img,
    super.createdBy,
    super.createdDate,
    super.updatedDate,
    super.updatedBy,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      img: json['img'] != null && json['img'] is Map<String, dynamic> ? FileDTO.fromJson(json['img']) : null,

      createdBy: json['createdBy'],
      updatedDate: json['updatedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedDate'])
          : null,
      createdDate: json['createdDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdDate'])
          : null,
      updatedBy: json['updatedBy'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['img'] = img?.toJson();
    return data;
  }

  @override
  String toString() {
    return name;
  }
}