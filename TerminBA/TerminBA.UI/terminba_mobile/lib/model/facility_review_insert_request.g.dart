// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_review_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityReviewInsertRequest _$FacilityReviewInsertRequestFromJson(
  Map<String, dynamic> json,
) => FacilityReviewInsertRequest(
  ratingNumber: (json['ratingNumber'] as num).toInt(),
  ratingDate: _dateOnlyFromJson(json['ratingDate'] as String),
  comment: json['comment'] as String?,
  userId: (json['userId'] as num?)?.toInt(),
  facilityId: (json['facilityId'] as num?)?.toInt(),
  reservationId: (json['reservationId'] as num?)?.toInt(),
);

Map<String, dynamic> _$FacilityReviewInsertRequestToJson(
  FacilityReviewInsertRequest instance,
) => <String, dynamic>{
  'ratingNumber': instance.ratingNumber,
  'ratingDate': _dateOnlyToJson(instance.ratingDate),
  'comment': instance.comment,
  'userId': instance.userId,
  'facilityId': instance.facilityId,
  'reservationId': instance.reservationId,
};
