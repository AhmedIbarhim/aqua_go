import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../data/models/gift_theme_model.dart';
import 'gift_theme_card.dart';

class GiftThemeCardsGrid extends StatelessWidget {
  final List<GiftThemeModel> themes;
  final GiftThemeModel? selectedTheme;
  final ValueChanged<GiftThemeModel> onThemeSelected;

  const GiftThemeCardsGrid({
    super.key,
    required this.themes,
    required this.selectedTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (MediaQuery.sizeOf(context).width - context.sw(48) - context.sw(12)) / 2;
    final double cardHeight = context.sh(100);
    final double childAspectRatio = cardWidth / cardHeight;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: context.sh(12),
        crossAxisSpacing: context.sw(12),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        return GiftThemeCard(
          theme: theme,
          isSelected: selectedTheme?.id == theme.id,
          onTap: () => onThemeSelected(theme),
        );
      },
    );
  }
}
