import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/screens/reservation/reservation_confirmation_screen.dart';
import 'package:intl/intl.dart';
import 'package:terminba_mobile/model/payment_method.dart';

class ReservationSummaryScreen extends StatefulWidget {
  const ReservationSummaryScreen({super.key});

  @override
  State<ReservationSummaryScreen> createState() => _ReservationSummaryScreenState();
}

class _ReservationSummaryScreenState extends State<ReservationSummaryScreen> {
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

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await _showCancelDialog(context, notifier);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('${state.sportCenterName} $courtName ($dateLabel)'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  final shouldPop = await _showCancelDialog(context, notifier);
                  if (shouldPop && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            body: _buildBody(context, state, notifier),
            bottomNavigationBar: _buildCta(context, state, notifier),
          ),
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
              onRetry: () {
                // For now, clear the error or let the user click the bottom button again
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
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded,
                      color: Colors.indigo.shade400, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stripe Secure Payment',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You will be prompted to enter your card details. '
                          'Test card: 4242 4242 4242 4242 · Any future date · Any CVC.',
                          style: TextStyle(
                              color: Color(0xFF757575), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── Reservation details ──────────────────────────────────────────────
          _ReservationDetailsSection(state: state),
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
              enabled: !state.isSubmitting && !state.isProcessingPayment,
              child: ElevatedButton(
                onPressed: (state.isSubmitting || state.isProcessingPayment)
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
                child: (state.isSubmitting || state.isProcessingPayment)
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
        const SnackBar(
            content: Text('Could not identify user. Please log in again.')),
      );
      return;
    }

    final state = notifier.state;

    if (state.paymentMethod == PaymentMethod.online) {
      await _handleOnlinePayment(context, notifier, userId);
    } else {
      await _submitOnSiteBooking(context, notifier, userId);
    }
  }

  Future<void> _handleOnlinePayment(
    BuildContext context,
    BookingFlowNotifier notifier,
    int userId,
  ) async {
    final state = notifier.state;
    if (state.bookingConfirmation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation not found. Please try again.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    final reservationId = state.bookingConfirmation!.id;
    final intentResponse = await notifier.createPaymentIntent(userId: userId, reservationId: reservationId);

    if (!mounted) return;

    if (intentResponse == null || intentResponse.clientSecret.isEmpty) {
      final err = notifier.state.paymentError ?? 'Failed to start payment.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
      return;
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intentResponse.clientSecret,
          merchantDisplayName: 'TerminBA',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      
      // Confirm with backend directly instead of relying solely on webhook
      await notifier.confirmPaymentIntent(intentResponse.paymentIntentId);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: notifier,
            child: const ReservationConfirmationScreen(),
          ),
        ),
      );
    } on StripeException catch (e) {
      if (!mounted) return;

      final code = e.error.code;
      final isCancelled = code == FailureCode.Canceled;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCancelled
                ? 'Payment was cancelled.'
                : 'Payment failed: ${e.error.localizedMessage ?? 'Unknown error'}',
          ),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _submitOnSiteBooking(
    BuildContext context,
    BookingFlowNotifier notifier,
    int userId,
  ) async {
    await notifier.confirmCashBooking();

    if (!mounted) return;

    final state = notifier.state;
    if (state.error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: notifier,
            child: const ReservationConfirmationScreen(),
          ),
        ),
      );
    } else {
      _showNetworkErrorDialog(context, notifier, userId);
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
        title: const Text('Reservation Failed'),
        content: Text(notifier.state.error ?? 'An error occurred.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showCancelDialog(BuildContext context, BookingFlowNotifier notifier) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Reservation?'),
          content: const Text('If you go back, your pending reservation will be canceled and the time slot will be freed up for others.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Booking'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      await notifier.cancelPendingReservation();
      return true;
    }
    return false;
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

class _ReservationDetailsSection extends StatelessWidget {
  const _ReservationDetailsSection({required this.state});
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD0D7F5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF5C7AE6), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cancellation Policy: Free cancellation up to ${state.selectedCourt?.sportCenter?.cancellationDeadlineHours ?? 24} hours before the reservation.',
                  style: const TextStyle(
                    color: Color(0xFF334A99),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
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
