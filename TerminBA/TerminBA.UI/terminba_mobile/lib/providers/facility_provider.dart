import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class FacilityProvider extends BaseProvider<Facility> {
  FacilityProvider() : super('Facility');

  Future<void> toggleFavorite(int facilityId) async {
    final uri = Uri.parse('${baseUrl}users/favorites/$facilityId');
    final headers = await createHeaders();

    final response = await http.post(uri, headers: headers, body: jsonEncode({}));
    if (!isValidResponse(response)) {
      throw Exception('Failed to update favorites');
    }
  }

  @override
  Facility fromJson(dynamic data) {
    return Facility.fromJson(data);
  }
}
