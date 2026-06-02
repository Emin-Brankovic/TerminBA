import 'package:flutter/material.dart';
import 'package:terminba_mobile/enums/day_of_week_enum.dart';
import 'package:terminba_mobile/model/sport_center.dart';
import 'package:terminba_mobile/model/working_hours.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueInfoSection extends StatelessWidget {
  const VenueInfoSection({super.key, required this.sportCenter});

  final SportCenter? sportCenter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = sportCenter;
    if (center == null) {
      return const SizedBox.shrink();
    }

    final workingHours = _formatWorkingHours(center.workingHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Info',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _infoRow(
          'Equipment Provided',
          center.isEquipmentProvided ? 'Yes' : 'No',
        ),
        _infoRow('Working hours', workingHours),
        GestureDetector(
          onTap: () => _callNumber(center.phoneNumber),
          child: _infoRow('Phone', center.phoneNumber, isLink: true),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF757575)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isLink ? const Color(0xFF4CAF50) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

String _formatWorkingHours(List<WorkingHours> hours) {
  if (hours.isEmpty) return 'Not provided';

  final activeHours = hours.where((entry) => entry.isActive).toList();

  if (activeHours.isEmpty) return 'Not provided';

  return activeHours.map((entry) {
    final startDay = _dayName(entry.startDay);
    final endDay = _dayName(entry.endDay);

    final dayLabel = entry.startDay == entry.endDay
        ? startDay
        : '$startDay - $endDay';

    return '$dayLabel: ${entry.openingHours} - ${entry.closeingHours}';
  }).join('\n');
}

String _dayName(DayOfWeek day) {
  final shortName= day.name.substring(0, 3);
  return shortName[0].toUpperCase() + shortName.substring(1); // "monday" → "MON"
}

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
