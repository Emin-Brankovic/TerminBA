// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_hours_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingHoursInsertRequest _$WorkingHoursInsertRequestFromJson(
  Map<String, dynamic> json,
) => WorkingHoursInsertRequest(
  (json['sportCenterId'] as num).toInt(),
  dayOfWeekFromJson((json['startDay'] as num).toInt()),
  dayOfWeekFromJson((json['endDay'] as num).toInt()),
  json['openingHours'] as String,
  json['closeingHours'] as String,
  WorkingHoursInsertRequest._dateFromJson(json['validFrom'] as String),
  WorkingHoursInsertRequest._nullableDateFromJson(json['validTo'] as String?),
);

Map<String, dynamic> _$WorkingHoursInsertRequestToJson(
  WorkingHoursInsertRequest instance,
) => <String, dynamic>{
  'sportCenterId': instance.sportCenterId,
  'startDay': dayOfWeekToJson(instance.startDay),
  'endDay': dayOfWeekToJson(instance.endDay),
  'openingHours': instance.openingHours,
  'closeingHours': instance.closeingHours,
  'validFrom': WorkingHoursInsertRequest._dateToJson(instance.validFrom),
  'validTo': WorkingHoursInsertRequest._nullableDateToJson(instance.validTo),
};
