import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/config/controllers/theme_controller/theme_cubit.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';

/// A wrapper widget that makes its child draggable within the screen bounds.
class DraggableFloatingWidget extends StatefulWidget {
  final Widget child;
  final double initialTopOffset;
  final VoidCallback onTap;

  const DraggableFloatingWidget({
    super.key,
    required this.child,
    required this.initialTopOffset,
    required this.onTap,
  });

  @override
  State<DraggableFloatingWidget> createState() =>
      _DraggableFloatingWidgetState();
}

class _DraggableFloatingWidgetState extends State<DraggableFloatingWidget> {
  late Offset _offset;
  bool _isDragging = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;
      // Position the widget on the correct side based on text directionality
      final isRtl = context.isAr;
      final double x = isRtl
          ? padding.left + 16
          : size.width - padding.right - 58 - 16;
      final double y = widget.initialTopOffset;
      _offset = Offset(x, y);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final padding = MediaQuery.of(context).padding;

    // Constrain offset inside safe areas of the screen
    final double minX = padding.left + 8;
    final double maxX =
        size.width - padding.right - 58; // 50 widget width + 8 padding
    final double minY = padding.top + 8;
    final double maxY = size.height - padding.bottom - viewInsets.bottom - 58;

    // Clamp the offset to ensure it stays on screen
    _offset = Offset(
      _offset.dx.clamp(minX, maxX),
      _offset.dy.clamp(minY, maxY),
    );

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
        },
        onPanCancel: () {
          setState(() {
            _isDragging = false;
          });
        },
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isDragging ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating Theme Switcher Widget
class FloatingThemeSwitcher extends StatelessWidget {
  const FloatingThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return DraggableFloatingWidget(
          initialTopOffset: 150,
          onTap: () {
            context.read<ThemeCubit>().toggleTheme(!context.isDarkTheme);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: context.isDarkTheme
                    ? [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.grey[900]!.withValues(alpha: 0.5),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.grey[200]!.withValues(alpha: 0.6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: context.colors.primary.withValues(alpha: 0.25),
              //     blurRadius: 12,
              //     spreadRadius: 1,
              //     offset: const Offset(0, 4),
              //   ),
              // ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: RotationTransition(
                          turns: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      context.isDarkTheme
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      key: ValueKey<bool>(context.isDarkTheme),
                      color: context.colors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating Language Switcher Widget
class FloatingLanguageSwitcher extends StatelessWidget {
  const FloatingLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return DraggableFloatingWidget(
          initialTopOffset: 214, // 150 + 48 height + 16 gap
          onTap: () {
            context.read<LanguageCubit>().toggleLanguage(context);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: context.isDarkTheme
                    ? [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.grey[900]!.withValues(alpha: 0.5),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.grey[200]!.withValues(alpha: 0.6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: context.colors.primary.withValues(alpha: 0.25),
              //     blurRadius: 12,
              //     spreadRadius: 1,
              //     offset: const Offset(0, 4),
              //   ),
              // ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      context.isAr ? 'EN' : 'عربي',
                      key: ValueKey<bool>(context.isAr),
                      style: TextStyle(
                        color: context.colors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: context.isAr
                            ? 'Roboto'
                            : 'Outfit', // Nicer fonts for target language indicator
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
