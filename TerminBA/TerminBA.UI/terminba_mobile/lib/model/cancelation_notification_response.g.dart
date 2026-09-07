// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancelation_notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelationNotificationResponse _$CancelationNotificationResponseFromJson(
  Map<String, dynamic> json,
) => CancelationNotificationResponse(
  id: (json['id'] as num).toInt(),
  postOwnerId: (json['postOwnerId'] as num).toInt(),
  reservationId: (json['reservationId'] as num).toInt(),
  requesterName: json['requesterName'] as String,
  facilityName: json['facilityName'] as String,
  dateCancelled: json['dateCancelled'] as String,
  isSeen: json['isSeen'] as bool,
  reason: json['reason'] as String?,
  reservation: json['reservation'] == null
      ? null
      : ReservationResponse.fromJson(
          json['reservation'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CancelationNotificationResponseToJson(
  CancelationNotificationResponse instance,
) {
  final val = <String, dynamic>{
    'id': instance.id,
    'postOwnerId': instance.postOwnerId,
    'reservationId': instance.reservationId,
    'requesterName': instance.requesterName,
  };
  val['facilityName'] = instance.facilityName;
  val['dateCancelled'] = instance.dateCancelled;
  val['isSeen'] = instance.isSeen;
  val['reason'] = instance.reason;
  val['reservation'] = instance.reservation?.toJson();
  return val;
}
