import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/language_controller/language_cubit.dart';

extension ContextExtensions on BuildContext {
  bool get isEn => read<LanguageCubit>().state.locale.languageCode == 'en';
  bool get isAr => read<LanguageCubit>().state.locale.languageCode == 'ar';
}
