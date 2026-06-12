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
