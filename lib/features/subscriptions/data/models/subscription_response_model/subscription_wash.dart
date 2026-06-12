import 'package:aqua_go/features/home/data/models/add_on_model.dart';

class SubscriptionWash {
  final String washId;
  final String? referenceNumber;
  final String subscriptionId;
  final int sequenceNumber;
  final String status;
  final String phase;
  final String? scheduledAt;
  final String? addressLabel;
  final num? addressLat;
  final num? addressLng;
  final List<dynamic> vehicles;
  final dynamic worker;
  final String? completedAt;
  final String? cancelledAt;
  final bool canSchedule;
  final bool canReschedule;
  final bool canCancel;
  final List<dynamic> addOns;
  final List<AddOnModel> availableOptionalAddons;

  SubscriptionWash({
    required this.washId,
    this.referenceNumber,
    required this.subscriptionId,
    required this.sequenceNumber,
    required this.status,
    required this.phase,
    this.scheduledAt,
    this.addressLabel,
    this.addressLat,
    this.addressLng,
    required this.vehicles,
    this.worker,
    this.completedAt,
    this.cancelledAt,
    required this.canSchedule,
    required this.canReschedule,
    required this.canCancel,
    required this.addOns,
    required this.availableOptionalAddons,
  });

  factory SubscriptionWash.fromJson(Map<String, dynamic> json) {
    return SubscriptionWash(
      washId: json['washId'] as String? ?? '',
      referenceNumber: json['referenceNumber'] as String?,
      subscriptionId: json['subscriptionId'] as String? ?? '',
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      phase: json['phase'] as String? ?? '',
      scheduledAt: json['scheduledAt'] as String?,
      addressLabel: json['addressLabel'] as String?,
      addressLat: json['addressLat'] as num?,
      addressLng: json['addressLng'] as num?,
      vehicles: json['vehicles'] as List<dynamic>? ?? [],
      worker: json['worker'],
      completedAt: json['completedAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      canSchedule: json['canSchedule'] as bool? ?? false,
      canReschedule: json['canReschedule'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
      addOns: json['addOns'] as List<dynamic>? ?? [],
      availableOptionalAddons:
          (json['availableOptionalAddons'] as List<dynamic>?)
              ?.map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'washId': washId,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      'subscriptionId': subscriptionId,
      'sequenceNumber': sequenceNumber,
      'status': status,
      'phase': phase,
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
      if (addressLabel != null) 'addressLabel': addressLabel,
      if (addressLat != null) 'addressLat': addressLat,
      if (addressLng != null) 'addressLng': addressLng,
      'vehicles': vehicles,
      if (worker != null) 'worker': worker,
      if (completedAt != null) 'completedAt': completedAt,
      if (cancelledAt != null) 'cancelledAt': cancelledAt,
      'canSchedule': canSchedule,
      'canReschedule': canReschedule,
      'canCancel': canCancel,
      'addOns': addOns,
      'availableOptionalAddons': availableOptionalAddons
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
