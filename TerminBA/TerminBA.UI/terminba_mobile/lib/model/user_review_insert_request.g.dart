// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_review_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReviewInsertRequest _$UserReviewInsertRequestFromJson(
  Map<String, dynamic> json,
) => UserReviewInsertRequest(
  ratingNumber: (json['ratingNumber'] as num).toInt(),
  ratingDate: _dateOnlyFromJson(json['ratingDate'] as String),
  comment: json['comment'] as String?,
  reviewerId: (json['reviewerId'] as num?)?.toInt(),
  reviewedId: (json['reviewedId'] as num?)?.toInt(),
  reservationId: (json['reservationId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserReviewInsertRequestToJson(
  UserReviewInsertRequest instance,
) => <String, dynamic>{
  'ratingNumber': instance.ratingNumber,
  'ratingDate': _dateOnlyToJson(instance.ratingDate),
  'comment': instance.comment,
  'reviewerId': instance.reviewerId,
  'reviewedId': instance.reviewedId,
  'reservationId': instance.reservationId,
};
