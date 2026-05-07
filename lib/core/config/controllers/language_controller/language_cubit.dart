import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial(_getInitialLocale()));

  static Locale _getInitialLocale() {
    final lang = SharedPrefs.getString(kLanguage);
    if (lang.isEmpty) {
      return const Locale('ar');
    }
    return Locale(lang);
  }

  Future<void> toggleLanguage(BuildContext context) async {
    final isArabic = state.locale.languageCode == 'ar';
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');

    await SharedPrefs.setString(kLanguage, newLocale.languageCode);
    await context.setLocale(newLocale);
    emit(LanguageChanged(newLocale));
  }

  Future<void> changeLanguage(BuildContext context, String lang) async {
    final newLocale = Locale(lang);

    await SharedPrefs.setString(kLanguage, newLocale.languageCode);
    await context.setLocale(newLocale);
    emit(LanguageChanged(newLocale));
  }
}
