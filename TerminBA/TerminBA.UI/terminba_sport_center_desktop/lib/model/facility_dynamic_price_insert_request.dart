import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';

part 'facility_dynamic_price_insert_request.g.dart';


@JsonSerializable()
class FacilityDynamicPriceInsertRequest {
	int facilityId;
	@JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
	DayOfWeek startDay;
	@JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
	DayOfWeek endDay;
	String startTime;
	String endTime;
	double pricePerHour;
	@JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
	DateTime validFrom;
	@JsonKey(fromJson: _nullableDateOnlyFromJson, toJson: _nullableDateOnlyToJson)
	DateTime? validTo;

	FacilityDynamicPriceInsertRequest(this.facilityId,this.startDay,this.endDay,this.startTime,this.endTime,this.pricePerHour,this.validFrom,this.validTo,);

	factory FacilityDynamicPriceInsertRequest.fromJson(Map<String, dynamic> json) => _$FacilityDynamicPriceInsertRequestFromJson(json);

	Map<String, dynamic> toJson() => _$FacilityDynamicPriceInsertRequestToJson(this);
}

DateTime _dateOnlyFromJson(String value) => DateTime.parse(value);

DateTime? _nullableDateOnlyFromJson(String? value) =>
		value == null ? null : DateTime.parse(value);

String _dateOnlyToJson(DateTime value) {
	final month = value.month.toString().padLeft(2, '0');
	final day = value.day.toString().padLeft(2, '0');
	return '${value.year}-$month-$day';
}

String? _nullableDateOnlyToJson(DateTime? value) =>
		value == null ? null : _dateOnlyToJson(value);