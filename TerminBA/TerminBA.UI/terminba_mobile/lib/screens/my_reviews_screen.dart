import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/facility_review.dart';
import 'package:terminba_mobile/model/facility_review_insert_request.dart';
import 'package:terminba_mobile/model/user_review.dart';
import 'package:terminba_mobile/model/user_review_insert_request.dart';
import 'package:terminba_mobile/providers/facility_review_provider.dart';
import 'package:terminba_mobile/providers/user_review_provider.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen>
    with SingleTickerProviderStateMixin {
  static const _pageSize = 10;

  late final TabController _tabController;
  late final PagingController<int, FacilityReview> _facilityPagingController;
  late final PagingController<int, UserReview> _userPagingController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _facilityPagingController = PagingController(firstPageKey: 1);
    _facilityPagingController.addPageRequestListener(_fetchFacilityPage);

    _userPagingController = PagingController(firstPageKey: 1);
    _userPagingController.addPageRequestListener(_fetchUserPage);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _facilityPagingController.dispose();
    _userPagingController.dispose();
    super.dispose();
  }

  // ─── Paginated fetching ───────────────────────────────────────────────────────

  Future<void> _fetchFacilityPage(int pageKey) async {
    try {
      final result = await context.read<FacilityReviewProvider>().get(
        filter: {
          'Page': pageKey,
          'PageSize': _pageSize,
        },
      );
      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetched = (pageKey - 1) * _pageSize + items.length;

      if (fetched >= total) {
        _facilityPagingController.appendLastPage(items);
      } else {
        _facilityPagingController.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      _facilityPagingController.error = e;
    }
  }

  Future<void> _fetchUserPage(int pageKey) async {
    try {
      final result = await context.read<UserReviewProvider>().get(
        filter: {
          'IsReviewer': true,
          'Page': pageKey,
          'PageSize': _pageSize,
        },
      );
      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetched = (pageKey - 1) * _pageSize + items.length;

      if (fetched >= total) {
        _userPagingController.appendLastPage(items);
      } else {
        _userPagingController.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      _userPagingController.error = e;
    }
  }

  // ─── Facility review actions ─────────────────────────────────────────────────

  Future<void> _editFacilityReview(FacilityReview review) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditFacilityReviewSheet(
        review: review,
        onSave: (rating, comment) async {
          final request = FacilityReviewInsertRequest(
            ratingNumber: rating,
            ratingDate: review.ratingDate,
            comment: comment,
            userId: review.userId,
            facilityId: review.facilityId,
            reservationId: null,
          );
          await context
              .read<FacilityReviewProvider>()
              .update(review.id, request);
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review updated successfully.'),
          backgroundColor: Color(0xFF00C875),
        ),
      );
      _facilityPagingController.refresh();
    }
  }

  Future<void> _deleteFacilityReview(FacilityReview review) async {
    final confirmed = await _confirmDelete(context);
    if (!confirmed || !mounted) return;

    try {
      await context.read<FacilityReviewProvider>().delete(review.id);
      _facilityPagingController.refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete review.')),
        );
      }
    }
  }

  // ─── User review actions ─────────────────────────────────────────────────────

  Future<void> _editUserReview(UserReview review) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditUserReviewSheet(
        review: review,
        onSave: (rating, comment) async {
          final request = UserReviewInsertRequest(
            ratingNumber: rating,
            ratingDate: review.ratingDate,
            comment: comment,
            reviewerId: review.reviewerId,
            reviewedId: review.reviewedId,
            reservationId: review.reservationId,
          );
          await context
              .read<UserReviewProvider>()
              .update(review.id, request);
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review updated successfully.'),
          backgroundColor: Color(0xFF00C875),
        ),
      );
      _userPagingController.refresh();
    }
  }

  Future<void> _deleteUserReview(UserReview review) async {
    final confirmed = await _confirmDelete(context);
    if (!confirmed || !mounted) return;

    try {
      await context.read<UserReviewProvider>().delete(review.id);
      _userPagingController.refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete review.')),
        );
      }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
            'Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('My Reviews'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: 'Facilities'),
            Tab(text: 'Players'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFacilityTab(),
          _buildUserTab(),
        ],
      ),
    );
  }

  Widget _buildFacilityTab() {
    return RefreshIndicator(
      onRefresh: () async => _facilityPagingController.refresh(),
      color: const Color(0xFF00C875),
      child: PagedListView<int, FacilityReview>(
        pagingController: _facilityPagingController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        builderDelegate: PagedChildBuilderDelegate<FacilityReview>(
          itemBuilder: (_, review, __) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FacilityReviewCard(
              review: review,
              onEdit: () => _editFacilityReview(review),
              onDelete: () => _deleteFacilityReview(review),
            ),
          ),
          firstPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          noItemsFoundIndicatorBuilder: (_) => const _EmptyView(
            icon: Icons.stadium_outlined,
            message: "You haven't reviewed any facilities yet.",
          ),
          firstPageErrorIndicatorBuilder: (_) => _ErrorView(
            message: 'Failed to load facility reviews.',
            onRetry: _facilityPagingController.refresh,
          ),
          newPageErrorIndicatorBuilder: (_) => Center(
            child: TextButton(
              onPressed: () =>
                  _facilityPagingController.retryLastFailedRequest(),
              child: const Text('Retry'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTab() {
    return RefreshIndicator(
      onRefresh: () async => _userPagingController.refresh(),
      color: const Color(0xFF00C875),
      child: PagedListView<int, UserReview>(
        pagingController: _userPagingController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        builderDelegate: PagedChildBuilderDelegate<UserReview>(
          itemBuilder: (_, review, __) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _UserReviewCard(
              review: review,
              onEdit: () => _editUserReview(review),
              onDelete: () => _deleteUserReview(review),
            ),
          ),
          firstPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          noItemsFoundIndicatorBuilder: (_) => const _EmptyView(
            icon: Icons.person_outline,
            message: "You haven't reviewed any players yet.",
          ),
          firstPageErrorIndicatorBuilder: (_) => _ErrorView(
            message: 'Failed to load player reviews.',
            onRetry: _userPagingController.refresh,
          ),
          newPageErrorIndicatorBuilder: (_) => Center(
            child: TextButton(
              onPressed: () => _userPagingController.retryLastFailedRequest(),
              child: const Text('Retry'),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Review Cards ─────────────────────────────────────────────────────────────

class _FacilityReviewCard extends StatelessWidget {
  const _FacilityReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  final FacilityReview review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final facilityName = review.facility?.name ?? 'Unknown Facility';
    final sportCenterName = review.facility?.sportCenter?.username ?? '';
    final dateLabel = DateFormat('d.M.yyyy.').format(review.ratingDate);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C875).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.stadium_outlined,
                  color: Color(0xFF00C875),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facilityName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (sportCenterName.isNotEmpty)
                      Text(
                        sportCenterName,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              _StarRating(rating: review.ratingNumber.toDouble()),
            ],
          ),
          const SizedBox(height: 10),
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(
              review.comment!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            )
          else
            Text(
              'No comment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                dateLabel,
                style:
                    theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: const Color(0xFF00C875),
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.redAccent,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserReviewCard extends StatelessWidget {
  const _UserReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  final UserReview review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewed = review.reviewed;
    final name = reviewed != null
        ? '${reviewed.firstName} ${reviewed.lastName}'.trim()
        : 'Unknown Player';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final dateLabel = DateFormat('d.M.yyyy.').format(review.ratingDate);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade50,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (review.sportName != null)
                      Text(
                        review.sportName!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              _StarRating(rating: review.ratingNumber.toDouble()),
            ],
          ),
          const SizedBox(height: 10),
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(
              review.comment!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            )
          else
            Text(
              'No comment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                dateLabel,
                style:
                    theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: const Color(0xFF00C875),
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.redAccent,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Edit Sheets ──────────────────────────────────────────────────────────────

class _EditFacilityReviewSheet extends StatefulWidget {
  const _EditFacilityReviewSheet({
    required this.review,
    required this.onSave,
  });

  final FacilityReview review;
  final Future<void> Function(int rating, String? comment) onSave;

  @override
  State<_EditFacilityReviewSheet> createState() =>
      _EditFacilityReviewSheetState();
}

class _EditFacilityReviewSheetState extends State<_EditFacilityReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.ratingNumber;
    _commentController =
        TextEditingController(text: widget.review.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_rating == 0) {
      setState(() => _error = 'Please select a rating.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final comment = _commentController.text.trim();
      await widget.onSave(_rating, comment.isEmpty ? null : comment);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _EditSheetScaffold(
        title: 'Edit Facility Review',
        rating: _rating,
        commentController: _commentController,
        saving: _saving,
        error: _error,
        onRatingChanged: (v) => setState(() => _rating = v),
        onSave: _save,
      );
}

class _EditUserReviewSheet extends StatefulWidget {
  const _EditUserReviewSheet({
    required this.review,
    required this.onSave,
  });

  final UserReview review;
  final Future<void> Function(int rating, String? comment) onSave;

  @override
  State<_EditUserReviewSheet> createState() => _EditUserReviewSheetState();
}

class _EditUserReviewSheetState extends State<_EditUserReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.ratingNumber;
    _commentController =
        TextEditingController(text: widget.review.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_rating == 0) {
      setState(() => _error = 'Please select a rating.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final comment = _commentController.text.trim();
      await widget.onSave(_rating, comment.isEmpty ? null : comment);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _EditSheetScaffold(
        title: 'Edit Player Review',
        rating: _rating,
        commentController: _commentController,
        saving: _saving,
        error: _error,
        onRatingChanged: (v) => setState(() => _rating = v),
        onSave: _save,
      );
}

// ─── Shared Edit Sheet Scaffold ───────────────────────────────────────────────

class _EditSheetScaffold extends StatelessWidget {
  const _EditSheetScaffold({
    required this.title,
    required this.rating,
    required this.commentController,
    required this.saving,
    required this.error,
    required this.onRatingChanged,
    required this.onSave,
  });

  final String title;
  final int rating;
  final TextEditingController commentController;
  final bool saving;
  final String? error;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Rating',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final value = i + 1;
              return GestureDetector(
                onTap: () => onRatingChanged(value),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    rating >= value ? Icons.star : Icons.star_border,
                    color: rating >= value
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade400,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            'Comment',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            maxLines: 4,
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
                    const BorderSide(color: Color(0xFF00C875), width: 1.5),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(error!,
                          style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: saving ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00C875),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Small Widgets ─────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: const Color(0xFFFFC107), size: size),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: size - 2),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
