class AvailabilityResponse {
  final List<AvailabilitySlot> slots;

  AvailabilityResponse({required this.slots});

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityResponse(
      slots: (json['slots'] as List? ?? [])
          .map(
            (item) => AvailabilitySlot.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class AvailabilitySlot {
  final DateTime start;
  final DateTime end;
  final bool available;
  final String? reason;

  AvailabilitySlot({
    required this.start,
    required this.end,
    required this.available,
    this.reason,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      available: json['available'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }
}
