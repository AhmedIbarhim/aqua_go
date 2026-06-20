import 'dart:math' as math;
import 'package:flutter/material.dart';

class OnboardingStepsWidget extends StatefulWidget {
  const OnboardingStepsWidget({super.key});

  @override
  State<OnboardingStepsWidget> createState() => _OnboardingStepsWidgetState();
}

class _OnboardingStepsWidgetState extends State<OnboardingStepsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _fadeAnimations = [];

  // Define step configurations: icon, text, and starting percentage-based positions to form the curve (sloping down-right)
  final List<StepConfig> _steps = [
    StepConfig(
      icon: Icons.phone_android_rounded,
      text: 'REGISTER',
      leftPercent: 0.25,
      topPercent: 0.15,
    ),
    StepConfig(
      icon: Icons.touch_app_rounded,
      text: 'CHOOSE SERVICE',
      leftPercent: 0.30,
      topPercent: 0.28,
    ),
    StepConfig(
      icon: Icons.location_on_rounded,
      text: 'PIN LOCATION',
      leftPercent: 0.35,
      topPercent: 0.41,
    ),
    StepConfig(
      icon: Icons.calendar_today_rounded,
      text: 'DATE AND TIME',
      leftPercent: 0.40,
      topPercent: 0.54,
    ),
    StepConfig(
      icon: Icons.payment_rounded,
      text: 'PAY ONLINE',
      leftPercent: 0.45,
      topPercent: 0.67,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Total duration: 5 steps * 1.0s interval = 5.0s total animation sequence.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // Staggered intervals: each step has a 1.0s (20% of 5s) delay before it starts fading in.
    // The fade-in duration for each step is also 1.0s (20% of 5s).
    for (int i = 0; i < _steps.length; i++) {
      final double start = i * 0.20;
      final double end = (start + 0.20).clamp(0.0, 1.0);

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
    final primaryColor = Color(0xFF02BCC5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        // Calculate responsive scale factor relative to a baseline mobile width (375px)
        final double scale = (width / 375.0).clamp(0.85, 1.15);

        return Stack(
          children: List.generate(_steps.length, (index) {
            final step = _steps[index];
            return Positioned(
              left: width * step.leftPercent,
              top: height * step.topPercent,
              child: FadeTransition(
                opacity: _fadeAnimations[index],
                child: OnboardingStepItem(
                  icon: step.icon,
                  text: step.text,
                  primaryColor: primaryColor,
                  scale: scale,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class StepConfig {
  final IconData icon;
  final String text;
  final double leftPercent;
  final double topPercent;

  StepConfig({
    required this.icon,
    required this.text,
    required this.leftPercent,
    required this.topPercent,
  });
}

class OnboardingStepItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color primaryColor;
  final double scale;

  const OnboardingStepItem({
    super.key,
    required this.icon,
    required this.text,
    required this.primaryColor,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizes
    final double iconSize = 20.0 * scale;
    final double circleSize = 36.0 * scale;
    final double outerArcSize = 46.0 * scale;
    final double fontSize = 12.0 * scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Decorative Circular Icon with Outer Crescent Arc
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Crescent Arc
            SizedBox(
              width: outerArcSize,
              height: outerArcSize,
              child: CustomPaint(
                painter: CrescentPainter(color: primaryColor, scale: scale),
              ),
            ),
            // White circular icon container with cyan border
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2.0 * scale),
              ),
              child: Icon(icon, color: primaryColor, size: iconSize),
            ),
          ],
        ),
        SizedBox(width: 8 * scale),
        // Text pill container
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 8 * scale,
          ),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(24 * scale),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.8),
              width: 1.5 * scale,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class CrescentPainter extends CustomPainter {
  final Color color;
  final double scale;

  CrescentPainter({required this.color, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    // The arc radius is slightly larger than the inner circle to wrap around it beautifully.
    final double radius = (size.width / 2) - (1.0 * scale);

    final rect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    );

    // To cover the top, left, and bottom sides, and be open towards the right (the text pill):
    // Start angle: 120 degrees (bottom-right/middle-bottom)
    // Sweep angle: 240 degrees (sweeps clockwise around the left to the top-right)
    const double startAngle = 120 * math.pi / 180;
    const double sweepAngle = 240 * math.pi / 180;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // Draw the small dot at the end of the arc (top-right, which is startAngle + sweepAngle = 360 degrees / 0 radians)
    final double endAngle = startAngle + sweepAngle;
    final double dotX = centerX + radius * math.cos(endAngle);
    final double dotY = centerY + radius * math.sin(endAngle);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 3.0 * scale, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CrescentPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.scale != scale;
  }
}
