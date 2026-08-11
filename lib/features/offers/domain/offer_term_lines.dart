import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';
import '../data/models/customer_offer_model.dart';

sealed class OfferTermLine {
  const OfferTermLine();
}

class OfferTermLiteral extends OfferTermLine {
  const OfferTermLiteral(this.text);

  final String text;
}

class OfferTermKey extends OfferTermLine {
  const OfferTermKey(
    this.key,
    this.args, {
    this.struckThrough = false,
    this.moneyArgIndex,
  });

  final String key;
  final List<String> args;

  final int? moneyArgIndex;

  final bool struckThrough;
}

String sarFromMinor(int minor) => (minor / 100).toStringAsFixed(2);

OfferTermKey? offerMinOrderLine(CustomerOfferModel offer) {
  if (!offer.isPromoCode) return null;
  if (offer.terms.minOrderMinor <= 0) return null;
  return OfferTermKey(LocaleKeys.offers_min_order, [
    sarFromMinor(offer.terms.minOrderMinor),
  ], moneyArgIndex: 0);
}

DateTime offerLastLiveDay(DateTime endsAt) {
  final atMidnight =
      endsAt.hour == 0 &&
      endsAt.minute == 0 &&
      endsAt.second == 0 &&
      endsAt.millisecond == 0 &&
      endsAt.microsecond == 0;
  return atMidnight ? endsAt.subtract(const Duration(days: 1)) : endsAt;
}

OfferTermKey offerExpiryLine(CustomerOfferModel offer, {required bool isAr}) {
  final formatted = DateFormat.yMMMd(
    isAr ? 'ar' : 'en',
  ).format(offerLastLiveDay(offer.endsAt));
  return OfferTermKey(LocaleKeys.offers_expires_on, [formatted]);
}

String _joinNames(List<String> names, {required bool isAr}) =>
    names.join(isAr ? '، ' : ', ');

List<OfferTermLine> offerTermLines(
  CustomerOfferModel offer, {
  required bool isAr,
}) {
  final terms = offer.terms;
  final lines = <OfferTermLine>[];

  if (offer.isPromoCode) {
    if (terms.discountType == 'PERCENTAGE') {
      lines.add(
        OfferTermKey(LocaleKeys.offers_discount_percent, [
          '${terms.configuredValue}',
        ]),
      );
    } else if (terms.discountType == 'FIXED_AMOUNT') {
      lines.add(
        OfferTermKey(LocaleKeys.offers_discount_amount, [
          sarFromMinor(terms.configuredValue),
        ], moneyArgIndex: 0),
      );
    } else if (terms.discountType == 'TARGET_PRICE') {
      lines.add(
        OfferTermKey(LocaleKeys.offers_discount_target_price, [
          sarFromMinor(terms.configuredValue),
        ], moneyArgIndex: 0),
      );
    }

    final minOrder = offerMinOrderLine(offer);
    if (minOrder != null) lines.add(minOrder);

    final services = terms.applicableServices(isAr: isAr);
    if (services.isNotEmpty) {
      lines.add(
        OfferTermKey(LocaleKeys.offers_applicable_services, [
          _joinNames(services, isAr: isAr),
        ]),
      );
    }

    final zones = terms.applicableZones(isAr: isAr);
    if (zones.isNotEmpty) {
      lines.add(
        OfferTermKey(LocaleKeys.offers_applicable_zones, [
          _joinNames(zones, isAr: isAr),
        ]),
      );
    }
    return lines;
  }

  if (offer.isService) {
    final serviceName = terms.serviceName(isAr: isAr);
    if (serviceName != null && serviceName.isNotEmpty) {
      lines.add(OfferTermLiteral(serviceName));
    }
    if (offer.hasTargetPrice) {
      if (terms.serviceListPriceMinor > terms.targetPriceMinor) {
        lines.add(
          OfferTermKey(
            LocaleKeys.offers_service_list_price,
            [sarFromMinor(terms.serviceListPriceMinor)],
            struckThrough: true,
            moneyArgIndex: 0,
          ),
        );
      }
      lines.add(
        OfferTermKey(LocaleKeys.offers_service_price, [
          sarFromMinor(terms.targetPriceMinor),
        ], moneyArgIndex: 0),
      );
    }
    return lines;
  }

  final name = terms.packageName(isAr: isAr);
  if (name != null && name.isNotEmpty) lines.add(OfferTermLiteral(name));
  if (terms.packageNumWashes > 0) {
    lines.add(
      OfferTermKey(LocaleKeys.offers_package_washes, [
        '${terms.packageNumWashes}',
      ]),
    );
  }
  if (terms.packageValidityDays > 0) {
    lines.add(
      OfferTermKey(LocaleKeys.offers_package_validity, [
        '${terms.packageValidityDays}',
      ]),
    );
  }
  if (terms.packagePriceMinor > 0) {
    lines.add(
      OfferTermKey(LocaleKeys.offers_package_price, [
        sarFromMinor(terms.packagePriceMinor),
      ], moneyArgIndex: 0),
    );
  }
  return lines;
}
