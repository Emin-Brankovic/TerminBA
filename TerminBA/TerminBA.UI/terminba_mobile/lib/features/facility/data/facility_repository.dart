import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/sport.dart';

abstract class FacilityRepository {
  Future<List<Facility>> getFacilities({
    String? city,
    Sport? sport,
    DateTime? date,
    String? query,
  });

  Future<Facility?> getFacility(int id);

  Future<List<Sport>> getSports();

  Future<void> toggleFavorite(int facilityId);
}
