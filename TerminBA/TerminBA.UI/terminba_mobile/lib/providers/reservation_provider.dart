import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/model/cancellation_response.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<ReservationResponse> {
  ReservationProvider() : super('Reservation');

  @override
  ReservationResponse fromJson(dynamic data) {
    return ReservationResponse.fromJson(data as Map<String, dynamic>);
  }

    Future<CancellationResponse> cancelReservationPost(int id) async {
    var url = '$baseUrl$endpoint/cancel/$id';
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.put(uri, headers: headers);
    if (!isValidResponse(response)) {
      throw Exception('Failed to cancel reservation');
    }
    
    return CancellationResponse.fromJson(jsonDecode(response.body));
  }

}

