/// The shape a promo code has to have before it is worth a round trip.
///
/// UCC16's input-field spec: "4–20 alphanumeric, case-insensitive". Checked on
/// the device so an obvious typo — a stray space, a pasted URL, three
/// characters — is answered immediately instead of coming back as a generic
/// "code not recognised", which is the same message an unknown code gets and
/// would leave the customer guessing which of the two happened.
///
/// Case is irrelevant: the server normalises to upper case on every lookup, so
/// `welcome20` and `WELCOME20` are the same code.
const int promoCodeMinLength = 4;
const int promoCodeMaxLength = 20;

final RegExp _promoCodeShape = RegExp(
  '^[A-Za-z0-9]{$promoCodeMinLength,$promoCodeMaxLength}\$',
);

/// True when [code] can be sent as it stands (after trimming).
bool isWellFormedPromoCode(String code) =>
    _promoCodeShape.hasMatch(code.trim());
