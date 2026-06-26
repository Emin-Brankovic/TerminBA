import 'package:json_annotation/json_annotation.dart';

part 'favorite_sport_center_insert_request.g.dart';

@JsonSerializable()
class FavoriteSportCenterInsertRequest {
  int userId;
  int sportCenterId;

  FavoriteSportCenterInsertRequest(this.userId, this.sportCenterId);

  factory FavoriteSportCenterInsertRequest.fromJson(Map<String, dynamic> json) => _$FavoriteSportCenterInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteSportCenterInsertRequestToJson(this);
}
