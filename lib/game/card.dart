/// Rule type of a card. It decides how the battle engine resolves it.
enum CardType { hero, troop, spell, equipment }

/// Thematic families of cards. Every group has exactly five cards.
enum CardGroup {
  heroes,
  infantry,
  archers,
  cavalry,
  mages,
  beasts,
  battleSpells,
  blessings,
  weapons,
  relics,
}

extension CardGroupLabel on CardGroup {
  String get label {
    switch (this) {
      case CardGroup.heroes:
        return 'قهرمانان';
      case CardGroup.infantry:
        return 'پیاده‌نظام';
      case CardGroup.archers:
        return 'کمانداران';
      case CardGroup.cavalry:
        return 'سواره‌نظام';
      case CardGroup.mages:
        return 'جادوگران';
      case CardGroup.beasts:
        return 'موجودات افسانه‌ای';
      case CardGroup.battleSpells:
        return 'طلسم‌های نبرد';
      case CardGroup.blessings:
        return 'برکت و درمان';
      case CardGroup.weapons:
        return 'جنگ‌افزارها';
      case CardGroup.relics:
        return 'زره و یادگارها';
    }
  }
}

extension CardTypeLabel on CardType {
  String get label {
    switch (this) {
      case CardType.hero:
        return 'قهرمان';
      case CardType.troop:
        return 'نیرو';
      case CardType.spell:
        return 'جادو';
      case CardType.equipment:
        return 'تجهیزات';
    }
  }
}

/// Which animated illustration is drawn on a card.
enum ArtMotif {
  sword,
  shield,
  bow,
  horse,
  wizard,
  dragon,
  flame,
  frost,
  heal,
  bolt,
  beast,
  golem,
  skull,
  crown,
  banner,
  armor,
  meteor,
  bird,
  tower,
}

class GameCard {
  const GameCard({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.group,
    required this.motif,
    required this.cost,
    this.attack = 0,
    this.health = 0,
    this.heal = 0,
  });

  final String id;
  final String name;
  final String description;
  final CardType type;
  final CardGroup group;
  final ArtMotif motif;
  final int cost;
  final int attack;
  final int health;
  final int heal;
}

