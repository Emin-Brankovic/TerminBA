import 'package:intl/intl.dart';
import 'package:terminba_mobile/features/facility/data/facility_repository.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/providers/facility_provider.dart';
import 'package:terminba_mobile/providers/sport_provider.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  FacilityRepositoryImpl({
    FacilityProvider? facilityProvider,
    SportProvider? sportProvider,
  })  : _facilityProvider = facilityProvider ?? FacilityProvider(),
        _sportProvider = sportProvider ?? SportProvider();

  final FacilityProvider _facilityProvider;
  final SportProvider _sportProvider;

  @override
  Future<List<Facility>> getFacilities({
    String? city,
    Sport? sport,
    DateTime? date,
    String? query,
  }) async {
    final dateValue = date == null ? null : DateFormat('yyyy-MM-dd').format(date);
    final filter = <String, dynamic>{};

    if (city != null && city.trim().isNotEmpty) {
      filter['city'] = city.trim();
    }
    if (sport?.name != null && sport!.name!.trim().isNotEmpty) {
      filter['sport'] = sport.name!.trim();
    }
    if (dateValue != null) {
      filter['date'] = dateValue;
    }
    if (query != null && query.trim().isNotEmpty) {
      filter['query'] = query.trim();
    }

    final result = await _facilityProvider.get(filter: filter);
    return (result.items ?? []).cast<Facility>();
  }

  @override
  Future<Facility?> getFacility(int id) {
    return _facilityProvider.getById(id);
  }

  @override
  Future<List<Sport>> getSports() async {
    final result = await _sportProvider.get();
    return (result.items ?? []).cast<Sport>();
  }

  @override
  Future<void> toggleFavorite(int facilityId) {
    return _facilityProvider.toggleFavorite(facilityId);
  }
}
