import 'package:flutter/material.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';

class ReferenceDataScreen extends StatefulWidget {
  const ReferenceDataScreen({super.key});

  @override
  State<ReferenceDataScreen> createState() => _ReferenceDataScreenState();
}

class _ReferenceDataScreenState extends State<ReferenceDataScreen> {
  int? _selectedIndex; // Track which index is selected
  List<String> categories = ['Turf Type', 'Amenity', 'City', 'Sport', 'Role'];
  final List<String> genres = [
    'Sarajevo',
    'Mostar',
    'Bajna Luka',
    'Tuzla',
    'Široki Brijeg',
    'Tešanj',
    'Bihać',
  ];
  late GenreDataSource _genreDataSource;

  @override
  void initState() {
    super.initState();
    _genreDataSource = GenreDataSource(genres, _onEdit, _onDelete);
  }

  void _onEdit(int index) {
    // Implement edit logic here
  }

  void _onDelete(int index) {
    // Implement delete logic here
  }
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reference Data',
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeaderChips(), // Section 1: Navigation     // Section 2: "Dodaj novi žanr"
            _buildListSection(), // Section 3: The Data List
          ],
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
                columnWidth:const FixedColumnWidth(20),
                headingRowAlignment: MainAxisAlignment.center,
                label: Padding(
                  padding: const EdgeInsets.only(left: 130),
                  child: Text("Actions"),
                ),
              ),
            ],
            source: _genreDataSource,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Wrap(
        spacing: 12,
        children: List<Widget>.generate(categories.length, (int index) {
          return ChoiceChip(
            label: Text(categories[index]),
            selected: _selectedIndex == index,
            onSelected: (bool selected) {
              setState(() {
                _selectedIndex = selected ? index : null;
              });
            },
          );
        }),
      ),
    );
  }
}

class GenreDataSource extends DataTableSource {
  final List<String> _items;
  final Function(int) _onEdit;
  final Function(int) _onDelete;

  GenreDataSource(this._items, this._onEdit, this._onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= _items.length) return null;
    final item = _items[index];
    return DataRow(
      cells: [
        DataCell(Text(item)),
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
