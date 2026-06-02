// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_photo_response.dart';

// ***************************************************************************
// JsonSerializableGenerator
// ***************************************************************************

FacilityPhotoResponse _$FacilityPhotoResponseFromJson(
  Map<String, dynamic> json,
) => FacilityPhotoResponse(
  (json['id'] as num).toInt(),
  json['url'] as String?,
  json['publicId'] as String?,
  (json['facilityId'] as num).toInt(),
  json['isMain'] as bool?,
);

Map<String, dynamic> _$FacilityPhotoResponseToJson(
  FacilityPhotoResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'publicId': instance.publicId,
  'facilityId': instance.facilityId,
  'isMain': instance.isMain,
};
