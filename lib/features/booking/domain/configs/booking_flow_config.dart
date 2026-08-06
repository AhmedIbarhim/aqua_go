import 'booking_flow_type.dart';
export 'booking_flow_type.dart';

class BookingFlowConfig {
  final BookingFlowType flowType;

  const BookingFlowConfig({required this.flowType});

  // ─── Default (normal flow) ───
  static const BookingFlowConfig normal = BookingFlowConfig(
    flowType: BookingFlowType.service,
  );

  // ─── View Step Control ───
  bool get showLocationStep => true;
  bool get showDetailsStep => true;
  bool get showSummaryStep =>
      flowType == BookingFlowType.service ||
      flowType == BookingFlowType.package ||
      flowType == BookingFlowType.giftRedeem;

  // ─── Details View Sections ───
  bool get showCarSelection => true;
  bool get showAddOns =>
      flowType == BookingFlowType.service ||
      flowType == BookingFlowType.package;
  bool get showDateTime => true;

  // ─── Summary View Sections ───
  bool get showBikerNotes => flowType != BookingFlowType.reschedule;
  bool get showPaymentMethod => flowType == BookingFlowType.service;
  bool get showPaymentSummary =>
      flowType == BookingFlowType.service ||
      flowType == BookingFlowType.package;
  bool get showBookingSummaryCard => flowType != BookingFlowType.reschedule;

  // ─── Pricing in Details bottom sheet ───
  bool get showPricingInDetails => flowType == BookingFlowType.service;

  // ─── Validation Rules ───
  bool get requiresPaymentMethod => flowType == BookingFlowType.service;

  /// Whether this flow fetches a QUOTE — the `/quote` round trip the service
  /// booking is priced by.
  ///
  /// This is about WHICH CALL the flow makes, not about whether it has a price
  /// yet. It drives the initial fetch (booking_details_view,
  /// booking_summary_view's `initState`) and must stay the service flow alone:
  /// the package flow has no quote endpoint to call. For "has the price
  /// landed?" see [awaitsBackendPrice] — the two were the same predicate until
  /// the package flow started rendering a priced summary, and conflating them
  /// is what let it render SAR 0.00.
  bool get requiresQuote => flowType == BookingFlowType.service;

  /// Whether the amounts this flow displays come from a backend figure that
  /// has to LAND before any of them can be stated.
  ///
  /// Two flows price from the server, by two different calls:
  ///   * service — the `/quote` round trip ([requiresQuote]);
  ///   * package — the read-only wash-charge preview
  ///     (`BookingCubit.fetchWashChargePreview`), mapped into a synthetic
  ///     quote and published on the SAME `state.quote` field.
  /// Both are fired from a post-frame callback, so both have frames with no
  /// price at all, and on those frames every figure the summary renders is
  /// `quote?.<field> ?? 0` — a fabricated zero the customer cannot tell from a
  /// real one. So both wait. See `isPriceLocked` (booking_payable_total.dart).
  ///
  /// This is deliberately the same set as [showPaymentSummary], and
  /// package_summary_pending_price_test.dart pins the implication: a flow that
  /// renders the priced card without waiting for a price states zeros.
  bool get awaitsBackendPrice =>
      flowType == BookingFlowType.service ||
      flowType == BookingFlowType.package;

  // ─── Flow identity helpers ───
  bool get isReschedule => flowType == BookingFlowType.reschedule;
  bool get isNormal => flowType == BookingFlowType.service;
  bool get isPackage => flowType == BookingFlowType.package;
  bool get isGiftRedeem => flowType == BookingFlowType.giftRedeem;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingFlowConfig && flowType == other.flowType;

  @override
  int get hashCode => flowType.hashCode;
}
