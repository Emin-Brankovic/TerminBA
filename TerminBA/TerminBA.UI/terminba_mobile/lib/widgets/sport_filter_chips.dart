import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terminba_mobile/model/sport.dart';

class SportFilterChips extends StatelessWidget {
  const SportFilterChips({
    super.key,
    required this.selectedDate,
    required this.selectedSport,
    required this.sports,
    required this.onDateTap,
    required this.onSportTap,
  });

  final DateTime selectedDate;
  final Sport? selectedSport;
  final List<Sport> sports;
  final VoidCallback onDateTap;
  final ValueChanged<Sport?> onSportTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: FilterChip(
              label: Text(_dateLabel()),
              selected: true,
              onSelected: (_) => onDateTap(),
              showCheckmark: false,
              selectedColor: const Color(0xFFFF5722),
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            height: 35,
            child: VerticalDivider(
              width: 16,
              thickness: 2,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          _buildSportChip(
            label: 'All Sports',
            isSelected: selectedSport == null,
            onTap: () => onSportTap(null),
            theme: theme,
          ),
          for (final sport in sports)
            _buildSportChip(
              label: sport.name ?? 'Sport',
              isSelected: selectedSport?.id == sport.id,
              onTap: () => onSportTap(sport),
              theme: theme,
            ),
        ],
      ),
    );
  }

  Widget _buildSportChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: const Color(0xFF4CAF50),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
      ),
    );
  }

  String _dateLabel() {
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
    if (isToday) {
      return 'Today';
    }
    return DateFormat('d MMM').format(selectedDate);
  }
}
