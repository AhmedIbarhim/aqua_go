import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../enums/chat_category_enum.dart';
import '../enums/chat_thread_kind_enum.dart';
import '../enums/chat_thread_status_enum.dart';

/// A support (or worker) conversation thread. Mirrors the backend `ThreadView`.
class ThreadModel {
  final String id;
  final ChatThreadKind kind;
  final ChatThreadStatus status;
  final String? customerId;
  final String? workerId;
  final String? bookingId;
  final String? subjectAr;
  final String? subjectEn;
  final ChatCategory category;

  /// Free-text subject typed by the customer at ticket creation (nullable — the
  /// backend also localises to subjectAr/subjectEn for system-created threads).
  final String? subject;
  final String? createdAt;
  final String? updatedAt;
  final int unreadCount;
  final String? lastMessagePreview;
  final String? lastMessageAt;

  const ThreadModel({
    required this.id,
    required this.kind,
    required this.status,
    this.customerId,
    this.workerId,
    this.bookingId,
    this.subjectAr,
    this.subjectEn,
    required this.category,
    this.subject,
    this.createdAt,
    this.updatedAt,
    this.unreadCount = 0,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      id: json['id'] as String? ?? '',
      kind: ChatThreadKind.fromString(json['kind'] as String?),
      status: ChatThreadStatus.fromString(json['status'] as String?),
      customerId: json['customerId'] as String?,
      workerId: json['workerId'] as String?,
      bookingId: json['bookingId'] as String?,
      subjectAr: json['subjectAr'] as String?,
      subjectEn: json['subjectEn'] as String?,
      category: ChatCategory.fromString(json['category'] as String?),
      subject: json['subject'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: json['lastMessageAt'] as String?,
    );
  }

  ThreadModel copyWith({
    ChatThreadStatus? status,
    int? unreadCount,
    String? lastMessagePreview,
    String? lastMessageAt,
    String? updatedAt,
  }) {
    return ThreadModel(
      id: id,
      kind: kind,
      status: status ?? this.status,
      customerId: customerId,
      workerId: workerId,
      bookingId: bookingId,
      subjectAr: subjectAr,
      subjectEn: subjectEn,
      category: category,
      subject: subject,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  /// The customer-facing subject: the free-text subject when present, otherwise
  /// the localised system subject for the active locale.
  String displaySubject(BuildContext context) {
    if (subject != null && subject!.trim().isNotEmpty) return subject!.trim();
    final localized = context.isAr ? subjectAr : subjectEn;
    if (localized != null && localized.trim().isNotEmpty) return localized;
    return subjectEn ?? subjectAr ?? '';
  }

  /// Timestamp shown on the inbox card (last activity), formatted for locale.
  String lastActivityLabel(BuildContext context) {
    final raw = lastMessageAt ?? updatedAt ?? createdAt;
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final locale = context.isAr ? 'ar' : 'en';
      final now = DateTime.now();
      final sameDay =
          dt.year == now.year && dt.month == now.month && dt.day == now.day;
      if (sameDay) {
        return DateFormat.jm(locale).format(dt);
      }
      return DateFormat.yMMMd(locale).format(dt);
    } catch (_) {
      return '';
    }
  }
}
