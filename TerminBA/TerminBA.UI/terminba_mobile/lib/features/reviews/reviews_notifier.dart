// lib/features/reviews/presentation/reviews_notifier.dart

import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/facility_review.dart';
import 'package:terminba_mobile/providers/facility_review_provider.dart';
import 'reviews_state.dart';

class ReviewsNotifier extends ChangeNotifier {
  ReviewsNotifier({
    required this.sportCenterId,
    required FacilityReviewProvider reviewProvider,
  }) : _reviewProvider = reviewProvider;

  final int sportCenterId;
  final FacilityReviewProvider _reviewProvider;

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

      final reviews = results.items as List<FacilityReview>;

      print('Fetched ${reviews.length} reviews for sport center $sportCenterId');

      _setState(_state.copyWith(
        reviews: reviews,
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