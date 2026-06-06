class ReschedulePolicy {
  int? minHoursBeforeStart;
  int? maxReschedulesPerBooking;
  int? reschedulesUsed;
  bool? canRescheduleNow;

  ReschedulePolicy({
    this.minHoursBeforeStart,
    this.maxReschedulesPerBooking,
    this.reschedulesUsed,
    this.canRescheduleNow,
  });

  ReschedulePolicy.fromJson(Map<String, dynamic> json) {
    minHoursBeforeStart = json['minHoursBeforeStart'];
    maxReschedulesPerBooking = json['maxReschedulesPerBooking'];
    reschedulesUsed = json['reschedulesUsed'];
    canRescheduleNow = json['canRescheduleNow'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['minHoursBeforeStart'] = minHoursBeforeStart;
    data['maxReschedulesPerBooking'] = maxReschedulesPerBooking;
    data['reschedulesUsed'] = reschedulesUsed;
    data['canRescheduleNow'] = canRescheduleNow;
    return data;
  }
}
