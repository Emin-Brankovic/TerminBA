// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_review_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityReviewInsertRequest _$FacilityReviewInsertRequestFromJson(
  Map<String, dynamic> json,
) => FacilityReviewInsertRequest(
  (json['ratingNumber'] as num).toInt(),
  _dateOnlyFromJson(json['ratingDate'] as String),
  json['comment'] as String,
  (json['userId'] as num?)?.toInt(),
  (json['facilityId'] as num?)?.toInt(),
);

Map<String, dynamic> _$FacilityReviewInsertRequestToJson(
  FacilityReviewInsertRequest instance,
) => <String, dynamic>{
  'ratingNumber': instance.ratingNumber,
  'ratingDate': _dateOnlyToJson(instance.ratingDate),
  'comment': instance.comment,
  'userId': instance.userId,
  'facilityId': instance.facilityId,
};
