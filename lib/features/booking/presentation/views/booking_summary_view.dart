import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/pricing/gross_price_breakdown.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/quote_model.dart';
import '../widgets/booking_summary_widgets/booking_summary_card.dart';
import '../widgets/booking_summary_widgets/biker_notes_selection.dart';
import '../widgets/booking_summary_widgets/payment_summary_card.dart';
import '../widgets/booking_summary_widgets/payment_method_selection.dart';
import '../widgets/booking_summary_widgets/gift_coupon_payment_widget.dart';
import '../widgets/booking_summary_widgets/promo_code_section.dart';
import '../widgets/booking_summary_widgets/wallet_points_section.dart';
import '../widgets/booking_summary_widgets/booking_summary_bottom_action_sheet.dart';
import '../widgets/booking_summary_widgets/booking_payable_total.dart';
import '../widgets/booking_summary_widgets/price_unavailable_card.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_payment_cubit.dart';
import '../controllers/booking_payment_state.dart';
import '../controllers/booking_pricing_cubit.dart';
import '../controllers/booking_pricing_state.dart';
import '../controllers/booking_state.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_bookings/presentation/views/my_booking_details_view.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_type.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/wallet/data/repos/wallet_repository.dart';
import 'package:aqua_go/features/wallet/data/models/loyalty_balance_model.dart';
import 'package:aqua_go/features/booking/domain/promo_code_history.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';

class BookingSummaryView extends StatefulWidget {
  const BookingSummaryView({super.key});

  @override
  State<BookingSummaryView> createState() => _BookingSummaryViewState();
}

class _BookingSummaryViewState extends State<BookingSummaryView> {
  String? _appliedPromoCode;
  bool _isPointsToggled = false;
  LoyaltyBalanceModel? _loyaltyBalance;
  bool isLoadingLoyalty = false;

