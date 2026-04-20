// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_time_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityTimeSlot _$FacilityTimeSlotFromJson(Map<String, dynamic> json) =>
    FacilityTimeSlot(
      json['startTime'] as String,
      json['endTime'] as String,
      json['isFree'] as bool,
    );

Map<String, dynamic> _$FacilityTimeSlotToJson(FacilityTimeSlot instance) =>
    <String, dynamic>{
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isFree': instance.isFree,
    };
