import 'package:terminba_admin_desktop/model/amenity.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class AmenityProvider extends BaseProvider<Amenity> {
  AmenityProvider() : super("Amenity");

  @override
   Amenity fromJson(dynamic data) {
    return Amenity.fromJson(data);
  }

}