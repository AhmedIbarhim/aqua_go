import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/customer_offer_model.dart';
import '../../domain/offer_countdown.dart';
import '../../domain/offer_term_lines.dart';
import '../../domain/pending_promo_code.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_motion.dart';

class OfferDetailView extends StatelessWidget {
  const OfferDetailView({super.key, required this.offer});

  final CustomerOfferModel offer;

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final banner = offer.banner(isAr: isAr);
    final lines = offerTermLines(offer, isAr: isAr);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: GenericAppBar(title: LocaleKeys.offers_title.tr(context: context)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // The banner arrives on the hero flight from the offers list, so it
          // is deliberately left out of the staggered entrance below.
          if (banner != null && banner.isNotEmpty) _Banner(offer: offer, url: banner),
          OfferEntrance(index: 0, child: _Summary(offer: offer)),
          if (lines.isNotEmpty) OfferEntrance(index: 1, child: _Terms(lines: lines)),
          OfferEntrance(index: 2, child: _PrimaryAction(offer: offer)),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.offer, required this.url});

  final CustomerOfferModel offer;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: offerBannerHeroTag(offer.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          url,
          width: double.infinity,
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
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.offer});

  final CustomerOfferModel offer;

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final endsIn = offerEndsInDays(offer.endsAt, DateTime.now());
    final endsAtLabel =
        DateFormat.yMMMd(isAr ? 'ar' : 'en').format(offer.endsAt.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          offer.title(isAr: isAr),
          style: AppTextStyles.bold18.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          offer.description(isAr: isAr),
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          LocaleKeys.offers_valid_until.tr(context: context, args: [endsAtLabel]),
          style: AppTextStyles.regular12.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
        if (endsIn != null) ...[
          const SizedBox(height: 4),
          OfferPopIn(
            child: Text(
              endsIn == 1
                  ? LocaleKeys.offers_ends_in_one_day.tr(context: context)
                  : LocaleKeys.offers_ends_in_days.tr(
                      context: context,
                      args: ['$endsIn'],
                    ),
              style: AppTextStyles.medium12.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _Terms extends StatelessWidget {
  const _Terms({required this.lines});

  final List<OfferTermLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          LocaleKeys.offers_terms_title.tr(context: context),
          style: AppTextStyles.semiBold16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line.literal ?? line.localeKey!.tr(context: context, args: line.args),
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.offer});

  final CustomerOfferModel offer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: () => _onPressed(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            offer.isPromoCode
                ? LocaleKeys.offers_use_code.tr(context: context)
                : LocaleKeys.offers_view_package.tr(context: context),
            style: AppTextStyles.semiBold16,
          ),
        ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    if (offer.isPromoCode) {
      final code = offer.terms.promoCode;
      if (code == null || code.isEmpty) return;
      // Stash the code for the next quote, then drop the customer back at the
      // app root (home / service picker) so they can start the booking flow.
      // booking_summary_view consumes the stash in initState.
      PendingPromoCode.instance.set(code);
      context.showSuccessSnackBar(
        LocaleKeys.offers_code_saved.tr(context: context, args: [code]),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final packageId = offer.terms.packageId;
    if (packageId == null || packageId.isEmpty) return;
    context.pushNamed(
      Routes.packageDetail,
      arguments: PackageDetailArgs(packageId: packageId),
    );
  }
}
