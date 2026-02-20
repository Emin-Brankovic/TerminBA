import 'package:json_annotation/json_annotation.dart';

part 'turf_type.g.dart';
@JsonSerializable()
class TurfType {
	int id;
	String name;

	TurfType(this.id,this.name,);

	factory TurfType.fromJson(Map<String, dynamic> json) => _$TurfTypeFromJson(json);

	Map<String, dynamic> toJson() => _$TurfTypeToJson(this);
}