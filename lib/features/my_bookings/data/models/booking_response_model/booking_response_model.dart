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
  int? vehicleYear;
  String? addressArrivalNotes;
  String? vehicleMake;
  String? vehicleModel;
  String? vehicleColor;
  PackageName? packageName;
  String? vehicleMakeLogoUrl;
  String? customerName;
  String? customerPhoneMasked;
  String? customerPhone;
  ReschedulePolicy? reschedulePolicy;
  List<BookingVehicle>? vehicles;
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
    this.vehicleYear,
    this.addressArrivalNotes,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.packageName,
    this.vehicleMakeLogoUrl,
    this.customerName,
    this.customerPhoneMasked,
    this.customerPhone,
    this.reschedulePolicy,
    this.vehicles,
    this.addOns,
    this.breakdown,
  });

  BookingResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceNumber = json['referenceNumber'] ?? json['reference_number'];
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
    invoice = json['invoice'] != null
        ? Invoice.fromJson(json['invoice'])
        : null;
    workerNotes = json['workerNotes'] != null
        ? (json['workerNotes'] is List
              ? List<String>.from(json['workerNotes'])
              : [json['workerNotes'].toString()])
        : null;

    addressArrivalNotes = json['addressArrivalNotes'];

    // Obtain vehicle data directly from the response root first
    vehicleMake = json['vehicleMake'] ?? json['vehicle_make'];
    vehicleModel = json['vehicleModel'] ?? json['vehicle_model'];
    vehicleColor = json['vehicleColor'] ?? json['vehicle_color'];
    vehicleYear = json['vehicleYear'] != null
        ? int.tryParse(json['vehicleYear'].toString())
        : (json['vehicle_year'] != null
            ? int.tryParse(json['vehicle_year'].toString())
            : null);
    vehicleMakeLogoUrl = json['vehicleMakeLogoUrl'] ??
        json['vehicle_make_logo_url'] ??
        json['makeLogoUrl'];
    plate = json['plate'] ??
        json['plateMasked'] ??
        json['plate_masked'] ??
        json['plateText'] ??
        json['plate_text'];

    // Extract details-specific nested vehicles array, falling back to it if root properties are null
    if (json['vehicles'] != null && json['vehicles'] is List) {
      vehicles = <BookingVehicle>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(BookingVehicle.fromJson(v));
      });
      if (vehicles!.isNotEmpty) {
        final firstVehicle = vehicles!.first;
        vehicleMake ??= firstVehicle.vehicleMake;
        vehicleModel ??= firstVehicle.vehicleModel;
        vehicleColor ??= firstVehicle.vehicleColor;
        vehicleYear ??= firstVehicle.vehicleYear;
        plate ??= firstVehicle.plate;
        vehicleMakeLogoUrl ??= firstVehicle.makeLogoUrl;
      }
    }

    packageName = json['packageName'] != null
        ? PackageName.fromJson(json['packageName'])
        : null;

    customerName = json['customerName'];
    customerPhoneMasked = json['customerPhoneMasked'] ??
        json['customerPhone'] ??
        json['customer_phone'];
    customerPhone = json['customerPhone'] ??
        json['customer_phone'] ??
        json['customerPhoneMasked'] ??
        json['customer_phone_masked'];
    reschedulePolicy = json['reschedulePolicyView'] != null
        ? ReschedulePolicy.fromJson(json['reschedulePolicyView'])
        : (json['reschedulePolicy'] != null
            ? ReschedulePolicy.fromJson(json['reschedulePolicy'])
            : null);
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
    data['vehicleYear'] = vehicleYear;
    data['addressArrivalNotes'] = addressArrivalNotes;
    data['vehicleMake'] = vehicleMake;
    data['vehicleModel'] = vehicleModel;
    data['vehicleColor'] = vehicleColor;
    if (packageName != null) {
      data['packageName'] = packageName!.toJson();
    }
    data['vehicleMakeLogoUrl'] = vehicleMakeLogoUrl;
    data['customerName'] = customerName;
    data['customerPhoneMasked'] = customerPhoneMasked;
    data['customerPhone'] = customerPhone;
    if (reschedulePolicy != null) {
      data['reschedulePolicyView'] = reschedulePolicy!.toJson();
    }
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['addOns'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (breakdown != null) {
      data['breakdown'] = breakdown!.toJson();
    }
    return data;
  }

  // --- UI Compatibility Helpers ---
  String get title => CacheClient.getString(kLanguage) == kArabicLang
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
