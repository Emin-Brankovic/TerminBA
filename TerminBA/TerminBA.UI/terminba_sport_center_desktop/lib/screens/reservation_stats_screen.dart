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
      print(  'Export error: $e');
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
        title:Text(
            'Reservation statistics',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
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
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE6E9ED)),
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
                ElevatedButton(
                  onPressed: _isExporting ? null : _exportReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12B76A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                  ),
                  child: Text(_isExporting ? 'Exporting...' : 'Export'),
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
        const Text(
          'Select date range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _pickFromDate,
          icon: const Icon(Icons.date_range, size: 18),
          label: Text('From: ${_formatDate(_fromDate)}'),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: _pickToDate,
          icon: const Icon(Icons.event, size: 18),
          label: Text('To: ${_formatDate(_toDate)}'),
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
            title: 'Distribution by sport',
            data: stats?.reservationCountBySport ?? const <String, int>{},
          ),
          const SizedBox(height: 20),
          _buildPieCard(
            title: 'Distribution by facaility',
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
        SizedBox(
          height: 190,
          child: total == 0
              ? const Center(child: Text('No data available'))
              : Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 0,
                          sectionsSpace: 0,
                          borderData: FlBorderData(show: false),
                          sections: [
                            for (int i = 0; i < entries.length; i++)
                              PieChartSectionData(
                                color: palette[i % palette.length],
                                value: entries[i].value.toDouble(),
                                radius: 88,
                                title:
                                    '${((entries[i].value / total) * 100).round()}%',
                                titleStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final color = palette[index % palette.length];
                          final key = entries[index].key;
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
                                    style: const TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
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
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                        color: const Color(0xFFE8ECF2),
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
                              width: 30,
                              borderRadius: BorderRadius.circular(0),
                              color: const Color(0xFF2F80ED),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: safeChartMax,
                                color: const Color(0xFFD7E7FB),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              : const Center(child: Text('No data available')),
        ),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.center,
          child: Text(
            'Distribution of reservations',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
