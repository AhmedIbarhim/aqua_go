import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/subscription_response_model/subscription_response_model.dart';

import '../../../data/models/subscription_request_model.dart';
import '../../../data/repos/subscriptions_repository.dart';

part 'subscriptions_state.dart';

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionsRepository _subscriptionsRepository;

  SubscriptionsCubit({required SubscriptionsRepository subscriptionsRepository})
    : _subscriptionsRepository = subscriptionsRepository,
      super(SubscriptionsInitial());

  Future<void> getActiveSubscriptions({
    int? limit,
    String? cursor,
    String? status,
  }) async {
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.fetchActiveSubscriptions(
      limit: limit,
      cursor: cursor,
      status: status,
    );
    result.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (subscriptions) => emit(SubscriptionsLoaded(subscriptions)),
    );
  }

  Future<void> getSubscriptionDetail({required String subscriptionId}) async {
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.fetchSubscriptionDetail(
      subscriptionId: subscriptionId,
    );
    result.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (subscription) => emit(
        SubscriptionCreated(subscription),
      ), // Re-using SubscriptionCreated/Loaded state or single subscription loaded state
    );
  }

  /// Pay-before-create step 1 (spec §4.3): validates the package + customer
  /// and returns the Moyasar SDK payload. Emits [SubscriptionsLoading] while
  /// in flight. Returns the [PaymentInitModel] on success, or null on failure
  /// (the error is already surfaced via [SubscriptionsError]).
  Future<PaymentInitModel?> initiateSubscriptionPayment({
    required String packageId,
  }) async {
    final customerId = FetchUserData.getUserId() ?? '';
    final attemptNonce = const Uuid().v4();
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.subscriptionPaymentInit(
      packageId: packageId,
      customerId: customerId,
      attemptNonce: attemptNonce,
    );
    return result.fold(
      (failure) {
        emit(SubscriptionsError(failure.message));
        return null;
      },
      (init) {
        // Re-emit initial so the sheet can respond without a state change
        // blocking the Navigator.push below.
        emit(SubscriptionsInitial());
        return init;
      },
    );
  }

  /// Pay-before-create step 3 (spec §4.3): after the Moyasar SDK returned a
  /// verified `paid` payment, attach it to the request and create the
  /// subscription.
  Future<void> completeSubscriptionAfterPayment(
    String moyasarPaymentId,
    SubscriptionRequestModel baseRequest,
  ) async {
    emit(SubscriptionsLoading());
    final request = baseRequest.copyWith(moyasarPaymentId: moyasarPaymentId);
    final result = await _subscriptionsRepository.createSubscription(request);
    result.fold(
      (failure) => emit(SubscriptionPaymentRefundPending(failure.message)),
      (subscription) => emit(SubscriptionCreated(subscription)),
    );
  }

  Future<void> subscribeToPackage(SubscriptionRequestModel request) async {
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.createSubscription(request);
    result.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (subscription) => emit(SubscriptionCreated(subscription)),
    );
  }

  /// The user dismissed the Moyasar SDK sheet without paying.
  void onSubscriptionPaymentCancelled() {
    emit(SubscriptionPaymentCancelled());
  }

  Future<void> cancelSubscription({
    required String subscriptionId,
    required String reasonCode,
    String? note,
  }) async {
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.cancelActiveSubscription(
      subscriptionId: subscriptionId,
      reasonCode: reasonCode,
      note: note,
    );
    result.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (subscription) => emit(SubscriptionCancelled(subscription)),
    );
  }
}
