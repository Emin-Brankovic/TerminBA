import 'package:json_annotation/json_annotation.dart';

part 'cancellation_response.g.dart';

@JsonSerializable()
class CancellationResponse {
  final String reservationState;
  final bool refundIssued;
  final String? refundStatus;
  final double? refundAmount;

  CancellationResponse({
    required this.reservationState,
    required this.refundIssued,
    this.refundStatus,
    this.refundAmount,
  });

    factory CancellationResponse.fromJson(Map<String, dynamic> json) =>
      _$CancellationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CancellationResponseToJson(this);
}
