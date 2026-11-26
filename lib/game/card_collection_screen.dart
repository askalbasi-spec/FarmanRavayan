import 'package:flutter/material.dart';

import 'card.dart';
import 'card_art.dart';
import 'card_view.dart';
import 'fx.dart';

const _gold = Color(0xFFF0D69A);

class CardCollectionScreen extends StatefulWidget {
  const CardCollectionScreen({super.key});

  @override
  State<CardCollectionScreen> createState() => _CardCollectionScreenState();
}

class _CardCollectionScreenState extends State<CardCollectionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _art = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  CardGroup? _filter;

  @override
  void dispose() {
    _art.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = allCards.where((card) => _filter == null || card.group == _filter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('مجموعه کارت‌ها'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: [
                  _chip('همه', null, null),
                  for (final g in CardGroup.values) _chip(g.label, g, g.icon),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text('${cards.length} کارت از ${allCards.length} کارت', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GestureDetector(
                    onTap: () => _showCard(card),
                    child: GameCardView(card: card, animation: _art),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, CardGroup? group, IconData? icon) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: ChoiceChip(
          avatar: icon == null ? null : Icon(icon, size: 16, color: group?.primary),
          label: Text(label),
          selected: _filter == group,
          onSelected: (_) => setState(() => _filter = group),
        ),
      );

  void _showCard(GameCard card) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 250, height: 360, child: GameCardView(card: card, animation: _art)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(14)),
              child: Text('${card.type.label} • ${card.group.label} • هزینه ${card.cost}', style: const TextStyle(color: _gold, fontSize: 12)),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن')),
          ],
        ),
      ),
    );
  }
}
