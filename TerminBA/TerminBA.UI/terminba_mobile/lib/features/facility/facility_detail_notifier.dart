import 'package:flutter/material.dart';
import 'package:terminba_mobile/features/facility/facility_detail_state.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/providers/sport_center_provider.dart';

class SportCenterDetailNotifier extends ChangeNotifier {
  SportCenterDetailNotifier({
      required int sportCenterId,
      required SportCenterProvider sportCenterProvider,
    })  : _sportCenterId = sportCenterId,
      _sportCenterProvider = sportCenterProvider;

    final int _sportCenterId;
    final SportCenterProvider _sportCenterProvider;

  SportCenterDetailState _state = SportCenterDetailState.initial();
  SportCenterDetailState get state => _state;

  Future<void> initialize() async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final sportCenter = await _sportCenterProvider.getById(_sportCenterId);
      _setState(
        _state.copyWith(
          sportCenter: sportCenter,
          isLoading: false,
          clearError: true,
        ),
      );
      _fetchAverageRating(_sportCenterId);
    } on Exception catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          error: _messageFromException(e),
        ),
      );
    }
  }



  Future<void> _fetchAverageRating(int sportCenterId) async {
    try {
      final rating = await _sportCenterProvider.getFacilityAverageRating(
        sportCenterId,
      );
      _state = _state.copyWith(averageRating: rating ?? 0.0);
      notifyListeners();
    } catch (_) {
      // non-critical — silently ignore
    }
  }

  

  void selectSport(Sport sport) {
    _setState(_state.copyWith(selectedSport: sport));
  }

  Future<void> toggleFavorite() async {
    final previous = _state.isFavorite;
    _setState(_state.copyWith(isFavorite: !previous, clearError: true));
  }

  void _setState(SportCenterDetailState state) {
    _state = state;
    notifyListeners();
  }

  String _messageFromException(Exception exception) {
    final message = exception.toString();
    if (message.contains('Exception:')) {
      return message.replaceAll('Exception:', '').trim();
    }
    return message.isEmpty ? 'Something went wrong.' : message;
  }
}
