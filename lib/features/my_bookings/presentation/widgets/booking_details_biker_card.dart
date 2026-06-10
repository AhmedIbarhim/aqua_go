import 'package:aqua_go/core/components/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/features/rating/presentation/widgets/rating_widget.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsBikerCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsBikerCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final worker = booking.assignedWorker;
    final String workerName =
        worker?.displayName ??
        (context.locale.languageCode == 'ar'
            ? 'بانتظار تعيين العامل'
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
        SizedBox(height: context.sh(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.sw(16),
            vertical: context.sh(16),
          ),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(context.sw(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: context.sw(40),
                height: context.sw(40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.sw(20)),
                  border: Border.all(color: context.colors.borderSecondary),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.sw(20)),
                  child: CustomNetworkImage(
                    worker?.avatarUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: context.sw(12)),
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
                      SizedBox(height: context.sh(4)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingWidget(
                            rating: rating,
                            starSize: context.sw(16),
                          ),
                          SizedBox(width: context.sw(4)),
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
