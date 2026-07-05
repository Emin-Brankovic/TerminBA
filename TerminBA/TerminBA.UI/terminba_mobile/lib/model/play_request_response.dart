import 'package:json_annotation/json_annotation.dart';
import 'package:terminba_mobile/model/post_response.dart';
import 'package:terminba_mobile/model/user.dart';

part 'play_request_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PlayRequestResponse {
  final int id;
  final int postId;
  final PostResponse? post;
  final int requesterId;
  final User? requester;
  final bool? isAccepted;
  final String? requestText;
  final String? dateOfRequest;
  final String? dateOfResponse;
  final bool? isSeenByOwner;
  final bool? isSeenByRequester;

  const PlayRequestResponse({
    required this.id,
    required this.postId,
    this.post,
    required this.requesterId,
    this.requester,
    this.isAccepted,
    this.requestText,
    this.dateOfRequest,
    this.dateOfResponse,
    this.isSeenByOwner,
    this.isSeenByRequester,
  });


  /// Returns a human-readable status string.
  String get statusLabel {
    if (isAccepted == null) return 'Pending';
    if (isAccepted == true) return 'Accepted';
    return 'Denied';
  }

  factory PlayRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$PlayRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlayRequestResponseToJson(this);
}
