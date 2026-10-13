import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/amenity.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/role.dart';
import 'package:terminba_admin_desktop/model/sport.dart';
import 'package:terminba_admin_desktop/model/turf_type.dart';
import 'package:terminba_admin_desktop/model/skill_level.dart';
import 'package:terminba_admin_desktop/providers/amenity_provider.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/role_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_provider.dart';
import 'package:terminba_admin_desktop/providers/turf_type_provider.dart';
import 'package:terminba_admin_desktop/providers/skill_level_provider.dart';
import 'package:terminba_admin_desktop/widgets/confirmation_dialog.dart';

class ReferenceDataScreen extends StatefulWidget {
  const ReferenceDataScreen({super.key});

  @override
  State<ReferenceDataScreen> createState() => _ReferenceDataScreenState();
}

class _ReferenceDataScreenState extends State<ReferenceDataScreen> {
  int? _selectedIndex = 0; 
  List<String> categories = ['Turf Type', 'Amenity', 'City', 'Sport', 'Role', 'Skill Level'];
  final List<String> data = [];
  late ReferenceDataDataSource<dynamic> _referenceDataDataSource;
  final TextEditingController _searchController = TextEditingController();
  int _currentFirstRowIndex = 0;
  int _rowsPerPage = 10;

  late AmenityProvider amenityProvider;
  late TurfTypeProvider turfTypeProvider;
  late CityProvider cityProvider;
  late SportProvider sportProvider;
  late RoleProvider roleProvider;
  late SkillLevelProvider skillLevelProvider;

