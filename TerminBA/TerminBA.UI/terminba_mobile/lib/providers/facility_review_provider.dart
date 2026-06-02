import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/facility_review.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class FacilityReviewProvider extends BaseProvider<FacilityReview> {
  FacilityReviewProvider() : super('FacilityReview');

  @override
  FacilityReview fromJson(dynamic data) {
    return FacilityReview.fromJson(data);
  }
  
    Future<double?> getFacilityAverageRating(int facilityId) async {
    var url = "$baseUrl$endpoint/averageRating/$facilityId";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      try {
        var rating = jsonDecode(response.body);
        if (rating == null) return null;
        return rating is int ? rating.toDouble() : rating as double;
      } catch (_) {
        return null;
      }
    } else {
      throw Exception("Unknown error");
    }
  }
}
