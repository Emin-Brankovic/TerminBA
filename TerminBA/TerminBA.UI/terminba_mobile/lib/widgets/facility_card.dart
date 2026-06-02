import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/facility.dart';

class FacilityCard extends StatelessWidget {
  const FacilityCard({
    super.key,
    required this.facility,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Facility facility;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = facility.sportCenter?.address ?? 'Address unavailable';
    final cityName = facility.sportCenter?.city?.name;
    final fullAddress = cityName == null || cityName.isEmpty
        ? address
        : '$address, $cityName';
    final sports = facility.availableSports
      .map((sport) => sport.name)
      .whereType<String>()
      .where((name) => name.trim().isNotEmpty)
      .join(' - ');

    final imageUrl = _resolveImageUrl();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: imageUrl == null
                        ? Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(Icons.image_not_supported_outlined),
                          )
                        : Semantics(
                            label: facility.name ?? 'Facility image',
                            image: true,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, _) => Container(
                                color: const Color(0xFFF5F5F5),
                              ),
                              errorWidget: (context, _, __) => Container(
                                color: const Color(0xFFF5F5F5),
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: onFavoriteToggle,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name ?? 'Facility',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          fullAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (sports.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      sports,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveImageUrl() {
    if (facility.photos.isEmpty) return null;
    final mainPhoto = facility.photos.firstWhere(
      (photo) => photo.isMain == true && (photo.url ?? '').isNotEmpty,
      orElse: () => facility.photos.first,
    );
    final url = mainPhoto.url;
    return url == null || url.trim().isEmpty ? null : url.trim();
  }
}
