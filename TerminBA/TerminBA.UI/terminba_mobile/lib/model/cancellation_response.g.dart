// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancellation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancellationResponse _$CancellationResponseFromJson(
  Map<String, dynamic> json,
) => CancellationResponse(
  reservationState: json['reservationState'] as String,
  refundIssued: json['refundIssued'] as bool,
  refundStatus: json['refundStatus'] as String?,
  refundAmount: (json['refundAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CancellationResponseToJson(
  CancellationResponse instance,
) => <String, dynamic>{
  'reservationState': instance.reservationState,
  'refundIssued': instance.refundIssued,
  'refundStatus': instance.refundStatus,
  'refundAmount': instance.refundAmount,
};
