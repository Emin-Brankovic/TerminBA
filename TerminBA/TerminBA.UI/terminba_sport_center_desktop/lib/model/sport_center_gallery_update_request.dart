import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'sport_center_gallery_update_request.g.dart';

@JsonSerializable()
class SportCenterGalleryUpdateRequest {
  @JsonKey(fromJson: _bytesListFromJson, toJson: _bytesListToJson)
  List<Uint8List>? photos;
  List<int>? removedPhotoIds;

  SportCenterGalleryUpdateRequest({
    this.photos,
    this.removedPhotoIds,
  });

  factory SportCenterGalleryUpdateRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SportCenterGalleryUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SportCenterGalleryUpdateRequestToJson(this);
}

List<Uint8List>? _bytesListFromJson(List<dynamic>? value) {
  if (value == null) {
    return null;
  }
  return value.map((item) => base64Decode(item as String)).toList();
}

List<String>? _bytesListToJson(List<Uint8List>? value) {
  if (value == null) {
    return null;
  }
  return value.map(base64Encode).toList();
}
