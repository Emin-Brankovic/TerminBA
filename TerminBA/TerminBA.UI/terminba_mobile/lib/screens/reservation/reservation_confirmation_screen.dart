import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/layouts/master_screen_bottom_nav.dart';
import 'package:intl/intl.dart';

/// Screen 5: Reservation Confirmation (Digital Ticket).
///
/// Terminal screen — back press navigates to Home, not back to summary.
/// [PopScope] is used (Flutter 3.22+) to intercept back gestures.
class ReservationConfirmationScreen extends StatelessWidget {
  const ReservationConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingFlowNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;
        final confirmation = state.bookingConfirmation;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _navigateHome(context);
          },
          child: Scaffold(
            body: SafeArea(
              child: confirmation == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(context, state, confirmation.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, BookingFlowState state, int reservationId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // ── Success header ───────────────────────────────────────────────
          Semantics(
            label: 'Reservation confirmed',
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 80,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your slot has been booked!!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // ── Ticket card ──────────────────────────────────────────────────
          _TicketCard(state: state, reservationId: reservationId),
          const SizedBox(height: 32),

          // ── Action buttons ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateHome(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    foregroundColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text(
                    'Home',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadTicket(context, reservationId),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text(
                    'Download Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateHome(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MasterScreenBottomNav()),
      (route) => false,
    );
  }

  // TODO: Implement PDF/image download when a PDF utility is added to the project.
  void _downloadTicket(BuildContext context, int bookingId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download ticket #$bookingId — coming soon.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Ticket Card ──────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.state, required this.reservationId});

  final BookingFlowState state;
  final int reservationId;

  @override
  Widget build(BuildContext context) {
    final confirmation = state.bookingConfirmation;
    final user = confirmation?.user;
    final userName = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : state.sportCenterName; // fallback
    final phone = user?.phoneNumber ?? '-';
    final sportName = state.sport?.name ?? '-';
    final courtName = state.selectedCourt?.name ?? '-';
    final address = state.sportCenterAddress;
    final slot = state.selectedTimeSlot;
    final timeStr = slot != null ? slot.label : '-';
    final date = state.selectedDate;
    final dateStr = date != null ? DateFormat('dd-MM-yyyy').format(date) : '-';
    final grandTotal = '${state.grandTotal.toStringAsFixed(0)} KM';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reservation ID
            const Text(
              'Reservation ID',
              style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 4),
            Text(
              '$reservationId',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF212121),
              ),
            ),
            const Divider(height: 24),
            // Grid of info cells
            _InfoGrid(cells: [
              _InfoCell(label: 'NAME', value: userName),
              _InfoCell(label: 'MOBILE', value: phone),
              _InfoCell(label: 'SPORT NAME', value: sportName),
              _InfoCell(label: 'COURT NAME', value: courtName),
              _InfoCell(label: 'ADDRESS', value: address),
              _InfoCell(label: 'RESERVATION TIME', value: timeStr),
              _InfoCell(label: 'DATE', value: dateStr),
              _InfoCell(label: 'AMOUNT', value: grandTotal),
            ]),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.cells});
  final List<_InfoCell> cells;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 2) {
      final left = cells[i];
      final right = i + 1 < cells.length ? cells[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: left),
              const VerticalDivider(width: 1, thickness: 1),
              const SizedBox(width: 12),
              Expanded(child: right ?? const SizedBox.shrink()),
            ],
          ),
        ),
      );
      if (i + 2 < cells.length) rows.add(const Divider(height: 16));
    }
    return Column(children: rows);
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }
}
