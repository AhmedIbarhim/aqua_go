class MyBookingsModel {
  final String id;
  final String title;
  final String location;
  final String formattedDateTime;
  final double totalAmount;
  final bool isUpcoming;
  final double latitude;
  final double longitude;

  const MyBookingsModel({
    required this.id,
    required this.title,
    required this.location,
    required this.formattedDateTime,
    required this.totalAmount,
    required this.isUpcoming,
    required this.latitude,
    required this.longitude,
  });
}
