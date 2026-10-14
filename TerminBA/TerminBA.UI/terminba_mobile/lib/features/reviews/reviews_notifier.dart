import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/facility_review.dart';
import 'package:terminba_mobile/providers/facility_review_provider.dart';
import 'package:terminba_mobile/providers/sport_center_provider.dart';
import 'reviews_state.dart';

class ReviewsNotifier extends ChangeNotifier {
  ReviewsNotifier({
    required this.sportCenterId,
    required FacilityReviewProvider reviewProvider,
    SportCenterProvider? sportCenterProvider,
  })  : _reviewProvider = reviewProvider,
        _sportCenterProvider = sportCenterProvider;

  final int sportCenterId;
  final FacilityReviewProvider _reviewProvider;
  final SportCenterProvider? _sportCenterProvider;

  ReviewsState _state = const ReviewsState();
  ReviewsState get state => _state;

  void _setState(ReviewsState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> initialize() async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final filter = <String, dynamic>{
        'sportCenterId': sportCenterId,
        'sortOption': 'newest',
      };
      final results = await _reviewProvider.get(filter: filter);

      final reviews = (results.items ?? []).cast<FacilityReview>();

      double avgRating = 0.0;
      if (reviews.isNotEmpty) {
        avgRating = reviews.map((r) => r.ratingNumber).reduce((a, b) => a + b) / reviews.length;
      } else if (_sportCenterProvider != null) {
        try {
          final backendAvg = await _sportCenterProvider.getFacilityAverageRating(sportCenterId);
          if (backendAvg != null) {
            avgRating = backendAvg;
          }
        } catch (_) {}
      }

      _setState(_state.copyWith(
        reviews: reviews,
        averageRating: avgRating,
        isLoading: false,
        clearError: true,
      ));
    } on Exception catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}