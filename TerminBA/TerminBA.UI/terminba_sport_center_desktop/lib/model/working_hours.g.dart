// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) => WorkingHours(
  (json['id'] as num).toInt(),
  (json['sportCenterId'] as num).toInt(),
  dayOfWeekFromJson((json['startDay'] as num).toInt()),
  dayOfWeekFromJson((json['endDay'] as num).toInt()),
  json['openingHours'] as String,
  json['closeingHours'] as String,
  DateTime.parse(json['validFrom'] as String),
  json['validTo'] == null ? null : DateTime.parse(json['validTo'] as String),
  json['isActive'] as bool,
);

Map<String, dynamic> _$WorkingHoursToJson(WorkingHours instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sportCenterId': instance.sportCenterId,
      'startDay': dayOfWeekToJson(instance.startDay),
      'endDay': dayOfWeekToJson(instance.endDay),
      'openingHours': instance.openingHours,
      'closeingHours': instance.closeingHours,
      'validFrom': instance.validFrom.toIso8601String(),
      'validTo': instance.validTo?.toIso8601String(),
      'isActive': instance.isActive,
    };
