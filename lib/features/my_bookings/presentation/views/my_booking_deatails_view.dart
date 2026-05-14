import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/features/my_bookings/data/models/my_bookings_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../core/components/rating_widget.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../widgets/my_booking_procedures_bottom_sheet.dart';
import '../widgets/my_booking_photos_section.dart';
import '../widgets/my_booking_location_section.dart';

class MyBookingDetailsArgs {
  final MyBookingsModel booking;
  MyBookingDetailsArgs({required this.booking});
}

class MyBookingDetailsView extends StatelessWidget {
  final MyBookingsModel booking;

  const MyBookingDetailsView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.bookings_booking_details.tr(),
        actions: [
          if (!booking.isUpcoming)
            IconButton(
              onPressed: () =>
                  MyBookingProceduresBottomSheet.show(context, booking),
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBookingNumberSection(context),
                  const SizedBox(height: 16),
                  _buildCarSection(context),
                  const SizedBox(height: 16),
                  _buildBikerSection(context),
                  const SizedBox(height: 16),
                  _buildSummarySection(context),
                  const SizedBox(height: 16),
                  if (!booking.isUpcoming) _buildLocationSection(context),
                  const SizedBox(height: 16),
                  if (!booking.isUpcoming) const MyBookingPhotosSection(),
                  if (booking.isUpcoming)
                    MyBookingLocationSection(
                      address: booking.location,
                      latitude: booking.latitude,
                      longitude: booking.longitude,
                    ),
                  const SizedBox(height: 16),
                  _buildInvoicesLink(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (booking.isUpcoming) _buildActionSheet(context),
        ],
      ),
    );
  }

  Widget _buildBookingNumberSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_booking_number.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${booking.id}',
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.contentSecondaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.warning,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'منتهية',
                  style: AppTextStyles.regular12.copyWith(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_car.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                AppAssets.demoToyota,
                width: 45,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),

              Text(
                'تويوتا لاند كروزر', // Placeholder
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.contentSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBikerSection(BuildContext context) {
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
                backgroundImage: const AssetImage(
                  AppAssets.wavingHand,
                ), // Placeholder
                backgroundColor: context.colors.borderSecondary,
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'محمد محمود',
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingWidget(rating: 3.5, starSize: 16),
                      const SizedBox(width: 4),

                      Text(
                        '(3.5)',
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

  Widget _buildSummarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_booking_summary.tr(),
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
          child: Column(
            children: [
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_service_name.tr(),
                value: booking.title,
                icon: AppAssets.document,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_date_and_time.tr(),
                value: booking.formattedDateTime,
                icon: AppAssets.date,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_total_amount.tr(),
                value: '${booking.totalAmount.toStringAsFixed(2)} SAR',
                icon: AppAssets.currency,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required String value,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colors.contentDisabled,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.contentDisabled,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.contentSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_car_location.tr(),
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
              SvgPicture.asset(
                AppAssets.location,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  context.colors.contentDisabled,
                  BlendMode.srcIn,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  booking.location,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.contentSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesLink(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.themeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleKeys.bookings_go_to_invoice_list.tr(),
            style: AppTextStyles.medium14.copyWith(
              color: context.colors.primary,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: context.colors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSheet(BuildContext context) {
    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_edit_booking.tr(),

        postWidget: SvgPicture.asset(
          AppAssets.edit,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            darkAppColors.contentBlack,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
