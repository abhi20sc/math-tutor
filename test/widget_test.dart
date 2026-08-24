// The first Dart tests in this project.
//
// What was here before was the Flutter template's scaffold test: it pumped a
// class called MyApp, which this app has never had, and imported a package
// that was never a dependency. It produced sixteen analyzer errors and tested
// nothing. Replaced rather than deleted, so `flutter test` has something to
// run.
//
// What is tested here is the percentage rule, because it is the piece of
// logic in this app most likely to be quietly broken by a later edit and
// least likely to look wrong on screen when it is. A unit reading 0% instead
// of a dash is a demoralising lie to a student who simply has not started,
// and it would take a screenshot and a careful reader to notice.
//
// Server-side behaviour is covered by tests/test_ama.sql (212 checks) and
// tests/test_sections.sql (55). This file covers what happens in the browser.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// `hide main` because main.dart declares one and so does this file. A local
// declaration shadows an import in Dart, so it would compile either way —
// but saying so is cheaper than the next reader working it out.
import 'package:math_tutor/main.dart' hide main;

SubtopicStat sub(String tag, {required int looks, int? rate}) => SubtopicStat(
      tag: tag,
      label: tag,
      questions: 10,
      firstLooks: looks,
      firstTryRate: rate,
      band: bandForRate(rate),
    );

UnitStat unit(List<SubtopicStat> subs) => UnitStat(
      unit: 'Quadratics',
      total: 40,
      solved: 10,
      percentComplete: 25,
      firstTryRate: 60,
      band: Band.yellow,
      levels: const [],
      subtopics: subs,
    );

void main() {
  group('subtopic percentage', () {
    test('is the first-try rate once there have been two first looks', () {
      expect(subtopicMastery(sub('a', looks: 2, rate: 75)), 75);
      expect(subtopicMastery(sub('a', looks: 9, rate: 40)), 40);
    });

    test('is null on a single look, because one guess is not a score', () {
      expect(subtopicMastery(sub('a', looks: 1, rate: 100)), isNull);
      expect(subtopicMastery(sub('a', looks: 0)), isNull);
    });

    test('a practice-test score overrides the first-try rate', () {
      final s = sub('sub-vertex-form', looks: 4, rate: 50);
      expect(subtopicMastery(s, override: {'sub-vertex-form': 90}), 90);
    });

    test('an override for a different tag is ignored', () {
      final s = sub('sub-vertex-form', looks: 4, rate: 50);
      expect(subtopicMastery(s, override: {'sub-factored-form': 90}), 50);
    });

    test('an override of zero is honoured, not treated as absent', () {
      final s = sub('t', looks: 4, rate: 80);
      expect(subtopicMastery(s, override: {'t': 0}), 0);
    });
  });

  group('unit percentage', () {
    test('averages its subtopics, counting an untouched one as zero', () {
      // Two subtopics at 80, two never practised. Not 80 — 40.
      final u = unit([
        sub('a', looks: 4, rate: 80),
        sub('b', looks: 4, rate: 80),
        sub('c', looks: 0),
        sub('d', looks: 0),
      ]);
      expect(unitMastery(u), 40);
    });

    test('climbs as more of the unit is practised', () {
      int withPractised(int n) => unitMastery(unit([
            for (var i = 0; i < 4; i++)
              i < n ? sub('s$i', looks: 4, rate: 100) : sub('s$i', looks: 0),
          ]))!;
      expect(withPractised(1), 25);
      expect(withPractised(2), 50);
      expect(withPractised(4), 100);
    });

    test('is null when nothing in the unit has been practised', () {
      final u = unit([sub('a', looks: 0), sub('b', looks: 1, rate: 100)]);
      expect(unitMastery(u), isNull);
    });

    test('is null, not zero, for a unit with no subtopics at all', () {
      expect(unitMastery(unit(const [])), isNull);
    });

    test('a real zero is a zero, and is not confused with no data', () {
      final u = unit([sub('a', looks: 5, rate: 0)]);
      expect(unitMastery(u), 0);
      expect(unitMastery(u), isNotNull);
    });
  });

  group('bands', () {
    test('a null rate is grey, not orange', () {
      expect(bandForRate(null), Band.grey);
      expect(bandForRate(0), Band.orange);
    });

    test('the cutoffs match the ones the server uses', () {
      expect(bandForRate(90), Band.green);
      expect(bandForRate(89), Band.lightGreen);
      expect(bandForRate(70), Band.lightGreen);
      expect(bandForRate(69), Band.yellow);
      expect(bandForRate(50), Band.yellow);
      expect(bandForRate(49), Band.orange);
    });

    test('every band has a word, so colour is never the only signal', () {
      for (final b in Band.values) {
        expect(bandWord(b), isNotEmpty);
      }
    });
  });

  testWidgets('the Map / List toggle reports the tab that was tapped',
      (WidgetTester tester) async {
    var picked = -1;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SegmentedTabs(
          labels: const ['Map', 'List'],
          selected: 1,
          onSelect: (i) => picked = i,
        ),
      ),
    ));

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);

    await tester.tap(find.text('Map'));
    expect(picked, 0);
  });
}
