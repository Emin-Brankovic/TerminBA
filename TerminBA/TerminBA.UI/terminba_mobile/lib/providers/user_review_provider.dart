import 'package:terminba_mobile/model/user_review.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class UserReviewProvider extends BaseProvider<UserReview> {
  UserReviewProvider() : super('UserReview');

  @override
  UserReview fromJson(dynamic data) {
    return UserReview.fromJson(data);
  }
}
