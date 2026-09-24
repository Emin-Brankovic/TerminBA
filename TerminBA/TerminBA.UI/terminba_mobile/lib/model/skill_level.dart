import 'package:json_annotation/json_annotation.dart';

part 'skill_level.g.dart';

@JsonSerializable()
class SkillLevel {
  int? id;
  String? name;

  SkillLevel();

  factory SkillLevel.fromJson(Map<String, dynamic> json) => _$SkillLevelFromJson(json);

  Map<String, dynamic> toJson() => _$SkillLevelToJson(this);
}
