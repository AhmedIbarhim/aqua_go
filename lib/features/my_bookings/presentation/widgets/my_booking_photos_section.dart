import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../views/gallery_view.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';
import '../../../../core/components/custom_network_image.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';

class MyBookingPhotosSection extends StatelessWidget {
  final List<Photos>? photos;

  const MyBookingPhotosSection({super.key, this.photos});

  /// Builds the localized "stage (angle)" label for a single photo.
  String _label(BuildContext context, Photos p) {
    final stage = p.stage?.toUpperCase();
    final angle = p.angle?.toUpperCase();

    String stageLabel;
    if (stage == 'BEFORE') {
      stageLabel = LocaleKeys.bookings_before_washing.tr(context: context);
    } else if (stage == 'AFTER') {
      stageLabel = LocaleKeys.bookings_after_washing.tr(context: context);
    } else {
      stageLabel = p.stage ?? '';
    }

    if (angle == null || angle.isEmpty) return stageLabel;

    final normalizedAngle =
        angle.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    String? translatedAngle;
    switch (normalizedAngle) {
      case 'front':
      case 'back':
        translatedAngle = null;
        break;
      case 'front_right':
        translatedAngle =
            LocaleKeys.bookings_angles_front_right.tr(context: context);
        break;
      case 'front_left':
        translatedAngle =
            LocaleKeys.bookings_angles_front_left.tr(context: context);
        break;
      case 'back_right':
        translatedAngle =
            LocaleKeys.bookings_angles_back_right.tr(context: context);
        break;
      case 'back_left':
        translatedAngle =
            LocaleKeys.bookings_angles_back_left.tr(context: context);
        break;
      case 'left_front':
        translatedAngle =
            LocaleKeys.bookings_angles_left_front.tr(context: context);
        break;
      case 'left_back':
        translatedAngle =
            LocaleKeys.bookings_angles_left_back.tr(context: context);
        break;
      case 'right_front':
        translatedAngle =
            LocaleKeys.bookings_angles_right_front.tr(context: context);
        break;
      case 'right_back':
        translatedAngle =
            LocaleKeys.bookings_angles_right_back.tr(context: context);
        break;
      default:
        translatedAngle = p.angle ?? '';
    }
    return translatedAngle == null
        ? stageLabel
        : '$stageLabel ($translatedAngle)';
  }

  /// Photos for one stage (BEFORE/AFTER), FRONT angle first.
  List<Photos> _stagePhotos(List<Photos> all, String stage) {
    final list = all.where((p) => p.stage?.toUpperCase() == stage).toList();
    final frontIdx = list.indexWhere((p) => p.angle?.toUpperCase() == 'FRONT');
    if (frontIdx > 0) {
      list.insert(0, list.removeAt(frontIdx));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final allPhotos =
        photos?.where((p) => p.url != null && p.url!.isNotEmpty).toList() ?? [];

    final beforeList = _stagePhotos(allPhotos, 'BEFORE');
    final afterList = _stagePhotos(allPhotos, 'AFTER');

    // The two preview tiles: the FRONT photo of each stage (first in each list).
    final List<String> imageUrls = [
      beforeList.isNotEmpty ? beforeList.first.url ?? '' : '',
      afterList.isNotEmpty ? afterList.first.url ?? '' : '',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: LocaleKeys.bookings_car_images.tr(context: context),
                style: AppTextStyles.regular16.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              TextSpan(
                text:
                    ' (${LocaleKeys.bookings_before_and_after_washing.tr(context: context)})',
                style: AppTextStyles.regular12.copyWith(
                  color: context.colors.contentDisabled,
                ),
              ),
            ],
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
            spacing: 12,
            children: List.generate(imageUrls.length.clamp(0, 2), (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 1 ? 12 : 0,
                    right: index == 0 && imageUrls.length > 1 ? 12 : 0,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final targetUrl = imageUrls[index];
                          if (targetUrl.isEmpty) return;

                          // BEFORE tile (0) opens a gallery of ONLY the before
                          // photos; AFTER tile (1) only the after photos.
                          final stageList =
                              index == 0 ? beforeList : afterList;
                          final stageUrls =
                              stageList.map((p) => p.url!).toList();
                          final stageLabels = stageList
                              .map((p) => _label(context, p))
                              .toList();
                          final initial = stageUrls.indexOf(targetUrl);

                          context.pushNamed(
                            Routes.gallery,
                            arguments: GalleryArgs(
                              images: stageUrls,
                              initialIndex: initial != -1 ? initial : 0,
                              labels: stageLabels,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: CustomNetworkImage(imageUrls[index]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        index == 0
                            ? LocaleKeys.bookings_before_washing.tr(
                                context: context,
                              )
                            : LocaleKeys.bookings_after_washing.tr(
                                context: context,
                              ),
                        style: AppTextStyles.regular12.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
