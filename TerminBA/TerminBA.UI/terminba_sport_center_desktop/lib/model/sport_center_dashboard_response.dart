import 'package:json_annotation/json_annotation.dart';

part 'sport_center_dashboard_response.g.dart';

@JsonSerializable()
class SportCenterDashboardResponse {
  double todayRevenue;
  double weeklyRevenue;
  int reservationsToday;
  int activeFacilities;
  int newReviews7d;
  double averageRating;
  int reviewsIn7d;
  int reviewsIn30d;
  Map<String, int> reservationsByWeekday;
  Map<String, int> reservationsBySport;
  Map<String, int> reservationsByFacility;
  List<DashboardUpcomingReservationResponse> upcomingReservations;
  List<DashboardLowRatedReviewResponse> lowestRatedReviews;

  SportCenterDashboardResponse(
    this.todayRevenue,
    this.weeklyRevenue,
    this.reservationsToday,
    this.activeFacilities,
    this.newReviews7d,
    this.averageRating,
    this.reviewsIn7d,
    this.reviewsIn30d,
    this.reservationsByWeekday,
    this.reservationsBySport,
    this.reservationsByFacility,
    this.upcomingReservations,
    this.lowestRatedReviews,
  );

  factory SportCenterDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$SportCenterDashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SportCenterDashboardResponseToJson(this);
}


@JsonSerializable()
class DashboardUpcomingReservationResponse {
  String slot;
  String facilityName;
  String bookedBy;
  String status;

  DashboardUpcomingReservationResponse(
    this.slot,
    this.facilityName,
    this.bookedBy,
    this.status,
  );

  factory DashboardUpcomingReservationResponse.fromJson(
          Map<String, dynamic> json) =>
      _$DashboardUpcomingReservationResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DashboardUpcomingReservationResponseToJson(this);
}

@JsonSerializable()
class DashboardLowRatedReviewResponse {
  String facilityName;
  int rating;
  String comment;

  DashboardLowRatedReviewResponse(
    this.facilityName,
    this.rating,
    this.comment,
  );

  factory DashboardLowRatedReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardLowRatedReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardLowRatedReviewResponseToJson(this);
}
