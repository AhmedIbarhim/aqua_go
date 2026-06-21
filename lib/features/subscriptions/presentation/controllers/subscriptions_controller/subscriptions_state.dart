part of 'subscriptions_cubit.dart';

sealed class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object?> get props => [];
}

final class SubscriptionsInitial extends SubscriptionsState {}

final class SubscriptionsLoading extends SubscriptionsState {}

final class SubscriptionsLoaded extends SubscriptionsState {
  final List<SubscriptionResponseModel> subscriptions;

  const SubscriptionsLoaded(this.subscriptions);

  @override
  List<Object?> get props => [subscriptions];
}

final class SubscriptionCreated extends SubscriptionsState {
  final SubscriptionResponseModel subscription;

  const SubscriptionCreated(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

final class SubscriptionCancelled extends SubscriptionsState {
  final SubscriptionResponseModel subscription;

  const SubscriptionCancelled(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

final class SubscriptionsError extends SubscriptionsState {
  final String message;

  const SubscriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when the subscription payment is cancelled (user dismissed
/// the Moyasar SDK sheet without paying).
final class SubscriptionPaymentCancelled extends SubscriptionsState {}

/// Emitted after the SDK returned a verified payment and the
/// subscription create call failed (server auto-refunds).
final class SubscriptionPaymentRefundPending extends SubscriptionsState {
  final String message;

  const SubscriptionPaymentRefundPending(this.message);

  @override
  List<Object?> get props => [message];
}
