// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportCenterUpdateRequest _$SportCenterUpdateRequestFromJson(
  Map<String, dynamic> json,
) => SportCenterUpdateRequest(
  json['username'] as String,
  json['phoneNumber'] as String,
  (json['cityId'] as num).toInt(),
  json['address'] as String,
  json['isEquipmentProvided'] as bool,
  json['description'] as String,
  (json['sportIds'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  (json['amenityIds'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  (json['workingHours'] as List<dynamic>)
      .map((e) => WorkingHoursInsertRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SportCenterUpdateRequestToJson(
  SportCenterUpdateRequest instance,
) => <String, dynamic>{
  'username': instance.username,
  'phoneNumber': instance.phoneNumber,
  'cityId': instance.cityId,
  'address': instance.address,
  'isEquipmentProvided': instance.isEquipmentProvided,
  'description': instance.description,
  'sportIds': instance.sportIds,
  'amenityIds': instance.amenityIds,
  'workingHours': instance.workingHours,
};
