import 'package:json_annotation/json_annotation.dart';


part 'payment_intent_response.g.dart';

@JsonSerializable()
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final String status;

  const PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.status,
  });

    factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentIntentResponseToJson(this);
}
