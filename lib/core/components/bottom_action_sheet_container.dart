import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:flutter/material.dart';

class BottomActionSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const BottomActionSheetContainer({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      padding: EdgeInsets.fromLTRB(
        width * 0.06,
        height * 0.02,
        width * 0.06,
        height * 0.05,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.screenBG,
      ),
      child: child,
    );
  }
}
