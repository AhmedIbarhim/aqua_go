import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/customer_offer_model.dart';
import '../../domain/offer_countdown.dart';
import '../../domain/offer_term_lines.dart';
import 'offer_motion.dart';

/// Hero tag shared by the offers-list card banner and the offer detail banner,
/// so tapping a card flies its banner into the detail screen.
String offerBannerHeroTag(String offerId) => 'offer-banner-$offerId';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, this.atHome = true});

  final CustomerOfferModel offer;

  /// true  -> home "Best Offers" rail: fixed-width, compact, title only.
  /// false -> offers screen list: full-width, taller banner, with description.
  final bool atHome;

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final size = MediaQuery.sizeOf(context);
    final banner = offer.banner(isAr: isAr);
    final endsIn = offerEndsInDays(offer.endsAt, DateTime.now());
    final endsAtLabel =
        DateFormat.yMMMd(isAr ? 'ar' : 'en').format(offer.endsAt.toLocal());
    final minOrder = offerMinOrderLine(offer);

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSecondary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Banner(
            url: banner,
            height: atHome ? size.height * 0.10 : size.height * 0.18,
            // Only the offers-list card opens the detail screen, so only it
            // owns the flight; the home rail routes elsewhere and stays put.
            heroTag: atHome ? null : offerBannerHeroTag(offer.id),
          ),
          Padding(
            padding: EdgeInsets.all(atHome ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  offer.title(isAr: isAr),
                  maxLines: atHome ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (context.isTablet ? AppTextStyles.bold18 : AppTextStyles.bold16)
                          .copyWith(color: context.colors.textPrimary),
                ),
                if (!atHome) ...[
                  const SizedBox(height: 6),
                  Text(
                    offer.description(isAr: isAr),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                // BR-OFR-10 / AC-EXT-06 — the threshold is stated on the CARD,
                // not only in the detail view, because a minimum order is the
                // one term that survives eligibility and is refused later. It
                // rides on both the rail and the list card: the rail is a real
                // route into the booking flow.
                if (minOrder != null) ...[
                  SizedBox(height: atHome ? 6 : 10),
                  Text(
                    minOrder.localeKey!.tr(context: context, args: minOrder.args),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: atHome ? 6 : 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.offers_valid_until.tr(
                          context: context,
                          args: [endsAtLabel],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.regular12.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ),
                    if (endsIn != null) _EndsInChip(days: endsIn),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return atHome ? SizedBox(width: size.width * 0.72, child: card) : card;
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.url, required this.height, this.heroTag});

  final String? url;
  final double height;

  /// Non-null -> this banner is the source of a flight into the detail screen.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final source = url;
    // The tinted plate sits under the image for the whole life of the card, so
    // a slow, failed or absent banner leaves a finished-looking block rather
    // than a hole, and the image has something to fade onto.
    final plate = ColoredBox(color: context.colors.fields);
    if (source == null || source.isEmpty) {
      return SizedBox(height: height, width: double.infinity, child: plate);
    }

    final tag = heroTag;
    // Matches the corners the card's own clip already produces; carrying it on
    // the hero child keeps the return flight rounded too.
    Widget image = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
    if (tag != null) image = Hero(tag: tag, child: image);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [plate, image]),
    );
  }
}

class _EndsInChip extends StatelessWidget {
  const _EndsInChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final label = days == 1
        ? LocaleKeys.offers_ends_in_one_day.tr(context: context)
        : LocaleKeys.offers_ends_in_days.tr(context: context, args: ['$days']);
    return OfferPopIn(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.medium11.copyWith(color: context.colors.error),
        ),
      ),
    );
  }
}
