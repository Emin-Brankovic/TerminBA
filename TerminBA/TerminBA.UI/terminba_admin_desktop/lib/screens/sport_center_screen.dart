import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/sport_center.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_center_provider.dart';
import 'package:terminba_admin_desktop/screens/sport_center_insert_screen.dart';
import 'package:terminba_admin_desktop/widgets/sport_center_card.dart';
import 'package:terminba_admin_desktop/widgets/universal_pagination.dart';

class SportCenterScreen extends StatefulWidget {
  const SportCenterScreen({super.key});

  @override
  State<SportCenterScreen> createState() => _SportCenterScreenState();
}

class _SportCenterScreenState extends State<SportCenterScreen> {
  late SportCenterProvider _sportCenterProvider;
  late CityProvider _cityProvider;
  static const int _pageSize = 8;
  List<SportCenter> _sportCenters = [];
  List<City> _cities = [];
  int? _selectedCityId;
  bool _isLoading = false;
  bool _initialized = false;
  bool _citySelected = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int totalItems = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sportCenterProvider = context.read<SportCenterProvider>();
    _cityProvider = context.read<CityProvider>();
    if (!_initialized) {
      _initialized = true;
      _loadCities();
      _loadSportCenters(page: 1);
    }
  }

  Future<void> _loadCities() async {
    try {
      final result = await _cityProvider.get(filter: {'PageSize': 100});
      setState(() {
        _cities = result.items ?? [];
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  Future<void> _loadSportCenters({int? page}) async {
    setState(() => _isLoading = true);
    try {
      final int targetPage = page ?? _currentPage;
      final filter = <String, dynamic>{
        if (_searchController.text.trim().isNotEmpty)
          'name': _searchController.text.trim(),
        if (_selectedCityId != null) 'cityId': _selectedCityId,
        'page': targetPage,
        'pageSize': _pageSize,
      };

      var result = await _sportCenterProvider.get(filter: filter);
      totalItems = result.totalCount ?? 0;
      final int calculatedTotalPages = totalItems == 0
          ? 1
          : ((totalItems + _pageSize - 1) ~/ _pageSize);

      setState(() {
        _sportCenters = result.items ?? [];
        _currentPage = targetPage;
        _totalPages = calculatedTotalPages;
      });
    } catch (e) {
      debugPrint('Error loading sport centers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Sport Center',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SportCenterInsertScreen(),
                ),
              );
              _loadSportCenters(page: _currentPage);
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text("Add Sport Center"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 380,
                    height: 42,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search sport centers...",
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: Colors.white,
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
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                        ),
                      ),
                      controller: _searchController,
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    height: 42,
                    child: DropdownButtonFormField<int?>(
                      value: _selectedCityId,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                      iconSize: _citySelected ? 0 : 20,
                      decoration: InputDecoration(
                        hintText: 'All Cities',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 17, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                        ),
                        suffixIcon: _citySelected
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _selectedCityId = null;
                                    _citySelected = false;
                                  });
                                  _onSearch();
                                },
                              )
                            : null,
                      ),
                      items: _cities
                          .map(
                            (c) => DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                          _citySelected = value != null;
                        });
                        _onSearch();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _onSearch,
                    icon: const Icon(Icons.search_rounded, size: 16),
                    label: const Text("Search"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(96, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

    if (_sportCenters.isEmpty) {
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
                mainAxisExtent: 480,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _sportCenters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SportCenterCard(
                    sportCenter: _sportCenters[index],
                    onDelete: _onDelete,
                    onRefresh: () => _loadSportCenters(page: _currentPage),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          UniversalPagination(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: (page) => _loadSportCenters(page: page),
          ),
        ],
      ),
    );
  }

  void _onDelete(int id) async {
    try {
      await _sportCenterProvider.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sport center deleted successfully.')),
      );

      final totalItemsAfterDeletion = totalItems - 1;
      final page = ((totalItemsAfterDeletion + _pageSize - 1) ~/ _pageSize);
      _loadSportCenters(page: page);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete sport center.')),
      );
      debugPrint('Error deleting sport center: $e');
    }
  }

  void _onSearch() {
    _loadSportCenters(page: 1);
  }
}
