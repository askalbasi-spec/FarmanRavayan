import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'battle_engine.dart';
import 'card.dart';
import 'audio.dart';
import 'deck.dart';
import 'profile.dart';
import 'card_view.dart';
import 'fx.dart';

const _gold = Color(0xFFF0D69A);

class _Floating {
  _Floating(this.id, this.text, this.color, this.onPlayerSide);
  final int id;
  final String text;
  final Color color;
  final bool onPlayerSide;
}

class BattleScreen extends StatefulWidget {
  const BattleScreen({
    super.key,
    this.missionTitle,
    this.enemyName,
    this.onVictory,
    this.difficulty = 1,
    this.enemyGroups,
  });

  final String? missionTitle;
  final String? enemyName;
  final VoidCallback? onVictory;
  final int difficulty;
  final List<CardGroup>? enemyGroups;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  late BattleEngine engine;
  late final AnimationController _art = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  bool _reportedVictory = false;
  bool _busy = false;
  bool _haptics = true;
  bool _resultSounded = false;
  BattleEvent? _showcase;
  int _showcaseKey = 0;
  final List<_Floating> _floating = [];
  int _floatingId = 0;
  bool _flashPlayer = false;
  bool _flashEnemy = false;

  @override
  void initState() {
    super.initState();
    engine = _newEngine();
    _loadHaptics();
  }

  @override
  void dispose() {
    _art.dispose();
    super.dispose();
  }

