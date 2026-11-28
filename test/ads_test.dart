import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/game/ads.dart';
import 'package:farman_ravayan/game/rewards.dart';

void main() {
  test('daily ad limit counts down and resets on a new day', () {
    final today = DateTime(2026, 11, 28);
    final key = dayKey(today);
    expect(AdsService.remainingToday(null, 0, today), AdsService.dailyLimit);
    expect(AdsService.remainingToday(key, 2, today), AdsService.dailyLimit - 2);
    expect(AdsService.remainingToday(key, 99, today), 0);
    expect(AdsService.remainingToday('2026-11-27', 5, today), AdsService.dailyLimit);
  });

  test('without Adivery ids ads are off and show reports a message', () async {
    expect(AdsService.configured, isFalse);
    expect(await AdsService.show(reward: () => 1), isNotNull);
  });
}
