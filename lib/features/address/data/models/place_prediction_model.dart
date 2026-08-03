/// PH1-005: mirrors the backend `PlaceAutocompleteResponse.Suggestion` DTO
/// ({placeId, mainText, secondaryText}) — no longer raw Google predictions.
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

  /// Single-line label for the search-result row (main + secondary parts).
  String get description =>
      secondaryText.isEmpty ? mainText : '$mainText, $secondaryText';
}
