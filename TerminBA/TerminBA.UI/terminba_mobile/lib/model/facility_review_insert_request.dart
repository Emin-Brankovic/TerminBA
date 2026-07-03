import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facility_review_insert_request.g.dart';

@JsonSerializable()
class FacilityReviewInsertRequest {
	int ratingNumber;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
	DateTime ratingDate;
	String? comment;
	int? userId;
	int? facilityId;
	int? reservationId;

	FacilityReviewInsertRequest({
		required this.ratingNumber,
		required this.ratingDate,
		this.comment,
		this.userId,
		this.facilityId,
		this.reservationId,
	});

	factory FacilityReviewInsertRequest.fromJson(Map<String, dynamic> json) => _$FacilityReviewInsertRequestFromJson(json);

	Map<String, dynamic> toJson() => _$FacilityReviewInsertRequestToJson(this);
}

final DateFormat _isoDateOnlyFormatter = DateFormat('yyyy-MM-dd');

DateTime _dateOnlyFromJson(String value) =>
    _isoDateOnlyFormatter.parseStrict(value);

String _dateOnlyToJson(DateTime value) => _isoDateOnlyFormatter.format(value);
