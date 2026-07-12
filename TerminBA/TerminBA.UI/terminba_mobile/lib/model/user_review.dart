import 'package:terminba_mobile/model/user.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_review.g.dart';

@JsonSerializable()
class UserReview {
  int id;
  int ratingNumber;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
  DateTime ratingDate;
  String? comment;
  int? reviewerId;
  User? reviewer;
  int? reviewedId;
  User? reviewed;
  int? reservationId;

  UserReview({
    required this.id,
    required this.ratingNumber,
    required this.ratingDate,
    this.comment,
    this.reviewerId,
    this.reviewer,
    this.reviewedId,
    this.reviewed,
    this.reservationId,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) => _$UserReviewFromJson(json);

  Map<String, dynamic> toJson() => _$UserReviewToJson(this);
}

final DateFormat _isoDateOnlyFormatter = DateFormat('yyyy-MM-dd');

DateTime _dateOnlyFromJson(String value) =>
    _isoDateOnlyFormatter.parseStrict(value);

String _dateOnlyToJson(DateTime value) => _isoDateOnlyFormatter.format(value);
