import 'dart:convert';

import 'package:terminba_mobile/model/user.dart';
import 'package:terminba_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User>{
  UserProvider() : super("User");

  @override
  User fromJson(dynamic data) {
    return User.fromJson(data);
  }

  Future<int> getPlayedMatches(int id) async {
    var url = "$baseUrl$endpoint/$id/playedMatches";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return int.tryParse(response.body) ?? 0;
    } else {
      return 0;
    }
  }

  Future<User?> getProfile() async {
    var url = "$baseUrl$endpoint/profile";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    }
    return null;
  }

  Future<int> getMyPlayedMatches() async {
    var url = "$baseUrl$endpoint/playedMatches";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return int.tryParse(response.body) ?? 0;
    } else {
      return 0;
    }
  }
}