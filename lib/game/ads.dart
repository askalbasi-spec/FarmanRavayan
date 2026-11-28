import 'package:adivery/adivery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'economy.dart';
import 'rewards.dart';

/// Optional rewarded video ads through Adivery.
///
/// The IDs are given at build time with `--dart-define=ADIVERY_APP_ID=...` and
/// `--dart-define=ADIVERY_REWARDED_ID=...`. Without them ads stay disabled
/// and no ad button is shown.
class AdsService {
  static const appId = String.fromEnvironment('ADIVERY_APP_ID');
  static const rewardedId = String.fromEnvironment('ADIVERY_REWARDED_ID');

  /// Coins for one watched ad in the shop.
  static const shopReward = 20;
  static const dailyLimit = 6;
  static const _dayKey = 'ads_day';
  static const _countKey = 'ads_count';

  static bool get configured => appId.isNotEmpty && rewardedId.isNotEmpty;

  static bool _started = false;
  static bool _loaded = false;

  /// The last error the ad network reported, shown to help find problems.
  static String lastError = '';
  static int Function()? _pendingReward;
  static void Function(int)? _onGranted;

  static void init() {
    if (!configured || _started) return;
    try {
      AdiveryPlugin.initialize(appId);
      AdiveryPlugin.addListener(
        onError: (placement, error) => lastError = error,
        onRewardedLoaded: (placement) => _loaded = true,
        onRewardedClosed: (placement, isRewarded) => _closed(isRewarded),
      );
      AdiveryPlugin.prepareRewardedAd(rewardedId);
      _started = true;
    } catch (_) {
      _started = false;
    }
  }

  static Future<void> _closed(bool rewarded) async {
    final amount = _pendingReward;
    final callback = _onGranted;
    _pendingReward = null;
    _onGranted = null;
    _loaded = false;
    try {
      AdiveryPlugin.prepareRewardedAd(rewardedId);
    } catch (_) {}
    if (!rewarded || amount == null) return;
    final coins = amount();
    await _countView();
    await Economy.earn(coins);
    callback?.call(coins);
  }

  /// How many more ads may be watched today.
  static int remainingToday(String? savedDay, int savedCount, DateTime now) {
    if (savedDay != dayKey(now)) return dailyLimit;
    return (dailyLimit - savedCount).clamp(0, dailyLimit);
  }

  static Future<int> remaining([DateTime? now]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return remainingToday(prefs.getString(_dayKey), prefs.getInt(_countKey) ?? 0, now ?? DateTime.now());
    } catch (_) {
      return 0;
    }
  }

  static Future<void> _countView() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = dayKey(DateTime.now());
      final count = prefs.getString(_dayKey) == today ? (prefs.getInt(_countKey) ?? 0) : 0;
      await prefs.setString(_dayKey, today);
      await prefs.setInt(_countKey, count + 1);
    } catch (_) {}
  }

  /// Shows a rewarded ad. [reward] gives the coins to grant if it is watched
  /// to the end, and [onGranted] runs after they were added.
  /// Returns a message when the ad could not be shown, otherwise null.
  static Future<String?> show({required int Function() reward, void Function(int)? onGranted}) async {
    if (!configured) return 'تبلیغ هنوز فعال نشده است.';
    init();
    if (await remaining() <= 0) return 'سهمیه‌ی تبلیغ امروز تمام شد. فردا دوباره بیا.';
    try {
      var ready = _loaded || (await AdiveryPlugin.isLoaded(rewardedId)) == true;
      if (!ready) {
        lastError = '';
        AdiveryPlugin.prepareRewardedAd(rewardedId);
        // Give the network up to about 10 seconds to deliver an ad.
        for (var i = 0; i < 20 && !ready; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          ready = _loaded || (await AdiveryPlugin.isLoaded(rewardedId)) == true;
          if (!ready && lastError.isNotEmpty && i >= 2) break;
        }
      }
      if (!ready) {
        final detail = lastError.isEmpty ? 'پاسخی از آدیوری نیامد' : lastError;
        return 'تبلیغی آماده نیست؛ چند دقیقه بعد دوباره امتحان کن.\nپیام آدیوری: $detail';
      }
      _pendingReward = reward;
      _onGranted = onGranted;
      AdiveryPlugin.show(rewardedId);
      return null;
    } catch (_) {
      return 'نمایش تبلیغ ممکن نشد.';
    }
  }
}
