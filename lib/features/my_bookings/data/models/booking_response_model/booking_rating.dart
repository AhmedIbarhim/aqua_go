class BookingRatingModel {
  int? score;
  List<String>? reasons;
  String? notes;
  String? ratedAt;

  BookingRatingModel({
    this.score,
    this.reasons,
    this.notes,
    this.ratedAt,
  });

  BookingRatingModel.fromJson(Map<String, dynamic> json) {
    score = json['score'] != null
        ? int.tryParse(json['score'].toString())
        : null;
    reasons = json['reasons'] is List
        ? (json['reasons'] as List).map((e) => e.toString()).toList()
        : null;
    notes = json['notes'];
    ratedAt = json['ratedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score'] = score;
    data['reasons'] = reasons;
    data['notes'] = notes;
    data['ratedAt'] = ratedAt;
    return data;
  }
}
