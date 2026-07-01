import 'package:json_annotation/json_annotation.dart';

part 'payment_intent_request.g.dart';
@JsonSerializable()
class PaymentIntentRequest {
  final int amount;
  final String currency;
  final int? facilityId;
  final int? userId;
  final int reservationId;

  const PaymentIntentRequest({
    required this.amount,
    this.currency = 'bam',
    this.facilityId,
    this.userId,
    required this.reservationId,
  });


  factory PaymentIntentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentIntentRequestToJson(this);
}
