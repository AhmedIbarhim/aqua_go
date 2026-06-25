import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../generated/locale_keys.g.dart';

enum ComplaintStatus {
  open,
  closed,
  resolved,
  pending,
  rejected;

  static ComplaintStatus fromString(String? status) {
    if (status == null) return ComplaintStatus.open;
    switch (status.toUpperCase()) {
      case 'OPEN':
        return ComplaintStatus.open;
      case 'CLOSED':
        return ComplaintStatus.closed;
      case 'RESOLVED':
        return ComplaintStatus.resolved;
      case 'REJECTED':
        return ComplaintStatus.rejected;
      case 'UNDER_REVIEW':
      case 'AWAITING_CUSTOMER':
      case 'PENDING':
      default:
        return ComplaintStatus.pending;
    }
  }

  String get originalValue {
    switch (this) {
      case ComplaintStatus.open:
        return 'OPEN';
      case ComplaintStatus.closed:
        return 'CLOSED';
      case ComplaintStatus.resolved:
        return 'RESOLVED';
      case ComplaintStatus.pending:
        return 'UNDER_REVIEW';
      case ComplaintStatus.rejected:
        return 'REJECTED';
    }
  }

  String get translationKey {
    switch (this) {
      case ComplaintStatus.open:
        return LocaleKeys.complaint_status_open;
      case ComplaintStatus.closed:
        return LocaleKeys.complaint_status_closed;
      case ComplaintStatus.resolved:
        return LocaleKeys.complaint_status_resolved;
      case ComplaintStatus.pending:
        return LocaleKeys.complaint_status_pending;
      case ComplaintStatus.rejected:
        return LocaleKeys.complaint_status_rejected;
    }
  }

  Color getBgColor(BuildContext context) {
    switch (this) {
      case ComplaintStatus.open:
        return context.colors.primary;
      case ComplaintStatus.closed:
        return context.colors.errorLight;
      case ComplaintStatus.resolved:
        return context.colors.successLight;
      case ComplaintStatus.pending:
        return context.colors.defaultSubtle;
      case ComplaintStatus.rejected:
        return context.colors.errorLight;
    }
  }

  Color getTextColor(BuildContext context) {
    switch (this) {
      case ComplaintStatus.open:
        return darkAppColors.themeColor;
      case ComplaintStatus.closed:
        return darkAppColors.themeOpositeColor;
      case ComplaintStatus.resolved:
        return darkAppColors.themeColor;
      case ComplaintStatus.pending:
        return darkAppColors.themeOpositeColor;
      case ComplaintStatus.rejected:
        return darkAppColors.themeOpositeColor;
    }
  }
}

enum ComplaintCategory {
  serviceQuality,
  missedAppointment,
  propertyDamage,
  workerBehavior,
  billing,
  other;

  static ComplaintCategory fromString(String? val) {
    if (val == null) return ComplaintCategory.other;
    switch (val.toUpperCase()) {
      case 'SERVICE_QUALITY':
        return ComplaintCategory.serviceQuality;
      case 'MISSED_APPOINTMENT':
        return ComplaintCategory.missedAppointment;
      case 'PROPERTY_DAMAGE':
        return ComplaintCategory.propertyDamage;
      case 'WORKER_BEHAVIOR':
        return ComplaintCategory.workerBehavior;
      case 'BILLING':
        return ComplaintCategory.billing;
      case 'OTHER':
      default:
        return ComplaintCategory.other;
    }
  }

  String get apiValue {
    switch (this) {
      case ComplaintCategory.serviceQuality:
        return 'SERVICE_QUALITY';
      case ComplaintCategory.missedAppointment:
        return 'MISSED_APPOINTMENT';
      case ComplaintCategory.propertyDamage:
        return 'PROPERTY_DAMAGE';
      case ComplaintCategory.workerBehavior:
        return 'WORKER_BEHAVIOR';
      case ComplaintCategory.billing:
        return 'BILLING';
      case ComplaintCategory.other:
        return 'OTHER';
    }
  }

  String get translationKey {
    switch (this) {
      case ComplaintCategory.serviceQuality:
        return LocaleKeys.bookings_complaint_types_poor_wash_quality;
      case ComplaintCategory.missedAppointment:
        return LocaleKeys.bookings_complaint_types_arrival_delay;
      case ComplaintCategory.propertyDamage:
        return LocaleKeys.bookings_complaint_types_car_damage;
      case ComplaintCategory.workerBehavior:
        return LocaleKeys.bookings_complaint_types_worker_behavior;
      case ComplaintCategory.billing:
        return LocaleKeys.bookings_complaint_types_billing_issue;
      case ComplaintCategory.other:
        return LocaleKeys.bookings_complaint_types_other_type;
    }
  }

