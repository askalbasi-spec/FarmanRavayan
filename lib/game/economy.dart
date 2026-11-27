import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';

class PackPull {
  const PackPull(this.card, this.isNew);

  final GameCard card;
  final bool isNew;
}

/// Coins and the cards the player owns.
class Economy {
  static const coinsKey = 'eco_coins';
  static const ownedKey = 'eco_owned';
  static const packPrice = 60;
  static const duplicateRefund = 15;
  static const winReward = 25;
  static const lossReward = 5;

  static int coins = 100;
  static Set<String> owned = starterIds();

  static Set<String> starterIds() {
    final sorted = List<GameCard>.of(allCards)..sort((a, b) => a.cost.compareTo(b.cost));
    final cheap = allCards.where((c) => c.cost <= 2).length;
    return sorted.take(max(cheap, 12)).map((c) => c.id).toSet();
  }

  static List<GameCard> get ownedCards => allCards.where((c) => owned.contains(c.id)).toList();

  static bool owns(GameCard card) => owned.contains(card.id);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      coins = prefs.getInt(coinsKey) ?? 100;
      final saved = prefs.getStringList(ownedKey);
      owned = saved == null ? starterIds() : {...starterIds(), ...saved};
    } catch (_) {}
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(coinsKey, coins);
      await prefs.setStringList(ownedKey, owned.toList());
    } catch (_) {}
  }

  static Future<void> earn(int amount) async {
    coins += amount;
    await _save();
  }

  static Rarity _roll(Random random) {
    final v = random.nextInt(100);
    if (v < 60) return Rarity.common;
    if (v < 88) return Rarity.rare;
    if (v < 97) return Rarity.epic;
    return Rarity.legendary;
  }

  /// Buys a three-card pack. Returns null when the player cannot afford it.
  static Future<List<PackPull>?> buyPack([Random? random]) async {
    if (coins < packPrice) return null;
    final rng = random ?? Random();
    coins -= packPrice;
    final pulls = <PackPull>[];
    for (var i = 0; i < 3; i++) {
      final rarity = _roll(rng);
      final pool = allCards.where((c) => c.rarity == rarity).toList();
      final card = pool[rng.nextInt(pool.length)];
      final isNew = !owned.contains(card.id);
      if (isNew) {
        owned.add(card.id);
      } else {
        coins += duplicateRefund;
      }
      pulls.add(PackPull(card, isNew));
    }
    await _save();
    return pulls;
  }
}
