// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center_photo_response.dart';

// ***************************************************************************
// JsonSerializableGenerator
// ***************************************************************************

SportCenterPhotoResponse _$SportCenterPhotoResponseFromJson(
  Map<String, dynamic> json,
) => SportCenterPhotoResponse(
  (json['id'] as num).toInt(),
  json['url'] as String?,
  json['publicId'] as String?,
  (json['sportCenterId'] as num).toInt(),
  json['isMain'] as bool?,
);

Map<String, dynamic> _$SportCenterPhotoResponseToJson(
  SportCenterPhotoResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'publicId': instance.publicId,
  'sportCenterId': instance.sportCenterId,
  'isMain': instance.isMain,
};
