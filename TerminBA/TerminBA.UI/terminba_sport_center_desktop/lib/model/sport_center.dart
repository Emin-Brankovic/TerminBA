import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_sport_center_desktop/model/amenity.dart';
import 'package:terminba_sport_center_desktop/model/city.dart';
import 'package:terminba_sport_center_desktop/model/role.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/working_hours.dart';

part 'sport_center.g.dart';

@JsonSerializable()
class SportCenter {
  int id;
  String username;
  String phoneNumber;
  int cityId;
  City? city;
  String address;
  bool isEquipmentProvided;
  String description;
  DateTime createdAt;
  DateTime? updatedAt;
  int roleId;
  Role? role;
  @JsonKey(fromJson: _bytesFromJson, toJson: _bytesToJson)
  Uint8List? credentialsReport;
  List<Sport> availableSports;
  List<Amenity> availableAmenities;
  List<WorkingHours> workingHours;

  SportCenter(
    this.id,
    this.username,
    this.phoneNumber,
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
    this.credentialsReport,
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
