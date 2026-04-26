import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/helpers/currency_helper.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/finance_summary_response.dart';
import 'package:terminba_sport_center_desktop/providers/report_provider.dart';

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
      print('Error fetching finance summary: $e');
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
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildRevenueCard(),
                  const SizedBox(height: 42),
                  _buildMonthlyStatsFilter(),
                  const SizedBox(height: 14),
                  _buildMonthTotalLabel(),
                  const SizedBox(height: 12),
                  _buildMonthlyChart(),
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

    return Container(
      width: 250,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6D9DE)),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF20B26B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            "Today's revenue:",
            style: TextStyle(
              fontSize: 36 / 2,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2F33),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyHelper.format(todayRevenue),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2125),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsFilter() {
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(2, (index) => currentYear - index);

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly statistics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF40444B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(color: Color(0xFFD8DCE2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color(0xFF9AC7AE),
                        width: 1.1,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF7C818A)),
                  dropdownColor: Colors.white,
                  items: List.generate(
                    _monthNames.length,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(_monthNames[index]),
                    ),
                ),
                  onChanged: (value) async {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedMonth = value;
                    });
                    await _fetchFinanceSummary();
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(color: Color(0xFFD8DCE2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color(0xFF9AC7AE),
                        width: 1.1,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF7C818A)),
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
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedYear = value;
                    });
                    await _fetchFinanceSummary();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTotalLabel() {
    final monthLabel = _financeSummary?.monthLabel ?? _monthNames[_selectedMonth - 1];
    final monthRevenue = _financeSummary?.monthRevenue ?? 0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '$monthLabel total: ${CurrencyHelper.format(monthRevenue)}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4E5561),
        ),
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
                        color: const Color(0xFFE4E8EE),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Color(0xFFD6DCE5)),
                      bottom: BorderSide(color: Color(0xFFD6DCE5)),
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
