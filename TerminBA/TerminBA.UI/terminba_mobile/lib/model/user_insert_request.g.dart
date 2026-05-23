// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInsertRequest _$UserInsertRequestFromJson(Map<String, dynamic> json) =>
    UserInsertRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      instagramAccount: json['instagramAccount'] as String?,
      password: json['password'] as String,
      birthDate: _dateOnlyFromJson(json['birthDate'] as String),
      cityId: (json['cityId'] as num).toInt(),
      roleId: (json['roleId'] as num).toInt(),
    );

Map<String, dynamic> _$UserInsertRequestToJson(UserInsertRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'instagramAccount': instance.instagramAccount,
      'password': instance.password,
      'birthDate': _dateOnlyToJson(instance.birthDate),
      'cityId': instance.cityId,
      'roleId': instance.roleId,
    };
