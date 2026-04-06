import 'package:json_annotation/json_annotation.dart';

part 'amenity.g.dart';
@JsonSerializable()
class Amenity {
	int id;
	String name;

	Amenity(this.id,this.name,);

  factory Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);
  Map<String, dynamic> toJson() => _$AmenityToJson(this);
}