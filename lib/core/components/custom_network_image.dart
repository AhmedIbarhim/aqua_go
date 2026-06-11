import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../extentions/context_extentions.dart';
import '../utils/app_assets.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage(this.image, {super.key, this.fit = BoxFit.fill});

  final String image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: fit,

      placeholder: (context, url) => const CustomLoadingIndicator(),
      errorWidget: (context, url, error) {
        return SvgPicture.asset(
          AppAssets.emptyImage,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            context.colors.contentDisabled,
            BlendMode.srcIn,
          ),
        );
      },
    );
  }
}
