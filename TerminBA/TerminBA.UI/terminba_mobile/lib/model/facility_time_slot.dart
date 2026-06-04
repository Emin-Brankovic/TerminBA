/// Matches the backend `FacilityTimeSlot` model.
///
/// `startTime` / `endTime` are .NET `TimeSpan` strings, e.g. `"09:00:00"`.
/// `isFree` is `true` when the slot is available for booking.
class FacilityTimeSlot {
  final String startTime;
  final String endTime;
  final bool isFree;

  const FacilityTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isFree,
  });

  factory FacilityTimeSlot.fromJson(Map<String, dynamic> json) {
    return FacilityTimeSlot(
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isFree: json['isFree'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime,
        'endTime': endTime,
        'isFree': isFree,
      };

  /// Returns a display label like `"09:00 - 10:00"`.
  String get label {
    String _trim(String t) {
      final parts = t.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return t;
    }

    return '${_trim(startTime)} - ${_trim(endTime)}';
  }
}
