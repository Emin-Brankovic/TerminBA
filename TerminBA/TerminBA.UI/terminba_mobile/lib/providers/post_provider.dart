import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/post_response.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class PostProvider extends BaseProvider<PostResponse> {
  PostProvider() : super('Post');

  @override
  PostResponse fromJson(dynamic data) {
    return PostResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<PostResponse?> closePost(int id) async {
    final url = '$baseUrl${endpoint}/closePost/$id';
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.put(uri, headers: headers);
    if (!isValidResponse(response)) return null;
    if (response.body.isEmpty) return null;
    final data = jsonDecode(response.body);
    return fromJson(data);
  }
}
