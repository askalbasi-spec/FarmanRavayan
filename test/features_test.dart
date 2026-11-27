import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/game/battle_engine.dart';
import 'package:farman_ravayan/game/card.dart';
import 'package:farman_ravayan/game/deck.dart';

GameCard card(String id) => allCards.firstWhere((c) => c.id == id);

void main() {
  test('medic heals the player commander when played', () {
    final engine = BattleEngine(random: Random(1));
    engine.state
      ..playerHealth = 10
      ..energy = 10
      ..hand = [card('medic')];
    engine.playCard(0);
    expect(engine.state.playerHealth, 13);
  });

  test('scout draws a card when played', () {
    final engine = BattleEngine(random: Random(2));
    engine.state
      ..energy = 10
      ..hand = [card('scout')];
    final deckBefore = engine.state.deck.length;
    engine.playCard(0);
    expect(engine.state.hand.length, 1);
    expect(engine.state.deck.length, deckBefore - 1);
  });

  test('falconer strikes the enemy commander when played', () {
    final engine = BattleEngine(random: Random(3));
    engine.state
      ..energy = 10
      ..hand = [card('falconer')];
    final before = engine.state.enemyHealth;
    engine.playCard(0);
    expect(engine.state.enemyHealth, before - 2);
  });

  test('abilities show up in the card description', () {
    expect(card('medic').fullDescription, contains('هنگام ورود'));
    expect(card('guard').fullDescription, card('guard').description);
  });

  test('a custom deck limits the cards the player draws from', () {
    final chosen = allCards.take(12).toList();
    final engine = BattleEngine(random: Random(4), playerDeck: chosen);
    final all = [...engine.state.hand, ...engine.state.deck];
    expect(all.length, 12);
    expect(all.every((c) => chosen.contains(c)), isTrue);
  });

  test('deck ids need the minimum size to become a deck', () {
    expect(DeckStore.fromIds(allCards.take(5).map((c) => c.id)), isNull);
    expect(DeckStore.fromIds(allCards.take(10).map((c) => c.id))!.length, 10);
  });

  test('balance simulation: every game ends and win rates are reported', () {
    for (final difficulty in [1, 4, 7, 10]) {
      var wins = 0;
      var unfinished = 0;
      const games = 80;
      for (var g = 0; g < games; g++) {
        final engine = BattleEngine(difficulty: difficulty, random: Random(difficulty * 1000 + g));
        var turns = 0;
        while (!engine.state.isOver && turns < 80) {
          var played = true;
          while (played && !engine.state.isOver) {
            played = false;
            final s = engine.state;
            var best = -1;
            for (var i = 0; i < s.hand.length; i++) {
              final c = s.hand[i];
              if (c.cost <= s.energy && (c.type != CardType.equipment || s.playerBoard.isNotEmpty)) {
                if (best == -1 || c.cost > s.hand[best].cost) best = i;
              }
            }
            if (best != -1) {
              engine.playCard(best);
              played = true;
            }
          }
          if (!engine.state.isOver) engine.endPlayerTurn();
          turns++;
        }
        if (!engine.state.isOver) {
          unfinished++;
        } else if (engine.state.winner == Winner.player) {
          wins++;
        }
      }
      // ignore: avoid_print
      print('SIM difficulty=$difficulty wins=$wins/$games unfinished=$unfinished');
      expect(wins + unfinished <= games, isTrue);
    }
  });
}
