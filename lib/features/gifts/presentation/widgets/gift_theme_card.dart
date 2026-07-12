import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/gift_theme_model.dart';

class GiftThemeCard extends StatelessWidget {
  final GiftThemeModel theme;
  final bool isSelected;
  final VoidCallback onTap;

  const GiftThemeCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getThemeIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('تهن') || lower.contains('congrat')) {
      return Icons.emoji_events_outlined;
    } else if (lower.contains('شكر') || lower.contains('thank')) {
      return Icons.favorite_border;
    } else if (lower.contains('ميلاد') || lower.contains('birth')) {
      return Icons.cake_outlined;
    } else {
      return Icons.card_giftcard_outlined;
    }
  }

  Color _getThemeBg(String name, bool isSelected, BuildContext context) {
    if (!isSelected) return context.colors.cardBackGround;
    final lower = name.toLowerCase();
    if (lower.contains('تهن') || lower.contains('congrat')) {
      return const Color(0xFF1E2A38); // dark blue/teal tint
    } else if (lower.contains('شكر') || lower.contains('thank')) {
      return const Color(0xFF2C1A1A); // dark red/brown tint
    } else if (lower.contains('ميلاد') || lower.contains('birth')) {
      return const Color(0xFF2A1B2D); // dark purple/pink tint
    } else {
      return const Color(0xFF222222); // dark grey tint
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = context.isAr ? (theme.nameAr ?? '') : (theme.nameEn ?? '');
    final iconData = _getThemeIcon(name);
    final cardBg = _getThemeBg(name, isSelected, context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.sh(100),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(context.sw(16)),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: context.sw(28),
              color: isSelected
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
            SizedBox(height: context.sh(8)),
            Text(
              name,
              style: AppTextStyles.medium14.copyWith(
                fontSize: context.sw(14),
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
