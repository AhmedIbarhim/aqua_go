import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../data/models/customer_offer_model.dart';
import 'offer_banner.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});

  final CustomerOfferModel offer;

  static double heightFor(BuildContext context) => context.isTablet
      ? context.screenHeight * 0.22
      : context.screenHeight * 0.18;

  static double railWidthFor(BuildContext context) =>
      context.screenWidth * (context.isTablet ? 0.6 : 0.75);

  static double aspectRatioFor(BuildContext context) =>
      railWidthFor(context) / heightFor(context);

  static double heightForWidth(BuildContext context, double width) =>
      width / aspectRatioFor(context);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatioFor(context),
      child: OfferBanner(source: offer.banner(isAr: context.isAr)),
    );
  }
}
