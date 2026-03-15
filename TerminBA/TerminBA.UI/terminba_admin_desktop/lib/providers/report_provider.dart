import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:terminba_admin_desktop/model/dashboard_response.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';
import 'dart:convert';

class ReportProvider extends BaseProvider<DashboardResponse> {
  static String? _baseUrl;

  ReportProvider() : super("Report") {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5078/api/",
    );
  }

  Future<DashboardResponse> fetchDashboardData(int year) async {
    final url ="$baseUrl$endpoint/$year";

    var uri = Uri.parse(url);
    var headers = await createHeaders();
    try {
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);

        var result = DashboardResponse.fromJson(data);
        return result;
      } else {
        throw new Exception("Unknown error");
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }
}
