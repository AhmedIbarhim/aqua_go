import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';
import 'package:aqua_go/features/booking/domain/promo_code_history.dart';
import 'package:aqua_go/features/booking/domain/strategies/booking_submit_strategy.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_state.dart';
import 'package:aqua_go/features/booking/presentation/widgets/payment_summary_card.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// UCC16 — what the customer is actually SHOWN once a code is applied, and what
/// they are told when a charge had to be undone.
///
/// The amounts asserted here are real rendered figures; the messages are
/// asserted by localization KEY, because `tr(context: context)` resolves to the
/// key under this harness. That keeps the assertions about WHICH message fires
/// rather than about its wording.
/// The figure rendered in the payment-summary row whose label contains
/// [labelKey].
///
/// A bare `find.text('115.00')` is AMBIGUOUS on this screen: the card itemises
/// every line, so a single-service order shows 115.00 twice — once as the
/// SERVICE line and once as the "original total" it sums to. Scoping to the row
/// makes each assertion about the row it is actually about, which is also what
/// stops a future second line item from breaking it again.
Finder summaryRowValue(String labelKey, String value) {
  final label = find.descendant(
    of: find.byType(PaymentSummaryCard),
    matching: find.textContaining(labelKey),
  );
  return find.descendant(
    of: find.ancestor(of: label, matching: find.byType(Row)).first,
    matching: find.text(value),
  );
}

