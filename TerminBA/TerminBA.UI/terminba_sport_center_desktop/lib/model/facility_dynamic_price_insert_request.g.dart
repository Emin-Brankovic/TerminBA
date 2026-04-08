// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_dynamic_price_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityDynamicPriceInsertRequest _$FacilityDynamicPriceInsertRequestFromJson(
  Map<String, dynamic> json,
) => FacilityDynamicPriceInsertRequest(
  (json['facilityId'] as num).toInt(),
  dayOfWeekFromJson((json['startDay'] as num).toInt()),
  dayOfWeekFromJson((json['endDay'] as num).toInt()),
  json['startTime'] as String,
  json['endTime'] as String,
  (json['pricePerHour'] as num).toDouble(),
  _dateOnlyFromJson(json['validFrom'] as String),
  _nullableDateOnlyFromJson(json['validTo'] as String?),
);

Map<String, dynamic> _$FacilityDynamicPriceInsertRequestToJson(
  FacilityDynamicPriceInsertRequest instance,
) => <String, dynamic>{
  'facilityId': instance.facilityId,
  'startDay': dayOfWeekToJson(instance.startDay),
  'endDay': dayOfWeekToJson(instance.endDay),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'pricePerHour': instance.pricePerHour,
  'validFrom': _dateOnlyToJson(instance.validFrom),
  'validTo': _nullableDateOnlyToJson(instance.validTo),
};
