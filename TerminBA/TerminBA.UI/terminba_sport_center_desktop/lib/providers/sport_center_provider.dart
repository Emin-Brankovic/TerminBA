import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_sport_center_desktop/model/sport_center.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_gallery_update_request.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';

class SportCenterProvider extends BaseProvider<SportCenter> {
  SportCenterProvider() : super("SportCenter");

  Future<SportCenter?> getCurrentSportCenter(int id) async {
    var url = "$baseUrl$endpoint/getCurrent";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      try {
        var data = jsonDecode(response.body);
        if (data == null) return null;
        return fromJson(data);
      } catch (_) {
        return null;
      }
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<SportCenter?> updateGallery(SportCenterGalleryUpdateRequest request) async {
    var url = "$baseUrl$endpoint/gallery";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      try {
        var data = jsonDecode(response.body);
        if (data == null) return null;
        return fromJson(data);
      } catch (_) {
        return null;
      }
    } else {
      throw Exception("Unknown error");
    }
  }

  @override
  SportCenter fromJson(dynamic data) {
    return SportCenter.fromJson(data);
  }
}
