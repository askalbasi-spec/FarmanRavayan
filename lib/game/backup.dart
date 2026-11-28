import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'deck.dart';
import 'economy.dart';
import 'themes.dart';

/// Saves all game progress as a text code that can be copied and restored.
class BackupService {
  static const prefix = 'FR1:';

  static String encode(Map<String, Object> values) {
    final items = <Map<String, Object>>[];
    values.forEach((key, value) {
      if (value is String) {
        items.add({'k': key, 't': 's', 'v': value});
      } else if (value is int) {
        items.add({'k': key, 't': 'i', 'v': value});
      } else if (value is bool) {
        items.add({'k': key, 't': 'b', 'v': value});
      } else if (value is double) {
        items.add({'k': key, 't': 'd', 'v': value});
      } else if (value is List<String>) {
        items.add({'k': key, 't': 'l', 'v': value});
      }
    });
    return prefix + base64Url.encode(utf8.encode(jsonEncode(items)));
  }

  /// Returns null when the code is not a valid backup.
  static Map<String, Object>? decode(String code) {
    final text = code.trim();
    if (!text.startsWith(prefix)) return null;
    try {
      final raw = utf8.decode(base64Url.decode(base64Url.normalize(text.substring(prefix.length))));
      final items = jsonDecode(raw) as List<dynamic>;
      final result = <String, Object>{};
      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final key = map['k'] as String;
        final value = map['v'];
        switch (map['t']) {
          case 's':
            result[key] = value as String;
          case 'i':
            result[key] = value as int;
          case 'b':
            result[key] = value as bool;
          case 'd':
            result[key] = (value as num).toDouble();
          case 'l':
            result[key] = (value as List<dynamic>).cast<String>();
          default:
            return null;
        }
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  static Future<String> export() async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, Object>{};
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value != null) values[key] = value;
    }
    return encode(values);
  }

  /// Restores a backup code. Returns false if the code is invalid.
  static Future<bool> restore(String code) async {
    final values = decode(code);
    if (values == null || values.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    for (final entry in values.entries) {
      final v = entry.value;
      if (v is String) {
        await prefs.setString(entry.key, v);
      } else if (v is int) {
        await prefs.setInt(entry.key, v);
      } else if (v is bool) {
        await prefs.setBool(entry.key, v);
      } else if (v is double) {
        await prefs.setDouble(entry.key, v);
      } else if (v is List<String>) {
        await prefs.setStringList(entry.key, v);
      }
    }
    await Economy.load();
    await ThemeStore.load();
    await DeckStore.loadIds();
    return true;
  }
}
