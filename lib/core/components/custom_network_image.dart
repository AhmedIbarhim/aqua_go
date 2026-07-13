import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import '../extentions/context_extentions.dart';
import '../utils/app_assets.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage(
    this.image, {
    super.key,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  final String image;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => const CustomLoadingIndicator(),
      errorWidget: (context, url, error) {
        return CachedNetworkSVGImage(
          image,
          width: width,
          height: height,
          placeholder: const CustomLoadingIndicator(),
          errorWidget: SvgPicture.asset(
            AppAssets.emptyImage,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              context.colors.contentTertiary,
              BlendMode.srcIn,
            ),
          ),
        );
      },
    );
  }
}

// class CustomNetworkImage extends StatelessWidget {
//   const CustomNetworkImage(this.image, {super.key, this.fit = BoxFit.fill});

//   final String image;
//   final BoxFit fit;

//   @override
//   Widget build(BuildContext context) {
//     return CachedNetworkSVGImage(
//       image,
//       placeholder: CustomLoadingIndicator(),
//       errorWidget: NormalCachedNetworkImage(image: image, fit: fit),
//       width: 250.0,
//       height: 250.0,
//       // fadeDuration: const Duration(milliseconds: 500),
//     );
//   }
// }

// class NormalCachedNetworkImage extends StatelessWidget {
//   const NormalCachedNetworkImage({
//     super.key,
//     required this.image,
//     required this.fit,
//   });

//   final String image;
//   final BoxFit fit;

//   @override
//   Widget build(BuildContext context) {
//     return CachedNetworkImage(
//       imageUrl: image,
//       fit: fit,

//       placeholder: (context, url) => const CustomLoadingIndicator(),
//       errorWidget: (context, url, error) {
//         return SvgPicture.asset(
//           AppAssets.emptyImage,
//           width: 18,
//           height: 18,
//           colorFilter: ColorFilter.mode(
//             context.colors.contentDisabled,
//             BlendMode.srcIn,
//           ),
//         );
//       },
//     );
//   }
// }