const allCards = <GameCard>[
  // قهرمانان
  GameCard(id: 'captain', name: 'فرمانده پیشتاز', description: 'رهبر خط مقدم', type: CardType.hero, group: CardGroup.heroes, motif: ArtMotif.crown, cost: 5, attack: 5, health: 5),
  GameCard(id: 'queen', name: 'ملکه سپیده', description: 'نور امید پادشاهی', type: CardType.hero, group: CardGroup.heroes, motif: ArtMotif.crown, cost: 6, attack: 4, health: 7),
  GameCard(id: 'paladin', name: 'پالادین نور', description: 'سپر زنده معبد', type: CardType.hero, group: CardGroup.heroes, motif: ArtMotif.shield, cost: 4, attack: 3, health: 6),
  GameCard(id: 'warlord', name: 'سردار آهنین', description: 'ویرانگر میدان‌های نبرد', type: CardType.hero, group: CardGroup.heroes, motif: ArtMotif.sword, cost: 7, attack: 7, health: 6),
  GameCard(id: 'ranger', name: 'شاهزاده جنگل', description: 'کمانداری افسانه‌ای', type: CardType.hero, group: CardGroup.heroes, motif: ArtMotif.bow, cost: 3, attack: 3, health: 3),
  // پیاده‌نظام
  GameCard(id: 'scout', name: 'دیده‌بان', description: 'چابک و هوشیار', type: CardType.troop, group: CardGroup.infantry, motif: ArtMotif.sword, cost: 1, attack: 1, health: 2),
  GameCard(id: 'guard', name: 'نگهبان سپیده', description: 'سرباز وفادار پادشاهی', type: CardType.troop, group: CardGroup.infantry, motif: ArtMotif.shield, cost: 1, attack: 2, health: 2),
  GameCard(id: 'spearman', name: 'نیزه‌دار کوه', description: 'دیوار نیزه‌های برافراشته', type: CardType.troop, group: CardGroup.infantry, motif: ArtMotif.sword, cost: 2, attack: 2, health: 3),
  GameCard(id: 'knight', name: 'شوالیه آهنین', description: 'زره‌پوش سنگین', type: CardType.troop, group: CardGroup.infantry, motif: ArtMotif.shield, cost: 3, attack: 3, health: 4),
  GameCard(id: 'berserker', name: 'خشمگین شمال', description: 'جنگجوی بی‌پروا', type: CardType.troop, group: CardGroup.infantry, motif: ArtMotif.sword, cost: 4, attack: 5, health: 3),
  // کمانداران
  GameCard(id: 'slinger', name: 'فلاخن‌انداز', description: 'سنگ‌های تیز و دقیق', type: CardType.troop, group: CardGroup.archers, motif: ArtMotif.bow, cost: 1, attack: 2, health: 1),
  GameCard(id: 'archer', name: 'کماندار الف', description: 'تیرانداز تیزچشم جنگل', type: CardType.troop, group: CardGroup.archers, motif: ArtMotif.bow, cost: 2, attack: 3, health: 2),
  GameCard(id: 'crossbow', name: 'کمان‌دار قلعه', description: 'تیر زره‌شکن', type: CardType.troop, group: CardGroup.archers, motif: ArtMotif.bow, cost: 3, attack: 4, health: 2),
  GameCard(id: 'falconer', name: 'شاهین‌بان', description: 'چشم‌های آسمان', type: CardType.troop, group: CardGroup.archers, motif: ArtMotif.bird, cost: 4, attack: 3, health: 4),
  GameCard(id: 'hunter', name: 'شکارچی مه', description: 'سایه‌ای با تیر', type: CardType.troop, group: CardGroup.archers, motif: ArtMotif.bow, cost: 5, attack: 5, health: 4),
  // سواره‌نظام
  GameCard(id: 'messenger', name: 'پیک تیزتک', description: 'سریع‌تر از باد', type: CardType.troop, group: CardGroup.cavalry, motif: ArtMotif.horse, cost: 1, attack: 2, health: 1),
  GameCard(id: 'rider', name: 'سوار تاخت', description: 'تاخت بی‌امان', type: CardType.troop, group: CardGroup.cavalry, motif: ArtMotif.horse, cost: 2, attack: 3, health: 2),
  GameCard(id: 'lancer', name: 'نیزه‌دار سواره', description: 'یورش مرگبار', type: CardType.troop, group: CardGroup.cavalry, motif: ArtMotif.horse, cost: 4, attack: 5, health: 4),
  GameCard(id: 'cataphract', name: 'زره‌سوار', description: 'قلعه متحرک', type: CardType.troop, group: CardGroup.cavalry, motif: ArtMotif.horse, cost: 5, attack: 4, health: 7),
  GameCard(id: 'champion', name: 'سوار افسانه‌ای', description: 'پرچم‌دار پیروزی', type: CardType.troop, group: CardGroup.cavalry, motif: ArtMotif.horse, cost: 6, attack: 7, health: 5),
  // جادوگران
  GameCard(id: 'medic', name: 'درمانگر سپید', description: 'پشتیبان سخت‌جان خط مقدم', type: CardType.troop, group: CardGroup.mages, motif: ArtMotif.heal, cost: 2, attack: 1, health: 4),
  GameCard(id: 'mage', name: 'جادوگر آذر', description: 'نگهبان آتش باستانی', type: CardType.hero, group: CardGroup.mages, motif: ArtMotif.flame, cost: 4, attack: 4, health: 4),
  GameCard(id: 'frostmage', name: 'یخ‌افسون', description: 'نجواگر زمستان', type: CardType.troop, group: CardGroup.mages, motif: ArtMotif.frost, cost: 3, attack: 2, health: 5),
  GameCard(id: 'stormcaller', name: 'توفان‌خوان', description: 'فراخوان رعد و برق', type: CardType.troop, group: CardGroup.mages, motif: ArtMotif.bolt, cost: 4, attack: 4, health: 4),
  GameCard(id: 'archmage', name: 'استاد بزرگ', description: 'سرور جادوگران', type: CardType.hero, group: CardGroup.mages, motif: ArtMotif.wizard, cost: 7, attack: 6, health: 7),
  // موجودات افسانه‌ای
  GameCard(id: 'wolf', name: 'گرگ سایه', description: 'شکارچی سریع شب', type: CardType.troop, group: CardGroup.beasts, motif: ArtMotif.beast, cost: 2, attack: 2, health: 3),
  GameCard(id: 'bear', name: 'خرس کوهستان', description: 'نیرومند و سرسخت', type: CardType.troop, group: CardGroup.beasts, motif: ArtMotif.beast, cost: 4, attack: 4, health: 5),
  GameCard(id: 'golem', name: 'غول سنگی', description: 'پیکره‌ای از دل کوهستان', type: CardType.troop, group: CardGroup.beasts, motif: ArtMotif.golem, cost: 5, attack: 4, health: 7),
  GameCard(id: 'phoenix', name: 'ققنوس', description: 'پرنده آتش و تولد دوباره', type: CardType.hero, group: CardGroup.beasts, motif: ArtMotif.bird, cost: 6, attack: 5, health: 6),
  GameCard(id: 'dragon', name: 'اژدهای سرخ', description: 'آتش‌افشان آسمان‌ها', type: CardType.hero, group: CardGroup.beasts, motif: ArtMotif.dragon, cost: 7, attack: 7, health: 6),
  // طلسم‌های نبرد
  GameCard(id: 'frost', name: 'یخ‌بند', description: '۲ واحد آسیب به فرمانده دشمن', type: CardType.spell, group: CardGroup.battleSpells, motif: ArtMotif.frost, cost: 2, attack: 2),
  GameCard(id: 'fire', name: 'گلوله آتشین', description: '۳ واحد آسیب به فرمانده دشمن', type: CardType.spell, group: CardGroup.battleSpells, motif: ArtMotif.flame, cost: 3, attack: 3),
  GameCard(id: 'lightning', name: 'صاعقه', description: '۴ واحد آسیب به فرمانده دشمن', type: CardType.spell, group: CardGroup.battleSpells, motif: ArtMotif.bolt, cost: 4, attack: 4),
  GameCard(id: 'storm', name: 'توفان جادویی', description: '۵ واحد آسیب به فرمانده دشمن', type: CardType.spell, group: CardGroup.battleSpells, motif: ArtMotif.wizard, cost: 5, attack: 5),
  GameCard(id: 'meteor', name: 'شهاب آسمانی', description: '۷ واحد آسیب به فرمانده دشمن', type: CardType.spell, group: CardGroup.battleSpells, motif: ArtMotif.meteor, cost: 6, attack: 7),
  // برکت و درمان
  GameCard(id: 'breeze', name: 'نسیم شفا', description: 'بازگرداندن ۲ واحد سلامت فرمانده', type: CardType.spell, group: CardGroup.blessings, motif: ArtMotif.heal, cost: 1, heal: 2),
  GameCard(id: 'heal', name: 'اکسیر زندگی', description: 'بازگرداندن ۳ واحد سلامت فرمانده', type: CardType.spell, group: CardGroup.blessings, motif: ArtMotif.heal, cost: 2, heal: 3),
  GameCard(id: 'sacrifice', name: 'قربانی خون', description: '۳ آسیب به دشمن و ۳ درمان برای شما', type: CardType.spell, group: CardGroup.blessings, motif: ArtMotif.skull, cost: 3, attack: 3, heal: 3),
  GameCard(id: 'spring', name: 'چشمه نور', description: 'بازگرداندن ۶ واحد سلامت فرمانده', type: CardType.spell, group: CardGroup.blessings, motif: ArtMotif.heal, cost: 4, heal: 6),
  GameCard(id: 'prayer', name: 'دعای ققنوس', description: '۲ آسیب به دشمن و ۵ درمان برای شما', type: CardType.spell, group: CardGroup.blessings, motif: ArtMotif.bird, cost: 5, attack: 2, heal: 5),
  // جنگ‌افزارها
  GameCard(id: 'axe', name: 'تبر جنگ', description: '+۲ حمله به یک نیروی میدان', type: CardType.equipment, group: CardGroup.weapons, motif: ArtMotif.sword, cost: 2, attack: 2),
  GameCard(id: 'banner', name: 'پرچم اتحاد', description: '+۱ حمله و +۱ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.weapons, motif: ArtMotif.banner, cost: 2, attack: 1, health: 1),
  GameCard(id: 'sword', name: 'شمشیر شاهان', description: '+۳ حمله به یک نیروی میدان', type: CardType.equipment, group: CardGroup.weapons, motif: ArtMotif.sword, cost: 3, attack: 3),
  GameCard(id: 'longbow', name: 'کمان حکیم', description: '+۲ حمله و +۱ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.weapons, motif: ArtMotif.bow, cost: 3, attack: 2, health: 1),
  GameCard(id: 'thunderspear', name: 'نیزه رعد', description: '+۳ حمله و +۱ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.weapons, motif: ArtMotif.bolt, cost: 4, attack: 3, health: 1),
  // زره و یادگارها
  GameCard(id: 'charm', name: 'طلسم محافظ', description: '+۱ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.relics, motif: ArtMotif.shield, cost: 1, health: 1),
  GameCard(id: 'plate', name: 'زره آهنین', description: '+۲ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.relics, motif: ArtMotif.armor, cost: 2, health: 2),
  GameCard(id: 'wall', name: 'دیوار سپر', description: '+۳ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.relics, motif: ArtMotif.tower, cost: 3, health: 3),
  GameCard(id: 'helm', name: 'کلاه‌خود طلایی', description: '+۱ حمله و +۲ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.relics, motif: ArtMotif.armor, cost: 3, attack: 1, health: 2),
  GameCard(id: 'sunCrown', name: 'تاج سپیده', description: '+۲ حمله و +۴ سلامت به یک نیروی میدان', type: CardType.equipment, group: CardGroup.relics, motif: ArtMotif.crown, cost: 5, attack: 2, health: 4),
];


/// Special effects that trigger when a card is played. Keyed by card id.
enum Ability { healSelf, draw, strikeEnemy }

class AbilityInfo {
  const AbilityInfo(this.kind, this.amount, this.text);

  final Ability kind;
  final int amount;
  final String text;
}

const cardAbilities = <String, AbilityInfo>{
  'medic': AbilityInfo(Ability.healSelf, 3, 'هنگام ورود: ۳ جان به فرمانده‌ات برمی‌گرداند'),
  'scout': AbilityInfo(Ability.draw, 1, 'هنگام ورود: یک کارت می‌کشی'),
  'messenger': AbilityInfo(Ability.draw, 1, 'هنگام ورود: یک کارت می‌کشی'),
  'falconer': AbilityInfo(Ability.strikeEnemy, 2, 'هنگام ورود: ۲ آسیب به فرمانده دشمن'),
  'stormcaller': AbilityInfo(Ability.strikeEnemy, 2, 'هنگام ورود: ۲ آسیب به فرمانده دشمن'),
  'phoenix': AbilityInfo(Ability.healSelf, 2, 'هنگام ورود: ۲ جان به فرمانده‌ات برمی‌گرداند'),
};

extension GameCardAbility on GameCard {
  AbilityInfo? get ability => cardAbilities[id];

  String get fullDescription => ability == null ? description : '$description\n${ability!.text}';
}
