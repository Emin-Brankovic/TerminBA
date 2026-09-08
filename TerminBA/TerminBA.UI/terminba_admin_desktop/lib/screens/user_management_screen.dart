import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/widgets/universal_pagination.dart';
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

  late UserProvider _userProvider;
  late CityProvider _cityProvider;
  bool _providersInitialized = false;
  List<City> cities = <City>[];
  bool _citySelected = false;
  int? _selectedCityId;
  
  int _currentPage = 1;
  int _totalPages = 1;
  static const int _pageSize = 10;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadUsers({int? page}) async {
    final int targetPage = page ?? _currentPage;
    try {
      final filter = <String, dynamic>{
        'page': targetPage,
        'pageSize': _pageSize,
      };

      if (formKey.currentState?.saveAndValidate() ?? false) {
        final values = formKey.currentState!.value;
        if (values['search'] != null && (values['search'] as String).isNotEmpty) {
          filter['fullName'] = values['search'];
        }
      }
      
      if (_selectedCityId != null) {
        filter['cityId'] = _selectedCityId;
      }

      var result = await _userProvider.get(filter: filter);
      int totalItems = result.totalCount ?? 0;
      
      setState(() {
        _users = result.items ?? [];
        _currentPage = targetPage;
        _totalPages = totalItems == 0 ? 1 : ((totalItems + _pageSize - 1) ~/ _pageSize);
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  Future<void> _loadCities() async {
    try {
      var result = await _cityProvider.get(filter: {'PageSize': 100});
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Id")),
                      DataColumn(label: Text("First Name")),
                      DataColumn(label: Text("Last Name")),
                      DataColumn(label: Text("Username")),
                      DataColumn(label: Text("Email")),
                      DataColumn(label: Text("Phone Number")),
                      DataColumn(label: Text("Instagram")),
                      DataColumn(label: Text("Birth Date")),
                      DataColumn(label: Text("City")),
                      DataColumn(label: Text("Created At")),
                      DataColumn(label: Text("Updated At")),
                    ],
                    rows: _users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user.id.toString())),
                          DataCell(Text(user.firstName)),
                          DataCell(Text(user.lastName)),
                          DataCell(Text(user.username)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.phoneNumber)),
                          DataCell(Text(user.instagramAccount ?? 'Not provided')),
                          DataCell(Text(user.birthDate.toLocal().toString().split(' ')[0])),
                          DataCell(Text(user.city?.name ?? '')),
                          DataCell(Text(user.createdAt?.toLocal().toString().split(' ')[0] ?? '')),
                          DataCell(Text(user.updatedAt?.toLocal().toString().split(' ')[0] ?? '')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            UniversalPagination(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) => _loadUsers(page: page),
            ),
          ],
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
              width: 180,
              child: DropdownButtonFormField<int?>(
                value: _selectedCityId,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                iconSize: _citySelected ? 0 : 24,
                onChanged: (value) {
                  setState(() {
                    _selectedCityId = value;
                    _citySelected = value != null;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'City',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  suffixIcon: _citySelected
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedCityId = null;
                              _citySelected = false;
                            });
                          },
                        )
                      : null,
                ),
                items: cities
                    .map(
                      (c) =>
                          DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _loadUsers(page: 1),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

