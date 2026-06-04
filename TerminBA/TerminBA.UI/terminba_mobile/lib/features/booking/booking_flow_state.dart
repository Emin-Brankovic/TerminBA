import 'package:terminba_mobile/enums/day_of_week_enum.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_time_slot.dart';
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/model/sport.dart';

enum PaymentMethod { onSite, online }

/// Accumulates all booking data across the 5-screen booking flow.
///
/// Passed via [ChangeNotifierProvider] from [CourtSelectionScreen] onward.
/// Do NOT use global mutable singletons — each flow creates a fresh notifier.
class BookingFlowState {
  // ── Facility / sport context ────────────────────────────────────────────
  final int sportCenterId;
  final String sportCenterName;
  final String sportCenterAddress;
  final Sport? sport;
  final DateTime initialDate;

  // ── Selected court (= Facility) ─────────────────────────────────────────
  final Facility? selectedCourt;

  // ── Selected date + time slot ────────────────────────────────────────────
  final DateTime? selectedDate;
  final FacilityTimeSlot? selectedTimeSlot;

  // ── Payment ──────────────────────────────────────────────────────────────
  final PaymentMethod paymentMethod;
  final String notes;

  // ── Pricing ──────────────────────────────────────────────────────────────
  final double totalPrice;

  // ── Async ────────────────────────────────────────────────────────────────
  final bool isLoadingCourts;
  final bool isLoadingSlots;
  final bool isSubmitting;
  final String? error;

  // ── Loaded data ──────────────────────────────────────────────────────────
  final List<Facility> courts;
  final List<FacilityTimeSlot> timeSlots;

  // ── Availability cache (lazily populated) ───────────────────────────────
  /// Dates ("yyyy-MM-dd") that have been checked and found fully booked.
  final Set<String> fullyBookedDates;

  // ── Result after booking ─────────────────────────────────────────────────
  final ReservationResponse? bookingConfirmation;

  const BookingFlowState({
    required this.sportCenterId,
    required this.sportCenterName,
    required this.sportCenterAddress,
    this.sport,
    required this.initialDate,
    this.selectedCourt,
    this.selectedDate,
    this.selectedTimeSlot,
    this.paymentMethod = PaymentMethod.onSite,
    this.notes = '',
    this.totalPrice = 0.0,
    this.isLoadingCourts = false,
    this.isLoadingSlots = false,
    this.isSubmitting = false,
    this.error,
    this.courts = const [],
    this.timeSlots = const [],
    this.fullyBookedDates = const {},
    this.bookingConfirmation,
  });

  factory BookingFlowState.initial({
    required int sportCenterId,
    required String sportCenterName,
    required String sportCenterAddress,
    required Sport sport,
    required DateTime initialDate,
  }) {
    return BookingFlowState(
      sportCenterId: sportCenterId,
      sportCenterName: sportCenterName,
      sportCenterAddress: sportCenterAddress,
      sport: sport,
      initialDate: initialDate,
    );
  }

  BookingFlowState copyWith({
    int? sportCenterId,
    String? sportCenterName,
    String? sportCenterAddress,
    Sport? sport,
    DateTime? initialDate,
    Facility? selectedCourt,
    bool clearSelectedCourt = false,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    FacilityTimeSlot? selectedTimeSlot,
    bool clearSelectedTimeSlot = false,
    PaymentMethod? paymentMethod,
    String? notes,
    double? totalPrice,
    bool? isLoadingCourts,
    bool? isLoadingSlots,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    List<Facility>? courts,
    List<FacilityTimeSlot>? timeSlots,
    Set<String>? fullyBookedDates,
    ReservationResponse? bookingConfirmation,
    bool clearBookingConfirmation = false,
  }) {
    return BookingFlowState(
      sportCenterId: sportCenterId ?? this.sportCenterId,
      sportCenterName: sportCenterName ?? this.sportCenterName,
      sportCenterAddress: sportCenterAddress ?? this.sportCenterAddress,
      sport: sport ?? this.sport,
      initialDate: initialDate ?? this.initialDate,
      selectedCourt: clearSelectedCourt ? null : selectedCourt ?? this.selectedCourt,
      selectedDate: clearSelectedDate ? null : selectedDate ?? this.selectedDate,
      selectedTimeSlot:
          clearSelectedTimeSlot ? null : selectedTimeSlot ?? this.selectedTimeSlot,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
      isLoadingCourts: isLoadingCourts ?? this.isLoadingCourts,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      courts: courts ?? this.courts,
      timeSlots: timeSlots ?? this.timeSlots,
      fullyBookedDates: fullyBookedDates ?? this.fullyBookedDates,
      bookingConfirmation:
          clearBookingConfirmation ? null : bookingConfirmation ?? this.bookingConfirmation,
    );
  }

