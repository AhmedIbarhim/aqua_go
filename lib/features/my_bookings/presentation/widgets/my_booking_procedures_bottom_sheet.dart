import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/features/my_bookings/data/models/my_bookings_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../views/complain_view.dart';

import 'rating_bottom_sheet.dart';

class MyBookingProceduresBottomSheet extends StatelessWidget {
  final MyBookingsModel booking;
  const MyBookingProceduresBottomSheet({super.key, required this.booking});

  static void show(BuildContext context, MyBookingsModel booking) {
    CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.bookings_booking_procedures.tr(),
      child: MyBookingProceduresBottomSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionItem(
          context,
          title: LocaleKeys.bookings_rate_service.tr(),
          onTap: () {
            Navigator.pop(context);
            RatingBottomSheet.show(context);
          },
        ),
        SizedBox(height: height * 0.015),
        _buildActionItem(
          context,
          title: LocaleKeys.bookings_submit_complaint.tr(),
          onTap: () {
            context.pushNamed(
              Routes.complain,
              arguments: ComplainArgs(booking: booking),
            );
          },
        ),
        SizedBox(height: height * 0.04),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
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
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
