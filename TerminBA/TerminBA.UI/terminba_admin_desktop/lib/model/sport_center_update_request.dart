import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_admin_desktop/model/working_hours_insert_request.dart';

part 'sport_center_update_request.g.dart';

@JsonSerializable()
class SportCenterUpdateRequest {
	String username;
	String phoneNumber;
	int cityId;
	String address;
	bool isEquipmentProvided;
	String description;
	List<int> sportIds;
	List<int> amenityIds;
  List<WorkingHoursInsertRequest> workingHours;

	SportCenterUpdateRequest(this.username,this.phoneNumber,this.cityId,this.address,this.isEquipmentProvided,this.description,this.sportIds,this.amenityIds,this.workingHours);

	factory SportCenterUpdateRequest.fromJson(Map<String, dynamic> json) => _$SportCenterUpdateRequestFromJson(json);

	Map<String, dynamic> toJson() => _$SportCenterUpdateRequestToJson(this);
}