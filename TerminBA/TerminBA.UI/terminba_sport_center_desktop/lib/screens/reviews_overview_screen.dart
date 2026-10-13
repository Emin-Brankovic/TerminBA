import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/facility_review.dart';
import 'package:terminba_sport_center_desktop/providers/auth_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_review_provider.dart';
import 'package:terminba_sport_center_desktop/widgets/confirmation_dialog.dart';
import 'package:terminba_sport_center_desktop/widgets/universal_pagination.dart';

class ReviewsOverviewScreen extends StatefulWidget {
  const ReviewsOverviewScreen({super.key});

  @override
  State<ReviewsOverviewScreen> createState() => _ReviewsOverviewScreenState();
}

class _ReviewsOverviewScreenState extends State<ReviewsOverviewScreen> {
  static const int _pageSize = 9;
  static final DateFormat _dateInputFormat = DateFormat('yyyy-MM-dd');
  static const Duration _searchDebounceDuration = Duration(milliseconds: 450);

  final _filterFormKey = GlobalKey<FormBuilderState>();
  final TextEditingController _searchController = TextEditingController();
  late FacilityReviewProvider _facilityReviewProvider;
  late FacilityProvider _facilityProvider;
  late AuthProvider _authProvider;
  bool _initialized = false;
  bool _isLoading = false;
  List<FacilityReview> _facilityReviews = [];
  List<Facility> _facilities = [];
  int? _selectedFacilityId;
  DateTime? _ratingDateFrom;
  DateTime? _ratingDateTo;
  String? _sortOption;
  bool _showFilterForm = false;
  Timer? _searchDebounce;
  int? _currentSportCenterId;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;
    _facilityReviewProvider = context.read<FacilityReviewProvider>();
    _facilityProvider = context.read<FacilityProvider>();
    _authProvider = context.read<AuthProvider>();
    _initializeData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      _fetchReviews(page: 1);
    });
  }

  Future<void> _initializeData() async {
    _currentSportCenterId = _authProvider.isLoggedIn
        ? await _authProvider.getCurrentUserId()
        : null;

    await Future.wait([
      _loadFacilities(),
      _fetchReviews(),
    ]);
  }

  Future<void> _loadFacilities() async {
    try {
      final result = await _facilityProvider.get(
        filter: {
          if (_currentSportCenterId != null) 'sportCenterId': _currentSportCenterId,
          'page': 1,
          'pageSize': 200,
        },
      );

      if (!mounted) return;

      setState(() {
        _facilities = result.items ?? [];
      });
    } catch (e) {
      debugPrint('Error loading facilities for reviews filter: $e');
    }
  }

  List<_ReviewCardData> get _filteredReviews {
    return _facilityReviews
        .map(
          (review) => _ReviewCardData(
            id: review.id,
            userName: _resolveUserName(review),
            facilityName: review.facility?.name ?? 'Facility',
            date: _formatDate(review.ratingDate),
            rating: review.ratingNumber.toDouble(),
            reviewText: (review.comment?.trim().isNotEmpty ?? false)
                ? review.comment!.trim()
                : 'No comment provided.',
          ),
        )
        .toList();
  }

  Future<void> _fetchReviews({int? page}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final targetPage = page ?? _currentPage;
      final reviews = await _facilityReviewProvider.get(
        filter: {
          'page': targetPage,
          'pageSize': _pageSize,
          if (_searchController.text.trim().isNotEmpty)
            'fts': _searchController.text.trim(),
          if (_sortOption != null) 'sortOption': _sortOption,
          if (_currentSportCenterId != null) 'sportCenterId': _currentSportCenterId,
          if (_selectedFacilityId != null) 'facilityId': _selectedFacilityId,
          if (_ratingDateFrom != null) 'ratingDateFrom': _toDateOnly(_ratingDateFrom!),
          if (_ratingDateTo != null) 'ratingDateTo': _toDateOnly(_ratingDateTo!),
        },
      );

      if (!mounted) return;

      final totalCount = reviews.totalCount ?? 0;
      final calculatedTotalPages =
          totalCount == 0 ? 1 : ((totalCount + _pageSize - 1) ~/ _pageSize);

      setState(() {
        _facilityReviews = reviews.items ?? [];
        _currentPage = targetPage;
        _totalPages = calculatedTotalPages;
        _totalItems = totalCount;
      });
    } catch (e) {
      // Handle error, e.g., show a snackbar
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _toDateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _applyFilters() {
    final formState = _filterFormKey.currentState;
    if (formState == null) return;

    formState.save();
    final values = formState.value;

    setState(() {
      _selectedFacilityId = values['facilityId'] as int?;
      _ratingDateFrom = values['ratingDateFrom'] as DateTime?;
      _ratingDateTo = values['ratingDateTo'] as DateTime?;
      _sortOption = values['sortOption'] as String?;
    });

    _fetchReviews(page: 1);
  }

  void _clearFilters() {
    _filterFormKey.currentState?.fields['facilityId']?.didChange(null);
    _filterFormKey.currentState?.fields['sortOption']?.didChange(null);
    _filterFormKey.currentState?.fields['ratingDateFrom']?.didChange(null);
    _filterFormKey.currentState?.fields['ratingDateTo']?.didChange(null);
    setState(() {
      _selectedFacilityId = null;
      _ratingDateFrom = null;
      _ratingDateTo = null;
      _sortOption = null;
    });
    _fetchReviews(page: 1);
  }

  Future<void> _removeReview(int id) async {
    final shouldDelete = await ConfirmationDialog.show(
      context,
      title: 'Delete review',
      message: 'Are you sure you want to delete this review?',
      cancelText: 'No',
      confirmText: 'Yes, delete',
      confirmButtonColor: const Color(0xFFFF4405),
    );

    if (!shouldDelete) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _facilityReviewProvider.delete(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully.')),
      );

      final totalItemsAfterDeletion = _totalItems - 1;
      final page = ((totalItemsAfterDeletion + _pageSize - 1) ~/ _pageSize);
      await _fetchReviews(page: page == 0 ? 1 : page);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete review.')),
      );
      debugPrint('Error deleting review: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }




  String _resolveUserName(FacilityReview review) {
    final user = review.user;
    if (user == null) {
      return 'Unknown user';
    }

    final fullName = '${user.firstName} ${user.lastName}'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    return user.username;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reviews',
      child: Container(
        color: const Color(0xFFF4F6F8),
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 22),
            _buildSearchRow(),
            if (_showFilterForm) ...[
              const SizedBox(height: 10),
              _buildFilterForm(),
            ],
            const SizedBox(height: 18),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredReviews.isEmpty
                      ? const Center(
                          child: Text(
                            'No reviews found.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = 3;
                                    if (constraints.maxWidth < 1120) {
                                      crossAxisCount = 2;
                                    }
                                    if (constraints.maxWidth < 760) {
                                      crossAxisCount = 1;
                                    }

                                    return GridView.builder(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      itemCount: _filteredReviews.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 2.15,
                                      ),
                                      itemBuilder: (context, index) {
                                        return _buildReviewCard(
                                          _filteredReviews[index],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: UniversalPagination(
                                  currentPage: _currentPage,
                                  totalPages: _totalPages,
                                  onPageChanged: (newPage) {
                                    _fetchReviews(page: newPage);
                                  },
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 430,
          height: 40,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (_) {
              _searchDebounce?.cancel();
              _fetchReviews(page: 1);
            },
            decoration: InputDecoration(
              hintText: 'Search keywords',
              hintStyle: const TextStyle(
                color: Color(0xFF97A1AF),
                fontSize: 14,
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: Color(0xFF7F8895),
                size: 18,
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFA9B3BF)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          height: 34,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _showFilterForm = !_showFilterForm;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: const BorderSide(color: Color(0xFFD1D6DD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              backgroundColor: Colors.white,
            ),
            child: const Icon(Icons.filter_list, color: Color(0xFF4B5563), size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: FormBuilder(
        key: _filterFormKey,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: FormBuilderDropdown<int>(
                name: 'facilityId',
                initialValue: _selectedFacilityId,
                iconSize: _selectedFacilityId != null ? 0 : 24,
                decoration: InputDecoration(
                  labelText: 'Facility',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _selectedFacilityId != null
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedFacilityId = null;
                            });
                            _filterFormKey
                                .currentState
                                ?.fields['facilityId']
                                ?.didChange(null);
                          },
                        )
                      : null,
                ),
                items: _facilities
                    .map(
                      (facility) => DropdownMenuItem<int>(
                        value: facility.id,
                        child: Text(facility.name ?? 'Facility ${facility.id}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFacilityId = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FormBuilderDropdown<String>(
                name: 'sortOption',
                initialValue: _sortOption,
                iconSize: _sortOption != null ? 0 : 24,
                decoration: InputDecoration(
                  labelText: 'Sort',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _sortOption != null
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _sortOption = null;
                            });
                            _filterFormKey
                                .currentState
                                ?.fields['sortOption']
                                ?.didChange(null);
                          },
                        )
                      : null,
                ),
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                  DropdownMenuItem(value: 'topRated', child: Text('Top Rated')),
                  DropdownMenuItem(value: 'lowRated', child: Text('Low Rated')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortOption = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FormBuilderDateTimePicker(
                name: 'ratingDateFrom',
                initialValue: _ratingDateFrom,
                inputType: InputType.date,
                format: _dateInputFormat,
                decoration: InputDecoration(
                  labelText: 'Date from',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _ratingDateFrom != null
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _ratingDateFrom = null;
                            });
                            _filterFormKey
                                .currentState
                                ?.fields['ratingDateFrom']
                                ?.didChange(null);
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _ratingDateFrom = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FormBuilderDateTimePicker(
                name: 'ratingDateTo',
                initialValue: _ratingDateTo,
                inputType: InputType.date,
                format: _dateInputFormat,
                decoration: InputDecoration(
                  labelText: 'Date to',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _ratingDateTo != null
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _ratingDateTo = null;
                            });
                            _filterFormKey
                                .currentState
                                ?.fields['ratingDateTo']
                                ?.didChange(null);
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _ratingDateTo = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _clearFilters,
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(_ReviewCardData review) {
    final initial = review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User info + Rating badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                review.facilityName,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            review.date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: Color(0xFFD97706)),
                      const SizedBox(width: 2.5),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Review text
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: _ScrollableReviewText(text: review.reviewText),
              ),
            ),
            const SizedBox(height: 6),
            // Action button
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 28,
                child: OutlinedButton.icon(
                  onPressed: () => _removeReview(review.id),
                  icon: const Icon(Icons.delete_outline_rounded, size: 13),
                  label: const Text(
                    'Remove',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFFEF2F2),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCardData {
  const _ReviewCardData({
    required this.id,
    required this.userName,
    required this.facilityName,
    required this.date,
    required this.rating,
    required this.reviewText,
  });

  final int id;
  final String userName;
  final String facilityName;
  final String date;
  final double rating;
  final String reviewText;
}

class _ScrollableReviewText extends StatefulWidget {
  const _ScrollableReviewText({required this.text});

  final String text;

  @override
  State<_ScrollableReviewText> createState() => _ScrollableReviewTextState();
}

class _ScrollableReviewTextState extends State<_ScrollableReviewText> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Text(
          widget.text,
          style: const TextStyle(
            fontSize: 13,
            height: 1.2,
            color: Color(0xFF4B4F57),
          ),
        ),
      ),
    );
  }
}
