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
    this.date,
    this.time,
    this.vehicleIds = const [],
    this.serviceAddOns = const [],
    this.workerNotes = const [],
    this.moyasarPaymentId,
    this.serviceId,
  });

  Map<String, dynamic> toJson() {
    String scheduledAt = '';
    if (date != null && time != null) {
      scheduledAt = DayTimeModel(
        date: date!,
        rawTime: time!,
      ).toScheduledAtString();
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
      if (moyasarPaymentId != null) 'moyasarPaymentId': moyasarPaymentId,
      if (serviceId != null) 'serviceId': serviceId,
    };
  }
}
