import 'package:terminba_mobile/model/sport.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class SportProvider extends BaseProvider<Sport> {
  SportProvider() : super('Sport');

  @override
  Sport fromJson(dynamic data) {
    return Sport.fromJson(data);
  }
}
