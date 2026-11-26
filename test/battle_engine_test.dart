import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/game/battle_engine.dart';
import 'package:farman_ravayan/game/card.dart';
import 'package:farman_ravayan/game/missions.dart';

GameCard card(String id) => allCards.firstWhere((c) => c.id == id);

/// An engine whose enemy has nothing to play, so tests are deterministic.
BattleEngine quietEngine({int difficulty = 1}) {
  final engine = BattleEngine(difficulty: difficulty, random: Random(7));
  engine.state.enemyHand.clear();
  engine.state.enemyDeck.clear();
  return engine;
}

void main() {
  test('collection has fifty unique cards in ten groups of five', () {
    expect(allCards, hasLength(50));
    expect(allCards.map((c) => c.id).toSet(), hasLength(50));
    expect(allCards.map((c) => c.type).toSet(), hasLength(4));
    for (final group in CardGroup.values) {
      expect(allCards.where((c) => c.group == group), hasLength(5), reason: group.name);
    }
    expect(CardGroup.values, hasLength(10));
  });

  test('there are ten story missions with unique titles and enemy decks', () {
    expect(missions, hasLength(10));
    expect(missions.map((m) => m.title).toSet(), hasLength(10));
    for (final mission in missions) {
      expect(mission.region, isNotEmpty);
      expect(mission.enemyGroups, isNotEmpty);
    }
  });

  test('a mission enemy deck only uses the groups of that mission', () {
    final mission = missions[3];
    final pool = allCards.where((c) => mission.enemyGroups.contains(c.group)).toList();
    final engine = BattleEngine(difficulty: 4, random: Random(3), enemyPool: pool);
    final enemyCards = [...engine.state.enemyHand, ...engine.state.enemyDeck];
    expect(enemyCards, isNotEmpty);
    expect(enemyCards.every((c) => mission.enemyGroups.contains(c.group)), isTrue);
  });

  test('every card is playable by the rules: spells deal or heal, equipment adds stats', () {
    for (final card in allCards) {
      switch (card.type) {
        case CardType.spell:
          expect(card.attack + card.heal, greaterThan(0), reason: card.id);
        case CardType.equipment:
          expect(card.attack + card.health, greaterThan(0), reason: card.id);
        case CardType.hero:
        case CardType.troop:
          expect(card.health, greaterThan(0), reason: card.id);
      }
    }
  });

  test('battle begins with commanders at twenty health', () {
    final engine = BattleEngine(random: Random(1));
    expect(engine.state.playerHealth, 20);
    expect(engine.state.enemyHealth, 20);
    expect(engine.state.hand, hasLength(4));
    expect(engine.state.enemyHand, hasLength(3));
    expect(engine.state.playerTurn, isTrue);
  });

  test('the same seed produces the same opening hand', () {
    final a = BattleEngine(random: Random(42));
    final b = BattleEngine(random: Random(42));
    expect(a.state.hand.map((c) => c.id), b.state.hand.map((c) => c.id));
  });

  test('higher campaign difficulty increases enemy maximum health', () {
    final engine = BattleEngine(difficulty: 3);
    expect(engine.state.enemyHealth, 26);
    expect(engine.state.enemyMaxHealth, 26);
    expect(BattleEngine(difficulty: 10).state.enemyMaxHealth, 47);
  });

  test('damage spells preserve enemy health above twenty on hard missions', () {
    final engine = BattleEngine(difficulty: 3);
    engine.state.hand = [card('fire')];
    engine.state.energy = 3;

    engine.playCard(0);

    expect(engine.state.enemyHealth, 23);
    expect(engine.state.message, 'کارت «گلوله آتشین» اجرا شد.');
  });

  test('a card cannot be played without enough energy', () {
    final engine = BattleEngine();
    engine.state.hand = [card('dragon')];
    engine.state.energy = 1;

    engine.playCard(0);

    expect(engine.state.hand, hasLength(1));
    expect(engine.state.energy, 1);
    expect(engine.state.message, 'انرژی کافی برای این کارت ندارید.');
  });

  test('ending a turn increases maximum energy and restores it', () {
    final engine = quietEngine();
    engine.endPlayerTurn();
    expect(engine.state.maxEnergy, 2);
    expect(engine.state.energy, 2);
    expect(engine.state.playerTurn, isTrue);
  });

  test('a freshly played unit cannot attack in the turn it was played', () {
    final engine = quietEngine();
    engine.state.hand = [card('berserker')];
    engine.state.energy = 4;

    engine.playCard(0);
    engine.endPlayerTurn();

    expect(engine.state.enemyHealth, 20);
    expect(engine.state.playerBoard.single.exhausted, isFalse);

    engine.endPlayerTurn();
    expect(engine.state.enemyHealth, 15);
  });

  test('units fight each other and die when their health reaches zero', () {
    final engine = quietEngine();
    final attacker = Unit(card('knight'))..exhausted = false;
    final defender = Unit(card('guard'));
    engine.state.playerBoard = [attacker];
    engine.state.enemyBoard = [defender];

    engine.endPlayerTurn();

    expect(engine.state.enemyBoard, isEmpty);
    expect(attacker.health, 2);
    expect(engine.state.enemyHealth, 20);
  });

  test('equipment needs a friendly unit and then strengthens it', () {
    final engine = quietEngine();
    engine.state.hand = [card('banner')];
    engine.state.energy = 5;

    engine.playCard(0);
    expect(engine.state.hand, hasLength(1));
    expect(engine.state.energy, 5);

    final unit = Unit(card('guard'));
    engine.state.playerBoard = [unit];
    engine.playCard(0);

    expect(engine.state.hand, isEmpty);
    expect(unit.attack, 3);
    expect(unit.health, 3);
  });

  test('a lethal spell ends the battle with a player victory', () {
    final engine = quietEngine();
    engine.state.enemyHealth = 3;
    engine.state.hand = [card('fire')];
    engine.state.energy = 3;

    engine.playCard(0);

    expect(engine.state.winner, Winner.player);
    expect(engine.state.isOver, isTrue);
  });

  test('playing a damage spell records damage and played events', () {
    final engine = quietEngine();
    engine.state.hand = [card('fire')];
    engine.state.energy = 3;

    engine.playCard(0);

    final kinds = engine.state.events.map((e) => e.kind).toList();
    expect(kinds, contains(BattleEventKind.played));
    final damage = engine.state.events.firstWhere((e) => e.kind == BattleEventKind.damage);
    expect(damage.amount, 3);
    expect(damage.onPlayerSide, isFalse);
  });

  test('a spell that also heals restores the casting commander', () {
    final engine = quietEngine();
    engine.state.playerHealth = 10;
    engine.state.hand = [card('sacrifice')];
    engine.state.energy = 3;

    engine.playCard(0);

    expect(engine.state.enemyHealth, 17);
    expect(engine.state.playerHealth, 13);
  });

  test('the enemy commander can defeat the player', () {
    final engine = quietEngine();
    engine.state.playerHealth = 2;
    engine.state.enemyHand = [card('fire')];
    engine.state.energy = 1;

    engine.endPlayerTurn();
    // The enemy has only one energy at the start, so it cannot cast yet.
    expect(engine.state.winner, isNull);

    engine.state.playerHealth = 2;
    engine.state.enemyHand = [card('scout')];
    engine.state.enemyBoard = [Unit(card('berserker'))..exhausted = false];
    engine.endPlayerTurn();

    expect(engine.state.winner, Winner.enemy);
  });

  test('drawing moves a card from the enemy deck to its hand without losing it', () {
    final engine = quietEngine();
    engine.state.enemyDeck = [card('scout'), card('guard'), card('wolf')];

    engine.endPlayerTurn();

    expect(engine.state.enemyHand, hasLength(1));
    expect(engine.state.enemyDeck, hasLength(2));
  });

  test('a full hand burns the next drawn card instead of overflowing', () {
    final engine = quietEngine();
    engine.state.hand = List<GameCard>.filled(BattleEngine.maxHandSize, card('guard'), growable: true);
    final deckBefore = engine.state.deck.length;

    engine.endPlayerTurn();

    expect(engine.state.hand, hasLength(BattleEngine.maxHandSize));
    expect(engine.state.deck, hasLength(deckBefore - 1));
  });
}
