import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_sport_center_desktop/model/reservation_response.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<ReservationResponse> {
  ReservationProvider() : super("Reservation");

  Future<ReservationResponse?> cancelReservation(int id) async {
    final url = '$baseUrl$endpoint/cancel/$id';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.put(uri, headers: headers, body: jsonEncode({}));

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      final data = jsonDecode(response.body);
      if (data == null) return null;
      return fromJson(data);
    }

    return null;
  }

  @override
  ReservationResponse fromJson(dynamic data) {
    return ReservationResponse.fromJson(data);
  }
}
