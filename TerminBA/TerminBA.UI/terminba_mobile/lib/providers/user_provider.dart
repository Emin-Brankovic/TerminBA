import 'package:terminba_mobile/model/user.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class UserProvider extends BaseProvider<User>{
  UserProvider() : super("User");

  @override
  User fromJson(dynamic data) {
    return User.fromJson(data);
  }
}