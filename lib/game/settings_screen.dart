import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _key = 'settings_haptics_enabled';
  bool _enabled = true;
  bool _loading = true;
  bool _sound = GameAudio.soundOn;
  bool _music = GameAudio.musicOn;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await GameAudio.load();
    if (!mounted) return;
    setState(() { _enabled = prefs.getBool(_key) ?? true; _sound = GameAudio.soundOn; _music = GameAudio.musicOn; _loading = false; });
  }
  Future<void> _change(bool value) async {
    setState(() => _enabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تنظیمات')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: SwitchListTile(secondary: const Icon(Icons.vibration, color: Color(0xFFD7B56D)), title: const Text('بازخورد لمسی'), subtitle: const Text('ذخیره ترجیح بازخورد لمسی'), value: _enabled, onChanged: _change)),
      Card(child: SwitchListTile(secondary: const Icon(Icons.volume_up, color: Color(0xFFD7B56D)), title: const Text('جلوه‌های صوتی'), subtitle: const Text('صدای کارت، ضربه و پیروزی'), value: _sound, onChanged: (v) { setState(() => _sound = v); GameAudio.setSound(v); })),
      Card(child: SwitchListTile(secondary: const Icon(Icons.music_note, color: Color(0xFFD7B56D)), title: const Text('موسیقی پس‌زمینه'), subtitle: const Text('آهنگ آرام فانتزی'), value: _music, onChanged: (v) { setState(() => _music = v); GameAudio.setMusic(v); })),
      const SizedBox(height: 18),
      const Card(child: ListTile(leading: Icon(Icons.shield_moon, color: Color(0xFFD7B56D), size: 34), title: Text('فرمانروایان'), subtitle: Text('بازی کارتی راهبردی فانتزی'))),
      const ListTile(title: Text('نسخه برنامه'), subtitle: Text('۰.۵.۰ — نسخه آزمایشی توسعه'), leading: Icon(Icons.info_outline)),
      const ListTile(title: Text('وضعیت اتصال'), subtitle: Text('این نسخه برای بازی تک‌نفره و آفلاین طراحی شده است. رقابت آنلاین در نسخه‌های آینده اضافه می‌شود.'), leading: Icon(Icons.wifi_off)),
    ]),
  );
}