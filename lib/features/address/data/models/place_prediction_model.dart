class PlacePredictionModel {
  final String description;
  final String placeId;

  PlacePredictionModel({
    required this.description,
    required this.placeId,
  });

  factory PlacePredictionModel.fromJson(Map<String, dynamic> json) {
    return PlacePredictionModel(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }
}
