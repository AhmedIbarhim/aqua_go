import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_network_image.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/customer_offer_model.dart';
import '../../domain/offer_countdown.dart';
import '../../domain/offer_term_lines.dart';

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
    final endsIn = offerEndsInDays(offer.endsAt, saudiNow());
    // No `.toLocal()`: `endsAt` is in the Riyadh frame, so its fields already
    // are the date to print. Same rule as `offerExpiryLine`.
    final endsAtLabel =
        DateFormat.yMMMd(isAr ? 'ar' : 'en').format(offer.endsAt);
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
                    minOrder.key.tr(context: context, args: minOrder.args),
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

/// The offer banner, on the house remote-image control.
///
/// [CustomNetworkImage] is what every other card in the product uses for a
/// remote catalogue image (`service_card`, `package_card`), and it is
/// `cached_network_image` underneath — which is what satisfies UCC23's "banner
/// images are cached". A raw `Image.network` only ever sat in Flutter's
/// in-memory `ImageCache`, so nothing survived a restart or memory pressure.
class _Banner extends StatelessWidget {
  const _Banner({required this.url, required this.height});

  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final source = url;
    // The tinted plate sits under the image for the whole life of the card, so
    // a slow, failed or absent banner leaves a finished-looking block rather
    // than a hole, and the image has something to resolve onto.
    final plate = ColoredBox(color: context.colors.fields);
    if (source == null || source.isEmpty) {
      return SizedBox(height: height, width: double.infinity, child: plate);
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          plate,
          // Matches the corners the card's own clip already produces.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: CustomNetworkImage(source),
          ),
        ],
      ),
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
    // Static, like every other chip in the product (`ComplaintStatus`, the
    // booking-status chips). Nothing else here animates on entry.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      // The app's `errorLight` plate is always paired with
      // `darkAppColors.themeOpositeColor` — see
      // `ComplaintStatus.getBgColor`/`getTextColor`, the established chip
      // pattern. `context.colors.error` on it is dark red on bright red, at
      // 11pt, which is not readable and is not a pairing this product uses
      // anywhere else.
      child: Text(
        label,
        style: AppTextStyles.medium11.copyWith(
          color: darkAppColors.themeOpositeColor,
        ),
      ),
    );
  }
}
