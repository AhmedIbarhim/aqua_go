import 'package:aqua_go/core/components/car_color_indicator.dart';
import 'package:aqua_go/core/components/vehicle_make_logo.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsVehicleCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsVehicleCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final vehicle = booking.vehicles?.isNotEmpty == true
        ? booking.vehicles!.first
        : null;

    // Resolve Vehicle Make and Model
    String brandModelText =
        '${vehicle?.vehicleMake ?? ""} ${vehicle?.vehicleModel ?? ""}'.trim();
    if (brandModelText.isEmpty) {
      brandModelText = '...';
    }

    // Resolve Vehicle Color
    final vehicleColor = vehicle?.vehicleColor;
    final bool hasColor = vehicleColor != null && vehicleColor.isNotEmpty;

    // Resolve Plate Number
    final String plateText = vehicle?.plate ?? booking.plate ?? '';

    // Resolve Year
    final String yearText = vehicle?.vehicleYear != null
        ? vehicle!.vehicleYear.toString()
        : '';

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VehicleMakeLogo(
                logoUrl: vehicle?.makeLogoUrl,
                colorEditable: vehicle?.colorEditable ?? false,
                size: 48,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandModelText,
                      style: AppTextStyles.medium16.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (yearText.isNotEmpty) ...[
                          Text(
                            yearText,
                            style: AppTextStyles.regular12.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (hasColor) ...[
                          CarColorIndicator(colorValue: vehicleColor),
                          const SizedBox(width: 12),
                        ],
                        if (plateText.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.background,
                              border: Border.all(
                                color: context.colors.borderSecondary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              plateText,
                              style: AppTextStyles.regular12.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
