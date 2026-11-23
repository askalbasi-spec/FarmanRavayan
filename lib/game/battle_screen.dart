import 'package:flutter/material.dart';
import 'battle_engine.dart';
import 'card.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});
  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late BattleEngine engine;
  @override
  void initState() { super.initState(); engine = BattleEngine(); }

  void _play(int index) => setState(() => engine.playCard(index));
  void _endTurn() => setState(() => engine.endPlayerTurn());
  void _restart() => setState(() => engine = BattleEngine());

  @override
  Widget build(BuildContext context) {
    final game = engine.state;
    return Scaffold(
      appBar: AppBar(title: const Text('نبرد فرمانروایان'), backgroundColor: const Color(0xFF182438)),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF26364D), Color(0xFF101827)])),
        child: SafeArea(child: Column(children: [
          _commander('فرمانده دشمن', game.enemyHealth, game.enemyBoard.length, true),
          const Divider(color: Color(0x557D8DA8), height: 1),
          Expanded(child: Center(child: SingleChildScrollView(child: Column(children: [
            _board('میدان دشمن', game.enemyBoard),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Icon(Icons.auto_awesome, color: Color(0xFFD7B56D), size: 28)),
            _board('میدان شما', game.playerBoard),
          ])))),
          _commander('فرمانده شما', game.playerHealth, game.playerBoard.length, false),
          Container(
            width: double.infinity, padding: const EdgeInsets.fromLTRB(12, 10, 12, 12), color: const Color(0xFF0B1220),
            child: Column(children: [
              Row(children: [
                Expanded(child: Text(game.message, maxLines: 2, style: const TextStyle(fontSize: 12))),
                Text('انرژی ${game.energy}/${game.maxEnergy}', style: const TextStyle(color: Color(0xFFF0D69A), fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              SizedBox(height: 145, child: game.hand.isEmpty
                ? const Center(child: Text('کارت دیگری در دست ندارید'))
                : ListView.separated(scrollDirection: Axis.horizontal, itemCount: game.hand.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, index) => _card(game.hand[index], index, game.energy))),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: game.isOver
                ? FilledButton.icon(onPressed: _restart, icon: const Icon(Icons.replay), label: Text('شروع نبرد تازه — ${game.winner == 'شما' ? 'پیروز شدید' : 'شکست خوردید'}'))
                : FilledButton.icon(onPressed: game.playerTurn ? _endTurn : null, icon: const Icon(Icons.skip_next), label: const Text('پایان نوبت'))),
            ]),
          ),
        ])),
      ),
    );
  }

  Widget _commander(String name, int health, int units, bool enemy) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      CircleAvatar(radius: 23, backgroundColor: enemy ? const Color(0xFF6C3038) : const Color(0xFF315B54), child: Icon(enemy ? Icons.local_fire_department : Icons.shield_moon, color: const Color(0xFFF0D69A))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('نیروهای میدان: $units', style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ])),
      Text('♥ $health', style: TextStyle(color: health <= 7 ? Colors.redAccent : const Color(0xFFF0D69A), fontSize: 19, fontWeight: FontWeight.w900)),
    ]),
  );

  Widget _board(String title, List<GameCard> cards) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Column(children: [
      Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 6),
      SizedBox(height: 82, child: cards.isEmpty
        ? const Center(child: Text('هنوز نیرویی در میدان نیست', style: TextStyle(color: Colors.white30, fontSize: 11)))
        : ListView.separated(scrollDirection: Axis.horizontal, itemCount: cards.length, separatorBuilder: (_, __) => const SizedBox(width: 7), itemBuilder: (_, i) => Container(
          width: 104, padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: const Color(0xFF253751), border: Border.all(color: const Color(0xFF9C7B42)), borderRadius: BorderRadius.circular(10)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(cards[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('⚔ ${cards[i].attack}   ♥ ${cards[i].health}', style: const TextStyle(color: Color(0xFFF0D69A), fontSize: 11)),
          ]),
        ))),
    ]),
  );

  Widget _card(GameCard card, int index, int energy) {
    final playable = card.cost <= energy;
    return InkWell(
      onTap: playable ? () => _play(index) : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(opacity: playable ? 1 : 0.48, child: Container(
        width: 112, padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF344966), Color(0xFF19283D)]), border: Border.all(color: const Color(0xFFD7B56D), width: 1.2), borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Expanded(child: Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            Text('${card.cost}', style: const TextStyle(color: Color(0xFFF0D69A), fontWeight: FontWeight.w900)),
          ]),
          Icon(_iconFor(card.type), size: 30, color: const Color(0xFFD7B56D)),
          Text(card.description, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.white70)),
          Text(card.type == CardType.spell ? '✦ ${card.attack + card.heal}' : '⚔ ${card.attack}  ♥ ${card.health}', style: const TextStyle(fontSize: 10, color: Color(0xFFF0D69A))),
        ]),
      )),
    );
  }

  IconData _iconFor(CardType type) {
    switch (type) {
      case CardType.hero: return Icons.workspace_premium;
      case CardType.troop: return Icons.shield;
      case CardType.spell: return Icons.auto_awesome;
      case CardType.equipment: return Icons.security;
    }
  }
}
