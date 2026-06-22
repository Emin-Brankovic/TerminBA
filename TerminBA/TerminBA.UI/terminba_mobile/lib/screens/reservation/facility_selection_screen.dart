import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/providers/facility_provider.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/screens/reservation/facility_detail_screen.dart';
import 'package:terminba_mobile/screens/reservation/date_time_slot_screen.dart';
import 'package:intl/intl.dart';

class CourtSelectionScreen extends StatefulWidget {
  const CourtSelectionScreen({
    super.key,
    required this.sportCenterId,
    required this.sportCenterName,
    required this.sportCenterAddress,
    required this.sport,
    required this.selectedDate,
  });

  final int sportCenterId;
  final String sportCenterName;
  final String sportCenterAddress;
  final Sport sport;
  final DateTime selectedDate;

  @override
  State<CourtSelectionScreen> createState() => _CourtSelectionScreenState();
}

class _CourtSelectionScreenState extends State<CourtSelectionScreen> {
  late final BookingFlowNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = BookingFlowNotifier(
      initialState: BookingFlowState.initial(
        sportCenterId: widget.sportCenterId,
        sportCenterName: widget.sportCenterName,
        sportCenterAddress: widget.sportCenterAddress,
        sport: widget.sport,
        initialDate: widget.selectedDate,
      ),
      facilityProvider: context.read<FacilityProvider>(),
      reservationProvider: context.read<ReservationProvider>(),
    );
    _notifier.loadCourts();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  String get _dateLabel => DateFormat('d MMM').format(widget.selectedDate);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<BookingFlowNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.sportCenterName} ($_dateLabel)'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: _buildBody(state, notifier),
            bottomNavigationBar: _buildCta(context, state, notifier),
          );
        },
      ),
    );
  }

  Widget _buildBody(BookingFlowState state, BookingFlowNotifier notifier) {
    if (state.isLoadingCourts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.courts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: notifier.loadCourts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.courts.isEmpty) {
      return const Center(
        child: Text(
          'No courts available for this sport.',
          style: TextStyle(color: Color(0xFF757575)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: state.courts.length,
      itemBuilder: (context, index) {
        final court = state.courts[index];
        final isSelected = state.selectedCourt?.id == court.id;
        return _CourtCard(
          court: court,
          isSelected: isSelected,
          onSelect: () => notifier.selectCourt(court),
          onViewDetail: () => _openDetail(context, court, notifier),
        );
      },
    );
  }

  void _openDetail(
    BuildContext context,
    Facility court,
    BookingFlowNotifier notifier,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: notifier,
          child: CourtDetailScreen(court: court),
        ),
      ),
    );
  }

  Widget _buildCta(
    BuildContext context,
    BookingFlowState state,
    BookingFlowNotifier notifier,
  ) {
    final isEnabled = state.selectedCourt != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Semantics(
          label: isEnabled
              ? 'Proceed to select a slot'
              : 'Proceed to select a slot, button, dimmed',
          button: true,
          enabled: isEnabled,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isEnabled
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: notifier,
                            child: const DateTimeSlotScreen(),
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled
                    ? const Color(0xFF4CAF50)
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'PROCEED TO SELECT A SLOT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Court Card widget ────────────────────────────────────────────────────────

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.court,
    required this.isSelected,
    required this.onSelect,
    required this.onViewDetail,
  });

  final Facility court;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final durationMins = court.duration.inMinutes;
    final price = court.staticPrice;
    final priceLabel = price != null ? '${price.toStringAsFixed(0)} KM' : 'Dynamic pricing';
    final sportName = court.availableSports.isNotEmpty
        ? court.availableSports.map((s) => s.name ?? '').join(', ')
        : 'N/A';
    final surfaceType = court.turfType?.name ?? 'N/A';
    final indoorLabel = court.isIndoor ? 'Indoor' : 'Outdoor';

    return GestureDetector(
      onTap: onViewDetail,
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        elevation: isSelected ? 4 : 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────
              if (court.photos.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Semantics(
                      label: '${court.name ?? 'Court'} photo',
                      image: true,
                      child: CachedNetworkImage(
                        imageUrl: court.photos.first.url ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              if (court.photos.isNotEmpty) const SizedBox(height: 12),
              Text(
                court.name ?? 'Court',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // ── Detail rows ───────────────────────────────────
              _DetailRow(
                  icon: Icons.layers_outlined, label: 'Surface Type: $surfaceType'),
              _DetailRow(
                  icon: court.isIndoor ? Icons.home_outlined : Icons.wb_sunny_outlined,
                  label: indoorLabel),
              _DetailRow(
                  icon: Icons.timer_outlined, label: 'Duration: $durationMins min'),
              _DetailRow(
                  icon: Icons.sports_outlined, label: 'Sport: $sportName'),
              _DetailRow(
                  icon: Icons.people_outline, label: 'Max players: ${court.maxCapacity}'),
              _DetailRow(
                  icon: Icons.payments_outlined, label: 'Price: $priceLabel'),
              const SizedBox(height: 12),
              // ── Select button ─────────────────────────────────
              Align(
                alignment: Alignment.bottomRight,
                child: Semantics(
                  label: 'Select ${court.name ?? 'Court'}, $priceLabel',
                  button: true,
                  child: isSelected
                      ? FilledButton.icon(
                          onPressed: onSelect,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Selected'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                          ),
                        )
                      : OutlinedButton(
                          onPressed: onSelect,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            foregroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text('Select'),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF757575)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
            ),
          ),
        ],
      ),
    );
  }
}
