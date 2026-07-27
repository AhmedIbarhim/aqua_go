import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';

/// An offer's banner artwork, drawn the one way the product draws a banner.
///
/// The treatment is `home_banners_carosal.dart`'s, control for control: the
/// same `cached_network_image`, the same `BoxFit.fill`, the same 12pt corners,
/// the same subtle plate while it loads and the same `demoBanner` asset when it
/// does not. Two image strips on one screen have to read as one thing.
///
/// It exists as ONE widget because both offer surfaces draw it: the card on the
/// home rail and the offers list, and the lead image on the detail view the
/// card opens. Those three drew the same asset three different ways once —
/// different control, different fit, different radius, different fallback — and
/// the customer met two of them one tap apart.
///
/// The artwork carries the offer's own words now (plan §1.5b: the card is image
/// only), so `fill` rather than `cover` is load-bearing: `cover` crops, and what
/// it crops is the title, the description and the BR-OFR-10 threshold.
class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key, required this.source});

  /// The banner URL for the reader's language. Null or blank when the offer
  /// carries no artwork for it.
  final String? source;

  @override
  Widget build(BuildContext context) {
    final url = source;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url == null || url.isEmpty
          // An offer with no artwork and an offer whose artwork fails to load
          // are the same outcome to the customer, so they land on the same
          // recognisable placeholder. A bare tinted rectangle would be a
          // tappable card carrying no information at all — the card has no text
          // left to fall back on.
          ? _fallback()
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) =>
                  Container(color: context.colors.defaultSubtle),
              errorWidget: (context, url, error) => _fallback(),
            ),
    );
  }

  Widget _fallback() => Image.asset(
    AppAssets.demoBanner,
    fit: BoxFit.fill,
    width: double.infinity,
    height: double.infinity,
  );
}
