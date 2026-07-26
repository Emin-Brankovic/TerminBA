// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationResult _$RecommendationResultFromJson(
  Map<String, dynamic> json,
) => RecommendationResult(
  facilityId: (json['facilityId'] as num).toInt(),
  facilityName: json['facilityName'] as String,
  sportCenterName: json['sportCenterName'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  price: (json['price'] as num).toDouble(),
  score: (json['score'] as num).toDouble(),
  reasons: (json['reasons'] as List<dynamic>).map((e) => e as String).toList(),
  isPersonalized: json['isPersonalized'] as bool,
);

Map<String, dynamic> _$RecommendationResultToJson(
  RecommendationResult instance,
) => <String, dynamic>{
  'facilityId': instance.facilityId,
  'facilityName': instance.facilityName,
  'sportCenterName': instance.sportCenterName,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'price': instance.price,
  'score': instance.score,
  'reasons': instance.reasons,
  'isPersonalized': instance.isPersonalized,
};
