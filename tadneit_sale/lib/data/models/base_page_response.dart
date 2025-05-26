import 'package:json_annotation/json_annotation.dart';

import 'base_page.dart';

part 'base_page_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PageResponseDTO<T> {
  final List<T> content;
  final Page page;

  PageResponseDTO({
    required this.content,
    required this.page,
  });

  factory PageResponseDTO.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) => _$PageResponseDTOFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PageResponseDTOToJson(this, toJsonT);

  int get pageNumber => page.number;
  int get pageSize => page.size;
  int get totalElements => page.totalElements;
  int get totalPages => page.totalPages;
  bool get isFirst => page.isFirst;
  bool get isLast => page.isLast;
  bool get isEmpty => page.isEmpty;
  int get numberOfElements => content.length;
}