import 'package:terminba_admin_desktop/model/role.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class RoleProvider extends BaseProvider<Role> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(dynamic json) {
    return Role.fromJson(json);
  }
}
