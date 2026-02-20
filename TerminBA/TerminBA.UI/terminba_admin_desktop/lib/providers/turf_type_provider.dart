import 'package:terminba_admin_desktop/model/turf_type.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class TurfTypeProvider extends BaseProvider<TurfType> {
  TurfTypeProvider() : super("TurfType");

  @override
   TurfType fromJson(dynamic json) {
    return TurfType.fromJson(json);
  }
}