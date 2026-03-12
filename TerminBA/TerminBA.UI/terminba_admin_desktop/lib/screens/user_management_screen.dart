import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/user.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/user_provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  Map<String, dynamic> _initValue = {'search': null, 'city': null};

  late UserDataSource _userDataSource;
  late UserProvider _userProvider;
  late CityProvider _cityProvider;
  bool _providersInitialized = false;
  List<City> cities = <City>[];
  bool _citySelected = false;

  @override
  void initState() {
    super.initState();
    _userDataSource = UserDataSource([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = context.read<UserProvider>();
    _cityProvider = context.read<CityProvider>();

    if (!_providersInitialized) {
      _providersInitialized = true;
      _loadUsers();
      _loadCities();
    }
  }

  Future<void> _loadUsers() async {
    try {
      var result = await _userProvider.get();
      setState(() {
        _userDataSource = UserDataSource(result.items ?? []);
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  Future<void> _loadCities() async {
    try {
      var result = await _cityProvider.get();
      setState(() {
        cities = result.items ?? [];
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'User Management',
      child: Center(
        child: Column(children: [_buildSearchForm(), _buildResultView()]),
      ),
    );
  }

  Widget _buildResultView() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            rowsPerPage: 10,
            columns: [
              DataColumn(label: Text("Id")),
              DataColumn(label: Text("First Name")),
              DataColumn(label: Text("Last Name")),
              DataColumn(label: Text("Age")),
              DataColumn(label: Text("Username")),
              DataColumn(label: Text("Email")),
              DataColumn(label: Text("Phone Number")),
              DataColumn(label: Text("Instagram")),
              DataColumn(label: Text("Birth Date")),
              DataColumn(label: Text("City")),
              DataColumn(label: Text("Active")),
              DataColumn(label: Text("Created At")),
              DataColumn(label: Text("Updated At")),
            ],
            source: _userDataSource,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilder(
        key: formKey,
        initialValue: _initValue,
        child: Row(
          children: [
            SizedBox(
              width: 310,
              child: FormBuilderTextField(
                name: 'search',
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 200,
              child: FormBuilderDropdown(
                name: 'city',
                initialValue: null,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                iconSize: _citySelected ? 0 : 24,
                onChanged: (value) {
                  setState(() => _citySelected = value != null);
                },
                decoration: InputDecoration(
                  hintText: 'Location',
                  border: const OutlineInputBorder(),
                  suffixIcon: _citySelected
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            formKey.currentState!.fields['city']?.reset();
                            setState(() => _citySelected = false);
                          },
                        )
                      : null,
                ),
                items: cities
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.saveAndValidate() ?? false) {
                  final values = formKey.currentState!.value;
                  try {
                    var result = await _userProvider.get(
                      filter: {
                        if (values['search'] != null &&
                            (values['search'] as String).isNotEmpty)
                          'fullName': values['search'],
                        if (values['city'] != null) 'cityId': values['city'],
                      },
                    );
                    setState(() {
                      _userDataSource = UserDataSource(result.items ?? []);
                    });
                  } catch (e) {
                    debugPrint('Search error: $e');
                  }
                }
              },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDataSource extends DataTableSource {
  final List<User> _users;

  UserDataSource(this._users);

  @override
  DataRow? getRow(int index) {
    if (index >= _users.length) return null;
    final user = _users[index];
    return DataRow(
      cells: [
        DataCell(Text(user.id.toString())),
        DataCell(Text(user.firstName)),
        DataCell(Text(user.lastName)),
        DataCell(Text(user.age?.toString() ?? '')),
        DataCell(Text(user.username)),
        DataCell(Text(user.email)),
        DataCell(Text(user.phoneNumber)),
        DataCell(Text(user.instagramAccount ?? 'Not provided')),
        DataCell(Text(user.birthDate.toLocal().toString().split(' ')[0])),
        DataCell(Text(user.city?.name ?? '')),
        DataCell(Text(user.isActive ? 'Yes' : 'No')),
        DataCell(
          Text(user.createdAt?.toLocal().toString().split(' ')[0] ?? ''),
        ),
        DataCell(
          Text(user.updatedAt?.toLocal().toString().split(' ')[0] ?? ''),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _users.length;

  @override
  int get selectedRowCount => 0;
}
