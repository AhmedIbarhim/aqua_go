import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/biker_notes_selection.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/payment_method_selection.dart';
import '../widgets/promo_code_section.dart';
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
import 'package:aqua_go/features/booking/domain/promo_code_history.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';

class BookingSummaryView extends StatefulWidget {
  const BookingSummaryView({super.key});

  @override
  State<BookingSummaryView> createState() => _BookingSummaryViewState();
}

class _BookingSummaryViewState extends State<BookingSummaryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = context.read<BookingCubit>().state.flowConfig;
      if (config.requiresQuote) {
        // An offer picked on the offers surface ("Use this code") is applied to
        // the very first quote of this flow, then dropped so it cannot leak
        // into a later booking — takeHandoff is single-shot by design. The
        // OFFER id is what goes on the wire, never the code alongside it:
        // the server resolves the offer's own code, refuses a request carrying
        // both, and stamps the redemption with the offer that drove the sale.
        // Only quote-bearing flows reach this branch, so no flow-type guard is
        // needed.
        final handoff = PendingPromoCode.instance.takeHandoff();
        if (handoff != null) {
          _applyOfferFromHandoff(handoff.offerId);
        } else {
          // Coming BACK to this screen (pop → forward) must re-price with the
          // code that is already applied. Quoting bare here would drop the
          // customer's discount without a word, and the applied chip would
          // then be describing a quote that no longer carries it.
          _reprice();
        }
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
          switch (state.paymentPhase) {
            // The card was ALREADY charged (pay-before-create) and the server
            // refunded it before answering — a promo cap consumed between the
            // quote and the charge, a lost slot, a mismatched amount. The
            // server's reason says none of that, and a customer who has just
            // seen money leave their account has to be told it is coming back,
            // and when. Root CLAUDE.md §10: up to 7 days on a card refund.
            case PaymentPhase.refundPending:
              context.showWarningAlert(
                title: LocaleKeys.bookings_payment_refunded_title.tr(
                  context: context,
                ),
                message:
                    '${state.errorMessage ?? ''}\n\n'
                    '${LocaleKeys.bookings_payment_refunded_notice.tr(context: context)}',
                primaryButtonText: LocaleKeys.ok.tr(context: context),
              );
            // The card was charged and the create did NOT come back with an
            // answer this client can read as a refund — a dropped connection, a
            // timeout, a 5xx, or one of the create-path rejections that throws
            // after the verify without compensating. The booking may exist; the
            // charge may still be sitting there, and NO job reclaims it (see
            // `refund_evidence.dart`). So nothing is asserted about either: the
            // customer is told not to pay again, to check My Bookings, and to
            // reach support if money left with no booking behind it. The copy
            // used to promise the amount came back automatically, which on this
            // branch was not true.
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
      },
      builder: (context, bookingState) {
        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: GenericAppBar(
            title: LocaleKeys.bookings_booking_summary.tr(context: context),
            titleColor: Colors.white,
            hasBackground: true,
            backgroundImage: AppAssets.bookingHeaderImage,
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

    // What the applied code took off THIS order, straight from the locked
    // quote — the same figure the server subtracted before splitting VAT. It
    // drives both the amount saved on the promo chip and the original/discount
    // pair in the payment summary; 0 when no code is applied, which is what
    // suppresses them.
    final int promoDiscountMinor = bookingState.quote?.promoDiscountMinor ?? 0;

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
          if (config.showPaymentMethod) ...[
            PaymentMethodSelection(
              initialMethod: bookingState.paymentMethod,
              onPaymentMethodChanged: (method) {
                context.read<BookingCubit>().updatePaymentMethod(method);
              },
            ),
            const SizedBox(height: 24),
          ],
          if (config.flowType == BookingFlowType.service) ...[
            PromoCodeSection(
              appliedPromoCode: bookingState.appliedPromoCode,
              promoDiscountMinor: promoDiscountMinor,
              onApplyPromoCode: _applyPromoCode,
              onRemovePromoCode: _removePromoCode,
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
              additionalItems: selectedAddons,
              subtotal: subtotal,
              vat: vat,
              total: total,
              promoDiscount: promoDiscountMinor / 100,
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
            // The re-quote MUST carry the applied promo — reprice() re-sends it
            // from the state, because quoting bare here would re-price at the
            // undiscounted total, which both drops the discount and trips the
            // gross comparison below, making the booking uncompletable.
            final existing = cubit.state.quote;
            if (existing != null &&
                saudiNow().isAfter(existing.expiresAt)) {
              final previousGross = existing.breakdown?.gross;
              final refresh = await cubit.reprice();
              if (!context.mounted) return;
              final refreshed = refresh.quote;
              if (refreshed == null) return; // failed → cubit set the error
              if (refresh.droppedPromoReason != null) {
                // The code stopped being applicable between the quote and the
                // charge. It is gone and the total has moved, so the customer
                // reviews the new figure rather than tapping into the same
                // rejection again — which is what the old bare return left them
                // doing, forever, with no way of telling why.
                _sayPromoWasDropped(refresh.droppedPromoReason!);
                return;
              }
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

  /// Re-quote WITH the code. The locked quote is the source of truth for every
  /// displayed amount and for whether the code counts as applied — the cubit
  /// takes that from the code the server echoes back, so a rejected code leaves
  /// the chip un-applied and the cubit's failure state raises the error
  /// snackbar via BlocConsumer. The fresh quote's subtotal/vat/total are
  /// ALREADY net of the promo, so no further client-side arithmetic is done
  /// anywhere on this screen.
  ///
  /// A code the backend accepted is remembered on this device so the customer
  /// can pick it again next time (UCC16 UI/UX) — only accepted ones, so the
  /// suggestions never offer a code that has never worked.
  void _applyPromoCode(String code) async {
    final quote = await context.read<BookingCubit>().applyPromoCode(code);
    if (quote?.promoCode != null) {
      await PromoCodeHistory.remember(quote!.promoCode!);
    }
  }

  /// Re-quote WITHOUT the code; the quote that comes back carries no code, so
  /// the chip clears itself.
  void _removePromoCode() {
    context.read<BookingCubit>().removePromoCode();
  }

  /// Prices this order with the offer the customer tapped "Use this code" on.
  ///
  /// The offer was eligible when the feed rendered it and may not be by the
  /// time they arrive here — its cap can be consumed by a concurrent booking,
  /// the campaign can end, they can turn out ineligible (UCC23 A3,
  /// BR-OFR-11). When that happens the quote fails and there is NO quote at
  /// all, so the summary would render 0.00 and gate Confirm: a dead screen with
  /// the basket, address, vehicle and slot all still chosen and no way forward.
  /// UCC23 A3 requires the opposite — the discount is not granted and the total
  /// is unchanged — so the order is re-priced without the offer.
  ///
  /// The rejection itself is already on screen: the cubit's failure state
  /// raises it through the BlocConsumer above. Nothing is added on top of it,
  /// and deliberately so — an unknown, deactivated or out-of-window offer all
  /// return the same `promo-not-recognised` a mistyped code returns, and any
  /// message this screen invented would be claiming to know which.
  void _applyOfferFromHandoff(String offerId) async {
    final cubit = context.read<BookingCubit>();
    final quote = await cubit.applyOffer(offerId);
    if (!mounted || quote != null) return;
    await cubit.reprice();
  }

  /// Re-prices the current selection, keeping whatever promo is applied, and
  /// says so when the code had to be dropped to get a usable quote.
  void _reprice() async {
    final refresh = await context.read<BookingCubit>().reprice();
    if (!mounted) return;
    final reason = refresh.droppedPromoReason;
    if (reason != null) _sayPromoWasDropped(reason);
  }

  /// One message carrying both halves: the server's own reason (which states
  /// the customer's actual situation for an eligibility failure, and stays
  /// deliberately generic for one that would otherwise say whether a code
  /// exists), and the consequence — the code is off the order and the total
  /// has changed.
  void _sayPromoWasDropped(String reason) {
    context.showErrorSnackBar(
      '$reason\n${LocaleKeys.bookings_promo_code_removed.tr(context: context)}',
    );
  }
}
