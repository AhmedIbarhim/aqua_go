import 'day_time_model.dart';

class RescheduleRequestModel {
  final String bookingId;
  final DateTime date;
  final String time;
  final String? addressId;
  final List<String> vehicleIds;

  RescheduleRequestModel({
    required this.bookingId,
    required this.date,
    required this.time,
    this.addressId,
    this.vehicleIds = const [],
  });

  Map<String, dynamic> toJson() {
    final scheduledAt = DayTimeModel(
      date: date,
      rawTime: time,
    ).toScheduledAtString();

    return {
      'newScheduledAt': scheduledAt,
      if (addressId != null) 'addressId': addressId,
      if (vehicleIds.isNotEmpty) 'vehicleIds': vehicleIds,
    };
  }
}
