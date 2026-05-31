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

  Future<void> getActiveSubscriptions() async {
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.fetchActiveSubscriptions();
    result.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (subscriptions) => emit(SubscriptionsLoaded(subscriptions)),
    );
  }

  Future<void> subscribeToPackage({
    required String packageId,
    required String vehicleId,
    required String addressId,
    String? nonce,
  }) async {
    emit(SubscriptionsLoading());
    final result = await _subscriptionsRepository.createSubscription(
      packageId: packageId,
      vehicleId: vehicleId,
      addressId: addressId,
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
