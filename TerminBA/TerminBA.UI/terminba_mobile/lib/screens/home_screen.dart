import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/recommendation_result.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/recommendation_provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/model/facility_time_slot.dart';
import 'package:terminba_mobile/providers/facility_provider.dart';
import 'package:terminba_mobile/providers/payment_provider.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';
import 'package:terminba_mobile/screens/reservation/date_time_slot_screen.dart';
class HomeScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeScreen({super.key, this.scrollController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _primaryGreen = Color(0xFF00C875);

  @override
  void initState() {
    super.initState();
    // Load recommendations after the first frame so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecommendations());
  }

  Future<void> _loadRecommendations() async {
    final authProvider = context.read<AuthProvider>();
    final recommendationProvider = context.read<RecommendationProvider>();
    final userId = await authProvider.getCurrentUserId();
    if (userId != null) {
      await recommendationProvider.loadRecommendations(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rec = context.watch<RecommendationProvider>();

    return SafeArea(
      child: RefreshIndicator(
        color: _primaryGreen,
        onRefresh: _loadRecommendations,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // ── Greeting ──────────────────────────────────────────────────
            _buildGreeting(auth.currentUsername),
            // const SizedBox(height: 24),

            // ── Quick stats card ──────────────────────────────────────────
            // _buildQuickStatsCard(context),
            const SizedBox(height: 18),

            // ── Recommendations section ───────────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.auto_awesome_rounded,
              title: rec.hasRecommendations && !rec.recommendations.first.isPersonalized
                  ? 'Popular courts'
                  : 'Recommended for you',
              subtitle: rec.hasRecommendations && !rec.recommendations.first.isPersonalized
                  ? 'Top rated courts in your area'
                  : 'Based on your previous bookings',
            ),
            const SizedBox(height: 12),
            _buildRecommendationsSection(rec),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Widgets
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildGreeting(String username) {
    final greeting = 'Hello';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $username',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to play today?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C875), Color(0xFF00A35C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nadolazeće rezervacije',
                style: TextStyle(
                    color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, d MMM', 'en_GB').format(DateTime.now()),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _primaryGreen, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              Text(subtitle,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(RecommendationProvider rec) {
    if (rec.isLoading) {
      return const _RecommendationsSkeleton();
    }

    if (!rec.hasRecommendations) {
      return _buildEmptyState();
    }

    return Column(
      children: rec.recommendations
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecommendationCard(recommendation: r),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.sports_soccer_rounded,
              size: 44, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No recommendations currently',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            'Make a few bookings and we will\nsuggest time slots that suit you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recommendation Card
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final RecommendationResult recommendation;
  static const _primaryGreen = Color(0xFF00C875);

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final r = recommendation;
    final dateStr = DateFormat('EEE, d MMM', 'en_GB').format(r.startTime.toLocal());
    final startStr = DateFormat('HH:mm').format(r.startTime.toLocal());
    final endStr = DateFormat('HH:mm').format(r.endTime.toLocal());

    return GestureDetector(
      onTap: () => _onRecommendationTap(context),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Body ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Facility name
                Text(
                  '${r.sportCenterName.isNotEmpty ? '${r.sportCenterName} - ' : ''}${r.facilityName.isNotEmpty ? r.facilityName : 'Court'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (r.sportCenterName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          r.sportCenterName,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),

                // Date / time / price row
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: dateStr,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: '$startStr – $endStr',
                    ),
                    const SizedBox(width: 8),
                    // _InfoChip(
                    //   icon: Icons.payments_outlined,
                    //   label: r.price > 0
                    //       ? '${r.price.toStringAsFixed(0)} BAM'
                    //       : 'N/A',
                    //   highlight: true,
                    // ),
                  ],
                ),

                // ── Reason chips ───────────────────────────────────────
                if (r.reasons.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: r.reasons
                        .map((reason) => _ReasonChip(reason: reason))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> _onRecommendationTap(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _primaryGreen)),
    );

    final rootNav = Navigator.of(context, rootNavigator: true);
    final nav = Navigator.of(context);

    try {
      final facilityProvider = context.read<FacilityProvider>();
      final facility = await facilityProvider.getById(recommendation.facilityId);
      
      if (!context.mounted) {
        rootNav.pop();
        return;
      }

      if (facility == null) {
        rootNav.pop(); // pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load court details')),
        );
        return;
      }

      final sport = facility.availableSports.isNotEmpty ? facility.availableSports.first : null;
      
      final start = recommendation.startTime.toLocal();
      final end = recommendation.endTime.toLocal();

      final initialState = BookingFlowState(
        sportCenterId: facility.sportCenterId,
        sportCenterName: facility.sportCenter?.displayName ?? recommendation.sportCenterName,
        sportCenterAddress: facility.sportCenter?.address ?? '',
        sport: sport,
        initialDate: start,
        selectedCourt: facility,
        selectedDate: start,
      );

      final notifier = BookingFlowNotifier(
        initialState: initialState,
        facilityProvider: facilityProvider,
        reservationProvider: context.read<ReservationProvider>(),
        paymentProvider: context.read<PaymentProvider>(),
      );

      await notifier.selectDate(start);

      // Find the loaded slot that matches the recommendation time
      try {
        final recStartHHmm = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
        final recEndHHmm = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
        
        final loadedSlot = notifier.state.timeSlots.firstWhere((s) {
          final sStart = s.startTime.split(':').take(2).join(':');
          final sEnd = s.endTime.split(':').take(2).join(':');
          return sStart == recStartHHmm && sEnd == recEndHHmm;
        });
        notifier.selectTimeSlot(loadedSlot);
      } catch (_) {
        final fallbackStartStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}:00';
        final fallbackEndStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}:00';
        notifier.selectTimeSlot(FacilityTimeSlot(
          startTime: fallbackStartStr,
          endTime: fallbackEndStr,
          isFree: true,
        ));
      }

      if (context.mounted) {
        rootNav.pop(); // Pop loading dialog here after everything is loaded
        rootNav.push( // Use rootNav to push over the bottom navigation bar
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: notifier,
              child: const DateTimeSlotScreen(),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        rootNav.pop(); // pop loading dialog on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFF00C875).withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: highlight
                  ? const Color(0xFF00C875)
                  : Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: highlight
                  ? const Color(0xFF00C875)
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String reason;

  const _ReasonChip({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF00C875).withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00C875).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 12, color: Color(0xFF00C875)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              reason,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF00A35C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendationsSkeleton extends StatelessWidget {
  const _RecommendationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF00C875),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
