import 'package:terminba_mobile/model/sport_center.dart';
import 'package:terminba_mobile/model/sport.dart';

class SportCenterDetailState {
  final SportCenter? sportCenter;
  final Sport? selectedSport;
  final bool isLoading;
  final bool isFavorite;
  final String? error;
  final double averageRating;

  const SportCenterDetailState({
    required this.sportCenter,
    required this.selectedSport,
    required this.isLoading,
    required this.isFavorite,
    required this.error,
    required this.averageRating,
  });

  factory SportCenterDetailState.initial() {
    return const SportCenterDetailState(
      sportCenter: null,
      selectedSport: null,
      isLoading: true,
      isFavorite: false,
      error: null,
      averageRating: 0.0,
    );
  }

  SportCenterDetailState copyWith({
    SportCenter? sportCenter,
    Sport? selectedSport,
    bool clearSelectedSport = false,
    bool? isLoading,
    bool? isFavorite,
    String? error,
    double? averageRating,
    bool clearError = false,
  }) {
    return SportCenterDetailState(
      sportCenter: sportCenter ?? this.sportCenter,
      selectedSport: clearSelectedSport ? null : selectedSport ?? this.selectedSport,
      isLoading: isLoading ?? this.isLoading,
      isFavorite: isFavorite ?? this.isFavorite,
      error: clearError ? null : error ?? this.error,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}
