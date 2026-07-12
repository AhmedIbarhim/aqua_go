import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/utils/app_assets.dart';

class PointsBalanceCard extends StatelessWidget {
  final int points;
  final double equivalentValue;
  final int earnRateRiyals;
  final int conversionPoints;
  final double conversionRiyals;

  const PointsBalanceCard({
    super.key,
    required this.points,
    required this.equivalentValue,
    required this.earnRateRiyals,
    required this.conversionPoints,
    required this.conversionRiyals,
  });

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);
    var height = MediaQuery.of(context).size.height;

    final locale = context.locale.toString();
    final pointsFormatted = NumberFormat('#,###', locale).format(points);
    final equivalentValueFormatted = NumberFormat(
      '0.##',
      locale,
    ).format(equivalentValue);

    // Currency labels based on locale
    final isAr = context.isAr;
    final currencyText = isAr ? 'ريال' : 'SAR';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: رصيد النقاط
        Text(
          LocaleKeys.wallet_points_balance.tr(context: context),
          style: AppTextStyles.semiBold18.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: sh(16)),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colors.brandSubtle.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(sw(20)),
            border: Border.all(color: context.colors.defaultSubtle, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,

                child: Image.asset(
                  AppAssets.shadows_1,
                  fit: BoxFit.cover,
                  color: context.colors.primary,
                  width: height * 0.25,
                  height: height * 0.2,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  AppAssets.shadows_2,
                  color: context.colors.primary,
                  width: height * 0.2,
                  height: height * 0.35,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sw(8),
                  vertical: sh(8),
                ),
                child: Column(
                  children: [
                    // Points counter
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.brandSubtle.withValues(
                          alpha: 0.67,
                        ),
                        borderRadius: BorderRadius.circular(sw(20)),
                        border: Border.all(
                          color: context.colors.defaultSubtle,
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: sh(8)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  pointsFormatted,
                                  style: AppTextStyles.semiBold32.copyWith(
                                    fontSize: sw(36),
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: sw(6)),
                                Text(
                                  LocaleKeys.wallet_points.tr(context: context),
                                  style: AppTextStyles.regular16.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sh(4)),

                            // Equivalent Cash Value: ≈ 12.5 ريال
                            Text(
                              '≈ $equivalentValueFormatted $currencyText',
                              style: AppTextStyles.medium16.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: sh(16)),

                            // Info Row: تكسب نقطة لكل 10 ريال يتم إنفاقها
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: context.colors.textSecondary,
                                  size: sw(16),
                                ),
                                SizedBox(width: sw(6)),
                                Flexible(
                                  child: Text(
                                    LocaleKeys.wallet_earn_rule.tr(
                                      context: context,
                                      args: [earnRateRiyals.toString()],
                                    ),
                                    style: AppTextStyles.regular12.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: sh(20)),

                    // Cyan Discount Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(sw(12)),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: sw(16),
                        vertical: sh(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(AppAssets.points),
                          SizedBox(width: sw(12)),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.wallet_conversion_rule.tr(
                                    context: context,
                                    args: [
                                      conversionPoints.toString(),
                                      conversionRiyals.toStringAsFixed(0),
                                    ],
                                  ),
                                  style: AppTextStyles.bold16.copyWith(
                                    color: Colors.black,
                                    fontSize: sw(15),
                                  ),
                                ),
                                SizedBox(height: sh(4)),
                                Text(
                                  LocaleKeys.wallet_conversion_subtext.tr(
                                    context: context,
                                  ),
                                  style: AppTextStyles.regular12.copyWith(
                                    color: Colors.black,
                                    fontSize: sw(11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
