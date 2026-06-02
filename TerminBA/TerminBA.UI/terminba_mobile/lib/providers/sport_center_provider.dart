import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/search_result.dart';
import 'package:terminba_mobile/model/sport_center.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class SportCenterProvider extends BaseProvider<SportCenter> {
  SportCenterProvider() : super("SportCenter");

  @override
  SportCenter fromJson(dynamic data) {
    return SportCenter.fromJson(data);
  }

  Future<SearchResult<SportCenter>> searchAvailable(
    Map<String, dynamic> filter,
  ) async {
    var url = '${baseUrl}SportCenter/searchAvailable';
    if (filter.isNotEmpty) {
      var query = getQueryString(filter);
      if (query.startsWith('&')) {
        query = query.substring(1);
      }
      url = '$url?$query';
    }

    final uri = Uri.parse(url);
    final headers = await createHeaders();
    final response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      final result = SearchResult<SportCenter>();
      result.totalCount = (data['count']) as int?;
      result.items = List<SportCenter>.from(
        data['items'].map((e) => fromJson(e)),
      );
      return result;
    }

    throw Exception('Unknown error');
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
