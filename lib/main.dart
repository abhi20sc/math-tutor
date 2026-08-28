// ===========================================================================
// MATH TUTOR — student accounts, per-grade question banks.
// ===========================================================================
//
// HOW IT BEHAVES
//   A student registers with an email, password and grade (9 to 12). Once
//   signed in they see only the units for their own grade. Tapping any option
//   shows feedback for THAT option only — a wrong answer is struck out and
//   disabled, but the correct one stays hidden, so the student keeps
//   reasoning. The score counts questions solved on the first tap.
//
// HOW TO RUN IT
//   flutter pub add supabase_flutter
//   flutter run -d chrome
//
// BEFORE FIRST RUN
//   In Supabase: Authentication -> Sign In / Providers -> Email, and uncheck
//   "Confirm email" while you are testing. Otherwise a new account cannot log
//   in until someone clicks a link in their inbox. Turn it back on for real
//   students.
//
// HOW THIS FILE IS ORGANISED
//   1. Config        the few things you might change
//   2. Models        Question, AnswerOption, Profile — plain data
//   3. Data layer    auth, profiles, and where questions come from
//   4. App shell     startup
//   5. Auth gate     decides: sign-in screen, or the quiz
//   6. Auth screen   register and sign in
//   7. Home page     the quiz screen, and everything that changes
//   8. Widgets       the visual pieces
//
// THE IDEAS WORTH UNDERSTANDING
//   The repository pattern. The UI only ever talks to QuestionRepository,
//   ProfileRepository and AuthRepository, never to Supabase directly.
//   Swapping the backend later touches those three classes and nothing else.
//
//   Stateful versus stateless. HomePage and AuthScreen remember things.
//   Everything in section 8 is stateless: hand it values, it draws them.
//   setState() is how a page says "these values changed, redraw."
//
//   Row Level Security. The grade filter in fetchUnits is a convenience, not
//   a security boundary. The real protection is the policies in the SQL file,
//   enforced inside Postgres. A student cannot read another student's profile
//   even by editing the JavaScript, because the database refuses.
//
// KNOWN LIMITS
//   This file is 16,000 lines. That was the right call while the shape of
//   the app was unknown and it is a liability now. Splitting it is the next
//   structural job, and it should be split along boundaries the code has
//   revealed rather than guessed ones.
//
//   Two limits that USED to be listed here are gone, and are recorded
//   because the repository is public and a reader finding them in an old
//   copy should know they were closed:
//
//     * correct_index is no longer sent to the browser. list_questions
//       returns prompts and option text only; grading happens inside
//       submit_answer. Block B of tests/test_ama.sql is twelve checks that
//       it stays that way.
//     * password reset exists. See ResetPasswordScreen.

// TimeoutException, for the network deadline.
import 'dart:async';
// JsonEncoder, for the data export.
import 'dart:convert';
// Trigonometry, for the mindmap's leaf fan.
import 'dart:math' as math;
// PlatformDispatcher, for the uncaught-error handler in main().
import 'dart:ui';

import 'package:flutter/material.dart';
// Clipboard, for copying the share link.
import 'package:flutter/services.dart';
// Profile photos. See the note in pubspec.yaml for why both are here — the
// short version is that `image` re-encodes every upload, and that is what
// strips the GPS coordinates out of a photo taken on a phone.
// Added with: flutter pub add image_picker image
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Opens Stripe checkout in a new tab. Added with: flutter pub add url_launcher
import 'package:url_launcher/url_launcher.dart';

// ==========================================================================
// 1. CONFIG
// ==========================================================================
//
// The publishable (anon) key is designed to live in client code — what
// actually protects the data is the Row Level Security policies in the SQL
// setup file. Never put the secret / service_role key here; that one bypasses
// RLS entirely.

const String supabaseUrl = 'https://frkswzowskeqmgdrrwab.supabase.co';
const String supabaseAnonKey = 'sb_publishable_QGTakKcrvWfpTL3SRiT9uQ_mpxnP6Fn';

// The palette is unchanged from before. What is new is everything around it:
// a warm hairline instead of a cold grey one, two ink tones so text has a
// hierarchy, and a soft shadow so cards sit on the page rather than being
// outlined on it.

/// The palette, as one swappable object.
///
/// HOW THIS WORKS, AND WHY IT IS NOT Theme.of(context)
///
/// Every colour below was a top-level `const Color` used in roughly five
/// hundred places, most of them inside `const` widgets. Threading a
/// BuildContext to all of them would have been a change to five hundred call
/// sites; swapping the object behind the same names is a change to none.
///
/// So the NAMES ARE UNCHANGED — kInk, kSurface, kLine and the rest still
/// mean what they meant — but they are getters onto whichever palette is in
/// force rather than compile-time constants. The only cost is that a `const`
/// widget can no longer hold one, and those `const` keywords have been
/// removed. Nothing else moved.
///
/// The one thing this arrangement cannot do is show two themes at once in
/// the same app, which nothing here wants. Theme.of(context).brightness
/// stays the source of truth: _AstroTheme sets this object from it before
/// each build, so Material's own widgets and ours can never disagree.
// ---------------------------------------------------------------------------
// Astro STEM Labs — the parent brand
// ---------------------------------------------------------------------------
//
// Lifted from astrostemlabs.com by way of the topicmindmap app, so a student
// sees one identity across the site, the physics app and this one rather than
// three cousins. These four are FIXED in both themes: a brand mark that
// restyles itself in the dark is not a mark, it is a suggestion.
//
//   badgeInk   the near-black tile the rocket sits on
//   gold/coral the gradient through the rocket, top-left to bottom-right
//   navy       primary actions and filled surfaces
//
// Navy is the only one that also does interface work — see accentSurface.
const Color kBrandBadgeInk = Color(0xFF12192B);
const Color kBrandGold = Color(0xFFF4A93B);
const Color kBrandCoral = Color(0xFFE8604C);
const Color kBrandNavy = Color(0xFF1D3557);

/// The gradient through the rocket. Same angle as the wordmark's.
const LinearGradient kBrandGradient = LinearGradient(
  colors: [kBrandGold, kBrandCoral],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// The name over the door. Maths is one subject inside it, not the whole
/// thing — see [AstroSubject].
const String kBrandName = 'Astro STEM Labs';

/// The rocket badge.
///
/// One widget covers every size it appears at — the sign-in hero at 76, the
/// sidebar mark in the twenties — because [size] drives the corner radius,
/// the icon and the glow proportionally. Two hand-tuned assets at two sizes
/// is how a mark starts looking like two marks.
///
/// Fixed colours in both themes, deliberately. Everything else in this file
/// swaps with the palette; the badge does not, because it is the same mark
/// that appears on astrostemlabs.com and on the physics app, and a student
/// who sees it change should be seeing a different company.
class BrandBadge extends StatelessWidget {
  final double size;

  const BrandBadge({super.key, this.size = 76});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: kBrandName,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kBrandBadgeInk,
          borderRadius: BorderRadius.circular(size * 0.26),
          boxShadow: [
            BoxShadow(
              color: kBrandCoral.withValues(alpha: 0.35),
              blurRadius: size * 0.29,
              offset: Offset(0, size * 0.11),
            ),
          ],
        ),
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => kBrandGradient.createShader(bounds),
            // The mask paints the gradient THROUGH the glyph, so the icon's
            // own colour only has to be opaque — white is the conventional
            // choice and any other would change nothing.
            child: Icon(Icons.rocket_launch_rounded,
                size: size * 0.5, color: Colors.white),
          ),
        ),
      ),
    );
  }
}


/// The three subjects, as a row of chips. Maths is on; the other two say so
/// plainly when tapped rather than doing nothing, because a control that
/// ignores a tap reads as broken rather than as unavailable.
class SubjectSwitcher extends StatelessWidget {
  const SubjectSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final subject in AstroSubject.values)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _SubjectChip(subject: subject),
          ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final AstroSubject subject;

  const _SubjectChip({required this.subject});

  @override
  Widget build(BuildContext context) {
    final on = subject.available;
    return Semantics(
      button: true,
      enabled: on,
      selected: on,
      label: on
          ? '${subject.label}. ${subject.blurb}'
          : '${subject.label}. Not open yet.',
      child: Tooltip(
        message: on ? subject.blurb : '${subject.label} is not open yet.',
        child: Material(
          color: on ? kAccentSurface : kTrack,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: on
                ? null
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${subject.label} is on the way. '
                          'Maths is the one that is open today.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
            child: Padding(
              // Symmetric. It was 9 against 10, which is not a centring
              // rule, it is a number somebody typed.
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    subject.icon,
                    size: 13,
                    // Not just dimmed: a disabled chip has to stay readable,
                    // or "coming soon" turns into "something is broken".
                    color: on ? kOnAccent : kInkSoft,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    subject.label,
                    // Same reason as the Open pill: a label this size next
                    // to a glyph sits a hair high, because the text box is
                    // taller than its ink and the icon's is not.
                    strutStyle:
                        const StrutStyle(forceStrutHeight: true, height: 1),
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: on ? kOnAccent : kInkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subjects
// ---------------------------------------------------------------------------
//
// Astro STEM Labs is three subjects. This app is the maths one, and the other
// two are named here rather than hidden because a student who opens the
// sidebar should be able to see that physics and tech are coming without
// having to be told — and because leaving them out would mean the maths app
// silently claims to be the whole company.
//
// Nothing behind physics or tech is stubbed in. There is no empty course
// list, no placeholder unit, no table waiting for rows. They are two
// disabled chips and a sentence, which is the honest amount of product to
// ship for something that does not exist yet.
enum AstroSubject {
  maths(
    label: 'Maths',
    icon: Icons.functions_rounded,
    available: true,
    blurb: 'Grades 9 to 12, six Ontario courses.',
  ),
  physics(
    label: 'Physics',
    icon: Icons.rocket_launch_rounded,
    available: false,
    blurb: 'Not open yet.',
  ),
  tech(
    label: 'Tech',
    icon: Icons.terminal_rounded,
    available: false,
    blurb: 'Not open yet.',
  );

  final String label;
  final IconData icon;
  final bool available;
  final String blurb;

  const AstroSubject({
    required this.label,
    required this.icon,
    required this.available,
    required this.blurb,
  });
}

// The five traffic bands and the eight unit hues, per theme. Declared out
// here rather than inline because the two palettes are `const` and a const
// constructor cannot hold a list literal that is not itself const.
//
// Band order is Band's own: grey, orange, yellow, lightGreen, green.
//
// The light sets are exactly what shipped, unchanged — they were measured
// against paper and they hold up. The dark sets are new. Each dark hue keeps
// its light counterpart's hue angle and moves only lightness, so 'Developing'
// is recognisably the same yellow in both themes rather than a different
// colour that happens to sit in the same slot.

const List<Color> _lightBandFill = [
  Color(0xFF9AA0A6), // grey  — not enough evidence yet
  Color(0xFFE8590C), // orange — needs work
  Color(0xFFD9A404), // yellow — developing
  Color(0xFF66BB6A), // light green — nearly there
  Color(0xFF2E7D32), // green — mastered
];
const List<Color> _lightBandText = [
  Color(0xFF5F6368),
  Color(0xFFBC4708),
  Color(0xFF8A6803),
  Color(0xFF33753B),
  Color(0xFF2E7D32),
];

// 4.94 to 9.13 as fills on a dark card, 6.23 to 12.10 as words. The light
// set in the same place measured 2.55 to 3.01 as words, which is the bug
// this fixes.
const List<Color> _darkBandFill = [
  Color(0xFF8A939B),
  Color(0xFFF5834A),
  Color(0xFFE8BC3A),
  Color(0xFF8CD98F),
  Color(0xFF5FBF63),
];
const List<Color> _darkBandText = [
  Color(0xFF9AA6B4),
  Color(0xFFF79A69),
  Color(0xFFEDC95C),
  Color(0xFFA3E0A5),
  Color(0xFF7FD183),
];

const List<Color> _unitTintsLight = [
  Color(0xFF2F6F62), // teal
  Color(0xFF3B5BA9), // indigo
  Color(0xFF7B4A86), // plum
  Color(0xFFA8552F), // clay
  Color(0xFF4F7A3A), // moss
  Color(0xFF2F6F8F), // slate blue
  Color(0xFFA6455F), // rose
  Color(0xFF8A6A1F), // ochre
];
const List<Color> _unitTintsLightDeep = [
  Color(0xFF285E53),
  Color(0xFF324D90),
  Color(0xFF693F72),
  Color(0xFF8F4828),
  Color(0xFF436831),
  Color(0xFF285E7A),
  Color(0xFF8D3B51),
  Color(0xFF755A1A),
];

// Same eight hues, lightness raised until each clears 4.5:1 on BOTH dark
// grounds (the page and the raised card). They land at 4.61 to 4.71 on the
// card, which is the tighter of the two.
const List<Color> _unitTintsDark = [
  Color(0xFF429C8A), // teal
  Color(0xFF728DCE), // indigo
  Color(0xFFAC7DB7), // plum
  Color(0xFFCE764E), // clay
  Color(0xFF649B4A), // moss
  Color(0xFF4096C0), // slate blue
  Color(0xFFC5758A), // rose
  Color(0xFFAF8727), // ochre
];
// Lighter again, for initials sitting on a 12% wash of their own hue. The
// undeepened set measures about 3.95 there, which is the same almost-fine
// that made the light theme need its own deep set.
const List<Color> _unitTintsDarkDeep = [
  Color(0xFF48AA97),
  Color(0xFF8199D3),
  Color(0xFFB58CBF),
  Color(0xFFD48764),
  Color(0xFF6DA951),
  Color(0xFF57A3C8),
  Color(0xFFCD8799),
  Color(0xFFC0942B),
];

class AstroPalette {
  final Brightness brightness;
  final Color accent;
  final Color accentDeep;
  final Color wrong;
  final Color hint;
  final Color surface;
  final Color card;
  final Color ink;
  final Color inkSoft;
  final Color line;

  /// Tints. Not decoration: each one means something, and each has to be
  /// decided for the dark theme rather than dimmed, because a pale wash on a
  /// dark ground is a light rectangle, not a tint.
  final Color wash;      // behind a correct answer, and inline code
  final Color warmTint;  // behind anything pending or awaiting a person
  final Color track;     // the empty part of a progress bar
  final Color wrongWash; // behind an option already ruled out

  /// A card or button FILLED with the accent, and what sits on top of it.
  /// Separate from `accent` because the accent has to lighten in the dark to
  /// stay legible as text, and a lightened teal is the wrong thing to fill a
  /// card with — white on it measures about 1.9:1. Filled surfaces go the
  /// other way and darken.
  final Color accentSurface;
  final Color onAccent;

  final List<BoxShadow> cardShadow;

  /// The five traffic bands, in Band's own declaration order:
  /// grey, orange, yellow, lightGreen, green.
  ///
  /// These live on the palette rather than in a top-level switch because
  /// they were the worst of the dark-theme leaks: bandText is DARKENED for
  /// white paper, so on a dark card the five words measured 2.55 to 3.01
  /// against a 4.5 floor — every one of them failing, and failing hardest
  /// on grey, which is the state most students are in most of the time.
  final List<Color> bandFill;
  final List<Color> bandText;

  /// The eight unit identity hues, and the variants for text on a 12% wash
  /// of the matching hue. Same story as the bands: the light set is tuned
  /// against paper and goes muddy on a dark ground.
  final List<Color> unitTints;
  final List<Color> unitTintsDeep;

  const AstroPalette({
    required this.brightness,
    required this.accent,
    required this.accentDeep,
    required this.wrong,
    required this.hint,
    required this.surface,
    required this.card,
    required this.ink,
    required this.inkSoft,
    required this.line,
    required this.wash,
    required this.warmTint,
    required this.track,
    required this.wrongWash,
    required this.accentSurface,
    required this.onAccent,
    required this.cardShadow,
    required this.bandFill,
    required this.bandText,
    required this.unitTints,
    required this.unitTintsDeep,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Astro STEM Labs, light. The warm cream this app shipped with has gone
  /// cool: the parent brand is navy, teal and off-white, and a cream page
  /// under a navy mark reads as two products stapled together.
  ///
  /// Two roles the brand splits that this app used to run through one
  /// colour, and the split is the reason the rebrand is more than a
  /// find-and-replace:
  ///
  ///   accent         teal. Text, links, ticks, active state.
  ///   accentSurface  navy. Anything FILLED and carrying white text.
  ///
  /// Teal at the lightness that works as 13px text measures 3.3:1 as a
  /// button fill under white, which fails. Navy measures 12.4:1. So the
  /// primary button is navy and the link beside it is teal, which is
  /// exactly how astrostemlabs.com already works.
  ///
  /// Every value below was measured, not chosen: the lowest ratio in the
  /// whole light theme is accent-on-wash at 4.52:1.
  static const AstroPalette light = AstroPalette(
    brightness: Brightness.light,
    accent: Color(0xFF0F7B7D), // Astro teal, darkened to clear 4.5 as text
    accentDeep: Color(0xFF0A5F61), // pressed and hover states
    wrong: Color(0xFFC2412E),
    hint: Color(0xFF8F620E),
    surface: Color(0xFFF5F7F8), // page background, Astro off-white
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1B2430), // headings and answers
    inkSoft: Color(0xFF5C6670), // labels, captions, hints
    line: Color(0xFFDCE1E4), // hairline, cool to match the page
    wash: Color(0xFFEAF4F4),
    warmTint: Color(0xFFFDF3E3), // the brand gold, at wash strength
    track: Color(0xFFE7ECEE),
    wrongWash: Color(0xFFFCEFEC),
    accentSurface: kBrandNavy,
    onAccent: Color(0xFFFFFFFF),
    cardShadow: [
      BoxShadow(color: Color(0x0F1B2430), blurRadius: 20, offset: Offset(0, 6)),
      BoxShadow(color: Color(0x0A1B2430), blurRadius: 2, offset: Offset(0, 1)),
    ],
    bandFill: _lightBandFill,
    bandText: _lightBandText,
    unitTints: _unitTintsLight,
    unitTintsDeep: _unitTintsLightDeep,
  );

  /// Not an inversion. A few things had to be decided rather than flipped:
  ///
  ///  * the accent LIGHTENS. #2F6F62 on a dark ground measures about 2.6:1,
  ///    which fails as text and reads as muddy as a fill. #6FB3A2 is the same
  ///    hue with the lightness moved to where it works.
  ///  * the ground is a very dark green-grey, not black. Pure black next to
  ///    a teal accent looks like a terminal; this keeps the warmth the cream
  ///    gives the light theme.
  ///  * cards are LIGHTER than the page, because in the dark a raised
  ///    surface catches more light, not less — the opposite of the shadow
  ///    that lifts them in daylight.
  ///  * the shadow all but disappears. A dark shadow on a dark ground is
  ///    invisible; the card edge does the work instead, so the border stays
  ///    and the shadow shrinks to a hint of depth.
  static const AstroPalette dark = AstroPalette(
    brightness: Brightness.dark,
    accent: Color(0xFF4DBDBE),
    accentDeep: Color(0xFF7FD4D5),
    wrong: Color(0xFFEE8873),
    hint: Color(0xFFE3B45C),
    surface: Color(0xFF10141A),
    card: Color(0xFF1E2530),
    ink: Color(0xFFE7ECF2),
    inkSoft: Color(0xFF9AA6B4),
    line: Color(0xFF333C48),
    wash: Color(0xFF123033),
    warmTint: Color(0xFF2E2617),
    track: Color(0xFF2A323D),
    wrongWash: Color(0xFF3A2621),
    // Navy itself is too dark to read as a raised, tappable surface against
    // a near-black page — it disappears into it. Lifted toward the light,
    // hue held, so a primary button still says "navy" but says it out loud.
    accentSurface: Color(0xFF3B5C86),
    onAccent: Color(0xFFFFFFFF),
    cardShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 5)),
      BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
    bandFill: _darkBandFill,
    bandText: _darkBandText,
    unitTints: _unitTintsDark,
    unitTintsDeep: _unitTintsDarkDeep,
  );
}

/// The palette in force. Assigned by _AstroTheme from the BuildContext's own
/// brightness, once per build of the app shell, before anything reads it.
AstroPalette kPalette = AstroPalette.light;

Color get kAccent => kPalette.accent;
Color get kAccentDeep => kPalette.accentDeep;
Color get kWrong => kPalette.wrong;
Color get kHint => kPalette.hint;
Color get kSurface => kPalette.surface;

/// White in the light theme. In the dark it is the raised surface — which is
/// why this name exists at all: three quarters of the Colors.white in this
/// file meant "card", and the rest meant "text on teal", which stays white
/// in both themes and was left alone.
Color get kCard => kPalette.card;
Color get kInk => kPalette.ink;
Color get kInkSoft => kPalette.inkSoft;
Color get kLine => kPalette.line;
Color get kWash => kPalette.wash;
Color get kWarmTint => kPalette.warmTint;
Color get kTrack => kPalette.track;
Color get kWrongWash => kPalette.wrongWash;
Color get kAccentSurface => kPalette.accentSurface;
Color get kOnAccent => kPalette.onAccent;
List<BoxShadow> get kCardShadow => kPalette.cardShadow;

// ---------------------------------------------------------------------------
// Unit colours — IDENTITY, never status
// ---------------------------------------------------------------------------
//
// One strong colour was the right rule while there was one kind of thing on
// the screen. There are two: how a student is DOING, and what they are
// working ON. The five traffic-light bands own the first and must keep
// owning it — a colour that means "you have this" has to mean that
// everywhere, or it means nothing. So these are strictly the second: a unit
// keeps its colour whether the student is brilliant at it or has never
// opened it, and nothing here ever changes with progress.
//
// That separation is what makes it safe to add colour at all. Eight hues,
// all measured at 4.5:1 or better against BOTH white and the cream page, so
// each works as a fill under white text and as text on the background:
//
//   teal 5.88  indigo 6.45  plum 6.63  clay 5.24
//   moss 5.03  slate 5.54   rose 5.77  ochre 5.05
//
// Deliberately not the band hues. Nothing here is green or orange, so a unit
// chip can never be misread as "mastered" or "needs work".
/// A stable index into the unit palettes, from any string. Used for units
/// (by name) and for people (by id).
///
/// The hues themselves now live on [AstroPalette] (see _unitTintsLight and
/// _unitTintsDark) because they had to be decided per theme rather than
/// dimmed — the same problem the bands had. What did NOT change is that the
/// index comes from the NAME: 'Factoring' is the same plum in Grade 10 as it
/// is anywhere else, in either theme, and adding a unit to the middle of a
/// course does not silently repaint every unit after it.
int tintIndex(String seed) {
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h % kPalette.unitTints.length;
}

/// The eight unit identity hues in force. Identity, never status — a unit
/// keeps its colour whether the student is brilliant at it or has never
/// opened it. Deliberately none of them green or orange, so a unit chip can
/// never be misread as 'mastered' or 'needs work'.
List<Color> get kUnitTints => kPalette.unitTints;

/// The same eight, for text on a pale wash of its own hue.
List<Color> get kUnitTintsDeep => kPalette.unitTintsDeep;

/// The colour a unit keeps forever.
Color unitTint(String unit) => kUnitTints[tintIndex(unit)];


// Question prompts are set in a serif and the interface in a sans, so a piece
// of maths never looks like a button label. These are fonts already on the
// machine — no package to install, nothing to download at runtime.
const String kSerif = 'Georgia';
const List<String> kSerifFallback = [
  'Iowan Old Style',
  'Palatino',
  'Times New Roman',
  'serif',
];
const List<String> kMonoFallback = [
  'SF Mono',
  'Menlo',
  'Consolas',
  'monospace',
];

/// Shown on the register screen and in the header once signed in.
/// Fallback course code per grade, used only when a profile predates
/// courses and has no course yet. The real list comes from the database —
/// see CourseOption and list_courses() — because one grade can hold several
/// courses (Grade 12 has three) and only the server knows which of them
/// actually have questions loaded.
const Map<int, String> kDefaultCourseForGrade = {
  9: 'MTH1W',
  10: 'MPM2D',
  11: 'MCR3U',
  12: 'MHF4U',
};

// ==========================================================================
// 2. MODELS
// ==========================================================================
//
// Plain data classes. No Flutter, no network — just shapes.
//
// fromJson reads the snake_case column names Postgres returns (course_code,
// correct_index) and maps them onto Dart's camelCase fields.

class AnswerOption {
  final String text;

  const AnswerOption({required this.text});

  /// Only the text arrives from the server. The feedback for an option is
  /// handed over one at a time, after it has been tapped — see Verdict.
  factory AnswerOption.fromJson(Map<String, dynamic> json) =>
      AnswerOption(text: json['text'] as String);
}

class Question {
  final String courseCode;
  final String unit;
  final String difficulty;
  final String prompt;
  final List<AnswerOption> options;

  /// Position within the unit, straight out of the SQL file.
  ///
  /// This is what an attempt is recorded against, rather than the row id.
  /// The grade files delete and re-insert on every run, which hands out new
  /// ids each time, so an id would stop pointing at the same question the
  /// moment a typo was fixed. sort_order is typed by hand and stays put.
  final int sortOrder;

  /// Short slug naming the mistake this question is built to catch. Null
  /// until the bank is tagged.
  final String? misconceptionTag;

  /// The subtopic's display name ('Solving by substitution'), straight from
  /// the same vocabulary table the report uses. Shown as a small chip on the
  /// question so a student always knows what they are practising — and can
  /// connect it to the topic map later.
  final String? subtopic;

  /// Optional figure path ('figures/tri_07.png'), served as a static file
  /// deployed alongside the app. Null for most questions.
  final String? figure;

  const Question({
    required this.courseCode,
    required this.unit,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.sortOrder,
    this.misconceptionTag,
    this.subtopic,
    this.figure,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        courseCode: json['course_code'] as String,
        unit: json['unit'] as String,
        difficulty: json['difficulty'] as String,
        prompt: json['prompt'] as String,
        sortOrder: json['sort_order'] as int,
        misconceptionTag: json['misconception_tag'] as String?,
        subtopic: json['subtopic'] as String?,
        figure: json['figure'] as String?,
        options: (json['options'] as List<dynamic>)
            .map((o) => AnswerOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}

/// One course a student can be in: the code that keys everything, the
/// school year it belongs to, and how many questions are actually loaded.
///
/// This exists because grade stopped being enough. Grade 12 alone has three
/// courses — Advanced Functions, Calculus and Vectors, Data Management — and
/// keyed on grade they would pour their units into one list.
class CourseOption {
  final String code;
  final int grade;
  final String title;
  final int questions;

  const CourseOption({
    required this.code,
    required this.grade,
    required this.title,
    required this.questions,
  });

  String get label => '$code — $title';

  factory CourseOption.fromJson(Map<String, dynamic> j) => CourseOption(
        code: j['code'] as String,
        grade: (j['grade'] as num).toInt(),
        title: j['title'] as String,
        questions: (j['questions'] as num?)?.toInt() ?? 0,
      );
}

/// A class, as its teacher sees it.
class ClassInfo {
  final int id;
  final String name;
  final int grade;
  final String course;
  final int students;
  final int invited;
  final int activeToday;

  const ClassInfo({
    required this.id,
    required this.name,
    required this.grade,
    required this.course,
    this.students = 0,
    this.invited = 0,
    this.activeToday = 0,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> j) => ClassInfo(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        grade: (j['grade'] as num).toInt(),
        course: (j['course'] as String?) ?? '',
        students: (j['students'] as num?)?.toInt() ?? 0,
        invited: (j['invited'] as num?)?.toInt() ?? 0,
        activeToday: (j['active_today'] as num?)?.toInt() ?? 0,
      );
}

/// A class as the student sees it, which is the other half of being honest
/// with them: who can see their work, and since when.
class StudentClass {
  final int classId;
  final String name;
  final String teacherEmail;
  final String status; // invited | active

  const StudentClass({
    required this.classId,
    required this.name,
    required this.teacherEmail,
    required this.status,
  });

  bool get isInvitation => status == 'invited';

  factory StudentClass.fromJson(Map<String, dynamic> j) => StudentClass(
        classId: (j['class_id'] as num).toInt(),
        name: j['class_name'] as String,
        teacherEmail: (j['teacher_email'] as String?) ?? 'your teacher',
        status: j['status'] as String,
      );
}

/// One student on a roster.
class RosterEntry {
  final String studentId;
  final String name;
  final String email;
  final int unitsMedalled;
  final int gold;
  final int questionsSeen;
  final int? firstTryRate;
  final DateTime? lastActive;

  /// Path in the private avatars bucket, or null. See avatars.sql.
  final String? avatarPath;

  const RosterEntry({
    required this.studentId,
    required this.name,
    required this.email,
    required this.unitsMedalled,
    required this.gold,
    required this.questionsSeen,
    required this.firstTryRate,
    required this.lastActive,
    this.avatarPath,
  });

  factory RosterEntry.fromJson(Map<String, dynamic> j) => RosterEntry(
        avatarPath: j['avatar_path'] as String?,
        studentId: j['student_id'] as String,
        name: (j['full_name'] as String?) ?? 'Student',
        email: (j['email'] as String?) ?? 'unknown',
        unitsMedalled: (j['units_medalled'] as num?)?.toInt() ?? 0,
        gold: (j['gold'] as num?)?.toInt() ?? 0,
        questionsSeen: (j['questions_seen'] as num?)?.toInt() ?? 0,
        firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
        lastActive: j['last_active'] == null
            ? null
            : DateTime.parse(j['last_active'] as String),
      );

  /// Plain words beat a timestamp on a screen a teacher scans quickly.
  String get lastSeen {
    if (lastActive == null) return 'never opened it';
    final days = DateTime.now().difference(lastActive!).inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 7) return '$days days ago';
    if (days < 14) return 'last week';
    return '$days days ago';
  }

  /// A student who has not appeared in two weeks is a different problem from
  /// one who is practising and struggling. The dashboard should say so.
  bool get isDrifting =>
      lastActive == null || DateTime.now().difference(lastActive!).inDays >= 14;
}

/// One row of the query this whole project was built to make possible.
class MisconceptionRow {
  final String label;
  final String unit;
  final int studentsAffected;
  final int timesChosen;
  final int? shareOfClass;

  const MisconceptionRow({
    required this.label,
    required this.unit,
    required this.studentsAffected,
    required this.timesChosen,
    required this.shareOfClass,
  });

  factory MisconceptionRow.fromJson(Map<String, dynamic> j) => MisconceptionRow(
        label: (j['label'] as String?) ?? 'untagged',
        unit: j['unit'] as String,
        studentsAffected: (j['students_affected'] as num?)?.toInt() ?? 0,
        timesChosen: (j['times_chosen'] as num?)?.toInt() ?? 0,
        shareOfClass: (j['share_of_class'] as num?)?.toInt(),
      );
}

/// How the class is doing in one topic. The planning view: not who is
/// behind, but which topics the room as a whole has not got.
class UnitBreakdown {
  final String unit;
  final int studentsAttempted;
  final int studentsFinished;
  final int questionsAttempted;
  final int wrongTaps;
  final int? firstTryRate;
  final int studentsStruggling;
  final String? topMistake;

  const UnitBreakdown({
    required this.unit,
    required this.studentsAttempted,
    required this.studentsFinished,
    required this.questionsAttempted,
    required this.wrongTaps,
    required this.firstTryRate,
    required this.studentsStruggling,
    required this.topMistake,
  });

  factory UnitBreakdown.fromJson(Map<String, dynamic> j) => UnitBreakdown(
        unit: j['unit'] as String,
        studentsAttempted: (j['students_attempted'] as num?)?.toInt() ?? 0,
        studentsFinished: (j['students_finished'] as num?)?.toInt() ?? 0,
        questionsAttempted: (j['questions_attempted'] as num?)?.toInt() ?? 0,
        wrongTaps: (j['wrong_taps'] as num?)?.toInt() ?? 0,
        firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
        studentsStruggling: (j['students_struggling'] as num?)?.toInt() ?? 0,
        topMistake: j['top_mistake'] as String?,
      );
}

/// A single question the class is failing, with the wrong option most of
/// them chose.
class HardQuestion {
  final String unit;
  final int sortOrder;
  final String difficulty;
  final String prompt;
  final int studentsWrong;
  final int timesWrong;
  final String? topChoice;
  final String? topFeedback;
  final String? mistake;

  const HardQuestion({
    required this.unit,
    required this.sortOrder,
    required this.difficulty,
    required this.prompt,
    required this.studentsWrong,
    required this.timesWrong,
    required this.topChoice,
    required this.topFeedback,
    required this.mistake,
  });

  factory HardQuestion.fromJson(Map<String, dynamic> j) => HardQuestion(
        unit: j['unit'] as String,
        sortOrder: (j['sort_order'] as num).toInt(),
        difficulty: (j['difficulty'] as String?) ?? '',
        prompt: j['prompt'] as String,
        studentsWrong: (j['students_wrong'] as num?)?.toInt() ?? 0,
        timesWrong: (j['times_wrong'] as num?)?.toInt() ?? 0,
        topChoice: j['top_choice'] as String?,
        topFeedback: j['top_feedback'] as String?,
        mistake: j['mistake'] as String?,
      );
}

/// One unit inside a student report.
class UnitLine {
  final String unit;
  final int questions;
  final int firstTry;
  final int wrongTaps;
  final Medal medal;

  const UnitLine({
    required this.unit,
    required this.questions,
    required this.firstTry,
    required this.wrongTaps,
    required this.medal,
  });

  factory UnitLine.fromJson(Map<String, dynamic> j) => UnitLine(
        unit: j['unit'] as String,
        questions: (j['questions'] as num?)?.toInt() ?? 0,
        firstTry: (j['first_try'] as num?)?.toInt() ?? 0,
        wrongTaps: (j['wrong_taps'] as num?)?.toInt() ?? 0,
        medal: medalFromText(j['medal'] as String?),
      );
}

/// One subtopic as the tutor sees it: how well, and how much.
///
/// The second number is the one most dashboards leave out. A student who
/// practises what they are already good at and steers around what they are
/// not produces no data on the hard topic — so a tool that only reports
/// scores never mentions it. [coveragePct] against [avoided] is what makes
/// that visible.
class SubtopicDiagnostic {
  final String unit;
  final String tag;
  final String label;
  final int questionsTotal;
  final int questionsSeen;
  final int coveragePct;
  final int unitCoverage;
  final int firstLooks;
  final int? firstTryRate;
  final Band band;

  /// Under half the attention this student gave their best-covered
  /// subtopic in the same unit, in a unit they have genuinely started.
  final bool avoided;

  final DateTime? lastSeen;

  const SubtopicDiagnostic({
    required this.unit,
    required this.tag,
    required this.label,
    required this.questionsTotal,
    required this.questionsSeen,
    required this.coveragePct,
    required this.unitCoverage,
    required this.firstLooks,
    required this.firstTryRate,
    required this.band,
    required this.avoided,
    this.lastSeen,
  });

  /// The case worth acting on: weak AND being steered around.
  bool get isBlindSpot =>
      avoided && (band == Band.orange || band == Band.yellow ||
                  band == Band.grey);

  /// Enough evidence to call it a strength.
  bool get isStrength =>
      firstLooks >= 2 && (band == Band.green || band == Band.lightGreen);

  factory SubtopicDiagnostic.fromJson(Map<String, dynamic> j) =>
      SubtopicDiagnostic(
        unit: j['unit'] as String,
        tag: j['tag'] as String? ?? '',
        label: j['label'] as String? ?? '',
        questionsTotal: (j['questions_total'] as num?)?.toInt() ?? 0,
        questionsSeen: (j['questions_seen'] as num?)?.toInt() ?? 0,
        coveragePct: (j['coverage_pct'] as num?)?.toInt() ?? 0,
        unitCoverage: (j['unit_coverage'] as num?)?.toInt() ?? 0,
        firstLooks: (j['first_looks'] as num?)?.toInt() ?? 0,
        firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
        band: bandFrom(j['band'] as String?),
        avoided: j['avoided'] == true,
        lastSeen: j['last_seen'] == null
            ? null
            : DateTime.parse(j['last_seen'] as String).toLocal(),
      );
}

/// One level of one unit, for a single student.
///
/// The unit rows on the report answer "how is Trigonometry going". These
/// answer the question a tutor asks next: where inside it did it stop going
/// well. Easy through Advanced, with the medal actually earned, how many
/// wrong taps it cost, and the mistake behind most of them.
class LevelDetail {
  final String unit;
  final String level;
  final Medal medal;

  /// The best first-try count ever recorded on this level. It is what the
  /// medal was awarded from, so it never falls.
  final int bestFirstTry;
  final int total;
  final int wrongTaps;
  final String? topMistake;
  final DateTime? lastActive;

  const LevelDetail({
    required this.unit,
    required this.level,
    required this.medal,
    required this.bestFirstTry,
    required this.total,
    required this.wrongTaps,
    required this.topMistake,
    required this.lastActive,
  });

  bool get untouched => bestFirstTry == 0 && wrongTaps == 0;

  /// Ten wrong taps on a ten-question level is a different story from ten
  /// spread across four levels, so the ratio is what gets shown.
  double get tapsPerQuestion => total == 0 ? 0 : wrongTaps / total;

  factory LevelDetail.fromJson(Map<String, dynamic> j) => LevelDetail(
        unit: j['unit'] as String,
        level: j['level'] as String,
        medal: medalFromText(j['medal'] as String?),
        bestFirstTry: (j['best_first_try'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        wrongTaps: (j['wrong_taps'] as num?)?.toInt() ?? 0,
        topMistake: j['top_mistake'] as String?,
        lastActive: j['last_active'] == null
            ? null
            : DateTime.parse(j['last_active'] as String).toLocal(),
      );
}

/// How far a whole class has got through one unit, and what they earned.
///
/// The topic breakdown already says how well the room is doing. This says
/// how many of them have finished the unit at all — a different question,
/// and usually the one that decides whether it is safe to move on.
class UnitMedalSummary {
  final String unit;
  final int studentsDone;
  final int studentsTotal;
  final int? avgFirstTry;
  final int gold;
  final int silver;
  final int bronze;

  const UnitMedalSummary({
    required this.unit,
    required this.studentsDone,
    required this.studentsTotal,
    required this.avgFirstTry,
    required this.gold,
    required this.silver,
    required this.bronze,
  });

  int get medals => gold + silver + bronze;

  double get doneFraction =>
      studentsTotal == 0 ? 0 : studentsDone / studentsTotal;

  factory UnitMedalSummary.fromJson(Map<String, dynamic> j) =>
      UnitMedalSummary(
        unit: j['unit'] as String,
        studentsDone: (j['students_done'] as num?)?.toInt() ?? 0,
        studentsTotal: (j['students_total'] as num?)?.toInt() ?? 0,
        avgFirstTry: (j['avg_first_try'] as num?)?.round(),
        gold: (j['gold'] as num?)?.toInt() ?? 0,
        silver: (j['silver'] as num?)?.toInt() ?? 0,
        bronze: (j['bronze'] as num?)?.toInt() ?? 0,
      );
}

/// One class a student is actually in, as the admin panel sees it.
///
/// admin_list_students hands the classes back as a single display string,
/// which is fine to read and useless to act on. This carries the id, so
/// "remove them from this one" can name a class rather than guess at it.
class AdminStudentClass {
  final int classId;
  final String name;
  final String course;
  final String teacherEmail;
  final DateTime? joinedAt;

  const AdminStudentClass({
    required this.classId,
    required this.name,
    required this.course,
    required this.teacherEmail,
    required this.joinedAt,
  });

  factory AdminStudentClass.fromJson(Map<String, dynamic> j) =>
      AdminStudentClass(
        classId: (j['class_id'] as num).toInt(),
        name: (j['class_name'] as String?) ?? 'Class',
        course: (j['course'] as String?) ?? '',
        teacherEmail: (j['teacher_email'] as String?) ?? '',
        joinedAt: j['joined_at'] == null
            ? null
            : DateTime.parse(j['joined_at'] as String).toLocal(),
      );
}

/// A note a tutor wrote to a student, optionally about one subtopic.
class TutorNote {
  final int id;
  final String? tag;
  final String? label;
  final String body;
  final DateTime createdAt;
  final DateTime? seenAt;
  final String teacherEmail;

  /// True on the tutor's own notes — only the author may delete one.
  final bool mine;

  const TutorNote({
    required this.id,
    required this.tag,
    required this.label,
    required this.body,
    required this.createdAt,
    required this.seenAt,
    required this.teacherEmail,
    this.mine = false,
  });

  factory TutorNote.fromJson(Map<String, dynamic> j) => TutorNote(
        id: (j['id'] as num).toInt(),
        tag: j['tag'] as String?,
        label: j['label'] as String?,
        body: j['body'] as String,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        seenAt: j['seen_at'] == null
            ? null
            : DateTime.parse(j['seen_at'] as String).toLocal(),
        teacherEmail: j['teacher_email'] as String? ?? '',
        mine: j['mine'] == true,
      );
}

/// One thing a student keeps getting wrong.
class WeakSpot {
  final String label;
  final String unit;
  final int times;

  const WeakSpot({
    required this.label,
    required this.unit,
    required this.times,
  });

  factory WeakSpot.fromJson(Map<String, dynamic> j) => WeakSpot(
        label: (j['label'] as String?) ?? 'untagged',
        unit: (j['unit'] as String?) ?? '',
        times: (j['times'] as num?)?.toInt() ?? 0,
      );
}

/// The whole picture for one student.
///
/// Deliberately the same shape as the parent report, so the two can never
/// tell different stories about the same child.
class StudentOverview {
  final String name;
  final String email;
  final int grade;
  final int questionsSeen;
  final int firstTry;
  final int? firstTryRate;
  final int wrongTaps;
  final int daysActive;
  final DateTime? lastActive;
  final List<UnitLine> units;
  final List<WeakSpot> weakSpots;

  const StudentOverview({
    required this.name,
    required this.email,
    required this.grade,
    required this.questionsSeen,
    required this.firstTry,
    required this.firstTryRate,
    required this.wrongTaps,
    required this.daysActive,
    required this.lastActive,
    required this.units,
    required this.weakSpots,
  });

  factory StudentOverview.fromJson(Map<String, dynamic> j) => StudentOverview(
        name: (j['name'] as String?) ?? 'Student',
        email: (j['email'] as String?) ?? '',
        grade: (j['grade'] as num?)?.toInt() ?? 0,
        questionsSeen: (j['questions_seen'] as num?)?.toInt() ?? 0,
        firstTry: (j['first_try'] as num?)?.toInt() ?? 0,
        firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
        wrongTaps: (j['wrong_taps'] as num?)?.toInt() ?? 0,
        daysActive: (j['days_active'] as num?)?.toInt() ?? 0,
        lastActive: j['last_active'] == null
            ? null
            : DateTime.parse(j['last_active'] as String),
        units: ((j['units'] as List?) ?? [])
            .map((u) => UnitLine.fromJson(Map<String, dynamic>.from(u)))
            .toList(),
        weakSpots: ((j['weak_spots'] as List?) ?? [])
            .map((w) => WeakSpot.fromJson(Map<String, dynamic>.from(w)))
            .toList(),
      );
}

/// What the server says about one tap.
///
/// This is the only route by which the app learns whether an answer was
/// right. Nothing in the browser knows the correct index, so nothing in the
/// browser can be read ahead or edited to fake a score.
class Verdict {
  final bool correct;

  /// True when this was the first option tapped for the question. Worked out
  /// on the server from the attempt history, not claimed by the app.
  final bool wasFirst;

  final String feedback;

  const Verdict({
    required this.correct,
    required this.wasFirst,
    required this.feedback,
  });

  factory Verdict.fromJson(Map<String, dynamic> json) => Verdict(
        correct: json['was_correct'] as bool,
        wasFirst: json['was_first'] as bool,
        feedback: (json['feedback'] as String?) ?? '',
      );
}

/// One unit as the chips need it: its name, how many questions it holds, and
/// how many of those are Hard. The Hard count exists because Gold requires
/// locked behind Astro+, so the unit card can say what a subscription buys.
class UnitSummary {
  final String name;
  final int total;
  final int lockedTotal;

  const UnitSummary({
    required this.name,
    required this.total,
    required this.lockedTotal,
  });

  /// list_units returns unit, unit_order, total and locked_total. unit_order
  /// is not kept as a field because the server already returns the rows in
  /// that order — storing it would invite somebody to re-sort in the app and
  /// let the two orderings drift apart.
  factory UnitSummary.fromJson(Map<String, dynamic> row) => UnitSummary(
        name: row['unit'] as String,
        total: (row['total'] as num).toInt(),
        lockedTotal: (row['locked_total'] as num?)?.toInt() ?? 0,
      );
}

/// Medal tiers, lowest first. The order of this enum is the ranking, which is
/// what lets medals be compared and stops one from ever going down.
enum Medal { none, bronze, silver, gold }

Medal medalFromText(String? text) => switch (text) {
      'Bronze' => Medal.bronze,
      'Silver' => Medal.silver,
      'Gold' => Medal.gold,
      _ => Medal.none,
    };

String medalToText(Medal medal) => switch (medal) {
      Medal.bronze => 'Bronze',
      Medal.silver => 'Silver',
      Medal.gold => 'Gold',
      Medal.none => 'None',
    };

/// One level of one unit, as list_levels returns it: what exists, whether
/// this student may open it, how far they are, and the medal they hold.
class LevelInfo {
  final String level;
  final int total;
  final bool locked;
  final int solved;
  final int firstTry;
  final Medal medal;
  final int bestFirstTry;

  const LevelInfo({
    required this.level,
    required this.total,
    required this.locked,
    required this.solved,
    required this.firstTry,
    required this.medal,
    required this.bestFirstTry,
  });

  bool get finished => total > 0 && solved >= total;

  factory LevelInfo.fromJson(Map<String, dynamic> j) => LevelInfo(
        level: j['level'] as String,
        total: (j['total'] as num).toInt(),
        locked: j['locked'] == true,
        solved: (j['solved'] as num?)?.toInt() ?? 0,
        firstTry: (j['first_try'] as num?)?.toInt() ?? 0,
        medal: medalFromText(j['medal'] as String?),
        bestFirstTry: (j['best_first_try'] as num?)?.toInt() ?? 0,
      );
}

/// Where a student stands in one unit: what they have finished since their
/// last reset, and what medal they hold regardless of resets.
class UnitProgress {
  /// sort_order of every question already answered correctly this pass.
  final Set<int> solved;

  /// Of those, how many were right on the very first tap.
  final int firstTry;

  final Medal medal;
  final int bestFirstTry;

  const UnitProgress({
    this.solved = const {},
    this.firstTry = 0,
    this.medal = Medal.none,
    this.bestFirstTry = 0,
  });

  bool get started => solved.isNotEmpty;

  UnitProgress copyWith({Set<int>? solved, int? firstTry, Medal? medal}) =>
      UnitProgress(
        solved: solved ?? this.solved,
        firstTry: firstTry ?? this.firstTry,
        medal: medal ?? this.medal,
        bestFirstTry: bestFirstTry,
      );
}

class Profile {
  final String id;
  final String? email;
  final String? fullName;
  final int grade;

  /// The course code this student is taking — the thing everything is keyed
  /// on. Grade is kept alongside it because classes and rosters really are
  /// about school year, but the questions follow the course.
  final String course;

  /// Where the photo lives in the private avatars bucket, or null. A PATH,
  /// never a URL — see avatars.sql. The URL is signed on demand and expires.
  final String? avatarPath;

  /// 'light', 'dark', 'system', or null for an account that has never opened
  /// Preferences. Null and 'system' mean the same thing.
  final String? themePref;

  const Profile({
    required this.id,
    this.email,
    this.fullName,
    required this.grade,
    required this.course,
    this.avatarPath,
    this.themePref,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        email: json['email'] as String?,
        fullName: json['full_name'] as String?,
        grade: json['grade'] as int,
        avatarPath: json['avatar_path'] as String?,
        themePref: json['theme_pref'] as String?,
        // Profiles written before courses existed carry the grade only.
        course: (json['course'] as String?) ??
            kDefaultCourseForGrade[json['grade'] as int] ??
            'MPM2D',
      );

  String get courseLabel => course;

  /// What to call this student on screen. Accounts made before names existed
  /// fall back to the part of the address before the at sign.
  String get displayName {
    final name = fullName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    return (email ?? 'student').split('@').first;
  }
}

// ==========================================================================
// 3. DATA LAYER
// ==========================================================================
//
// Three small classes wrapping Supabase. Everything above this line is plain
// Dart; everything the UI needs from the network goes through here.

SupabaseClient get _db => Supabase.instance.client;

/// What happened when someone tried to register.
/// What signup says, whether or not the address already had an account.
///
/// One string, used for both outcomes, because the moment they differ the
/// form becomes a way to test whether somebody has an Astro account. It has
/// to be true of both cases at once, which is why it says "if" rather than
/// promising an email.
const String _sameEitherWayNotice =
    'Check your email. If this address is new, there is a confirmation link '
    'waiting; if it already has an account, you can sign in with it — use '
    'Forgot password if you need to.';

enum RegisterOutcome {
  /// Signed in straight away (email confirmation is off).
  signedIn,

  /// Account made, but they must click a link in their email first.
  confirmEmail,

  /// The email already has an account — they should sign in instead.
  alreadyExists,
}

// ---------------------------------------------------------------------------
// Age
// ---------------------------------------------------------------------------
//
// These two mirror minimum_age() and guardian_required_below() in
// supabase/migrations/student_safeguarding.sql. The SERVER is the rule; these
// exist so a student is told before an account is created rather than after.
// If one moves, move the other — there is no way to derive one from the
// other and a mismatch shows up as a form that accepts what the server then
// refuses.

/// Below this, no account. Not a legal constant: it is the line below which
/// guidance agrees a child cannot consent for themselves, and the courses
/// here start at Grade 9 anyway.
const int kMinimumAge = 13;

/// Below this, a parent or guardian has to say yes first.
const int kGuardianRequiredBelow = 18;

/// Whole years, the way a birthday works rather than the way a subtraction
/// of days does.
int _wholeYearsSince(DateTime dob) {
  final now = DateTime.now();
  var years = now.year - dob.year;
  final hadBirthday = now.month > dob.month ||
      (now.month == dob.month && now.day >= dob.day);
  if (!hadBirthday) years -= 1;
  return years;
}

/// The date-of-birth picker on the signup form.
class _DateOfBirthField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  const _DateOfBirthField({required this.value, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      // Opens on a plausible birthday for this app's students rather than
      // on today, which would be fourteen taps away from any real answer.
      initialDate: value ?? DateTime(now.year - 15, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Your date of birth',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final years = value == null ? null : _wholeYearsSince(value!);
    final tooYoung = years != null && years < kMinimumAge;
    final needsGuardian =
        years != null && years >= kMinimumAge && years < kGuardianRequiredBelow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of birth',
            border: const OutlineInputBorder(),
            errorText: tooYoung
                ? 'You need to be at least $kMinimumAge'
                : null,
            helperText: needsGuardian
                ? 'We will ask a parent or guardian to confirm your account'
                : 'So we know whether to ask a parent or guardian',
          ),
          child: InkWell(
            onTap: () => _pick(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value == null
                          ? 'Tap to choose'
                          : '${value!.day} ${_shortMonth(value!.month)} '
                              '${value!.year}',
                      style: TextStyle(
                        fontSize: 15,
                        color: value == null ? kInkSoft : kInk,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_rounded, size: 17, color: kInkSoft),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The screen a student under 18 sees until a guardian confirms.
///
/// It does NOT lock them out. Reading is allowed and always was — the rule
/// is that nothing about them is RECORDED, and that rule lives on the
/// attempts and lesson_reads tables rather than here. This screen exists so
/// a student understands why their work is not being saved, instead of
/// meeting a database error mid-question.
class GuardianConsentScreen extends StatefulWidget {
  final ConsentStatus status;
  final VoidCallback onRecheck;

  /// Carry on without consent. The app still works; nothing is saved.
  final VoidCallback onContinueAnyway;

  const GuardianConsentScreen({
    super.key,
    required this.status,
    required this.onRecheck,
    required this.onContinueAnyway,
  });

  @override
  State<GuardianConsentScreen> createState() => _GuardianConsentScreenState();
}

class _GuardianConsentScreenState extends State<GuardianConsentScreen> {
  final _safeguarding = SafeguardingRepository();
  final _emailController = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _link;
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.status.guardianEmail ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    if (email.length < 3 || !email.contains('@')) {
      setState(() => _error = 'Enter your parent or guardian\'s email.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final token = await _safeguarding.requestGuardianConsent(email);
      // Ask the server to email it. Falls back to showing the link when
      // email is not set up, which is a normal answer rather than an
      // error — see trySendLink.
      final sentTo = await trySendLink('consent');
      if (!mounted) return;
      setState(() {
        _sentTo = sentTo;
        // Shown either way. "We emailed your mum" is not reassuring on its
        // own, and a link the student can also send costs nothing.
        _link = Uri.base.resolve('?consent=$token').toString();
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not do that: $e';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Center(child: BrandBadge(size: 56)),
                  const SizedBox(height: 20),
                  Text(
                    'One thing first',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kSerif,
                      fontFamilyFallback: kSerifFallback,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You are under $kGuardianRequiredBelow, so we need a '
                    'parent or guardian to say it is alright for us to keep '
                    'a record of your work. Until they do you can read '
                    'everything and try any question — none of it is saved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.5, height: 1.55, color: kInkSoft),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Parent or guardian email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    _Banner(message: _error!, colour: kWrong),
                  ],
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _link == null ? 'Make their link' : 'Make a new link',
                    busy: _busy,
                    onPressed: _busy ? null : _send,
                  ),
                  if (_link != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                      decoration: BoxDecoration(
                        color: kTrack,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sentTo != null
                                ? 'Sent to $_sentTo. If it has not arrived, '
                                    'check spam — or send them this link '
                                    'yourself. Making a new link stops this '
                                    'one working.'
                                : 'Send this to them. Opening it is all they '
                                    'have to do. Making a new link stops this '
                                    'one working.',
                            style: TextStyle(
                                fontSize: 12.5, height: 1.5, color: kInkSoft),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _link!,
                            style: TextStyle(
                                fontSize: 12, height: 1.4, color: kInk),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: _link!)),
                            icon: const Icon(Icons.copy_rounded, size: 17),
                            label: const Text('Copy the link'),
                            style: TextButton.styleFrom(
                                foregroundColor: kAccentDeep),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  TextButton(
                    onPressed: widget.onRecheck,
                    child: const Text('They have done it — check again'),
                  ),
                  TextButton(
                    onPressed: widget.onContinueAnyway,
                    style: TextButton.styleFrom(foregroundColor: kInkSoft),
                    child: const Text(
                        'Look around without saving anything for now'),
                  ),
                  const SizedBox(height: 12),
                  const LegalLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What a parent or guardian sees when they follow the link.
///
/// Reachable WITHOUT an account, because a parent should not have to make
/// one to say yes. The token in the URL is the authentication, exactly as
/// it is for a shared report.
class GuardianConsentLandingScreen extends StatefulWidget {
  final String token;

  const GuardianConsentLandingScreen({super.key, required this.token});

  @override
  State<GuardianConsentLandingScreen> createState() =>
      _GuardianConsentLandingScreenState();
}

class _GuardianConsentLandingScreenState
    extends State<GuardianConsentLandingScreen> {
  final SupabaseClient _db = Supabase.instance.client;
  bool _loading = true;
  String? _error;
  String? _name;
  bool _already = false;

  @override
  void initState() {
    super.initState();
    _confirm();
  }

  Future<void> _confirm() async {
    try {
      final rows = await _db.rpc('guardian_consent_by_token',
          params: {'p_token': widget.token}) as List;
      if (!mounted) return;
      final row = Map<String, dynamic>.from(rows.first);
      setState(() {
        _name = row['student_name'] as String?;
        _already = row['already'] == true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // Deliberately vague. An unknown token must not be distinguishable
        // from an expired or replaced one, or the page becomes a way to
        // test tokens.
        _error = 'This link is not valid any more. Ask for a new one.';
        _loading = false;
      });
    }
  }

  Future<void> _withdraw() async {
    try {
      await _db.rpc('withdraw_guardian_consent',
          params: {'p_token': widget.token});
      if (!mounted) return;
      setState(() {
        _name = null;
        _error = 'Consent withdrawn. Nothing new will be recorded. '
            'Work already saved is not deleted — ask us if you want it gone.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not do that. Try the link again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 90),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        const Center(child: BrandBadge(size: 56)),
                        const SizedBox(height: 20),
                        Text(
                          _error != null
                              ? 'Sorry'
                              : (_already ? 'Already done' : 'Thank you'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kSerif,
                            fontFamilyFallback: kSerifFallback,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error ??
                              (_already
                                  ? '${_name ?? 'This student'} is already '
                                      'confirmed. There is nothing else to do.'
                                  : '${_name ?? 'This student'} can now use '
                                      'Astro STEM Labs, and we will keep a '
                                      'record of the questions they answer so '
                                      'their tutor can see how they are '
                                      'getting on.'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.5, height: 1.6, color: kInkSoft),
                        ),
                        const SizedBox(height: 26),
                        if (_error == null) ...[
                          Text(
                            'You can change your mind at any time by opening '
                            'this same link again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.5, height: 1.5, color: kInkSoft),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _withdraw,
                            style:
                                TextButton.styleFrom(foregroundColor: kWrong),
                            child: const Text('Withdraw consent'),
                          ),
                        ],
                        const SizedBox(height: 18),
                        const LegalLinks(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An invisible route whose only job is to give Back something to pop.
///
/// THE PROBLEM
///
/// This app moves between screens with setState, not with routes. That is
/// fine inside the app and invisible to Flutter, but the browser's Back
/// button does not know about setState — it only knows about the
/// Navigator's stack. With one route on that stack, Back leaves the site
/// entirely, so a student who opens a topic and presses Back lands on
/// whatever they were looking at before Astro, which is usually Google.
/// Sign-in through to answering a question was one page as far as the
/// browser was concerned.
///
/// WHAT THIS IS
///
/// A route that renders nothing and blocks nothing. `opaque: false` keeps
/// the screen underneath visible; `IgnorePointer` over an empty box means
/// it cannot swallow a tap. It exists purely so the stack has depth, and
/// popping it is what tells the app to step back.
///
/// WHAT COUNTS AS A PAGE, AND WHY
///
/// Back unwinds PLACE, not MODE. A level, a unit, the profile pane and the
/// constellation each push one of these, because each is somewhere you
/// went. The Learn / Quiz / Improve / Test tabs do not, because they are
/// how you are working on the place you are already in — and because four
/// tabs generating four history entries makes Back useless for getting
/// anywhere.
/// OverlayRoute, NOT PageRoute, and that distinction is the whole thing.
///
/// The first version of this was a PageRouteBuilder with `opaque: false`
/// and an IgnorePointer, which looked right and was not: every PageRoute is
/// a ModalRoute, and a ModalRoute inserts a ModalBarrier whether or not it
/// has a barrier colour. The barrier is invisible and still eats every tap
/// underneath it. The app would have looked completely dead — a far worse
/// bug than the one this fixes — and the test below is what caught it.
///
/// OverlayRoute has no barrier. It contributes an overlay entry and
/// nothing else, which is exactly the amount of route needed to give Back
/// something to pop.
class HistoryMarkerRoute<T> extends OverlayRoute<T> {
  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(
      builder: (_) => const IgnorePointer(child: SizedBox.shrink()),
      // The screen below is the real one: it stays visible and keeps its
      // state.
      opaque: false,
      maintainState: true,
    );
  }
}

/// How long any one network call gets before the app gives up on it.
///
/// There was no timeout anywhere in this file, and that is what "I have to
/// refresh for it to load" actually is: a request that never returns leaves
/// a spinner on screen for ever, because a Future that does not complete
/// does not throw either. The student sees a working-looking app that is
/// waiting on something already dead, and reloading is the only way out —
/// which is exactly what they end up doing.
///
/// Twelve seconds is long enough for a slow school connection to finish a
/// real request and short enough that nobody sits through it twice.
const Duration kNetworkTimeout = Duration(seconds: 12);

/// Gives a Future a deadline, and a message worth reading when it passes.
///
/// The message names WHAT was being fetched, because "something went wrong"
/// tells a student nothing and tells a tutor less.
Future<T> withTimeout<T>(Future<T> future, String what) => future.timeout(
      kNetworkTimeout,
      onTimeout: () => throw TimeoutException(
          '$what took too long. Check your connection and try again.'),
    );

/// Where a student's account stands on age and guardian consent.
class ConsentStatus {
  final bool needsGuardian;
  final String? guardianEmail;
  final DateTime? consentedAt;
  final DateTime? dateOfBirth;
  final int? age;

  const ConsentStatus({
    required this.needsGuardian,
    this.guardianEmail,
    this.consentedAt,
    this.dateOfBirth,
    this.age,
  });

  /// The guardian has been named and the link sent, but not followed yet.
  bool get waitingOnGuardian => needsGuardian && guardianEmail != null;

  factory ConsentStatus.fromJson(Map<String, dynamic> j) => ConsentStatus(
        needsGuardian: j['needs_guardian'] == true,
        guardianEmail: j['guardian_email'] as String?,
        consentedAt: j['consented_at'] == null
            ? null
            : DateTime.tryParse(j['consented_at'] as String),
        dateOfBirth: j['date_of_birth'] == null
            ? null
            : DateTime.tryParse(j['date_of_birth'] as String),
        age: (j['age'] as num?)?.toInt(),
      );

  /// A database that predates student_safeguarding.sql. Nothing is blocked,
  /// which matches what the server does — see consent_required.
  static const unknown = ConsentStatus(needsGuardian: false);
}

/// One Astro+ enrolment request, as the student who made it sees it.
class EnrolmentStatus {
  final int requestId;
  /// 'new' | 'sent' | 'paid' | 'cancelled'
  final String status;
  final String plan;
  final String method;
  final String parentName;
  final String parentEmail;
  final DateTime? emailedAt;
  final DateTime? createdAt;

  const EnrolmentStatus({
    required this.requestId,
    required this.status,
    required this.plan,
    required this.method,
    required this.parentName,
    required this.parentEmail,
    this.emailedAt,
    this.createdAt,
  });

  bool get open => status == 'new' || status == 'sent';
  bool get paid => status == 'paid';

  String get planLabel => plan == 'annual' ? 'Astro+ yearly' : 'Astro+ monthly';
  String get methodLabel =>
      method == 'etransfer' ? 'Interac e-transfer' : 'Card';

  factory EnrolmentStatus.fromJson(Map<String, dynamic> j) => EnrolmentStatus(
        requestId: (j['request_id'] as num).toInt(),
        status: j['status'] as String? ?? 'new',
        plan: j['plan'] as String? ?? 'monthly',
        method: j['method'] as String? ?? 'stripe',
        parentName: j['parent_name'] as String? ?? '',
        parentEmail: j['parent_email'] as String? ?? '',
        emailedAt: j['emailed_at'] == null
            ? null
            : DateTime.tryParse(j['emailed_at'] as String),
        createdAt: j['created_at'] == null
            ? null
            : DateTime.tryParse(j['created_at'] as String),
      );
}

/// One request as the ADMIN sees it — the same row plus who it belongs to
/// and how to reach them.
class EnrolmentRequest {
  final int requestId;
  final String studentName;
  final String accountEmail;
  final int grade;
  final String schoolBoard;
  final String? school;
  final String parentName;
  final String parentEmail;
  final String? parentPhone;
  final String plan;
  final String method;
  final String status;
  final DateTime? createdAt;

  const EnrolmentRequest({
    required this.requestId,
    required this.studentName,
    required this.accountEmail,
    required this.grade,
    required this.schoolBoard,
    required this.school,
    required this.parentName,
    required this.parentEmail,
    required this.parentPhone,
    required this.plan,
    required this.method,
    required this.status,
    this.createdAt,
  });

  factory EnrolmentRequest.fromJson(Map<String, dynamic> j) => EnrolmentRequest(
        requestId: (j['request_id'] as num).toInt(),
        studentName: j['student_name'] as String? ?? '',
        accountEmail: j['account_email'] as String? ?? '',
        grade: (j['grade'] as num?)?.toInt() ?? 0,
        schoolBoard: j['school_board'] as String? ?? '',
        school: j['school'] as String?,
        parentName: j['parent_name'] as String? ?? '',
        parentEmail: j['parent_email'] as String? ?? '',
        parentPhone: j['parent_phone'] as String?,
        plan: j['plan'] as String? ?? 'monthly',
        method: j['method'] as String? ?? 'stripe',
        status: j['status'] as String? ?? 'new',
        createdAt: j['created_at'] == null
            ? null
            : DateTime.tryParse(j['created_at'] as String),
      );
}

/// What a parent sees when they open the payment link. Deliberately thin:
/// a first name, what is being bought, and how far along it is. A parent
/// confirming a payment has no business reading the child's marks.
class EnrolmentInvite {
  final String studentFirst;
  final String plan;
  final String method;
  final String status;

  const EnrolmentInvite({
    required this.studentFirst,
    required this.plan,
    required this.method,
    required this.status,
  });

  factory EnrolmentInvite.fromJson(Map<String, dynamic> j) => EnrolmentInvite(
        studentFirst: j['student_first'] as String? ?? 'Your child',
        plan: j['plan'] as String? ?? 'monthly',
        method: j['method'] as String? ?? 'stripe',
        status: j['status'] as String? ?? 'new',
      );
}

/// Tries to email a link, and says plainly whether it went.
///
/// The client sends only a KIND. It cannot name the recipient and cannot
/// supply the token — the function derives both from the caller's JWT. That
/// is what stops this being a way to send Astro-branded mail to anybody.
///
/// Returns the address it went to, or null when email is not set up. Null
/// is a normal answer, not a failure: until RESEND_API_KEY exists the app
/// shows the link for the student to pass on, and that path is the one
/// that has actually been used.
Future<String?> trySendLink(String kind) async {
  try {
    final res = await Supabase.instance.client.functions
        .invoke('send-link', body: {'kind': kind});
    final data = res.data;
    if (data is Map && data['sent'] == true) return data['to'] as String?;
    return null;
  } catch (_) {
    // Not deployed, not configured, rate limited, or offline. Every one of
    // those means the same thing to the student: we could not send it, here
    // is the link.
    return null;
  }
}

/// The Astro+ enrolment path: a student asks, an admin works the queue, a
/// parent pays.
///
/// Every function here already existed in astro_sections.sql and had no
/// caller. What was actually missing was a way to reach the pay_token —
/// see enrolment_links.sql.
class EnrolmentRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<EnrolmentStatus?> mine() async {
    final rows = await _db.rpc('my_enrolment_status') as List;
    if (rows.isEmpty) return null;
    return EnrolmentStatus.fromJson(Map<String, dynamic>.from(rows.first));
  }

  /// The link to hand to a parent, or null when there is no open request.
  Future<String?> myLink() async {
    final token = await _db.rpc('my_enrolment_link');
    return token as String?;
  }

  /// Submits the form. A second submission replaces the first rather than
  /// queueing behind it, so a parent never receives two payment links —
  /// that rule is a unique index in the schema, not something this checks.
  Future<int> request({
    required String studentName,
    required int grade,
    required String schoolBoard,
    required String parentName,
    required String parentEmail,
    required String plan,
    required String method,
    String? school,
    String? parentPhone,
  }) async {
    final rows = await _db.rpc('request_enrolment', params: {
      'p_student_name': studentName,
      'p_grade': grade,
      'p_school_board': schoolBoard,
      'p_parent_name': parentName,
      'p_parent_email': parentEmail,
      'p_plan': plan,
      'p_method': method,
      'p_school': school,
      'p_parent_phone': parentPhone,
    }) as List;
    return (Map<String, dynamic>.from(rows.first)['request_id'] as num).toInt();
  }

  Future<void> cancel() => _db.rpc('cancel_enrolment');

  /// Callable without an account — the token is the authentication.
  Future<EnrolmentInvite?> byToken(String token) async {
    final rows =
        await _db.rpc('enrolment_by_token', params: {'p_token': token}) as List;
    if (rows.isEmpty) return null;
    return EnrolmentInvite.fromJson(Map<String, dynamic>.from(rows.first));
  }

  // ---- admin ----

  Future<List<EnrolmentRequest>> adminList({String? status}) async {
    final rows = await _db
        .rpc('admin_list_enrolments', params: {'p_status': status}) as List;
    return rows
        .map((e) => EnrolmentRequest.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<String> adminLink(int requestId) async {
    final token = await _db.rpc('admin_enrolment_link', params: {
      'p_id': requestId,
    });
    return token as String;
  }

  Future<void> adminMark(int requestId, String status, {String? note}) =>
      _db.rpc('admin_mark_enrolment', params: {
        'p_id': requestId,
        'p_status': status,
        'p_note': note,
      });
}

/// Age, guardian consent, export and deletion.
///
/// Everything here is enforced server-side as well; this class is the way
/// in, not the rule. The rules are triggers and grants in
/// supabase/migrations/student_safeguarding.sql, so a student who edits the
/// JavaScript gets exactly as far as one who does not.
class SafeguardingRepository {
  final SupabaseClient _db = Supabase.instance.client;

  /// Null when the migration has not been applied, so callers can tell
  /// "nothing to do" apart from "cannot ask".
  Future<ConsentStatus> status() async {
    try {
      final rows = await _db.rpc('my_consent_status') as List;
      if (rows.isEmpty) return ConsentStatus.unknown;
      return ConsentStatus.fromJson(Map<String, dynamic>.from(rows.first));
    } catch (_) {
      return ConsentStatus.unknown;
    }
  }

  /// Set once, at signup. The server refuses a second call, refuses anybody
  /// under the floor, and refuses a date in the future.
  Future<void> setDateOfBirth(DateTime dob) async {
    await _db.rpc('set_my_date_of_birth', params: {
      // Date only. Sending a timestamp would put a timezone into a birthday
      // and make somebody a day younger in the wrong hemisphere.
      'p_dob': dob.toIso8601String().split('T').first,
    });
  }

  /// Names the guardian and returns the token for their link.
  Future<String> requestGuardianConsent(String email) async {
    final token = await _db.rpc('request_guardian_consent', params: {
      'p_email': email,
    });
    return token as String;
  }

  /// Everything held about this student, as one document.
  Future<Map<String, dynamic>> export() async {
    final data = await _db.rpc('export_my_data');
    return Map<String, dynamic>.from(data as Map);
  }

  /// Irreversible. The caller is responsible for having asked properly.
  Future<void> deleteAccount() async {
    await _db.rpc('delete_my_account');
  }
}

class AuthRepository {
  Session? get currentSession => _db.auth.currentSession;

  /// The signed-in account, or null. Used by the teacher dashboard to show
  /// whose classes are on screen.
  User? get currentUser => _db.auth.currentUser;

  /// Fires whenever the student signs in or out, so the app can react.
  Stream<AuthState> get onAuthStateChange => _db.auth.onAuthStateChange;

  /// Registers a new student.
  ///
  /// The grade is stashed in the account's metadata rather than written to
  /// the profiles table straight away. If email confirmation is switched on
  /// there is no session yet, so an insert would be refused by RLS — this way
  /// the grade survives until their first successful sign-in.
  ///
  /// Returns a result saying whether they are signed in, need to confirm
  /// their email, or already have an account.
  ///
  /// The last case needs care. When someone signs up with an email that is
  /// already registered, Supabase does NOT raise an error — for privacy, it
  /// returns a response that looks just like "confirmation needed," so an app
  /// that does not check will tell them to go look for an email that never
  /// arrives. The tell is the identities list: a genuinely new signup comes
  /// back with one identity, while an already-registered email comes back
  /// with an empty identities list. That is what distinguishes the two.
  Future<RegisterOutcome> register({
    required String email,
    required String password,
    required String fullName,
    required int grade,
    required String course,
    required DateTime? dateOfBirth,
  }) async {
    // Five per fifteen minutes. Signup also sends mail, and it is the other
    // endpoint somebody would use to probe for accounts — which the shared
    // notice already makes pointless, but a limit costs nothing.
    if (!await _underLimit(_bucketFor('signup', email), limit: 5)) {
      throw const AuthException(
        'Too many attempts. Wait a few minutes and try again.',
        statusCode: rateLimited,
      );
    }
    final response = await _db.auth.signUp(
      email: email,
      password: password,
      // The name rides along with the course for the same reason: if email
      // confirmation is on there is no session yet, so writing to profiles
      // would be refused by RLS. All three are copied over on first sign-in.
      data: {
        'grade': grade,
        'course': course,
        'full_name': fullName,
        // Date only — a timestamp would put a timezone into a birthday.
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      },
    );

    // Empty identities on a signup response means the email was already taken.
    final identities = response.user?.identities;
    if (identities != null && identities.isEmpty) {
      return RegisterOutcome.alreadyExists;
    }

    return response.session != null
        ? RegisterOutcome.signedIn
        : RegisterOutcome.confirmEmail;
  }

  /// Thrown when the server has seen too many of the same action.
  ///
  /// A separate type from AuthException on purpose: the sign-in screen has
  /// to say something different for "wrong password" and "stop trying", and
  /// catching one to mean the other is how a rate limit ends up telling
  /// somebody their password is wrong.
  static const rateLimited = 'RATE_LIMITED';

  /// Asks the server whether this action may proceed, and records the try.
  ///
  /// Fails OPEN. If the rate-limit call itself errors — the migration has
  /// not been run, the network blinked — the action goes ahead. A student
  /// locked out of their own account because a counter was unreachable is
  /// a worse outcome than an attacker getting a few extra guesses, and the
  /// fail-open decision is exactly the sort that has to be deliberate and
  /// written down rather than arrived at.
  Future<bool> _underLimit(String bucket, {int limit = 10}) async {
    try {
      final ok = await _db.rpc('note_rate_limit', params: {
        'p_bucket': bucket,
        'p_limit': limit,
      });
      return ok != false;
    } catch (_) {
      return true;
    }
  }

  /// The bucket for an email-keyed action.
  ///
  /// The address is lowercased and hashed rather than stored: this table is
  /// a counter, and a counter that accumulates a list of every address
  /// anybody has tried to sign in as is a list worth stealing. The hash is
  /// not a security boundary — it is there so the table holds no addresses.
  String _bucketFor(String action, String email) =>
      '$action:${email.trim().toLowerCase().hashCode}';

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Ten tries per fifteen minutes against one address. Enough that a
    // student mistyping a password never notices; far short of what a
    // guessing attack needs.
    if (!await _underLimit(_bucketFor('signin', email))) {
      throw const AuthException(
        'Too many sign-in attempts for this address. '
        'Wait a few minutes and try again.',
        statusCode: rateLimited,
      );
    }
    await _db.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _db.auth.signOut();

  /// Sends a password-reset email. The link in it brings the user back to the
  /// app with a short-lived recovery session, which is what lets them set a
  /// new password without knowing the old one.
  ///
  /// redirectTo points at the app so the link lands somewhere that can act on
  /// it. It deliberately reveals nothing about whether the email exists — the
  /// caller shows the same "check your email" line either way, so this cannot
  /// be used to probe for accounts.
  Future<void> sendPasswordReset(String email) async {
    // Tighter than sign-in, because every one of these sends a real email
    // to somebody who did not ask for it. Three per fifteen minutes.
    if (!await _underLimit(_bucketFor('reset', email), limit: 3)) {
      throw const AuthException(
        'A reset link has already been sent for this address. '
        'Check your inbox, including spam, before asking for another.',
        statusCode: rateLimited,
      );
    }
    await _db.auth.resetPasswordForEmail(
      email,
      redirectTo: '${Uri.base.origin}/',
    );
  }

  /// Sets a new password for the user who is currently in a recovery session
  /// (they arrived via the reset link). Supabase requires an active session
  /// for this, which the recovery link provides.
  Future<void> updatePassword(String newPassword) async {
    await _db.auth.updateUser(UserAttributes(password: newPassword));
  }
}

class ProfileRepository {
  /// Remembering the theme on the server rather than in the browser is what
  /// makes it follow a student from the school laptop to the phone at home.
  /// Failing to save is not worth interrupting anyone over: the choice has
  /// already been applied on screen, it just will not survive a sign-out.
  Future<void> saveThemePref(String pref) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client
        .from('profiles')
        .update({'theme_pref': pref}).eq('id', user.id);
  }

  /// Reads the signed-in student's profile, creating it on first sign-in.
  ///
  /// maybeSingle returns null rather than throwing when there is no row,
  /// which is exactly the case we want to handle here.
  Future<Profile> loadOrCreate() async {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');

    final existing =
        await _db.from('profiles').select().eq('id', user.id).maybeSingle();

    if (existing != null) return Profile.fromJson(existing);

    // First sign-in: build the row from the metadata saved at registration.
    final grade = (user.userMetadata?['grade'] as num?)?.toInt();
    final course = user.userMetadata?['course'] as String?;
    if (grade == null) {
      throw Exception(
        'No grade found on this account. It may have been created before '
        'grades existed — register again, or add a row by hand in the '
        'profiles table.',
      );
    }

    // upsert, not insert: if a row already exists — because another load
    // raced this one, or the profiles table was just rebuilt while a tab was
    // open — the write becomes a harmless no-op instead of colliding with
    // profiles_pkey. onConflict names the primary key so Postgres knows which
    // clash to absorb.
    final created = await _db
        .from('profiles')
        .upsert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'] as String?,
          'grade': grade,
          // Accounts made before courses existed carry only a grade; the
          // default for that grade is the right course for all of them.
          'course': course ?? kDefaultCourseForGrade[grade] ?? 'MPM2D',
        }, onConflict: 'id')
        .select()
        .single();

    // The birth date rides in the signup metadata for the same reason the
    // grade does: at signup there may be no session yet, so nothing can be
    // written to profiles. It is copied over on the first sign-in.
    //
    // Through set_my_date_of_birth rather than into the upsert above,
    // because that function is where the age floor is enforced. Writing the
    // column directly would put the one rule that matters behind a client
    // that could simply choose not to call it.
    final dob = user.userMetadata?['date_of_birth'] as String?;
    if (dob != null && created['date_of_birth'] == null) {
      try {
        await _db.rpc('set_my_date_of_birth', params: {'p_dob': dob});
      } catch (_) {
        // Already set, refused, or the migration is not applied. None of
        // those should stop a student reaching their course — the consent
        // trigger is what actually holds the line, and it holds it in the
        // database rather than here.
      }
    }

    return Profile.fromJson(created);
  }
}

// ==========================================================================
// Profile photos
// ==========================================================================
//
// The bucket is private, so a photo is not a URL you can keep — it is a path
// plus a signed URL minted on demand and good for an hour. That shapes both
// halves of this section: an upload that produces a path, and a cache that
// turns paths into URLs without asking the server the same question thirty
// times while a roster paints.

/// Signed URLs, cached until shortly before they expire.
///
/// A class of thirty means thirty paths on one screen. Signing them one at a
/// time and in series is slow; [prefetch] fires the whole list at once and
/// awaits them together, so by the time the cards build the answers are
/// already here and the avatars paint without a spinner.
///
/// Deliberately a plain static map. It holds at most a few dozen short
/// strings, it is thrown away when the tab closes, and the alternative —
/// threading a cache object through every widget that draws a person — would
/// cost more than it saves.
class AvatarUrls {
  static final Map<String, _SignedUrl> _cache = {};

  /// An hour is what Supabase is asked for; fifty minutes is when this stops
  /// trusting it. The gap covers a slow render and a clock that disagrees.
  static const Duration _life = Duration(minutes: 50);

  static String? cached(String? path) {
    if (path == null) return null;
    final hit = _cache[path];
    if (hit == null || hit.mintedAt.isBefore(DateTime.now().subtract(_life))) {
      return null;
    }
    return hit.url;
  }

  /// Warm the cache for a whole list before it is drawn.
  static Future<void> prefetch(Iterable<String?> paths) async {
    final wanted = paths
        .whereType<String>()
        .where((p) => cached(p) == null)
        .toSet()
        .toList();
    if (wanted.isEmpty) return;
    // Concurrent single calls rather than storage's batch endpoint. The batch
    // call exists, but the shape of what it returns has moved between
    // supabase_flutter releases, and firing one per photo all at once costs
    // the same one round trip of latency. Not worth pinning the build to a
    // client version over.
    //
    // url() swallows its own failures, so a photo that will not load degrades
    // to initials rather than to an error in the middle of a roster.
    await Future.wait(wanted.map(url));
  }

  static Future<String?> url(String path) async {
    final hit = cached(path);
    if (hit != null) return hit;
    try {
      final signed = await Supabase.instance.client.storage
          .from('avatars')
          .createSignedUrl(path, 3600);
      _cache[path] = _SignedUrl(signed, DateTime.now());
      return signed;
    } catch (_) {
      return null;
    }
  }

  /// After an upload the path is unchanged but the bytes behind it are not,
  /// so the old signed URL would keep serving the old face out of the browser
  /// cache. Dropping the entry forces a fresh URL, and a fresh URL is a new
  /// query string, which is what actually busts the cache.
  static void forget(String? path) {
    if (path != null) _cache.remove(path);
  }
}

class _SignedUrl {
  final String url;
  final DateTime mintedAt;
  const _SignedUrl(this.url, this.mintedAt);
}

class AvatarRepository {
  final SupabaseClient _db = Supabase.instance.client;

  /// The longest side of the stored image. A 34px disc on a 3x screen needs
  /// about 102px; 256 leaves room for the bigger disc on the profile screen
  /// and for whatever Retina invents next, and still lands around 20 kB.
  static const int _size = 256;

  /// Anything larger than this is refused before it is decoded. Decoding is
  /// the expensive step and it happens in the browser's main isolate, so a
  /// 60 MP image would freeze the tab for several seconds before failing.
  static const int _maxBytes = 12 * 1024 * 1024;

  /// Pick, shrink, upload, record. Returns the new path, or null if the
  /// student closed the picker without choosing anything.
  ///
  /// Every step of the shrink is deliberate:
  ///   - decodeImage, not a cheaper resize, because decoding to raw pixels is
  ///     what discards EXIF — including the GPS tag a phone writes by default
  ///   - a square centre crop, because the app only ever draws circles, and
  ///     cropping here means the whole app does not have to agree on how to
  ///     letterbox a portrait photo
  ///   - JPEG at 82, which is indistinguishable from 100 at this size
  Future<String?> pickAndUpload() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // A first pass at the platform level. The real resize is below; this
      // just stops a huge file being read into memory whole.
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    if (picked == null) return null;

    final raw = await picked.readAsBytes();
    if (raw.lengthInBytes > _maxBytes) {
      throw Exception('That image is too large. Try one under 12 MB.');
    }

    final decoded = img.decodeImage(raw);
    if (decoded == null) {
      throw Exception('That file is not an image the app can read.');
    }

    final side = decoded.width < decoded.height ? decoded.width : decoded.height;
    final square = img.copyCrop(
      decoded,
      x: (decoded.width - side) ~/ 2,
      y: (decoded.height - side) ~/ 2,
      width: side,
      height: side,
    );
    final small = img.copyResize(square, width: _size, height: _size);
    final jpeg = img.encodeJpg(small, quality: 82);

    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');

    // A fixed filename per student rather than a new one each time. The
    // storage policy is what stops anyone writing here, and one file per
    // student means changing your photo replaces it instead of leaving every
    // previous face in the bucket forever.
    final path = '${user.id}/avatar.jpg';

    await _db.storage.from('avatars').uploadBinary(
          path,
          jpeg,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    // The pointer is set server-side, where it is re-checked against the
    // caller's own id. The upload above proves the bytes went somewhere
    // allowed; this proves the profile points somewhere allowed.
    await _db.rpc('set_my_avatar', params: {'p_path': path});
    AvatarUrls.forget(path);
    return path;
  }

  Future<void> remove(String? path) async {
    await _db.rpc('clear_my_avatar');
    AvatarUrls.forget(path);
    // The row is what the app reads, so it is cleared first and the bytes
    // second. If this delete fails — offline, say — the photo is already
    // invisible everywhere, and the next upload overwrites the file anyway.
    if (path != null) {
      try {
        await _db.storage.from('avatars').remove([path]);
      } catch (_) {}
    }
  }
}

/// Reading the question bank.
///
/// The app never selects straight from the questions table, because
/// correct_index and all four feedback strings would then arrive in the
/// browser. Anything the browser receives is visible in the network tab, so
/// the answer would be readable before tapping — and a feedback string
/// starting "Correct." gives it away just as plainly as the index does.
///
/// list_questions returns prompts and option text only, filtered to one
/// level, and it refuses a locked level outright. The paywall and the answer
/// key are both enforced on the server side of this line.
class QuestionRepository {
  final SupabaseClient _db = Supabase.instance.client;

  /// Every course that actually has questions loaded. This is what the
  /// signup screen offers — a course with an empty bank is worse than one
  /// that is not listed, because the student signs up and finds nothing.
  Future<List<CourseOption>> listCourses() async {
    final rows = await _db.rpc('list_courses');
    return (rows as List)
        .map((r) => CourseOption.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<UnitSummary>> fetchUnits(String course) async {
    final rows = await _db.rpc('list_units', params: {'p_course': course});
    return (rows as List)
        .map((row) => UnitSummary.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  /// The four levels of one unit, with this student's standing in each.
  Future<List<LevelInfo>> fetchLevels(String course, String unit) async {
    final rows = await _db.rpc(
      'list_levels',
      params: {'p_course': course, 'p_unit': unit},
    );
    return (rows as List)
        .map((r) => LevelInfo.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<Question>> fetchQuestions(
      String course, String unit, String level) async {
    final rows = await _db.rpc(
      'list_questions',
      params: {'p_course': course, 'p_unit': unit, 'p_level': level},
    );

    return (rows as List)
        .map((row) => Question.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}

/// Everything to do with what a student has done: submitting taps, working
/// out where to resume, awarding medals, and clearing a run.
///
/// Every write here goes through a database function. The tables themselves
/// are read-only to students, so nobody can insert a fake attempt or hand
/// themselves a Gold by calling the REST API directly.
class ProgressRepository {
  final SupabaseClient _db = Supabase.instance.client;

  String get _uid {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');
    return user.id;
  }

  /// Sends one tap to be graded, and returns what the server says.
  ///
  /// This both grades and logs, in a single call inside one transaction. That
  /// pairing is deliberate: there is no way to answer a question without the
  /// attempt being recorded, so the history cannot be selectively pruned by a
  /// client that simply declines to send it.
  Future<Verdict> submitAnswer({
    required String course,
    required Question question,
    required int chosenIndex,
  }) async {
    final rows = await _db.rpc('submit_answer', params: {
      'p_course': course,
      'p_unit': question.unit,
      'p_sort_order': question.sortOrder,
      'p_chosen': chosenIndex,
    });

    final list = rows as List;
    if (list.isEmpty) throw Exception('The server did not grade that answer.');
    return Verdict.fromJson(Map<String, dynamic>.from(list.first));
  }

  /// Everything the chips, the resume card and the mastery header need.
  ///
  /// Attempts give the current run; unit_mastery gives the medals, which
  /// survive resets. Keeping those two separate is the whole reason a reset
  /// is safe to offer at all.
  ///
  /// The reset cutoff used to be a second round trip from here — see
  /// progress_resets in my_progress.sql, which now applies it in the same
  /// query rather than making the browser ask first and filter after.
  ///
  /// Every unit's progress, in one round trip and a bounded payload.
  ///
  /// This used to download every attempt row the student had ever made and
  /// reduce it in the browser. At eight students that was invisible; the
  /// query had no limit and grew for the life of an account, and it ran on
  /// every load. my_progress does the reduction in Postgres and returns one
  /// row per unit — six to nine, whatever happens.
  ///
  /// The two rules that used to live in the loop below now live in the SQL,
  /// and are stated in its header: test rows do not count as solved, and
  /// first-try is a set rather than a counter.
  Future<Map<String, UnitProgress>> fetchProgress(String course) async {
    final rows =
        await _db.rpc('my_progress', params: {'p_course': course}) as List;

    final solved = <String, Set<int>>{};
    final firstTry = <String, Set<int>>{};

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final unit = row['unit'] as String;
      solved[unit] = ((row['solved_orders'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toSet();
      firstTry[unit] = ((row['first_try_orders'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toSet();
    }

    final mastery = await _db
        .from('unit_mastery')
        .select('unit, medal, best_first_try')
        .eq('student_id', _uid)
        .eq('course', course);

    final medals = <String, Medal>{};
    final bests = <String, int>{};
    for (final row in mastery) {
      final unit = row['unit'] as String;
      final medal = medalFromText(row['medal'] as String?);
      // One row per LEVEL now. The chip shows the best medal anywhere in the
      // unit — Gold on Easy is a real Gold, and the level screen shows the
      // full breakdown.
      final current = medals[unit] ?? Medal.none;
      if (medal.index > current.index) medals[unit] = medal;
      bests[unit] =
          (bests[unit] ?? 0) + ((row['best_first_try'] as int?) ?? 0);
    }

    final units = <String>{...solved.keys, ...medals.keys};
    return {
      for (final unit in units)
        unit: UnitProgress(
          solved: solved[unit] ?? const {},
          firstTry: (firstTry[unit] ?? const <int>{}).length,
          medal: medals[unit] ?? Medal.none,
          bestFirstTry: bests[unit] ?? 0,
        ),
    };
  }

  /// Asks the server to work out the medal for a finished unit.
  ///
  /// The app does not compute this and send it. It recomputes from the logged
  /// attempts, so the medal reflects what actually happened rather than what
  /// the browser claims happened. The upward-only rule lives there too: a bad
  /// rerun cannot cost a medal already earned, which is what makes practising
  /// a unit again free of risk.
  Future<Medal> recordCompletion({
    required String course,
    required String unit,
    required String level,
  }) async {
    final result = await _db.rpc(
      'award_medal',
      params: {'p_course': course, 'p_unit': unit, 'p_level': level},
    );
    return medalFromText(result as String?);
  }

  /// Clears the run for one grade without deleting a thing.
  ///
  /// Everything before this moment stops counting toward position and score.
  /// The attempts themselves stay, so the teacher dashboard keeps its history
  /// and nobody can erase a bad week before a parent sees it. Medals stay too.
  Future<void> resetCourse(String course) async {
    await _db.rpc('reset_progress', params: {'p_course': course});
  }
}

/// Astro+ — whether this student has it, and the two doors to Stripe.
///
/// Note what is NOT here: no price handling, no card fields, no entitlement
/// writes. The browser asks the server for a checkout page and gets a URL;
/// Stripe's webhook writes the subscriptions table; has_premium() in the
/// database decides access. If this class lied about any of it, the server
/// would still refuse the locked questions.
class SubscriptionRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<bool> hasPremium() async {
    final result = await _db.rpc('has_premium');
    return result == true;
  }

  /// A Stripe checkout page for the Astro+ subscription. The caller opens
  /// the returned URL in a new tab — the payment happens entirely on
  /// Stripe's page, so no card detail ever touches this app.
  ///
  /// The plan is a NAME ('monthly' or 'annual'), never a price. The server
  /// maps the name to a Stripe price id from its own allowlist, so a
  /// tampered request cannot invent an amount.
  Future<String> checkoutUrl(String plan) =>
      _stripeCall(body: {'plan': plan});

  /// Stripe's billing portal: change card, see invoices, cancel. Cancelling
  /// has to be as easy as subscribing, and this is that door.
  Future<String> portalUrl() => _stripeCall(body: {'portal': true});

  /// Sent in the BODY, not as a query string on the function name.
  ///
  /// This used to call invoke('create-checkout?plan=annual'). The client
  /// builds the request URL from the function NAME, so the query never
  /// travelled — the function saw no plan at all, fell back to its default,
  /// and quietly opened a MONTHLY checkout when Annual was tapped. No error,
  /// no clue, just the wrong price in front of a parent.
  ///
  /// The same silence hit the billing portal, which is the worse half:
  /// ?portal=1 was dropped too, so "Manage subscription" started a SECOND
  /// subscription instead of opening the page where you cancel the first.
  Future<String> _stripeCall({required Map<String, dynamic> body}) async {
    final response =
        await _db.functions.invoke('create-checkout', body: body);
    final data = response.data;
    if (data is Map && data['error'] != null) {
      throw Exception(data['error'].toString());
    }
    final url = (data is Map ? data['url'] : null) as String?;
    if (url == null) throw Exception('Stripe did not return a page.');
    return url;
  }

  // ---- paying by Interac e-transfer ----
  //
  // There is no webhook for a bank inbox, so this path is a declaration,
  // not a payment: the family sends the transfer themselves, the student
  // taps "I have sent it", and NOTHING unlocks until the admin has seen the
  // money in the actual bank account and confirmed the claim. The server
  // enforces all of that; these two calls just carry the messages.

  Future<String> requestEtransfer(String plan) async {
    final result =
        await _db.rpc('request_etransfer', params: {'p_plan': plan});
    return result as String;
  }

  /// The student's latest claim: 'pending', 'confirmed' or 'rejected'.
  /// Null when they have never claimed one.
  Future<String?> etransferStatus() async {
    final rows = await _db.rpc('my_etransfer_status');
    final list = rows as List;
    if (list.isEmpty) return null;
    return (list.first as Map)['status'] as String?;
  }
}

// ---- the admin panel's data ----

/// One student as the admin sees them: who they are, what plan they are on,
/// and whose class they sit in. This is the whole management view.
class AdminStudent {
  final String id;
  final String name;
  final String email;
  final int grade;
  final String course;
  final String planStatus;
  final bool premium;
  final DateTime? periodEnd;
  final String? classes;
  final DateTime? lastActive;

  /// Path in the private avatars bucket, or null. See avatars.sql.
  final String? avatarPath;

  const AdminStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    required this.course,
    required this.planStatus,
    required this.premium,
    this.periodEnd,
    this.classes,
    this.lastActive,
    this.avatarPath,
  });

  factory AdminStudent.fromJson(Map<String, dynamic> j) => AdminStudent(
        avatarPath: j['avatar_path'] as String?,
        id: j['student_id'] as String,
        name: (j['full_name'] as String?)?.trim().isNotEmpty == true
            ? (j['full_name'] as String).trim()
            : (j['email'] as String),
        email: j['email'] as String,
        grade: (j['grade'] as num).toInt(),
        course: (j['course'] as String?) ?? '',
        planStatus: (j['plan_status'] as String?) ?? 'none',
        premium: j['premium'] == true,
        periodEnd: j['period_end'] == null
            ? null
            : DateTime.parse(j['period_end'] as String).toLocal(),
        classes: j['classes'] as String?,
        lastActive: j['last_active'] == null
            ? null
            : DateTime.parse(j['last_active'] as String).toLocal(),
      );
}

/// One tutor (or the admin) on the staff list.
class AdminTeacher {
  final String userId;
  final String email;
  final String role;
  final int classCount;
  final int studentCount;

  const AdminTeacher({
    required this.userId,
    required this.email,
    required this.role,
    required this.classCount,
    required this.studentCount,
  });

  factory AdminTeacher.fromJson(Map<String, dynamic> j) => AdminTeacher(
        userId: j['user_id'] as String,
        email: j['email'] as String,
        role: j['role'] as String,
        classCount: (j['class_count'] as num?)?.toInt() ?? 0,
        studentCount: (j['student_count'] as num?)?.toInt() ?? 0,
      );
}

/// One student of one tutor, as the admin panel sees them.
///
/// Carries the class alongside the student because a tutor can run several,
/// and "which class were they in" is the first thing you want when a name
/// looks unfamiliar.
class TeacherStudent {
  final int classId;
  final String className;
  final String course;
  final String studentId;
  final String name;
  final String email;
  final int questionsSeen;
  final int? firstTryRate;
  final int medals;
  final DateTime? lastActive;

  /// Path in the private avatars bucket, or null. See avatars.sql.
  final String? avatarPath;

  const TeacherStudent({
    required this.classId,
    required this.className,
    required this.course,
    required this.studentId,
    required this.name,
    required this.email,
    required this.questionsSeen,
    required this.firstTryRate,
    required this.medals,
    required this.lastActive,
    this.avatarPath,
  });

  bool get neverPractised => lastActive == null;

  factory TeacherStudent.fromJson(Map<String, dynamic> j) => TeacherStudent(
        avatarPath: j['avatar_path'] as String?,
        classId: (j['class_id'] as num).toInt(),
        className: (j['class_name'] as String?) ?? 'Class',
        course: (j['course'] as String?) ?? '',
        studentId: j['student_id'] as String,
        name: (j['full_name'] as String?) ?? 'Student',
        email: (j['email'] as String?) ?? '',
        questionsSeen: (j['questions_seen'] as num?)?.toInt() ?? 0,
        firstTryRate: (j['first_try_rate'] as num?)?.round(),
        medals: (j['medals'] as num?)?.toInt() ?? 0,
        lastActive: j['last_active'] == null
            ? null
            : DateTime.parse(j['last_active'] as String).toLocal(),
      );
}

/// One class in the assignment picker: whose it is and how full it is.
class AdminClassRow {
  final int id;
  final String name;
  final int grade;
  final String course;
  final String teacherEmail;
  final int students;

  const AdminClassRow({
    required this.id,
    required this.name,
    required this.grade,
    required this.course,
    required this.teacherEmail,
    required this.students,
  });

  factory AdminClassRow.fromJson(Map<String, dynamic> j) => AdminClassRow(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        grade: (j['grade'] as num).toInt(),
        course: (j['course'] as String?) ?? '',
        teacherEmail: j['teacher_email'] as String,
        students: (j['students'] as num?)?.toInt() ?? 0,
      );
}

/// One e-transfer claim awaiting a decision (or already decided).
class EtransferClaim {
  final int id;
  final String email;
  final String name;
  final String plan;
  final String status;
  final DateTime createdAt;

  const EtransferClaim({
    required this.id,
    required this.email,
    required this.name,
    required this.plan,
    required this.status,
    required this.createdAt,
  });

  factory EtransferClaim.fromJson(Map<String, dynamic> j) => EtransferClaim(
        id: (j['claim_id'] as num).toInt(),
        email: j['email'] as String,
        name: (j['full_name'] as String?) ?? (j['email'] as String),
        plan: j['plan'] as String,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
      );
}

/// Everything the admin can do, and nothing anybody else can.
///
/// Every call lands in a database function that re-checks is_admin() in its
/// own body, so this class holds no secrets and grants no power — a student
/// constructing it and calling everything gets exceptions and empty lists.
///
/// The one deliberate power here is makeTeacher: the teacher role used to be
/// grantable only from the SQL editor. The server hardcodes the granted role
/// to 'teacher' — there is no in-app path to admin, so a compromised admin
/// password cannot mint another admin.
class AdminRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<bool> amIAdmin() async {
    final result = await _db.rpc('is_admin');
    return result == true;
  }

  Future<List<AdminStudent>> students() async {
    final rows = await _db.rpc('admin_list_students');
    final out = (rows as List)
        .map((r) => AdminStudent.fromJson(Map<String, dynamic>.from(r)))
        .toList();
    // One signing call for the whole list, before the cards are built, so
    // the avatars paint in the same frame as the names rather than popping
    // in one at a time.
    await AvatarUrls.prefetch(out.map((s) => s.avatarPath));
    return out;
  }

  Future<List<AdminTeacher>> teachers() async {
    final rows = await _db.rpc('admin_list_teachers');
    return (rows as List)
        .map((r) => AdminTeacher.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<AdminClassRow>> classes() async {
    final rows = await _db.rpc('admin_list_classes');
    return (rows as List)
        .map((r) => AdminClassRow.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<String> makeTeacher(String email) async {
    final result =
        await _db.rpc('admin_make_teacher', params: {'p_email': email});
    return result as String;
  }

  Future<String> revokeTeacher(String userId) async {
    final result =
        await _db.rpc('admin_revoke_teacher', params: {'p_user': userId});
    return result as String;
  }

  Future<String> assignStudent(int classId, String email) async {
    final result = await _db.rpc('admin_assign_student',
        params: {'p_class_id': classId, 'p_email': email});
    return result as String;
  }

  Future<String> setCourse(String email, String course) async {
    final result = await _db.rpc('admin_set_course',
        params: {'p_email': email, 'p_course': course});
    return result as String;
  }

  /// Every student taught by one tutor, across all their live classes.
  ///
  /// class_roster answers the same question but is teacher-only: it asks
  /// whether YOU teach them, and an admin teaches nobody. This is the
  /// admin-side twin.
  Future<List<TeacherStudent>> teacherStudents(String teacherId) async {
    final rows = await _db
        .rpc('admin_teacher_students', params: {'p_teacher': teacherId});
    final out = (rows as List)
        .map((r) => TeacherStudent.fromJson(Map<String, dynamic>.from(r)))
        .toList();
    await AvatarUrls.prefetch(out.map((s) => s.avatarPath));
    return out;
  }

  /// The classes this student is actively in, with ids. Needed because the
  /// classes column on admin_list_students is a display string.
  Future<List<AdminStudentClass>> studentClasses(String studentId) async {
    final rows = await _db
        .rpc('admin_student_classes', params: {'p_student': studentId});
    return (rows as List)
        .map((r) => AdminStudentClass.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Take a student out of one class. Their history stays; only the
  /// enrolment ends, which also ends that tutor's sight of them.
  Future<void> removeFromClass(int classId, String studentId) async {
    await _db.rpc('admin_remove_student',
        params: {'p_class_id': classId, 'p_student': studentId});
  }

  Future<List<EtransferClaim>> etransfers() async {
    final rows = await _db.rpc('admin_list_etransfers');
    return (rows as List)
        .map((r) => EtransferClaim.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<String> confirmEtransfer(int claimId) async {
    final result = await _db
        .rpc('admin_confirm_etransfer', params: {'p_claim_id': claimId});
    return result as String;
  }

  Future<String> rejectEtransfer(int claimId, String note) async {
    final result = await _db.rpc('admin_reject_etransfer',
        params: {'p_claim_id': claimId, 'p_note': note});
    return result as String;
  }
}

/// Classes, from both sides.
///
/// Every method here is a database function rather than a table read. The
/// tables are readable only through row level security that checks for a live
/// enrolment, so the functions are not a convenience — they are the only
/// route that works.
class ClassRepository {
  final SupabaseClient _db = Supabase.instance.client;

  /// Whether to show teacher screens at all.
  Future<bool> amITeacher() async {
    final result = await _db.rpc('is_teacher');
    return result == true;
  }

  /// Redeem a teacher access code.
  ///
  /// This is how somebody becomes a teacher without anyone touching the
  /// database. There is deliberately no button that simply grants it: being a
  /// teacher means being able to read the work of children, so it takes a
  /// code issued by whoever runs the project.
  Future<List<ClassInfo>> myClasses() async {
    final rows = await _db.rpc('my_classes');
    return (rows as List)
        .map((r) => ClassInfo.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<ClassInfo> createClass(String name, String course) async {
    final rows = await _db.rpc(
      'create_class',
      params: {'p_name': name, 'p_course': course},
    );
    final list = rows as List;
    if (list.isEmpty) throw Exception('The class was not created.');
    return ClassInfo.fromJson(Map<String, dynamic>.from(list.first));
  }

  /// Invites rather than enrols. The student has to accept before the teacher
  /// can see anything of theirs, which is the difference between adding
  /// somebody to a list and being given access to their work.
  Future<String> inviteStudent(int classId, String email) async {
    final result = await _db.rpc(
      'invite_student',
      params: {'p_class_id': classId, 'p_email': email},
    );
    return (result as String?) ?? 'Invitation sent.';
  }

  Future<List<RosterEntry>> roster(int classId) async {
    final rows = await _db.rpc('class_roster', params: {'p_class_id': classId});
    final out = (rows as List)
        .map((r) => RosterEntry.fromJson(Map<String, dynamic>.from(r)))
        .toList();
    await AvatarUrls.prefetch(out.map((e) => e.avatarPath));
    return out;
  }

  Future<List<MisconceptionRow>> misconceptions(int classId) async {
    final rows = await _db.rpc(
      'class_misconceptions',
      params: {'p_class_id': classId},
    );
    return (rows as List)
        .map((r) => MisconceptionRow.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<UnitBreakdown>> unitBreakdown(int classId) async {
    final rows = await _db.rpc(
      'class_unit_breakdown',
      params: {'p_class_id': classId},
    );
    return (rows as List)
        .map((r) => UnitBreakdown.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<HardQuestion>> hardQuestions(int classId) async {
    final rows = await _db.rpc(
      'class_hard_questions',
      params: {'p_class_id': classId},
    );
    return (rows as List)
        .map((r) => HardQuestion.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<StudentOverview> studentOverview(String studentId) async {
    final row =
        await _db.rpc('student_overview', params: {'p_student': studentId});
    if (row == null) {
      throw Exception('That student is not in one of your classes.');
    }
    return StudentOverview.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> removeStudent(int classId, String studentId) async {
    await _db.rpc('remove_student',
        params: {'p_class_id': classId, 'p_student': studentId});
  }

  /// Every level of every unit this student has touched, weakest first.
  ///
  /// Server-guarded the same way the rest of the dashboard is: a teacher who
  /// does not teach this student gets an empty list rather than an error.
  Future<List<LevelDetail>> studentDetail(String studentId) async {
    final rows =
        await _db.rpc('student_detail', params: {'p_student': studentId});
    return (rows as List)
        .map((r) => LevelDetail.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Per-unit completion and medals for a whole class.
  Future<List<UnitMedalSummary>> unitSummary(int classId) async {
    final rows =
        await _db.rpc('class_unit_summary', params: {'p_class_id': classId});
    return (rows as List)
        .map((r) => UnitMedalSummary.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Retire a class without deleting it. Enrolments, attempts and notes all
  /// survive — the class simply stops appearing, and stops granting the
  /// teacher sight of those students.
  Future<void> archiveClass(int classId) async {
    await _db.rpc('archive_class', params: {'p_class_id': classId});
  }

  /// Move a student to a different course. The server sets their grade from
  /// the course, so this is also how "they have moved up a year" happens.
  /// Guarded by teaches_student, so a tutor can only move their own.
  Future<void> setStudentCourse(String studentId, String course) async {
    await _db.rpc('set_student_course',
        params: {'p_student': studentId, 'p_course': course});
  }

  // ---- tutor review ----

  /// Every subtopic in this student's grade, with how well and how much.
  /// Server-ordered: weakest and most-avoided first, because this list is a
  /// plan for the next session rather than a table to sort.
  Future<List<SubtopicDiagnostic>> studentSubtopics(String studentId) async {
    final rows =
        await _db.rpc('student_subtopics', params: {'p_student': studentId});
    return (rows as List)
        .map((r) => SubtopicDiagnostic.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<TutorNote>> studentNotes(String studentId) async {
    final rows =
        await _db.rpc('student_notes', params: {'p_student': studentId});
    return (rows as List)
        .map((r) => TutorNote.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<void> writeNote(String studentId, String? tag, String body) async {
    await _db.rpc('write_tutor_note',
        params: {'p_student': studentId, 'p_tag': tag, 'p_body': body});
  }

  Future<void> deleteNote(int id) async {
    await _db.rpc('delete_tutor_note', params: {'p_id': id});
  }

  // ---- the student side ----

  /// Feedback written to this student by their tutor.
  Future<List<TutorNote>> myTutorNotes() async {
    final rows = await _db.rpc('my_tutor_notes');
    return (rows as List)
        .map((r) => TutorNote.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<void> markNotesSeen() => _db.rpc('mark_notes_seen');

  Future<List<StudentClass>> myClassesAsStudent() async {
    final rows = await _db.rpc('my_classes_as_student');
    return (rows as List)
        .map((r) => StudentClass.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<void> respondToInvitation(int classId, bool accept) async {
    await _db.rpc('respond_to_invitation',
        params: {'p_class_id': classId, 'p_accept': accept});
  }

  Future<void> leaveClass(int classId) async {
    await _db.rpc('leave_class', params: {'p_class_id': classId});
  }
}

// ==========================================================================
// 4. APP SHELL
// ==========================================================================

/// Where an uncaught error goes.
///
/// Before this, nowhere. A crash inside a build or a failed Future in a
/// button handler printed to a console nobody has open and the student saw
/// a frozen screen, which is the worst of both: they cannot report it
/// usefully and we never hear about it.
///
/// This is not an error reporting service and does not pretend to be one.
/// It is the seam where one goes — the single place to add a Sentry DSN or
/// a POST to an edge function later, rather than hunting through the app
/// for every place something can throw. Until then it at least makes a
/// crash legible in a browser console a tutor can be walked through
/// opening.
///
/// What it must never do is include what the student was answering. An
/// error report is not a place for question text.
/// The app's version, sent with a crash so a report can be tied to a build.
/// Matches `version:` in pubspec.yaml — if you bump one, bump the other.
const String kAppVersion = '1.0.0+1';

/// True while a crash is being reported, so a failure inside the reporter
/// cannot report itself. Without this, one broken Supabase call becomes an
/// unbounded recursion at exactly the moment the app is least able to
/// survive it.
bool _reportingError = false;

/// Anything in an error message that should not be stored.
///
/// Public, like the other rules with tests over them: what a crash log
/// does NOT keep is the part worth proving, and it cannot be proved from
/// outside the library if it is private.
///
/// An exception carries whatever the code was holding, and this app holds
/// email addresses, share tokens and consent tokens. A crash log is not a
/// place to accumulate those — not because the table is insecure, but
/// because the safest data is the data that was never collected.
///
/// Deliberately blunt. Over-redacting costs a little debuggability;
/// under-redacting puts a student's guardian's address in a log table for
/// ninety days.
String redactForCrashLog(String text) => text
    // Anything shaped like an email.
    .replaceAll(RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+'), '[email]')
    // Uuids: every token in this app is one.
    .replaceAll(
        RegExp(r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
            r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'),
        '[uuid]')
    // JWTs, which is what a leaked session looks like.
    .replaceAll(RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]+'), '[jwt]');

/// What makes two crashes the same crash.
///
/// The message plus the first line of the stack. Not the whole stack —
/// two occurrences of one bug can differ further down, and a fingerprint
/// that changes is a fingerprint that does not dedupe.
String crashFingerprint(String message, StackTrace? stack) {
  final head = stack?.toString().split('\n').first.trim() ?? '';
  final basis = '$message|$head';
  // Not a hash: there is no cheap one in the SDK and the server hashes the
  // message as a fallback anyway. A bounded prefix is enough to group by.
  return basis.length <= 64 ? basis : basis.substring(0, 64);
}

void _reportError(Object error, StackTrace? stack, {String? context}) {
  final where = context == null ? '' : ' [$context]';
  // debugPrint rather than print: it throttles, so an error that fires on
  // every frame cannot lock the tab up on its own log output.
  debugPrint('AstroError$where: $error');
  if (stack != null) debugPrint(stack.toString());

  // And then somewhere you will actually see it. The console is fine for
  // the person with the browser open, which is never the student.
  _sendError(error, stack, context);
}

/// Posts a crash to note_client_error, and cannot make anything worse.
///
/// Every failure path here is a silent return. An error reporter that
/// throws, blocks, or retries is a bug multiplier — the whole value of it
/// is that the app carries on exactly as it would have.
void _sendError(Object error, StackTrace? stack, String? context) {
  if (_reportingError) return;

  // Errors thrown before Supabase.initialize have nowhere to go. Asking
  // for the client would itself throw, which is why this is checked rather
  // than caught.
  if (!_supabaseReady) return;

  _reportingError = true;
  try {
    final message = redactForCrashLog(error.toString());
    // Fire and forget, explicitly. Awaiting would make every crash wait on
    // the network, and a crash during startup would hold the first frame.
    Supabase.instance.client.rpc('note_client_error', params: {
      'p_context': context ?? 'unknown',
      'p_message': message,
      'p_stack': stack == null ? null : redactForCrashLog(stack.toString()),
      'p_fingerprint': crashFingerprint(message, stack),
      'p_version': kAppVersion,
    }).ignore();
  } catch (_) {
    // Offline, throttled, not deployed, signed out mid-flight. All the
    // same: the console line above already happened.
  } finally {
    _reportingError = false;
  }
}

/// Set once Supabase.initialize has returned. Guards the reporter against
/// firing before there is a client to fire through.
bool _supabaseReady = false;

Future<void> main() async {
  // Required because Supabase.initialize is async and runs before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Anything Flutter catches during build, layout or paint.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    _reportError(details.exception, details.stack, context: 'flutter');
    previousOnError?.call(details);
  };

  // Anything that escapes a Future and would otherwise vanish. Returning
  // true says it has been handled, which stops it also reaching the
  // platform's own handler and being reported twice.
  PlatformDispatcher.instance.onError = (error, stack) {
    _reportError(error, stack, context: 'uncaught');
    return true;
  };

  // publishableKey rather than the deprecated anonKey — the key below is
  // already a publishable one, so this is a rename, not a change of secret.
  await Supabase.initialize(
      url: supabaseUrl, publishableKey: supabaseAnonKey);
  // From here a crash has somewhere to go. Before it, the console is all
  // there is — which is why the handlers above are installed first anyway:
  // a crash inside initialize is one worth seeing, even if only locally.
  _supabaseReady = true;

  runApp(const MathTutorApp());
}

/// The one place the app's theme mode lives, and the only thing that writes
/// kPalette.
///
/// A student's choice is stored on their profile, so it follows them from
/// the school laptop to the phone. Until that has loaded — and for the
/// signed-out screens, which have no profile to read — the setting is
/// whatever the operating system says.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void set(ThemeMode m) {
    if (_mode == m) return;
    _mode = m;
    notifyListeners();
  }

  static ThemeMode parse(String? pref) => switch (pref) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String name(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

/// Global because the palette getters are global, and they are global
/// because that is what let five hundred call sites stay untouched. One
/// controller, one app, set before runApp.
final ThemeController kTheme = ThemeController();

/// Sets kPalette from the brightness Flutter actually resolved, before any
/// descendant builds.
///
/// This is what stops the two systems drifting: Material decides light or
/// dark from themeMode and the platform, and our palette is then taken from
/// its answer rather than worked out a second time from the same inputs. A
/// second calculation is a second chance to be wrong.
class _AstroTheme extends StatefulWidget {
  final Widget child;
  const _AstroTheme({required this.child});

  @override
  State<_AstroTheme> createState() => _AstroThemeState();
}

/// Sets the palette, and then makes the screen actually repaint with it.
///
/// THE BUG THIS EXISTS TO FIX
///
/// kPalette is a plain global. Every kInk, kCard and kLine in this file
/// reads it directly, which is what made a themeable palette possible
/// without touching five hundred call sites — but it means none of those
/// widgets DEPENDS on the Theme inherited widget. Flutter rebuilds a widget
/// when something it depends on changes. These depend on nothing.
///
/// So switching to dark rebuilt MaterialApp, reassigned kPalette, and left
/// every widget already on screen exactly as it was painted: white cards on
/// a dark page, and a heading in dark ink on a dark ground. Navigating away
/// and back fixed it, because that built the widgets afresh. It was worst
/// on the Appearance panel, which is the one screen a student is guaranteed
/// to be looking at when they change the theme.
///
/// THE FIX
///
/// When the brightness changes, walk the element tree and mark everything
/// needing a rebuild. markNeedsBuild does NOT recreate State, so scroll
/// positions, open dialogs and the question a student is halfway through
/// all survive — which rules out the easy alternative of keying the subtree
/// and throwing it away.
///
/// It runs once per theme change, not per frame.
class _AstroThemeState extends State<_AstroTheme> {
  Brightness? _last;

  void _rebuildEverything(Element el) {
    el.markNeedsBuild();
    el.visitChildren(_rebuildEverything);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    kPalette =
        brightness == Brightness.dark ? AstroPalette.dark : AstroPalette.light;

    if (_last != null && _last != brightness) {
      // After this frame: marking dirty during build is not allowed, and
      // the widgets have to be laid out with the new palette anyway.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.visitChildElements(_rebuildEverything);
      });
    }
    _last = brightness;

    return widget.child;
  }
}

ThemeData _themeFor(AstroPalette p) {
  // Assigning the global first means every getter below reads the palette
  // being built, not the one currently on screen.
  kPalette = p;
  return ThemeData(
        useMaterial3: true,
        // brightness has to be passed explicitly. Without it fromSeed builds
        // a light scheme whatever the seed, and every Material widget the app
        // does not style by hand — dialogs, menus, snackbars, the date picker
        // — stays light inside a dark app.
        brightness: p.brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: p.accent,
          brightness: p.brightness,
        ),
        scaffoldBackgroundColor: kSurface,
        canvasColor: kSurface,
        dialogTheme: DialogThemeData(backgroundColor: kCard),
        popupMenuTheme: PopupMenuThemeData(color: kCard),
        dividerColor: kLine,

        // Setting the look of fields and buttons once, here, keeps every
        // screen below about layout instead of repeating decoration.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kCard,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kLine),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kAccent, width: 2),
          ),
          labelStyle: TextStyle(color: kInkSoft),
          floatingLabelStyle: TextStyle(
            color: kAccent,
            fontWeight: FontWeight.w600,
          ),
          helperStyle: TextStyle(color: kInkSoft, fontSize: 12),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kAccent,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kInk,
            backgroundColor: kCard,
            side: BorderSide(color: kLine),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      );
}

class MathTutorApp extends StatelessWidget {
  const MathTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: kTheme,
      builder: (context, _) => MaterialApp(
        title: kBrandName,
        debugShowCheckedModeBanner: false,
        theme: _themeFor(AstroPalette.light),
        darkTheme: _themeFor(AstroPalette.dark),
        themeMode: kTheme.mode,
        // Wrapped INSIDE MaterialApp so the context it reads already carries
        // the theme Material resolved. Outside it, Theme.of would find the
        // default and the palette would be wrong on the very first frame.
        builder: (context, child) =>
            _AstroTheme(child: child ?? const SizedBox.shrink()),
        home: const AuthGate(),
      ),
    );
  }
}

// ==========================================================================
// 5. AUTH GATE
// ==========================================================================
//
// One decision: is somebody signed in?
//
// StreamBuilder rebuilds whenever onAuthStateChange fires, so signing in or
// out swaps the screen by itself. Nothing else in the app has to think about
// it.

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository();

    // A share link is read before anything else. Somebody opening one has no
    // account and should never meet a sign-in screen — the token in the URL
    // is the whole of their visit.
    final sharedToken = Uri.base.queryParameters['report'];
    if (sharedToken != null && sharedToken.isNotEmpty) {
      return SharedReportScreen(token: sharedToken);
    }

    // Same rule, same reason: a parent following a consent link has no
    // account and must never meet a sign-in screen. The token is the whole
    // of their visit.
    final consentToken = Uri.base.queryParameters['consent'];
    if (consentToken != null && consentToken.isNotEmpty) {
      return GuardianConsentLandingScreen(token: consentToken);
    }

    // And the Astro+ payment link. Same rule again: a parent arrives with a
    // token and no account, and must not meet a sign-in screen.
    final payToken = Uri.base.queryParameters['pay'];
    if (payToken != null && payToken.isNotEmpty) {
      return EnrolmentPaymentScreen(token: payToken);
    }

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Someone arriving via a password-reset link lands here with a
        // recovery session AND a passwordRecovery event. That session is only
        // meant for setting a new password, so it must not fall through to the
        // app as if they had signed in normally — it routes to the reset
        // screen instead.
        if (snapshot.data?.event == AuthChangeEvent.passwordRecovery) {
          return ResetPasswordScreen(auth: auth);
        }

        // currentSession covers the first frame, before the stream emits.
        final session = snapshot.data?.session ?? auth.currentSession;

        if (session == null) return AuthScreen(auth: auth);
        // Signed in — RoleGate decides whether that means the quiz or the
        // teacher dashboard.
        return RoleGate(auth: auth);
      },
    );
  }
}

// ==========================================================================
// 6. AUTH SCREEN
// ==========================================================================

class AuthScreen extends StatefulWidget {
  final AuthRepository auth;

  const AuthScreen({super.key, required this.auth});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _registering = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  /// Date of birth, collected only at signup.
  ///
  /// A date picker rather than three text fields, and rather than an age
  /// box: an age typed as a number is the one a student will round, and it
  /// is wrong a year later. The server takes the date and does the
  /// arithmetic itself, so nothing here has to be trusted.
  DateTime? _dob;

  /// The course catalogue, straight from the database. Loaded once on the
  /// way in so the picker is ready the moment somebody taps Register.
  List<CourseOption> _courses = [];
  String? _course;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await QuestionRepository().listCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _course ??= courses.isEmpty ? null : courses.first.code;
      });
    } catch (_) {
      // Not fatal — signing in does not need the list, and register shows
      // "Loading courses..." until it arrives.
    }
  }

  @override
  void dispose() {
    // Controllers hold resources, so hand them back when the screen goes.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Sends a reset email for whatever address is in the email field. The
  /// confirmation is deliberately the same whether or not that email has an
  /// account — telling the difference would let anyone check who is
  /// registered. So the notice says "if that email has an account."
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() => _error =
          'Enter your email above first, then tap Forgot password.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });

    try {
      await widget.auth.sendPasswordReset(email);
      if (mounted) {
        setState(() => _notice =
            'If that email has an account, a reset link is on its way. '
            'Check your inbox, then follow the link to set a new password.');
      }
    } catch (e) {
      // Even on error, say the same neutral thing rather than leaking whether
      // the address exists.
      if (mounted) {
        setState(() => _notice =
            'If that email has an account, a reset link is on its way.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    // Checked here so the student is told before an account is made, and
    // checked AGAIN on the server, which is the one that counts — see
    // set_my_date_of_birth. This is the courtesy; that is the rule.
    if (_registering && _dob == null) {
      setState(() => _error = 'Please give your date of birth.');
      return;
    }
    if (_registering && _dob != null) {
      final years = _wholeYearsSince(_dob!);
      if (years < kMinimumAge) {
        setState(() => _error =
            'You need to be at least $kMinimumAge to use Astro STEM Labs.');
        return;
      }
    }
    if (_registering && _nameController.text.trim().length < 2) {
      setState(
          () => _error = 'Enter your name so your teacher knows who you are.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });

    try {
      if (_registering) {
        final chosen = _course;
        if (chosen == null) {
          setState(() {
            _busy = false;
            _error = 'Pick a course first.';
          });
          return;
        }
        final outcome = await widget.auth.register(
          email: email,
          password: password,
          fullName: _nameController.text.trim(),
          grade: _courses.firstWhere((c) => c.code == chosen).grade,
          course: chosen,
          dateOfBirth: _dob,
        );
        if (mounted) {
          switch (outcome) {
            case RegisterOutcome.signedIn:
              // The AuthGate stream swaps the screen — nothing to do here.
              break;
            case RegisterOutcome.confirmEmail:
              setState(() {
                _notice = _sameEitherWayNotice;
                _registering = false;
              });
            case RegisterOutcome.alreadyExists:
              // Say the SAME thing as a genuinely new signup.
              //
              // This used to read "You already have an account with this
              // email", which is friendlier and is a user-enumeration
              // leak: anybody could check whether an address has an Astro
              // account by trying to register it. Supabase deliberately
              // makes the two cases indistinguishable and this app used to
              // undo that on purpose.
              //
              // The friendliness is not lost, only made unconditional. The
              // wording covers both cases honestly — a new account really
              // does need the email confirming, and an existing one really
              // can be signed into — so nobody is told to wait for a
              // message that never comes.
              setState(() {
                _notice = _sameEitherWayNotice;
                _registering = false;
              });
          }
        }
      } else {
        await widget.auth.signIn(email: email, password: password);
      }
      // On success the AuthGate stream swaps the screen — nothing to do here.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  // The parent company's own mark, at hero size. The italic
                  // 'x' in a box that used to sit here was this app's alone,
                  // which was the problem with it.
                  const Center(child: BrandBadge(size: 72)),
                  const SizedBox(height: 20),
                  Text(
                    kBrandName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kSerif,
                      fontFamilyFallback: kSerifFallback,
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _registering
                        ? 'Every wrong answer tells you what went wrong.'
                        : 'Welcome back. Pick up where you left off.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: kInkSoft,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      helperText: 'At least 8 characters',
                    ),
                  ),

                  // Only offered when signing in — during registration there
                  // is no password to have forgotten yet.
                  if (!_registering)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy ? null : _forgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: kInkSoft,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Forgot password?',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),

                  // Name and grade only matter when creating the account.
                  if (_registering) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        border: OutlineInputBorder(),
                        helperText: 'This is what your teacher will see',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Courses, not grades. One grade can hold several — Grade
                    // 12 has three — and only the server knows which of them
                    // have questions loaded, so the list comes from there.
                    if (_courses.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Loading courses…',
                          style: TextStyle(fontSize: 13, color: kInkSoft),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _course,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Course',
                          border: OutlineInputBorder(),
                          helperText: 'Your tutor can move you later',
                        ),
                        items: _courses
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.code,
                                child: Text(
                                  'Grade ${c.grade} · ${c.label}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _course = v),
                      ),
                    const SizedBox(height: 20),
                    _DateOfBirthField(
                      value: _dob,
                      onChanged: (d) => setState(() => _dob = d),
                    ),
                  ],

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    _Banner(message: _error!, colour: kWrong),
                  ],
                  if (_notice != null) ...[
                    const SizedBox(height: 16),
                    _Banner(message: _notice!, colour: kAccent),
                  ],

                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: _registering ? 'Create account' : 'Sign in',
                    busy: _busy,
                    onPressed: _busy ? null : _submit,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _registering = !_registering;
                              _error = null;
                              _notice = null;
                            }),
                    child: Text(
                      _registering
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                  const SizedBox(height: 18),
                  // The policy has to be reachable from the screen where
                  // the account is created, not only from a footer on a
                  // site the student never visits. These users are
                  // children; a privacy policy nobody can find is a
                  // privacy policy nobody has read.
                  const LegalLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Where someone lands after clicking the reset link in their email. They
/// arrive with a recovery session — enough to set a new password, nothing
/// more — so this screen does only that, then drops them back to a normal
/// signed-in state.
class ResetPasswordScreen extends StatefulWidget {
  final AuthRepository auth;
  const ResetPasswordScreen({super.key, required this.auth});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pw = _passwordController.text;
    if (pw.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (pw != _confirmController.text) {
      setState(() => _error = 'The two passwords do not match.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await widget.auth.updatePassword(pw);
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error =
            'That did not work. The reset link may have expired — request a '
            'new one from the sign-in screen.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Set a new password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kSerif,
                      fontFamilyFallback: kSerifFallback,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_done) ...[
                    _Banner(
                      message: 'Password changed. You are signed in.',
                      colour: kAccent,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Continue',
                      // Clearing the recovery event by rebuilding the gate:
                      // the normal session remains, so this lands in the app.
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                        (route) => false,
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        border: OutlineInputBorder(),
                        helperText: 'At least 8 characters',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _confirmController,
                      obscureText: true,
                      onSubmitted: (_) => _save(),
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _Banner(message: _error!, colour: kWrong),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Save password',
                      busy: _busy,
                      onPressed: _busy ? null : _save,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final Color colour;

  const _Banner({required this.message, required this.colour});

  @override
  Widget build(BuildContext context) {
    // A colour rail down the left edge instead of a full outline — it reads
    // faster and does not box the text in.
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: colour, width: 3)),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 14, height: 1.45, color: colour),
      ),
    );
  }
}

// ==========================================================================
// 6b. ROLE GATE
// ==========================================================================
// One question on sign-in: teacher or student? Teachers get the dashboard,
// everyone else gets the quiz.
//
// The answer comes from is_teacher() on the server, never from anything the
// browser could edit. A student who tampered with the reply would reach a
// dashboard that returned empty rows for every class, because each dashboard
// function re-checks ownership in its own query.

/// Open Stripe in the CURRENT tab rather than a new one.
///
/// A browser only allows a new tab if the call happens inside the click that
/// asked for it. Here it cannot: the app has to ask the server for a checkout
/// URL first, and by the time that await returns the click is over. The popup
/// blocker sees a tab opening from nowhere and silently kills it — which is
/// exactly the "Stripe does not come up" symptom, and it is silent, so it
/// reads as the button being broken.
///
/// Navigating this tab needs no permission and cannot be blocked. Nothing is
/// lost by leaving: Stripe returns the browser to SITE_URL when the payment
/// finishes or is cancelled, and the app reloads from the server, where all
/// the state lives anyway.
Future<void> _openBilling(String url) async {
  await launchUrl(
    Uri.parse(url),
    // Ignored off the web, where a real new window is fine.
    webOnlyWindowName: '_self',
  );
}

class RoleGate extends StatefulWidget {
  final AuthRepository auth;

  const RoleGate({super.key, required this.auth});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  final _classes = ClassRepository();
  final _admin = AdminRepository();
  final _safeguarding = SafeguardingRepository();

  // 'admin' | 'teacher' | 'student' | null while checking.
  String? _role;

  /// Null until asked. Only students are asked: a tutor or an admin with an
  /// account is not the person this protects.
  ConsentStatus? _consent;

  /// The student chose to carry on without consent. A session-only choice,
  /// deliberately not saved — the next sign-in should put the explanation
  /// back in front of them, because nothing is being saved and they should
  /// be reminded of that rather than allowed to forget it.
  bool _dismissedConsent = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      // Admin outranks teacher: the admin account is usually also a tutor,
      // and lands on the panel with a door through to their classes.
      if (await _admin.amIAdmin()) {
        if (!mounted) return;
        setState(() => _role = 'admin');
        return;
      }
      final teacher = await _classes.amITeacher();
      if (teacher) {
        if (!mounted) return;
        setState(() => _role = 'teacher');
        return;
      }

      final consent = await _safeguarding.status();
      if (!mounted) return;
      setState(() {
        _consent = consent;
        _role = 'student';
      });
    } catch (_) {
      // If the check fails, fall back to the student app. Erring toward less
      // access rather than more is the right default here.
      if (!mounted) return;
      setState(() => _role = 'student');
    }
  }

  Future<void> _recheckConsent() async {
    final consent = await _safeguarding.status();
    if (!mounted) return;
    setState(() => _consent = consent);
  }

  void _recheck() => setState(() => _role = null);

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      _check();
      return Scaffold(
        backgroundColor: kSurface,
        body: Center(child: CircularProgressIndicator(color: kAccent)),
      );
    }

    if (_role == 'admin') {
      return AdminHome(auth: widget.auth);
    }
    if (_role == 'teacher') {
      return TeacherHome(auth: widget.auth);
    }

    // A student under 18 whose guardian has not confirmed. Not a lock —
    // there is a way past it, and past it the app works normally. What
    // does NOT work is saving anything, and that is refused by the
    // database rather than by this screen.
    final consent = _consent;
    if (consent != null && consent.needsGuardian && !_dismissedConsent) {
      return GuardianConsentScreen(
        status: consent,
        onRecheck: _recheckConsent,
        onContinueAnyway: () => setState(() => _dismissedConsent = true),
      );
    }

    return HomePage(auth: widget.auth, onBecameTeacher: _recheck);
  }
}

// ==========================================================================
// 7. HOME PAGE
// ==========================================================================
//
// Loads the student's profile, then runs the quiz for their grade.
// Also owns the grade switcher: _changeGrade saves the new grade and
// reloads the unit chips.
//
// What it remembers:
//   _profile            who is signed in, and their grade
//   _units              the unit chips for that grade
//   _selectedUnit       which chip is active
//   _index              which of the questions we are on
//   _tried              options already ruled out on this question
//   _showingFeedbackFor whose feedback is on screen right now
//   _solved             whether the correct option has been found
//   _firstTryCount      questions answered right on the first tap
//   _unitProgress       what the database says has been done already
//   _alreadySolved      questions in the open unit that are already correct
//   _earned             the medal from the run just finished
//
// Every setState below is saying: one of those changed, redraw.
//
// On progress: the database is the record, this state is a working copy. On
// load it is filled from ProgressRepository, and every tap is written back.
// Nothing important lives only in memory, which is what lets a student close
// the tab mid-unit and carry on next week.

class HomePage extends StatefulWidget {
  final AuthRepository auth;

  /// Lets the app swap to the teacher dashboard the moment a code is
  /// redeemed, instead of asking somebody to sign out and back in.
  final VoidCallback? onBecameTeacher;

  const HomePage({super.key, required this.auth, this.onBecameTeacher});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _profiles = ProfileRepository();
  final _questions = QuestionRepository();
  final _progress = ProgressRepository();
  final _classes = ClassRepository();

  // The page is one long scroll. When feedback appears after a tap it can
  // land below the fold on a short screen — and that feedback is the entire
  // point of the app, so it is brought into view rather than left to be
  // discovered. The key marks the panel; the controller does the scrolling.
  final _scroll = ScrollController();
  final _feedbackKey = GlobalKey();

  /// Classes the student is in or has been invited to. Loaded on every visit
  /// because a student should never have to go looking to find out who can
  /// see their work.
  List<StudentClass> _myClasses = [];
  List<TutorNote> _notes = [];

  Profile? _profile;
  bool _loading = true;
  String? _error;

  List<UnitSummary> _units = [];
  Map<String, UnitProgress> _unitProgress = {};
  String? _selectedUnit;

  /// Which level of that unit is open, or null while the picker is showing.
  /// The flow is units -> levels -> questions, and each back step clears one.
  String? _selectedLevel;
  List<LevelInfo> _levels = [];
  List<Question> _current = [];
  bool _loadingUnit = false;

  int _index = 0;
  final Set<int> _tried = {};

  /// What the server said about each option tapped on the current question.
  /// The app has no other way of knowing which one is right.
  final Map<int, Verdict> _verdicts = {};

  int? _showingFeedbackFor;
  int? _foundIndex;
  bool _solved = false;
  bool _grading = false;
  int _firstTryCount = 0;
  bool _finished = false;
  Medal _earned = Medal.none;

  /// sort_order of everything already answered correctly in the open unit,
  /// carried over from previous visits so those questions are skipped.
  Set<int> _alreadySolved = {};

  UnitSummary? get _openUnit {
    for (final u in _units) {
      if (u.name == _selectedUnit) return u;
    }
    return null;
  }

  /// Units finished at Bronze — meaning completed, but with enough wrong
  /// taps that the feedback is worth going back to. Silver and Gold are left
  /// alone; there is nothing useful to say to a student who has those.
  List<UnitSummary> get _revisit {
    final out = <UnitSummary>[];
    for (final unit in _units) {
      final p = _unitProgress[unit.name];
      if (p == null) continue;
      if (p.medal == Medal.bronze) out.add(unit);
    }
    return out;
  }

  /// The unit to offer on the resume card: the first one that has been
  /// started but not finished. Null when there is nothing to carry on with.
  UnitSummary? get _resumable {
    for (final unit in _units) {
      final p = _unitProgress[unit.name];
      if (p != null && p.started && p.solved.length < unit.total) return unit;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Bring the feedback panel fully into view after it renders. Waits one
  /// frame so the panel exists to scroll to, then eases to it. Harmless if
  /// the panel is already visible — Flutter moves only as far as needed.
  void _revealFeedback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _feedbackKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        alignment: 0.15,
      );
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile =
          await withTimeout(_profiles.loadOrCreate(), 'Loading your profile');
      // Before anything is drawn with it. A student who chose dark should
      // not see one frame of the light theme on every sign-in.
      kTheme.set(ThemeController.parse(profile.themePref));

      // Units and progress both need the COURSE, and neither needs the
      // other, so they go out together. In sequence they were two round
      // trips stacked on top of the profile fetch — three waits before
      // anything could be drawn, on a phone, on a school connection.
      final core = await Future.wait([
        withTimeout(_questions.fetchUnits(profile.course), 'Loading your topics')
            .then<Object>((v) => v),
        withTimeout(_progress.fetchProgress(profile.course),
                'Loading your progress')
            .then<Object>((v) => v),
      ]);
      final units = core[0] as List<UnitSummary>;
      final progress = core[1] as Map<String, UnitProgress>;

      // Neither of these gates the app, so they go out TOGETHER rather
      // than one after the other, and neither is fatal. Run in sequence
      // they added two more round trips to a cold start on a phone, for
      // information nobody needs in order to answer a question.
      final extras = await Future.wait([
        withTimeout(_classes.myClassesAsStudent(), 'Loading your classes')
            .then<Object>((v) => v)
            .catchError((_) => <StudentClass>[] as Object),
        withTimeout(_classes.myTutorNotes(), 'Loading your feedback')
            .then<Object>((v) => v)
            .catchError((_) => <TutorNote>[] as Object),
      ]);
      final classes = extras[0] as List<StudentClass>;
      final notes = extras[1] as List<TutorNote>;

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _units = units;
        _unitProgress = progress;
        _myClasses = classes;
        _notes = notes;
        _loading = false;
      });

      // Drop the student straight back into whatever they were part way
      // through. They can still pick a different unit from the chips — the
      // point is only that they never have to.
      final resume = _resumable;
      if (resume != null && _selectedUnit == null) {
        await _selectUnit(resume.name);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Opens the grade picker, and if the student chooses a different grade,
  /// saves it and reloads the unit chips for the new course.
  ///
  /// Progress is cleared deliberately: the score counts first-try answers
  /// within a unit, and the old unit does not exist in the new grade.
  /// Opening a unit shows its four levels, not its questions. The level is
  /// where the free/paid line runs, so it has to be a real place in the app
  /// rather than a filter.
  Future<void> _selectUnit(String unit) async {
    // Opening a topic is going somewhere, so Back should come out of it.
    // Only the FIRST one records a step: switching from one topic to
    // another is moving sideways, and stacking those would make Back walk
    // the student through every topic they had glanced at.
    if (_selectedUnit == null) {
      _pushHistory(() => setState(() {
            _selectedUnit = null;
            _selectedLevel = null;
            _levels = [];
            _resetProgress();
          }));
    }

    // Choosing a topic while Learn is open should show that topic's
    // lessons, not leave the previous unit's list sitting there.
    if (_section == 'learn') _loadLessons(unit);
    if (_section == 'test') _loadTestHistory(unit);
    setState(() {
      _selectedUnit = unit;
      _selectedLevel = null;
      _loadingUnit = true;
      _error = null;
      _resetProgress();
    });

    try {
      final levels = await _questions.fetchLevels(_profile!.course, unit);
      if (!mounted) return;
      setState(() {
        _levels = levels;
        _loadingUnit = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingUnit = false;
      });
    }
  }

  Future<void> _selectLevel(LevelInfo level) async {
    // The rail folds itself away as the question arrives. It does not unfold
    // when the question is finished: see the note on _railCollapsed.
    if (_wideLayout && !_railCollapsed) {
      setState(() => _railCollapsed = true);
    }
    // The lock check here is a courtesy so the tap gets a proper answer
    // instead of a server error. The one that counts is in the database:
    // list_questions refuses locked levels no matter what this code does.
    if (level.locked) {
      await _offerAstroPlus();
      return;
    }

    _pushHistory(() => setState(() {
          _selectedLevel = null;
          _resetProgress();
        }));

    setState(() {
      _selectedLevel = level.level;
      _loadingUnit = true;
      _error = null;
    });

    try {
      final questions = await _questions.fetchQuestions(
          _profile!.course, _selectedUnit!, level.level);
      final saved = _unitProgress[_selectedUnit!];

      // The saved solved set covers the whole unit; only the entries that
      // belong to this level's questions matter here.
      final ordersHere = questions.map((q) => q.sortOrder).toSet();
      final solvedHere =
          (saved?.solved ?? const <int>{}).intersection(ordersHere);

      if (!mounted) return;
      setState(() {
        _current = questions;
        _alreadySolved = solvedHere;
        // First-try count comes from the server per level, not from the
        // unit-wide number, or a Gold on Easy would inflate Medium's score.
        _firstTryCount = level.firstTry;
        _index = _firstUnansweredIndex(questions, solvedHere);
        _finished = _index >= questions.length;
        _loadingUnit = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _loadingUnit = false;
      });
    }
  }

  /// The Astro+ ask, worded at the adult. The users are minors, minors
  /// cannot form contracts, and Stripe requires the purchaser to be an
  /// adult — so the app never pretends the student is the customer.
  Future<void> _offerAstroPlus() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => const AstroPlusDialog(),
    );
    if (choice == null || !mounted) return;

    try {
      switch (choice) {
        case 'stripe-monthly':
        case 'stripe-annual':
          final plan = choice == 'stripe-annual' ? 'annual' : 'monthly';
          final url = await SubscriptionRepository().checkoutUrl(plan);
          if (!mounted) return;
          await _openBilling(url);
          break;

        case 'etransfer':
          final email =
              Supabase.instance.client.auth.currentUser?.email ?? '';
          if (!mounted) return;
          final plan = await showDialog<String>(
            context: context,
            builder: (_) => EtransferDialog(accountEmail: email),
          );
          if (plan == null || !mounted) return;
          final message =
              await SubscriptionRepository().requestEtransfer(plan);
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
          break;

        case 'enrol':
          final made = await showDialog<bool>(
            context: context,
            builder: (_) => AstroPlusEnrolmentSheet(
              studentName: _profile?.displayName ?? '',
              grade: _profile?.grade ?? 10,
            ),
          );
          if (made != true || !mounted) return;
          await _showEnrolmentLink();
          break;

        case 'support':
          // A plain mailto. No form, no ticket system — a family with a
          // payment question reaches the person who runs the thing.
          await launchUrl(
            Uri.parse('mailto:stemlabs.ca@gmail.com'
                '?subject=Astro%2B%20question'),
            mode: LaunchMode.externalApplication,
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  /// Shows the link the parent has to open.
  ///
  /// The app cannot send email, so the student is handed the link to pass
  /// on — the same decision the guardian consent screen makes, for the same
  /// reason, and it is said out loud rather than dressed up as "sent!".
  Future<void> _showEnrolmentLink() async {
    // Try to send it properly first. If that works the student still sees
    // the link, because "we emailed your mum" is not reassuring on its own
    // and a link they can also send costs nothing.
    final sentTo = await trySendLink('pay');

    String? link;
    try {
      final token = await EnrolmentRepository().myLink();
      if (token != null) {
        link = Uri.base.resolve('?pay=$token').toString();
      }
    } catch (_) {
      // Falls through to the no-link copy below.
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send them this', style: TextStyle(fontSize: 18)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sentTo != null
                    ? 'Sent to $sentTo. If it has not arrived in a few '
                        'minutes, check the spam folder — or send them this '
                        'link yourself.'
                    : link == null
                        ? 'Your request is in. We will be in touch with your '
                            'parent or guardian at the address you gave.'
                        : 'Your request is in. Send this link to your parent '
                            'or guardian — opening it is all they have to do.',
                style: TextStyle(fontSize: 13.5, height: 1.55, color: kInk),
              ),
              if (link != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
                  decoration: BoxDecoration(
                    color: kTrack,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    link,
                    style:
                        TextStyle(fontSize: 12, height: 1.4, color: kInk),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (link != null)
            TextButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: link!)),
              child: const Text('Copy the link'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    _current = [];
    _index = 0;
    _tried.clear();
    _verdicts.clear();
    _foundIndex = null;
    _showingFeedbackFor = null;
    _solved = false;
    _firstTryCount = 0;
    _finished = false;
    _earned = Medal.none;
    _alreadySolved = {};
  }

  /// First question in the list the student has not already got right.
  /// Returns the length of the list when they have finished all of them.
  int _firstUnansweredIndex(List<Question> questions, Set<int> solved) {
    for (var i = 0; i < questions.length; i++) {
      if (!solved.contains(questions[i].sortOrder)) return i;
    }
    return questions.length;
  }

  /// Sends the tap to the server and shows whatever comes back.
  ///
  /// This one is awaited, unlike the old fire-and-forget logging. It has to
  /// be: the browser genuinely does not know whether the answer was right,
  /// so there is nothing to show until the server says. In exchange, the
  /// score cannot be faked from the network tab.
  Future<void> _tapOption(int i) async {
    // Already solved, already ruled out, or a tap still in flight.
    if (_solved || _tried.contains(i) || _grading) return;

    final question = _current[_index];
    setState(() => _grading = true);

    try {
      final verdict = await _progress.submitAnswer(
        course: _profile!.course,
        question: question,
        chosenIndex: i,
      );
      if (!mounted) return;

      setState(() {
        _grading = false;
        _verdicts[i] = verdict;
        _showingFeedbackFor = i;

        if (verdict.correct) {
          _solved = true;
          _foundIndex = i;
          // The server decides what counts as a first try, from the attempt
          // history. The app cannot claim it.
          if (verdict.wasFirst) {
            _firstTryCount++;
          }
          _alreadySolved = {..._alreadySolved, question.sortOrder};
        } else {
          _tried.add(i);
        }
      });

      // The panel is in the tree now; bring it into view.
      _revealFeedback();
    } catch (e) {
      // Deliberately NOT setState(_error): that replaces the whole quiz
      // area with the error screen and throws the student back to the
      // level picker, losing their crossed-out options over one Wi-Fi
      // blip. The question stays; the tapped option stays enabled; a
      // snackbar says try again.
      if (!mounted) return;
      setState(() => _grading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('That answer could not be sent. Check your connection '
                  'and tap it again.')));
    }
  }

  Future<void> _refreshClasses() async {
    try {
      final classes = await _classes.myClassesAsStudent();
      if (!mounted) return;
      setState(() => _myClasses = classes);
    } catch (_) {}
  }

  /// Feedback a tutor has written. Loaded quietly — a student with no tutor
  /// simply gets an empty list and never sees the section.
  /// Opens the feedback, and marks it read so the tutor knows it landed.
  Future<void> _openFeedback() async {
    await showDialog<void>(
      context: context,
      builder: (_) => TutorFeedbackDialog(notes: _notes),
    );
    try {
      await _classes.markNotesSeen();
    } catch (_) {}
    if (!mounted) return;
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    try {
      final notes = await _classes.myTutorNotes();
      if (!mounted) return;
      setState(() => _notes = notes);
    } catch (_) {}
  }

  Future<void> _answerInvitation(StudentClass invite, bool accept) async {
    await _classes.respondToInvitation(invite.classId, accept);
    await _refreshClasses();
  }

  Future<void> _openClasses() async {
    await showDialog<void>(
      context: context,
      builder: (_) => MyClassesDialog(
        classes: _myClasses,
        onLeave: (id) async {
          await _classes.leaveClass(id);
          await _refreshClasses();
        },
      ),
    );
    await _refreshClasses();
  }

  /// Opens the report. A full screen rather than a dialog, because it is
  /// something a student reads and shares rather than glances at.
  Future<void> _openReport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyReportScreen()),
    );
  }

  // ------------------------------------------------------------------
  // Profile photo
  // ------------------------------------------------------------------

  /// Pick a photo, shrink it, upload it, and repaint with the new one.
  ///
  /// The profile is refetched rather than patched locally, because the path
  /// is decided by the server and this screen should show what the server
  /// actually stored — not what it hopes was stored.
  Future<void> _changePhoto() async {
    try {
      final path = await AvatarRepository().pickAndUpload();
      // Null means they opened the picker and closed it again. That is not
      // an error and should not produce a message.
      if (path == null || !mounted) return;
      final fresh = await ProfileRepository().loadOrCreate();
      if (!mounted) return;
      setState(() => _profile = fresh);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Photo saved.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Future<void> _removePhoto() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove your photo?', style: TextStyle(fontSize: 17)),
        content: Text(
          'Your initials come back in its place. Nothing else changes — your '
          'work, your medals and your classes all stay exactly as they are.',
          style: TextStyle(fontSize: 13.5, height: 1.55, color: kInkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      await AvatarRepository().remove(_profile?.avatarPath);
      final fresh = await ProfileRepository().loadOrCreate();
      if (!mounted) return;
      setState(() => _profile = fresh);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Photo removed.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  /// The Astro+ menu entry: subscribers get the billing portal (change
  /// card, invoices, cancel), everyone else gets the pitch. Cancelling has
  /// to be as findable as subscribing was, which is why this lives on the
  /// same menu as everything else rather than buried.
  Future<void> _openAstro() async {
    final repo = SubscriptionRepository();
    try {
      final premium = await repo.hasPremium();
      if (!mounted) return;
      if (premium) {
        final url = await repo.portalUrl();
        if (!mounted) return;
        await _openBilling(url);
      } else {
        await _offerAstroPlus();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  /// Redeeming a teacher access code.
  ///
  /// Deliberately not a switch that simply makes somebody a teacher. Being a
  /// teacher means being able to read the work of children, so it takes a
  /// code issued by whoever runs the project.
  /// Offers the reset, and carries it out if the student confirms.
  ///
  /// Worth being clear with them about what it does and does not touch,
  /// because "reset" usually means "delete" and here it does not.
  Future<void> _resetCourse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ResetDialog(course: _profile!.courseLabel),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _selectedUnit = null;
      _resetProgress();
    });

    try {
      await _progress.resetCourse(_profile!.course);
      final progress = await _progress.fetchProgress(_profile!.course);
      if (!mounted) return;
      setState(() {
        _unitProgress = progress;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _next() async {
    if (_index + 1 < _current.length) {
      setState(() {
        _index++;
        _tried.clear();
        _verdicts.clear();
        _showingFeedbackFor = null;
        _solved = false;
        _foundIndex = null;
      });
      return;
    }

    setState(() => _finished = true);
    await _saveCompletion();
  }

  /// Works out the medal and stores it, then refreshes the chips so the new
  /// one shows without a reload.
  Future<void> _saveCompletion() async {
    final unit = _openUnit;
    if (unit == null) return;

    try {
      final earned = await _progress.recordCompletion(
        course: _profile!.course,
        unit: unit.name,
        level: _selectedLevel!,
      );
      final progress = await _progress.fetchProgress(_profile!.course);
      if (!mounted) return;
      setState(() {
        _earned = earned;
        _unitProgress = progress;
      });
    } catch (_) {
      // The score is already on screen. A failed write is not worth an error
      // screen at the moment a student has just finished something.
    }
  }

  void _restartUnit() {
    setState(() {
      _index = 0;
      _tried.clear();
      _verdicts.clear();
      _showingFeedbackFor = null;
      _solved = false;
      _foundIndex = null;
      _firstTryCount = 0;
        _finished = false;
      _earned = Medal.none;
      _alreadySolved = {};
    });
  }

  void _backToUnits() {
    // Through the Navigator, so the browser's history unwinds with the
    // app's. Reverting state alone would leave a marker on the stack and
    // the next Back would replay a step the student had already taken.
    _popHistory(() => setState(() {
          _selectedUnit = null;
          _selectedLevel = null;
          _levels = [];
          _resetProgress();
        }));
  }

  /// From the quiz or the results back to the four levels, with the medals
  /// refetched so a just-earned one shows immediately.
  Future<void> _backToLevels() async {
    final unit = _selectedUnit;
    if (unit == null) return;
    setState(() {
      _selectedLevel = null;
      _resetProgress();
    });
    await _selectUnit(unit);
  }

  // Which pane the sidebar has open on a wide screen: the topics/practice
  // flow, or the profile. Phones never see this — they keep the AccountBar.
  /// How many history markers this screen has on the Navigator.
  ///
  /// Tracked so the app's own Back affordances pop the route rather than
  /// only reverting state — otherwise the browser stack keeps growing and
  /// Back starts replaying steps the student already undid.
  int _historyDepth = 0;

  /// Records a step, so Back can undo it.
  void _pushHistory(VoidCallback onBack) {
    _historyDepth++;
    Navigator.of(context).push(HistoryMarkerRoute<void>()).then((_) {
      _historyDepth = _historyDepth > 0 ? _historyDepth - 1 : 0;
      if (mounted) onBack();
    });
  }

  /// Steps back, from a button in the app rather than from the browser.
  /// Falls back to plain state when there is no marker to pop, which
  /// happens on the very first screen.
  void _popHistory(VoidCallback fallback) {
    if (_historyDepth > 0) {
      Navigator.of(context).pop();
    } else {
      fallback();
    }
  }

  String _railView = 'topics';
  bool _wideLayout = false;

  // How the student is looking at the course while no unit is open: the
  // classroom — a list, a resume card and the sections — or the map.
  //
  // Two ways to browse the same curriculum, not two products. Some students
  // read a list faster than they read a map, and the reverse is true often
  // enough that picking one for everybody would be picking wrong for half
  // of them. A per-session choice rather than a saved preference: it costs
  // one tap to change and guessing wrong costs more.
  String _topicView = 'classroom';

  /// The map needs a band per unit and per subtopic, which only my_report
  /// computes. Loaded the first time the map is opened rather than on the
  /// way in, because most sessions never open it.
  final ReportRepository _mapRepo = ReportRepository();
  ReportData? _mapData;
  bool _loadingMap = false;
  String? _mapError;

  Future<void> _loadMap() async {
    if (_loadingMap || _mapData != null) return;
    setState(() {
      _loadingMap = true;
      _mapError = null;
    });
    try {
      final data = await _mapRepo.mine();
      if (!mounted) return;
      setState(() {
        _mapData = data;
        _loadingMap = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mapError = 'Could not load your constellation.';
        _loadingMap = false;
      });
    }
  }

  /// The header, above everything, on every screen and at every width.
  ///
  /// The brand and the Classroom/Constellation switch used to live in the
  /// left rail, which meant they were absent exactly where they were most
  /// wanted: the rail collapses when a question opens, and it does not
  /// exist at all on a phone. So the one control that governs the whole
  /// surface disappeared whenever the surface got busy, and the phone had a
  /// second copy of it pasted into the content instead — two switches, one
  /// state, and neither in a fixed place.
  ///
  /// One bar, one copy, always there. The rail goes back to answering only
  /// "what are you working on".
  Widget _buildTopBar() {
    final narrow = !_wideLayout;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kLine)),
      ),
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 18),
      child: Row(
        children: [
          const BrandBadge(size: 26),
          const SizedBox(width: 9),
          // The wordmark is the first thing to go when space is short. The
          // badge alone still identifies the app, and the switch beside it
          // is the thing a student is actually reaching for.
          if (!narrow)
            Text(
              kBrandName,
              style: TextStyle(
                fontFamily: kSerif,
                fontFamilyFallback: kSerifFallback,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
          const Spacer(),
          // Centre of attention rather than centre of the bar: it sits with
          // the other controls so the eye finds all of them in one place.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: narrow ? 232 : 268),
            child: _buildTopicViewToggle(),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.help_outline_rounded, size: 21, color: kInkSoft),
            tooltip: 'How to use Astro STEM Labs',
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HowToUseScreen()),
            ),
          ),
        ],
      ),
    );
  }

  /// Map or Classroom. Only shown while no unit is open — once a student is
  /// inside a unit the choice is about how to BROWSE, and there is nothing
  /// left to browse.
  /// Classroom or Constellation.
  ///
  /// "Map" was a description of the widget rather than a name for it, and it
  /// sat oddly next to "Classroom", which is a place. The brand already had
  /// the better word: brand/01-constellation-a.svg is the letter A "drawn
  /// the way a star chart draws a constellation, five plotted points joined
  /// by faint lines". That is exactly what this view is, and it is the only
  /// one of the five logo directions that says "astro" and "plot a point"
  /// with one mark.
  Widget _buildTopicViewToggle() => SegmentedTabs(
        labels: const ['Classroom', 'Constellation'],
        selected: _topicView == 'map' ? 1 : 0,
        onSelect: (i) => _showTopicView(i == 1 ? 'map' : 'classroom'),
      );

  void _showTopicView(String view) {
    // Only opening the constellation records a step. Coming back to the
    // classroom IS the step back, and pushing one for it too would mean
    // Back toggled between the two for ever instead of leaving.
    if (view == 'map' && _topicView != 'map') {
      _pushHistory(() => setState(() => _topicView = 'classroom'));
    }
    setState(() => _topicView = view);
    if (view == 'map') _loadMap();
  }

  /// The map, as its own pane. Not inside the scrolling column: a canvas you
  /// pan needs the whole area, and a pannable canvas inside a scroll view is
  /// a fight over every drag.
  Widget _buildMapPane() {
    if (_loadingMap && _mapData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_mapError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_mapError!, style: TextStyle(fontSize: 14, color: kInkSoft)),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadMap, child: const Text('Try again')),
          ],
        ),
      );
    }
    final data = _mapData;
    if (data == null || data.units.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Your constellation fills in as you work. Answer a few questions '
            'and every unit and subtopic appears here, coloured by how it '
            'is going.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.55, color: kInkSoft),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, box) => _MindMap(
        units: data.units,
        centreLabel: _profile?.courseLabel ?? 'My course',
        scores: data.testScores,
        reachable: data.reachable,
        height: box.maxHeight,
        // Nothing to scroll past here, so nothing to trap. The scrim exists
        // for the report, where the map sits inside a scrolling page.
        sleepUntilTapped: false,
        onOpenUnit: (unit, section) {
          _showTopicView('classroom');
          _openSection(section);
          _selectUnit(unit);
        },
      ),
    );
  }

  // Which of the sections the student is working in. Learn and Quiz share
  // the same unit list, so this sits BESIDE _railView rather than replacing
  // it: picking a topic keeps you in the section you were already in, which
  // is the behaviour that makes "read it, then try it" one movement instead
  // of two navigations.
  String _section = 'quiz';
  final LessonRepository _lessonRepo = LessonRepository();
  List<Lesson> _unitLessons = const [];
  bool _loadingLessons = false;
  String? _lessonsFor;

  final ImproveRepository _improveRepo = ImproveRepository();
  List<ImproveRow> _plan = const [];
  bool _loadingPlan = false;
  bool _planLoaded = false;

  final TestRepository _testRepo = TestRepository();
  List<TestAttempt> _testHistory = const [];
  String? _historyFor;

  /// The rail, folded to an icon strip.
  ///
  /// Auto-collapses when a question opens and does NOT auto-expand when it
  /// closes: the app may decide a student wants to concentrate, but only the
  /// student decides they have finished concentrating. Undoing someone's
  /// choice for them is worse than never making it.
  bool _railCollapsed = false;

  @override
  Widget build(BuildContext context) {
    // The Classroom layout: on a screen wide enough for both, navigation
    // lives in a left rail (topics, report, profile) and the right side is
    // kept clean for the question, the answers and the feedback. On a phone
    // everything stacks exactly as it always has — the rail would eat half
    // the width that the question needs.
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _wideLayout = constraints.maxWidth >= 980;
            // The header is outside everything below it, which is the whole
            // point: it survives the rail collapsing, a question opening,
            // the profile pane, and the switch between the two widths.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Everything under the header. Split out only so the header can wrap it;
  /// the two branches below are unchanged.
  Widget _buildBody() {
    {
      {
            if (!_wideLayout) {
              // No `&& _selectedUnit == null` here, and that was the bug:
              // on a phone the switch is in the content, so by the time a
              // student taps Constellation they have almost always opened
              // a topic. The guard meant the tap set the state and drew
              // nothing, which is indistinguishable from the button being
              // broken.
              if (_topicView == 'map') {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  // No toggle here any more — it is in the header, where
                  // it is reachable whether or not a topic is open.
                  child: _buildMapPane(),
                );
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(),
                  ),
                ),
              );
            }
            // No `&& _selectedUnit == null`. I fixed this on the phone
            // path and left the desktop one, so on a wide screen the
            // switch flipped to Constellation and the pane kept drawing
            // the classroom — the state changed and nothing moved, which
            // reads as a broken button. Clearing the topic made it appear,
            // which is the tell.
            final onMap = _railView == 'topics' && _topicView == 'map';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRail(),
                Expanded(
                  child: onMap
                      // The map gets the whole pane, unconstrained and
                      // unscrolled. Everything else keeps the reading
                      // measure it has always had.
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: _buildMapPane(),
                        )
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: SingleChildScrollView(
                              controller: _scroll,
                              padding: const EdgeInsets.all(28),
                              child: _railView == 'profile'
                                  ? _buildProfilePane()
                                  : _buildContent(),
                            ),
                          ),
                        ),
                ),
              ],
            );
      }
    }
  }

  /// The left rail: brand, the three navigation links, and the topic list.
  void _openSection(String section) {
    if (_section == section) return;
    setState(() {
      _section = section;
      // A section is part of the topics flow, so opening one closes the
      // profile pane. Landing on Learn with Profile still showing would
      // look like the tap did nothing.
      _railView = 'topics';
    });
    final unit = _selectedUnit;
    if (section == 'learn' && unit != null) _loadLessons(unit);
    if (section == 'improve') _loadPlan();
    if (section == 'test' && unit != null) _loadTestHistory(unit);
  }

  Future<void> _loadTestHistory(String unit) async {
    setState(() => _historyFor = unit);
    try {
      final rows = await _testRepo.history(_profile!.course, unit);
      if (!mounted || _historyFor != unit) return;
      setState(() => _testHistory = rows);
    } catch (_) {
      if (!mounted) return;
      setState(() => _testHistory = const []);
    }
  }

  /// Lessons for one unit. Cached by unit name, because switching between
  /// Learn and Quiz on the same topic is the movement this whole section
  /// exists to make cheap, and refetching every time would put a spinner in
  /// the middle of it.
  Future<void> _loadLessons(String unit) async {
    if (_lessonsFor == unit && _unitLessons.isNotEmpty) return;
    setState(() {
      _loadingLessons = true;
      _lessonsFor = unit;
      _unitLessons = const [];
    });
    try {
      final rows = await _lessonRepo.list(_profile!.course, unit);
      if (!mounted) return;
      setState(() {
        _unitLessons = rows;
        _loadingLessons = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLessons = false);
    }
  }

  /// The plan is course-wide, not per unit, so it is fetched once and only
  /// refreshed when something could have changed it — finishing a drill or
  /// handing in a test.
  Future<void> _loadPlan({bool force = false}) async {
    if (_planLoaded && !force) return;
    setState(() => _loadingPlan = true);
    try {
      final rows = await _improveRepo.plan();
      if (!mounted) return;
      setState(() {
        _plan = rows;
        _planLoaded = true;
        _loadingPlan = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPlan = false);
    }
  }

  Future<void> _openDrill(ImproveRow row) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DrillScreen(
          course: _profile!.course,
          tags: [row.tag],
          title: row.label,
        ),
      ),
    );
    if (!mounted) return;
    // The plan is a picture of what is weak. Ten questions later it is a
    // different picture, and showing the old one would be a lie.
    await _loadPlan(force: true);
    await _refreshProgress();
  }

  Future<void> _openTest() async {
    final unit = _selectedUnit;
    if (unit == null) return;
    final finished = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TestScreen(
          course: _profile!.course,
          unit: unit,
          lessons: _lessonRepo,
        ),
      ),
    );
    if (!mounted) return;
    if (finished == true) {
      await _loadPlan(force: true);
      await _refreshProgress();
      await _loadTestHistory(unit);
    }
  }

  /// Progress after work done outside the quiz flow. Wrapped so a failure
  /// here can never take down the screen the student just came back to.
  /// Applied on screen at once, saved in the background. If the write fails
  /// the student still gets the theme they asked for; it simply will not
  /// survive a sign-out, which is not worth a dialog.
  void _setTheme(ThemeMode mode) {
    kTheme.set(mode);
    setState(() {});
    ProfileRepository()
        .saveThemePref(ThemeController.name(mode))
        .catchError((Object _) {});
  }

  Future<void> _refreshProgress() async {
    try {
      final p = await _progress.fetchProgress(_profile!.course);
      if (!mounted) return;
      setState(() => _unitProgress = p);
    } catch (_) {
      // Stale numbers for a moment are better than an error page after a
      // test the student has just finished.
    }
  }

  Future<void> _openLessonById(int id) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
          lessonId: id,
          lessons: _lessonRepo,
          course: _profile!.course,
        ),
      ),
    );
  }

  /// Opens a lesson, and keeps opening the next one for as long as the
  /// student asks for it. A unit is five or six short reads; making them
  /// walk back out to the list between each one would turn a ten-minute
  /// sitting into ten navigations.
  Future<void> _openLesson(Lesson lesson) async {
    var current = lesson;
    while (true) {
      final at = _unitLessons.indexWhere((l) => l.id == current.id);
      final hasNext = at >= 0 && at + 1 < _unitLessons.length;

      final wantsNext = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => LessonScreen(
            lessonId: current.id,
            lessons: _lessonRepo,
            course: _profile!.course,
            hasNext: hasNext,
          ),
        ),
      );
      if (!mounted) return;
      if (wantsNext == true && hasNext) {
        current = _unitLessons[at + 1];
        continue;
      }
      break;
    }

    // Coming back, the ticks beside the lessons should be right. Forcing a
    // refetch is cheaper than trying to guess server-side state here.
    if (!mounted) return;
    final unit = _lessonsFor;
    if (unit != null) {
      _lessonsFor = null;
      await _loadLessons(unit);
    }
  }

  Widget _buildRail() {
    if (_railCollapsed) return _buildRailStrip();
    return AnimatedContainer(
      duration: _motion(context),
      width: 248,
      decoration: BoxDecoration(
        color: kCard,
        border: Border(right: BorderSide(color: kLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The brand moved to the header. Repeating it here would
                // put the logo twice on one screen, eleven pixels apart.
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'MY COURSE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: kInkSoft,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.first_page_rounded,
                          size: 20, color: kInkSoft),
                      tooltip: 'Collapse the sidebar',
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          setState(() => _railCollapsed = true),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Pulled 10px left, out of the header's own padding, so the
                // chips line up with the rail links below rather than
                // sitting proud of them. The header insets its content by
                // 20; a _RailLink's pill starts at 10. Without this the
                // subject row is the only thing in the sidebar that does
                // not share an edge with everything under it.
                Transform.translate(
                  offset: const Offset(-10, 0),
                  child: const SubjectSwitcher(),
                ),
                const SizedBox(height: 3),
                Text(
                  // The class count stays on the front surface here for the
                  // same reason the phone AccountBar shows it: a student
                  // should never have to go looking to learn that a teacher
                  // can see their work.
                  [
                    _profile?.courseLabel ?? '',
                    () {
                      final n =
                          _myClasses.where((c) => !c.isInvitation).length;
                      return n == 0
                          ? 'not in a class'
                          : 'in $n ${n == 1 ? 'class' : 'classes'}';
                    }(),
                  ].join('  ·  '),
                  style: TextStyle(fontSize: 12, color: kInkSoft),
                ),
              ],
            ),
          ),
          _RailLink(
            icon: Icons.grid_view_rounded,
            label: 'Topics',
            selected: _railView == 'topics',
            onTap: () {
              // Back to the overview, closing any open unit — otherwise
              // this link does nothing visible mid-question and reads as
              // broken.
              setState(() => _railView = 'topics');
              if (_selectedUnit != null) _backToUnits();
            },
          ),
          _RailLink(
            icon: Icons.insights_rounded,
            label: 'My report',
            selected: false,
            onTap: _openReport,
          ),
          _RailLink(
            icon: Icons.person_rounded,
            label: 'Profile and Preferences',
            selected: _railView == 'profile',
            onTap: () {
              _pushHistory(() => setState(() => _railView = 'topics'));
              setState(() => _railView = 'profile');
            },
            // Their own face (or initials) instead of a generic person icon.
            leading: PersonAvatar(
              name: _profile?.displayName ?? '',
              seed: _profile?.id ?? '',
              size: 20,
              photoPath: _profile?.avatarPath,
            ),
          ),
          // The rail is one list now, not two.
          //
          // It used to carry SECTIONS (Learn, Quiz, Improve, Test) above
          // TOPICS (the units), and neither governed the other: you picked
          // a section, then a topic, and nothing on screen said which was
          // the parent. Two lists competing to be the primary navigation is
          // the definition of a confusing sidebar.
          //
          // Now the rail answers one question — WHAT are you working on —
          // and the four sections answer the other — HOW — as tabs on the
          // page, where they belong to the topic you actually picked.
          Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              'TOPICS',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: kInkSoft,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
              children: [
                for (final u in _units)
                  _RailTopic(
                    unit: u,
                    progress: _unitProgress[u.name],
                    selected: _selectedUnit == u.name,
                    onTap: () {
                      setState(() => _railView = 'topics');
                      _selectUnit(u.name);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The rail folded to 64 pixels: the four sections as icons, and nothing
  /// else. The topic list goes entirely — a truncated unit name is worse
  /// than no unit name, and the point of collapsing is that the student is
  /// working rather than choosing.
  Widget _buildRailStrip() {
    Widget icon(IconData i, String label, String section) {
      final on = _railView == 'topics' && _section == section;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Tooltip(
          message: label,
          child: Material(
            color: on ? kWash : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => _openSection(section),
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 44,
                child: Icon(i, size: 21, color: on ? kAccent : kInkSoft),
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: _motion(context),
      width: 64,
      decoration: BoxDecoration(
        color: kCard,
        border: Border(right: BorderSide(color: kLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          IconButton(
            icon: Icon(Icons.last_page_rounded, size: 20, color: kInkSoft),
            tooltip: 'Expand the sidebar',
            onPressed: () => setState(() => _railCollapsed = false),
          ),
          const SizedBox(height: 10),
          for (final s in kSections) icon(s.$3, s.$2, s.$1),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Tooltip(
              message: 'Profile',
              child: IconButton(
                icon: PersonAvatar(
                  name: _profile?.displayName ?? '',
                  seed: _profile?.id ?? '',
                  size: 22,
                  photoPath: _profile?.avatarPath,
                ),
                onPressed: () => setState(() {
                  _railCollapsed = false;
                  _railView = 'profile';
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The profile pane: everything that lives behind the phone's "…" menu,
  /// laid out in the open on a wide screen.
  Widget _buildProfilePane() {
    final p = _profile!;
    Widget card(List<Widget> children) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(13),
            boxShadow: kCardShadow,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children),
        );

    final classCount = _myClasses.where((c) => !c.isInvitation).length;

    Widget themeChoice(ThemeMode mode, IconData i, String label, String hint) {
      final on = kTheme.mode == mode;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: on ? kWash : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _setTheme(mode),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: on ? kAccent : kLine),
              ),
              child: Row(
                children: [
                  Icon(i, size: 19, color: on ? kAccent : kInkSoft),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                          ),
                        ),
                        Text(
                          hint,
                          style: TextStyle(fontSize: 12, color: kInkSoft),
                        ),
                      ],
                    ),
                  ),
                  if (on) Icon(Icons.check_rounded, size: 18, color: kAccent),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Profile',
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: kInk,
          ),
        ),
        const SizedBox(height: 18),
        // An invitation is a request to see this student's work; it appears
        // wherever they are, not only behind the Topics pane.
        for (final invite in _myClasses.where((c) => c.isInvitation)) ...[
          InvitationCard(
            invite: invite,
            onAccept: () => _answerInvitation(invite, true),
            onDecline: () => _answerInvitation(invite, false),
          ),
          const SizedBox(height: 14),
        ],
        card([
          Row(
            children: [
              // Tapping the picture is the obvious gesture; the buttons
              // below exist for whoever does not think to try it.
              Tooltip(
                message:
                    p.avatarPath == null ? 'Add a photo' : 'Change your photo',
                child: InkWell(
                  onTap: _changePhoto,
                  customBorder: const CircleBorder(),
                  child: PersonAvatar(
                    name: p.displayName,
                    seed: p.id,
                    size: 56,
                    photoPath: p.avatarPath,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.displayName,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kInk)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (p.email != null) p.email!,
                        p.courseLabel,
                        classCount == 0
                            ? 'not in a class'
                            : 'in $classCount '
                                '${classCount == 1 ? 'class' : 'classes'}',
                      ].join('  ·  '),
                      style:
                          TextStyle(fontSize: 12.5, color: kInkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: _changePhoto,
                child: Text(
                    p.avatarPath == null ? 'Add a photo' : 'Change photo'),
              ),
              if (p.avatarPath != null)
                TextButton(
                  onPressed: _removePhoto,
                  style: TextButton.styleFrom(foregroundColor: kInkSoft),
                  child: const Text('Remove photo'),
                ),
            ],
          ),
        ]),
        card([
          Text('My classes',
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600, color: kInk)),
          const SizedBox(height: 4),
          Text(
            'Who can see your work, and since when. You can leave a class '
            'at any time.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: _openClasses, child: const Text('View classes')),
          ),
        ]),
        card([
          Text('Appearance',
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600, color: kInk)),
          const SizedBox(height: 4),
          Text(
            'Saved to your account, so it follows you between the school '
            'computer and your phone.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 12),
          themeChoice(ThemeMode.light, Icons.light_mode_rounded, 'Light',
              'The original. Cream paper, dark ink.'),
          themeChoice(ThemeMode.dark, Icons.dark_mode_rounded, 'Dark',
              'Easier at night, and on a phone in bed.'),
          themeChoice(ThemeMode.system, Icons.brightness_auto_rounded,
              'Match my device', 'Follows whatever your phone or laptop does.'),
          const SizedBox(height: 2),
          Text(
            'Lesson diagrams are drawn twice, once for each, so they never '
            'glow white on a dark page.',
            style: TextStyle(fontSize: 11.5, height: 1.45, color: kInkSoft),
          ),
        ]),
        card([
          Text('Astro+',
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600, color: kInk)),
          const SizedBox(height: 4),
          Text(
            'Challenge and Advanced levels, plus a tutor who reviews your '
            'work. Manage the subscription or see the plans.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: _openAstro, child: const Text('Open Astro+')),
          ),
        ]),
        card([
          Text('Start over',
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600, color: kInk)),
          const SizedBox(height: 4),
          Text(
            'Clears your position so every topic starts from question one. '
            'Medals and history stay.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: _resetCourse,
                child: const Text('Reset my progress')),
          ),
        ]),
        // Getting hold of a person, in the pane a student goes to when
        // something is wrong. The footer strip carries it too, but nobody
        // scrolls to a footer looking for help.
        card([
          Text('Something wrong?',
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600, color: kInk)),
          const SizedBox(height: 4),
          Text(
            'A broken question, a payment problem, anything at all. A person '
            'reads the inbox.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showContactSheet(context),
              child: const Text('Contact us'),
            ),
          ),
        ]),

        // Your data. Two rights, and they are rights rather than settings,
        // so they sit in their own card and not in a menu.
        card([
          Text('Your data',
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600, color: kInk)),
          const SizedBox(height: 4),
          Text(
            'Everything we hold about you, in one file. Or delete the '
            'account and all of it, for good.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _exportMyData,
                child: const Text('Download my data'),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: _deleteMyAccount,
                style: TextButton.styleFrom(foregroundColor: kWrong),
                child: const Text('Delete my account'),
              ),
            ],
          ),
        ]),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.auth.signOut,
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            icon: const Icon(Icons.logout_rounded, size: 17),
            label: const Text('Sign out'),
          ),
        ),
        // Reachable from INSIDE the app, not only from the sign-in screen.
        // A student who made an account a year ago has not seen that screen
        // since, and the policy they are governed by should not be behind
        // signing out.
        const SizedBox(height: 8),
        const LegalLinks(),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Hands the student a JSON file of everything held about them.
  ///
  /// Built in the browser from what the server returns rather than fetched
  /// as a file, because the server has no file to give — export_my_data
  /// returns a document and this turns it into something you can keep.
  Future<void> _exportMyData() async {
    try {
      final data = await SafeguardingRepository().export();
      const encoder = JsonEncoder.withIndent('  ');
      final text = encoder.convert(data);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: kCard,
          title: Text('Your data',
              style: TextStyle(fontSize: 17, color: kInk)),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is everything Astro STEM Labs holds about you. '
                  'Copy it and save it wherever you like.',
                  style:
                      TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 240,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kTrack,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      text,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontFamilyFallback: kMonoFallback,
                        fontSize: 11,
                        height: 1.45,
                        color: kInk,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: text)),
              child: const Text('Copy all'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not build the export: $e')),
      );
    }
  }

  /// Deletes the account. Irreversible, and said so twice.
  ///
  /// The second confirmation is typing the word, not a second button. A
  /// second button is a reflex; typing is a decision. This is the only
  /// place in the app that asks for that, and it is the only action in the
  /// app that cannot be undone.
  Future<void> _deleteMyAccount() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: kCard,
          title: Text('Delete your account?',
              style: TextStyle(fontSize: 17, color: kInk)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This deletes your profile, every question you have '
                'answered, your medals, your test papers and your photo. '
                'It cannot be undone and there is no copy.',
                style: TextStyle(fontSize: 13.5, height: 1.55, color: kInk),
              ),
              const SizedBox(height: 10),
              Text(
                'If you only want to start the course again, close this and '
                'use Reset my progress instead.',
                style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => setLocal(() {}),
                decoration: const InputDecoration(
                  labelText: 'Type DELETE to confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep my account'),
            ),
            TextButton(
              onPressed: controller.text.trim().toUpperCase() == 'DELETE'
                  ? () => Navigator.of(context).pop(true)
                  : null,
              style: TextButton.styleFrom(foregroundColor: kWrong),
              child: const Text('Delete everything'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    try {
      await SafeguardingRepository().deleteAccount();
      // The session is now attached to a user that no longer exists, so
      // sign out rather than leaving the app holding a dead token.
      await widget.auth.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete the account: $e')),
      );
    }
  }

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 140),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return ErrorView(
        message: _error ?? 'Could not load your profile.',
        onRetry: _load,
        onSignOut: widget.auth.signOut,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // On a wide screen the rail carries all of this; a second copy on
        // top of the content would just be noise.
        if (!_wideLayout)
          AccountBar(
            courseLabel: _profile!.courseLabel,
            grade: _profile!.grade,
            classCount: _myClasses.where((c) => !c.isInvitation).length,
            name: _profile!.displayName,
            studentId: _profile!.id,
            avatarPath: _profile!.avatarPath,
            onChangePhoto: _changePhoto,
            onRemovePhoto: _removePhoto,
            onOpenReport: _openReport,
            onResetProgress: _resetCourse,
            onOpenClasses: _openClasses,
            onOpenAstro: _openAstro,
            onSignOut: widget.auth.signOut,
          ),

        // A greeting, but only on the way in. Once a unit is open the student
        // is working and does not need to be welcomed again.
        if (_selectedUnit == null) ...[
          const SizedBox(height: 18),
          WelcomeHeader(
            name: _profile!.displayName,
            returning: _unitProgress.isNotEmpty,
          ),
        ],

        // An invitation is the one thing that interrupts. Somebody is asking
        // to see this student's work, and that deserves a decision rather
        // than a line in a menu.
        for (final invite in _myClasses.where((c) => c.isInvitation)) ...[
          const SizedBox(height: 14),
          InvitationCard(
            invite: invite,
            onAccept: () => _answerInvitation(invite, true),
            onDecline: () => _answerInvitation(invite, false),
          ),
        ],

        // Feedback from a tutor, on the way in. Above the resume card
        // deliberately: somebody took the time to write it, and it should
        // not sit under the thing that pulls the student straight back
        // into practising.
        if (_selectedUnit == null && _notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          TutorFeedbackShelf(
            notes: _notes,
            onOpen: _openFeedback,
          ),
        ],

        // Only worth showing when they are not already inside a unit.
        if (_selectedUnit == null && _resumable != null) ...[
          const SizedBox(height: 16),
          ResumeCard(
            unit: _resumable!,
            progress: _unitProgress[_resumable!.name]!,
            onContinue: () => _selectUnit(_resumable!.name),
          ),
        ],

        // The overview strip is for choosing what to work on. Once a unit is
        // open it only takes up vertical space above the question, so it
        // steps aside until the student comes back out.
        if (_units.isNotEmpty && _selectedUnit == null) ...[
          const SizedBox(height: 14),
          MasteryHeader(units: _units, progress: _unitProgress),
        ],

        // Units already finished but not finished well. Not a medal and not a
        // scold — just a note that the feedback in these is worth rereading.
        if (_selectedUnit == null && _revisit.isNotEmpty) ...[
          const SizedBox(height: 14),
          RevisitShelf(units: _revisit, onSelect: _selectUnit),
        ],

        // The full unit selector shows only when no unit is open — and only
        // on a phone, where there is no rail. On a wide screen the topic
        // list lives on the left, permanently visible, which is the whole
        // point of the Classroom layout.
        if (_selectedUnit == null && !_wideLayout) ...[
          const SizedBox(height: 22),
          UnitSelector(
            units: _units,
            progress: _unitProgress,
            selected: _selectedUnit,
            onSelect: _selectUnit,
          ),
        ],
        // The four sections, as tabs on the topic you have open.
        //
        // They used to live in the rail on a wide screen and only appear
        // here on a phone. That put them next to the topic list rather
        // than inside it, and left the two reading as siblings when one
        // belongs to the other: you do not pick Learn and then pick
        // Quadratics, you pick Quadratics and then decide how to work on
        // it.
        //
        // So they follow the topic now, on every width. The heading above
        // them names the unit, because a row of tabs with no subject is a
        // row of tabs about nothing.
        // Same switch, on a phone, where there is no rail to put it in.
        if (!_wideLayout && _units.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTopicViewToggle(),
        ],

        // The four sections, as tabs.
        //
        // ALWAYS shown, whether or not a topic is open, and that is not
        // symmetry for its own sake: Improve is course-wide by design,
        // because weakness does not respect unit boundaries. Showing the
        // tabs only once a unit was picked — which is what the first
        // version of this did — made Improve unreachable on a wide screen
        // until the student had opened a topic they did not need.
        //
        // The heading above them names the unit when there is one. A row
        // of tabs with no subject is a row of tabs about nothing, but
        // "everything in this course" is a perfectly good subject too.
        if (_units.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            _selectedUnit ?? 'All of ${_profile?.courseLabel ?? 'your course'}',
            style: TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: kInk,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedTabs(
            labels: const ['Learn', 'Quiz', 'Improve', 'Test'],
            selected: _sectionOrder.indexOf(_section).clamp(0, 3),
            onSelect: (i) => _openSection(_sectionOrder[i]),
          ),
        ],
        const SizedBox(height: 24),
        _buildSectionArea(),
      ],
    );
  }

  /// The order the four sections are meant to be used in, which is also the
  /// order they appear in the rail and on the phone tabs. Read it, try it,
  /// fix what broke, prove it.
  static const List<String> _sectionOrder = ['learn', 'quiz', 'improve', 'test'];

  Widget _buildSectionArea() {
    switch (_section) {
      case 'learn':
        return _buildLearnArea();
      case 'improve':
        return _buildImproveArea();
      case 'test':
        return _buildTestArea();
      default:
        return _buildQuizArea();
    }
  }

  /// The Improve pane: the few subtopics worth time right now.
  ///
  /// Course-wide rather than per unit, because weakness does not respect
  /// unit boundaries and a student who has finished three units should be
  /// sent to the weakest thing across all three.
  Widget _buildImproveArea() {
    if (_loadingPlan && _plan.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 90),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_plan.isEmpty) {
      return const EmptyPrompt(
        message: 'Nothing to fix yet. Answer some questions and anything '
            'that keeps tripping you up will show up here.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Worth your time',
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'The subtopics you get wrong on the first look, and the ones you '
          'have been quietly going around. Short sets — nothing is scored '
          'and no medal moves.',
          style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
        ),
        const SizedBox(height: 16),
        for (final row in _plan)
          ImproveTile(
            row: row,
            onDrill: () => _openDrill(row),
            onLesson: row.lessonId == null
                ? null
                : () => _openLessonById(row.lessonId!),
          ),
      ],
    );
  }

  /// The Test pane: what a test is, and the button that starts one.
  Widget _buildTestArea() {
    if (_units.isEmpty) {
      return EmptyPrompt(
        message: 'No questions for ${_profile!.courseLabel} yet.',
      );
    }
    final unit = _selectedUnit;
    if (unit == null) {
      return EmptyPrompt(
        message: _wideLayout
            ? 'Pick a topic from the left to test yourself on it.'
            : 'Pick a unit above to test yourself on it.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          unit,
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kInk,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kLine),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The whole unit, straight through.',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: kInk),
              ),
              const SizedBox(height: 6),
              Text(
                'No feedback until you hand it in — that is what makes the '
                'score mean something. You can change any answer before you '
                'do, and your best score on a unit is the one that counts, '
                'so it can only go up.',
                style:
                    TextStyle(fontSize: 13.5, height: 1.55, color: kInkSoft),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: _testHistory.isEmpty
                    ? 'Start the test'
                    : 'Take it again',
                onPressed: _openTest,
              ),
            ],
          ),
        ),
        if (_testHistory.isNotEmpty) ...[
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Papers you have sat',
                  style: TextStyle(
                    fontFamily: kSerif,
                    fontFamilyFallback: kSerifFallback,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
              ),
              // The topic map shows the best score, which cannot go down and
              // so stops being news. Saying which one it is puts the number
              // on the map back in reach of the student.
              Text(
                'best ${_testHistory.map((t) => t.scorePct).reduce((a, b) => a > b ? a : b)}%',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: bandTextColour(bandForRate(
                      _testHistory.map((t) => t.scorePct).reduce(
                          (a, b) => a > b ? a : b))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final t in _testHistory) _TestHistoryRow(attempt: t),
        ],
        const SizedBox(height: 16),
        JokeStrip(seed: '$unit-test', label: 'Before you start'),
      ],
    );
  }

  /// The Learn pane: a unit's lessons, in the order they should be read.
  Widget _buildLearnArea() {
    if (_units.isEmpty) {
      return EmptyPrompt(
        message: 'No lessons for ${_profile!.courseLabel} yet.',
      );
    }
    final unit = _selectedUnit;
    if (unit == null) {
      return EmptyPrompt(
        message: _wideLayout
            ? 'Pick a topic from the left to read about it.'
            : 'Pick a unit above to read about it.',
      );
    }
    if (_loadingLessons) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 90),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_unitLessons.isEmpty) {
      return const EmptyPrompt(
        message: 'No lessons written for this unit yet.',
      );
    }

    final states = learnPathStates(_unitLessons);
    final done = states.where((s) => s == LessonNodeState.done).length;
    final locking = states.contains(LessonNodeState.locked) ||
        _unitLessons.every((l) => l.hasGateData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                unit,
                style: TextStyle(
                  fontFamily: kSerif,
                  fontFamilyFallback: kSerifFallback,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
            ),
            Text(
              '$done of ${_unitLessons.length} done',
              style: TextStyle(fontSize: 12.5, color: kInkSoft),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          locking
              ? 'One at a time. Read it, then get ${Lesson.gateSize} questions '
                  'on it right, and the next one opens. Wrong answers do not '
                  'count against you here — they tell you which turn you '
                  'missed and you go again.'
              : 'Short reads. Each one ends with the mistakes people actually '
                  'make on it, which are the same mistakes the questions are '
                  'built from.',
          style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _unitLessons.length; i++)
          LessonNode(
            lesson: _unitLessons[i],
            state: states[i],
            isLast: i == _unitLessons.length - 1,
            onOpen: states[i] == LessonNodeState.locked
                ? null
                : () => _openLesson(_unitLessons[i]),
            onPractise: states[i] == LessonNodeState.locked ||
                    !_unitLessons[i].hasGate
                ? null
                : () => _openGate(_unitLessons[i]),
          ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Try the questions',
          onPressed: () => _openSection('quiz'),
        ),
      ],
    );
  }

  /// The gate: a short drill on this lesson's subtopic.
  ///
  /// Reuses DrillScreen, which is what Improve already opens, so a gate is
  /// not a second kind of question screen — it is the same one, pointed at
  /// one tag. The lessons are refetched afterwards because the gate is
  /// derived from attempts, so the path only moves once the server agrees
  /// it should.
  Future<void> _openGate(Lesson lesson) async {
    final tag = lesson.tag;
    if (tag == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DrillScreen(
          course: _profile!.course,
          tags: [tag],
          title: lesson.subtopic,
        ),
      ),
    );
    if (!mounted) return;
    final unit = _selectedUnit;
    if (unit != null) await _loadLessons(unit);
  }

  Widget _buildQuizArea() {
    if (_loadingUnit) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 90),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry:
            _selectedUnit == null ? _load : () => _selectUnit(_selectedUnit!),
      );
    }

    if (_units.isEmpty) {
      return EmptyPrompt(
        message: 'No questions for ${_profile!.courseLabel} yet.',
      );
    }

    if (_selectedUnit == null) {
      return EmptyPrompt(
        message: _unitProgress.isEmpty
            ? (_wideLayout
                ? 'Pick a topic from the left to begin.'
                : 'Pick a unit above to begin.')
            : (_wideLayout
                ? 'Pick a topic from the left to carry on.'
                : 'Pick a unit above to carry on.'),
      );
    }

    // Unit open, level not chosen yet: the picker.
    if (_selectedLevel == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LevelPicker(
            unit: _selectedUnit!,
            levels: _levels,
            onSelect: _selectLevel,
            onBack: _backToUnits,
          ),
          const SizedBox(height: 18),
          JokeStrip(seed: _selectedUnit!, label: 'Before you start'),
        ],
      );
    }

    if (_finished) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResultsView(
            level: _selectedLevel!,
            firstTry: _firstTryCount,
            total: _current.length,
            medal: _earned,
            onRestart: _restartUnit,
            onChangeUnit: _backToLevels,
          ),
          const SizedBox(height: 20),
          // A different seed from the warm-up, so finishing a level does not
          // repeat the joke the student just read.
          JokeStrip(
            seed: '${_selectedUnit!}-${_selectedLevel!}-done',
            label: 'One more',
          ),
        ],
      );
    }

    if (_current.isEmpty) {
      return const EmptyPrompt(message: 'No questions in this unit yet.');
    }

    return _buildQuestion();
  }

  Widget _buildQuestion() {
    final q = _current[_index];
    final isLast = _index + 1 >= _current.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressHeader(
          current: _index + 1,
          total: _current.length,
          courseCode: q.courseCode,
          difficulty: q.difficulty,
          onBack: _backToLevels,
        ),
        const SizedBox(height: 18),
        QuestionCard(prompt: q.prompt, subtopic: q.subtopic, figure: q.figure),
        // While a tap is away being graded there was previously no signal
        // at all — on a slow connection the options just stopped
        // responding and students tapped harder. A thin moving line says
        // "working on it" without shifting the layout.
        SizedBox(
          height: 2,
          child: _grading
              ? LinearProgressIndicator(
                  color: kAccent, backgroundColor: Colors.transparent)
              : null,
        ),
        const SizedBox(height: 22),
        for (int i = 0; i < q.options.length; i++) ...[
          OptionTile(
            letter: String.fromCharCode(65 + i),
            option: q.options[i],
            // Only ever mark an option once the student has tapped it.
            isRuledOut: _tried.contains(i),
            isFound: i == _foundIndex,
            isFocused: _showingFeedbackFor == i,
            enabled: !_solved && !_tried.contains(i) && !_grading,
            onTap: () => _tapOption(i),
          ),
          const SizedBox(height: 10),
        ],
        if (_showingFeedbackFor != null) ...[
          const SizedBox(height: 10),
          FeedbackPanel(
            key: _feedbackKey,
            correct: _verdicts[_showingFeedbackFor!]?.correct ?? false,
            message: _verdicts[_showingFeedbackFor!]?.feedback ?? '',
          ),
        ],
        if (_solved) ...[
          const SizedBox(height: 18),
          PrimaryButton(
            label: isLast ? 'See results' : 'Next question',
            onPressed: _next,
          ),
        ] else if (_tried.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Keep going — try another option.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kInkSoft),
          ),
        ],
      ],
    );
  }
}

/// One navigation link on the left rail.
class _RailLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Drawn in place of the icon when set. Exists so the Profile link can be
  /// the student's own face — the same trick every app with an account uses,
  /// because "the circle with me in it" needs no label to be findable.
  final Widget? leading;

  const _RailLink({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? kWash : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                leading ??
                    Icon(icon,
                        size: 18, color: selected ? kAccentDeep : kInkSoft),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? kAccentDeep : kInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One topic on the left rail: name, progress line, and the medal if any.
class _RailTopic extends StatelessWidget {
  final UnitSummary unit;
  final UnitProgress? progress;
  final bool selected;
  final VoidCallback onTap;

  const _RailTopic({
    required this.unit,
    required this.progress,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final solved = progress?.solved.length ?? 0;
    final medal = progress?.medal ?? Medal.none;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? kWash : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? kAccentDeep : kInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        solved == 0
                            ? '${unit.total} questions'
                            : '$solved of ${unit.total}',
                        style: TextStyle(
                            fontSize: 11, color: kInkSoft),
                      ),
                    ],
                  ),
                ),
                if (medal != Medal.none) MedalDot(medal: medal, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// 7b. TEACHER DASHBOARD
// ==========================================================================
// Two screens. A list of classes, and one class opened.
//
// The class screen has two tabs, and the order of them is the argument this
// project makes. Students first, because that is what a teacher expects. But
// Mistakes is the tab worth having: a score tells you who is behind, and a
// misconception tells you what to teach on Monday.

class TeacherHome extends StatefulWidget {
  final AuthRepository auth;

  const TeacherHome({super.key, required this.auth});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  final _classes = ClassRepository();

  List<ClassInfo> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _classes.myClasses();
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createClass() async {
    final made = await showDialog<bool>(
      context: context,
      builder: (_) => const CreateClassDialog(),
    );
    if (made == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: RefreshIndicator(
              onRefresh: _load,
              color: kAccent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your classes',
                              style: TextStyle(
                                fontFamily: kSerif,
                                fontFamilyFallback: kSerifFallback,
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: kInk,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.auth.currentUser?.email ?? '',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: kInkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: widget.auth.signOut,
                        style:
                            TextButton.styleFrom(foregroundColor: kInkSoft),
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_loading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(color: kAccent),
                      ),
                    )
                  else if (_error != null)
                    ErrorView(message: _error!, onRetry: _load)
                  else if (_list.isEmpty)
                    const EmptyPrompt(
                      message: 'No classes yet.\n\nCreate one, then invite '
                          'your students by email.',
                    )
                  else
                    ..._list.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClassCard(
                            info: c,
                            onOpen: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ClassDetail(info: c),
                                ),
                              );
                              _load();
                            },
                          ),
                        )),

                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'New class',
                    onPressed: _createClass,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final ClassInfo info;
  final VoidCallback onOpen;

  const ClassCard({super.key, required this.info, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: kCardShadow,
          ),
          child: Row(
            children: [
              // A colour bar rather than a lettered tile. The rule that came
              // out of looking at it: letters are for PEOPLE, where initials
              // are how we already recognise each other, and colour alone is
              // for things. A tile reading 'S' next to the words 'Saturday
              // MPM2D' was telling you what you could already read.
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: unitTint(info.name),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        info.course.isEmpty
                            ? 'Grade ${info.grade}'
                            : info.course,
                        info.students == 1
                            ? '1 student'
                            : '${info.students} students',
                        if (info.invited > 0) '${info.invited} invited',
                        if (info.activeToday > 0)
                          '${info.activeToday} active today',
                      ].join('  ·  '),
                      style: TextStyle(fontSize: 12.5, color: kInkSoft),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: kInkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateClassDialog extends StatefulWidget {
  const CreateClassDialog({super.key});

  @override
  State<CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends State<CreateClassDialog> {
  final _name = TextEditingController();
  String? _course;
  List<CourseOption> _courses = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await QuestionRepository().listCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _course ??= courses.isEmpty ? null : courses.first.code;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_course == null) {
      setState(() => _error = 'Pick a course first.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ClassRepository().createClass(_name.text.trim(), _course!);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('New class', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Class name',
                helperText: 'Something you will recognise, like MHF4U P2',
              ),
            ),
            const SizedBox(height: 16),
            // A class teaches one COURSE. Enrolling a student sets their
            // course from it, which is how a tutor moves somebody between
            // courses without touching anything else.
            DropdownButtonFormField<String>(
              initialValue: _course,
              // isExpanded lets the item shrink to the field. Without it a
              // dropdown sizes itself to its widest child and pushes past
              // the dialog, which is what the overflow stripes were.
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Course'),
              items: _courses
                  .map((c) => DropdownMenuItem(
                        value: c.code,
                        // Code and grade only — the full course title is
                        // what made this too wide.
                        child: Text(
                          'Grade ${c.grade} — ${c.code}',
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _course = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              _Banner(message: _error!, colour: kWrong),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? 'Creating…' : 'Create'),
        ),
      ],
    );
  }
}

/// One class, opened.
class ClassDetail extends StatefulWidget {
  final ClassInfo info;

  const ClassDetail({super.key, required this.info});

  @override
  State<ClassDetail> createState() => _ClassDetailState();
}

class _ClassDetailState extends State<ClassDetail> {
  final _classes = ClassRepository();

  List<RosterEntry> _roster = [];
  List<UnitBreakdown> _topics = [];
  List<UnitMedalSummary> _summary = [];
  List<HardQuestion> _hard = [];
  bool _loading = true;
  String? _error;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final roster = await _classes.roster(widget.info.id);
      final topics = await _classes.unitBreakdown(widget.info.id);
      final summary = await _classes.unitSummary(widget.info.id);
      final hard = await _classes.hardQuestions(widget.info.id);
      if (!mounted) return;
      setState(() {
        _roster = roster;
        _topics = topics;
        _summary = summary;
        _hard = hard;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Retire the class. Deliberately worded as retiring rather than deleting,
  /// because that is what it does: the students keep every attempt, the
  /// notes stay written, and only the tutor's continuing sight of them ends.
  Future<void> _archive() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Archive this class?',
            style: TextStyle(fontSize: 17)),
        content: Text(
          'It stops appearing in your classes. Nothing is deleted — every '
          'student keeps their work, and the feedback you wrote stays with '
          'them.\n\nWhat does end is your view: after archiving you will no '
          'longer see the practice of the '
          '${_roster.length} ${_roster.length == 1 ? 'student' : 'students'} '
          'in it.',
          style: TextStyle(fontSize: 13.5, height: 1.55,
              color: kInkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;

    try {
      await _classes.archiveClass(widget.info.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Future<void> _invite() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => const InviteStudentDialog(),
    );
    if (email == null || !mounted) return;

    try {
      final message = await _classes.inviteStudent(widget.info.id, email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        surfaceTintColor: kSurface,
        elevation: 0,
        foregroundColor: kInk,
        title: Text(
          widget.info.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            color: kCard,
            tooltip: 'More',
            onSelected: (v) {
              if (v == 'archive') _archive();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'archive', child: Text('Archive class')),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _invite,
                      icon: const Icon(Icons.person_add_alt_1_rounded,
                          size: 17),
                      label: const Text('Invite'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SegmentedTabs(
                  labels: ['Students (${_roster.length})', 'Class progress'],
                  selected: _tab,
                  onSelect: (i) => setState(() => _tab = i),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(color: kAccent))
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: ErrorView(message: _error!, onRetry: _load),
                          )
                        : _tab == 0
                            ? _buildRoster()
                            : _buildClassProgress(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoster() {
    if (_roster.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: EmptyPrompt(
          message: 'Nobody has joined yet.\n\nRead the code out, or invite '
              'a student by email. An invitation shows them who is asking, '
              'and shows you nothing until they accept.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: _roster.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => RosterTile(
        entry: _roster[i],
        onOpen: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StudentReportScreen(entry: _roster[i]),
          ),
        ),
        onRemove: () async {
          await _classes.removeStudent(widget.info.id, _roster[i].studentId);
          _load();
        },
      ),
    );
  }

  /// Two halves, in the order a teacher plans in.
  ///
  /// First: which topics the class as a whole has not got, hardest at the
  /// top. That is what decides what to reteach on Monday.
  ///
  /// Then: the individual questions failing most widely, which is what you
  /// put on the board. Tapping one opens the actual question and the wrong
  /// answer most of them chose.
  Widget _buildClassProgress() {
    if (_topics.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: EmptyPrompt(
          message: 'Nothing to show yet.\n\nThis fills up as students '
              'practise, and it is the useful half of this screen.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        if (_summary.isNotEmpty) ...[
          const SectionLabel(
            title: 'HOW FAR THE CLASS HAS GOT',
            note: 'How many have finished each unit, and what they earned. '
                'This is the one that decides whether it is safe to move on.',
          ),
          ..._summary.map(
            (u) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: UnitSummaryRow(summary: u),
            ),
          ),
          const SizedBox(height: 26),
        ],
        const SectionLabel(
          title: 'TOPICS',
          note: 'Weakest first. The percentage is how often the class gets a '
              'question right on the first try.',
        ),
        ..._topics.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TopicRow(topic: t, classSize: _roster.length),
          ),
        ),
        const SizedBox(height: 26),
        const SectionLabel(
          title: 'QUESTIONS MOST GOT WRONG',
          note: 'Tap one to see the question and the answer most of them '
              'chose.',
        ),
        ..._hard.take(15).map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: HardQuestionRow(question: q),
              ),
            ),
      ],
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: kLine),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isOn = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: _motion(context),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isOn ? kAccentSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                    color: isOn ? kOnAccent : kInkSoft,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class RosterTile extends StatelessWidget {
  final RosterEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const RosterTile({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(13),
        child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(13),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // Seeded from the student id so the disc survives a name being
          // corrected, and so two students called Sam do not collide.
          PersonAvatar(
            name: entry.name,
            seed: entry.studentId,
            size: 34,
            photoPath: entry.avatarPath,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // The name, not the address. A roster is a list of people.
                  entry.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // A student who has vanished gets said plainly, because
                    // it is a different problem from a low score and needs a
                    // different response.
                    if (entry.isDrifting)
                      Text(
                        entry.lastSeen,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kHint,
                        ),
                      )
                    else
                      Text(
                        entry.lastSeen,
                        style: TextStyle(
                            fontSize: 12, color: kInkSoft),
                      ),
                    Text('  ·  ',
                        style: TextStyle(fontSize: 12, color: kInkSoft)),
                    // The percentage moved to the right-hand column below,
                    // where it can carry its band colour. Repeating it here
                    // would be the same fact twice in one row.
                    Text(
                      entry.questionsSeen == 0
                          ? 'no questions yet'
                          : '${entry.questionsSeen} questions',
                      style: TextStyle(fontSize: 12, color: kInkSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status, in the band palette — the one place on this tile where
          // colour is allowed to mean how well somebody is doing.
          if (entry.firstTryRate != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.firstTryRate}%',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: bandTextColour(bandForRate(entry.firstTryRate)),
                    ),
                  ),
                  Text('first try',
                      style: TextStyle(fontSize: 10, color: kInkSoft)),
                ],
              ),
            ),
          if (entry.unitsMedalled > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                children: [
                  MedalDot(
                    medal: entry.gold > 0 ? Medal.gold : Medal.bronze,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${entry.unitsMedalled}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                    ),
                  ),
                ],
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded,
                size: 20, color: kInkSoft),
            color: kCard,
            onSelected: (_) => onRemove(),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'remove',
                child: Text('Remove from class'),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String title;
  final String note;

  const SectionLabel({super.key, required this.title, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: kInkSoft.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Divider(height: 1, color: kLine)),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            note,
            style: TextStyle(fontSize: 12.5, height: 1.45,
                color: kInkSoft),
          ),
        ],
      ),
    );
  }
}

/// One unit, as completion rather than as a score.
///
/// Deliberately separate from TopicRow. That one answers "are they getting it
/// right"; this answers "have they done it at all". A unit can sit at 90%
/// first-try because two keen students finished it and nobody else opened it,
/// and only this row makes that visible.
class UnitSummaryRow extends StatelessWidget {
  final UnitMedalSummary summary;

  const UnitSummaryRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final done = summary.studentsDone;
    final total = summary.studentsTotal;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: kLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.unit,
                  style: TextStyle(fontSize: 14, color: kInk),
                ),
              ),
              Text(
                total == 0
                    ? 'no students'
                    : '$done of $total finished',
                style: TextStyle(fontSize: 12.5, color: kInkSoft),
              ),
            ],
          ),
          const SizedBox(height: 9),

          // Completion, not score. Neutral ink rather than the traffic
          // light, so it is never mistaken for the first-try bands.
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: summary.doneFraction.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: kLine,
              valueColor: AlwaysStoppedAnimation<Color>(kAccent),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              if (summary.medals == 0)
                Text('No medals yet',
                    style: TextStyle(fontSize: 12, color: kInkSoft))
              else ...[
                if (summary.gold > 0) ...[
                  const MedalDot(medal: Medal.gold, size: 11),
                  const SizedBox(width: 4),
                  Text('${summary.gold}',
                      style: TextStyle(fontSize: 12, color: kInkSoft)),
                  const SizedBox(width: 12),
                ],
                if (summary.silver > 0) ...[
                  const MedalDot(medal: Medal.silver, size: 11),
                  const SizedBox(width: 4),
                  Text('${summary.silver}',
                      style: TextStyle(fontSize: 12, color: kInkSoft)),
                  const SizedBox(width: 12),
                ],
                if (summary.bronze > 0) ...[
                  const MedalDot(medal: Medal.bronze, size: 11),
                  const SizedBox(width: 4),
                  Text('${summary.bronze}',
                      style: TextStyle(fontSize: 12, color: kInkSoft)),
                ],
              ],
              const Spacer(),
              if (summary.avgFirstTry != null)
                Text('${summary.avgFirstTry}% first try',
                    style: TextStyle(fontSize: 12, color: kInkSoft)),
            ],
          ),
        ],
      ),
    );
  }
}

/// One topic across the whole class.
///
/// The bar is the first-try rate, and it is coloured by how much trouble the
/// topic is causing rather than by a fixed threshold — a teacher scanning
/// this wants the weak ones to jump out, not a wall of green.
class TopicRow extends StatelessWidget {
  final UnitBreakdown topic;
  final int classSize;

  const TopicRow({super.key, required this.topic, required this.classSize});

  Color get _tone {
    final rate = topic.firstTryRate ?? 0;
    if (rate >= 70) return kAccent;
    if (rate >= 45) return kHint;
    return kWrong;
  }

  @override
  Widget build(BuildContext context) {
    final rate = topic.firstTryRate;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(13),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  topic.unit,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                rate == null ? '—' : '$rate%',
                style: TextStyle(
                  fontFamily: kSerif,
                  fontFamilyFallback: kSerifFallback,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: _tone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (rate ?? 0) / 100,
              minHeight: 5,
              backgroundColor: kLine,
              valueColor: AlwaysStoppedAnimation<Color>(_tone),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            [
              '${topic.studentsAttempted} of $classSize started',
              if (topic.studentsFinished > 0)
                '${topic.studentsFinished} finished',
              // The number that matters most: how many are actually stuck,
              // rather than an average that hides a split class.
              if (topic.studentsStruggling > 0)
                '${topic.studentsStruggling} struggling',
            ].join('  ·  '),
            style: TextStyle(fontSize: 12, color: kInkSoft),
          ),
          if (topic.topMistake != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.subdirectory_arrow_right_rounded,
                    size: 15, color: kInkSoft.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Most common slip: ${topic.topMistake}',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: kInkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One question the class is failing. Collapsed it is a headline; opened it
/// shows the question itself and the wrong answer most of them picked.
class HardQuestionRow extends StatefulWidget {
  final HardQuestion question;

  const HardQuestionRow({super.key, required this.question});

  @override
  State<HardQuestionRow> createState() => _HardQuestionRowState();
}

class _HardQuestionRowState extends State<HardQuestionRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return AnimatedContainer(
      duration: _motion(context),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(13),
        boxShadow: kCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: kWrong.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${q.studentsWrong} wrong',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: kWrong,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${q.unit}  ·  Q${q.sortOrder}  ·  ${q.difficulty}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: kInkSoft),
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: kInkSoft,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  q.prompt,
                  maxLines: _open ? null : 2,
                  overflow: _open ? null : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kSerif,
                    fontFamilyFallback: kSerifFallback,
                    fontSize: 15.5,
                    height: 1.45,
                    color: kInk,
                  ),
                ),

                if (_open) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                    decoration: BoxDecoration(
                      color: kWarmTint,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border(left: BorderSide(color: kHint, width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOST CHOSE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: kHint.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.topChoice ?? '—',
                          style: TextStyle(
                            fontFamily: kSerif,
                            fontFamilyFallback: kSerifFallback,
                            fontSize: 16,
                            color: kInk,
                          ),
                        ),
                        if (q.mistake != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'The mistake: ${q.mistake}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: kInk,
                            ),
                          ),
                        ],
                        if (q.topFeedback != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            // The feedback the student saw, so a teacher
                            // knows what has already been said to them and
                            // does not repeat it word for word.
                            q.topFeedback!,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: kInkSoft,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chosen ${q.timesWrong} times in total. The correct '
                    'answer is not shown here.',
                    style: TextStyle(fontSize: 11.5, color: kInkSoft),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One student, opened from the roster.
///
/// Deliberately laid out like the report a parent receives: the same
/// sections in the same order, so a teacher on a parents evening is looking
/// at the same picture the family already has.
class StudentReportScreen extends StatefulWidget {
  final RosterEntry entry;

  const StudentReportScreen({super.key, required this.entry});

  @override
  State<StudentReportScreen> createState() => _StudentReportScreenState();
}

class _StudentReportScreenState extends State<StudentReportScreen> {
  final _classes = ClassRepository();
  StudentOverview? _data;
  List<SubtopicDiagnostic> _subtopics = [];
  List<LevelDetail> _levels = [];
  List<TutorNote> _notes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _classes.studentOverview(widget.entry.studentId);
      final subs = await _classes.studentSubtopics(widget.entry.studentId);
      final levels = await _classes.studentDetail(widget.entry.studentId);
      final notes = await _classes.studentNotes(widget.entry.studentId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _subtopics = subs;
        _levels = levels;
        _notes = notes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    }
  }

  /// Move this student to another course. Their attempts are stored against
  /// the course they were sitting in, so nothing is lost — the old work is
  /// still there if they move back.
  Future<void> _changeCourse() async {
    final List<CourseOption> courses;
    try {
      courses = await QuestionRepository().listCourses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      return;
    }
    if (!mounted) return;

    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Move ${widget.entry.name.split(' ').first} to…',
            style: const TextStyle(fontSize: 16)),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: Text(
              'Their work in the old course is kept, not deleted. If they '
              'move back it is all still there.',
              style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
            ),
          ),
          for (final c in courses)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(c.code),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  'Grade ${c.grade} — ${c.title}  (${c.code})',
                  style: TextStyle(fontSize: 14.5, color: kInk),
                ),
              ),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;

    try {
      await _classes.setStudentCourse(widget.entry.studentId, chosen);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved to $chosen.')));
      setState(() {
        _data = null;
        _levels = [];
        _subtopics = [];
      });
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  /// Write feedback, optionally attached to one subtopic so it lands
  /// beside the thing it is about.
  Future<void> _writeNote({String? tag, String? label}) async {
    final body = await showDialog<String>(
      context: context,
      builder: (_) => WriteNoteDialog(
        studentName: widget.entry.name,
        subtopicLabel: label,
      ),
    );
    if (body == null || body.trim().isEmpty || !mounted) return;
    try {
      await _classes.writeNote(widget.entry.studentId, tag, body.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sent. They see it next time they open the app.')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Future<void> _deleteNote(TutorNote note) async {
    try {
      await _classes.deleteNote(note.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        surfaceTintColor: kSurface,
        elevation: 0,
        foregroundColor: kInk,
        title: Text(
          widget.entry.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            color: kCard,
            tooltip: 'More',
            onSelected: (v) {
              if (v == 'course') _changeCourse();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'course', child: Text('Change course')),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _error != null
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: ErrorView(message: _error!, onRetry: _load),
                )
              : _data == null
                  ? Center(
                      child: CircularProgressIndicator(color: kAccent))
                  : _buildReport(_data!),
        ),
      ),
    );
  }

  Widget _buildReport(StudentOverview d) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        Text(
          d.email,
          style: TextStyle(fontSize: 12.5, color: kInkSoft),
        ),
        const SizedBox(height: 3),
        Text(
          'Grade ${d.grade}',
          style: TextStyle(fontSize: 12.5, color: kInkSoft),
        ),
        const SizedBox(height: 20),

        // The one-line answer, in words, before any number. Same opening the
        // parent report uses.
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _summaryLine(d),
                style: TextStyle(
                  fontFamily: kSerif,
                  fontFamilyFallback: kSerifFallback,
                  fontSize: 17,
                  height: 1.55,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _stat('${d.questionsSeen}', 'questions'),
                  _stat(
                    d.firstTryRate == null ? '—' : '${d.firstTryRate}%',
                    'first try',
                  ),
                  _stat('${d.daysActive}', 'days'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        const SectionLabel(
          title: 'WHERE THE TIME WENT',
          note: 'Every unit touched, and how much of it landed first time.',
        ),
        ...d.units.map(
          (u) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14,
                  vertical: 12),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: kLine),
              ),
              child: Row(
                children: [
                  if (u.medal != Medal.none) ...[
                    MedalDot(medal: u.medal, size: 14),
                    const SizedBox(width: 9),
                  ],
                  Expanded(
                    child: Text(
                      u.unit,
                      style: TextStyle(fontSize: 14, color: kInk),
                    ),
                  ),
                  Text(
                    '${u.firstTry} of ${u.questions} first try',
                    style: TextStyle(fontSize: 12.5, color: kInkSoft),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (d.weakSpots.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: kWarmTint,
              borderRadius: BorderRadius.circular(13),
              border: Border(left: BorderSide(color: kHint, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHAT KEEPS TRIPPING THEM UP',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: kHint.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 12),
                ...d.weakSpots.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•  ',
                            style: TextStyle(fontSize: 14, color: kInk)),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: w.label,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                    color: kInk,
                                  ),
                                ),
                                TextSpan(
                                  text: '  (${w.unit}, ${w.times}×)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: kInkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These are habits rather than gaps in effort. Asking them '
                  'to talk one through out loud usually does more than '
                  'reteaching it.',
                  style: TextStyle(fontSize: 12.5, height: 1.5,
                      color: kInkSoft),
                ),
              ],
            ),
          ),
        ],

        // ---- the subtopic diagnosis: how well, and how much ----
        if (_subtopics.isNotEmpty) ...[
          const SizedBox(height: 26),
          const SectionLabel(
            title: 'TOPIC BY TOPIC',
            note: 'Two numbers per topic: how much of it they have done, '
                'and how much landed first time. A topic can be weak '
                'because it is hard, or invisible because it is being '
                'skipped — the second is easy to miss.',
          ),
          _BlindSpotCallout(
            subtopics: _subtopics,
            onWrite: (sub) =>
                _writeNote(tag: sub.tag, label: sub.label),
          ),
          ..._subtopics.map((sub) => SubtopicRow(
                sub: sub,
                onWrite: () => _writeNote(tag: sub.tag, label: sub.label),
              )),
        ],

        // ---- level by level: where inside a unit it stopped working ----
        if (_levels.isNotEmpty) ...[
          const SizedBox(height: 26),
          const SectionLabel(
            title: 'LEVEL BY LEVEL',
            note: 'Hardest first. A level with a medal but a lot of wrong '
                'taps was won the slow way, and is worth a second look '
                'before moving up.',
          ),
          ..._groupLevels(_levels).entries.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 6),
                        child: Text(
                          g.key,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                          ),
                        ),
                      ),
                      ...g.value.map((l) => LevelDetailRow(level: l)),
                    ],
                  ),
                ),
              ),
        ],

        // ---- feedback the tutor has written ----
        const SizedBox(height: 26),
        Row(
          children: [
            const Expanded(
              child: SectionLabel(
                title: 'FEEDBACK YOU HAVE SENT',
                note: 'They read this in the app, beside the topic it is '
                    'about.',
              ),
            ),
            TextButton.icon(
              onPressed: () => _writeNote(),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Write'),
            ),
          ],
        ),
        if (_notes.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              'Nothing yet. A sentence naming one habit beats a paragraph '
              'of encouragement.',
              style:
                  TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
            ),
          )
        else
          ..._notes.map((n) => TutorNoteCard(
                note: n,
                onDelete: n.mine ? () => _deleteNote(n) : null,
              )),

        const SizedBox(height: 20),
        Text(
          d.lastActive == null
              ? 'Has not opened the app yet.'
              : 'Last practised ${widget.entry.lastSeen}. '
                  '${d.wrongTaps} wrong taps in total, which is where the '
                  'learning happens — every one showed them the mistake '
                  'before the answer.',
          style: TextStyle(fontSize: 12.5, height: 1.55,
              color: kInkSoft),
        ),
      ],
    );
  }

  /// Group the level rows under their unit, keeping the order the server
  /// sent them in. The server sorts by where the trouble is, so the first
  /// unit to appear is the one to open the session with.
  Map<String, List<LevelDetail>> _groupLevels(List<LevelDetail> rows) {
    final out = <String, List<LevelDetail>>{};
    for (final r in rows) {
      out.putIfAbsent(r.unit, () => []).add(r);
    }
    return out;
  }

  /// Said in words, and never as praise the numbers do not support.
  String _summaryLine(StudentOverview d) {
    if (d.questionsSeen == 0) {
      return '${d.name} has not answered anything yet.';
    }
    final rate = d.firstTryRate ?? 0;
    final name = d.name.split(' ').first;
    if (rate >= 85) {
      return '$name is on top of this. ${d.questionsSeen} questions across '
          '${d.units.length} units, most of them right first time.';
    }
    if (rate >= 65) {
      return '$name is working steadily — ${d.questionsSeen} questions, and '
          'most land on the first try.';
    }
    if (rate >= 40) {
      return '$name is putting the work in, but a lot needs a second '
          'attempt. The pattern below is worth a look.';
    }
    return '$name is struggling with most of this. Worth sitting down '
        'together rather than sending more practice.';
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: kAccent,
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(fontSize: 11.5, color: kInkSoft)),
        ],
      ),
    );
  }
}

class InviteStudentDialog extends StatefulWidget {
  const InviteStudentDialog({super.key});

  @override
  State<InviteStudentDialog> createState() => _InviteStudentDialogState();
}

class _InviteStudentDialogState extends State<InviteStudentDialog> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Invite a student', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Their email address',
                helperText: 'They need an account already',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'They will see the invitation next time they open the app, '
              'along with your name. You will not see any of their work '
              'until they accept.',
              style: TextStyle(fontSize: 12.5, height: 1.45, color: kInkSoft),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_email.text.trim()),
          child: const Text('Send invitation'),
        ),
      ],
    );
  }
}

/// Postgres error messages arrive wrapped in exception noise. The message
/// itself is written to be read by a person, so dig it out.
String friendlyError(Object e) {
  final text = e.toString();
  final match = RegExp(r'message: ([^,]+)').firstMatch(text);
  if (match != null) return match.group(1)!;
  return text.replaceFirst('Exception: ', '');
}

/// The finding a tutor should read first: topics that are BOTH weak and
/// being steered around.
///
/// Worth its own box rather than a row in the list, because it is the one
/// thing a score-only dashboard structurally cannot tell you. Revising the
/// topics you are already good at feels like work and shows up as good
/// numbers; the avoided topic just goes quiet.
class _BlindSpotCallout extends StatelessWidget {
  final List<SubtopicDiagnostic> subtopics;
  final void Function(SubtopicDiagnostic) onWrite;

  const _BlindSpotCallout({required this.subtopics, required this.onWrite});

  @override
  Widget build(BuildContext context) {
    final blind = subtopics.where((s) => s.isBlindSpot).toList();
    final strong = subtopics.where((s) => s.isStrength).toList();
    if (blind.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: kWarmTint,
        borderRadius: BorderRadius.circular(13),
        border: Border(left: BorderSide(color: kHint, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORTH A CONVERSATION',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: kHint.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 14, height: 1.55, color: kInk),
              children: [
                const TextSpan(text: 'They are steering around '),
                TextSpan(
                  text: blind.map((b) => b.label.toLowerCase()).join(', '),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '.'),
                if (strong.isNotEmpty) ...[
                  const TextSpan(text: ' Meanwhile '),
                  TextSpan(
                    text: strong.first.label.toLowerCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' is done and solid at '
                        '${strong.first.firstTryRate}% first try.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Practising what already works is the most natural thing in the '
            'world, and it is why the hard topic stays hard. A session spent '
            'on the first list is worth three on the second.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final b in blind)
                OutlinedButton(
                  onPressed: () => onWrite(b),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  child: Text('Write about ${b.label.toLowerCase()}'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One subtopic row: a coverage bar and a first-try bar side by side, so
/// "hardly touched" and "touched and going badly" never look alike.
class SubtopicRow extends StatelessWidget {
  final SubtopicDiagnostic sub;
  final VoidCallback onWrite;

  const SubtopicRow({super.key, required this.sub, required this.onWrite});

  @override
  Widget build(BuildContext context) {
    final colour = bandColour(sub.band);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 11, 8, 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: sub.avoided ? kHint : kLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(color: colour, shape: BoxShape.circle),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    sub.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kInk),
                  ),
                ),
                if (sub.avoided)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: kWarmTint,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: kHint.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'being skipped',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: kHint.withValues(alpha: 0.95)),
                    ),
                  ),
                IconButton(
                  tooltip: 'Write feedback on this topic',
                  onPressed: onWrite,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.edit_note_rounded,
                      size: 19, color: kInkSoft),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniBar(
                      label: 'done',
                      value: sub.coveragePct,
                      caption:
                          '${sub.questionsSeen}/${sub.questionsTotal}',
                      colour: sub.avoided ? kHint : kInkSoft,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MiniBar(
                      label: 'first try',
                      value: sub.firstTryRate ?? 0,
                      caption: sub.firstTryRate == null
                          ? 'no data yet'
                          : '${sub.firstTryRate}% · '
                              '${bandWord(sub.band).toLowerCase()}',
                      colour: sub.firstTryRate == null
                          ? bandColour(Band.grey)
                          : colour,
                      empty: sub.firstTryRate == null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final int value;
  final String caption;
  final Color colour;
  final bool empty;

  const _MiniBar({
    required this.label,
    required this.value,
    required this.caption,
    required this.colour,
    this.empty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: kInkSoft)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 6, color: kTrack),
              if (!empty)
                FractionallySizedBox(
                  widthFactor: (value / 100).clamp(0.0, 1.0),
                  child: Container(height: 6, color: colour),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(caption,
            style: TextStyle(fontSize: 11, color: kInkSoft)),
      ],
    );
  }
}

/// One level of one unit on the student drill-down.
///
/// Three facts, in the order a tutor reads them: what they earned, how much
/// of it landed first time, and what it cost them in wrong taps. The mistake
/// line only appears when there is one, because a level with no repeated
/// mistake has nothing useful to say about itself.
class LevelDetailRow extends StatelessWidget {
  final LevelDetail level;

  const LevelDetailRow({super.key, required this.level});

  /// Untouched is not the same as failed, and must not look like it.
  static const _untouchedNote = 'not started';

  @override
  Widget build(BuildContext context) {
    final rate = level.total == 0
        ? 0
        : (level.bestFirstTry * 100 / level.total).round();

    // Earned the medal, but paid for it. Worth flagging: the medal ladder
    // rewards the best run, so a slow win and a clean win look identical
    // everywhere else in the app.
    final hardWon = level.medal != Medal.none && level.tapsPerQuestion >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  child: level.medal == Medal.none
                      ? null
                      : MedalDot(medal: level.medal, size: 13),
                ),
                SizedBox(
                  width: 78,
                  child: Text(
                    level.level,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: level.untouched ? kInkSoft : kInk,
                    ),
                  ),
                ),
                Expanded(
                  child: level.untouched
                      ? Text(
                          _untouchedNote,
                          style: TextStyle(fontSize: 12.5, color: kInkSoft),
                        )
                      : Text(
                          '${level.bestFirstTry} of ${level.total} '
                          'first try  ·  $rate%',
                          style: TextStyle(
                              fontSize: 12.5, color: kInkSoft),
                        ),
                ),
                if (!level.untouched)
                  Text(
                    level.wrongTaps == 0
                        ? 'clean'
                        : '${level.wrongTaps} wrong '
                            '${level.wrongTaps == 1 ? 'tap' : 'taps'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: level.wrongTaps == 0 ? kInkSoft : kHint,
                    ),
                  ),
              ],
            ),
            if (hardWon)
              Padding(
                padding: EdgeInsets.only(left: 20, top: 5),
                child: Text(
                  'Medal earned on a later run — the first pass was a '
                  'struggle.',
                  style: TextStyle(fontSize: 11.5, height: 1.4,
                      color: kInkSoft),
                ),
              ),
            if (level.topMistake != null && level.topMistake!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 5),
                child: Text(
                  'Mostly: ${level.topMistake}',
                  style: TextStyle(
                      fontSize: 11.5, height: 1.4, color: kInkSoft),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One piece of feedback. Shown to the tutor who wrote it and, in the same
/// shape, to the student receiving it.
class TutorNoteCard extends StatelessWidget {
  final TutorNote note;
  final VoidCallback? onDelete;

  /// The student's copy names the tutor; the tutor's copy names the topic
  /// and whether it has been read.
  final bool studentView;

  const TutorNoteCard({
    super.key,
    required this.note,
    this.onDelete,
    this.studentView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 13, 10, 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(11),
          border: Border(left: BorderSide(color: kAccent, width: 3)),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (note.label != null && note.label!.isNotEmpty) ...[
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: kWash,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        note.label!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kAccentDeep),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    studentView
                        ? 'from ${note.teacherEmail}'
                        : (note.seenAt != null ? 'read' : 'not read yet'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: kInkSoft),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close_rounded,
                        size: 17, color: kInkSoft),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.body,
              style: TextStyle(fontSize: 14, height: 1.55, color: kInk),
            ),
            const SizedBox(height: 6),
            Text(
              friendlyDate(note.createdAt),
              style: TextStyle(fontSize: 11, color: kInkSoft),
            ),
          ],
        ),
      ),
    );
  }
}

/// The student's view of tutor feedback: a quiet shelf on the way in.
///
/// Not a badge and not a red dot. Somebody who teaches them wrote something
/// — that deserves a line they can read at a glance and open if they want,
/// not an alert that has to be dismissed.
class TutorFeedbackShelf extends StatelessWidget {
  final List<TutorNote> notes;
  final VoidCallback onOpen;

  const TutorFeedbackShelf({
    super.key,
    required this.notes,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final unread = notes.where((n) => n.seenAt == null).length;
    final latest = notes.first;

    return Material(
      color: kWash,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 15, 14, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kAccent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mark_chat_read_rounded,
                      size: 17, color: kAccentDeep),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      unread > 0
                          ? (unread == 1
                              ? 'Your tutor left you a note'
                              : 'Your tutor left you $unread notes')
                          : 'Feedback from your tutor',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kAccentDeep),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: kAccentDeep),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                latest.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13.5, height: 1.5, color: kInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// All of it, in one scrollable place.
class TutorFeedbackDialog extends StatelessWidget {
  final List<TutorNote> notes;

  const TutorFeedbackDialog({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('From your tutor', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Written by the tutor who reviews your work. The topic tag '
                'says what each one is about.',
                style: TextStyle(
                    fontSize: 12.5, height: 1.5, color: kInkSoft),
              ),
              const SizedBox(height: 14),
              ...notes.map(
                  (n) => TutorNoteCard(note: n, studentView: true)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// The composer. Deliberately plain, with a nudge toward the kind of
/// feedback that actually helps: name one habit, say what to do next.
class WriteNoteDialog extends StatefulWidget {
  final String studentName;
  final String? subtopicLabel;

  const WriteNoteDialog({
    super.key,
    required this.studentName,
    this.subtopicLabel,
  });

  @override
  State<WriteNoteDialog> createState() => _WriteNoteDialogState();
}

class _WriteNoteDialogState extends State<WriteNoteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.subtopicLabel;
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        topic == null
            ? 'Feedback for ${widget.studentName}'
            : 'About $topic',
        style: const TextStyle(fontSize: 17),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic == null
                  ? 'They read this in the app. One specific thing beats '
                      'three general ones.'
                  : 'This lands beside $topic in their app, so it does not '
                      'have to repeat which topic it is about.',
              style: TextStyle(
                  fontSize: 12.5, height: 1.5, color: kInkSoft),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'Name the habit, then say what to try next. '
                    '"You are isolating y first even when x is easier — '
                    'try picking the variable with a coefficient of 1."',
                hintMaxLines: 4,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Send it'),
        ),
      ],
    );
  }
}

// ==========================================================================
// 7c. ADMIN PANEL
// ==========================================================================
//
// The whole operation on one screen, three tabs: Students, Tutors,
// Payments. This is the uncle's chair — see every student and their plan,
// onboard a tutor without touching SQL, put a paying student into a class,
// confirm an e-transfer against the bank.
//
// Everything here is display and plumbing. The power lives in the
// admin_* database functions, each of which re-checks is_admin() itself,
// so this screen appearing on the wrong account would show empty lists
// and errors, not data.

class AdminHome extends StatefulWidget {
  final AuthRepository auth;

  const AdminHome({super.key, required this.auth});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _admin = AdminRepository();

  List<AdminStudent> _students = [];
  List<AdminTeacher> _teachers = [];
  List<AdminClassRow> _classes = [];
  List<EtransferClaim> _claims = [];
  List<EnrolmentRequest> _enrolments = [];
  List<CourseOption> _courses = [];
  final _enrol = EnrolmentRepository();
  bool _loading = true;
  String? _error;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final students = await _admin.students();
      final teachers = await _admin.teachers();
      final classes = await _admin.classes();
      final claims = await _admin.etransfers();
      final courses = await QuestionRepository().listCourses();
      // Not fatal if this one fails: enrolment_links.sql may not be applied
      // on an older database, and the rest of the panel still works.
      var enrolments = <EnrolmentRequest>[];
      try {
        enrolments = await _enrol.adminList();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _students = students;
        _teachers = teachers;
        _classes = classes;
        _claims = claims;
        _enrolments = enrolments;
        _courses = courses;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- student actions ----

  Future<void> _assignToClass(AdminStudent s) async {
    if (_classes.isEmpty) {
      _toast('No classes yet. A tutor needs to create one first.');
      return;
    }
    final chosen = await showDialog<AdminClassRow>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Assign ${s.name} to…',
            style: const TextStyle(fontSize: 16)),
        children: _classes
            .map((c) => SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(c),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.name} · ${c.course}',
                            style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: kInk)),
                        Text(
                            '${c.teacherEmail} · ${c.students} '
                            '${c.students == 1 ? 'student' : 'students'}',
                            style: TextStyle(
                                fontSize: 12.5, color: kInkSoft)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
    if (chosen == null || !mounted) return;
    try {
      // Direct enrolment, same as a tutor adding their own student: the
      // class also settles the student's grade, which is how "move them to
      // grade 10" actually happens.
      _toast(await _admin.assignStudent(chosen.id, s.email));
      _load();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<void> _changeCourse(AdminStudent s) async {
    final course = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            Text('Course for ${s.name}', style: const TextStyle(fontSize: 16)),
        children: [
          for (final c in _courses)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(c.code),
              child: Text(
                'Grade ${c.grade} — ${c.label}'
                '${c.code == s.course ? '   (current)' : ''}',
                style: TextStyle(fontSize: 14.5, color: kInk),
              ),
            ),
        ],
      ),
    );
    if (course == null || course == s.course || !mounted) return;
    try {
      _toast(await _admin.setCourse(s.email, course));
      _load();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  /// Take a student out of a class. Two steps on purpose: pick which class
  /// (a student can be in more than one), then confirm — because the effect
  /// a tutor notices is that the student vanishes from their dashboard, and
  /// that should not happen from a single stray tap.
  Future<void> _removeFromClass(AdminStudent s) async {
    final List<AdminStudentClass> inClasses;
    try {
      inClasses = await _admin.studentClasses(s.id);
    } catch (e) {
      _toast(friendlyError(e));
      return;
    }
    if (!mounted) return;

    if (inClasses.isEmpty) {
      _toast('${s.name.split(' ').first} is not in any class.');
      return;
    }

    final chosen = inClasses.length == 1
        ? inClasses.first
        : await showDialog<AdminStudentClass>(
            context: context,
            builder: (context) => SimpleDialog(
              backgroundColor: kCard,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Remove ${s.name.split(' ').first} from…',
                  style: const TextStyle(fontSize: 16)),
              children: inClasses
                  .map((c) => SimpleDialogOption(
                        onPressed: () => Navigator.of(context).pop(c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${c.name} · ${c.course}',
                                  style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: kInk)),
                              Text(c.teacherEmail,
                                  style: TextStyle(
                                      fontSize: 12.5, color: kInkSoft)),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
    if (chosen == null || !mounted) return;

    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove from the class?',
            style: TextStyle(fontSize: 17)),
        content: Text(
          '${s.name} comes off the roster of ${chosen.name}, and '
          '${chosen.teacherEmail} stops being able to see their practice.'
          '\n\nNothing of the student\'s is deleted — their answers, medals '
          'and feedback all stay. They can be added back at any time.',
          style: TextStyle(fontSize: 13.5, height: 1.55,
              color: kInkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;

    try {
      await _admin.removeFromClass(chosen.classId, s.id);
      _toast('${s.name.split(' ').first} removed from ${chosen.name}.');
      _load();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<void> _sendReset(AdminStudent s) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send a password reset?',
            style: TextStyle(fontSize: 17)),
        content: Text(
          'This emails ${s.email} a link to choose a new password. '
          'Nobody — including you — ever sees the password itself.',
          style:
              TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send it'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      await widget.auth.sendPasswordReset(s.email);
      _toast('Reset email sent to ${s.email}.');
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  // ---- tutor actions ----

  Future<void> _addTutor() async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add a tutor', style: TextStyle(fontSize: 17)),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'They sign up as a normal account first; this upgrades it. '
                'A tutor can see the work of every student in their own '
                'classes — nobody else\'s.',
                style:
                    TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(labelText: 'Their email address'),
                onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Make them a tutor'),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty || !mounted) return;
    try {
      _toast(await _admin.makeTeacher(email));
      _load();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<void> _revokeTutor(AdminTeacher t) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove this tutor?',
            style: TextStyle(fontSize: 17)),
        content: Text(
          '${t.email} loses the dashboard immediately. Their classes and '
          'their students\' history stay, and can be reassigned.',
          style:
              TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Keep them'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kWrong),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      _toast(await _admin.revokeTeacher(t.userId));
      _load();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  /// Open one tutor's roster. Pushed rather than shown in a dialog because
  /// it is a list of unknown length that you read down, not a decision you
  /// answer and dismiss.
  void _openTutor(AdminTeacher t) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AdminTutorStudentsScreen(teacher: t),
    ));
  }

  // ---- payment actions ----

  Future<void> _decideClaim(EtransferClaim c, bool confirm) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(confirm ? 'Confirm this transfer?' : 'Reject this claim?',
            style: const TextStyle(fontSize: 17)),
        content: Text(
          confirm
              ? 'Only confirm after seeing the money in the bank account. '
                  'This unlocks Astro+ for ${c.name} '
                  '(${c.plan == 'annual' ? '12 months' : '1 month'}).'
              : 'Rejecting closes the claim without unlocking anything. '
                  '${c.name} sees it marked rejected.',
          style:
              TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Back'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: confirm ? kAccent : kWrong),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirm ? 'Money received — confirm' : 'Reject'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      final message = confirm
          ? await _admin.confirmEtransfer(c.id)
          : await _admin.rejectEtransfer(c.id, 'No transfer found');
      _toast(message);
      _load();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  // ---- build ----

  @override
  Widget build(BuildContext context) {
    final pending = _claims.where((c) => c.status == 'pending').length;
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        surfaceTintColor: kSurface,
        elevation: 0,
        foregroundColor: kInk,
        title: const Text('Admin',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          // The admin is usually also a tutor; this is the door to that hat.
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TeacherHome(auth: widget.auth))),
            icon: const Icon(Icons.co_present_rounded, size: 17),
            label: const Text('My classes'),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.auth.signOut,
            icon: const Icon(Icons.logout_rounded, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SegmentedTabs(
                  labels: [
                    'Students (${_students.length})',
                    'Tutors (${_teachers.length})',
                    pending > 0 ? 'Payments · $pending' : 'Payments',
                    _openEnrolments > 0
                        ? 'Astro+ · $_openEnrolments'
                        : 'Astro+',
                  ],
                  selected: _tab,
                  onSelect: (i) => setState(() => _tab = i),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(color: kAccent))
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child:
                                ErrorView(message: _error!, onRetry: _load),
                          )
                        : _buildTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Requests still waiting on somebody. 'new' has not been contacted;
  /// 'sent' has, and is waiting on the parent.
  int get _openEnrolments =>
      _enrolments.where((e) => e.status == 'new' || e.status == 'sent').length;

  Widget _buildTab() {
    switch (_tab) {
      case 0:
        return _buildStudents();
      case 1:
        return _buildTutors();
      case 2:
        return _buildPayments();
      default:
        return _buildEnrolments();
    }
  }

  /// The Astro+ queue: who has asked, who to contact, and the link to send
  /// them.
  ///
  /// The whole point of this tab is the link. Every function behind it has
  /// existed and been tested since August; what was missing was any way to
  /// get the pay_token out of the database, which is why there was no
  /// interface. See enrolment_links.sql.
  Widget _buildEnrolments() {
    if (_enrolments.isEmpty) {
      return const EmptyPrompt(
          message: 'No Astro+ requests.\n\nThey appear here when a student '
              'asks a parent to pay.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _enrolments.length,
      itemBuilder: (context, i) => _EnrolmentRow(
        request: _enrolments[i],
        onCopyLink: () => _copyEnrolmentLink(_enrolments[i]),
        onMark: (status) => _markEnrolment(_enrolments[i], status),
      ),
    );
  }

  Future<void> _copyEnrolmentLink(EnrolmentRequest r) async {
    try {
      final token = await _enrol.adminLink(r.requestId);
      final link = Uri.base.resolve('?pay=$token').toString();
      await Clipboard.setData(ClipboardData(text: link));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Link copied. Send it to ${r.parentEmail}.'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Future<void> _markEnrolment(EnrolmentRequest r, String status) async {
    try {
      await _enrol.adminMark(r.requestId, status);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Widget _buildStudents() {
    if (_students.isEmpty) {
      return const EmptyPrompt(
          message: 'No students yet.\n\nThey appear here as soon as they '
              'sign up.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _students.length,
      itemBuilder: (context, i) {
        final s = _students[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(13),
              boxShadow: kCardShadow,
            ),
            child: Row(
              children: [
                PersonAvatar(
                  name: s.name,
                  seed: s.id,
                  size: 34,
                  photoPath: s.avatarPath,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(s.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: kInk)),
                          ),
                          const SizedBox(width: 8),
                          _PlanBadge(student: s),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        [
                          s.email,
                          s.course.isEmpty ? 'Grade ${s.grade}' : s.course,
                          if (s.classes != null) s.classes!,
                          if (s.lastActive == null)
                            'never practised'
                        ].join('  ·  '),
                        style: TextStyle(
                            fontSize: 12.5, color: kInkSoft),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: kInkSoft, size: 20),
                  color: kCard,
                  onSelected: (v) {
                    switch (v) {
                      case 'assign':
                        _assignToClass(s);
                        break;
                      case 'course':
                        _changeCourse(s);
                        break;
                      case 'unassign':
                        _removeFromClass(s);
                        break;
                      case 'reset':
                        _sendReset(s);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'assign', child: Text('Assign to a class')),
                    if (s.classes != null)
                      const PopupMenuItem(
                          value: 'unassign',
                          child: Text('Remove from a class')),
                    const PopupMenuItem(
                        value: 'course', child: Text('Change course')),
                    const PopupMenuItem(
                        value: 'reset',
                        child: Text('Send password reset')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutors() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _addTutor,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
            label: const Text('Add tutor'),
          ),
        ),
        const SizedBox(height: 4),
        if (_teachers.isEmpty)
          const EmptyPrompt(message: 'No tutors yet.')
        else
          // The whole card is a door now. Before this a tutor row was a dead
          // end: it told you Uncle Dileep had 3 classes and 14 students, and
          // gave you no way to see who any of them were. The only route was
          // to open all forty students one at a time and read their classes.
          ..._teachers.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                // Shadow on the outer Container, ripple on the inner
                // Material: an Ink decoration cannot carry a boxShadow
                // without the splash clipping it away.
                child: Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: kCardShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () => _openTutor(t),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.email,
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: kInk)),
                                  const SizedBox(height: 3),
                                  Text(
                                    [
                                      t.role == 'admin' ? 'Admin' : 'Tutor',
                                      '${t.classCount} '
                                          '${t.classCount == 1 ? 'class' : 'classes'}',
                                      '${t.studentCount} '
                                          '${t.studentCount == 1 ? 'student' : 'students'}',
                                    ].join('  ·  '),
                                    style: TextStyle(
                                        fontSize: 12.5, color: kInkSoft),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: kInkSoft, size: 20),
                            if (t.role != 'admin')
                              IconButton(
                                tooltip: 'Remove tutor',
                                onPressed: () => _revokeTutor(t),
                                icon: Icon(Icons.person_remove_rounded,
                                    color: kInkSoft, size: 20),
                              )
                            else
                              const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildPayments() {
    if (_claims.isEmpty) {
      return const EmptyPrompt(
          message: 'No e-transfer claims yet.\n\nStripe payments confirm '
              'themselves and never appear here.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Check the bank account before confirming anything — a claim '
            'is a student saying they sent it, nothing more.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
        ),
        ..._claims.map((c) {
          final isPending = c.status == 'pending';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              decoration: BoxDecoration(
                color: isPending ? kWarmTint : kCard,
                borderRadius: BorderRadius.circular(13),
                boxShadow: kCardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${c.name} — '
                            '${c.plan == 'annual' ? '\$100 annual' : '\$10 monthly'}',
                            style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: kInk)),
                        const SizedBox(height: 3),
                        Text(
                          '${c.email}  ·  ${friendlyDate(c.createdAt)}'
                          '${isPending ? '' : '  ·  ${c.status}'}',
                          style: TextStyle(
                              fontSize: 12.5, color: kInkSoft),
                        ),
                      ],
                    ),
                  ),
                  if (isPending) ...[
                    TextButton(
                      style:
                          TextButton.styleFrom(foregroundColor: kInkSoft),
                      onPressed: () => _decideClaim(c, false),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => _decideClaim(c, true),
                      child: const Text('Confirm'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================================================
// 12b. ADMIN → ONE TUTOR'S STUDENTS
// ==========================================================================
//
// The admin panel could list tutors and could list students, but had no
// edge between them. This screen is that edge.
//
// It is deliberately read-only. Everything you might want to DO to a
// student — assign, move course, remove from a class, reset password —
// already lives on the Students tab, and duplicating those actions here
// would mean two places to keep honest. This screen answers one question:
// who does this person teach, and how are they getting on.
//
// Grouped by class rather than shown flat, because a tutor with three
// classes reads them as three groups, and because a student can sit in
// two of them — the same name appearing twice under different headings is
// correct and legible, where twice in one flat list looks like a bug.

class AdminTutorStudentsScreen extends StatefulWidget {
  final AdminTeacher teacher;

  const AdminTutorStudentsScreen({super.key, required this.teacher});

  @override
  State<AdminTutorStudentsScreen> createState() =>
      _AdminTutorStudentsScreenState();
}

class _AdminTutorStudentsScreenState extends State<AdminTutorStudentsScreen> {
  final _admin = AdminRepository();

  List<TeacherStudent> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _admin.teacherStudents(widget.teacher.userId);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _loading = false;
      });
    }
  }

  /// Preserves the order the SQL chose (class name, then quietest student
  /// first) instead of re-sorting here — the ordering is a deliberate part
  /// of that function and should not be silently overridden by the UI.
  List<MapEntry<String, List<TeacherStudent>>> get _byClass {
    final groups = <String, List<TeacherStudent>>{};
    for (final r in _rows) {
      groups.putIfAbsent('${r.className}  ·  ${r.course}', () => []).add(r);
    }
    return groups.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.teacher;
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        surfaceTintColor: kSurface,
        elevation: 0,
        foregroundColor: kInk,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            Text(t.role == 'admin' ? 'Admin' : 'Tutor',
                style: TextStyle(fontSize: 12, color: kInkSoft)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: _loading
              ? Center(child: CircularProgressIndicator(color: kAccent))
              : _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: ErrorView(message: _error!, onRetry: _load),
                    )
                  : _rows.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: EmptyPrompt(
                            message: t.classCount == 0
                                ? 'No classes yet.\n\nThis tutor has not '
                                    'created one, so there is nobody to show.'
                                : 'No students yet.\n\nThe classes exist, but '
                                    'either nobody has been invited or nobody '
                                    'has accepted the invitation.',
                          ),
                        )
                      : _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    final groups = _byClass;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        for (final g in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: unitTint(g.value.first.className),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    g.key.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: kInkSoft,
                    ),
                  ),
                ),
                Text(
                  '${g.value.length} '
                  '${g.value.length == 1 ? 'student' : 'students'}',
                  style: TextStyle(fontSize: 11.5, color: kInkSoft),
                ),
              ],
            ),
          ),
          ...g.value.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TutorStudentCard(student: s),
              )),
        ],
        const SizedBox(height: 18),
        Text(
          'Read-only. To move a student, change their course or reset a '
          'password, use the Students tab.',
          style: TextStyle(fontSize: 12, height: 1.5, color: kInkSoft),
        ),
      ],
    );
  }
}

/// One student inside one class.
///
/// The first-try rate is the number that matters, so it gets the band
/// colour and the right-hand slot. It is deliberately absent — not shown
/// as 0% — when the student has never answered anything: nought per cent
/// reads as "failing badly" when the truth is "has not started".
class _TutorStudentCard extends StatelessWidget {
  final TeacherStudent student;

  const _TutorStudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final s = student;
    final rate = s.firstTryRate;

    final facts = <String>[
      s.email,
      '${s.questionsSeen} '
          '${s.questionsSeen == 1 ? 'question' : 'questions'}',
      if (s.medals > 0) '${s.medals} ${s.medals == 1 ? 'medal' : 'medals'}',
      if (s.neverPractised)
        'never practised'
      else if (s.lastActive != null)
        'last ${friendlyDate(s.lastActive!)}',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(13),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          PersonAvatar(
            name: s.name,
            seed: s.studentId,
            size: 34,
            photoPath: s.avatarPath,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: kInk)),
                const SizedBox(height: 3),
                Text(
                  facts.join('  ·  '),
                  style: TextStyle(fontSize: 12.5, color: kInkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (rate == null)
            Text('—',
                style: TextStyle(fontSize: 15, color: kLine))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // bandTextColour, not bandColour: the fill palette is tuned
                // for dots and bars, and yellow at this size on white sits
                // around 2.3:1, well under the readable floor.
                Text('$rate%',
                    style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: bandTextColour(bandForRate(rate)))),
                Text('first try',
                    style: TextStyle(fontSize: 10.5, color: kInkSoft)),
              ],
            ),
        ],
      ),
    );
  }
}

/// '9 Mar 2026' — never '3/9/2026'. Canada reads numeric dates both ways,
/// and the admin panel is exactly where a wrong reading matters: matching
/// a bank transfer to a date, telling a parent when Astro+ ends.
String friendlyDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// The plan at a glance: green Astro+ chip, grey Free chip.
class _PlanBadge extends StatelessWidget {
  final AdminStudent student;

  const _PlanBadge({required this.student});

  @override
  Widget build(BuildContext context) {
    final on = student.premium;
    final label = on
        ? (student.periodEnd != null
            ? 'Astro+ to ${friendlyDate(student.periodEnd!)}'
            : 'Astro+')
        : 'Free';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: on ? kWash : kSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: on ? kAccent : kLine),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: on ? kAccentDeep : kInkSoft,
        ),
      ),
    );
  }
}

// ==========================================================================
// 8. WIDGETS
// ==========================================================================
//
// Presentational only. Each takes values and draws them; none of them
// remember anything or decide anything. Splitting the deciding (section 7)
// from the drawing (here) is the main structural idea in this file.
//
// House style, so the pieces below stay consistent:
//   - question prompts and big numbers in the serif, interface text in sans
//   - one strong colour (kAccent), used sparingly, never two at once
//   - soft shadow for depth, hairline only where an edge must be legible
//   - 12px radius on cards, 10px on controls, 999 on chips
//   - every state change animates through _motion so nothing snaps

/// Animation length, collapsing to zero when the operating system asks for
/// reduced motion. Every animated widget below goes through this.
Duration _motion(BuildContext context, [int ms = 180]) =>
    MediaQuery.maybeOf(context)?.disableAnimations == true
        ? Duration.zero
        : Duration(milliseconds: ms);

/// The one filled button in the app. Having a single definition is why the
/// sign-in button and the results button cannot drift apart.
class PrimaryButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.busy = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: kAccentSurface,
          disabledBackgroundColor: kAccentSurface.withValues(alpha: 0.45),
          foregroundColor: kOnAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            kAccentDeep.withValues(alpha: 0.35),
          ),
        ),
        child: busy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: kOnAccent,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

/// The three appearance choices, for the phone.
///
/// The same list the profile pane shows, in a sheet, because on a phone
/// there is no profile pane to put it in. Written once here and called from
/// both would be better; it is written twice because the pane's version has
/// to sit inside a card that already exists and a shared widget would have
/// to know about both, which is more indirection than two short lists are
/// worth.
Future<void> showAppearanceSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: kCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        Widget row(ThemeMode mode, IconData i, String label) {
          final on = kTheme.mode == mode;
          return ListTile(
            leading: Icon(i, color: on ? kAccent : kInkSoft),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: kInk,
              ),
            ),
            trailing: on ? Icon(Icons.check_rounded, color: kAccent) : null,
            onTap: () {
              kTheme.set(mode);
              ProfileRepository()
                  .saveThemePref(ThemeController.name(mode))
                  .catchError((Object _) {});
              setSheet(() {});
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 6),
              row(ThemeMode.light, Icons.light_mode_rounded, 'Light'),
              row(ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
              row(ThemeMode.system, Icons.brightness_auto_rounded,
                  'Match my device'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ),
  );
}

class AccountBar extends StatelessWidget {
  final String courseLabel;
  final int grade;
  final int classCount;

  /// Who this is, for the avatar. Passed in rather than read from Supabase
  /// here, because a widget that fetches its own data is a widget you cannot
  /// put on a screen twice.
  final String name;
  final String studentId;
  final String? avatarPath;
  final VoidCallback onChangePhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onOpenReport;
  final VoidCallback onResetProgress;
  final VoidCallback onOpenClasses;

  final VoidCallback onOpenAstro;

  final VoidCallback onSignOut;

  const AccountBar({
    super.key,
    required this.courseLabel,
    required this.grade,
    this.classCount = 0,
    required this.name,
    required this.studentId,
    this.avatarPath,
    required this.onChangePhoto,
    required this.onRemovePhoto,
    required this.onOpenReport,
    required this.onResetProgress,
    required this.onOpenClasses,

    required this.onOpenAstro,

    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // This slot used to hold the grade as a numeral. The line right
          // beside it already reads 'Grade 10', so the tile was saying the
          // same thing twice; the student's own face earns the space better.
          // Tapping it is the shortest route to changing it — the menu item
          // exists too, for anyone who does not think to try.
          Tooltip(
            message: avatarPath == null ? 'Add a photo' : 'Change your photo',
            child: InkWell(
              onTap: onChangePhoto,
              customBorder: const CircleBorder(),
              child: PersonAvatar(
                name: name,
                seed: studentId,
                size: 38,
                photoPath: avatarPath,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade $grade',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  // Being in a class is said on the front screen, not buried
                  // in a menu. A student should not have to go looking to
                  // find out that a teacher can see their work.
                  classCount == 0
                      ? courseLabel
                      : '$courseLabel  ·  in '
                          '${classCount == 1 ? '1 class' : '$classCount classes'}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: kInkSoft),
                ),
              ],
            ),
          ),
          // Change grade and reset are both rare and both destructive-ish,
          // so they sit behind a menu rather than tempting a stray tap.
          PopupMenuButton<String>(
            tooltip: 'Account',
            icon: Icon(Icons.more_horiz_rounded, color: kInkSoft),
            color: kCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              // A switch statement rather than a switch expression: these
              // arms return nothing, and an expression needs a value.
              switch (value) {
                case 'report':
                  onOpenReport();
                case 'classes':
                  onOpenClasses();
                case 'astro':
                  onOpenAstro();
                case 'appearance':
                  showAppearanceSheet(context);
                case 'photo':
                  onChangePhoto();
                case 'nophoto':
                  onRemovePhoto();
                case 'reset':
                  onResetProgress();
                default:
                  onSignOut();
              }
            },
            // No grade switch and no "I am a teacher" any more. The grade is
            // set by whoever enrols the student, because it decides which
            // question bank they see — a student who can change it at will
            // can dodge the work their tutor set. Teacher accounts are
            // granted by the admin, since a self-serve route into an account
            // that reads every classmate's marks is too much to hang on a
            // code typed into a box.
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'report', child: Text('My report')),
              const PopupMenuItem(value: 'classes', child: Text('My classes')),
              const PopupMenuItem(value: 'astro', child: Text('Astro+')),
              // The profile pane is wide-screen only, so without this entry
              // a student on a phone could not reach the setting at all —
              // and a phone in the dark is exactly who wants it most.
              const PopupMenuItem(
                  value: 'appearance', child: Text('Appearance')),
              PopupMenuItem(
                value: 'photo',
                child: Text(avatarPath == null
                    ? 'Add a photo'
                    : 'Change my photo'),
              ),
              // Only offered when there is something to remove. An item that
              // does nothing is worse than a missing one.
              if (avatarPath != null)
                const PopupMenuItem(
                  value: 'nophoto',
                  child: Text('Remove my photo'),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset my progress'),
              ),
              const PopupMenuItem(value: 'signout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
    );
  }
}

class UnitSelector extends StatelessWidget {
  final List<UnitSummary> units;
  final Map<String, UnitProgress> progress;
  final String? selected;
  final ValueChanged<String> onSelect;

  const UnitSelector({
    super.key,
    required this.units,
    required this.progress,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'UNITS',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: kInkSoft.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Divider(height: 1, color: kLine)),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: units.map((unit) {
            final isSelected = unit.name == selected;
            final p = progress[unit.name] ?? const UnitProgress();
            final done = p.solved.length;
            final complete = done >= unit.total && unit.total > 0;
            // Identity, not status — see kUnitTints. The chip is this colour
            // on the student's first day and on their last.
            final tint = unitTint(unit.name);

            return AnimatedContainer(
              duration: _motion(context),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                // Selected fills with the unit's own colour rather than the
                // house teal. Only one chip is ever filled, so "which one am
                // I on" stays unmistakable, and the row stops being eight
                // identical white pills.
                color: isSelected ? tint : tint.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected ? kCardShadow : null,
                border: Border.all(
                    color: isSelected ? tint : tint.withValues(alpha: 0.28)),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => onSelect(unit.name),
                  borderRadius: BorderRadius.circular(999),
                  hoverColor: isSelected
                      ? Colors.white.withValues(alpha: 0.10)
                      : tint.withValues(alpha: 0.10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // A monogram tile sat here for a while. Cut: a unit
                        // is named in full on the chip already, so the letter
                        // was repeating the first character of a word that
                        // was right beside it. The colour does the work of
                        // making the row scannable without the noise.
                        if (p.medal != Medal.none) ...[
                          MedalDot(medal: p.medal, size: 13),
                          const SizedBox(width: 7),
                        ],
                        Text(
                          unit.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : kInk,
                          ),
                        ),
                        // Part-finished units say how far in they are. A
                        // finished one does not need a counter, and an
                        // untouched one has nothing to report.
                        if (done > 0 && !complete) ...[
                          const SizedBox(width: 7),
                          Text(
                            '$done/${unit.total}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : kInkSoft,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Someone's initials in a coloured disc — the thing every roster in the
/// world has and this one did not.
///
/// A class list was twelve identical white cards distinguishable only by
/// reading the name on each. A tutor scanning for one student had to read
/// all twelve. Initials and a stable colour turn that into recognition.
///
/// The colour is seeded from the student ID, not the name, so it survives a
/// student correcting the spelling of their own name — and two students
/// called Sam do not end up with the same disc.
class PersonAvatar extends StatelessWidget {
  final String name;
  final String seed;
  final double size;

  /// Path in the private avatars bucket, if this person has set a photo.
  /// Initials are not a placeholder waiting for a photo — most people will
  /// never set one, and the lettered disc is the finished state for them.
  final String? photoPath;

  const PersonAvatar({
    super.key,
    required this.name,
    required this.seed,
    this.size = 34,
    this.photoPath,
  });

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    // First and LAST, not first and second: 'Ana Maria Rodrigues' is
    // AR to everyone who knows her, not AM.
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _lettered() {
    final i = tintIndex(seed);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // A circle for a person, a rounded square for a unit. The shapes are
        // never explained anywhere and never need to be — they just stop the
        // two kinds of tile from being mistaken for each other.
        color: kUnitTints[i].withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials(name),
        style: TextStyle(
          fontSize: size * 0.38,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: kUnitTintsDeep[i],
        ),
      ),
    );
  }

  Widget _photo(String url) => ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // A signed URL that has expired, a photo deleted straight out of
          // the bucket, a flaky connection: all of them land here, and all of
          // them should look like somebody who never set a photo rather than
          // like a broken app.
          errorBuilder: (_, _, _) => _lettered(),
          // The letters stand in while the bytes arrive, so a roster never
          // shows a row of grey holes.
          frameBuilder: (_, child, frame, wasSyncLoaded) =>
              (wasSyncLoaded || frame != null) ? child : _lettered(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    if (path == null) return _lettered();

    // Already signed — the common case once a list has prefetched — so this
    // paints in the same frame as everything around it.
    final ready = AvatarUrls.cached(path);
    if (ready != null) return _photo(ready);

    return FutureBuilder<String?>(
      future: AvatarUrls.url(path),
      builder: (_, snap) =>
          snap.data == null ? _lettered() : _photo(snap.data!),
    );
  }
}

/// The medal itself: a small filled disc. Colour alone would fail anyone who
/// cannot distinguish gold from bronze, so the shape carries a letter too.
class MedalDot extends StatelessWidget {
  final Medal medal;
  final double size;

  const MedalDot({super.key, required this.medal, this.size = 16});

  static const Color _gold = Color(0xFFC79A2E);
  static const Color _silver = Color(0xFF9099A0);
  static const Color _bronze = Color(0xFFB07348);

  Color get colour => switch (medal) {
        Medal.gold => _gold,
        Medal.silver => _silver,
        Medal.bronze => _bronze,
        Medal.none => kLine,
      };

  String get letter => switch (medal) {
        Medal.gold => 'G',
        Medal.silver => 'S',
        Medal.bronze => 'B',
        Medal.none => '',
      };

  String get label => switch (medal) {
        Medal.gold => 'Gold',
        Medal.silver => 'Silver',
        Medal.bronze => 'Bronze',
        Medal.none => 'Not yet earned',
      };

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colour,
          shape: BoxShape.circle,
          border: Border.all(color: kCard.withValues(alpha: 0.55)),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: size * 0.58,
              height: 1,
              fontWeight: FontWeight.w800,
              color: kCard,
            ),
          ),
        ),
      ),
    );
  }
}

/// A one-line summary of the whole grade, sitting above the chips.
///
/// Kept deliberately quiet: a count and a row of medals, no percentage and no
/// rank. The medals are the reward; this is only a place to see them together.
class MasteryHeader extends StatelessWidget {
  final List<UnitSummary> units;
  final Map<String, UnitProgress> progress;

  const MasteryHeader({
    super.key,
    required this.units,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    var earned = 0;
    var gold = 0;
    for (final unit in units) {
      final medal = progress[unit.name]?.medal ?? Medal.none;
      if (medal != Medal.none) earned++;
      if (medal == Medal.gold) gold++;
    }

    // 'No units finished yet' was accurate and slightly grim as the first
    // line a new student reads. It is now phrased as the thing that is about
    // to happen rather than the thing that has not.
    final label = earned == 0
        ? 'Your first medal is one finished unit away'
        : '$earned of ${units.length} units earned a medal';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        // A whisper of the house colour rather than flat white — enough that
        // the strip reads as a header and not as another card in the stack.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAccent.withValues(alpha: 0.10),
            kAccent.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: kAccent.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
                if (gold > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    gold == units.length
                        ? 'Every one of them Gold.'
                        : '$gold at Gold.',
                    style: TextStyle(fontSize: 12, color: kInkSoft),
                  ),
                ],
              ],
            ),
          ),
          // One slot per unit, in the order the chips appear, so the row
          // doubles as a map of which units are still outstanding.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: units.map((unit) {
              final medal = progress[unit.name]?.medal ?? Medal.none;
              return Padding(
                padding: const EdgeInsets.only(left: 5),
                child: medal == Medal.none
                    ? Tooltip(
                        message: unit.name,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kLine, width: 1.5),
                          ),
                        ),
                      )
                    : MedalDot(medal: medal, size: 14),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Units finished at Bronze, offered back without any scolding.
///
/// This is the part of the gamification that actually teaches: a medal says
/// how you did, but this says where to go next, and it points at the units
/// whose feedback the student has the most left to get out of.
class RevisitShelf extends StatelessWidget {
  final List<UnitSummary> units;
  final ValueChanged<String> onSelect;

  const RevisitShelf({
    super.key,
    required this.units,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: kHint.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(13),
        border: Border(left: BorderSide(color: kHint, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            units.length == 1
                ? 'One unit worth another look'
                : '${units.length} units worth another look',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: kHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You finished these, but a few took more than one try.',
            style: TextStyle(fontSize: 12.5, height: 1.4, color: kInkSoft),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: units.map((unit) {
              return Material(
                color: kCard,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => onSelect(unit.name),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: kHint.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          unit.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: kHint,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// The card that means a student never has to remember where they were.
class ResumeCard extends StatelessWidget {
  final UnitSummary unit;
  final UnitProgress progress;
  final VoidCallback onContinue;

  const ResumeCard({
    super.key,
    required this.unit,
    required this.progress,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final done = progress.solved.length;
    final left = unit.total - done;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: kAccentSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PICK UP WHERE YOU LEFT OFF',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: kCard.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            unit.name,
            style: TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: kCard,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            left == 1 ? '1 question left' : '$left questions left',
            style: TextStyle(
              fontSize: 13.5,
              color: kCard.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: unit.total == 0 ? 0 : done / unit.total,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                // On the accent-filled card, so this is the inverse pair:
                // the page's "on accent" colour as the fill, and the filled
                // surface's own colour as the label. kAccent here would be
                // the light teal in the dark theme, on white, at 2.4:1.
                backgroundColor: kOnAccent,
                foregroundColor: kAccentSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A class invitation, shown on the front screen rather than in a menu.
class InvitationCard extends StatelessWidget {
  final StudentClass invite;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationCard({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: kCardShadow,
        border: Border(left: BorderSide(color: kAccent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitation to join ${invite.name}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${invite.teacherEmail} is asking you to join. If you accept, '
            'they will be able to see which units you have done and which '
            'questions you find hard. They cannot see anything yet.',
            style: TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccentSurface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: onDecline,
                  child: const Text('No thanks'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Who can see this student's work, and the way out.
class MyClassesDialog extends StatefulWidget {
  final List<StudentClass> classes;
  final Future<void> Function(int classId) onLeave;

  const MyClassesDialog({
    super.key,
    required this.classes,
    required this.onLeave,
  });

  @override
  State<MyClassesDialog> createState() => _MyClassesDialogState();
}

class _MyClassesDialogState extends State<MyClassesDialog> {
  late List<StudentClass> _list;
  String? _message;

  @override
  void initState() {
    super.initState();
    _list = widget.classes.where((c) => !c.isInvitation).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('My classes', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_list.isEmpty)
              Text(
                'You are not in any class, so nobody can see your work '
                'except you.',
                style: TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
              )
            else ...[
              Text(
                'These teachers can see which units you have done and which '
                'questions you find hard. They cannot see your password or '
                'anything outside this app.',
                style: TextStyle(fontSize: 12.5, height: 1.45, color: kInkSoft),
              ),
              const SizedBox(height: 12),
              ..._list.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kInk,
                              ),
                            ),
                            Text(
                              c.teacherEmail,
                              style: TextStyle(
                                  fontSize: 12, color: kInkSoft),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await widget.onLeave(c.classId);
                          if (!mounted) return;
                          setState(() => _list.remove(c));
                        },
                        style: TextButton.styleFrom(foregroundColor: kWrong),
                        child: const Text('Leave'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Your tutor adds you to a class. If you should be in one and '
              'are not, ask them.',
              style: TextStyle(fontSize: 12, height: 1.45, color: kInkSoft),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              _Banner(message: _message!, colour: kAccent),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// The four levels of one unit. This is the screen where the free/paid line
/// is visible, so it carries the honesty work: locked levels show what they
/// contain and what unlocking costs in plain words, rather than hiding.
class LevelPicker extends StatelessWidget {
  final String unit;
  final List<LevelInfo> levels;
  final void Function(LevelInfo) onSelect;
  final VoidCallback onBack;

  const LevelPicker({
    super.key,
    required this.unit,
    required this.levels,
    required this.onSelect,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_rounded,
                  size: 20, color: kInkSoft),
            ),
            // The unit's colour carries through from the chip you tapped —
            // in the title itself rather than in a tile beside it, so the
            // continuity is there without another object on the screen.
            Expanded(
              child: Text(
                unit,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kSerif,
                  fontFamilyFallback: kSerifFallback,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: kUnitTintsDeep[tintIndex(unit)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (levels.isEmpty)
          const EmptyPrompt(
              message: 'No questions in this unit yet — new material is on '
                  'its way.')
        else
          ...levels.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LevelCard(
                  info: l,
                  unit: unit,
                  onTap: () => onSelect(l),
                ),
              )),
      ],
    );
  }
}

class LevelCard extends StatelessWidget {
  final LevelInfo info;

  /// Only used for colour. Optional so nothing that already builds a
  /// LevelCard without it breaks.
  final String? unit;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.info,
    this.unit,
    required this.onTap,
  });

  /// How many of the four rungs this level fills. The four names were doing
  /// all the work of conveying an order, and 'Challenge' before 'Advanced'
  /// is not obvious to a fourteen-year-old the first time they see it. Four
  /// little bars say it without a word.
  static const _rungs = {
    'Easy': 1,
    'Medium': 2,
    'Challenge': 3,
    'Advanced': 4,
  };

  @override
  Widget build(BuildContext context) {
    final done = info.finished;
    final tint = unit == null ? kAccent : unitTint(unit!);
    final filled = _rungs[info.level] ?? 1;

    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: kCardShadow,
          ),
          // Clipped so the coloured rail can run the full height of the card
          // and still take the corner radius with it.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The rail deepens with the level, so the four cards read
                  // as a ramp at a glance. A locked level keeps the shape and
                  // loses the saturation — visibly the same thing, not yet
                  // available, which is the honest picture.
                  Container(
                    width: 5,
                    // 0.42 → 0.95 across the four rungs. Deliberately not
                    // 0.30 + 0.20 * filled, which reaches 1.10 on Advanced
                    // and trips the alpha assertion.
                    color: info.locked
                        ? kLine
                        : tint.withValues(alpha: 0.245 + 0.175 * filled),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 16, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      info.level,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: kInk,
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    _DifficultyRungs(
                                      filled: filled,
                                      colour: info.locked ? kInkSoft : tint,
                                    ),
                                    if (info.locked) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.lock_rounded,
                                          size: 14,
                                          color: kInkSoft.withValues(
                                              alpha: 0.8)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  info.locked
                                      ? '${info.total} questions with Astro+'
                                      : done
                                          ? '${info.total} of ${info.total} '
                                              'answered'
                                          : info.solved > 0
                                              ? '${info.solved} of '
                                                  '${info.total} answered'
                                              : '${info.total} questions',
                                  style: TextStyle(
                                      fontSize: 12.5, color: kInkSoft),
                                ),
                              ],
                            ),
                          ),
                          if (info.medal != Medal.none) ...[
                            MedalDot(medal: info.medal, size: 18),
                            const SizedBox(width: 10),
                          ],
                          Icon(Icons.chevron_right_rounded,
                              color: kInkSoft),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Four rungs, of which [filled] are solid. Never the only signal — the
/// level's name is right beside it — so nobody has to read the bars, and
/// anyone who cannot tell the colours apart still has the word.
class _DifficultyRungs extends StatelessWidget {
  final int filled;
  final Color colour;

  const _DifficultyRungs({required this.filled, required this.colour});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // Bottom-aligned, so the rungs climb from a shared baseline instead of
      // fanning out from the middle.
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final on = i < filled;
        return Padding(
          padding: const EdgeInsets.only(right: 2.5),
          child: Container(
            width: 3.5,
            // Rungs climb, so the shape says "more" even in greyscale.
            height: 6.0 + i * 2.0,
            decoration: BoxDecoration(
              color: on ? colour : colour.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// The Astro+ ask. Two things this dialog refuses to do: pretend the student
/// is the customer, and take a card number. The words are aimed at the adult
/// in the room, and the button leads to Stripe, so no payment detail ever
/// touches this app.
/// The Astro+ ask. Returns what the family chose:
/// 'stripe-monthly' | 'stripe-annual' | 'etransfer' | 'support' | null.
///
/// Two plans, two ways to pay, one door to a human. Every path is worded at
/// the adult — the users are minors, minors cannot form contracts, and both
/// the card page and the bank transfer belong to a parent.
/// The Astro+ enrolment form: a student asks, a parent pays.
///
/// This is the other half of Astro+, and until now it was server-only. The
/// existing plan tiles are the STUDENT paying, on their own card, right
/// now. This is the case the product is actually for — a fourteen-year-old
/// who wants Challenge unlocked and has no card, and a parent who does.
///
/// Nothing here charges anything. It records a request, and hands back a
/// link the parent opens to pay.
/// One request in the admin's Astro+ queue.
class _EnrolmentRow extends StatelessWidget {
  final EnrolmentRequest request;
  final VoidCallback onCopyLink;
  final ValueChanged<String> onMark;

  const _EnrolmentRow({
    required this.request,
    required this.onCopyLink,
    required this.onMark,
  });

  /// Status as a word and a colour. Reusing the band palette rather than
  /// inventing a fourth colour language: grey is waiting, yellow is with
  /// the parent, green is done, orange is off.
  (String, Color) get _badge => switch (request.status) {
        'paid' => ('Paid', bandColour(Band.green)),
        'sent' => ('With the parent', bandColour(Band.yellow)),
        'cancelled' => ('Cancelled', bandColour(Band.orange)),
        _ => ('New', bandColour(Band.grey)),
      };

  @override
  Widget build(BuildContext context) {
    final (word, colour) = _badge;
    final open = request.status == 'new' || request.status == 'sent';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kLine),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.studentName,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: kInk),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: colour.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: bandTextColour(switch (request.status) {
                          'paid' => Band.green,
                          'sent' => Band.yellow,
                          'cancelled' => Band.orange,
                          _ => Band.grey,
                        })),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'Grade ${request.grade} · ${request.schoolBoard}'
              '${request.school == null ? '' : ' · ${request.school}'}',
              style: TextStyle(fontSize: 12, color: kInkSoft),
            ),
            const SizedBox(height: 10),
            Text(
              '${request.parentName} · ${request.parentEmail}'
              '${request.parentPhone == null ? '' : ' · ${request.parentPhone}'}',
              style: TextStyle(fontSize: 12.5, height: 1.4, color: kInk),
            ),
            const SizedBox(height: 3),
            Text(
              '${request.plan == 'annual' ? 'Yearly' : 'Monthly'} · '
              '${request.method == 'etransfer' ? 'e-transfer' : 'card'}',
              style: TextStyle(fontSize: 12, color: kInkSoft),
            ),
            if (open) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: onCopyLink,
                    icon: const Icon(Icons.link_rounded, size: 16),
                    label: const Text('Copy their link'),
                    style: TextButton.styleFrom(foregroundColor: kAccentDeep),
                  ),
                  if (request.status == 'new')
                    TextButton(
                      onPressed: () => onMark('sent'),
                      child: const Text('Mark as sent'),
                    ),
                  TextButton(
                    onPressed: () => onMark('paid'),
                    child: const Text('Mark as paid'),
                  ),
                  TextButton(
                    onPressed: () => onMark('cancelled'),
                    style: TextButton.styleFrom(foregroundColor: kInkSoft),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AstroPlusEnrolmentSheet extends StatefulWidget {
  final String studentName;
  final int grade;

  const AstroPlusEnrolmentSheet({
    super.key,
    required this.studentName,
    required this.grade,
  });

  @override
  State<AstroPlusEnrolmentSheet> createState() =>
      _AstroPlusEnrolmentSheetState();
}

class _AstroPlusEnrolmentSheetState extends State<AstroPlusEnrolmentSheet> {
  final _repo = EnrolmentRepository();
  final _board = TextEditingController();
  final _school = TextEditingController();
  final _parentName = TextEditingController();
  final _parentEmail = TextEditingController();
  final _parentPhone = TextEditingController();

  String _plan = 'monthly';
  String _method = 'stripe';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _board.dispose();
    _school.dispose();
    _parentName.dispose();
    _parentEmail.dispose();
    _parentPhone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final board = _board.text.trim();
    final parentName = _parentName.text.trim();
    final parentEmail = _parentEmail.text.trim();

    // Checked here so the student is told which field, rather than being
    // handed whatever Postgres says about a not-null constraint.
    if (board.isEmpty) {
      setState(() => _error = 'Which school board are you in?');
      return;
    }
    if (parentName.length < 2) {
      setState(() => _error = 'Your parent or guardian\'s name, please.');
      return;
    }
    if (!parentEmail.contains('@') || parentEmail.length < 5) {
      setState(() => _error = 'That does not look like an email address.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.request(
        studentName: widget.studentName,
        grade: widget.grade,
        schoolBoard: board,
        school: _school.text.trim().isEmpty ? null : _school.text.trim(),
        parentName: parentName,
        parentEmail: parentEmail,
        parentPhone:
            _parentPhone.text.trim().isEmpty ? null : _parentPhone.text.trim(),
        plan: _plan,
        method: _method,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _busy = false;
      });
    }
  }

  Widget _choice(String value, String group, String label, String hint,
      ValueChanged<String> onPick) {
    final on = value == group;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: on ? kWash : kCard,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => onPick(value),
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: on ? kAccent : kLine, width: on ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(
                    on
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: on ? kAccent : kInkSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: kInk)),
                      Text(hint,
                          style: TextStyle(fontSize: 12, color: kInkSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Ask a parent to pay', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We will make a link for them. Nothing is charged until they '
                'open it and choose to pay.',
                style: TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _board,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'School board',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _school,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'School (optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 18),
              Text('Your parent or guardian',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: kInkSoft)),
              const SizedBox(height: 8),
              TextField(
                controller: _parentName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Their name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _parentEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Their email',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _parentPhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Their phone (optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 18),
              Text('Plan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: kInkSoft)),
              const SizedBox(height: 8),
              _choice('monthly', _plan, 'Monthly — \$10 CAD',
                  'Cancel any time.', (v) => setState(() => _plan = v)),
              _choice('annual', _plan, 'Yearly — \$100 CAD',
                  'Two months free.', (v) => setState(() => _plan = v)),
              const SizedBox(height: 10),
              Text('How they would like to pay',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: kInkSoft)),
              const SizedBox(height: 8),
              _choice('stripe', _method, 'Card', 'Handled by Stripe.',
                  (v) => setState(() => _method = v)),
              _choice('etransfer', _method, 'Interac e-transfer',
                  'From their own banking app.',
                  (v) => setState(() => _method = v)),
              if (_error != null) ...[
                const SizedBox(height: 14),
                _Banner(message: _error!, colour: kWrong),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Not now'),
        ),
        TextButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? 'Sending…' : 'Make the link'),
        ),
      ],
    );
  }
}

/// The page a parent lands on. No account, no sign-in — the token in the
/// URL is the whole of their visit, exactly as it is for a shared report
/// and for guardian consent.
class EnrolmentPaymentScreen extends StatefulWidget {
  final String token;

  const EnrolmentPaymentScreen({super.key, required this.token});

  @override
  State<EnrolmentPaymentScreen> createState() => _EnrolmentPaymentScreenState();
}

class _EnrolmentPaymentScreenState extends State<EnrolmentPaymentScreen> {
  final _repo = EnrolmentRepository();
  EnrolmentInvite? _invite;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final invite = await _repo.byToken(widget.token);
      if (!mounted) return;
      setState(() {
        _invite = invite;
        // Vague on purpose. An unknown token must not be distinguishable
        // from a cancelled one, or the page becomes a way to test tokens.
        _error = invite == null ? 'This link is not valid any more.' : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'This link is not valid any more.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invite = _invite;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 90),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        const Center(child: BrandBadge(size: 56)),
                        const SizedBox(height: 20),
                        Text(
                          _error != null ? 'Sorry' : 'Astro+ for ${invite!.studentFirst}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kSerif,
                            fontFamilyFallback: kSerifFallback,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_error != null)
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.6,
                                  color: kInkSoft))
                        else ...[
                          Text(
                            invite!.status == 'paid'
                                ? 'This is already paid for. There is nothing '
                                    'left to do, and you will not be charged '
                                    'again by opening this link.'
                                : 'Astro+ unlocks the Challenge and Advanced '
                                    'levels, and a tutor who reviews their '
                                    'work. Easy and Medium are free forever, '
                                    'and every medal they have earned stays '
                                    'theirs either way.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14.5, height: 1.6, color: kInkSoft),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
                            decoration: BoxDecoration(
                              color: kTrack,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  invite.plan == 'annual'
                                      ? 'Yearly — \$100 CAD'
                                      : 'Monthly — \$10 CAD',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: kInk),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  invite.method == 'etransfer'
                                      ? 'By Interac e-transfer'
                                      : 'By card',
                                  style: TextStyle(
                                      fontSize: 13, color: kInkSoft),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (invite.status != 'paid')
                            // No checkout button here on purpose. Starting a
                            // Stripe session needs a signed-in student id,
                            // and this page has no session — so the honest
                            // thing is to tell the parent how it actually
                            // works today rather than show a button that
                            // cannot complete.
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 16, 15),
                              decoration: BoxDecoration(
                                color: kWarmTint,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color: kHint.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                invite.method == 'etransfer'
                                    ? 'Send the amount above by Interac '
                                        'e-transfer to stemlabs.ca@gmail.com, '
                                        'putting ${invite.studentFirst}\'s name '
                                        'in the message. We confirm it by hand, '
                                        'usually within a day.'
                                    : 'We will email you a card payment link '
                                        'from stemlabs.ca@gmail.com. If you '
                                        'would rather not wait, reply to that '
                                        'address and we will call you.',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.55,
                                    color: kInk),
                              ),
                            ),
                        ],
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => launchUrl(
                            Uri.parse('mailto:stemlabs.ca@gmail.com'
                                '?subject=Astro%2B'),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: const Text('Email us a question'),
                        ),
                        const SizedBox(height: 8),
                        const LegalLinks(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AstroPlusDialog extends StatelessWidget {
  const AstroPlusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Astro+', style: TextStyle(fontSize: 18)),
      // Scrollable, because on a 375x812 phone this content is 388 pixels
      // taller than the dialog it sits in. It was close to the edge with
      // three plan tiles and went over with the fourth; a fixed-height
      // Column in a dialog is a bug waiting for one more line of copy.
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Astro+ unlocks the Challenge and Advanced levels, and a tutor '
              'who reviews your work and gives feedback.',
              style: TextStyle(fontSize: 14.5, height: 1.55, color: kInk),
            ),
            const SizedBox(height: 8),
            Text(
              'Easy and Medium stay free forever, and every medal you have '
              'earned stays yours either way.',
              style: TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask a parent or guardian to do this part — the payment '
              'should be theirs. Cancelling later is one click on the same '
              'page.',
              style: TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
            ),
            const SizedBox(height: 16),
            _PlanTile(
              title: 'Monthly — \$10 CAD',
              subtitle: 'Pay by card. Cancel any time.',
              onTap: () => Navigator.of(context).pop('stripe-monthly'),
            ),
            const SizedBox(height: 8),
            _PlanTile(
              title: 'Annual — \$100 CAD',
              subtitle: 'Pay by card. Two months free.',
              onTap: () => Navigator.of(context).pop('stripe-annual'),
            ),
            const SizedBox(height: 8),
            _PlanTile(
              title: 'Interac e-Transfer',
              subtitle: 'Send it from your own banking app instead.',
              onTap: () => Navigator.of(context).pop('etransfer'),
            ),
            const SizedBox(height: 8),
            // The case this product is actually for: a fourteen-year-old
            // with no card, and a parent who has one. The three tiles above
            // all assume the person tapping them is the payer.
            _PlanTile(
              title: 'Ask a parent or guardian',
              subtitle: 'We make a link for them. Nothing is charged now.',
                onTap: () => Navigator.of(context).pop('enrol'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop('support'),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Contact support'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Not now'),
        ),
      ],
    );
  }
}

/// One tappable plan row in the Astro+ dialog.
class _PlanTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Selected gets the accent treatment OptionTile already taught users to
  /// read. A subtitle quietly saying 'Selected' was invisible enough that a
  /// parent could confirm the wrong plan — and the admin then untangles a
  /// bank transfer that matches nothing.
  final bool selected;

  const _PlanTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? kWash : kSurface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: selected ? kAccent : kLine, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: kInk)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 12.5, color: kInkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The e-transfer instructions, and the "I have sent it" declaration.
///
/// Plain about what happens: nothing unlocks until a person has seen the
/// money arrive. Promising instant access here would be a lie the student
/// discovers an hour later, which is worse than the truth up front.
class EtransferDialog extends StatefulWidget {
  final String accountEmail;

  const EtransferDialog({super.key, required this.accountEmail});

  @override
  State<EtransferDialog> createState() => _EtransferDialogState();
}

class _EtransferDialogState extends State<EtransferDialog> {
  String _plan = 'monthly';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title:
          const Text('Pay by Interac e-Transfer', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _PlanTile(
                    title: 'Monthly \$10',
                    subtitle: _plan == 'monthly' ? 'Selected' : 'Tap to pick',
                    selected: _plan == 'monthly',
                    onTap: () => setState(() => _plan = 'monthly'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PlanTile(
                    title: 'Annual \$100',
                    subtitle: _plan == 'annual' ? 'Selected' : 'Tap to pick',
                    selected: _plan == 'annual',
                    onTap: () => setState(() => _plan = 'annual'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'From your banking app, send an Interac e-Transfer to:',
              style: TextStyle(fontSize: 13.5, height: 1.5, color: kInk),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: kLine),
              ),
              child: SelectableText(
                'stemlabs.ca@gmail.com',
                style: TextStyle(
                  fontFamilyFallback: kMonoFallback,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Important: put this sign-in email in the transfer message, so '
              'we know whose account to unlock:\n${widget.accountEmail}',
              style: TextStyle(
                  fontSize: 13, height: 1.5, color: kInk),
            ),
            const SizedBox(height: 12),
            Text(
              'Once you have sent it, tap the button below. Astro+ unlocks '
              'when the transfer is confirmed at our end — usually within a '
              'day, not instantly.',
              style: TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_plan),
          child: const Text('I have sent it'),
        ),
      ],
    );
  }
}

/// Confirms a reset, and says plainly what it does.
///
/// Students expect "reset" to mean "delete", and here it does not — medals
/// and the record stay. Saying so is the difference between a student
/// trusting the button and avoiding it.
class ResetDialog extends StatelessWidget {
  final String course;

  const ResetDialog({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Start $course again?',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Every unit in this course goes back to the first question.',
            style: TextStyle(fontSize: 14.5, height: 1.5, color: kInk),
          ),
          SizedBox(height: 12),
          Text(
            'Your medals stay, and so does everything your teacher can see. '
            'Nothing is deleted — you are just starting a fresh run.',
            style: TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
          ),
          SizedBox(height: 12),
          Text(
            'Other grades are not affected.',
            style: TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Start again'),
        ),
      ],
    );
  }
}

class EmptyPrompt extends StatelessWidget {
  final String message;

  const EmptyPrompt({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: kInkSoft,
          ),
        ),
      ),
    );
  }
}

class ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final String courseCode;
  final String difficulty;
  final VoidCallback? onBack;

  const ProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.courseCode,
    required this.difficulty,
    this.onBack,
  });

  /// Warmer colours as the question gets harder.
  Color get _difficultyColour => switch (difficulty) {
        'Easy' => kAccent,
        'Medium' => kHint,
        _ => kWrong,
      };

  /// Three pips filled to match the level — a size you can read without
  /// having to read the word next to it.
  Widget _pips() {
    final filled = switch (difficulty) {
      'Easy' => 1,
      'Medium' => 2,
      _ => 3,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 4,
          height: 4 + (i * 3),
          margin: const EdgeInsets.only(right: 2.5),
          decoration: BoxDecoration(
            color: i < filled
                ? _difficultyColour
                : _difficultyColour.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // A way back to the levels without needing the unit strip, which
            // is hidden while a question is open.
            if (onBack != null) ...[
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.arrow_back_rounded,
                      size: 18, color: kInkSoft),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              courseCode,
              style: TextStyle(
                fontFamilyFallback: kMonoFallback,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: kInkSoft,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 12, color: kLine),
            const SizedBox(width: 12),
            _pips(),
            const SizedBox(width: 7),
            Text(
              difficulty,
              style: TextStyle(
                color: _difficultyColour,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$current',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                    ),
                  ),
                  TextSpan(
                    text: ' / $total',
                    style: TextStyle(fontSize: 13, color: kInkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // The bar fills rather than jumps, so finishing a question is
        // something you see happen.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: current / total),
          duration: _motion(context, 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: kLine,
                valueColor: AlwaysStoppedAnimation<Color>(kAccent),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// LEARN
// ---------------------------------------------------------------------------
//
// A lesson is a two-minute read attached to a SUBTOPIC, not to a unit. That
// grain is the whole point: the diagnosis works in misconception tags, so a
// weak tag can link to the one lesson that addresses it, and a dropped mark
// on a practice test can do the same. A lesson with a null tag is a unit's
// opening read and belongs to no single subtopic.

/// A row in the Learn tab. Deliberately without the body: a unit's lessons
/// run to tens of kilobytes of markdown, and downloading all of it to draw a
/// list of titles would make opening the tab slower than reading a lesson.
class Lesson {
  final int id;
  final String? tag;
  final String subtopic;
  final int sortOrder;
  final String title;
  final String summary;
  final int readMinutes;
  final bool hasVideo;
  final DateTime? readAt;
  final int readSeconds;

  /// How this student is doing on the subtopic this lesson teaches, so the
  /// list can say "you are shaky on this one" beside the thing that fixes
  /// it. Null for a unit-opening lesson, which belongs to no subtopic.
  final Band? band;
  final int firstLooks;

  /// Distinct questions on this subtopic the student has ever got right,
  /// however many attempts each took. The gate on the Learn path counts
  /// this, not the band — see learn_journey.sql for why the two have to be
  /// different numbers.
  final int solved;

  /// Whether the payload carried `solved` at all.
  ///
  /// This is not fussiness. A database that has not had learn_journey.sql
  /// applied returns no such column, every lesson reads solved = 0, every
  /// gate is shut, and the Learn section locks at the first node — a
  /// working feature turned into a wall by a migration nobody ran yet.
  ///
  /// So the path asks this before it locks anything. Missing column, no
  /// locking: the journey still draws, every node stays open, and the app
  /// degrades to exactly what it did before.
  final bool hasGateData;

  const Lesson({
    required this.id,
    required this.tag,
    required this.subtopic,
    required this.sortOrder,
    required this.title,
    required this.summary,
    required this.readMinutes,
    required this.hasVideo,
    required this.readAt,
    required this.readSeconds,
    required this.band,
    required this.firstLooks,
    this.solved = 0,
    this.hasGateData = true,
  });

  bool get isRead => readAt != null;

  /// How many questions on this subtopic have to be solved before the next
  /// node opens.
  ///
  /// Three, and low on purpose. The gate exists to stop somebody scrolling
  /// past nine lessons in a minute, not to be a second quiz — Quiz is forty
  /// questions and is where the work is. A gate long enough to be a
  /// challenge would make Learn something to get through rather than
  /// something to read.
  static const int gateSize = 3;

  /// A lesson with no subtopic — a unit opener — has nothing to be tested
  /// on, so it is done once it is read.
  bool get hasGate => tag != null;

  bool get gatePassed => !hasGate || solved >= gateSize;

  /// Read AND past the gate. The path opens the next node on this.
  bool get isComplete => isRead && gatePassed;

  /// How far through the gate, 0 to gateSize.
  int get gateProgress => hasGate ? solved.clamp(0, gateSize) : gateSize;

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: (j['id'] as num).toInt(),
        tag: j['tag'] as String?,
        subtopic: j['subtopic'] as String? ?? '',
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
        title: j['title'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        readMinutes: (j['read_minutes'] as num?)?.toInt() ?? 2,
        hasVideo: j['has_video'] == true,
        readAt: j['read_at'] == null
            ? null
            : DateTime.tryParse(j['read_at'] as String),
        readSeconds: (j['read_seconds'] as num?)?.toInt() ?? 0,
        band: j['band'] == null ? null : bandFrom(j['band'] as String?),
        firstLooks: (j['first_looks'] as num?)?.toInt() ?? 0,
        solved: (j['solved'] as num?)?.toInt() ?? 0,
        hasGateData: j.containsKey('solved'),
      );
}

/// Where one node sits on the Learn path.
///
/// Three states, and the order of the list is the order of the journey.
enum LessonNodeState {
  /// Read, and past its gate. Nothing left to do here.
  done,

  /// The one to do next, or one already started. Open.
  active,

  /// An earlier node is not finished yet.
  locked,
}

/// The Learn path: which lesson a student may open, in what order.
///
/// Borrowed from Coddy, which lays a course out as a line of nodes you
/// unlock forward — read a little, then prove it on a few questions, then
/// the next one opens. It suits Learn because lessons already sit in a
/// deliberate order inside a unit, each one assuming the last. It would not
/// suit Improve, which is built to send a student to whatever they keep
/// getting wrong regardless of where it sits.
///
/// The rule, in one line: EVERY NODE BEFORE THIS ONE IS COMPLETE.
///
/// Three properties this has to hold, and they are what the tests check:
///
///   * exactly one active node, unless the whole unit is finished, in which
///     case none — a student always knows what is next
///   * nothing after a locked node is ever open, so the line cannot have a
///     hole in it
///   * a unit where nothing has been done yet still has its FIRST node
///     open, or the path would be a wall
///
/// A lesson already read is never re-locked by a later change, because
/// isComplete needs isRead and reading does not come undone.
List<LessonNodeState> learnPathStates(List<Lesson> lessons) {
  // A database without learn_journey.sql cannot answer the gate question,
  // and the safe answer to "I do not know" is not "locked". Draw the path,
  // lock nothing, and let a student work exactly as they did before.
  if (lessons.any((l) => !l.hasGateData)) {
    return [
      for (final lesson in lessons)
        lesson.isRead ? LessonNodeState.done : LessonNodeState.active,
    ];
  }

  final states = <LessonNodeState>[];
  var everythingBeforeIsDone = true;
  for (final lesson in lessons) {
    if (lesson.isComplete) {
      states.add(LessonNodeState.done);
      continue;
    }
    if (everythingBeforeIsDone) {
      states.add(LessonNodeState.active);
      // The first unfinished node is the only open one. Everything past it
      // waits.
      everythingBeforeIsDone = false;
    } else {
      states.add(LessonNodeState.locked);
    }
  }
  return states;
}

/// The lesson itself, fetched only when one is opened.
class LessonBody {
  final int id;
  final String title;
  final String body;
  final int readMinutes;
  final String? videoTitle;
  final String? videoUrl;
  final String? videoSource;
  final String? tag;
  final String subtopic;

  const LessonBody({
    required this.id,
    required this.title,
    required this.body,
    required this.readMinutes,
    required this.videoTitle,
    required this.videoUrl,
    required this.videoSource,
    required this.tag,
    required this.subtopic,
  });

  factory LessonBody.fromJson(Map<String, dynamic> j) => LessonBody(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        readMinutes: (j['read_minutes'] as num?)?.toInt() ?? 2,
        videoTitle: j['video_title'] as String?,
        videoUrl: j['video_url'] as String?,
        videoSource: j['video_source'] as String?,
        tag: j['tag'] as String?,
        subtopic: j['subtopic'] as String? ?? '',
      );
}

class LessonRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Lesson>> list(String course, String unit) async {
    final rows = await _db.rpc('list_lessons', params: {
      'p_course': course,
      'p_unit': unit,
    }) as List;
    return rows
        .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<LessonBody> body(int id) async {
    final rows = await _db.rpc('lesson_body', params: {'p_id': id}) as List;
    if (rows.isEmpty) throw Exception('That lesson could not be found.');
    return LessonBody.fromJson(Map<String, dynamic>.from(rows.first));
  }

  /// Recorded when the student LEAVES the lesson, with the seconds actually
  /// spent — not on fetch. Marking a lesson read the moment it loads would
  /// tick off something closed after two seconds, and the tick would stop
  /// meaning anything.
  Future<void> markRead(int id, int seconds) async {
    await _db.rpc('mark_lesson_read', params: {
      'p_id': id,
      'p_seconds': seconds,
    });
  }
}
// ---------------------------------------------------------------------------
// The lesson renderer
// ---------------------------------------------------------------------------
//
// Hand-written rather than flutter_markdown, for the same reason this app has
// no charting package and exactly one CustomPainter: a dependency has to earn
// its place, and this needs about two hundred lines of the several thousand a
// general markdown renderer carries.
//
// It handles the subset the lesson bank actually uses, which is fixed and
// checked by tools/import_lessons.py rather than open-ended:
//
//   # ## ###     headings
//   **bold**     `code`     *italic*
//   - item       1. item    > quote
//   ```fenced``` | tables |
//   :::img <name>      a diagram — see below
//   :::caption <text>
//   :::desmos <url>    an interactive graph, opened in a browser tab
//   :::
//
// DIAGRAMS ARE PNG, NOT SVG, AND THAT IS DELIBERATE.
// Flutter draws no SVG without a package. The app already knows how to show a
// picture beside a question — a file under web/figures, drawn with
// Image.network — so lesson diagrams take the same road. Two files exist per
// name because the source colours are theme tokens rather than hex, so the
// drawing follows dark mode instead of glowing white on a dark page.

enum _BlockKind { h1, h2, h3, para, bullet, number, code, quote, img, desmos }

class _Block {
  final _BlockKind kind;
  final String text;
  final String extra; // caption for img, language for code
  const _Block(this.kind, this.text, [this.extra = '']);
}

List<_Block> _parseLesson(String body) {
  final blocks = <_Block>[];
  final lines = body.split('\n');
  var i = 0;

  while (i < lines.length) {
    final line = lines[i];
    final t = line.trimRight();

    if (t.trim().isEmpty) {
      i++;
      continue;
    }

    // Fenced code. Everything inside is taken verbatim, including any of the
    // markers below, which is why this case comes first.
    if (t.trimLeft().startsWith('```')) {
      final lang = t.trimLeft().substring(3).trim();
      final buf = <String>[];
      i++;
      while (i < lines.length && !lines[i].trimLeft().startsWith('```')) {
        buf.add(lines[i]);
        i++;
      }
      i++; // closing fence
      blocks.add(_Block(_BlockKind.code, buf.join('\n'), lang));
      continue;
    }

    // The two block extensions the importer produces.
    if (t.startsWith(':::img ')) {
      final name = t.substring(7).trim();
      var caption = '';
      i++;
      while (i < lines.length && lines[i].trim() != ':::') {
        if (lines[i].startsWith(':::caption ')) {
          caption = lines[i].substring(11).trim();
        }
        i++;
      }
      i++; // closing :::
      blocks.add(_Block(_BlockKind.img, name, caption));
      continue;
    }
    if (t.startsWith(':::desmos ')) {
      final url = t.substring(10).trim();
      i++;
      while (i < lines.length && lines[i].trim() != ':::') {
        i++;
      }
      i++;
      blocks.add(_Block(_BlockKind.desmos, url));
      continue;
    }
    // A stray fence from a shape the importer did not know about. Skipped
    // rather than printed, so a student never sees ':::' in a lesson.
    if (t.trim() == ':::' || t.startsWith(':::')) {
      i++;
      continue;
    }

    if (t.startsWith('### ')) {
      blocks.add(_Block(_BlockKind.h3, t.substring(4).trim()));
      i++;
      continue;
    }
    if (t.startsWith('## ')) {
      blocks.add(_Block(_BlockKind.h2, t.substring(3).trim()));
      i++;
      continue;
    }
    if (t.startsWith('# ')) {
      blocks.add(_Block(_BlockKind.h1, t.substring(2).trim()));
      i++;
      continue;
    }
    if (t.startsWith('> ')) {
      blocks.add(_Block(_BlockKind.quote, t.substring(2).trim()));
      i++;
      continue;
    }

    // Tables are rendered as their rows rather than as a grid. A four-column
    // table is unreadable on a phone at any font size, and every table in
    // this bank is a short lookup rather than a matrix, so "Cell — Cell"
    // per row loses nothing. The separator row is dropped.
    if (t.trimLeft().startsWith('|') && t.contains('|')) {
      while (i < lines.length && lines[i].trimLeft().startsWith('|')) {
        final row = lines[i].trim();
        final cells = row
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();
        final isSeparator =
            cells.isNotEmpty && cells.every((c) => RegExp(r'^:?-{2,}:?$').hasMatch(c));
        if (!isSeparator && cells.isNotEmpty) {
          blocks.add(_Block(_BlockKind.bullet, cells.join('  —  ')));
        }
        i++;
      }
      continue;
    }

    final bullet = RegExp(r'^\s*[-*]\s+(.*)$').firstMatch(t);
    if (bullet != null) {
      blocks.add(_Block(_BlockKind.bullet, bullet.group(1)!.trim()));
      i++;
      continue;
    }
    final numbered = RegExp(r'^\s*(\d+)\.\s+(.*)$').firstMatch(t);
    if (numbered != null) {
      blocks.add(
          _Block(_BlockKind.number, numbered.group(2)!.trim(), numbered.group(1)!));
      i++;
      continue;
    }

    // Everything else is a paragraph, joined until a blank line so that
    // markdown's soft wraps do not become line breaks on screen.
    final buf = <String>[t.trim()];
    i++;
    while (i < lines.length &&
        lines[i].trim().isNotEmpty &&
        !lines[i].trimLeft().startsWith('```') &&
        !lines[i].startsWith(':::') &&
        !lines[i].trimLeft().startsWith('|') &&
        !lines[i].startsWith('#') &&
        !lines[i].startsWith('> ') &&
        RegExp(r'^\s*[-*]\s+').firstMatch(lines[i]) == null &&
        RegExp(r'^\s*\d+\.\s+').firstMatch(lines[i]) == null) {
      buf.add(lines[i].trim());
      i++;
    }
    blocks.add(_Block(_BlockKind.para, buf.join(' ')));
  }
  return blocks;
}

/// Inline spans: **bold**, `code`, *italic*. Parsed in one left-to-right
/// pass rather than by nested regex, so a stray asterisk in the middle of a
/// sentence stays a stray asterisk instead of swallowing the rest of the
/// paragraph.
List<TextSpan> _inlineSpans(String text, TextStyle base) {
  final spans = <TextSpan>[];
  final buf = StringBuffer();

  void flush() {
    if (buf.isNotEmpty) {
      spans.add(TextSpan(text: buf.toString(), style: base));
      buf.clear();
    }
  }

  var i = 0;
  while (i < text.length) {
    if (text.startsWith('**', i)) {
      final end = text.indexOf('**', i + 2);
      if (end > i + 2) {
        flush();
        spans.add(TextSpan(
          text: text.substring(i + 2, end),
          style: base.copyWith(fontWeight: FontWeight.w700),
        ));
        i = end + 2;
        continue;
      }
    }
    if (text[i] == '`') {
      final end = text.indexOf('`', i + 1);
      if (end > i + 1) {
        flush();
        spans.add(TextSpan(
          text: text.substring(i + 1, end),
          style: base.copyWith(
            fontFamily: 'monospace',
            fontSize: (base.fontSize ?? 15) - 0.5,
            color: kAccentDeep,
            backgroundColor: kWash,
          ),
        ));
        i = end + 1;
        continue;
      }
    }
    if (text[i] == '*' && !text.startsWith('**', i)) {
      final end = text.indexOf('*', i + 1);
      if (end > i + 1 && !text.substring(i + 1, end).contains('\n')) {
        flush();
        spans.add(TextSpan(
          text: text.substring(i + 1, end),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ));
        i = end + 1;
        continue;
      }
    }
    buf.write(text[i]);
    i++;
  }
  flush();
  return spans;
}
/// Draws the parsed blocks.
class LessonMarkdown extends StatelessWidget {
  final String body;
  const LessonMarkdown({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final blocks = _parseLesson(body);
    final para = TextStyle(fontSize: 15, height: 1.62, color: kInk);

    Widget text(String s, TextStyle style) => RichText(
          text: TextSpan(children: _inlineSpans(s, style)),
        );

    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      // The lesson's own H1 repeats the title already shown in the header.
      if (b.kind == _BlockKind.h1 && i == 0) continue;

      switch (b.kind) {
        case _BlockKind.h1:
        case _BlockKind.h2:
          children.add(Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 0 : 26, bottom: 8),
            child: text(
              b.text,
              TextStyle(
                fontFamily: kSerif,
                fontFamilyFallback: kSerifFallback,
                fontSize: 19,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
            ),
          ));
          break;
        case _BlockKind.h3:
          children.add(Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: text(
              b.text,
              TextStyle(
                  fontSize: 15.5, fontWeight: FontWeight.w700, color: kInk),
            ),
          ));
          break;
        case _BlockKind.para:
          children.add(Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: text(b.text, para),
          ));
          break;
        case _BlockKind.bullet:
          children.add(Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8, right: 10),
                  child: SizedBox(
                    width: 5,
                    height: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Expanded(child: text(b.text, para)),
              ],
            ),
          ));
          break;
        case _BlockKind.number:
          children.add(Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '${b.extra}.',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: kAccent,
                    ),
                  ),
                ),
                Expanded(child: text(b.text, para)),
              ],
            ),
          ));
          break;
        case _BlockKind.quote:
          children.add(Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: kAccent, width: 3)),
            ),
            child: text(b.text, para.copyWith(color: kInkSoft)),
          ));
          break;
        case _BlockKind.code:
          children.add(Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kTrack,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: kLine),
            ),
            // Maths lines up in columns; wrapping it would break the
            // alignment that makes a worked example readable.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                b.text,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13.5,
                  height: 1.55,
                  color: kInk,
                ),
              ),
            ),
          ));
          break;
        case _BlockKind.img:
          children.add(_LessonDiagram(name: b.text, caption: b.extra));
          break;
        case _BlockKind.desmos:
          children.add(_DesmosLink(url: b.text));
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// A diagram. Two files exist per name; which one is fetched depends on the
/// theme, because the source colours were tokens rather than hex.
class _LessonDiagram extends StatelessWidget {
  final String name;
  final String caption;
  const _LessonDiagram({required this.name, required this.caption});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final url = '${Uri.base.origin}/figures/lessons/'
        '${name}_${dark ? 'dark' : 'light'}.png';

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              // The caption describes the picture, so it is the right
              // alt text — better than anything generic could be.
              semanticLabel: caption.isEmpty ? 'Lesson diagram' : caption,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(height: 160, color: kSurface),
              errorBuilder: (context, error, stack) => Container(
                height: 90,
                alignment: Alignment.center,
                color: kSurface,
                child: Text(
                  'This diagram could not load.',
                  style: TextStyle(fontSize: 12.5, color: kInkSoft),
                ),
              ),
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              caption,
              style: TextStyle(
                  fontSize: 12.5, height: 1.45, color: kInkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens a link in a NEW tab. Deliberately not _openBilling, which uses
/// webOnlyWindowName '_self' and would navigate the student out of the
/// lesson they are in the middle of reading.
Future<void> _openInNewTab(String url) async {
  await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
}

/// An interactive graph. Opened in a tab rather than embedded: an iframe
/// inside a scrolling lesson traps the scroll, which is the same trap the
/// mindmap needed a tap-to-wake scrim to escape.
class _DesmosLink extends StatelessWidget {
  final String url;
  const _DesmosLink({required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: OutlinedButton.icon(
        onPressed: () => _openInNewTab(url),
        icon: const Icon(Icons.show_chart_rounded, size: 18),
        label: const Text('Open the interactive graph'),
        style: OutlinedButton.styleFrom(
          foregroundColor: kAccentDeep,
          side: BorderSide(color: kLine),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
/// One lesson, full screen.
///
/// Time on the page is measured here and sent when the student LEAVES,
/// which is why this is stateful for something that mostly just renders
/// text. A lesson opened and closed in three seconds has not been read, and
/// a tick that appears anyway is a tick that means nothing to the student or
/// to their tutor.
class LessonScreen extends StatefulWidget {
  final int lessonId;
  final LessonRepository lessons;

  /// Needed so a lesson can hand straight over to questions on its own
  /// subtopic. A lesson that ends in nothing is a lesson a student closes
  /// and forgets; a lesson that ends in eight questions on the thing they
  /// just read is the whole reason Learn sits next to Quiz.
  final String course;

  /// Whether there is another lesson after this one in the unit. The caller
  /// knows the list, so it decides; this screen only reports that the
  /// student asked for it, by popping true.
  final bool hasNext;

  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.lessons,
    required this.course,
    this.hasNext = false,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  LessonBody? _body;
  String? _error;
  bool _loading = true;
  bool _recorded = false;
  DateTime? _opened;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final b = await widget.lessons.body(widget.lessonId);
      if (!mounted) return;
      setState(() {
        _body = b;
        _loading = false;
        _opened = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'That lesson could not be opened.';
        _loading = false;
      });
    }
  }

  /// Fire and forget. A student leaving a lesson should never wait on a
  /// write, and a lost tick matters far less than a stalled back button.
  void _record() {
    if (_recorded || _opened == null) return;
    _recorded = true;
    final seconds = DateTime.now().difference(_opened!).inSeconds;
    widget.lessons.markRead(widget.lessonId, seconds).catchError((Object _) {});
  }

  @override
  void dispose() {
    _record();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = _body;
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kCard,
        surfaceTintColor: kCard,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: kLine)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: kInk),
          tooltip: 'Back to the lessons',
          onPressed: () {
            _record();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          b?.subtopic.isNotEmpty == true ? b!.subtopic : 'Lesson',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: kInk),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ErrorView(message: _error!, onRetry: _load)
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b!.title,
                              style: TextStyle(
                                fontFamily: kSerif,
                                fontFamilyFallback: kSerifFallback,
                                fontSize: 26,
                                height: 1.18,
                                fontWeight: FontWeight.w700,
                                color: kInk,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${b.readMinutes} minute read',
                              style: TextStyle(
                                  fontSize: 12.5, color: kInkSoft),
                            ),
                            const SizedBox(height: 20),
                            LessonMarkdown(body: b.body),
                            if (b.videoUrl != null) ...[
                              const SizedBox(height: 8),
                              _VideoLink(
                                title: b.videoTitle ?? 'Watch this explained',
                                source: b.videoSource,
                                url: b.videoUrl!,
                              ),
                            ],
                            const SizedBox(height: 26),
                            Divider(height: 1, color: kLine),
                            const SizedBox(height: 20),
                            if (b.tag != null) ...[
                              PrimaryButton(
                                label: 'Try questions on this',
                                onPressed: () {
                                  _record();
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => DrillScreen(
                                        course: widget.course,
                                        tags: [b.tag!],
                                        title: b.subtopic.isEmpty
                                            ? b.title
                                            : b.subtopic,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (widget.hasNext)
                              OutlinedButton(
                                onPressed: () {
                                  _record();
                                  Navigator.of(context).pop(true);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: kAccentDeep,
                                  side: BorderSide(color: kLine),
                                  minimumSize:
                                      const Size(double.infinity, 46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Next lesson'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _VideoLink extends StatelessWidget {
  final String title;
  final String? source;
  final String url;

  const _VideoLink({required this.title, required this.source, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openInNewTab(url),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: kLine),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline_rounded,
                size: 26, color: kAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
                  ),
                  if (source != null)
                    Text(
                      source!,
                      style: TextStyle(fontSize: 12, color: kInkSoft),
                    ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 16, color: kInkSoft),
          ],
        ),
      ),
    );
  }
}

/// A row in the Learn list.
/// One node on the Learn path.
///
/// A numbered marker, a connector down to the next one, and the lesson
/// beside it. The three states are drawn differently AND labelled: a
/// locked node says "Locked" rather than only going pale, because pale is
/// how a disabled control looks when an app is broken.
///
/// The gate sits inside the node rather than on a screen of its own, so a
/// student can see what is between them and the next lesson without
/// opening anything.
class LessonNode extends StatelessWidget {
  final Lesson lesson;
  final LessonNodeState state;
  final bool isLast;

  /// Null when the node is locked.
  final VoidCallback? onOpen;

  /// Null when the node is locked, or when the lesson has no subtopic and
  /// so has no questions to be gated on.
  final VoidCallback? onPractise;

  const LessonNode({
    super.key,
    required this.lesson,
    required this.state,
    required this.isLast,
    this.onOpen,
    this.onPractise,
  });

  bool get _locked => state == LessonNodeState.locked;
  bool get _done => state == LessonNodeState.done;

  @override
  Widget build(BuildContext context) {
    final marker = _done
        ? kAccent
        : (_locked ? kLine : kAccentSurface);

    return Semantics(
      button: !_locked,
      enabled: !_locked,
      label: '${lesson.title}. '
          '${_done ? 'Done.' : (_locked ? 'Locked.' : 'Open.')}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The line of the journey: a marker, and a rail running down to
            // the next node.
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _done ? marker : kCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: marker, width: 2),
                  ),
                  child: Center(
                    child: _done
                        ? Icon(Icons.check_rounded, size: 15, color: kOnAccent)
                        : (_locked
                            ? Icon(Icons.lock_rounded,
                                size: 13, color: kInkSoft)
                            : Text(
                                '${lesson.sortOrder}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: kAccentSurface,
                                ),
                              )),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: _done ? kAccent.withValues(alpha: 0.45) : kLine,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Opacity(
                  // Pale, but never so pale it cannot be read — a student
                  // should be able to see what is coming.
                  opacity: _locked ? 0.65 : 1,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state == LessonNodeState.active
                            ? kAccent.withValues(alpha: 0.55)
                            : kLine,
                        width: state == LessonNodeState.active ? 1.5 : 1,
                      ),
                      boxShadow:
                          state == LessonNodeState.active ? kCardShadow : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lesson.title,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: kInk,
                                ),
                              ),
                            ),
                            if (_locked)
                              Text(
                                'LOCKED',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w800,
                                  color: kInkSoft,
                                ),
                              )
                            else
                              Text(
                                '${lesson.readMinutes} min',
                                style: TextStyle(
                                    fontSize: 11.5, color: kInkSoft),
                              ),
                          ],
                        ),
                        if (lesson.summary.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            lesson.summary,
                            style: TextStyle(
                                fontSize: 12.5, height: 1.45, color: kInkSoft),
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (_locked)
                          Text(
                            'Finish the one above to open this.',
                            style: TextStyle(fontSize: 12, color: kInkSoft),
                          )
                        else
                          Row(
                            children: [
                              _NodeAction(
                                icon: lesson.isRead
                                    ? Icons.menu_book_rounded
                                    : Icons.play_arrow_rounded,
                                label: lesson.isRead ? 'Read again' : 'Read',
                                onTap: onOpen,
                                primary: !lesson.isRead,
                              ),
                              if (lesson.hasGate) ...[
                                const SizedBox(width: 8),
                                _NodeAction(
                                  icon: Icons.bolt_rounded,
                                  label: lesson.gatePassed
                                      ? 'Practise'
                                      : '${lesson.gateProgress} of '
                                          '${Lesson.gateSize}',
                                  onTap: onPractise,
                                  primary:
                                      lesson.isRead && !lesson.gatePassed,
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the two small buttons inside a node.
class _NodeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  const _NodeAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    return Material(
      color: primary && on ? kAccentSurface : kTrack,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: primary && on ? kOnAccent : kInkSoft),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primary && on ? kOnAccent : kInkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// IMPROVE
// ---------------------------------------------------------------------------
//
// The section with real work behind it, because until now the database could
// not answer the question it asks.
//
// student_subtopics has always produced a good diagnosis — coverage, a
// first-try band, and an `avoided` flag that measures a subtopic against the
// student's own best-covered subtopic in the same unit rather than the unit
// average — and it has always been visible only to tutors. my_subtopics is
// that query self-scoped, and improve_plan is its top handful with the
// lesson that covers each one attached.
//
// list_practice is the genuinely new part: questions selected by
// misconception tag rather than by unit and level. Nothing in this app could
// do that before, and it is the only thing a drill actually needs.

/// One line of the plan: a subtopic worth time, and why.
class ImproveRow {
  final String unit;
  final String tag;
  final String label;
  final Band band;
  final int? firstTryRate;
  final int coveragePct;
  final bool avoided;
  final int unseen;
  final int? lessonId;
  final String? lessonTitle;

  /// The server's own words for why this row is here. Written in SQL beside
  /// the rule that put it there, so the explanation cannot drift away from
  /// the logic the way a client-side restatement would.
  final String reason;

  const ImproveRow({
    required this.unit,
    required this.tag,
    required this.label,
    required this.band,
    required this.firstTryRate,
    required this.coveragePct,
    required this.avoided,
    required this.unseen,
    required this.lessonId,
    required this.lessonTitle,
    required this.reason,
  });

  factory ImproveRow.fromJson(Map<String, dynamic> j) => ImproveRow(
        unit: j['unit'] as String? ?? '',
        tag: j['tag'] as String? ?? '',
        label: j['label'] as String? ?? '',
        band: bandFrom(j['band'] as String?),
        firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
        coveragePct: (j['coverage_pct'] as num?)?.toInt() ?? 0,
        avoided: j['avoided'] == true,
        unseen: (j['unseen'] as num?)?.toInt() ?? 0,
        lessonId: (j['lesson_id'] as num?)?.toInt(),
        lessonTitle: j['lesson_title'] as String?,
        reason: j['reason'] as String? ?? '',
      );
}

class ImproveRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<ImproveRow>> plan({int limit = 6}) async {
    final rows = await _db.rpc('improve_plan', params: {'p_limit': limit})
        as List;
    return rows
        .map((e) => ImproveRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Questions for a drill. The server picks them: unseen before seen,
  /// anything answered cleanly twice left out, and the Astro+ gate applied
  /// exactly as list_questions applies it.
  Future<List<Question>> practice(List<String> tags, {int limit = 10}) async {
    final rows = await _db.rpc('list_practice', params: {
      'p_tags': tags,
      'p_limit': limit,
    }) as List;
    return rows.map((e) {
      // list_practice names the column `tag`; Question reads
      // `misconception_tag`, because that is what it is called in the bank.
      final m = Map<String, dynamic>.from(e as Map);
      m['misconception_tag'] = m['tag'];
      return Question.fromJson(m);
    }).toList();
  }
}

/// A short, targeted set on the subtopics a student keeps getting wrong.
///
/// Deliberately not a level: eight to ten questions, no medal, no ramp.
/// A medal would turn it into something to grind; this is meant to feel like
/// clearing something off a list.
class DrillScreen extends StatefulWidget {
  final String course;
  final List<String> tags;
  final String title;

  const DrillScreen({
    super.key,
    required this.course,
    required this.tags,
    required this.title,
  });

  @override
  State<DrillScreen> createState() => _DrillScreenState();
}

class _DrillScreenState extends State<DrillScreen> {
  final ImproveRepository _improve = ImproveRepository();
  // submitAnswer lives on ProgressRepository, not QuestionRepository —
  // grading is a write against the attempt history, not a question lookup.
  final ProgressRepository _progress = ProgressRepository();

  List<Question> _set = const [];
  bool _loading = true;
  String? _error;

  int _index = 0;
  final Set<int> _tried = {};
  int? _found;
  String? _feedback;
  bool _feedbackCorrect = false;
  bool _grading = false;
  int _firstTry = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final qs = await _improve.practice(widget.tags);
      if (!mounted) return;
      setState(() {
        _set = qs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Those questions could not be loaded.';
        _loading = false;
      });
    }
  }

  Future<void> _tap(int i) async {
    if (_grading || _found != null || _tried.contains(i)) return;
    setState(() => _grading = true);
    try {
      final v = await _progress.submitAnswer(
        course: widget.course,
        question: _set[_index],
        chosenIndex: i,
      );
      if (!mounted) return;
      setState(() {
        _grading = false;
        _feedback = v.feedback;
        _feedbackCorrect = v.correct;
        if (v.correct) {
          _found = i;
          if (v.wasFirst) _firstTry++;
        } else {
          _tried.add(i);
        }
      });
    } catch (e) {
      if (!mounted) return;
      // Same rule as the quiz: a dropped connection mid-answer must not
      // throw the student out of the set they are working through.
      setState(() => _grading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That did not save. Try the tap again.')),
      );
    }
  }

  void _next() {
    if (_index + 1 >= _set.length) {
      setState(() => _done = true);
      return;
    }
    setState(() {
      _index++;
      _tried.clear();
      _found = null;
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kCard,
        surfaceTintColor: kCard,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: kLine)),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kInk),
          tooltip: 'Leave this set',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: kInk),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
              child: _body(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 120),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_set.isEmpty) {
      return const EmptyPrompt(
        message: 'Nothing left to drill here — you have already answered '
            'these correctly first time. Try a different subtopic.',
      );
    }
    if (_done) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            _firstTry == _set.length
                ? 'Every one first time.'
                : '$_firstTry of ${_set.length} first time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nothing is scored here and no medal moves. The point was the '
            'practice, and the topic map will catch up on its own.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    final q = _set[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Question ${_index + 1} of ${_set.length}  ·  ${q.unit}',
          style: TextStyle(fontSize: 12, color: kInkSoft),
        ),
        const SizedBox(height: 12),
        QuestionCard(
          prompt: q.prompt,
          subtopic: q.subtopic,
          figure: q.figure,
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < q.options.length; i++) ...[
          OptionTile(
            letter: String.fromCharCode(65 + i),
            option: q.options[i],
            isRuledOut: _tried.contains(i),
            isFound: _found == i,
            isFocused: false,
            enabled: !_grading && _found == null && !_tried.contains(i),
            onTap: () => _tap(i),
          ),
          const SizedBox(height: 9),
        ],
        if (_feedback != null) ...[
          const SizedBox(height: 6),
          FeedbackPanel(correct: _feedbackCorrect, message: _feedback!),
        ],
        if (_found != null) ...[
          const SizedBox(height: 18),
          PrimaryButton(
            label: _index + 1 >= _set.length ? 'Finish' : 'Next question',
            onPressed: _next,
          ),
        ],
      ],
    );
  }
}

/// One subtopic on the plan.
class ImproveTile extends StatelessWidget {
  final ImproveRow row;
  final VoidCallback onDrill;
  final VoidCallback? onLesson;

  const ImproveTile({
    super.key,
    required this.row,
    required this.onDrill,
    this.onLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kLine),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: bandColour(row.band),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  row.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                  ),
                ),
              ),
              if (row.firstTryRate != null)
                Text(
                  '${row.firstTryRate}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: bandTextColour(row.band),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            row.reason,
            style: TextStyle(fontSize: 13, height: 1.45, color: kInkSoft),
          ),
          const SizedBox(height: 4),
          Text(
            row.unit,
            style: TextStyle(fontSize: 11.5, color: kInkSoft),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onLesson != null) ...[
                OutlinedButton(
                  onPressed: onLesson,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kAccentDeep,
                    side: BorderSide(color: kLine),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text('Read the lesson'),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: PrimaryButton(label: 'Practise this', onPressed: onDrill),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TEST
// ---------------------------------------------------------------------------
//
// The whole unit, straight through, with no feedback until the end. That
// last part is the only reason the score means anything: Quiz lets a student
// keep tapping until they are right, so Quiz can measure effort but never
// attainment. It is also why this is a pushed screen rather than a pane —
// during a test the rail, the topic list and the resume card are all
// distractions from a paper that is being marked.
//
// Astro+ gets fifteen questions across all four bands. A free account gets a
// ten-question warm-up over Easy and Medium, labelled as a warm-up rather
// than passed off as the real thing.

class TestStart {
  final int testId;
  final int total;
  final bool isWarmup;
  final bool resumed;

  const TestStart({
    required this.testId,
    required this.total,
    required this.isWarmup,
    required this.resumed,
  });

  factory TestStart.fromJson(Map<String, dynamic> j) => TestStart(
        testId: (j['test_id'] as num).toInt(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        isWarmup: j['is_warmup'] == true,
        resumed: j['resumed'] == true,
      );
}

class TestItem {
  final int itemNo;
  final int sortOrder;
  final String difficulty;
  final String prompt;
  final List<AnswerOption> options;
  final String? subtopic;
  final String? figure;
  final int? chosenIndex;

  const TestItem({
    required this.itemNo,
    required this.sortOrder,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.subtopic,
    required this.figure,
    required this.chosenIndex,
  });

  factory TestItem.fromJson(Map<String, dynamic> j) => TestItem(
        itemNo: (j['item_no'] as num).toInt(),
        sortOrder: (j['sort_order'] as num).toInt(),
        difficulty: j['difficulty'] as String? ?? '',
        prompt: j['prompt'] as String? ?? '',
        options: ((j['options'] as List?) ?? [])
            .map((o) => AnswerOption.fromJson(Map<String, dynamic>.from(o)))
            .toList(),
        subtopic: j['subtopic'] as String?,
        figure: j['figure'] as String?,
        chosenIndex: (j['chosen_index'] as num?)?.toInt(),
      );
}

class TestScore {
  final int scorePct;
  final int correct;
  final int total;
  final bool isWarmup;
  final int seconds;

  const TestScore({
    required this.scorePct,
    required this.correct,
    required this.total,
    required this.isWarmup,
    required this.seconds,
  });

  factory TestScore.fromJson(Map<String, dynamic> j) => TestScore(
        scorePct: (j['score_pct'] as num?)?.toInt() ?? 0,
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        isWarmup: j['is_warmup'] == true,
        seconds: (j['seconds'] as num?)?.toInt() ?? 0,
      );
}

/// One question of a finished paper, as the student is allowed to see it.
///
/// The option they chose, whether it was right, and — only when it was not —
/// the feedback line naming the mistake. Never the correct answer: these
/// questions come round again, and printing it would spend one of them.
/// Privacy and terms, as they appear on the sign-in screen and in the
/// profile pane.
///
/// They open in a new tab rather than inside the app because they are
/// rendered HTML — tools/render_legal.py turns docs/PRIVACY.md and
/// docs/TERMS.md into web/privacy.html and web/terms.html, so there is one
/// copy of each and it is the one under version control.
/// Getting hold of a person.
///
/// A sheet rather than a page, and a mailto rather than a form. A form
/// needs somewhere to put what it collects, which for this app means a
/// table holding messages from children — a new place to store their words
/// and their problems, with its own retention question and its own row in
/// the privacy policy. A mailto puts the message in the sender's own outbox
/// and delivers it to an inbox a person already reads.
///
/// The address is the same one named in the privacy policy as the route for
/// deletion and access requests. One address, one inbox, one promise.
Future<void> showContactSheet(BuildContext context) {
  const address = 'stemlabs.ca@gmail.com';

  Future<void> mail(String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      // Uri does the percent-encoding, which matters: a subject with a
      // space or an apostrophe hand-pasted into a mailto silently
      // truncates the link in some clients.
      query: Uri(queryParameters: {'subject': subject}).query,
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Contact us', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A person reads this inbox. Pick whichever is closest and it '
              'will open your email app with the subject filled in.',
              style: TextStyle(fontSize: 13.5, height: 1.55, color: kInkSoft),
            ),
            const SizedBox(height: 16),
            for (final reason in const [
              ('Something is broken', 'Astro STEM Labs - something is broken',
               Icons.bug_report_rounded),
              ('A question looks wrong', 'Astro STEM Labs - question problem',
               Icons.help_outline_rounded),
              ('Astro+, payments or billing', 'Astro STEM Labs - Astro+',
               Icons.payments_rounded),
              ('My data, or deleting my account',
               'Astro STEM Labs - my data', Icons.shield_outlined),
              ('Something else', 'Astro STEM Labs', Icons.mail_outline_rounded),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: kTrack,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.of(context).pop();
                      mail(reason.$2);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
                      child: Row(
                        children: [
                          Icon(reason.$3, size: 18, color: kInkSoft),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(reason.$1,
                                style:
                                    TextStyle(fontSize: 13.5, color: kInk)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            // Shown in full and selectable, because a student on a device
            // with no mail app set up still needs to be able to reach us.
            Text('Or write to us directly:',
                style: TextStyle(fontSize: 12.5, color: kInkSoft)),
            const SizedBox(height: 4),
            SelectableText(address,
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: kInk)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  Future<void> _open(String page) async {
    // Relative to wherever the app is served, so this works on Cloudflare
    // Pages and on a local build without knowing either URL.
    final uri = Uri.base.resolve(page);
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12, color: kInkSoft);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _open('privacy.html'),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: Text('Privacy', style: style),
        ),
        Text('\u00b7', style: style),
        TextButton(
          onPressed: () => _open('terms.html'),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: Text('Terms', style: style),
        ),
        Text('\u00b7', style: style),
        TextButton(
          onPressed: () => showContactSheet(context),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: Text('Contact', style: style),
        ),
      ],
    );
  }
}

/// One option of a finished paper's question: the text, and the mistake
/// that lands on it.
///
/// The only type in this app that pairs an option with its feedback. See the
/// note on TestReview.options for why it is not AnswerOption.
class ReviewOption {
  final String text;
  final String? feedback;

  const ReviewOption({required this.text, this.feedback});

  factory ReviewOption.fromJson(Map<String, dynamic> json) => ReviewOption(
        text: json['text'] as String? ?? '',
        feedback: json['feedback'] as String?,
      );
}

/// One question of a finished paper, as the student may now see it.
///
/// This is the ONE place in the app where the answer reaches the browser,
/// and it is deliberate. The reasoning, and what it costs, is written out in
/// supabase/migrations/test_review_answers.sql. The short version: a test is
/// summative, its attempts never count as first looks, and a student handed
/// a mark without being shown which fifteen they got wrong has been graded
/// rather than taught.
///
/// Nothing about Quiz or Improve changed. Tap a wrong option there and it
/// still names the mistake and keeps the answer to itself.
class TestReview {
  final int itemNo;
  final String difficulty;
  final String prompt;
  final String? chosenText;
  final bool wasCorrect;
  final String? feedback;
  final String subtopic;

  /// Which option was tapped, and which was right. Both 0-based, both null
  /// on a payload from a database that predates test_review_answers.sql —
  /// the UI falls back to the old behaviour rather than rendering wrong.
  final int? chosenIndex;
  final int? correctIndex;

  /// All four, each with the line that names the mistake it comes from.
  ///
  /// Deliberately NOT AnswerOption. That type carries text and nothing else,
  /// and its whole job is to be the thing a question ships to the browser —
  /// Block B of tests/test_ama.sql asserts as much. Reusing it here would
  /// have quietly dropped the feedback, and worse, it would have blurred the
  /// one line this app is built on. ReviewOption exists in exactly one
  /// place, which is where the answer is allowed out.
  ///
  /// The correct option's feedback is exactly 'Correct.' by the authoring
  /// rule, so there is no sentence in the bank explaining WHY the answer is
  /// right. The review must not invent one. What it can show, and what is
  /// worth more, is the named mistake behind each of the three wrong ones.
  final List<ReviewOption> options;

  const TestReview({
    required this.itemNo,
    required this.difficulty,
    required this.prompt,
    required this.chosenText,
    required this.wasCorrect,
    required this.feedback,
    required this.subtopic,
    this.chosenIndex,
    this.correctIndex,
    this.options = const [],
  });

  /// Whether this row carries enough to show the full breakdown.
  bool get hasAnswers => correctIndex != null && options.length == 4;

  factory TestReview.fromJson(Map<String, dynamic> j) => TestReview(
        itemNo: (j['item_no'] as num).toInt(),
        difficulty: j['difficulty'] as String? ?? '',
        prompt: j['prompt'] as String? ?? '',
        chosenText: j['chosen_text'] as String?,
        wasCorrect: j['was_correct'] == true,
        feedback: j['feedback'] as String?,
        subtopic: j['subtopic'] as String? ?? '',
        chosenIndex: (j['chosen_index'] as num?)?.toInt(),
        correctIndex: (j['correct_index'] as num?)?.toInt(),
        options: ((j['options'] as List?) ?? [])
            .map((e) => ReviewOption.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

/// A paper already sat on this unit.
///
/// The topic map shows a student's BEST score, which is a kindness but also
/// opaque — it cannot go down, so it stops being news. The history is where
/// improvement is actually visible.
class TestAttempt {
  final int testId;
  final int scorePct;
  final int correct;
  final int total;
  final bool isWarmup;
  final int seconds;
  final DateTime? finishedAt;

  const TestAttempt({
    required this.testId,
    required this.scorePct,
    required this.correct,
    required this.total,
    required this.isWarmup,
    required this.seconds,
    required this.finishedAt,
  });

  factory TestAttempt.fromJson(Map<String, dynamic> j) => TestAttempt(
        testId: (j['test_id'] as num).toInt(),
        scorePct: (j['score_pct'] as num?)?.toInt() ?? 0,
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        isWarmup: j['is_warmup'] == true,
        seconds: (j['seconds'] as num?)?.toInt() ?? 0,
        finishedAt: j['finished_at'] == null
            ? null
            : DateTime.tryParse(j['finished_at'] as String),
      );
}

class TestBreakdown {
  final String tag;
  final String label;
  final int asked;
  final int got;
  final int pct;
  final int? lessonId;
  final String? lessonTitle;

  const TestBreakdown({
    required this.tag,
    required this.label,
    required this.asked,
    required this.got,
    required this.pct,
    required this.lessonId,
    required this.lessonTitle,
  });

  factory TestBreakdown.fromJson(Map<String, dynamic> j) => TestBreakdown(
        tag: j['tag'] as String? ?? '',
        label: j['label'] as String? ?? '',
        asked: (j['asked'] as num?)?.toInt() ?? 0,
        got: (j['got'] as num?)?.toInt() ?? 0,
        pct: (j['pct'] as num?)?.toInt() ?? 0,
        lessonId: (j['lesson_id'] as num?)?.toInt(),
        lessonTitle: j['lesson_title'] as String?,
      );
}

class TestRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<TestStart> start(String course, String unit) async {
    final rows = await _db.rpc('start_test', params: {
      'p_course': course,
      'p_unit': unit,
    }) as List;
    if (rows.isEmpty) throw Exception('That test could not be started.');
    return TestStart.fromJson(Map<String, dynamic>.from(rows.first));
  }

  Future<List<TestItem>> paper(int testId) async {
    final rows = await _db.rpc('test_paper', params: {'p_test': testId})
        as List;
    return rows
        .map((e) => TestItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Returns nothing, and that is the point. submit_answer hands back a
  /// verdict and a feedback line because Quiz is meant to teach in the
  /// moment; either of those here would let a student read the result off
  /// the network tab and change their answer.
  Future<void> answer(int testId, int itemNo, int chosen) async {
    await _db.rpc('answer_test_item', params: {
      'p_test': testId,
      'p_item_no': itemNo,
      'p_chosen': chosen,
    });
  }

  Future<TestScore> finish(int testId) async {
    final rows = await _db.rpc('finish_test', params: {'p_test': testId})
        as List;
    if (rows.isEmpty) throw Exception('That test could not be marked.');
    return TestScore.fromJson(Map<String, dynamic>.from(rows.first));
  }

  Future<List<TestBreakdown>> result(int testId) async {
    final rows = await _db.rpc('test_result', params: {'p_test': testId})
        as List;
    return rows
        .map((e) => TestBreakdown.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<TestReview>> review(int testId) async {
    final rows = await _db.rpc('test_item_review', params: {'p_test': testId})
        as List;
    return rows
        .map((e) => TestReview.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<TestAttempt>> history(String course, String unit) async {
    final rows = await _db.rpc('unit_test_history', params: {
      'p_course': course,
      'p_unit': unit,
    }) as List;
    return rows
        .map((e) => TestAttempt.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> abandon(int testId) async {
    await _db.rpc('abandon_test', params: {'p_test': testId});
  }
}

class TestScreen extends StatefulWidget {
  final String course;
  final String unit;
  final LessonRepository lessons;

  const TestScreen({
    super.key,
    required this.course,
    required this.unit,
    required this.lessons,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TestRepository _tests = TestRepository();

  TestStart? _start;
  List<TestItem> _paper = const [];
  final Map<int, int> _answers = {}; // item_no -> chosen index
  int _index = 0;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  TestScore? _score;
  List<TestBreakdown> _breakdown = const [];
  List<TestReview> _review = const [];
  bool _showReview = false;

  @override
  void initState() {
    super.initState();
    _begin();
  }

  Future<void> _begin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await _tests.start(widget.course, widget.unit);
      final p = await _tests.paper(s.testId);
      if (!mounted) return;
      setState(() {
        _start = s;
        _paper = p;
        _answers.clear();
        for (final item in p) {
          if (item.chosenIndex != null) _answers[item.itemNo] = item.chosenIndex!;
        }
        // A resumed paper opens at the first unanswered question rather than
        // at the top, so coming back from a dropped connection does not mean
        // scrolling past work already done.
        _index = p.indexWhere((i) => i.chosenIndex == null);
        if (_index < 0) _index = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'That test could not be started.';
        _loading = false;
      });
    }
  }

  Future<void> _choose(int chosen) async {
    final item = _paper[_index];
    setState(() {
      _answers[item.itemNo] = chosen;
      _saving = true;
    });
    try {
      await _tests.answer(_start!.testId, item.itemNo, chosen);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That answer did not save. Tap it again.'),
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final s = await _tests.finish(_start!.testId);
      final b = await _tests.result(_start!.testId);
      final r = await _tests.review(_start!.testId);
      if (!mounted) return;
      setState(() {
        _score = s;
        _breakdown = b;
        _review = r;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'That test could not be marked.';
      });
    }
  }

  Future<void> _confirmLeave() async {
    if (_score != null) {
      Navigator.of(context).pop(true);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave the test?'),
        content: const Text(
          'Your answers are saved. Coming back opens the same paper at the '
          'first question you have not answered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final answered = _answers.length;
    final total = _paper.length;

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kCard,
        surfaceTintColor: kCard,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: kLine)),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kInk),
          tooltip: 'Leave the test',
          onPressed: _confirmLeave,
        ),
        title: Text(
          _score != null ? 'Your result' : widget.unit,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: kInk),
        ),
        actions: [
          if (_score == null && total > 0)
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Center(
                child: Text(
                  '$answered / $total',
                  style: TextStyle(fontSize: 13, color: kInkSoft),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
              child: _body(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 120),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _begin);
    }
    if (_score != null) return _results();
    if (_paper.isEmpty) {
      return const EmptyPrompt(message: 'This unit has no test yet.');
    }

    final item = _paper[_index];
    final chosen = _answers[item.itemNo];
    final isLast = _index + 1 >= _paper.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Question ${_index + 1} of ${_paper.length}  ·  '
                '${item.difficulty}',
                style: TextStyle(fontSize: 12, color: kInkSoft),
              ),
            ),
            if (_start!.isWarmup)
              Text(
                'warm-up',
                style: TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700, color: kHint),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (_index + 1) / _paper.length,
            minHeight: 5,
            backgroundColor: kTrack,
            valueColor: AlwaysStoppedAnimation<Color>(kAccent),
          ),
        ),
        const SizedBox(height: 16),
        QuestionCard(
          prompt: item.prompt,
          subtopic: item.subtopic,
          figure: item.figure,
        ),
        const SizedBox(height: 14),
        // Nothing here says whether the choice was right. An option a
        // student has picked simply looks picked, and stays changeable
        // until the paper is handed in.
        for (var i = 0; i < item.options.length; i++) ...[
          OptionTile(
            letter: String.fromCharCode(65 + i),
            option: item.options[i],
            isRuledOut: false,
            isFound: chosen == i,
            isFocused: false,
            enabled: !_saving,
            onTap: () => _choose(i),
          ),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            if (_index > 0) ...[
              OutlinedButton(
                onPressed: () => setState(() => _index--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAccentDeep,
                  side: BorderSide(color: kLine),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Back'),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: isLast
                  ? PrimaryButton(
                      label: 'Hand it in',
                      busy: _saving,
                      onPressed: _answers.length < _paper.length
                          ? null
                          : _finish,
                    )
                  : PrimaryButton(
                      label: 'Next',
                      onPressed: () => setState(() => _index++),
                    ),
            ),
          ],
        ),
        if (isLast && _answers.length < _paper.length) ...[
          const SizedBox(height: 10),
          Text(
            '${_paper.length - _answers.length} still unanswered. Use Back to '
            'find them.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: kHint),
          ),
        ],
      ],
    );
  }

  Widget _results() {
    final s = _score!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Text(
          '${s.scorePct}%',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: bandTextColour(bandForRate(s.scorePct)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${s.correct} of ${s.total} right'
          '${s.seconds >= 60 ? '  ·  ${s.seconds ~/ 60} min' : ''}'
          '${s.isWarmup ? '  ·  warm-up paper' : ''}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: kInkSoft),
        ),
        const SizedBox(height: 6),
        Text(
          'Your best score on a unit is the one that counts, so this can '
          'only go up. Take it again whenever you like.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
        ),
        const SizedBox(height: 26),
        // Two readings of the same paper. By band answers "is this hard for
        // me, or is this level hard for me" — a student at 90% on Easy and
        // 20% on Challenge has a very different problem from one at 55%
        // everywhere, and the subtopic list alone cannot tell them apart.
        if (_byBand().length > 1) ...[
          Text(
            'How the paper went by level',
            style: TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kInk,
            ),
          ),
          const SizedBox(height: 12),
          for (final e in _byBand())
            _LevelResultRow(level: e.level, got: e.got, asked: e.asked),
          const SizedBox(height: 24),
        ],
        Text(
          'Where the marks went',
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kInk,
          ),
        ),
        const SizedBox(height: 12),
        for (final b in _breakdown)
          _BreakdownRow(
            row: b,
            onLesson: b.lessonId == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonScreen(
                          lessonId: b.lessonId!,
                          lessons: widget.lessons,
                          course: widget.course,
                        ),
                      ),
                    ),
          ),
        if (_review.isNotEmpty) ...[
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showReview = !_showReview),
              icon: Icon(
                _showReview
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 20,
              ),
              label: Text(_showReview
                  ? 'Hide the questions'
                  : 'Go through the questions and answers'),
              style: TextButton.styleFrom(foregroundColor: kAccentDeep),
            ),
          ),
          if (_showReview) ...[
            // The review carries one row per item ANSWERED, not per item on
            // the paper — see test_review_answers.sql. Say so, rather than
            // letting a student who skipped four questions count eleven
            // rows and conclude the app lost them.
            if (_paper.isNotEmpty && _review.length < _paper.length) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Showing the ${_review.length} you answered. The '
                  '${_paper.length - _review.length} you left blank are not '
                  'here, and their answers stay unread.',
                  style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
                ),
              ),
            ],
            for (final r in _review) _ReviewRow(row: r),
          ],
        ],
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Take it again',
          busy: _saving,
          onPressed: _retake,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: kInkSoft),
          child: const Text('Back to the unit'),
        ),
      ],
    );
  }

  /// Correct and asked, per difficulty band, in the order a paper ramps.
  List<_BandTally> _byBand() {
    const order = ['Easy', 'Medium', 'Challenge', 'Advanced'];
    final got = <String, int>{};
    final asked = <String, int>{};
    for (final r in _review) {
      asked[r.difficulty] = (asked[r.difficulty] ?? 0) + 1;
      if (r.wasCorrect) got[r.difficulty] = (got[r.difficulty] ?? 0) + 1;
    }
    return [
      for (final level in order)
        if (asked.containsKey(level))
          _BandTally(level, got[level] ?? 0, asked[level]!),
    ];
  }

  /// A fresh paper on the same unit. Best score counts, so this can only
  /// ever help — which is exactly why the button says so on the way in.
  Future<void> _retake() async {
    setState(() {
      _score = null;
      _breakdown = const [];
      _review = const [];
      _showReview = false;
    });
    await _begin();
  }
}

/// One paper already sat, newest first.
class _TestHistoryRow extends StatelessWidget {
  final TestAttempt attempt;
  const _TestHistoryRow({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final band = bandForRate(attempt.scorePct);
    final when = attempt.finishedAt;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kLine),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              '${attempt.scorePct}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: bandTextColour(band),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${attempt.correct} of ${attempt.total}'
              '${attempt.isWarmup ? '  ·  warm-up' : ''}'
              '${attempt.seconds >= 60 ? '  ·  ${attempt.seconds ~/ 60} min' : ''}',
              style: TextStyle(fontSize: 12.5, color: kInkSoft),
            ),
          ),
          if (when != null)
            Text(
              '${when.day} ${_shortMonth(when.month)}',
              style: TextStyle(fontSize: 11.5, color: kInkSoft),
            ),
        ],
      ),
    );
  }
}

/// Dates read '9 Mar', never '3/9' — the admin screens already settled that
/// a numeric date is ambiguous between Canada and everywhere else.
String _shortMonth(int m) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][(m - 1).clamp(0, 11)];

class _BandTally {
  final String level;
  final int got;
  final int asked;
  const _BandTally(this.level, this.got, this.asked);
}

class _LevelResultRow extends StatelessWidget {
  final String level;
  final int got;
  final int asked;

  const _LevelResultRow({
    required this.level,
    required this.got,
    required this.asked,
  });

  @override
  Widget build(BuildContext context) {
    final pct = asked == 0 ? 0 : (100 * got / asked).round();
    final band = bandForRate(pct);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              level,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: kInk),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                children: [
                  Container(height: 9, color: kTrack),
                  FractionallySizedBox(
                    widthFactor: (pct / 100).clamp(0.0, 1.0),
                    child: Container(height: 9, color: bandColour(band)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 54,
            child: Text(
              '$got / $asked',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, color: kInkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// One question, after the paper is closed.
class _ReviewRow extends StatelessWidget {
  final TestReview row;
  const _ReviewRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: kLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                row.wasCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 17,
                color: row.wasCorrect ? kAccent : kWrong,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${row.itemNo}. ${row.subtopic}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: kInk),
                ),
              ),
              Text(
                row.difficulty,
                style: TextStyle(fontSize: 11.5, color: kInkSoft),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            row.prompt,
            style: TextStyle(fontSize: 13.5, height: 1.5, color: kInk),
          ),
          // The full breakdown, on a finished paper only. Every option, the
          // one that was tapped, the one that was right, and the mistake
          // behind each of the three that were not — including the two the
          // student did not choose, which are the two they may still be one
          // step away from choosing next time.
          if (row.hasAnswers) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < row.options.length; i++)
              _ReviewOptionRow(
                option: row.options[i],
                isCorrect: i == row.correctIndex,
                isChosen: i == row.chosenIndex,
              ),
          ] else ...[
            // A database that predates test_review_answers.sql. Show what
            // the old payload carried rather than an empty space.
            if (row.chosenText != null) ...[
              const SizedBox(height: 8),
              Text(
                'You chose: ${row.chosenText}',
                style: TextStyle(fontSize: 12.5, color: kInkSoft),
              ),
            ],
            if (row.feedback != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
                decoration: BoxDecoration(
                  color: kWarmTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kHint.withValues(alpha: 0.35)),
                ),
                child: Text(
                  row.feedback!,
                  style: TextStyle(fontSize: 12.5, height: 1.5, color: kHint),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// One option inside the end-of-test review.
///
/// Three states, and the word matters as much as the colour: an option is
/// marked "Answer", "Your answer", or both. A student who cannot tell green
/// from amber still reads which was which.
class _ReviewOptionRow extends StatelessWidget {
  final ReviewOption option;
  final bool isCorrect;
  final bool isChosen;

  const _ReviewOptionRow({
    required this.option,
    required this.isCorrect,
    required this.isChosen,
  });

  @override
  Widget build(BuildContext context) {
    // Right and chosen is one state, not two stacked on each other.
    final tint = isCorrect ? kAccent : (isChosen ? kWrong : kLine);
    final label = isCorrect
        ? (isChosen ? 'Your answer, and right' : 'Answer')
        : (isChosen ? 'You chose this' : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? kWash
            : (isChosen ? kWrongWash : Colors.transparent),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isCorrect || isChosen ? tint.withValues(alpha: 0.5) : kLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : (isChosen
                        ? Icons.cancel_rounded
                        : Icons.circle_outlined),
                size: 15,
                color: isCorrect ? kAccent : (isChosen ? kWrong : kLine),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontFamily: kSerif,
                    fontFamilyFallback: kSerifFallback,
                    fontSize: 13.5,
                    height: 1.45,
                    color: kInk,
                  ),
                ),
              ),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w800,
                    color: isCorrect ? kAccent : kWrong,
                  ),
                ),
              ],
            ],
          ),
          // The mistake this option comes from. Not shown on the right
          // answer, where the bank only ever says 'Correct.' and printing
          // that back would be filler.
          if (!isCorrect &&
              option.feedback != null &&
              option.feedback!.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: Text(
                option.feedback!,
                style: TextStyle(fontSize: 12, height: 1.5, color: kInkSoft),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final TestBreakdown row;
  final VoidCallback? onLesson;

  const _BreakdownRow({required this.row, required this.onLesson});

  @override
  Widget build(BuildContext context) {
    final band = bandForRate(row.pct);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: kLine),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: bandColour(band),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
                ),
                Text(
                  '${row.got} of ${row.asked}',
                  style: TextStyle(fontSize: 12, color: kInkSoft),
                ),
              ],
            ),
          ),
          if (onLesson != null)
            TextButton(
              onPressed: onLesson,
              style: TextButton.styleFrom(foregroundColor: kAccentDeep),
              child: const Text('Read it'),
            ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String prompt;

  /// Subtopic display name, shown as a quiet chip so the student knows what
  /// they are practising ('Solving by substitution'). Names the topic,
  /// never the answer.
  final String? subtopic;

  /// Figure path relative to the site root. When present, the image renders
  /// above the prompt; when it fails to load (old deploy, missing file) it
  /// collapses to nothing rather than showing a broken-image icon.
  final String? figure;

  const QuestionCard(
      {super.key, required this.prompt, this.subtopic, this.figure});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtopic != null && subtopic!.isNotEmpty) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: kLine),
              ),
              child: Text(
                subtopic!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: kInkSoft,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (figure != null && figure!.isNotEmpty) ...[
            // Fixed height on purpose: an image that pops in after the
            // options render shoves them downward at the exact moment a
            // student is aiming a tap. The space is reserved before the
            // bytes arrive, and a failed load says so instead of leaving a
            // geometry question silently missing its diagram.
            SizedBox(
              height: 230,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '${Uri.base.origin}/${figure!}',
                  fit: BoxFit.contain,
                  semanticLabel: 'Diagram for this question',
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : Container(color: kSurface),
                  errorBuilder: (context, error, stack) => Container(
                    color: kSurface,
                    alignment: Alignment.center,
                    child: Text(
                      'The diagram could not load — refresh to try again.',
                      style: TextStyle(fontSize: 12.5, color: kInkSoft),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            prompt,
            style: TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 21,
              height: 1.55,
              color: kInk,
            ),
          ),
        ],
      ),
    );
  }
}

/// One answer choice.
///
/// Stateful only to track the mouse, which matters on web: without a hover
/// state the four options look like a printed list rather than something you
/// can press.
class OptionTile extends StatefulWidget {
  final String letter;
  final AnswerOption option;
  final bool isRuledOut;
  final bool isFound;
  final bool isFocused;
  final bool enabled;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.letter,
    required this.option,
    required this.isRuledOut,
    required this.isFound,
    required this.isFocused,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool _hovering = false;

  /// Drop the hover when the option underneath changes.
  ///
  /// Flutter reuses a State object for the widget at the same position in a
  /// list, so the tile that was option C on question 2 is the same State
  /// that becomes option C on question 3. _hovering stayed true across that
  /// swap, and the next question opened with C already lit — the previous
  /// question's answer, shown as if the student had chosen it. On one
  /// question the carried-over letter happened to be the correct one.
  ///
  /// Fixed here rather than with a key on the three call sites, because a
  /// key fixes the callers that remember to use it and this fixes the
  /// widget.
  @override
  void didUpdateWidget(OptionTile old) {
    super.didUpdateWidget(old);
    if (old.option.text != widget.option.text) {
      _hovering = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hot = _hovering && widget.enabled;

    Color border = kLine;
    Color background = kCard;
    Color textColor = kInk;
    Color tokenBg = kSurface;
    Color tokenFg = kInkSoft;

    if (widget.isFound) {
      border = kAccent;
      background = kWash;
      tokenBg = kAccent;
      tokenFg = Colors.white;
    } else if (widget.isRuledOut) {
      border = kWrong.withValues(alpha: 0.30);
      background = kWrongWash;
      textColor = kInkSoft.withValues(alpha: 0.75);
      tokenBg = Colors.transparent;
      tokenFg = kInkSoft.withValues(alpha: 0.6);
    } else if (hot) {
      border = kAccent.withValues(alpha: 0.55);
      tokenBg = kAccent.withValues(alpha: 0.12);
      tokenFg = kAccent;
    }

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: _motion(context),
        curve: Curves.easeOut,
        // Lifting a couple of pixels on hover is the whole trick.
        transform: Matrix4.translationValues(0, hot ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: border,
            width: (widget.isFound || widget.isFocused) ? 2 : 1.2,
          ),
          boxShadow: hot ? kCardShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            borderRadius: BorderRadius.circular(13),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: _motion(context),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: tokenBg,
                      borderRadius: BorderRadius.circular(8),
                      border: widget.isRuledOut
                          ? Border.all(color: kWrongWash)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        widget.letter.replaceAll('.', ''),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: tokenFg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.option.text,
                      style: TextStyle(
                        fontFamily: kSerif,
                        fontFamilyFallback: kSerifFallback,
                        fontSize: 16.5,
                        height: 1.35,
                        color: textColor,
                        decoration: widget.isRuledOut
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: kInkSoft.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  if (widget.isFound)
                    Icon(Icons.check_rounded, size: 20, color: kAccent)
                  else if (widget.isRuledOut)
                    Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: kInkSoft.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The feedback panel — the point of the whole app, so it is the one piece
/// given a real entrance.
///
/// The ValueKey on the animation is what makes it replay: change the message
/// and Flutter builds a fresh builder, which restarts the tween. Without it
/// the panel would swap its text silently.
class FeedbackPanel extends StatelessWidget {
  final bool correct;
  final String message;

  const FeedbackPanel({
    super.key,
    required this.correct,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final accent = correct ? kAccent : kHint;

    return TweenAnimationBuilder<double>(
      key: ValueKey(message),
      tween: Tween(begin: 0, end: 1),
      duration: _motion(context, 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: correct ? kWash : kWarmTint,
          borderRadius: BorderRadius.circular(13),
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_outline_rounded,
                  size: 17,
                  color: accent,
                ),
                const SizedBox(width: 7),
                Text(
                  correct ? 'That is it' : 'Not this one',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              message,
              style: TextStyle(
                fontSize: 15.5,
                height: 1.55,
                color: kInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsView extends StatelessWidget {
  final String level;
  final int firstTry;
  final int total;
  final Medal medal;
  final VoidCallback onRestart;
  final VoidCallback onChangeUnit;

  const ResultsView({
    super.key,
    required this.level,
    required this.firstTry,
    required this.total,
    required this.medal,
    required this.onRestart,
    required this.onChangeUnit,
  });

  /// Said plainly, and never as praise the score does not support.
  String get _line {
    if (total == 0) return 'Nothing to score yet.';
    final share = firstTry / total;
    if (share == 1) return 'Every one on the first try.';
    if (share >= 0.7) return 'Most of them straight away.';
    if (share >= 0.4) return 'A solid run. The rest came with a second look.';
    return 'Worth another pass — the feedback is where the work is.';
  }

  /// What the next tier would take. Shown only when there is one, so a Gold
  /// is left alone rather than nagged.
  String? get _nextUp => switch (medal) {
        Medal.bronze => 'Silver needs 7 of $total on the first try.',
        // No hard-question clause any more: a level IS one difficulty, so
        // the percentage already says everything the old rule said.
        Medal.silver => 'Gold needs 9 of $total on the first try.',
        _ => null,
      };

  String get _medalLine => switch (medal) {
        Medal.gold => 'Gold — $level level is yours',
        Medal.silver => 'Silver earned on $level',
        Medal.bronze => 'Bronze earned — $level complete',
        Medal.none => '',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: kCardShadow,
          ),
          child: Column(
            children: [
              if (medal != Medal.none) ...[
                // The medal arrives a beat after the screen does, so it
                // reads as a reward rather than as part of the furniture.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: _motion(context, 520),
                  curve: Curves.elasticOut,
                  builder: (context, t, child) =>
                      Transform.scale(scale: t.clamp(0, 1.2), child: child),
                  child: MedalDot(medal: medal, size: 46),
                ),
                const SizedBox(height: 14),
                Text(
                  _medalLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 20),
              ] else
                Text(
                  'LEVEL COMPLETE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: kInkSoft.withValues(alpha: 0.9),
                  ),
                ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: firstTry.toDouble()),
                duration: _motion(context, 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${value.round()}',
                          style: TextStyle(
                            fontFamily: kSerif,
                            fontFamilyFallback: kSerifFallback,
                            fontSize: 54,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: kAccent,
                          ),
                        ),
                        TextSpan(
                          text: ' / $total',
                          style: TextStyle(
                            fontFamily: kSerif,
                            fontFamilyFallback: kSerifFallback,
                            fontSize: 24,
                            color: kInkSoft,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'answered correctly on the first try',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: kInkSoft),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: kLine),
              const SizedBox(height: 18),
              Text(
                _line,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5, color: kInk),
              ),
              if (_nextUp != null) ...[
                const SizedBox(height: 10),
                Text(
                  _nextUp!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: kInkSoft,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Try this unit again', onPressed: onRestart),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: onChangeUnit,
            child: const Text('Choose another unit'),
          ),
        ),
      ],
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSignOut;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.onSignOut,
  });

  /// A student should never read a database exception. This turns the common
  /// failures into a plain heading, a sentence about what to do, and a hint
  /// at whether waiting or refreshing is likely to help. The raw text is kept
  /// too, but folded away under "details" for whoever is maintaining this.
  ///
  /// Each case returns (heading, what the student can do).
  (String, String) get _plain {
    final m = message.toLowerCase();

    if (m.contains('duplicate key') || m.contains('profiles_pkey')) {
      return (
        'Almost there',
        'Your account is still being set up. Refreshing the page should '
            'finish it — this usually only happens once.',
      );
    }
    if (m.contains('failed host lookup') ||
        m.contains('socketexception') ||
        m.contains('connection') ||
        m.contains('network')) {
      return (
        'No connection',
        'The internet connection dropped. Check that you are online, then '
            'try again.',
      );
    }
    if (m.contains('jwt') ||
        m.contains('not signed in') ||
        m.contains('expired') ||
        m.contains('401')) {
      return (
        'Signed out',
        'You have been signed out, which usually just means it has been a '
            'while. Sign in again to carry on.',
      );
    }
    if (m.contains('no grade')) {
      return (
        'Account needs a grade',
        'This account was made before grades were added. Ask whoever set up '
            'the app to add your grade, or register again.',
      );
    }
    if (m.contains('subscription') || m.contains('astro+')) {
      return (
        'That level is part of Astro+',
        'Challenge and Advanced questions need an Astro+ subscription. Easy '
            'and Medium are always free.',
      );
    }
    // Anything not recognised: still no raw text up front.
    return (
      'That did not load',
      'Something went wrong loading this. Try again, and if it keeps '
          'happening, refreshing the page usually helps.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final (heading, guidance) = _plain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          decoration: BoxDecoration(
            color: kWrongWash,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: kWrong, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: kWrong,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      heading,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kWrong,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                guidance,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: kInk,
                ),
              ),
              // The raw error, folded away. A student can ignore it; whoever
              // maintains the app can expand it. Keeping it here means the
              // technical detail is never lost, only hidden.
              const SizedBox(height: 6),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 4),
                  title: Text(
                    'Technical details',
                    style: TextStyle(fontSize: 12, color: kInkSoft),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        message,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.45,
                          color: kInkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
        if (onSignOut != null) ...[
          const SizedBox(height: 6),
          TextButton(
            onPressed: onSignOut,
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Sign out'),
          ),
        ],
      ],
    );
  }
}

// ==========================================================================
// 9. THE REPORT
// ==========================================================================
// One page the student opens themselves, showing where they stand and what
// to work on next. It replaces the old weekly-email machinery entirely: the
// student pulls the report rather than having it pushed at a guardian, and
// decides who else sees it by generating a link.
//
// Everything here comes from one server call. The colour bands are computed
// in SQL, not in this file, so the bar chart and the mind map can never
// disagree about what "struggling" means.

/// How a unit is going, as the server judged it.
/// Five bands, traffic-signal style, worst to best. This is the uncle's
/// mindmap palette adopted across the whole report: grey (not enough
/// evidence) → orange (struggling) → yellow (developing) → light green
/// (nearing) → green (mastered).
///
/// The server decides the band (report_payload), from FIRST-TRY RATE and
/// never completion — a student who finished a unit by guessing has not
/// learned it. The old names 'amber' and 'red' are still parsed so a
/// payload from an undeployed database renders sensibly.
enum Band { grey, orange, yellow, lightGreen, green }

Band bandFrom(String? s) => switch (s) {
      'green' => Band.green,
      'light-green' => Band.lightGreen,
      'yellow' => Band.yellow,
      'orange' => Band.orange,
      // Legacy names from the four-band scheme.
      'amber' => Band.yellow,
      'red' => Band.orange,
      _ => Band.grey,
    };

/// The same cutoffs the server uses, for the handful of screens handed a
/// bare first-try percentage instead of a band — the admin's view of one
/// tutor's roster, mainly. Kept beside bandFrom on purpose: if the SQL
/// cutoffs ever move, these two are the pair that must move together.
///
/// A null rate is grey, not orange. Zero per cent and "has not started"
/// look alike as numbers and mean opposite things.
Band bandForRate(int? rate) {
  if (rate == null) return Band.grey;
  if (rate >= 90) return Band.green;
  if (rate >= 70) return Band.lightGreen;
  if (rate >= 50) return Band.yellow;
  return Band.orange;
}

/// Colour for a band, in the theme currently in force.
///
/// The traffic-signal palette, exactly as the mindmap design specifies it.
/// Deliberately not red-for-bad-only: orange and yellow mean "spend time
/// here", which is useful information, not a telling-off.
///
/// This used to be a switch over five compile-time constants, and that was
/// the single worst thing about the dark theme: dots, bars and branches all
/// kept their daylight values against a near-black page.
Color bandColour(Band b) => kPalette.bandFill[b.index];

// ---------------------------------------------------------------------------
// The progress ladder
// ---------------------------------------------------------------------------
//
// THE PROBLEM THIS FIXES
//
// One number was doing two jobs. A subtopic was banded purely on first-try
// rate, so two answers both right and seven answers all right rendered
// identically: 100%, top band, "Mastered". Accuracy was measured and
// coverage was not, and no amount of tuning the percentage fixes that,
// because the percentage is not the thing that is missing.
//
// So the ladder has two axes. Accuracy decides WHICH band. Coverage decides
// whether the top one is available at all.
//
// THE DENOMINATOR IS WHAT THE STUDENT CAN REACH
//
// 20 of the 40 questions in a unit are behind Astro+. Counting all 40 would
// mean a free student could answer everything available to them, perfectly,
// and never reach the top band, with nothing on screen to say why. The
// denominator is therefore the pool they can actually attempt — see
// my_reachable_pool in supabase/migrations/reachable_pool.sql — and the
// badge says what it covers. Paying enlarges the map rather than unlocking
// a badge.
//
// "COMPLETED", NOT "MASTERED"
//
// The word was invented here; the written spec says Completed, and that is
// the better word for what this now measures. "Completed" is a coverage
// claim, so gating it on coverage makes the label honest. "Mastered" was
// the strongest word available attached to the weakest evidence, which is
// how a two-question sample ended up wearing it.
//
// 90% RATHER THAN EVERYTHING RIGHT
//
// The spec says 90 and the spec wins. One slip in ten is humane for a
// fourteen-year-old, and first-try only happens once — a single careless
// tap on question 37 should not cost a topic its badge with no way back.
// The strictness lives in coverage instead, which is losable and regainable
// in a way a first try is not.

/// Where a subtopic stands. The order is the ladder.
enum Progress {
  notStarted,
  justStarted,
  needsWork,
  developing,
  nearlyThere,
  completed,
}

/// Too thin a sample to score. Two answers is not a percentage.
///
/// Unless two is all there is — see [looksNeededToScore].
const int kMinLooksToScore = 3;

/// How many first looks this subtopic needs before a percentage means
/// anything: three, OR the whole pool if the pool is smaller than three.
///
/// The second half is not a nicety, it is a bug fix found by counting the
/// real bank. Free accounts see Easy and Medium only, and 26 subtopics
/// across the six courses have exactly TWO questions at those levels. A
/// flat three-look guard makes those 26 permanently unscoreable for anyone
/// who has not paid: the student answers everything they are allowed to
/// answer and the row still reads "Just started", with nothing on the
/// screen to explain why and no action that would ever change it.
///
/// The guard exists to reject a thin SAMPLE of a pool. Two answers out of
/// seven is a thin sample. Two answers out of two is the whole pool, which
/// is the strongest evidence that subtopic can produce, not the weakest.
/// A pool that small scores coarsely — one slip is 50% — and that is an
/// honest limit of two questions rather than something to paper over.
int looksNeededToScore(int? reachable) =>
    (reachable != null && reachable > 0 && reachable < kMinLooksToScore)
        ? reachable
        : kMinLooksToScore;

/// Bands one subtopic.
///
/// [attempted] is first looks, [rate] the first-try percentage, [reachable]
/// how many questions in this subtopic the student may attempt on their
/// plan. A null or zero [reachable] means we do not know the pool, and the
/// top band is withheld rather than guessed at — better to under-claim than
/// to hand out a Completed nobody earned.
Progress progressFor({
  required int attempted,
  required int? rate,
  int? reachable,
}) {
  if (attempted <= 0) return Progress.notStarted;
  if (attempted < looksNeededToScore(reachable) || rate == null) {
    return Progress.justStarted;
  }
  if (rate < 50) return Progress.needsWork;
  if (rate < 70) return Progress.developing;

  // 70 and up. The only question left is whether the top band is earned,
  // and that is where coverage decides rather than accuracy.
  final seenItAll = reachable != null && reachable > 0 && attempted >= reachable;
  if (rate >= 90 && seenItAll) return Progress.completed;

  // Strong but not through it yet. This is the band that did not exist
  // before, and its absence is why a thin sample had nowhere to sit except
  // the top.
  return Progress.nearlyThere;
}

/// The same ladder one level up.
///
/// NOT an average of percentages. Averaging let a unit drift upward on
/// coverage alone and downward on nothing having been touched — one
/// subtopic at 100% against five never opened came out as "17%", a number
/// describing no student's experience.
///
/// A unit is as strong as its WEAKEST TOUCHED subtopic, and Completed only
/// when nothing is left. Two rules follow from that and both matter:
///
///   * untouched subtopics do not set the word. A plain minimum would call
///     a unit with five completed subtopics and one unopened one "Not
///     started", which is false about five sixths of the unit. What is
///     untouched shows as grey nodes and in the answered count, where it
///     belongs.
///   * but they DO block the top rung. Completed is a claim about the whole
///     unit, so anything unopened or unfinished holds it at Nearly there —
///     which is exactly the coverage-over-accuracy rule one level up.
Progress unitProgress(Iterable<Progress> subtopics) {
  final all = subtopics.toList();
  if (all.isEmpty) return Progress.notStarted;

  final touched = all.where((p) => p != Progress.notStarted).toList();
  if (touched.isEmpty) return Progress.notStarted;

  final weakest = touched.reduce((a, b) => a.index <= b.index ? a : b);
  if (weakest != Progress.completed) return weakest;

  // Everything touched is Completed. Whether the UNIT is depends on
  // whether anything is still untouched.
  return touched.length == all.length
      ? Progress.completed
      : Progress.nearlyThere;
}

String progressWord(Progress p) => switch (p) {
      Progress.notStarted => 'Not started',
      Progress.justStarted => 'Just started',
      Progress.needsWork => 'Needs work',
      Progress.developing => 'Developing',
      Progress.nearlyThere => 'Nearly there',
      Progress.completed => 'Completed',
    };

/// The band a Progress paints as, so the ladder reuses the palette that is
/// already measured for contrast in both themes rather than inventing a
/// seventh colour.
Band progressBand(Progress p) => switch (p) {
      Progress.notStarted => Band.grey,
      Progress.justStarted => Band.grey,
      Progress.needsWork => Band.orange,
      Progress.developing => Band.yellow,
      Progress.nearlyThere => Band.lightGreen,
      Progress.completed => Band.green,
    };

/// The words for an ACCURACY band on its own, where there is no coverage
/// to weigh and something else on the screen is carrying it.
///
/// One caller left: the Improve view's first-try bar, which sits beside its
/// own coverage bar reading "3/8 done", so the two halves are already
/// separate there and this only has to name the accuracy half.
///
/// Green is "Strong", NOT "Mastered". Mastered was a coverage claim being
/// made by a number that had never counted coverage, which is how a
/// two-question sample came to wear the strongest word in the app. The
/// ladder owns that claim now and spells it "Completed"; this vocabulary
/// deliberately has no top rung to hand out.
String bandWord(Band b) => switch (b) {
      Band.green => 'Strong',
      Band.lightGreen => 'Nearly there',
      Band.yellow => 'Developing',
      Band.orange => 'Needs work',
      Band.grey => 'No score yet',
    };

/// The variant for TEXT in a band colour. The fill palette above is tuned
/// for dots, bars and branches; as 11px text, yellow and light green
/// measure about 2.3:1 on white — well under the 4.5:1 readable floor.
/// Fills stay bright, words use these.
///
/// In the light theme these are DARKENED and in the dark theme they are
/// LIGHTENED, which is why this cannot be one set. Shipping the light set
/// into the dark put all five words between 2.55:1 and 3.01:1.
Color bandTextColour(Band b) => kPalette.bandText[b.index];

class LevelStat {
  final String level;
  final int total;
  final int solved;
  final int firstTry;
  final Medal medal;

  const LevelStat({
    required this.level,
    required this.total,
    required this.solved,
    required this.firstTry,
    required this.medal,
  });

  factory LevelStat.fromJson(Map<String, dynamic> j) => LevelStat(
        level: j['level'] as String,
        total: (j['total'] as num?)?.toInt() ?? 0,
        solved: (j['solved'] as num?)?.toInt() ?? 0,
        firstTry: (j['first_try'] as num?)?.toInt() ?? 0,
        medal: medalFromText(j['medal'] as String?),
      );
}

/// One subtopic node on the mindmap: the lesson-vocabulary label and its
/// own traffic band. Every subtopic in the bank appears, grey until the
/// student has actually looked at it — the map shows the whole course, not
/// just the visited part.
class SubtopicStat {
  final String tag;
  final String label;
  final int questions;
  final int firstLooks;
  final int? firstTryRate;
  final Band band;

  const SubtopicStat({
    required this.tag,
    required this.label,
    required this.questions,
    required this.firstLooks,
    required this.firstTryRate,
    required this.band,
  });

  factory SubtopicStat.fromJson(Map<String, dynamic> j) => SubtopicStat(
        tag: j['tag'] as String? ?? '',
        label: j['label'] as String? ?? '',
        questions: (j['questions'] as num?)?.toInt() ?? 0,
        firstLooks: (j['first_looks'] as num?)?.toInt() ?? 0,
        firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
        band: bandFrom(j['band'] as String?),
      );
}

class UnitStat {
  final String unit;
  final int total;
  final int solved;
  final int percentComplete;
  final int? firstTryRate;
  final Band band;
  final List<LevelStat> levels;
  final List<SubtopicStat> subtopics;

  const UnitStat({
    required this.unit,
    required this.total,
    required this.solved,
    required this.percentComplete,
    required this.firstTryRate,
    required this.band,
    required this.levels,
    required this.subtopics,
  });

  factory UnitStat.fromJson(Map<String, dynamic> j) => UnitStat(
        unit: j['unit'] as String,
        total: (j['total'] as num?)?.toInt() ?? 0,
        solved: (j['solved'] as num?)?.toInt() ?? 0,
        percentComplete: (j['percent_complete'] as num?)?.toInt() ?? 0,
        firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
        band: bandFrom(j['band'] as String?),
        levels: ((j['levels'] as List?) ?? [])
            .map((e) => LevelStat.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        subtopics: ((j['subtopics'] as List?) ?? [])
            .map((e) => SubtopicStat.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class WeakTopic {
  final String topic;
  final String unit;
  final int wrongTaps;

  const WeakTopic({
    required this.topic,
    required this.unit,
    required this.wrongTaps,
  });

  factory WeakTopic.fromJson(Map<String, dynamic> j) => WeakTopic(
        topic: j['topic'] as String? ?? '',
        unit: j['unit'] as String? ?? '',
        wrongTaps: (j['wrong_taps'] as num?)?.toInt() ?? 0,
      );
}

class ReportData {
  final String firstName;
  final int grade;
  final String course;
  final int questionsSeen;
  final int totalTaps;
  final int daysPractised;
  final int? firstTryRate;
  final DateTime? lastActive;
  final int gold;
  final int silver;
  final int bronze;
  final List<UnitStat> units;
  final List<WeakTopic> weakTopics;

  /// Best practice-test score per misconception tag.
  ///
  /// Empty until report_payload starts sending `test_scores`, which happens
  /// when the Test section ships. Empty and absent behave identically — a
  /// lookup misses and the topic falls back to its first-try rate — so this
  /// can be wired through the whole tree today and simply start carrying
  /// numbers later, with no second pass over the widgets.
  final Map<String, int> testScores;

  /// How many questions in each subtopic this student may ATTEMPT, keyed by
  /// tag, from my_reachable_pool().
  ///
  /// The denominator of the coverage half of the ladder, and deliberately
  /// not `SubtopicStat.questions`: that counts the whole bank including the
  /// half behind Astro+, so using it would put the top rung behind the
  /// paywall with nothing on screen to say why. Empty means the pool is
  /// unknown, and progressFor withholds the top rung rather than guessing.
  final Map<String, int> reachable;

  const ReportData({
    required this.firstName,
    required this.grade,
    required this.course,
    required this.questionsSeen,
    required this.totalTaps,
    required this.daysPractised,
    required this.firstTryRate,
    required this.lastActive,
    required this.gold,
    required this.silver,
    required this.bronze,
    required this.units,
    required this.weakTopics,
    this.testScores = const {},
    this.reachable = const {},
  });

  bool get hasWork => questionsSeen > 0;

  /// The same report with the two side numbers attached.
  ///
  /// Both arrive from their own functions rather than from report_payload,
  /// and that is deliberate: report_payload is a large, load-bearing thing
  /// covered by 212 checks, while my_percentages and my_reachable_pool each
  /// already compute exactly one of these and carry their own. Merging
  /// three results in the app is cheaper and safer than reshaping one of
  /// them in SQL.
  ///
  /// An omitted argument keeps what is already there, so a call that only
  /// knows one of them cannot silently blank the other.
  ReportData withSideNumbers({
    Map<String, int>? scores,
    Map<String, int>? reachable,
  }) =>
      ReportData(
        firstName: firstName,
        grade: grade,
        course: course,
        questionsSeen: questionsSeen,
        totalTaps: totalTaps,
        daysPractised: daysPractised,
        firstTryRate: firstTryRate,
        lastActive: lastActive,
        gold: gold,
        silver: silver,
        bronze: bronze,
        units: units,
        weakTopics: weakTopics,
        testScores: scores ?? testScores,
        reachable: reachable ?? this.reachable,
      );

  factory ReportData.fromJson(Map<String, dynamic> j) {
    final medals = Map<String, dynamic>.from(j['medals'] ?? const {});
    return ReportData(
      firstName: j['first_name'] as String? ?? 'Student',
      grade: (j['grade'] as num?)?.toInt() ?? 10,
      course: j['course'] as String? ?? '',
      questionsSeen: (j['questions_seen'] as num?)?.toInt() ?? 0,
      totalTaps: (j['total_taps'] as num?)?.toInt() ?? 0,
      daysPractised: (j['days_practised'] as num?)?.toInt() ?? 0,
      firstTryRate: (j['first_try_rate'] as num?)?.toInt(),
      lastActive: j['last_active'] == null
          ? null
          : DateTime.tryParse(j['last_active'] as String),
      gold: (medals['gold'] as num?)?.toInt() ?? 0,
      silver: (medals['silver'] as num?)?.toInt() ?? 0,
      bronze: (medals['bronze'] as num?)?.toInt() ?? 0,
      units: ((j['units'] as List?) ?? [])
          .map((e) => UnitStat.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      weakTopics: ((j['weak_topics'] as List?) ?? [])
          .map((e) => WeakTopic.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      testScores: ((j['test_scores'] as Map?) ?? const <String, dynamic>{})
          .map((k, v) => MapEntry(k as String, (v as num).toInt())),
    );
  }
}

class ReportRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<ReportData> mine() async {
    final row = await _db.rpc('my_report');
    final data = ReportData.fromJson(Map<String, dynamic>.from(row as Map));
    // Two independent round trips with nothing to say to each other, so
    // they go together. Awaiting them in sequence would put a whole extra
    // trip's latency on a screen that already waited for my_report.
    final side = await Future.wait([_testScores(), _reachablePool()]);
    return data.withSideNumbers(scores: side[0], reachable: side[1]);
  }

  /// Best test score per subtopic tag, from my_percentages.
  ///
  /// Keyed by TAG, which is what the topic map and the tree look up. A
  /// subtopic with no finished test simply misses the lookup and falls
  /// back to its first-try rate, which is why this can fail quietly: an
  /// empty map and an unreachable function produce the same, correct,
  /// screen.
  Future<Map<String, int>> _testScores() async {
    try {
      final rows = await _db.rpc('my_percentages') as List;
      final out = <String, int>{};
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final tag = row['tag'] as String?;
        final pct = (row['subtopic_pct'] as num?)?.toInt();
        if (tag != null && pct != null) out[tag] = pct;
      }
      return out;
    } catch (_) {
      return const {};
    }
  }

  /// How many questions per subtopic this student may attempt, from
  /// my_reachable_pool.
  ///
  /// Fails quiet for the same reason as the scores above, and the failure
  /// is safe in the right direction: an empty map means no subtopic can
  /// prove coverage, so the ladder tops out at "Nearly there" for everyone
  /// until the call works again. A broken read under-claims rather than
  /// handing out a Completed nobody earned.
  Future<Map<String, int>> _reachablePool() async {
    try {
      final rows = await _db.rpc('my_reachable_pool') as List;
      final out = <String, int>{};
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final tag = row['tag'] as String?;
        final open = (row['questions_open'] as num?)?.toInt();
        if (tag != null && open != null) out[tag] = open;
      }
      return out;
    } catch (_) {
      return const {};
    }
  }

  /// Reads a shared report by token. Callable without an account — the token
  /// is the authentication, which is why revoking has to work instantly.
  /// Returns null for a revoked or unknown link.
  Future<ReportData?> shared(String token) async {
    final row = await _db.rpc('shared_report', params: {'p_token': token});
    if (row == null) return null;
    final data = ReportData.fromJson(Map<String, dynamic>.from(row as Map));
    // The parent needs the same pool the student has, or their copy of the
    // report says different words about the same work — the child sees
    // "Completed" and the parent, reading the identical data, "Nearly
    // there". shared_reachable_pool is the same numbers behind the same
    // token. It fails quiet in the safe direction, like the student's.
    return data.withSideNumbers(reachable: await _sharedPool(token));
  }

  Future<Map<String, int>> _sharedPool(String token) async {
    try {
      final rows = await _db
          .rpc('shared_reachable_pool', params: {'p_token': token}) as List;
      final out = <String, int>{};
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final tag = row['tag'] as String?;
        final open = (row['questions_open'] as num?)?.toInt();
        if (tag != null && open != null) out[tag] = open;
      }
      return out;
    } catch (_) {
      return const {};
    }
  }

  /// The live share token, creating one on first use. Calling twice returns
  /// the same token, so a link already sent to a parent keeps working.
  Future<String> shareToken() async =>
      (await _db.rpc('my_share_token')) as String;

  Future<Map<String, dynamic>?> shareStatus() async {
    final rows = await _db.rpc('my_share_status');
    final list = rows as List;
    if (list.isEmpty) return null;
    return Map<String, dynamic>.from(list.first);
  }

  Future<String> reissue() async =>
      (await _db.rpc('revoke_and_reissue_share')) as String;

  Future<void> stopSharing() => _db.rpc('revoke_share');
}

// ==========================================================================
// Jokes
// ==========================================================================
// A joke before a level and another after it. They are not decoration: the
// moment before starting is when a student is most likely to close the tab,
// and the moment after finishing is when they decide whether this was
// pleasant enough to come back to.
//
// Kept groan-worthy on purpose. A joke that tries too hard to be cool ages
// badly; a pun about a hippopotenuse does not.

const List<String> kMathJokes = [
  'Why was the math book sad? It had a lot of problems.',
  'What is an algebra teacher\u2019s favourite animal? A hippopotenuse.',
  'What did one algebra book say to the other? Do not bother me, I have my own problems.',
  'What do you call friends who love maths? Alge-bros.',
  'What is a bird\u2019s favourite type of maths? Owl-gebra.',
  'Why does algebra make you a better dancer? Because you can use the algo-rhythm.',
  'Do you know who invented algebra? An x-pert.',
  'Why can you never trust an algebra teacher holding graph paper? They must be plotting something.',
  'Did you hear that old algebra teachers never die? They just lose some of their functions.',
  'What is a maths teacher\u2019s favourite season? Sum-mer.',
  'What is a butterfly\u2019s favourite subject at school? Mothematics.',
  'What is 2n plus 2n? I do not know, it sounds 4n to me.',
  'Why do mathematicians like parks? Because of all the natural logs.',
  'Why can you not trust a polynomial to stay the same? It has too many variables.',
  'How does a ghost solve a quadratic equation? By completing the scare.',
  'What do baby parabolas drink? Quadratic formula.',
  'Why do plants hate maths? It gives them square roots.',
  'Why did the hyperbola not feel sick? It was asymptote-matic.',
  'What do you call more than one L? Parallel.',
  'Why is it sad that parallel lines have so much in common? Because they will never meet.',
  'Why will Goldilocks not drink a glass of water with 8 pieces of ice in it? It is too cubed.',
  'Why did seven eat nine? Because you are supposed to eat 3 squared meals a day.',
  'Did you hear about the mathematician afraid of negative numbers? He will stop at nothing to avoid them.',
  'What did the zero say to the eight? Nice belt.',
  'Why did the two 4s skip lunch? They already 8.',
  'Why was 6 afraid of 7? Because 7 8 9.',
  'What did 2, 3, 5 and 7 have for dinner? Prime rib.',
  'Why should you never start a conversation with pi? It will just go on forever.',
  'Why did pi get its driving licence revoked? Because it did not know when to stop.',
  'What is the official animal of Pi day? The pi-thon.',
  'What was Isaac Newton\u2019s favourite dessert? Apple pi.',
  'What is the best way to visualise infinity? Using a pi chart.',
  'What did pi say in a fight with its brother? You are being irrational.',
];

/// A joke picked from the level and unit rather than at random, so a student
/// who reopens the same level sees the same joke instead of a slot machine.
String jokeFor(String seed) =>
    kMathJokes[seed.hashCode.abs() % kMathJokes.length];

/// A quiet strip of text with a small label. Used either side of a level.
class JokeStrip extends StatelessWidget {
  final String seed;
  final String label;

  const JokeStrip({super.key, required this.seed, this.label = 'Warm-up'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: BoxDecoration(
        color: kTrack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: kInkSoft,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            jokeFor(seed),
            style: TextStyle(fontSize: 13.5, height: 1.5, color: kInk),
          ),
        ],
      ),
    );
  }
}



/// The greeting on the way in. Time of day plus first name, and a line that
/// changes for somebody returning versus somebody arriving for the first
/// time — the difference between "welcome" and "welcome back" is small but
/// it is the difference between a tool and a place.
class WelcomeHeader extends StatelessWidget {
  final String name;
  final bool returning;

  const WelcomeHeader({
    super.key,
    required this.name,
    required this.returning,
  });

  String get _partOfDay {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    // First name only. A full name in a greeting reads like a summons.
    final first = name.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_partOfDay, $first',
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: kInk,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          returning
              ? 'Pick up where you left off, or start something new.'
              : 'Every wrong answer here tells you what went wrong. Start anywhere.',
          style: TextStyle(fontSize: 14, height: 1.5, color: kInkSoft),
        ),
      ],
    );
  }
}

/// The report page. One widget serves both the student and anyone holding a
/// share link: a visitor simply gets no shareControls, so they see the
/// numbers and nothing else. Keeping it as one widget is deliberate — two
/// copies would drift, and the shared view would eventually stop matching
/// what the student sees.
class ReportView extends StatelessWidget {
  final ReportData data;
  final Widget? shareControls;

  const ReportView({
    super.key,
    required this.data,
    this.shareControls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${data.firstName}\u2019s maths report',
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: kInk,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Grade ${data.grade}${data.course.isEmpty ? '' : ' \u00b7 ${data.course}'}',
          style: TextStyle(fontSize: 13.5, color: kInkSoft),
        ),

        if (!data.hasWork) ...[
          const SizedBox(height: 28),
          const EmptyPrompt(
            message: 'No practice yet. Answer a few questions and this page '
                'fills in.',
          ),
        ] else ...[
          const SizedBox(height: 22),
          _HeadlineRow(data: data),

          const SizedBox(height: 30),
          const _SectionTitle('Your topic map'),
          const SizedBox(height: 4),
          Text(
            'A subtopic\'s percentage is the share you get right first time. '
            'A unit\'s averages its subtopics, counting one you have not '
            'practised yet as nothing — so it climbs as you work through the '
            'whole unit instead of jumping to a single topic\'s score. Too '
            'little practice to judge shows a dash, never a nought, because '
            'those mean opposite things. Colours run orange (needs work) '
            'through yellow and light green to full green (mastered).',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 14),
          _TopicMapSection(
            units: data.units,
            centreLabel: 'Grade ${data.grade}',
            scores: data.testScores,
            reachable: data.reachable,
          ),

          const SizedBox(height: 30),
          const _SectionTitle('How far through each unit'),
          const SizedBox(height: 4),
          Text(
            'The bar is how much you have finished. The colour is how well it '
            'is going \u2014 based on first-try answers, not on how much you '
            'have done.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
          ),
          const SizedBox(height: 16),
          ...data.units.map((u) => _UnitBar(
                unit: u,
                scores: data.testScores,
                reachable: data.reachable,
              )),

          if (data.weakTopics.isNotEmpty) ...[
            const SizedBox(height: 30),
            const _SectionTitle('Worth practising'),
            const SizedBox(height: 4),
            Text(
              'The subtopics costing the most wrong taps.',
              style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
            ),
            const SizedBox(height: 12),
            ...data.weakTopics.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      // The same orange the bands use for "needs work",
                      // because that is exactly what this bullet means.
                      decoration: BoxDecoration(
                        color: bandColour(Band.orange),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        w.topic,
                        style: TextStyle(fontSize: 14, color: kInk),
                      ),
                    ),
                    Text(
                      w.unit,
                      style: TextStyle(fontSize: 11.5, color: kInkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],

        if (shareControls != null) ...[
          const SizedBox(height: 32),
          Divider(height: 1, color: kLine),
          const SizedBox(height: 20),
          shareControls!,
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: kSerif,
          fontFamilyFallback: kSerifFallback,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: kInk,
        ),
      );
}

/// The four numbers worth knowing at a glance.
class _HeadlineRow extends StatelessWidget {
  final ReportData data;
  const _HeadlineRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _StatTile(
        value: '${data.questionsSeen}',
        label: 'questions\nanswered',
      ),
      _StatTile(
        value: data.firstTryRate == null ? '\u2014' : '${data.firstTryRate}%',
        label: 'right on the\nfirst try',
      ),
      _StatTile(value: '${data.daysPractised}', label: 'days\npractised'),
      _StatTile(
        value: '${data.gold + data.silver + data.bronze}',
        label: 'medals\nearned',
      ),
    ];

    return LayoutBuilder(
      builder: (context, box) {
        // Two across on a phone, four on anything wider.
        final perRow = box.maxWidth < 420 ? 2 : 4;
        final rows = <Widget>[];
        for (var i = 0; i < tiles.length; i += perRow) {
          rows.add(Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (var j = i; j < i + perRow && j < tiles.length; j++) ...[
                  Expanded(child: tiles[j]),
                  if (j < i + perRow - 1 && j < tiles.length - 1)
                    const SizedBox(width: 10),
                ],
              ],
            ),
          ));
        }
        return Column(children: rows);
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: kInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, height: 1.35, color: kInkSoft),
          ),
        ],
      ),
    );
  }
}

/// One unit: a labelled progress bar tinted by its band, with the four
/// levels underneath as small segments so a locked or untouched level is
/// visible rather than averaged away.
class _UnitBar extends StatelessWidget {
  final UnitStat unit;
  final Map<String, int> scores;
  final Map<String, int> reachable;

  const _UnitBar({
    required this.unit,
    this.scores = const {},
    this.reachable = const {},
  });

  @override
  Widget build(BuildContext context) {
    final rung = unitLadder(unit, scores: scores, reachable: reachable);
    final band = progressBand(rung);
    final colour = bandColour(band);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unit.unit,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit.firstTryRate == null
                    ? progressWord(rung)
                    : '${unit.firstTryRate}% first try · '
                        '${progressWord(rung).toLowerCase()}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  // The word carries the meaning; the darker variant keeps
                  // it readable. Colour alone is never the message.
                  color: bandTextColour(band),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          // The bar itself.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 10, color: kTrack),
                FractionallySizedBox(
                  widthFactor: (unit.percentComplete / 100).clamp(0.0, 1.0),
                  child: Container(height: 10, color: colour),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${unit.solved} of ${unit.total} answered',
            style: TextStyle(fontSize: 11.5, color: kInkSoft),
          ),
        ],
      ),
    );
  }
}

/// A mind map of the units: a centre node with a branch to each unit,
/// coloured by band. Drawn rather than laid out, because the whole point is
/// seeing the shape of it at a glance.
/// The topic map, interactive. This is the uncle's mindmap design carried
/// into the report: a pannable, zoomable canvas with the course at the
/// centre, one branch per unit, and \u2014 on tapping a unit \u2014 its subtopics
/// fanning out beside it, each coloured by the student's own first-try
/// band. Nodes can be dragged if a label sits awkwardly; the layout resets
/// with the button in the corner.
///
/// The whole course is always on the map. A subtopic nobody has touched is
/// a grey node, which is the honest version of "not started" \u2014 hiding it
/// would make thin practice look complete.
// ---------------------------------------------------------------------------
// THE PERCENTAGE
// ---------------------------------------------------------------------------
//
// One number, defined once, so the map, the tree and the rail can never
// disagree about what "58%" means. The rule is Dileep's, adopted wholesale
// because it is better than showing coverage:
//
//   * a SUBTOPIC's percentage is how well it is going, not how much of it is
//     done — first-try rate, and null until there have been two first looks.
//     One lucky guess is not a score.
//   * a UNIT's percentage is the MEAN ACROSS ITS SUBTOPICS, counting an
//     untouched subtopic as zero. That is the whole trick: it climbs steadily
//     from 0 toward 100 as a student works through the unit, instead of
//     leaping to whatever the one subtopic they tried happened to score.
//   * a unit with NOTHING attempted returns null, and null must survive all
//     the way to the widget. A zero and an absence look identical in a chart
//     and mean opposite things — "you got none right" versus "you have not
//     started". Nothing is drawn for null.
//
// `override` is how practice-test scores take over later: once the Test
// section ships, my_percentages() supplies a best-test-score per tag and it
// is passed in here. The shape does not change, only the source, and both
// obey the same three rules above.

int? subtopicMastery(SubtopicStat s, {Map<String, int> override = const {}}) {
  final fromTest = override[s.tag];
  if (fromTest != null) return fromTest;
  if (s.firstLooks < 2) return null;
  return s.firstTryRate;
}

/// The ladder for one subtopic, from what the report already carries.
///
/// The bridge between the numbers and the rungs, and the only place the
/// two are joined, so the tree, the map and the summary cannot come to
/// different conclusions about the same subtopic.
Progress subtopicProgress(
  SubtopicStat s, {
  Map<String, int> scores = const {},
  Map<String, int> reachable = const {},
}) {
  // A finished practice test is a whole sample on its own, so it clears
  // the thin-sample guard that exists to stop two lucky taps reading as a
  // score. It does NOT clear coverage: a test samples the pool, it is not
  // the pool, so this never claims more looks than the guard needs.
  final open = reachable[s.tag];
  final needed = looksNeededToScore(open);
  final tested = scores.containsKey(s.tag);
  final attempted =
      tested && s.firstLooks < needed ? needed : s.firstLooks;

  return progressFor(
    attempted: attempted,
    rate: subtopicMastery(s, override: scores),
    reachable: open,
  );
}

/// The ladder for a whole unit, from its subtopics.
Progress unitLadder(
  UnitStat u, {
  Map<String, int> scores = const {},
  Map<String, int> reachable = const {},
}) =>
    unitProgress(u.subtopics.map(
      (s) => subtopicProgress(s, scores: scores, reachable: reachable),
    ));

int? unitMastery(UnitStat u, {Map<String, int> override = const {}}) {
  if (u.subtopics.isEmpty) return null;
  var touched = 0;
  var total = 0;
  for (final s in u.subtopics) {
    final pct = subtopicMastery(s, override: override);
    if (pct != null) {
      touched++;
      total += pct;
    }
  }
  if (touched == 0) return null;
  return (total / u.subtopics.length).round();
}

/// Map or list. The map is the better picture and the worse reference: it
/// shows a whole course at a glance and is hopeless for finding one topic,
/// and on a phone it is a pan-and-pinch canvas. The list is the opposite.
/// Neither replaces the other, so the student picks.
class _TopicMapSection extends StatefulWidget {
  final List<UnitStat> units;
  final String centreLabel;

  /// Best practice-test score per subtopic tag. Empty until the Test
  /// section starts producing them; the widgets below already honour it.
  final Map<String, int> scores;

  /// Questions this student may attempt per subtopic. The coverage half of
  /// the ladder; empty means unknown, which holds the top rung back.
  final Map<String, int> reachable;

  const _TopicMapSection({
    required this.units,
    required this.centreLabel,
    this.scores = const {},
    this.reachable = const {},
  });

  @override
  State<_TopicMapSection> createState() => _TopicMapSectionState();
}

class _TopicMapSectionState extends State<_TopicMapSection> {
  // The list, not the map, is the default. A student arriving at their
  // report wants to read where they stand; the map rewards exploring, which
  // is the second thing they do, not the first.
  int _view = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 208,
            child: SegmentedTabs(
              labels: const ['Map', 'List'],
              selected: _view,
              onSelect: (i) => setState(() => _view = i),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_view == 0)
          _MindMap(
            units: widget.units,
            centreLabel: widget.centreLabel,
            scores: widget.scores,
            reachable: widget.reachable,
          )
        else
          TopicTree(
            units: widget.units,
            scores: widget.scores,
            reachable: widget.reachable,
          ),
      ],
    );
  }
}

/// Every unit and every subtopic as rows, with the ladder and the counts.
///
/// Public, like SubjectSwitcher and SubtopicRow, for the same reason: this
/// is where the progress rules become words on a screen, and a rule tested
/// in isolation while the widget quietly reads something else is not
/// tested at all.
///
/// This is also the accessible half of the pair, and that is not a
/// side-effect. The mindmap's nodes are pointer-only — draggable, tappable,
/// unreachable by keyboard or screen reader — and the subtopic bands existed
/// nowhere else. Here they are text in a list, which anything can read.
class TopicTree extends StatefulWidget {
  final List<UnitStat> units;
  final Map<String, int> scores;
  final Map<String, int> reachable;

  const TopicTree({
    super.key,
    required this.units,
    this.scores = const {},
    this.reachable = const {},
  });

  @override
  State<TopicTree> createState() => TopicTreeState();
}

class TopicTreeState extends State<TopicTree> {
  final Set<String> _open = <String>{};

  @override
  void initState() {
    super.initState();
    // Open the unit that most needs attention, so the list arrives already
    // saying something rather than as a wall of closed rows. Weakest first,
    // and only if it has actually been started.
    //
    // By RUNG, then by percentage within a rung. Picking on the old unit
    // percentage alone opened whichever unit had been touched least, since
    // that number fell as coverage fell — so the row that sprang open was
    // usually the newest one rather than the one going worst.
    UnitStat? worst;
    Progress? worstRung;
    int? worstPct;
    for (final u in widget.units) {
      final rung =
          unitLadder(u, scores: widget.scores, reachable: widget.reachable);
      if (rung == Progress.notStarted) continue;
      final pct = unitMastery(u, override: widget.scores) ?? 100;
      if (worstRung == null ||
          rung.index < worstRung.index ||
          (rung == worstRung && pct < worstPct!)) {
        worstRung = rung;
        worstPct = pct;
        worst = u;
      }
    }
    if (worst != null) _open.add(worst.unit);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kLine),
        boxShadow: kCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: kCard,
        child: Column(
          children: [
            for (var i = 0; i < widget.units.length; i++)
              _UnitTreeRow(
                unit: widget.units[i],
                scores: widget.scores,
                reachable: widget.reachable,
                expanded: _open.contains(widget.units[i].unit),
                isLast: i == widget.units.length - 1,
                onToggle: () => setState(() {
                  final k = widget.units[i].unit;
                  if (!_open.remove(k)) _open.add(k);
                }),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnitTreeRow extends StatelessWidget {
  final UnitStat unit;
  final Map<String, int> scores;
  final Map<String, int> reachable;
  final bool expanded;
  final bool isLast;
  final VoidCallback onToggle;

  const _UnitTreeRow({
    required this.unit,
    required this.scores,
    required this.reachable,
    required this.expanded,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final rung = unitLadder(unit, scores: scores, reachable: reachable);
    final band = progressBand(rung);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Semantics carries the whole row as one sentence, because a screen
        // reader reading "Quadratics, 62, Developing, 24 of 40" as four
        // fragments tells a student almost nothing.
        Semantics(
          button: true,
          expanded: expanded,
          label: '${unit.unit}. ${progressWord(rung)}. '
              '${unit.solved} of ${unit.total} questions answered.',
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 13, 16, 13),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: _motion(context),
                    child: Icon(Icons.chevron_right,
                        size: 20, color: kInkSoft),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      unit.unit,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // The word, where a percentage used to be.
                  //
                  // That percentage was the mean over the unit's subtopics
                  // counting an untouched one as zero, so it moved on
                  // accuracy AND on coverage and told you which only if you
                  // knew the rule. One subtopic at 100% against five never
                  // opened read "17%", which describes nothing that
                  // happened to the student. The word carries the accuracy
                  // now and the count beside it carries the coverage, and
                  // neither is pretending to be the other. Subtopic rows,
                  // one tap away, still show real percentages, because
                  // there the number means one thing.
                  Flexible(
                    child: Text(
                      progressWord(rung),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: rung == Progress.notStarted
                            ? kInkSoft
                            : bandTextColour(band),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 78,
                    child: Text(
                      '${unit.solved}/${unit.total}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11.5, color: kInkSoft),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded)
          Container(
            color: kSurface,
            child: Column(
              children: [
                for (final s in unit.subtopics)
                  _SubtopicTreeRow(
                      stat: s, scores: scores, reachable: reachable),
                const SizedBox(height: 4),
              ],
            ),
          ),
        if (!isLast) Divider(height: 1, thickness: 1, color: kLine),
      ],
    );
  }
}

class _SubtopicTreeRow extends StatelessWidget {
  final SubtopicStat stat;
  final Map<String, int> scores;
  final Map<String, int> reachable;

  const _SubtopicTreeRow({
    required this.stat,
    required this.scores,
    required this.reachable,
  });

  @override
  Widget build(BuildContext context) {
    // The word and the colour come from the ladder, which knows about
    // coverage; the number beside them is still accuracy alone. That split
    // is the point — one of them cannot say both things.
    final rung = subtopicProgress(stat, scores: scores, reachable: reachable);

    // And the number obeys the ladder's guard, not its own. subtopicMastery
    // shows a percentage from two first looks; the guard needs three unless
    // the pool is smaller. Left alone those disagree by one answer and put
    // "100% · just started" on the screen, which is the original complaint
    // with a caption bolted on. Below the guard there is no number, which
    // is what "not enough to score yet" means.
    final pct = rung.index >= Progress.needsWork.index
        ? subtopicMastery(stat, override: scores)
        : null;
    final band = progressBand(rung);
    final open = reachable[stat.tag];

    return Semantics(
      label: '${stat.label}. '
          '${progressWord(rung)}.'
          '${pct == null ? '' : ' $pct per cent first try.'}'
          '${open == null ? '' : ' ${stat.firstLooks} of $open questions attempted.'}',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(44, 7, 16, 7),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: bandColour(band),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                stat.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: kInk),
              ),
            ),
            const SizedBox(width: 10),
            _MasteryPercent(pct: pct, band: band, big: false),
            const SizedBox(width: 10),
            SizedBox(
              width: 78,
              child: Text(
                progressWord(rung).toLowerCase(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  color: rung == Progress.notStarted ||
                          rung == Progress.justStarted
                      ? kInkSoft
                      : bandTextColour(band),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The number, or deliberately nothing.
///
/// A dash rather than "0%" when there is no score, and the dash is grey.
/// This is the third rule of the percentage doing its job in one widget: a
/// student who has not touched a topic must not be shown a zero, because a
/// zero reads as failure and the truth is simply that they have not been
/// there yet.
class _MasteryPercent extends StatelessWidget {
  final int? pct;
  final Band band;
  final bool big;

  const _MasteryPercent({
    required this.pct,
    required this.band,
    required this.big,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: big ? 44 : 38,
      child: Text(
        pct == null ? '—' : '$pct%',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: big ? 14 : 12.5,
          fontWeight: FontWeight.w800,
          color: pct == null
              ? bandTextColour(Band.grey)
              : bandTextColour(band),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The mindmap's leaf fan
// ---------------------------------------------------------------------------
//
// Out here rather than inside the State so it can be tested without pumping
// a widget. It is the piece of this screen most likely to be quietly wrong:
// an overlap shows up only on a unit with exactly the wrong number of
// subtopics, and only once that unit is expanded.

const double kLeafMaxSpanDeg = 230.0;
const double kLeafSpanPerGap = 34.0;
/// The floor on how far a leaf sits from its unit.
///
/// It only ever binds at a count of one, because the chord spacing below
/// puts every multi-leaf fan at 338 or more. At one it is the whole rule,
/// and 110 — the value carried over from the app this layout came from —
/// was not enough: half a unit node is 115 and half a subtopic node is 97,
/// so a single leaf directly outward needs 212 to clear its own parent and
/// was landing on top of it instead.
const double kLeafMinRadius = 220.0;

/// How far a unit sits off the spine, and how far its leaf fan tilts away
/// from it. Out here with the leaf layout for the same reason: the property
/// that matters — no leaf crossing the spine into the other wing — is
/// arithmetic, and arithmetic should be testable without pumping a widget.
const double kRibY = 190.0;
const double kFanTiltDeg = 82.0;

/// The subtopic counts this geometry is solved for.
///
/// Checked against the live bank rather than guessed: all 40 units have
/// between four and seven subtopics (three have 4, twenty have 5, fifteen
/// have 6, two have 7). At rib 190 and tilt 82 every fan in that range
/// clears the spine with 58px to spare.
///
/// EIGHT IS WHERE IT GIVES OUT, at any tilt. A fan of eight spreads the
/// full 230 degrees, and a 230-degree spray around a point wraps back on
/// itself however you rotate it — no angle keeps all of it on one side. A
/// unit with eight subtopics would put a leaf or two over the spine. Not
/// broken, just less tidy, and it would want the span capped or a second
/// rank of leaves rather than a bigger number here.
const List<int> kRealSubtopicCounts = [4, 5, 6, 7];

/// NOT safe to shorten. Because alternating leaves sit closer in, the
/// tightest pair is not always the two immediate neighbours, so this cannot
/// be reasoned about from the angular step alone — it has to be checked
/// against the node's own box, at every count. test/widget_test.dart does
/// exactly that, and fails below this value.
const double kLeafTargetChord = 225.0;

/// Where each of [count] subtopics sits relative to its unit: an angle off
/// the outward direction, and a radius.
///
/// The arc widens with the count, so two subtopics stay near each other
/// rather than being flung to the far top and bottom of the available space,
/// the way a small cluster of real leaves would. Radius is whatever keeps
/// neighbours [kLeafTargetChord] apart at that angular spacing. Alternating
/// leaves sit slightly closer in, which is what stops the ring reading as a
/// drawn circle.
List<({double angleDeg, double radius})> mindmapLeafLayout(int count) {
  if (count <= 0) return const [];
  if (count == 1) return const [(angleDeg: 0.0, radius: kLeafMinRadius)];

  final span = math.min(kLeafMaxSpanDeg, kLeafSpanPerGap * (count - 1));
  final angleStep = span / (count - 1);
  final spacingRad = angleStep * math.pi / 180;
  final radius = math.max(
    kLeafMinRadius,
    kLeafTargetChord / (2 * math.sin(spacingRad / 2)),
  );
  return [
    for (var i = 0; i < count; i++)
      (
        angleDeg: -span / 2 + i * angleStep,
        radius: radius * (i.isEven ? 1.0 : 0.88),
      ),
  ];
}

/// How far a fan of [count] leaves reaches outward from its unit, and back
/// toward the root. Used to space units along a row so one unit's fan can
/// never reach into its neighbour's.
({double towardRoot, double outward}) mindmapFanReach(int count) {
  if (count <= 0) return (towardRoot: 0, outward: 0);
  var outward = 0.0, towardRoot = 0.0;
  for (final leaf in mindmapLeafLayout(count)) {
    // angleDeg is relative to outward, so this is the same on either side
    // and can be computed once, unsigned.
    final x = leaf.radius * math.cos(leaf.angleDeg * math.pi / 180);
    outward = math.max(outward, x);
    towardRoot = math.max(towardRoot, -x);
  }
  return (towardRoot: towardRoot, outward: outward);
}

class _MindMap extends StatefulWidget {
  final List<UnitStat> units;
  final String centreLabel;

  /// The same two maps the tree gets. The map and the list are two views of
  /// one set of facts, so they read the ladder from the same inputs — a
  /// node that is green here and a row that says "developing" there would
  /// be the original bug wearing a different hat.
  final Map<String, int> scores;
  final Map<String, int> reachable;

  /// How tall the canvas is. The report embeds the map in a scrolling page
  /// and gives it a fixed strip; the topics pane hands it the whole area.
  final double? height;

  /// Whether the map starts dormant behind a tap-to-wake scrim. True inside
  /// the scrolling report, where a live InteractiveViewer is a scroll trap.
  /// False when the map IS the page and there is nothing to scroll past.
  final bool sleepUntilTapped;

  /// Open this unit in the app, in a named section.
  ///
  /// Null in the report, where the constellation is a picture of how things
  /// are going rather than a way in.
  final void Function(String unit, String section)? onOpenUnit;

  const _MindMap({
    required this.units,
    required this.centreLabel,
    this.scores = const {},
    this.reachable = const {},
    this.height,
    this.sleepUntilTapped = true,
    this.onOpenUnit,
  });

  @override
  State<_MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<_MindMap> {
  // A large fixed logical canvas the map lives on. Nodes are positioned
  // freely within it and the InteractiveViewer pans and zooms around it.
  // Bigger than any real course needs, because a canvas that runs out is a
  // node that cannot be dragged where the student wants it.
  static const _canvas = Size(4400, 4400);
  static const _centre = Offset(2200, 2200);

  // Units grow outward from the root toward the left and right margins in a
  // roughly horizontal row, the way a horizontal mind map's primary
  // branches do. Only the subtopics branch vertically.
  static const _unitOffsetX = 300.0;

  // ---- the fishbone ------------------------------------------------------
  //
  // Units alternate above and below a horizontal spine rather than sitting
  // on it. That is not decoration, it is what buys the zoom.
  //
  // In a straight line every unit has to clear its neighbour horizontally,
  // so the step is half a node plus a gap plus half a node: 380px. Six
  // units came out 2,120px wide, and fit-to-content had to zoom a long way
  // out to get that on screen, which is why the labels were small and the
  // whole thing read as a scatter.
  //
  // Off a spine, neighbours are separated vertically, so only units at the
  // SAME level need horizontal clearance and those are two steps apart.
  // The step halves to 175, six units come out 1,300px, and the map is
  // 1.63x narrower for exactly the same content. Same nodes, more zoom.
  //
  // The step is set against the node's ACTUAL width, which is 290 now that
  // the node carries a labelled Open pill rather than a 17px icon. 175 was
  // right for the 230px node and leaves only 60px between two same-level
  // nodes at 290; 200 leaves 110px. Widening the node without moving this
  // would have shipped an overlap.
  //
  // Still 1.51x narrower than the straight line, which is the zoom.
  static const _spineStep = 200.0;
  static const _ribY = kRibY;
  // How far along the spine the rib leans as it rises. Roughly a 40 degree
  // bone, which is what reads as a fishbone rather than a comb.
  static const _ribSweep = 95.0;
  // How far the leaf fan tilts off horizontal.
  //
  // Nearly perpendicular to the spine, pointing away from it, because a
  // fan is WIDE: five subtopics spread 136 degrees and eight spread 230.
  // At a shallow tilt the near half of that swings back down across the
  // spine and tangles with the wing on the other side. At 68 the whole
  // fan stays on its own side of the bone, which is both correct and what
  // the barbs of a fishbone actually look like.
  static const _fanTiltDeg = kFanTiltDeg;
  // The gap either side of an open fan. Wider than the collapsed step,
  // because an expanded unit is a fan of nodes rather than one node.
  static const _fanGap = 110.0;

  // Subtopics fan out around their unit like leaves around a branch tip
  // rather than stacking in a column to one side. They spread across an arc
  // centred on the "outward" direction — away from the root — widening as
  // there are more of them, with the cone back toward the root left clear
  // so nothing crosses the line to the parent.
  static const _minZoom = 0.18;
  static const _maxZoom = 2.2;

  final TransformationController _transform = TransformationController();

  /// Centre of every visible node in canvas coordinates. Dragging a node
  /// just overwrites its entry.
  final Map<String, Offset> _positions = {};
  final Set<String> _expanded = {};
  bool _laidOut = false;
  bool _canvasGestures = true;
  Size _viewport = Size.zero;

  late bool _awake = !widget.sleepUntilTapped;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Layout
  // -------------------------------------------------------------------------

  /// How far a unit's leaf fan reaches outward, and back toward the root.
  /// Used to give each unit in a row just enough room that its fan can
  /// never reach into its neighbour's.
  ({double towardRoot, double outward}) _fanReach(int unitIndex) =>
      mindmapFanReach(widget.units[unitIndex].subtopics.length);

  /// Where each unit's rib meets the spine. The painter draws the spine
  /// between these and a bone from each to its unit, which is what makes
  /// the shape legible as one structure rather than a scatter of pills.
  final Map<String, Offset> _ribAnchors = {};

  /// Units the student has dragged. Their position is theirs now, and the
  /// row layout below leaves them alone — a layout that snaps a node back
  /// after somebody deliberately moved it is a layout arguing with its user.
  final Set<String> _moved = {};

  /// Lays the units out as ONE horizontal row, evenly, and re-lays them
  /// whenever what is on screen changes.
  ///
  /// The first version spaced every unit by its LEAF FAN, expanded or not.
  /// So a collapsed constellation reserved room for subtopics nobody could
  /// see, and the gaps were uneven because they depended on how many
  /// subtopics each unit happened to have: on a real six-unit course the
  /// gaps came out 257px then 423px between nodes only 230px wide. It read
  /// as a sparse scatter rather than a row.
  ///
  /// Now a collapsed unit reserves room for a unit, and an expanded one
  /// reserves room for its fan. Expanding pushes its neighbours outward to
  /// make space, which is both the correct layout and the most satisfying
  /// thing this screen does.
  void _layoutRow() {
    _positions['root'] = _centre;

    // Alternating sides, so the two wings stay about the same length.
    final right = <int>[];
    final left = <int>[];
    for (var i = 0; i < widget.units.length; i++) {
      (i.isEven ? right : left).add(i);
    }

    void placeSide(List<int> side, double sign) {
      if (side.isEmpty) return;
      var cursorX = _centre.dx + sign * _unitOffsetX;
      var previousOutward = 0.0;
      for (var i = 0; i < side.length; i++) {
        final open = _expanded.contains('u${side[i]}');
        final reach = open
            ? _fanReach(side[i])
            : (towardRoot: 0.0, outward: 0.0);

        if (i > 0) {
          // An open unit needs its whole fan cleared. A shut one only has
          // to clear the node beside it, and because the fishbone puts
          // that node on the other side of the spine, one step does it.
          cursorX += sign *
              (open || previousOutward > 0
                  ? previousOutward + _fanGap + reach.towardRoot
                  : _spineStep);
        }

        // The rib. A fishbone's bones do not stand perpendicular to the
        // spine, they sweep back from it — so the unit sits both ABOVE (or
        // below) its attachment point and further OUT along the spine.
        // That sweep is the whole difference between a fishbone and two
        // rows of nodes with a line between them.
        //
        // The two wings START ON OPPOSITE SIDES, which is what makes the
        // shape read as deliberate. With both wings opening upward, three
        // units a side comes out two-up-one-down twice: six bones, four of
        // them above the spine, and the whole thing looks like it fell that
        // way. Mirrored, any count is balanced and the figure is
        // symmetrical through the root.
        final up = sign > 0 ? i.isEven : i.isOdd;
        final rib = up ? -_ribY : _ribY;

        final id = 'u${side[i]}';
        _ribAnchors[id] = Offset(cursorX, _centre.dy);
        if (!_moved.contains(id)) {
          _positions[id] =
              Offset(cursorX + sign * _ribSweep, _centre.dy + rib);
        }
        previousOutward = reach.outward;
      }
    }

    placeSide(right, 1);
    placeSide(left, -1);
  }

  void _ensureLayout() {
    if (_laidOut) return;
    _laidOut = true;
    _layoutRow();
  }

  /// Re-places a unit's leaves around its CURRENT position, overwriting
  /// whatever was there. Used after the row reflows, because a leaf that
  /// stayed put while its unit moved is a leaf hanging off nothing.
  void _replaceSubtopicPositions(int unitIndex) {
    for (var i = 0; i < widget.units[unitIndex].subtopics.length; i++) {
      _positions.remove('u$unitIndex-s$i');
    }
    _ensureSubtopicPositions(unitIndex);
  }

  void _ensureSubtopicPositions(int unitIndex) {
    final unit = widget.units[unitIndex];
    final unitPos = _positions['u$unitIndex']!;
    final sign = unitPos.dx >= _centre.dx ? 1.0 : -1.0;

    // The fan points along the bone, continuing away from the spine, rather
    // than straight out horizontally. A unit sitting above the spine throws
    // its leaves up and out; one below throws them down and out. Leaves
    // that all fanned horizontally would cross the spine and tangle with
    // the wing on the other side of it.
    final above = unitPos.dy < _centre.dy;
    final outwardDeg = (sign > 0 ? 0.0 : 180.0) +
        (above ? -_fanTiltDeg : _fanTiltDeg) * sign;

    final leaves = mindmapLeafLayout(unit.subtopics.length);
    for (var i = 0; i < unit.subtopics.length; i++) {
      final id = 'u$unitIndex-s$i';
      if (_positions.containsKey(id)) continue;
      final angleRad = (outwardDeg + leaves[i].angleDeg) * math.pi / 180;
      _positions[id] = unitPos +
          Offset(
            leaves[i].radius * math.cos(angleRad),
            leaves[i].radius * math.sin(angleRad),
          );
    }
  }

  // -------------------------------------------------------------------------
  // View
  // -------------------------------------------------------------------------

  /// Fits everything currently visible into the viewport at once — the root,
  /// every unit, and the subtopics of every expanded unit.
  ///
  /// Called after the first layout, after every expand and collapse, after a
  /// resize, and from Reset view. Each of those is a moment where what needs
  /// to be on screen just changed, which is exactly when refitting is right
  /// and any other time it would be the map moving under the student's hand.
  void _fitToContent() {
    // Reached from a post-frame callback, which can outlive the widget.
    if (!mounted || _viewport == Size.zero) return;
    final root = _positions['root'];
    if (root == null) return;

    var minX = root.dx, maxX = root.dx, minY = root.dy, maxY = root.dy;
    void include(Offset? p) {
      if (p == null) return;
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }

    for (var i = 0; i < widget.units.length; i++) {
      include(_positions['u$i']);
      if (!_expanded.contains('u$i')) continue;
      for (var sIndex = 0;
          sIndex < widget.units[i].subtopics.length;
          sIndex++) {
        include(_positions['u$i-s$sIndex']);
      }
    }

    // Padding around the bounding box of node CENTRES, so the widest boxes
    // do not end up flush against the edge. Nodes are much wider than they
    // are tall, so they need less room above and below.
    const padX = 170.0;
    const padY = 90.0;
    final contentW = (maxX - minX) + padX * 2;
    final contentH = (maxY - minY) + padY * 2;
    final centre = Offset((minX + maxX) / 2, (minY + maxY) / 2);

    final scale = math
        .min(contentW > 0 ? _viewport.width / contentW : _maxZoom,
            contentH > 0 ? _viewport.height / contentH : _maxZoom)
        .clamp(_minZoom, _maxZoom);

    setState(() {
      _transform.value = Matrix4.identity()
        ..translateByDouble(_viewport.width / 2 - centre.dx * scale,
            _viewport.height / 2 - centre.dy * scale, 0, 1)
        // Scaling z as well as x and y matters: getMaxScaleOnAxis takes the
        // max across all three, so leaving z at 1 makes it impossible to
        // read a scale below 1 back out — and the drag maths below divides
        // by exactly that value.
        ..scaleByDouble(scale, scale, scale, 1);
    });
  }

  void _toggleUnit(int i) {
    setState(() {
      if (_expanded.contains('u$i')) {
        _expanded.remove('u$i');
      } else {
        _expanded.add('u$i');
      }
      // Re-space the row for what is now on screen, then place this unit's
      // leaves around wherever it ended up. Order matters: the fan hangs
      // off the unit, so the unit has to move first.
      _layoutRow();
      for (var u = 0; u < widget.units.length; u++) {
        if (_expanded.contains('u$u')) _replaceSubtopicPositions(u);
      }
    });
    _fitToContent();
  }

  /// Back to the map a student sees on first opening the course: every unit
  /// collapsed, every node back where the layout put it, fitted to the
  /// viewport. The one button that undoes any amount of dragging.
  void _resetView() {
    setState(() {
      _positions.clear();
      _ribAnchors.clear();
      _expanded.clear();
      // Including everything the student dragged. That is the whole point
      // of the button: one tap undoes any amount of rearranging.
      _moved.clear();
      _laidOut = false;
      _ensureLayout();
    });
    _fitToContent();
  }

  /// Drags a unit together with every subtopic already placed under it,
  /// expanded or not, so the whole branch moves as one piece the way it
  /// would in a real mindmap instead of leaving its leaves behind.
  void _moveUnit(int unitIndex, Offset delta) {
    final scale = _transform.value.getMaxScaleOnAxis();
    final scaled = delta / scale;
    setState(() {
      // From here on this unit is where the student put it. Its bone comes
      // off the spine at that point too — dropping the anchor lets the
      // painter fall back to a curve from the root, which is the honest
      // drawing once a node is no longer where the layout put it.
      _moved.add('u$unitIndex');
      _ribAnchors.remove('u$unitIndex');
      _positions['u$unitIndex'] = _positions['u$unitIndex']! + scaled;
      for (var i = 0; i < widget.units[unitIndex].subtopics.length; i++) {
        final id = 'u$unitIndex-s$i';
        final pos = _positions[id];
        if (pos != null) _positions[id] = pos + scaled;
      }
    });
  }

  /// Drags the WHOLE constellation by its centre.
  ///
  /// The centre used to take the default node drag, which moved only its own
  /// position. Everything else stayed: the rib anchors are laid out from the
  /// canvas centre and never moved, and the painter draws the spine through
  /// the ROOT while drawing the bones from those anchors. So pulling the
  /// title away slid the pill and the spine off on their own and left the
  /// units and topics behind — the figure came apart, which is exactly what
  /// it looked like.
  ///
  /// A centre is not a thing you reposition relative to its own diagram;
  /// there is no arrangement where the middle of a fishbone sits somewhere
  /// else. So it is a handle for the whole figure instead, and everything
  /// travels with it — nodes, leaves and anchors alike.
  void _moveEverything(Offset delta) {
    final scale = _transform.value.getMaxScaleOnAxis();
    final scaled = delta / scale;
    setState(() {
      for (final id in _positions.keys.toList()) {
        _positions[id] = _positions[id]! + scaled;
      }
      // The anchors are canvas coordinates like the rest, so they move too.
      // Leaving them behind is the whole bug, one layer down.
      for (final id in _ribAnchors.keys.toList()) {
        _ribAnchors[id] = _ribAnchors[id]! + scaled;
      }
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _ensureLayout();
    return LayoutBuilder(
      builder: (context, box) {
        final height = widget.height ?? 380;
        final size = Size(box.maxWidth, height);
        if (size != _viewport) {
          _viewport = size;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _fitToContent());
        }
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: kLine),
                  ),
                  // Zoom is InteractiveViewer's own: pinch on a trackpad,
                  // scroll on a wheel. A second Cmd/Ctrl+scroll handler was
                  // written for this and then taken out again — the viewer
                  // already reacts to the same tick, so both would apply a
                  // zoom to it and compound.
                  child: InteractiveViewer(
                    transformationController: _transform,
                    constrained: false,
                    panEnabled: _awake && _canvasGestures,
                    scaleEnabled: _awake && _canvasGestures,
                    minScale: _minZoom,
                    maxScale: _maxZoom,
                    boundaryMargin: const EdgeInsets.all(800),
                    child: SizedBox(
                      width: _canvas.width,
                      height: _canvas.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MindMapEdgePainter(
                                positions: _positions,
                                ribAnchors: _ribAnchors,
                                units: widget.units,
                                expanded: _expanded,
                              ),
                            ),
                          ),
                          ..._buildNodes(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Dormant state: a transparent layer that absorbs the first
              // tap, wakes the map, and until then lets the page scroll
              // straight over it.
              if (!_awake)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _awake = true),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kCard.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: kInk.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Tap to explore the map',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: kCard),
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                right: 8,
                top: 8,
                child: Material(
                  color: kCard.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Reset the view',
                    onPressed: _resetView,
                    icon: Icon(Icons.center_focus_strong_rounded,
                        size: 19, color: kInkSoft),
                  ),
                ),
              ),

              if (_awake)
                Positioned(
                  left: 12,
                  bottom: 10,
                  child: Text(
                    'Drag to pan, or to move a topic. Pinch or scroll to '
                    'zoom. Tap a unit to open its subtopics.',
                    style: TextStyle(fontSize: 10.5, color: kInkSoft),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildNodes() {
    final nodes = <Widget>[];

    void addNode(
      String id,
      Widget child, {
      VoidCallback? onTap,
      void Function(Offset delta)? onDrag,
    }) {
      final pos = _positions[id];
      if (pos == null) return;
      nodes.add(_MapNode(
        position: pos,
        onDragStart: () => setState(() => _canvasGestures = false),
        onDragUpdate: onDrag ??
            (delta) {
              final scale = _transform.value.getMaxScaleOnAxis();
              setState(() => _positions[id] = _positions[id]! + delta / scale);
            },
        onDragEnd: () => setState(() => _canvasGestures = true),
        onTap: onTap,
        child: child,
      ));
    }

    addNode(
      'root',
      Tooltip(
        message: 'Drag to move the whole constellation',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: kAccentSurface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: kCardShadow,
          ),
          child: Text(
            widget.centreLabel,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: kOnAccent),
          ),
        ),
      ),
      onDrag: _moveEverything,
    );

    for (var i = 0; i < widget.units.length; i++) {
      final unit = widget.units[i];
      final rung = unitLadder(unit,
          scores: widget.scores, reachable: widget.reachable);
      final colour = bandColour(progressBand(rung));
      final open = _expanded.contains('u$i');
      addNode(
        'u$i',
        Semantics(
          button: true,
          expanded: open,
          label: '${unit.unit}, ${progressWord(rung).toLowerCase()}',
          child: Container(
            constraints: const BoxConstraints(maxWidth: 290),
            padding: const EdgeInsets.fromLTRB(13, 7, 7, 7),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colour, width: 2),
              boxShadow: kCardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: colour, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    unit.unit,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: kInk),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                    open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 15,
                    color: kInkSoft),
                // The constellation is a way in, not only a picture. But
                // opening a unit is a separate, deliberate tap from
                // spreading it out to look at, so tapping the node itself
                // only ever expands.
                //
                // The menu goes straight to a SECTION rather than to the
                // unit's default one. From a map of how you are doing, the
                // useful next move is usually "read this one" or "drill
                // this one", and making the student land on Quiz and then
                // navigate again would waste the thing the map just told
                // them.
                if (widget.onOpenUnit != null) ...[
                  const SizedBox(width: 2),
                  PopupMenuButton<String>(
                    tooltip: 'Open ${unit.unit}',
                    padding: EdgeInsets.zero,
                    position: PopupMenuPosition.under,
                    color: kCard,
                    // A 17px icon is not an affordance, it is a smudge. This
                    // is a labelled pill in the accent colour, because the
                    // whole point of the constellation is that a node is a
                    // way in and nobody was finding the way in.
                    // `child`, not `icon`. PopupMenuButton wraps an `icon`
                    // in an IconButton, which imposes its own square sizing
                    // and centring on what it is given — fine for a glyph,
                    // wrong for a pill, and the reason the label sat off
                    // centre. `child` is rendered as handed over.
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(11, 5, 8, 5),
                      decoration: BoxDecoration(
                        color: kAccentSurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Open',
                              // The default is a hair above centre next to
                              // a glyph this size, because the text box is
                              // taller than the ink and the arrow is not.
                              strutStyle: const StrutStyle(
                                  forceStrutHeight: true, height: 1),
                              style: TextStyle(
                                  fontSize: 11,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  color: kOnAccent)),
                          const SizedBox(width: 1),
                          Icon(Icons.arrow_drop_down_rounded,
                              size: 15, color: kOnAccent),
                        ],
                      ),
                    ),
                    constraints: const BoxConstraints(minWidth: 176),
                    onSelected: (section) =>
                        widget.onOpenUnit!(unit.unit, section),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        enabled: false,
                        height: 30,
                        child: Text(
                          unit.unit.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: kInkSoft),
                        ),
                      ),
                      for (final s in kSections)
                        PopupMenuItem(
                          value: s.$1,
                          height: 40,
                          child: Row(
                            children: [
                              Icon(s.$3, size: 17, color: kInkSoft),
                              const SizedBox(width: 10),
                              Text(s.$2,
                                  style:
                                      TextStyle(fontSize: 13.5, color: kInk)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        onTap: () => _toggleUnit(i),
        onDrag: (delta) => _moveUnit(i, delta),
      );

      if (!open) continue;
      for (var sIndex = 0; sIndex < unit.subtopics.length; sIndex++) {
        final sub = unit.subtopics[sIndex];
        final subRung = subtopicProgress(sub,
            scores: widget.scores, reachable: widget.reachable);
        final subColour = bandColour(progressBand(subRung));
        final subOpen = widget.reachable[sub.tag];
        addNode(
          'u$i-s$sIndex',
          Tooltip(
            // Says both halves, because the node's colour is now a verdict
            // on both. "80% first try, 3 of 6 answered" is the whole story
            // in the space the percentage alone used to take.
            message: '${sub.label} — ${progressWord(subRung).toLowerCase()}'
                '${sub.firstTryRate == null ? '' : ', ${sub.firstTryRate}% first try'}'
                '${subOpen == null ? '' : ', ${sub.firstLooks} of $subOpen answered'}',
            child: Container(
              constraints: const BoxConstraints(maxWidth: 175),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: subColour.withValues(alpha: 0.8), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: subColour, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      sub.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: kInk),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return nodes;
  }
}

/// A draggable, tappable node on the mindmap canvas, centred on [position].
///
/// Raw Listener rather than GestureDetector, deliberately: the node sits
/// inside an InteractiveViewer whose own pan/scale recognizer competes with
/// \u2014 and can swallow \u2014 a descendant's tap and pan in the gesture arena.
/// Listener bypasses the arena, so we tell tap from drag ourselves and
/// switch the viewer's panning off the instant a node-drag starts.
class _MapNode extends StatefulWidget {
  final Offset position;
  final VoidCallback onDragStart;
  final void Function(Offset delta) onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback? onTap;
  final Widget child;

  const _MapNode({
    required this.position,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
    this.onTap,
  });

  @override
  State<_MapNode> createState() => _MapNodeState();
}

class _MapNodeState extends State<_MapNode> {
  // A real mouse click carries a few pixels of jitter between press and
  // release; a tight threshold would misread an intended tap as a drag and
  // silently swallow it.
  static const _tapThreshold = 12.0;
  double _moved = 0;
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    // Animated, and the animation earns its place: expanding a unit pushes
    // its neighbours outward to make room, and a jump-cut would read as the
    // constellation being rebuilt rather than opening. 240ms is long enough
    // to follow and short enough not to be waited on.
    //
    // A drag has to be instant, though, or the node lags the finger — so
    // the duration collapses to zero while one is in progress.
    return AnimatedPositioned(
      duration: (_active || MediaQuery.disableAnimationsOf(context))
          ? Duration.zero
          : const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      left: widget.position.dx,
      top: widget.position.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {
              _moved = 0;
              _active = true;
              widget.onDragStart();
            },
            onPointerMove: (e) {
              if (!_active) return;
              _moved += e.delta.distance;
              widget.onDragUpdate(e.delta);
            },
            onPointerUp: (_) {
              if (!_active) return;
              _active = false;
              widget.onDragEnd();
              if (_moved < _tapThreshold) widget.onTap?.call();
            },
            onPointerCancel: (_) {
              if (!_active) return;
              _active = false;
              widget.onDragEnd();
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// The curved branches, coloured by band, drawn under the nodes.
class _MindMapEdgePainter extends CustomPainter {
  final Map<String, Offset> positions;
  final Map<String, Offset> ribAnchors;
  final List<UnitStat> units;
  final Set<String> expanded;

  _MindMapEdgePainter({
    required this.positions,
    required this.ribAnchors,
    required this.units,
    required this.expanded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final root = positions['root'];
    if (root == null) return;

    // THE SPINE.
    //
    // One straight line through the root, reaching the outermost rib on
    // each side. It is what turns a set of curves into a fishbone: without
    // it the ribs read as unrelated branches and the eye has nothing to
    // follow. Drawn first, and drawn faintly, because it is the armature
    // rather than the content.
    var minX = root.dx, maxX = root.dx;
    for (final anchor in ribAnchors.values) {
      if (anchor.dx < minX) minX = anchor.dx;
      if (anchor.dx > maxX) maxX = anchor.dx;
    }
    if (maxX > minX) {
      canvas.drawLine(
        Offset(minX, root.dy),
        Offset(maxX, root.dy),
        Paint()
          ..color = kInkSoft.withValues(alpha: 0.28)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < units.length; i++) {
      final unitPos = positions['u$i'];
      if (unitPos == null) continue;
      final colour = bandColour(units[i].band);

      // THE BONE, curved. It leaves the spine along the spine's own
      // direction and arrives at the unit along the unit's, so the join at
      // each end is tangent rather than a corner and the whole figure
      // reads as one drawn line.
      //
      // Straight was the first version and it was correct without being
      // nice: six hard angles off a straight spine looked like a technical
      // diagram rather than a constellation. The leaves were already
      // curved, so the two kinds of connection now differ by weight — 3
      // against 2 — and by the node at the spine, which is a better
      // distinction than one being stiff.
      final anchor = ribAnchors['u$i'];
      if (anchor != null) {
        _bone(canvas, anchor, unitPos, colour);
        // A small node where the bone meets the spine, so the join reads as
        // deliberate rather than as two lines happening to touch.
        canvas.drawCircle(
            anchor, 3.5, Paint()..color = colour.withValues(alpha: 0.7));
      } else {
        // A dragged unit has no anchor on the spine any more, so fall back
        // to the old curve from the root. It still connects to something.
        _curve(canvas, root, unitPos, colour, 3.5);
      }

      if (!expanded.contains('u$i')) continue;
      for (var s = 0; s < units[i].subtopics.length; s++) {
        final subPos = positions['u$i-s$s'];
        if (subPos == null) continue;
        _curve(canvas, unitPos, subPos,
            bandColour(units[i].subtopics[s].band), 2);
      }
    }
  }

  /// The bone: a quarter turn out of the spine and up to the unit.
  ///
  /// Not the same curve as the leaves. _curve below leaves and arrives
  /// HORIZONTALLY, which suits a leaf because a leaf sits out to the side
  /// of its unit. A bone travels 95px across and 190px up, and a
  /// horizontal-to-horizontal S over that shape folds back on itself and
  /// reads as a zigzag rather than a sweep.
  ///
  /// So this one leaves along the SPINE and arrives along the unit's
  /// vertical: tangent to the spine at the bottom, tangent to the node at
  /// the top, one clean quarter turn between them.
  void _bone(Canvas canvas, Offset spine, Offset unit, Color colour) {
    final path = Path()
      ..moveTo(spine.dx, spine.dy)
      ..cubicTo(
        // Out along the spine first.
        spine.dx + (unit.dx - spine.dx) * 0.62, spine.dy,
        // Then straight up into the unit.
        unit.dx, unit.dy + (spine.dy - unit.dy) * 0.62,
        unit.dx, unit.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = colour.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _curve(
      Canvas canvas, Offset start, Offset end, Color colour, double width) {
    final paint = Paint()
      ..color = colour.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final midX = (start.dx + end.dx) / 2;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MindMapEdgePainter old) => true;
}


/// The student's own report, with the sharing controls attached.
/// The four sections: id, label and icon, defined ONCE.
///
/// This list existed twice already, spelled out in the collapsed rail strip
/// and again in the topic popup menu, and the How to use page made a third
/// copy that promptly disagreed with both — it taught a Test icon the app
/// never shows. A help page that draws different symbols than the interface
/// is worse than no help page, because it is confidently wrong.
///
/// The order is the order the tabs appear in, so anything built from this
/// reads the same way round as the thing it describes.
const List<(String, String, IconData)> kSections = [
  ('learn', 'Learn', Icons.menu_book_rounded),
  ('quiz', 'Quiz', Icons.edit_note_rounded),
  ('improve', 'Improve', Icons.auto_fix_high_rounded),
  ('test', 'Test', Icons.fact_check_rounded),
];

// ---------------------------------------------------------------------------
// How to use
// ---------------------------------------------------------------------------
//
// Reachable from the header on every screen, because the moment somebody
// needs this is the moment they are already lost, and a help page filed
// under Profile is a help page for people who are not lost.
//
// It explains the things the interface cannot say for itself: what the four
// sections are FOR, and what the progress words mean. The second one earns
// its place. "Completed" now requires having attempted every question a
// student can reach as well as getting 90% of them right first time, and a
// rule that strict is unfair if it is never stated. A student who cannot
// see why a topic will not turn green concludes the app is broken.

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        surfaceTintColor: kSurface,
        elevation: 0,
        foregroundColor: kInk,
        title: const Text('How to use Astro STEM Labs',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              Text(
                'Everything here is practice. Nothing is a school mark, '
                'nobody is timing you, and a wrong answer is the most useful '
                'thing that can happen, because every one of them explains '
                'the mistake before it shows you the answer.',
                style: TextStyle(fontSize: 15.5, height: 1.6, color: kInk),
              ),
              const SizedBox(height: 26),

              const _HelpHeading('The four ways to work on a topic'),
              const _HelpNote(
                'Pick a topic first, then choose how you want to work on it. '
                'The four tabs sit at the top of the topic.',
              ),
              // Icons and order both come from kSections, so this cannot
              // teach a symbol the app does not draw.
              for (final section in kSections)
                _HelpRow(
                  icon: section.$3,
                  title: section.$2,
                  body: _sectionHelp[section.$1]!,
                ),

              const SizedBox(height: 26),
              const _HelpHeading('Classroom and Constellation'),
              // No icons on this pair, unlike the four sections above.
              //
              // The sections have icons because the app draws those exact
              // icons on their tabs, so the page is naming something the
              // student can see. Classroom and Constellation are chosen
              // from a segmented switch that has NO icons, so inventing two
              // here would teach symbols the interface never shows — the
              // same mistake the Test row made and the reason kSections
              // exists.
              //
              // Separately and worth writing down: Icons.dashboard_rounded
              // and Icons.hub_rounded, which is what this pair had, drew
              // NOTHING in the web build. Both codepoints are present in
              // the bundled MaterialIcons font and it is not icon
              // tree-shaking, because --no-tree-shake-icons renders them
              // exactly the same. I could not explain it. If an icon ever
              // comes out blank here, that is the shape of the problem, and
              // swapping it for one the app already draws is the workaround
              // that worked.
              const _HelpRow(
                title: 'Classroom',
                body: 'The list. Better for finding one topic and getting on '
                    'with it.',
              ),
              const _HelpRow(
                title: 'Constellation',
                body: 'The whole course as one picture, every unit and every '
                    'subtopic, coloured by how it is going. Better for seeing '
                    'where you stand. Tap a unit to open its subtopics, drag '
                    'anything to move it, drag the title in the middle to '
                    'move the whole thing, and use Reset view to put it all '
                    'back.',
              ),
              const _HelpNote(
                'The switch is in the bar at the top, so you can go and look '
                'at the constellation without losing your place.',
              ),

              const SizedBox(height: 26),
              const _HelpHeading('What the progress words mean'),
              const _HelpNote(
                'Two different things decide these: how much of a topic you '
                'have attempted, and how much of it you get right first try. '
                'A high score on two questions is not the same as a high '
                'score on all of them, so the words say both.',
              ),
              for (final rung in Progress.values)
                _HelpRung(rung: rung),
              const _HelpNote(
                'Completed needs every question you can open, not just a good '
                'score, which is why a topic can sit on Nearly there while '
                'reading 100%. It means there is more of it to see.',
              ),

              const SizedBox(height: 26),
              const _HelpHeading('Sharing it with a parent'),
              const _HelpNote(
                'My report makes a private link you can send to a parent or '
                'guardian. They see how you are getting on without needing an '
                'account. You can see how many times it has been opened, and '
                'you can stop the link working at any moment. Nobody gets a '
                'link unless you make one.',
              ),

              const SizedBox(height: 26),
              const _HelpHeading('Astro+'),
              const _HelpNote(
                'Every topic is open without paying. Astro+ adds the harder '
                'two levels of each one, Challenge and Advanced. It makes the '
                'course bigger rather than unlocking anything you have '
                'already earned, and the progress words work the same way on '
                'both: they measure the questions you can actually open.',
              ),

              const SizedBox(height: 26),
              const _HelpHeading('If something goes wrong'),
              const _HelpNote(
                'Tell us. A page that will not load or a question that looks '
                'wrong is worth reporting, and it is the fastest way for it '
                'to get fixed.',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => showContactSheet(context),
                  icon: const Icon(Icons.mail_outline_rounded, size: 18),
                  label: const Text('Contact us'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What each section is FOR, keyed by the same id kSections uses, so a
/// section without an explanation fails loudly at the lookup rather than
/// quietly rendering a gap.
const Map<String, String> _sectionHelp = {
  'learn': 'The explanation, worked through one step at a time. Start here '
      'if a topic is new, or come back to it when something stops making '
      'sense.',
  'quiz': 'One question at a time, with feedback straight away. This is '
      'where most of the work happens and where your progress comes from.',
  'improve': 'The whole course sorted by what is costing you marks. It looks '
      'across every topic, so it is the place to go when you do not know '
      'what to practise next.',
  'test': 'A set of questions with no feedback until the end, so you find '
      'out what you can do without help. Afterwards you can review every '
      'question and see what went wrong.',
};

class _HelpHeading extends StatelessWidget {
  final String text;
  const _HelpHeading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: kSerif,
            fontFamilyFallback: kSerifFallback,
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: kInk,
          ),
        ),
      );
}

class _HelpNote extends StatelessWidget {
  final String text;
  const _HelpNote(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, height: 1.6, color: kInkSoft),
        ),
      );
}

class _HelpRow extends StatelessWidget {
  /// Null draws no icon AND no gap where one would have been, rather than
  /// an empty 32px indent that reads as a picture that failed to load.
  final IconData? icon;
  final String title;
  final String body;

  const _HelpRow({
    this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 16, 14),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kLine),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: kAccent),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: TextStyle(
                          fontSize: 13.5, height: 1.55, color: kInkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

/// One rung of the ladder, drawn in its own colour.
///
/// Generated from Progress.values rather than written out, so this page
/// cannot fall out of step with the rule. A new rung appears here the day it
/// is added, which is the only version of this that stays true.
class _HelpRung extends StatelessWidget {
  final Progress rung;
  const _HelpRung({required this.rung});

  static String _meaning(Progress p) => switch (p) {
        Progress.notStarted => 'You have not opened this one yet.',
        Progress.justStarted =>
          'You have answered one or two. Not enough to score fairly, so '
              'there is no percentage yet.',
        Progress.needsWork =>
          'Under half right first try. Worth going back to Learn.',
        Progress.developing => 'Between half and about two thirds first try.',
        Progress.nearlyThere =>
          'Going well, but there are questions in here you have not seen.',
        Progress.completed =>
          'You have attempted every question you can open, and got at least '
              '90% of them right first try.',
      };

  @override
  Widget build(BuildContext context) {
    final band = progressBand(rung);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: bandColour(band),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${progressWord(rung)}. ',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: bandTextColour(band),
                    ),
                  ),
                  TextSpan(
                    text: _meaning(rung),
                    style: TextStyle(
                        fontSize: 13.5, height: 1.55, color: kInkSoft),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyReportScreen extends StatefulWidget {
  const MyReportScreen({super.key});

  @override
  State<MyReportScreen> createState() => _MyReportScreenState();
}

class _MyReportScreenState extends State<MyReportScreen> {
  final _repo = ReportRepository();
  ReportData? _data;
  String? _token;
  int _views = 0;
  bool _loading = true;
  String? _error;
  bool _busy = false;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.mine();
      final status = await _repo.shareStatus();
      if (!mounted) return;
      setState(() {
        _data = data;
        _token = status?['token'] as String?;
        _views = (status?['view_count'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _loading = false;
      });
    }
  }

  String get _shareUrl => '${Uri.base.origin}/?report=$_token';

  Future<void> _createLink() async {
    setState(() => _busy = true);
    try {
      final t = await _repo.shareToken();
      if (!mounted) return;
      setState(() {
        _token = t;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = friendlyError(e);
      });
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shareUrl));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _newLink() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Make a new link?', style: TextStyle(fontSize: 17)),
        content: const Text(
          'The old link stops working straight away. Anyone you gave it to '
          'will not be able to open your report until you send them the new '
          'one.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kInkSoft),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Make a new link'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    final t = await _repo.reissue();
    if (!mounted) return;
    setState(() {
      _token = t;
      _views = 0;
      _busy = false;
    });
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    await _repo.stopSharing();
    if (!mounted) return;
    setState(() {
      _token = null;
      _views = 0;
      _busy = false;
    });
  }

  Widget _shareControls() {
    if (_token == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Share this report'),
          const SizedBox(height: 6),
          Text(
            'Make a link you can send to a parent, a tutor, or a friend. They '
            'do not need an account \u2014 they just open the link.',
            style: TextStyle(fontSize: 13, height: 1.55, color: kInkSoft),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: _busy ? null : _createLink,
              child: Text(_busy ? '\u2026' : 'Create a share link'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Share this report'),
        const SizedBox(height: 6),
        Text(
          _views == 0
              ? 'Your link is live. Nobody has opened it yet.'
              : 'Your link is live. Opened $_views ${_views == 1 ? 'time' : 'times'}.',
          style: TextStyle(fontSize: 13, height: 1.55, color: kInkSoft),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: kTrack,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableText(
            _shareUrl,
            style: TextStyle(fontSize: 12, height: 1.4, color: kInk),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _copied ? null : _copy,
                  child: Text(_copied ? 'Copied' : 'Copy link'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _busy ? null : _newLink,
              style: TextButton.styleFrom(foregroundColor: kInkSoft),
              child: const Text('New link'),
            ),
            TextButton(
              onPressed: _busy ? null : _stop,
              style: TextButton.styleFrom(foregroundColor: kWrong),
              child: const Text('Stop'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Anyone with the link can see this page, so only send it to people '
          'you want reading it. It shows your first name, not your full name, '
          'and never your email. Stop or replace it any time.',
          style: TextStyle(fontSize: 11.5, height: 1.5, color: kInkSoft),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kInk,
        title: const Text('My report', style: TextStyle(fontSize: 17)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _error != null
                        ? ErrorView(message: _error!, onRetry: _load)
                        : ReportView(
                            data: _data!,
                            shareControls: _shareControls(),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// What somebody sees when they open a share link. No account, no sign-in,
/// and no way from here into the rest of the app — this page is the whole
/// visit.
class SharedReportScreen extends StatefulWidget {
  final String token;
  const SharedReportScreen({super.key, required this.token});

  @override
  State<SharedReportScreen> createState() => _SharedReportScreenState();
}

class _SharedReportScreenState extends State<SharedReportScreen> {
  ReportData? _data;
  bool _loading = true;
  bool _dead = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ReportRepository().shared(widget.token);
      if (!mounted) return;
      setState(() {
        _data = d;
        _dead = d == null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dead = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _dead
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              Text(
                                'This link is no longer active',
                                style: TextStyle(
                                  fontFamily: kSerif,
                                  fontFamilyFallback: kSerifFallback,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: kInk,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'The student may have replaced it or turned '
                                'sharing off. Ask them for a new link.',
                                style: TextStyle(
                                    fontSize: 14, height: 1.55, color: kInkSoft),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              ReportView(data: _data!),
                              Divider(height: 1, color: kLine),
                              const SizedBox(height: 14),
                              Text(
                                'Shared from Astro STEM Labs. This page was '
                                'shared by the student and can be turned off '
                                'by them at any time.',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.5,
                                    color: kInkSoft),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}