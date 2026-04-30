// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_center_dashboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportCenterDashboardResponse _$SportCenterDashboardResponseFromJson(
  Map<String, dynamic> json,
) => SportCenterDashboardResponse(
  (json['todayRevenue'] as num).toDouble(),
  (json['weeklyRevenue'] as num).toDouble(),
  (json['reservationsToday'] as num).toInt(),
  (json['activeFacilities'] as num).toInt(),
  (json['newReviews7d'] as num).toInt(),
  (json['averageRating'] as num).toDouble(),
  (json['reviewsIn7d'] as num).toInt(),
  (json['reviewsIn30d'] as num).toInt(),
  Map<String, int>.from(json['reservationsByWeekday'] as Map),
  Map<String, int>.from(json['reservationsBySport'] as Map),
  Map<String, int>.from(json['reservationsByFacility'] as Map),
  (json['upcomingReservations'] as List<dynamic>)
      .map(
        (e) => DashboardUpcomingReservationResponse.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  (json['lowestRatedReviews'] as List<dynamic>)
      .map(
        (e) =>
            DashboardLowRatedReviewResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$SportCenterDashboardResponseToJson(
  SportCenterDashboardResponse instance,
) => <String, dynamic>{
  'todayRevenue': instance.todayRevenue,
  'weeklyRevenue': instance.weeklyRevenue,
  'reservationsToday': instance.reservationsToday,
  'activeFacilities': instance.activeFacilities,
  'newReviews7d': instance.newReviews7d,
  'averageRating': instance.averageRating,
  'reviewsIn7d': instance.reviewsIn7d,
  'reviewsIn30d': instance.reviewsIn30d,
  'reservationsByWeekday': instance.reservationsByWeekday,
  'reservationsBySport': instance.reservationsBySport,
  'reservationsByFacility': instance.reservationsByFacility,
  'upcomingReservations': instance.upcomingReservations,
  'lowestRatedReviews': instance.lowestRatedReviews,
};

DashboardUpcomingReservationResponse
_$DashboardUpcomingReservationResponseFromJson(Map<String, dynamic> json) =>
    DashboardUpcomingReservationResponse(
      json['slot'] as String,
      json['facilityName'] as String,
      json['bookedBy'] as String,
      json['status'] as String,
    );

Map<String, dynamic> _$DashboardUpcomingReservationResponseToJson(
  DashboardUpcomingReservationResponse instance,
) => <String, dynamic>{
  'slot': instance.slot,
  'facilityName': instance.facilityName,
  'bookedBy': instance.bookedBy,
  'status': instance.status,
};

DashboardLowRatedReviewResponse _$DashboardLowRatedReviewResponseFromJson(
  Map<String, dynamic> json,
) => DashboardLowRatedReviewResponse(
  json['facilityName'] as String,
  (json['rating'] as num).toInt(),
  json['comment'] as String,
);

Map<String, dynamic> _$DashboardLowRatedReviewResponseToJson(
  DashboardLowRatedReviewResponse instance,
) => <String, dynamic>{
  'facilityName': instance.facilityName,
  'rating': instance.rating,
  'comment': instance.comment,
};
