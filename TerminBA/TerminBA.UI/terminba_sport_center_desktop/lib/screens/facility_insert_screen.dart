import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_sport_center_desktop/model/facility_dynamic_price_insert_request.dart';
import 'package:terminba_sport_center_desktop/model/facility_insert_request.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/turf_type.dart';
import 'package:terminba_sport_center_desktop/providers/auth_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_provider.dart';
import 'package:terminba_sport_center_desktop/providers/sport_provider.dart';
import 'package:terminba_sport_center_desktop/providers/turf_type_provider.dart';

class FacilityInsertScreen extends StatefulWidget {
  const FacilityInsertScreen({super.key});

  @override
  State<FacilityInsertScreen> createState() => _FacilityInsertScreenState();
}

class _FacilityInsertScreenState extends State<FacilityInsertScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();

  late FacilityProvider _facilityProvider;
  late SportProvider _sportProvider;
  late TurfTypeProvider _turfTypeProvider;
  late AuthProvider _authProvider;

  final List<Sport> _sports = [];
  final List<TurfType> _turfTypes = [];
  final List<_DynamicPriceEntry> _dynamicPrices = [];

  bool _initialized = false;
  bool _isLoading = true;
  bool _isSaving = false;
  int? _sportCenterId;

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;
    _facilityProvider = context.read<FacilityProvider>();
    _sportProvider = context.read<SportProvider>();
    _turfTypeProvider = context.read<TurfTypeProvider>();
    _authProvider = context.read<AuthProvider>();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _sportProvider.get(),
        _turfTypeProvider.get(),
        _authProvider.getCurrentUserId(),
      ]);

      setState(() {
        _sports
          ..clear()
          ..addAll((results[0] as dynamic).items?.cast<Sport>() ?? <Sport>[]);

        _turfTypes
          ..clear()
          ..addAll((results[1] as dynamic).items?.cast<TurfType>() ?? <TurfType>[]);

        _sportCenterId = results[2] as int?;
      });
    } catch (e) {
      debugPrint('Error loading facility reference data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    if (hours < 0 || minutes < 0 || minutes > 59 || (hours == 0 && minutes == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid duration (minutes must be 0-59).'),
        ),
      );
      return;
    }

    if (_sportCenterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to resolve your sport center identity.'),
        ),
      );
      return;
    }

    final values = _formKey.currentState!.value;
    final bool isDynamicPricing = values['isDynamicPricing'] as bool? ?? false;

    if (isDynamicPricing && _dynamicPrices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one dynamic price rule.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final request = FacilityInsertRequest(
        name: values['name'] as String,
        maxCapacity: values['maxCapacity'] as int,
        isDynamicPricing: isDynamicPricing,
        staticPrice: isDynamicPricing ? null : values['staticPrice'] as double,
        isIndoor: values['isIndoor'] as bool? ?? false,
        duration: Duration(hours: hours, minutes: minutes),
        sportCenterId: _sportCenterId!,
        turfTypeId: values['turfTypeId'] as int,
        availableSportsIds: (values['availableSportsIds'] as List<dynamic>)
            .cast<int>(),
        dynamicPrices: isDynamicPricing
            ? _dynamicPrices
                .map(
                  (e) => FacilityDynamicPriceInsertRequest(
                    e.facilityId,
                    e.startDay,
                    e.endDay,
                    _formatTime(e.startTime),
                    _formatTime(e.endTime),
                    e.pricePerHour,
                    e.validFrom,
                    e.validTo,
                  ),
                )
                .toList()
            : null,
      );

      await _facilityProvider.insert(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facility created successfully.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating facility: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Future<void> _pickTime({
    required int index,
    required bool isStart,
  }) async {
    final entry = _dynamicPrices[index];
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart ? entry.startTime : entry.endTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _dynamicPrices[index].startTime = selected;
      } else {
        _dynamicPrices[index].endTime = selected;
      }
    });
  }

  Future<void> _pickDate({
    required int index,
    required bool isFrom,
  }) async {
    final entry = _dynamicPrices[index];
    final selected = await showDatePicker(
      context: context,
      initialDate: isFrom ? entry.validFrom : entry.validTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (isFrom) {
        _dynamicPrices[index].validFrom = selected;
      } else {
        _dynamicPrices[index].validTo = selected;
      }
    });
  }

  Widget _buildDynamicPricingSection(bool isDynamicPricing) {
    const dayLabels = <String>[
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    if (!isDynamicPricing) {
      return FormBuilderTextField(
        name: 'staticPrice',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
        ],
        decoration: _inputDecoration('Static Price (EUR)*'),
        valueTransformer: (value) =>
            value == null || value.trim().isEmpty ? null : double.tryParse(value),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          (valueCandidate) {
            final parsed = double.tryParse(valueCandidate?.toString() ?? '');
            if (parsed == null || parsed <= 0) {
              return 'Enter a valid positive price.';
            }
            return null;
          },
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dynamic Prices*',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => _dynamicPrices.add(_DynamicPriceEntry()));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add rule'),
            ),
          ],
        ),
        if (_dynamicPrices.isEmpty)
          Text(
            'Add at least one pricing rule.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 8),
        ..._dynamicPrices.asMap().entries.map((entry) {
          final index = entry.key;
          final rule = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rule ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _dynamicPrices.removeAt(index));
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Color.fromARGB(183, 255, 82, 82),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<DayOfWeek>(
                          value: rule.startDay,
                          decoration: _inputDecoration('From Day'),
                          items: DayOfWeek.values
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(dayLabels[d.index]),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _dynamicPrices[index].startDay = v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<DayOfWeek>(
                          value: rule.endDay,
                          decoration: _inputDecoration('To Day'),
                          items: DayOfWeek.values
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(dayLabels[d.index]),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _dynamicPrices[index].endDay = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickTime(index: index, isStart: true),
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            'Start: ${_formatTime(rule.startTime).substring(0, 5)}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickTime(index: index, isStart: false),
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            'End: ${_formatTime(rule.endTime).substring(0, 5)}',
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
                          onPressed: () => _pickDate(index: index, isFrom: true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text('From: ${_formatDate(rule.validFrom)}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(index: index, isFrom: false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            rule.validTo != null
                                ? 'To: ${_formatDate(rule.validTo!)}'
                                : 'To: No end date',
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Clear end date',
                        onPressed: () {
                          setState(() => _dynamicPrices[index].validTo = null);
                        },
                        icon: const Icon(Icons.event_busy),
                      ),
                    ],
                  ),
                                   const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'dynamicPrice_$index',
                    initialValue: rule.pricePerHour.toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Price per hour (EUR)*'),
                    onChanged: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed != null) {
                        _dynamicPrices[index].pricePerHour = parsed;
                      }
                    },
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid positive price.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDynamicPricing =
        _formKey.currentState?.instantValue['isDynamicPricing'] as bool? ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Center(
          child: Text(
            'Add Facility',
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
                            _sectionHeader('Basic Information'),
                            FormBuilderTextField(
                              name: 'name',
                              decoration: _inputDecoration('Facility Name*'),
                              validator: FormBuilderValidators.required(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'maxCapacity',
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Max Capacity*'),
                              valueTransformer: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? null
                                      : int.tryParse(value),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                (valueCandidate) {
                                  final parsed =
                                      int.tryParse(valueCandidate?.toString() ?? '');
                                  if (parsed == null || parsed <= 0) {
                                    return 'Enter a valid positive number.';
                                  }
                                  return null;
                                },
                                FormBuilderValidators.max(80, errorText: 'Capacity seems too high.'),
                                FormBuilderValidators.min(0, errorText: 'Capacity seems too low.'),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            // _sectionHeader('Configuration'),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blueGrey.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Slot Duration*',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          decoration: _inputDecoration('Hours'),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            (valueCandidate) {
                                              final parsed = int.tryParse(valueCandidate ?? '');
                                              if (parsed == null || parsed < 0) {
                                                return 'Enter a valid non-negative number.';
                                              }
                                              return null;
                                            },
                                          ]),
                                          controller: _hoursController,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          ':',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          decoration: _inputDecoration('Minutes'),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            (valueCandidate) {
                                              final parsed = int.tryParse(valueCandidate ?? '');
                                              if (parsed == null || parsed < 0) {
                                                return 'Enter a valid non-negative number.';
                                              }
                                              return null;
                                            },
                                          ]),
                                          controller: _minutesController,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'HH : MM',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderDropdown<int>(
                              name: 'turfTypeId',
                              decoration: _inputDecoration('Turf Type*'),
                              validator: FormBuilderValidators.required(),
                              items: _turfTypes
                                  .map(
                                    (t) => DropdownMenuItem<int>(
                                      value: t.id,
                                      child: Text(t.name),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade100,
                              ),
                              child: FormBuilderCheckbox(
                                name: 'isIndoor',
                                initialValue: true,
                                title: const Text('Indoor Facility', style: TextStyle(fontSize: 14),),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade100,
                              ),
                              child: FormBuilderSwitch(
                                name: 'isDynamicPricing',
                                title: const Text('Use dynamic pricing', style: TextStyle(fontSize: 14),),
                                initialValue: false,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _sectionHeader('Pricing'),
                            _buildDynamicPricingSection(isDynamicPricing),
                            const SizedBox(height: 20),
                            _sectionHeader('Available Sports'),
                            FormBuilderCheckboxGroup<int>(
                              name: 'availableSportsIds',
                              decoration: _inputDecoration('Sports*'),
                              options: _sports
                                  .map(
                                    (s) => FormBuilderFieldOption<int>(
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
                            const SizedBox(height: 34),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                                        'Create Facility',
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

class _DynamicPriceEntry {
  DayOfWeek startDay;
  DayOfWeek endDay;
  int facilityId;
  TimeOfDay startTime;
  TimeOfDay endTime;
  double pricePerHour;
  DateTime validFrom;
  DateTime? validTo;

  _DynamicPriceEntry({
    this.startDay = DayOfWeek.monday,
    this.endDay = DayOfWeek.friday,
    this.facilityId = 2,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    this.pricePerHour = 20,
    DateTime? validFrom,
    this.validTo,
  }) : startTime = startTime ?? const TimeOfDay(hour: 8, minute: 0),
       endTime = endTime ?? const TimeOfDay(hour: 22, minute: 0),
       validFrom = validFrom ?? DateTime.now();
}
