// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityInsertRequest _$FacilityInsertRequestFromJson(
  Map<String, dynamic> json,
) => FacilityInsertRequest(
  name: json['name'] as String,
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  isDynamicPricing: json['isDynamicPricing'] as bool,
  staticPrice: (json['staticPrice'] as num?)?.toDouble(),
  isIndoor: json['isIndoor'] as bool,
  duration: _durationFromJson(json['duration']),
  sportCenterId: (json['sportCenterId'] as num).toInt(),
  turfTypeId: (json['turfTypeId'] as num).toInt(),
  availableSportsIds: (json['availableSportsIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  dynamicPrices: (json['dynamicPrices'] as List<dynamic>?)
      ?.map(
        (e) => FacilityDynamicPriceInsertRequest.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$FacilityInsertRequestToJson(
  FacilityInsertRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'maxCapacity': instance.maxCapacity,
  'isDynamicPricing': instance.isDynamicPricing,
  'staticPrice': instance.staticPrice,
  'isIndoor': instance.isIndoor,
  'duration': _durationToJson(instance.duration),
  'sportCenterId': instance.sportCenterId,
  'turfTypeId': instance.turfTypeId,
  'availableSportsIds': instance.availableSportsIds,
  'dynamicPrices': instance.dynamicPrices,
};
