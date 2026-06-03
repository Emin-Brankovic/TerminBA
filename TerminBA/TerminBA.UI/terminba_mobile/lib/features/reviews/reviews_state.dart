import 'package:terminba_mobile/model/facility_review.dart';

class ReviewsState {
  final List<FacilityReview> reviews;
  final bool isLoading;
  final String? error;
  final double averageRating;

  const ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.averageRating = 0.0,
  });

  ReviewsState copyWith({
    List<FacilityReview>? reviews,
    bool? isLoading,
    String? error,
    double? averageRating,
    bool clearError = false,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}