  bool _providersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    amenityProvider = context.read<AmenityProvider>();
    turfTypeProvider = context.read<TurfTypeProvider>();
    cityProvider = context.read<CityProvider>();
    sportProvider = context.read<SportProvider>();
    roleProvider = context.read<RoleProvider>();
    skillLevelProvider = context.read<SkillLevelProvider>();
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
      0,
      0,
      (item) => '',
      _onEdit,
      _onDelete,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshTable({int? firstRowIndex}) async {
    if (_selectedIndex == null) return;
    
    if (firstRowIndex != null) {
      _currentFirstRowIndex = firstRowIndex;
    }

    var source = await _getReferenceData(_selectedIndex!, _currentFirstRowIndex);
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
                  } else if (categories[_selectedIndex!] == 'Skill Level') {
                    await skillLevelProvider.insert({"name": name});
                  }

                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${categories[_selectedIndex!]} added successfully',
                      ),
                    ),
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
              } else if (currentItem is SkillLevel) {
                await skillLevelProvider.update(currentItem.id!, {
                  "name": controller.text,
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${categories[_selectedIndex!]} updated successfully',
                  ),
                ),
              );

              await _refreshTable();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onDelete(int index) async {
    var currentItem = _referenceDataDataSource._items[index];

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete this item? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmButtonColor: const Color(0xFFFF3D00),
    );

    if (!confirmed) return;

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
    } else if (currentItem is SkillLevel) {
      await skillLevelProvider.delete(currentItem.id!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${categories[_selectedIndex!]} deleted successfully',
          ),
        ),
      );
    }

    await _refreshTable();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reference Data',
      child: Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildActionBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildTableCard(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(int index) {
    switch (index) {
      case 0:
        return Icons.grass;
      case 1:
        return Icons.star_outline_rounded;
      case 2:
        return Icons.location_city_outlined;
      case 3:
        return Icons.sports_soccer_outlined;
      case 4:
        return Icons.badge_outlined;
      case 5:
        return Icons.bar_chart_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: List<Widget>.generate(categories.length, (int index) {
          final isSelected = _selectedIndex == index;
          return Material(
            color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                if (_selectedIndex != index) {
                  setState(() {
                    _selectedIndex = index;
                    _searchController.clear();
                    _currentFirstRowIndex = 0;
                  });
                  final source = await _getReferenceData(index, _currentFirstRowIndex);
                  setState(() {
                    _referenceDataDataSource = source;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _categoryIcon(index),
                      size: 15,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      categories[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: _onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            'Add ${categories[_selectedIndex!]}',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            minimumSize: const Size(0, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search ${categories[_selectedIndex!].toLowerCase()}s...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            _refreshTable();
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _refreshTable(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _refreshTable(),
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('Search', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: const Color(0xFFF1F5F9),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.transparent,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: PaginatedDataTable(
                  rowsPerPage: _rowsPerPage,
                  availableRowsPerPage: const [10, 20, 50],
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _rowsPerPage = value ?? 10;
                      _currentFirstRowIndex = 0;
                    });
                    _refreshTable();
                  },
                  onPageChanged: (firstRowIndex) {
                    _refreshTable(firstRowIndex: firstRowIndex);
                  },
                  columns: const [
                    DataColumn(
                      label: Text(
                        "NAME",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.end,
                      label: SizedBox(
                        width: 170,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "ACTIONS",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  source: _referenceDataDataSource,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<ReferenceDataDataSource<dynamic>> _getReferenceData(int index, int firstRowIndex) async {
    final pageNumber = (firstRowIndex ~/ _rowsPerPage) + 1;
    Map<String, dynamic> filter = {
      'PageSize': _rowsPerPage,
      'Page': pageNumber,
    };
    if (_searchController.text.isNotEmpty) {
      final search = _searchController.text;
      if (index == 0) filter['name'] = search;
      else if (index == 1) filter['name'] = search;
      else if (index == 2) filter['cityName'] = search;
      else if (index == 3) filter['sportName'] = search;
      else if (index == 4) filter['roleName'] = search;
      else if (index == 5) filter['name'] = search;
    }

    final catIcon = _categoryIcon(index);

    switch (index) {
      case 0:
        var result = await turfTypeProvider.get(filter: filter);
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          result.totalCount ?? 0,
          firstRowIndex,
          (item) => (item as TurfType).name,
          _onEdit,
          _onDelete,
          iconData: catIcon,
        );
      case 1:
        var result = await amenityProvider.get(filter: filter);
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          result.totalCount ?? 0,
          firstRowIndex,
          (item) => (item as Amenity).name,
          _onEdit,
          _onDelete,
          iconData: catIcon,
        );
      case 2:
        var result = await cityProvider.get(filter: filter);
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          result.totalCount ?? 0,
          firstRowIndex,
          (item) => (item as City).name,
          _onEdit,
          _onDelete,
          iconData: catIcon,
        );
      case 3:
        var result = await sportProvider.get(filter: filter);
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          result.totalCount ?? 0,
          firstRowIndex,
          (item) => (item as Sport).name ?? '',
          _onEdit,
          _onDelete,
          iconData: catIcon,
        );
      case 4:
        var result = await roleProvider.get(filter: filter);
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          result.totalCount ?? 0,
          firstRowIndex,
          (item) => (item as Role).name ?? '',
          _onEdit,
          _onDelete,
          iconData: catIcon,
        );
      case 5:
        var result = await skillLevelProvider.get(filter: filter);
        return ReferenceDataDataSource<dynamic>(
          List<dynamic>.from(result.items ?? []),
          result.totalCount ?? 0,
          firstRowIndex,
          (item) => (item as SkillLevel).name ?? '',
          _onEdit,
          _onDelete,
          iconData: catIcon,
        );
      default:
        return ReferenceDataDataSource<dynamic>(
          [],
          0,
          firstRowIndex,
          (item) => '',
          _onEdit,
          _onDelete,
          iconData: catIcon,
        );
    }
  }
}

class ReferenceDataDataSource<T> extends DataTableSource {
  final List<T> _items;
  final int _totalCount;
  final int _startingIndex;
  final String Function(T) _nameExtractor;
  final Function(int) _onEdit;
  final Function(int) _onDelete;
  final IconData? iconData;

  ReferenceDataDataSource(
    this._items,
    this._totalCount,
    this._startingIndex,
    this._nameExtractor,
    this._onEdit,
    this._onDelete, {
    this.iconData,
  });

  @override
  DataRow? getRow(int index) {
    int localIndex = index - _startingIndex;
    if (localIndex < 0 || localIndex >= _items.length) return null;
    final item = _items[localIndex];
    return DataRow(
      cells: [
        DataCell(
          Text(
            _nameExtractor(item),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: InkWell(
                  onTap: () => _onEdit(index),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: Color(0xFF2563EB)),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: InkWell(
                  onTap: () => _onDelete(index),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
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
  int get rowCount => _totalCount;

  @override
  int get selectedRowCount => 0;
}
