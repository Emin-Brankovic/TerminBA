import 'package:terminba_mobile/model/city.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic data) {
    return City.fromJson(data);
  }
}
