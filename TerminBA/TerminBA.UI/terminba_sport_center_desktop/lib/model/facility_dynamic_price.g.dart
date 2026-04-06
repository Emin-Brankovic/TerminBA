// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_dynamic_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityDynamicPrice _$FacilityDynamicPriceFromJson(
  Map<String, dynamic> json,
) => FacilityDynamicPrice(
  id: (json['id'] as num).toInt(),
  facilityId: (json['facilityId'] as num).toInt(),
  facilityName: json['facilityName'] as String?,
  startDay: dayOfWeekFromJson((json['startDay'] as num).toInt()),
  endDay: dayOfWeekFromJson((json['endDay'] as num).toInt()),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  pricePerHour: (json['pricePerHour'] as num).toDouble(),
  isActive: json['isActive'] as bool,
  validFrom: DateTime.parse(json['validFrom'] as String),
  validTo: json['validTo'] == null
      ? null
      : DateTime.parse(json['validTo'] as String),
);

Map<String, dynamic> _$FacilityDynamicPriceToJson(
  FacilityDynamicPrice instance,
) => <String, dynamic>{
  'id': instance.id,
  'facilityId': instance.facilityId,
  'facilityName': instance.facilityName,
  'startDay': dayOfWeekToJson(instance.startDay),
  'endDay': dayOfWeekToJson(instance.endDay),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'pricePerHour': instance.pricePerHour,
  'isActive': instance.isActive,
  'validFrom': instance.validFrom.toIso8601String(),
  'validTo': instance.validTo?.toIso8601String(),
};
