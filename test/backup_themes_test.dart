import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farman_ravayan/game/backup.dart';
import 'package:farman_ravayan/game/economy.dart';
import 'package:farman_ravayan/game/themes.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Economy.load();
    await ThemeStore.load();
  });

  test('backup codes round-trip every supported value type', () {
    final values = <String, Object>{'a': 'سلام', 'b': 5, 'c': true, 'd': 1.5, 'e': <String>['x', 'y']};
    final decoded = BackupService.decode(BackupService.encode(values))!;
    expect(decoded['a'], 'سلام');
    expect(decoded['b'], 5);
    expect(decoded['c'], true);
    expect(decoded['d'], 1.5);
    expect(decoded['e'], ['x', 'y']);
  });

  test('invalid backup codes are rejected', () {
    expect(BackupService.decode('hello'), isNull);
    expect(BackupService.decode('FR1:@@@'), isNull);
  });

  test('restoring a backup brings back coins', () async {
    SharedPreferences.setMockInitialValues({'eco_coins': 777});
    final code = await BackupService.export();
    SharedPreferences.setMockInitialValues({'eco_coins': 5});
    expect(await BackupService.restore(code), isTrue);
    expect(Economy.coins, 777);
  });

  test('themes: coin purchase spends coins, unlocks and selects the theme', () async {
    final forest = gameThemes.firstWhere((t) => t.id == 'forest');
    Economy.coins = 100;
    expect(await ThemeStore.buy(forest), isFalse);
    expect(ThemeStore.owns(forest), isFalse);
    Economy.coins = 400;
    expect(await ThemeStore.buy(forest), isTrue);
    expect(Economy.coins, 400 - forest.price);
    expect(ThemeStore.selectedId, 'forest');
  });

  test('five fantasy themes exist and the first is free', () {
    expect(gameThemes.length, 5);
    expect(gameThemes.first.price, 0);
  });
}
