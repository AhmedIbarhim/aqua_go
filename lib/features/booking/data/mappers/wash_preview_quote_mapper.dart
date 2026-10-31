import '../../../../core/utils/saudi_wire_format.dart';
import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../my_bookings/data/models/booking_response_model/quote_line.dart';
import '../models/quote_model.dart';

/// A wash preview is read-only and has no server quote behind it, so this id
/// can never be sent to a quote endpoint as a real one.
const _washPreviewQuoteId = 'wash-preview';
const _defaultCurrency = 'SAR';
const _addonLineKind = 'ADDON';

typedef _ChargedAddon = ({String? refId, int grossMinor});

/// Shapes the schedule-preview response as a [QuoteModel] so the summary screen
/// renders a wash charge the same way it renders a service quote.
QuoteModel washPreviewQuoteFrom(Map<String, dynamic> data) {
  final breakdownJson = data['breakdown'] as Map<String, dynamic>?;
  final breakdown = breakdownJson != null
      ? Breakdown.fromJson(breakdownJson)
      : null;
  final chargeTotalMinor = _minorFrom(data['chargeTotalMinor']);

  final resolvedBreakdown =
      breakdown ??
      Breakdown(
        grossMinor: chargeTotalMinor,
        totalMinor: chargeTotalMinor,
        currency: _defaultCurrency,
      );
  if (resolvedBreakdown.totalMinor == null &&
      resolvedBreakdown.grossMinor == null) {
    resolvedBreakdown.totalMinor = chargeTotalMinor;
    resolvedBreakdown.grossMinor = chargeTotalMinor;
  }

  return QuoteModel(
    quoteId: _washPreviewQuoteId,
    currency: resolvedBreakdown.currency ?? _defaultCurrency,
    expiresAt: saudiNow(),
    breakdown: resolvedBreakdown,
    lines: _quoteLines(
      _chargedAddons(data['addonLines']),
      netTotal: breakdown?.netMinor,
    ),
  );
}

int _minorFrom(Object? raw) => int.tryParse('$raw') ?? 0;

List<_ChargedAddon> _chargedAddons(Object? addonLines) {
  if (addonLines is! List) return const [];
  return [
    for (final raw in addonLines.whereType<Map>())
      (
        refId: raw['addonId']?.toString(),
        grossMinor: _minorFrom(raw['chargedMinor']),
      ),
  ];
}

/// Splits [netTotal] across the paid addons by their share of the gross. The
/// last paid line takes the remainder, so rounding can never make the lines
/// disagree with the breakdown.
List<QuoteLine> _quoteLines(List<_ChargedAddon> addons, {int? netTotal}) {
  final lastPaidIndex = addons.lastIndexWhere((a) => a.grossMinor > 0);
  final totalGross = addons.fold(0, (sum, a) => sum + a.grossMinor);

  final lines = <QuoteLine>[];
  var netAssigned = 0;
  for (var i = 0; i < addons.length; i++) {
    final addon = addons[i];
    final int lineNet;
    if (addon.grossMinor <= 0) {
      lineNet = 0;
    } else if (netTotal == null || totalGross <= 0) {
      lineNet = addon.grossMinor;
    } else if (i == lastPaidIndex) {
      lineNet = netTotal - netAssigned;
    } else {
      lineNet = (addon.grossMinor * netTotal / totalGross).round();
    }
    if (addon.grossMinor > 0) netAssigned += lineNet;

    lines.add(
      QuoteLine(
        kind: _addonLineKind,
        refId: addon.refId,
        grossMinor: addon.grossMinor,
        netMinor: lineNet,
        vatMinor: addon.grossMinor - lineNet,
      ),
    );
  }
  return lines;
}
