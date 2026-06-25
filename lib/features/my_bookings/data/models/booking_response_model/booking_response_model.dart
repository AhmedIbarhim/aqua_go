import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/enums/payment_status_enum.dart';
import '../../enums/booking_status_enum.dart';
import '../../enums/booking_type_enum.dart';
import 'assigned_worker.dart';
import 'booking_addon.dart';
import 'booking_address.dart';
import 'booking_rating.dart';
import 'booking_vehicle.dart';
import 'breakdown.dart';
import 'cancellation_policy.dart';
import 'package_name.dart';
import 'photos.dart';
import 'quote_line.dart';
import 'reschedule_policy.dart';
import 'service_name.dart';
export 'assigned_worker.dart';
export 'booking_addon.dart';
export 'booking_address.dart';
export 'booking_rating.dart';
export 'booking_vehicle.dart';
export 'bookings_list_response_model.dart';
export 'breakdown.dart';
export 'cancellation_policy.dart';
export 'invoice.dart';
export 'package_name.dart';
export 'photos.dart';
export 'quote_line.dart';
export 'reschedule_policy.dart';
export 'vehicle_localized_name.dart';

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
  PaymentStatus? paymentStatus;
  bool? isSubscription;
  String? moyasarPaymentId;
  // String? invoiceId;
  int? cancellationFeeMinor;
  bool? cancellationFeeWaived;
  int? reschedulesUsed;
  String? rescheduledAt;
  CancellationPolicy? cancellationPolicy;
  List<Photos>? photos;
  AssignedWorker? assignedWorker;
  String? plate;
  // Invoice? invoice;
  List<String>? workerNotes;
  String? addressArrivalNotes;
  List<BookingVehicle>? vehicles;
  PackageName? packageName;
  ServiceName? serviceName;
  ReschedulePolicy? reschedulePolicy;
  String? customerName;
  String? customerPhone;
  List<BookingAddon>? addOns;
  List<QuoteLine>? lines;
  Breakdown? breakdown;
  BookingAddress? address;
  BookingRatingModel? rating;
  String? complaintId;
  String? paymentIntentId;
  String? paymentStuckDetectedAt;
  String? pspRedirectUrl;
  String? startedAt;
  String? completedAt;
  String? cancelledAt;
  String? completionNotes;
  String? cantFindClientReportedAt;

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
    this.isSubscription,
    this.moyasarPaymentId,
    // this.invoiceId,
    this.cancellationFeeMinor,
    this.cancellationFeeWaived,
    this.reschedulesUsed,
    this.rescheduledAt,
    this.cancellationPolicy,
    this.photos,
    this.assignedWorker,
    this.plate,
    // this.invoice,
    this.workerNotes,
    this.addressArrivalNotes,
    this.vehicles,
    this.packageName,
    this.serviceName,
    this.reschedulePolicy,
    this.customerName,
    this.customerPhone,
    this.addOns,
    this.lines,
    this.breakdown,
    this.address,
    this.rating,
    this.complaintId,
    this.paymentIntentId,
    this.paymentStuckDetectedAt,
    this.pspRedirectUrl,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.completionNotes,
    this.cantFindClientReportedAt,
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
    paymentStatus = PaymentStatus.fromString(json['paymentStatus']);
    isSubscription = json['isSubscription'];
    moyasarPaymentId = json['moyasarPaymentId'];
    // invoiceId = json['invoiceId'];
    cancellationFeeMinor = json['cancellationFeeMinor'];
    cancellationFeeWaived = json['cancellationFeeWaived'];
    reschedulesUsed = json['reschedulesUsed'];
    rescheduledAt = json['rescheduledAt'];
    cancellationPolicy = json['cancellationPolicy'] != null
        ? CancellationPolicy.fromJson(json['cancellationPolicy'])
        : null;
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
    // invoice = json['invoice'] != null
    //     ? Invoice.fromJson(json['invoice'])
    //     : null;
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
    serviceName = json['serviceName'] != null
        ? ServiceName.fromJson(json['serviceName'])
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
    lines = QuoteLine.listFromJson(json['lines']);
    breakdown = json['breakdown'] != null
        ? Breakdown.fromJson(json['breakdown'])
        : null;
    address = json['address'] != null
        ? BookingAddress.fromJson(json['address'])
        : null;
    rating = json['rating'] != null
        ? BookingRatingModel.fromJson(json['rating'])
        : null;
    complaintId = json['complaintId'];
    paymentIntentId = json['paymentIntentId'];
    paymentStuckDetectedAt = json['paymentStuckDetectedAt'];
    pspRedirectUrl = json['pspRedirectUrl'];
    startedAt = json['startedAt'];
    completedAt = json['completedAt'];
    cancelledAt = json['cancelledAt'];
    completionNotes = json['completionNotes'];
    cantFindClientReportedAt = json['cantFindClientReportedAt'];
  }

  // --- UI Compatibility Helpers ---
  String get title =>
      CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang
      ? (serviceName?.ar ?? packageName?.ar ?? '')
      : (serviceName?.en ?? packageName?.en ?? '');

  String get location => addressLabel ?? address?.label ?? '';

  double get latitude => (addressLat ?? address?.lat) != null
      ? ((addressLat ?? address!.lat!).toDouble().abs() > 180.0
            ? (addressLat ?? address!.lat!).toDouble() / 1000000.0
            : (addressLat ?? address!.lat!).toDouble())
      : 0.0;

  double get longitude => (addressLng ?? address?.lng) != null
      ? ((addressLng ?? address!.lng!).toDouble().abs() > 180.0
            ? (addressLng ?? address!.lng!).toDouble() / 1000000.0
            : (addressLng ?? address!.lng!).toDouble())
      : 0.0;

  double get totalAmount => (totalAmountMinor ?? 0) / 100.0;

  /// A subscription wash is pre-paid by the subscription — there is no per-wash
  /// charge (total is 0 / NOT_REQUIRED). `isSubscription` is the robust signal;
  /// the per-wash money total must read as covered, not "0.00".
  bool get isCoveredBySubscription => isSubscription == true;

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
