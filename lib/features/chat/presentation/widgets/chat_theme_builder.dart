import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extentions/context_extentions.dart';

/// Builds a [ChatTheme] from the app's [AppColors] tokens + the IBM Plex Sans
/// Arabic font, so the flutter_chat_ui surface matches the rest of the app in
/// both light and dark. RTL is handled automatically by the widget — no
/// direction-specific styling here.
ChatTheme buildChatTheme(BuildContext context) {
  final colors = context.colors;
  final fontFamily = GoogleFonts.ibmPlexSansArabic().fontFamily;

  return ChatTheme(
    colors: ChatColors(
      // Sent-message bubbles + accents.
      primary: colors.primary,
      // Dark, readable text/icons on the cyan primary (matches CustomButton).
      onPrimary: colors.contentBlack,
      // Chat background.
      surface: colors.background,
      onSurface: colors.textPrimary,
      // Received-message bubbles.
      surfaceContainer: colors.chatSecondary,
      surfaceContainerLow: colors.chatPrimary,
      surfaceContainerHigh: colors.cardBackGround,
    ),
    typography: ChatTypography.standard(fontFamily: fontFamily),
    shape: const BorderRadius.all(Radius.circular(14)),
  );
}
