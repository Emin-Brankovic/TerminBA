import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/play_request_response.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/play_request_provider.dart';
import 'package:terminba_mobile/widgets/request_card.dart';

class PlayerSearchRequestsScreen extends StatefulWidget {
  const PlayerSearchRequestsScreen({super.key});

  @override
  State<PlayerSearchRequestsScreen> createState() =>
      _PlayerSearchRequestsScreenState();
}

class _PlayerSearchRequestsScreenState
    extends State<PlayerSearchRequestsScreen>
    with SingleTickerProviderStateMixin {
  static const _pageSize = 10;
  late TabController _tabController;

  late PagingController<int, PlayRequestResponse> _receivedController;
  late PagingController<int, PlayRequestResponse> _sentController;

  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _receivedController = PagingController(firstPageKey: 1);
    _sentController = PagingController(firstPageKey: 1);

    _receivedController.addPageRequestListener(_fetchReceived);
    _sentController.addPageRequestListener(_fetchSent);

    _loadUserId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _receivedController.dispose();
    _sentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final id = await context.read<AuthProvider>().getCurrentUserId();
    if (mounted) {
      setState(() => _currentUserId = id);
      _receivedController.refresh();
      _sentController.refresh();
    }
  }

  Future<void> _fetchReceived(int pageKey) async {
    if (_currentUserId == null) {
      _receivedController.appendLastPage([]);
      return;
    }
    try {
      final result = await context.read<PlayRequestProvider>().get(
        filter: {
          'RecipientUserId': _currentUserId,
          'Page': pageKey,
          'PageSize': _pageSize,
        },
      );
      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetched = (pageKey - 1) * _pageSize + items.length;
      if (fetched >= total) {
        _receivedController.appendLastPage(items);
      } else {
        _receivedController.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      _receivedController.error = e;
    }
  }

  Future<void> _fetchSent(int pageKey) async {
    if (_currentUserId == null) {
      _sentController.appendLastPage([]);
      return;
    }
    try {
      final result = await context.read<PlayRequestProvider>().get(
        filter: {
          'RequesterId': _currentUserId,
          'Page': pageKey,
          'PageSize': _pageSize,
        },
      );
      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetched = (pageKey - 1) * _pageSize + items.length;
      if (fetched >= total) {
        _sentController.appendLastPage(items);
      } else {
        _sentController.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      _sentController.error = e;
    }
  }

  Future<void> _respond(PlayRequestResponse req, bool accept) async {
    try {
      await context.read<PlayRequestProvider>().respondToRequest(req.id, accept);
      _receivedController.refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? 'Request accepted.' : 'Request denied.'),
            backgroundColor:
                accept ? const Color(0xFF00C875) : Colors.red.shade600,
          ),
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

  Future<void> _cancel(PlayRequestResponse req) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<PlayRequestProvider>().cancelRequest(req.id);
        _sentController.refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request cancelled.')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00C875),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00C875),
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Received ---
          RefreshIndicator(
            onRefresh: () async => _receivedController.refresh(),
            color: const Color(0xFF00C875),
            child: PagedListView<int, PlayRequestResponse>(
              pagingController: _receivedController,
              builderDelegate: PagedChildBuilderDelegate<PlayRequestResponse>(
                itemBuilder: (ctx, req, _) => ReceivedRequestCard(
                  request: req,
                  onAccept: () => _respond(req, true),
                  onDeny: () => _respond(req, false),
                ),
                firstPageProgressIndicatorBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                noItemsFoundIndicatorBuilder: (_) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No received requests yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                firstPageErrorIndicatorBuilder: (_) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _receivedController.refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Sent ---
          RefreshIndicator(
            onRefresh: () async => _sentController.refresh(),
            color: const Color(0xFF00C875),
            child: PagedListView<int, PlayRequestResponse>(
              pagingController: _sentController,
              builderDelegate: PagedChildBuilderDelegate<PlayRequestResponse>(
                itemBuilder: (ctx, req, _) => SentRequestCard(
                  request: req,
                  onCancel: () => _cancel(req),
                ),
                firstPageProgressIndicatorBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                noItemsFoundIndicatorBuilder: (_) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No sent requests yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                firstPageErrorIndicatorBuilder: (_) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _sentController.refresh,
                        child: const Text('Retry'),
                      ),
                    ],
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
