// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinanceSummaryResponse _$FinanceSummaryResponseFromJson(
  Map<String, dynamic> json,
) => FinanceSummaryResponse(
  (json['todayRevenue'] as num).toDouble(),
  (json['monthRevenue'] as num).toDouble(),
  json['monthLabel'] as String,
  (json['dailyRevenuePoints'] as List<dynamic>)
      .map(
        (e) => FinanceDailyRevenuePointResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$FinanceSummaryResponseToJson(
  FinanceSummaryResponse instance,
) => <String, dynamic>{
  'todayRevenue': instance.todayRevenue,
  'monthRevenue': instance.monthRevenue,
  'monthLabel': instance.monthLabel,
  'dailyRevenuePoints': instance.dailyRevenuePoints,
};

FinanceDailyRevenuePointResponse _$FinanceDailyRevenuePointResponseFromJson(
  Map<String, dynamic> json,
) => FinanceDailyRevenuePointResponse(
  (json['day'] as num).toInt(),
  (json['revenue'] as num).toDouble(),
);

Map<String, dynamic> _$FinanceDailyRevenuePointResponseToJson(
  FinanceDailyRevenuePointResponse instance,
) => <String, dynamic>{
  'day': instance.day,
  'revenue': instance.revenue,
};