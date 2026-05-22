import 'package:equatable/equatable.dart';

class NotificationPreferencesModel extends Equatable {
  final bool marketingPush;
  final bool marketingSms;
  final bool marketingEmail;
  final DateTime? updatedAt;
  final String? consentVersion;

  const NotificationPreferencesModel({
    required this.marketingPush,
    required this.marketingSms,
    required this.marketingEmail,
    this.updatedAt,
    this.consentVersion,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> map) {
    return NotificationPreferencesModel(
      marketingPush: map['marketingPush'] ?? false,
      marketingSms: map['marketingSms'] ?? false,
      marketingEmail: map['marketingEmail'] ?? false,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      consentVersion: map['consentVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marketingPush': marketingPush,
      'marketingSms': marketingSms,
      'marketingEmail': marketingEmail,
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (consentVersion != null) 'consentVersion': consentVersion,
    };
  }

  Map<String, dynamic> toPatchJson() {
    return {
      'marketingPush': marketingPush,
      'marketingSms': marketingSms,
      'marketingEmail': marketingEmail,
    };
  }

  NotificationPreferencesModel copyWith({
    bool? marketingPush,
    bool? marketingSms,
    bool? marketingEmail,
    DateTime? updatedAt,
    String? consentVersion,
  }) {
    return NotificationPreferencesModel(
      marketingPush: marketingPush ?? this.marketingPush,
      marketingSms: marketingSms ?? this.marketingSms,
      marketingEmail: marketingEmail ?? this.marketingEmail,
      updatedAt: updatedAt ?? this.updatedAt,
      consentVersion: consentVersion ?? this.consentVersion,
    );
  }

  @override
  List<Object?> get props => [
        marketingPush,
        marketingSms,
        marketingEmail,
        updatedAt,
        consentVersion,
      ];
}
