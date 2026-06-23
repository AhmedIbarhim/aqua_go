import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'vehicle_localized_name.dart';

class BookingVehicle {
  int? vehicleSeq;
  VehicleLocalizedName? vehicleMake;
  VehicleLocalizedName? vehicleModel;
  String? vehicleColor;
  int? vehicleYear;
  String? plate;
  String? makeLogoUrl;
  bool? colorEditable;

  BookingVehicle({
    this.vehicleSeq,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleYear,
    this.plate,
    this.makeLogoUrl,
    this.colorEditable,
  });

  BookingVehicle.fromJson(Map<String, dynamic> json) {
    vehicleSeq = json['vehicleSeq'];
    vehicleMake = json['vehicleMake'] != null
        ? (json['vehicleMake'] is Map
            ? VehicleLocalizedName.fromJson(json['vehicleMake'])
            : VehicleLocalizedName(en: json['vehicleMake'].toString(), ar: json['vehicleMake'].toString()))
        : null;
    vehicleModel = json['vehicleModel'] != null
        ? (json['vehicleModel'] is Map
            ? VehicleLocalizedName.fromJson(json['vehicleModel'])
            : VehicleLocalizedName(en: json['vehicleModel'].toString(), ar: json['vehicleModel'].toString()))
        : null;
    vehicleColor = json['vehicleColor'];
    vehicleYear = json['vehicleYear'] != null
        ? int.tryParse(json['vehicleYear'].toString())
        : null;
    plate = json['plate'];
    makeLogoUrl = json['makeLogoUrl'];
    colorEditable = json['colorEditable'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicleSeq'] = vehicleSeq;
    data['vehicleMake'] = vehicleMake?.toJson();
    data['vehicleModel'] = vehicleModel?.toJson();
    data['vehicleColor'] = vehicleColor;
    data['vehicleYear'] = vehicleYear;
    data['plate'] = plate;
    data['makeLogoUrl'] = makeLogoUrl;
    data['colorEditable'] = colorEditable;
    return data;
  }

  // --- UI Helpers for Backwards Compatibility ---
  String get makeName =>
      CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang
      ? (vehicleMake?.ar ?? '')
      : (vehicleMake?.en ?? '');

  String get modelName =>
      CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang
      ? (vehicleModel?.ar ?? '')
      : (vehicleModel?.en ?? '');
}
