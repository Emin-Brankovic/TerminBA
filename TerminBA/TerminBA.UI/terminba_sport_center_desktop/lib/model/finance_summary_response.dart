import 'package:json_annotation/json_annotation.dart';

part 'finance_summary_response.g.dart';

@JsonSerializable()
class FinanceSummaryResponse {
  double todayRevenue;
  double monthRevenue;
  String monthLabel;
  List<FinanceDailyRevenuePointResponse> dailyRevenuePoints;

  FinanceSummaryResponse(
    this.todayRevenue,
    this.monthRevenue,
    this.monthLabel,
    this.dailyRevenuePoints,
  );

  factory FinanceSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$FinanceSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceSummaryResponseToJson(this);
}

@JsonSerializable()
class FinanceDailyRevenuePointResponse {
  int day;
  double revenue;

  FinanceDailyRevenuePointResponse(this.day, this.revenue);

  factory FinanceDailyRevenuePointResponse.fromJson(Map<String, dynamic> json) =>
      _$FinanceDailyRevenuePointResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceDailyRevenuePointResponseToJson(this);
}