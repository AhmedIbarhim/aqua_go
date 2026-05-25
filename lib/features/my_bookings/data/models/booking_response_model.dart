// ignore_for_file: constant_identifier_names
import 'package:intl/intl.dart';

enum BookingType {
  ON_DEMAND,
  SCHEDULED;

  static BookingType? fromString(String? val) {
    if (val == null) return null;
    return BookingType.values.firstWhere(
      (e) => e.name == val.toUpperCase(),
      orElse: () => BookingType.ON_DEMAND,
    );
  }

  String toJson() => name;
}

enum BookingStatus {
  UNSCHEDULED,
  PENDING,
  ASSIGNED,
  ON_THE_WAY,
  ARRIVED,
  STARTED,
  COMPLETED,
  CANCELLED;

  static BookingStatus? fromString(String? val) {
    if (val == null) return null;
    final upperVal = val.toUpperCase().replaceAll(' ', '_');
    return BookingStatus.values.firstWhere(
      (e) => e.name == upperVal,
      orElse: () => BookingStatus.PENDING,
    );
  }

  String toJson() => name;
}

class BookingsListResponseModel {
  final List<BookingResponseModel> items;
  final String? nextCursor;
  final int? totalMatching;

  BookingsListResponseModel({
    required this.items,
    this.nextCursor,
    this.totalMatching,
  });

  factory BookingsListResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingsListResponseModel(
      items:
          (json['items'] as List?)
              ?.map(
                (item) =>
                    BookingResponseModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      nextCursor: json['nextCursor'] as String?,
      totalMatching: json['totalMatching'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'nextCursor': nextCursor,
      'totalMatching': totalMatching,
    };
  }
}

class BookingResponseModel {
  String? id;
  String? customerId;
  String? workerId;
  String? addressLabel;
  num? addressLat;
  num? addressLng;
  String? zoneId;
  String? packageId;
  BookingType? type;
  BookingStatus? status;
  String? scheduledAt;
  String? createdAt;
  String? updatedAt;
  String? quoteId;
  int? totalAmountMinor;
  String? currency;
  String? paymentStatus;
  String? paymentIntentId;
  String? invoiceId;
  String? paymentVoidedAt;
  String? paymentStuckDetectedAt;
  int? cancellationFeeMinor;
  bool? cancellationFeeWaived;
  int? reschedulesUsed;
  String? rescheduledAt;
  CancellationPolicy? cancellationPolicy;
  String? pspRedirectUrl;
  List<Photos>? photos;
  AssignedWorker? assignedWorker;
  String? plateMasked;
  Invoice? invoice;
  List<String>? workerNotes;
  int? vehicleYear;
  String? addressArrivalNotes;
  String? vehicleMake;
  String? vehicleModel;
  String? vehicleColor;
  PackageName? packageName;
  String? vehicleMakeLogoUrl;

  BookingResponseModel({
    this.id,
    this.customerId,
    this.workerId,
    this.addressLabel,
    this.addressLat,
    this.addressLng,
    this.zoneId,
    this.packageId,
    this.type,
    this.status,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
    this.quoteId,
    this.totalAmountMinor,
    this.currency,
    this.paymentStatus,
    this.paymentIntentId,
    this.invoiceId,
    this.paymentVoidedAt,
    this.paymentStuckDetectedAt,
    this.cancellationFeeMinor,
    this.cancellationFeeWaived,
    this.reschedulesUsed,
    this.rescheduledAt,
    this.cancellationPolicy,
    this.pspRedirectUrl,
    this.photos,
    this.assignedWorker,
    this.plateMasked,
    this.invoice,
    this.workerNotes,
    this.vehicleYear,
    this.addressArrivalNotes,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.packageName,
    this.vehicleMakeLogoUrl,
  });

  BookingResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customerId'];
    workerId = json['workerId'];
    addressLabel = json['addressLabel'];

    // safe coordinate parsing
    addressLat = json['addressLat'] != null
        ? num.tryParse(json['addressLat'].toString())
        : (json['address_lat'] != null
              ? num.tryParse(json['address_lat'].toString())
              : (json['lat'] != null
                    ? num.tryParse(json['lat'].toString())
                    : null));

    addressLng = json['addressLng'] != null
        ? num.tryParse(json['addressLng'].toString())
        : (json['address_lng'] != null
              ? num.tryParse(json['address_lng'].toString())
              : (json['lng'] != null
                    ? num.tryParse(json['lng'].toString())
                    : null));

