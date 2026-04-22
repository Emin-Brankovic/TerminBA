import 'package:json_annotation/json_annotation.dart';

part 'sport_center_reservation_stats_response.g.dart';

@JsonSerializable()
class SportCenterReservationStatsResponse {
	Map<String,int> reservationCountByFacility;
	Map<String,int> reservationCountBySport;
	Map<String,int> reservationCountByWeekDay;


	SportCenterReservationStatsResponse(this.reservationCountByFacility,this.reservationCountBySport,this.reservationCountByWeekDay,);

	factory SportCenterReservationStatsResponse.fromJson(Map<String, dynamic> json) => _$SportCenterReservationStatsResponseFromJson(json);

	Map<String, dynamic> toJson() => _$SportCenterReservationStatsResponseToJson(this);
}