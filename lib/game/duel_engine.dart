import 'dart:math';

import 'battle_engine.dart';
import 'card.dart';

/// One of the two human players in a duel.
class DuelPlayer {
  DuelPlayer(this.name, this.deck, this.hand)
      : health = DuelEngine.startHealth,
        maxHealth = DuelEngine.startHealth;

  final String name;
  final List<GameCard> deck;
  final List<GameCard> hand;
  final List<Unit> board = [];
  int health;
  final int maxHealth;
  int maxEnergy = 0;
  int energy = 0;
}

/// A two-human duel on one device. Same rules as the battle against the
/// computer, but both commanders are played by people taking turns.
class DuelEngine {
  DuelEngine({String firstName = 'بازیکن ۱', String secondName = 'بازیکن ۲', Random? random}) {
    final rng = random ?? Random();
    final deckA = (List<GameCard>.of(allCards)..shuffle(rng)).take(30).toList();
    final deckB = (List<GameCard>.of(allCards)..shuffle(rng)).take(30).toList();
    first = DuelPlayer(firstName, deckA.skip(4).toList(), deckA.take(4).toList());
    // The second player acts later, so they begin with an extra card.
    second = DuelPlayer(secondName, deckB.skip(5).toList(), deckB.take(5).toList());
    _startTurn(first);
  }

  static const int startHealth = 30;
  static const int maxHand = 7;

  late final DuelPlayer first;
  late final DuelPlayer second;
  bool firstTurn = true;
  int turnNumber = 1;
  Winner? winner;
  String message = '';

  /// Index (0 or 1) of the winner, or null while the duel goes on.
  int? get winnerIndex => winner == null ? null : (winner == Winner.player ? 0 : 1);

  DuelPlayer get current => firstTurn ? first : second;
  DuelPlayer get other => firstTurn ? second : first;
  bool get isOver => winner != null;

  void _startTurn(DuelPlayer p) {
    p.maxEnergy = (p.maxEnergy + 1).clamp(1, 10);
    p.energy = p.maxEnergy;
    for (final u in p.board) {
      u.exhausted = false;
    }
    if (turnNumber > 1 || p != first) _draw(p);
  }

  void _draw(DuelPlayer p) {
    if (p.deck.isEmpty) return;
    final card = p.deck.removeAt(0);
    if (p.hand.length < maxHand) p.hand.add(card);
  }

  bool canPlay(int index) {
    if (isOver || index < 0 || index >= current.hand.length) return false;
    final card = current.hand[index];
    if (card.cost > current.energy) return false;
    if (card.type == CardType.equipment && current.board.isEmpty) return false;
    return true;
  }

  /// Plays a card; returns false if it cannot be played now.
  bool playCard(int index) {
    if (!canPlay(index)) return false;
    final me = current;
    final card = me.hand.removeAt(index);
    me.energy -= card.cost;
    switch (card.type) {
      case CardType.spell:
        if (card.attack > 0) _hit(other, card.attack);
        if (card.heal > 0) _heal(me, card.heal);
        break;
      case CardType.equipment:
        final target = me.board.reduce((a, b) => b.attack > a.attack ? b : a);
        target.attack += card.attack;
        target.health += card.health;
        target.maxHealth += card.health;
        break;
      case CardType.hero:
      case CardType.troop:
        me.board.add(Unit(card));
        _battlecry(card, me);
        break;
    }
    message = '${me.name}: «${card.name}»';
    _check();
    return true;
  }

  void _battlecry(GameCard card, DuelPlayer me) {
    final info = card.ability;
    if (info == null) return;
    switch (info.kind) {
      case Ability.healSelf:
        _heal(me, info.amount);
        break;
      case Ability.draw:
        _draw(me);
        break;
      case Ability.strikeEnemy:
        _hit(other, info.amount);
        break;
    }
  }

  void _hit(DuelPlayer p, int amount) {
    p.health = (p.health - amount).clamp(0, p.maxHealth);
  }

  void _heal(DuelPlayer p, int amount) {
    p.health = (p.health + amount).clamp(0, p.maxHealth);
  }

  void _check() {
    if (winner != null) return;
    if (second.health <= 0) {
      winner = Winner.player;
    } else if (first.health <= 0) {
      winner = Winner.enemy;
    }
  }

  /// Ready units attack, then the other player's turn begins.
  void endTurn() {
    if (isOver) return;
    final me = current;
    final foe = other;
    for (final unit in me.board.where((u) => !u.exhausted).toList()) {
      if (isOver) return;
      if (!unit.isAlive || unit.attack <= 0) continue;
      if (foe.board.isEmpty) {
        _hit(foe, unit.attack);
        _check();
      } else {
        final target = foe.board.first;
        target.health -= unit.attack;
        unit.health -= target.attack;
        me.board.removeWhere((u) => !u.isAlive);
        foe.board.removeWhere((u) => !u.isAlive);
      }
    }
    if (isOver) return;
    firstTurn = !firstTurn;
    if (firstTurn) turnNumber++;
    _startTurn(current);
    message = 'نوبت ${current.name}';
  }
}
