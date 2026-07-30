import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // Splash Colors
  final Color splashColor;

  // Brand Colors
  final Color primary;
  final Color brandSubtle;
  final Color brandHover;

  // Neutral Colors
  final Color themeColor;
  final Color themeOpositeColor;
  final Color background;
  final Color screenBG;
  final Color defaultSubtle;
  final Color borderSecondary;
  final Color cardBackGround;
  final Color fields;

  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textTheme;

  // Content Colors
  final Color contentBlack;
  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentSecondaryLight;
  final Color contentTertiary;
  final Color contentDisabled;
  final Color chatPrimary;
  final Color chatSecondary;

  // Semantic Colors
  final Color success;
  final Color error;
  final Color warning;
  final Color successSecondry;
  final Color errorSecondary;
  final Color info;

  const AppColors({
    required this.splashColor,
    required this.primary,
    required this.brandSubtle,
    required this.brandHover,
    required this.themeColor,
    required this.themeOpositeColor,
    required this.background,
    required this.screenBG,
    required this.defaultSubtle,
    required this.borderSecondary,
    required this.cardBackGround,
    required this.fields,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textTheme,
    required this.contentBlack,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentSecondaryLight,
    required this.contentTertiary,
    required this.contentDisabled,
    required this.chatPrimary,
    required this.chatSecondary,
    required this.success,
    required this.error,
    required this.warning,
    required this.successSecondry,
    required this.errorSecondary,
    required this.info,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? brandSubtle,
    Color? brandHover,
    Color? black,
    Color? white,
    Color? background,
    Color? screenBG,
    Color? cardBackGround,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDark,
    Color? contentBlack,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentSecondaryLight,
    Color? contentTertiary,
    Color? contentDisabled,
    Color? chatPrimary,
    Color? chatSecondary,
    Color? success,
    Color? successSecondry,
    Color? error,
    Color? errorSecondary,
    Color? warning,
    Color? successLight,
    Color? errorLight,
    Color? info,
  }) {
    return AppColors(
      splashColor: splashColor,
      primary: primary ?? this.primary,
      brandSubtle: brandSubtle ?? this.brandSubtle,
      brandHover: brandHover ?? this.brandHover,
      themeColor: black ?? themeColor,
      themeOpositeColor: white ?? themeOpositeColor,
      background: background ?? this.background,
      screenBG: screenBG ?? this.screenBG,
      fields: fields ?? this.fields,
      defaultSubtle: defaultSubtle ?? this.defaultSubtle,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      cardBackGround: cardBackGround ?? this.cardBackGround,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textTheme: textDark ?? textTheme,
      contentBlack: contentBlack ?? this.contentBlack,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentSecondaryLight:
          contentSecondaryLight ?? this.contentSecondaryLight,
      contentTertiary: contentTertiary ?? this.contentTertiary,
      contentDisabled: contentDisabled ?? this.contentDisabled,
      chatPrimary: chatPrimary ?? this.chatPrimary,
      chatSecondary: chatSecondary ?? this.chatSecondary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      successSecondry: successSecondry ?? this.successSecondry,
      errorSecondary: errorSecondary ?? this.errorSecondary,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      splashColor: Color.lerp(splashColor, other.splashColor, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      brandSubtle: Color.lerp(brandSubtle, other.brandSubtle, t)!,
      brandHover: Color.lerp(brandHover, other.brandHover, t)!,
      themeColor: Color.lerp(themeColor, other.themeColor, t)!,
      themeOpositeColor: Color.lerp(
        themeOpositeColor,
        other.themeOpositeColor,
        t,
      )!,
      background: Color.lerp(background, other.background, t)!,
      fields: Color.lerp(fields, other.fields, t)!,
      screenBG: Color.lerp(screenBG, other.screenBG, t)!,
      defaultSubtle: Color.lerp(defaultSubtle, other.defaultSubtle, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      cardBackGround: Color.lerp(cardBackGround, other.cardBackGround, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textTheme: Color.lerp(textTheme, other.textTheme, t)!,
      contentBlack: Color.lerp(contentBlack, other.contentBlack, t)!,
      contentPrimary: Color.lerp(contentPrimary, other.contentPrimary, t)!,
      contentSecondary: Color.lerp(
        contentSecondary,
        other.contentSecondary,
        t,
      )!,
      contentSecondaryLight: Color.lerp(
        contentSecondaryLight,
        other.contentSecondaryLight,
        t,
      )!,
      contentTertiary: Color.lerp(contentTertiary, other.contentTertiary, t)!,
      contentDisabled: Color.lerp(contentDisabled, other.contentDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      chatPrimary: Color.lerp(chatPrimary, other.chatPrimary, t)!,
      chatSecondary: Color.lerp(chatSecondary, other.chatSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      successSecondry: Color.lerp(successSecondry, other.successSecondry, t)!,
      errorSecondary: Color.lerp(errorSecondary, other.errorSecondary, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

// -----------------------------------------------------------------------------
// Dark Theme Colors
// -----------------------------------------------------------------------------
const darkAppColors = AppColors(
  splashColor: Color(0xFF0D0D0D),
  primary: Color(0xFF16F7FF),
  brandSubtle: Color(0xFF12363A),
  brandHover: Color(0xFF0F1F22),
  themeColor: Color(0xFF171717),
  themeOpositeColor: Color(0xFFFFFFFF),
  background: Color(0xFF151515),
  screenBG: Color(0xFF0D0D0D),
  defaultSubtle: Color(0xFF262626),
  borderSecondary: Color(0xFF525252),
  cardBackGround: Color(0xFF1C1C1C),
  fields: Color(0xFF151515),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFE5E5E5),
  textTertiary: Color(0xFFA3A3A3),
  textTheme: Colors.black,
  contentBlack: Color(0xFF171717),
  contentPrimary: Color(0xFF262C35),
  contentSecondary: Color(0xFF404A59),
  contentSecondaryLight: Color(0xFFE5E5E5),
  contentTertiary: Color(0xFF5A687D),
  contentDisabled: Color(0xFF737373),
  success: Color(0xFF22C55E),
  error: Color(0xFFD90421),
  successSecondry: Color(0xFF15803D),
  errorSecondary: Color(0xFFEF4444),
  warning: Color(0xFFF59E00),
  info: Color(0xFF3B82F6),
  chatPrimary: Color(0xFF1C1C1C),
  chatSecondary: Color(0xFF262626),
);

// -----------------------------------------------------------------------------
// Light Theme Colors
// -----------------------------------------------------------------------------
const lightAppColors = AppColors(
  splashColor: Color(0xFF0D0D0D),
  primary: Color(0xFF35C5CC),
  brandSubtle: Color(0xFFE0F7F8),
  brandHover: Color(0xFFBFEFF0),
  themeColor: Color(0xFFFFFFFF),
  themeOpositeColor: Color(0xFF171717),
  background: Color(0xFFF0F1F4),
  screenBG: Color(0xFFF8FAFC),
  defaultSubtle: Color(0xFFDEE4EC),
  borderSecondary: Color(0xFFCCD0D7),
  cardBackGround: Color(0xFFE6E7E9),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF404A59),
  textTertiary: Color(0xFF5A687D),
  textTheme: Colors.white,
  contentBlack: Color(0xFF171717),
  contentPrimary: Color(0xFFF1F5F9),
  contentSecondary: Color(0xFFE2E8F0),
  contentSecondaryLight: Color(0xFF334155),
  contentTertiary: Color(0xFF94A3B8),
  contentDisabled: Color(0xFFCCD0D7),
  success: Color(0xFF15803D),
  error: Color(0xFFD90421),
  successSecondry: Color(0xFF22C55E),
  errorSecondary: Color(0xFFEF4444),
  warning: Color(0xFFD97706),
  info: Color(0xFF1D4ED8),
  fields: Color(0xFFEFF0F2),
  chatPrimary: Color(0xFFEFF0F2),
  chatSecondary: Color(0xFFE2E8F0),
);
