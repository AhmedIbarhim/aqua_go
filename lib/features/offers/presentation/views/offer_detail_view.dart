import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/currency_amount.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
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

    final lines = [
      ...offerTermLines(offer, isAr: isAr),
      offerExpiryLine(offer, isAr: isAr),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: GenericAppBar(
        title: LocaleKeys.offers_title.tr(context: context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (banner != null && banner.isNotEmpty) _Banner(url: banner),
          _Summary(offer: offer),
          _Terms(lines: lines),
          _PrimaryAction(offer: offer),
        ],
      ),
    );
  }
}

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
    final countdown = offerCountdown(offer.endsAt, saudiNow());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          offer.title(isAr: isAr),
          style: AppTextStyles.bold18.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          offer.description(isAr: isAr),
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
        ),

        if (countdown != null) ...[
          const SizedBox(height: 12),
          Text(
            _countdownText(context, countdown),
            style: AppTextStyles.medium12.copyWith(color: context.colors.error),
          ),
        ],
      ],
    );
  }
}

String _countdownText(BuildContext context, OfferCountdown c) {
  switch (c.unit) {
    case OfferCountdownUnit.days:
      return c.value == 1
          ? LocaleKeys.offers_ends_in_one_day.tr(context: context)
          : LocaleKeys.offers_ends_in_days.tr(
              context: context,
              args: ['${c.value}'],
            );
    case OfferCountdownUnit.hours:
      return c.value == 1
          ? LocaleKeys.offers_ends_in_one_hour.tr(context: context)
          : LocaleKeys.offers_ends_in_hours.tr(
              context: context,
              args: ['${c.value}'],
            );
    case OfferCountdownUnit.minutes:
      return c.value == 1
          ? LocaleKeys.offers_ends_in_one_minute.tr(context: context)
          : LocaleKeys.offers_ends_in_minutes.tr(
              context: context,
              args: ['${c.value}'],
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

class _TermRow extends StatelessWidget {
  const _TermRow({required this.line});

  final OfferTermLine line;

  static const String _amountSlot = '￼';

  @override
  Widget build(BuildContext context) {
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
      case OfferTermKey(
        key: final key,
        args: final args,
        moneyArgIndex: final money,
      ):
        final plain = Text(
          key.tr(context: context, args: args),
          style: style,
        );

        if (money == null || money < 0 || money >= args.length) return plain;

        final slotted = [...args]..[money] = _amountSlot;
        final sentence = key.tr(context: context, args: slotted);
        final at = sentence.indexOf(_amountSlot);
        if (at < 0) return plain;

        final before = sentence.substring(0, at);
        final after = sentence.substring(at + _amountSlot.length);

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

          style: style,
        );
    }
  }
}

class _PrimaryAction extends StatefulWidget {
  const _PrimaryAction({required this.offer});

  final CustomerOfferModel offer;

  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
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

    final verdict = await context.read<OffersCubit>().revalidateOffer(
      widget.offer.id,
    );
    if (!mounted) return;

    try {
      switch (verdict) {
        case OfferGone():
          _leaveUnavailable();

        case OfferStillLive(offer: final fresh):
          await _act(fresh);

        case OfferUncheckable():
          await _act(widget.offer);
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _leaveUnavailable() {
    context.showWarningSnackBar(LocaleKeys.offers_expired.tr(context: context));
    Navigator.of(context).pop();
  }

  Future<void> _act(CustomerOfferModel offer) async {
    if (offer.isService) {
      if (FetchUserData.isGuest()) {
        FetchUserData.promptGuestToLogin(context);
        return;
      }
      final serviceId = offer.terms.serviceId;
      if (serviceId == null || serviceId.isEmpty) {
        _leaveUnavailable();
        return;
      }

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

      if (offer.hasTargetPrice) {
        PendingPromoCode.instance.hold(offerId: offer.id);
      }
      context.pushNamed(
        Routes.bookingLocation,
        arguments: BookingFlowStartArgs(
          service: service,

          offerListPriceMinor: offer.terms.serviceListPriceMinor,
          offerTargetPriceMinor: offer.terms.targetPriceMinor,

          offerTitleAr: offer.titleAr,
          offerTitleEn: offer.titleEn,
        ),
      );
      return;
    }

    if (offer.isPromoCode) {
      final code = offer.terms.promoCode;

      if (code == null || code.isEmpty) {
        _leaveUnavailable();
        return;
      }

      PendingPromoCode.instance.hold(offerId: offer.id);
      context.showSuccessSnackBar(
        LocaleKeys.offers_code_saved.tr(context: context, args: [code]),
      );

      context.pushNamedAndRemoveUntil(
        Routes.layout,
        arguments: MainLayoutArgs(initialIndex: 0),
      );
      return;
    }

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
