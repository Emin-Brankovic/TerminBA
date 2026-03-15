// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      (json['appUserCount'] as num).toInt(),
      (json['appReservationCount'] as num).toInt(),
      (json['appSportCenterCount'] as num).toInt(),
      (json['userCountByMonth'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      (json['reservationCountByMonth'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'appUserCount': instance.appUserCount,
      'appReservationCount': instance.appReservationCount,
      'appSportCenterCount': instance.appSportCenterCount,
      'userCountByMonth': instance.userCountByMonth.map(
        (k, e) => MapEntry(k.toString(), e),
      ),
      'reservationCountByMonth': instance.reservationCountByMonth.map(
        (k, e) => MapEntry(k.toString(), e),
      ),
    };
