import 'subscription_response_model/schedule_entry.dart';

class SubscriptionRequestModel {
  final String packageId;
  final String? vehicleId;
  final String? addressId;
  final List<ScheduleEntry>? initialSchedule;
  final String? nonce;

  SubscriptionRequestModel({
    required this.packageId,
    this.vehicleId,
    this.addressId,
    this.initialSchedule,
    this.nonce,
  });

  Map<String, dynamic> toJson() {
    final cleanNonce = nonce ?? DateTime.now().millisecondsSinceEpoch.toString();
    List<ScheduleEntry>? finalSchedule = initialSchedule;
    if (finalSchedule == null && vehicleId != null && addressId != null) {
      finalSchedule = [
        ScheduleEntry(
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          addressId: addressId!,
          vehicleIds: [vehicleId!],
        ),
      ];
    }

    return {
      'packageId': packageId,
      'idempotencyNonce': cleanNonce,
      if (finalSchedule != null)
        'initialSchedule': finalSchedule.map((e) => e.toJson()).toList(),
    };
  }
}
