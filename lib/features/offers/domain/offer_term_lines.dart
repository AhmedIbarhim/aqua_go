// DateFormat, via easy_localization's re-export — `intl` is a transitive
// dependency and importing it directly is not declared in pubspec.
import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';
import '../data/models/customer_offer_model.dart';

/// One rendered row under "Offer details".
///
/// Sealed on purpose: a row is EITHER an [OfferTermLiteral] — the package name,
/// which arrives already localised from the API — OR an [OfferTermKey], a
/// locale key plus its positional args that the view feeds to easy_localization.
/// Two nullable fields would only encode that exclusivity by convention, and
/// every render site would have to force-unwrap one of them; a sealed hierarchy
/// makes the compiler check the switch instead.
sealed class OfferTermLine {
  const OfferTermLine();
}

/// A row whose text is already in the reader's language when it arrives.
class OfferTermLiteral extends OfferTermLine {
  const OfferTermLiteral(this.text);

  final String text;
}

/// A row rendered from a locale [key] and its positional [args].
class OfferTermKey extends OfferTermLine {
  const OfferTermKey(this.key, this.args);

  final String key;
  final List<String> args;
}

/// Two-decimal SAR from minor units. 24900 -> '249.00'.
String sarFromMinor(int minor) => (minor / 100).toStringAsFixed(2);

/// The BR-OFR-10 minimum-order threshold as ONE line, or null when the offer
/// carries no threshold.
///
/// BR-OFR-10 makes the minimum order the one term that is deliberately NOT an
/// eligibility filter — it cannot be evaluated before a cart exists — so an
/// offer carrying it is shown anyway, with the threshold stated rather than
/// used to withhold the offer.
///
/// The DETAIL view is the only surface that states it in text, and the only
/// caller of this helper. Since §1.5b the card is its artwork and nothing else,
/// so the number reaches a customer scrolling the rail only through the banner
/// image itself — a brief for whoever produces the artwork, not a code path.
/// AC-EXT-06's first leg is graded on the detail view.
///
/// Package offers never have one: the package half of `OfferTerms` leaves
/// `minOrderMinor` at 0, and the offer type — not the value — is what decides,
/// so a wire change cannot start printing a threshold on a package card.
OfferTermKey? offerMinOrderLine(CustomerOfferModel offer) {
  if (!offer.isPromoCode) return null;
  if (offer.terms.minOrderMinor <= 0) return null;
  return OfferTermKey(
    LocaleKeys.offers_min_order,
    [sarFromMinor(offer.terms.minOrderMinor)],
  );
}

/// UCC23 step 6 lists "expiry" among the terms, so the offer's end date is a
/// term row like any other rather than a footnote on the summary.
///
/// Always present: every offer has an end date, and the far-future
/// [CustomerOfferModel.endsAtFallback] only stands in for an unparseable one,
/// which the server never sends.
/// Formatted from `endsAt`'s own fields, with NO `.toLocal()`: the value is in
/// the Riyadh frame, so its fields already ARE the date the customer should
/// read. Converting would re-interpret them through the device's offset and
/// print the wrong day either side of midnight.
OfferTermKey offerExpiryLine(CustomerOfferModel offer, {required bool isAr}) {
  final formatted =
      DateFormat.yMMMd(isAr ? 'ar' : 'en').format(offer.endsAt);
  return OfferTermKey(LocaleKeys.offers_expires_on, [formatted]);
}

/// Joins restriction names with the separator the reader's script uses — the
/// Arabic comma U+060C, not the Latin one, which reads as a typo in Arabic.
String _joinNames(List<String> names, {required bool isAr}) =>
    names.join(isAr ? '، ' : ', ');

/// The term rows for [offer].
///
/// The discount-type literals MUST stay byte-identical to the backend's
/// com.aquago.promo.internal.application.PromoServiceImpl constants —
/// DISCOUNT_TYPE_PERCENTAGE = "PERCENTAGE" and
/// DISCOUNT_TYPE_FIXED_AMOUNT = "FIXED_AMOUNT". A drift renders an EMPTY terms
/// block with no error anywhere, which is why this is a pure, unit-tested
/// function instead of an inline branch in the widget.
List<OfferTermLine> offerTermLines(CustomerOfferModel offer, {required bool isAr}) {
  final terms = offer.terms;
  final lines = <OfferTermLine>[];

  if (offer.isPromoCode) {
    if (terms.discountType == 'PERCENTAGE') {
      lines.add(OfferTermKey(
        LocaleKeys.offers_discount_percent,
        ['${terms.configuredValue}'],
      ));
    } else if (terms.discountType == 'FIXED_AMOUNT') {
      lines.add(OfferTermKey(
        LocaleKeys.offers_discount_amount,
        [sarFromMinor(terms.configuredValue)],
      ));
    }
    // BR-OFR-10's threshold, kept in its own helper rather than inlined here:
    // it is the one term that is stated INSTEAD of being enforced at display
    // time, so it is worth reading and testing on its own.
    final minOrder = offerMinOrderLine(offer);
    if (minOrder != null) lines.add(minOrder);

    // UCC23 step 6 — "applicable services, applicable zones". An EMPTY list is
    // UNRESTRICTED, so it produces no row: printing "Valid on nothing" would
    // invert the meaning, and printing an empty row would look like a bug.
    final services = terms.applicableServices(isAr: isAr);
    if (services.isNotEmpty) {
      lines.add(OfferTermKey(
        LocaleKeys.offers_applicable_services,
        [_joinNames(services, isAr: isAr)],
      ));
    }
    // A5 — stated whether or not the customer has a saved address. The zone
    // rule is SKIPPED for an address-less customer rather than failed, so the
    // offer reaches them, and the restriction they will meet at apply time has
    // to be on the card that got them there.
    final zones = terms.applicableZones(isAr: isAr);
    if (zones.isNotEmpty) {
      lines.add(OfferTermKey(
        LocaleKeys.offers_applicable_zones,
        [_joinNames(zones, isAr: isAr)],
      ));
    }
    return lines;
  }

  final name = terms.packageName(isAr: isAr);
  if (name != null && name.isNotEmpty) lines.add(OfferTermLiteral(name));
  if (terms.packageNumWashes > 0) {
    lines.add(OfferTermKey(
      LocaleKeys.offers_package_washes,
      ['${terms.packageNumWashes}'],
    ));
  }
  if (terms.packageValidityDays > 0) {
    lines.add(OfferTermKey(
      LocaleKeys.offers_package_validity,
      ['${terms.packageValidityDays}'],
    ));
  }
  if (terms.packagePriceMinor > 0) {
    lines.add(OfferTermKey(
      LocaleKeys.offers_package_price,
      [sarFromMinor(terms.packagePriceMinor)],
    ));
  }
  return lines;
}
