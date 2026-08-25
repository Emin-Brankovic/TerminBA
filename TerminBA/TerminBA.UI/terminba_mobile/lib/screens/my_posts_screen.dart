import 'package:flutter/material.dart';
import 'package:terminba_mobile/widgets/confirmation_dialog.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/post_response.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/post_provider.dart';
import 'package:terminba_mobile/providers/sport_provider.dart';
import 'package:terminba_mobile/screens/edit_player_search_post_screen.dart';
import 'package:terminba_mobile/widgets/filter_chip_bar.dart';
import 'package:terminba_mobile/widgets/player_search_post_card.dart';

/// Screen showing all player-search posts created by the currently logged-in user.
class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  static const _pageSize = 10;
  late PagingController<int, PostResponse> _pagingController;
  int? _currentUserId;

  int? _selectedSportId;
  String? _selectedSkillLevel;
  DateTime? _selectedDate;
  String _sortDirection = 'asc';
  List<Sport> _sports = [];

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
    _loadUserId();
    _loadSports();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final id = await context.read<AuthProvider>().getCurrentUserId();
    if (mounted) {
      setState(() => _currentUserId = id);
      _pagingController.refresh();
    }
  }

  Future<void> _loadSports() async {
    try {
      final result =
          await context.read<SportProvider>().get(filter: {'pageSize': 10});
      if (mounted) {
        setState(() {
          _sports = result.items ?? [];
        });
      }
    } catch (_) {}
  }

  void _applyFilters() {
    _pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    if (_currentUserId == null) {
      _pagingController.appendLastPage([]);
      return;
    }

    try {
      final filter = <String, dynamic>{
        'UserId': _currentUserId,
        'SortByReservationDate': true,
        'SortDirection': _sortDirection,
        'Page': pageKey,
        'PageSize': _pageSize,
      };

      if (_selectedSportId != null) filter['SportId'] = _selectedSportId;
      if (_selectedSkillLevel != null) filter['SkillLevel'] = _selectedSkillLevel;
      if (_selectedDate != null) {
        filter['ReservationDate'] = _selectedDate!.toIso8601String().split('T').first;
      }

      final result = await context.read<PostProvider>().get(
        filter: filter,
      );

      if (!mounted) return;

      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetchedSoFar = (pageKey - 1) * _pageSize + items.length;

      if (fetchedSoFar >= total) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      if (!mounted) return;
      _pagingController.error = e;
    }
  }

  Future<void> _onClosePost(PostResponse post) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Close Post?',
      message: 'This will mark the post as closed. It will no longer appear in the public feed and will stop accepting new requests. It can be reopened before the reservation starts.',
      confirmText: 'Close Post',
      cancelText: 'Cancel',
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<PostProvider>().closePost(post.id);
        _pagingController.refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post closed successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to close post: $e')),
          );
        }
      }
    }
  }

  Future<void> _onReopenPost(PostResponse post) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Reopen Post?',
      message: 'This will reopen the post, making it visible again and allowing new players to join.',
      confirmText: 'Reopen Post',
      cancelText: 'Cancel',
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<PostProvider>().reopenPost(post.id);
        _pagingController.refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post reopened successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reopen post: $e')),
          );
        }
      }
    }
  }

  Future<void> _onEditPost(PostResponse post) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlayerSearchPostScreen(post: post),
      ),
    );

    if (result == true && mounted) {
      _pagingController.refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilterChipBar(
                  sports: _sports,
                  selectedSportId: _selectedSportId,
                  selectedSkillLevel: _selectedSkillLevel,
                  selectedDate: _selectedDate,
                  onSportChanged: (id) {
                    setState(() => _selectedSportId = id);
                    _applyFilters();
                  },
                  onSkillLevelChanged: (level) {
                    setState(() => _selectedSkillLevel = level);
                    _applyFilters();
                  },
                  onDateChanged: (date) {
                    setState(() => _selectedDate = date);
                    _applyFilters();
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _sortDirection == 'asc' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: Colors.grey.shade700,
                ),
                tooltip: 'Sort by date',
                onPressed: () {
                  setState(() {
                    _sortDirection = _sortDirection == 'asc' ? 'desc' : 'asc';
                  });
                  _applyFilters();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _pagingController.refresh(),
              color: const Color(0xFF00C875),
              child: PagedListView<int, PostResponse>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<PostResponse>(
                  itemBuilder: (ctx, post, _) => PlayerSearchPostCard(
                    post: post,
                    isOwner: true,
                    onClosePost: (post.isActive || post.postState == 'PlayerFoundPostState') ? () => _onClosePost(post) : null,
                    onReopenPost: post.isClosed ? () => _onReopenPost(post) : null,
                    onEditPost: (post.isActive || post.postState == 'PlayerFoundPostState') ? () => _onEditPost(post) : null,
                  ),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder: (_) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No posts found.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or create a new post.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  firstPageErrorIndicatorBuilder: (_) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load posts.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _pagingController.refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  newPageErrorIndicatorBuilder: (_) => Center(
                    child: TextButton(
                      onPressed: () => _pagingController.retryLastFailedRequest(),
                      child: const Text('Retry'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
