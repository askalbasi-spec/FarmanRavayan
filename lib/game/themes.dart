import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'economy.dart';

class GameTheme {
  const GameTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.top,
    required this.middle,
    required this.bottom,
    required this.particle,
    this.fall = false,
  });

  final String id;
  final String name;
  final String description;

  /// Price in coins; 0 means free.
  final int price;
  final Color top;
  final Color middle;
  final Color bottom;
  final Color particle;

  /// Particles drift downward (snow) instead of upward (sparks, fireflies).
  final bool fall;
}

const gameThemes = <GameTheme>[
  GameTheme(id: 'night', name: 'شب ستاره‌ای', description: 'آسمان آرام و ستاره‌های طلایی', price: 0, top: Color(0xFF26364D), middle: Color(0xFF101827), bottom: Color(0xFF090E18), particle: Color(0xFFF0D69A)),
  GameTheme(id: 'forest', name: 'جنگل افسون‌شده', description: 'کرم‌های شب‌تاب میان درختان کهن', price: 150, top: Color(0xFF1E3B2C), middle: Color(0xFF0F2318), bottom: Color(0xFF08130E), particle: Color(0xFF9BFFB0)),
  GameTheme(id: 'fire', name: 'دژ آتشین', description: 'جرقه‌های آتش بر فراز دژ اژدها', price: 250, top: Color(0xFF4A1A12), middle: Color(0xFF251008), bottom: Color(0xFF120805), particle: Color(0xFFFF9A4D)),
  GameTheme(id: 'ice', name: 'قلمرو یخی', description: 'برف آرام بر قله‌های یخ‌زده', price: 350, top: Color(0xFF21456B), middle: Color(0xFF10243B), bottom: Color(0xFF08121F), particle: Color(0xFFE8F6FF), fall: true),
  GameTheme(id: 'sky', name: 'معبد آسمانی', description: 'غبار نورانی در معبدی بالای ابرها', price: 500, top: Color(0xFF40306B), middle: Color(0xFF1E1638), bottom: Color(0xFF0E0A1E), particle: Color(0xFFE2C8FF)),
];

/// Owned and selected visual themes.
class ThemeStore {
  static const ownedKey = 'theme_owned';
  static const selectedKey = 'theme_selected';

  static Set<String> owned = {'night'};
  static String selectedId = 'night';

  static GameTheme get current => gameThemes.firstWhere((t) => t.id == selectedId, orElse: () => gameThemes.first);

  static bool owns(GameTheme t) => t.price == 0 || owned.contains(t.id);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      owned = {'night', ...(prefs.getStringList(ownedKey) ?? <String>[])};
      final saved = prefs.getString(selectedKey) ?? 'night';
      selectedId = owned.contains(saved) ? saved : 'night';
    } catch (_) {}
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(ownedKey, owned.toList());
      await prefs.setString(selectedKey, selectedId);
    } catch (_) {}
  }

  static Future<void> select(GameTheme t) async {
    if (!owns(t)) return;
    selectedId = t.id;
    await _save();
  }

  /// Buys a theme with coins. Returns false when the balance is too low.
  static Future<bool> buy(GameTheme t) async {
    if (owns(t)) return true;
    if (!await Economy.spend(t.price)) return false;
    owned.add(t.id);
    selectedId = t.id;
    await _save();
    return true;
  }

  /// Used by the paid "all themes" bundle.
  static Future<void> unlockAll() async {
    owned = {for (final t in gameThemes) t.id};
    await _save();
  }
}
