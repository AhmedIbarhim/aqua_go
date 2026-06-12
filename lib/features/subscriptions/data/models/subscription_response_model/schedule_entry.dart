class ScheduleEntry {
  final DateTime scheduledAt;
  final String addressId;
  final List<String> vehicleIds;

  ScheduleEntry({
    required this.scheduledAt,
    required this.addressId,
    required this.vehicleIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'scheduledAt': scheduledAt.toIso8601String(),
      'addressId': addressId,
      'vehicleIds': vehicleIds,
    };
  }

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      addressId: json['addressId'] as String? ?? '',
      vehicleIds:
          (json['vehicleIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
