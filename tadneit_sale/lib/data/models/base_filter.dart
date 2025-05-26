class BaseFilter {
  String? searchKey;
  String? createdBy;
  String? updatedBy;
  DateTime? createdDate;
  DateTime? updatedDate;
  DateTime? createdDateFrom;
  DateTime? createdDateTo;
  DateTime? updatedDateFrom;
  DateTime? updatedDateTo;
  int? page;
  int? size;

  BaseFilter({
    this.searchKey,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.createdDateFrom,
    this.createdDateTo,
    this.updatedDateFrom,
    this.updatedDateTo,
    this.page,
    this.size
  });

  factory BaseFilter.fromJson(Map<String, dynamic> json) {
    return BaseFilter(
      searchKey: json['searchKey'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate']) : null,
      createdDateFrom: json['createdDateFrom'] != null ? DateTime.parse(json['createdDateFrom']) : null,
      createdDateTo: json['createdDateTo'] != null ? DateTime.parse(json['createdDateTo']) : null,
      updatedDateFrom: json['updatedDateFrom'] != null ? DateTime.parse(json['updatedDateFrom']) : null,
      updatedDateTo: json['updatedDateTo'] != null ? DateTime.parse(json['updatedDateTo']) : null,
      page: json['page'] ?? 0,
      size: json['size'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['searchKey'] = searchKey;
    data['createdBy'] = createdBy;
    data['updatedBy'] = updatedBy;
    if (createdDate != null) {
      data['createdDate'] = createdDate!.toIso8601String();
    }
    if (updatedDate != null) {
      data['updatedDate'] = updatedDate!.toIso8601String();
    }
    if (createdDateFrom != null) {
      data['createdDateFrom'] = createdDateFrom!.toIso8601String();
    }
    if (createdDateTo != null) {
      data['createdDateTo'] = createdDateTo!.toIso8601String();
    }
    if (updatedDateFrom != null) {
      data['updatedDateFrom'] = updatedDateFrom!.toIso8601String();
    }
    if (updatedDateTo != null) {
      data['updatedDateTo'] = updatedDateTo!.toIso8601String();
    }
    data['page'] = page ?? 0;
    data['size'] = size ?? 10;
    return data;
  }
}