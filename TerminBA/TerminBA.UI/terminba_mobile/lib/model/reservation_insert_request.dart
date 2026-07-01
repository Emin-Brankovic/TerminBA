/// Matches the backend `ReservationInsertRequest`.
///
/// `reservationDate` → `DateOnly` on server (send as `"YYYY-MM-DD"`).
/// `startTime` / `endTime` → `TimeOnly` on server (send as `"HH:MM:SS"`).
class ReservationInsertRequest {
  final int? userId;
  final int? facilityId;
  final String reservationDate; // "YYYY-MM-DD"
  final String startTime;       // "HH:MM:SS"
  final String endTime;         // "HH:MM:SS"
  final double price;
  final int? chosenSportId;
  final String? paymentMethod;

  const ReservationInsertRequest({
    this.userId,
    this.facilityId,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.chosenSportId,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        if (userId != null) 'userId': userId,
        if (facilityId != null) 'facilityId': facilityId,
        'reservationDate': reservationDate,
        'startTime': startTime,
        'endTime': endTime,
        'price': price,
        if (chosenSportId != null) 'chosenSportId': chosenSportId,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      };
}
