import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/facility/facility_detail_notifier.dart';
import 'package:terminba_mobile/features/facility/facility_detail_state.dart';
import 'package:terminba_mobile/providers/sport_center_provider.dart';
import 'package:terminba_mobile/screens/facility_reviews_screen.dart';
import 'package:terminba_mobile/screens/reservation/facility_selection_screen.dart';
import 'package:terminba_mobile/widgets/amenities_section.dart';
import 'package:terminba_mobile/widgets/venue_info_section.dart';
import 'package:terminba_mobile/model/sport_center.dart';
import 'package:url_launcher/url_launcher.dart';

class SportCenterDetailScreen extends StatefulWidget {
  const SportCenterDetailScreen({
    super.key,
    required this.sportCenterId,
    required this.selectedDate,
  });

  final int sportCenterId;
  final DateTime selectedDate;

  @override
  State<SportCenterDetailScreen> createState() => _SportCenterDetailScreenState();
}

class _SportCenterDetailScreenState extends State<SportCenterDetailScreen> {
  late final SportCenterDetailNotifier _notifier;
  late final PageController _photoController;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
    _notifier = SportCenterDetailNotifier(
      sportCenterId: widget.sportCenterId,
      sportCenterProvider: context.read<SportCenterProvider>(),
    );

    _notifier.initialize();
  }

  @override
  void dispose() {
    _photoController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<SportCenterDetailNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;
          return Scaffold(
            appBar: AppBar(
              title: Text(state.sportCenter?.username ?? 'Sport Center'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    state.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: notifier.toggleFavorite,
                ),
              ],
            ),
            body: _buildBody(state, notifier),
            bottomNavigationBar: _buildCta(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(SportCenterDetailState state, SportCenterDetailNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.sportCenter == null) {
      return Center(
        child: Text(state.error ?? 'Failed to load sport center.'),
      );
    }

    final center = state.sportCenter!;
    final address = center.address.isEmpty ? 'Address unavailable' : center.address;
    final cityName = center.city?.name;
    final fullAddress = cityName == null || cityName.isEmpty
        ? address
        : '$address, $cityName';

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.error!)),
                  ],
                ),
              ),
            ),
          SizedBox(
            height: 220,
            child: _buildPhotoCarousel(center),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  center.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFFF6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Semantics(
                  label: 'Rated 4.0 out of 5',
                  child: Row(
                    children:  [
                      Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                      SizedBox(width: 4),
                      Text(state.averageRating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  fullAddress,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF757575),
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FacilityReviewsScreen(
                        sportCenterId: center.id,
                        sportCenterName: center.username,
                        averageRating: state.averageRating,
                      ),
                    ),
                  );
                },
                child: const Text('Reviews'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMap(center),
          const SizedBox(height: 16),
          Text(
            'Available Sports',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final sport in center.availableSports)
                ChoiceChip(
                  label: Text(sport.name ?? 'Sport'),
                  selected: state.selectedSport?.id == sport.id,
                  onSelected: (_) => notifier.selectSport(sport),
                ),
            ],
          ),
          const SizedBox(height: 18),
          VenueInfoSection(sportCenter: center),
          const SizedBox(height: 18),
          AmenitiesSection(amenities: center.availableAmenities),
        ],
      ),
    );
  }

  Widget _buildPhotoCarousel(SportCenter center) {
    final photoUrls = _buildPhotoUrls(center);
    if (photoUrls.isEmpty) {
      return _imageContainer(
        child: const Icon(Icons.image_not_supported_outlined, size: 48),
      );
    }

    if (photoUrls.length == 1) {
      return _imageContainer(
        child: _buildPhotoImage(photoUrls.first, center.username),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _photoController,
          itemCount: photoUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentPhotoIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return _imageContainer(
              child: _buildPhotoImage(photoUrls[index], center.username),
            );
          },
        ),
        Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: _buildNavButton(
            icon: Icons.chevron_left,
            onPressed: () => _goToPhoto(photoUrls.length, -1),
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: _buildNavButton(
            icon: Icons.chevron_right,
            onPressed: () => _goToPhoto(photoUrls.length, 1),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: _buildDots(photoUrls.length),
        ),
      ],
    );
  }

  Widget _imageContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: child,
      ),
    );
  }

  Widget _buildPhotoImage(String url, String? label) {
    return Semantics(
      label: label ?? 'Sport center image',
      image: true,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          color: const Color(0xFFF5F5F5),
        ),
        errorWidget: (context, _, __) => const Icon(Icons.broken_image),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onPressed}) {
    return Center(
      child: Material(
        color: Colors.black.withOpacity(0.35),
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPhotoIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 10 : 6,
          height: isActive ? 10 : 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white70,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  void _goToPhoto(int total, int step) {
    if (total <= 1) {
      return;
    }

    final nextIndex = (_currentPhotoIndex + step) % total;
    _photoController.animateToPage(
      nextIndex < 0 ? total - 1 : nextIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  List<String> _buildPhotoUrls(SportCenter center) {
    if (center.photos.isEmpty) {
      return const [];
    }

    final mainPhotos = center.photos
        .where((p) => p.isMain == true && (p.url?.isNotEmpty ?? false))
        .map((p) => p.url!)
        .toList();

    final otherPhotos = center.photos
        .where((p) => p.isMain != true && (p.url?.isNotEmpty ?? false))
        .map((p) => p.url!)
        .toList();

    return [...mainPhotos, ...otherPhotos];
  }

  Widget _buildMap(SportCenter center) {
    final cityName = center.city?.name ?? 'Sarajevo';
    final mapCenter = _resolveCityCenter(cityName);

    return GestureDetector(
      onTap: () => _openMaps(center),
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 180,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'terminba_mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: mapCenter,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LatLng _resolveCityCenter(String city) {
    const centers = {
      'Sarajevo': LatLng(43.8563, 18.4131),
      'Mostar': LatLng(43.3438, 17.8078),
      'Tuzla': LatLng(44.5384, 18.6671),
      'Banja Luka': LatLng(44.7722, 17.191),
    };

    return centers[city] ?? const LatLng(43.8563, 18.4131);
  }

  Future<void> _openMaps(SportCenter center) async {
    final address = center.address;
    final query = address.isEmpty ? 'Sports facility' : address;
    final uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildCta(SportCenterDetailState state) {
    final selectedSport = state.selectedSport;
    final isEnabled = selectedSport != null;
    final label = isEnabled
        ? 'Select a Court'
        : 'Select a Court, button, dimmed';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Semantics(
          label: label,
          button: true,
          enabled: isEnabled,
          child: ElevatedButton(
            onPressed: isEnabled
                ? () {
                    final center = _notifier.state.sportCenter;
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => CourtSelectionScreen(
                          sportCenterId: widget.sportCenterId,
                          sportCenterName: center?.username ?? 'Facility',
                          sportCenterAddress: center?.address ?? '',
                          sport: selectedSport,
                          selectedDate: widget.selectedDate,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isEnabled ? const Color(0xFF4CAF50) : Colors.grey.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select a Court'),
          ),
        ),
      ),
    );
  }
}


