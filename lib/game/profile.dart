import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_art.dart';

const _gold = Color(0xFFF0D69A);

class PlayerProfile {
  const PlayerProfile({this.name = 'فرمانروا', this.avatar = 0, this.setupDone = false});

  final String name;
  final int avatar;
  final bool setupDone;

  PlayerProfile copyWith({String? name, int? avatar, bool? setupDone}) =>
      PlayerProfile(name: name ?? this.name, avatar: avatar ?? this.avatar, setupDone: setupDone ?? this.setupDone);
}

class ProfileStore {
  static const _nameKey = 'profile_name';
  static const _avatarKey = 'profile_avatar';
  static const _doneKey = 'profile_setup_done';
  static const _campaignKey = 'campaign_completed_missions';

  static Future<PlayerProfile> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return PlayerProfile(
        name: prefs.getString(_nameKey) ?? 'فرمانروا',
        avatar: (prefs.getInt(_avatarKey) ?? 0).clamp(0, avatarOptions.length - 1),
        setupDone: prefs.getBool(_doneKey) ?? false,
      );
    } catch (_) {
      return const PlayerProfile(setupDone: true);
    }
  }

  static Future<void> save(PlayerProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, profile.name);
      await prefs.setInt(_avatarKey, profile.avatar);
      await prefs.setBool(_doneKey, profile.setupDone);
    } catch (_) {}
  }

  static Future<BattleStats> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return BattleStats(played: prefs.getInt('stats_played') ?? 0, won: prefs.getInt('stats_won') ?? 0);
    } catch (_) {
      return const BattleStats();
    }
  }

  static Future<void> recordBattle({required bool won}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('stats_played', (prefs.getInt('stats_played') ?? 0) + 1);
      if (won) await prefs.setInt('stats_won', (prefs.getInt('stats_won') ?? 0) + 1);
    } catch (_) {}
  }

  static Future<int> completedMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_campaignKey) ?? []).map(int.tryParse).whereType<int>().toSet().length;
    } catch (_) {
      return 0;
    }
  }
}

class BattleStats {
  const BattleStats({this.played = 0, this.won = 0});

  final int played;
  final int won;
}

/// A rank title that grows with campaign progress.
String rankFor(int completed) {
  if (completed >= 10) return 'فرمانروای بزرگ';
  if (completed >= 8) return 'سردار';
  if (completed >= 5) return 'فرمانده';
  if (completed >= 3) return 'شوالیه';
  if (completed >= 1) return 'سروان';
  return 'سرباز';
}

/// Lets the player pick a name and a fantasy portrait.
Future<PlayerProfile?> showProfileSheet(BuildContext context, PlayerProfile current, {bool first = false}) {
  return showModalBottomSheet<PlayerProfile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF16233A),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (context) => _ProfileSheet(current: current, first: first),
  );
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet({required this.current, required this.first});

  final PlayerProfile current;
  final bool first;

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.current.name == 'فرمانروا' && widget.first ? '' : widget.current.name);
  late int _avatar = widget.current.avatar;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final typed = _name.text.trim();
    Navigator.of(context).pop(PlayerProfile(name: typed.isEmpty ? 'فرمانروا' : typed, avatar: _avatar, setupDone: true));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.first ? 'به فرمانروایان خوش آمدی' : 'ویرایش پروفایل', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _gold)),
            const SizedBox(height: 6),
            const Text('نام و چهره‌ی خودت را انتخاب کن.', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              maxLength: 16,
              decoration: const InputDecoration(labelText: 'نام فرمانروا', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            const Text('چهره', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < avatarOptions.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _avatar = i),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: i == _avatar ? _gold : Colors.transparent, width: 3)),
                          child: AvatarArt(index: i, size: 62),
                        ),
                        const SizedBox(height: 3),
                        Text(avatarOptions[i].label, style: TextStyle(fontSize: 11, color: i == _avatar ? _gold : Colors.white60)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: FilledButton(onPressed: _save, child: const Text('ذخیره'))),
                if (widget.first) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(widget.current.copyWith(setupDone: true)),
                    child: const Text('بعداً'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
