import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/game/battle_engine.dart';
import 'package:farman_ravayan/game/card.dart';

void main() {
  test('starter collection contains twenty cards across four types', () {
    expect(starterCards, hasLength(20));
    expect(starterCards.map((card) => card.type).toSet(), hasLength(4));
  });

  test('battle begins with commanders at twenty health', () {
    final engine = BattleEngine();
    expect(engine.state.playerHealth, 20);
    expect(engine.state.enemyHealth, 20);
    expect(engine.state.hand, hasLength(4));
    expect(engine.state.playerTurn, isTrue);
  });

  test('higher campaign difficulty increases enemy maximum health', () {
    final engine = BattleEngine(difficulty: 3);
    expect(engine.state.enemyHealth, 30);
    expect(engine.state.enemyMaxHealth, 30);
  });

  test('damage spells preserve enemy health above twenty on hard missions', () {
    final engine = BattleEngine(difficulty: 3);
    engine.state.hand = [starterCards.firstWhere((card) => card.id == 'fire')];
    engine.state.energy = 3;

    engine.playCard(0);

    expect(engine.state.enemyHealth, 27);
    expect(engine.state.message, 'کارت «گلوله آتشین» اجرا شد.');
  });

  test('a card cannot be played without enough energy', () {
    final engine = BattleEngine();
    engine.state.hand = [starterCards.firstWhere((card) => card.id == 'dragon')];
    engine.state.energy = 1;

    engine.playCard(0);

    expect(engine.state.hand, hasLength(1));
    expect(engine.state.energy, 1);
    expect(engine.state.message, 'انرژی کافی برای این کارت ندارید.');
  });

  test('ending a turn increases maximum energy and restores it', () {
    final engine = BattleEngine();
    engine.endPlayerTurn();
    expect(engine.state.maxEnergy, 2);
    expect(engine.state.energy, 2);
    expect(engine.state.playerTurn, isTrue);
  });
}
