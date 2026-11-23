import 'package:flutter/material.dart';

import 'game/battle_screen.dart';

void main() {
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
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: GameHomePage(),
      ),
    );
  }
}

class GameHomePage extends StatelessWidget {
  const GameHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF26364D), Color(0xFF101827), Color(0xFF090E18)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                children: [
                  const Icon(Icons.shield_moon, size: 72, color: Color(0xFFD7B56D)),
                  const SizedBox(height: 14),
                  Text(
                    'فرمانروایان',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFF0D69A),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سرنوشت پادشاهی را با هوشمندی رقم بزن',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 36),
                  _MenuTile(
                    icon: Icons.flag,
                    title: 'آغاز کارزار',
                    subtitle: 'ورود به نبردهای داستانی',
                    onTap: () => _showComingSoon(context, 'کارزار داستانی'),
                  ),
                  const SizedBox(height: 14),
                  _MenuTile(
                    icon: Icons.style,
                    title: 'مجموعه کارت‌ها',
                    subtitle: 'قهرمانان، نیروها، جادوها و تجهیزات',
                    onTap: () => _showComingSoon(context, 'مجموعه کارت‌ها'),
                  ),
                  const SizedBox(height: 14),
                  _MenuTile(
                    icon: Icons.shield,
                    title: 'نبرد تمرینی',
                    subtitle: 'تمرین تاکتیک‌ها در برابر هوش مصنوعی',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BattleScreen())),
                  ),
                  const SizedBox(height: 14),
                  _MenuTile(
                    icon: Icons.settings,
                    title: 'تنظیمات',
                    subtitle: 'صدا، نمایش و اطلاعات بازی',
                    onTap: () => _showComingSoon(context, 'تنظیمات'),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'نسخه آزمایشی ۰.۱.۰',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature در مرحله بعدی توسعه می‌یابد.')),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xCC1B2A40),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0x665D7190)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Icon(icon, color: const Color(0xFFD7B56D), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.chevron_left, color: Color(0xFFD7B56D)),
        onTap: onTap,
      ),
    );
  }
}
