import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_mobile/model/amenity.dart';
import 'package:terminba_mobile/model/city.dart';
import 'package:terminba_mobile/model/role.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/model/sport_center_photo_response.dart';
import 'package:terminba_mobile/model/working_hours.dart';

part 'sport_center.g.dart';

@JsonSerializable()
class SportCenter {
  int id;
  String username;
  String phoneNumber;
  String? contactEmail;
  int cityId;
  City? city;
  String address;
  bool isEquipmentProvided;
  String description;
  DateTime createdAt;
  DateTime? updatedAt;
  int roleId;
  Role? role;
  double? longitude ;
  double? latitude;
  @JsonKey(fromJson: _bytesFromJson, toJson: _bytesToJson)
  Uint8List? credentialsReport;
  List<Sport> availableSports;
  List<Amenity> availableAmenities;
  List<WorkingHours> workingHours;
  List<SportCenterPhotoResponse> photos;

  SportCenter(
    this.id,
    this.username,
    this.phoneNumber,
    this.contactEmail,
    this.cityId,
    this.address,
    this.isEquipmentProvided,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.roleId,
    this.availableSports,
    this.availableAmenities,
    this.city,
    this.role,
    this.workingHours,
    this.photos,
    this.credentialsReport,
    this.longitude,
    this.latitude,
  );

  factory SportCenter.fromJson(Map<String, dynamic> json) =>
      _$SportCenterFromJson(json);

  Map<String, dynamic> toJson() => _$SportCenterToJson(this);
}

Uint8List? _bytesFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return base64Decode(value);
  if (value is List) return Uint8List.fromList(value.cast<int>());
  throw ArgumentError(
    'Invalid bytes value for credentialsReport: ${value.runtimeType}',
  );
}

String? _bytesToJson(Uint8List? value) =>
    value == null ? null : base64Encode(value);
