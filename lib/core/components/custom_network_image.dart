import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../themes/app_colors_extension.dart';
import '../utils/app_assets.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage(this.image, {super.key});

  final String image;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.fill,
      placeholder: (context, url) => const SizedBox(width: 30, height: 30),
      errorWidget: (context, url, error) {
        return SvgPicture.asset(
          AppAssets.imageNotFound,
          colorFilter: ColorFilter.mode(
            context.colors.contentDisabled,
            BlendMode.srcIn,
          ),
        );
      },
    );
  }
}
