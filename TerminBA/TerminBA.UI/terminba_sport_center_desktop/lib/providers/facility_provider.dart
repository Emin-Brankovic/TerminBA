import 'package:terminba_sport_center_desktop/providers/base_provider.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';

class FacilityProvider extends BaseProvider<Facility> {
  FacilityProvider() : super("Facility");

  @override
  Facility fromJson(dynamic data) {
    return Facility.fromJson(data);
  }
}