  void _fetchLoyaltyBalance() async {
    if (!mounted) return;
    setState(() {
      isLoadingLoyalty = true;
    });
    final result = await locator<WalletRepository>().getWalletBalance();
    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            isLoadingLoyalty = false;
          });
        },
        (balance) {
          setState(() {
            _loyaltyBalance = balance;
            isLoadingLoyalty = false;
          });
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = context.read<BookingCubit>().state.flowConfig;
      if (config.flowType == BookingFlowType.service) {
        _fetchLoyaltyBalance();
      }
      _fetchPrice();
    });
  }

  void _fetchPrice() {
    final config = context.read<BookingCubit>().state.flowConfig;
    if (config.requiresQuote) {
      final handoff = PendingPromoCode.instance.takeHandoff();
      if (handoff != null) {
        _applyOfferFromHandoff(handoff.offerId);
      } else {
        _reprice();
      }
    } else if (config.isPackage) {
      context.read<BookingPricingCubit>().fetchWashChargePreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return MultiBlocListener(
      listeners: [
        BlocListener<BookingPricingCubit, BookingPricingState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == BookingStatus.failure) {
              context.showErrorSnackBar(state.errorMessage ?? '');
            }
          },
        ),
        BlocListener<BookingPaymentCubit, BookingPaymentState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: _onPaymentStatusChanged,
        ),
      ],
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, bookingState) {
          return BlocBuilder<BookingPricingCubit, BookingPricingState>(
            builder: (context, pricingState) {
              return Scaffold(
                backgroundColor: context.colors.screenBG,
                appBar: GenericAppBar(
                  title: LocaleKeys.bookings_booking_summary.tr(
                    context: context,
                  ),
                  titleColor: context.colors.textPrimary,
                  hasBackground: true,
                  backgroundImage: context.isDarkTheme
                      ? AppAssets.bookingHeaderImageDark
                      : AppAssets.bookingHeaderImageLight,
                  centerTitle: true,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildContent(
                          context,
                          bookingState,
                          pricingState,
                          width,
                        ),
                      ),
                    ),
                    BookingSummaryBottomActionSheet(
                      bookingState: bookingState,
                      pricingState: pricingState,
                      appliedPromoCode: _appliedPromoCode,
                      getPointsToApply: () =>
                          _getPointsToApply(pricingState.quote),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onPaymentStatusChanged(
    BuildContext context,
    BookingPaymentState state,
  ) {
    if (state.status == BookingStatus.success) {
      context.showSuccessSnackBar(
        LocaleKeys.snackbar_booking_created.tr(context: context),
      );
      context
          .showSuccessAlert(
            title: LocaleKeys.bookings_booking_success_message.tr(
              context: context,
            ),
          )
          .then((_) {
            if (!context.mounted) return;
            Navigator.popUntil(context, (route) => route.isFirst);
            if (state.createdBooking != null) {
              Navigator.pushNamed(
                context,
                Routes.myBookingDetails,
                arguments: MyBookingDetailsArgs(
                  booking: BookingSummaryModel.fromDetails(
                    state.createdBooking!,
                  ),
                  isFromBookingFlow: true,
                ),
              );
            }
          });
    } else if (state.status == BookingStatus.failure) {
      switch (state.paymentPhase) {
        case PaymentPhase.createUnconfirmed:
          context.showWarningAlert(
            title: LocaleKeys.bookings_payment_unconfirmed_title.tr(
              context: context,
            ),
            message:
                '${state.errorMessage ?? ''}\n\n'
                '${LocaleKeys.bookings_payment_unconfirmed_notice.tr(context: context)}',
            primaryButtonText: LocaleKeys.ok.tr(context: context),
          );
        default:
          context.showErrorSnackBar(state.errorMessage ?? '');
      }
    }
  }

  Widget _buildContent(
    BuildContext context,
    BookingState bookingState,
    BookingPricingState pricingState,
    double width,
  ) {
    final config = bookingState.flowConfig;
    final quote = pricingState.quote;

    final priceLocked = isPriceLocked(config: config, quote: quote);

    final priceDisplay = resolvePriceDisplay(
      config: config,
      quote: quote,
      priceLoadFailed: pricingState.priceLoadFailed,
    );

    final serviceName = _resolveServiceName(context, bookingState);
    final availableAddons = bookingState.selectedService?.addons ?? [];

    final lines = quote?.lines ?? const [];

    final List<GrossLine> itemLines = [];

    if (lines.isNotEmpty) {
      final service = lines.where((l) => l.isService).firstOrNull;
      if (service != null) {
        itemLines.add(
          GrossLine(label: serviceName, grossMinor: service.grossMinor),
        );
      }
      for (final line in lines.where((l) => l.isAddon)) {
        final addon = availableAddons
            .where((a) => a.id == line.refId)
            .firstOrNull;
        final title = addon == null
            ? ''
            : (context.isAr
                  ? (addon.nameAr ?? addon.nameEn ?? '')
                  : (addon.nameEn ?? addon.nameAr ?? ''));
        itemLines.add(GrossLine(label: title, grossMinor: line.grossMinor));
      }
    }

    final int promoDiscountMinor = quote?.promoDiscountMinor ?? 0;

    final quoteTotalMinor = quote?.totalMinor ?? 0;
    final summary = GrossPriceBreakdown.fromBookingLines(
      itemLines: itemLines,
      discountMinor: promoDiscountMinor,
      promoCode: quote?.promoCode,
      totalMinor: quoteTotalMinor,
      vatMinor: quote?.vatMinor ?? 0,
      pointsDiscountMinor: quote?.pointsDiscountMinor ?? 0,
    );

    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(color: context.colors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.showBookingSummaryCard) ...[
            _buildSectionTitle(
              LocaleKeys.bookings_booking_summary.tr(context: context),
            ),
            const SizedBox(height: 16),
            BookingSummaryCard(
              serviceName: serviceName,
              carName:
                  '${bookingState.selectedCar!.carMake!.vehicleMakeName.localizedName} ${bookingState.selectedCar!.carModel!.vehicleModelName.localizedName}',
              location:
                  bookingState.selectedAddress?.label ??
                  bookingState.selectedAddress?.details ??
                  '',
              dateTime: bookingState.selectedSlotStart != null
                  ? formatDateAndTime(bookingState.selectedSlotStart!)
                  : '',
            ),
            const SizedBox(height: 24),
          ],
          if (config.showBikerNotes) ...[
            _buildSectionTitle(
              LocaleKeys.bookings_notes_for_biker.tr(context: context),
            ),
            const SizedBox(height: 16),
            BikerNotesSelection(
              initialNotes: bookingState.bikerNotes,
              initialSpecialNoteText: bookingState.specialNoteText,
              onNotesChanged: (notes) {
                context.read<BookingCubit>().updateNotes(notes);
              },
              onSpecialNoteTextChanged: (text) {
                context.read<BookingCubit>().updateSpecialNoteText(text);
              },
            ),
            const SizedBox(height: 24),
          ],

          if (config.showPaymentMethod && priceLocked) ...[
            if (needsPaymentMethod(
              payableTotal: payableTotalMajor(quote?.breakdown),
              hasPayableAddon: false,
            ))
              PaymentMethodSelection(
                initialMethod: bookingState.paymentMethod,
                onPaymentMethodChanged: (method) {
                  context.read<BookingCubit>().updatePaymentMethod(method);
                },
              )
            else
              Text(
                LocaleKeys.bookings_no_payment_required.tr(context: context),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 24),
          ],
          if (config.isGiftRedeem) ...[
            const GiftCouponPaymentWidget(),
            const SizedBox(height: 24),
          ],
          if (config.flowType == BookingFlowType.service) ...[
            PromoCodeSection(
              appliedPromoCode: pricingState.appliedPromoCode,
              promoDiscountMinor: promoDiscountMinor,
              onApplyPromoCode: _applyPromoCode,
              onRemovePromoCode: _removePromoCode,
              canReapplyOffer:
                  pricingState.rememberedOfferId != null &&
                  pricingState.appliedOfferId == null &&
                  pricingState.appliedPromoCode == null,
              reapplyOfferTitle: context.isAr
                  ? pricingState.offerTitleAr
                  : pricingState.offerTitleEn,
              onReapplyOffer: _reapplyOffer,
            ),
            const SizedBox(height: 24),
            WalletPointsSection(
              quote: quote,
              loyaltyBalance: _loyaltyBalance,
              isPointsToggled: _isPointsToggled,
              onPointsToggled: (val) async {
                setState(() {
                  _isPointsToggled = val;
                });
                final pricing = context.read<BookingPricingCubit>();
                final currentQuote = pricing.state.quote;
                final balValMinor =
                    currentQuote?.currentBalanceValueMinor ??
                    _loyaltyBalance?.estimatedValueMinor ??
                    0;
                if (val && balValMinor >= 100) {
                  final maxPoints = currentQuote?.maxApplicablePoints ?? 0;
                  final balance =
                      currentQuote?.currentBalancePoints ??
                      _loyaltyBalance?.points ??
                      0;
                  final pointsToApply = balance < maxPoints
                      ? balance
                      : maxPoints;
                  await pricing.fetchQuote(
                    promoCode: _appliedPromoCode,
                    pointsToApply: pointsToApply,
                  );
                } else if (!val) {
                  await pricing.fetchQuote(
                    promoCode: _appliedPromoCode,
                    pointsToApply: 0,
                  );
                }
              },
            ),
            const SizedBox(height: 24),
          ],
          if (config.showPaymentSummary) ...[
            _buildSectionTitle(
              LocaleKeys.bookings_payment_summary.tr(context: context),
            ),
            const SizedBox(height: 16),

            switch (priceDisplay) {
              PriceDisplay.ready => PaymentSummaryCard(breakdown: summary),
              PriceDisplay.pending => ShimmerHelper.paymentSummary(),
              PriceDisplay.unavailable => PriceUnavailableCard(
                onRetry: _fetchPrice,
              ),
            },
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _resolveServiceName(BuildContext context, BookingState state) {
    final chosen = state.flowConfig.isPackage
        ? (state.selectedPackageService ??
              (state.packageServices.length <= 1
                  ? state.selectedService
                  : null))
        : state.selectedService;
    return context.isAr
        ? (chosen?.rawName?.nameAr ?? '')
        : (chosen?.rawName?.nameEn ?? '');
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.regular16.copyWith(
        color: context.colors.textPrimary,
      ),
    );
  }

  int? _getPointsToApply(QuoteModel? quote) {
    if (!_isPointsToggled) return 0;
    final balanceValueMinor =
        quote?.currentBalanceValueMinor ??
        _loyaltyBalance?.estimatedValueMinor ??
        0;
    if (balanceValueMinor < 100) return 0;
    final maxPoints = quote?.maxApplicablePoints ?? 0;
    final balance = quote?.currentBalancePoints ?? _loyaltyBalance?.points ?? 0;
    return balance < maxPoints ? balance : maxPoints;
  }

  void _applyPromoCode(String code) async {
    setState(() {
      _isPointsToggled = false;
    });
    final quote = await context.read<BookingPricingCubit>().applyPromoCode(
      code,
    );
    if (quote?.promoCode != null) {
      await PromoCodeHistory.remember(quote!.promoCode!);
    }
  }

  void _removePromoCode() {
    context.read<BookingPricingCubit>().removePromoCode();
  }

  void _reapplyOffer() {
    setState(() {
      _isPointsToggled = false;
    });
    final cubit = context.read<BookingPricingCubit>();
    final offerId = cubit.state.rememberedOfferId;
    if (offerId == null) return;
    cubit.applyOffer(offerId);
  }

  void _applyOfferFromHandoff(String offerId) async {
    final cubit = context.read<BookingPricingCubit>();
    final application = await cubit.applyOffer(offerId);
    if (application.applied) return;
    if (!application.settled) {
      PendingPromoCode.instance.hold(offerId: offerId);
    }
    if (!mounted) return;

    await cubit.reprice();
  }

  void _reprice() async {
    final refresh = await context.read<BookingPricingCubit>().reprice();
    if (!mounted) return;
    final reason = refresh.droppedPromoReason;
    if (reason != null) _sayPromoWasDropped(reason);
  }

  void _sayPromoWasDropped(String reason) {
    context.showErrorSnackBar(
      '$reason\n${LocaleKeys.bookings_promo_code_removed.tr(context: context)}',
    );
  }
}
