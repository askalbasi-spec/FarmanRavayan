import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';

/// The player's chosen battle deck, remembered between launches.
class DeckStore {
  static const key = 'deck_card_ids';
  static const minSize = 10;
  static const maxSize = 30;

  /// In-memory copy used when a battle starts. Null means "random deck".
  static List<GameCard>? cached;

  static List<GameCard>? fromIds(Iterable<String> ids) {
    final wanted = ids.toSet();
    final cards = allCards.where((c) => wanted.contains(c.id)).toList();
    return cards.length >= minSize ? cards : null;
  }

  static Future<List<String>> loadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(key) ?? <String>[];
      cached = fromIds(ids);
      return ids;
    } catch (_) {
      return <String>[];
    }
  }

  static Future<void> saveIds(List<String> ids) async {
    cached = fromIds(ids);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, ids);
    } catch (_) {}
  }
}
