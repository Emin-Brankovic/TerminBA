// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_sport_center_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteSportCenterInsertRequest _$FavoriteSportCenterInsertRequestFromJson(
  Map<String, dynamic> json,
) => FavoriteSportCenterInsertRequest(
  (json['userId'] as num).toInt(),
  (json['sportCenterId'] as num).toInt(),
);

Map<String, dynamic> _$FavoriteSportCenterInsertRequestToJson(
  FavoriteSportCenterInsertRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'sportCenterId': instance.sportCenterId,
};
