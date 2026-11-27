import 'dart:math';

import 'package:flutter/material.dart';

import 'card.dart';

extension CardGroupStyle on CardGroup {
  Color get primary {
    switch (this) {
      case CardGroup.heroes:
        return const Color(0xFFE6B94A);
      case CardGroup.infantry:
        return const Color(0xFF6C8FC7);
      case CardGroup.archers:
        return const Color(0xFF5FB36B);
      case CardGroup.cavalry:
        return const Color(0xFFD08A45);
      case CardGroup.mages:
        return const Color(0xFFA97CE8);
      case CardGroup.beasts:
        return const Color(0xFFE05A4F);
      case CardGroup.battleSpells:
        return const Color(0xFFFF8A3D);
      case CardGroup.blessings:
        return const Color(0xFF52D1C0);
      case CardGroup.weapons:
        return const Color(0xFF9AA8BD);
      case CardGroup.relics:
        return const Color(0xFFC79BE0);
    }
  }

  Color get secondary {
    switch (this) {
      case CardGroup.heroes:
        return const Color(0xFF4A3410);
      case CardGroup.infantry:
        return const Color(0xFF16284A);
      case CardGroup.archers:
        return const Color(0xFF123A1F);
      case CardGroup.cavalry:
        return const Color(0xFF4A2A10);
      case CardGroup.mages:
        return const Color(0xFF2B1650);
      case CardGroup.beasts:
        return const Color(0xFF4A1512);
      case CardGroup.battleSpells:
        return const Color(0xFF4A200A);
      case CardGroup.blessings:
        return const Color(0xFF0C3A38);
      case CardGroup.weapons:
        return const Color(0xFF222B3A);
      case CardGroup.relics:
        return const Color(0xFF38204A);
    }
  }

  IconData get icon {
    switch (this) {
      case CardGroup.heroes:
        return Icons.workspace_premium;
      case CardGroup.infantry:
        return Icons.shield;
      case CardGroup.archers:
        return Icons.my_location;
      case CardGroup.cavalry:
        return Icons.pets;
      case CardGroup.mages:
        return Icons.auto_fix_high;
      case CardGroup.beasts:
        return Icons.cruelty_free;
      case CardGroup.battleSpells:
        return Icons.local_fire_department;
      case CardGroup.blessings:
        return Icons.favorite;
      case CardGroup.weapons:
        return Icons.gavel;
      case CardGroup.relics:
        return Icons.diamond;
    }
  }
}

/// An animated illustration for a card. Pass a shared [animation] when many
/// arts are on screen so they all use one ticker.
class CardArt extends StatefulWidget {
  const CardArt({super.key, required this.card, this.animation});

  final GameCard card;
  final Animation<double>? animation;

  @override
  State<CardArt> createState() => _CardArtState();
}

class _CardArtState extends State<CardArt> with SingleTickerProviderStateMixin {
  AnimationController? _own;

  Animation<double> get _animation {
    final shared = widget.animation;
    if (shared != null) return shared;
    return _own ??= AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ArtPainter(card: widget.card, animation: _animation),
        size: Size.infinite,
      ),
    );
  }
}

class AvatarOption {
  const AvatarOption(this.label, this.motif, this.group);

  final String label;
  final ArtMotif motif;
  final CardGroup group;
}

/// Fantasy portraits a player can choose from.
const avatarOptions = <AvatarOption>[
  AvatarOption('شوالیه', ArtMotif.sword, CardGroup.infantry),
  AvatarOption('کماندار', ArtMotif.bow, CardGroup.archers),
  AvatarOption('جادوگر', ArtMotif.wizard, CardGroup.mages),
  AvatarOption('اژدها', ArtMotif.dragon, CardGroup.beasts),
  AvatarOption('ققنوس', ArtMotif.bird, CardGroup.battleSpells),
  AvatarOption('پادشاه', ArtMotif.crown, CardGroup.heroes),
  AvatarOption('شفابخش', ArtMotif.heal, CardGroup.blessings),
  AvatarOption('نگهبان', ArtMotif.shield, CardGroup.relics),
];

