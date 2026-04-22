import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'dart:typed_data';

part 'sport_center_reservation_stats_report_request.g.dart';

@JsonSerializable()
class SportCenterReservationStatsReportRequest {
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
  DateTime? fromDate;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
  DateTime? toDate;
  @JsonKey(fromJson: _bytesFromJson, toJson: _bytesToJson)
  Uint8List? chartImage;
  int totalReservations;
  Map<String, int> countBySport;
  Map<String, int> countByFacility;

  SportCenterReservationStatsReportRequest({
    this.fromDate,
    this.toDate,
    this.chartImage,
    required this.totalReservations,
    required this.countBySport,
    required this.countByFacility,
  });

  factory SportCenterReservationStatsReportRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$SportCenterReservationStatsReportRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SportCenterReservationStatsReportRequestToJson(this);
}

DateTime? _dateOnlyFromJson(String? value) =>
    value == null ? null : DateTime.parse(value);

String? _dateOnlyToJson(DateTime? value) {
  if (value == null) {
    return null;
  }
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

Uint8List? _bytesFromJson(String? value) {
  if (value == null) {
    return null;
  }
  return base64Decode(value);
}

String? _bytesToJson(Uint8List? value) {
  if (value == null) {
    return null;
  }
  return base64Encode(value);
}
