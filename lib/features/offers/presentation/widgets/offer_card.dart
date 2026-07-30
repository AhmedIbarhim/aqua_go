import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../data/models/customer_offer_model.dart';
import 'offer_banner.dart';

/// An offer, rendered as its banner and nothing else.
///
/// The card carries no title, description, threshold, validity line or
/// countdown chip: the artwork leads, on the home rail and on the offers screen
/// alike. Every card still opens the offer's detail view, which is where the
/// UCC23 step 6 terms — the BR-OFR-10 minimum order among them — are stated.
///
/// The image treatment is the home banner strip's, deliberately, and it is
/// shared with the detail view's lead image through [OfferBanner].
class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});

  final CustomerOfferModel offer;

  /// The banner strip's height, so an offer sits at the same scale as a banner
  /// wherever it is drawn.
  static double heightFor(BuildContext context) => context.isTablet
      ? context.screenHeight * 0.22
      : context.screenHeight * 0.18;

  /// The banner strip's width for ONE slide — `home_banners_carosal.dart`'s
  /// viewport fraction, which the offers rail reuses verbatim.
  static double railWidthFor(BuildContext context) =>
      context.screenWidth * (context.isTablet ? 0.6 : 0.75);

  /// The proportions an offer's artwork is drawn at, everywhere.
  ///
  /// [heightFor] alone is not enough. The rail lays a card out at
  /// [railWidthFor]; the offers list lays the same card out full width, which
  /// on a 375pt phone is ~343pt against the rail's ~281pt. `BoxFit.fill` is a
  /// non-uniform stretch, not a crop, so pinning only the height would widen
  /// the identical asset by ~22% on one of the two surfaces — and the artwork
  /// is what carries the offer's title, description and threshold now
  /// (§1.5b). Pinning the RATIO instead lets each surface derive the dimension
  /// it does not already own, and the same image reads the same on both.
  ///
  /// Derived rather than a literal, so it cannot drift from the banner strip
  /// this scale is borrowed from.
  static double aspectRatioFor(BuildContext context) =>
      railWidthFor(context) / heightFor(context);

  /// The height a card occupies when it is laid out at [width] — what a
  /// full-width surface's skeleton has to stand at so the handoff from loading
  /// to loaded does not jump the page.
  static double heightForWidth(BuildContext context, double width) =>
      width / aspectRatioFor(context);

  @override
  Widget build(BuildContext context) {
    // AC-EXT-08 — the reader's language picks the banner; an offer may ship a
    // different image per language and the wrong one is the wrong words.
    return AspectRatio(
      aspectRatio: aspectRatioFor(context),
      child: OfferBanner(source: offer.banner(isAr: context.isAr)),
    );
  }
}
