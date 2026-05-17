import 'package:json_annotation/json_annotation.dart';

part 'sport_center_photo_response.g.dart';

@JsonSerializable()
class SportCenterPhotoResponse {
  int id;
  String? url;
  String? publicId;
  int sportCenterId;
  bool? isMain;

  SportCenterPhotoResponse(
    this.id,
    this.url,
    this.publicId,
    this.sportCenterId,
    this.isMain,
  );

  factory SportCenterPhotoResponse.fromJson(Map<String, dynamic> json) =>
      _$SportCenterPhotoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SportCenterPhotoResponseToJson(this);
}
