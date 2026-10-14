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
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PaymentIntentResponse.fromJson(data);
      } catch (e) {
        throw FormatException('Failed to parse payment intent response: $e');
      }
    } else {
      throw Exception('Failed to create payment intent.');
    }
  }

  Future<bool> confirmPaymentIntent(String paymentIntentId) async {
    final url = '${baseUrl}payments/confirm/$paymentIntentId';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['status'] == 'succeeded';
      } catch (e) {
        throw FormatException('Failed to parse confirmation response: $e');
      }
    } else {
      throw Exception('Failed to confirm payment intent.');
    }
  }

  Future<bool> cancelPaymentIntent(String paymentIntentId) async {
    final url = '${baseUrl}payments/cancel/$paymentIntentId';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['status'] == 'canceled';
      } catch (e) {
        throw FormatException('Failed to parse cancellation response: $e');
      }
    } else {
      throw Exception('Failed to cancel payment intent.');
    }
  }
}
