part of 'favorite_sport_center_insert_request.dart';

FavoriteSportCenterInsertRequest _$FavoriteSportCenterInsertRequestFromJson(Map<String, dynamic> json) =>
    FavoriteSportCenterInsertRequest(
      (json['userId'] as num).toInt(),
      (json['sportCenterId'] as num).toInt(),
    );

Map<String, dynamic> _$FavoriteSportCenterInsertRequestToJson(
        FavoriteSportCenterInsertRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'sportCenterId': instance.sportCenterId,
    };
