import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/payment_intent_request.dart';
import 'package:terminba_mobile/model/payment_intent_response.dart';
import 'package:terminba_mobile/providers/base_provider.dart';


class PaymentProvider extends BaseProvider<PaymentIntentResponse> {
  PaymentProvider() : super('payments');

  @override
  PaymentIntentResponse fromJson(dynamic data) {
    return PaymentIntentResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<PaymentIntentResponse> createPaymentIntent(
    PaymentIntentRequest request,
  ) async {
    final url = '${baseUrl}payments/create-payment-intent';
    final uri = Uri.parse(url);
    final headers = await createHeaders();
    final body = jsonEncode(request.toJson());

    final response = await http.post(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PaymentIntentResponse.fromJson(data);
    } else {
      throw Exception('Failed to create payment intent.');
    }
  }
}
