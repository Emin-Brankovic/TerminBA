import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/user.dart';
import 'package:terminba_mobile/model/user_review.dart';
import 'package:terminba_mobile/model/user_review_insert_request.dart';
import 'package:terminba_mobile/providers/user_review_provider.dart';

class WriteUserReviewScreen extends StatefulWidget {
  const WriteUserReviewScreen({
    super.key,
    required this.reviewedUser,
    required this.reservationId,
    required this.sportName,
    this.existingReview,
  });

  final User reviewedUser;
  final int reservationId;
  final String sportName;
  final UserReview? existingReview;

  @override
  State<WriteUserReviewScreen> createState() => _WriteUserReviewScreenState();
}

class _WriteUserReviewScreenState extends State<WriteUserReviewScreen> {
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
      final request = UserReviewInsertRequest(
        ratingNumber: _selectedRating,
        ratingDate: DateTime.now(),
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        reviewerId: null, // set by backend
        reviewedId: widget.reviewedUser.id,
        reservationId: widget.reservationId,
      );
      
      await context.read<UserReviewProvider>().insert(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you.'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.of(context).pop();
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
        title: const Text('User Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildStarSelector(),
            const SizedBox(height: 28),

            Text(
              'Sport',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: widget.sportName),
              readOnly: true,
              decoration: InputDecoration(
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
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                fillColor: Colors.grey.shade50,
                filled: true,
              ),
            ),
            const SizedBox(height: 28),

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
                  hintText: 'Placeholder',
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
                    borderSide: const BorderSide(color: Color(0xFF00C875), width: 1.5),
                  ),
                ),
              ),
            const SizedBox(height: 8),

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

            if (widget.existingReview == null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_isSubmitting || _selectedRating == 0) ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00C875),
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
