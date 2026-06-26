import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_mobile/model/sport_center.dart';

part 'favorite_sport_center.g.dart';

@JsonSerializable()
class FavoriteSportCenter {
  int? id;
  int? userId;
  int? sportCenterId;
  SportCenter? sportCenter;

  FavoriteSportCenter(this.id, this.userId, this.sportCenterId, this.sportCenter);

  factory FavoriteSportCenter.fromJson(Map<String, dynamic> json) => _$FavoriteSportCenterFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteSportCenterToJson(this);
}
