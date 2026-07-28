import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../utils/app_assets.dart';

/// The gap between a figure and the currency glyph that follows it.
const double kCurrencyGlyphGap = 4;

/// The Saudi riyal glyph, plus the small gap that separates it from the figure
/// it follows.
///
/// The currency is a SYMBOL everywhere a figure is shown — never the word "SAR"
/// and never "ريال". Two surfaces had drifted apart (the booking price
/// breakdown drew the glyph, the offer terms spelled the word out inside the
/// translation), which put two different currencies on screen in one app, so
/// the composition lives here rather than being re-invented at each site.
///
/// [size] and [color] are the caller's: the glyph is sized and tinted to sit
/// with the text it follows, exactly as the price breakdown does it —
/// `ColorFilter.mode(..., BlendMode.srcIn)` over the surrounding text colour.
///
/// The gap is [EdgeInsetsDirectional], so in Arabic — where the glyph is laid
/// out to the LEFT of the figure — it stays BETWEEN the two. Nothing here
/// branches on direction.
///
/// [struckThrough] draws the strike itself instead of leaning on
/// [TextDecoration.lineThrough]: a `TextDecoration` on the surrounding style
/// does not reach inside a `WidgetSpan`, so a superseded price would otherwise
/// be crossed out up to the currency and no further. The line runs across the
/// gap too, so it continues unbroken from the figure through the glyph.
class CurrencyGlyph extends StatelessWidget {
  const CurrencyGlyph({
    super.key,
    required this.color,
    this.size = 16,
    this.gapBefore = kCurrencyGlyphGap,
    this.struckThrough = false,
  });

  final Color color;
  final double size;
  final double gapBefore;
  final bool struckThrough;

  @override
  Widget build(BuildContext context) {
    final glyph = Padding(
      padding: EdgeInsetsDirectional.only(start: gapBefore),
      child: SvgPicture.asset(
        AppAssets.currency,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
    if (!struckThrough) return glyph;
    return Stack(
      alignment: Alignment.center,
      children: [
        glyph,
        Positioned.fill(child: Center(child: Container(height: 1, color: color))),
      ],
    );
  }
}

/// [amount] followed by the riyal glyph, as inline spans for a `Text.rich`.
///
/// Inline rather than a `Row` because the money often sits INSIDE a sentence —
/// "Minimum order 100.00", "20.00 off" — so the glyph has to land immediately
/// after the figure wherever the figure falls, not at the end of the line.
/// Callers splice these spans between whatever text sits either side.
///
/// [PlaceholderAlignment.middle] centres the glyph on the surrounding text
/// rather than hanging it off a baseline it does not share.
List<InlineSpan> currencyAmountSpans({
  required String amount,
  required Color color,
  double glyphSize = 16,
  bool struckThrough = false,
}) {
  return <InlineSpan>[
    TextSpan(text: amount),
    WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: CurrencyGlyph(
        color: color,
        size: glyphSize,
        struckThrough: struckThrough,
      ),
    ),
  ];
}
