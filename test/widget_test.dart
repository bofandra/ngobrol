import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngobrol/game.dart';
import 'package:ngobrol/main.dart';

const shellTitle = 'What makes a good home for a hermit crab?';

Future<void> openShell(WidgetTester tester) async {
  await tester.ensureVisible(find.text(shellTitle));
  await tester.tap(find.text(shellTitle));
  await tester.pumpAndSettle();
}

Future<void> atMobileSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 800);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const NgobrolApp());
  await tester.pumpAndSettle();
}

void main() {
  test('Vote switches and withdraws without changing the base counts', () {
    final link = Link('A', 'B', true, up: 3, down: 1);
    expect((link.upCount, link.downCount), (3, 1));
    link.choose(1);
    expect((link.upCount, link.downCount), (4, 1));
    link.choose(-1);
    expect((link.upCount, link.downCount), (3, 2));
    link.choose(-1);
    expect((link.upCount, link.downCount), (3, 1));
  });

  testWidgets(
    'Search has an empty state and persists after re-opening a topic',
    (tester) async {
      await atMobileSize(tester);
      final search = find.byType(TextField);
      await tester.enterText(search, 'nothing similar');
      await tester.pump();
      expect(find.text('No discussions match this search.'), findsOneWidget);

      await tester.enterText(search, '  HERMIT ');
      await tester.pump();
      expect(find.text('How can we reduce urban heat?'), findsNothing);
      await openShell(tester);
      expect(find.text('Talk'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).controller!.text, '  HERMIT ');
      await openShell(tester);
      expect(find.text('Talk'), findsOneWidget);
    },
  );

  testWidgets('Validate and create a topic, then revisit it with its context', (
    tester,
  ) async {
    await atMobileSize(tester);
    await tester.tap(find.text('Create new topic'));
    await tester.pumpAndSettle();
    final submit = find.text('Start Ngobrol');

    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(
      find.text('Use 10–120 characters for your question.'),
      findsOneWidget,
    );

    const question = 'How can parks help a neighborhood stay cool?';
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '  $question  ');
    await tester.enterText(fields.last, 'a' * 2001);
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(
      find.text('Use 2,000 characters or fewer for context.'),
      findsOneWidget,
    );

    await tester.enterText(fields.last, 'Compare shade and street design.');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('10 XP'), findsOneWidget);
    expect(find.text('Compare shade and street design.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(question));
    await tester.tap(find.text(question));
    await tester.pumpAndSettle();
    expect(find.text('Compare shade and street design.'), findsOneWidget);
  });

  testWidgets('Offline contribution earns XP once and stays with its topic', (
    tester,
  ) async {
    await atMobileSize(tester);
    await openShell(tester);

    final composer = find.byType(TextField);
    final send = find.byTooltip('Send contribution');
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('Write a contribution first.'), findsOneWidget);
    await tester.enterText(composer, '🐚' * 2001);
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('Use 2,000 characters or fewer.'), findsOneWidget);
    expect(find.text('0 XP'), findsOneWidget);

    await tester.enterText(composer, 'What about the tide?');
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('What about the tide?'), findsOneWidget);
    expect(find.text('5 XP'), findsOneWidget);
    expect(find.text('Simulated facilitator'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('+5 XP · Question'), findsOneWidget);
  });

  testWidgets(
    'Relationship vote can be withdrawn and a proposal stays pending',
    (tester) async {
      await atMobileSize(tester);
      await openShell(tester);
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('List (5)'));
      await tester.pumpAndSettle();

      Future<void> vote(String label) async {
        final target = find.byTooltip(label);
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await vote('Agree on Shell size to Protection');
      expect(find.text('25'), findsOneWidget);
      await vote('Withdraw agreement on Shell size to Protection');
      expect(find.text('24'), findsOneWidget);
      expect(find.text('25'), findsNothing);
      expect(find.text('Shell weight → Mobility (−)'), findsOneWidget);

      final suggest = find.text('Suggest map change');
      await tester.scrollUntilVisible(suggest, 150);
      await tester.tap(suggest);
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      final submit = find.text('Submit for review');
      await tester.enterText(fields.at(0), 'Tide height');
      await tester.enterText(fields.at(1), '  TIDE HEIGHT ');
      await tester.enterText(fields.at(2), 'Incoming water covers dry ground.');
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Choose two different factors.'), findsOneWidget);
      expect(find.text('0 XP'), findsOneWidget);

      await tester.enterText(fields.at(1), 'Dry ground');
      await tester.tap(find.text('Same direction (+)'));
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      final pending = find.text('Pending proposals (1)');
      await tester.scrollUntilVisible(pending, 120);
      expect(pending, findsOneWidget);
      expect(find.text('Tide height → Dry ground (−)'), findsOneWidget);
      expect(find.text('10 XP'), findsOneWidget);
      final relationshipList = find.text('List (5)');
      await tester.scrollUntilVisible(relationshipList, -160);
      expect(relationshipList, findsOneWidget);
    },
  );

  testWidgets('Long title and composer fit with a narrow keyboard viewport', (
    tester,
  ) async {
    await atMobileSize(tester);
    await tester.tap(find.text('Create new topic'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'very long ' * 12);
    await tester.tap(find.text('Start Ngobrol'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(320, 740);
    tester.view.viewInsets = const FakeViewPadding(bottom: 325);
    addTearDown(tester.view.resetViewInsets);
    await tester.enterText(find.byType(TextField), 'A small contribution');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Send contribution').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
