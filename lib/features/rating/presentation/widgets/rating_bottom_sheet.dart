import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../../../core/config/di/service_locator.dart';
import '../controllers/rating_cubit/rating_cubit.dart';
import '../controllers/rating_cubit/rating_state.dart';
import 'package:aqua_go/core/components/custom_text_field.dart';
import 'pay_tips_bottom_sheet.dart';
import 'rating_success_alert_box.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_bookings/presentation/views/my_booking_details_view.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';

class RatingBottomSheet extends StatefulWidget {
  final BookingResponseModel booking;
  final bool navigateOnSuccess;
  const RatingBottomSheet({
    super.key,
    required this.booking,
    this.navigateOnSuccess = true,
  });

  static Future<void> show(
    BuildContext context,
    BookingResponseModel booking, {
    bool navigateOnSuccess = true,
  }) {
    return CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.bookings_rate_service.tr(context: context),
      child: BlocProvider<RatingCubit>(
        create: (_) => locator<RatingCubit>(),
        child: RatingBottomSheet(
          booking: booking,
          navigateOnSuccess: navigateOnSuccess,
        ),
      ),
    );
  }

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _rating = 4;
  final List<String> _selectedReasons = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Re-evaluate the Submit gate live as the "Other reason" text changes.
    _commentController.addListener(_onCommentChanged);
  }

  void _onCommentChanged() {
    if (mounted) setState(() {});
  }

  // Block submission when "Other" is chosen on a low rating but no reason text
  // was entered — the backend rejects an empty Other reason as unparseable.
  bool get _otherReasonMissing =>
      _rating < 5 &&
      _selectedReasons.contains('OTHER') &&
      _commentController.text.trim().isEmpty;

  @override
  void dispose() {
    _commentController.removeListener(_onCommentChanged);
    _commentController.dispose();
    super.dispose();
  }

  final Map<String, String> _reasonsMap = {
    'DELIVERY_DELAY': LocaleKeys.bookings_rating_reasons_delivery_delay.tr(),
    'DAMAGE': LocaleKeys.bookings_rating_reasons_damage.tr(),
    'STAFF_BEHAVIOR': LocaleKeys.bookings_rating_reasons_staff_behavior.tr(),
    'POOR_QUALITY': LocaleKeys.bookings_rating_reasons_poor_quality.tr(),
    'OTHER': LocaleKeys.bookings_rating_reasons_other_reason.tr(),
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return BlocListener<RatingCubit, RatingState>(
      listener: (context, state) {
        if (state is RatingSubmitLoading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state is RatingSubmitSuccess) {
          Navigator.pop(context);
          RatingSuccessAlertBox.show(context).then((_) {
            if (!widget.navigateOnSuccess) return;
            AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              Routes.myBookingDetails,
              (route) => route.settings.name == Routes.layout || route.isFirst,
              arguments: MyBookingDetailsArgs(
                booking: BookingSummaryModel.fromDetails(widget.booking),
              ),
            );
          });
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
              LocaleKeys.bookings_share_opinion.tr(context: context),
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
          // _buildBikerInfo(),
          _buildPayTipButton(),

          if (_rating < 5) ...[
            SizedBox(height: height * 0.03),
            _buildRatingReasons(),
          ],
          SizedBox(height: height * 0.05),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomButton(
                  enabled: !_otherReasonMissing,
                  onPressed: () {
                    final reasons = _rating < 5
                        ? _selectedReasons.toList()
                        : null;
                    final comment =
                        _rating < 5 && _selectedReasons.contains('OTHER')
                        ? _commentController.text.trim()
                        : null;

                    context.read<RatingCubit>().submitRating(
                      bookingId: widget.booking.id ?? '',
                      score: _rating,
                      reasons: reasons,
                      comment: comment,
                    );
                  },
                  text: LocaleKeys.submit.tr(context: context),
                ),
              ),
              SizedBox(width: width * 0.02),

              Expanded(
                flex: 1,
                child: CustomButton(
                  onPressed: () => Navigator.pop(context),
                  text: LocaleKeys.cancel.tr(context: context),
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
    final width = MediaQuery.sizeOf(context).width;
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

  // Widget _buildBikerInfo() {
  //   final width = MediaQuery.sizeOf(context).width;
  //   final worker = widget.booking.assignedWorker;
  //   if (worker == null) {
  //     return const SizedBox.shrink();
  //   }
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         LocaleKeys.bookings_your_biker.tr(context: context),
  //         style: AppTextStyles.regular14.copyWith(
  //           color: context.colors.textPrimary,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         padding: EdgeInsets.all(width * 0.04),
  //         decoration: BoxDecoration(
  //           color: context.colors.cardBackGround,
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Row(
  //           children: [
  //             ClipRRect(
  //               borderRadius: BorderRadius.circular(width * 0.05),
  //               child: Container(
  //                 width: width * 0.1,
  //                 height: width * 0.1,
  //                 color: context.colors.borderSecondary,
  //                 child: CustomNetworkImage(
  //                   worker.avatarUrl ?? "",
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: width * 0.03),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   worker.displayName ??
  //                       (context.isEn ? "Service Provider" : "مقدم الخدمة"),
  //                   style: AppTextStyles.medium14.copyWith(
  //                     color: context.colors.textPrimary,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 RatingWidget(
  //                   rating: worker.ratingAggregate?.toDouble() ?? 0.0,
  //                   starSize: 16,
  //                   showRatingValue: true,
  //                   ratingTextStyle: AppTextStyles.regular12.copyWith(
  //                     color: context.colors.contentDisabled,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildRatingReasons() {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_rating_reason.tr(context: context),
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
                    if (reasonKey == 'OTHER') {
                      _commentController.clear();
                    }
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
        if (_selectedReasons.contains('OTHER')) ...[
          const SizedBox(height: 16),
          CustomTextField(
            label: LocaleKeys.bookings_rating_reasons_other_reason.tr(),
            hint: context.isEn
                ? "Write your reason here..."
                : "اكتب السبب هنا...",
            controller: _commentController,
            maxLines: 3,
            minLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildPayTipButton() {
    final width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: () {
        PayTipsBottomSheet.show(context, widget.booking);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.warning, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_outlined,
              color: context.colors.warning,
            ),
            SizedBox(width: width * 0.02),

            Text(
              context.isEn ? "Pay Tip For the Biker" : "دفع إكرامية للبايكر",
              style: AppTextStyles.regular16.copyWith(
                color: context.colors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
