// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center_reservation_stats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportCenterReservationStatsResponse
_$SportCenterReservationStatsResponseFromJson(Map<String, dynamic> json) =>
    SportCenterReservationStatsResponse(
      Map<String, int>.from(json['reservationCountByFacility'] as Map),
      Map<String, int>.from(json['reservationCountBySport'] as Map),
      Map<String, int>.from(json['reservationCountByWeekDay'] as Map),
    );

Map<String, dynamic> _$SportCenterReservationStatsResponseToJson(
  SportCenterReservationStatsResponse instance,
) => <String, dynamic>{
  'reservationCountByFacility': instance.reservationCountByFacility,
  'reservationCountBySport': instance.reservationCountBySport,
  'reservationCountByWeekDay': instance.reservationCountByWeekDay,
};
