// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityReview _$FacilityReviewFromJson(Map<String, dynamic> json) =>
    FacilityReview(
      id: (json['id'] as num).toInt(),
      ratingNumber: (json['ratingNumber'] as num).toInt(),
      ratingDate: _dateOnlyFromJson(json['ratingDate'] as String),
      comment: json['comment'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      facilityId: (json['facilityId'] as num?)?.toInt(),
      facility: json['facility'] == null
          ? null
          : Facility.fromJson(json['facility'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FacilityReviewToJson(FacilityReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ratingNumber': instance.ratingNumber,
      'ratingDate': _dateOnlyToJson(instance.ratingDate),
      'comment': instance.comment,
      'userId': instance.userId,
      'user': instance.user,
      'facilityId': instance.facilityId,
      'facility': instance.facility,
    };
