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
	int? cityId;
  City? city;
	int? roleId;
  Role? role;
	bool isActive;
  @JsonKey(fromJson: _utcDateTimeFromJson, toJson: _utcDateTimeToJson)
	DateTime? createdAt;
  @JsonKey(fromJson: _nullableUtcDateTimeFromJson, toJson: _nullableUtcDateTimeToJson)
	DateTime? updatedAt;

	User(this.id,this.firstName,this.lastName,this.age,this.username,this.email,this.phoneNumber,this.instagramAccount,this.birthDate,this.cityId,this.roleId,this.isActive,this.createdAt,this.updatedAt,this.city,this.role);

	factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

	Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// Parses a server-issued UTC datetime string and converts it to local time.
DateTime _utcDateTimeFromJson(String value) => DateTime.parse(value).toLocal();
String _utcDateTimeToJson(DateTime value) => value.toUtc().toIso8601String();
DateTime? _nullableUtcDateTimeFromJson(String? value) =>
    value == null ? null : DateTime.parse(value).toLocal();
String? _nullableUtcDateTimeToJson(DateTime? value) =>
    value?.toUtc().toIso8601String();