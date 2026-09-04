import 'dart:convert';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:http/http.dart' as http;

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
}
