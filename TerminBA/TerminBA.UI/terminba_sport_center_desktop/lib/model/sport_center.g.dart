// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportCenter _$SportCenterFromJson(Map<String, dynamic> json) => SportCenter(
  (json['id'] as num).toInt(),
  json['username'] as String,
  json['phoneNumber'] as String,
  (json['cityId'] as num).toInt(),
  json['address'] as String,
  json['isEquipmentProvided'] as bool,
  json['description'] as String,
  DateTime.parse(json['createdAt'] as String),
  json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  (json['roleId'] as num).toInt(),
  (json['availableSports'] as List<dynamic>)
      .map((e) => Sport.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['availableAmenities'] as List<dynamic>)
      .map((e) => Amenity.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['city'] == null
      ? null
      : City.fromJson(json['city'] as Map<String, dynamic>),
  json['role'] == null
      ? null
      : Role.fromJson(json['role'] as Map<String, dynamic>),
  (json['workingHours'] as List<dynamic>)
      .map((e) => WorkingHours.fromJson(e as Map<String, dynamic>))
      .toList(),
  _bytesFromJson(json['credentialsReport']),
);

Map<String, dynamic> _$SportCenterToJson(SportCenter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'cityId': instance.cityId,
      'city': instance.city,
      'address': instance.address,
      'isEquipmentProvided': instance.isEquipmentProvided,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'roleId': instance.roleId,
      'role': instance.role,
      'credentialsReport': _bytesToJson(instance.credentialsReport),
      'availableSports': instance.availableSports,
      'availableAmenities': instance.availableAmenities,
      'workingHours': instance.workingHours,
    };
