import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../controllers/booking_cubit.dart';

class ServicesLoadErrorWidget extends StatelessWidget {
  final double width;

  const ServicesLoadErrorWidget({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.bookings_services_load_failed.tr(context: context),
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () {
                context.read<BookingCubit>().retryPackageServices();
              },
              child: Text(
                LocaleKeys.retry.tr(context: context),
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
