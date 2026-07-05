// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostResponse _$PostResponseFromJson(Map<String, dynamic> json) => PostResponse(
      id: (json['id'] as num).toInt(),
      skillLevel: json['skillLevel'] as String?,
      text: json['text'] as String?,
      reservationId: (json['reservationId'] as num).toInt(),
      reservation: json['reservation'] == null
          ? null
          : ReservationResponse.fromJson(
              json['reservation'] as Map<String, dynamic>),
      numberOfPlayersWanted: (json['numberOfPlayersWanted'] as num).toInt(),
      numberOfPlayersFound: (json['numberOfPlayersFound'] as num).toInt(),
      postState: json['postState'] as String,
    );

Map<String, dynamic> _$PostResponseToJson(PostResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'skillLevel': instance.skillLevel,
      'text': instance.text,
      'reservationId': instance.reservationId,
      'reservation': instance.reservation?.toJson(),
      'numberOfPlayersWanted': instance.numberOfPlayersWanted,
      'numberOfPlayersFound': instance.numberOfPlayersFound,
      'postState': instance.postState,
    };
