enum PaymentMethodEnum {
  visa,
  applePay;

  String get name {
    switch (this) {
      case PaymentMethodEnum.visa:
        return 'Visa';
      case PaymentMethodEnum.applePay:
        return 'Apple Pay';
    }
  }
}