  /// Effective price for the slot (static price from court, dynamic price if configured, or 0).
  double get slotPrice {
    final court = selectedCourt;
    if (court == null) return 0.0;

    if (!court.isDynamicPricing) {
      return court.staticPrice?.toDouble() ?? 0.0;
    }

    final date = selectedDate;
    final slot = selectedTimeSlot;
    if (date == null || slot == null) {
      return 0.0;
    }

    return getDynamicPriceFor(court, date, slot);
  }

  /// The grand total (now just the slot price).
  double get grandTotal => slotPrice;

  /// Helper to calculate the dynamic price for a specific slot on a specific date.
  double getDynamicPriceFor(Facility court, DateTime date, FacilityTimeSlot slot) {
    if (court.dynamicPrices.isEmpty) {
      return court.staticPrice?.toDouble() ?? 0.0;
    }

    double parseTimeToDouble(String timeStr) {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = parts.length >= 3 ? (int.tryParse(parts[2].split('.')[0]) ?? 0) : 0;
        return hours + (minutes / 60.0) + (seconds / 3600.0);
      }
      return 0.0;
    }

    // 1. Get DayOfWeek of date
    DayOfWeek targetDay;
    switch (date.weekday) {
      case DateTime.monday:
        targetDay = DayOfWeek.monday;
        break;
      case DateTime.tuesday:
        targetDay = DayOfWeek.tuesday;
        break;
      case DateTime.wednesday:
        targetDay = DayOfWeek.wednesday;
        break;
      case DateTime.thursday:
        targetDay = DayOfWeek.thursday;
        break;
      case DateTime.friday:
        targetDay = DayOfWeek.friday;
        break;
      case DateTime.saturday:
        targetDay = DayOfWeek.saturday;
        break;
      case DateTime.sunday:
        targetDay = DayOfWeek.sunday;
        break;
      default:
        targetDay = DayOfWeek.monday;
    }

    // Helper for day range check
    bool isInDayRange(DayOfWeek target, DayOfWeek start, DayOfWeek end) {
      final t = target.index;
      final s = start.index;
      final e = end.index;
      if (s <= e) {
        return t >= s && t <= e;
      } else {
        return t >= s || t <= e;
      }
    }

    // Helper for validity period check
    bool isWithinValidityPeriod(DateTime resDate, DateTime validFrom, DateTime? validTo) {
      final rDate = DateTime(resDate.year, resDate.month, resDate.day);
      final from = DateTime(validFrom.year, validFrom.month, validFrom.day);
      if (rDate.isBefore(from)) return false;
      if (validTo != null) {
        final to = DateTime(validTo.year, validTo.month, validTo.day);
        if (rDate.isAfter(to)) return false;
      }
      return true;
    }

    final slotStart = parseTimeToDouble(slot.startTime);
    final slotEnd = parseTimeToDouble(slot.endTime);

    for (final dp in court.dynamicPrices) {
      final dpStart = parseTimeToDouble(dp.startTime);
      final dpEnd = parseTimeToDouble(dp.endTime);

      if (isInDayRange(targetDay, dp.startDay, dp.endDay) &&
          isWithinValidityPeriod(date, dp.validFrom, dp.validTo) &&
          dpStart <= slotStart &&
          dpEnd >= slotEnd) {
        return dp.pricePerHour;
      }
    }

    // Fallback to static price if no matching dynamic price rule is found
    return court.staticPrice?.toDouble() ?? 0.0;
  }
}
