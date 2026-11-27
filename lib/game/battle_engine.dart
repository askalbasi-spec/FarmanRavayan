import 'dart:math';

import 'card.dart';

enum Winner { player, enemy }

enum BattleEventKind { played, damage, heal }

/// A visible thing that happened during a call, replayed by the UI as animation.
class BattleEvent {
  const BattleEvent(this.kind, {required this.onPlayerSide, this.amount = 0, this.card});

  final BattleEventKind kind;

  /// For `played` the side that played the card; for `damage` and `heal` the
  /// side whose commander was affected.
  final bool onPlayerSide;
  final int amount;
  final GameCard? card;
}

/// A card that is on the battlefield, with its own mutable stats.
class Unit {
  Unit(this.card)
      : attack = card.attack,
        health = card.health,
        maxHealth = card.health;

  final GameCard card;
  int attack;
  int health;
  int maxHealth;

  /// A unit cannot attack during the turn in which it was played.
  bool exhausted = true;

  String get name => card.name;
  bool get isAlive => health > 0;
}

class BattleState {
  BattleState({
    required this.playerHealth,
    required this.enemyHealth,
    required this.playerMaxHealth,
    required this.enemyMaxHealth,
    required this.energy,
    required this.maxEnergy,
    required this.hand,
    required this.playerBoard,
    required this.enemyBoard,
    required this.deck,
    required this.enemyDeck,
    required this.enemyHand,
    List<BattleEvent>? events,
    this.playerTurn = true,
    this.message = 'نوبت شماست؛ یک کارت انتخاب کنید.',
    this.winner,
  }) : events = events ?? [];

  int playerHealth;
  int enemyHealth;
  final int playerMaxHealth;
  final int enemyMaxHealth;
  int energy;
  int maxEnergy;
  List<GameCard> hand;
  List<Unit> playerBoard;
  List<Unit> enemyBoard;
  List<GameCard> deck;
  List<GameCard> enemyDeck;
  List<GameCard> enemyHand;
  bool playerTurn;
  String message;
  Winner? winner;
  final List<BattleEvent> events;

  bool get isOver => winner != null;
}

class BattleEngine {
  BattleEngine({this.difficulty = 1, Random? random, List<GameCard>? enemyPool, List<GameCard>? playerDeck}) : _random = random ?? Random() {
    final source = (playerDeck != null && playerDeck.length >= 8) ? playerDeck : allCards;
    final shuffled = List<GameCard>.of(source)..shuffle(_random);
    final basePool = (enemyPool == null || enemyPool.isEmpty) ? allCards : enemyPool;
    // Early missions only face cheaper cards so beginners can win.
    final capped = basePool.where((c) => c.cost <= difficulty + 2).toList();
    final pool = capped.length >= 8 ? capped : basePool;
    final enemyShuffled = <GameCard>[...pool, ...pool]..shuffle(_random);
    final enemyMaxHealth = 20 + ((difficulty - 1).clamp(0, 9) * 3);
    state = BattleState(
      playerHealth: 30,
      enemyHealth: enemyMaxHealth,
      playerMaxHealth: 30,
      enemyMaxHealth: enemyMaxHealth,
      energy: 1,
      maxEnergy: 1,
      hand: shuffled.take(4).toList(),
      playerBoard: [],
      enemyBoard: [],
      deck: shuffled.skip(4).take(26).toList(),
      enemyHand: enemyShuffled.take(3).toList(),
      enemyDeck: enemyShuffled.skip(3).take(27).toList(),
    );
  }

  final int difficulty;
  final Random _random;
  static const int maxHandSize = 7;

  late final BattleState state;

  void playCard(int handIndex) {
    if (state.isOver || !state.playerTurn || handIndex < 0 || handIndex >= state.hand.length) return;
    final card = state.hand[handIndex];
    if (card.cost > state.energy) {
      state.message = 'انرژی کافی برای این کارت ندارید.';
      return;
    }
    if (!_canPlay(card, state.playerBoard)) {
      state.message = 'برای تجهیزات به یک نیرو در میدان نیاز دارید.';
      return;
    }
    state.energy -= card.cost;
    state.hand.removeAt(handIndex);
    _resolve(card, player: true);
    if (!state.isOver) state.message = 'کارت «${card.name}» اجرا شد.';
  }

  void endPlayerTurn() {
    if (state.isOver || !state.playerTurn) return;
    state.playerTurn = false;
    _attackPhase(player: true);
    if (state.isOver) return;
    _enemyTurn();
    if (state.isOver) return;
    state.maxEnergy = (state.maxEnergy + 1).clamp(1, 10);
    state.energy = state.maxEnergy;
    _draw(player: true);
    state.playerTurn = true;
    state.message = 'نوبت شماست؛ انرژی بازیابی شد.';
  }

  bool _canPlay(GameCard card, List<Unit> ownBoard) {
    if (card.type == CardType.equipment) return ownBoard.isNotEmpty;
    return true;
  }

  void _enemyTurn() {
    state.message = 'فرمانده دشمن در حال حرکت است...';
    // Harder missions give the enemy extra energy.
    var budget = (state.maxEnergy + (difficulty >= 10 ? 3 : (difficulty >= 7 ? 2 : (difficulty >= 4 ? 1 : 0)))).clamp(1, 10);
    while (!state.isOver) {
      final playable = state.enemyHand
          .where((c) => c.cost <= budget && _canPlay(c, state.enemyBoard))
          .toList();
      if (playable.isEmpty) break;
      final card = _chooseEnemyCard(playable);
      budget -= card.cost;
      state.enemyHand.remove(card);
      _resolve(card, player: false);
    }
    if (state.isOver) return;
    _attackPhase(player: false);
    if (state.isOver) return;
    _draw(player: false);
    state.message = 'دشمن حمله کرد؛ نوبت شماست.';
  }

