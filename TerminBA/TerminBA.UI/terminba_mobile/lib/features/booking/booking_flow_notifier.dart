import 'package:flutter/material.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_time_slot.dart';
import 'package:terminba_mobile/model/reservation_insert_request.dart';
import 'package:terminba_mobile/providers/facility_provider.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';

class BookingFlowNotifier extends ChangeNotifier {
  BookingFlowNotifier({
    required BookingFlowState initialState,
    required FacilityProvider facilityProvider,
    required ReservationProvider reservationProvider,
  })  : _state = initialState,
        _facilityProvider = facilityProvider,
        _reservationProvider = reservationProvider;

  BookingFlowState _state;
  final FacilityProvider _facilityProvider;
  final ReservationProvider _reservationProvider;

  BookingFlowState get state => _state;

  // ── Court loading ─────────────────────────────────────────────────────────

  Future<void> loadCourts() async {
    _setState(_state.copyWith(isLoadingCourts: true, clearError: true));
    var filter = <String, dynamic>{
      'sportCenterId': _state.sportCenterId,
      'sportId': _state.sport?.id,
    };
    try {
      final result = await _facilityProvider.get(filter: filter);
      _setState(_state.copyWith(courts: result.items, isLoadingCourts: false));
    } on Exception catch (e) {
      _setState(_state.copyWith(
        isLoadingCourts: false,
        error: _messageFrom(e),
      ));
    }
  }

  // ── Court selection ───────────────────────────────────────────────────────

  void selectCourt(Facility court) {
    final price = court.staticPrice?.toDouble() ?? 0.0;
    _setState(_state.copyWith(
      selectedCourt: court,
      totalPrice: price,
      clearError: true,
    ));
  }

  // ── Date selection + time slot loading ───────────────────────────────────

  Future<void> selectDate(DateTime date) async {
    _setState(_state.copyWith(
      selectedDate: date,
      clearSelectedTimeSlot: true,
      isLoadingSlots: true,
      clearError: true,
    ));
    await _loadTimeSlots(date);
  }

  Future<void> _loadTimeSlots(DateTime date) async {
    final courtId = _state.selectedCourt?.id;
    if (courtId == null) return;

    try {
      final slots = await _facilityProvider.getTimeSlots(
        facilityId: courtId,
        date: date,
      );

      // Update the lazily-populated fully-booked-dates cache.
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final isFullyBooked = slots.isNotEmpty && slots.every((s) => !s.isFree);
      final updatedCache = Set<String>.from(_state.fullyBookedDates);
      if (isFullyBooked) {
        updatedCache.add(dateKey);
      } else {
        updatedCache.remove(dateKey);
      }

      _setState(_state.copyWith(
        timeSlots: slots,
        isLoadingSlots: false,
        fullyBookedDates: updatedCache,
      ));
    } on Exception catch (e) {
      _setState(_state.copyWith(
        isLoadingSlots: false,
        error: _messageFrom(e),
      ));
    }
  }

  // ── Time slot selection ───────────────────────────────────────────────────

  void selectTimeSlot(FacilityTimeSlot slot) {
    _setState(_state.copyWith(
      selectedTimeSlot: slot,
      clearError: true,
    ));
  }

  // ── Payment + notes ───────────────────────────────────────────────────────

  void setPaymentMethod(PaymentMethod method) {
    _setState(_state.copyWith(paymentMethod: method));
  }

  void setNotes(String notes) {
    _setState(_state.copyWith(notes: notes));
  }

  // ── Booking submission ────────────────────────────────────────────────────

  /// Submits the booking via `POST /api/Reservation`.
  ///
  /// On success: sets [BookingFlowState.bookingConfirmation].
  /// On failure: sets [BookingFlowState.error].
  Future<void> submitBooking({required int userId}) async {
    final court = _state.selectedCourt;
    final date = _state.selectedDate;
    final slot = _state.selectedTimeSlot;

    if (court == null || date == null || slot == null) {
      _setState(_state.copyWith(error: 'Incomplete booking details.'));
      return;
    }

    _setState(_state.copyWith(isSubmitting: true, clearError: true));

    try {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Ensure times are in HH:MM:SS format
      final startTime = _ensureSeconds(slot.startTime);
      final endTime = _ensureSeconds(slot.endTime);

      final request = ReservationInsertRequest(
        userId: userId,
        facilityId: court.id,
        reservationDate: dateString,
        startTime: startTime,
        endTime: endTime,
        price: _state.grandTotal,
        chosenSportId: _state.sport?.id,
      );

      final confirmation = await _reservationProvider.insert(request);
      _setState(_state.copyWith(
        isSubmitting: false,
        bookingConfirmation: confirmation,
      ));
    } on Exception catch (e) {
      _setState(_state.copyWith(
        isSubmitting: false,
        error: _messageFrom(e),
      ));
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _setState(BookingFlowState newState) {
    _state = newState;
    notifyListeners();
  }

  String _messageFrom(Exception e) {
    final msg = e.toString().replaceAll('Exception:', '').trim();
    return msg.isEmpty ? 'Something went wrong.' : msg;
  }

  String _ensureSeconds(String time) {
    // "HH:MM" → "HH:MM:00"; "HH:MM:SS" stays as-is
    final parts = time.split(':');
    if (parts.length == 2) return '$time:00';
    return time;
  }
}
