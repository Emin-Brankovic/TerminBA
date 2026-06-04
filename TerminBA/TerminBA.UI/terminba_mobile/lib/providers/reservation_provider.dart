import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<ReservationResponse> {
  ReservationProvider() : super('Reservation');

  @override
  ReservationResponse fromJson(dynamic data) {
    return ReservationResponse.fromJson(data as Map<String, dynamic>);
  }

}
