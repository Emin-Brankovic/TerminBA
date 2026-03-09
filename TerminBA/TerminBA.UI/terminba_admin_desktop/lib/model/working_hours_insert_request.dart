import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_admin_desktop/enums/day_of_week_enum.dart';

part 'working_hours_insert_request.g.dart';

@JsonSerializable()
class WorkingHoursInsertRequest {
	int sportCenterId;
  @JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
  DayOfWeek startDay;

  @JsonKey(fromJson: dayOfWeekFromJson, toJson: dayOfWeekToJson)
  DayOfWeek endDay;
	String openingHours;
	String closeingHours;
	String validFrom;
	String validTo;

	WorkingHoursInsertRequest(this.sportCenterId,this.startDay,this.endDay,this.openingHours,this.closeingHours,this.validFrom,this.validTo,);

	factory WorkingHoursInsertRequest.fromJson(Map<String, dynamic> json) => _$WorkingHoursInsertRequestFromJson(json);

	Map<String, dynamic> toJson() => _$WorkingHoursInsertRequestToJson(this);
}


