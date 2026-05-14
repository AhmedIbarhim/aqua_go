import 'package:aqua_go/core/components/rating_widget.dart';
import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../generated/locale_keys.g.dart';
import 'rating_success_alert_box.dart';

class RatingBottomSheet extends StatefulWidget {
  const RatingBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.bookings_rate_service.tr(),
      child: const RatingBottomSheet(),
    );
  }

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _rating = 4;
  final List<String> _selectedReasons = [];

  final List<String> _reasons = [
    LocaleKeys.bookings_rating_reasons_delivery_delay.tr(),
    LocaleKeys.bookings_rating_reasons_damage.tr(),
    LocaleKeys.bookings_rating_reasons_staff_behavior.tr(),
    LocaleKeys.bookings_rating_reasons_poor_quality.tr(),
    LocaleKeys.bookings_rating_reasons_other_reason.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Text(
            LocaleKeys.bookings_share_opinion.tr(),
            style: AppTextStyles.regular20.copyWith(
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: height * 0.02),
        _buildRatingStars(),
        SizedBox(height: height * 0.01),
        Center(
          child: Text(
            _getRatingText(),
            style: AppTextStyles.medium14.copyWith(
              color: context.colors.contentSecondaryLight,
            ),
          ),
        ),
        SizedBox(height: height * 0.03),
        _buildBikerInfo(),

        if (_rating < 5) ...[
          SizedBox(height: height * 0.03),
          _buildRatingReasons(),
        ],
        SizedBox(height: height * 0.04),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton(
                onPressed: () {
                  // TODO: Handle rating submission
                  Navigator.pop(context);
                  RatingSuccessAlertBox.show(context);
                },
                text: LocaleKeys.submit.tr(),
              ),
            ),
            SizedBox(width: width * 0.02),

            Expanded(
              flex: 1,
              child: CustomButton(
                onPressed: () => Navigator.pop(context),
                text: LocaleKeys.cancel.tr(),
                color: Colors.transparent,
                textColor: context.colors.primary,
                borderColor: context.colors.borderSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.02),
      ],
    );
  }

  Widget _buildRatingStars() {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.01),
            child: Icon(
              index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: index < _rating
                  ? context.colors.warning
                  : context.colors.contentDisabled,
              size: width * 0.1,
            ),
          ),
        );
      }),
    );
  }

  String _getRatingText() {
    if (_rating == 5) return context.isEn ? "Excellent Rating" : "تقييم ممتاز";
    if (_rating == 4)
      return context.isEn ? "Very Good Rating" : "تقييم جيد جداً";
    if (_rating == 3) return context.isEn ? "Good Rating" : "تقييم جيد";
    if (_rating == 2) return context.isEn ? "Acceptable Rating" : "تقييم مقبول";
    return context.isEn ? "Poor Rating" : "تقييم ضعيف";
  }

  Widget _buildBikerInfo() {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_your_biker.tr(),
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: width * 0.05,
                backgroundImage: const AssetImage(
                  AppAssets.wavingHand,
                ), // Placeholder
                backgroundColor: context.colors.borderSecondary,
              ),
              SizedBox(width: width * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "محمد محمود",
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingWidget(rating: 4.0, starSize: 16),
                      const SizedBox(width: 4),
                      Text(
                        "(4.0)",
                        style: AppTextStyles.regular12.copyWith(
                          color: context.colors.contentDisabled,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingReasons() {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_rating_reason.tr(),
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: width * 0.02,
          runSpacing: width * 0.02,
          children: _reasons.map((reason) {
            final isSelected = _selectedReasons.contains(reason);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedReasons.remove(reason);
                  } else {
                    _selectedReasons.add(reason);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: width * 0.03,
                ),
                decoration: BoxDecoration(
                  color: context.colors.themeColor,
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.borderSecondary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reason,
                  style: AppTextStyles.regular14.copyWith(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
