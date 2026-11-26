import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'game/battle_screen.dart';
import 'game/campaign_screen.dart';
import 'game/card_collection_screen.dart';
import 'game/fx.dart';
import 'game/settings_screen.dart';
import 'game/tutorial_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Show the real error on screen instead of a blank or grey page.
  ErrorWidget.builder = (details) => Material(
        color: const Color(0xFF101827),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'خطای نمایش: ${details.exceptionAsString()}',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Color(0xFFF0D69A), fontSize: 13),
            ),
          ),
        ),
      );
  runApp(const FarmanRavayanApp());
}

class FarmanRavayanApp extends StatelessWidget {
  const FarmanRavayanApp({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD7B56D);
    const midnight = Color(0xFF101827);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فرمانروایان',
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: midnight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
          surface: const Color(0xFF182438),
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const GameHomePage(),
    );
  }
}

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key});

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(Icons.flag, 'آغاز کارزار', 'ده نبرد داستانی در سرزمین‌های افسانه‌ای', () => _open(const CampaignScreen())),
      _MenuItem(Icons.style, 'مجموعه کارت‌ها', 'مشاهده ۵۰ کارت انیمیشنی در ده گروه', () => _open(const CardCollectionScreen())),
      _MenuItem(Icons.shield, 'نبرد تمرینی', 'تمرین تاکتیک‌ها در برابر هوش مصنوعی', () => _open(const BattleScreen())),
      _MenuItem(Icons.menu_book, 'راهنمای بازی', 'قوانین نبرد در شش گام کوتاه', () => _open(const TutorialScreen())),
      _MenuItem(Icons.settings, 'تنظیمات', 'تنظیمات بازی و اطلاعات نسخه', () => _open(const SettingsScreen())),
    ];
    return Scaffold(
      body: AnimatedBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) => Transform.scale(
                      scale: 1.0 + 0.06 * _pulse.value,
                      child: Icon(
                        Icons.shield_moon,
                        size: 84,
                        color: const Color(0xFFD7B56D),
                        shadows: [Shadow(color: const Color(0xFFD7B56D).withOpacity(0.35 + 0.4 * _pulse.value), blurRadius: 28)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'فرمانروایان',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFFF0D69A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سرنوشت پادشاهی را با هوشمندی رقم بزن',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  for (var i = 0; i < items.length; i++)
                    TweenAnimationBuilder<double>(
                      key: ValueKey('menu$i'),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + i * 130),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 30 * (1 - v)), child: child)),
                      child: Padding(padding: const EdgeInsets.only(bottom: 14), child: _MenuTile(item: items[i])),
                    ),
                  const SizedBox(height: 18),
                  const Text('نسخه آزمایشی ۰.۲.۰', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.title, this.subtitle, this.onTap);

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xCC1B2A40),
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0x665D7190)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Icon(item.icon, color: const Color(0xFFD7B56D), size: 30),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.subtitle, style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.chevron_left, color: Color(0xFFD7B56D)),
        onTap: item.onTap,
      ),
    );
  }
}
