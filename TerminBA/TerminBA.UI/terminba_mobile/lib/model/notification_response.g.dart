// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => NotificationResponse(
  id: (json['id'] as num).toInt(),
  postOwnerId: (json['postOwnerId'] as num).toInt(),
  reservationId: (json['reservationId'] as num).toInt(),
  reservation: json['reservation'] == null
      ? null
      : ReservationResponse.fromJson(
          json['reservation'] as Map<String, dynamic>,
        ),
  requesterName: json['requesterName'] as String,
  facilityName: json['facilityName'] as String,
  date: json['date'] as String,
  isSeen: json['isSeen'] as bool,
  reason: json['reason'] as String?,
  type: json['type'] as String,
);

Map<String, dynamic> _$NotificationResponseToJson(
  NotificationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'postOwnerId': instance.postOwnerId,
  'reservationId': instance.reservationId,
  'reservation': instance.reservation,
  'requesterName': instance.requesterName,
  'facilityName': instance.facilityName,
  'date': instance.date,
  'isSeen': instance.isSeen,
  'reason': instance.reason,
  'type': instance.type,
};
