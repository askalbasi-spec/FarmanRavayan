import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'battle_screen.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  static const _key = 'campaign_completed_missions';
  static const _missions = <({String title, String region, String story})>[
    (title: 'طلوع پادشاهی', region: 'دشت سپیده', story: 'نخستین نگهبانان را از مرزهای پادشاهی بران'),
    (title: 'گرگ‌های مه‌آلود', region: 'جنگل سایه‌ها', story: 'در برابر شکارچیان شب ایستادگی کن'),
    (title: 'محاصره سنگی', region: 'دره کوهستان', story: 'از دیوارهای دژ در برابر غول‌ها دفاع کن'),
    (title: 'آتش آذرگاه', region: 'سرزمین آتش', story: 'جادوگران آذر را از میدان بیرون کن'),
    (title: 'تاج اژدها', region: 'قله اژدهای سرخ', story: 'فرمانروای تاریکی را به چالش بکش'),
  ];

  Set<int> _completed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _completed = (prefs.getStringList(_key) ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      _loading = false;
    });
  }

  Future<void> _complete(int mission) async {
    _completed.add(mission);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _completed.map((e) => e.toString()).toList());
    if (mounted) setState(() {});
  }

  void _start(int index) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BattleScreen(
        missionTitle: _missions[index].title,
        difficulty: index + 1,
        onVictory: () => _complete(index),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _completed.length;
    return Scaffold(
      appBar: AppBar(title: const Text('کارزار داستانی')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('پیشرفت کارزار: ${_completed.length} از ${_missions.length} مأموریت',
                    style: const TextStyle(color: Color(0xFFF0D69A), fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _completed.length / _missions.length),
                const SizedBox(height: 16),
                for (var i = 0; i < _missions.length; i++)
                  Card(
                    color: const Color(0xFF1B2A40),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _completed.contains(i) ? Colors.green.shade800 : const Color(0xFF344966),
                        child: Icon(_completed.contains(i) ? Icons.check : (i <= unlocked ? Icons.flag : Icons.lock)),
                      ),
                      title: Text('مرحله ${i + 1}: ${_missions[i].title}'),
                      subtitle: Text('${_missions[i].region} — ${_missions[i].story}'),
                      trailing: i <= unlocked
                          ? IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _start(i))
                          : const Icon(Icons.lock_outline),
                      onTap: i <= unlocked ? () => _start(i) : null,
                    ),
                  ),
              ],
            ),
    );
  }
}
