import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../extentions/context_extentions.dart';
import '../themes/app_text_styles.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets? padding;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox.expand(),
                ),
              ),
              CustomBottomSheet(title: title, padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              padding ??
              EdgeInsets.only(
                top: height * 0.03,
                left: width * 0.06,
                right: width * 0.06,
                bottom: MediaQuery.of(context).viewInsets.bottom + 5,
              ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ),
                    Text(title, style: AppTextStyles.regular20),
                    const SizedBox(width: 32),
                  ],
                ),
                SizedBox(height: height * 0.05),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
