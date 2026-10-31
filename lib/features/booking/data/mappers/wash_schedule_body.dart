import '../../../../core/utils/saudi_wire_format.dart';

/// The ScheduleWashRequest body. `scheduledAt` is required by the record but
/// ignored by payment-init and the read-only preview, so a sentinel passes
/// `@NotNull` validation.
Map<String, dynamic> washScheduleBody({
  String? vehicleId,
  required List<String> addOnIds,
}) {
  return {
    'scheduledAt': toWireDateTime(saudiNow()),
    if (vehicleId != null) 'vehicleIds': [vehicleId],
    if (addOnIds.isNotEmpty)
      'addOns': [
        for (final id in addOnIds) {'addonId': id},
      ],
  };
}
