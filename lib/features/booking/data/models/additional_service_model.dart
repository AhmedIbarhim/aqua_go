class AdditionalServiceModel {
  final String id;
  final String name;
  final double price;
  final String image;

  AdditionalServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory AdditionalServiceModel.fromJson(Map<String, dynamic> json) =>
      AdditionalServiceModel(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'image': image,
  };
}
