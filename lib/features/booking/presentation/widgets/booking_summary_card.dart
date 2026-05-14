import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class BookingSummaryCard extends StatelessWidget {
  final String serviceName;
  final String carName;
  final String location;
  final String dateTime;

  const BookingSummaryCard({
    super.key,
    required this.serviceName,
    required this.carName,
    required this.location,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            label: LocaleKeys.bookings_service_name.tr(),
            value: serviceName,
            icon: AppAssets.document,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            label: LocaleKeys.bookings_selected_car.tr(),
            value: carName,
            icon: AppAssets.myCarsDisabled,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            label: LocaleKeys.bookings_car_location.tr(),
            value: location,
            icon: AppAssets.location,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            label: LocaleKeys.bookings_date_and_time.tr(),
            value: dateTime,
            icon: AppAssets.date,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),

            Text(
              label,
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.regular12.copyWith(
            color: context.colors.contentSecondaryLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
