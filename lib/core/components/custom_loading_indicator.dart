import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitWaveSpinner(color: context.colors.primary);
  }
}
