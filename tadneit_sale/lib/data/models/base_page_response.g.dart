// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_page_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseDTO<T> _$PageResponseDTOFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PageResponseDTO<T>(
  content: (json['content'] as List<dynamic>).map(fromJsonT).toList(),
  page: Page.fromJson(json['page'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PageResponseDTOToJson<T>(
  PageResponseDTO<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'content': instance.content.map(toJsonT).toList(),
  'page': instance.page,
};
