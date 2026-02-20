import 'package:terminba_admin_desktop/model/sport.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class SportProvider extends BaseProvider<Sport> {
  SportProvider() : super("Sport");

  @override
  Sport fromJson(dynamic json) {
    return Sport.fromJson(json);
  }
}
