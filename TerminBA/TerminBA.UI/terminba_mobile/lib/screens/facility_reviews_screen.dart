// lib/screens/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/reviews/reviews_notifier.dart';
import 'package:terminba_mobile/features/reviews/reviews_state.dart';
import 'package:terminba_mobile/model/facility_review.dart';
import 'package:terminba_mobile/providers/facility_review_provider.dart';
import 'package:terminba_mobile/screens/write_facility_review_screen.dart';

class FacilityReviewsScreen extends StatefulWidget  {
  const FacilityReviewsScreen({
    super.key,
    required this.averageRating,
    required this.sportCenterId,
    required this.sportCenterName,
  });

  final String sportCenterName;
  final double averageRating;
  final int sportCenterId;

  @override
  State<FacilityReviewsScreen> createState() => _FacilityReviewsScreenState();
}

  class _FacilityReviewsScreenState extends State<FacilityReviewsScreen> {
  late final ReviewsNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ReviewsNotifier(
      sportCenterId: widget.sportCenterId,
      reviewProvider: context.read<FacilityReviewProvider>(),
    );
    _notifier.initialize();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sportCenterName = widget.sportCenterName;

    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<ReviewsNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: Text('$sportCenterName Reviews'),
              centerTitle: true,
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(ReviewsState state) {
    final theme = Theme.of(context);
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(state.error!),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _notifier.initialize,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _buildSummaryHeader(theme, state),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 8),
        if (state.reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: Text('No reviews yet.')),
          )
        else
          ...state.reviews.map((review) => _ReviewCard(review: review, sportCenterName: widget.sportCenterName)),
      ],
    );
  }

  Widget _buildSummaryHeader(ThemeData theme, ReviewsState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.averageRating.toStringAsFixed(1)}/5.0',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            _StarRow(rating: widget.averageRating),
            const SizedBox(height: 4),
            Text(
              '${state.reviews.length} ratings',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Spacer(),
        FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WriteFacilityReviewScreen(
                  sportCenterId: widget.sportCenterId,
                ),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF5722),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: const Text('Write a review'),
        ),
      ],
    );
  }
}

// ─── Star Row ────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, this.size = 20});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final fill = (rating - index).clamp(0.0, 1.0);
        return Icon(
          fill >= 1.0
              ? Icons.star
              : fill >= 0.5
                  ? Icons.star_half
                  : Icons.star_border,
          color: const Color(0xFFFFC107),
          size: size,
        );
      }),
    );
  }
}

// ─── Review Card ─────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.sportCenterName});

  final FacilityReview review;
  final String sportCenterName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = review.user?.username ?? 'Anonymous';
    final facilityName = review.facility?.name ?? 'Unknown Facility';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final date = review.ratingDate;
    final dateLabel = '${date.day}.${date.month}.${date.year}.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE0E0E0),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name, date, facility tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$sportCenterName, $facilityName',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rating number
              Text(
                review.ratingNumber.toStringAsFixed(1),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1),
        ],
      ),
    );
  }
}