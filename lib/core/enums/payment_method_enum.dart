enum PaymentMethod { creditCard, applePay }

extension PaymentMethodEnumExtension on PaymentMethod {
  String nameAr() {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمانية';
      case PaymentMethod.applePay:
        return 'أبل باي';
    }
  }

  String nameEn() {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }

  static PaymentMethod? fromString(String? val) {
    if (val == null) return null;
    switch (val.toLowerCase()) {
      case 'creditcard':
      case 'credit_card':
      case 'visa':
      case 'mastercard':
      case 'mada':
        return PaymentMethod.creditCard;
      case 'applepay':
      case 'apple_pay':
        return PaymentMethod.applePay;
      default:
        return null;
    }
  }
}
