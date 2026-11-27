import 'package:flutter/material.dart';

import 'card.dart';
import 'card_art.dart';
import 'card_view.dart';
import 'deck.dart';
import 'fx.dart';

const _gold = Color(0xFFF0D69A);

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _art = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  final Set<String> _chosen = {};
  CardGroup? _filter;

  @override
  void initState() {
    super.initState();
    DeckStore.loadIds().then((ids) {
      if (mounted) setState(() => _chosen.addAll(ids));
    });
  }

  @override
  void dispose() {
    _art.dispose();
    super.dispose();
  }

  void _toggle(GameCard card) {
    setState(() {
      if (_chosen.contains(card.id)) {
        _chosen.remove(card.id);
      } else if (_chosen.length < DeckStore.maxSize) {
        _chosen.add(card.id);
      }
    });
  }

  void _autoFill() {
    final shuffled = List<GameCard>.of(allCards)..shuffle();
    setState(() {
      _chosen
        ..clear()
        ..addAll(shuffled.take(DeckStore.maxSize).map((c) => c.id));
    });
  }

  Future<void> _save() async {
    await DeckStore.saveIds(_chosen.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cards = allCards.where((c) => _filter == null || c.group == _filter).toList();
    final ok = _chosen.length >= DeckStore.minSize;
    return Scaffold(
      appBar: AppBar(title: const Text('ساخت دسته‌ی کارت'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: [
                  _chip('همه', null),
                  for (final g in CardGroup.values) _chip(g.label, g),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                'انتخاب‌شده: ${_chosen.length} از ${DeckStore.maxSize} (حداقل ${DeckStore.minSize})',
                style: TextStyle(color: ok ? _gold : Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: cards.length,
                itemBuilder: (context, i) {
                  final card = cards[i];
                  final on = _chosen.contains(card.id);
                  return GestureDetector(
                    onTap: () => _toggle(card),
                    child: Stack(
                      children: [
                        Positioned.fill(child: GameCardView(card: card, animation: _art, dimmed: !on)),
                        if (on) const Positioned(top: 6, left: 6, child: CircleAvatar(radius: 14, backgroundColor: _gold, child: Icon(Icons.check, color: Colors.black, size: 18))),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Row(
                  children: [
                    OutlinedButton(onPressed: _autoFill, child: const Text('انتخاب تصادفی')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () => setState(_chosen.clear), child: const Text('پاک کردن')),
                    const SizedBox(width: 8),
                    Expanded(child: FilledButton(onPressed: ok ? _save : null, child: const Text('ذخیره دسته'))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, CardGroup? g) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(label: Text(label), selected: _filter == g, onSelected: (_) => setState(() => _filter = g)),
    );
  }
}
