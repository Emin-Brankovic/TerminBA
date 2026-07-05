import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_mobile/model/reservation_response.dart';

part 'post_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PostResponse {
  final int id;
  final String? skillLevel;
  final String? text;
  final int reservationId;
  final ReservationResponse? reservation;
  final int numberOfPlayersWanted;
  final int numberOfPlayersFound;
  final String postState;

  const PostResponse({
    required this.id,
    this.skillLevel,
    this.text,
    required this.reservationId,
    this.reservation,
    required this.numberOfPlayersWanted,
    required this.numberOfPlayersFound,
    required this.postState,
  });

  bool get isActive => postState == 'PlayerSearchPostState';
  bool get isClosed =>
      postState == 'ClosedPostState' || postState == 'PlayerFoundPostState';

  factory PostResponse.fromJson(Map<String, dynamic> json) =>
      _$PostResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PostResponseToJson(this);
}
