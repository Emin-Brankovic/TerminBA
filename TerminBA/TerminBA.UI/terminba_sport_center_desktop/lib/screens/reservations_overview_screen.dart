import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  static const int _bookedByFlex = 3;
  static const int _chosenSportFlex = 2;
  static const int _slotFlex = 2;
  static const int _priceFlex = 2;
  static const int _paymentFlex = 2;
  static const int _bookedOnFlex = 2;
  static const int _statusFlex = 2;
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

      await Future.wait([
        _loadFacilities(),
        _loadReservations(),
      ]);
    } catch (e) {
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
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelReservation(int reservationId) async {
    final reservation = _reservations.firstWhere((r) => r.id == reservationId);
    String cancelMessage = 'Are you sure you want to cancel this reservation?';
    if (reservation.isPaid == true) {
      double refundAmount = reservation.price;
      cancelMessage += '\n\nA full refund of ${refundAmount.toStringAsFixed(2)} KM will be issued to the user.';
    }

    final reasonController = TextEditingController();

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel reservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cancelMessage),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for cancellation (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4405), foregroundColor: Colors.white),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, cancel'),
            ),
          ],
        );
      },
    ) ?? false;

    if (!shouldCancel) {
      return;
    }
    
    final reason = reasonController.text.trim();

    try {
      setState(() => _isLoading = true);
      await _reservationProvider.cancelReservation(reservationId, reason);
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
      bookedBy: reservation.user?.username ?? 'Deleted User',
      bookedOn: DateHelper.toLocalDateStatic(reservation.reservationDate),
      chosenSport: reservation.chosenSport?.name ?? 'N/A',
      status: _formatStatus(reservation.status),
      slot:
          '${_toHourMinute(reservation.startTime)} - ${_toHourMinute(reservation.endTime)}',
      price: reservation.price,
      paymentMethod: _formatPaymentMethod(reservation.paymentMethod),
      cancellationReason: reservation.cancellationReason,
      canceledAt: reservation.canceledAt,
      canceledByUserId: reservation.canceledByUserId,
      canceledBySportCenterId: reservation.canceledBySportCenterId,
      completedAt: reservation.completedAt,
    );
  }

  String _formatStatus(String? status) {
    if (status == null) return 'N/A';
    if (status == 'CanceledWithRefundReservationState' ||
        status == 'CanceledWithoutRefundReservationState' ||
        status == 'CancelledReservationState' ||
        status == 'CanceledReservationState' ||
        status == 'Cancelled' ||
        status == 'Canceled') {
      return 'Canceled';
    }
    return status.split('Reservation')[0];
  }

  String _formatPaymentMethod(String? method) {
    if (method == null || method.trim().isEmpty) return 'N/A';
    if (method.toLowerCase() == 'stripe') return 'Online';
    if (method.toLowerCase() == 'onsite') return 'On site';
    return method;
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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
                  borderRadius: BorderRadius.circular(10),
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
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: _buildHeaderRow(),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                    Expanded(
                      child: _filteredRows.isEmpty
                          ? const Center(
                              child: Text(
                                'No reservations found.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _pagedRows.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              itemBuilder: (context, index) {
                                final row = _pagedRows[index];
                                return _buildDataRow(row);
                              },
                            ),
                    ),
                    if (_filteredRows.isNotEmpty) ...[
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
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
      fontSize: 11.5,
      color: Color(0xFF475569),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );

    return Row(
      children: [
        _buildHeaderCell('#', _reservationNoFlex, headerStyle),
        _buildHeaderCell('FACILITY', _courtPitchFlex, headerStyle),
        _buildHeaderCell('BOOKED BY', _bookedByFlex, headerStyle),
        _buildHeaderCell('SPORT', _chosenSportFlex, headerStyle),
        _buildHeaderCell('SLOT', _slotFlex, headerStyle),
        _buildHeaderCell('PRICE', _priceFlex, headerStyle),
        _buildHeaderCell('PAYMENT', _paymentFlex, headerStyle),
        _buildHeaderCell('BOOKED ON', _bookedOnFlex, headerStyle),
        _buildHeaderCell('STATUS', _statusFlex, headerStyle),
        const SizedBox(width: 104),
      ],
    );
  }

  Widget _buildDataRow(_ReservationRowData row) {
    final normalizedStatus = row.status.toLowerCase();
    final isCanceled = normalizedStatus.contains('canceled') || normalizedStatus.contains('cancelled');
    final isCompleted = normalizedStatus.contains('completed');
    final isPending = normalizedStatus.contains('pending');

    final Color leftBorderColor;
    final Color rowBackgroundColor;

    if (isCanceled) {
      leftBorderColor = const Color(0xFFEF4444);
      rowBackgroundColor = const Color(0xFFFFF1F2);
    } else if (isCompleted) {
      leftBorderColor = const Color(0xFF3B82F6);
      rowBackgroundColor = const Color(0xFFF8FAFC);
    } else if (isPending) {
      leftBorderColor = const Color(0xFFF59E0B);
      rowBackgroundColor = const Color(0xFFFFFDF5);
    } else {
      // Active / Confirmed
      leftBorderColor = const Color(0xFF10B981);
      rowBackgroundColor = Colors.white;
    }

    final Color facilityColor = isCanceled
        ? const Color(0xFF94A3B8)
        : isCompleted
            ? const Color(0xFF334155)
            : const Color(0xFF0F172A);

    final Color bookedByColor = isCanceled
        ? const Color(0xFF94A3B8)
        : isCompleted
            ? const Color(0xFF334155)
            : const Color(0xFF1E293B);

    final Color slotColor = isCanceled
        ? const Color(0xFF94A3B8)
        : isCompleted
            ? const Color(0xFF475569)
            : const Color(0xFF0F172A);

    final Color priceColor = isCanceled
        ? const Color(0xFF94A3B8)
        : isCompleted
            ? const Color(0xFF047857)
            : const Color(0xFF059669);

    return Container(
      decoration: BoxDecoration(
        color: rowBackgroundColor,
        border: Border(
          left: BorderSide(
            color: leftBorderColor,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 11, 14, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Reservation No
          Expanded(
            flex: _reservationNoFlex,
            child: Text(
              '#${row.reservationNo}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isCanceled ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          // Facility
          Expanded(
            flex: _courtPitchFlex,
            child: Text(
              row.courtPitch,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: facilityColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Booked by
          Expanded(
            flex: _bookedByFlex,
            child: Text(
              row.bookedBy,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: bookedByColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Chosen sport
          Expanded(
            flex: _chosenSportFlex,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isCanceled ? const Color(0xFFF1F5F9) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isCanceled ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Text(
                  row.chosenSport,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCanceled ? const Color(0xFF94A3B8) : const Color(0xFF1D4ED8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Slot
          Expanded(
            flex: _slotFlex,
            child: Text(
              row.slot,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: slotColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Price
          Expanded(
            flex: _priceFlex,
            child: Text(
              CurrencyHelper.format(row.price),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: priceColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Payment
          Expanded(
            flex: _paymentFlex,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildPaymentBadge(row.paymentMethod),
            ),
          ),
          // Booked on
          Expanded(
            flex: _bookedOnFlex,
            child: Text(
              row.bookedOn,
              style: TextStyle(
                fontSize: 13.5,
                color: isCanceled ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Status
          Expanded(
            flex: _statusFlex,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(row.status),
            ),
          ),
          // Actions
          SizedBox(
            width: 104,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isCanceled || isCompleted ? const Color(0xFFF1F5F9) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCanceled || isCompleted ? const Color(0xFFE2E8F0) : const Color(0xFFDBEAFE),
                    ),
                  ),
                  child: IconButton(
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
                    iconSize: 15,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: isCanceled || isCompleted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: isCanceled || isCompleted ? const Color(0xFFF1F5F9) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCanceled || isCompleted ? const Color(0xFFE2E8F0) : const Color(0xFFFECACA),
                    ),
                  ),
                  child: IconButton(
                    onPressed: isCanceled || isCompleted
                        ? null
                        : () => _cancelReservation(row.reservationId),
                    tooltip: 'Cancel reservation',
                    iconSize: 15,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: isCanceled || isCompleted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
                if (isCanceled || isCompleted) ...[
                  const SizedBox(width: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      onPressed: () {
                        String auditInfo = '';
                        final df = DateFormat('dd.MM.yyyy HH:mm:ss');
                        if (isCanceled) {
                          if (row.canceledAt != null) auditInfo += 'Canceled At: ${df.format(row.canceledAt!.toLocal())}\n';
                          
                          if (row.canceledByUserId != null) {
                            auditInfo += 'Canceled By: User\n';
                          } else if (row.canceledBySportCenterId != null) {
                            auditInfo += 'Canceled By: Sport Center\n';
                          }
                          
                          if (row.cancellationReason != null && row.cancellationReason!.isNotEmpty) {
                            auditInfo += 'Reason: ${row.cancellationReason}\n';
                          } else {
                            auditInfo += 'Reason: Not provided\n';
                          }
                        } else if (isCompleted) {
                          if (row.completedAt != null) auditInfo += 'Completed At: ${df.format(row.completedAt!.toLocal())}\n';
                        }

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Audit Log Details'),
                              content: Text(auditInfo),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      tooltip: 'View Audit Log',
                      iconSize: 15,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String method) {
    final isCard = method.toLowerCase().contains('stripe') || method.toLowerCase().contains('card');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isCard ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: isCard ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
      ),
      child: Text(
        method,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCard ? const Color(0xFF15803D) : const Color(0xFF475569),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFF1F5F9);
    Color border = const Color(0xFFE2E8F0);
    Color text = const Color(0xFF475569);

    if (s.contains('active') || s.contains('confirmed')) {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFFA7F3D0);
      text = const Color(0xFF047857);
    } else if (s.contains('pending')) {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      text = const Color(0xFFB45309);
    } else if (s.contains('completed')) {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFFBFDBFE);
      text = const Color(0xFF1D4ED8);
    } else if (s.contains('canceled') || s.contains('cancelled')) {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      text = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
  final String paymentMethod;
  final String? cancellationReason;
  final DateTime? canceledAt;
  final int? canceledByUserId;
  final int? canceledBySportCenterId;
  final DateTime? completedAt;

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
    required this.paymentMethod,
    this.cancellationReason,
    this.canceledAt,
    this.canceledByUserId,
    this.canceledBySportCenterId,
    this.completedAt,
  });
}
