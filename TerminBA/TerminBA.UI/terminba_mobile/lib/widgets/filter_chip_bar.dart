import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/sport.dart';

/// Horizontally-scrollable filter row for the player search feed.
class FilterChipBar extends StatelessWidget {
  final List<Sport> sports;
  final int? selectedSportId;
  final String? selectedSkillLevel;
  final DateTime? selectedDate;
  final ValueChanged<int?> onSportChanged;
  final ValueChanged<String?> onSkillLevelChanged;
  final ValueChanged<DateTime?> onDateChanged;

  const FilterChipBar({
    super.key,
    required this.sports,
    this.selectedSportId,
    this.selectedSkillLevel,
    this.selectedDate,
    required this.onSportChanged,
    required this.onSkillLevelChanged,
    required this.onDateChanged,
  });

  static const _skillLevels = ['Beginner', 'Medium', 'Advance'];
  static const _green = Color(0xFF00C875);

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  void _showSportSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select Sport',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text('All Sports'),
              trailing: selectedSportId == null
                  ? const Icon(Icons.check, color: _green)
                  : null,
              onTap: () {
                onSportChanged(null);
                Navigator.pop(ctx);
              },
            ),
            ...sports.map((sport) => ListTile(
                  title: Text(sport.name ?? ''),
                  trailing: selectedSportId == sport.id
                      ? const Icon(Icons.check, color: _green)
                      : null,
                  onTap: () {
                    onSportChanged(sport.id);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showSkillLevelSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select Skill Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text('All Levels'),
              trailing: selectedSkillLevel == null
                  ? const Icon(Icons.check, color: _green)
                  : null,
              onTap: () {
                onSkillLevelChanged(null);
                Navigator.pop(ctx);
              },
            ),
            ..._skillLevels.map((level) => ListTile(
                  title: Text(level),
                  trailing: selectedSkillLevel == level
                      ? const Icon(Icons.check, color: _green)
                      : null,
                  onTap: () {
                    onSkillLevelChanged(level);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSportName = selectedSportId != null
        ? sports
            .firstWhere(
              (s) => s.id == selectedSportId,
              orElse: () => Sport(0, 'All Sports'),
            )
            .name
        : 'All Sports';
    final selectedLevelName = selectedSkillLevel ?? 'All Levels';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // -- Sport chip --
          _FilterGroupChip(
            label: selectedSportName ?? 'All Sports',
            selected: selectedSportId != null,
            onTap: () => _showSportSelector(context),
            onClear:
                selectedSportId != null ? () => onSportChanged(null) : null,
          ),
          const SizedBox(width: 8),

          // -- Skill level chip --
          _FilterGroupChip(
            label: selectedLevelName,
            selected: selectedSkillLevel != null,
            onTap: () => _showSkillLevelSelector(context),
            onClear: selectedSkillLevel != null
                ? () => onSkillLevelChanged(null)
                : null,
          ),
          const SizedBox(width: 8),

          // -- Date chip --
          _FilterGroupChip(
            label: selectedDate != null
                ? '${_formatDate(selectedDate!)}'
                : 'Pick date',
            selected: selectedDate != null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: _green),
                  ),
                  child: child!,
                ),
              );
              onDateChanged(picked);
            },
            onClear: selectedDate != null ? () => onDateChanged(null) : null,
          ),
        ],
      ),
    );
  }
}

class _FilterGroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _FilterGroupChip({
    required this.label,
    required this.selected,
    this.onTap,
    this.onClear,
  });

  static const _green = Color(0xFF00C875);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _green : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _green.withOpacity(0.25), blurRadius: 6)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
            if (onClear == null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
