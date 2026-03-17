import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_admin_desktop/model/amenity.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/sport.dart';
import 'package:terminba_admin_desktop/model/sport_center.dart';
import 'package:terminba_admin_desktop/model/sport_center_insert_request.dart';
import 'package:terminba_admin_desktop/model/sport_center_update_request.dart';
import 'package:terminba_admin_desktop/model/working_hours_insert_request.dart';
import 'package:terminba_admin_desktop/providers/amenity_provider.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_center_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_provider.dart';

class SportCenterInsertScreen extends StatefulWidget {
  const SportCenterInsertScreen({super.key, this.sportCenter});

  final SportCenter? sportCenter;

  @override
  State<SportCenterInsertScreen> createState() =>
      _SportCenterInsertScreenState();
}

class _SportCenterInsertScreenState extends State<SportCenterInsertScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  late SportCenterProvider _sportCenterProvider;
  late CityProvider _cityProvider;
  late SportProvider _sportProvider;
  late AmenityProvider _amenityProvider;

  List<City> _cities = [];
  List<Sport> _sports = [];
  List<Amenity> _amenities = [];
  List<_WorkingHoursEntry> _workingHoursList = [];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.sportCenter != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sportCenterProvider = context.read<SportCenterProvider>();
    _cityProvider = context.read<CityProvider>();
    _sportProvider = context.read<SportProvider>();
    _amenityProvider = context.read<AmenityProvider>();
    _loadReferenceData();
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
        _cities = (results[0].items ?? []).cast<City>();
        _sports = (results[1].items ?? []).cast<Sport>();
        _amenities = (results[2].items ?? []).cast<Amenity>();
      });

      // Pre-fill working hours if editing
      if (_isEditing) {
        _workingHoursList = widget.sportCenter!.workingHours.map((wh) {
          TimeOfDay _parseTime(String t) {
            final parts = t.split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }

          return _WorkingHoursEntry(
            startDay: wh.startDay,
            endDay: wh.endDay,
            openingTime: _parseTime(wh.openingHours),
            closingTime: _parseTime(wh.closeingHours),
            validFrom: wh.validFrom,
            validTo: wh.validTo,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading reference data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final values = _formKey.currentState!.value;

    final workingHours = _workingHoursList
        .map(
          (e) => WorkingHoursInsertRequest(
            0,
            e.startDay,
            e.endDay,
            _formatTime(e.openingTime),
            _formatTime(e.closingTime),
            e.validFrom,
            e.validTo,
          ),
        )
        .toList();

    setState(() => _isSaving = true);
    try {
      print(_formKey.currentState?.value.toString());

      if (_isEditing) {
        final updateRequest = SportCenterUpdateRequest(
          values['username'] as String,
          values['phoneNumber'] as String,
          values['cityId'] as int,
          values['address'] as String,
          values['isEquipmentProvided'] as bool,
          values['description'] as String,
          (values['sportIds'] as List<dynamic>).cast<int>(),
          (values['amenityIds'] as List<dynamic>).cast<int>(),
          workingHours,
        );
        await _sportCenterProvider.update(
          widget.sportCenter!.id,
          updateRequest,
        );
      } else {
        final insertRequest = SportCenterInsertRequest(
          values['username'] as String,
          values['phoneNumber'] as String,
          values['cityId'] as int,
          values['address'] as String,
          values['isEquipmentProvided'] as bool,
          values['description'] as String,
          2, // default roleId for sport center
          (values['sportIds'] as List<dynamic>).cast<int>(),
          (values['amenityIds'] as List<dynamic>).cast<int>(),
          workingHours,
        );
        await _sportCenterProvider.insert(insertRequest);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Sport center updated successfully.'
                  : 'Sport center created successfully.',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error creating sport center: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addWorkingHoursEntry() {
    setState(() => _workingHoursList.add(_WorkingHoursEntry()));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _buildWorkingHoursRow(int index, _WorkingHoursEntry wh) {
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
                  onPressed: () =>
                      setState(() => _workingHoursList.removeAt(index)),
                  icon: const Icon(
                    Icons.close,
                    color: Color.fromARGB(183, 255, 82, 82),
                  ),
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
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        ),
                      );
                      if (t != null) {
                        setState(
                          () => _workingHoursList[index].openingTime = t,
                        );
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      'Open: ${_formatTime(wh.openingTime).substring(0, 5)}',
                    ),
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
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        ),
                      );
                      if (t != null) {
                        setState(
                          () => _workingHoursList[index].closingTime = t,
                        );
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      'Close: ${_formatTime(wh.closingTime).substring(0, 5)}',
                    ),
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
        title: Center(
          child: Text(
            _isEditing ? 'Edit Sport Center' : 'Add Sport Center',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username
                            FormBuilderTextField(
                              name: 'username',
                              initialValue: widget.sportCenter?.username,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                            const SizedBox(height: 16),

                            // Phone number
                            FormBuilderTextField(
                              name: 'phoneNumber',
                              initialValue: widget.sportCenter?.phoneNumber,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                            const SizedBox(height: 16),

                            // City dropdown
                            FormBuilderDropdown<int>(
                              name: 'cityId',
                              initialValue: widget.sportCenter?.cityId,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.required(),
                              items: _cities
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),

                            // Address
                            FormBuilderTextField(
                              name: 'address',
                              initialValue: widget.sportCenter?.address,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                            const SizedBox(height: 16),

                            // Description
                            FormBuilderTextField(
                              name: 'description',
                              initialValue: widget.sportCenter?.description,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                            const SizedBox(height: 16),

                            // Equipment provided
                            FormBuilderCheckbox(
                              name: 'isEquipmentProvided',
                              initialValue:
                                  widget.sportCenter?.isEquipmentProvided ??
                                  false,
                              title: const Text('Equipment Provided'),
                            ),
                            const SizedBox(height: 16),

                            // Available Sports (multi-select)
                            FormBuilderCheckboxGroup<int>(
                              name: 'sportIds',
                              decoration: const InputDecoration(
                                labelText: 'Available Sports',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _isEditing
                                  ? widget.sportCenter!.availableSports
                                        .map((s) => s.id)
                                        .toList()
                                  : const [],
                              options: _sports
                                  .map(
                                    (s) => FormBuilderFieldOption(
                                      value: s.id,
                                      child: Text(s.name ?? ''),
                                    ),
                                  )
                                  .toList(),
                              validator: FormBuilderValidators.minLength(
                                1,
                                errorText: 'Select at least one sport.',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Amenities (multi-select)
                            FormBuilderCheckboxGroup<int>(
                              name: 'amenityIds',
                              decoration: const InputDecoration(
                                labelText: 'Amenities',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _isEditing
                                  ? widget.sportCenter!.availableAmenities
                                        .map((a) => a.id)
                                        .toList()
                                  : const [],
                              options: _amenities
                                  .map(
                                    (a) => FormBuilderFieldOption(
                                      value: a.id,
                                      child: Text(a.name),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),

                            // Working Hours
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Working Hours',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _addWorkingHoursEntry,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add'),
                                    ),
                                  ],
                                ),
                                ..._workingHoursList.asMap().entries.map(
                                  (entry) => _buildWorkingHoursRow(
                                    entry.key,
                                    entry.value,
                                  ),
                                ),
                              ],
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
                                    : Text(
                                        _isEditing
                                            ? 'Update Sport Center'
                                            : 'Create Sport Center',
                                        style: const TextStyle(fontSize: 16),
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
    DateTime? validTo,
  }) : openingTime = openingTime ?? const TimeOfDay(hour: 8, minute: 0),
       closingTime = closingTime ?? const TimeOfDay(hour: 22, minute: 0),
       validFrom = validFrom ?? DateTime.now(),
       validTo = validTo;
}
