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

  test('ending a turn increases maximum energy and restores it', () {
    final engine = BattleEngine();
    engine.endPlayerTurn();
    expect(engine.state.maxEnergy, 2);
    expect(engine.state.energy, 2);
    expect(engine.state.playerTurn, isTrue);
  });
}
