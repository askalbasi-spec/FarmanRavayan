import 'card.dart';

class Mission {
  const Mission({
    required this.title,
    required this.region,
    required this.story,
    required this.enemyName,
    required this.enemyGroups,
  });

  final String title;
  final String region;
  final String story;
  final String enemyName;

  /// The enemy deck is built from these card groups.
  final List<CardGroup> enemyGroups;
}

const missions = <Mission>[
  Mission(
    title: 'طلوع پادشاهی',
    region: 'دشت سپیده',
    story: 'نخستین نگهبانان را از مرزهای پادشاهی بران و راه را به سوی پایتخت باز کن.',
    enemyName: 'سروان مرزبان',
    enemyGroups: [CardGroup.infantry, CardGroup.archers, CardGroup.weapons],
  ),
  Mission(
    title: 'گرگ‌های مه‌آلود',
    region: 'جنگل سایه‌ها',
    story: 'در دل مه، شکارچیان شب در کمین‌اند. با سپر و کمان از کاروان پناهندگان محافظت کن.',
    enemyName: 'شکارچی مه',
    enemyGroups: [CardGroup.beasts, CardGroup.archers, CardGroup.relics],
  ),
  Mission(
    title: 'محاصره سنگی',
    region: 'دره کوهستان',
    story: 'غول‌های سنگی دژ کوهستان را محاصره کرده‌اند؛ از دیوارها در برابر آنان دفاع کن.',
    enemyName: 'ارباب سنگ',
    enemyGroups: [CardGroup.beasts, CardGroup.infantry, CardGroup.relics],
  ),
  Mission(
    title: 'آتش آذرگاه',
    region: 'سرزمین آتش',
    story: 'جادوگران آذر معبد باستانی را در آتش فرو برده‌اند. شعله‌ها را خاموش کن.',
    enemyName: 'جادوگر آذر',
    enemyGroups: [CardGroup.mages, CardGroup.battleSpells, CardGroup.weapons],
  ),
  Mission(
    title: 'نجوای یخ',
    region: 'دریاچه یخ‌زده',
    story: 'ملکه یخ زمستان را بی‌پایان کرده است. به قلب دریاچه برو و سرما را بشکن.',
    enemyName: 'ملکه یخ',
    enemyGroups: [CardGroup.mages, CardGroup.battleSpells, CardGroup.blessings],
  ),
  Mission(
    title: 'طوفان صحرا',
    region: 'صحرای سوزان',
    story: 'سواران تیزتک صحرا کاروان‌ها را غارت می‌کنند. سردار طوفان را در گرد و غبار شکست بده.',
    enemyName: 'سردار طوفان',
    enemyGroups: [CardGroup.cavalry, CardGroup.archers, CardGroup.weapons],
  ),
  Mission(
    title: 'راز بیشه کهن',
    region: 'بیشه‌زار کهن',
    story: 'نگهبان ققنوس راز جاودانگی را پنهان می‌کند. با خرد و درمان به او نزدیک شو.',
    enemyName: 'نگهبان بیشه',
    enemyGroups: [CardGroup.beasts, CardGroup.blessings, CardGroup.mages],
  ),
  Mission(
    title: 'دژ فراموش‌شده',
    region: 'خرابه‌های شمال',
    story: 'شوالیه سیاه دژ متروک را بازپس گرفته است. زره‌هایش بی‌شکست‌اند؛ راه شکستنشان را پیدا کن.',
    enemyName: 'شوالیه سیاه',
    enemyGroups: [CardGroup.infantry, CardGroup.cavalry, CardGroup.relics],
  ),
  Mission(
    title: 'معبد آسمان',
    region: 'قله‌های ابری',
    story: 'کاهن بزرگ نور آسمان را به تاریکی گره زده است. نور را به معبد برگردان.',
    enemyName: 'کاهن بزرگ',
    enemyGroups: [CardGroup.blessings, CardGroup.mages, CardGroup.battleSpells],
  ),
  Mission(
    title: 'تاج اژدها',
    region: 'قله اژدهای سرخ',
    story: 'فرمانروای تاریکی تاج اژدها را بر سر نهاده است. آخرین نبرد پادشاهی آغاز می‌شود.',
    enemyName: 'فرمانروای تاریکی',
    enemyGroups: [CardGroup.heroes, CardGroup.beasts, CardGroup.battleSpells],
  ),
];
