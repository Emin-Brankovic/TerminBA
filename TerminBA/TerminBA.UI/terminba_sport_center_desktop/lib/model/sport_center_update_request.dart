import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/model/working_hours_insert_request.dart';

part 'sport_center_update_request.g.dart';

@JsonSerializable()
class SportCenterUpdateRequest {
	String username;
	String phoneNumber;
	String? contactEmail;
	int cityId;
	String address;
	bool isEquipmentProvided;
	String description;
	List<int> sportIds;
	List<int> amenityIds;
  List<WorkingHoursInsertRequest> workingHours;
  double? latitude;
  double? longitude;

	SportCenterUpdateRequest(this.username,this.phoneNumber,this.contactEmail,this.cityId,this.address,this.isEquipmentProvided,this.description,this.sportIds,this.amenityIds,this.workingHours,{this.latitude,this.longitude});

	factory SportCenterUpdateRequest.fromJson(Map<String, dynamic> json) => _$SportCenterUpdateRequestFromJson(json);

	Map<String, dynamic> toJson() => _$SportCenterUpdateRequestToJson(this);
}