import 'package:flutter/material.dart';

import 'card.dart';
import 'card_view.dart';
import 'fx.dart';

const _gold = Color(0xFFF0D69A);

class _Step {
  const _Step(this.icon, this.title, this.text, this.cardId);

  final IconData icon;
  final String title;
  final String text;
  final String cardId;
}

const _steps = <_Step>[
  _Step(Icons.flag, 'هدف بازی', 'فرمانده دشمن را شکست بده. هر فرمانده با ۲۰ جان شروع می‌کند؛ هر کس جانش به صفر برسد، بازنده است.', 'captain'),
  _Step(Icons.bolt, 'انرژی', 'عدد آبی بالای هر کارت هزینه آن است. نوبت اول یک انرژی داری و در هر نوبت یک واحد بیشتر می‌شود تا سقف ده.', 'scout'),
  _Step(Icons.shield, 'نیرو و قهرمان', 'نیروها روی میدان می‌مانند. نیروی تازه‌وارد همان نوبت حمله نمی‌کند. نیروها نخست به نیروهای دشمن می‌زنند و اگر میدان دشمن خالی باشد، به فرمانده حمله می‌کنند.', 'knight'),
  _Step(Icons.auto_awesome, 'جادو', 'جادوها بلافاصله اجرا می‌شوند و از دست می‌روند: آسیب به فرمانده دشمن یا درمان فرمانده خودت.', 'fire'),
  _Step(Icons.security, 'تجهیزات', 'تجهیزات روی قوی‌ترین نیروی میدان نصب می‌شوند و حمله یا سلامتش را بالا می‌برند. بدون نیرو در میدان نمی‌توانی آن‌ها را بازی کنی.', 'banner'),
  _Step(Icons.skip_next, 'پایان نوبت', 'کارتی را برای بازی لمس کن و بعد «پایان نوبت» را بزن. نیروهای آماده حمله می‌کنند، دشمن بازی می‌کند و تو یک کارت تازه می‌کشی. دست تو حداکثر هفت کارت جا دارد.', 'dragon'),
];

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _steps.length - 1;
    return Scaffold(
      appBar: AppBar(title: const Text('راهنمای بازی'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _steps.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => _page_(_steps[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.all(4),
                      width: i == _page ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: i == _page ? _gold : Colors.white24, borderRadius: BorderRadius.circular(8)),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (last) {
                        Navigator.of(context).pop();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
                      }
                    },
                    child: Text(last ? 'متوجه شدم' : 'بعدی'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page_(_Step step) {
    final card = allCards.firstWhere((c) => c.id == step.cardId);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          Icon(step.icon, color: _gold, size: 44),
          const SizedBox(height: 8),
          Text(step.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _gold)),
          const SizedBox(height: 14),
          SizedBox(width: 170, height: 245, child: GameCardView(card: card)),
          const SizedBox(height: 16),
          Text(step.text, textAlign: TextAlign.center, style: const TextStyle(height: 1.8, fontSize: 15)),
        ],
      ),
    );
  }
}
