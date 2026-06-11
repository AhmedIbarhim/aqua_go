// ignore_for_file: use_build_context_synchronously

import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial(_getInitialLocale()));

  static Locale _getInitialLocale() {
    final isArabic = CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang;
    return isArabic ? const Locale('ar') : const Locale('en');
  }

  Future<void> toggleLanguage(BuildContext context) async {
    final isArabic = state.locale.languageCode == 'ar';
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    final authRepo = locator<AuthRepository>();
    final user = authRepo.getUser();

    if (user != null) {
      emit(LanguageLoading(state.locale));
      final localeStr = newLocale.languageCode == 'ar' ? 'ar_SA' : 'en';
      final updatedUser = user.copyWith(locale: localeStr);
      final result = await authRepo.updateProfile(updatedUser);
      
      await result.fold(
        (failure) async {
          emit(LanguageError(state.locale, failure.message));
        },
        (_) async {
          await CacheClient.setString(kLanguage, newLocale.languageCode);
          await context.setLocale(newLocale);
          emit(LanguageChanged(newLocale));
        },
      );
    } else {
      await CacheClient.setString(kLanguage, newLocale.languageCode);
      await context.setLocale(newLocale);
      emit(LanguageChanged(newLocale));
    }
  }

  Future<void> changeLanguage(BuildContext context, String lang) async {
    final newLocale = Locale(lang);
    final authRepo = locator<AuthRepository>();
    final user = authRepo.getUser();

    if (user != null) {
      emit(LanguageLoading(state.locale));
      final localeStr = newLocale.languageCode == 'ar' ? 'ar_SA' : 'en';
      final updatedUser = user.copyWith(locale: localeStr);
      final result = await authRepo.updateProfile(updatedUser);

      await result.fold(
        (failure) async {
          emit(LanguageError(state.locale, failure.message));
        },
        (_) async {
          await CacheClient.setString(kLanguage, newLocale.languageCode);
          await context.setLocale(newLocale);
          emit(LanguageChanged(newLocale));
        },
      );
    } else {
      await CacheClient.setString(kLanguage, newLocale.languageCode);
      await context.setLocale(newLocale);
      emit(LanguageChanged(newLocale));
    }
  }
}
