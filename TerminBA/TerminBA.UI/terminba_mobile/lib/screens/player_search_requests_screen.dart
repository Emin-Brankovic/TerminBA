import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/play_request_response.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/play_request_provider.dart';
import 'package:terminba_mobile/providers/notification_provider.dart';
import 'package:terminba_mobile/widgets/request_card.dart';
import 'package:terminba_mobile/providers/post_provider.dart';
import 'package:terminba_mobile/model/post_response.dart';


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
  DateTime? _selectedDate;
  String? _selectedStatus;
  int? _selectedPostId;
  List<PostResponse> _userPosts = [];

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
      if (id != null) {
        _fetchUserPosts(id);
      }
      _receivedController.refresh();
      _sentController.refresh();
    }
  }

  Future<void> _fetchUserPosts(int userId) async {
    try {
      final result = await context.read<PostProvider>().get(
        filter: {'UserId': userId},
      );
      if (mounted) {
        setState(() {
          final items = result.items ?? [];
          _userPosts = items
              .where((p) => p.reservation?.status == 'ActiveReservationState')
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
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
          if (_selectedDate != null) 'DateOfRequest': _selectedDate!.toIso8601String(),
          if (_selectedStatus != null) 'Status': _selectedStatus,
          if (_selectedPostId != null) 'PostId': _selectedPostId,
        },
      );
      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      
      // Mark as seen
      if (mounted) {
        final notificationProvider = context.read<NotificationProvider>();
        for (final item in items) {
          if (item.isSeenByOwner != true) {
            notificationProvider.markAsSeen(item.id);
          }
        }
      }

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
          if (_selectedDate != null) 'DateOfRequest': _selectedDate!.toIso8601String(),
          if (_selectedStatus != null) 'Status': _selectedStatus,
        },
      );
      final items = result.items ?? [];
      final total = result.totalCount ?? 0;

      // Mark responses as seen
      if (mounted) {
        final notificationProvider = context.read<NotificationProvider>();
        for (final item in items) {
          if (item.isSeenByRequester == false && item.isAccepted != null) {
            notificationProvider.markResponseAsSeen(item.id);
          }
        }
      }

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
          const SnackBar(
            content: Text('Response sent.'),
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Date Picker
                  ListTile(
                    title: const Text('Date of Request'),
                    subtitle: Text(
                      _selectedDate == null
                          ? 'Any date'
                          : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => _selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  // Status Dropdown
                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                      DropdownMenuItem(value: 'denied', child: Text('Denied')),
                    ],
                    onChanged: (val) {
                      setSheetState(() => _selectedStatus = val);
                    },
                  ),
                  if (_tabController.index == 0) ...[
                    const SizedBox(height: 10),
                    // Post Dropdown
                    DropdownButtonFormField<int?>(
                      decoration: const InputDecoration(
                        labelText: 'Reservation (Post)',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      value: _selectedPostId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        ..._userPosts.map((p) {
                          final res = p.reservation;
                          final facilityName = res?.facility?.name ?? 'Unknown';
                          final date = res?.reservationDate ?? '';
                          final time = res?.startTime ?? '';
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text('$facilityName - $date $time', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                      ],
                      onChanged: (val) {
                        setSheetState(() => _selectedPostId = val);
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              _selectedDate = null;
                              _selectedStatus = null;
                              _selectedPostId = null;
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _receivedController.refresh();
                            _sentController.refresh();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C875),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: _showFilterSheet,
          ),
        ],
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
