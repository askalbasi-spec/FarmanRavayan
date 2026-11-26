import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/main.dart';

Future<void> openCollection(WidgetTester tester) async {
  await tester.pumpWidget(const FarmanRavayanApp());
  await tester.pump(const Duration(milliseconds: 900));
  await tester.tap(find.text('مجموعه کارت‌ها'));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('home screen shows the game title and main sections', (tester) async {
    await tester.pumpWidget(const FarmanRavayanApp());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('فرمانروایان'), findsOneWidget);
    expect(find.text('آغاز کارزار'), findsOneWidget);
    expect(find.text('مجموعه کارت‌ها'), findsOneWidget);
    expect(find.text('نبرد تمرینی'), findsOneWidget);
  });

  testWidgets('pushed screens keep the right-to-left direction', (tester) async {
    await openCollection(tester);

    final context = tester.element(find.byType(Scaffold).last);
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('card collection counts all fifty cards', (tester) async {
    await openCollection(tester);

    expect(find.text('50 کارت از 50 کارت'), findsOneWidget);
  });
}
