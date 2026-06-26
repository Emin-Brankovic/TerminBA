import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';
import 'package:terminba_mobile/widgets/reservation_tab_switcher.dart';
import 'package:terminba_mobile/widgets/reservation_card.dart';
import 'package:terminba_mobile/screens/reservation_overview_screen.dart';
import 'dart:async';

class ReservationsScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const ReservationsScreen({super.key, this.scrollController});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  static const _pageSize = 10;

  int _selectedTab = 0; // 0 = Upcoming, 1 = Past

  String? _searchQuery;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late PagingController<int, ReservationResponse> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final provider = context.read<ReservationProvider>();
      final status = _selectedTab == 0 ? 'upcoming' : 'past';
      
      final filter = <String, dynamic>{
        'status': status,
        'SortByChosenTimeSlot': true,
        'TimeSlotSortDirection': 'desc',
        'Page': pageKey,
        'PageSize': _pageSize,
      };

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        filter['FacilityName'] = _searchQuery;
      }
      if (_selectedDate != null) {
        filter['ReservationDate'] = _selectedDate!.toIso8601String().split('T').first;
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

  void _onTabChanged(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _pagingController.refresh();
  }

  void _cancelReservation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: const Text(
            'Are you sure you want to cancel this reservation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final provider = context.read<ReservationProvider>();
        await provider.cancelReservationPost(id);
        _pagingController.refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'My Reservations',
              style:
                  Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by facility...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = null;
                                });
                                _pagingController.refresh();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _searchQuery = value;
                        });
                        _pagingController.refresh();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: _selectedDate != null ? Theme.of(context).primaryColor : null,
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                      _pagingController.refresh();
                    }
                  },
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      _pagingController.refresh();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ReservationTabSwitcher(
              selectedIndex: _selectedTab,
              onTabChanged: _onTabChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PagedListView<int, ReservationResponse>(
                pagingController: _pagingController,
                scrollController: widget.scrollController,
                builderDelegate: PagedChildBuilderDelegate<ReservationResponse>(
                  itemBuilder: (context, res, index) => ReservationCard(
                    reservation: res,
                    isPast: _selectedTab == 1,
                    onShowDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReservationOverviewScreen(reservationId: res.id),
                        ),
                      ).then((_) => _pagingController.refresh());
                    },
                    onCancel: () => _cancelReservation(res.id),
                  ),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder: (_) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Center(
                    child: Text(
                      _selectedTab == 0
                          ? 'No upcoming reservations.'
                          : 'No past reservations.',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  firstPageErrorIndicatorBuilder: (_) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load reservations.'),
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
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
