import 'package:terminba_admin_desktop/model/sport_center.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class SportCenterProvider extends BaseProvider<SportCenter> {
  SportCenterProvider() : super("SportCenter");

  @override
  SportCenter fromJson(dynamic data) {
    return SportCenter.fromJson(data);
  }
}
