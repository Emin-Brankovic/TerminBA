// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportCenterInsertRequest _$SportCenterInsertRequestFromJson(
  Map<String, dynamic> json,
) => SportCenterInsertRequest(
  json['username'] as String,
  json['phoneNumber'] as String,
  (json['cityId'] as num).toInt(),
  json['address'] as String,
  json['isEquipmentProvided'] as bool,
  json['description'] as String,
  (json['roleId'] as num).toInt(),
  (json['sportIds'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  (json['amenityIds'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  (json['workingHours'] as List<dynamic>)
      .map((e) => WorkingHoursInsertRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SportCenterInsertRequestToJson(
  SportCenterInsertRequest instance,
) => <String, dynamic>{
  'username': instance.username,
  'phoneNumber': instance.phoneNumber,
  'cityId': instance.cityId,
  'address': instance.address,
  'isEquipmentProvided': instance.isEquipmentProvided,
  'description': instance.description,
  'roleId': instance.roleId,
  'sportIds': instance.sportIds,
  'amenityIds': instance.amenityIds,
  'workingHours': instance.workingHours,
};
