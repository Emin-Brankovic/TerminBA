import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/enums/day_of_week_enum.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_dynamic_price.dart';
import 'package:terminba_mobile/model/facility_time_slot.dart';
import 'package:terminba_mobile/screens/booking/booking_summary_screen.dart';
import 'package:intl/intl.dart';

/// Screen 3: Inline calendar + time slot chips.
///
/// Receives [BookingFlowNotifier] from the ancestor [ChangeNotifierProvider].
class DateTimeSlotScreen extends StatefulWidget {
  const DateTimeSlotScreen({super.key});

  @override
  State<DateTimeSlotScreen> createState() => _DateTimeSlotScreenState();
}

class _DateTimeSlotScreenState extends State<DateTimeSlotScreen> {
  // Displayed month/year in the calendar
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final notifier = context.read<BookingFlowNotifier>();
    final initialDate = notifier.state.selectedDate ?? notifier.state.initialDate;
    _visibleMonth = DateTime(initialDate.year, initialDate.month);
    // Auto-select initial date to pre-load slots
    if (notifier.state.selectedDate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.selectDate(initialDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingFlowNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;
        final courtName = state.selectedCourt?.name ?? 'Court';
        final dateLabel = state.selectedDate != null
            ? DateFormat('d MMM').format(state.selectedDate!)
            : DateFormat('d MMM').format(state.initialDate);

        final canProceed =
            state.selectedDate != null && state.selectedTimeSlot != null;

        return Scaffold(
          appBar: AppBar(
            title: Text('${state.sportCenterName} $courtName ($dateLabel)'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildCalendar(state, notifier),
                const Divider(height: 1),
                if (state.selectedCourt != null)
                  _buildPricingInfo(state.selectedCourt!),
                const SizedBox(height: 16),
                _buildSlotSection(state, notifier),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context, state, notifier, canProceed),
        );
      },
    );
  }

  Widget _buildPricingInfo(Facility court) {
    if (!court.isDynamicPricing || court.dynamicPrices.isEmpty) {
      return const SizedBox.shrink();
    }

    String formatDayOfWeek(DayOfWeek day) {
      final name = day.name;
      if (name.isEmpty) return '';
      return name[0].toUpperCase() + name.substring(1);
    }

    String formatTime(String time) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.sell_outlined, size: 16, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'Pricing Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...court.dynamicPrices.map((dp) {
            final days = dp.startDay == dp.endDay
                ? formatDayOfWeek(dp.startDay)
                : '${formatDayOfWeek(dp.startDay)} - ${formatDayOfWeek(dp.endDay)}';
            final times = '${formatTime(dp.startTime)} - ${formatTime(dp.endTime)}';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$days ($times)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${dp.pricePerHour.toStringAsFixed(0)} KM',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ── Calendar ──────────────────────────────────────────────────────────────

  Widget _buildCalendar(BookingFlowState state, BookingFlowNotifier notifier) {
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // Mon=1 … Sun=7

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _visibleMonth =
                        DateTime(_visibleMonth.year, _visibleMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_visibleMonth),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _visibleMonth =
                        DateTime(_visibleMonth.year, _visibleMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          // Day-of-week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: (startWeekday - 1) + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday - 1) {
                return const SizedBox.shrink();
              }
              final day = index - (startWeekday - 1) + 1;
              final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
              final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected = state.selectedDate != null &&
                  state.selectedDate!.year == date.year &&
                  state.selectedDate!.month == date.month &&
                  state.selectedDate!.day == date.day;

              // Check if this date is fully booked (lazily cached).
              final dateKey =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final isFullyBooked =
                  !isPast && state.fullyBookedDates.contains(dateKey);

              final isDisabled = isPast || isFullyBooked;

              // Determine circle fill color.
              Color circleColor;
              if (isSelected) {
                circleColor = const Color(0xFF4CAF50);
              } else if (isFullyBooked) {
                circleColor = const Color.fromARGB(60, 177, 177, 177); // light grey tint
              } else {
                circleColor = Colors.transparent;
              }

              // Determine text color.
              Color textColor;
              if (isSelected) {
                textColor = Colors.white;
              } else if (isPast) {
                textColor = Colors.grey.shade400;
              } else if (isFullyBooked) {
                textColor = const Color.fromARGB(255, 177, 177, 177); // same grey as booked chips
              } else {
                textColor = const Color(0xFF212121);
              }

              return Semantics(
                label: DateFormat('EEEE, d MMMM yyyy').format(date) +
                    (isPast ? ', unavailable' : '') +
                    (isFullyBooked ? ', fully booked' : '') +
                    (isSelected ? ', selected' : ''),
                button: !isDisabled,
                child: GestureDetector(
                  onTap: isDisabled ? null : () => notifier.selectDate(date),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border: isToday && !isSelected
                            ? Border.all(color: const Color(0xFF4CAF50), width: 1.5)
                            : isFullyBooked && !isSelected
                                ? Border.all(
                                    color: const Color.fromARGB(255, 177, 177, 177), width: 1)
                                : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              color: textColor,
                            ),
                          ),
                          // Small dot indicator at bottom for fully booked.
                          if (isFullyBooked && !isSelected)
                            Positioned(
                              bottom: 3,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 177, 177, 177),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Time slot chips ───────────────────────────────────────────────────────

  Widget _buildSlotSection(BookingFlowState state, BookingFlowNotifier notifier) {
    if (state.selectedDate == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Select a date to see available slots.',
          style: TextStyle(color: Color(0xFF757575)),
        ),
      );
    }

    if (state.isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
      );
    }

