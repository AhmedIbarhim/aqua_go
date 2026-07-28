import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/currency_amount.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../home/data/models/service_model.dart';
import '../../../home/data/repos/services_repository.dart';
import '../../../layout/presentation/views/main_layout.dart';
import '../../data/models/customer_offer_model.dart';
import '../../domain/offer_countdown.dart';
import '../../domain/offer_revalidation.dart';
import '../../domain/offer_term_lines.dart';
import '../../domain/pending_promo_code.dart';
import '../controllers/offers_controller/offers_cubit.dart';
import '../widgets/offer_banner.dart';
import '../widgets/offer_card.dart';

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
          // No artwork, no band. The card falls back to the placeholder asset
          // because it has nothing else to show and would otherwise be a blank
          // tap target; this screen states the title, the description and the
          // terms in text, so a stand-in image here would add nothing and take
          // the top of the screen to say it.
          if (banner != null && banner.isNotEmpty) _Banner(url: banner),
          _Summary(offer: offer),
          _Terms(lines: lines),
          _PrimaryAction(offer: offer),
        ],
      ),
    );
  }
}

/// The offer banner, drawn exactly as the card the customer just tapped drew
/// it — same [OfferBanner], same `cached_network_image` (UCC23's "banner images
/// are cached"), same `BoxFit.fill`, same corners, same fallback.
///
/// It used to reach for `CustomNetworkImage`, whose default fit is `cover`.
/// Since §1.5b the artwork is the only thing that states the offer's title,
/// description and BR-OFR-10 threshold, and `cover` CROPS — so the one surface
/// that has to state the threshold was the one cropping it away.
///
/// Ratio-bound rather than left to the image's own dimensions, so a slow,
/// failed or absent banner leaves a finished-looking block instead of
/// collapsing the top of the screen to nothing.
class _Banner extends StatelessWidget {
  const _Banner({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: OfferCard.aspectRatioFor(context),
      child: OfferBanner(source: url),
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
          Text(
            endsIn == 1
                ? LocaleKeys.offers_ends_in_one_day.tr(context: context)
                : LocaleKeys.offers_ends_in_days.tr(
                    context: context,
                    args: ['$endsIn'],
                  ),
            style: AppTextStyles.medium12.copyWith(color: context.colors.error),
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
            child: _TermRow(line: line),
          ),
        ),
      ],
    );
  }
}

/// One term row.
///
/// A row that states money is drawn as a `Text.rich` so the riyal glyph can be
/// spliced in immediately after the figure — the same currency the booking
/// price breakdown draws. Everything else is a plain `Text`.
class _TermRow extends StatelessWidget {
  const _TermRow({required this.line});

  final OfferTermLine line;

  /// Stands in for the money argument while the sentence is translated, so the
  /// glyph can be placed by SPLITTING the finished string instead of guessing
  /// where the figure ended up. U+FFFC (OBJECT REPLACEMENT CHARACTER) is the
  /// Unicode placeholder for exactly this — an inline object inside text — and
  /// cannot occur in a translation.
  static const String _amountSlot = '￼';

