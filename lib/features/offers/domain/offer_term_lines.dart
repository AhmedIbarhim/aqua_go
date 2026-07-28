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
  const OfferTermKey(this.key, this.args, {this.struckThrough = false});

  final String key;
  final List<String> args;

  /// Whether the row is drawn crossed out — true only for the price an offer
  /// REPLACES, so the saving is legible without arithmetic. It is a property of
  /// the row rather than of the render site because only this function knows
  /// which of two price rows is the superseded one, and it is only ever set
  /// where the struck figure is genuinely the higher of the two.
  final bool struckThrough;
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

/// The last KSA day the offer is actually usable on, from its EXCLUSIVE
/// `endsAt` bound.
///
/// `endsAt` is documented on the backend record as "when the offer stops being
/// shown (exclusive)" and the feed query is `o.endsAt > :now`, so a bound
/// sitting on a KSA midnight excludes that whole day: an operator who runs a
/// campaign THROUGH 31 August stores 1 September's midnight. Printing the bound
/// verbatim names a day the offer is already gone on — the console shows
/// "31 August" and the customer app said "1 September", for a date on which
/// [visibleOffers] has already dropped the card.
///
/// A bound that carries a real time of day is already INSIDE its own last day
/// and is reported as-is; shifting it would move a date nobody picked. This is
/// the exact mirror of admin-web's `isoToEndDay`, and the two must stay one
/// rule — the operator's picker and the customer's terms line are describing
/// the same calendar day.
///
/// `endsAt` is UTC-flagged with Asia/Riyadh wall-clock fields
/// ([tryParseWireDateTime]), so "midnight" is read off the fields directly and
/// the day arithmetic never passes through a device offset.
DateTime offerLastLiveDay(DateTime endsAt) {
  final atMidnight = endsAt.hour == 0 &&
      endsAt.minute == 0 &&
      endsAt.second == 0 &&
      endsAt.millisecond == 0 &&
      endsAt.microsecond == 0;
  return atMidnight ? endsAt.subtract(const Duration(days: 1)) : endsAt;
}

/// UCC23 step 6 lists "expiry" among the terms, so the offer's end date is a
/// term row like any other rather than a footnote on the summary.
///
/// Always present: every offer has an end date, and the far-future
/// [CustomerOfferModel.endsAtFallback] only stands in for an unparseable one,
/// which the server never sends.
/// Formatted from the [offerLastLiveDay] fields, with NO `.toLocal()`: the
/// value is in the Riyadh frame, so its fields already ARE the date the
/// customer should read. Converting would re-interpret them through the
/// device's offset and print the wrong day either side of midnight.
OfferTermKey offerExpiryLine(CustomerOfferModel offer, {required bool isAr}) {
  final formatted =
      DateFormat.yMMMd(isAr ? 'ar' : 'en').format(offerLastLiveDay(offer.endsAt));
  return OfferTermKey(LocaleKeys.offers_expires_on, [formatted]);
}

/// Joins restriction names with the separator the reader's script uses — the
/// Arabic comma U+060C, not the Latin one, which reads as a typo in Arabic.
String _joinNames(List<String> names, {required bool isAr}) =>
    names.join(isAr ? '، ' : ', ');

/// The term rows for [offer] — one arm per offer type, each of which returns
/// rather than falling through. The three thirds of `OfferTerms` share no
/// field, so an arm reached by the wrong type reads all-zero and emits nothing
/// at all; the type is what selects the arm, never the values.
///
/// The discount-type literals MUST stay byte-identical to the backend's
/// com.aquago.promo.internal.application.PromoServiceImpl constants, and there
/// are THREE of them, not two — "PERCENTAGE", "FIXED_AMOUNT" and
/// "TARGET_PRICE". A literal with no arm renders an EMPTY terms block with no
/// error anywhere, which is why this is a pure, unit-tested function instead of
/// an inline branch in the widget: `offer_term_lines_test.dart` walks the whole
/// backend set and fails on the first literal that emits no discount row.
///
/// The three do NOT share a unit. `configuredValue` is whole percentage points
/// for PERCENTAGE, halala OFF the order for FIXED_AMOUNT, and for TARGET_PRICE
/// the VAT-INCLUSIVE GROSS PRICE IN HALALA THE WASH BECOMES — never an amount
/// off it. Wording a target as a reduction states the deal an order of
/// magnitude wrong in the customer's favour, so each arm owns its own key.
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
    } else if (terms.discountType == 'TARGET_PRICE') {
      // A PROMO_CODE offer may link a STANDALONE target-price code — nothing
      // rejects one: `OfferServiceImpl.requireUnmanagedPromoLink` refuses only
      // ANOTHER offer's MANAGED code, and the discount type is passed through
      // verbatim. Without this arm the terms block said nothing at all about
      // what the code does.
      //
      // TARGET_PRICE is LINE-scoped: `configuredValue` is the FINAL gross the
      // wash BECOMES, so the row states a PRICE. It must never be worded as a
      // reduction — "35.00 off" for a code that sets a 175.00 wash to 35.00
      // reads as a 35.00 saving instead of a 140.00 one.
      lines.add(OfferTermKey(
        LocaleKeys.offers_discount_target_price,
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

  // The SERVICE third. It has its OWN arm because it shares no field with the
  // package third: `packageName` is null and packageNumWashes /
  // packageValidityDays / packagePriceMinor are all 0 by construction, so a
  // SERVICE offer falling through to the tail below emitted ZERO rows — the
  // "Offer details" heading over nothing but the expiry, on the one screen that
  // states in text what the deal actually is.
  if (offer.isService) {
    final serviceName = terms.serviceName(isAr: isAr);
    if (serviceName != null && serviceName.isNotEmpty) {
      lines.add(OfferTermLiteral(serviceName));
    }
    // A SHORTCUT card carries no deal — `targetPriceMinor` 0 means "nothing to
    // show", never "free" — so it names the wash and stops. Pricing it here
    // would state a discount the offer does not carry. `hasTargetPrice` is the
    // documented way to ask, rather than testing the number.
    if (offer.hasTargetPrice) {
      // The list price is struck through ONLY when it is genuinely above what
      // the offer charges. An admin who drops the wash below an already
      // published target leaves the pair inverted, and the server then clamps
      // the discount to 0 and charges the LOWER list price — so crossing out
      // 79.00 beside 99.00 would advertise a deal priced above the number it
      // crossed out. Verbatim server figures either way: nothing here is
      // derived, no VAT arithmetic, no subtraction.
      if (terms.serviceListPriceMinor > terms.targetPriceMinor) {
        lines.add(OfferTermKey(
          LocaleKeys.offers_service_list_price,
          [sarFromMinor(terms.serviceListPriceMinor)],
          struckThrough: true,
        ));
      }
      lines.add(OfferTermKey(
        LocaleKeys.offers_service_price,
        [sarFromMinor(terms.targetPriceMinor)],
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
