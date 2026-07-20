/// Thread kind — a customer support ticket or a customer↔worker thread.
///
/// The customer support inbox surfaces CUSTOMER_SUPPORT threads; CUSTOMER_WORKER
/// is modelled for completeness (worker-linked threads share the same shape).
enum ChatThreadKind {
  customerSupport,
  customerWorker;

  static ChatThreadKind fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CUSTOMER_WORKER':
        return ChatThreadKind.customerWorker;
      case 'CUSTOMER_SUPPORT':
      default:
        return ChatThreadKind.customerSupport;
    }
  }

  String get originalValue {
    switch (this) {
      case ChatThreadKind.customerSupport:
        return 'CUSTOMER_SUPPORT';
      case ChatThreadKind.customerWorker:
        return 'CUSTOMER_WORKER';
    }
  }
}
