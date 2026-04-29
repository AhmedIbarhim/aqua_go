import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Brand Colors
  final Color primary;
  final Color brandSubtle;
  final Color brandHover;

  // Neutral Colors
  final Color black;
  final Color white;
  final Color background;
  final Color screenBG;
  final Color defaultSubtle;
  final Color borderSecondary;
  final Color cardBackGround;

  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textDark;

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

  const AppColorsExtension({
    required this.primary,
    required this.brandSubtle,
    required this.brandHover,
    required this.black,
    required this.white,
    required this.background,
    required this.screenBG,
    required this.defaultSubtle,
    required this.borderSecondary,
    required this.cardBackGround,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDark,
    required this.contentBlack,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentSecondaryLight,
    required this.contentTertiary,
    required this.contentDisabled,
    required this.success,
    required this.error,
    required this.warning,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
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
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      brandSubtle: brandSubtle ?? this.brandSubtle,
      brandHover: brandHover ?? this.brandHover,
      black: black ?? this.black,
      white: white ?? this.white,
      background: background ?? this.background,
      screenBG: screenBG ?? this.screenBG,
      defaultSubtle: defaultSubtle ?? this.defaultSubtle,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      cardBackGround: cardBackGround ?? this.cardBackGround,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDark: textDark ?? this.textDark,
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
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      brandSubtle: Color.lerp(brandSubtle, other.brandSubtle, t)!,
      brandHover: Color.lerp(brandHover, other.brandHover, t)!,
      black: Color.lerp(black, other.black, t)!,
      white: Color.lerp(white, other.white, t)!,
      background: Color.lerp(background, other.background, t)!,
      screenBG: Color.lerp(screenBG, other.screenBG, t)!,
      defaultSubtle: Color.lerp(defaultSubtle, other.defaultSubtle, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      cardBackGround: Color.lerp(cardBackGround, other.cardBackGround, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
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
    );
  }
}

// -----------------------------------------------------------------------------
// Dark Theme Colors (Matching your existing AppColors)
// -----------------------------------------------------------------------------
const darkAppColors = AppColorsExtension(
  primary: Color(0xFF16F7FF),
  brandSubtle: Color(0xFF202222),
  brandHover: Color(0xFF0F1F22),
  black: Color(0xFF171717),
  white: Color(0xFFFFFFFF),
  background: Color(0xFF151515),
  screenBG: Color(0xFF0D0D0D),
  defaultSubtle: Color(0xFF262626),
  borderSecondary: Color(0xFF525252),
  cardBackGround: Color(0xFF1C1C1C),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFA3A3A3),
  textDark: Colors.black,
  contentBlack: Color(0xFF171717),
  contentPrimary: Color(0xFF262C35),
  contentSecondary: Color(0xFF404A59),
  contentSecondaryLight: Color(0xFFE5E5E5),
  contentTertiary: Color(0xFF5A687D),
  contentDisabled: Color(0xFF737373),
  success: Color(0xFF22C55E),
  error: Color(0xFFEF4444),
  warning: Color(0xFFF59E0B),
);

// -----------------------------------------------------------------------------
// Light Theme Colors (Suggested placeholders, adjust as needed)
// -----------------------------------------------------------------------------
const lightAppColors = AppColorsExtension(
  primary: Color(0xFF008D91), // Darker cyan for contrast on light mode
  brandSubtle: Color(0xFFE0F7F8),
  brandHover: Color(0xFFBFFCFF),
  black: Color(0xFFFFFFFF), // Inverted for light mode
  white: Color(0xFF171717), // Inverted for light mode
  background: Color(0xFFF8FAFC),
  screenBG: Color(0xFFF3F4F6),
  defaultSubtle: Color(0xFFE2E8F0),
  borderSecondary: Color(0xFFCBD5E1),
  cardBackGround: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF64748B),
  textDark: Colors.black,
  contentBlack: Color(0xFF171717),
  contentPrimary: Color(0xFFF1F5F9),
  contentSecondary: Color(0xFFE2E8F0),
  contentSecondaryLight: Color(0xFF334155),
  contentTertiary: Color(0xFF94A3B8),
  contentDisabled: Color(0xFF94A3B8),
  success: Color(0xFF16A34A),
  error: Color(0xFFDC2626),
  warning: Color(0xFFD97706),
);

// -----------------------------------------------------------------------------
// BuildContext Helper for easy access
// -----------------------------------------------------------------------------
extension AppThemeExtension on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
