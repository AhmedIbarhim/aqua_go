part of 'language_cubit.dart';

sealed class LanguageState extends Equatable {
  final Locale locale;
  const LanguageState(this.locale);

  @override
  List<Object> get props => [locale];
}

final class LanguageInitial extends LanguageState {
  const LanguageInitial(super.locale);
}

final class LanguageChanged extends LanguageState {
  const LanguageChanged(super.locale);
}

final class LanguageLoading extends LanguageState {
  const LanguageLoading(super.locale);
}

final class LanguageError extends LanguageState {
  final String message;
  const LanguageError(super.locale, this.message);

  @override
  List<Object> get props => [locale, message];
}
