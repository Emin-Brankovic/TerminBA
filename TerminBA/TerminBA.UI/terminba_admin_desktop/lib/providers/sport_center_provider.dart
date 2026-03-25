import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terminba_admin_desktop/model/sport_center.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class SportCenterProvider extends BaseProvider<SportCenter> {
  SportCenterProvider() : super("SportCenter");

  @override
  SportCenter fromJson(dynamic data) {
    return SportCenter.fromJson(data);
  }

  @override
  Future<SportCenter?> insert(request) async {
    final response = await super.insert(request);
    final responseBytes = response?.credentialsReport;

    if (responseBytes == null || responseBytes.isEmpty) {
      return response;
    }


    final saveDir =  await getApplicationDocumentsDirectory();
    final safeTimestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final filePath = '${saveDir.path}/$safeTimestamp-sport-center-credentials.pdf';

    final file = File(filePath);
    await file.writeAsBytes(responseBytes, flush: true);

    final openResult = await OpenFilex.open(filePath);
    if (openResult.type != ResultType.done) {
      throw Exception(
        'Sport center created and PDF downloaded, but it could not be opened automatically. File saved at: $filePath',
      );
    }

    return response;
  }
}
