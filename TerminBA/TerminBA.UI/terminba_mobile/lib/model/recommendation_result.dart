import 'package:json_annotation/json_annotation.dart';

part 'recommendation_result.g.dart';

@JsonSerializable()
class RecommendationResult {
  final int facilityId;
  final String facilityName;
  final String sportCenterName;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final double score;
  final List<String> reasons;
  final bool isPersonalized;

  const RecommendationResult({
    required this.facilityId,
    required this.facilityName,
    required this.sportCenterName,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.score,
    required this.reasons,
    required this.isPersonalized,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResultFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationResultToJson(this);
}
