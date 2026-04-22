// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center_reservation_stats_report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportCenterReservationStatsReportRequest
_$SportCenterReservationStatsReportRequestFromJson(Map<String, dynamic> json) =>
    SportCenterReservationStatsReportRequest(
      fromDate: _dateOnlyFromJson(json['fromDate'] as String?),
      toDate: _dateOnlyFromJson(json['toDate'] as String?),
      chartImage: _bytesFromJson(json['chartImage'] as String?),
      totalReservations: (json['totalReservations'] as num).toInt(),
      countBySport: Map<String, int>.from(json['countBySport'] as Map),
      countByFacility: Map<String, int>.from(json['countByFacility'] as Map),
    );

Map<String, dynamic> _$SportCenterReservationStatsReportRequestToJson(
  SportCenterReservationStatsReportRequest instance,
) => <String, dynamic>{
  'fromDate': _dateOnlyToJson(instance.fromDate),
  'toDate': _dateOnlyToJson(instance.toDate),
  'chartImage': _bytesToJson(instance.chartImage),
  'totalReservations': instance.totalReservations,
  'countBySport': instance.countBySport,
  'countByFacility': instance.countByFacility,
};