    final freeSlots = state.timeSlots.where((s) => s.isFree).toList();

    if (state.timeSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No available slots for this date.',
          style: TextStyle(color: Color(0xFF757575)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            freeSlots.isEmpty ? 'Time Slots' : 'Available Slots',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          if (freeSlots.isEmpty) ...[
            const Text(
              'All slots are booked for this date.',
              style: TextStyle(color: Color(0xFF757575), fontSize: 13),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.timeSlots.map((slot) {
              final isAvailable = slot.isFree;
              final isSelected = state.selectedTimeSlot?.startTime == slot.startTime &&
                  state.selectedTimeSlot?.endTime == slot.endTime;

              final showPrice = state.selectedCourt?.isDynamicPricing == true && state.selectedDate != null;
              final dynamicPriceVal = showPrice
                  ? state.getDynamicPriceFor(state.selectedCourt!, state.selectedDate!, slot)
                  : 0.0;

              return Semantics(
                label: '${slot.label}, ${isAvailable ? 'available' : 'booked, unavailable'}' +
                    (showPrice ? ', ${dynamicPriceVal.toStringAsFixed(0)} KM' : ''),
                button: isAvailable,
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        slot.label,
                        style: TextStyle(
                          color: isAvailable
                              ? (isSelected ? Colors.white : const Color(0xFF4CAF50))
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (showPrice) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${dynamicPriceVal.toStringAsFixed(0)} KM',
                          style: TextStyle(
                            color: isAvailable
                                ? (isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF4CAF50).withOpacity(0.8))
                                : Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: isAvailable
                      ? (_) => notifier.selectTimeSlot(slot)
                      : null,
                  selectedColor: const Color(0xFF4CAF50),
                  backgroundColor: isAvailable
                      ? Colors.white
                      : const Color(0xFFE53935),
                  disabledColor: const Color.fromARGB(166, 177, 177, 177),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isAvailable
                          ? (isSelected
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF4CAF50))
                          : const Color.fromARGB(255, 177, 177, 177),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFF4CAF50), label: 'Available'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color.fromARGB(255, 177, 177, 177), label: 'Booked'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    BookingFlowState state,
    BookingFlowNotifier notifier,
    bool canProceed,
  ) {
    final priceLabel = state.selectedTimeSlot != null
        ? '${state.grandTotal.toStringAsFixed(0)} KM'
        : (state.selectedCourt?.isDynamicPricing == true
            ? 'Dynamic Pricing'
            : '${state.selectedCourt?.staticPrice?.toStringAsFixed(0) ?? '0'} KM');

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Text(
              priceLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF212121),
              ),
            ),
            const Spacer(),
            Semantics(
              label: 'Proceed, $priceLabel',
              button: true,
              enabled: canProceed,
              child: ElevatedButton(
                onPressed: canProceed
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: notifier,
                              child: const BookingSummaryScreen(),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canProceed ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'PROCEED →',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
      ],
    );
  }
}
