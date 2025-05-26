// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page _$PageFromJson(Map<String, dynamic> json) => Page(
  size: (json['size'] as num).toInt(),
  number: (json['number'] as num).toInt(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$PageToJson(Page instance) => <String, dynamic>{
  'size': instance.size,
  'number': instance.number,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
};
