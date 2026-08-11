import '../../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../data/models/payment_init_model.dart';
import '../../../data/models/quote_model.dart';
import '../../../domain/configs/booking_flow_config.dart';

bool isPriceLocked({
  required BookingFlowConfig config,
  required QuoteModel? quote,
}) => !config.awaitsBackendPrice || quote != null;

enum PriceDisplay { pending, unavailable, ready }

PriceDisplay resolvePriceDisplay({
  required BookingFlowConfig config,
  required QuoteModel? quote,
  required bool priceLoadFailed,
}) {
  if (isPriceLocked(config: config, quote: quote)) return PriceDisplay.ready;
  return priceLoadFailed ? PriceDisplay.unavailable : PriceDisplay.pending;
}

double payableTotalMajor(Breakdown? breakdown) {
  if (breakdown == null) return 0.0;
  final minor =
      breakdown.amountDueMinor ??
      breakdown.totalMinor ??
      breakdown.grossMinor ??
      0;
  return minor / 100.0;
}

bool needsPaymentMethod({
  required double payableTotal,
  required bool hasPayableAddon,
}) => payableTotal > 0 || hasPayableAddon;

bool shouldOpenPaymentSdk(PaymentInitModel init) => init.amountMinor > 0;