    zoneId = json['zoneId'];
    packageId = json['packageId'];
    type = BookingType.fromString(json['type']);
    status = BookingStatus.fromString(json['status']);
    scheduledAt = json['scheduledAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    quoteId = json['quoteId'];
    totalAmountMinor = json['totalAmountMinor'];
    currency = json['currency'];
    paymentStatus = json['paymentStatus'];
    paymentIntentId = json['paymentIntentId'];
    invoiceId = json['invoiceId'];
    paymentVoidedAt = json['paymentVoidedAt'];
    paymentStuckDetectedAt = json['paymentStuckDetectedAt'];
    cancellationFeeMinor = json['cancellationFeeMinor'];
    cancellationFeeWaived = json['cancellationFeeWaived'];
    reschedulesUsed = json['reschedulesUsed'];
    rescheduledAt = json['rescheduledAt'];
    cancellationPolicy = json['cancellationPolicy'] != null
        ? CancellationPolicy.fromJson(json['cancellationPolicy'])
        : null;
    pspRedirectUrl = json['pspRedirectUrl'];
    if (json['photos'] != null) {
      photos = <Photos>[];
      json['photos'].forEach((v) {
        photos!.add(Photos.fromJson(v));
      });
    }
    assignedWorker = json['assignedWorker'] != null
        ? AssignedWorker.fromJson(json['assignedWorker'])
        : null;
    plateMasked =
        json['plateMasked'] ??
        json['plate_masked'] ??
        json['plateText'] ??
        json['plate_text'];
    invoice = json['invoice'] != null
        ? Invoice.fromJson(json['invoice'])
        : null;
    workerNotes = json['workerNotes'] != null
        ? List<String>.from(json['workerNotes'])
        : null;

    vehicleYear = json['vehicleYear'] != null
        ? int.tryParse(json['vehicleYear'].toString())
        : (json['vehicle_year'] != null
              ? int.tryParse(json['vehicle_year'].toString())
              : null);

    addressArrivalNotes = json['addressArrivalNotes'];
    vehicleMake = json['vehicleMake'] ?? json['vehicle_make'];
    vehicleModel = json['vehicleModel'] ?? json['vehicle_model'];
    vehicleColor = json['vehicleColor'] ?? json['vehicle_color'];

    packageName = json['packageName'] != null
        ? PackageName.fromJson(json['packageName'])
        : null;
    vehicleMakeLogoUrl =
        json['vehicleMakeLogoUrl'] ?? json['vehicle_make_logo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customerId'] = customerId;
    data['workerId'] = workerId;
    data['addressLabel'] = addressLabel;
    data['addressLat'] = addressLat;
    data['addressLng'] = addressLng;
    data['zoneId'] = zoneId;
    data['packageId'] = packageId;
    data['type'] = type?.name;
    data['status'] = status?.name;
    data['scheduledAt'] = scheduledAt;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['quoteId'] = quoteId;
    data['totalAmountMinor'] = totalAmountMinor;
    data['currency'] = currency;
    data['paymentStatus'] = paymentStatus;
    data['paymentIntentId'] = paymentIntentId;
    data['invoiceId'] = invoiceId;
    data['paymentVoidedAt'] = paymentVoidedAt;
    data['paymentStuckDetectedAt'] = paymentStuckDetectedAt;
    data['cancellationFeeMinor'] = cancellationFeeMinor;
    data['cancellationFeeWaived'] = cancellationFeeWaived;
    data['reschedulesUsed'] = reschedulesUsed;
    data['rescheduledAt'] = rescheduledAt;
    if (cancellationPolicy != null) {
      data['cancellationPolicy'] = cancellationPolicy!.toJson();
    }
    data['pspRedirectUrl'] = pspRedirectUrl;
    if (photos != null) {
      data['photos'] = photos!.map((v) => v.toJson()).toList();
    }
    if (assignedWorker != null) {
      data['assignedWorker'] = assignedWorker!.toJson();
    }
    data['plateMasked'] = plateMasked;
    if (invoice != null) {
      data['invoice'] = invoice!.toJson();
    }
    data['workerNotes'] = workerNotes;
    data['vehicleYear'] = vehicleYear;
    data['addressArrivalNotes'] = addressArrivalNotes;
    data['vehicleMake'] = vehicleMake;
    data['vehicleModel'] = vehicleModel;
    data['vehicleColor'] = vehicleColor;
    if (packageName != null) {
      data['packageName'] = packageName!.toJson();
    }
    data['vehicleMakeLogoUrl'] = vehicleMakeLogoUrl;
    return data;
  }

