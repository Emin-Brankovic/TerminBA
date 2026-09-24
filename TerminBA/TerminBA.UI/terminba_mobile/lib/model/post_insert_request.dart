class PostInsertRequest {
  final int skillLevelId;
  final String? text;
  final int reservationId;
  final int numberOfPlayersWanted;

  const PostInsertRequest({
    required this.skillLevelId,
    this.text,
    required this.reservationId,
    required this.numberOfPlayersWanted,
  });

  Map<String, dynamic> toJson() => {
        'skillLevelId': skillLevelId,
        'text': text,
        'reservationId': reservationId,
        'numberOfPlayersWanted': numberOfPlayersWanted,
      };
}
