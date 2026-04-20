import 'dart:convert';

import 'package:terminba_sport_center_desktop/model/facility_time_slot.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class FacilityTimeSlotProvider extends BaseProvider<FacilityTimeSlot> {
  FacilityTimeSlotProvider() : super("FacilityTimeSlot");

  Future<List<FacilityTimeSlot>?> getFacilityTimeSlots(
    int id,
    DateTime pickedDate,
  ) async {
    final dateParam = pickedDate.toIso8601String().split('T').first;
    final uri = Uri.parse(
      '${baseUrl}Facility/facilityTimeSlots/$id',
    ).replace(queryParameters: {'datePicked': dateParam});
    final headers = await createHeaders();

    final response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      final data = jsonDecode(response.body);
      if (data == null || data is! List) return null;

      return data.map((item) => fromJson(item)).toList();
    }

    return null;
  }

  @override
  FacilityTimeSlot fromJson(dynamic data) {
    return FacilityTimeSlot.fromJson(data);
  }
}
