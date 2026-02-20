// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sport _$SportFromJson(Map<String, dynamic> json) =>
    Sport((json['id'] as num).toInt(), json['name'] as String?);

Map<String, dynamic> _$SportToJson(Sport instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};
