import 'package:flutter/material.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late UserDataSource _userDataSource;
  String? _selectedFilter;
 List<String> list = <String>['Sarajevo', 'Mostar', 'Tuzla', 'Konjic'];

  @override
  void initState() {
    super.initState();
    List<dynamic> users = [
      {
        'id': 1,
        'firstName': 'John',
        'lastName': 'Doe',
        'age': 25,
        'username': 'johndoe',
        'email': 'john.doe@example.com',
        'phoneNumber': '+387 61 123 456',
        'instagramAccount': '@johndoe',
        'birthDate': '1999-01-15',
        'cityId': 1,
        'city': 'Sarajevo',
        'roleId': 1,
        'role': 'User',
        'isActive': true,
        'createdAt': '2024-01-01',
        'updatedAt': '2024-06-15'
      },
      {
        'id': 2,
        'firstName': 'Jane',
        'lastName': 'Smith',
        'age': 30,
        'username': 'janesmith',
        'email': 'jane.smith@example.com',
        'phoneNumber': '+387 62 234 567',
        'instagramAccount': '@janesmith',
        'birthDate': '1994-05-22',
        'cityId': 2,
        'city': 'Mostar',
        'roleId': 2,
        'role': 'Admin',
        'isActive': true,
        'createdAt': '2024-02-10',
        'updatedAt': '2024-07-20'
      }
    ];
    _userDataSource = UserDataSource(users);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'User Management',
      child: Center(
        child: Column(
          children: [
            _buildSearch(),
            _buildResultView(),
          ],
        ),      ),
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
              DataColumn(label: Text("Role")),
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

    Widget _buildSearch() {
    String? _dropdownValue=list.first; 
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              hint: Text("Filter"),
              // decoration: InputDecoration(
              //   hintText: "Filter",
              //   border: OutlineInputBorder(),
              // ),
              value: _selectedFilter,
              items: [
                DropdownMenuItem(value: "all", child: Text("All")),
                DropdownMenuItem(value: "active", child: Text("Active")),
                DropdownMenuItem(value: "inactive", child: Text("Inactive")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: DropdownMenu<String>(
              hintText: "Location",
              onSelected: (String? value) {
                setState(() {
                  _dropdownValue = value;
                });
              },
              dropdownMenuEntries: [
                DropdownMenuEntry(value: "Sarajevo", label: "Sarajevo"),
                DropdownMenuEntry(value: "Mostar", label: "Mostar"),
                DropdownMenuEntry(value: "Tuzla", label: "Tuzla"),
                DropdownMenuEntry(value: "Konjic", label: "Konjic"),
              ],
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Implement search logic here
            },
            child: Text("Search"),
          ),
        ],
      ),
    );
  }
  
}

class UserDataSource extends DataTableSource {
  final List<dynamic> _users;

  UserDataSource(this._users);

  @override
  DataRow? getRow(int index) {
    if (index >= _users.length) return null;
    final user = _users[index];
    return DataRow(cells: [
      DataCell(Text(user['id'].toString())),
      DataCell(Text(user['firstName'] ?? '')),
      DataCell(Text(user['lastName'] ?? '')),
      DataCell(Text(user['age']?.toString() ?? '')),
      DataCell(Text(user['username'] ?? '')),
      DataCell(Text(user['email'] ?? '')),
      DataCell(Text(user['phoneNumber'] ?? '')),
      DataCell(Text(user['instagramAccount'] ?? '')),
      DataCell(Text(user['birthDate'] ?? '')),
      DataCell(Text(user['city'] ?? '')),
      DataCell(Text(user['role'] ?? '')),
      DataCell(Text(user['isActive'] == true ? 'Yes' : 'No')),
      DataCell(Text(user['createdAt'] ?? '')),
      DataCell(Text(user['updatedAt'] ?? '')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _users.length;

  @override
  int get selectedRowCount => 0;
}