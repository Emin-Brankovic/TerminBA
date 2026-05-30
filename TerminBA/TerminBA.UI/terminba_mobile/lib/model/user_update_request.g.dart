// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdateRequest _$UserUpdateRequestFromJson(Map<String, dynamic> json) =>
    UserUpdateRequest(
      json['firstName'] as String,
      json['lastName'] as String,
      json['username'] as String,
      json['email'] as String,
      json['phoneNumber'] as String?,
      json['instagramAccount'] as String?,
      UserUpdateRequest._birthDateFromJson(json['birthDate'] as String),
      (json['cityId'] as num).toInt(),
    );

Map<String, dynamic> _$UserUpdateRequestToJson(UserUpdateRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'instagramAccount': instance.instagramAccount,
      'birthDate': UserUpdateRequest._birthDateToJson(instance.birthDate),
      'cityId': instance.cityId,
    };
