import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../extentions/context_extentions.dart';
import '../utils/app_assets.dart';

/// Renders a vehicle make (brand) logo from a remote URL.
///
/// When [colorEditable] is true the logo is a clean monochrome asset and is
/// tinted with [context.colors.themeOpositeColor] (white on the dark theme,
/// near-black on the light theme) so it stays visible against the dark card
/// background.  When false the logo has intrinsic colours (e.g. BMW) and is
/// rendered as-is.
///
/// A null or empty [logoUrl] shows the generic race-car silhouette fallback.
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

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        context.colors.themeOpositeColor,
        BlendMode.srcIn,
      ),
      child: image,
    );
  }

  Widget _fallback(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.raceCar,
      width: size,
      height: size,
      fit: fit,
      colorFilter: ColorFilter.mode(
        context.colors.contentDisabled,
        BlendMode.srcIn,
      ),
    );
  }
}
