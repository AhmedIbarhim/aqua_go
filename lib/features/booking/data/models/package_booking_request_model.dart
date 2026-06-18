import '../../../address/data/models/address_model.dart';
import '../../../home/data/models/add_on_model.dart';
import 'day_time_model.dart';

class PackageBookingRequestModel {
  final AddressModel? address;
  final DateTime? date;
  final String? time;
  final List<String> vehicleIds;
  final List<AddOnModel> serviceAddOns;
  final List<String> workerNotes;

  PackageBookingRequestModel({
    this.address,
    this.date,
    this.time,
    this.vehicleIds = const [],
    this.serviceAddOns = const [],
    this.workerNotes = const [],
  });

  Map<String, dynamic> toJson() {
    String scheduledAt = '';
    if (date != null && time != null) {
      scheduledAt = DayTimeModel(
        date: date!,
        rawTime: time!,
      ).toScheduledAtString();
      scheduledAt = '${scheduledAt}Z';
    }

    final addr = address;
    final isSavedAddress =
        addr?.id != null &&
        addr?.id != 'current_gps' &&
        addr?.id != 'custom_map';

    return {
      'scheduledAt': scheduledAt,
      if (isSavedAddress) 'addressId': addr?.id,
      if (!isSavedAddress && addr != null) ...{
        'addressLabel': addr.details.isNotEmpty ? addr.details : addr.label,
        'lat': addr.lat,
        'lng': addr.lng,
        if (addr.arrivalNotes != null) 'addressArrivalNotes': addr.arrivalNotes,
      },
      'vehicleIds': vehicleIds,
      if (serviceAddOns.isNotEmpty)
        'addOns': serviceAddOns.map((e) => {'addonId': e.id}).toList(),
      if (workerNotes.isNotEmpty) 'workerNotes': workerNotes,
    };
  }
}
