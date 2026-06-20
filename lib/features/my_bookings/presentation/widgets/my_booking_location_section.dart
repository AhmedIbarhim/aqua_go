import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:svg_flutter/svg.dart';

class MyBookingLocationSection extends StatelessWidget {
  final String address;
  final double latitude;
  final double longitude;

  /// Optional arrival/access notes the customer left for the worker.
  final String? arrivalNotes;

  const MyBookingLocationSection({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.arrivalNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_car_location.tr(context: context),
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
              Row(
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
                      address,
                      style: AppTextStyles.regular14.copyWith(
                        color: context.colors.contentSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (arrivalNotes != null && arrivalNotes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppAssets.note,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        context.colors.contentDisabled,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.address_access_notes_label.tr(context: context),
                            style: AppTextStyles.regular12.copyWith(
                              color: context.colors.contentDisabled,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            arrivalNotes!.trim(),
                            style: AppTextStyles.regular14.copyWith(
                              color: context.colors.contentSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AbsorbPointer(
                    child: GoogleMap(
                      key: ValueKey('$latitude,$longitude'),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('car_location'),
                          position: LatLng(latitude, longitude),
                        ),
                      },
                      liteModeEnabled: true,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
