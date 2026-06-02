import 'package:terminba_mobile/model/role.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class RoleProvider extends BaseProvider<Role> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(dynamic data) {
    return Role.fromJson(data);
  }
}
