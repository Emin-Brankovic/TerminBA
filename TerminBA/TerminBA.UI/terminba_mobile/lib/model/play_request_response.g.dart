// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayRequestResponse _$PlayRequestResponseFromJson(Map<String, dynamic> json) =>
    PlayRequestResponse(
      id: (json['id'] as num).toInt(),
      postId: (json['postId'] as num).toInt(),
      post: json['post'] == null
          ? null
          : PostResponse.fromJson(json['post'] as Map<String, dynamic>),
      requesterId: (json['requesterId'] as num).toInt(),
      requester: json['requester'] == null
          ? null
          : User.fromJson(json['requester'] as Map<String, dynamic>),
      isAccepted: json['isAccepted'] as bool?,
      requestText: json['requestText'] as String?,
      dateOfRequest: json['dateOfRequest'] as String?,
      dateOfResponse: json['dateOfResponse'] as String?,
    );

Map<String, dynamic> _$PlayRequestResponseToJson(
        PlayRequestResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'post': instance.post?.toJson(),
      'requesterId': instance.requesterId,
      'requester': instance.requester?.toJson(),
      'isAccepted': instance.isAccepted,
      'requestText': instance.requestText,
      'dateOfRequest': instance.dateOfRequest,
      'dateOfResponse': instance.dateOfResponse,
    };
