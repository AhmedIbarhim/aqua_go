import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key, required this.source});

  final String? source;

  @override
  Widget build(BuildContext context) {
    final url = source;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url == null || url.isEmpty
          ? _fallback()
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) =>
                  Container(color: context.colors.defaultSubtle),
              errorWidget: (context, url, error) => _fallback(),
            ),
    );
  }

  Widget _fallback() => Image.asset(
    AppAssets.demoBanner,
    fit: BoxFit.fill,
    width: double.infinity,
    height: double.infinity,
  );
}
