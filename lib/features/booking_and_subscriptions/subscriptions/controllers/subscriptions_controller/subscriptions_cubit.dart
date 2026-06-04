import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/subscribed_package_model.dart';
import '../../data/repos/subscriptions_repository.dart';

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

  Future<void> subscribeToPackage({
    required String packageId,
    String? vehicleId,
    String? addressId,
    List<ScheduleEntry>? initialSchedule,
    String? nonce,
  }) async {
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.createSubscription(
      packageId: packageId,
      vehicleId: vehicleId,
      addressId: addressId,
      initialSchedule: initialSchedule,
      nonce: nonce,
    );
    result.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (subscription) => emit(SubscriptionCreated(subscription)),
    );
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
