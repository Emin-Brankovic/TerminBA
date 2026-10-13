import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/helpers/currency_helper.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/finance_summary_response.dart';
import 'package:terminba_sport_center_desktop/providers/report_provider.dart';
import 'package:terminba_sport_center_desktop/widgets/report_card.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late ReportProvider _reportProvider;
  bool _initialized = false;
  bool _isLoading = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  FinanceSummaryResponse? _financeSummary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    _reportProvider = context.read<ReportProvider>();
    _fetchFinanceSummary();
  }

  Future<void> _fetchFinanceSummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final summary = await _reportProvider.fetchSportCenterFinanceSummary(
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _financeSummary = summary;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load finances: $e')));
      debugPrint('Error fetching finance summary: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Finances',
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildRevenueCard(),
                  const SizedBox(height: 28),
                  _buildMonthlyCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    final todayRevenue = _financeSummary?.todayRevenue ?? 0;

    return ReportCard(
      title: "Today's Revenue",
      value: CurrencyHelper.format(todayRevenue),
      iconData: Icons.attach_money_rounded,
      width: 280,
    );
  }

  Widget _buildMonthlyCard() {
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(2, (index) => currentYear - index);
    final monthLabel = _financeSummary?.monthLabel ?? _monthNames[_selectedMonth - 1];
    final monthRevenue = _financeSummary?.monthRevenue ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Statistics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Daily revenue breakdown for $monthLabel $_selectedYear',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 15,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$monthLabel Total: ${CurrencyHelper.format(monthRevenue)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: InputDecoration(
                    labelText: 'Month',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  dropdownColor: Colors.white,
                  items: List.generate(
                    _monthNames.length,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(_monthNames[index]),
                    ),
                  ),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      _selectedMonth = value;
                    });
                    await _fetchFinanceSummary();
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: InputDecoration(
                    labelText: 'Year',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  dropdownColor: Colors.white,
                  items: years
                      .map(
                        (year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      _selectedYear = value;
                    });
                    await _fetchFinanceSummary();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMonthlyChart(),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final dailyPoints = _financeSummary?.dailyRevenuePoints ?? const <FinanceDailyRevenuePointResponse>[];
    final chartPoints = dailyPoints.isEmpty
        ? const [0.0]
        : dailyPoints.map((e) => e.revenue).toList();

    final spots = chartPoints
        .asMap()
        .entries
        .map((entry) => FlSpot((entry.key + 1).toDouble(), entry.value))
        .toList();

    final maxRevenue = chartPoints.reduce(
      (a, b) => a > b ? a : b,
    );
    final maxY = maxRevenue <= 0
        ? 100.0
        : ((maxRevenue / 100).ceil() * 100).toDouble() + 100;

    final maxX = dailyPoints.isEmpty ? 1.0 : dailyPoints.length.toDouble();
    final yInterval = (maxY / 5).ceilToDouble();

    return SizedBox(
      height: 280,
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: _isLoading && _financeSummary == null
            ? const Center(child: CircularProgressIndicator())
            : LineChart(
                LineChartData(
                  minX: 1,
                  maxX: maxX,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFF1F5F9),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Color(0xFFE2E8F0)),
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF98A0AA),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final day = value.toInt();
                          if (day < 1 || day > maxX.toInt()) {
                            return const SizedBox.shrink();
                          }
                          if (day != 1 && day % 5 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              day.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF98A0AA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: const Color(0xFF2F86E9),
                      dotData: FlDotData(
                        show: dailyPoints.isNotEmpty,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 3,
                              color: const Color(0xFF2F86E9),
                              strokeWidth: 1.2,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF2F86E9).withValues(alpha: 0.18),
                            const Color(0xFF2F86E9).withValues(alpha: 0.02),
                          ],
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
