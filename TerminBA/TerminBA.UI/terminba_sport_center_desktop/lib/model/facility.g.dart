// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Facility _$FacilityFromJson(Map<String, dynamic> json) => Facility(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  isDynamicPricing: json['isDynamicPricing'] as bool,
  staticPrice: (json['staticPrice'] as num?)?.toDouble(),
  isIndoor: json['isIndoor'] as bool,
    duration: _durationFromJson(json['duration']),
  sportCenterId: (json['sportCenterId'] as num).toInt(),
  sportCenter: json['sportCenter'] == null
      ? null
      : SportCenter.fromJson(json['sportCenter'] as Map<String, dynamic>),
  turfTypeId: (json['turfTypeId'] as num).toInt(),
  turfType: json['turfType'] == null
      ? null
      : TurfType.fromJson(json['turfType'] as Map<String, dynamic>),
  availableSports: (json['availableSports'] as List<dynamic>?)
      ?.map((e) => Sport.fromJson(e as Map<String, dynamic>))
      .toList(),
  dynamicPrices: (json['dynamicPrices'] as List<dynamic>?)
      ?.map((e) => FacilityDynamicPrice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FacilityToJson(Facility instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'maxCapacity': instance.maxCapacity,
  'isDynamicPricing': instance.isDynamicPricing,
  'staticPrice': instance.staticPrice,
  'isIndoor': instance.isIndoor,
    'duration': _durationToJson(instance.duration),
  'sportCenterId': instance.sportCenterId,
  'sportCenter': instance.sportCenter,
  'turfTypeId': instance.turfTypeId,
  'turfType': instance.turfType,
  'availableSports': instance.availableSports,
  'dynamicPrices': instance.dynamicPrices,
};
