import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_admin_desktop/enums/day_of_week_enum.dart';

part 'working_hours_insert_request.g.dart';

@JsonSerializable()
class WorkingHoursInsertRequest {
  int sportCenterId;
  @JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
  DayOfWeek startDay;

  @JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
  DayOfWeek endDay;
  String openingHours;
  String closeingHours;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime validFrom;
  @JsonKey(fromJson: _nullableDateFromJson, toJson: _nullableDateToJson)
  DateTime? validTo;

  WorkingHoursInsertRequest(
    this.sportCenterId,
    this.startDay,
    this.endDay,
    this.openingHours,
    this.closeingHours,
    this.validFrom,
    this.validTo,
  );

  factory WorkingHoursInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursInsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingHoursInsertRequestToJson(this);

  static DateTime _dateFromJson(String value) => DateTime.parse(value);

  static String _dateToJson(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static DateTime? _nullableDateFromJson(String? value) =>
      value == null ? null : DateTime.parse(value);

  static String? _nullableDateToJson(DateTime? value) =>
      value == null ? null : _dateToJson(value);
}
