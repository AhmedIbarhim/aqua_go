class CurrentPackageModel {
  final String title;
  final String description;
  final String image;
  final int remainingWashes;
  final int totalWashes;
  final DateTime expiryDate;

  CurrentPackageModel({
    required this.title,
    required this.description,
    required this.image,
    required this.remainingWashes,
    required this.totalWashes,
    required this.expiryDate,
  });

  factory CurrentPackageModel.fromJson(Map<String, dynamic> json) {
    return CurrentPackageModel(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      remainingWashes: json['remainingWashes'],
      totalWashes: json['totalWashes'],
      expiryDate: DateTime.parse(json['expiryDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'remainingWashes': remainingWashes,
      'totalWashes': totalWashes,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }
}
