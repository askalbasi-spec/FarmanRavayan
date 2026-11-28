import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/game/billing.dart';

void main() {
  test('coin packs have unique product ids and positive coins', () {
    final ids = coinPacks.map((p) => p.productId).toSet();
    expect(ids.length, coinPacks.length);
    expect(coinPacks.every((p) => p.coins > 0), isTrue);
  });

  test('without a Bazaar key purchases report unavailable instead of crashing', () async {
    final result = await BillingService.buy(coinPacks.first);
    expect(result.status, BillingStatus.unavailable);
    expect(await BillingService.recoverPending(), 0);
  });
}
