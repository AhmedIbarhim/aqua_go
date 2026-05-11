import 'package:flutter/material.dart';

import '../themes/app_colors_extension.dart';

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GenericAppBar({
    this.title,
    super.key,
    this.leading,
    this.trailing,
    this.actions,
    this.fontSize,
    this.titleWidget,
    this.backgroundColor,
    this.onBackAction,
    this.bottom,
    this.elevation,
    this.shadowColor,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.hasBackground = false,
    this.backgroundImage,
  });

  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final double? fontSize;
  final Color? backgroundColor;
  final VoidCallback? onBackAction;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? shadowColor;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final bool hasBackground;
  final String? backgroundImage;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;

    double sw(double width) => (width / 414) * screenWidth;

    return AppBar(
      backgroundColor: context.colors.screenBG,
      flexibleSpace: hasBackground && backgroundImage != null
          ? Image.asset(backgroundImage!, fit: BoxFit.cover)
          : null,
      elevation: elevation ?? 0,
      shadowColor: shadowColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      bottom: bottom,
      actions:
          actions ??
          [
            if (trailing != null)
              Container(
                margin: EdgeInsetsDirectional.only(end: sw(18)),
                child: trailing,
              ),
          ],
      leading:
          leading ??
          (automaticallyImplyLeading && Navigator.of(context).canPop()
              ? IconButton(
                  onPressed:
                      onBackAction ??
                      () {
                        Navigator.of(context).pop();
                      },
                  icon: const Icon(Icons.arrow_back),
                )
              : null),
      title:
          titleWidget ??
          (title != null ? Text(title!, textAlign: TextAlign.center) : null),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom != null ? bottom!.preferredSize.height : 0),
  );
}
