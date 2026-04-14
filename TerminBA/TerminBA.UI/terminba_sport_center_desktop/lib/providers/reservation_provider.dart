import 'package:terminba_sport_center_desktop/model/reservation_response.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<ReservationResponse> {
  ReservationProvider() : super("Reservation");

  @override
  ReservationResponse fromJson(dynamic data) {
    return ReservationResponse.fromJson(data);
  }
}
