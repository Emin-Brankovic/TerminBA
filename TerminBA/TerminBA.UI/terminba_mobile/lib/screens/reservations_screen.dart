import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';
import 'package:terminba_mobile/widgets/reservation_tab_switcher.dart';
import 'package:terminba_mobile/widgets/reservation_card.dart';
import 'package:terminba_mobile/screens/reservation_overview_screen.dart';

class ReservationsScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const ReservationsScreen({super.key, this.scrollController});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Past
  List<ReservationResponse> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ReservationProvider>(context, listen: false);

      final status = _selectedTab == 0 ? 'upcoming' : 'past';
      final results = await provider.get(filter: {
        'status': status,
        'SortByChosenTimeSlot': true,
        'TimeSlotSortDirection': 'desc'
      });
      if (mounted) {
        setState(() {
          _reservations = results.items ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reservations: $e')),
        );
      }
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() {
        _selectedTab = index;
      });
      _fetchReservations();
    }
  }

  void _cancelReservation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: const Text('Are you sure you want to cancel this reservation? This action cannot be undone.'),
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
        final provider = Provider.of<ReservationProvider>(context, listen: false);
        await provider.cancelReservationPost(id);
        _fetchReservations(); // refresh
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'My Reservations',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 16),
            ReservationTabSwitcher(
              selectedIndex: _selectedTab,
              onTabChanged: _onTabChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reservations.isEmpty
                      ? Center(
                          child: Text(
                            _selectedTab == 0
                                ? 'No upcoming reservations.'
                                : 'No past reservations.',
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          controller: widget.scrollController,
                          itemCount: _reservations.length,
                          itemBuilder: (context, index) {
                            final res = _reservations[index];
                            return ReservationCard(
                              reservation: res,
                              isPast: _selectedTab == 1,
                              onShowDetails: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationOverviewScreen(reservationId: res.id),
                                  ),
                                ).then((_) => _fetchReservations());
                              },
                              onCancel: () => _cancelReservation(res.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

