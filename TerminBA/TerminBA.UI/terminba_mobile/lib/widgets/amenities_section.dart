import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/amenity.dart';
import 'package:terminba_mobile/utils/amenity_icon_mapper.dart';

class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({super.key, required this.amenities});

  final List<Amenity> amenities;

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        for (final amenity in amenities)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(AmenityIconMapper.getIcon(amenity.name), size: 18, color: const Color(0xFF00A565)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    amenity.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


// class AmenitiesSection extends StatelessWidget {
//   const AmenitiesSection({super.key, required this.amenities});

//   final List<Amenity> amenities;

//   @override
//   Widget build(BuildContext context) {
//     if (amenities.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Amenities',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Wrap(
//           spacing: 12,
//           runSpacing: 8,
//           children: amenities.map((amenity) {
//             final icon = AmenityIconMapper.getIcon(amenity.name); // ✅
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 18, color: const Color(0xFF00A565)),
//                 const SizedBox(width: 6),
//                 Text(amenity.name),
//               ],
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }