import 'package:aqua_go/core/components/custom_network_image.dart';
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

  Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    try {
      String cleanColor = hexColor
          .replaceAll('#', '')
          .replaceAll('0x', '')
          .replaceAll('0X', '');
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor';
      }
      return Color(int.parse(cleanColor, radix: 16));
    } catch (_) {
      return null;
    }
  }

  Color _getThemeBg(String name, bool isSelected, BuildContext context) {
    final themeColor = _parseColor(theme.color);

    return themeColor!.withValues(alpha: isSelected ? 0.3 : 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final name = context.isAr ? (theme.nameAr ?? '') : (theme.nameEn ?? '');
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
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: CustomNetworkImage(
                theme.imageUrl!,
                width: context.sw(28),
                height: context.sw(28),
                errorWidget: Icon(Icons.card_giftcard, size: context.sw(28)),
              ),
            ),
            SizedBox(height: context.sh(8)),
            Text(
              name,
              style: AppTextStyles.bold13.copyWith(
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
