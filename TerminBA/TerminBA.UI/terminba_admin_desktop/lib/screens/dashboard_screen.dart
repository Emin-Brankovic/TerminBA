import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/dashboard_response.dart';
import 'package:terminba_admin_desktop/providers/report_provider.dart';
import 'package:screenshot/screenshot.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ReportProvider _reportProvider;
  bool _isGeneratingPdf = false;
  int _selectedYear = DateTime.now().year;
  DashboardResponse? _dashboardData;
  final ScreenshotController screenshotController = ScreenshotController();


    @override
  void initState() {
    super.initState();
    _reportProvider = context.read<ReportProvider>();

    _fetchDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Dashboard',
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _reportCard(
                      "Total Users",
                      "${_dashboardData?.appUserCount ?? 0}",
                      Icons.people_alt_outlined,
                      const Color(0xFFEFF6FF),
                      const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _reportCard(
                      "Sport Centers",
                      "${_dashboardData?.appSportCenterCount ?? 0}",
                      Icons.location_city_outlined,
                      const Color(0xFFECFDF5),
                      const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _reportCard(
                      "Reservations",
                      "${_dashboardData?.appReservationCount ?? 0}",
                      Icons.event_available_outlined,
                      const Color(0xFFF5F3FF),
                      const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 150,
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      items: List.generate(DateTime.now().year - 2024, (i) => DateTime.now().year - i)
                          .map(
                            (y) =>
                                DropdownMenuItem(value: y, child: Text('$y')),
                          )
                          .toList(),
                      onChanged: (year) =>{
                          setState(() => _selectedYear = year!),
                          _fetchDashboardData(),
                      }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Screenshot(
                controller: screenshotController,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildLineChart(
                        title: "Users by Month",
                        dataByMonth: _dashboardData?.userCountByMonth ?? {},
                        lineColor: Colors.green,
                      ),
                    ),
                
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildLineChart(
                        title: "Reservations by Month",
                        dataByMonth:
                            _dashboardData?.reservationCountByMonth ?? {},
                        lineColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isGeneratingPdf
                        ? null
                        : () async {
                            await _captureAndSendToPdf();
                          },
                    icon: _isGeneratingPdf
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(_isGeneratingPdf ? "Generating..." : "Export as PDF",style: TextStyle(fontSize: 16),),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 18),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportCard(
    String title,
    String value,
    IconData iconData, [
    Color iconBgColor = const Color(0xFFEFF6FF),
    Color iconColor = const Color(0xFF2563EB),
  ]) {
    return Container(
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
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  static const _monthLabels = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  Widget _buildLineChart({
    required String title,
    required Map<int, int> dataByMonth,
    required Color lineColor,
  }) {
    final sortedEntries = dataByMonth.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    final maxVal = sortedEntries.isEmpty
        ? 0
        : sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    final maxY = maxVal == 0 ? 10.0 : maxVal.toDouble() * 1.2;

    double yInterval = (maxY / 5).ceilToDouble();
    if (yInterval == 0) yInterval = 1;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: spots.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: 12,
                        minY: 0,
                        maxY: maxY == 0 ? 10 : maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
                            left: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 1 || idx > 12) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _monthLabels[idx],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) {
                                if (value != value.toInt().toDouble()) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
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
                            color: lineColor,
                            barWidth: 2.5,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: lineColor,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: lineColor.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchDashboardData() async {
    try {
      var result = await _reportProvider.fetchDashboardData(_selectedYear);
      if (!mounted) return;
      setState(() {
        _dashboardData = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $e')),
      );
    }
  }

  Future<void> _captureAndSendToPdf() async {
    final dashboard = _dashboardData;
    if (dashboard == null || _isGeneratingPdf) {
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to capture chart image.')),
        );
        return;
      }

      final filePath = await _reportProvider.generateReport(
        imageBytes: imageBytes,
        totalUsers: dashboard.appUserCount,
        totalSportCenters: dashboard.appSportCenterCount,
        totalReservations: dashboard.appReservationCount,
        selectedYear: _selectedYear,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report saved to: $filePath')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }
}
