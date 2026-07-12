// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReview _$UserReviewFromJson(Map<String, dynamic> json) => UserReview(
  id: (json['id'] as num).toInt(),
  ratingNumber: (json['ratingNumber'] as num).toInt(),
  ratingDate: _dateOnlyFromJson(json['ratingDate'] as String),
  comment: json['comment'] as String?,
  reviewerId: (json['reviewerId'] as num?)?.toInt(),
  reviewer: json['reviewer'] == null
      ? null
      : User.fromJson(json['reviewer'] as Map<String, dynamic>),
  reviewedId: (json['reviewedId'] as num?)?.toInt(),
  reviewed: json['reviewed'] == null
      ? null
      : User.fromJson(json['reviewed'] as Map<String, dynamic>),
  reservationId: (json['reservationId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserReviewToJson(UserReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ratingNumber': instance.ratingNumber,
      'ratingDate': _dateOnlyToJson(instance.ratingDate),
      'comment': instance.comment,
      'reviewerId': instance.reviewerId,
      'reviewer': instance.reviewer,
      'reviewedId': instance.reviewedId,
      'reviewed': instance.reviewed,
      'reservationId': instance.reservationId,
    };