  static ComplaintCategory categoryFromTranslation(String text) {
    final lowerText = text.toLowerCase().trim();
    if (lowerText ==
            LocaleKeys.bookings_complaint_types_poor_wash_quality
                .tr()
                .toLowerCase()
                .trim() ||
        lowerText ==
            LocaleKeys.bookings_complaint_types_wrong_service
                .tr()
                .toLowerCase()
                .trim()) {
      return ComplaintCategory.serviceQuality;
    }
    if (lowerText ==
        LocaleKeys.bookings_complaint_types_arrival_delay
            .tr()
            .toLowerCase()
            .trim()) {
      return ComplaintCategory.missedAppointment;
    }
    if (lowerText ==
        LocaleKeys.bookings_complaint_types_worker_behavior
            .tr()
            .toLowerCase()
            .trim()) {
      return ComplaintCategory.workerBehavior;
    }
    if (lowerText ==
            LocaleKeys.bookings_complaint_types_car_damage
                .tr()
                .toLowerCase()
                .trim() ||
        lowerText ==
            LocaleKeys.bookings_complaint_types_safety_incident
                .tr()
                .toLowerCase()
                .trim()) {
      return ComplaintCategory.propertyDamage;
    }
    if (lowerText ==
        LocaleKeys.bookings_complaint_types_billing_issue
            .tr()
            .toLowerCase()
            .trim()) {
      return ComplaintCategory.billing;
    }
    return ComplaintCategory.other;
  }
}

class ComplaintModel {
  final String id;
  // final String? dateAr;
  // final String? dateEn;
  // final String? timeAr;
  // final String? timeEn;
  final ComplaintStatus status;
  final String? detailsAr;
  final String? detailsEn;
  final String bookingId;
  final String? referenceNumber;
  final String? customerId;
  final String? category;
  final String? description;
  final String? raisedAt;
  final String? updatedAt;
  final String? priority;
  final List<String>? photoObjectKeys;
  final String? desiredOutcome;
  final String? preferredContactChannel;
  final List<ComplaintPhoto>? photos;
  final String? resolutionNote;
  final String? rejectionReason;

  const ComplaintModel({
    required this.id,
    required this.status,
    this.detailsAr,
    this.detailsEn,
    required this.bookingId,
    this.referenceNumber,
    this.customerId,
    this.category,
    this.description,
    this.raisedAt,
    this.updatedAt,
    this.priority,
    this.photoObjectKeys,
    this.desiredOutcome,
    this.preferredContactChannel,
    this.photos,
    this.resolutionNote,
    this.rejectionReason,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String?,
      bookingId: json['bookingId'] as String? ?? '',
      referenceNumber:
          json['referenceNumber'] as String? ??
          json['referenceNumber'] as String?,
      status: ComplaintStatus.fromString(json['status'] as String?),
      category: json['category'] as String?,
      description: json['description'] as String?,
      raisedAt: json['raisedAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      priority: json['priority'] as String?,
      photoObjectKeys: json['photoObjectKeys'] != null
          ? List<String>.from(json['photoObjectKeys'])
          : null,
      desiredOutcome: json['desiredOutcome'] as String?,
      preferredContactChannel: json['preferredContactChannel'] as String?,
      photos: json['photos'] != null
          ? (json['photos'] as List)
                .map((e) => ComplaintPhoto.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
      resolutionNote: json['resolutionNote'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      'category': category,
      'description': description,
      if (desiredOutcome?.isNotEmpty ?? false) 'desiredOutcome': desiredOutcome,
      if (preferredContactChannel?.isNotEmpty ?? false)
        'preferredContactChannel': preferredContactChannel,
      if (photoObjectKeys != null) 'photoObjectKeys': photoObjectKeys,
      if (photos != null) 'photos': photos!.map((e) => e.toJson()).toList(),
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? dateAr,
    String? dateEn,
    String? timeAr,
    String? timeEn,
    ComplaintStatus? status,
    String? detailsAr,
    String? detailsEn,
    String? bookingId,
    String? referenceNumber,
    String? customerId,
    String? category,
    String? description,
    String? raisedAt,
    String? updatedAt,
    String? priority,
    List<String>? photoObjectKeys,
    String? desiredOutcome,
    String? preferredContactChannel,
    List<ComplaintPhoto>? photos,
    String? resolutionNote,
    String? rejectionReason,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      status: status ?? this.status,
      detailsAr: detailsAr ?? this.detailsAr,
      detailsEn: detailsEn ?? this.detailsEn,
      bookingId: bookingId ?? this.bookingId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      customerId: customerId ?? this.customerId,
      category: category ?? this.category,
      description: description ?? this.description,
      raisedAt: raisedAt ?? this.raisedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      photoObjectKeys: photoObjectKeys ?? this.photoObjectKeys,
      desiredOutcome: desiredOutcome ?? this.desiredOutcome,
      preferredContactChannel:
          preferredContactChannel ?? this.preferredContactChannel,
      photos: photos ?? this.photos,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  String getDate(BuildContext context) {
    if (raisedAt != null) {
      try {
        final dt = DateTime.parse(raisedAt!).toLocal();
        return DateFormat.yMMMMd(context.isAr ? 'ar' : 'en').format(dt);
      } catch (_) {}
    }
    return '';
  }

  String getTime(BuildContext context) {
    if (raisedAt != null) {
      try {
        final dt = DateTime.parse(raisedAt!).toLocal();
        return DateFormat.jm(context.isAr ? 'ar' : 'en').format(dt);
      } catch (_) {}
    }
    return '';
  }

  String getDetails(BuildContext context) {
    if (description != null) {
      return description!;
    }
    return context.isAr ? (detailsAr ?? '') : (detailsEn ?? '');
  }
}

class ComplaintPhoto {
  final int photoIndex;
  final String url;
  final String contentType;

  const ComplaintPhoto({
    required this.photoIndex,
    required this.url,
    required this.contentType,
  });

  factory ComplaintPhoto.fromJson(Map<String, dynamic> json) {
    return ComplaintPhoto(
      photoIndex: json['photoIndex'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'photoIndex': photoIndex, 'url': url, 'contentType': contentType};
  }
}
