import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farman_ravayan/main.dart';

void main() {
  testWidgets('home screen shows the game title and main sections', (tester) async {
    await tester.pumpWidget(const FarmanRavayanApp());

    expect(find.text('فرمانروایان'), findsOneWidget);
    expect(find.text('آغاز کارزار'), findsOneWidget);
    expect(find.text('مجموعه کارت‌ها'), findsOneWidget);
    expect(find.text('نبرد تمرینی'), findsOneWidget);
  });

  testWidgets('pushed screens keep the right-to-left direction', (tester) async {
    await tester.pumpWidget(const FarmanRavayanApp());

    await tester.tap(find.text('مجموعه کارت‌ها'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).last);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
