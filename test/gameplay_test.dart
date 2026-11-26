import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farman_ravayan/game/card_view.dart';
import 'package:farman_ravayan/main.dart';

void phoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> settle(WidgetTester tester, {int seconds = 3}) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('practice battle opens and a full turn can be played', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(const FarmanRavayanApp());
    await settle(tester, seconds: 1);

    await tester.tap(find.text('نبرد تمرینی'));
    await settle(tester, seconds: 1);
    expect(tester.takeException(), isNull);
    expect(find.text('پایان نوبت'), findsOneWidget);
    expect(find.byType(GameCardView), findsWidgets);

    await tester.tap(find.byType(GameCardView).first);
    await settle(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('پایان نوبت'));
    await settle(tester, seconds: 6);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('پایان نوبت'));
    await settle(tester, seconds: 6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a campaign mission opens from the story list', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(const FarmanRavayanApp());
    await settle(tester, seconds: 1);

    await tester.tap(find.text('آغاز کارزار'));
    await settle(tester, seconds: 2);
    expect(tester.takeException(), isNull);
    expect(find.text('طلوع پادشاهی'), findsOneWidget);

    await tester.tap(find.text('طلوع پادشاهی'));
    await settle(tester, seconds: 1);
    expect(find.text('آغاز نبرد'), findsOneWidget);

    await tester.tap(find.text('آغاز نبرد'));
    await settle(tester, seconds: 1);
    expect(tester.takeException(), isNull);
    expect(find.text('پایان نوبت'), findsOneWidget);
    await settle(tester, seconds: 2);
  });

  testWidgets('tutorial pages can be swiped through', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(const FarmanRavayanApp());
    await settle(tester, seconds: 1);

    await tester.ensureVisible(find.text('راهنمای بازی'));
    await tester.tap(find.text('راهنمای بازی'));
    await settle(tester, seconds: 1);
    expect(find.text('هدف بازی'), findsOneWidget);

    await tester.tap(find.text('بعدی'));
    await settle(tester, seconds: 1);
    expect(find.text('انرژی'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings and collection screens build without errors', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(const FarmanRavayanApp());
    await settle(tester, seconds: 1);

    await tester.tap(find.text('تنظیمات'));
    await settle(tester, seconds: 1);
    expect(tester.takeException(), isNull);
  });
}
