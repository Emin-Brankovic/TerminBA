import 'package:terminba_admin_desktop/model/skill_level.dart';
import 'package:terminba_admin_desktop/providers/base_provider.dart';

class SkillLevelProvider extends BaseProvider<SkillLevel> {
  SkillLevelProvider() : super("SkillLevel");

  @override
  SkillLevel fromJson(data) {
    return SkillLevel.fromJson(data);
  }
}
