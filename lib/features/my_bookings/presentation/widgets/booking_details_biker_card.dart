import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/core/components/rating_widget.dart';
import '../../data/models/booking_response_model.dart';

class BookingDetailsBikerCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsBikerCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final worker = booking.assignedWorker;
    final String workerName =
        worker?.displayName ??
        (context.locale.languageCode == 'ar'
            ? 'بانتظار تعيين السائق'
            : 'Awaiting Biker Assignment');

    final double rating = worker?.ratingAggregate != null
        ? (worker!.ratingAggregate! > 5
              ? worker.ratingAggregate! / 10.0
              : worker.ratingAggregate!.toDouble())
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_your_biker.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: const AssetImage(AppAssets.wavingHand),
                backgroundColor: context.colors.borderSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workerName,
                      style: AppTextStyles.medium14.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (worker != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingWidget(rating: rating, starSize: 16),
                          const SizedBox(width: 4),
                          Text(
                            '($rating)',
                            style: AppTextStyles.regular12.copyWith(
                              color: context.colors.contentDisabled,
                            ),
                          ),
                        ],
                      ),
                    ],
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
