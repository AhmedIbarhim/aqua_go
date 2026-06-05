class RatingModel {
  final int? score;
  final String? comment;
  final List<String>? reasons;

  RatingModel({this.score, this.comment, this.reasons});

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      score: json['score'] != null
          ? num.tryParse(json['score'].toString())?.toInt()
          : null,
      comment: json['comment']?.toString(),
      reasons: json['reasons'] is List
          ? (json['reasons'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score'] = score;
    data['comment'] = comment;
    data['reasons'] = reasons;
    return data;
  }
}
