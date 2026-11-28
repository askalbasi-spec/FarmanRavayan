import 'package:flutter/material.dart';

import 'arena.dart';
import 'audio.dart';
import 'battle_engine.dart';
import 'card_view.dart';
import 'duel_engine.dart';
import 'fx.dart';
import 'profile.dart';

const _gold = Color(0xFFF0D69A);

/// Two people play against each other on one phone, passing it between turns.
class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key, this.firstName, this.secondName});

  final String? firstName;
  final String? secondName;

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _art = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  late DuelEngine _engine;
  bool _cover = true;
  String _p1 = 'بازیکن ۱';

  @override
  void initState() {
    super.initState();
    _p1 = widget.firstName ?? 'بازیکن ۱';
    _engine = DuelEngine(firstName: _p1, secondName: widget.secondName ?? 'بازیکن ۲');
    if (widget.firstName == null) {
      ProfileStore.load().then((p) {
        if (!mounted || !_cover || _engine.turnNumber != 1 || !_engine.firstTurn) return;
        setState(() {
          _p1 = p.name;
          _engine = DuelEngine(firstName: p.name, secondName: widget.secondName ?? 'بازیکن ۲');
        });
      });
    }
  }

  @override
  void dispose() {
    _art.dispose();
    super.dispose();
  }

  void _play(int index) {
    if (_engine.playCard(index)) {
      GameAudio.sfx('card');
    }
    setState(() {});
  }

  void _end() {
    GameAudio.sfx('hit');
    _engine.endTurn();
    setState(() => _cover = !_engine.isOver);
  }

  void _restart() {
    setState(() {
      _engine = DuelEngine(firstName: _engine.first.name, secondName: _engine.second.name);
      _cover = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = _engine;
    return Scaffold(
      appBar: AppBar(title: const Text('دو نفره روی یک گوشی'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: Stack(
          children: [
            Column(
              children: [
                _bar(e.other.name, e.other.health, e.other.maxHealth, true),
                Expanded(child: ArenaView(enemy: e.other.board, player: e.current.board, animation: _art, lunge: kAlwaysDismissedAnimation, lungeSide: true, difficulty: 1 + (e.turnNumber % 10))),
                _bar(e.current.name, e.current.health, e.current.maxHealth, false),
                _controls(e),
                _hand(e),
              ],
            ),
            if (_cover && !e.isOver) _coverView(e),
            if (e.isOver) _resultView(e),
          ],
        ),
      ),
    );
  }

  Widget _bar(String name, int health, int maxHealth, bool enemy) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0x66182438), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x555D7190))),
      child: Row(
        children: [
          Icon(enemy ? Icons.local_fire_department : Icons.shield_moon, color: _gold),
          const SizedBox(width: 8),
          Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
          const SizedBox(width: 4),
          Text('$health / $maxHealth', style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _controls(DuelEngine e) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Color(0xFF6CB6FF)),
          Text(' انرژی ${e.current.energy} از ${e.current.maxEnergy}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(e.message, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(width: 8),
          FilledButton(onPressed: e.isOver ? null : _end, child: const Text('پایان نوبت')),
        ],
      ),
    );
  }

  Widget _hand(DuelEngine e) {
    final hand = e.current.hand;
    return SizedBox(
      height: 168,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        itemCount: hand.length,
        itemBuilder: (context, i) {
          final playable = e.canPlay(i);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _play(i),
              child: SizedBox(width: 108, child: GameCardView(card: hand[i], animation: _art, dimmed: !playable, showDescription: false)),
            ),
          );
        },
      ),
    );
  }

  Widget _coverView(DuelEngine e) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xF2080C16),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_android, size: 56, color: _gold),
            const SizedBox(height: 14),
            Text('گوشی را به ${e.current.name} بده', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _gold)),
            const SizedBox(height: 8),
            const Text('کارت‌های حریف دیده نمی‌شود. وقتی آماده بود دکمه را بزند.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => setState(() => _cover = false), child: Text('${e.current.name} آماده است')),
          ],
        ),
      ),
    );
  }

  Widget _resultView(DuelEngine e) {
    final winner = e.winnerIndex == 0 ? e.first.name : e.second.name;
    return Positioned.fill(
      child: Container(
        color: const Color(0xE6080C16),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 72, color: _gold),
            const SizedBox(height: 10),
            Text('$winner پیروز شد!', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _gold)),
            const SizedBox(height: 18),
            FilledButton(onPressed: _restart, child: const Text('بازی دوباره')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('بازگشت')),
          ],
        ),
      ),
    );
  }
}
