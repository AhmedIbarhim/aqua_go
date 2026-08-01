import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/pricing/gross_price_breakdown.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/quote_model.dart';
import '../widgets/booking_summary_widgets/booking_summary_card.dart';
import '../widgets/booking_summary_widgets/biker_notes_selection.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/booking_summary_widgets/payment_method_selection.dart';
import '../widgets/booking_summary_widgets/gift_coupon_payment_widget.dart';
import '../widgets/promo_code_section.dart';
import '../widgets/booking_summary_widgets/wallet_points_section.dart';
import '../widgets/booking_summary_widgets/booking_summary_bottom_action_sheet.dart';
import '../controllers/booking_cubit.dart';
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

    // SERVICE + ADDON only. The DISCOUNT row is deliberately NOT an item line:
    // it is `discountMinor`, rendered once below the subtotal. Modelling it as
    // a `GrossLine` would let it be summed into the very subtotal it is meant
    // to be subtracted from — the trap `QuoteLine`'s own javadoc warns about,
    // and the reason this filter is explicit rather than incidental.
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
      totalMinor: bookingState.quote?.totalMinor ?? 0,
      vatMinor: bookingState.quote?.vatMinor ?? 0,
      pointsDiscountMinor: bookingState.quote?.pointsDiscountMinor ?? 0,
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
          if (config.isGiftRedeem) ...[
            const GiftCouponPaymentWidget(),
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
            PaymentSummaryCard(breakdown: summary),
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
    setState(() {
      _isPointsToggled = false;
    });
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
    setState(() {
      _isPointsToggled = false;
    });
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
