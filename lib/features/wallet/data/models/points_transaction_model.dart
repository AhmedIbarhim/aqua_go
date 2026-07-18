class PointsTransactionModel {
  final String id;
  final String? bookingId;
  final int points;
  final DateTime date;
  final bool isEarned;

  // Swagger fields
  final String? kind;
  final String? refType;
  final String? refId;
  final String? reason;
  final String? refNumber;

  PointsTransactionModel({
    required this.id,
    this.bookingId,
    required this.points,
    required this.date,
    required this.isEarned,
    this.kind,
    this.refType,
    this.refId,
    this.reason,
    this.refNumber,
  });

  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    final pointsDelta = (json['pointsDelta'] as num?)?.toInt() ?? 0;
    final occurredAtStr = json['occurredAt'] as String? ??
        json['date'] as String? ??
        DateTime.now().toIso8601String();
    final refTypeStr = json['refType'] as String?;
    final refNum = json['refNumber'] as String?;

    // Map refNumber to bookingId if refType is BOOKING
    final isBooking = refTypeStr?.toUpperCase() == 'BOOKING';
    final mappedBookingId = isBooking ? refNum : (json['bookingId'] as String?);

    return PointsTransactionModel(
      id: json['id'] as String? ?? '',
      bookingId: mappedBookingId,
      points: pointsDelta != 0 ? pointsDelta.abs() : ((json['points'] as num?)?.toInt() ?? 0),
      date: DateTime.parse(occurredAtStr),
      isEarned: pointsDelta != 0 ? pointsDelta > 0 : (json['isEarned'] as bool? ?? true),
      kind: json['kind'] as String?,
      refType: refTypeStr,
      refId: json['refId'] as String?,
      reason: json['reason'] as String?,
      refNumber: refNum,
    );
  }
}
