import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_admin_desktop/model/working_hours_insert_request.dart';

part 'sport_center_insert_request.g.dart';

@JsonSerializable()
class SportCenterInsertRequest {
	String username;
	String phoneNumber;
	int cityId;
	String address;
	bool isEquipmentProvided;
	String description;
	int roleId;
	List<int> sportIds;
	List<int> amenityIds;
  List<WorkingHoursInsertRequest> workingHours;

	SportCenterInsertRequest(this.username,this.phoneNumber,this.cityId,this.address,this.isEquipmentProvided,this.description,this.roleId,this.sportIds,this.amenityIds,this.workingHours);

	factory SportCenterInsertRequest.fromJson(Map<String, dynamic> json) => _$SportCenterInsertRequestFromJson(json);

	Map<String, dynamic> toJson() => _$SportCenterInsertRequestToJson(this);
}