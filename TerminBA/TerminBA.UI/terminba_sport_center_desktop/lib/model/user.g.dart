// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  (json['id'] as num).toInt(),
  json['firstName'] as String,
  json['lastName'] as String,
  json['username'] as String,
  json['email'] as String,
  json['phoneNumber'] as String,
  json['instagramAccount'] as String?,
  _dateOnlyFromJson(json['birthDate'] as String),
  (json['cityId'] as num).toInt(),
  json['city'] == null
      ? null
      : City.fromJson(json['city'] as Map<String, dynamic>),
  json['isActive'] as bool,
  DateTime.parse(json['createdAt'] as String),
  json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'instagramAccount': instance.instagramAccount,
  'birthDate': _dateOnlyToJson(instance.birthDate),
  'cityId': instance.cityId,
  'city': instance.city,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
