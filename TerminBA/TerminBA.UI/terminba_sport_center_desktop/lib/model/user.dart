import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/model/city.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
	int id;
	String firstName;
	String lastName;
	String username;
	String email;
	String phoneNumber;
	String? instagramAccount;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
	DateTime birthDate;
	int cityId;
	City? city;
	bool isActive;
	DateTime createdAt;
	DateTime? updatedAt;

	User(this.id,this.firstName,this.lastName,this.username,this.email,this.phoneNumber,this.instagramAccount,this.birthDate,this.cityId,this.city,this.isActive,this.createdAt,this.updatedAt,);

	factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

	Map<String, dynamic> toJson() => _$UserToJson(this);

}

DateTime _dateOnlyFromJson(String value) => DateTime.parse(value);

String _dateOnlyToJson(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}