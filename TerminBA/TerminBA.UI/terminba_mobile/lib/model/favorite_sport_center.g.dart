// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_sport_center.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteSportCenter _$FavoriteSportCenterFromJson(Map<String, dynamic> json) =>
    FavoriteSportCenter(
      (json['id'] as num?)?.toInt(),
      (json['userId'] as num?)?.toInt(),
      (json['sportCenterId'] as num?)?.toInt(),
      json['sportCenter'] == null
          ? null
          : SportCenter.fromJson(json['sportCenter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavoriteSportCenterToJson(
  FavoriteSportCenter instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'sportCenterId': instance.sportCenterId,
  'sportCenter': instance.sportCenter,
};
