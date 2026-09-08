import 'dart:convert';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:http/http.dart' as http;
import 'package:terminba_sport_center_desktop/model/facility_time_slot.dart';

class FacilityProvider extends BaseProvider<Facility> {
  FacilityProvider() : super("Facility");

  @override
  Facility fromJson(dynamic data) {
    return Facility.fromJson(data);
  }

  Future<Facility?> getByIdWithAllDynamicPrices(int id) async {
    String url = "${baseUrl}Facility/$id/withAllDynamicPrices";

    var uri = Uri.parse(url);
    var headers = await createHeaders();

    final response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

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

      return data.map((item) => FacilityTimeSlot.fromJson(item)).toList();
    }

    return null;
  }
}
