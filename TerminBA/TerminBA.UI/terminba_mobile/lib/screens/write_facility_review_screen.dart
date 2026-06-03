import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_review_insert_request.dart';
import 'package:terminba_mobile/providers/facility_review_provider.dart';
import 'package:terminba_mobile/providers/facility_provider.dart';

class WriteFacilityReviewScreen extends StatefulWidget {
  const WriteFacilityReviewScreen({
    super.key,
    required this.sportCenterId,
    this.preselectedFacility, // optional — pass when navigating from detail screen
  });

  final int sportCenterId;
  final Facility? preselectedFacility;

  @override
  State<WriteFacilityReviewScreen> createState() => _WriteFacilityReviewScreenState();
}

class _WriteFacilityReviewScreenState extends State<WriteFacilityReviewScreen> {
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  Facility? _selectedFacility;
  List<Facility> _facilities = [];
  bool _isLoadingFacilities = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedFacility = widget.preselectedFacility;
    _loadFacilities();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() => _isLoadingFacilities = true);
    try {
      final provider = context.read<FacilityProvider>();
      final result = await provider.get(filter: {
        'sportCenterId': widget.sportCenterId,
      });
      setState(() {
        _facilities = result.items?.cast<Facility>() ?? [];
        _isLoadingFacilities = false;
        if (_selectedFacility != null) {
          final match = _facilities.cast<Facility?>().firstWhere(
            (f) => f?.id == _selectedFacility!.id,
            orElse: () => null,
          );
          if (match != null) {
            _selectedFacility = match;
          } else {
            _facilities.insert(0, _selectedFacility!);
          }
        }
      });
    } catch (_) {
      setState(() => _isLoadingFacilities = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedFacility == null) {
      setState(() => _error = 'Please select a facility.');
      return;
    }
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
        _selectedRating,
        DateTime.now(),
        _commentController.text.trim(),
        null, // userId — set by the server from the JWT token
        _selectedFacility!.id,
      );
      await context.read<FacilityReviewProvider>().insert(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
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
        title: const Text('Reviews'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Facility Selector ──────────────────────────────
            _buildFacilitySelector(theme),
            const SizedBox(height: 24),

            // ── Rating ────────────────────────────────────────
            Text(
              'Rating',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildStarSelector(),
            const SizedBox(height: 24),

            // ── Comment ───────────────────────────────────────
            Text(
              'Write your review',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 6,
              maxLength: 180,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Error ─────────────────────────────────────────
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

            // ── Submit ────────────────────────────────────────
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
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
        ),
      ),
    );
  }

  Widget _buildFacilitySelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: _isLoadingFacilities
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Loading facilities...'),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<Facility>(
                isExpanded: true,
                hint: const Text('Select a facility'),
                value: _selectedFacility,
                icon: const Icon(Icons.keyboard_arrow_down),
                borderRadius: BorderRadius.circular(12),
                items: _facilities.map((facility) {
                  return DropdownMenuItem<Facility>(
                    value: facility,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stadium_outlined,
                          size: 18,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            facility.name ?? 'Facility',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedFacility = value;
                  _error = null;
                }),
              ),
            ),
    );
  }

  Widget _buildStarSelector() {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _selectedRating = starValue),
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              _selectedRating >= starValue ? Icons.star : Icons.star_border,
              color: _selectedRating >= starValue
                  ? const Color(0xFFFFC107)
                  : Colors.grey.shade400,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}