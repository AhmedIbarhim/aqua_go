class PlacePredictionModel {
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlacePredictionModel({
    required this.placeId,
    required this.mainText,
    this.secondaryText = '',
  });

  factory PlacePredictionModel.fromJson(Map<String, dynamic> json) {
    return PlacePredictionModel(
      placeId: json['placeId'] ?? '',
      mainText: json['mainText'] ?? '',
      secondaryText: json['secondaryText'] ?? '',
    );
  }

  String get description =>
      secondaryText.isEmpty ? mainText : '$mainText, $secondaryText';
}
