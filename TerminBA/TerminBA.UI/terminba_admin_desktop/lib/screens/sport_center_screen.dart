import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/sport_center.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_center_provider.dart';
import 'package:terminba_admin_desktop/screens/sport_center_insert_screen.dart';
import 'package:terminba_admin_desktop/widgets/sport_center_card.dart';

class SportCenterScreen extends StatefulWidget {
  const SportCenterScreen({super.key});

  @override
  State<SportCenterScreen> createState() => _SportCenterScreenState();
}

class _SportCenterScreenState extends State<SportCenterScreen> {
  late SportCenterProvider _sportCenterProvider;
  late CityProvider _cityProvider;
  List<SportCenter> _sportCenters = [];
  List<City> _cities = [];
  int? _selectedCityId;
  bool _isLoading = false;
  bool _initialized = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sportCenterProvider = context.read<SportCenterProvider>();
    _cityProvider = context.read<CityProvider>();
    if (!_initialized) {
      _initialized = true;
      _loadCities();
      _loadSportCenters();
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

  Future<void> _loadSportCenters() async {
    setState(() => _isLoading = true);
    try {
      var result = await _sportCenterProvider.get();
      setState(() {
        _sportCenters = result.items ?? [];
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
              _loadSportCenters();
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
              onRefresh: _loadSportCenters,
            ),
          );
        },
      ),
    );
  }

  void _onDelete(int id) async {
    try {
      await _sportCenterProvider.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sport center deleted successfully.')),
      );
      _loadSportCenters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete sport center.')),
      );
      debugPrint('Error deleting sport center: $e');
    }
  }

  void _onSearch() async {
    // Implement search logic here
    print("Searching for: ${_searchController.text}");

    try {
      final filter = <String, dynamic>{
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_selectedCityId != null) 'cityId': _selectedCityId,
      };
      var result = await _sportCenterProvider.get(filter: filter);

      setState(() {
        _sportCenters = result.items ?? [];
      });
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }
}
