import 'package:terminba_sport_center_desktop/model/facility_dynamic_price.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/sport_center.dart';
import 'package:terminba_sport_center_desktop/model/turf_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facility.g.dart';

@JsonSerializable()
class Facility {
  int id;
  String? name;
  int maxCapacity;
  bool isDynamicPricing;
  double? staticPrice;
  bool isIndoor;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  Duration duration;
  int sportCenterId;
  SportCenter? sportCenter;
  int turfTypeId;
  TurfType? turfType;
  List<Sport> availableSports;
  List<FacilityDynamicPrice> dynamicPrices;

  Facility({
    required this.id,
    this.name,
    required this.maxCapacity,
    required this.isDynamicPricing,
    this.staticPrice,
    required this.isIndoor,
    required this.duration,
    required this.sportCenterId,
    this.sportCenter,
    required this.turfTypeId,
    this.turfType,
    List<Sport>? availableSports,
    List<FacilityDynamicPrice>? dynamicPrices,
  })  : availableSports = availableSports ?? [],
        dynamicPrices = dynamicPrices ?? [];


  factory Facility.fromJson(Map<String, dynamic> json) =>
      _$FacilityFromJson(json);

  Map<String, dynamic> toJson() => _$FacilityToJson(this);

  String get durationHms => _durationToJson(duration);
}

Duration _durationFromJson(dynamic value) {
  if (value is num) {
    return Duration(microseconds: value.toInt());
  }

  if (value is String) {
    final parts = value.split(':');
    if (parts.length >= 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;

      final secondsParts = parts[2].split('.');
      final seconds = int.tryParse(secondsParts[0]) ?? 0;

      var microseconds = 0;
      if (secondsParts.length > 1) {
        final fraction = secondsParts[1].padRight(6, '0').substring(0, 6);
        microseconds = int.tryParse(fraction) ?? 0;
      }

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        microseconds: microseconds,
      );
    }
  }

  throw ArgumentError('Invalid duration value: $value');
}

String _durationToJson(Duration value) {
  final hours = value.inHours.toString().padLeft(2, '0');
  final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}