import 'package:aqua_go/features/profile/data/models/notification_preferences_model.dart';
import 'package:aqua_go/features/profile/data/repos/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_preferences_state.dart';

class NotificationPreferencesCubit extends Cubit<NotificationPreferencesState> {
  final ProfileRepository _repository;

  NotificationPreferencesCubit(this._repository) : super(NotificationPreferencesInitial());

  Future<void> getNotificationPreferences() async {
    emit(NotificationPreferencesLoading());
    final result = await _repository.getNotificationPreferences();
    result.fold(
      (failure) => emit(NotificationPreferencesError(failure.message)),
      (preferences) => emit(NotificationPreferencesLoaded(preferences)),
    );
  }

  Future<void> updateNotificationPreferences(NotificationPreferencesModel updatedPreferences) async {
    // Determine the current state's preferences to fall back to or display during loading
    NotificationPreferencesModel? currentPrefs;
    if (state is NotificationPreferencesLoaded) {
      currentPrefs = (state as NotificationPreferencesLoaded).preferences;
    } else if (state is NotificationPreferencesUpdating) {
      currentPrefs = (state as NotificationPreferencesUpdating).currentPreferences;
    } else if (state is NotificationPreferencesUpdateSuccess) {
      currentPrefs = (state as NotificationPreferencesUpdateSuccess).preferences;
    } else if (state is NotificationPreferencesUpdateError) {
      currentPrefs = (state as NotificationPreferencesUpdateError).currentPreferences;
    }

    final fallbackPrefs = currentPrefs ?? updatedPreferences;

    emit(NotificationPreferencesUpdating(fallbackPrefs));
    final result = await _repository.updateNotificationPreferences(updatedPreferences);
    result.fold(
      (failure) => emit(NotificationPreferencesUpdateError(failure.message, fallbackPrefs)),
      (newPreferences) => emit(NotificationPreferencesUpdateSuccess(newPreferences)),
    );
  }
}
