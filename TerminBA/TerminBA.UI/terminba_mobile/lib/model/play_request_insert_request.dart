class PlayRequestInsertRequest {
  final int postId;
  final int requesterId;
  final String? requestText;

  const PlayRequestInsertRequest({
    required this.postId,
    required this.requesterId,
    this.requestText,
  });

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'requesterId': requesterId,
        'requestText': requestText,
        'dateOfRequest': DateTime.now().toIso8601String(),
      };
}
