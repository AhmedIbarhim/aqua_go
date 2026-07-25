import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/customer_offer_model.dart';
import '../../domain/offer_countdown.dart';

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
  const _Banner({required this.url, required this.height});

  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(height: height, color: context.colors.fields);
    final source = url;
    if (source == null || source.isEmpty) return placeholder;
    return Image.network(
      source,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.medium11.copyWith(color: context.colors.error),
      ),
    );
  }
}
