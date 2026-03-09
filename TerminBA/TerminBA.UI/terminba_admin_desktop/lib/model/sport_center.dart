import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_admin_desktop/model/amenity.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/role.dart';
import 'package:terminba_admin_desktop/model/sport.dart';
import 'package:terminba_admin_desktop/model/working_hours.dart';

part 'sport_center.g.dart';

@JsonSerializable()
class SportCenter {
	int id;
	String username;
	String phoneNumber;
	int cityId;
  City city;
	String address;
	bool isEquipmentProvided;
	String description;
	DateTime createdAt;
	int roleId;
  Role role;
  List<Sport> availableSports;
  List<Amenity> availableAmenities;
  List<WorkingHours> workingHours;


	SportCenter(this.id,this.username,this.phoneNumber,this.cityId,this.address,this.isEquipmentProvided,this.description,this.createdAt,this.roleId,this.availableSports,this.availableAmenities,this.city,this.role,this.workingHours,);

	factory SportCenter.fromJson(Map<String, dynamic> json) => _$SportCenterFromJson(json);

	Map<String, dynamic> toJson() => _$SportCenterToJson(this);
}