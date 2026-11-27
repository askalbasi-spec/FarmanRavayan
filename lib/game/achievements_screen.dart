import 'package:flutter/material.dart';

import 'audio.dart';
import 'fx.dart';
import 'rewards.dart';

const _gold = Color(0xFFF0D69A);

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  AchSnapshot _snap = const AchSnapshot();
  Set<String> _claimed = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final snap = await AchievementStore.snapshot();
    final claimed = await AchievementStore.claimed();
    if (!mounted) return;
    setState(() {
      _snap = snap;
      _claimed = claimed;
      _loaded = true;
    });
  }

  Future<void> _claim(Achievement a) async {
    final ok = await AchievementStore.claim(a, _snap);
    if (ok) GameAudio.sfx('win');
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = achievements.where((a) => _claimed.contains(a.id)).length;
    return Scaffold(
      appBar: AppBar(title: const Text('دستاوردها'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  Center(child: Text('دریافت‌شده: $doneCount از ${achievements.length}', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  for (final a in achievements) _tile(a),
                ],
              ),
      ),
    );
  }

  Widget _tile(Achievement a) {
    final value = a.progress(_snap).clamp(0, a.target);
    final complete = value >= a.target;
    final claimed = _claimed.contains(a.id);
    return Card(
      color: const Color(0xCC1B2A40),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(claimed ? Icons.verified : (complete ? Icons.emoji_events : Icons.military_tech), color: claimed ? const Color(0xFF5CF0B8) : _gold, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(a.description, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: value / a.target, minHeight: 7, backgroundColor: Colors.white12, color: const Color(0xFFD7B56D)),
                  ),
                  const SizedBox(height: 2),
                  Text('$value از ${a.target}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (claimed)
              const Text('گرفته شد', style: TextStyle(color: Color(0xFF5CF0B8), fontSize: 12))
            else
              FilledButton(
                onPressed: complete ? () => _claim(a) : null,
                child: Text('${a.reward} سکه'),
              ),
          ],
        ),
      ),
    );
  }
}
