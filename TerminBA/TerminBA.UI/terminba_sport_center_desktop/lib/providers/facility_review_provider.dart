import 'package:terminba_sport_center_desktop/model/facility_review.dart';
import 'package:terminba_sport_center_desktop/providers/base_provider.dart';

class FacilityReviewProvider extends BaseProvider<FacilityReview> {
  FacilityReviewProvider() : super("FacilityReview");

  @override
  FacilityReview fromJson(dynamic data) {
    return FacilityReview.fromJson(data);
  }
}
