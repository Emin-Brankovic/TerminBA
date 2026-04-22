import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/helpers/currency_helper.dart';
import 'package:terminba_sport_center_desktop/helpers/date_helper.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/reservation_response.dart';
import 'package:terminba_sport_center_desktop/providers/auth_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_provider.dart';
import 'package:terminba_sport_center_desktop/providers/reservation_provider.dart';
import 'package:terminba_sport_center_desktop/screens/reservation_edit_screen.dart';
import 'package:terminba_sport_center_desktop/screens/reservation_stats_screen.dart';
import 'package:terminba_sport_center_desktop/widgets/confirmation_dialog.dart';
import 'package:terminba_sport_center_desktop/widgets/universal_pagination.dart';

class ReservationsOverviewScreen extends StatefulWidget {
  const ReservationsOverviewScreen({super.key});

  @override
  State<ReservationsOverviewScreen> createState() =>
      _ReservationsOverviewScreenState();
}

class _ReservationsOverviewScreenState
    extends State<ReservationsOverviewScreen> {
  static const double _tableMinWidth = 1100;
  static const int _reservationNoFlex = 1;
  static const int _courtPitchFlex = 3;
  static const int _bookedByFlex = 2;
  static const int _bookedOnFlex = 2;
  static const int _chosenSportFlex = 2;
  static const int _statusFlex = 2;
  static const int _slotFlex = 2;
  static const int _priceFlex = 2;
  static const int _pageSize = 10;

  bool _initialized = false;
  bool _isLoading = true;

  DateTime _selectedDate = DateTime.now();
  int? _selectedFacilityId;
  late ReservationProvider _reservationProvider;
  late FacilityProvider _facilityProvider;
  late AuthProvider _authProvider;
  int? _currentSportCenterId;
  String _reservationNoSearch = '';
  int _currentPage = 1;
  final List<Facility> _facilities = [];
  List<ReservationResponse> _reservations = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;
    _reservationProvider = context.read<ReservationProvider>();
    _facilityProvider = context.read<FacilityProvider>();
    _authProvider = context.read<AuthProvider>();

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentSportCenterId = _authProvider.isLoggedIn
          ? await _authProvider.getCurrentUserId()
          : null;

      if (_currentSportCenterId == null) {
        throw Exception('Sport center not found for current user.');
      }

      await _loadFacilities();
      await _loadReservations();
    } catch (e) {
      // Errors are intentionally not surfaced in the UI on this screen.
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFacilities() async {
    final result = await _facilityProvider.get(
      filter: {'sportCenterId': _currentSportCenterId, 'page': 1},
    );

    if (!mounted) return;
    final facilities = result.items ?? [];
    _facilities
      ..clear()
      ..addAll(facilities);

    if (_selectedFacilityId != null &&
        !_facilities.any((f) => f.id == _selectedFacilityId)) {
      _selectedFacilityId = null;
    }
  }

  Future<void> _loadReservations() async {
    if (_currentSportCenterId == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final filter = <String, dynamic>{
        'sportCenterId': _currentSportCenterId,
        'reservationDate': _toDateOnly(_selectedDate),
        'sortByChosenTimeSlot': true,
        if (_selectedFacilityId != null) 'facilityId': _selectedFacilityId,
        'page': 1,
      };

      final result = await _reservationProvider.get(filter: filter);

      if (!mounted) return;
      setState(() {
        _reservations = result.items ?? [];
        _currentPage = 1;
      });
    } catch (e) {
      // Errors are intentionally not surfaced in the UI on this screen.
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelReservation(int reservationId) async {
    final shouldCancel = await ConfirmationDialog.show(
      context,
      title: 'Cancel reservation',
      message: 'Are you sure you want to cancel this reservation?',
      cancelText: 'No',
      confirmText: 'Yes, cancel',
      confirmButtonColor: const Color(0xFFFF4405),
    );

    if (!shouldCancel) {
      return;
    }

    try {
      setState(() => _isLoading = true);
      await _reservationProvider.cancelReservation(reservationId);
      await _loadReservations();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation cancelled successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<_ReservationRowData> get _filteredRows {
    final mapped = _reservations.map(_toRowData).toList();

    if (_reservationNoSearch.trim().isEmpty) {
      return mapped;
    }

    return mapped
        .where(
          (row) => row.reservationNo.toLowerCase().contains(
            _reservationNoSearch.trim().toLowerCase(),
          ),
        )
        .toList();
  }

  int get _totalPages {
    if (_filteredRows.isEmpty) {
      return 1;
    }

    return (_filteredRows.length + _pageSize - 1) ~/ _pageSize;
  }

  int get _effectiveCurrentPage {
    return _currentPage.clamp(1, _totalPages).toInt();
  }

  List<_ReservationRowData> get _pagedRows {
    if (_filteredRows.isEmpty) {
      return [];
    }

    final start = (_effectiveCurrentPage - 1) * _pageSize;
    if (start >= _filteredRows.length) {
      return [];
    }

    final end = math.min(start + _pageSize, _filteredRows.length);
    return _filteredRows.sublist(start, end);
  }

  _ReservationRowData _toRowData(ReservationResponse reservation) {
    return _ReservationRowData(
      reservationId: reservation.id,
      reservationNo: reservation.id.toString(),
      courtPitch: reservation.facility?.name ?? 'N/A',
      bookedBy: reservation.user?.username ?? 'N/A',
      bookedOn: DateHelper.toLocalDateStatic(reservation.reservationDate),
      chosenSport: reservation.chosenSport?.name ?? 'N/A',
      status: reservation.status?.split('Reservation')[0] ?? 'N/A',
      slot:
          '${_toHourMinute(reservation.startTime)} - ${_toHourMinute(reservation.endTime)}',
      price: reservation.price,
    );
  }

  String _toDateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _toHourMinute(String value) {
    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reservations',
      child: Container(
        color: const Color(0xFFF2F3F5),
        child: Row(
          children: [
            _buildSidebar(),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFFE5E7EB),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 350,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      color: const Color(0xFFF7F8FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _reservationNoSearch = value;
                _currentPage = 1;
              });
            },
            decoration: InputDecoration(
              hintText: 'Reservation No.',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 16),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 320,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: const Color(0xFF3B82F6)),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(DateTime.now().year + 1),
                calendarDelegate: GregorianCalendarDelegate(),
                onDateChanged: (value) {
                  setState(() => _selectedDate = value);
                  _loadReservations();
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Facility',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int?>(
            value: _selectedFacilityId,
            isExpanded: true,
            menuMaxHeight: 280,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            iconSize: _selectedFacilityId != null ? 0 : 24,
            decoration: InputDecoration(
              hintText: 'Facility',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 14,
              ),
              suffixIcon: _selectedFacilityId != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _selectedFacilityId = null;
                        });
                        _loadReservations();
                      },
                    )
                  : null,
            ),
            items: [
              ..._facilities.map(
                (facility) => DropdownMenuItem<int?>(
                  value: facility.id,
                  child: Text(facility.name ?? 'Facility ${facility.id}'),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedFacilityId = value);
              _loadReservations();
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReservationStatsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF12B76A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'View Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = math.max(constraints.maxWidth, _tableMinWidth);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: _buildHeaderRow(),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0F1F3),
                    ),
                    Expanded(
                      child: _filteredRows.isEmpty
                          ? const Center(
                              child: Text(
                                'No reservations found.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _pagedRows.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF0F1F3),
                              ),
                              itemBuilder: (context, index) {
                                final row = _pagedRows[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: _buildDataRow(row),
                                );
                              },
                            ),
                    ),
                    if (_filteredRows.isNotEmpty) ...[
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF0F1F3),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: UniversalPagination(
                            currentPage: _effectiveCurrentPage,
                            totalPages: _totalPages,
                            onPageChanged: (page) {
                              setState(() => _currentPage = page);
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRow() {
    const headerStyle = TextStyle(
      fontSize: 16,
      color: Color(0xFF6B7280),
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        _buildHeaderCell('#', _reservationNoFlex, headerStyle),
        _buildHeaderCell('Facility', _courtPitchFlex, headerStyle),
        _buildHeaderCell('Booked by', _bookedByFlex, headerStyle),
        _buildHeaderCell('Sport', _chosenSportFlex, headerStyle),
        _buildHeaderCell('Slot', _slotFlex, headerStyle),
        _buildHeaderCell('Price', _priceFlex, headerStyle),
        _buildHeaderCell('Booked on', _bookedOnFlex, headerStyle),
        _buildHeaderCell('Status', _statusFlex, headerStyle),
        const SizedBox(width: 64),
      ],
    );
  }

  Widget _buildDataRow(_ReservationRowData row) {
    const cellStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF111827),
      fontWeight: FontWeight.w600,
    );
    final normalizedStatus = row.status.toLowerCase();
    final isCanceled = normalizedStatus.contains('canceled');
    final isCompleted = normalizedStatus.contains('completed');

    final rowTextStyle = isCanceled
        ? cellStyle.copyWith(
            color: const Color(0xFF9CA3AF),
            decoration: TextDecoration.lineThrough,
            decorationColor: const Color(0xFF9CA3AF),
          )
        : isCompleted
        ? cellStyle.copyWith(color: const Color(0xFF065F46))
        : cellStyle;

    final rowBackgroundColor = isCanceled
        ? const Color(0xFFF3F4F6)
        : isCompleted
        ? const Color(0xFFECFDF3)
        : Colors.transparent;

    return Container(
      color: rowBackgroundColor,
      child: Row(
        children: [
          _buildDataCell(row.reservationNo, _reservationNoFlex, rowTextStyle),
          _buildDataCell(row.courtPitch, _courtPitchFlex, rowTextStyle),
          _buildDataCell(row.bookedBy, _bookedByFlex, rowTextStyle),
          _buildDataCell(row.chosenSport, _chosenSportFlex, rowTextStyle),
          _buildDataCell(row.slot, _slotFlex, rowTextStyle),
          _buildDataCell(
            CurrencyHelper.format(row.price),
            _priceFlex,
            rowTextStyle,
          ),
          _buildDataCell(row.bookedOn, _bookedOnFlex, rowTextStyle),
          _buildDataCell(row.status, _statusFlex, rowTextStyle),
          SizedBox(
            width: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: isCanceled || isCompleted
                      ? null
                      : () async {
                          final updated = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => ReservationEditScreen(
                                reservation: _reservations.firstWhere(
                                  (r) => r.id == row.reservationId,
                                ),
                              ),
                            ),
                          );

                          if (updated == true) {
                            _loadReservations();
                          }
                        },
                  tooltip: 'Edit reservation',
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  splashRadius: 18,
                  icon: Icon(
                    Icons.edit,
                    color: isCanceled || isCompleted
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF1570EF),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: isCanceled || isCompleted
                      ? null
                      : () => _cancelReservation(row.reservationId),
                  tooltip: 'Cancel reservation',
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  splashRadius: 18,
                  icon: Icon(
                    Icons.cancel,
                    color: isCanceled || isCompleted
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFFFF4405),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, int flex, TextStyle style) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataCell(String text, int flex, TextStyle style) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ReservationRowData {
  final int reservationId;
  final String reservationNo;
  final String courtPitch;
  final String bookedBy;
  final String bookedOn;
  final String chosenSport;
  final String status;
  final String slot;
  final double price;

  const _ReservationRowData({
    required this.reservationId,
    required this.reservationNo,
    required this.courtPitch,
    required this.bookedBy,
    required this.bookedOn,
    required this.chosenSport,
    required this.status,
    required this.slot,
    required this.price,
  });
}
