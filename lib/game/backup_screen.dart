import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'backup.dart';
import 'fx.dart';

const _gold = Color(0xFFF0D69A);

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  String _code = '';
  final TextEditingController _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    BackupService.export().then((c) {
      if (mounted) setState(() => _code = c);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _say(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _code));
    _say('کد پشتیبان کپی شد. آن را جایی امن نگه دار.');
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) setState(() => _input.text = data!.text!);
  }

  Future<void> _restore() async {
    final ok = await BackupService.restore(_input.text);
    if (!mounted) return;
    _say(ok ? 'پیشرفت بازی بازیابی شد. برای دیدن همه‌ی تغییرات به صفحه‌ی اول برگرد.' : 'این کد معتبر نیست.');
    if (ok) {
      final fresh = await BackupService.export();
      if (mounted) setState(() => _code = fresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پشتیبان‌گیری'), backgroundColor: const Color(0xFF182438)),
      body: AnimatedBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('ذخیره‌ی پیشرفت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _gold)),
            const SizedBox(height: 6),
            const Text('سکه، کارت‌ها، تم‌ها، دستاوردها و پروفایل در یک کد ذخیره می‌شود. کد را کپی کن و در یادداشت یا پیام ذخیره‌شده‌ی خودت نگه دار. اگر گوشی عوض شد یا برنامه پاک شد، همین کد را بازیابی کن.', style: TextStyle(color: Colors.white70, height: 1.6)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(maxHeight: 110),
              decoration: BoxDecoration(color: const Color(0xCC1B2A40), borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(child: Text(_code.isEmpty ? '...' : _code, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 11, color: Colors.white54))),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(onPressed: _code.isEmpty ? null : _copy, icon: const Icon(Icons.copy), label: const Text('کپی کد پشتیبان')),
            const SizedBox(height: 28),
            const Text('بازیابی پیشرفت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _gold)),
            const SizedBox(height: 6),
            const Text('هشدار: بازیابی، پیشرفت فعلی این گوشی را با پیشرفت داخل کد جایگزین می‌کند.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: _input,
              minLines: 3,
              maxLines: 5,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'FR1:...'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(onPressed: _paste, icon: const Icon(Icons.paste), label: const Text('چسباندن')),
                const SizedBox(width: 10),
                Expanded(child: FilledButton(onPressed: _restore, child: const Text('بازیابی'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
