import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class CarMakeLogoNetworkSvg extends StatelessWidget {
  const CarMakeLogoNetworkSvg({super.key, required this.logoUrl});

  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [Color(0xFFE3E3E3), Color(0xFF6D6B6B), Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: SvgPicture.network(logoUrl),
    );
  }
}
