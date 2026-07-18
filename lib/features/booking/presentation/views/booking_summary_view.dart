import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/biker_notes_selection.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/payment_method_selection.dart';
import '../widgets/gift_coupon_payment_widget.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_state.dart';
import 'moyasar_payment_view.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';
import 'package:aqua_go/core/config/payment/payment_sdk_config_service.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_bookings/presentation/views/my_booking_details_view.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_type.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/wallet/data/repos/wallet_repository.dart';
import 'package:aqua_go/features/wallet/data/models/loyalty_balance_model.dart';

class BookingSummaryView extends StatefulWidget {
  const BookingSummaryView({super.key});

  @override
  State<BookingSummaryView> createState() => _BookingSummaryViewState();
}

class _BookingSummaryViewState extends State<BookingSummaryView> {
  String? _appliedPromoCode;
  bool _isPointsToggled = false;
  LoyaltyBalanceModel? _loyaltyBalance;
  bool _isLoadingLoyalty = false;

  void _fetchLoyaltyBalance() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLoyalty = true;
    });
    final result = await locator<WalletRepository>().getWalletBalance();
    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoadingLoyalty = false;
          });
        },
        (balance) {
          setState(() {
            _loyaltyBalance = balance;
            _isLoadingLoyalty = false;
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
              _buildBottomActionSheet(context, bookingState),
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

    final quoteBreakdown = bookingState.quote?.breakdown;

    // PRICE LOCK: subtotal/vat/total come STRAIGHT from the backend quote
    // breakdown frozen at booking initiation — never from the live catalog.
    // When the quote is absent (still loading / fetch failed / expired) we
    // render zeros and the Confirm gate below blocks, rather than silently
    // falling back to live selectedService prices (which would mismatch the
    // eventual charge and break the locked-at-initiation guarantee).
    final double subtotal;
    final double vat;
    final double total;

    if (quoteBreakdown != null) {
      subtotal = quoteBreakdown.net;
      vat = quoteBreakdown.vat;
      total = quoteBreakdown.gross;
    } else {
      subtotal = 0.0;
      vat = 0.0;
      total = 0.0;
    }

    final double pointsValue =
        (_loyaltyBalance?.estimatedValueMinor ?? 0) / 100.0;
    final int estimatedValueMinor = _loyaltyBalance?.estimatedValueMinor ?? 0;
    final bool isInsufficient = _isPointsToggled && (estimatedValueMinor < 100);
    final double pointsDiscount = (_isPointsToggled && !isInsufficient)
        ? (total > pointsValue ? pointsValue : total)
        : 0.0;
    final double finalTotal = total - pointsDiscount;

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
            _buildPromoCodeSection(context, bookingState),
            const SizedBox(height: 24),
            _buildWalletPointsSection(context, bookingState, total),
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

  /// Service name shown on BOTH the Booking-Summary and Payment-Summary cards.
  /// For a multi-service package the customer PICKED a specific service, so show
  /// that chosen service (selectedPackageService); fall back to selectedService
  /// (which holds the PACKAGE name) only for a single-service bundle / the
  /// non-package service flow where selectedService is the real chosen service.
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

  /// True when a multi-service package REQUIRES a service pick that hasn't been
  /// made yet (or the picker failed to load) — Confirm is blocked in that state
  /// so a paid wash can never silently submit serviceId=null. Mirrors the
  /// booking_details_view `servicePicked` gate.
  bool _servicePicked(BookingState state) {
    final config = state.flowConfig;
    return !config.isPackage ||
        state.packageServices.length <= 1 ||
        state.selectedPackageService != null;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.regular16.copyWith(
        color: context.colors.textPrimary,
      ),
    );
  }

  /// Load-bearing safety net (spec Fix B): true when the package wash carries
  /// at least one PAYABLE add-on (optional add-ons always pay; included add-ons
  /// pay when their free allowance is exhausted) — mirrors
  /// booking_details_view._requiresPayment. ORed into the Confirm gate so a
  /// paid wash can NEVER bare-submit (→ backend 422), even if the charge
  /// preview is slow or failed.
  bool _hasPayableAddon(BookingState state) {
    if (!state.flowConfig.isPackage) return false;
    final addons = state.selectedService?.addons ?? [];
    final optionalIds = state.optionalAddonIds;
    final includedIds = state.includedAddonIds;
    for (final idx in state.selectedServiceIndices) {
      if (idx >= addons.length) continue;
      final addon = addons[idx];
      final id = addon.id ?? '';
      if (optionalIds.contains(id)) return true;
      if (includedIds.contains(id) && (addon.freeQty ?? 0) <= 0) return true;
    }
    return false;
  }

  double _calculateTotal(BookingState state) {
    // Total used only to gate "needs payment". Backend breakdown.gross already
    // includes every add-on — NO client-side add-on summing (that double-added
    // the add-on amounts on top of the gross total). No client math at all.
    // No live-catalog fallback: when the quote is absent we return 0.0 so the
    // covered-wash zero-total path stays enabled while the service flow is held
    // by the explicit quote-presence gate below.
    final quoteBreakdown = state.quote?.breakdown;
    if (quoteBreakdown != null) {
      return quoteBreakdown.gross;
    }
    return 0.0;
  }

  Widget _buildBottomActionSheet(
    BuildContext context,
    BookingState bookingState,
  ) {
    final config = bookingState.flowConfig;
    final total = _calculateTotal(bookingState);
    // hasPayableAddon is the safety net: a paid package wash needs payment even
    // before/without the charge preview (total may still be 0 if it failed).
    final hasPayableAddon = _hasPayableAddon(bookingState);
    final needsPayment =
        config.requiresPaymentMethod || total > 0 || hasPayableAddon;
    // PRICE LOCK gate: the service flow must have a locked quote before Confirm
    // so a failed/expired quote fetch can never charge a live (unlocked) amount.
    // The package flow does not require the service quote (it uses the wash
    // charge-preview + hasPayableAddon safety net), so it is not blocked here —
    // preserving the covered-wash zero-total path.
    final priceLocked = !config.requiresQuote || bookingState.quote != null;
    // Multi-service package gate: a required service pick must be made before
    // Confirm — never silently submit serviceId=null when the picker failed to
    // load or no service is selected.
    final servicePicked = _servicePicked(bookingState);
    final isEnabled =
        priceLocked &&
        servicePicked &&
        (needsPayment ? bookingState.paymentMethod != null : true);

    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_confirm_booking.tr(context: context),
        enabled: isEnabled,
        onPressed: () async {
          final cubit = context.read<BookingCubit>();
          // Hard block: a required package service must be chosen before any
          // submit/charge — never bare-submit serviceId=null.
          if (!_servicePicked(bookingState)) {
            context.showErrorSnackBar(
              LocaleKeys.bookings_service_selection_required.tr(
                context: context,
              ),
            );
            return;
          }
          // Covered / zero-total (NOT_REQUIRED): no on-device payment — the
          // backend creates the booking directly.
          if (!needsPayment) {
            cubit.submitBooking();
            return;
          }

          // Branch: package flow (subscription wash with payable add-ons) uses
          // wash-addon-payment-init; service flow uses booking-payment-init.
          final PaymentInitModel? init;
          if (config.isPackage) {
            // Pay-before-confirm (spec §4.4 / A2): addon-payment-init →
            // Moyasar SDK → schedule with moyasarPaymentId.
            init = await cubit.initiateWashAddonPayment();
          } else {
            // PRICE LOCK / 15-min TTL: if the locked quote has expired, re-quote
            // before charging. If the refreshed total differs, surface the
            // "prices refreshed" notice and abort so the customer reviews the
            // new amount rather than being silently charged a changed total.
            final existing = cubit.state.quote;
            if (existing != null &&
                DateTime.now().isAfter(existing.expiresAt)) {
              final previousGross = existing.breakdown?.gross;
              final refreshed = await cubit.fetchQuote();
              if (!context.mounted) return;
              if (refreshed == null) return; // fetch failed → cubit set error
              final newGross = refreshed.breakdown?.gross;
              if (previousGross != newGross) {
                context.showErrorSnackBar(
                  LocaleKeys.bookings_price_updated.tr(context: context),
                );
                return;
              }
            }
            if (!context.mounted) return;
            // Pay-before-create (spec §4.2): booking-payment-init →
            // Moyasar SDK → verify + create.
            init = await cubit.initiatePayment();
          }
          if (init == null || !context.mounted) return;
          await PaymentSdkConfigService.instance.ensureLoaded();
          if (!context.mounted) return;
          final PaymentInitModel resolvedInit = init;
          final result = await Navigator.of(context).push<MoyasarPaymentResult>(
            MaterialPageRoute(
              builder: (_) => MoyasarPaymentView(
                args: MoyasarPaymentArgs(
                  init: resolvedInit,
                  paymentMethod:
                      bookingState.paymentMethod ?? PaymentMethod.creditCard,
                  description: context.isAr ? 'أكوا جو' : 'Aqua Go',
                ),
              ),
            ),
          );
          if (!context.mounted) return;
          switch (result?.status) {
            case MoyasarPaymentStatus.paid:
              await cubit.completeBookingAfterPayment(result!.paymentId!);
              break;
            case MoyasarPaymentStatus.failed:
              cubit.onPaymentCancelled();
              if (context.mounted) {
                context.showErrorSnackBar(
                  context.isAr
                      ? 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.'
                      : 'Payment failed. Please try again.',
                );
              }
              break;
            case MoyasarPaymentStatus.cancelled:
            case null:
              cubit.onPaymentCancelled();
              break;
          }
        },
      ),
    );
  }

  Widget _buildPromoCodeSection(
    BuildContext context,
    BookingState bookingState,
  ) {
    final hasAppliedCode = _appliedPromoCode != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          LocaleKeys.bookings_promo_code_title.tr(context: context),
        ),
        const SizedBox(height: 16),
        if (!hasAppliedCode)
          GestureDetector(
            onTap: _showPromoCodeDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: context.colors.themeColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.warning, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.discount_outlined, color: context.colors.warning),
                  const SizedBox(width: 8),
                  Text(
                    LocaleKeys.bookings_apply_promo_code.tr(context: context),
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.warning,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.themeColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.borderSecondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.defaultSubtle,
                    border: Border.all(
                      color: context.colors.borderSecondary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: context.colors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${LocaleKeys.bookings_promo_code_title.tr(context: context)} $_appliedPromoCode',
                      style: AppTextStyles.medium14.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LocaleKeys.bookings_promo_code_applied.tr(
                        context: context,
                      ),
                      style: AppTextStyles.regular12.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                GestureDetector(
                  onTap: _removePromoCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.close, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          LocaleKeys.bookings_delete_promo_code.tr(
                            context: context,
                          ),
                          style: AppTextStyles.medium12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWalletPointsSection(
    BuildContext context,
    BookingState bookingState,
    double total,
  ) {
    final double pointsValue =
        (_loyaltyBalance?.estimatedValueMinor ?? 0) / 100.0;
    final int estimatedValueMinor = _loyaltyBalance?.estimatedValueMinor ?? 0;
    final bool isInsufficient = _isPointsToggled && (estimatedValueMinor < 100);

    final borderBorder = Border.all(
      color: _isPointsToggled
          ? (isInsufficient ? context.colors.error : context.colors.primary)
          : context.colors.borderSecondary.withValues(alpha: 0.3),
      width: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          LocaleKeys.bookings_wallet_points_title.tr(context: context),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.themeColor,
            borderRadius: BorderRadius.circular(12),
            border: borderBorder,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.bookings_pay_using_points.tr(context: context),
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.bookings_available_points_format.tr(
                      context: context,
                      args: [
                        _loyaltyBalance != null
                            ? NumberFormat(
                                '#,###',
                              ).format(_loyaltyBalance!.points)
                            : '0',
                        pointsValue.toStringAsFixed(2),
                      ],
                    ),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Switch.adaptive(
                value: _isPointsToggled,

                onChanged: (val) {
                  setState(() {
                    _isPointsToggled = val;
                  });
                },
                activeThumbColor: isInsufficient
                    ? context.colors.errorSecondary
                    : context.colors.primary,
                activeTrackColor:
                    (isInsufficient
                            ? context.colors.errorSecondary
                            : context.colors.primary)
                        .withValues(alpha: 0.3),
                inactiveThumbColor: context.colors.textTertiary,
                inactiveTrackColor: context.colors.defaultSubtle,
              ),
            ],
          ),
        ),
        if (isInsufficient) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              LocaleKeys.bookings_insufficient_points.tr(context: context),
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showPromoCodeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.colors.cardBackGround,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            LocaleKeys.bookings_apply_promo_code.tr(context: context),
            style: AppTextStyles.bold16.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: LocaleKeys.bookings_apply_code_hint.tr(
                    context: context,
                  ),
                  hintStyle: AppTextStyles.regular14.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  filled: true,
                  fillColor: context.colors.fields,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.colors.borderSecondary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                LocaleKeys.bookings_cancel.tr(context: context),
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final code = controller.text.trim();
                if (code.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  _applyPromoCode(code);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                LocaleKeys.bookings_apply.tr(context: context),
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.textTheme,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyPromoCode(String code) async {
    final quote = await context.read<BookingCubit>().fetchQuote(
      promoCode: code,
    );
    if (quote != null) {
      setState(() {
        _appliedPromoCode = code;
      });
    }
  }

  void _removePromoCode() async {
    final quote = await context.read<BookingCubit>().fetchQuote(
      promoCode: null,
    );
    if (quote != null) {
      setState(() {
        _appliedPromoCode = null;
      });
    }
  }
}
