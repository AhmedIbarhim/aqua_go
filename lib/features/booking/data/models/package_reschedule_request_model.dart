import '../../../address/data/models/address_model.dart';
import 'day_time_model.dart';

class PackageRescheduleRequestModel {
  final DateTime date;
  final String time;
  final AddressModel? address;
  final List<String> vehicleIds;

  PackageRescheduleRequestModel({
    required this.date,
    required this.time,
    this.address,
    this.vehicleIds = const [],
  });

  Map<String, dynamic> toJson() {
    String scheduledAt = '';
    scheduledAt = DayTimeModel(
      date: date,
      rawTime: time,
    ).toScheduledAtString();
    scheduledAt = '${scheduledAt}Z';

    final addr = address;
    final isSavedAddress =
        addr?.id != null &&
        addr?.id != 'current_gps' &&
        addr?.id != 'custom_map';

    return {
      'newScheduledAt': scheduledAt,
      if (isSavedAddress) 'addressId': addr?.id,
      if (!isSavedAddress && addr != null) ...{
        'addressLabel': addr.details.isNotEmpty ? addr.details : addr.label,
        'lat': addr.lat,
        'lng': addr.lng,
        if (addr.arrivalNotes != null) 'addressArrivalNotes': addr.arrivalNotes,
      },
      'vehicleIds': vehicleIds,
    };
  }
}
