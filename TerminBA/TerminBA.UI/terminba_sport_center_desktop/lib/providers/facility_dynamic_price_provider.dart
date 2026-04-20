import 'package:terminba_sport_center_desktop/model/dynamic_price_date_request.dart';
import 'package:terminba_sport_center_desktop/model/facility_dynamic_price.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FacilityDynamicPriceProvider extends BaseProvider<FacilityDynamicPrice> {
  FacilityDynamicPriceProvider() : super("FacilityDynamicPrice");

  Future<double> getDynamicPriceForDate(
    DynamicPriceForDateRequest request,
  ) async {
    var queryString = getQueryString(request.toQueryMap());
    var url = '$baseUrl$endpoint/selectedDatePrice?$queryString';
    var uri = Uri.parse(url);
    final headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      if (data is num) {
        return data.toDouble();
      }

      throw Exception('Invalid dynamic price response format.');
    }

    throw Exception("Unknown error");
  }

  @override
  FacilityDynamicPrice fromJson(dynamic data) {
    return FacilityDynamicPrice.fromJson(data);
  }
}
