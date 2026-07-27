import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';
import '../../data/models/customer_offer_model.dart';

/// An offer, rendered as its banner and nothing else.
///
/// The card carries no title, description, threshold, validity line or
/// countdown chip: the artwork leads, on the home rail and on the offers screen
/// alike. Every card still opens the offer's detail view, which is where the
/// UCC23 step 6 terms — the BR-OFR-10 minimum order among them — are stated.
///
/// The image treatment is the home banner strip's, deliberately: same
/// `cached_network_image` control, same `BoxFit.fill` at full width, same 12pt
/// corners, same subtle plate while it loads and same asset fallback when it
/// fails. Two image strips on one screen have to read as one thing.
class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});

  final CustomerOfferModel offer;

  /// The banner strip's height, so an offer sits at the same scale as a banner
  /// wherever it is drawn.
  static double heightFor(BuildContext context) => context.isTablet
      ? context.screenHeight * 0.22
      : context.screenHeight * 0.18;

  @override
  Widget build(BuildContext context) {
    // AC-EXT-08 — the reader's language picks the banner; an offer may ship a
    // different image per language and the wrong one is the wrong words.
    final source = offer.banner(isAr: context.isAr);
    final plate = Container(color: context.colors.defaultSubtle);

    return SizedBox(
      height: heightFor(context),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: source == null || source.isEmpty
            ? plate
            : CachedNetworkImage(
                imageUrl: source,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) =>
                    Container(color: context.colors.defaultSubtle),
                errorWidget: (context, url, error) => Image.asset(
                  AppAssets.demoBanner,
                  fit: BoxFit.fill,
                ),
              ),
      ),
    );
  }
}
