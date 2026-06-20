import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../utils/app_assets.dart';

class VehicleMakeLogo extends StatelessWidget {
  const VehicleMakeLogo({
    super.key,
    required this.logoUrl,
    required this.colorEditable,
    this.size = 40,
    this.fit = BoxFit.contain,
  });

  final String? logoUrl;
  final bool colorEditable;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return _fallback(context);
    }

    final image = CachedNetworkImage(
      imageUrl: logoUrl!,
      width: size,
      height: size,
      fit: fit,
      placeholder: (context, url) => const CustomLoadingIndicator(),
      errorWidget: (context, url, error) => CachedNetworkSVGImage(
        logoUrl!,
        width: size,
        height: size,
        placeholder: const CustomLoadingIndicator(),
        errorWidget: _fallback(context),
      ),
    );

    if (!colorEditable) {
      return image;
    }

    return _applyGradientFilter(image);
  }

  Widget _fallback(BuildContext context) {
    return _applyGradientFilter(
      SvgPicture.asset(AppAssets.raceCar, width: size, height: size, fit: fit),
    );
  }

  Widget _applyGradientFilter(Widget child) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.grey.shade300,

          Colors.grey.shade600,
          Colors.grey.shade100,
          Colors.grey.shade600,

          Colors.grey.shade800,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }
}
