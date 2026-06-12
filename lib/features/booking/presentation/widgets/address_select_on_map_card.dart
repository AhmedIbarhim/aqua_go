import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../address/data/models/address_model.dart';

class AddressSelectOnMapCard extends StatelessWidget {
  final bool isSelected;
  final AddressModel? selectedMapAddress;
  final VoidCallback onTap;

  const AddressSelectOnMapCard({
    super.key,
    required this.isSelected,
    required this.selectedMapAddress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final hasSelectedAddress = selectedMapAddress != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandHover
              : context.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppAssets.mapOutlined,
                  width: width * 0.06,
                  colorFilter: !isSelected
                      ? ColorFilter.mode(
                          context.colors.textSecondary,
                          BlendMode.srcIn,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.address_select_on_map.tr(),
                  style: AppTextStyles.regular16.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            if (hasSelectedAddress) ...[
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppAssets.location,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      context.colors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      selectedMapAddress!.details,
                      maxLines: 1,
                      style: AppTextStyles.regular14.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.015),
              SizedBox(
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AbsorbPointer(
                    child: GoogleMap(
                      key: ValueKey(
                        '${selectedMapAddress!.lat},${selectedMapAddress!.lng}',
                      ),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          selectedMapAddress!.lat,
                          selectedMapAddress!.lng,
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: LatLng(
                            selectedMapAddress!.lat,
                            selectedMapAddress!.lng,
                          ),
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
          ],
        ),
      ),
    );
  }
}