void main() {
  const promoCode = 'WELCOME15';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  // Each test starts with an empty code history, so one test's suggestions can
  // never explain another's.
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    // The code history is keyed by the signed-in customer's local id, so the
    // suggestion assertions need somebody signed in. Same cached-user record
    // the app writes — and the same one session teardown removes.
    await CacheClient.setString(
      kUserData,
      UserModel(id: 'customer-under-test').toEncodedJson(),
    );
  });

  group('the three-value breakdown (UCC16 step 4)', () {
    testWidgets('states the original and the saving beside the new total', (
      tester,
    ) async {
      final cubit = buildCubit(RecordingBookingRepo());
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await applyPromo(tester, promoCode);

      // Original (115.00) − discount (20.00) == the new total (95.00). The
      // Subtotal/VAT column above is a SEPARATE statement over the same total
      // and is untouched: 82.61 + 12.39 == 95.00.
      expect(
        summaryRowValue('bookings.original_total', '115.00'),
        findsOneWidget,
        reason: 'the customer must see what the order cost before the code',
      );
      expect(
        find.text('-20.00'),
        findsOneWidget,
        reason: 'and what the code took off it',
      );
      expect(find.text('95.00'), findsOneWidget);
      expect(
        find.text('12.39'),
        findsOneWidget,
        reason: 'VAT is still the backend split of the DISCOUNTED total — the '
            'discount is not subtracted a second time',
      );
    });

    testWidgets('shows neither row when no code is applied', (tester) async {
      final cubit = buildCubit(RecordingBookingRepo());
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(find.textContaining('bookings.original_total'), findsNothing);
      expect(find.textContaining('bookings.promo_discount'), findsNothing);
      // The total, undiscounted — read off the TOTAL row. The SERVICE line
      // above it carries the same figure, which is exactly right for a
      // single-service order and exactly why the finder is scoped.
      expect(summaryRowValue('bookings.total_amount', '115.00'), findsOneWidget);
    });
  });

  group('the amount the code saved', () {
    testWidgets('is named on the applied chip, not just "applied"', (
      tester,
    ) async {
      final cubit = buildCubit(RecordingBookingRepo());
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await applyPromo(tester, promoCode);

      expect(
        find.textContaining('bookings.promo_saved'),
        findsOneWidget,
        reason: 'a customer told only "code applied" cannot tell whether it '
            'was worth 5 SAR or 50',
      );
      expect(find.textContaining('bookings.promo_code_applied'), findsNothing);
    });
  });

  group('the promo code dialog', () {
    testWidgets('refuses a code that is not 4-20 alphanumeric', (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await openPromoDialog(tester);

      // Nothing typed yet is the starting state, not an error.
      expect(find.textContaining('bookings.promo_code_malformed'), findsNothing);
      expect(applyButtonEnabled(tester), isFalse);

      await tester.enterText(find.byType(TextField), 'AB-');
      await tester.pumpAndSettle();

      expect(find.textContaining('bookings.promo_code_malformed'), findsOneWidget);
      expect(
        applyButtonEnabled(tester),
        isFalse,
        reason: 'a malformed code must not cost a round trip that would come '
            'back as the same generic "not recognised" an unknown code gets',
      );

      await tester.enterText(find.byType(TextField), 'ABCD');
      await tester.pumpAndSettle();

      expect(find.textContaining('bookings.promo_code_malformed'), findsNothing);
      expect(applyButtonEnabled(tester), isTrue);
      expect(repo.quoteCalls, [null], reason: 'nothing was sent yet');
    });

    testWidgets('offers previously used codes, most recent first', (
      tester,
    ) async {
      await PromoCodeHistory.remember('OLDCODE1');
      await PromoCodeHistory.remember('WELCOME15');

      final cubit = buildCubit(RecordingBookingRepo());
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await openPromoDialog(tester);

      expect(find.textContaining('bookings.promo_recent_codes'), findsOneWidget);
      final chips = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(Wrap),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .toList();
      expect(chips, ['WELCOME15', 'OLDCODE1']);

      // Typing narrows the list to what still matches.
      await tester.enterText(find.byType(TextField), 'OLD');
      await tester.pumpAndSettle();
      expect(find.text('WELCOME15'), findsNothing);

      // Tapping a suggestion fills the field rather than applying it — the
      // customer stays in control of when the code is sent.
      await tester.tap(find.text('OLDCODE1'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'OLDCODE1');
    });

    testWidgets('a code that arrived through an OFFER is never remembered', (
      tester,
    ) async {
      // This used to assert the opposite, on the reasoning that an accepted
      // code is an accepted code. The code the server echoes on an offer-driven
      // quote is the offer's own MANAGED code, and a managed code is refused
      // the moment it is TYPED — so the suggestion was permanently dead, for a
      // code the customer appeared to use minutes earlier, and it left a
      // durable copy of an offer-bound code on the handset. An offer is applied
      // by TAPPING it, never by typing its code, so nothing that arrived
      // through a handoff belongs in an autocomplete of things to type.
      PendingPromoCode.instance.hold(offerId: 'offer-1');
      addTearDown(PendingPromoCode.instance.takeHandoff);

      final cubit = buildCubit(RecordingBookingRepo());
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      // The offer WAS applied — the code the SERVER resolved it to is on the
      // quote, so this is not a vacuous pass.
      expect(cubit.state.appliedPromoCode, offerResolvedPromoCode);
      expect(PromoCodeHistory.recent(), isEmpty);
    });

    testWidgets('an offer the backend refused leaves the history empty', (
      tester,
    ) async {
      PendingPromoCode.instance.hold(offerId: 'offer-1');
      addTearDown(PendingPromoCode.instance.takeHandoff);

      final cubit = buildCubit(
        RecordingBookingRepo(
          quoteFailure: (_, offerId) => offerId == null
              ? null
              : const ServerFailure(
                  'Code not recognised or expired',
                  type: FailureType.validation,
                ),
        ),
      );
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(cubit.state.appliedPromoCode, isNull);
      expect(PromoCodeHistory.recent(), isEmpty);
    });

    testWidgets('remembers only codes the backend accepted', (tester) async {
      final repo = RecordingBookingRepo(
        quoteFailure: (code, _) => code == null
            ? null
            : const ServerFailure(
                'Code not recognised or expired',
                type: FailureType.validation,
              ),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await applyPromo(tester, 'NOSUCHCODE');

      expect(cubit.state.appliedPromoCode, isNull);
      expect(
        PromoCodeHistory.recent(),
        isEmpty,
        reason: 'suggesting a code that has never worked would send the '
            'customer back into the same rejection',
      );
    });
  });

  group('a charge that had to be undone', () {
    testWidgets(
      'says the card was refunded and how long it takes to appear',
      (tester) async {
        // The 422 the server raises when a promo cap was consumed between the
        // quote and the charge. The card WAS charged and HAS been refunded —
        // the server detail says nothing about either, but the SLUG does: the
        // backend runs its compensating refund on this rejection before it
        // throws, so the claim rests on the contract rather than a guess.
        const serverDetail = 'This promo code is no longer valid.';
        final cubit = buildCubit(
          RecordingBookingRepo(),
          submitStrategy: const _FailingSubmit(
            serverDetail,
            slug: 'promo-code-no-longer-valid',
          ),
        );
        addTearDown(cubit.close);

        await pumpSummary(tester, cubit);
        await cubit.completeBookingAfterPayment('pay_1');
        await settle(tester);

        expect(cubit.state.paymentPhase, PaymentPhase.refundPending);
        expect(
          find.textContaining('bookings.payment_refunded_title'),
          findsOneWidget,
        );
        expect(
          find.textContaining(serverDetail),
          findsOneWidget,
          reason: 'the reason the booking failed is still stated',
        );
        expect(
          find.textContaining('bookings.payment_refunded_notice'),
          findsOneWidget,
          reason: 'money left the account — the customer must be told it is '
              'coming back, and that a card refund can take up to 7 days',
        );
      },
    );

    testWidgets(
      'never promises a refund when the create never got an answer',
      (tester) async {
        // The connection dropped after the card was charged. The server may
        // have created the booking and may never have refunded anything — the
        // client knows neither.
        final cubit = buildCubit(
          RecordingBookingRepo(),
          submitStrategy: const _FailingSubmit(
            'No internet connection',
            type: FailureType.network,
          ),
        );
        addTearDown(cubit.close);

        await pumpSummary(tester, cubit);
        await cubit.completeBookingAfterPayment('pay_1');
        await settle(tester);

        expect(cubit.state.paymentPhase, PaymentPhase.createUnconfirmed);
        expect(
          find.textContaining('bookings.payment_refunded_notice'),
          findsNothing,
          reason: 'the booking may in fact exist and no refund may have run — '
              'asserting one would be inventing it',
        );
        expect(
          find.textContaining('bookings.payment_unconfirmed_title'),
          findsOneWidget,
        );
        expect(
          find.textContaining('bookings.payment_unconfirmed_notice'),
          findsOneWidget,
          reason: 'the customer must be told not to pay again and where to '
              'check whether the booking went through',
        );
      },
    );

    testWidgets(
      'a 4xx that runs no compensation is unconfirmed, not refunded',
      (tester) async {
        // A rejection thrown AFTER verify but on a path with no compensating
        // refund (zone mismatch, saved address gone, schedule window). Same
        // 422/409 shape as the refunding ones, so the status code cannot tell
        // them apart — only the slug can, and this one is not in the set.
        final cubit = buildCubit(
          RecordingBookingRepo(),
          submitStrategy: const _FailingSubmit(
            'The address is no longer in this zone.',
            slug: 'zone-mismatch',
          ),
        );
        addTearDown(cubit.close);

        await pumpSummary(tester, cubit);
        await cubit.completeBookingAfterPayment('pay_1');
        await settle(tester);

        expect(cubit.state.paymentPhase, PaymentPhase.createUnconfirmed);
        expect(
          find.textContaining('bookings.payment_refunded_notice'),
          findsNothing,
        );
        expect(
          find.textContaining('bookings.payment_unconfirmed_notice'),
          findsOneWidget,
        );
      },
    );

    testWidgets('an ordinary failure stays a snackbar, not a refund notice', (
      tester,
    ) async {
      final repo = RecordingBookingRepo(
        quoteFailure: (code, _) => code == null
            ? null
            : const ServerFailure(
                'Code not recognised or expired',
                type: FailureType.validation,
              ),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await applyPromo(tester, 'NOSUCHCODE');

      expect(cubit.state.paymentPhase, PaymentPhase.none);
      expect(
        find.textContaining('bookings.payment_refunded_notice'),
        findsNothing,
        reason: 'nothing was charged, so promising a refund would be a lie',
      );
      expect(find.textContaining('Code not recognised'), findsOneWidget);
    });
  });
}

/// Fails booking-create the way the server does after the card is charged.
/// [slug] is the RFC 9457 error slug the rejection carried — the only thing
/// that says whether the compensating refund ran.
class _FailingSubmit implements BookingSubmitStrategy {
  const _FailingSubmit(
    this.detail, {
    this.type = FailureType.validation,
    this.slug,
  });

  final String detail;
  final FailureType type;
  final String? slug;

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
    String? moyasarPaymentId,
  }) async => left(ServerFailure(detail, type: type, slug: slug));
}
