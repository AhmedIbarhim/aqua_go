import 'package:flutter/material.dart';

class OfferEntrance extends StatefulWidget {
  const OfferEntrance({super.key, required this.child, this.index = 0});

  final Widget child;

  final int index;

  static const int maxStaggerSteps = 4;

  @override
  State<OfferEntrance> createState() => _OfferEntranceState();
}

class _OfferEntranceState extends State<OfferEntrance>
    with SingleTickerProviderStateMixin {
  static const Duration _travel = Duration(milliseconds: 320);
  static const Duration _step = Duration(milliseconds: 55);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final steps = widget.index < OfferEntrance.maxStaggerSteps
        ? widget.index
        : OfferEntrance.maxStaggerSteps;
    final delay = _step * steps;
    final total = delay + _travel;
    _controller = AnimationController(vsync: this, duration: total)..forward();

    final start = delay.inMicroseconds / total.inMicroseconds;
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, 1, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class OfferPopIn extends StatelessWidget {
  const OfferPopIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 520),
      curve: const Interval(0.45, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.88 + 0.12 * t, child: child),
      ),
      child: child,
    );
  }
}
