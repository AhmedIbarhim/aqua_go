import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';

class BookingAddon {
  String? addonId;
  String? nameAr;
  String? nameEn;
  String? currency;
  String? kind;
  int? qty;
  int? freeQty;
  int? paidQty;
  int? unitPriceMinor;
  int? chargedMinor;

  BookingAddon({
    this.addonId,
    this.nameAr,
    this.nameEn,
    this.currency,
    this.kind,
    this.qty,
    this.freeQty,
    this.paidQty,
    this.unitPriceMinor,
    this.chargedMinor,
  });

  BookingAddon.fromJson(Map<String, dynamic> json) {
    addonId = json['addonId'];
    nameAr = json['nameAr'];
    nameEn = json['nameEn'];
    currency = json['currency'];
    kind = json['kind'];
    qty = json['qty'] != null ? int.tryParse(json['qty'].toString()) : null;
    freeQty = json['freeQty'] != null
        ? int.tryParse(json['freeQty'].toString())
        : null;
    paidQty = json['paidQty'] != null
        ? int.tryParse(json['paidQty'].toString())
        : null;
    unitPriceMinor = json['unitPriceMinor'] != null
        ? int.tryParse(json['unitPriceMinor'].toString())
        : null;
    chargedMinor = json['chargedMinor'] != null
        ? int.tryParse(json['chargedMinor'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['addonId'] = addonId;
    data['nameAr'] = nameAr;
    data['nameEn'] = nameEn;
    data['currency'] = currency;
    data['kind'] = kind;
    data['qty'] = qty;
    data['freeQty'] = freeQty;
    data['paidQty'] = paidQty;
    data['unitPriceMinor'] = unitPriceMinor;
    data['chargedMinor'] = chargedMinor;
    return data;
  }

  // --- UI Helpers ---
  String get name =>
      CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang
      ? (nameAr ?? '')
      : (nameEn ?? '');

  double get unitPrice => (unitPriceMinor ?? 0) / 100.0;
  double get charged => (chargedMinor ?? 0) / 100.0;
}
