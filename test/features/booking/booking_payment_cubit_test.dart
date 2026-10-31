import 'dart:async';

import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/booking/data/models/service_booking_request_model.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';
import 'package:aqua_go/features/booking/domain/booking_submission.dart';
import 'package:aqua_go/features/booking/domain/strategies/booking_submit_strategy.dart';
import 'package:aqua_go/features/booking/domain/strategies/package_booking_submit.dart';
import 'package:aqua_go/features/booking/domain/strategies/package_reschedule_booking_submit.dart';
import 'package:aqua_go/features/booking/domain/strategies/redeem_gift_booking_submit.dart';
import 'package:aqua_go/features/booking/domain/strategies/service_booking_submit.dart';
import 'package:aqua_go/features/booking/domain/strategies/service_reschedule_booking_submit.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_payment_state.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_state.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_loading_overlay_listener.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// Records what reached the create endpoint, then fails so no response body has
/// to be faked.
class _CreateRecordingRepo extends RecordingBookingRepo {
  final List<String?> createdWithPayment = [];

  @override
  Future<Either<Failure, BookingResponseModel>> createBooking(
    ServiceBookingRequestModel booking,
  ) async {
    createdWithPayment.add(booking.moyasarPaymentId);
    return left(ServerFailure('stop here'));
  }
}

class _StatusCubit extends Cubit<BookingStatus> {
  _StatusCubit() : super(BookingStatus.initial);

  void set(BookingStatus status) => emit(status);
}

/// A flow that cannot carry a payment, like reschedule or gift redemption.
class _UnpaidStrategy implements BookingSubmitStrategy {
  int submits = 0;

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingSubmission submission,
  }) async {
    submits++;
    return left(ServerFailure('must not be reached'));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  test('only the flows that can take money are paid strategies', () {
    expect(ServiceBookingSubmit(), isA<PaidBookingSubmitStrategy>());
    expect(const PackageBookingSubmit(), isA<PaidBookingSubmitStrategy>());

    final unpaid = <BookingSubmitStrategy>[
      const RedeemGiftBookingSubmit(),
      const PackageRescheduleBookingSubmit(),
      ServiceRescheduleBookingSubmit(existingBookingId: 'b-1'),
    ];
    for (final strategy in unpaid) {
      expect(strategy, isNot(isA<PaidBookingSubmitStrategy>()));
    }
  });

  test('a paid completion sends the payment id to create', () async {
    final repo = _CreateRecordingRepo();
    final cubit = buildCubit(repo, submitStrategy: ServiceBookingSubmit());
    addTearDown(cubit.close);

    await cubit.payment.completeBookingAfterPayment('pay_1');

    expect(repo.createdWithPayment, ['pay_1']);
  });

  test('a zero-total submit sends no payment id', () async {
    final repo = _CreateRecordingRepo();
    final cubit = buildCubit(repo, submitStrategy: ServiceBookingSubmit());
    addTearDown(cubit.close);

    await cubit.payment.submitBooking();

    expect(repo.createdWithPayment, [null]);
  });

  test(
    'a paid customer in an unpaid flow gets the unconfirmed alert',
    () async {
      final strategy = _UnpaidStrategy();
      final cubit = buildCubit(
        RecordingBookingRepo(),
        submitStrategy: strategy,
      );
      addTearDown(cubit.close);

      await cubit.payment.completeBookingAfterPayment('pay_1');

      expect(strategy.submits, 0);
      expect(cubit.payment.state.status, BookingStatus.failure);
      expect(cubit.payment.state.paymentPhase, PaymentPhase.createUnconfirmed);
    },
  );

  testWidgets('a failed quote on the details screen is reported there', (
    tester,
  ) async {
    final repo = RecordingBookingRepo(
      quoteFailure: (_, _) => ServerFailure('pricing is down'),
    );
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    await pumpDetails(tester, cubit);

    // Pumped by hand: settling would run the snackbar's duration out.
    unawaited(cubit.pricing.repriceForDisplayWithoutPromo());
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('pricing is down'), findsOneWidget);
  });

  testWidgets('the overlay follows a request and every show has its hide', (
    tester,
  ) async {
    final cubit = _StatusCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[lightAppColors],
        ),
        home: BlocProvider.value(
          value: cubit,
          child: MultiBlocListener(
            listeners: [
              bookingLoadingOverlayListener<_StatusCubit, BookingStatus>(
                (status) => status,
              ),
            ],
            child: const SizedBox(),
          ),
        ),
      ),
    );

    cubit.set(BookingStatus.loading);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);

    // Moving between two settled statuses must not spend another cubit's hide.
    cubit.set(BookingStatus.failure);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    cubit.set(BookingStatus.initial);
    await tester.pump();
    await tester.pump();

    expect(find.byType(CustomLoadingIndicator), findsNothing);
  });
}
