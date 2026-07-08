import 'package:json_annotation/json_annotation.dart';

import 'package:terminba_mobile/model/reservation_response.dart';

part 'cancelation_notification_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CancelationNotificationResponse {
  final int id;
  final int postOwnerId;
  final int reservationId;
  final String requesterName;
  final String facilityName;
  final String dateCancelled;
  final bool isSeen;
  final ReservationResponse? reservation;

  const CancelationNotificationResponse({
    required this.id,
    required this.postOwnerId,
    required this.reservationId,
    required this.requesterName,
    required this.facilityName,
    required this.dateCancelled,
    required this.isSeen,
    this.reservation,
  });

  factory CancelationNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$CancelationNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CancelationNotificationResponseToJson(this);
}
