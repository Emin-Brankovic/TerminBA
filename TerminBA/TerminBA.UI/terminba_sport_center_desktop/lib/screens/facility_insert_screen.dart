import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_sport_center_desktop/helpers/image_validator.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/facility_dynamic_price_insert_request.dart';
import 'package:terminba_sport_center_desktop/model/facility_insert_request.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/turf_type.dart';
import 'package:terminba_sport_center_desktop/providers/auth_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_provider.dart';
import 'package:terminba_sport_center_desktop/providers/sport_provider.dart';
import 'package:terminba_sport_center_desktop/providers/turf_type_provider.dart';

class FacilityInsertScreen extends StatefulWidget {
  const FacilityInsertScreen({super.key, this.facility});

  final Facility? facility;

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
  final List<Uint8List> _selectedPhotos = [];
  final Set<int> _removedPhotoIds = {};

  bool _initialized = false;
  bool _prefilled = false;
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
    _applyFacilityDefaults();
    _loadReferenceData();
  }

  void _applyFacilityDefaults() {
    if (_prefilled || widget.facility == null) {
      return;
    }

    final facility = widget.facility!;
    _hoursController.text = facility.duration.inHours.toString();
    _minutesController.text =
        (facility.duration.inMinutes % 60).toString().padLeft(2, '0');

    _dynamicPrices
      ..clear()
      ..addAll(
        facility.dynamicPrices.map(
          (price) => _DynamicPriceEntry(
            startDay: price.startDay,
            endDay: price.endDay,
            facilityId: facility.id,
            startTime: _parseTimeOfDay(price.startTime),
            endTime: _parseTimeOfDay(price.endTime),
            pricePerHour: price.pricePerHour,
            validFrom: price.validFrom,
            validTo: price.validTo,
          ),
        ),
      );

    _prefilled = true;
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
      print(_removedPhotoIds);
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
        photos: _selectedPhotos.isEmpty ? null : List.unmodifiable(_selectedPhotos),
        removedPhotoIds:
            _removedPhotoIds.isEmpty ? null : _removedPhotoIds.toList(),
      );

      if (widget.facility == null) {
        await _facilityProvider.insert(request);
      } else {
        await _facilityProvider.update(widget.facility!.id, request);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.facility == null
                  ? 'Facility created successfully.'
                  : 'Facility updated successfully.',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.facility == null
                  ? 'Error creating facility: $e'
                  : 'Error updating facility: $e',
            ),
          ),
        );
        print(e);
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

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length < 2) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hours, minute: minutes);
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

  Future<void> _pickPhotos({bool replace = false}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null) {
      return;
    }

    final picked = <Uint8List>[];
    final errors = <String>[];

    for (final file in result.files) {
      final validationError = ImageValidator.validatePickedImage(file);
      if (validationError != null) {
        errors.add('${file.name}: $validationError');
        continue;
      }

      if (file.bytes != null) {
        picked.add(file.bytes!);
      }
    }

    if (picked.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errors.isNotEmpty
                  ? errors.first
                  : 'No readable images selected.',
            ),
          ),
        );
      }
      return;
    }

    if (errors.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errors.length == 1
                ? errors.first
                : '${errors.first} (+${errors.length - 1} more)',
          ),
        ),
      );
    }

    setState(() {
      if (replace) {
        _selectedPhotos
          ..clear()
          ..addAll(picked);
        final existing = widget.facility?.photos ?? [];
        if (existing.isNotEmpty) {
          _removedPhotoIds
            ..clear()
            ..addAll(existing.map((photo) => photo.id));
        }
      } else {
        _selectedPhotos.addAll(picked);
      }
    });
  }

  Widget _buildPhotoPickerSection() {
    final existingPhotos = widget.facility?.photos
            .where((photo) => (photo.url ?? '').trim().isNotEmpty)
            .toList() ??
        [];
    final hasExisting = existingPhotos.isNotEmpty;
    final hasRemoved = _removedPhotoIds.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickPhotos(replace: false),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Add photos'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _pickPhotos(replace: true),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Replace photos'),
                ),
                if (_selectedPhotos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextButton(
                      onPressed: () => setState(() => _selectedPhotos.clear()),
                      child: const Text('Clear'),
                    ),
                  ),
              ],
            ),
          ],
        ),
        // if (hasExisting)
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 8),
        //     child: Text(
        //       'Existing photos will be kept unless you replace them.',
        //       style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        //     ),
        //   ),
        if (hasExisting)
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _removedPhotoIds
                      ..clear()
                      ..addAll(existingPhotos.map((photo) => photo.id));
                  });
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('Remove all existing'),
              ),
              if (hasRemoved)
                TextButton.icon(
                  onPressed: () => setState(() => _removedPhotoIds.clear()),
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo removals'),
                ),
            ],
          ),
        if (hasExisting)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: existingPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final photo = existingPhotos[index];
                final url = photo.url;
                final isRemoved = _removedPhotoIds.contains(photo.id);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: isRemoved ? 0.4 : 1,
                        child: Image.network(
                          url!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          iconSize: 18,
                          onPressed: () {
                            setState(() {
                              if (isRemoved) {
                                _removedPhotoIds.remove(photo.id);
                              } else {
                                _removedPhotoIds.add(photo.id);
                              }
                            });
                          },
                          icon: Icon(
                            isRemoved ? Icons.undo : Icons.delete_outline,
                            color: isRemoved
                                ? Colors.orange.shade700
                                : Colors.red.shade600,
                          ),
                        ),
                      ),
                      if (isRemoved)
                        Positioned(
                          left: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Removed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Text(
            'No existing photos uploaded.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        const SizedBox(height: 8),
        if (_selectedPhotos.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _selectedPhotos[index],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          )
        else
          Text(
            'No new photos selected.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
      ],
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
        initialValue: widget.facility?.staticPrice?.toString(),
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
      _formKey.currentState?.instantValue['isDynamicPricing'] as bool? ??
        (widget.facility?.isDynamicPricing ?? false);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Center(
          child: Text(
            widget.facility == null ? 'Add Facility' : 'Edit Facility',
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
                              initialValue: widget.facility?.name,
                              decoration: _inputDecoration('Facility Name*'),
                              validator: FormBuilderValidators.required(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'maxCapacity',
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Max Capacity*'),
                              initialValue:
                                widget.facility?.maxCapacity.toString(),
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
                              initialValue: widget.facility?.turfTypeId,
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
                                initialValue: widget.facility?.isIndoor ?? true,
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
                                initialValue:
                                    widget.facility?.isDynamicPricing ?? false,
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
                              initialValue: widget.facility?.availableSports
                                  .map((s) => s.id)
                                  .toList(),
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
                            const SizedBox(height: 20),
                            _sectionHeader('Photos'),
                            _buildPhotoPickerSection(),
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
                                      : Text(
                                          widget.facility == null
                                              ? 'Create Facility'
                                              : 'Save Changes',
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
