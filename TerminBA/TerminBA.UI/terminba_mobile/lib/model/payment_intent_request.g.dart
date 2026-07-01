// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentIntentRequest _$PaymentIntentRequestFromJson(
  Map<String, dynamic> json,
) => PaymentIntentRequest(
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String? ?? 'bam',
  facilityId: (json['facilityId'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  reservationId: (json['reservationId'] as num).toInt(),
);

Map<String, dynamic> _$PaymentIntentRequestToJson(
  PaymentIntentRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
  'facilityId': instance.facilityId,
  'userId': instance.userId,
  'reservationId': instance.reservationId,
};
