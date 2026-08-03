import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/pricing/gross_price_breakdown.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/booking_summary_widgets/booking_summary_card.dart';
import '../widgets/booking_summary_widgets/biker_notes_selection.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/booking_summary_widgets/payment_method_selection.dart';
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
            // The card was charged (pay-before-create) and no booking came back.
            // Refunds were removed platform-wide on 2026-07-29, so nothing
            // returns the money automatically — the former refundPending arm,
            // which promised the charge was reversed within ~7 days, was folded
            // in here rather than left telling customers something untrue. The
            // booking may exist; the charge may still be sitting there, and NO
            // job reclaims it. So nothing is asserted about either: the customer
            // is told not to pay again, to check My Bookings, and to reach
            // support if money left with no booking behind it.
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
            backgroundImage: (context.isDarkTheme
              ? AppAssets.bookingHeaderImageDark
              : AppAssets.bookingHeaderImageLight),
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
    // for displayed amounts — no client-side VAT math. Each line's GROSS
    // (VAT-inclusive) grossMinor is what the customer sees, so the rows carry
    // the catalogue prices they recognise and sum to the pre-discount subtotal.
    // The SERVICE line is labelled with the selected service name and each
    // ADDON by mapping its refId to the selected add-on's localized name.
    // Package wash: show the CHOSEN included service (selectedPackageService);
    // fall back to selectedService — which holds the PACKAGE name — only when
    // the bundle has a single service (no picker, so package name is the wash
    // name). Mirrors package_addon_payment_bottom_sheet. The service flow keeps
    // selectedService (the real chosen service) unchanged.
    final serviceName = _resolveServiceName(context, bookingState);
    final availableAddons = bookingState.selectedService?.addons ?? [];

    final lines = bookingState.quote?.lines ?? const [];
    final quoteBreakdown = bookingState.quote?.breakdown;

    // SERVICE + ADDON only. The DISCOUNT row is deliberately NOT an item line:
    // it is `discountMinor`, rendered once below the subtotal. Modelling it as
    // a `GrossLine` would let it be summed into the very subtotal it is meant
    // to be subtracted from — the trap `QuoteLine`'s own javadoc warns about,
    // and the reason this filter is explicit rather than incidental.
    final List<GrossLine> itemLines = [];

    if (lines.isNotEmpty) {
      final service = lines.where((l) => l.isService).firstOrNull;
      if (service != null) {
        itemLines.add(GrossLine(
          label: serviceName,
          grossMinor: service.grossMinor,
        ));
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
    // When lines are absent (still loading / fetch failed / expired, or the
    // covered-wash zero-total path) we deliberately render NO line rows and no
    // live catalog price — the totals below come out as 0.00 and the Confirm
    // gate blocks.

    // PRICE LOCK: every figure comes STRAIGHT from the backend quote frozen at
    // booking initiation — never from the live catalog. When the quote is
    // absent we render zeros and the Confirm gate below blocks, rather than
    // silently falling back to live selectedService prices (which would
    // mismatch the eventual charge and break the locked-at-initiation
    // guarantee).
    //
    // `promoDiscountMinor` is what the applied code took off THIS order — the
    // same figure the server subtracted from the VAT-inclusive gross. It drives
    // the amount saved on the promo chip and the subtotal/discount pair in the
    // payment summary; 0 when no code is applied, which is what suppresses
    // both rows.
    final int promoDiscountMinor = bookingState.quote?.promoDiscountMinor ?? 0;
    // The quote's own DISCOUNT row, when it has one. Its gross is NEGATIVE, so
    // the display value is its magnitude. `promoDiscountMinor` is the fallback
    // for a quote whose lines the backend omitted — the same figure, stated in
    // a different place.
    final discountLine = lines.where((l) => l.isDiscount).firstOrNull;
    final summary = GrossPriceBreakdown.fromBookingLines(
      itemLines: itemLines,
      discountMinor: discountLine != null
          ? -discountLine.grossMinor
          : promoDiscountMinor,
      promoCode: bookingState.quote?.promoCode,
      totalMinor: quoteBreakdown?.grossMinor ?? 0,
      vatMinor: quoteBreakdown?.vatMinor ?? 0,
    );

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
              // An offer this flow already took, and that nothing is pricing
              // the order with right now. Both halves matter: an offer still
              // applied has nothing to restore, and a code the customer typed
              // is their own more recent choice — the card would be inviting
              // them to overwrite it with no way of knowing they had.
              canReapplyOffer:
                  bookingState.rememberedOfferId != null &&
                  bookingState.appliedOfferId == null &&
                  bookingState.appliedPromoCode == null,
              reapplyOfferTitle: context.isAr
                  ? bookingState.offerTitleAr
                  : bookingState.offerTitleEn,
              onReapplyOffer: _reapplyOffer,
            ),
            const SizedBox(height: 24),
          ],
          if (config.showPaymentSummary) ...[
            _buildSectionTitle(
              LocaleKeys.bookings_payment_summary.tr(context: context),
            ),
            const SizedBox(height: 16),
            PaymentSummaryCard(breakdown: summary),
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
  ///
  /// An OFFER removed this way is not thereby over — the customer took it off,
  /// which is not the server ending it — so `rememberedOfferId` survives and
  /// the re-apply card appears in the chip's place.
  void _removePromoCode() {
    context.read<BookingCubit>().removePromoCode();
  }

  /// Puts back the offer this flow already took, after the customer removed it
  /// or typed a code over it.
  ///
  /// Straight through the SAME [BookingCubit.applyOffer] the handoff uses, so
  /// the wire rule holds without restating it: the offer id goes out alone and
  /// the server resolves its own code (the pair is a 400), and a refusal here
  /// is settled exactly as it is on the way in — the offer is forgotten and the
  /// card stops being offered rather than re-running the same rejection.
  ///
  /// Nothing is re-priced without the tap. The removal that led here left the
  /// order priced bare on purpose; re-applying silently would move a total the
  /// customer had just chosen to move the other way.
  void _reapplyOffer() {
    final cubit = context.read<BookingCubit>();
    final offerId = cubit.state.rememberedOfferId;
    if (offerId == null) return;
    cubit.applyOffer(offerId);
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
  ///
  /// **A code that arrived through an offer is NOT remembered.** It used to
  /// feed the same UCC16 autocomplete the typed path feeds, on the reasoning
  /// that an accepted code is an accepted code. That was wrong in both
  /// directions. The code the server echoes on an offer-driven quote is the
  /// offer's own MANAGED code, and a managed code is rejected the moment it is
  /// TYPED — so the suggestion is permanently dead, offered for a code the
  /// customer appeared to use minutes earlier. And it leaves a durable copy of
  /// an offer-bound code on the handset, which is precisely what
  /// `promo_code_history.dart` says the store never holds: codes the customer
  /// typed here, and nothing else.
  ///
  /// The client cannot tell a managed code from the ordinary one a PROMO_CODE
  /// offer links, and it does not need to: an offer is applied by TAPPING it,
  /// never by typing its code, so nothing that came through a handoff belongs
  /// in an autocomplete of things to type.
  ///
  /// The handoff was drained on the way in — `takeHandoff` is single-shot by
  /// design. Only a VERDICT earns that: the offer was applied, or it was
  /// refused on its merits and must not follow the customer into a later
  /// booking. A request that never reached a verdict — no network, a timeout,
  /// a 5xx — has said nothing about the offer, so it goes back in the slot and
  /// the next entry to this flow tries it again. Losing it there would charge
  /// the customer full price for a deal they accepted, with no message saying
  /// so and nothing on screen to tell them what happened.
  ///
  /// **The retry that matters happens inside [BookingCubit.applyOffer], not
  /// here.** This method used to claim the re-hold meant "the next quote this
  /// flow makes still carries it" — it did not, and could not: the very next
  /// quote is the bare [BookingCubit.reprice] below, and the slot is drained
  /// nowhere in this widget's lifetime (`takeHandoff` is called once, from
  /// `initState`). So an unanswered attempt priced the order at full price with
  /// only a network error to explain it, and the offer sat in a slot until the
  /// customer happened to re-enter the flow. `applyOffer` now re-attempts the
  /// offer itself before reporting a verdict-less outcome; the slot is what
  /// survives a genuine outage, on the next entry, and nothing more is claimed
  /// for it.
  void _applyOfferFromHandoff(String offerId) async {
    final cubit = context.read<BookingCubit>();
    final application = await cubit.applyOffer(offerId);
    if (application.applied) return;
    if (!application.settled) {
      PendingPromoCode.instance.hold(offerId: offerId);
    }
    if (!mounted) return;
    // UCC23 A3 — the discount is not granted and the total is unchanged, so the
    // order is priced without the offer rather than left with no quote at all.
    // Nothing is applied on this path, so there is no discount for this bare
    // quote to throw away.
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
