import 'dart:math';

import 'package:flutter/material.dart';

import 'battle_engine.dart';
import 'card_art.dart';

const _gold = Color(0xFFF0D69A);

class _Scene {
  const _Scene(this.skyTop, this.skyBottom, this.far, this.near, this.ground, this.glow);

  final Color skyTop;
  final Color skyBottom;
  final Color far;
  final Color near;
  final Color ground;
  final Color glow;
}

/// One landscape per mission region.
const _scenes = <_Scene>[
  _Scene(Color(0xFF2B5C8A), Color(0xFFF2C58B), Color(0xFF3F6E6A), Color(0xFF2F5A4C), Color(0xFF3F6B3A), Color(0xFFFFE9A8)),
  _Scene(Color(0xFF23353F), Color(0xFF7C95A0), Color(0xFF3B4D52), Color(0xFF2A3A3F), Color(0xFF2F4A3F), Color(0xFFCFE3E8)),
  _Scene(Color(0xFF3A3F55), Color(0xFFB39A8A), Color(0xFF5A5560), Color(0xFF433F4A), Color(0xFF59524A), Color(0xFFFFD9B0)),
  _Scene(Color(0xFF3D1210), Color(0xFFE2662B), Color(0xFF5A1D12), Color(0xFF3A120D), Color(0xFF4A1E12), Color(0xFFFFB347)),
  _Scene(Color(0xFF14304F), Color(0xFFA8D6F0), Color(0xFF6C93B4), Color(0xFF4D7494), Color(0xFFCFE6F2), Color(0xFFFFFFFF)),
  _Scene(Color(0xFF8A4B1F), Color(0xFFF7CE7A), Color(0xFFC08A4A), Color(0xFFA06C34), Color(0xFFD9B26B), Color(0xFFFFF0B8)),
  _Scene(Color(0xFF0F2A1C), Color(0xFF5FA070), Color(0xFF1E4A30), Color(0xFF123B25), Color(0xFF1F4A2A), Color(0xFFC8FFC8)),
  _Scene(Color(0xFF1A1424), Color(0xFF6A5578), Color(0xFF3A2E4A), Color(0xFF2A2036), Color(0xFF3A3040), Color(0xFFE2C8FF)),
  _Scene(Color(0xFF2A4E8E), Color(0xFFEAF2FF), Color(0xFF8AA6D0), Color(0xFF6A88B8), Color(0xFFD8E4F4), Color(0xFFFFFFFF)),
  _Scene(Color(0xFF220C0C), Color(0xFFB02A1E), Color(0xFF3C1210), Color(0xFF2A0C0A), Color(0xFF3A1612), Color(0xFFFF8A3C)),
];

/// The animated battlefield: landscape, both armies and attack lunges.
class ArenaView extends StatelessWidget {
  const ArenaView({
    super.key,
    required this.enemy,
    required this.player,
    required this.animation,
    required this.lunge,
    required this.lungeSide,
    required this.difficulty,
  });

  final List<Unit> enemy;
  final List<Unit> player;
  final Animation<double> animation;
  final Animation<double> lunge;

  /// true when the player's army is lunging, false for the enemy's.
  final bool lungeSide;
  final int difficulty;

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[(difficulty - 1).clamp(0, _scenes.length - 1)];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x66D7B56D)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, box) {
          final half = box.maxHeight / 2;
          return Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(child: CustomPaint(painter: _ScenePainter(scene, animation))),
              ),
              Positioned(left: 0, right: 0, top: 0, height: half, child: _Army(units: enemy, enemySide: true, animation: animation, lunge: lunge, lunging: !lungeSide)),
              Positioned(left: 0, right: 0, bottom: 0, height: half, child: _Army(units: player, enemySide: false, animation: animation, lunge: lunge, lunging: lungeSide)),
              if (enemy.isEmpty && player.isEmpty)
                const Center(child: Text('میدان نبرد آماده است', style: TextStyle(color: Colors.white54, fontSize: 12))),
            ],
          );
        },
      ),
    );
  }
}

class _Army extends StatelessWidget {
  const _Army({required this.units, required this.enemySide, required this.animation, required this.lunge, required this.lunging});

