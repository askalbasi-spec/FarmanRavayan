import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';
import 'economy.dart';
import 'profile.dart';

String dayKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class DailyStatus {
  const DailyStatus({required this.canClaim, required this.streak, required this.reward});

  final bool canClaim;

  /// The streak after claiming today (or the current one if already claimed).
  final int streak;
  final int reward;
}

/// A reward for opening the game every day; a longer streak pays more.
class DailyReward {
  static const lastKey = 'daily_last_claim';
  static const streakKey = 'daily_streak';

  static int rewardFor(int streak) => 20 + 10 * (streak.clamp(1, 7) - 1);

  static DailyStatus compute(String? last, int streak, DateTime now) {
    final today = dayKey(now);
    if (last == today) return DailyStatus(canClaim: false, streak: streak, reward: rewardFor(streak));
    final yesterday = dayKey(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)));
    final next = last == yesterday ? streak + 1 : 1;
    return DailyStatus(canClaim: true, streak: next, reward: rewardFor(next));
  }

  static Future<DailyStatus> status([DateTime? now]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return compute(prefs.getString(lastKey), prefs.getInt(streakKey) ?? 0, now ?? DateTime.now());
    } catch (_) {
      return const DailyStatus(canClaim: false, streak: 0, reward: 0);
    }
  }

  /// Claims today's reward and returns it, or null when already claimed.
  static Future<DailyStatus?> claim([DateTime? now]) async {
    final time = now ?? DateTime.now();
    final s = await status(time);
    if (!s.canClaim) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(lastKey, dayKey(time));
      await prefs.setInt(streakKey, s.streak);
    } catch (_) {}
    await Economy.earn(s.reward);
    return s;
  }
}

class AchSnapshot {
  const AchSnapshot({this.won = 0, this.played = 0, this.missions = 0, this.cards = 0, this.packs = 0, this.streak = 0});

  final int won;
  final int played;
  final int missions;
  final int cards;
  final int packs;
  final int streak;
}

class Achievement {
  const Achievement(this.id, this.title, this.description, this.target, this.reward, this.progress);

  final String id;
  final String title;
  final String description;
  final int target;
  final int reward;
  final int Function(AchSnapshot) progress;
}

final achievements = <Achievement>[
  Achievement('first_win', 'نخستین پیروزی', 'یک نبرد را ببر', 1, 30, (s) => s.won),
  Achievement('win_10', 'جنگجوی کهنه‌کار', 'ده نبرد را ببر', 10, 80, (s) => s.won),
  Achievement('win_50', 'افسانه‌ی میدان', 'پنجاه نبرد را ببر', 50, 200, (s) => s.won),
  Achievement('play_25', 'همیشه در میدان', 'بیست‌وپنج نبرد انجام بده', 25, 60, (s) => s.played),
  Achievement('mission_3', 'آغاز سفر', 'سه مأموریت کارزار را کامل کن', 3, 50, (s) => s.missions),
  Achievement('mission_10', 'تاج‌دار اژدها', 'هر ده مأموریت را کامل کن', 10, 200, (s) => s.missions),
  Achievement('cards_25', 'گردآورنده', 'بیست‌وپنج کارت داشته باش', 25, 80, (s) => s.cards),
  Achievement('cards_50', 'مجموعه‌دار بزرگ', 'همه‌ی ۵۰ کارت را داشته باش', 50, 300, (s) => s.cards),
  Achievement('packs_5', 'بسته‌گشا', 'پنج بسته‌ی کارت باز کن', 5, 60, (s) => s.packs),
  Achievement('streak_7', 'هفته‌ی وفاداری', 'هفت روز پشت‌سرهم وارد بازی شو', 7, 100, (s) => s.streak),
];

class AchievementStore {
  static const claimedKey = 'ach_claimed';
  static const packsKey = 'stats_packs';

  static Future<void> countPack() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(packsKey, (prefs.getInt(packsKey) ?? 0) + 1);
    } catch (_) {}
  }

  static Future<AchSnapshot> snapshot() async {
    await Economy.load();
    final stats = await ProfileStore.loadStats();
    final missions = await ProfileStore.completedMissions();
    var packs = 0;
    var streak = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      packs = prefs.getInt(packsKey) ?? 0;
      streak = prefs.getInt(DailyReward.streakKey) ?? 0;
    } catch (_) {}
    return AchSnapshot(won: stats.won, played: stats.played, missions: missions, cards: Economy.owned.length.clamp(0, allCards.length), packs: packs, streak: streak);
  }

  static Future<Set<String>> claimed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(claimedKey) ?? <String>[]).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<bool> claim(Achievement a, AchSnapshot snap) async {
    final done = await claimed();
    if (done.contains(a.id) || a.progress(snap) < a.target) return false;
    done.add(a.id);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(claimedKey, done.toList());
    } catch (_) {}
    await Economy.earn(a.reward);
    return true;
  }
}
