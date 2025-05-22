import 'package:tadneit_sale/core/constants/enums.dart';
import 'package:tadneit_sale/data/models/base_model.dart';

class FileDTO extends BaseDTO {
  String? id;
  String? fileId;
  String? fileName;
  String? originalName;
  String? contentType;
  String? filePath;
  String? url;
  int? size;
  String? mappingId;
  FileMappingType? mappingType;

  FileDTO({
    this.id,
    this.fileId,
    this.fileName,
    this.originalName,
    this.contentType,
    this.filePath,
    this.url,
    this.size,
    this.mappingId,
    this.mappingType,
    super.createdBy,
    super.createdDate,
    super.updatedDate,
    super.updatedBy,
  });

  factory FileDTO.fromJson(Map<String, dynamic> json) {
    return FileDTO(
      id: json['id'],
      fileId: json['fileId'],
      fileName: json['fileName'],
      originalName: json['originalName'],
      contentType: json['contentType'],
      filePath: json['filePath'],
      url: json['url'],
      size: json['size'],
      mappingId: json['mappingId'],
      mappingType: json['mappingId'] != null ? FileMappingType.fromString(json['mappingId']) : null,
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
    data['fileId'] = fileId;
    data['fileName'] = fileName;
    data['originalName'] = originalName;
    data['contentType'] = contentType;
    data['filePath'] = filePath;
    data['url'] = url;
    data['size'] = size;
    data['mappingId'] = mappingId;
    data['mappingType'] = mappingType;
    return data;
  }
}