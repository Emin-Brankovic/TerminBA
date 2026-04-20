import 'package:json_annotation/json_annotation.dart';

part 'facility_time_slot.g.dart';

@JsonSerializable()
class FacilityTimeSlot {
	String startTime;
	String endTime;
	bool isFree;

	FacilityTimeSlot(this.startTime,this.endTime,this.isFree);

	factory FacilityTimeSlot.fromJson(Map<String, dynamic> json) => _$FacilityTimeSlotFromJson(json);

	Map<String, dynamic> toJson() => _$FacilityTimeSlotToJson(this);
}
