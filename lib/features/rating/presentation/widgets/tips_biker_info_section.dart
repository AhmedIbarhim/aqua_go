import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/components/custom_network_image.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/assigned_worker.dart';
import 'package:aqua_go/features/rating/presentation/widgets/rating_widget.dart';

class TipsBikerInfoSection extends StatelessWidget {
  final AssignedWorker? worker;
  const TipsBikerInfoSection({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    if (worker == null) {
      return const SizedBox.shrink();
    }
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_wash_biker.tr(context: context),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.05),
                child: Container(
                  width: width * 0.1,
                  height: width * 0.1,
                  color: context.colors.borderSecondary,
                  child: CustomNetworkImage(
                    worker!.avatarUrl ?? "",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: width * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker!.displayName ??
                        LocaleKeys.bookings_worker_name.tr(context: context),
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RatingWidget(
                    rating: worker!.ratingAggregate?.toDouble() ?? 0.0,
                    starSize: 16,
                    showRatingValue: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
