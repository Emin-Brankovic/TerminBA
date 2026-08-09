import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/turf_type.dart';
import 'package:terminba_sport_center_desktop/providers/auth_provider.dart';
import 'package:terminba_sport_center_desktop/providers/facility_provider.dart';
import 'package:terminba_sport_center_desktop/screens/facility_insert_screen.dart';
import 'package:terminba_sport_center_desktop/providers/sport_provider.dart';
import 'package:terminba_sport_center_desktop/providers/turf_type_provider.dart';
import 'package:terminba_sport_center_desktop/widgets/facility_card.dart';
import 'package:terminba_sport_center_desktop/widgets/universal_pagination.dart';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiescreenState();
}

class _FacilitiescreenState extends State<FacilitiesScreen> {
  late FacilityProvider _facilityProvider;
  late SportProvider _sportProvider;
  late TurfTypeProvider _turfTypeProvider;
  late AuthProvider _authProvider;
  static const int _pageSize = 8;
  List<Facility> _facilities = [];
  List<Sport> _sports = [];
  List<TurfType> _turfTypes = [];
  int? _selectedSportId;
  int? _selectedTurfTypeId;
  bool? _selectedIsIndoor;
  
  int? _formSportId;
  int? _formTurfTypeId;
  bool? _formIsIndoor;
  bool _isLoading = false;
  bool _initialized = false;
  bool _showFilters = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int totalItems = 0;
  final TextEditingController _searchController = TextEditingController();

  static const Duration _searchDebounceDuration = Duration(milliseconds: 450);
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      _loadFacilities(page: 1);
    });
  }

  void _applyFilters() {
    setState(() {
      _selectedSportId = _formSportId;
      _selectedTurfTypeId = _formTurfTypeId;
      _selectedIsIndoor = _formIsIndoor;
    });
    _loadFacilities(page: 1);
  }

  void _clearFilters() {
    setState(() {
      _formSportId = null;
      _formTurfTypeId = null;
      _formIsIndoor = null;
      _selectedSportId = null;
      _selectedTurfTypeId = null;
      _selectedIsIndoor = null;
    });
    _loadFacilities(page: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _facilityProvider = context.read<FacilityProvider>();
    _sportProvider = context.read<SportProvider>();
    _turfTypeProvider = context.read<TurfTypeProvider>();
    _authProvider = context.read<AuthProvider>();
    if (!_initialized) {
      _initialized = true;
      _loadSports();
      _loadTurfTypes();
      _loadFacilities(page: 1);
    }
  }

  Future<void> _loadSports() async {
    try {
      final result = await _sportProvider.get();
      setState(() {
        _sports = result.items ?? [];
      });
    } catch (e) {
      debugPrint('Error loading sports: $e');
    }
  }

  Future<void> _loadTurfTypes() async {
    try {
      final result = await _turfTypeProvider.get();
      setState(() {
        _turfTypes = result.items ?? [];
      });
    } catch (e) {
      debugPrint('Error loading turf types: $e');
    }
  }

  Future<void> _loadFacilities({int? page}) async {
    setState(() => _isLoading = true);
    try {
      final int targetPage = page ?? _currentPage;
      final int? currentUserId = _authProvider.isLoggedIn ? await _authProvider.getCurrentUserId() : null;
      final filter = <String, dynamic>{
        if (_searchController.text.trim().isNotEmpty)
          'name': _searchController.text.trim(),
        if (_selectedSportId != null) 'sportId': _selectedSportId,
        if (_selectedTurfTypeId != null) 'turfTypeId': _selectedTurfTypeId,
        if (_selectedIsIndoor != null) 'isIndoor': _selectedIsIndoor,
        'page': targetPage,
        'pageSize': _pageSize,
        'sportCenterId': currentUserId,
      };


      final result = await _facilityProvider.get(filter: filter);
      totalItems = result.totalCount ?? 0;
      final int calculatedTotalPages =
          totalItems == 0 ? 1 : ((totalItems + _pageSize - 1) ~/ _pageSize);

      final facilities = result.items ?? [];

      setState(() {
        _facilities = facilities;
        _currentPage = targetPage;
        _totalPages = calculatedTotalPages;
      });
    } catch (e) {
      debugPrint('Error loading facilities: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Facilities',
      child: Container(
        color: const Color(0xFFF4F6F8),
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 22),
            _buildSearchRow(),
            if (_showFilters) ...[
              const SizedBox(height: 10),
              _buildFilterForm(),
            ],
            const SizedBox(height: 18),
            _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const FacilityInsertScreen()),
                );

                if (created == true) {
                  _loadFacilities(page: 1);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Add Facility"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 430,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) {
                    _searchDebounce?.cancel();
                    _loadFacilities(page: 1);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search keywords',
                    hintStyle: const TextStyle(
                      color: Color(0xFF97A1AF),
                      fontSize: 14,
                    ),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF7F8895),
                      size: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFA9B3BF)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 34,
                height: 34,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Color(0xFFD1D6DD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.filter_list, color: Color(0xFF4B5563), size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: SizedBox(
          width: 1000,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _formSportId,
                  iconSize: _formSportId != null ? 0 : 24,
                  decoration: InputDecoration(
                    labelText: 'Sport',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _formSportId != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _formSportId = null;
                              });
                            },
                          )
                        : null,
                  ),
                  items: _sports
                      .map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _formSportId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _formTurfTypeId,
                  iconSize: _formTurfTypeId != null ? 0 : 24,
                  decoration: InputDecoration(
                    labelText: 'Turf type',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _formTurfTypeId != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _formTurfTypeId = null;
                              });
                            },
                          )
                        : null,
                  ),
                  items: _turfTypes
                      .map(
                        (t) => DropdownMenuItem<int?>(
                          value: t.id,
                          child: Text(t.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _formTurfTypeId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<bool?>(
                  value: _formIsIndoor,
                  iconSize: _formIsIndoor != null ? 0 : 24,
                  decoration: InputDecoration(
                    labelText: 'Indoor/Outdoor',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _formIsIndoor != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _formIsIndoor = null;
                              });
                            },
                          )
                        : null,
                  ),
                  items: const [
                    DropdownMenuItem<bool?>(
                      value: true,
                      child: Text('Indoor'),
                    ),
                    DropdownMenuItem<bool?>(
                      value: false,
                      child: Text('Outdoor'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _formIsIndoor = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Apply'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (_facilities.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No facilities found.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    var screenWidth = MediaQuery.of(context).size.width;
    int itemCount;
    if (screenWidth < 1000) {
      itemCount = 2;
    } else if (screenWidth < 1400) {
      itemCount = 3;
    } else {
      itemCount = 4;
    }

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 14),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: itemCount,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _facilities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FacilityCard(
                      facility: _facilities[index],
                      onDelete: _onDelete,
                      onRefresh: () => _loadFacilities(page: _currentPage),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UniversalPagination(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) => _loadFacilities(page: page),
            ),
          ),
        ],
      ),
    );
  }

  void _onDelete(int id) async {
    try {
      await _facilityProvider.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facility deleted successfully.')),
      );

      final totalItemsAfterDeletion = totalItems - 1;
      final page = ((totalItemsAfterDeletion + _pageSize - 1) ~/ _pageSize);
      _loadFacilities(page: page == 0 ? 1 : page);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete facility.')),
      );
      debugPrint('Error deleting facility: $e');
    }
  }

}
