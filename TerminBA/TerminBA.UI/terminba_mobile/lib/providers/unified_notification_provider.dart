import 'dart:convert';
import 'package:terminba_mobile/model/notification_response.dart';
import 'package:terminba_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UnifiedNotificationProvider extends BaseProvider<NotificationResponse> {
  UnifiedNotificationProvider() : super("Notification");

  @override
  NotificationResponse fromJson(data) {
    return NotificationResponse.fromJson(data);
  }

  Future<void> markAsSeen(int id, String type) async {
    var url = "$baseUrl$endpoint/$id/mark-as-seen?type=$type";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.put(uri, headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to mark notification as seen");
    }
  }

  Future<int> getUnseenCount() async {
    var url = "$baseUrl$endpoint/unseen-count";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      return int.tryParse(response.body) ?? 0;
    }
    return 0;
  }

  Future<void> markAsSeenMultiple(List<Map<String, dynamic>> items) async {
    var url = "$baseUrl$endpoint/mark-as-seen-multiple";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.put(uri, headers: headers, body: jsonEncode(items));
    if (!isValidResponse(response)) {
      throw Exception("Failed to mark notifications as seen");
    }
  }

  Future<void> deleteMultiple(List<Map<String, dynamic>> items) async {
    var url = "$baseUrl$endpoint/delete-multiple";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.post(uri, headers: headers, body: jsonEncode(items));
    if (!isValidResponse(response)) {
      throw Exception("Failed to delete notifications");
    }
  }
}
