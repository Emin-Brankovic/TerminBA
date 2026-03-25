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
      final result = await _cityProvider.get();
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
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SportCenterInsertScreen(),
                ),
              );
              _loadSportCenters(page: _currentPage);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 46), // width, height
              textStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
            ),
            child: const Text("Add Sport Center"),
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
                        hintText: "Search sport centers...",
                        suffixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      controller: _searchController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<int?>(
                      value: _selectedCityId,
                      decoration: const InputDecoration(
                        hintText: 'All cities',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'City',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                        ..._cities.map(
                          (c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCityId = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _onSearch();
                    },
                    child: Text("Search"),
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
              itemCount: _sportCenters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FacilityCard(
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
