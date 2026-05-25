import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../views/gallery_view.dart';
import '../../data/models/booking_response_model.dart';
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
    final List<String> imageUrls = (photos != null && photos!.isNotEmpty)
        ? photos!.map((p) => p.url ?? '').where((u) => u.isNotEmpty).toList()
        : const [
            'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?q=80&w=2070&auto=format&fit=crop', // Before
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=2070&auto=format&fit=crop', // After
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: LocaleKeys.bookings_car_images.tr(),
                style: AppTextStyles.regular16.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              TextSpan(
                text: ' (${LocaleKeys.bookings_before_and_after_washing.tr()})',
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
            children: List.generate(imageUrls.length.clamp(0, 2), (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 1 ? 12 : 0,
                    right: index == 0 && imageUrls.length > 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        Routes.gallery,
                        arguments: GalleryArgs(
                          images: imageUrls,
                          initialIndex: index,
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
