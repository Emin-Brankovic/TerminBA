import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/model/user.dart';

/// Matches the backend `ReservationResponse` model.
class ReservationResponse {
  final int id;
  final int? userId;
  final User? user;
  final int? facilityId;
  final Facility? facility;
  final String reservationDate; // "YYYY-MM-DD"
  final String startTime;       // "HH:MM:SS"
  final String endTime;         // "HH:MM:SS"
  final String? status;
  final double price;
  final int? chosenSportId;
  final Sport? chosenSport;

  const ReservationResponse({
    required this.id,
    this.userId,
    this.user,
    this.facilityId,
    this.facility,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    this.status,
    required this.price,
    this.chosenSportId,
    this.chosenSport,
  });

  factory ReservationResponse.fromJson(Map<String, dynamic> json) {
    User? parsedUser;
    if (json['user'] != null) {
      try {
        parsedUser = User.fromJson(json['user'] as Map<String, dynamic>);
      } catch (_) {
        // User shape may differ from embedded response — silently ignore
      }
    }

    Facility? parsedFacility;
    if (json['facility'] != null) {
      try {
        parsedFacility = Facility.fromJson(json['facility'] as Map<String, dynamic>);
      } catch (_) {}
    }

    Sport? parsedSport;
    if (json['chosenSport'] != null) {
      try {
        parsedSport = Sport.fromJson(json['chosenSport'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return ReservationResponse(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int?,
      user: parsedUser,
      facilityId: json['facilityId'] as int?,
      facility: parsedFacility,
      reservationDate: _extractDateString(json['reservationDate']),
      startTime: _extractTimeString(json['startTime']),
      endTime: _extractTimeString(json['endTime']),
      status: json['status'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      chosenSportId: json['chosenSportId'] as int?,
      chosenSport: parsedSport,
    );
  }

  static String _extractDateString(dynamic value) {
    if (value == null) return '';
    final s = value.toString();
    // DateOnly from .NET may arrive as "YYYY-MM-DD" or ISO string
    if (s.length >= 10) return s.substring(0, 10);
    return s;
  }

  static String _extractTimeString(dynamic value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.length >= 5) return s.substring(0, 5); // "HH:MM"
    return s;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'facilityId': facilityId,
        'reservationDate': reservationDate,
        'startTime': startTime,
        'endTime': endTime,
        'status': status,
        'price': price,
        'chosenSportId': chosenSportId,
      };
}
