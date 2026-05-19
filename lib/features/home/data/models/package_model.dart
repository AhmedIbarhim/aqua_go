class PackageModel {
  final String title;
  final String description;
  final String price;
  final String duration;
  final String image;

  PackageModel({
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.image,
  });

  String get total =>
      (num.parse(price) + (num.parse(price) * .14)).toStringAsFixed(2);
  String get vat => (num.parse(price) * .14).toStringAsFixed(2);
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      title: json['title'],
      description: json['description'],
      price: json['price'],
      duration: json['duration'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'duration': duration,
      'image': image,
    };
  }
}
