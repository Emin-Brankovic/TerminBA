import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_review_insert_request.dart';
import 'package:terminba_mobile/model/facility_review.dart';
import 'package:terminba_mobile/providers/facility_review_provider.dart';
import 'package:terminba_mobile/screens/facility_reviews_screen.dart';

class WriteFacilityReviewScreen extends StatefulWidget {
  const WriteFacilityReviewScreen({
    super.key,
    required this.sportCenterId,
    required this.facility,
    this.reservationId,
    this.existingReview,
  });

  final int sportCenterId;
  final Facility facility;
  final int? reservationId;
  final FacilityReview? existingReview;

  @override
  State<WriteFacilityReviewScreen> createState() =>
      _WriteFacilityReviewScreenState();
}

class _WriteFacilityReviewScreenState
    extends State<WriteFacilityReviewScreen> {
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _selectedRating = widget.existingReview!.ratingNumber;
      if (widget.existingReview!.comment != null) {
        _commentController.text = widget.existingReview!.comment!;
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      setState(() => _error = 'Please select a rating.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final request = FacilityReviewInsertRequest(
        ratingNumber: _selectedRating,
        ratingDate: DateTime.now(),
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        userId: null, // set by the server from the JWT token
        facilityId: widget.facility.id,
        reservationId: widget.reservationId,
      );
      await context.read<FacilityReviewProvider>().insert(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you.'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        // Navigate to the reviews list for this sport center
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => FacilityReviewsScreen(
              sportCenterId: widget.sportCenterId,
              sportCenterName:
                  widget.facility.sportCenter?.username ?? 'Sport Center',
              averageRating: 0.0, // will be recalculated from the list
            ),
          ),
        );
      }
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Write a Review'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Facility summary card ─────────────────────────────
            _FacilitySummaryCard(facility: widget.facility),
            const SizedBox(height: 28),

            // ── Rating ───────────────────────────────────────────
            Text(
              'Your Rating',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildStarSelector(),
            const SizedBox(height: 28),

            // ── Comment ──────────────────────────────────────────
            Text(
              widget.existingReview != null ? 'Your Review' : 'Write your review',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.existingReview != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  widget.existingReview!.comment?.isNotEmpty == true
                      ? widget.existingReview!.comment!
                      : 'No comment provided.',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.existingReview!.comment?.isNotEmpty == true
                        ? Colors.black87
                        : Colors.grey,
                    fontStyle: widget.existingReview!.comment?.isNotEmpty == true
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              )
            else
              TextField(
                controller: _commentController,
                maxLines: 6,
                maxLength: 180,
                decoration: InputDecoration(
                  hintText: 'Share your experience... (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // ── Error ────────────────────────────────────────────
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Submit ───────────────────────────────────────────
            if (widget.existingReview == null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      (_isSubmitting || _selectedRating == 0) ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarSelector() {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () {
            if (widget.existingReview == null) {
              setState(() => _selectedRating = starValue);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              _selectedRating >= starValue ? Icons.star : Icons.star_border,
              color: _selectedRating >= starValue
                  ? const Color(0xFFFFC107)
                  : Colors.grey.shade400,
              size: 40,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Facility Summary Card ────────────────────────────────────────────────────

class _FacilitySummaryCard extends StatelessWidget {
  const _FacilitySummaryCard({required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = facility.photos.isNotEmpty
        ? facility.photos.first.url
        : null;

    final durationMinutes = facility.duration.inMinutes;
    final durationLabel = durationMinutes >= 60
        ? '${durationMinutes ~/ 60}h ${durationMinutes % 60 == 0 ? '' : '${durationMinutes % 60}min'}'.trim()
        : '${durationMinutes}min';

    final price = facility.staticPrice != null
        ? '${facility.staticPrice!.toStringAsFixed(0)} KM'
        : 'Dynamic';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility.name ?? 'Facility',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.grass,
                  label: 'Surface',
                  value: facility.turfType?.name ?? '—',
                ),
                _InfoRow(
                  icon: facility.isIndoor ? Icons.house : Icons.wb_sunny_outlined,
                  label: 'Type',
                  value: facility.isIndoor ? 'Indoor' : 'Outdoor',
                ),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Duration',
                  value: durationLabel,
                ),
                _InfoRow(
                  icon: Icons.people_outline,
                  label: 'Max players',
                  value: '${facility.maxCapacity}',
                ),
                _InfoRow(
                  icon: Icons.attach_money,
                  label: 'Price',
                  value: price,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade100,
                    ),
                    errorWidget: (_, __, ___) => _PlaceholderThumb(),
                  )
                : _PlaceholderThumb(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade100,
      child: const Icon(Icons.stadium_outlined, color: Colors.grey, size: 36),
    );
  }
}