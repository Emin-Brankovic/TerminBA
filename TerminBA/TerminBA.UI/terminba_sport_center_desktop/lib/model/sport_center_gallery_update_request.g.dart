// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center_gallery_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportCenterGalleryUpdateRequest _$SportCenterGalleryUpdateRequestFromJson(
  Map<String, dynamic> json,
) => SportCenterGalleryUpdateRequest(
  photos: _bytesListFromJson(json['photos'] as List<dynamic>?),
  removedPhotoIds: (json['removedPhotoIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$SportCenterGalleryUpdateRequestToJson(
  SportCenterGalleryUpdateRequest instance,
) => <String, dynamic>{
  'photos': _bytesListToJson(instance.photos),
  'removedPhotoIds': instance.removedPhotoIds,
};
