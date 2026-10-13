import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_reservation_stats_report_request.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_reservation_stats_response.dart';
import 'package:terminba_sport_center_desktop/providers/report_provider.dart';

class ReservationStatsScreen extends StatefulWidget {
  const ReservationStatsScreen({super.key});

  @override
  State<ReservationStatsScreen> createState() => _ReservationStatsScreenState();
}

class _ReservationStatsScreenState extends State<ReservationStatsScreen> {
  static const List<String> _weekdayShort = [
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
  ];

  final ScreenshotController _screenshotController = ScreenshotController();

  late ReportProvider _reportProvider;
  bool _initialized = false;
  bool _isLoading = false;
  bool _isExporting = false;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 29));
  DateTime _toDate = DateTime.now();

  SportCenterReservationStatsResponse? _statsResponse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    _reportProvider = context.read<ReportProvider>();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _reportProvider.fetchSportCenterReservationStats(
        fromDate: _fromDate,
        toDate: _toDate,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _statsResponse = results;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Failed to load stats: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportReport() async {
    if (_isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final Uint8List? bytes = await _screenshotController.capture(
        pixelRatio: 2,
      );

      if (bytes == null) {
        throw Exception('Could not capture chart image.');
      }

      final stats = _statsResponse;
      final countBySport =
          stats?.reservationCountBySport ?? const <String, int>{};
      final countByFacility =
          stats?.reservationCountByFacility ?? const <String, int>{};
      final totalReservations = countBySport.values.fold<int>(
        0,
        (sum, value) => sum + value,
      );
      final reportRequest = SportCenterReservationStatsReportRequest(
        fromDate: _fromDate,
        toDate: _toDate,
        chartImage: bytes,
        totalReservations: totalReservations,
        countBySport: countBySport,
        countByFacility: countByFacility,
      );

      final filePath = await _reportProvider
          .generateSportCenterReservationStatsReport(
            reportRequest: reportRequest,
          );

      if (!mounted) {
        return;
      }
      _showSnackBar('Report exported to: $filePath');
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Export failed: $e');
      debugPrint(  'Export error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _fromDate = DateTime(picked.year, picked.month, picked.day);
      if (_fromDate.isAfter(_toDate)) {
        _toDate = _fromDate;
      }
    });

    _fetchStats();
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _toDate = DateTime(picked.year, picked.month, picked.day);
      if (_toDate.isBefore(_fromDate)) {
        _fromDate = _toDate;
      }
    });

    _fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statsResponse;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title:Center(
          child: Text(
              'Reservation statistics',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                ),
        )),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFilterRow(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading && stats == null
                  ? const Center(child: CircularProgressIndicator())
                    : Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 950;
                            if (stacked) {
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLeftCharts(stats),
                                    const SizedBox(height: 20),
                                    _buildBarSection(stats, 300),
                                  ],
                                ),
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 360,
                                  child: _buildLeftCharts(stats),
                                ),
                                const SizedBox(width: 24),
                                Expanded(child: _buildBarSection(stats, 390)),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportReport,
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: Text(_isExporting ? 'Exporting...' : 'Export Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        const Icon(Icons.date_range_rounded, size: 20, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        const Text(
          'Date Range',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 14),
        OutlinedButton.icon(
          onPressed: _pickFromDate,
          icon: const Icon(Icons.calendar_today_rounded, size: 14),
          label: Text('From: ${_formatDate(_fromDate)}'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: _pickToDate,
          icon: const Icon(Icons.event_available_rounded, size: 14),
          label: Text('To: ${_formatDate(_toDate)}'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const Spacer(),
        if (_isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildLeftCharts(SportCenterReservationStatsResponse? stats) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPieCard(
            title: 'Distribution by Sport',
            data: stats?.reservationCountBySport ?? const <String, int>{},
          ),
          const SizedBox(height: 24),
          _buildPieCard(
            title: 'Distribution by Facility',
            data: stats?.reservationCountByFacility ?? const <String, int>{},
          ),
        ],
      ),
    );
  }

  Widget _buildPieCard({
    required String title,
    required Map<String, int> data,
  }) {
    final entries = data.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<int>(0, (sum, item) => sum + item.value);
    final palette = _chartPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        SizedBox(
          height: 185,
          child: total == 0
              ? Container(
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'No data available',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                  ),
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 175,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 0,
                          sectionsSpace: 1.5,
                          borderData: FlBorderData(show: false),
                          sections: [
                            for (int i = 0; i < entries.length; i++)
                              PieChartSectionData(
                                color: palette[i % palette.length],
                                value: entries[i].value.toDouble(),
                                radius: 85,
                                title:
                                    '${((entries[i].value / total) * 100).round()}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  shadows: [
                                    Shadow(color: Colors.black26, blurRadius: 2),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final color = palette[index % palette.length];
                          final key = entries[index].key;
                          final count = entries[index].value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    key,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF334155),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBarSection(
    SportCenterReservationStatsResponse? stats,
    double height,
  ) {
    final weeklyData = _toOrderedWeekData(
      stats?.reservationCountByWeekDay ?? const <String, int>{},
    );
    final hasData = weeklyData.any((e) => e.value > 0);

    final maxCount = weeklyData.isEmpty
        ? 1
        : weeklyData.map((e) => e.value).reduce(math.max);
    final chartMax = maxCount.toDouble();
    final safeChartMax = chartMax <= 0 ? 1.0 : chartMax;
    final yInterval = safeChartMax / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Distribution of Reservations by Weekday',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        SizedBox(
          height: height,
          child: hasData
              ? BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: safeChartMax,
                    groupsSpace: 18,
                    alignment: BarChartAlignment.spaceEvenly,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0xFFF1F5F9),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= weeklyData.length) {
                              return const SizedBox.shrink();
                            }

                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                weeklyData[index].value.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF5E6673),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= _weekdayShort.length) {
                              return const SizedBox.shrink();
                            }

                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                _weekdayShort[index],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF777E8B),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: yInterval,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            if (value % 50 != 0) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9AA3AF),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (int i = 0; i < weeklyData.length; i++)
                        BarChartGroupData(
                          x: i,
                          barsSpace: 0,
                          barRods: [
                            BarChartRodData(
                              toY: weeklyData[i].value.toDouble(),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              color: const Color(0xFF2563EB),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: safeChartMax,
                                color: const Color(0xFFEFF6FF),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text('No data available', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                ),
        ),
      ],
    );
  }

  List<MapEntry<String, int>> _toOrderedWeekData(Map<String, int> input) {
    int find(String short) {
      final lowerShort = short.toLowerCase();
      final match = input.entries.firstWhere((entry) {
        final key = entry.key.toLowerCase();
        return key == lowerShort ||
            key.startsWith(lowerShort) ||
            (lowerShort == 'mo' && key.startsWith('mon')) ||
            (lowerShort == 'tu' && key.startsWith('tue')) ||
            (lowerShort == 'we' && key.startsWith('wed')) ||
            (lowerShort == 'th' && key.startsWith('thu')) ||
            (lowerShort == 'fr' && key.startsWith('fri')) ||
            (lowerShort == 'sa' && key.startsWith('sat')) ||
            (lowerShort == 'su' && key.startsWith('sun'));
      }, orElse: () => MapEntry(short, 0));
      return match.value;
    }

    return _weekdayShort
        .map((day) => MapEntry(day, find(day)))
        .toList(growable: false);
  }

  List<Color> get _chartPalette => const [
    Color(0xFFEB5757),
    Color(0xFFF2994A),
    Color(0xFFF2C94C),
    Color(0xFF6FCF97),
    Color(0xFF56CCF2),
    Color(0xFF2D9CDB),
    Color(0xFFBB6BD9),
  ];
}
