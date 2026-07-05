import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/play_request_response.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class PlayRequestProvider extends BaseProvider<PlayRequestResponse> {
  PlayRequestProvider() : super('PlayRequest');

  @override
  PlayRequestResponse fromJson(dynamic data) {
    return PlayRequestResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Accepts or denies a received request.
  Future<PlayRequestResponse?> respondToRequest(int id, bool accepted) async {
    final url =
        '$baseUrl${endpoint}/requestResponse/$id?response=$accepted';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.put(uri, headers: headers);
    if (!isValidResponse(response)) return null;
    if (response.body.isEmpty) return null;
    final data = jsonDecode(response.body);
    return fromJson(data);
  }

  /// Cancels a sent request (by requester).
  Future<PlayRequestResponse?> cancelRequest(int id) async {
    final url = '$baseUrl${endpoint}/cancleRequest/$id';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.put(uri, headers: headers);
    if (!isValidResponse(response)) return null;
    if (response.body.isEmpty) return null;
    final data = jsonDecode(response.body);
    return fromJson(data);
  }

  Future<int> getUnseenCount() async {
    final url = '$baseUrl${endpoint}/received/unseen-count';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.get(uri, headers: headers);
    if (!isValidResponse(response)) return 0;
    if (response.body.isEmpty) return 0;
    return int.tryParse(response.body) ?? 0;
  }

  Future<PlayRequestResponse?> markAsSeen(int id) async {
    final url = '$baseUrl${endpoint}/$id/mark-seen';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.post(uri, headers: headers);
    if (!isValidResponse(response)) return null;
    if (response.body.isEmpty) return null;
    final data = jsonDecode(response.body);
    return fromJson(data);
  }

  Future<int> getUnseenResponsesCount() async {
    final url = '$baseUrl${endpoint}/sent/unseen-count';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.get(uri, headers: headers);
    if (!isValidResponse(response)) return 0;
    if (response.body.isEmpty) return 0;
    return int.tryParse(response.body) ?? 0;
  }

  Future<PlayRequestResponse?> markResponseAsSeen(int id) async {
    final url = '$baseUrl${endpoint}/$id/mark-response-seen';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.post(uri, headers: headers);
    if (!isValidResponse(response)) return null;
    if (response.body.isEmpty) return null;
    final data = jsonDecode(response.body);
    return fromJson(data);
  }
}

