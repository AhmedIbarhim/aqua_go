class AddOnModel {
  final String id;
  final String name;
  final double price;
  final String image;

  AddOnModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory AddOnModel.fromJson(Map<String, dynamic> json) => AddOnModel(
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