  GameCard _chooseEnemyCard(List<GameCard> options) {
    if (difficulty <= 2) return options[_random.nextInt(options.length)];
    GameCard best = options.first;
    var bestScore = _score(best);
    for (final card in options.skip(1)) {
      final score = _score(card);
      if (score > bestScore) {
        best = card;
        bestScore = score;
      }
    }
    return best;
  }

  double _score(GameCard card) {
    switch (card.type) {
      case CardType.spell:
        final heal = state.enemyHealth < state.enemyMaxHealth ? card.heal.toDouble() : 0.0;
        // A lethal spell is always the best option.
        if (card.attack >= state.playerHealth) return 1000;
        return card.attack * 1.5 + heal;
      case CardType.equipment:
        return (card.attack + card.health).toDouble();
      case CardType.hero:
      case CardType.troop:
        return (card.attack * 1.2 + card.health).toDouble();
    }
  }

  /// Each ready unit attacks the first enemy unit, or the commander when the
  /// opposing board is empty. Units that fight trade damage and die at 0 health.
  void _attackPhase({required bool player}) {
    final own = player ? state.playerBoard : state.enemyBoard;
    final opposing = player ? state.enemyBoard : state.playerBoard;
    final attackers = own.where((u) => !u.exhausted).toList();
    for (final unit in attackers) {
      if (state.isOver) return;
      if (!unit.isAlive || unit.attack <= 0) continue;
      if (opposing.isEmpty) {
        if (player) {
          _damageCommander(playerSide: false, amount: unit.attack);
        } else {
          _damageCommander(playerSide: true, amount: unit.attack);
        }
        _checkWinner();
      } else {
        final target = opposing.first;
        target.health -= unit.attack;
        unit.health -= target.attack;
        own.removeWhere((u) => !u.isAlive);
        opposing.removeWhere((u) => !u.isAlive);
      }
    }
    if (state.isOver) return;
    for (final unit in own) {
      unit.exhausted = false;
    }
  }

  void _resolve(GameCard card, {required bool player}) {
    final ownBoard = player ? state.playerBoard : state.enemyBoard;
    state.events.add(BattleEvent(BattleEventKind.played, onPlayerSide: player, card: card));
    switch (card.type) {
      case CardType.spell:
        if (card.attack > 0) _damageCommander(playerSide: !player, amount: card.attack);
        if (card.heal > 0) _healCommander(playerSide: player, amount: card.heal);
        break;
      case CardType.equipment:
        if (ownBoard.isNotEmpty) {
          final target = ownBoard.reduce((a, b) => b.attack > a.attack ? b : a);
          target.attack += card.attack;
          target.health += card.health;
          target.maxHealth += card.health;
        }
        break;
      case CardType.hero:
      case CardType.troop:
        ownBoard.add(Unit(card));
        _battlecry(card, player);
        break;
    }
    _checkWinner();
  }

  void _battlecry(GameCard card, bool player) {
    final info = card.ability;
    if (info == null) return;
    switch (info.kind) {
      case Ability.healSelf:
        _healCommander(playerSide: player, amount: info.amount);
        break;
      case Ability.draw:
        _draw(player: player);
        break;
      case Ability.strikeEnemy:
        _damageCommander(playerSide: !player, amount: info.amount);
        break;
    }
  }

  void _damageCommander({required bool playerSide, required int amount}) {
    if (playerSide) {
      final before = state.playerHealth;
      state.playerHealth = (before - amount).clamp(0, state.playerMaxHealth);
      state.events.add(BattleEvent(BattleEventKind.damage, onPlayerSide: true, amount: before - state.playerHealth));
    } else {
      final before = state.enemyHealth;
      state.enemyHealth = (before - amount).clamp(0, state.enemyMaxHealth);
      state.events.add(BattleEvent(BattleEventKind.damage, onPlayerSide: false, amount: before - state.enemyHealth));
    }
  }

  void _healCommander({required bool playerSide, required int amount}) {
    if (playerSide) {
      final before = state.playerHealth;
      state.playerHealth = (before + amount).clamp(0, state.playerMaxHealth);
      state.events.add(BattleEvent(BattleEventKind.heal, onPlayerSide: true, amount: state.playerHealth - before));
    } else {
      final before = state.enemyHealth;
      state.enemyHealth = (before + amount).clamp(0, state.enemyMaxHealth);
      state.events.add(BattleEvent(BattleEventKind.heal, onPlayerSide: false, amount: state.enemyHealth - before));
    }
  }

  void _checkWinner() {
    if (state.winner != null) return;
    if (state.enemyHealth <= 0) {
      state.winner = Winner.player;
      state.message = 'پیروزی! فرمانده دشمن شکست خورد.';
    } else if (state.playerHealth <= 0) {
      state.winner = Winner.enemy;
      state.message = 'فرمانده شما شکست خورد.';
    }
  }

  void _draw({required bool player}) {
    final source = player ? state.deck : state.enemyDeck;
    final destination = player ? state.hand : state.enemyHand;
    if (source.isEmpty) return;
    final card = source.removeAt(0);
    // When the hand is full the drawn card is burned, as in most card games.
    if (destination.length < maxHandSize) destination.add(card);
  }
}