/// A round animated portrait for the player profile.
class AvatarArt extends StatefulWidget {
  const AvatarArt({super.key, required this.index, this.size = 72, this.animation});

  final int index;
  final double size;
  final Animation<double>? animation;

  @override
  State<AvatarArt> createState() => _AvatarArtState();
}

class _AvatarArtState extends State<AvatarArt> with SingleTickerProviderStateMixin {
  AnimationController? _own;

  Animation<double> get _animation {
    final shared = widget.animation;
    if (shared != null) return shared;
    return _own ??= AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = avatarOptions[widget.index.clamp(0, avatarOptions.length - 1)];
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        child: RepaintBoundary(
          child: CustomPaint(painter: _AvatarPainter(option: option, animation: _animation), size: Size.infinite),
        ),
      ),
    );
  }
}

/// A round animated token for a unit on the battlefield.
class MotifOrb extends StatelessWidget {
  const MotifOrb({super.key, required this.card, required this.size, required this.animation});

  final GameCard card;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final option = AvatarOption(card.name, card.motif, card.group);
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: RepaintBoundary(
          child: CustomPaint(painter: _AvatarPainter(option: option, animation: animation), size: Size.infinite),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({required this.option, required this.animation}) : super(repaint: animation);

  final AvatarOption option;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final a = option.group.primary;
    final b = option.group.secondary;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.9,
          colors: [Color.lerp(b, a, 0.45)!, b, const Color(0xFF05070C)],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(rect),
    );
    final unit = min(size.width, size.height) * 0.33;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + sin(t * 2 * pi) * unit * 0.05);
    canvas.scale(unit);
    canvas.drawCircle(
      Offset.zero,
      1.2,
      Paint()
        ..shader = RadialGradient(colors: [a.withOpacity(0.5), a.withOpacity(0.0)]).createShader(Rect.fromCircle(center: Offset.zero, radius: 1.2)),
    );
    _Motifs.draw(canvas, option.motif, t, a, b);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) => oldDelegate.option != option;
}

class _ArtPainter extends CustomPainter {
  _ArtPainter({required this.card, required this.animation}) : super(repaint: animation);

  final GameCard card;
  final Animation<double> animation;

  double get _phase {
    var h = 0;
    for (final unit in card.id.codeUnits) {
      h = (h * 31 + unit) % 1000;
    }
    return h / 1000.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = (animation.value + _phase) % 1.0;
    final a = card.group.primary;
    final b = card.group.secondary;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.15),
          radius: 0.95,
          colors: [Color.lerp(b, a, 0.35)!, b, const Color(0xFF05070C)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(rect),
    );

    _drawRays(canvas, size, t, a);
    _drawParticles(canvas, size, t, a);

    final unit = min(size.width, size.height) * 0.36;
    final bob = sin(t * 2 * pi) * unit * 0.06;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + bob);
    canvas.scale(unit);

    final pulse = 1.0 + 0.08 * sin(t * 4 * pi);
    canvas.drawCircle(
      Offset.zero,
      1.15 * pulse,
      Paint()
        ..shader = RadialGradient(
          colors: [a.withOpacity(0.5), a.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1.15 * pulse)),
    );

    _Motifs.draw(canvas, card.motif, t, a, b);
    canvas.restore();
  }

  void _drawRays(Canvas canvas, Size size, double t, Color color) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(t * 2 * pi * 0.5);
    final radius = size.longestSide;
    final paint = Paint()..color = color.withOpacity(0.07);
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(cos(angle) * radius, sin(angle) * radius)
        ..lineTo(cos(angle + 0.18) * radius, sin(angle + 0.18) * radius)
        ..close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  void _drawParticles(Canvas canvas, Size size, double t, Color color) {
    for (var i = 0; i < 10; i++) {
      final phase = (t + i / 10.0) % 1.0;
      final x = size.width * (0.08 + 0.84 * (((i * 37) % 100) / 100.0));
      final y = size.height * (1.0 - phase);
      final radius = 1.0 + (i % 3) * 0.7;
      final opacity = sin(phase * pi).clamp(0.0, 1.0) * 0.8;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = color.withOpacity(opacity));
    }
  }

  @override
  bool shouldRepaint(covariant _ArtPainter oldDelegate) => oldDelegate.card != card;
}

