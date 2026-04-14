// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationResponse _$ReservationResponseFromJson(Map<String, dynamic> json) =>
    ReservationResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      facilityId: (json['facilityId'] as num?)?.toInt(),
      facility: json['facility'] == null
          ? null
          : Facility.fromJson(json['facility'] as Map<String, dynamic>),
      reservationDate: _dateOnlyFromJson(json['reservationDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String?,
      price: (json['price'] as num).toDouble(),
      chosenSportId: (json['chosenSportId'] as num?)?.toInt(),
      chosenSport: json['chosenSport'] == null
          ? null
          : Sport.fromJson(json['chosenSport'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReservationResponseToJson(
  ReservationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'user': instance.user,
  'facilityId': instance.facilityId,
  'facility': instance.facility,
  'reservationDate': _dateOnlyToJson(instance.reservationDate),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'status': instance.status,
  'price': instance.price,
  'chosenSportId': instance.chosenSportId,
  'chosenSport': instance.chosenSport,
};
