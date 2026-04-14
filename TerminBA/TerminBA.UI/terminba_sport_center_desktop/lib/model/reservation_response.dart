import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/user.dart';

part 'reservation_response.g.dart';

@JsonSerializable()
class ReservationResponse {
  int id;
  int? userId;
  User? user;
  int? facilityId;
  Facility? facility;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
  DateTime reservationDate;
  String startTime;
  String endTime;
  String? status;
  double price;
  int? chosenSportId;
  Sport? chosenSport;

  ReservationResponse({
    required this.id,
    this.userId,
    this.user,
    this.facilityId,
    this.facility,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    this.status,
    required this.price,
    this.chosenSportId,
    this.chosenSport,
  });

  factory ReservationResponse.fromJson(Map<String, dynamic> json) =>
      _$ReservationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationResponseToJson(this);
}

DateTime _dateOnlyFromJson(String value) => DateTime.parse(value);

String _dateOnlyToJson(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
