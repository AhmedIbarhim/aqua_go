import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_network_image.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bookings/presentation/views/gallery_view.dart';

class ComplaintDetailsPhotosCard extends StatelessWidget {
  final List<String> photos;

  const ComplaintDetailsPhotosCard({super.key, required this.photos});

  String _getImageUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return 'https://api.aquago.sa/api/customer/$path';
  }

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    double sh(double height) => (height / 896) * MediaQuery.sizeOf(context).height;

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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: photos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final imageUrl = _getImageUrl(photos[index]);
              return GestureDetector(
                onTap: () {
                  context.pushNamed(
                    Routes.gallery,
                    arguments: GalleryArgs(
                      images: photos.map((p) => _getImageUrl(p)).toList(),
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
      ],
    );
  }
}
