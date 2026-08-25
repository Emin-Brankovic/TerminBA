import 'package:json_annotation/json_annotation.dart';

part 'reservation_update_request.g.dart';

@JsonSerializable()
class ReservationUpdateRequest {
  int? facilityId;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
  DateTime reservationDate;
  String startTime;
  String endTime;
  String status;
  double price;
  int? chosenSportId;

  ReservationUpdateRequest({
    this.facilityId,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    this.chosenSportId,
  });

  factory ReservationUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationUpdateRequestToJson(this);
}

DateTime _dateOnlyFromJson(String value) => DateTime.parse(value);

String _dateOnlyToJson(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
