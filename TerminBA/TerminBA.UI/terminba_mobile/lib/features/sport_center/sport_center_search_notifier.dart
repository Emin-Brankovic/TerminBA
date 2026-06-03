import 'dart:async';

import 'package:flutter/material.dart';
import 'package:terminba_mobile/features/sport_center/sport_center_search_state.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/model/sport_center.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/sport_provider.dart';
import 'package:terminba_mobile/providers/sport_center_provider.dart';
import 'package:terminba_mobile/providers/user_provider.dart';
import 'package:intl/intl.dart';

class SportCenterSearchNotifier extends ChangeNotifier {
  SportCenterSearchNotifier({
    required AuthProvider authProvider,
    required SportCenterProvider sportCenterProvider,
    required SportProvider sportProvider,
    UserProvider? userProvider,
  })  : _authProvider = authProvider,
        _sportCenterProvider = sportCenterProvider,
        _sportProvider = sportProvider,
        _userProvider = userProvider ?? UserProvider();

  final AuthProvider _authProvider;
  final SportCenterProvider _sportCenterProvider;
  final SportProvider _sportProvider;
  final UserProvider _userProvider;

  SportCenterSearchState _state = SportCenterSearchState.initial();
  SportCenterSearchState get state => _state;

  Timer? _debounce;
  bool _isDisposed = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  Future<void> initialize() async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final userId = await _authProvider.getCurrentUserId();
      String userCity = '';
      String userName = _authProvider.currentUsername;

      if (userId != null) {
        final user = await _userProvider.getById(userId);
        if (user != null) {
          userCity = user.city?.name ?? userCity;
          if (user.firstName.trim().isNotEmpty) {
            userName = user.firstName.trim();
          }
        }
      }

      final sportsResult = await _sportProvider.get();
      final sports = (sportsResult.items ?? []).cast<Sport>();

      _setState(
        _state.copyWith(
          userCity: userCity,
          userName: userName,
          sports: sports,
        ),
      );

      await loadFacilities();
    } on Exception catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          error: _messageFromException(e),
        ),
      );
    }
  }

  Future<void> loadFacilities({bool showLoading = true}) async {
    if (showLoading) {
      _setState(_state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final filter = _buildFacilityFilter();
      final result = await _sportCenterProvider.searchAvailable(filter);
      final centers = (result.items ?? []).cast<SportCenter>();

      final searchQuery = _state.searchQuery.trim().toLowerCase();
      final filteredCenters = searchQuery.isEmpty
          ? centers
          : centers.where((center) {
              final name = center.username.toLowerCase();
              final address = center.address.toLowerCase();
              return name.contains(searchQuery) || address.contains(searchQuery);
            }).toList();

      _setState(
        _state.copyWith(
          sportCenters: filteredCenters,
          isLoading: false,
          clearError: true,
        ),
      );
    } on Exception catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          error: _messageFromException(e),
        ),
      );
    }
  }

  

  void updateSearchQuery(String value) {
    _setState(_state.copyWith(searchQuery: value));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      loadFacilities(showLoading: false);
    });
  }

  void selectSport(Sport? sport) {
    if (sport == null) {
      _setState(_state.copyWith(clearSelectedSport: true));
    } else {
      _setState(_state.copyWith(selectedSport: sport));
    }
    loadFacilities();
  }

  void clearSport() {
    _setState(_state.copyWith(clearSelectedSport: true));
    loadFacilities();
  }

  void selectDate(DateTime date) {
    _setState(_state.copyWith(selectedDate: date));
    loadFacilities();
  }

  void clearFilters() {
    final today = DateTime.now();
    _setState(
      _state.copyWith(
        clearSelectedSport: true,
        searchQuery: '',
        selectedDate: DateTime(today.year, today.month, today.day),
      ),
    );
    loadFacilities();
  }

  void _setState(SportCenterSearchState state) {
    if (_isDisposed) return;
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

  Map<String, dynamic> _buildFacilityFilter() {
    final filter = <String, dynamic>{};
    if (_state.userCity.trim().isNotEmpty) {
      filter['cityName'] = _state.userCity.trim();
    }
    final selectedSport = _state.selectedSport?.name;
    if (selectedSport != null && selectedSport.trim().isNotEmpty) {
      filter['sportId'] = _state.selectedSport!.id;
    }
    filter['date'] = DateFormat('yyyy-MM-dd').format(_state.selectedDate);
    filter['page'] = 1;
    filter['pageSize'] = 50;
    return filter;
  }
}