  final List<Unit> units;
  final bool enemySide;
  final Animation<double> animation;
  final Animation<double> lunge;
  final bool lunging;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final n = max(units.length, 1);
        final orb = min(min(64.0, (box.maxWidth - 16) / n - 6), box.maxHeight - 26).clamp(30.0, 64.0);
        return Align(
          alignment: enemySide ? const Alignment(0, 0.35) : const Alignment(0, -0.35),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              for (var i = 0; i < units.length; i++)
                _Token(key: ObjectKey(units[i]), unit: units[i], size: orb, phase: i * 0.9, enemySide: enemySide, animation: animation, lunge: lunge, lunging: lunging),
            ],
          ),
        );
      },
    );
  }
}

class _Token extends StatelessWidget {
  const _Token({super.key, required this.unit, required this.size, required this.phase, required this.enemySide, required this.animation, required this.lunge, required this.lunging});

  final Unit unit;
  final double size;
  final double phase;
  final bool enemySide;
  final Animation<double> animation;
  final Animation<double> lunge;
  final bool lunging;

  @override
  Widget build(BuildContext context) {
    final color = unit.card.group.primary;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, enter, child) => Transform.scale(scale: enter.clamp(0.0, 1.2), child: child),
      child: AnimatedBuilder(
        animation: Listenable.merge([animation, lunge]),
        builder: (context, child) {
          final bob = sin(animation.value * 2 * pi + phase) * 3;
          final dir = enemySide ? 1.0 : -1.0;
          final hit = lunging ? sin(lunge.value * pi) * 38 * dir : 0.0;
          return Transform.translate(offset: Offset(0, bob + hit), child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: unit.exhausted ? Colors.white38 : _gold, width: 2),
                boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 12)],
              ),
              child: MotifOrb(card: unit.card, size: size, animation: animation),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _badge('${unit.attack}', const Color(0xFFD64545)),
                const SizedBox(width: 3),
                _badge('${unit.health}', const Color(0xFF3FA564)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
      );
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.animation) : super(repaint: animation);

  final _Scene scene;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [scene.skyTop, scene.skyBottom]).createShader(rect),
    );
    // Sun or moon with a soft pulse.
    final sun = Offset(size.width * 0.78, size.height * 0.2);
    canvas.drawCircle(sun, 40 + 4 * sin(t * 2 * pi), Paint()..shader = RadialGradient(colors: [scene.glow.withOpacity(0.55), scene.glow.withOpacity(0)]).createShader(Rect.fromCircle(center: sun, radius: 48)));
    canvas.drawCircle(sun, 13, Paint()..color = scene.glow.withOpacity(0.9));
    // Two mountain layers.
    _ridge(canvas, size, scene.far, 0.42, 0.14, 1.3, 0.0);
    _ridge(canvas, size, scene.near, 0.5, 0.1, 2.1, 1.7);
    // Ground.
    final groundTop = size.height * 0.52;
    final ground = Rect.fromLTWH(0, groundTop, size.width, size.height - groundTop);
    canvas.drawRect(ground, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [scene.ground, Color.lerp(scene.ground, Colors.black, 0.45)!]).createShader(ground));
    // Battle line.
    final mid = size.height / 2;
    canvas.drawLine(
      Offset(12, mid),
      Offset(size.width - 12, mid),
      Paint()
        ..color = scene.glow.withOpacity(0.35 + 0.2 * sin(t * 2 * pi))
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Drifting embers or motes.
    final mote = Paint()..color = scene.glow.withOpacity(0.55);
    for (var i = 0; i < 14; i++) {
      final x = (size.width * ((i * 0.137 + t * (0.05 + (i % 3) * 0.02)) % 1.0));
      final y = size.height * (1 - ((i * 0.211 + t * 0.35) % 1.0));
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3) * 0.5, mote);
    }
  }

  void _ridge(Canvas canvas, Size size, Color color, double base, double amp, double freq, double shift) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 6) {
      final u = x / size.width;
      final y = size.height * base - size.height * amp * (0.5 + 0.5 * sin(u * freq * 2 * pi + shift)) * (0.6 + 0.4 * sin(u * 7 + shift));
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) => oldDelegate.scene != scene;
}