  @override
  Widget build(BuildContext context) {
    // A SERVICE offer's superseded list price is crossed out, the same
    // treatment the booking details screen gives it, so the two figures read as
    // one move rather than as two prices.
    final struckThrough = switch (line) {
      OfferTermKey(struckThrough: final struck) => struck,
      OfferTermLiteral() => false,
    };
    final color = context.colors.textSecondary;
    final style = AppTextStyles.regular14.copyWith(
      color: color,
      decoration: struckThrough ? TextDecoration.lineThrough : null,
    );

    switch (line) {
      case OfferTermLiteral(text: final text):
        return Text(text, style: style);
      case OfferTermKey(key: final key, args: final args, moneyArgIndex: final money):
        final plain = Text(key.tr(context: context, args: args), style: style);
        // Defensive on BOTH reads, and deliberately not a failure: an index the
        // args cannot answer, or a translation that dropped its `{}`, is a
        // shape this screen must still render. The fallback loses the glyph,
        // never the terms.
        if (money == null || money < 0 || money >= args.length) return plain;

        final slotted = [...args]..[money] = _amountSlot;
        final sentence = key.tr(context: context, args: slotted);
        final at = sentence.indexOf(_amountSlot);
        if (at < 0) return plain;

        final before = sentence.substring(0, at);
        final after = sentence.substring(at + _amountSlot.length);
        // Position-independent by construction: whatever the translator wrapped
        // around the figure stays around it, in either language, with no
        // direction branching anywhere.
        return Text.rich(
          TextSpan(
            children: [
              if (before.isNotEmpty) TextSpan(text: before),
              ...currencyAmountSpans(
                amount: args[money],
                color: color,
                struckThrough: struckThrough,
              ),
              if (after.isNotEmpty) TextSpan(text: after),
            ],
          ),
          // On the Text, not on the root span: `Text.style` is what the rest of
          // the app — and the tests — read a row's treatment off, and it is
          // inherited by the spans either way.
          style: style,
        );
    }
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
            : widget.offer.isService
            ? LocaleKeys.offers_book_now.tr(context: context)
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

    // The guard is HELD across `_act`, not released here. A SERVICE offer's
    // action fetches the wash catalogue before it navigates, and releasing at
    // this point re-enabled the button mid-fetch — a second tap then fired a
    // second navigation off one offer, which is precisely what `_checking`
    // exists to prevent.
    try {
      switch (verdict) {
        // The cubit has already refreshed the list, so popping lands the
        // customer on a corrected one instead of on a list still showing what
        // they lost.
        case OfferGone():
          _leaveUnavailable();
        // A fresh copy supersedes the one the list drew.
        case OfferStillLive(offer: final fresh):
          await _act(fresh);
        // An unreachable server leaves the held copy in play: BR-OFR-11 puts
        // the real gate at apply time, and a flaky connection must not read to
        // the customer as an expiry.
        case OfferUncheckable():
          await _act(widget.offer);
      }
    } finally {
      // `_leaveUnavailable` pops this screen, so the State may already be gone.
      if (mounted) setState(() => _checking = false);
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

  Future<void> _act(CustomerOfferModel offer) async {
    // UCC23 step 7, service half — a SERVICE offer deep-links straight into
    // the booking flow at the wash it names. Checked BEFORE the promo branch:
    // a SERVICE offer with a deal also carries a code, but that code is the
    // server's to resolve, not the client's to apply.
    if (offer.isService) {
      final serviceId = offer.terms.serviceId;
      if (serviceId == null || serviceId.isEmpty) {
        _leaveUnavailable();
        return;
      }
      // There is no by-id service read: `ServicesRepository` exposes only
      // `fetchServices()`. It is a `registerLazySingleton`, so the locator is
      // the right handle — `ServicesCubit` is a `registerFactory` and would
      // hand back a fresh, EMPTY instance.
      final services = await locator<ServicesRepository>().fetchServices();
      final service = services.fold<ServiceModel?>(
        (_) => null,
        (list) => list.where((s) => s.id == serviceId).firstOrNull,
      );
      if (!mounted) return;
      if (service == null) {
        _leaveUnavailable();
        return;
      }
      // Hold the OFFER, not the code: the server resolves the managed code
      // itself, and a client-supplied code carries no evidence of which offer
      // produced the sale. A shortcut offer (no deal) holds nothing.
      if (offer.hasTargetPrice) {
        PendingPromoCode.instance.hold(offerId: offer.id);
      }
      context.pushNamed(
        Routes.bookingLocation,
        arguments: BookingFlowStartArgs(
          service: service,
          // The two figures the card promised, carried into the flow so the
          // details screen shows the price the customer tapped rather than the
          // list price (owner decision D-4). Server figures, passed through.
          offerListPriceMinor: offer.terms.serviceListPriceMinor,
          offerTargetPriceMinor: offer.terms.targetPriceMinor,
          // The offer's own name, both languages, so the summary can offer it
          // back BY NAME after a typed code has displaced it. This screen is
          // the only place the offer object is in scope.
          offerTitleAr: offer.titleAr,
          offerTitleEn: offer.titleEn,
        ),
      );
      return;
    }

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
      PendingPromoCode.instance.hold(offerId: offer.id);
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
