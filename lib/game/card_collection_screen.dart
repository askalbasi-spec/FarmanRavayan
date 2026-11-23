import 'package:flutter/material.dart';
import 'card.dart';

class CardCollectionScreen extends StatefulWidget {
  const CardCollectionScreen({super.key});
  @override State<CardCollectionScreen> createState() => _CardCollectionScreenState();
}

class _CardCollectionScreenState extends State<CardCollectionScreen> {
  CardType? _filter;
  @override
  Widget build(BuildContext context) {
    final cards = starterCards.where((card) => _filter == null || card.type == _filter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('مجموعه کارت‌ها')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          _chip('همه', null), _chip('قهرمان', CardType.hero), _chip('نیرو', CardType.troop), _chip('جادو', CardType.spell), _chip('تجهیزات', CardType.equipment),
        ])),
        Padding(padding: const EdgeInsets.all(8), child: Text('${cards.length} کارت از ${starterCards.length} کارت آغازین', style: const TextStyle(color: Color(0xFFF0D69A), fontWeight: FontWeight.bold))),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .82, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: cards.length,
          itemBuilder: (context, index) => _CardTile(card: cards[index]),
        )),
      ]),
    );
  }
  Widget _chip(String label, CardType? type) => ChoiceChip(label: Text(label), selected: _filter == type, onSelected: (_) => setState(() => _filter = type));
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});
  final GameCard card;
  @override
  Widget build(BuildContext context) {
    final typeName = switch (card.type) { CardType.hero => 'قهرمان', CardType.troop => 'نیرو', CardType.spell => 'جادو', CardType.equipment => 'تجهیزات' };
    final icon = switch (card.type) { CardType.hero => Icons.workspace_premium, CardType.troop => Icons.shield, CardType.spell => Icons.auto_awesome, CardType.equipment => Icons.security };
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => showDialog<void>(context: context, builder: (context) => AlertDialog(
        title: Text(card.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 52, color: const Color(0xFFD7B56D)), const SizedBox(height: 12),
          Text(card.description, textAlign: TextAlign.center), const SizedBox(height: 12),
          Text('نوع: $typeName   |   هزینه انرژی: ${card.cost}'), const SizedBox(height: 6),
          Text('قدرت حمله: ${card.attack}   |   سلامت: ${card.health}'),
          if (card.heal > 0) Text('درمان: ${card.heal}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))],
      )),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF344966), Color(0xFF172338)]), border: Border.all(color: const Color(0xFFD7B56D), width: 1.2), borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Expanded(child: Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))), CircleAvatar(radius: 13, backgroundColor: const Color(0xFFD7B56D), child: Text('${card.cost}', style: const TextStyle(color: Color(0xFF101827), fontWeight: FontWeight.w900)))]),
          Icon(icon, size: 48, color: const Color(0xFFD7B56D)),
          Text(card.description, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          Text(card.type == CardType.spell ? 'قدرت جادو: ${card.attack}  درمان: ${card.heal}' : '⚔ ${card.attack}     ♥ ${card.health}', style: const TextStyle(color: Color(0xFFF0D69A), fontWeight: FontWeight.bold, fontSize: 11)),
          const Text('برای جزئیات لمس کن', style: TextStyle(fontSize: 9, color: Colors.white38)),
        ]),
      ),
    );
  }
}