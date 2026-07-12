import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/user.dart';
import 'package:terminba_mobile/model/user_review.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/user_provider.dart';
import 'package:terminba_mobile/providers/user_review_provider.dart';
import 'package:intl/intl.dart';

class PublicProfileScreen extends StatefulWidget {
  final int? userId;
  final User? user;

  const PublicProfileScreen({super.key, this.userId, this.user});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _userProvider = UserProvider();
  final _userReviewProvider = UserReviewProvider();

  bool _isLoading = true;
  String? _error;
  User? _user;
  List<UserReview> _reviews = [];
  double _averageRating = 0.0;
  int _playedCount = 0;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final isCurrentUser = widget.userId == null;

      User? user;
      int targetUserId = 0;
      int playedCount = 0;
      var reviewsResult;

      if (isCurrentUser) {
        user = widget.user ?? await _userProvider.getProfile();
        if (user == null) throw Exception('User not found');
        targetUserId = user.id;
        _currentUserId = targetUserId;
        reviewsResult = await _userReviewProvider.get(filter: {
          'IsReviewed': true,
        });
        playedCount = await _userProvider.getMyPlayedMatches();
      } else {
        targetUserId = widget.userId!;
        user = widget.user ?? await _userProvider.getById(targetUserId);
        if (user == null) throw Exception('User not found');
        reviewsResult = await _userReviewProvider.get(filter: {
          'ReviewedId': targetUserId,
        });
        playedCount = await _userProvider.getPlayedMatches(targetUserId);
      }

      final reviews = (reviewsResult.items ?? []).cast<UserReview>();

      double avgRating = 0.0;
      if (reviews.isNotEmpty) {
        avgRating = reviews.map((e) => e.ratingNumber).reduce((a, b) => a + b) / reviews.length;
      }

      if (mounted) {
        setState(() {
          _user = user;
          _reviews = reviews;
          _averageRating = avgRating;
          _playedCount = playedCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load user profile';
          _isLoading = false;
        });
      }
    }
  }

  String _initials(User? user) {
    if (user == null) return 'U';
    final first = user.firstName.trim();
    final last = user.lastName.trim();
    final firstInitial = first.isNotEmpty ? first[0] : '';
    final lastInitial = last.isNotEmpty ? last[0] : '';
    final initials = '$firstInitial$lastInitial'.toUpperCase();
    return initials.isEmpty ? 'U' : initials;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_user == null ? 'Profile' : '${_user!.firstName} ${_user!.lastName}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildProfileHeader(theme),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          ..._reviews.map((review) => _buildReviewCard(review, theme)),
          if (_reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No reviews yet.'),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                _initials(_user),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Row(
              children: [
                _buildStatColumn('${_averageRating.toStringAsFixed(1)}/5.0', 'rating'),
                const SizedBox(width: 24),
                _buildStatColumn('${_reviews.length}', 'ratings'),
                const SizedBox(width: 24),
                _buildStatColumn('$_playedCount', 'played'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${_user?.firstName} ${_user?.lastName}',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_user?.phoneNumber != null && _user!.phoneNumber.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(_user!.phoneNumber, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        if (_user?.instagramAccount != null && _user!.instagramAccount!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(_user!.instagramAccount!, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildReviewCard(UserReview review, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    _initials(review.reviewer),
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewer?.firstName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        DateFormat('d.M.yyyy.').format(review.ratingDate),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  review.ratingNumber.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
