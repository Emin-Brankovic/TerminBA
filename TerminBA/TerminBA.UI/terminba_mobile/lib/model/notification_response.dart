import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_mobile/model/reservation_response.dart';

part 'notification_response.g.dart';

@JsonSerializable()
class NotificationResponse {
  final int id;
  final int postOwnerId;
  final int reservationId;
  final ReservationResponse? reservation;
  final String requesterName;
  final String facilityName;
  final String date;
  final bool isSeen;
  final String? reason;
  final String type;

  NotificationResponse({
    required this.id,
    required this.postOwnerId,
    required this.reservationId,
    this.reservation,
    required this.requesterName,
    required this.facilityName,
    required this.date,
    required this.isSeen,
    this.reason,
    required this.type,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}
