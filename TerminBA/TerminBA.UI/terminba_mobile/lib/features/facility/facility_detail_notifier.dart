import 'package:flutter/material.dart';
import 'package:terminba_mobile/features/facility/facility_detail_state.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/providers/sport_center_provider.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/favorite_sport_center_provider.dart';
import 'package:terminba_mobile/model/favorite_sport_center_insert_request.dart';

class SportCenterDetailNotifier extends ChangeNotifier {
  SportCenterDetailNotifier({
      required int sportCenterId,
      required SportCenterProvider sportCenterProvider,
      required AuthProvider authProvider,
      required FavoriteSportCenterProvider favoriteProvider,
    })  : _sportCenterId = sportCenterId,
      _sportCenterProvider = sportCenterProvider,
      _authProvider = authProvider,
      _favoriteProvider = favoriteProvider;

    final int _sportCenterId;
    final SportCenterProvider _sportCenterProvider;
    final AuthProvider _authProvider;
    final FavoriteSportCenterProvider _favoriteProvider;

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
      _checkIsFavorite(_sportCenterId);
    } on Exception catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          error: _messageFromException(e),
        ),
      );
    }
  }

  Future<void> _checkIsFavorite(int sportCenterId) async {
    final userId = await _authProvider.getCurrentUserId();
    if (userId == null) return;
    try {
      final searchResult = await _favoriteProvider.get(filter: {
          'userId': userId,
          'sportCenterId': sportCenterId
      });
      if (searchResult.items != null && searchResult.items!.isNotEmpty) {
          _setState(_state.copyWith(isFavorite: true));
      }
    } catch (_) {
      // silently ignore
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

    final userId = await _authProvider.getCurrentUserId();
    if (userId == null) {
       _setState(_state.copyWith(isFavorite: previous, error: 'Must be logged in'));
       return;
    }

    try {
        if (!previous) {
            await _favoriteProvider.insert(FavoriteSportCenterInsertRequest(
                userId,
                _sportCenterId
            ));
        } else {
            // we need to find the favorite id to delete it, or the backend should have a specific endpoint. 
            // We can search for it first
            final searchResult = await _favoriteProvider.get(filter: {
                'userId': userId,
                'sportCenterId': _sportCenterId
            });
            if (searchResult.items != null && searchResult.items!.isNotEmpty) {
                await _favoriteProvider.delete(searchResult.items!.first.id!);
            }
        }
    } catch (e) {
        _setState(_state.copyWith(isFavorite: previous, error: _messageFromException(e as Exception)));
    }
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
