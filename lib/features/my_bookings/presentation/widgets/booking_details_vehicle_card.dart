import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/core/helpers/car_color_helper.dart';
import 'package:aqua_go/features/my_cars/presentation/widgets/car_make_logo_network_svg.dart';
import '../../data/models/booking_response_model.dart';

class BookingDetailsVehicleCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsVehicleCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Resolve Vehicle Make and Model
    String brandModelText =
        '${booking.vehicleMake ?? ""} ${booking.vehicleModel ?? ""}'.trim();
    if (brandModelText.isEmpty) {
      brandModelText = context.isAr ? 'مركبة غير محددة' : 'Unspecified Vehicle';
    }

    // Resolve Vehicle Color
    String colorName = '';
    Color? colorVisual;
    if (booking.vehicleColor != null && booking.vehicleColor!.isNotEmpty) {
      final colorStr = booking.vehicleColor!;
      if (colorStr.startsWith('#') || colorStr.toLowerCase().startsWith('0x')) {
        try {
          String cleanColor = colorStr
              .replaceAll('#', '')
              .replaceAll('0x', '')
              .replaceAll('0X', '');
          if (cleanColor.length == 6) {
            cleanColor = 'FF$cleanColor';
          }
          final colorVal = int.parse(cleanColor, radix: 16);
          colorVisual = Color(colorVal);
          colorName = getLocalizedColorName(colorVal);
        } catch (_) {
          colorName = colorStr;
        }
      } else {
        colorName = colorStr;
      }
    }

    // Resolve Plate Number
    final String plateText = booking.plateMasked ?? '';

    // Resolve Year
    final String yearText = booking.vehicleYear != null
        ? booking.vehicleYear.toString()
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
              SizedBox(
                width: 48,
                height: 48,
                child:
                    (booking.vehicleMakeLogoUrl != null &&
                        booking.vehicleMakeLogoUrl!.isNotEmpty)
                    ? CarMakeNetworkLogo(
                        logoUrl: booking.vehicleMakeLogoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      )
                    : SvgPicture.asset(
                        AppAssets.raceCar,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          context.colors.textPrimary.withValues(alpha: 0.3),
                          BlendMode.srcIn,
                        ),
                      ),
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
                        if (colorName.isNotEmpty) ...[
                          if (colorVisual != null) ...[
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colorVisual,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.colors.borderSecondary,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  colorName,
                                  style: AppTextStyles.regular12.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],

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
