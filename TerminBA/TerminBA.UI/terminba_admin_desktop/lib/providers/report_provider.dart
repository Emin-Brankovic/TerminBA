import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terminba_admin_desktop/model/dashboard_response.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';
import 'dart:convert';

class ReportProvider extends BaseProvider<DashboardResponse> {
  ReportProvider() : super("Report");

  Future<DashboardResponse> fetchDashboardData(int year) async {
    final url = "$baseUrl$endpoint/$year";

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

  Future<String> generateReport({
    required Uint8List imageBytes,
    required int totalUsers,
    required int totalSportCenters,
    required int totalReservations,
    required int selectedYear,
  }) async {
    final url = "$baseUrl$endpoint/generate";
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final request = http.MultipartRequest("POST", uri);

    final authorization = headers['Authorization'];
    if (authorization != null) {
      request.headers['Authorization'] = authorization;
    }

    request.fields['totalUsers'] = totalUsers.toString();
    request.fields['totalSportCenters'] = totalSportCenters.toString();
    request.fields['totalReservations'] = totalReservations.toString();
    request.fields['selectedYear'] = selectedYear.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        'chartImage',
        imageBytes,
        filename: 'dashboard_chart.png',
      ),
    );

    final streamedResponse = await request.send();
    final responseBytes = await streamedResponse.stream.toBytes();

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      final tempDir = await getApplicationDocumentsDirectory();
      final safeTimestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final filePath = '${tempDir.path}/$safeTimestamp-report.pdf';

      final file = File(filePath);
      await file.writeAsBytes(responseBytes, flush: true);

      final openResult = await OpenFilex.open(filePath);
      if (openResult.type != ResultType.done) {
        throw Exception(
          'Report generated but could not be opened automatically. File saved at: $filePath',
        );
      }

      return filePath;
    }

    final errorBody = utf8.decode(responseBytes);
    throw Exception(
      'Error generating report: ${streamedResponse.statusCode} - $errorBody',
    );
  }
}
