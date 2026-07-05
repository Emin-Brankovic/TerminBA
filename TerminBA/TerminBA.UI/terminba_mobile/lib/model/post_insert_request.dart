class PostInsertRequest {
  final String skillLevel;
  final String? text;
  final int reservationId;
  final int numberOfPlayersWanted;

  const PostInsertRequest({
    required this.skillLevel,
    this.text,
    required this.reservationId,
    required this.numberOfPlayersWanted,
  });

  Map<String, dynamic> toJson() => {
        'skillLevel': skillLevel,
        'text': text,
        'reservationId': reservationId,
        'numberOfPlayersWanted': numberOfPlayersWanted,
      };
}
