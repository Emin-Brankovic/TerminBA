import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';

part 'facility_dynamic_price.g.dart';

@JsonSerializable()
class FacilityDynamicPrice {
	int id;
	int facilityId;
	String? facilityName;
	@JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
	DayOfWeek startDay;
	@JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
	DayOfWeek endDay;
	String startTime;
	String endTime;
	double pricePerHour;
	bool isActive;
	DateTime validFrom;
	DateTime? validTo;

	FacilityDynamicPrice({
		required this.id,
		required this.facilityId,
		this.facilityName,
		required this.startDay,
		required this.endDay,
		required this.startTime,
		required this.endTime,
		required this.pricePerHour,
		required this.isActive,
		required this.validFrom,
		this.validTo,
	});

	factory FacilityDynamicPrice.fromJson(Map<String, dynamic> json) =>
			_$FacilityDynamicPriceFromJson(json);

	Map<String, dynamic> toJson() => _$FacilityDynamicPriceToJson(this);
}