  // --- UI Compatibility Helpers ---
  String get title => (vehicleMake != null || vehicleModel != null)
      ? '${vehicleMake ?? ''} ${vehicleModel ?? ''}'.trim()
      : (type == BookingType.ON_DEMAND ? 'غسلة (على الطلب)' : 'غسلة جدولة');

  String get location => addressLabel ?? '';

  double get latitude => addressLat != null
      ? (addressLat!.toDouble().abs() > 180.0
            ? addressLat!.toDouble() / 1000000.0
            : addressLat!.toDouble())
      : 0.0;

  double get longitude => addressLng != null
      ? (addressLng!.toDouble().abs() > 180.0
            ? addressLng!.toDouble() / 1000000.0
            : addressLng!.toDouble())
      : 0.0;

  double get totalAmount => (totalAmountMinor ?? 0) / 100.0;

  bool get isUpcoming {
    if (status == null) return false;
    return status != BookingStatus.COMPLETED &&
        status != BookingStatus.CANCELLED;
  }

  String get formattedDateTime {
    if (scheduledAt == null) return '';
    try {
      final dateTime = DateTime.parse(scheduledAt!).toLocal();
      final timeStr = DateFormat.jm().format(dateTime);
      final dateStr = DateFormat.yMd().format(dateTime);
      return '$timeStr . $dateStr';
    } catch (_) {
      return scheduledAt!;
    }
  }
}

class CancellationPolicy {
  bool? isFreeNow;
  int? feeIfCancelledNowMinor;
  String? freeUntil;
  String? currency;

  CancellationPolicy({
    this.isFreeNow,
    this.feeIfCancelledNowMinor,
    this.freeUntil,
    this.currency,
  });

  CancellationPolicy.fromJson(Map<String, dynamic> json) {
    isFreeNow = json['isFreeNow'];
    feeIfCancelledNowMinor = json['feeIfCancelledNowMinor'];
    freeUntil = json['freeUntil'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isFreeNow'] = isFreeNow;
    data['feeIfCancelledNowMinor'] = feeIfCancelledNowMinor;
    data['freeUntil'] = freeUntil;
    data['currency'] = currency;
    return data;
  }
}

class Photos {
  String? stage;
  String? angle;
  String? url;

  Photos({this.stage, this.angle, this.url});

  Photos.fromJson(Map<String, dynamic> json) {
    stage = json['stage'];
    angle = json['angle'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stage'] = stage;
    data['angle'] = angle;
    data['url'] = url;
    return data;
  }
}

class AssignedWorker {
  String? workerId;
  String? displayName;
  int? ratingAggregate;

  AssignedWorker({this.workerId, this.displayName, this.ratingAggregate});

  AssignedWorker.fromJson(Map<String, dynamic> json) {
    workerId = json['workerId'];
    displayName = json['displayName'];
    ratingAggregate = json['ratingAggregate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workerId'] = workerId;
    data['displayName'] = displayName;
    data['ratingAggregate'] = ratingAggregate;
    return data;
  }
}

class Invoice {
  String? invoiceUuid;
  String? invoiceNumber;
  String? qrTlvBase64;
  String? reportStatus;
  String? reportedAt;
  String? pdfUrl;
  String? pdfUrlExpiresAt;

  Invoice({
    this.invoiceUuid,
    this.invoiceNumber,
    this.qrTlvBase64,
    this.reportStatus,
    this.reportedAt,
    this.pdfUrl,
    this.pdfUrlExpiresAt,
  });

  Invoice.fromJson(Map<String, dynamic> json) {
    invoiceUuid = json['invoiceUuid'];
    invoiceNumber = json['invoiceNumber'];
    qrTlvBase64 = json['qrTlvBase64'];
    reportStatus = json['reportStatus'];
    reportedAt = json['reportedAt'];
    pdfUrl = json['pdfUrl'];
    pdfUrlExpiresAt = json['pdfUrlExpiresAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invoiceUuid'] = invoiceUuid;
    data['invoiceNumber'] = invoiceNumber;
    data['qrTlvBase64'] = qrTlvBase64;
    data['reportStatus'] = reportStatus;
    data['reportedAt'] = reportedAt;
    data['pdfUrl'] = pdfUrl;
    data['pdfUrlExpiresAt'] = pdfUrlExpiresAt;
    return data;
  }
}

class PackageName {
  String? en;
  String? ar;

  PackageName({this.en, this.ar});

  PackageName.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar_SA'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['en'] = en;
    json['ar_SA'] = ar;
    return json;
  }
}
