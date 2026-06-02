import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/model/sport_center.dart';

class SportCenterSearchState {
  final String userCity;
  final String userName;
  final Sport? selectedSport;
  final DateTime selectedDate;
  final String searchQuery;
  final List<SportCenter> sportCenters;
  final List<Sport> sports;
  final bool isLoading;
  final String? error;

  const SportCenterSearchState({
    required this.userCity,
    required this.userName,
    required this.selectedSport,
    required this.selectedDate,
    required this.searchQuery,
    required this.sportCenters,
    required this.sports,
    required this.isLoading,
    required this.error,
  });

  factory SportCenterSearchState.initial() {
    final today = DateTime.now();
    return SportCenterSearchState(
      userCity: '',
      userName: 'User',
      selectedSport: null,
      selectedDate: DateTime(today.year, today.month, today.day),
      searchQuery: '',
      sportCenters: const [],
      sports: const [],
      isLoading: false,
      error: null,
    );
  }

  SportCenterSearchState copyWith({
    String? userCity,
    String? userName,
    Sport? selectedSport,
    bool clearSelectedSport = false,
    DateTime? selectedDate,
    String? searchQuery,
    List<SportCenter>? sportCenters,
    List<Sport>? sports,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SportCenterSearchState(
      userCity: userCity ?? this.userCity,
      userName: userName ?? this.userName,
      selectedSport: clearSelectedSport ? null : selectedSport ?? this.selectedSport,
      selectedDate: selectedDate ?? this.selectedDate,
      searchQuery: searchQuery ?? this.searchQuery,
      sportCenters: sportCenters ?? this.sportCenters,
      sports: sports ?? this.sports,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
