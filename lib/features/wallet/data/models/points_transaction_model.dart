class PointsTransactionModel {
  final String id;
  final String? bookingId;
  final int points;
  final DateTime date;
  final bool isEarned;

  PointsTransactionModel({
    required this.id,
    this.bookingId,
    required this.points,
    required this.date,
    required this.isEarned,
  });

  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String?,
      points: json['points'] as int,
      date: DateTime.parse(json['date'] as String),
      isEarned: json['isEarned'] as bool,
    );
  }
}
