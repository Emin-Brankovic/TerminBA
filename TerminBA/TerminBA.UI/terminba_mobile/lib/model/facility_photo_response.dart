import 'package:json_annotation/json_annotation.dart';

part 'facility_photo_response.g.dart';

@JsonSerializable()
class FacilityPhotoResponse {
  int id;
  String? url;
  String? publicId;
  int facilityId;
  

  FacilityPhotoResponse(
    this.id,
    this.url,
    this.publicId,
    this.facilityId,
    
  );

  factory FacilityPhotoResponse.fromJson(Map<String, dynamic> json) =>
      _$FacilityPhotoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FacilityPhotoResponseToJson(this);
}
