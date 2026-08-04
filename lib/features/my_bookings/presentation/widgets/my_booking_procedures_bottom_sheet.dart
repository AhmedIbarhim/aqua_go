import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../complaints/presentation/views/complaint_view.dart';

import '../../../rating/presentation/widgets/pay_tips_bottom_sheet.dart';
import '../../../rating/presentation/widgets/rating_bottom_sheet.dart';

class MyBookingProceduresBottomSheet extends StatelessWidget {
  final BookingResponseModel booking;
  const MyBookingProceduresBottomSheet({super.key, required this.booking});

  static void show(BuildContext context, BookingResponseModel booking) {
    CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.bookings_booking_procedures.tr(context: context),
      child: MyBookingProceduresBottomSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionItem(
          context,
          title: LocaleKeys.bookings_rate_service.tr(context: context),
          onTap: booking.rating == null
              ? () {
                  Navigator.pop(context);
                  RatingBottomSheet.show(context, booking);
                }
              : null,
        ),
        SizedBox(height: height * 0.015),

        _buildActionItem(
          context,
          title: LocaleKeys.bookings_pay_tip_for_biker.tr(context: context),
          // UC-C19 — `canTip` is the server's decision (COMPLETED, not already
          // tipped, and still inside the admin-configurable tip window measured
          // from completedAt). Gating on tipPaid alone kept offering the row on
          // long-finished bookings the tip endpoint rejects. Kept VISIBLE but
          // disabled, like the rate/complaint rows above and below it — this menu
          // lists what the booking supports, so a row vanishing would read as a
          // missing feature rather than an expired one.
          onTap: booking.canTip
              ? () {
                  Navigator.pop(context);
                  PayTipsBottomSheet.show(context, booking);
                }
              : null,
        ),
        SizedBox(height: height * 0.015),
        _buildActionItem(
          context,
          title: LocaleKeys.bookings_submit_complaint.tr(context: context),
          onTap: booking.complaintId == null
              ? () {
                  Navigator.pop(context);
                  context.pushNamed(
                    Routes.complain,
                    arguments: ComplaintArgs(booking: booking),
                  );
                }
              : null,
        ),
        SizedBox(height: height * 0.04),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required VoidCallback? onTap,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.04,
        ),
        decoration: BoxDecoration(
          color: context.colors.defaultSubtle,
          border: Border.all(color: context.colors.borderSecondary, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: AppTextStyles.regular16.copyWith(
            color: onTap != null
                ? context.colors.textPrimary
                : context.colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
