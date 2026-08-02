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
      playRequestState: json['playRequestState'] as String,
      reason: json['reason'] as String?,
      respondedAt: json['respondedAt'] as String?,
      respondedById: (json['respondedById'] as num?)?.toInt(),
      canceledAt: json['canceledAt'] as String?,
      canceledById: (json['canceledById'] as num?)?.toInt(),
      requestText: json['requestText'] as String?,
      dateOfRequest: json['dateOfRequest'] as String?,
      dateOfResponse: json['dateOfResponse'] as String?,
      isSeenByOwner: json['isSeenByOwner'] as bool?,
      isSeenByRequester: json['isSeenByRequester'] as bool?,
    );

Map<String, dynamic> _$PlayRequestResponseToJson(
  PlayRequestResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'post': instance.post?.toJson(),
  'requesterId': instance.requesterId,
  'requester': instance.requester?.toJson(),
  'playRequestState': instance.playRequestState,
  'reason': instance.reason,
  'respondedAt': instance.respondedAt,
  'respondedById': instance.respondedById,
  'canceledAt': instance.canceledAt,
  'canceledById': instance.canceledById,
  'requestText': instance.requestText,
  'dateOfRequest': instance.dateOfRequest,
  'dateOfResponse': instance.dateOfResponse,
  'isSeenByOwner': instance.isSeenByOwner,
  'isSeenByRequester': instance.isSeenByRequester,
};
