import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/model/dynamic_price_date_request.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/facility_time_slot.dart';
import 'package:terminba_sport_center_desktop/model/reservation_response.dart';
import 'package:terminba_sport_center_desktop/model/reservation_update_request.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/providers/auth_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_dynamic_price_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_time_slot_provider.dart';
import 'package:terminba_sport_center_desktop/providers/reservation_provider.dart';

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
  late AuthProvider _authProvider;
  late FacilityTimeSlotProvider _facilityTimeSlotProvider;
  late FacilityDynamicPriceProvider _facilityDynamicPriceProvider;

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
    _authProvider = context.read<AuthProvider>();
    _facilityTimeSlotProvider = context.read<FacilityTimeSlotProvider>();
    _facilityDynamicPriceProvider = context
        .read<FacilityDynamicPriceProvider>();
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
      _sportCenterId = _authProvider.isLoggedIn
          ? await _authProvider.getCurrentUserId()
          : null;

      _selectedFacilityId = reservation.facilityId;
      _selectedSportId = reservation.chosenSportId;
      _selectedDate = reservation.reservationDate;
      _startTime = _parseTimeOfDay(reservation.startTime);
      _endTime = _parseTimeOfDay(reservation.endTime);
      _status = reservation.status ?? '';
      _priceController.text = reservation.price.toStringAsFixed(2);

      await _loadFacilities();
      _syncAvailableSportsWithSelectedFacility();
      await _loadAvailableTimeSlots();
      await _updateDynamicPrice();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading reservation: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
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

  Future<void> _updateDynamicPrice() async {
    if (_selectedFacilityId == null || _startTime == null || _endTime == null) {
      return;
    }

    try {
      final request = DynamicPriceForDateRequest(
        _selectedFacilityId!,
        _selectedDate,
        _formatApiTime(_startTime!),
        _formatApiTime(_endTime!),
      );

      final price = await _facilityDynamicPriceProvider.getDynamicPriceForDate(
        request,
      );

      if (!mounted) return;
      setState(() {
        _priceController.text = price.toStringAsFixed(2);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dynamic price: $e')),
      );
    }
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
      final result = await _facilityTimeSlotProvider.getFacilityTimeSlots(
        _selectedFacilityId!,
        _selectedDate,
      );

      if (!mounted) return;
      setState(() {
        _availableTimeSlots
          ..clear()
          ..addAll(result ?? []);

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
    print('Loaded ${_availableTimeSlots.length} time slots for facility $_selectedFacilityId on date $_selectedDate');
      await _updateDynamicPrice();
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
      if (!mounted) return;
      setState(() => _isSaving = false);
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

  bool _isFacilityPriceDynamic(int? facilityId) {
    final facility = _facilities.where((f) => f.id == facilityId).firstOrNull;
    return facility?.isDynamicPricing ?? false;
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
                            Text(
                              'Booked by: ${widget.reservation.user?.username ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Current status: ${widget.reservation.status ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                            ? (_) async {
                                                setState(() {
                                                  _startTime = _parseTimeOfDay(
                                                    slot.startTime,
                                                  );
                                                  _endTime = _parseTimeOfDay(
                                                    slot.endTime,
                                                  );
                                                });
                                                if (_isFacilityPriceDynamic(
                                                  _selectedFacilityId,
                                                )) {
                                                  await _updateDynamicPrice();
                                                }
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
