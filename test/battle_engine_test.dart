import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/game/battle_engine.dart';
import 'package:farman_ravayan/game/card.dart';

GameCard card(String id) => starterCards.firstWhere((c) => c.id == id);

/// An engine whose enemy has nothing to play, so tests are deterministic.
BattleEngine quietEngine({int difficulty = 1}) {
  final engine = BattleEngine(difficulty: difficulty, random: Random(7));
  engine.state.enemyHand.clear();
  engine.state.enemyDeck.clear();
  return engine;
}

void main() {
  test('starter collection contains twenty cards across four types', () {
    expect(starterCards, hasLength(20));
    expect(starterCards.map((card) => card.type).toSet(), hasLength(4));
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
    expect(engine.state.enemyHealth, 30);
    expect(engine.state.enemyMaxHealth, 30);
  });

  test('damage spells preserve enemy health above twenty on hard missions', () {
    final engine = BattleEngine(difficulty: 3);
    engine.state.hand = [card('fire')];
    engine.state.energy = 3;

    engine.playCard(0);

    expect(engine.state.enemyHealth, 27);
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
    engine.state.hand = [card('assassin')];
    engine.state.energy = 3;

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
    engine.state.enemyBoard = [Unit(card('assassin'))..exhausted = false];
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
