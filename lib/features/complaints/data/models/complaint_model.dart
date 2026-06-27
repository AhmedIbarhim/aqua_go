import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../enums/complaint_status_enum.dart';

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
