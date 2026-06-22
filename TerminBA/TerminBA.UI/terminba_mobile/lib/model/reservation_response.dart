import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/model/user.dart';

part 'reservation_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ReservationResponse {
  final int id;
  final int? userId;
  final User? user;
  final int? facilityId;
  final Facility? facility;
  final String? reservationDate; // "YYYY-MM-DD"
  final String? startTime;       // "HH:MM:SS"
  final String? endTime;         // "HH:MM:SS"
  final String? status;
  final double? price;
  final int? chosenSportId;
  final Sport? chosenSport;

  const ReservationResponse({
    required this.id,
    this.userId,
    this.user,
    this.facilityId,
    this.facility,
    this.reservationDate,
    this.startTime,
    this.endTime,
    this.status,
    this.price,
    this.chosenSportId,
    this.chosenSport,
  });

  bool get isCancelled => status == 'Cancelled';

  bool get isUpcoming {
    if (isCancelled) return false;
    if (reservationDate == null || reservationDate!.isEmpty) return false;
    try {
      DateTime resDate = DateTime.parse(reservationDate!);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      if (resDate.isBefore(today)) return false;
      if (resDate.isAtSameMomentAs(today)) {
        if (endTime != null && endTime!.isNotEmpty) {
          var parts = endTime!.split(':');
          if (parts.length >= 2) {
            int h = int.parse(parts[0]);
            int m = int.parse(parts[1]);
            if (now.hour > h || (now.hour == h && now.minute >= m)) {
              return false;
            }
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get ticketDownloaded => false;

  factory ReservationResponse.fromJson(Map<String, dynamic> json) => _$ReservationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationResponseToJson(this);
}
