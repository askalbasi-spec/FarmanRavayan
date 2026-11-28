import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'economy.dart';
import 'themes.dart';

/// A coin pack sold through Cafe Bazaar. The [productId] must match the
/// product ID defined in the Bazaar developer panel exactly.
class CoinPack {
  const CoinPack(this.productId, this.coins, this.title);

  final String productId;
  final int coins;
  final String title;
}

const coinPacks = <CoinPack>[
  CoinPack('coins_100', 100, 'کیسه‌ی سکه'),
  CoinPack('coins_350', 350, 'صندوق سکه'),
  CoinPack('coins_900', 900, 'گنج سکه'),
];

const themeBundleId = 'themes_all';

enum BillingStatus { success, cancelled, unavailable, failed }

class BillingResult {
  const BillingResult(this.status, [this.message = '']);

  final BillingStatus status;
  final String message;
}

/// In-app purchases through Cafe Bazaar (Poolakey).
///
/// The public RSA key is given at build time with
/// `--dart-define=BAZAAR_RSA_KEY=...`; without it purchases stay disabled.
class BillingService {
  static const rsaKey = String.fromEnvironment('BAZAAR_RSA_KEY');
  static const _creditedKey = 'billing_credited_tokens';

  static bool get configured => rsaKey.isNotEmpty;
  static bool _connected = false;

  static Future<bool> _connect() async {
    if (!configured) return false;
    if (_connected) return true;
    var done = false;
    try {
      await FlutterPoolakey.connect(
        rsaKey,
        onSucceed: () {
          _connected = true;
          done = true;
        },
        onFailed: () {
          _connected = false;
          done = true;
        },
        onDisconnected: () => _connected = false,
      );
      // The callbacks arrive shortly after connect returns.
      for (var i = 0; i < 20 && !done; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    } catch (_) {
      _connected = false;
    }
    return _connected;
  }

  static CoinPack? _packFor(String productId) {
    for (final p in coinPacks) {
      if (p.productId == productId) return p;
    }
    return null;
  }

  static Future<Set<String>> _credited() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_creditedKey) ?? <String>[]).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> _markCredited(Set<String> tokens) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_creditedKey, tokens.toList());
    } catch (_) {}
  }

  /// Gives the coins for one purchase exactly once, then consumes it so the
  /// same pack can be bought again.
  static Future<void> _fulfil(PurchaseInfo info) async {
    if (info.productId == themeBundleId) {
      // A one-time purchase: unlock the themes and keep it unconsumed so it
      // can be restored later.
      await ThemeStore.unlockAll();
      return;
    }
    final pack = _packFor(info.productId);
    if (pack == null) return;
    final credited = await _credited();
    if (!credited.contains(info.purchaseToken)) {
      await Economy.earn(pack.coins);
      credited.add(info.purchaseToken);
      await _markCredited(credited);
    }
    try {
      await FlutterPoolakey.consume(info.purchaseToken);
    } catch (_) {}
  }

  static Future<BillingResult> buyThemeBundle() async {
    if (!configured) {
      return const BillingResult(BillingStatus.unavailable, 'پرداخت درون‌برنامه‌ای هنوز فعال نشده است.');
    }
    if (!await _connect()) {
      return const BillingResult(BillingStatus.unavailable, 'اتصال به کافه‌بازار برقرار نشد. برنامه‌ی بازار نصب و وارد حساب باشد.');
    }
    try {
      final info = await FlutterPoolakey.purchase(themeBundleId, payload: 'themes', dynamicPriceToken: '');
      await _fulfil(info);
      return const BillingResult(BillingStatus.success, 'همه‌ی تم‌ها باز شد.');
    } catch (e) {
      if (e.toString().toLowerCase().contains('cancel')) return const BillingResult(BillingStatus.cancelled, 'خرید لغو شد.');
      return const BillingResult(BillingStatus.failed, 'خرید کامل نشد.');
    }
  }

  static Future<BillingResult> buy(CoinPack pack) async {
    if (!configured) {
      return const BillingResult(BillingStatus.unavailable, 'پرداخت درون‌برنامه‌ای هنوز فعال نشده است.');
    }
    if (!await _connect()) {
      return const BillingResult(BillingStatus.unavailable, 'اتصال به کافه‌بازار برقرار نشد. برنامه‌ی بازار نصب و وارد حساب باشد.');
    }
    try {
      final info = await FlutterPoolakey.purchase(pack.productId, payload: 'coins', dynamicPriceToken: '');
      await _fulfil(info);
      return BillingResult(BillingStatus.success, '${pack.coins} سکه به حسابت اضافه شد.');
    } catch (e) {
      final text = e.toString().toLowerCase();
      if (text.contains('cancel')) return const BillingResult(BillingStatus.cancelled, 'خرید لغو شد.');
      return const BillingResult(BillingStatus.failed, 'خرید کامل نشد.');
    }
  }

  /// Credits purchases that were paid for but not delivered (for example when
  /// the app was closed during payment). Safe to call at startup.
  static Future<int> recoverPending() async {
    if (!await _connect()) return 0;
    var count = 0;
    try {
      final purchases = await FlutterPoolakey.getAllPurchasedProducts();
      for (final info in purchases) {
        if (_packFor(info.productId) == null && info.productId != themeBundleId) continue;
        await _fulfil(info);
        count++;
      }
    } catch (_) {}
    return count;
  }
}
