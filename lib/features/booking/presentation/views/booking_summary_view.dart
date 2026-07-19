import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/quote_model.dart';
import '../widgets/booking_summary_widgets/booking_summary_card.dart';
import '../widgets/booking_summary_widgets/biker_notes_selection.dart';
import '../widgets/booking_summary_widgets/payment_summary_card.dart';
import '../widgets/booking_summary_widgets/payment_method_selection.dart';
import '../widgets/booking_summary_widgets/gift_coupon_payment_widget.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_state.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_bookings/presentation/views/my_booking_details_view.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_type.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/wallet/data/repos/wallet_repository.dart';
import 'package:aqua_go/features/wallet/data/models/loyalty_balance_model.dart';
import '../widgets/booking_summary_widgets/promo_code_section.dart';
import '../widgets/booking_summary_widgets/wallet_points_section.dart';
import '../widgets/booking_summary_widgets/booking_summary_bottom_action_sheet.dart';

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
      if (config.requiresQuote) {
        context.read<BookingCubit>().fetchQuote();
      } else if (config.isPackage) {
        // Subscription wash: fetch the read-only charge preview so the summary
        // shows the real payable total (e.g. 8 SAR add-on) instead of 0.00 and
        // the Confirm gate routes a paid wash through addon-payment-init.
        context.read<BookingCubit>().fetchWashChargePreview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.loading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

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
          context.showErrorSnackBar(state.errorMessage ?? '');
        }
      },
      builder: (context, bookingState) {
        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: GenericAppBar(
            title: LocaleKeys.bookings_booking_summary.tr(context: context),
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
                  child: _buildContent(context, bookingState, width),
                ),
              ),
              BookingSummaryBottomActionSheet(
                bookingState: bookingState,
                appliedPromoCode: _appliedPromoCode,
                getPointsToApply: () => _getPointsToApply(bookingState.quote),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingState bookingState,
    double width,
  ) {
    final config = bookingState.flowConfig;

    // Backend-rendered per-line breakdown (quote.lines) is the source of truth
    // for displayed amounts — no client-side VAT/base math. Each line carries a
    // NET (VAT-exclusive) netMinor; per Option B we render one row per line at
    // its NET amount so the line rows sum to the net subtotal (breakdown.net),
    // labelling the SERVICE line with the selected service name and each ADDON
    // by mapping its refId to the selected add-on's localized name.
    // Package wash: show the CHOSEN included service (selectedPackageService);
    // fall back to selectedService — which holds the PACKAGE name — only when
    // the bundle has a single service (no picker, so package name is the wash
    // name). Mirrors package_addon_payment_bottom_sheet. The service flow keeps
    // selectedService (the real chosen service) unchanged.
    final serviceName = _resolveServiceName(context, bookingState);
    final availableAddons = bookingState.selectedService?.addons ?? [];

    final lines = bookingState.quote?.lines ?? const [];

    // Service row (label + gross price) and add-on rows for the summary card.
    double servicePrice;
    final List<Map<String, dynamic>> selectedAddons = [];

    if (lines.isNotEmpty) {
      // Per-line rows render NET (line.net = netMinor/100); add-on rows come
      // from ADDON lines, each labelled by refId → catalog add-on name. Line
      // rows sum to the net subtotal (breakdown.net) — no client-side math.
      final serviceLine = lines.where((l) => l.isService).firstOrNull;
      servicePrice = serviceLine?.net ?? 0.0;
      for (final line in lines.where((l) => l.isAddon)) {
        final addon = availableAddons
            .where((a) => a.id == line.refId)
            .firstOrNull;
        final title = addon == null
            ? ''
            : (context.isAr
                  ? (addon.nameAr ?? addon.nameEn ?? '')
                  : (addon.nameEn ?? addon.nameAr ?? ''));
        selectedAddons.add({'name': title, 'price': line.net});
      }
    } else {
      // No quote/lines yet (still loading / fetch failed / expired). Do NOT
      // render a live catalog price — show 0.00 and let the Confirm gate block.
      // The covered-wash zero-total path also lands here and correctly shows 0.
      servicePrice = 0.0;
    }

    // PRICE LOCK: subtotal/vat/total come STRAIGHT from the backend quote
    // breakdown frozen at booking initiation — never from the live catalog.
    // When the quote is absent (still loading / fetch failed / expired) we
    // render zeros and the Confirm gate below blocks, rather than silently
    // falling back to live selectedService prices (which would mismatch the
    // eventual charge and break the locked-at-initiation guarantee).
    final double subtotal;
    final double vat;
    final double total;

    final quote = bookingState.quote;
    final int balanceValueMinor =
        quote?.currentBalanceValueMinor ??
        _loyaltyBalance?.estimatedValueMinor ??
        0;
    final bool isInsufficient = _isPointsToggled && (balanceValueMinor < 100);

    if (quote != null) {
      subtotal =
          (quote.breakdown?.netMinor ?? (quote.totalMinor - quote.vatMinor)) /
          100.0;
      vat = (quote.breakdown?.vatMinor ?? quote.vatMinor) / 100.0;
      total = quote.totalMinor / 100.0;
    } else {
      subtotal = 0.0;
      vat = 0.0;
      total = 0.0;
    }

    final double pointsDiscount = (_isPointsToggled && !isInsufficient)
        ? ((quote?.pointsDiscountMinor ?? 0) / 100.0)
        : 0.0;

    final double finalTotal = (_isPointsToggled && !isInsufficient)
        ? ((quote?.amountDueMinor ?? quote?.totalMinor ?? 0) / 100.0)
        : total;

    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(color: context.colors.themeColor),
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
              dateTime: bookingState.selectedDate != null
                  ? '${bookingState.selectedDate!.month}/${bookingState.selectedDate!.day}/${bookingState.selectedDate!.year} - ${bookingState.selectedTime ?? ""}'
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
          if (config.showPaymentMethod) ...[
            PaymentMethodSelection(
              initialMethod: bookingState.paymentMethod,
              onPaymentMethodChanged: (method) {
                context.read<BookingCubit>().updatePaymentMethod(method);
              },
            ),
            const SizedBox(height: 24),
          ],
          if (config.isGiftRedeem) ...[
            const GiftCouponPaymentWidget(),
            const SizedBox(height: 24),
          ],
          if (config.flowType == BookingFlowType.service) ...[
            PromoCodeSection(
              appliedPromoCode: _appliedPromoCode,
              onApplyPromoCode: _applyPromoCode,
              onRemovePromoCode: _removePromoCode,
            ),
            const SizedBox(height: 24),
            WalletPointsSection(
              bookingState: bookingState,
              loyaltyBalance: _loyaltyBalance,
              isPointsToggled: _isPointsToggled,
              onPointsToggled: (val) async {
                setState(() {
                  _isPointsToggled = val;
                });
                final currentQuote = context.read<BookingCubit>().state.quote;
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
                  await context.read<BookingCubit>().fetchQuote(
                    promoCode: _appliedPromoCode,
                    pointsToApply: pointsToApply,
                  );
                } else if (!val) {
                  await context.read<BookingCubit>().fetchQuote(
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
            PaymentSummaryCard(
              serviceName: serviceName,
              servicePrice: servicePrice,
              additionalItems: [
                ...selectedAddons,
                if (pointsDiscount > 0)
                  {
                    'name': context.isAr ? 'خصم النقاط' : 'Points Discount',
                    'price': -pointsDiscount,
                  },
              ],
              subtotal: subtotal,
              vat: vat,
              total: finalTotal,
            ),
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
    final currentQuote = context.read<BookingCubit>().state.quote;
    final pts = _getPointsToApply(currentQuote);
    final quote = await context.read<BookingCubit>().fetchQuote(
      promoCode: code,
      pointsToApply: pts,
    );
    if (quote != null) {
      setState(() {
        _appliedPromoCode = code;
      });
    }
  }

  void _removePromoCode() async {
    final currentQuote = context.read<BookingCubit>().state.quote;
    final pts = _getPointsToApply(currentQuote);
    final quote = await context.read<BookingCubit>().fetchQuote(
      promoCode: null,
      pointsToApply: pts,
    );
    if (quote != null) {
      setState(() {
        _appliedPromoCode = null;
      });
    }
  }
}
