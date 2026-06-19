import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_network_image.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bookings/presentation/views/gallery_view.dart';
import '../../data/models/complaint_model.dart';

class ComplaintDetailsPhotosCard extends StatelessWidget {
  final List<ComplaintPhoto> photos;

  const ComplaintDetailsPhotosCard({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    double sh(double height) =>
        (height / 896) * MediaQuery.sizeOf(context).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_car_images.tr(),
          style: AppTextStyles.medium14,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: sh(110),
          child: Center(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: photos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final imageUrl = photos[index].url;
                return GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      Routes.gallery,
                      arguments: GalleryArgs(
                        images: photos.map((p) => p.url).toList(),
                        initialIndex: index,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: CustomNetworkImage(imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
