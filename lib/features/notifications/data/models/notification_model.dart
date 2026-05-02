class NotificationModel {
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;

  bool serviceDone;

  NotificationModel({
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
    this.serviceDone = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      serviceDone: json['service_done'] ?? false,
    );
  }
}