/// Hand-drawn vector motifs, drawn in a unit space of roughly -1..1.
class _Motifs {
  static Paint _metal() => Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFFF5F7FA), Color(0xFF7F8CA3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(-1, -1, 2, 2));

  static Paint _gold() => Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFFFFE9A8), Color(0xFFC8962E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(-1, -1, 2, 2));

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static void _sparkle(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.2, c.dy - r * 0.2)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + r * 0.2, c.dy + r * 0.2)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.2, c.dy + r * 0.2)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - r * 0.2, c.dy - r * 0.2)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void draw(Canvas canvas, ArtMotif motif, double t, Color a, Color b) {
    switch (motif) {
      case ArtMotif.sword:
        _sword(canvas, t);
      case ArtMotif.shield:
        _shield(canvas, t, a);
      case ArtMotif.bow:
        _bow(canvas, t);
      case ArtMotif.horse:
        _horseshoe(canvas, t);
      case ArtMotif.wizard:
        _wizard(canvas, t, a);
      case ArtMotif.dragon:
        _dragon(canvas, t, a, b);
      case ArtMotif.flame:
        _flame(canvas, t);
      case ArtMotif.frost:
        _frost(canvas, t);
      case ArtMotif.heal:
        _heal(canvas, t);
      case ArtMotif.bolt:
        _bolt(canvas, t);
      case ArtMotif.beast:
        _paw(canvas, t, a);
      case ArtMotif.golem:
        _golem(canvas, t);
      case ArtMotif.skull:
        _skull(canvas, t);
      case ArtMotif.crown:
        _crown(canvas, t);
      case ArtMotif.banner:
        _banner(canvas, t, a);
      case ArtMotif.armor:
        _helmet(canvas, t);
      case ArtMotif.meteor:
        _meteor(canvas, t);
      case ArtMotif.bird:
        _phoenix(canvas, t);
      case ArtMotif.tower:
        _tower(canvas, t);
    }
  }

  static void _sword(Canvas canvas, double t) {
    canvas.rotate(0.5 + sin(t * 2 * pi) * 0.05);
    final blade = Path()
      ..moveTo(0, -1.0)
      ..lineTo(0.14, -0.7)
      ..lineTo(0.14, 0.35)
      ..lineTo(-0.14, 0.35)
      ..lineTo(-0.14, -0.7)
      ..close();
    canvas.drawPath(blade, _metal());
    canvas.drawLine(const Offset(0, -0.8), const Offset(0, 0.3), Paint()..color = Colors.white54..strokeWidth = 0.03);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.42, 0.35, 0.84, 0.12), const Radius.circular(0.05)), _gold());
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.06, 0.47, 0.12, 0.35), const Radius.circular(0.04)), _gold());
    canvas.drawCircle(const Offset(0, 0.88), 0.1, _gold());
    final shine = (sin(t * 2 * pi) + 1) / 2;
    _sparkle(canvas, Offset(0.0, -0.75 + shine * 0.9), 0.14, Paint()..color = Colors.white.withOpacity(0.9));
  }

  static void _shield(Canvas canvas, double t, Color a) {
    final path = Path()
      ..moveTo(-0.65, -0.65)
      ..lineTo(0.65, -0.65)
      ..lineTo(0.65, 0.1)
      ..quadraticBezierTo(0.65, 0.65, 0, 0.95)
      ..quadraticBezierTo(-0.65, 0.65, -0.65, 0.1)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(a, Colors.white, 0.35)!, Color.lerp(a, Colors.black, 0.35)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(-0.7, -0.7, 1.4, 1.7)),
    );
    canvas.drawPath(path, _stroke(const Color(0xFFFFE9A8), 0.07));
    canvas.drawLine(const Offset(0, -0.45), const Offset(0, 0.6), _stroke(const Color(0xFFFFE9A8), 0.09));
    canvas.drawLine(const Offset(-0.4, -0.05), const Offset(0.4, -0.05), _stroke(const Color(0xFFFFE9A8), 0.09));
    final glint = (sin(t * 2 * pi) + 1) / 2;
    canvas.drawCircle(Offset(-0.35 + glint * 0.7, -0.45), 0.06, Paint()..color = Colors.white.withOpacity(0.7));
  }

  static void _bow(Canvas canvas, double t) {
    final pull = (sin(t * 2 * pi) + 1) / 2 * 0.25;
    final wood = _stroke(const Color(0xFFB07A3A), 0.1);
    canvas.drawArc(const Rect.fromLTWH(-0.9, -0.95, 1.1, 1.9), -1.25, 2.5, false, wood);
    const top = Offset(-0.18, -0.9);
    const bottom = Offset(-0.18, 0.9);
    final nock = Offset(-0.18 - pull, 0);
    final string = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(nock.dx, nock.dy)
      ..lineTo(bottom.dx, bottom.dy);
    canvas.drawPath(string, _stroke(Colors.white70, 0.025));
    canvas.drawLine(nock, const Offset(0.9, 0), _stroke(const Color(0xFFE6D3A8), 0.045));
    final head = Path()
      ..moveTo(0.95, 0)
      ..lineTo(0.75, -0.1)
      ..lineTo(0.75, 0.1)
      ..close();
    canvas.drawPath(head, _metal());
  }

  static void _horseshoe(Canvas canvas, double t) {
    canvas.rotate(sin(t * 2 * pi) * 0.06);
    canvas.drawArc(const Rect.fromLTWH(-0.6, -0.55, 1.2, 1.3), -0.35, pi + 0.7, false, _stroke(const Color(0xFFCFD6E2), 0.24));
    canvas.drawArc(const Rect.fromLTWH(-0.6, -0.55, 1.2, 1.3), -0.35, pi + 0.7, false, _stroke(const Color(0xFF6C7689), 0.06));
    for (var k = 0; k < 5; k++) {
      final ang = 0.25 + k * (pi - 0.5) / 4;
      canvas.drawCircle(Offset(cos(ang) * 0.6, 0.1 + sin(ang) * 0.65), 0.05, Paint()..color = const Color(0xFF222B3A));
    }
    final glow = (sin(t * 4 * pi) + 1) / 2;
    _sparkle(canvas, const Offset(0.45, -0.7), 0.14 + glow * 0.06, Paint()..color = Colors.white.withOpacity(0.9));
  }

  static void _wizard(Canvas canvas, double t, Color a) {
    canvas.drawLine(const Offset(-0.55, 0.95), const Offset(0.3, -0.45), _stroke(const Color(0xFF9A6B34), 0.1));
    final pulse = 1.0 + 0.1 * sin(t * 4 * pi);
    const orb = Offset(0.38, -0.6);
    canvas.drawCircle(
      orb,
      0.42 * pulse,
      Paint()
        ..shader = RadialGradient(colors: [Colors.white, a.withOpacity(0.0)]).createShader(Rect.fromCircle(center: orb, radius: 0.42 * pulse)),
    );
    canvas.drawCircle(orb, 0.22, Paint()..color = Color.lerp(a, Colors.white, 0.6)!);
    for (var i = 0; i < 4; i++) {
      final ang = t * 2 * pi + i * pi / 2;
      _sparkle(canvas, Offset(0.0 + cos(ang) * 0.75, -0.1 + sin(ang) * 0.6), 0.1, Paint()..color = Colors.white.withOpacity(0.8));
    }
  }

  static void _dragon(Canvas canvas, double t, Color a, Color b) {
    final flap = 1.0 + 0.1 * sin(t * 2 * pi);
    canvas.scale(1.0, flap);
    final wing = Path()
      ..moveTo(-0.9, 0.55)
      ..quadraticBezierTo(-0.8, -0.65, 0.0, -0.85)
      ..quadraticBezierTo(0.8, -0.65, 0.9, 0.55)
      ..lineTo(0.55, 0.2)
      ..lineTo(0.28, 0.6)
      ..lineTo(0.0, 0.2)
      ..lineTo(-0.28, 0.6)
      ..lineTo(-0.55, 0.2)
      ..close();
    canvas.drawPath(
      wing,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(a, Colors.white, 0.2)!, Color.lerp(b, Colors.black, 0.2)!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTWH(-0.9, -0.9, 1.8, 1.5)),
    );
    canvas.drawPath(wing, _stroke(const Color(0xFFFFD27A), 0.05));
    canvas.drawLine(const Offset(0, -0.8), const Offset(0, 0.2), _stroke(const Color(0xFFFFD27A), 0.05));
    canvas.drawCircle(const Offset(0, -0.1), 0.12, Paint()..color = const Color(0xFFFFF1A8));
    canvas.drawCircle(const Offset(0, -0.1), 0.05, Paint()..color = const Color(0xFF1A0A0A));
  }

  static void _flame(Canvas canvas, double t) {
    final f = 1.0 + 0.07 * sin(t * 4 * pi);
    Path drop(double s) => Path()
      ..moveTo(0, -1.0 * f * s)
      ..cubicTo(0.55 * s, -0.4 * s, 0.75 * s, 0.2 * s, 0.5 * s, 0.6 * s)
      ..cubicTo(0.3 * s, 0.95 * s, -0.3 * s, 0.95 * s, -0.5 * s, 0.6 * s)
      ..cubicTo(-0.75 * s, 0.2 * s, -0.5 * s, -0.3 * s, 0, -1.0 * f * s)
      ..close();
    canvas.drawPath(
      drop(1.0),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFE5391E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTWH(-0.8, -1.0, 1.6, 2.0)),
    );
    canvas.save();
    canvas.translate(0, 0.25);
    canvas.drawPath(drop(0.55), Paint()..color = const Color(0xFFFFE680));
    canvas.restore();
  }

  static void _frost(Canvas canvas, double t) {
    canvas.rotate(t * 2 * pi * 0.25);
    final paint = _stroke(const Color(0xFFC8F1FF), 0.07);
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * pi / 3);
      canvas.drawLine(Offset.zero, const Offset(0, -0.95), paint);
      canvas.drawLine(const Offset(0, -0.55), const Offset(0.24, -0.78), paint);
      canvas.drawLine(const Offset(0, -0.55), const Offset(-0.24, -0.78), paint);
      canvas.drawLine(const Offset(0, -0.3), const Offset(0.17, -0.46), paint);
      canvas.drawLine(const Offset(0, -0.3), const Offset(-0.17, -0.46), paint);
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 0.12, Paint()..color = Colors.white);
  }

  static void _heal(Canvas canvas, double t) {
    final s = 1.0 + 0.06 * sin(t * 4 * pi);
    canvas.scale(s);
    canvas.drawCircle(Offset.zero, 0.85, _stroke(const Color(0xFFB9FFF0), 0.06));
    final green = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB8FFD9), Color(0xFF2FBF8A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-0.6, -0.6, 1.2, 1.2));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.18, -0.6, 0.36, 1.2), const Radius.circular(0.12)), green);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.6, -0.18, 1.2, 0.36), const Radius.circular(0.12)), green);
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3.0) % 1.0;
      _sparkle(canvas, Offset(-0.6 + i * 0.6, 0.8 - phase * 1.6), 0.09, Paint()..color = Colors.white.withOpacity(sin(phase * pi)));
    }
  }

  static void _bolt(Canvas canvas, double t) {
    final flicker = 0.75 + 0.25 * sin(t * 8 * pi);
    final path = Path()
      ..moveTo(0.15, -1.0)
      ..lineTo(-0.45, 0.1)
      ..lineTo(-0.05, 0.1)
      ..lineTo(-0.22, 1.0)
      ..lineTo(0.45, -0.2)
      ..lineTo(0.05, -0.2)
      ..close();
    canvas.drawPath(path, _stroke(Colors.white.withOpacity(flicker), 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFF7A8), Color(0xFFFFB400)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTWH(-0.5, -1.0, 1.0, 2.0)),
    );
  }

  static void _paw(Canvas canvas, double t, Color a) {
    final fill = Paint()..color = Color.lerp(a, Colors.black, 0.25)!;
    final edge = _stroke(const Color(0xFFFFD6A0), 0.04);
    final pad = Rect.fromCenter(center: const Offset(0, 0.3), width: 1.0, height: 0.8);
    canvas.drawOval(pad, fill);
    canvas.drawOval(pad, edge);
    const toes = [Offset(-0.58, -0.2), Offset(-0.2, -0.6), Offset(0.2, -0.6), Offset(0.58, -0.2)];
    for (var i = 0; i < toes.length; i++) {
      final lift = sin(t * 2 * pi + i * 0.8) * 0.04;
      final c = toes[i].translate(0, lift);
      canvas.drawCircle(c, 0.2, fill);
      canvas.drawCircle(c, 0.2, edge);
    }
  }

  static void _golem(Canvas canvas, double t) {
    final stone = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB7BEC9), Color(0xFF5E6676)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-1, -1, 2, 2));
    final edge = _stroke(const Color(0xFF2A3040), 0.05);
    for (final r in const [
      Rect.fromLTWH(-0.55, -0.1, 1.1, 0.9),
      Rect.fromLTWH(-0.35, -0.72, 0.7, 0.55),
      Rect.fromLTWH(-0.92, -0.05, 0.32, 0.7),
      Rect.fromLTWH(0.6, -0.05, 0.32, 0.7),
    ]) {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(0.12));
      canvas.drawRRect(rr, stone);
      canvas.drawRRect(rr, edge);
    }
    final glow = 0.6 + 0.4 * sin(t * 4 * pi);
    final eye = Paint()..color = Color.fromRGBO(255, 160, 40, glow);
    canvas.drawCircle(const Offset(-0.14, -0.45), 0.07, eye);
    canvas.drawCircle(const Offset(0.14, -0.45), 0.07, eye);
  }

  static void _skull(Canvas canvas, double t) {
    final bone = Paint()..color = const Color(0xFFF1EBDD);
    canvas.drawCircle(const Offset(0, -0.15), 0.6, bone);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.35, 0.2, 0.7, 0.45), const Radius.circular(0.1)), bone);
    final dark = Paint()..color = const Color(0xFF14101A);
    canvas.drawCircle(const Offset(-0.24, -0.2), 0.17, dark);
    canvas.drawCircle(const Offset(0.24, -0.2), 0.17, dark);
    final glow = 0.5 + 0.5 * sin(t * 4 * pi);
    final eye = Paint()..color = Color.fromRGBO(120, 255, 140, glow);
    canvas.drawCircle(const Offset(-0.24, -0.2), 0.07, eye);
    canvas.drawCircle(const Offset(0.24, -0.2), 0.07, eye);
    final nose = Path()
      ..moveTo(0, 0.0)
      ..lineTo(-0.07, 0.15)
      ..lineTo(0.07, 0.15)
      ..close();
    canvas.drawPath(nose, dark);
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(i * 0.12, 0.38), Offset(i * 0.12, 0.6), _stroke(const Color(0xFF14101A), 0.025));
    }
  }

  static void _crown(Canvas canvas, double t) {
    final path = Path()
      ..moveTo(-0.7, 0.5)
      ..lineTo(-0.82, -0.5)
      ..lineTo(-0.36, -0.1)
      ..lineTo(0.0, -0.75)
      ..lineTo(0.36, -0.1)
      ..lineTo(0.82, -0.5)
      ..lineTo(0.7, 0.5)
      ..close();
    canvas.drawPath(path, _gold());
    canvas.drawPath(path, _stroke(const Color(0xFF8A5E12), 0.05));
    canvas.drawRect(const Rect.fromLTWH(-0.7, 0.28, 1.4, 0.22), Paint()..color = const Color(0xFF8A5E12));
    final glow = 0.6 + 0.4 * sin(t * 4 * pi);
    canvas.drawCircle(const Offset(0, 0.0), 0.1, Paint()..color = Color.fromRGBO(255, 80, 90, glow));
    canvas.drawCircle(const Offset(-0.45, 0.1), 0.07, Paint()..color = Color.fromRGBO(90, 200, 255, glow));
    canvas.drawCircle(const Offset(0.45, 0.1), 0.07, Paint()..color = Color.fromRGBO(90, 200, 255, glow));
  }

  static void _banner(Canvas canvas, double t, Color a) {
    canvas.drawLine(const Offset(-0.6, -0.95), const Offset(-0.6, 0.95), _stroke(const Color(0xFFD9C08A), 0.08));
    final w = sin(t * 2 * pi) * 0.12;
    final flag = Path()
      ..moveTo(-0.6, -0.85)
      ..cubicTo(-0.2, -0.95 + w, 0.2, -0.75 - w, 0.75, -0.85)
      ..lineTo(0.5, -0.35)
      ..lineTo(0.75, 0.15)
      ..cubicTo(0.2, 0.25 - w, -0.2, 0.05 + w, -0.6, 0.15)
      ..close();
    canvas.drawPath(
      flag,
      Paint()
        ..shader = LinearGradient(colors: [Color.lerp(a, Colors.white, 0.2)!, Color.lerp(a, Colors.black, 0.4)!]).createShader(const Rect.fromLTWH(-0.6, -0.9, 1.4, 1.1)),
    );
    _sparkle(canvas, Offset(0.05, -0.38 + w * 0.5), 0.2, _gold());
  }

  static void _helmet(Canvas canvas, double t) {
    final dome = Path()
      ..moveTo(-0.6, 0.55)
      ..lineTo(-0.6, -0.1)
      ..arcTo(const Rect.fromLTWH(-0.6, -0.8, 1.2, 1.4), pi, pi, false)
      ..lineTo(0.6, 0.55)
      ..close();
    canvas.drawPath(dome, _metal());
    canvas.drawPath(dome, _stroke(const Color(0xFF3A4458), 0.05));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.45, -0.05, 0.9, 0.16), const Radius.circular(0.06)), Paint()..color = const Color(0xFF14181F));
    canvas.drawLine(const Offset(0, -0.8), const Offset(0, -0.1), _stroke(const Color(0xFFC8962E), 0.07));
    final sway = sin(t * 2 * pi) * 0.1;
    final plume = Path()
      ..moveTo(0, -0.8)
      ..quadraticBezierTo(0.3 + sway, -1.1, 0.6 + sway, -0.75)
      ..quadraticBezierTo(0.3, -0.85, 0, -0.7)
      ..close();
    canvas.drawPath(plume, Paint()..color = const Color(0xFFE05A4F));
  }

  static void _meteor(Canvas canvas, double t) {
    final shake = sin(t * 8 * pi) * 0.03;
    canvas.translate(shake, -shake);
    final tail = Path()
      ..moveTo(-0.4, -0.2)
      ..lineTo(0.95, -1.0)
      ..lineTo(0.55, -0.35)
      ..lineTo(1.0, -0.55)
      ..lineTo(0.0, 0.35)
      ..close();
    canvas.drawPath(
      tail,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFE680), Color(0x00FF5A1E)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ).createShader(const Rect.fromLTWH(-0.5, -1.0, 1.5, 1.4)),
    );
    canvas.drawCircle(const Offset(-0.25, 0.3), 0.5, Paint()..color = const Color(0xFF5A3A2A));
    canvas.drawCircle(const Offset(-0.25, 0.3), 0.5, _stroke(const Color(0xFFFF8A3D), 0.06));
    canvas.drawCircle(const Offset(-0.4, 0.2), 0.1, Paint()..color = const Color(0xFF3A2418));
    canvas.drawCircle(const Offset(-0.1, 0.45), 0.08, Paint()..color = const Color(0xFF3A2418));
  }

  static void _phoenix(Canvas canvas, double t) {
    final flap = 0.8 + 0.3 * sin(t * 2 * pi);
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE680), Color(0xFFE5391E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-1, -0.7, 2, 1.4));
    for (final sign in const [-1.0, 1.0]) {
      canvas.save();
      canvas.scale(sign, 1.0);
      final wing = Path()
        ..moveTo(0.1, 0.1)
        ..cubicTo(0.5, -0.4 * flap, 0.9, -0.5 * flap, 1.0, -0.1)
        ..cubicTo(0.8, 0.0, 0.7, 0.2, 0.65, 0.45)
        ..cubicTo(0.45, 0.25, 0.3, 0.3, 0.1, 0.35)
        ..close();
      canvas.drawPath(wing, wingPaint);
      canvas.restore();
    }
    final tail = Path()
      ..moveTo(-0.15, 0.3)
      ..quadraticBezierTo(0, 1.0 + 0.05 * sin(t * 6 * pi), 0.15, 0.3)
      ..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFFFF9A2E));
    canvas.drawOval(const Rect.fromLTWH(-0.17, -0.2, 0.34, 0.6), Paint()..color = const Color(0xFFFFC857));
    canvas.drawCircle(const Offset(0, -0.3), 0.15, Paint()..color = const Color(0xFFFFE9A8));
    final beak = Path()
      ..moveTo(0, -0.28)
      ..lineTo(0.1, -0.18)
      ..lineTo(-0.1, -0.18)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFE5391E));
  }

  static void _tower(Canvas canvas, double t) {
    final stone = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFC1C7D2), Color(0xFF6C7587)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-0.6, -0.7, 1.2, 1.6));
    canvas.drawRect(const Rect.fromLTWH(-0.45, -0.35, 0.9, 1.2), stone);
    for (final x in const [-0.55, -0.14, 0.27]) {
      canvas.drawRect(Rect.fromLTWH(x, -0.62, 0.28, 0.27), stone);
    }
    canvas.drawRect(const Rect.fromLTWH(-0.45, -0.35, 0.9, 1.2), _stroke(const Color(0xFF2A3040), 0.04));
    final door = Path()
      ..moveTo(-0.17, 0.85)
      ..lineTo(-0.17, 0.45)
      ..arcTo(const Rect.fromLTWH(-0.17, 0.28, 0.34, 0.34), pi, pi, false)
      ..lineTo(0.17, 0.85)
      ..close();
    canvas.drawPath(door, Paint()..color = const Color(0xFF2A3040));
    final glow = 0.6 + 0.4 * sin(t * 4 * pi);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.06, -0.15, 0.12, 0.3), const Radius.circular(0.05)), Paint()..color = Color.fromRGBO(255, 210, 90, glow));
    final w = sin(t * 2 * pi) * 0.05;
    canvas.drawLine(const Offset(0, -0.62), const Offset(0, -0.95), _stroke(const Color(0xFFD9C08A), 0.03));
    final flag = Path()
      ..moveTo(0, -0.95)
      ..lineTo(0.3 + w, -0.88)
      ..lineTo(0, -0.78)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFFE05A4F));
  }
}
