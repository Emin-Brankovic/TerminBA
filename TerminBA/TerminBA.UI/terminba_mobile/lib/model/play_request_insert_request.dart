class PlayRequestInsertRequest {
  final int postId;
  final String? requestText;

  const PlayRequestInsertRequest({
    required this.postId,
    this.requestText,
  });

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'requestText': requestText,
        'dateOfRequest': DateTime.now().toUtc().toIso8601String(),
      };
}
