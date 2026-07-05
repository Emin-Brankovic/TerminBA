import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/play_request_insert_request.dart';
import 'package:terminba_mobile/model/post_response.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/play_request_provider.dart';
import 'package:terminba_mobile/providers/post_provider.dart';
import 'package:terminba_mobile/providers/sport_provider.dart';
import 'package:terminba_mobile/screens/player_search_requests_screen.dart';
import 'package:terminba_mobile/widgets/filter_chip_bar.dart';
import 'package:terminba_mobile/widgets/player_search_post_card.dart';

class PlayerSearchFeedScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const PlayerSearchFeedScreen({super.key, this.scrollController});

  @override
  State<PlayerSearchFeedScreen> createState() => _PlayerSearchFeedScreenState();
}

class _PlayerSearchFeedScreenState extends State<PlayerSearchFeedScreen> {
  static const _pageSize = 10;

  int? _selectedSportId;
  String? _selectedSkillLevel;
  DateTime? _selectedDate;

  List<Sport> _sports = [];
  Map<int, String> _postRequestStatus = {};

  late PagingController<int, PostResponse> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
    _loadSports();
    _fetchSentRequests();
  }

  Future<void> _fetchSentRequests() async {
    final currentUserId = await context.read<AuthProvider>().getCurrentUserId();
    if (currentUserId == null) return;
    try {
      final result = await context.read<PlayRequestProvider>().get(
        filter: {
          'RequesterId': currentUserId,
          'PageSize': 1000,
        },
      );
      final items = result.items ?? [];
      if (mounted) {
        setState(() {
          _postRequestStatus.clear();
          for (var req in items) {
            final pid = req.postId;
            if (_postRequestStatus[pid] == 'Joined') continue; // keep highest status

            if (req.isAccepted == true) {
              _postRequestStatus[pid] = 'Joined';
            } else if (req.isAccepted == null) {
              _postRequestStatus[pid] = 'Pending';
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _loadSports() async {
    try {
      final result =
          await context.read<SportProvider>().get(filter: {'pageSize': 100});
      if (mounted) {
        setState(() {
          _sports = result.items ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final provider = context.read<PostProvider>();

      final filter = <String, dynamic>{
        'PostState': 'PlayerSearchPostState',
        'Page': pageKey,
        'PageSize': _pageSize,
      };

      if (_selectedSportId != null) filter['SportId'] = _selectedSportId;
      if (_selectedSkillLevel != null) {
        filter['SkillLevel'] = _selectedSkillLevel;
      }
      if (_selectedDate != null) {
        filter['ReservationDate'] =
            _selectedDate!.toIso8601String().split('T').first;
      }

      final result = await provider.get(filter: filter);
      final items = result.items ?? [];
      final totalCount = result.totalCount ?? 0;
      final fetchedSoFar = (pageKey - 1) * _pageSize + items.length;

      if (fetchedSoFar >= totalCount) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  void _applyFilters() {
    _pagingController.refresh();
  }

  Future<void> _onSendRequest(PostResponse post) async {
    final currentUserId =
        await context.read<AuthProvider>().getCurrentUserId();
    if (currentUserId == null) return;

    // Check if user is the owner
    if (post.reservation?.userId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot request to join your own post.')),
      );
      return;
    }

    final TextEditingController msgCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Join Request',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'to ${post.reservation?.facility?.name ?? 'this post'}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Add a message (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C875),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Request',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final req = PlayRequestInsertRequest(
          postId: post.id,
          requesterId: currentUserId,
          requestText: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim(),
        );
        await context
            .read<PlayRequestProvider>()
            .insert(req.toJson());

        if (mounted) {
          setState(() {
            _postRequestStatus[post.id] = 'Pending';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request sent!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _onClosePost(PostResponse post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Post?'),
        content: const Text(
          'This will mark the post as closed. It will no longer appear in the feed and will stop accepting requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close Post'),
          ),
        ],
      ),
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
            SnackBar(content: Text('Failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Find Players',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 28),
                ),
                // IconButton(
                //   tooltip: 'My Requests',
                //   icon: const Icon(Icons.notifications_outlined),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) =>
                //             const PlayerSearchRequestsScreen(),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Browse open posts and send a join request.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),

          // Filter bar
          FilterChipBar(
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

          // Feed
          Expanded(
            child: FutureBuilder<int?>(
              future: context.read<AuthProvider>().getCurrentUserId(),
              builder: (ctx, snapshot) {
                final currentUserId = snapshot.data;
                return PagedListView<int, PostResponse>(
                  pagingController: _pagingController,
                  scrollController: widget.scrollController,
                  builderDelegate: PagedChildBuilderDelegate<PostResponse>(
                    itemBuilder: (context, post, index) {
                      final isOwner =
                          post.reservation?.userId == currentUserId;
                      return PlayerSearchPostCard(
                        post: post,
                        isOwner: isOwner,
                        requestStatus: _postRequestStatus[post.id],
                        onSendRequest: () => _onSendRequest(post),
                        onClosePost: () => _onClosePost(post),
                      );
                    },
                    firstPageProgressIndicatorBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    noItemsFoundIndicatorBuilder: (_) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No active posts found.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create one from a reservation!',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                        onPressed: () =>
                            _pagingController.retryLastFailedRequest(),
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
