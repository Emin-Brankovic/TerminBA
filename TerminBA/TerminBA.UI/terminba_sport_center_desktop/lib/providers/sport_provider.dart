import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';

class SportProvider extends BaseProvider<Sport> {
  SportProvider() : super("Sport");

  @override
  Sport fromJson(dynamic data) {
    return Sport.fromJson(data);
  }
}
