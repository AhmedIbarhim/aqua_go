import '../../../../core/enums/payment_method_enum.dart';
import 'subscription_response_model/schedule_entry.dart';

class SubscriptionRequestModel {
  final String packageId;
  final String? vehicleId;
  final String? addressId;
  final List<ScheduleEntry>? initialSchedule;

  /// The Moyasar payment id returned by the on-device SDK purchase. The
  /// backend verifies this `paid` payment, then creates the subscription
  /// (pay-before-create). Required on the create call.
  final String? moyasarPaymentId;

  /// Drives the SDK purchase surface (card vs Apple Pay). Previously the UI
  /// discarded the chosen method; it now rides the create request.
  final PaymentMethod? paymentMethod;

  SubscriptionRequestModel({
    required this.packageId,
    this.vehicleId,
    this.addressId,
    this.initialSchedule,
    this.moyasarPaymentId,
    this.paymentMethod,
  });

  SubscriptionRequestModel copyWith({
    String? moyasarPaymentId,
    PaymentMethod? paymentMethod,
  }) {
    return SubscriptionRequestModel(
      packageId: packageId,
      vehicleId: vehicleId,
      addressId: addressId,
      initialSchedule: initialSchedule,
      moyasarPaymentId: moyasarPaymentId ?? this.moyasarPaymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toJson() {
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
      if (moyasarPaymentId != null) 'moyasarPaymentId': moyasarPaymentId,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      if (finalSchedule != null)
        'initialSchedule': finalSchedule.map((e) => e.toJson()).toList(),
    };
  }
}
