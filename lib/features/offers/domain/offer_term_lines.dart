import '../../../generated/locale_keys.g.dart';
import '../data/models/customer_offer_model.dart';

/// One rendered row under "Offer details". Either a raw [literal] — the package
/// name, which arrives already localised from the API — or a [localeKey] plus
/// its positional [args], which the view feeds to easy_localization.
class OfferTermLine {
  const OfferTermLine.literal(this.literal)
      : localeKey = null,
        args = const [];

  const OfferTermLine.key(this.localeKey, this.args) : literal = null;

  final String? literal;
  final String? localeKey;
  final List<String> args;
}

/// Two-decimal SAR from minor units. 24900 -> '249.00'.
String sarFromMinor(int minor) => (minor / 100).toStringAsFixed(2);

/// The BR-OFR-10 minimum-order threshold as ONE line, or null when the offer
/// carries no threshold.
///
/// BR-OFR-10 makes the minimum order the one term that is deliberately NOT an
/// eligibility filter — it cannot be evaluated before a cart exists — so an
/// offer carrying it is shown anyway, "with the threshold stated on the card
/// and in the detail view". The card is the half that was missing: a customer
/// scrolling the rail could reach the booking flow and be refused there without
/// ever having been told the number. AC-EXT-06 grades exactly that.
///
/// Package offers never have one: the package half of `OfferTerms` leaves
/// `minOrderMinor` at 0, and the offer type — not the value — is what decides,
/// so a wire change cannot start printing a threshold on a package card.
OfferTermLine? offerMinOrderLine(CustomerOfferModel offer) {
  if (!offer.isPromoCode) return null;
  if (offer.terms.minOrderMinor <= 0) return null;
  return OfferTermLine.key(
    LocaleKeys.offers_min_order,
    [sarFromMinor(offer.terms.minOrderMinor)],
  );
}

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
      lines.add(OfferTermLine.key(
        LocaleKeys.offers_discount_percent,
        ['${terms.configuredValue}'],
      ));
    } else if (terms.discountType == 'FIXED_AMOUNT') {
      lines.add(OfferTermLine.key(
        LocaleKeys.offers_discount_amount,
        [sarFromMinor(terms.configuredValue)],
      ));
    }
    // Same helper the card uses, so the two surfaces AC-EXT-06 grades together
    // cannot state different thresholds.
    final minOrder = offerMinOrderLine(offer);
    if (minOrder != null) lines.add(minOrder);
    return lines;
  }

  final name = terms.packageName(isAr: isAr);
  if (name != null && name.isNotEmpty) lines.add(OfferTermLine.literal(name));
  if (terms.packageNumWashes > 0) {
    lines.add(OfferTermLine.key(
      LocaleKeys.offers_package_washes,
      ['${terms.packageNumWashes}'],
    ));
  }
  if (terms.packageValidityDays > 0) {
    lines.add(OfferTermLine.key(
      LocaleKeys.offers_package_validity,
      ['${terms.packageValidityDays}'],
    ));
  }
  if (terms.packagePriceMinor > 0) {
    lines.add(OfferTermLine.key(
      LocaleKeys.offers_package_price,
      [sarFromMinor(terms.packagePriceMinor)],
    ));
  }
  return lines;
}
