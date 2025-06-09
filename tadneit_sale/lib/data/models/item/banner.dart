import 'package:tadneit_sale/data/models/base_model.dart';
import 'package:tadneit_sale/data/models/file/file.dart';

class BannerDTO extends BaseDTO {
  String? id;
  String name;
  String description;
  List<FileDTO>? imgs;

  BannerDTO({
    this.id,
    required this.name,
    required this.description,
    this.imgs,
    super.createdBy,
    super.createdDate,
    super.updatedDate,
    super.updatedBy,
  });

  factory BannerDTO.fromJson(Map<String, dynamic> json) {
    return BannerDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imgs: json['imgs'] != null ? (json['imgs'] as List)
          .map((item) => FileDTO.fromJson(item as Map<String, dynamic>))
          .toList() : null,

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
    if (imgs != null && imgs!.isNotEmpty) {
      data['imgs'] = imgs?.map((item) => item.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return name;
  }
}