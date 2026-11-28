import 'package:flutter/material.dart';

import 'audio.dart';
import 'billing.dart';
import 'economy.dart';
import 'fx.dart';
import 'themes.dart';

const _gold = Color(0xFFF0D69A);

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Economy.load().then((_) => ThemeStore.load()).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _say(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _use(GameTheme t) async {
    await ThemeStore.select(t);
    if (mounted) setState(() {});
  }

  Future<void> _buy(GameTheme t) async {
    if (Economy.coins < t.price) {
      _say('سکه‌ی کافی نیست: ${Economy.coins} از ${t.price}.');
      return;
    }
    await ThemeStore.buy(t);
    GameAudio.sfx('win');
    if (mounted) setState(() {});
  }

  Future<void> _buyAll() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await BillingService.buyThemeBundle();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.status == BillingStatus.success) GameAudio.sfx('win');
    _say(result.message.isEmpty ? 'خرید انجام نشد.' : result.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تم‌های فانتزی'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Center(child: Text('${Economy.coins} سکه', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _gold))),
            const SizedBox(height: 10),
            for (final t in gameThemes) _tile(t),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xCC1B2A40),
              child: ListTile(
                leading: const Icon(Icons.auto_awesome, color: _gold),
                title: const Text('همه‌ی تم‌ها با هم'),
                subtitle: Text(BillingService.configured ? 'پرداخت امن با کافه‌بازار' : 'به‌زودی با کافه‌بازار فعال می‌شود', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                trailing: FilledButton(onPressed: _busy ? null : _buyAll, child: const Text('خرید')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(GameTheme t) {
    final owned = ThemeStore.owns(t);
    final selected = ThemeStore.selectedId == t.id;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [t.top, t.bottom]),
        border: Border.all(color: selected ? _gold : Colors.white24, width: selected ? 2.5 : 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.circle, size: 14, color: t.particle),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                Text(t.description, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: selected
                ? const Icon(Icons.check_circle, color: _gold, size: 30)
                : owned
                    ? FilledButton(onPressed: () => _use(t), child: const Text('انتخاب'))
                    : FilledButton.icon(onPressed: () => _buy(t), icon: const Icon(Icons.monetization_on, size: 18), label: Text('${t.price}')),
          ),
        ],
      ),
    );
  }
}
