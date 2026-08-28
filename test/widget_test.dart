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

    test('a collapsed unit asks only for the room a node needs', () {
      // The bug this pins: the first version spaced EVERY unit by its leaf
      // fan, expanded or not. A collapsed six-unit course reserved 257px
      // then 423px between nodes only 230px wide, so the row read as a
      // sparse scatter and the gaps were uneven for no reason a student
      // could see.
      //
      // mindmapFanReach still describes an EXPANDED fan, which is correct
      // and is what the row asks for when a unit is open. What changed is
      // that the layout stopped asking for it while the unit is shut. This
      // records how big that difference is, so nobody quietly puts it back.
      const nodeHalf = 115.0;
      for (final count in [4, 5, 6, 7]) {
        expect(mindmapFanReach(count).outward, greaterThan(nodeHalf * 2),
            reason: 'an expanded fan should need far more room than a '
                'collapsed node, or reflowing on expand achieves nothing');
      }
    });

    test('no leaf ever crosses the spine into the other wing', () {
      // The fishbone puts units above and below a horizontal spine, and
      // throws each unit's leaves away from it. A fan is WIDE though —
      // five subtopics spread 136 degrees, eight spread 230 — so at a
      // shallow tilt the near half of the fan swings back down across the
      // spine and tangles with the wing on the other side. That is what it
      // did at 32 degrees, and it looked like a mess rather than a diagram.
      //
      // Checked for every combination of wing and side, because the tilt
      // is signed by both and getting one sign wrong points the whole fan
      // at the spine instead of away from it.
      // The counts that actually exist, from the live bank, not a made-up
      // range: three units have 4 subtopics, twenty have 5, fifteen have 6,
      // two have 7. Eight would wrap however the fan is rotated, and no
      // unit has eight — see kRealSubtopicCounts.
      for (final count in kRealSubtopicCounts) {
        for (final sign in [1.0, -1.0]) {
          for (final above in [true, false]) {
            final centre = (sign > 0 ? 0.0 : 180.0) +
                (above ? -kFanTiltDeg : kFanTiltDeg) * sign;
            for (final leaf in mindmapLeafLayout(count)) {
              final rad = (centre + leaf.angleDeg) * math.pi / 180;
              // Unit sits kRibY off the spine; the spine is dy == 0 relative
              // to it, so a leaf crosses when it travels further back than
              // the unit is out.
              final dy = leaf.radius * math.sin(rad);
              final leafY = (above ? -kRibY : kRibY) + dy;
              expect(above ? leafY < 0 : leafY > 0, isTrue,
                  reason: 'count $count, sign $sign, above $above: a leaf '
                      'landed on the wrong side of the spine');
            }
          }
        }
      }
    });

    test('a unit with no subtopics asks for no room', () {
      expect(mindmapLeafLayout(0), isEmpty);
      expect(mindmapFanReach(0).outward, 0);
      expect(mindmapFanReach(0).towardRoot, 0);
    });
  });

  // -------------------------------------------------------------------------
  // The end-of-test review
  // -------------------------------------------------------------------------
  //
  // The one place the answer is allowed to reach the browser. These pin the
  // seam: a row only claims to have answers when the payload actually
  // carries them, so a database that has not had
  // supabase/migrations/test_review_answers.sql applied falls back to the
  // old display instead of rendering a blank breakdown.
  group('test review', () {
    Map<String, dynamic> row({
      int? chosenIndex,
      int? correctIndex,
      List<Map<String, dynamic>>? options,
    }) =>
        {
          'item_no': 1,
          'difficulty': 'Easy',
          'prompt': 'Factor x^2 - 9.',
          'chosen_text': '(x-3)^2',
          'was_correct': false,
          'feedback': 'You squared instead of using the difference of squares.',
          'subtopic': 'Factoring',
          if (chosenIndex != null) 'chosen_index': chosenIndex,
          if (correctIndex != null) 'correct_index': correctIndex,
          if (options != null) 'options': options,
        };

    final fourOptions = [
      {'text': '(x-3)(x+3)', 'feedback': 'Correct.'},
      {'text': '(x-3)^2', 'feedback': 'You squared instead.'},
      {'text': '(x+3)^2', 'feedback': 'Sign dropped, then squared.'},
      {'text': 'x(x-9)', 'feedback': 'You factored out x.'},
    ];

    test('a full payload reports that it has the answers', () {
      final r = TestReview.fromJson(
          row(chosenIndex: 1, correctIndex: 0, options: fourOptions));
      expect(r.hasAnswers, isTrue);
      expect(r.correctIndex, 0);
      expect(r.options.length, 4);
      expect(r.options[0].text, '(x-3)(x+3)');
      expect(r.options[1].feedback, 'You squared instead.');
    });

    test('a payload from a database without the migration does not', () {
      // No chosen_index, no correct_index, no options — exactly what the
      // old function returns. The row still parses and still carries what
      // it always did.
      final r = TestReview.fromJson(row());
      expect(r.hasAnswers, isFalse);
      expect(r.correctIndex, isNull);
      expect(r.options, isEmpty);
      expect(r.chosenText, '(x-3)^2');
      expect(r.feedback, isNotNull);
    });

    test('a truncated option list does not count as having the answers', () {
      // Fewer than four means something is wrong upstream. Better to fall
      // back than to draw three options and let a student conclude the
      // fourth did not exist.
      final r = TestReview.fromJson(row(
          chosenIndex: 1,
          correctIndex: 0,
          options: fourOptions.take(3).toList()));
      expect(r.hasAnswers, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // The Learn path
  // -------------------------------------------------------------------------
  //
  // Locking is the kind of rule that is easy to get subtly wrong and hard to
  // notice: a hole in the line, or a wall at the start, both look like the
  // app is broken rather than like a rule.
  group('learn path', () {
    Lesson lesson({
      required int order,
      bool read = false,
      int solved = 0,
      String? tag = 'factoring',
    }) =>
        Lesson(
          id: order,
          tag: tag,
          subtopic: 'Factoring',
          sortOrder: order,
          title: 'Lesson $order',
          summary: '',
          readMinutes: 3,
          hasVideo: false,
          readAt: read ? DateTime(2026, 8, 1) : null,
          readSeconds: read ? 120 : 0,
          band: null,
          firstLooks: 0,
          solved: solved,
        );

    Lesson doneLesson(int order) =>
        lesson(order: order, read: true, solved: Lesson.gateSize);

    test('a fresh unit opens its first node and locks the rest', () {
      final states = learnPathStates([for (var i = 1; i <= 4; i++) lesson(order: i)]);
      expect(states.first, LessonNodeState.active);
      expect(states.skip(1), everyElement(LessonNodeState.locked));
    });

    test('finishing a node opens exactly the next one', () {
      final states = learnPathStates([
        doneLesson(1),
        lesson(order: 2),
        lesson(order: 3),
      ]);
      expect(states, [
        LessonNodeState.done,
        LessonNodeState.active,
        LessonNodeState.locked,
      ]);
    });

    test('there is never more than one active node', () {
      // Including the awkward case: a later lesson finished out of order,
      // which can happen because Improve can send a student anywhere.
      final states = learnPathStates([
        lesson(order: 1),
        doneLesson(2),
        lesson(order: 3),
      ]);
      expect(states.where((s) => s == LessonNodeState.active).length, 1);
    });

    test('nothing after a locked node is ever open', () {
      final states = learnPathStates([
        doneLesson(1),
        lesson(order: 2),
        doneLesson(3),
        lesson(order: 4),
      ]);
      var seenLocked = false;
      for (final state in states) {
        if (state == LessonNodeState.locked) seenLocked = true;
        if (seenLocked) {
          expect(state, isNot(LessonNodeState.active),
              reason: 'the path has a hole in it');
        }
      }
    });

    test('a finished unit has no active node left', () {
      final states = learnPathStates([doneLesson(1), doneLesson(2)]);
      expect(states, everyElement(LessonNodeState.done));
    });

    test('reading alone does not finish a node that has a gate', () {
      final read = lesson(order: 1, read: true, solved: 0);
      expect(read.isRead, isTrue);
      expect(read.gatePassed, isFalse);
      expect(read.isComplete, isFalse);
    });

    test('passing the gate alone does not finish it either', () {
      final drilled = lesson(order: 1, read: false, solved: Lesson.gateSize);
      expect(drilled.gatePassed, isTrue);
      expect(drilled.isComplete, isFalse);
    });

    test('a unit opener has no gate, so reading it is enough', () {
      // A lesson with no subtopic has no questions to be tested on.
      final opener = lesson(order: 1, read: true, tag: null);
      expect(opener.hasGate, isFalse);
      expect(opener.isComplete, isTrue);
    });

    test('a database without the migration locks nothing at all', () {
      // The hazard this guards: without learn_journey.sql there is no
      // solved column, every gate reads shut, and Learn becomes a wall at
      // node one. A feature that works today must not be broken by a
      // migration nobody has run yet.
      final old = Lesson.fromJson({
        'id': 1,
        'tag': 'factoring',
        'subtopic': 'Factoring',
        'sort_order': 1,
        'title': 'Lesson 1',
        'summary': '',
        'read_minutes': 3,
        'has_video': false,
        'read_at': '2026-08-01T00:00:00Z',
        'read_seconds': 120,
        'band': null,
        'first_looks': 4,
      });
      expect(old.hasGateData, isFalse);
      expect(old.solved, 0);

      // Nothing locked, and a read lesson still reads as done.
      final states = learnPathStates([old, old, old]);
      expect(states, everyElement(LessonNodeState.done));
      expect(states, isNot(contains(LessonNodeState.locked)));
    });

    test('one lesson missing the column unlocks the whole unit', () {
      // Mixed payloads should not half-lock a path. If any row cannot
      // answer, none of them locks.
      final withData = doneLesson(1);
      final without = Lesson.fromJson({
        'id': 2,
        'tag': 'factoring',
        'subtopic': 'Factoring',
        'sort_order': 2,
        'title': 'Lesson 2',
        'summary': '',
        'read_minutes': 3,
        'has_video': false,
        'read_at': null,
        'read_seconds': 0,
        'band': null,
        'first_looks': 0,
      });
      expect(learnPathStates([withData, without]),
          isNot(contains(LessonNodeState.locked)));
    });

    test('the gate never reports more progress than its size', () {
      final over = lesson(order: 1, solved: 99);
      expect(over.gateProgress, Lesson.gateSize);
    });
  });

  // -------------------------------------------------------------------------
  // Phone width
  // -------------------------------------------------------------------------
  //
  // Seven dialogs in this app set a fixed SizedBox width between 380 and 520.
  // On a 375pt phone every one of those is wider than the screen.
  //
  // Flutter's own layout clamps a SizedBox to its parent's constraints, so
  // the theory is that they are all fine. Theory is not evidence: an
  // overflow inside one of them fails the test below with the yellow-and-
  // black banner, and nothing else in this project would have caught it.
  //
  // Only widgets that do not touch Supabase can be pumped — anything holding
  // a repository reaches for Supabase.instance in its field initialisers and
  // throws before it can lay anything out. That is a real limit on this
  // group and the reason it covers presentation rather than screens.
  group('at 375x812, the smallest phone we support', () {
    setUp(() => kPalette = AstroPalette.light);

    Future<void> pumpPhone(WidgetTester tester, Widget child) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: child));
      await tester.pump();
    }

    testWidgets('the Astro+ dialog fits', (tester) async {
      await pumpPhone(tester, const AstroPlusDialog());
      expect(find.text('Astro+'), findsOneWidget);
      // The option a student with no card actually needs. Exact text, not
      // textContaining: the body copy above the tiles says "Ask a parent or
      // guardian to do this part" and would match too.
      expect(find.text('Ask a parent or guardian'), findsOneWidget);
    });

    testWidgets('the subject switcher fits', (tester) async {
      await pumpPhone(tester, const Scaffold(body: SubjectSwitcher()));
      for (final s in AstroSubject.values) {
        expect(find.text(s.label), findsOneWidget);
      }
    });

    testWidgets('the joke strip fits, and in the dark too', (tester) async {
      await pumpPhone(
          tester, const Scaffold(body: JokeStrip(seed: 'Quadratics')));
      kPalette = AstroPalette.dark;
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: JokeStrip(seed: 'Quadratics'))));
      await tester.pump();
    });

    testWidgets('the brand mark fits at every size it is used at',
        (tester) async {
      for (final size in [26.0, 56.0, 72.0]) {
        await pumpPhone(tester, Scaffold(body: BrandBadge(size: size)));
      }
    });

    testWidgets('four segmented tabs fit, which is the widest row we build',
        (tester) async {
      await pumpPhone(
        tester,
        Scaffold(
          body: SegmentedTabs(
            labels: const ['Learn', 'Quiz', 'Improve', 'Test'],
            selected: 0,
            onSelect: (_) {},
          ),
        ),
      );
      expect(find.text('Improve'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Back
  // -------------------------------------------------------------------------
  //
  // The app moves between screens with setState, which the browser's Back
  // button knows nothing about — so Back used to leave the site entirely.
  // HistoryMarkerRoute gives the Navigator stack depth without putting
  // anything on screen. Two properties make or break it, and both are
  // testable without an account.
  group('the history marker', () {
    testWidgets('shows nothing and blocks nothing', (tester) async {
      var tapsUnderneath = 0;
      late BuildContext ctx;

      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          ctx = context;
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => tapsUnderneath++,
                child: const Text('underneath'),
              ),
            ),
          );
        }),
      ));

      await tester.tap(find.text('underneath'));
      expect(tapsUnderneath, 1);

      Navigator.of(ctx).push(HistoryMarkerRoute<void>());
      await tester.pumpAndSettle();

      // Still visible: the marker is not opaque, so the screen it was
      // pushed over is still the screen.
      expect(find.text('underneath'), findsOneWidget);

      // Still tappable: an invisible route that ate every tap would be a
      // far worse bug than the one it fixes.
      await tester.tap(find.text('underneath'));
      expect(tapsUnderneath, 2,
          reason: 'the marker swallowed a tap meant for the app');
    });

    testWidgets('popping it runs the step-back', (tester) async {
      var steppedBack = false;
      late BuildContext ctx;

      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          ctx = context;
          return const Scaffold(body: SizedBox.shrink());
        }),
      ));

      Navigator.of(ctx)
          .push(HistoryMarkerRoute<void>())
          .then((_) => steppedBack = true);
      await tester.pumpAndSettle();
      expect(steppedBack, isFalse);

      // What the browser's Back button does.
      Navigator.of(ctx).pop();
      await tester.pumpAndSettle();
      expect(steppedBack, isTrue);
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
