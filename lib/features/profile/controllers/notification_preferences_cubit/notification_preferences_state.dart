part of 'notification_preferences_cubit.dart';

sealed class NotificationPreferencesState extends Equatable {
  const NotificationPreferencesState();

  @override
  List<Object?> get props => [];
}

final class NotificationPreferencesInitial extends NotificationPreferencesState {}

final class NotificationPreferencesLoading extends NotificationPreferencesState {}

final class NotificationPreferencesLoaded extends NotificationPreferencesState {
  final NotificationPreferencesModel preferences;
  const NotificationPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

final class NotificationPreferencesError extends NotificationPreferencesState {
  final String message;
  const NotificationPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}

final class NotificationPreferencesUpdating extends NotificationPreferencesState {
  final NotificationPreferencesModel currentPreferences;
  const NotificationPreferencesUpdating(this.currentPreferences);

  @override
  List<Object?> get props => [currentPreferences];
}

final class NotificationPreferencesUpdateSuccess extends NotificationPreferencesState {
  final NotificationPreferencesModel preferences;
  const NotificationPreferencesUpdateSuccess(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

final class NotificationPreferencesUpdateError extends NotificationPreferencesState {
  final String message;
  final NotificationPreferencesModel currentPreferences;
  const NotificationPreferencesUpdateError(this.message, this.currentPreferences);

  @override
  List<Object?> get props => [message, currentPreferences];
}
