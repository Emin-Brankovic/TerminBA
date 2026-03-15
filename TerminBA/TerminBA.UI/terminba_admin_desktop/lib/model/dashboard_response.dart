import 'package:json_annotation/json_annotation.dart';

part 'dashboard_response.g.dart';

@JsonSerializable()
class DashboardResponse {
	int appUserCount;
	int appReservationCount;
	int appSportCenterCount;
	Map<int,int> userCountByMonth;
	Map<int,int> reservationCountByMonth;

	DashboardResponse(this.appUserCount,this.appReservationCount,this.appSportCenterCount,this.userCountByMonth,this.reservationCountByMonth,);

	factory DashboardResponse.fromJson(Map<String, dynamic> json) => _$DashboardResponseFromJson(json);

	Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);
}