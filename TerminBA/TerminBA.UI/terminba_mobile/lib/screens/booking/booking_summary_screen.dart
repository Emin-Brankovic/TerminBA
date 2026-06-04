import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/screens/booking/booking_confirmation_screen.dart';
import 'package:intl/intl.dart';

/// Screen 4: Booking Summary & Payment.
///
/// Shows payment method toggle, booking detail rows, bill breakdown,
/// optional notes field, and a sticky CTA that POSTs the reservation.
class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingFlowNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;
        final courtName = state.selectedCourt?.name ?? 'Court';
        final dateLabel = state.selectedDate != null
            ? DateFormat('d MMM').format(state.selectedDate!)
            : '';

        return Scaffold(
          appBar: AppBar(
            title: Text('${state.sportCenterName} $courtName ($dateLabel)'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _buildBody(context, state, notifier),
          bottomNavigationBar: _buildCta(context, state, notifier),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    BookingFlowState state,
    BookingFlowNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error banner
          if (state.error != null)
            _ErrorBanner(
              message: state.error!,
              onRetry: () async {
                final authProvider = context.read<AuthProvider>();
                final userId = await authProvider.getCurrentUserId();
                if (userId != null) await notifier.submitBooking(userId: userId);
              },
            ),

          // ── Payment options ──────────────────────────────────────────────
          _SectionHeader(title: 'Payment Options'),
          const SizedBox(height: 10),
          _PaymentToggle(
            selected: state.paymentMethod,
            onChanged: notifier.setPaymentMethod,
          ),
          if (state.paymentMethod == PaymentMethod.online) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Online Payment',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Online payment integration coming soon.',
                    // TODO: Integrate payment gateway
                    style: TextStyle(color: Color(0xFF757575), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── Booking details ──────────────────────────────────────────────
          _BookingDetailsSection(state: state),
          const SizedBox(height: 24),

          // ── Bill details ─────────────────────────────────────────────────
          _BillDetailsSection(state: state),
          const SizedBox(height: 24),

          // ── Additional notes ─────────────────────────────────────────────
          _SectionHeader(title: 'Additional Notes'),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 3,
            onChanged: notifier.setNotes,
            decoration: InputDecoration(
              hintText: 'Add any special requests or notes (optional)...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCta(
    BuildContext context,
    BookingFlowState state,
    BookingFlowNotifier notifier,
  ) {
    final grandTotal = state.grandTotal;
    final totalLabel = '${grandTotal.toStringAsFixed(0)} KM';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Text(
              totalLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF212121),
              ),
            ),
            const Spacer(),
            Semantics(
              label: 'Proceed to pay, $totalLabel',
              button: true,
              enabled: !state.isSubmitting,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => _submitBooking(context, notifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'PROCEED TO PAY →',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBooking(
    BuildContext context,
    BookingFlowNotifier notifier,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final userId = await authProvider.getCurrentUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not identify user. Please log in again.')),
      );
      return;
    }

    await notifier.submitBooking(userId: userId);

    if (!mounted) return;

    final state = notifier.state;
    if (state.bookingConfirmation != null) {
      // Navigate to confirmation — replace so back goes home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: notifier,
            child: const BookingConfirmationScreen(),
          ),
        ),
      );
    } else if (state.error != null) {
      // Check for slot conflict
      final isConflict = state.error!.toLowerCase().contains('conflict') ||
          state.error!.toLowerCase().contains('already') ||
          state.error!.toLowerCase().contains('booked');

      if (isConflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Slot no longer available, please select another.'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
      } else {
        _showNetworkErrorDialog(context, notifier, userId);
      }
    }
  }

  void _showNetworkErrorDialog(
    BuildContext context,
    BookingFlowNotifier notifier,
    int userId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Booking Failed'),
        content: Text(notifier.state.error ?? 'An error occurred.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await notifier.submitBooking(userId: userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

class _PaymentToggle extends StatelessWidget {
  const _PaymentToggle({required this.selected, required this.onChanged});
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PaymentOption(
          label: 'On site',
          isActive: selected == PaymentMethod.onSite,
          onTap: () => onChanged(PaymentMethod.onSite),
        ),
        const SizedBox(width: 12),
        _PaymentOption(
          label: 'Online',
          isActive: selected == PaymentMethod.online,
          onTap: () => onChanged(PaymentMethod.online),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF757575),
          ),
        ),
      ),
    );
  }
}

class _BookingDetailsSection extends StatelessWidget {
  const _BookingDetailsSection({required this.state});
  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final date = state.selectedDate;
    final dateStr = date != null ? DateFormat('d.M.yyyy.').format(date) : '-';
    final slot = state.selectedTimeSlot;
    final timeStr = slot != null ? slot.label : '-';
    final indoorLabel = state.selectedCourt?.isIndoor == true ? 'Indoor' : 'Outdoor';
    final sportName = state.sport?.name ?? '-';
    final courtName = state.selectedCourt?.name ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _DetailTableRow(label: 'Location', value: state.sportCenterName),
        _DetailTableRow(label: 'Court', value: courtName),
        _DetailTableRow(label: 'Facilities Type', value: indoorLabel),
        _DetailTableRow(label: 'Sport', value: sportName),
        _DetailTableRow(label: 'Date', value: dateStr),
        _DetailTableRow(label: 'Time', value: timeStr),
        const Divider(),
      ],
    );
  }
}

class _DetailTableRow extends StatelessWidget {
  const _DetailTableRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillDetailsSection extends StatelessWidget {
  const _BillDetailsSection({required this.state});
  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final slotPrice = state.slotPrice;
    final grandTotal = state.grandTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bill Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _BillRow(label: 'No. of Slots:  1', value: '${slotPrice.toStringAsFixed(0)} KM'),
        _BillRow(label: 'Slot Cost', value: '${slotPrice.toStringAsFixed(0)} KM'),
        const Divider(thickness: 1),
        _BillRow(
          label: 'Total',
          value: '${grandTotal.toStringAsFixed(0)} KM',
          isBold: true,
        ),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.label, required this.value, this.isBold = false});
  final String label;
  final String value;
  final bool isBold;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 20 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF4CAF50): const Color(0xFF757575),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 20 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? const Color(0xFF4CAF50) : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
