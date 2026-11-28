import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farman_ravayan/game/battle_engine.dart';
import 'package:farman_ravayan/game/card.dart';
import 'package:farman_ravayan/game/duel_engine.dart';
import 'package:farman_ravayan/game/duel_screen.dart';

GameCard card(String id) => allCards.firstWhere((c) => c.id == id);

void main() {
  test('duel starts with player one, 4 and 5 cards, and 1 energy', () {
    final e = DuelEngine(random: Random(1));
    expect(e.firstTurn, isTrue);
    expect(e.first.hand.length, 4);
    expect(e.second.hand.length, 5);
    expect(e.current.energy, 1);
    expect(e.first.health, 30);
    expect(e.second.health, 30);
  });

  test('turns alternate and energy grows for each player', () {
    final e = DuelEngine(random: Random(2));
    e.endTurn();
    expect(e.firstTurn, isFalse);
    expect(e.current.maxEnergy, 1);
    e.endTurn();
    expect(e.firstTurn, isTrue);
    expect(e.current.maxEnergy, 2);
    expect(e.turnNumber, 2);
  });

  test('a spell damages the other player and a medic heals the caster', () {
    final e = DuelEngine(random: Random(3));
    e.first.energy = 10;
    e.first.health = 10;
    e.first.hand
      ..clear()
      ..add(card('medic'));
    expect(e.playCard(0), isTrue);
    expect(e.first.health, 13);
    expect(e.first.board.length, 1);
  });

  test('units attack the enemy commander when the other board is empty', () {
    final e = DuelEngine(random: Random(4));
    final unit = Unit(card('guard'))..exhausted = false;
    e.first.board.add(unit);
    final before = e.second.health;
    e.endTurn();
    expect(e.second.health, before - unit.attack);
  });

  test('reducing a commander to zero ends the duel with a winner', () {
    final e = DuelEngine(random: Random(5));
    e.second.health = 1;
    final unit = Unit(card('guard'))..exhausted = false;
    e.first.board.add(unit);
    e.endTurn();
    expect(e.isOver, isTrue);
    expect(e.winnerIndex, 0);
  });

  test('equipment cannot be played without a friendly unit', () {
    final e = DuelEngine(random: Random(6));
    e.first.energy = 10;
    e.first.hand
      ..clear()
      ..add(allCards.firstWhere((c) => c.type == CardType.equipment));
    expect(e.canPlay(0), isFalse);
  });

  testWidgets('the duel screen asks to pass the phone and then shows the hand', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: DuelScreen(firstName: 'الف', secondName: 'ب')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('گوشی را به الف بده'), findsOneWidget);
    await tester.tap(find.text('الف آماده است'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('پایان نوبت'), findsOneWidget);
    await tester.tap(find.text('پایان نوبت'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('گوشی را به ب بده'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
