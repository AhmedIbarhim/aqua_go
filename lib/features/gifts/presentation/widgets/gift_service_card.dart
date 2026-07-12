import 'package:flutter/material.dart';
import '../../../../core/components/custom_radio_widget.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../home/data/models/service_model.dart';

class GiftServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final VoidCallback onTap;

  const GiftServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = context.isAr
        ? (service.rawName?.nameAr ?? '')
        : (service.rawName?.nameEn ?? '');
    final description = context.isAr
        ? (service.rawDescription?.descAr ?? '')
        : (service.rawDescription?.descEn ?? '');
    final priceStr = service.price;
    final currency = context.isAr ? 'ر.س' : 'SAR';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(16),
          vertical: context.sh(16),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandHover.withValues(alpha: 0.15)
              : context.colors.cardBackGround,
          borderRadius: BorderRadius.circular(context.sw(12)),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: context.sw(250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bold16.copyWith(
                      fontSize: context.sw(14),
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: context.sh(4)),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular12.copyWith(
                        fontSize: context.sw(12),
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: context.sh(4)),
                  Row(
                    children: [
                      Text(
                        "$priceStr $currency",
                        style: AppTextStyles.bold13.copyWith(
                          fontSize: context.sw(14),
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            CustomRadioWidget(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
