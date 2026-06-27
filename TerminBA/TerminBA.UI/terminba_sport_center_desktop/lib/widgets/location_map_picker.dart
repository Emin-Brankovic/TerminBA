import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationMapPickerDialog extends StatefulWidget {
  const LocationMapPickerDialog({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  /// Convenience helper to open the dialog.
  static Future<LatLng?> show(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
  }) {
    return showDialog<LatLng>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LocationMapPickerDialog(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
    );
  }

  @override
  State<LocationMapPickerDialog> createState() =>
      _LocationMapPickerDialogState();
}

class _LocationMapPickerDialogState extends State<LocationMapPickerDialog> {
  static const _defaultCenter = LatLng(43.8563, 18.4131);

  late LatLng _pinPosition;
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pinPosition = (widget.initialLatitude != null &&
            widget.initialLongitude != null)
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _defaultCenter;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Nominatim address search ─────────────────────────────────────────────────

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {'q': query, 'format': 'json', 'limit': '1'},
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'TerminBA-SportCenterManager/1.0'},
      );

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List<dynamic>;
        if (results.isNotEmpty) {
          final first = results.first as Map<String, dynamic>;
          final lat = double.parse(first['lat'] as String);
          final lng = double.parse(first['lon'] as String);
          final newPos = LatLng(lat, lng);
          setState(() => _pinPosition = newPos);
          _mapController.move(newPos, 15.0);
        } else {
          setState(() => _searchError = 'No results found for "".');
        }
      } else {
        setState(
          () => _searchError = 'Search failed (HTTP ).',
        );
      }
    } catch (_) {
      setState(
        () => _searchError =
            'Could not reach search service. Check your connection.',
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleBar(context),
            const Divider(height: 1),
            _buildSearchBar(),
            if (_searchError != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  _searchError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            Expanded(child: _buildMap()),
            const Divider(height: 1),
            _buildCoordReadout(),
            const Divider(height: 1),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, size: 22),
          const SizedBox(width: 10),
          Text(
            'Pick Location',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search address...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _searchAddress,
                  tooltip: 'Search',
                ),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
        onSubmitted: (_) => _searchAddress(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _pinPosition,
        initialZoom: 14.0,
        onTap: (_, latLng) {
          setState(() => _pinPosition = latLng);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.terminba.sportcenterdesktop',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _pinPosition,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_pin,
                size: 40,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordReadout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.pin_drop_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Lat: ${_pinPosition.latitude.toStringAsFixed(6)}    '
            'Lng: ${_pinPosition.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            'Tap the map to move the pin',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(_pinPosition),
            icon: const Icon(Icons.check),
            label: const Text('Confirm Location'),
          ),
        ],
      ),
    );
  }
}
