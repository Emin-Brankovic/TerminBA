import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_review_insert_request.g.dart';

@JsonSerializable()
class UserReviewInsertRequest {
  int ratingNumber;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
  DateTime ratingDate;
  String? comment;
  int? reviewerId;
  int? reviewedId;
  int? reservationId;

  UserReviewInsertRequest({
    required this.ratingNumber,
    required this.ratingDate,
    this.comment,
    this.reviewerId,
    this.reviewedId,
    this.reservationId,
  });

  factory UserReviewInsertRequest.fromJson(Map<String, dynamic> json) => _$UserReviewInsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserReviewInsertRequestToJson(this);
}

final DateFormat _isoDateOnlyFormatter = DateFormat('yyyy-MM-dd');

DateTime _dateOnlyFromJson(String value) =>
    _isoDateOnlyFormatter.parseStrict(value);

String _dateOnlyToJson(DateTime value) => _isoDateOnlyFormatter.format(value);
