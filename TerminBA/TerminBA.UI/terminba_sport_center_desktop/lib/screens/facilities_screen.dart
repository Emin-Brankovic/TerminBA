import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/sport.dart';
import 'package:terminba_sport_center_desktop/model/turf_type.dart';
import 'package:terminba_sport_center_desktop/providers/facility_provider.dart';
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
  static const int _pageSize = 8;
  List<Facility> _facilities = [];
  List<Sport> _sports = [];
  List<TurfType> _turfTypes = [];
  int? _selectedSportId;
  int? _selectedTurfTypeId;
  bool? _selectedIsIndoor;
  bool _isLoading = false;
  bool _initialized = false;
  bool _showFilters = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int totalItems = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _facilityProvider = context.read<FacilityProvider>();
    _sportProvider = context.read<SportProvider>();
    _turfTypeProvider = context.read<TurfTypeProvider>();
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
      final filter = <String, dynamic>{
        if (_searchController.text.trim().isNotEmpty)
          'name': _searchController.text.trim(),
        if (_selectedSportId != null) 'sportId': _selectedSportId,
        if (_selectedTurfTypeId != null) 'turfTypeId': _selectedTurfTypeId,
        if (_selectedIsIndoor != null) 'isIndoor': _selectedIsIndoor,
        'page': targetPage,
        'pageSize': _pageSize,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildSearch(), _buildResult()],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              _loadFacilities(page: _currentPage);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 46), // width, height
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text("Add Facility"),
          ),

          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 400,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search facilities...",
                        suffixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      controller: _searchController,
                    ),
                  ),
                  if (_showFilters) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<int?>(
                        value: _selectedSportId,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        iconSize: _selectedSportId != null ? 0 : 24,
                        decoration: InputDecoration(
                          hintText: 'Sport',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          suffixIcon: _selectedSportId != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedSportId = null;
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
                            _selectedSportId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<int?>(
                        value: _selectedTurfTypeId,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        iconSize: _selectedTurfTypeId != null ? 0 : 24,
                        decoration: InputDecoration(
                          hintText: 'Turf type',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          suffixIcon: _selectedTurfTypeId != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedTurfTypeId = null;
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
                            _selectedTurfTypeId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<bool?>(
                        value: _selectedIsIndoor,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        iconSize: _selectedIsIndoor != null ? 0 : 24,
                        decoration: InputDecoration(
                          hintText: 'Indoor/Outdoor',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          suffixIcon: _selectedIsIndoor != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedIsIndoor = null;
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
                            _selectedIsIndoor = value;
                          });
                        },
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Filters',
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _onSearch();
                    },
                    child: const Text("Search"),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            'No results found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
            child: GridView.builder(
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
          const SizedBox(height: 6),
          UniversalPagination(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: (page) => _loadFacilities(page: page),
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

  void _onSearch() {
    _loadFacilities(page: 1);
  }
}
