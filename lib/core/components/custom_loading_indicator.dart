import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key, this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SpinKitWaveSpinner(
      color: context.colors.primary,
      waveColor: context.colors.primary.withValues(alpha: 0.5),
      size: size ?? 50,
    );
  }
}
