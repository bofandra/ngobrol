import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngobrol/main.dart';

void main() {
  test('Vote toggles and changes direction without double counting', () {
    final link = Link('A', 'B', true, up: 3, down: 1);
    link.choose(1);
    expect(link.vote, 1);
    link.choose(-1);
    expect(link.vote, -1);
    link.choose(-1);
    expect(link.vote, 0);
  });

  testWidgets('Open seed topic, contribute, view map and vote', (tester) async {
    await tester.pumpWidget(const NgobrolApp());
    await tester.tap(find.text('What makes a good home for a hermit crab?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'What about the tide?');
    await tester.tap(find.byTooltip('Send contribution'));
    await tester.pumpAndSettle();
    expect(find.text('🏆 5 XP'), findsOneWidget);
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();
    expect(find.text('Living system map'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Shell size → Protection (+)'), 150);
    await tester.tap(find.text('24'));
    await tester.pumpAndSettle();
    expect(find.text('25'), findsOneWidget);
  });
}
