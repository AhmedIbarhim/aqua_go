import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../enums/booking_status_enum.dart';
import '../../enums/booking_type_enum.dart';
import 'assigned_worker.dart';
import 'booking_addon.dart';
import 'booking_vehicle.dart';
import 'breakdown.dart';
import 'cancellation_policy.dart';
import 'invoice.dart';
import 'package_name.dart';
import 'photos.dart';
import 'reschedule_policy.dart';
export 'assigned_worker.dart';
export 'booking_addon.dart';
export 'booking_vehicle.dart';
export 'bookings_list_response_model.dart';
export 'breakdown.dart';
export 'cancellation_policy.dart';
export 'invoice.dart';
export 'package_name.dart';
export 'photos.dart';
export 'reschedule_policy.dart';

class BookingResponseModel {
  String? id;
  String? referenceNumber;
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
  String? plate;
  Invoice? invoice;
  List<String>? workerNotes;
  String? addressArrivalNotes;
  List<BookingVehicle>? vehicles;
  PackageName? packageName;
  ReschedulePolicy? reschedulePolicy;
  String? customerName;
  String? customerPhone;
  List<BookingAddon>? addOns;
  Breakdown? breakdown;

  BookingResponseModel({
    this.id,
    this.referenceNumber,
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
    this.plate,
    this.invoice,
    this.workerNotes,
    this.addressArrivalNotes,
    this.vehicles,
    this.packageName,
    this.reschedulePolicy,
    this.customerName,
    this.customerPhone,
    this.addOns,
    this.breakdown,
  });

  BookingResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceNumber = json['referenceNumber'];
    customerId = json['customerId'];
    workerId = json['workerId'];
    addressLabel = json['addressLabel'];
    addressLat = json['addressLat'] != null
        ? num.tryParse(json['addressLat'].toString())
        : null;
    addressLng = json['addressLng'] != null
        ? num.tryParse(json['addressLng'].toString())
        : null;
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
    plate = json['plate'];
    invoice = json['invoice'] != null
        ? Invoice.fromJson(json['invoice'])
        : null;
    workerNotes = json['workerNotes'] != null
        ? List<String>.from(json['workerNotes'])
        : null;
    addressArrivalNotes = json['addressArrivalNotes'];
    if (json['vehicles'] != null && json['vehicles'] is List) {
      vehicles = <BookingVehicle>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(BookingVehicle.fromJson(v));
      });
    }
    packageName = json['packageName'] != null
        ? PackageName.fromJson(json['packageName'])
        : null;
    reschedulePolicy = json['reschedulePolicyView'] != null
        ? ReschedulePolicy.fromJson(json['reschedulePolicyView'])
        : null;
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    if (json['addOns'] != null && json['addOns'] is List) {
      addOns = <BookingAddon>[];
      json['addOns'].forEach((v) {
        addOns!.add(BookingAddon.fromJson(v));
      });
    }
    breakdown = json['breakdown'] != null
        ? Breakdown.fromJson(json['breakdown'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['referenceNumber'] = referenceNumber;
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
    data['plate'] = plate;
    if (invoice != null) {
      data['invoice'] = invoice!.toJson();
    }
    data['workerNotes'] = workerNotes;
    data['addressArrivalNotes'] = addressArrivalNotes;
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    if (packageName != null) {
      data['packageName'] = packageName!.toJson();
    }
    if (reschedulePolicy != null) {
      data['reschedulePolicyView'] = reschedulePolicy!.toJson();
    }
    data['customerName'] = customerName;
    data['customerPhone'] = customerPhone;
    if (addOns != null) {
      data['addOns'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (breakdown != null) {
      data['breakdown'] = breakdown!.toJson();
    }
    return data;
  }

  // --- UI Compatibility Helpers ---
  String get title =>
      CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang
      ? (packageName?.ar ?? '')
      : (packageName?.en ?? '');

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
      return '$dateStr - $timeStr';
    } catch (_) {
      return scheduledAt!;
    }
  }
}
