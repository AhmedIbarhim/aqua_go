import '../../../address/data/models/address_model.dart';
import '../../../home/data/models/add_on_model.dart';
import '../../../../core/utils/saudi_wire_format.dart';

class PackageBookingRequestModel {
  final AddressModel? address;
  /// The picked availability slot's own `start` instant. Serialised verbatim
  /// as the bare Asia/Riyadh `scheduledAt` — no display string in between.
  final DateTime? slotStart;
  final List<String> vehicleIds;
  final List<AddOnModel> serviceAddOns;
  final List<String> workerNotes;

  /// For a subscription wash carrying a payable add-on (A2): the verified
  /// on-device Moyasar payment id for the add-on-only purchase. Null when the
  /// wash is fully covered (no add-on charge).
  final String? moyasarPaymentId;

  /// The included service the customer picked for this wash. Must be a member
  /// of the subscription's bundled services. When null the backend defaults to
  /// the package's first bundled service (back-compat).
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
