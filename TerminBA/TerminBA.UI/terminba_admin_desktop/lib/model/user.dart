import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/role.dart';

part 'user.g.dart';
@JsonSerializable()
class User {
	int id;
	String firstName;
	String lastName;
	int? age;
	String username;
	String email;
	String phoneNumber;
	String? instagramAccount;
	DateTime birthDate;
	int cityId;
  City? city;
	int roleId;
  Role? role;
	bool isActive;
	DateTime? createdAt;
	DateTime? updatedAt;

	User(this.id,this.firstName,this.lastName,this.age,this.username,this.email,this.phoneNumber,this.instagramAccount,this.birthDate,this.cityId,this.roleId,this.isActive,this.createdAt,this.updatedAt,this.city,this.role);

	factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

	Map<String, dynamic> toJson() => _$UserToJson(this);
}