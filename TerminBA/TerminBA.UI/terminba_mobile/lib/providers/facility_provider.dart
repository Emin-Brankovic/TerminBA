import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_time_slot.dart';
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


  Future<List<FacilityTimeSlot>> getTimeSlots({
    required int facilityId,
    required DateTime date,
  }) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final url = '${baseUrl}Facility/facilityTimeSlots/$facilityId?datePicked=$dateString';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => FacilityTimeSlot.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load time slots');
  }

  @override
  Facility fromJson(dynamic data) {
    return Facility.fromJson(data);
  }
}
