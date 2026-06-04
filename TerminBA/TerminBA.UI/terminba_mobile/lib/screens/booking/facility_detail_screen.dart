import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/screens/booking/date_time_slot_screen.dart';
import 'package:intl/intl.dart';

/// Screen 2 (optional): Full-detail view of a court with photo carousel.
/// Shares the [BookingFlowNotifier] passed from [CourtSelectionScreen].
class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key, required this.court});

  final Facility court;

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingFlowNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;
        final isSelected = state.selectedCourt?.id == widget.court.id;
        final dateLabel = DateFormat('d MMM').format(state.initialDate);

        return Scaffold(
          appBar: AppBar(
            title: Text('${state.sportCenterName} ($dateLabel)'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCarousel(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSpecs(isSelected, notifier),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildCta(context, state, notifier, isSelected),
        );
      },
    );
  }

  Widget _buildCarousel() {
    final photoUrls = widget.court.photos
        .where((p) => p.url?.isNotEmpty ?? false)
        .map((p) => p.url!)
        .toList();

    if (photoUrls.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: photoUrls.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Semantics(
                label: '${widget.court.name ?? 'Court'} photo ${index + 1}',
                image: true,
                child: CachedNetworkImage(
                  imageUrl: photoUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(color: Colors.grey.shade100),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              );
            },
          ),
        ),
        if (photoUrls.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photoUrls.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 10 : 6,
                  height: active ? 10 : 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white70,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecs(bool isSelected, BookingFlowNotifier notifier) {
    final court = widget.court;
    final durationMins = court.duration.inMinutes;
    final price = court.staticPrice;
    final priceLabel = price != null ? '${price.toStringAsFixed(0)} KM' : 'N/A';
    final sportName = court.availableSports.isNotEmpty
        ? court.availableSports.map((s) => s.name ?? '').join(', ')
        : 'N/A';
    final surfaceType = court.turfType?.name ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          court.name ?? 'Court',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _SpecRow(icon: Icons.layers_outlined, label: 'Surface Type', value: surfaceType),
        _SpecRow(
          icon: court.isIndoor ? Icons.home_outlined : Icons.wb_sunny_outlined,
          label: 'Type',
          value: court.isIndoor ? 'Indoor' : 'Outdoor',
        ),
        _SpecRow(icon: Icons.timer_outlined, label: 'Duration', value: '$durationMins min'),
        _SpecRow(icon: Icons.sports_outlined, label: 'Sport', value: sportName),
        _SpecRow(
            icon: Icons.people_outline,
            label: 'Max players',
            value: '${court.maxCapacity}'),
        _SpecRow(icon: Icons.payments_outlined, label: 'Price', value: priceLabel),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: Semantics(
            label: 'Select ${court.name ?? 'Court'}, $priceLabel',
            button: true,
            child: isSelected
                ? FilledButton.icon(
                    onPressed: () => notifier.selectCourt(court),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Selected ✓'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  )
                : OutlinedButton(
                    onPressed: () => notifier.selectCourt(court),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      foregroundColor: const Color(0xFF4CAF50),
                    ),
                    child: const Text('Select'),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCta(
    BuildContext context,
    BookingFlowState state,
    BookingFlowNotifier notifier,
    bool isSelected,
  ) {
    final isEnabled = state.selectedCourt != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
              backgroundColor:
                  isEnabled ? const Color(0xFF4CAF50) : Colors.grey.shade400,
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
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF757575)),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
