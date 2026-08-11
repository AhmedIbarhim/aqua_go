import '../../../address/data/models/address_model.dart';
import '../../../../core/utils/saudi_wire_format.dart';

class ServiceRescheduleRequestModel {
  final String bookingId;
  final DateTime slotStart;
  final AddressModel? address;
  final List<String> vehicleIds;

  ServiceRescheduleRequestModel({
    required this.bookingId,
    required this.slotStart,
    this.address,
    this.vehicleIds = const [],
  });

  Map<String, dynamic> toJson() {
    final scheduledAt = toWireDateTime(slotStart);

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
      if (vehicleIds.isNotEmpty) 'vehicleIds': vehicleIds,
    };
  }
}
