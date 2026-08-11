import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extentions/context_extentions.dart';

ChatTheme buildChatTheme(BuildContext context) {
  final colors = context.colors;
  final fontFamily = GoogleFonts.ibmPlexSansArabic().fontFamily;

  return ChatTheme(
    colors: ChatColors(
      primary: colors.primary,
      onPrimary: colors.contentBlack,
      surface: colors.background,
      onSurface: colors.textPrimary,
      surfaceContainer: colors.chatSecondary,
      surfaceContainerLow: colors.chatPrimary,
      surfaceContainerHigh: colors.cardBackGround,
    ),
    typography: ChatTypography.standard(fontFamily: fontFamily),
    shape: const BorderRadius.all(Radius.circular(14)),
  );
}
