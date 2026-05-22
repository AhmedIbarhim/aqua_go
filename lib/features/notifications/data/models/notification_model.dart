enum NotificationType {
  bookingAssigned('booking.assigned'),
  bookingCompleted('booking.completed'),
  bookingCancellationMadaPending('booking.cancellation_mada_pending'),
  complaintResolved('complaint.resolved'),
  subscriptionExpiring('subscription.expiring'),
  subscriptionCancelled('subscription.cancelled'),
  system('system'),
  unknown('unknown');

  final String value;
  const NotificationType(this.value);

  factory NotificationType.fromString(String? val) {
    return NotificationType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => NotificationType.unknown,
    );
  }
}

class LocalizedText {
  final String ar;
  final String en;

  LocalizedText({required this.ar, required this.en});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }

  String getValue(String langCode) {
    return langCode == 'ar' ? ar : en;
  }
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final LocalizedText title;
  final LocalizedText body;
  final String? targetType;
  final String? targetId;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.targetType,
    this.targetId,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  bool get serviceDone =>
      type == NotificationType.bookingCompleted ||
      type == NotificationType.complaintResolved;

  String getLocalizedTitle(String langCode) => title.getValue(langCode);
  String getLocalizedBody(String langCode) => body.getValue(langCode);

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    LocalizedText? title,
    LocalizedText? body,
    String? targetType,
    String? targetId,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: NotificationType.fromString(json['type']),
      title: LocalizedText.fromJson(json['title'] ?? {}),
      body: LocalizedText.fromJson(json['body'] ?? {}),
      targetType: json['targetType'],
      targetId: json['targetId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt']).toLocal()
          : null,
    );
  }
}

class NotificationsPageModel {
  final List<NotificationModel> items;
  final String? nextCursor;
  final int totalMatching;

  NotificationsPageModel({
    required this.items,
    this.nextCursor,
    required this.totalMatching,
  });

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? [];
    return NotificationsPageModel(
      items: list
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'],
      totalMatching: json['totalMatching'] ?? 0,
    );
  }
}
