import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/amenity.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/role.dart';
import 'package:terminba_admin_desktop/model/sport.dart';
import 'package:terminba_admin_desktop/model/turf_type.dart';
import 'package:terminba_admin_desktop/providers/amenity_provider.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/role_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_provider.dart';
import 'package:terminba_admin_desktop/providers/turf_type_provider.dart';

class ReferenceDataScreen extends StatefulWidget {
  const ReferenceDataScreen({super.key});

  @override
  State<ReferenceDataScreen> createState() => _ReferenceDataScreenState();
}

class _ReferenceDataScreenState extends State<ReferenceDataScreen> {
  int? _selectedIndex = 0; // Track which index is selected
  List<String> categories = ['Turf Type', 'Amenity', 'City', 'Sport', 'Role'];
  final List<String> data = [];
  late ReferenceDataDataSource<dynamic> _referenceDataDataSource;

  late AmenityProvider amenityProvider;
  late TurfTypeProvider turfTypeProvider;
  late CityProvider cityProvider;
  late SportProvider sportProvider;
  late RoleProvider roleProvider;

  bool _providersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    amenityProvider = context.read<AmenityProvider>();
    turfTypeProvider = context.read<TurfTypeProvider>();
    cityProvider = context.read<CityProvider>();
    sportProvider = context.read<SportProvider>();
    roleProvider = context.read<RoleProvider>();
    if (!_providersInitialized) {
      _providersInitialized = true;
      _refreshTable();
    }
  }

  @override
  void initState() {
    super.initState();
    _referenceDataDataSource = ReferenceDataDataSource<dynamic>(
      [],
      (item) => '',
      _onEdit,
      _onDelete,
    );
  }

  Future<void> _refreshTable() async {
    if (_selectedIndex == null) return;
    var source = await _getReferenceData(_selectedIndex!);
    setState(() {
      _referenceDataDataSource = source;
    });
  }

  void _onAdd() {
    final TextEditingController controller = TextEditingController(text: '');
    final formKey = GlobalKey<FormState>();
    bool hasTriedSubmit = false;
    String? submitError;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Add ${categories[_selectedIndex!]}'),
          content: Form(
            key: formKey,
            autovalidateMode: hasTriedSubmit
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Enter name"),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                if (submitError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    submitError!,
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                setDialogState(() {
                  hasTriedSubmit = true;
                  submitError = null;
                });

                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final name = controller.text.trim();
                try {
                  if (categories[_selectedIndex!] == 'Turf Type') {
                    await turfTypeProvider.insert({"name": name});
                  } else if (categories[_selectedIndex!] == 'Amenity') {
                    await amenityProvider.insert({"name": name});
                  } else if (categories[_selectedIndex!] == 'City') {
                    await cityProvider.insert({"name": name});
                  } else if (categories[_selectedIndex!] == 'Sport') {
                    await sportProvider.insert({"name": name});
                  } else if (categories[_selectedIndex!] == 'Role') {
                    await roleProvider.insert({"name": name});
                  }

                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${categories[_selectedIndex!]} added successfully')),
                  );

                  await _refreshTable();
                } catch (e) {
                  setDialogState(() {
                    submitError = e.toString().replaceFirst('Exception: ', '');
                  });

                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _onEdit(int index) {
    var currentItem = _referenceDataDataSource._items[index];

    final TextEditingController controller = TextEditingController(
      text: currentItem.name,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${categories[_selectedIndex!]}'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (currentItem is TurfType) {
                await turfTypeProvider.update(currentItem.id, {
                  "name": controller.text,
                });
              } else if (currentItem is Amenity) {
                await amenityProvider.update(currentItem.id, {
                  "name": controller.text,
                });
              } else if (currentItem is City) {
                await cityProvider.update(currentItem.id, {
                  "name": controller.text,
                });
              } else if (currentItem is Sport) {
                await sportProvider.update(currentItem.id, {
                  "name": controller.text,
                });
              } else if (currentItem is Role) {
                await roleProvider.update(currentItem.id, {
                  "name": controller.text,
                });
              }
              await _refreshTable();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onDelete(int index) {
    var currentItem = _referenceDataDataSource._items[index];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (currentItem is TurfType) {
                await turfTypeProvider.delete(currentItem.id);
              } else if (currentItem is Amenity) {
                await amenityProvider.delete(currentItem.id);
              } else if (currentItem is City) {
                await cityProvider.delete(currentItem.id);
              } else if (currentItem is Sport) {
                await sportProvider.delete(currentItem.id);
              } else if (currentItem is Role) {
                await roleProvider.delete(currentItem.id);
              }
              await _refreshTable();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reference Data',
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildHeaderChips(), _buildListSection()],
        ),
      ),
    );
  }

  Widget _buildListSection() {
    return Expanded(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            rowsPerPage: 10,
            columns: [
              DataColumn(label: Text("Name")),
              DataColumn(
                columnWidth: const FixedColumnWidth(20),
                headingRowAlignment: MainAxisAlignment.end,
                label: SizedBox(
                  width: 140,
                  child: Center(child: Text("Actions")),
                ),
              ),
            ],
            source: _referenceDataDataSource,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                _onAdd();
              },
              child: const Text('Add New'),
            ),
          ),
          Center(
            child: Wrap(
              spacing: 12,
              children: List<Widget>.generate(categories.length, (int index) {
                return ChoiceChip(
                  label: Text(categories[index]),
                  selected: _selectedIndex == index,
                  onSelected: _selectedIndex == index ? null :
                  (bool selected) async {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (selected) {
                      var source = await _getReferenceData(index);
                      setState(() {
                        _referenceDataDataSource = source;
                      });
                    } else {
                      setState(() {
                        _referenceDataDataSource =
                            ReferenceDataDataSource<dynamic>(
                              [],
                              (item) => '',
                              _onEdit,
                              _onDelete,
                            );
                      });
                    }
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<ReferenceDataDataSource<dynamic>> _getReferenceData(int index) async {
    switch (index) {
      case 0:
        var result = await turfTypeProvider.get();
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          (item) => (item as TurfType).name,
          _onEdit,
          _onDelete,
        );
      case 1:
        var result = await amenityProvider.get();
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          (item) => (item as Amenity).name,
          _onEdit,
          _onDelete,
        );
      case 2:
        var result = await cityProvider.get();
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          (item) => (item as City).name,
          _onEdit,
          _onDelete,
        );
      case 3:
        var result = await sportProvider.get();
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          (item) => (item as Sport).name ?? '',
          _onEdit,
          _onDelete,
        );
      case 4:
        var result = await roleProvider.get();
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          (item) => (item as Role).name ?? '',
          _onEdit,
          _onDelete,
        );
      default:
        return ReferenceDataDataSource<dynamic>(
          [],
          (item) => '',
          _onEdit,
          _onDelete,
        );
    }
  }
}

class ReferenceDataDataSource<T> extends DataTableSource {
  final List<T> _items;
  final String Function(T) _nameExtractor;
  final Function(int) _onEdit;
  final Function(int) _onDelete;

  ReferenceDataDataSource(
    this._items,
    this._nameExtractor,
    this._onEdit,
    this._onDelete,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= _items.length) return null;
    final item = _items[index];
    return DataRow(
      cells: [
        DataCell(Text(_nameExtractor(item))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                onPressed: () => _onEdit(index),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  minimumSize: Size(80, 36),
                ),
                child: Text("Edit", style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => _onDelete(index),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  minimumSize: Size(80, 36),
                ),
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _items.length;

  @override
  int get selectedRowCount => 0;
}
