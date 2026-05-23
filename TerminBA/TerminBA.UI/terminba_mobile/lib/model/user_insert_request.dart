import 'package:json_annotation/json_annotation.dart';

part'user_insert_request.g.dart';
@JsonSerializable()
class UserInsertRequest {
  String firstName;
  String lastName;
  String username;
  String email;
  String? phoneNumber;
  String? instagramAccount;
  String password;
  @JsonKey(fromJson: _dateOnlyFromJson, toJson: _dateOnlyToJson)
  DateTime birthDate;
  int cityId;
  int roleId;


  UserInsertRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.instagramAccount,
    required this.password,
    required this.birthDate,
    required this.cityId,
    required this.roleId,
  });

  factory UserInsertRequest.fromJson(Map<String, dynamic> json) => _$UserInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserInsertRequestToJson(this);

}
DateTime _dateOnlyFromJson(String value) => DateTime.parse(value);

String _dateOnlyToJson(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
