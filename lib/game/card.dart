enum CardType { hero, troop, spell, equipment }

class GameCard {
  const GameCard({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.cost,
    this.attack = 0,
    this.health = 0,
    this.heal = 0,
  });

  final String id;
  final String name;
  final String description;
  final CardType type;
  final int cost;
  final int attack;
  final int health;
  final int heal;
}

const starterCards = <GameCard>[
  GameCard(id: 'guard', name: 'نگهبان سپیده', description: 'سرباز وفادار پادشاهی', type: CardType.troop, cost: 1, attack: 2, health: 2),
  GameCard(id: 'archer', name: 'کماندار الف', description: 'تیرانداز تیزچشم جنگل', type: CardType.troop, cost: 2, attack: 3, health: 2),
  GameCard(id: 'wolf', name: 'گرگ سایه', description: 'شکارچی سریع شب', type: CardType.troop, cost: 2, attack: 2, health: 3),
  GameCard(id: 'knight', name: 'شوالیه آهنین', description: 'زره‌پوش سنگین', type: CardType.troop, cost: 3, attack: 3, health: 4),
  GameCard(id: 'mage', name: 'جادوگر آذر', description: 'نگهبان آتش باستانی', type: CardType.hero, cost: 4, attack: 4, health: 4),
  GameCard(id: 'golem', name: 'غول سنگی', description: 'پیکره‌ای از دل کوهستان', type: CardType.troop, cost: 5, attack: 4, health: 7),
  GameCard(id: 'dragon', name: 'اژدهای سرخ', description: 'آتش‌افشان آسمان‌ها', type: CardType.hero, cost: 7, attack: 7, health: 6),
  GameCard(id: 'heal', name: 'اکسیر زندگی', description: 'بازگرداندن ۳ واحد سلامت فرمانده', type: CardType.spell, cost: 2, heal: 3),
  GameCard(id: 'fire', name: 'گلوله آتشین', description: '۳ واحد آسیب به فرمانده دشمن', type: CardType.spell, cost: 3, attack: 3),
  GameCard(id: 'storm', name: 'توفان جادویی', description: '۵ واحد آسیب به فرمانده دشمن', type: CardType.spell, cost: 5, attack: 5),
  GameCard(id: 'banner', name: 'پرچم اتحاد', description: 'تجهیزات افتخارآفرین', type: CardType.equipment, cost: 2, attack: 1, health: 1),
  GameCard(id: 'medic', name: 'درمانگر سپید', description: 'پشتیبان نیروهای میدان', type: CardType.troop, cost: 2, attack: 1, health: 4),
  GameCard(id: 'assassin', name: 'تیغ پنهان', description: 'ضربه‌زن ماهر', type: CardType.troop, cost: 3, attack: 5, health: 1),
  GameCard(id: 'bear', name: 'خرس کوهستان', description: 'نیرومند و سرسخت', type: CardType.troop, cost: 4, attack: 4, health: 5),
  GameCard(id: 'phoenix', name: 'ققنوس', description: 'پرنده آتش و تولد دوباره', type: CardType.hero, cost: 6, attack: 5, health: 6),
  GameCard(id: 'frost', name: 'یخ‌بند', description: 'جادوی سرمای شمال', type: CardType.spell, cost: 2, attack: 2),
  GameCard(id: 'wall', name: 'دیوار سپر', description: 'استحکامات دفاعی', type: CardType.equipment, cost: 3, health: 3),
  GameCard(id: 'captain', name: 'فرمانده پیشتاز', description: 'رهبر خط مقدم', type: CardType.hero, cost: 5, attack: 5, health: 5),
  GameCard(id: 'scout', name: 'دیده‌بان', description: 'چابک و هوشیار', type: CardType.troop, cost: 1, attack: 1, health: 2),
  GameCard(id: 'meteor', name: 'شهاب آسمانی', description: 'ضربه نهایی آسمان', type: CardType.spell, cost: 6, attack: 7),
];
