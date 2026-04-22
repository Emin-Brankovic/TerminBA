import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_reservation_stats_report_request.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_reservation_stats_response.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';

class ReportProvider extends BaseProvider {
  ReportProvider() : super("Report");

  Future<SportCenterReservationStatsResponse> fetchSportCenterReservationStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final url = "$baseUrl$endpoint/sportCenterReservationStats";

    String formatDate(DateTime date) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year}-$month-$day';
    }

    final queryParameters = <String, String>{};
    if (fromDate != null) {
      queryParameters['fromDate'] = formatDate(fromDate);
    }
    if (toDate != null) {
      queryParameters['toDate'] = formatDate(toDate);
    }

    var uri = Uri.parse(url).replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    var headers = await createHeaders();
    try {
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);

        var result = SportCenterReservationStatsResponse.fromJson(data);
        return result;
      } else {
        throw new Exception("Unknown error");
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<String> generateSportCenterReservationStatsReport({
    required SportCenterReservationStatsReportRequest reportRequest,
  }) async {
    final url = "$baseUrl$endpoint/generateSportCenterReservationStats";
    final uri = Uri.parse(url);
    final headers = await createHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(reportRequest.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final docsDir = await getApplicationDocumentsDirectory();
      final safeTimestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final filePath =
          '${docsDir.path}/$safeTimestamp-sport-center-reservation-report.pdf';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes, flush: true);

      final openResult = await OpenFilex.open(filePath);
      if (openResult.type != ResultType.done) {
        throw Exception(
          'Report generated but could not be opened automatically. File saved at: $filePath',
        );
      }

      return filePath;
    }

    final errorBody = response.body;
    throw Exception(
      'Error generating report: ${response.statusCode} - $errorBody',
    );
  }

}
