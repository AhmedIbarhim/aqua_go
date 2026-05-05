class MyBookingsModel {
  final String id;
  final String title;
  final String location;
  final String formattedDateTime;
  final double totalAmount;
  final bool isUpcoming;

  const MyBookingsModel({
    required this.id,
    required this.title,
    required this.location,
    required this.formattedDateTime,
    required this.totalAmount,
    this.isUpcoming = false,
  });

  // You can add fromJson and toJson methods here when integrating with API
}
