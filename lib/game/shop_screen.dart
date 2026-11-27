import 'dart:math';

import 'package:flutter/material.dart';

import 'audio.dart';
import 'card.dart';
import 'card_view.dart';
import 'economy.dart';
import 'fx.dart';

const _gold = Color(0xFFF0D69A);

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Economy.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    if (_busy) return;
    setState(() => _busy = true);
    final pulls = await Economy.buyPack();
    if (!mounted) return;
    setState(() => _busy = false);
    if (pulls == null) return;
    GameAudio.sfx('win');
    await showDialog<void>(context: context, builder: (_) => _PackDialog(pulls: pulls, animation: _anim));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final canBuy = Economy.coins >= Economy.packPrice && !_busy;
    return Scaffold(
      appBar: AppBar(title: const Text('فروشگاه'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: _CoinChip(coins: Economy.coins)),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                final glow = 0.5 + 0.5 * sin(_anim.value * 2 * pi);
                return Container(
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(colors: [Color(0xFF3B2A6B), Color(0xFF1B2A60)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    border: Border.all(color: _gold, width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFFB06BFF).withOpacity(0.25 + 0.2 * glow), blurRadius: 24)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(angle: 0.1 * (_anim.value - 0.5), child: const Icon(Icons.auto_awesome, color: _gold, size: 64)),
                      const SizedBox(height: 8),
                      const Text('بسته‌ی کارت افسانه‌ای', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _gold)),
                      const Text('سه کارت تصادفی', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: canBuy ? _buy : null,
              icon: const Icon(Icons.monetization_on),
              label: const Text('خرید بسته — ${Economy.packPrice} سکه'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            if (Economy.coins < Economy.packPrice)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('سکه‌ی کافی نداری؛ با بردن نبردها سکه جمع کن.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
              ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('کارت‌های تو: ${Economy.owned.length} از ${allCards.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final r in Rarity.values) _rarityRow(r),
                    const SizedBox(height: 8),
                    const Text('کارت تکراری ۱۵ سکه بازمی‌گردد. هر پیروزی ۲۵ سکه و هر شکست ۵ سکه پاداش دارد.', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rarityRow(Rarity r) {
    final all = allCards.where((c) => c.rarity == r).length;
    final have = allCards.where((c) => c.rarity == r && Economy.owned.contains(c.id)).length;
    const chance = {Rarity.common: '۶۰٪', Rarity.rare: '۲۸٪', Rarity.epic: '۹٪', Rarity.legendary: '۳٪'};
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: Color(r.color)),
          const SizedBox(width: 8),
          Expanded(child: Text(r.label)),
          Text('$have/$all  ·  شانس ${chance[r]}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0x33D7B56D), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x88D7B56D))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFC94D)),
          const SizedBox(width: 8),
          Text('$coins سکه', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _gold)),
        ],
      ),
    );
  }
}

class _PackDialog extends StatelessWidget {
  const _PackDialog({required this.pulls, required this.animation});

  final List<PackPull> pulls;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF16233A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('کارت‌های تازه!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _gold)),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < pulls.length; i++)
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 500 + i * 350),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) => Opacity(opacity: v.clamp(0.0, 1.0), child: Transform.scale(scale: v, child: child)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            AspectRatio(aspectRatio: 0.68, child: GameCardView(card: pulls[i].card, animation: animation, showDescription: false)),
                            const SizedBox(height: 4),
                            Text(pulls[i].card.rarity.label, style: TextStyle(fontSize: 11, color: Color(pulls[i].card.rarity.color), fontWeight: FontWeight.bold)),
                            Text(pulls[i].isNew ? 'جدید' : '+۱۵ سکه', style: TextStyle(fontSize: 11, color: pulls[i].isNew ? const Color(0xFF5CF0B8) : Colors.white60)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('عالی!')),
          ],
        ),
      ),
    );
  }
}
