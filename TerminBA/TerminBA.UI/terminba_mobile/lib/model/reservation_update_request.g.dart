// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationUpdateRequest _$ReservationUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ReservationUpdateRequest(
  facilityId: (json['facilityId'] as num?)?.toInt(),
  reservationDate: _dateOnlyFromJson(json['reservationDate'] as String),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  status: json['status'] as String,
  price: (json['price'] as num).toDouble(),
  chosenSportId: (json['chosenSportId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReservationUpdateRequestToJson(
  ReservationUpdateRequest instance,
) => <String, dynamic>{
  'facilityId': instance.facilityId,
  'reservationDate': _dateOnlyToJson(instance.reservationDate),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'status': instance.status,
  'price': instance.price,
  'chosenSportId': instance.chosenSportId,
};
