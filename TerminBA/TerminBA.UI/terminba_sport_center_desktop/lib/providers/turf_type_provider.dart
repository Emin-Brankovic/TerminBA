import 'package:terminba_sport_center_desktop/model/turf_type.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';

class TurfTypeProvider extends BaseProvider<TurfType> {
  TurfTypeProvider() : super("TurfType");

  @override
  TurfType fromJson(dynamic data) {
    return TurfType.fromJson(data);
  }
}
