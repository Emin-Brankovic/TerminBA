import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/post_response.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/post_provider.dart';
import 'package:terminba_mobile/screens/edit_player_search_post_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
    _loadUserId();
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

  Future<void> _fetchPage(int pageKey) async {
    if (_currentUserId == null) {
      _pagingController.appendLastPage([]);
      return;
    }

    try {
      final result = await context.read<PostProvider>().get(
        filter: {
          'UserId': _currentUserId,
          'Page': pageKey,
          'PageSize': _pageSize,
        },
      );

      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetchedSoFar = (pageKey - 1) * _pageSize + items.length;

      if (fetchedSoFar >= total) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future<void> _onClosePost(PostResponse post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Post?'),
        content: const Text(
          'This will mark the post as closed. It will no longer appear in the public feed and will stop accepting new requests.',
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
            SnackBar(content: Text('Failed to close post: $e')),
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
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        color: const Color(0xFF00C875),
        child: PagedListView<int, PostResponse>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<PostResponse>(
            itemBuilder: (ctx, post, _) => PlayerSearchPostCard(
              post: post,
              isOwner: true,
              onClosePost: post.isActive ? () => _onClosePost(post) : null,
              onEditPost: post.isActive ? () => _onEditPost(post) : null,
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
                      'No posts yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create one from a reservation to find players.',
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
    );
  }
}
