import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/features/rating/presentation/widgets/rating_widget.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsRatingCard extends StatelessWidget {
  final BookingRatingModel rating;

  const BookingDetailsRatingCard({super.key, required this.rating});

  Map<String, String> get _reasonsMap => {
    'DELIVERY_DELAY': LocaleKeys.bookings_rating_reasons_delivery_delay.tr(),
    'DAMAGE': LocaleKeys.bookings_rating_reasons_damage.tr(),
    'STAFF_BEHAVIOR': LocaleKeys.bookings_rating_reasons_staff_behavior.tr(),
    'POOR_QUALITY': LocaleKeys.bookings_rating_reasons_poor_quality.tr(),
    'OTHER_REASON': LocaleKeys.bookings_rating_reasons_other_reason.tr(),
  };

  String _readableReason(String reason) {
    return _reasonsMap[reason] ??
        reason
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
            )
            .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final reasons = rating.reasons ?? const <String>[];
    final notes = rating.notes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_your_rating.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingWidget(
                rating: (rating.score ?? 0).toDouble(),
                starSize: 24,
              ),
              if (reasons.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: width * 0.02,
                  runSpacing: width * 0.02,
                  children: reasons.map((reason) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: width * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.themeColor,
                        border: Border.all(
                          color: context.colors.borderSecondary,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _readableReason(reason),
                        style: AppTextStyles.regular14.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (notes != null && notes.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.bookings_rating_notes.tr(),
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.contentDisabled,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.contentSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
