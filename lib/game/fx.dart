import 'dart:math';

import 'package:flutter/material.dart';

import 'themes.dart';

/// Deep-night gradient with slowly drifting, twinkling stars.
class AnimatedBackdrop extends StatefulWidget {
  const AnimatedBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeStore.current;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.top, theme.middle, theme.bottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: CustomPaint(painter: _StarPainter(_controller, theme))),
          widget.child,
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.animation, this.theme) : super(repaint: animation);

  final Animation<double> animation;
  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (var i = 0; i < 70; i++) {
      final x = size.width * (((i * 53) % 100) / 100.0);
      final speed = 0.3 + (i % 5) * 0.12;
      final base = ((((i * 29) % 100) / 100.0) + t * speed) % 1.0;
      final y = size.height * (theme.fall ? base : 1.0 - base);
      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * 2 * pi * (3 + i % 4) + i));
      final radius = 0.6 + (i % 4) * 0.4;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = theme.particle.withOpacity(0.55 * twinkle));
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => oldDelegate.theme != theme;
}

/// A number that rises and fades, used for damage and healing.
class FloatingText extends StatelessWidget {
  const FloatingText({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        final scale = 0.6 + min(value * 4, 1.0) * 0.6;
        return Opacity(
          opacity: (1.0 - value).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -70 * value),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 38,
          fontWeight: FontWeight.w900,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
        ),
      ),
    );
  }
}
