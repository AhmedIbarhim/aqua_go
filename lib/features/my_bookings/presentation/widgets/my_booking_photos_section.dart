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

  @override
  Widget build(BuildContext context) {
    final allPhotos =
        photos?.where((p) => p.url != null && p.url!.isNotEmpty).toList() ?? [];

    final beforeIndex = allPhotos.indexWhere(
      (p) =>
          p.stage?.toUpperCase() == 'BEFORE' &&
          p.angle?.toUpperCase() == 'FRONT',
    );
    Photos? beforePhotoItem;
    if (beforeIndex != -1) {
      beforePhotoItem = allPhotos.removeAt(beforeIndex);
    }

    final afterIndex = allPhotos.indexWhere(
      (p) =>
          p.stage?.toUpperCase() == 'AFTER' &&
          p.angle?.toUpperCase() == 'FRONT',
    );
    Photos? afterPhotoItem;
    if (afterIndex != -1) {
      afterPhotoItem = allPhotos.removeAt(afterIndex);
    }

    if (afterPhotoItem != null) {
      allPhotos.insert(0, afterPhotoItem);
    }
    if (beforePhotoItem != null) {
      allPhotos.insert(0, beforePhotoItem);
    }

    final List<String> imageUrls = [
      beforePhotoItem?.url ?? '',
      afterPhotoItem?.url ?? '',
    ];

    final allImageUrls = allPhotos.map((p) => p.url!).toList();
    final allLabels = allPhotos.map((p) {
      final stage = p.stage?.toUpperCase();
      final angle = p.angle?.toUpperCase();

      String stageLabel = '';
      if (stage == 'BEFORE') {
        stageLabel = LocaleKeys.bookings_before_washing.tr(context: context);
      } else if (stage == 'AFTER') {
        stageLabel = LocaleKeys.bookings_after_washing.tr(context: context);
      } else {
        stageLabel = p.stage ?? '';
      }

      if (angle != null && angle.isNotEmpty) {
        final String? translatedAngle;
        final normalizedAngle = angle
            .toLowerCase()
            .replaceAll('-', '_')
            .replaceAll(' ', '_');
        switch (normalizedAngle) {
          case 'front':
            translatedAngle = null;

            // LocaleKeys.bookings_angles_front.tr(
            //   context: context,
            // );
            break;
          case 'back':
            translatedAngle = null;

            // LocaleKeys.bookings_angles_back.tr(
            //   context: context,
            // );
            break;
          // case 'left':
          //   translatedAngle = LocaleKeys.bookings_angles_left.tr(
          //     context: context,
          //   );
          //   break;
          // case 'right':
          //   translatedAngle = LocaleKeys.bookings_angles_right.tr(
          //     context: context,
          //   );
          //   break;
          case 'front_right':
            translatedAngle = LocaleKeys.bookings_angles_front_right.tr(
              context: context,
            );
            break;
          case 'front_left':
            translatedAngle = LocaleKeys.bookings_angles_front_left.tr(
              context: context,
            );
            break;
          case 'back_right':
            translatedAngle = LocaleKeys.bookings_angles_back_right.tr(
              context: context,
            );
            break;
          case 'back_left':
            translatedAngle = LocaleKeys.bookings_angles_back_left.tr(
              context: context,
            );
            break;
          case 'left_front':
            translatedAngle = LocaleKeys.bookings_angles_left_front.tr(
              context: context,
            );
            break;
          case 'left_back':
            translatedAngle = LocaleKeys.bookings_angles_left_back.tr(
              context: context,
            );
            break;
          case 'right_front':
            translatedAngle = LocaleKeys.bookings_angles_right_front.tr(
              context: context,
            );
            break;
          case 'right_back':
            translatedAngle = LocaleKeys.bookings_angles_right_back.tr(
              context: context,
            );
            break;
          // case 'roof':
          //   translatedAngle = LocaleKeys.bookings_angles_roof.tr(
          //     context: context,
          //   );
          //   break;
          // case 'interior':
          //   translatedAngle = LocaleKeys.bookings_angles_interior.tr(
          //     context: context,
          //   );
          // break;
          default:
            translatedAngle = p.angle ?? '';
        }
        return translatedAngle == null
            ? stageLabel
            : '$stageLabel ($translatedAngle)';
      }
      return stageLabel;
    }).toList();

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
                  child: GestureDetector(
                    onTap: () {
                      final targetUrl = imageUrls[index];
                      if (targetUrl.isEmpty) return;

                      final galleryInitialIndex = allImageUrls.indexOf(
                        targetUrl,
                      );

                      context.pushNamed(
                        Routes.gallery,
                        arguments: GalleryArgs(
                          images: allImageUrls,
                          initialIndex: galleryInitialIndex != -1
                              ? galleryInitialIndex
                              : 0,
                          labels: allLabels,
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
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
