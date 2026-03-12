import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_update_request.g.dart';

@JsonSerializable()
class UserUpdateRequest {
  String firstName;
  String lastName;
  String username;
  String email;
  String? phoneNumber;
  String? instagramAccount;
  @JsonKey(toJson: _birthDateToJson, fromJson: _birthDateFromJson)
  DateTime birthDate;
  int cityId;

  UserUpdateRequest(
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
    this.instagramAccount,
    this.birthDate,
    this.cityId,
  );

  static String _birthDateToJson(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static DateTime _birthDateFromJson(String date) =>
      DateFormat('yyyy-MM-dd').parse(date);

  factory UserUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateRequestToJson(this);
}
