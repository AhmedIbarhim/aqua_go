import '../../../address/data/models/address_model.dart';
import '../../../home/data/models/add_on_model.dart';
import '../../../../core/utils/saudi_wire_format.dart';

class PackageBookingRequestModel {
  final AddressModel? address;
  final DateTime? slotStart;
  final List<String> vehicleIds;
  final List<AddOnModel> serviceAddOns;
  final List<String> workerNotes;

  final String? moyasarPaymentId;
  final String? serviceId;

  PackageBookingRequestModel({
    this.address,
    this.slotStart,
    this.vehicleIds = const [],
    this.serviceAddOns = const [],
    this.workerNotes = const [],
    this.moyasarPaymentId,
    this.serviceId,
  });

  Map<String, dynamic> toJson() {
    final start = slotStart;
    final String scheduledAt = start != null ? toWireDateTime(start) : '';

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
      if (moyasarPaymentId != null) 'moyasarPaymentId': moyasarPaymentId,
      if (serviceId != null) 'serviceId': serviceId,
    };
  }
}
