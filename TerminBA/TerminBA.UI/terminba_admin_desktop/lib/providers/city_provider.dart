import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic data) {
    return City.fromJson(data);
  }
}
