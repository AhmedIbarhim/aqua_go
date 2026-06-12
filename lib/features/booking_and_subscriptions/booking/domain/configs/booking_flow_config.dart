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
      flowType == BookingFlowType.package;

  // ─── Details View Sections ───
  bool get showCarSelection => true;
  bool get showAddOns => flowType == BookingFlowType.service;
  bool get showDateTime => true;

  // ─── Summary View Sections ───
  bool get showBikerNotes => flowType != BookingFlowType.reschedule;
  bool get showPaymentMethod => flowType != BookingFlowType.reschedule;
  bool get showPaymentSummary => flowType != BookingFlowType.reschedule;
  bool get showBookingSummaryCard => flowType != BookingFlowType.reschedule;

  // ─── Pricing in Details bottom sheet ───
  bool get showPricingInDetails => flowType == BookingFlowType.service;

  // ─── Validation Rules ───
  bool get requiresPaymentMethod =>
      flowType == BookingFlowType.service ||
      flowType == BookingFlowType.package;
  bool get requiresQuote =>
      flowType == BookingFlowType.service ||
      flowType == BookingFlowType.package;

  // ─── Flow identity helpers ───
  bool get isReschedule => flowType == BookingFlowType.reschedule;
  bool get isNormal => flowType == BookingFlowType.service;
  bool get isPackage => flowType == BookingFlowType.package;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingFlowConfig && flowType == other.flowType;

  @override
  int get hashCode => flowType.hashCode;
}
