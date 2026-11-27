import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'game/battle_screen.dart';
import 'game/card.dart';
import 'game/card_art.dart';
import 'game/card_view.dart';
import 'game/deck_builder_screen.dart';
import 'game/missions.dart';
import 'game/profile.dart';
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
  static const _gold = Color(0xFFF0D69A);
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  PlayerProfile _profile = const PlayerProfile(setupDone: true);
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    _load(firstRun: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _load({bool firstRun = false}) async {
    final profile = await ProfileStore.load();
    final completed = await ProfileStore.completedMissions();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _completed = completed;
    });
    if (firstRun && !profile.setupDone) {
      await _editProfile(first: true);
    }
  }

  Future<void> _editProfile({bool first = false}) async {
    final result = await showProfileSheet(context, _profile, first: first);
    if (result == null) {
      if (first) {
        final skipped = _profile.copyWith(setupDone: true);
        await ProfileStore.save(skipped);
        if (mounted) setState(() => _profile = skipped);
      }
      return;
    }
    await ProfileStore.save(result);
    if (mounted) setState(() => _profile = result);
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final total = missions.length;
    final finished = _completed >= total;
    final nextTitle = finished ? 'همه‌ی نبردها را بردی؛ دوباره بجنگ' : missions[_completed].title;
    return Scaffold(
      body: AnimatedBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  _Reveal(
                    index: 0,
                    child: _ProfileHeader(profile: _profile, completed: _completed, total: total, animation: _anim, onEdit: _editProfile),
                  ),
                  const SizedBox(height: 18),
                  _Reveal(
                    index: 1,
                    child: Column(
                      children: [
                        Text('فرمانروایان', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _gold, fontSize: 34)),
                        const SizedBox(height: 4),
                        const Text('سرنوشت پادشاهی را با هوشمندی رقم بزن', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Reveal(index: 2, child: _CardFan(animation: _anim)),
                  const SizedBox(height: 10),
                  _Reveal(
                    index: 3,
                    child: _PlayButton(
                      animation: _anim,
                      title: _completed == 0 ? 'آغاز کارزار' : 'ادامه کارزار',
                      subtitle: nextTitle,
                      onTap: () => _open(const CampaignScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Reveal(
                    index: 4,
                    child: Row(
                      children: [
                        Expanded(child: _GridTile(icon: Icons.shield, title: 'نبرد تمرینی', subtitle: 'تمرین در برابر دشمن', onTap: () => _open(const BattleScreen()))),
                        const SizedBox(width: 12),
                        Expanded(child: _GridTile(icon: Icons.style, title: 'مجموعه کارت‌ها', subtitle: '۵۰ کارت انیمیشنی', onTap: () => _open(const CardCollectionScreen()))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Reveal(
                    index: 5,
                    child: Row(
                      children: [
                        Expanded(child: _GridTile(icon: Icons.dashboard_customize, title: 'ساخت دسته‌ی کارت', subtitle: 'دسته‌ی دلخواهت را بچین', onTap: () => _open(const DeckBuilderScreen()))),
                        const SizedBox(width: 12),
                        Expanded(child: _GridTile(icon: Icons.menu_book, title: 'راهنمای بازی', subtitle: 'قوانین در شش گام', onTap: () => _open(const TutorialScreen()))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Reveal(index: 6, child: _GridTile(icon: Icons.settings, title: 'تنظیمات', subtitle: 'لرزش و اطلاعات نسخه', onTap: () => _open(const SettingsScreen()))),
                  const SizedBox(height: 16),
                  const Text('نسخه آزمایشی ۰.۴.۰', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Fades and slides a child in, staggered by [index].
class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + index * 110),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 28 * (1 - v)), child: child)),
      child: child,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.completed, required this.total, required this.animation, required this.onEdit});

  final PlayerProfile profile;
  final int completed;
  final int total;
  final Animation<double> animation;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xCC1B2A40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66D7B56D)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Transform.rotate(
                    angle: animation.value * 2 * 3.14159265,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [Color(0xFFF0D69A), Color(0x00F0D69A), Color(0xFFD7B56D), Color(0x00D7B56D), Color(0xFFF0D69A)]),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF101827)),
                  child: AvatarArt(index: profile.avatar, size: 64, animation: animation),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0x33D7B56D), borderRadius: BorderRadius.circular(10)),
                  child: Text('درجه: ${rankFor(completed)}', style: const TextStyle(fontSize: 12, color: Color(0xFFF0D69A))),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: total == 0 ? 0.0 : completed / total),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(value: v, minHeight: 7, backgroundColor: Colors.white12, color: const Color(0xFFD7B56D)),
                  ),
                ),
              ],
            ),
          ),
          IconButton(tooltip: 'ویرایش پروفایل', onPressed: onEdit, icon: const Icon(Icons.edit, color: Color(0xFFD7B56D))),
        ],
      ),
    );
  }
}

class _CardFan extends StatelessWidget {
  const _CardFan({required this.animation});

  final Animation<double> animation;

  static GameCard _byId(String id) => allCards.firstWhere((c) => c.id == id);

  @override
  Widget build(BuildContext context) {
    final cards = [_byId('archmage'), _byId('dragon'), _byId('queen')];
    const angles = [-0.14, 0.0, 0.14];
    const dx = [-86.0, 0.0, 86.0];
    return SizedBox(
      height: 190,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              for (final i in [0, 2, 1])
                Transform.translate(
                  offset: Offset(dx[i], -6 * (i == 1 ? 1 : 0) + 5 * _wave(i)),
                  child: Transform.rotate(
                    angle: angles[i] + 0.015 * _wave(i),
                    child: SizedBox(width: 118, height: 172, child: GameCardView(card: cards[i], animation: animation, showDescription: false)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _wave(int i) => math.sin(animation.value * 2 * math.pi + i * 1.6);
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.animation, required this.title, required this.subtitle, required this.onTap});

  final Animation<double> animation;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final glow = 0.5 + 0.5 * math.sin(animation.value * 2 * math.pi);
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xFFB8872E), Color(0xFFF0D69A), Color(0xFFB8872E)]),
              boxShadow: [BoxShadow(color: const Color(0xFFD7B56D).withOpacity(0.25 + 0.35 * glow), blurRadius: 14 + 14 * glow)],
            ),
            child: Row(
              children: [
                const Icon(Icons.flag, color: Color(0xFF241705), size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Color(0xFF241705), fontSize: 21, fontWeight: FontWeight.w900)),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF4A3510), fontSize: 13)),
                    ],
                  ),
                ),
                Transform.translate(offset: Offset(-4 * glow, 0), child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF241705))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Material(
      color: const Color(0xCC1B2A40),
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0x665D7190)), borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFD7B56D), size: 32),
              const SizedBox(height: 6),
              Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
