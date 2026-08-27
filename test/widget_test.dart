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

import 'dart:math' as math;

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

  // -------------------------------------------------------------------------
  // The theme
  // -------------------------------------------------------------------------
  //
  // These exist because the dark theme shipped with the band colours, the
  // unit hues and a dozen panel fills still set to their daylight values,
  // and nothing caught it. Every one of them looked fine in review, because
  // review happened in the light theme.
  //
  // The rule each test below pins is the same one: a colour that carries
  // meaning has to be READ FROM THE PALETTE, not written down once.
  group('palette', () {
    tearDown(() => kPalette = AstroPalette.light);

    test('every band word changes between the two themes', () {
      kPalette = AstroPalette.light;
      final light = [for (final b in Band.values) bandTextColour(b)];
      kPalette = AstroPalette.dark;
      final dark = [for (final b in Band.values) bandTextColour(b)];

      for (var i = 0; i < Band.values.length; i++) {
        expect(dark[i], isNot(light[i]),
            reason: '${Band.values[i]} reuses its light colour in the dark');
      }
    });

    test('every band fill changes between the two themes', () {
      kPalette = AstroPalette.light;
      final light = [for (final b in Band.values) bandColour(b)];
      kPalette = AstroPalette.dark;
      final dark = [for (final b in Band.values) bandColour(b)];

      for (var i = 0; i < Band.values.length; i++) {
        expect(dark[i], isNot(light[i]));
      }
    });

    test('a unit keeps its slot in both themes, and changes colour', () {
      kPalette = AstroPalette.light;
      final lightIndex = tintIndex('Factoring');
      final lightColour = unitTint('Factoring');
      kPalette = AstroPalette.dark;

      // The SLOT is derived from the name and must not move, or a student
      // switching to dark would see every unit change identity at once.
      expect(tintIndex('Factoring'), lightIndex);
      expect(unitTint('Factoring'), isNot(lightColour));
    });

    test('both palettes carry a full set of bands and tints', () {
      for (final p in [AstroPalette.light, AstroPalette.dark]) {
        expect(p.bandFill.length, Band.values.length);
        expect(p.bandText.length, Band.values.length);
        expect(p.unitTints.length, 8);
        expect(p.unitTintsDeep.length, p.unitTints.length);
      }
    });

    test('the brand mark does not change with the theme', () {
      // Fixed on purpose: it is the parent company's mark, not this app's.
      kPalette = AstroPalette.dark;
      expect(kBrandBadgeInk, const Color(0xFF12192B));
      expect(kBrandGold, const Color(0xFFF4A93B));
      expect(kBrandCoral, const Color(0xFFE8604C));
    });
  });

  testWidgets('the subject switcher offers three subjects, one of them open',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SubjectSwitcher()),
    ));

    for (final subject in AstroSubject.values) {
      expect(find.text(subject.label), findsOneWidget);
    }

    // Exactly one is open, and it is maths. If a second ever goes true
    // without a course behind it, this is what says so.
    final open = AstroSubject.values.where((s) => s.available).toList();
    expect(open, [AstroSubject.maths]);
  });

  // -------------------------------------------------------------------------
  // The mindmap's leaf fan
  // -------------------------------------------------------------------------
  //
  // The fan is the one piece of this app whose bug is invisible until a
  // specific course has a specific number of subtopics in one unit AND a
  // student expands it. Checking it by eye means expanding forty units.
  group('mindmap leaf fan', () {
    // The subtopic node, as it is actually built: maxWidth 175 plus 10px of
    // padding each side, and about 34 tall. Two nodes overlap when their
    // centres are closer than this in BOTH axes at once.
    const nodeW = 195.0;
    const nodeH = 34.0;

    // Every real subtopics-per-unit count across the six courses, widened at
    // both ends so a new course cannot walk off the tested range unnoticed.
    const counts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    List<Offset> placed(int count) => [
          for (final leaf in mindmapLeafLayout(count))
            Offset(
              leaf.radius * math.cos(leaf.angleDeg * math.pi / 180),
              leaf.radius * math.sin(leaf.angleDeg * math.pi / 180),
            ),
        ];

    test('no two subtopics overlap, at any real count', () {
      for (final count in counts) {
        final points = placed(count);
        for (var i = 0; i < points.length; i++) {
          for (var j = i + 1; j < points.length; j++) {
            final dx = (points[i].dx - points[j].dx).abs();
            final dy = (points[i].dy - points[j].dy).abs();
            expect(dx >= nodeW || dy >= nodeH, isTrue,
                reason: 'count $count: leaves $i and $j overlap '
                    '(dx ${dx.toStringAsFixed(1)}, '
                    'dy ${dy.toStringAsFixed(1)})');
          }
        }
      }
    });

    test('the fan never wraps back around toward the root', () {
      // The span is capped so the two end leaves cannot swing behind the
      // unit and cross the line back to its parent.
      for (final count in counts) {
        for (final leaf in mindmapLeafLayout(count)) {
          expect(leaf.angleDeg.abs(), lessThanOrEqualTo(kLeafMaxSpanDeg / 2));
        }
      }
    });

    test('no leaf lands on top of its own unit', () {
      // This is the check that caught the real one. At a count of one the
      // leaf goes straight outward at kLeafMinRadius, and at the value
      // inherited from the app this layout came from that put it 102px
      // inside the unit node it hangs off.
      //
      // Note the fan's outward reach is NOT monotonic in the count — it
      // runs 368, 339, 368, 385, 368 across counts 2 to 6, because the
      // radius depends on the angular step and the step is pinned at 34
      // degrees until the span caps. Asserting it grows would be asserting
      // something false.
      const unitW = 230.0;
      const unitH = 40.0;
      for (final count in counts) {
        for (final p in placed(count)) {
          expect(p.dx.abs() >= (unitW + nodeW) / 2 ||
                  p.dy.abs() >= (unitH + nodeH) / 2, isTrue,
              reason: 'count $count: a leaf at '
                  '(${p.dx.toStringAsFixed(1)}, ${p.dy.toStringAsFixed(1)}) '
                  'overlaps its own unit');
        }
      }
    });

    test('a unit with no subtopics asks for no room', () {
      expect(mindmapLeafLayout(0), isEmpty);
      expect(mindmapFanReach(0).outward, 0);
      expect(mindmapFanReach(0).towardRoot, 0);
    });
  });

  testWidgets('an unopened subject says so rather than doing nothing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SubjectSwitcher()),
    ));

    await tester.tap(find.text('Physics'));
    await tester.pump();

    expect(find.textContaining('on the way'), findsOneWidget);
  });
}
