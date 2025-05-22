class BaseDTO {
  String? createdBy;
  DateTime? createdDate;
  DateTime? updatedDate;
  String? updatedBy;

  BaseDTO({
    this.createdBy,
    this.createdDate,
    this.updatedDate,
    this.updatedBy,
  });

  factory BaseDTO.fromJson(Map<String, dynamic> json) {
    return BaseDTO(
      createdBy: json['createdBy'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate']) : null,
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdBy'] = createdBy;
    if (createdDate != null) {
      data['createdDate'] = createdDate!.toIso8601String();
    }
    if (updatedDate != null) {
      data['updatedDate'] = updatedDate!.toIso8601String();
    }
    data['updatedBy'] = updatedBy;
    return data;
  }

  void copyBasePropertiesFrom(BaseDTO source) {
    createdBy = source.createdBy;
    createdDate = source.createdDate;
    updatedDate = source.updatedDate;
    updatedBy = source.updatedBy;
  }
}