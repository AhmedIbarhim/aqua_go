const int promoCodeMinLength = 4;
const int promoCodeMaxLength = 20;

final RegExp _promoCodeShape = RegExp(
  '^[A-Za-z0-9]{$promoCodeMinLength,$promoCodeMaxLength}\$',
);

bool isWellFormedPromoCode(String code) =>
    _promoCodeShape.hasMatch(code.trim());
