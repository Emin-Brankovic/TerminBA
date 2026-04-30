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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _reportProvider.fetchSportCenterDashboard();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print(e);
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
    final int maxValue = data
        .map((e) => e.value)
        .fold<int>(1, (prev, element) => element > prev ? element : prev);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...data.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      item.label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: item.value / maxValue,
                        backgroundColor: const Color(0xFFE5E7EB),
                        color: const Color(0xFF12B76A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${item.value}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
    final int cancelled = _upcomingReservations.where((e) => e.status == 'Cancelled').length;

    return _sectionCard(
      title: 'Today Operations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusChip('Completed: $completed', const Color(0xFF027A48), const Color(0xFFECFDF3)),
              _statusChip('Active: $active', const Color(0xFF1D4ED8), const Color(0xFFEFF6FF)),
              _statusChip('Cancelled: $cancelled', const Color(0xFFB42318), const Color(0xFFFEF3F2)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Next reservations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._upcomingReservations.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(item.slot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text(
                      '${item.facility} - ${item.bookedBy}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(item.status, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color textColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 12),
          Text(
            'Lowest rated recent reviews',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
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
                    Text('${item.rating}/5', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item.facility}: ${item.comment}',
                        style: const TextStyle(fontSize: 13),
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
          (item) => _UpcomingReservation(
            item.slot,
            item.facilityName,
            item.bookedBy,
            item.status,
          ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          if (subtitle != null) ...[
            Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
          ],
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}