  BattleEngine _newEngine() {
    final groups = widget.enemyGroups;
    final pool = groups == null ? null : allCards.where((c) => groups.contains(c.group)).toList();
    return BattleEngine(difficulty: widget.difficulty, enemyPool: pool, playerDeck: DeckStore.cached);
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) _haptics = prefs.getBool('settings_haptics_enabled') ?? true;
  }

  void _buzz(bool heavy) {
    if (!_haptics) return;
    if (heavy) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _play(int index) async {
    if (_busy) return;
    final before = engine.state.hand.length;
    setState(() => engine.playCard(index));
    if (engine.state.hand.length < before) _buzz(false);
    await _replayEvents();
    _reportVictory();
  }

  Future<void> _endTurn() async {
    if (_busy) return;
    setState(() => engine.endPlayerTurn());
    _buzz(true);
    await _replayEvents();
    _reportVictory();
  }

  Future<void> _replayEvents() async {
    final events = List<BattleEvent>.of(engine.state.events);
    engine.state.events.clear();
    if (events.isEmpty || !mounted) return;
    setState(() => _busy = true);
    for (final event in events) {
      if (!mounted) return;
      switch (event.kind) {
        case BattleEventKind.played:
          GameAudio.sfx('card');
          setState(() {
            _showcase = event;
            _showcaseKey++;
          });
          await Future<void>.delayed(Duration(milliseconds: event.onPlayerSide ? 380 : 700));
          if (!mounted) return;
          setState(() => _showcase = null);
        case BattleEventKind.damage:
          if (event.amount > 0) GameAudio.sfx('hit');
          if (event.amount > 0) await _popup('-${event.amount}', Colors.redAccent, event.onPlayerSide, flash: true);
        case BattleEventKind.heal:
          if (event.amount > 0) GameAudio.sfx('heal');
          if (event.amount > 0) await _popup('+${event.amount}', const Color(0xFF5CF0B8), event.onPlayerSide);
      }
    }
    if (mounted) setState(() => _busy = false);
    if (!_resultSounded && engine.state.winner != null) {
      _resultSounded = true;
      ProfileStore.recordBattle(won: engine.state.winner == Winner.player);
      GameAudio.sfx(engine.state.winner == Winner.player ? 'win' : 'lose');
    }
  }

  Future<void> _popup(String text, Color color, bool onPlayerSide, {bool flash = false}) async {
    final item = _Floating(_floatingId++, text, color, onPlayerSide);
    setState(() {
      _floating.add(item);
      if (flash) {
        if (onPlayerSide) {
          _flashPlayer = true;
        } else {
          _flashEnemy = true;
        }
      }
    });
    if (flash) HapticFeedback.selectionClick();
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    setState(() {
      _flashPlayer = false;
      _flashEnemy = false;
    });
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _floating.remove(item));
    });
  }

  void _reportVictory() {
    if (!_reportedVictory && engine.state.winner == Winner.player) {
      _reportedVictory = true;
      widget.onVictory?.call();
    }
  }

  void _restart() {
    setState(() {
      engine = _newEngine();
      _reportedVictory = false;
      _resultSounded = false;
      _busy = false;
      _showcase = null;
      _floating.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = engine.state;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.missionTitle ?? 'نبرد تمرینی'),
        backgroundColor: const Color(0xFF182438),
      ),
      body: AnimatedBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _commander(widget.enemyName ?? 'فرمانده دشمن', game.enemyHealth, game.enemyMaxHealth, game.enemyHand.length, true, _flashEnemy),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _board('میدان دشمن', game.enemyBoard),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Icon(Icons.auto_awesome, color: _gold, size: 22),
                            ),
                            _board('میدان شما', game.playerBoard),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _commander('فرمانده شما', game.playerHealth, game.playerMaxHealth, game.hand.length, false, _flashPlayer),
                  _handPanel(game),
                ],
              ),
              for (final f in _floating)
                Align(
                  alignment: Alignment(0.0, f.onPlayerSide ? 0.45 : -0.82),
                  child: FloatingText(key: ValueKey(f.id), text: f.text, color: f.color),
                ),
              if (_showcase != null) _showcaseOverlay(_showcase!),
              if (game.isOver && !_busy) _resultOverlay(game),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showcaseOverlay(BattleEvent event) {
    final card = event.card;
    if (card == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_showcaseKey),
          tween: Tween(begin: 0.4, end: 1.0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Opacity(
            opacity: ((scale - 0.4) / 0.6).clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                child: Text(event.onPlayerSide ? 'شما بازی کردید' : 'دشمن بازی کرد', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              SizedBox(width: 170, height: 245, child: GameCardView(card: card, animation: _art)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultOverlay(BattleState game) {
    final won = game.winner == Winner.player;
    return Container(
      color: Colors.black.withOpacity(0.72),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1.0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF16233A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: won ? _gold : Colors.redAccent, width: 2),
            boxShadow: [BoxShadow(color: (won ? _gold : Colors.redAccent).withOpacity(0.4), blurRadius: 26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(won ? Icons.emoji_events : Icons.heart_broken, size: 72, color: won ? _gold : Colors.redAccent),
              const SizedBox(height: 10),
              Text(won ? 'پیروزی!' : 'شکست', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: won ? _gold : Colors.redAccent)),
              const SizedBox(height: 8),
              Text(game.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(onPressed: _restart, icon: const Icon(Icons.replay), label: const Text('نبرد دوباره')),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_forward), label: const Text('بازگشت')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handPanel(BattleState game) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(color: Color(0xE60B1220), border: Border(top: BorderSide(color: Color(0x557D8DA8)))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(game.message, maxLines: 2, style: const TextStyle(fontSize: 12))),
              const Icon(Icons.bolt, color: Color(0xFF5CB8FF), size: 20),
              Text('${game.energy}/${game.maxEnergy}', style: const TextStyle(color: Color(0xFF5CB8FF), fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 172,
            child: game.hand.isEmpty
                ? const Center(child: Text('کارت دیگری در دست ندارید'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: game.hand.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final card = game.hand[index];
                      final playable = card.cost <= game.energy && game.playerTurn && !game.isOver && !_busy;
                      return GestureDetector(
                        onTap: () => _play(index),
                        child: SizedBox(width: 116, child: GameCardView(card: card, animation: _art, dimmed: !playable, showDescription: false)),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (game.playerTurn && !game.isOver && !_busy) ? _endTurn : null,
              icon: const Icon(Icons.skip_next),
              label: const Text('پایان نوبت'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commander(String name, int health, int maxHealth, int handSize, bool enemy, bool flash) {
    final color = enemy ? const Color(0xFF6C3038) : const Color(0xFF315B54);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: flash ? const Color(0x88E53935) : const Color(0x66182438),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: flash ? Colors.redAccent : const Color(0x555D7190)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: color, child: Icon(enemy ? Icons.local_fire_department : Icons.shield_moon, color: _gold)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
                    const Icon(Icons.style, color: Colors.white54, size: 15),
                    const SizedBox(width: 3),
                    Text('$handSize', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: maxHealth == 0 ? 0.0 : health / maxHealth),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 9,
                      backgroundColor: Colors.black38,
                      color: value < 0.35 ? Colors.redAccent : const Color(0xFF4CCB7A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('♥ $health', style: TextStyle(color: health <= 7 ? Colors.redAccent : _gold, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _board(String title, List<Unit> units) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          SizedBox(
            height: 118,
            child: units.isEmpty
                ? const Center(child: Text('هنوز نیرویی در میدان نیست', style: TextStyle(color: Colors.white30, fontSize: 11)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: units.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 7),
                    itemBuilder: (_, i) => TweenAnimationBuilder<double>(
                      key: ObjectKey(units[i]),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) => Transform.scale(scale: v.clamp(0.0, 1.2), child: child),
                      child: UnitView(unit: units[i], animation: _art),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
