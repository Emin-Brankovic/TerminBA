import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/model/facility_dynamic_price_insert_request.dart';

part 'facility_insert_request.g.dart';

@JsonSerializable()
class FacilityInsertRequest {
	String name;
	int maxCapacity;
	bool isDynamicPricing;
	double? staticPrice;
	bool isIndoor;
	@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
	Duration duration;
	int sportCenterId;
	int turfTypeId;
	List<int> availableSportsIds;
	List<FacilityDynamicPriceInsertRequest>? dynamicPrices;

	FacilityInsertRequest({
		required this.name,
		required this.maxCapacity,
		required this.isDynamicPricing,
		this.staticPrice,
		required this.isIndoor,
		required this.duration,
		required this.sportCenterId,
		required this.turfTypeId,
		List<int>? availableSportsIds,
		this.dynamicPrices,
	}) : availableSportsIds = availableSportsIds ?? [];

	factory FacilityInsertRequest.fromJson(Map<String, dynamic> json) =>
			_$FacilityInsertRequestFromJson(json);

	Map<String, dynamic> toJson() => _$FacilityInsertRequestToJson(this);
}

Duration _durationFromJson(dynamic value) {
	if (value is num) {
		return Duration(microseconds: value.toInt());
	}

	if (value is String) {
		final parts = value.split(':');
		if (parts.length >= 2) {
			final hours = int.tryParse(parts[0]) ?? 0;
			final minutes = int.tryParse(parts[1]) ?? 0;

			var seconds = 0;
			if (parts.length >= 3) {
				seconds = int.tryParse(parts[2].split('.').first) ?? 0;
			}

			return Duration(hours: hours, minutes: minutes, seconds: seconds);
		}
	}

	throw ArgumentError('Invalid duration value: $value');
}

String _durationToJson(Duration value) {
	final hours = value.inHours.toString().padLeft(2, '0');
	final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
	return '$hours:$minutes';
}
