import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farman_ravayan/game/card.dart';
import 'package:farman_ravayan/game/economy.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Economy.load();
  });

  test('every rarity has cards and the starter set can make a deck', () {
    for (final r in Rarity.values) {
      expect(allCards.where((c) => c.rarity == r), isNotEmpty);
    }
    expect(Economy.starterIds().length, greaterThanOrEqualTo(12));
    expect(Economy.owned.length, lessThan(allCards.length));
  });

  test('buying a pack costs coins, returns three cards and unlocks new ones', () async {
    final startCoins = Economy.coins;
    final startOwned = Economy.owned.length;
    final pulls = await Economy.buyPack(Random(7));
    expect(pulls, isNotNull);
    expect(pulls!.length, 3);
    final fresh = pulls.where((p) => p.isNew).length;
    final dupes = pulls.length - fresh;
    expect(Economy.owned.length, startOwned + fresh);
    expect(Economy.coins, startCoins - Economy.packPrice + dupes * Economy.duplicateRefund);
  });

  test('a pack cannot be bought without enough coins', () async {
    Economy.coins = 10;
    expect(await Economy.buyPack(), isNull);
    expect(Economy.coins, 10);
  });

  test('earning coins adds to the balance', () async {
    final before = Economy.coins;
    await Economy.earn(25);
    expect(Economy.coins, before + 25);
  });
}
