import 'package:terminba_mobile/model/skill_level.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class SkillLevelProvider extends BaseProvider<SkillLevel> {
  SkillLevelProvider() : super("SkillLevel");

  @override
  SkillLevel fromJson(data) {
    return SkillLevel.fromJson(data);
  }
}
