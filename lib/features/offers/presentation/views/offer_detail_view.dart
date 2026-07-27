import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../layout/presentation/views/main_layout.dart';
import '../../data/models/customer_offer_model.dart';
import '../../domain/offer_countdown.dart';
import '../../domain/offer_revalidation.dart';
import '../../domain/offer_term_lines.dart';
import '../../domain/pending_promo_code.dart';
import '../controllers/offers_controller/offers_cubit.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_motion.dart';

class OfferDetailView extends StatelessWidget {
  const OfferDetailView({super.key, required this.offer});

  final CustomerOfferModel offer;

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final banner = offer.banner(isAr: isAr);
    // UCC23 step 6 — "terms (minimum order value, applicable services,
    // applicable zones, expiry)". The first three come off the linked promo
    // code or package; the expiry is the offer's own and closes the block.
    final lines = [
      ...offerTermLines(offer, isAr: isAr),
      offerExpiryLine(offer, isAr: isAr),
    ];

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
          OfferEntrance(index: 1, child: _Terms(lines: lines)),
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
    final endsIn = offerEndsInDays(offer.endsAt, saudiNow());

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
        // The end DATE now lives in the terms block below, where UCC23 step 6
        // enumerates it ("terms … and expiry"). What stays here is the urgency
        // chip, which is a UI/UX note rather than a term — so the date is
        // stated once, in the place the requirement puts it.
        if (endsIn != null) ...[
          const SizedBox(height: 12),
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

/// UCC23 step 7 — the single primary action, chosen by offer type, and
/// re-validated before it fires (A2).
class _PrimaryAction extends StatefulWidget {
  const _PrimaryAction({required this.offer});

  final CustomerOfferModel offer;

  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction> {
  /// Guards a second tap while the re-validation round-trip is open — two taps
  /// would fire two navigations off one offer.
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    // The app's primary action is `CustomButton` — 25 screens use it, and it
    // owns the full-width shape, the 12pt radius, the type weight and the
    // disabled treatment. A locally styled `ElevatedButton` here made the one
    // button on this screen the only one in the product that looks like that.
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: CustomButton(
        key: const ValueKey('offer-primary-action'),
        enabled: !_checking,
        onPressed: _onPressed,
        text: widget.offer.isPromoCode
            ? LocaleKeys.offers_use_code.tr(context: context)
            : LocaleKeys.offers_view_package.tr(context: context),
      ),
    );
  }

  Future<void> _onPressed() async {
    setState(() => _checking = true);
    // A2 — eligibility is evaluated at request time and never cached
    // (BR-OFR-11), so the copy this screen was handed is only as fresh as the
    // moment the list was fetched, which may be several minutes of reading ago.
    // Re-check it now, as the customer commits, not when they were browsing.
    final verdict =
        await context.read<OffersCubit>().revalidateOffer(widget.offer.id);
    if (!mounted) return;
    setState(() => _checking = false);

    switch (verdict) {
      // The cubit has already refreshed the list, so popping lands the customer
      // on a corrected one instead of on a list still showing what they lost.
      case OfferGone():
        _leaveUnavailable();
      // A fresh copy supersedes the one the list drew.
      case OfferStillLive(offer: final fresh):
        _act(fresh);
      // An unreachable server leaves the held copy in play: BR-OFR-11 puts the
      // real gate at apply time, and a flaky connection must not read to the
      // customer as an expiry.
      case OfferUncheckable():
        _act(widget.offer);
    }
  }

  /// The one blocked outcome UCC23 A2 allows: a brief toast, and back to the
  /// list. It states nothing about WHY — an offer withheld, an offer expired
  /// and an offer whose linked object is missing all read the same, which is
  /// what UCC23 requires ("never expose the reason an offer was withheld").
  void _leaveUnavailable() {
    context.showWarningSnackBar(
      LocaleKeys.offers_expired.tr(context: context),
    );
    Navigator.of(context).pop();
  }

  void _act(CustomerOfferModel offer) {
    if (offer.isPromoCode) {
      final code = offer.terms.promoCode;
      // `OfferTermsModel.fromJson` degrades a missing identity field to null
      // rather than throwing, so a partial `terms` payload is a supported input
      // — and one that leaves nothing to act on. Returning silently here is
      // what made the primary action a dead button: it ran its re-validation
      // round-trip and then did nothing at all.
      if (code == null || code.isEmpty) {
        _leaveUnavailable();
        return;
      }
      // UCC23 step 7 — the code is "pre-applied to the customer's next quote at
      // the booking review step (UCC16)". The OFFER id travels with it, not
      // just the code: the server binds the quote to the offer and writes it
      // onto the redemption row, which is the only way a sale can be attributed
      // back to the offer that produced it, since two live offers may carry the
      // same code (UCA22 A6).
      PendingPromoCode.instance.hold(offerId: offer.id, promoCode: code);
      context.showSuccessSnackBar(
        LocaleKeys.offers_code_saved.tr(context: context, args: [code]),
      );
      // "…the customer is taken into the booking flow." That flow opens at
      // Routes.bookingLocation and needs BOTH a service and an address, neither
      // of which an offer carries, so the landing point is service selection —
      // the home tab, which hosts the service picker that starts the flow —
      // with the offer held. Popping to whatever happened to be underneath is
      // not "taken into the booking flow": from the home rail that is the home
      // screen, but from a deeper entry it is an unrelated screen.
      context.pushNamedAndRemoveUntil(
        Routes.layout,
        arguments: MainLayoutArgs(initialIndex: 0),
      );
      return;
    }

    // UCC23 step 7, package half — "the customer is taken to the linked package
    // in the subscription catalogue (UC-C13)".
    final packageId = offer.terms.packageId;
    if (packageId == null || packageId.isEmpty) {
      _leaveUnavailable();
      return;
    }
    context.pushNamed(
      Routes.packageDetail,
      arguments: PackageDetailArgs(packageId: packageId),
    );
  }
}
