import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';

part 'working_hours.g.dart';

@JsonSerializable()
class WorkingHours {
	int id;
	int sportCenterId;
  @JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
  DayOfWeek startDay;
  @JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
  DayOfWeek endDay;
	String openingHours;
	String closeingHours;
	DateTime validFrom;
	DateTime? validTo;
	bool isActive;

	WorkingHours(this.id,this.sportCenterId,this.startDay,this.endDay,this.openingHours,this.closeingHours,this.validFrom,this.validTo,this.isActive,);

	factory WorkingHours.fromJson(Map<String, dynamic> json) => _$WorkingHoursFromJson(json);

	Map<String, dynamic> toJson() => _$WorkingHoursToJson(this);
}