import 'package:flutter/material.dart';

class OnboardingStepsWidget extends StatefulWidget {
  final List<String> enImages;
  final List<String> arImages;

  const OnboardingStepsWidget({
    super.key,
    required this.enImages,
    required this.arImages,
  });

  @override
  State<OnboardingStepsWidget> createState() => _OnboardingStepsWidgetState();
}

class _OnboardingStepsWidgetState extends State<OnboardingStepsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _fadeAnimations = [];

  @override
  void initState() {
    super.initState();

    final int stepsCount = widget.enImages.length;

    // Total duration: 1.0s interval per step.
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: stepsCount * 1000),
    );

    // Staggered intervals: each step has a 1.0s delay before it starts fading in.
    final double stepInterval = 1.0 / stepsCount;
    for (int i = 0; i < stepsCount; i++) {
      final double start = i * stepInterval;
      final double end = (start + stepInterval).clamp(0.0, 1.0);

      _fadeAnimations.add(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    }

    // Start the staggered animation sequence
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final List<String> images = isArabic ? widget.arImages : widget.enImages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Calculate responsive scale factor relative to a baseline mobile width (375px)
        final double scale = (width / 375.0).clamp(0.85, 1.15);

        return Stack(
          children: List.generate(images.length, (index) {
            // Horizontal diagonal shift (sloping down-right in LTR, down-left in RTL)
            // Arabic is shifted slightly more to the right (base offset 18% instead of 25%)
            final double basePercent = isArabic ? 0.1 : 0.25;
            final double horizontalPercent = basePercent + index * 0.05;
            // Vertical spacing (13% gap between items, starting near the top at 3%)
            final double topPercent = 0.03 + index * 0.13;

            return Positioned(
              left: isArabic ? null : width * horizontalPercent,
              right: isArabic ? width * horizontalPercent : null,
              top: height * topPercent,
              child: FadeTransition(
                opacity: _fadeAnimations[index],
                child: Image.asset(
                  images[index],
                  height: 36 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
