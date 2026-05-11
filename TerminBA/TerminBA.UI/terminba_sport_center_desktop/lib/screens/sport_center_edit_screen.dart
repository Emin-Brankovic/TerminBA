import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_sport_center_desktop/model/amenity.dart';
import 'package:terminba_sport_center_desktop/model/city.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/sport_center.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_update_request.dart';
import 'package:terminba_sport_center_desktop/model/working_hours_insert_request.dart';
import 'package:terminba_sport_center_desktop/providers/amenity_provider.dart';
import 'package:terminba_sport_center_desktop/providers/city_provider.dart';
import 'package:terminba_sport_center_desktop/providers/sport_center_provider.dart';
import 'package:terminba_sport_center_desktop/providers/sport_provider.dart';

class SportCenterEditScreen extends StatefulWidget {
  const SportCenterEditScreen({super.key, required this.sportCenter});

  final SportCenter sportCenter;

  @override
  State<SportCenterEditScreen> createState() => _SportCenterEditScreenState();
}

class _SportCenterEditScreenState extends State<SportCenterEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  late SportCenterProvider _sportCenterProvider;
  late CityProvider _cityProvider;
  late SportProvider _sportProvider;
  late AmenityProvider _amenityProvider;

  final List<City> _cities = [];
  final List<Sport> _sports = [];
  final List<Amenity> _amenities = [];
  final List<_WorkingHoursEntry> _workingHoursList = [];

  bool _initialized = false;
  bool _prefilled = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    _sportCenterProvider = context.read<SportCenterProvider>();
    _cityProvider = context.read<CityProvider>();
    _sportProvider = context.read<SportProvider>();
    _amenityProvider = context.read<AmenityProvider>();

    _applyWorkingHoursDefaults();
    _loadReferenceData();
  }

  void _applyWorkingHoursDefaults() {
    if (_prefilled) {
      return;
    }

    _workingHoursList
      ..clear()
      ..addAll(
        widget.sportCenter.workingHours.map(
          (wh) => _WorkingHoursEntry(
            startDay: wh.startDay,
            endDay: wh.endDay,
            openingTime: _parseTimeOfDay(wh.openingHours),
            closingTime: _parseTimeOfDay(wh.closeingHours),
            validFrom: wh.validFrom,
            validTo: wh.validTo,
          ),
        ),
      );

    _prefilled = true;
  }

  Future<void> _loadReferenceData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _cityProvider.get(),
        _sportProvider.get(),
        _amenityProvider.get(),
      ]);

      setState(() {
        _cities
          ..clear()
          ..addAll((results[0] as dynamic).items?.cast<City>() ?? <City>[]);
        _sports
          ..clear()
          ..addAll((results[1] as dynamic).items?.cast<Sport>() ?? <Sport>[]);
        _amenities
          ..clear()
          ..addAll((results[2] as dynamic).items?.cast<Amenity>() ?? <Amenity>[]);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    if (_workingHoursList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one working hours entry.')),
      );
      return;
    }

    final values = _formKey.currentState!.value;

    final workingHours = _workingHoursList
        .map(
          (entry) => WorkingHoursInsertRequest(
            widget.sportCenter.id,
            entry.startDay,
            entry.endDay,
            _formatTime(entry.openingTime),
            _formatTime(entry.closingTime),
            entry.validFrom,
            entry.validTo,
          ),
        )
        .toList();

    final request = SportCenterUpdateRequest(
      values['username'] as String,
      values['phoneNumber'] as String,
      values['contactEmail'] as String?,
      values['cityId'] as int,
      values['address'] as String,
      values['isEquipmentProvided'] as bool,
      values['description'] as String? ?? '',
      (values['sportIds'] as List<dynamic>).cast<int>(),
      (values['amenityIds'] as List<dynamic>).cast<int>(),
      workingHours,
    );

    setState(() => _isSaving = true);

    try {
      await _sportCenterProvider.update(widget.sportCenter.id, request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sport center updated successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 0, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Widget _buildWorkingHoursRow(
    int index,
    _WorkingHoursEntry wh,
    VoidCallback onRemove,
  ) {
    const dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final days = DayOfWeek.values;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  iconSize: 20,
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DayOfWeek>(
                    value: wh.startDay,
                    decoration: const InputDecoration(
                      labelText: 'From Day',
                      border: OutlineInputBorder(),
                    ),
                    items: days
                        .asMap()
                        .entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(dayNames[e.key]),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _workingHoursList[index].startDay = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<DayOfWeek>(
                    value: wh.endDay,
                    decoration: const InputDecoration(
                      labelText: 'To Day',
                      border: OutlineInputBorder(),
                    ),
                    items: days
                        .asMap()
                        .entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(dayNames[e.key]),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _workingHoursList[index].endDay = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: wh.openingTime,
                        builder: (context, child) => MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        ),
                      );
                      if (t != null) {
                        setState(() =>
                            _workingHoursList[index].openingTime = t);
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label:
                        Text('Open: ${_formatTime(wh.openingTime).substring(0, 5)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: wh.closingTime,
                        builder: (context, child) => MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        ),
                      );
                      if (t != null) {
                        setState(() =>
                            _workingHoursList[index].closingTime = t);
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label:
                        Text('Close: ${_formatTime(wh.closingTime).substring(0, 5)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: wh.validFrom,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setState(() => _workingHoursList[index].validFrom = d);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text('From: ${_formatDate(wh.validFrom)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: wh.validTo ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setState(() => _workingHoursList[index].validTo = d);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      wh.validTo != null
                          ? 'To: ${_formatDate(wh.validTo!)}'
                          : 'To: No end date',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear end date',
                  onPressed: () =>
                      setState(() => _workingHoursList[index].validTo = null),
                  icon: const Icon(Icons.event_busy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Center(
          child: Text(
            'Edit Sport Center',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormBuilderTextField(
                              name: 'username',
                              initialValue: widget.sportCenter.username,
                              decoration: const InputDecoration(
                                labelText: 'Name*',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.required(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'phoneNumber',
                              initialValue: widget.sportCenter.phoneNumber,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number*',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.phoneNumber(),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'contactEmail',
                              initialValue: widget.sportCenter.contactEmail,
                              decoration: const InputDecoration(
                                labelText: 'Contact Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                return FormBuilderValidators.email()(value);
                              },
                            ),
                            const SizedBox(height: 16),
                            FormBuilderDropdown<int>(
                              name: 'cityId',
                              initialValue: widget.sportCenter.cityId,
                              decoration: const InputDecoration(
                                labelText: 'City*',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.required(),
                              items: _cities
                                  .map(
                                    (city) => DropdownMenuItem(
                                      value: city.id,
                                      child: Text(city.name),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'address',
                              initialValue: widget.sportCenter.address,
                              decoration: const InputDecoration(
                                labelText: 'Address*',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.required(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'description',
                              initialValue: widget.sportCenter.description,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: FormBuilderValidators.maxLength(
                                180,
                                errorText: 'Description cannot exceed 180 characters.',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderCheckbox(
                              name: 'isEquipmentProvided',
                              initialValue: widget.sportCenter.isEquipmentProvided,
                              title: const Text('Equipment Provided'),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderCheckboxGroup<int>(
                              name: 'sportIds',
                              decoration: const InputDecoration(
                                labelText: 'Available Sports*',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: widget.sportCenter.availableSports
                                  .map((s) => s.id)
                                  .toList(),
                              options: _sports
                                  .map(
                                    (sport) => FormBuilderFieldOption(
                                      value: sport.id,
                                      child: Text(sport.name ?? ''),
                                    ),
                                  )
                                  .toList(),
                              validator: FormBuilderValidators.minLength(
                                1,
                                errorText: 'Select at least one sport.',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderCheckboxGroup<int>(
                              name: 'amenityIds',
                              decoration: const InputDecoration(
                                labelText: 'Amenities*',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: widget.sportCenter.availableAmenities
                                  .map((a) => a.id)
                                  .toList(),
                              options: _amenities
                                  .map(
                                    (amenity) => FormBuilderFieldOption(
                                      value: amenity.id,
                                      child: Text(amenity.name),
                                    ),
                                  )
                                  .toList(),
                              validator: FormBuilderValidators.required(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderField<List<_WorkingHoursEntry>>(
                              name: 'workingHours',
                              initialValue:
                                  List<_WorkingHoursEntry>.from(_workingHoursList),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                final entries = value ?? _workingHoursList;
                                if (entries.isEmpty) {
                                  return 'Add at least one working hours entry.';
                                }
                                return null;
                              },
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Working Hours*',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            setState(() =>
                                                _workingHoursList.add(_WorkingHoursEntry()));
                                            field.didChange(
                                              List<_WorkingHoursEntry>.from(
                                                _workingHoursList,
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add'),
                                        ),
                                      ],
                                    ),
                                    ..._workingHoursList.asMap().entries.map(
                                      (entry) => _buildWorkingHoursRow(
                                        entry.key,
                                        entry.value,
                                        () {
                                          setState(() =>
                                              _workingHoursList.removeAt(entry.key));
                                          field.didChange(
                                            List<_WorkingHoursEntry>.from(
                                              _workingHoursList,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Update Sport Center',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
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

class _WorkingHoursEntry {
  DayOfWeek startDay;
  DayOfWeek endDay;
  TimeOfDay openingTime;
  TimeOfDay closingTime;
  DateTime validFrom;
  DateTime? validTo;

  _WorkingHoursEntry({
    this.startDay = DayOfWeek.monday,
    this.endDay = DayOfWeek.friday,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    DateTime? validFrom,
    this.validTo,
  })  : openingTime = openingTime ?? const TimeOfDay(hour: 8, minute: 0),
        closingTime = closingTime ?? const TimeOfDay(hour: 20, minute: 0),
        validFrom = validFrom ?? DateTime.now();
}
