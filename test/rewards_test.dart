import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farman_ravayan/game/economy.dart';
import 'package:farman_ravayan/game/rewards.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Economy.load();
  });

  test('daily reward grows with the streak and caps at seven days', () {
    expect(DailyReward.rewardFor(1), 20);
    expect(DailyReward.rewardFor(7), 80);
    expect(DailyReward.rewardFor(30), 80);
  });

  test('daily reward continues, resets and blocks double claims', () {
    final today = DateTime(2026, 11, 27);
    expect(DailyReward.compute(null, 0, today).streak, 1);
    expect(DailyReward.compute('2026-11-26', 3, today).streak, 4);
    expect(DailyReward.compute('2026-11-20', 3, today).streak, 1);
    expect(DailyReward.compute('2026-11-27', 3, today).canClaim, isFalse);
  });

  test('claiming twice on one day only pays once', () async {
    final day = DateTime(2026, 11, 27);
    final before = Economy.coins;
    expect(await DailyReward.claim(day), isNotNull);
    expect(await DailyReward.claim(day), isNull);
    expect(Economy.coins, before + 20);
  });

  test('an achievement can be claimed only once and only when complete', () async {
    final first = achievements.firstWhere((a) => a.id == 'first_win');
    expect(await AchievementStore.claim(first, const AchSnapshot()), isFalse);
    final before = Economy.coins;
    expect(await AchievementStore.claim(first, const AchSnapshot(won: 1)), isTrue);
    expect(await AchievementStore.claim(first, const AchSnapshot(won: 5)), isFalse);
    expect(Economy.coins, before + first.reward);
  });
}
