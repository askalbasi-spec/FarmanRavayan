import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'battle_screen.dart';
import 'card.dart';
import 'card_art.dart';
import 'fx.dart';
import 'missions.dart';

const _gold = Color(0xFFF0D69A);

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  static const _key = 'campaign_completed_missions';

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
      _completed = (prefs.getStringList(_key) ?? []).map(int.tryParse).whereType<int>().where((i) => i >= 0 && i < missions.length).toSet();
      _loading = false;
    });
  }

  Future<void> _complete(int mission) async {
    _completed.add(mission);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _completed.map((e) => e.toString()).toList());
    if (mounted) setState(() {});
  }

  /// The mission after the furthest completed one is the newest unlocked.
  int get _unlockedUntil => _completed.isEmpty ? 0 : _completed.reduce(max) + 1;

  void _start(int index) {
    final mission = missions[index];
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BattleScreen(
        missionTitle: 'مرحله ${index + 1}: ${mission.title}',
        enemyName: mission.enemyName,
        enemyGroups: mission.enemyGroups,
        difficulty: index + 1,
        onVictory: () => _complete(index),
      ),
    ));
  }

  void _details(int index) {
    final mission = missions[index];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF16233A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحله ${index + 1}: ${mission.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _gold)),
            const SizedBox(height: 4),
            Text(mission.region, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 12),
            Text(mission.story, style: const TextStyle(height: 1.7)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 20),
                const SizedBox(width: 6),
                Expanded(child: Text('دشمن: ${mission.enemyName}', style: const TextStyle(fontWeight: FontWeight.bold))),
                _stars(index),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [for (final g in mission.enemyGroups) Chip(avatar: Icon(g.icon, size: 16, color: g.primary), label: Text(g.label, style: const TextStyle(fontSize: 11)))],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _start(index);
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(_completed.contains(index) ? 'نبرد دوباره' : 'آغاز نبرد'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stars(int index) {
    final count = (index ~/ 2) + 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 0; i < 5; i++) Icon(i < count ? Icons.star : Icons.star_border, size: 16, color: _gold)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کارزار داستانی'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('پیشرفت کارزار: ${_completed.length} از ${missions.length} مأموریت', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: _completed.length / missions.length),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: value, minHeight: 10, backgroundColor: Colors.black38, color: _gold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < missions.length; i++) _missionTile(i),
                ],
              ),
      ),
    );
  }

  Widget _missionTile(int i) {
    final mission = missions[i];
    final done = _completed.contains(i);
    final open = i <= _unlockedUntil;
    final accent = mission.enemyGroups.first.primary;
    return TweenAnimationBuilder<double>(
      key: ValueKey('mission$i'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + i * 70),
      builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child)),
      child: Card(
        color: const Color(0xCC1B2A40),
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: done ? const Color(0xFF3FAE6A) : (open ? accent : Colors.white12), width: 1.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: done ? const Color(0xFF2E7D4F) : (open ? accent.withOpacity(0.35) : const Color(0xFF2A3548)),
            child: done ? const Icon(Icons.check, color: Colors.white) : (open ? Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900)) : const Icon(Icons.lock, size: 20)),
          ),
          title: Text(mission.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${mission.region} — دشمن: ${mission.enemyName}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
          trailing: open ? const Icon(Icons.chevron_left, color: _gold) : null,
          onTap: open ? () => _details(i) : null,
        ),
      ),
    );
  }
}
