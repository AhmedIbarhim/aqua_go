import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';

class BookingAddon {
  String? addonId;
  int? qty;
  int? unitPriceMinor;
  int? chargedMinor;
  String? source;
  String? nameAr;
  String? nameEn;

  BookingAddon({
    this.addonId,
    this.qty,
    this.unitPriceMinor,
    this.chargedMinor,
    this.source,
    this.nameAr,
    this.nameEn,
  });

  BookingAddon.fromJson(Map<String, dynamic> json) {
    addonId = json['addonId'];
    qty = json['qty'] != null ? int.tryParse(json['qty'].toString()) : null;
    unitPriceMinor = json['unitPriceMinor'] != null
        ? int.tryParse(json['unitPriceMinor'].toString())
        : null;
    chargedMinor = json['chargedMinor'] != null
        ? int.tryParse(json['chargedMinor'].toString())
        : null;
    source = json['source'];
    nameAr = json['nameAr'];
    nameEn = json['nameEn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['addonId'] = addonId;
    data['qty'] = qty;
    data['unitPriceMinor'] = unitPriceMinor;
    data['chargedMinor'] = chargedMinor;
    data['source'] = source;
    data['nameAr'] = nameAr;
    data['nameEn'] = nameEn;
    return data;
  }

  // --- UI Helpers ---
  String get name => CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang
      ? (nameAr ?? '')
      : (nameEn ?? '');

  double get unitPrice => (unitPriceMinor ?? 0) / 100.0;
  double get charged => (chargedMinor ?? 0) / 100.0;
}
