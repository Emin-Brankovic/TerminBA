import 'package:flutter/material.dart';
import 'package:terminba_mobile/widgets/confirmation_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/enums/day_of_week_enum.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_time_slot.dart';
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/model/reservation_update_request.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/facility_provider.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';

class ReservationEditScreen extends StatefulWidget {
  final ReservationResponse reservation;

  const ReservationEditScreen({super.key, required this.reservation});

  @override
  State<ReservationEditScreen> createState() => _ReservationEditScreenState();
}

class _ReservationEditScreenState extends State<ReservationEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _priceController = TextEditingController();

  late ReservationProvider _reservationProvider;
  late FacilityProvider _facilityProvider;

  bool _initialized = false;
  bool _isLoading = true;
  bool _isSaving = false;

  int? _sportCenterId;
  int? _selectedFacilityId;
  int? _selectedSportId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _status = '';

  final List<Facility> _facilities = [];
  List<Sport> _availableSports = [];
  final List<FacilityTimeSlot> _availableTimeSlots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;
    _reservationProvider = context.read<ReservationProvider>();
    _facilityProvider = context.read<FacilityProvider>();
    _initializeData();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      final reservation = widget.reservation;
      _sportCenterId = reservation.facility?.sportCenterId;

      _selectedFacilityId = reservation.facilityId;
      _selectedSportId = reservation.chosenSportId;
      _selectedDate = reservation.reservationDate != null ? (DateTime.tryParse(reservation.reservationDate!) ?? DateTime.now()) : DateTime.now();
      _startTime = _parseTimeOfDay(reservation.startTime ?? '00:00:00');
      _endTime = _parseTimeOfDay(reservation.endTime ?? '00:00:00');
      _status = reservation.status ?? '';
      _priceController.text = (reservation.price ?? 0).toStringAsFixed(2);

      await _loadFacilities();
      _syncAvailableSportsWithSelectedFacility();
      await _loadAvailableTimeSlots();
      _updateDynamicPrice();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading reservation: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadFacilities() async {
    final result = await _facilityProvider.get(
      filter: {
        if (_sportCenterId != null) 'sportCenterId': _sportCenterId,
        'page': 1,
      },
    );

    final facilities = result.items ?? [];
    _facilities
      ..clear()
      ..addAll(facilities);

    if (_selectedFacilityId == null && _facilities.isNotEmpty) {
      _selectedFacilityId = _facilities.first.id;
    }
  }

  void _updateDynamicPrice() {
    if (_selectedFacilityId == null || _startTime == null || _endTime == null) {
      return;
    }

    try {
      final facility = _facilities.firstWhere((f) => f.id == _selectedFacilityId);
      final price = _getDynamicPriceFor(facility, _selectedDate, _startTime!, _endTime!);

      if (!mounted) return;
      setState(() {
        _priceController.text = price.toStringAsFixed(2);
      });
    } catch (e) {
      // Ignored
    }
  }

  double _getDynamicPriceFor(Facility court, DateTime date, TimeOfDay start, TimeOfDay end) {
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

    bool isInDayRange(DayOfWeek target, DayOfWeek startD, DayOfWeek endD) {
      final t = target.index;
      final s = startD.index;
      final e = endD.index;
      if (s <= e) {
        return t >= s && t <= e;
      } else {
        return t >= s || t <= e;
      }
    }

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

    final slotStart = start.hour + start.minute / 60.0;
    final slotEnd = end.hour + end.minute / 60.0;

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

    return court.staticPrice?.toDouble() ?? 0.0;
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedFacilityId == null) {
      if (!mounted) return;
      setState(() {
        _availableTimeSlots.clear();
        _startTime = null;
        _endTime = null;
      });
      return;
    }

    try {
      final result = await _facilityProvider.getTimeSlots(
        facilityId: _selectedFacilityId!,
        date: _selectedDate,
      );

      if (!mounted) return;
      setState(() {
        _availableTimeSlots
          ..clear()
          ..addAll(result);

        final hasSelectedSlot = _availableTimeSlots.any(
          (slot) => _isSlotSelected(slot),
        );

        if (!hasSelectedSlot) {
          final firstFree = _availableTimeSlots
              .where((slot) => slot.isFree)
              .firstOrNull;
          if (firstFree != null) {
            _startTime = _parseTimeOfDay(firstFree.startTime);
            _endTime = _parseTimeOfDay(firstFree.endTime);
          }
        }
      });
      _updateDynamicPrice();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _availableTimeSlots.clear();
        _startTime = null;
        _endTime = null;
      });

      _priceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading time slots: ${e.toString().split(":").last}',
          ),
        ),
      );
    }
  }

  void _syncAvailableSportsWithSelectedFacility() {
    final selectedFacility = _facilities
        .where((f) => f.id == _selectedFacilityId)
        .firstOrNull;

    _availableSports = selectedFacility?.availableSports ?? [];

    if (_selectedSportId != null &&
        !_availableSports.any((sport) => sport.id == _selectedSportId)) {
      _selectedSportId = _availableSports.isNotEmpty
          ? _availableSports.first.id
          : null;
    }

    if (_selectedSportId == null && _availableSports.isNotEmpty) {
      _selectedSportId = _availableSports.first.id;
    }
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatApiTime(TimeOfDay value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  String _formatUiTime(TimeOfDay value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  bool _isSlotSelected(FacilityTimeSlot slot) {
    if (_startTime == null || _endTime == null) {
      return false;
    }

    final slotStart = _parseTimeOfDay(slot.startTime);
    final slotEnd = _parseTimeOfDay(slot.endTime);
    return slotStart.hour == _startTime!.hour &&
        slotStart.minute == _startTime!.minute &&
        slotEnd.hour == _endTime!.hour &&
        slotEnd.minute == _endTime!.minute;
  }

  String _formatSlotLabel(FacilityTimeSlot slot) {
    final start = _formatUiTime(_parseTimeOfDay(slot.startTime));
    final end = _formatUiTime(_parseTimeOfDay(slot.endTime));
    return '$start - $end';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });

    await _loadAvailableTimeSlots();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    if (_selectedFacilityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a facility.')),
      );
      return;
    }

    if (_selectedSportId == null && _availableSports.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a sport.')));
      return;
    }

    if (_availableTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No time slots are available for selected date.'),
        ),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }

    final parsedPrice = double.parse(
      _priceController.text.replaceAll(',', '.'),
    );

    final originalPrice = widget.reservation.price ?? 0.0;
    
    String priceMessage = '';
    if (widget.reservation.isPaid == true) {
      if (parsedPrice > originalPrice) {
        final diff = parsedPrice - originalPrice;
        priceMessage = ' An extra charge of ${diff.toStringAsFixed(2)} KM will be made to the card on which you made the reservation.';
      } else if (parsedPrice < originalPrice) {
        double refundAmount = originalPrice - parsedPrice;
        if (widget.reservation.cancellationDeadline != null && widget.reservation.cancellationDeadline!.isBefore(DateTime.now().toUtc())) {
          refundAmount = refundAmount * 0.3;
        }
        priceMessage = ' A refund of ${refundAmount.toStringAsFixed(2)} KM will be issued to the card on which you made the reservation.';
      }
    }

    bool? confirm = await ConfirmationDialog.show(
      context,
      title: 'Confirm Changes',
      message: 'Are you sure you want to save these changes?$priceMessage',
      confirmText: 'Yes, save',
      cancelText: 'Cancel',
    );

    if (confirm != true) {
      return;
    }

    final request = ReservationUpdateRequest(
      facilityId: _selectedFacilityId,
      reservationDate: _selectedDate,
      startTime: _formatApiTime(_startTime!),
      endTime: _formatApiTime(_endTime!),
      status: _status,
      price: parsedPrice,
      chosenSportId: _selectedSportId,
    );

    setState(() => _isSaving = true);

    try {
      await _reservationProvider.update(
        widget.reservation.id,
        request.toJson(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation updated successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating reservation: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Edit Reservation #${widget.reservation.id}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    color: const Color(0xFFFDFDFD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(26),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            FormBuilderDropdown<int>(
                              name: 'facilityId',
                              initialValue: _selectedFacilityId,
                              decoration: _inputDecoration('Facility*'),
                              items: _facilities
                                  .map(
                                    (facility) => DropdownMenuItem<int>(
                                      value: facility.id,
                                      child: Text(
                                        facility.name ??
                                            'Facility ${facility.id}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedFacilityId = value;
                                  _syncAvailableSportsWithSelectedFacility();
                                });

                                _formKey.currentState?.fields['sportId']
                                    ?.didChange(_selectedSportId);
                                _loadAvailableTimeSlots();
                              },
                              validator: FormBuilderValidators.required(
                                errorText: 'Facility is required.',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderDropdown<int>(
                              name: 'sportId',
                              initialValue: _selectedSportId,
                              decoration: _inputDecoration('Sport*'),
                              items: _availableSports
                                  .map(
                                    (sport) => DropdownMenuItem<int>(
                                      value: sport.id,
                                      child: Text(
                                        sport.name ?? 'Sport ${sport.id}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedSportId = value);
                              },
                              validator: (_) {
                                if (_availableSports.isNotEmpty &&
                                    _selectedSportId == null) {
                                  return 'Sport is required.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      'Date: ${_formatDate(_selectedDate)}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Time slots',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_availableTimeSlots.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFFF3F4F6),
                                ),
                                child: const Text(
                                  'No time slots found for this date.',
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableTimeSlots
                                    .map(
                                      (slot) => ChoiceChip(
                                        label: Text(_formatSlotLabel(slot)),
                                        selected: _isSlotSelected(slot),
                                        onSelected: slot.isFree
                                            ? (_) {
                                                setState(() {
                                                  _startTime = _parseTimeOfDay(
                                                    slot.startTime,
                                                  );
                                                  _endTime = _parseTimeOfDay(
                                                    slot.endTime,
                                                  );
                                                });
                                                _updateDynamicPrice();
                                              }
                                            : null,
                                      ),
                                    )
                                    .toList(),
                              ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'price',
                              controller: _priceController,
                              readOnly: true,
                              decoration: _inputDecoration('Price (KM)*'),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                (valueCandidate) {
                                  final parsed = double.tryParse(
                                    (valueCandidate ?? '').replaceAll(',', '.'),
                                  );
                                  if (parsed == null || parsed <= 0) {
                                    return 'Enter a valid positive price.';
                                  }
                                  return null;
                                },
                              ]),
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : () =>
                                              Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _save,
                                    child: _isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Save Changes'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
