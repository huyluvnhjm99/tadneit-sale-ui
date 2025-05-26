import 'package:json_annotation/json_annotation.dart';

part 'base_page.g.dart';

@JsonSerializable()
class Page {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  Page({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);
  Map<String, dynamic> toJson() => _$PageToJson(this);

  int get pageNumber => number;
  int get pageSize => size;
  bool get isFirst => number == 0;
  bool get isLast => number >= (totalPages - 1);
  bool get isEmpty => totalElements == 0;
}