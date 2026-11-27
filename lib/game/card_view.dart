import 'package:flutter/material.dart';

import 'battle_engine.dart';
import 'card.dart';
import 'card_art.dart';

const _gold = Color(0xFFF0D69A);

/// A full card face: animated art, cost, name, description and stats.
class GameCardView extends StatelessWidget {
  const GameCardView({super.key, required this.card, this.animation, this.dimmed = false, this.showDescription = true});

  final GameCard card;
  final Animation<double>? animation;
  final bool dimmed;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final group = card.group;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final base = (w / 11).clamp(8.0, 20.0);
        return Opacity(
          opacity: dimmed ? 0.5 : 1.0,
          child: Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(group.secondary, Colors.white, 0.12)!, const Color(0xFF0C1422)],
              ),
              border: Border.all(color: group.primary, width: 1.6),
              borderRadius: BorderRadius.circular(w * 0.1),
              boxShadow: [BoxShadow(color: group.primary.withOpacity(0.35), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 11,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(w * 0.07),
                        child: CardArt(card: card, animation: animation),
                      ),
                      PositionedDirectional(
                        top: 2,
                        start: 2,
                        child: Container(
                          width: base * 2.1,
                          height: base * 2.1,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1B6FD1)),
                          child: Text('${card.cost}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: base * 1.2)),
                        ),
                      ),
                      PositionedDirectional(
                        top: 2,
                        end: 2,
                        child: Icon(group.icon, color: group.primary, size: base * 1.6),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w * 0.03),
                Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: _gold, fontSize: base * 1.15)),
                if (showDescription)
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Text(
                        card.fullDescription,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: base * 0.85),
                      ),
                    ),
                  ),
                _Stats(card: card, base: base),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.card, required this.base});

  final GameCard card;
  final double base;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    final isEquipment = card.type == CardType.equipment;
    final isSpell = card.type == CardType.spell;
    if (card.attack > 0 || (!isSpell && !isEquipment)) {
      chips.add(_chip(isEquipment ? '+${card.attack} ⚔' : '⚔ ${card.attack}', const Color(0xFFE05A4F)));
    }
    if (card.health > 0) {
      chips.add(_chip(isEquipment ? '+${card.health} ♥' : '♥ ${card.health}', const Color(0xFF3FAE6A)));
    }
    if (card.heal > 0) {
      chips.add(_chip('✚ ${card.heal}', const Color(0xFF3FC9B5)));
    }
    final spaced = <Widget>[];
    for (var i = 0; i < chips.length; i++) {
      if (i > 0) spaced.add(SizedBox(width: base * 0.4));
      spaced.add(chips[i]);
    }
    return FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: spaced));
  }

  Widget _chip(String text, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: base * 0.6, vertical: base * 0.15),
        decoration: BoxDecoration(color: color.withOpacity(0.25), borderRadius: BorderRadius.circular(base), border: Border.all(color: color.withOpacity(0.7))),
        child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: base * 1.0)),
      );
}

/// A compact unit on the battlefield, showing its current stats.
class UnitView extends StatelessWidget {
  const UnitView({super.key, required this.unit, this.animation});

  final Unit unit;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final card = unit.card;
    final hurt = unit.health < unit.maxHealth;
    return Opacity(
      opacity: unit.exhausted ? 0.72 : 1.0,
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF16233A),
          border: Border.all(color: unit.exhausted ? Colors.white24 : card.group.primary, width: 1.6),
          borderRadius: BorderRadius.circular(10),
          boxShadow: unit.exhausted ? null : [BoxShadow(color: card.group.primary.withOpacity(0.5), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(borderRadius: BorderRadius.circular(7), child: CardArt(card: card, animation: animation)),
            ),
            const SizedBox(height: 2),
            Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _gold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('⚔ ${unit.attack}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFFF8A7A))),
                Text('♥ ${unit.health}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: hurt ? Colors.redAccent : const Color(0xFF7CE0A0))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
