// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  (json['id'] as num).toInt(),
  json['firstName'] as String,
  json['lastName'] as String,
  (json['age'] as num?)?.toInt(),
  json['username'] as String,
  json['email'] as String,
  json['phoneNumber'] as String,
  json['instagramAccount'] as String?,
  DateTime.parse(json['birthDate'] as String),
  (json['cityId'] as num?)?.toInt(),
  (json['roleId'] as num?)?.toInt(),
  _nullableUtcDateTimeFromJson(json['createdAt'] as String?),
  _nullableUtcDateTimeFromJson(json['updatedAt'] as String?),
  json['city'] == null
      ? null
      : City.fromJson(json['city'] as Map<String, dynamic>),
  json['role'] == null
      ? null
      : Role.fromJson(json['role'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'age': instance.age,
  'username': instance.username,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'instagramAccount': instance.instagramAccount,
  'birthDate': instance.birthDate.toIso8601String(),
  'cityId': instance.cityId,
  'city': instance.city,
  'roleId': instance.roleId,
  'role': instance.role,
  'createdAt': _nullableUtcDateTimeToJson(instance.createdAt),
  'updatedAt': _nullableUtcDateTimeToJson(instance.updatedAt),
};
