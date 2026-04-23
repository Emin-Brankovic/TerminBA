import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/user.dart';

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facility_review.g.dart';

@JsonSerializable()
class FacilityReview {
	int id;
	int ratingNumber;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
	DateTime ratingDate;
	String? comment;
	int? userId;
	User? user;
	int? facilityId;
	Facility? facility;

	FacilityReview({
		required this.id,
		required this.ratingNumber,
		required this.ratingDate,
		this.comment,
		this.userId,
		this.user,
		this.facilityId,
		this.facility,
	});

	factory FacilityReview.fromJson(Map<String, dynamic> json) => _$FacilityReviewFromJson(json);

	Map<String, dynamic> toJson() => _$FacilityReviewToJson(this);
}

final DateFormat _isoDateOnlyFormatter = DateFormat('yyyy-MM-dd');

DateTime _dateOnlyFromJson(String value) =>
    _isoDateOnlyFormatter.parseStrict(value);

String _dateOnlyToJson(DateTime value) => _isoDateOnlyFormatter.format(value);
