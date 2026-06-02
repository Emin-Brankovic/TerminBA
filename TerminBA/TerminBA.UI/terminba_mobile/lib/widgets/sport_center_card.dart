import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/sport_center.dart';

class SportCenterCard extends StatelessWidget {
  const SportCenterCard({
    super.key,
    required this.sportCenter,
    required this.onTap,
  });

  final SportCenter sportCenter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cityName = sportCenter.city?.name;
    final fullAddress = cityName == null || cityName.isEmpty
        ? sportCenter.address
        : '${sportCenter.address}, $cityName';
    final sports = sportCenter.availableSports
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
                        label: sportCenter.username,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sportCenter.username,
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
    if (sportCenter.photos.isEmpty) return null;
    final mainPhoto = sportCenter.photos.firstWhere(
      (photo) => photo.isMain == true && (photo.url ?? '').isNotEmpty,
      orElse: () => sportCenter.photos.first,
    );
    final url = mainPhoto.url;
    return url == null || url.trim().isEmpty ? null : url.trim();
  }
}
