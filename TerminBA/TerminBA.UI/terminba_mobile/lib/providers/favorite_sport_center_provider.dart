import 'package:terminba_mobile/model/favorite_sport_center.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class FavoriteSportCenterProvider extends BaseProvider<FavoriteSportCenter> {
  FavoriteSportCenterProvider() : super("FavoriteSportCenter");

  @override
  FavoriteSportCenter fromJson(data) {
    return FavoriteSportCenter.fromJson(data);
  }
}
