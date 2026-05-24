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

  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTheme;

  // Content Colors
  final Color contentBlack;
  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentSecondaryLight;
  final Color contentTertiary;
  final Color contentDisabled;

  // Semantic Colors
  final Color success;
  final Color error;
  final Color warning;
  final Color successLight;
  final Color errorLight;

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
    required this.textPrimary,
    required this.textSecondary,
    required this.textTheme,
    required this.contentBlack,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentSecondaryLight,
    required this.contentTertiary,
    required this.contentDisabled,
    required this.success,
    required this.error,
    required this.warning,
    required this.successLight,
    required this.errorLight,
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
    Color? defaultSubtle,
    Color? borderSecondary,
    Color? cardBackGround,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDark,
    Color? contentBlack,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentSecondaryLight,
    Color? contentTertiary,
    Color? contentDisabled,
    Color? success,
    Color? error,
    Color? warning,
    Color? successLight,
    Color? errorLight,
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
      defaultSubtle: defaultSubtle ?? this.defaultSubtle,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      cardBackGround: cardBackGround ?? this.cardBackGround,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTheme: textDark ?? textTheme,
      contentBlack: contentBlack ?? this.contentBlack,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentSecondaryLight:
          contentSecondaryLight ?? this.contentSecondaryLight,
      contentTertiary: contentTertiary ?? this.contentTertiary,
      contentDisabled: contentDisabled ?? this.contentDisabled,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      successLight: successLight ?? this.successLight,
      errorLight: errorLight ?? this.errorLight,
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
      screenBG: Color.lerp(screenBG, other.screenBG, t)!,
      defaultSubtle: Color.lerp(defaultSubtle, other.defaultSubtle, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      cardBackGround: Color.lerp(cardBackGround, other.cardBackGround, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
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
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
    );
  }
}

// -----------------------------------------------------------------------------
// Dark Theme Colors (Matching your existing AppColors)
// -----------------------------------------------------------------------------
const darkAppColors = AppColors(
  splashColor: Color(0xFF0D0D0D),
  primary: Color(0xFF16F7FF),
  brandSubtle: Color(0xFF202222),
  brandHover: Color(0xFF0F1F22),
  themeColor: Color(0xFF171717),
  themeOpositeColor: Color(0xFFFFFFFF),
  background: Color(0xFF151515),
  screenBG: Color(0xFF0D0D0D),
  defaultSubtle: Color(0xFF262626),
  borderSecondary: Color(0xFF525252),
  cardBackGround: Color(0xFF1C1C1C),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFA3A3A3),
  textTheme: Colors.black,
  contentBlack: Color(0xFF171717),
  contentPrimary: Color(0xFF262C35),
  contentSecondary: Color(0xFF404A59),
  contentSecondaryLight: Color(0xFFE5E5E5),
  contentTertiary: Color(0xFF5A687D),
  contentDisabled: Color(0xFF737373),
  success: Color(0xFF0E612C),
  error: Color(0xFFD90421),
  successLight: Color(0xFF22C55E),
  errorLight: Color(0xFFEF4444),
  warning: Color(0xFFF59E0B),
);

// -----------------------------------------------------------------------------
// Light Theme Colors (Suggested placeholders, adjust as needed)
// -----------------------------------------------------------------------------
const lightAppColors = AppColors(
  splashColor: Color(0xFF0D0D0D),
  primary: Color(0xFF0095AA),
  // primary: Color(0xFF00BEC3), // Darker cyan for contrast on light mode
  brandSubtle: Color(0xFFE0F7F8),
  brandHover: Color(0xFFBFFCFF),
  themeColor: Color(0xFFFFFFFF), // Inverted for light mode
  themeOpositeColor: Color(0xFF171717), // Inverted for light mode
  background: Color(0xFFF8FAFC),
  screenBG: Color(0xFFF3F4F6),
  defaultSubtle: Color(0xFFE2E8F0),
  borderSecondary: Color(0xFFCBD5E1),
  cardBackGround: Color(0xFFE1E2E3),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF64748B),
  textTheme: Colors.white,
  contentBlack: Color(0xFF171717),
  contentPrimary: Color(0xFFF1F5F9),
  contentSecondary: Color(0xFFE2E8F0),
  contentSecondaryLight: Color(0xFF334155),
  contentTertiary: Color(0xFF94A3B8),
  contentDisabled: Color(0xFF94A3B8),
  success: Color(0xFF0E612C),
  error: Color(0xFFD90421),
  successLight: Color(0xFF22C55E),
  errorLight: Color(0xFFEF4444),
  warning: Color(0xFFD97706),
);
