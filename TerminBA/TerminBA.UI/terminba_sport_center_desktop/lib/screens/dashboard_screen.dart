import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_dashboard_response.dart';
import 'package:terminba_sport_center_desktop/providers/report_provider.dart';
import 'package:terminba_sport_center_desktop/widgets/report_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ReportProvider _reportProvider;
  SportCenterDashboardResponse? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  static const List<String> _weekdayOrder = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _reportProvider = context.read<ReportProvider>();
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Dashboard',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool stacked = constraints.maxWidth < 1160;

            if (_dashboardData == null && _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Center(child: _buildKpiGrid()),
                  const SizedBox(height: 18),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (stacked) ...[
                    _buildDemandSection(),
                    const SizedBox(height: 16),
                    _buildTodayOperations(),
                    const SizedBox(height: 16),
                    _buildQualityPanel(),
                    const SizedBox(height: 16),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildDemandSection()),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTodayOperations(),
                              const SizedBox(height: 16),
                              _buildQualityPanel(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _reportProvider.fetchSportCenterDashboard();
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
    }
  }

  Widget _buildKpiGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _buildKpis()
          .map(
            (item) => SizedBox(
              width: 250,
              child: ReportCard(
                title: item.title,
                value: item.value,
                iconData: item.icon,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDemandSection() {
    return _sectionCard(
      title: 'Reservation Demand',
      child: Column(
        children: [
          _demandSubsection('Reservations By Weekday', _reservationsByWeekday),
          const SizedBox(height: 14),
          _demandSubsection('Reservations By Facility', _reservationsByFacility),
          const SizedBox(height: 14),
          _demandSubsection('Reservations By Sport', _reservationsBySport),
        ],
      ),
    );
  }

  Widget _demandSubsection(String title, List<_DemandItem> data) {
    final int maxValue = data.isEmpty
        ? 1
        : data
            .map((e) => e.value)
            .fold<int>(1, (prev, element) => element > prev ? element : prev);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No reservations recorded.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            )
          else
            ...data.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: maxValue == 0 ? 0 : (item.value / maxValue),
                          backgroundColor: const Color(0xFFE2E8F0),
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.value}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayOperations() {
    final int completed = _upcomingReservations.where((e) => e.status == 'Completed').length;
    final int active = _upcomingReservations.where((e) => e.status == 'Active').length;
    final int cancelled = _upcomingReservations.where((e) => e.status == 'Cancelled' || e.status == 'Canceled').length;

    return _sectionCard(
      title: 'Today Reservations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusChip('Completed: $completed', const Color(0xFF027A48), const Color(0xFFECFDF3)),
              _statusChip('Active: $active', const Color(0xFF1D4ED8), const Color(0xFFEFF6FF)),
              _statusChip('Canceled: $cancelled', const Color(0xFFB42318), const Color(0xFFFEF3F2)),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Next reservations',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (_upcomingReservations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No upcoming reservations for today.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            )
          else
            ..._upcomingReservations.map(
              (item) {
                final statusLower = item.status.toLowerCase();
                final isCompleted = statusLower.contains('complete');
                final isCancelled = statusLower.contains('cancel');

                final badgeColor = isCompleted
                    ? const Color(0xFF027A48)
                    : isCancelled
                        ? const Color(0xFFB42318)
                        : const Color(0xFF1D4ED8);
                final badgeBg = isCompleted
                    ? const Color(0xFFECFDF3)
                    : isCancelled
                        ? const Color(0xFFFEF3F2)
                        : const Color(0xFFEFF6FF);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              item.slot,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.facility,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 11, color: Color(0xFF64748B)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    item.bookedBy,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color textColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQualityPanel() {
    final double averageRating = _dashboardData?.averageRating ?? 0;
    final int reviewsIn7d = _dashboardData?.reviewsIn7d ?? 0;
    final int reviewsIn30d = _dashboardData?.reviewsIn30d ?? 0;
    final List<_ReviewAlertItem> reviews = _lowestRatedReviews;

    return _sectionCard(
      title: 'Quality And Growth',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _QualityMetric(
                  label: 'Avg Rating',
                  value: '${averageRating.toStringAsFixed(1)} / 5',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QualityMetric(
                  label: 'Reviews 7d',
                  value: reviewsIn7d.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QualityMetric(
                  label: 'Reviews 30d',
                  value: reviewsIn30d.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Lowest rated recent reviews',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            Text(
              'No low-rated reviews for this period.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          else
            ...reviews.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                          const SizedBox(width: 3),
                          Text(
                            '${item.rating}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.facility,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.comment,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_KpiItem> _buildKpis() {
    final data = _dashboardData;

    final todayRevenue = _formatCurrency(data?.todayRevenue ?? 0);
    final weeklyRevenue = _formatCurrency(data?.weeklyRevenue ?? 0);
    final reservationsToday = (data?.reservationsToday ?? 0).toString();
    final activeFacilities = (data?.activeFacilities ?? 0).toString();
    final newReviews = (data?.newReviews7d ?? 0).toString();

    return [
      _KpiItem('Today Revenue', todayRevenue, Icons.attach_money),
      _KpiItem('Weekly Revenue', weeklyRevenue, Icons.trending_up),
      _KpiItem('Reservations Today', reservationsToday, Icons.event_available),
      _KpiItem('Active Facilities', activeFacilities, Icons.stadium),
      _KpiItem('New Reviews (7d)', newReviews, Icons.reviews),
    ];
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  List<_DemandItem> get _reservationsByWeekday {
    final counts = _dashboardData?.reservationsByWeekday ?? {};
    final items = <_DemandItem>[];

    for (final label in _weekdayOrder) {
      if (counts.containsKey(label)) {
        items.add(_DemandItem(label, counts[label] ?? 0));
      }
    }

    final remaining = counts.entries
        .where((entry) => !_weekdayOrder.contains(entry.key))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    items.addAll(remaining.map((e) => _DemandItem(e.key, e.value)));
    return items;
  }

  List<_DemandItem> get _reservationsBySport {
    return _mapCountItems(_dashboardData?.reservationsBySport ?? {});
  }

  List<_DemandItem> get _reservationsByFacility {
    return _mapCountItems(_dashboardData?.reservationsByFacility ?? {});
  }

  List<_DemandItem> _mapCountItems(Map<String, int> data) {
    final entries = data.entries.toList()
      ..sort((a, b) {
        final compare = b.value.compareTo(a.value);
        return compare != 0 ? compare : a.key.compareTo(b.key);
      });

    return entries.map((e) => _DemandItem(e.key, e.value)).toList();
  }

  List<_UpcomingReservation> get _upcomingReservations {
    final items = _dashboardData?.upcomingReservations ?? [];
    return items
        .map(
          (item) {
            String displayStatus = item.status;
            if (displayStatus == 'CanceledWithRefundReservationState' || 
                displayStatus == 'CanceledWithoutRefundReservationState' || 
                displayStatus == 'Cancelled') {
              displayStatus = 'Canceled';
            }
            return _UpcomingReservation(
              item.slot,
              item.facilityName,
              item.bookedBy,
              displayStatus,
            );
          },
        )
        .toList();
  }

  List<_ReviewAlertItem> get _lowestRatedReviews {
    final items = _dashboardData?.lowestRatedReviews ?? [];
    return items
        .map(
          (item) => _ReviewAlertItem(
            item.facilityName,
            item.rating,
            item.comment,
          ),
        )
        .toList();
  }
 

  Widget _sectionCard({
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _KpiItem {
  final String title;
  final String value;
  final IconData icon;

  const _KpiItem(this.title, this.value, this.icon);
}

class _DemandItem {
  final String label;
  final int value;

  const _DemandItem(this.label, this.value);
}

class _UpcomingReservation {
  final String slot;
  final String facility;
  final String bookedBy;
  final String status;

  const _UpcomingReservation(
    this.slot,
    this.facility,
    this.bookedBy,
    this.status,
  );
}

class _ReviewAlertItem {
  final String facility;
  final int rating;
  final String comment;

  const _ReviewAlertItem(this.facility, this.rating, this.comment);
}

class _QualityMetric extends StatelessWidget {
  final String label;
  final String value;

  const _QualityMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
