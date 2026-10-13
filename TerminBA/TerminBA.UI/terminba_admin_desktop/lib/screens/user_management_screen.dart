import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/user.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/user_provider.dart';
import 'package:terminba_admin_desktop/screens/user_edit_screen.dart';
import 'package:terminba_admin_desktop/widgets/universal_pagination.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  static const double _tableMinWidth = 850;
  static const int _nameFlex = 4;
  static const int _usernameFlex = 2;
  static const int _emailFlex = 3;
  static const int _cityFlex = 2;
  static const int _datesFlex = 2;
  static const int _actionsFlex = 2;
  static const int _pageSize = 10;

  bool _initialized = false;
  bool _isLoading = true;

  late UserProvider _userProvider;
  late CityProvider _cityProvider;

  List<City> _cities = [];
  int? _selectedCityId;
  String _searchQuery = '';

  int _currentPage = 1;
  int _totalPages = 1;
  List<User> _users = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _userProvider = context.read<UserProvider>();
    _cityProvider = context.read<CityProvider>();

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadCities(),
        _loadUsers(),
      ]);
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCities() async {
    try {
      var result = await _cityProvider.get(filter: {'PageSize': 100});
      if (mounted) {
        setState(() {
          _cities = result.items ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  Future<void> _loadUsers({int? page}) async {
    final int targetPage = page ?? _currentPage;
    setState(() => _isLoading = true);
    
    try {
      final filter = <String, dynamic>{
        'page': targetPage,
        'pageSize': _pageSize,
      };

      if (_searchQuery.trim().isNotEmpty) {
        filter['fullName'] = _searchQuery.trim();
      }

      if (_selectedCityId != null) {
        filter['cityId'] = _selectedCityId;
      }

      var result = await _userProvider.get(filter: filter);
      int totalItems = result.totalCount ?? 0;

      if (mounted) {
        setState(() {
          _users = result.items ?? [];
          _currentPage = targetPage;
          _totalPages = totalItems == 0 ? 1 : ((totalItems + _pageSize - 1) ~/ _pageSize);
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(User user) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: Text("Are you sure you want to delete user ${user.username}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _userProvider.delete(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully.')),
          );
          await _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'User Management',
      child: Container(
        color: const Color(0xFFF2F3F5),
        child: Row(
          children: [
            _buildSidebar(),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF7F8FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              _searchQuery = value;
            },
            onSubmitted: (_) => _loadUsers(page: 1),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'City',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            value: _selectedCityId,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Cities'),
              ),
              ..._cities.map((city) => DropdownMenuItem<int?>(
                    value: city.id,
                    child: Text(city.name),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCityId = value;
              });
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _loadUsers(page: 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12B76A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = math.max(constraints.maxWidth, _tableMinWidth);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: _buildHeaderRow(),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                    Expanded(
                      child: _users.isEmpty
                          ? const Center(
                              child: Text(
                                'No users found.',
                                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _users.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              itemBuilder: (context, index) {
                                return _buildDataRow(_users[index], index);
                              },
                            ),
                    ),
                    if (_users.isNotEmpty) ...[
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: UniversalPagination(
                            currentPage: _currentPage,
                            totalPages: _totalPages,
                            onPageChanged: (page) => _loadUsers(page: page),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRow() {
    const headerStyle = TextStyle(
      fontSize: 11.5,
      color: Color(0xFF475569),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );

    return Row(
      children: [
        _buildHeaderCell('USER', _nameFlex, headerStyle),
        _buildHeaderCell('USERNAME', _usernameFlex, headerStyle),
        _buildHeaderCell('EMAIL', _emailFlex, headerStyle),
        _buildHeaderCell('CITY', _cityFlex, headerStyle),
        _buildHeaderCell('DATES', _datesFlex, headerStyle),
        _buildHeaderCell('ACTIONS', _actionsFlex, headerStyle, align: TextAlign.center),
      ],
    );
  }

  Widget _buildDataRow(User user, int index) {
    final bgColor = index % 2 == 0 ? Colors.white : const Color(0xFFFAFBFC);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User column with Full name + Subtitle info
          Expanded(
            flex: _nameFlex,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}'.trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (user.birthDate != null) ...[
                      const Icon(Icons.cake_outlined, size: 11, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 3),
                      Text(
                        _formatDate(user.birthDate),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (user.phoneNumber.isNotEmpty) ...[
                      const Icon(Icons.phone_outlined, size: 11, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          user.phoneNumber,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Username column
          Expanded(
            flex: _usernameFlex,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                child: Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Email column
          Expanded(
            flex: _emailFlex,
            child: Row(
              children: [
                const Icon(Icons.mail_outline_rounded, size: 13.5, color: Color(0xFF94A3B8)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // City column
          Expanded(
            flex: _cityFlex,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF2563EB)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        user.city?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Dates column
          Expanded(
            flex: _datesFlex,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(user.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Updated: ${_formatDate(user.updatedAt)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Actions column
          Expanded(
            flex: _actionsFlex,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => UserEditScreen(user: user)),
                      );
                      if (result == true) {
                        _loadUsers();
                      }
                    },
                    tooltip: 'Edit User',
                    iconSize: 16,
                    color: const Color(0xFF2563EB),
                    icon: const Icon(Icons.edit_outlined),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: IconButton(
                    onPressed: () => _deleteUser(user),
                    tooltip: 'Delete User',
                    iconSize: 16,
                    color: const Color(0xFFDC2626),
                    icon: const Icon(Icons.delete_outline_rounded),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, int flex, TextStyle style, {TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        textAlign: align,
      ),
    );
  }

  Widget _buildDataCell(String text, int flex, {bool isHighlighted = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: isHighlighted ? const Color(0xFF0F172A) : const Color(0xFF475569),
          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
