import 'package:aqua_go/features/rating/presentation/widgets/rating_widget.dart';
import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../controllers/rating_cubit/rating_cubit.dart';
import '../../controllers/rating_cubit/rating_state.dart';
import '../../../../core/components/custom_network_image.dart';
import 'rating_success_alert_box.dart';

class RatingBottomSheet extends StatefulWidget {
  final BookingResponseModel booking;
  const RatingBottomSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingResponseModel booking) {
    return CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.bookings_rate_service.tr(),
      child: BlocProvider<RatingCubit>(
        create: (_) => locator<RatingCubit>(),
        child: RatingBottomSheet(booking: booking),
      ),
    );
  }

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _rating = 4;
  final List<String> _selectedReasons = [];

  final Map<String, String> _reasonsMap = {
    'DELIVERY_DELAY': LocaleKeys.bookings_rating_reasons_delivery_delay.tr(),
    'DAMAGE': LocaleKeys.bookings_rating_reasons_damage.tr(),
    'STAFF_BEHAVIOR': LocaleKeys.bookings_rating_reasons_staff_behavior.tr(),
    'POOR_QUALITY': LocaleKeys.bookings_rating_reasons_poor_quality.tr(),
    'OTHER_REASON': LocaleKeys.bookings_rating_reasons_other_reason.tr(),
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return BlocListener<RatingCubit, RatingState>(
      listener: (context, state) {
        if (state is RatingSubmitLoading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state is RatingSubmitSuccess) {
          Navigator.pop(context);
          RatingSuccessAlertBox.show(context);
        } else if (state is RatingSubmitFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Column(
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
                    context.read<RatingCubit>().submitRating(
                          bookingId: widget.booking.id ?? '',
                          score: _rating,
                          reasons: _rating < 5 ? _selectedReasons : null,
                        );
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
      ),
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
    if (_rating == 5) {
      return context.isEn ? "Excellent Rating" : "تقييم ممتاز";
    }
    if (_rating == 4) {
      return context.isEn ? "Very Good Rating" : "تقييم جيد جداً";
    }
    if (_rating == 3) {
      return context.isEn ? "Good Rating" : "تقييم جيد";
    }
    if (_rating == 2) {
      return context.isEn ? "Acceptable Rating" : "تقييم مقبول";
    }
    return context.isEn ? "Poor Rating" : "تقييم ضعيف";
  }

  Widget _buildBikerInfo() {
    final width = MediaQuery.of(context).size.width;
    final worker = widget.booking.assignedWorker;
    if (worker == null) {
      return const SizedBox.shrink();
    }
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
              ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.05),
                child: Container(
                  width: width * 0.1,
                  height: width * 0.1,
                  color: context.colors.borderSecondary,
                  child: worker.avatarUrl != null && worker.avatarUrl!.isNotEmpty
                      ? CustomNetworkImage(
                          worker.avatarUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          AppAssets.wavingHand,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: width * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.displayName ?? (context.isEn ? "Service Provider" : "مقدم الخدمة"),
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingWidget(
                        rating: worker.ratingAggregate?.toDouble() ?? 0.0,
                        starSize: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${worker.ratingAggregate?.toDouble() ?? 0.0})",
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
          children: _reasonsMap.entries.map((entry) {
            final reasonKey = entry.key;
            final reasonLabel = entry.value;
            final isSelected = _selectedReasons.contains(reasonKey);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedReasons.remove(reasonKey);
                  } else {
                    _selectedReasons.add(reasonKey);
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
                  reasonLabel,
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
