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
//   correct_index is sent to the browser, so it is readable in the network
//   tab. When that matters, the fix is a Postgres function called via .rpc()
//   that grades on the server instead.
//
//   No password reset flow yet. Supabase supports it through
//   auth.resetPasswordForEmail; it needs a screen building.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

const Color kAccent = Color(0xFF2F6F62); // teal, the one strong colour
const Color kAccentDeep = Color(0xFF20514A); // pressed and hover states
const Color kWrong = Color(0xFFC0392B);
const Color kHint = Color(0xFFB9791C);
const Color kSurface = Color(0xFFF6F5F1); // page background
const Color kInk = Color(0xFF1E2422); // headings and answers
const Color kInkSoft = Color(0xFF6E7772); // labels, captions, hints
const Color kLine = Color(0xFFE2E0D9); // hairline, warm to match the cream

/// Cards float instead of being fenced in. Two layers: a wide soft one for
/// the lift, a tight dark one so the edge stays crisp.
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0x0F1E2422), blurRadius: 20, offset: Offset(0, 6)),
  BoxShadow(color: Color(0x0A1E2422), blurRadius: 2, offset: Offset(0, 1)),
];

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
const Map<int, String> kGradeCourses = {
  9: 'MTH1W — Mathematics',
  10: 'MPM2D — Principles of Mathematics',
  11: 'MCR3U — Functions',
  12: 'MHF4U — Advanced Functions',
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

  bool get isHard => difficulty == 'Hard';

  const Question({
    required this.courseCode,
    required this.unit,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.sortOrder,
    this.misconceptionTag,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        courseCode: json['course_code'] as String,
        unit: json['unit'] as String,
        difficulty: json['difficulty'] as String,
        prompt: json['prompt'] as String,
        sortOrder: json['sort_order'] as int,
        misconceptionTag: json['misconception_tag'] as String?,
        options: (json['options'] as List<dynamic>)
            .map((o) => AnswerOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}

/// A class, as its teacher sees it.
class ClassInfo {
  final int id;
  final String name;
  final int grade;
  final String joinCode;
  final int students;
  final int invited;
  final int activeToday;

  const ClassInfo({
    required this.id,
    required this.name,
    required this.grade,
    required this.joinCode,
    this.students = 0,
    this.invited = 0,
    this.activeToday = 0,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> j) => ClassInfo(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        grade: (j['grade'] as num).toInt(),
        joinCode: j['join_code'] as String,
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

  const RosterEntry({
    required this.studentId,
    required this.name,
    required this.email,
    required this.unitsMedalled,
    required this.gold,
    required this.questionsSeen,
    required this.firstTryRate,
    required this.lastActive,
  });

  factory RosterEntry.fromJson(Map<String, dynamic> j) => RosterEntry(
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

/// Somebody who receives the weekly report, and whether they have agreed to.
class Guardian {
  final int id;
  final String email;
  final String? name;
  final String status; // pending | active | revoked

  const Guardian({
    required this.id,
    required this.email,
    this.name,
    required this.status,
  });

  factory Guardian.fromJson(Map<String, dynamic> j) => Guardian(
        id: (j['id'] as num).toInt(),
        email: j['email'] as String,
        name: j['display_name'] as String?,
        status: j['status'] as String,
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
/// every Hard question first try, so the target has to be known up front.
class UnitSummary {
  final String name;
  final int total;
  final int hardTotal;

  const UnitSummary({
    required this.name,
    required this.total,
    required this.hardTotal,
  });
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

  const Profile({
    required this.id,
    this.email,
    this.fullName,
    required this.grade,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        email: json['email'] as String?,
        fullName: json['full_name'] as String?,
        grade: json['grade'] as int,
      );

  String get courseLabel => kGradeCourses[grade] ?? 'Grade $grade';

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
  /// Returns true if they are signed in already, false if they need to
  /// confirm their email first.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required int grade,
  }) async {
    final response = await _db.auth.signUp(
      email: email,
      password: password,
      // The name rides along with the grade for the same reason: if email
      // confirmation is on there is no session yet, so writing to profiles
      // would be refused by RLS. Both are copied over on first sign-in.
      data: {'grade': grade, 'full_name': fullName},
    );
    return response.session != null;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _db.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _db.auth.signOut();
}

class ProfileRepository {
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
    if (grade == null) {
      throw Exception(
        'No grade found on this account. It may have been created before '
        'grades existed — register again, or add a row by hand in the '
        'profiles table.',
      );
    }

    final created = await _db
        .from('profiles')
        .insert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'] as String?,
          'grade': grade,
        })
        .select()
        .single();

    return Profile.fromJson(created);
  }

  /// Switches the signed-in student to a different grade.
  ///
  /// Two writes on purpose. The profiles row is what the app reads on every
  /// visit, so that one is the real change. The metadata copy is updated too
  /// so loadOrCreate still finds the right grade if the row ever has to be
  /// rebuilt from scratch — otherwise the two would drift apart.
  ///
  /// The "Update own profile" RLS policy is what allows this: Postgres checks
  /// auth.uid() = id, so a student can only ever move their own grade.
  Future<Profile> updateGrade(int grade) async {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');

    final updated = await _db
        .from('profiles')
        .update({'grade': grade})
        .eq('id', user.id)
        .select()
        .single();

    await _db.auth.updateUser(UserAttributes(data: {'grade': grade}));

    return Profile.fromJson(updated);
  }
}

class QuestionRepository {
  final SupabaseClient _db = Supabase.instance.client;

  /// The unit chips.
  ///
  /// This goes through a database function rather than reading the questions
  /// table, because students no longer have permission to read that table at
  /// all — see the note on fetchQuestions below.
  Future<List<UnitSummary>> fetchUnits(int grade) async {
    final rows = await _db.rpc('list_units', params: {'p_grade': grade});

    return (rows as List)
        .map((row) => UnitSummary(
              name: row['unit'] as String,
              total: (row['total'] as num).toInt(),
              hardTotal: (row['hard_total'] as num).toInt(),
            ))
        .toList();
  }

  /// The questions for one unit, with the answers stripped out.
  ///
  /// The app used to select straight from the questions table, which meant
  /// correct_index and all four feedback strings arrived in the browser.
  /// Anything the browser receives is visible in the network tab, so the
  /// answer was readable before tapping — and a feedback string starting
  /// "Correct." gave it away just as plainly as the index did.
  ///
  /// list_questions returns prompts and option text only. The ordering is
  /// done in SQL too, Easy through Hard, so the ramp cannot be sidestepped by
  /// a client that asks differently.
  Future<List<Question>> fetchQuestions(int grade, String unit) async {
    final rows = await _db.rpc(
      'list_questions',
      params: {'p_grade': grade, 'p_unit': unit},
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
    required int grade,
    required Question question,
    required int chosenIndex,
  }) async {
    final rows = await _db.rpc('submit_answer', params: {
      'p_grade': grade,
      'p_unit': question.unit,
      'p_sort_order': question.sortOrder,
      'p_chosen': chosenIndex,
    });

    final list = rows as List;
    if (list.isEmpty) throw Exception('The server did not grade that answer.');
    return Verdict.fromJson(Map<String, dynamic>.from(list.first));
  }

  /// When this grade was last reset, or null if it never has been.
  Future<DateTime?> _resetAt(int grade) async {
    final rows = await _db
        .from('progress_resets')
        .select('reset_at')
        .eq('student_id', _uid)
        .eq('grade', grade)
        .limit(1);

    if (rows.isEmpty) return null;
    return DateTime.parse(rows.first['reset_at'] as String);
  }

  /// Everything the chips, the resume card and the mastery header need.
  ///
  /// Attempts give the current run; unit_mastery gives the medals, which
  /// survive resets. Keeping those two separate is the whole reason a reset
  /// is safe to offer at all.
  Future<Map<String, UnitProgress>> fetchProgress(int grade) async {
    final since = await _resetAt(grade);

    var query = _db
        .from('attempts')
        .select('unit, sort_order, was_correct, was_first_attempt')
        .eq('student_id', _uid)
        .eq('grade', grade);

    if (since != null) {
      query = query.gt('answered_at', since.toIso8601String());
    }

    final attempts = await query;

    final solved = <String, Set<int>>{};
    final firstTry = <String, Set<int>>{};

    for (final row in attempts) {
      if (row['was_correct'] != true) continue;
      final unit = row['unit'] as String;
      final order = row['sort_order'] as int;
      solved.putIfAbsent(unit, () => <int>{}).add(order);
      if (row['was_first_attempt'] == true) {
        // A set, not a counter: a question answered right after three wrong
        // taps must not be able to count more than once.
        firstTry.putIfAbsent(unit, () => <int>{}).add(order);
      }
    }

    final mastery = await _db
        .from('unit_mastery')
        .select('unit, medal, best_first_try')
        .eq('student_id', _uid)
        .eq('grade', grade);

    final medals = <String, Medal>{};
    final bests = <String, int>{};
    for (final row in mastery) {
      final unit = row['unit'] as String;
      medals[unit] = medalFromText(row['medal'] as String?);
      bests[unit] = (row['best_first_try'] as int?) ?? 0;
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
    required int grade,
    required String unit,
  }) async {
    final result = await _db.rpc(
      'award_medal',
      params: {'p_grade': grade, 'p_unit': unit},
    );
    return medalFromText(result as String?);
  }

  /// Clears the run for one grade without deleting a thing.
  ///
  /// Everything before this moment stops counting toward position and score.
  /// The attempts themselves stay, so the teacher dashboard keeps its history
  /// and nobody can erase a bad week before a parent sees it. Medals stay too.
  Future<void> resetGrade(int grade) async {
    await _db.rpc('reset_progress', params: {'p_grade': grade});
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
  Future<void> claimTeacherRole(String code) async {
    await _db.rpc('claim_teacher_role', params: {'p_code': code});
  }

  Future<List<ClassInfo>> myClasses() async {
    final rows = await _db.rpc('my_classes');
    return (rows as List)
        .map((r) => ClassInfo.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<ClassInfo> createClass(String name, int grade) async {
    final rows = await _db.rpc(
      'create_class',
      params: {'p_name': name, 'p_grade': grade},
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
    return (rows as List)
        .map((r) => RosterEntry.fromJson(Map<String, dynamic>.from(r)))
        .toList();
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

  Future<String> regenerateCode(int classId) async {
    final result =
        await _db.rpc('regenerate_join_code', params: {'p_class_id': classId});
    return result as String;
  }

  // ---- the student side ----

  Future<List<StudentClass>> myClassesAsStudent() async {
    final rows = await _db.rpc('my_classes_as_student');
    return (rows as List)
        .map((r) => StudentClass.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<String> joinClass(String code) async {
    final rows = await _db.rpc('join_class', params: {'p_code': code});
    final list = rows as List;
    if (list.isEmpty) throw Exception('No open class has that code.');
    return list.first['joined_class_name'] as String;
  }

  Future<void> respondToInvitation(int classId, bool accept) async {
    await _db.rpc('respond_to_invitation',
        params: {'p_class_id': classId, 'p_accept': accept});
  }

  Future<void> leaveClass(int classId) async {
    await _db.rpc('leave_class', params: {'p_class_id': classId});
  }
}

/// Who receives the weekly report.
///
/// Note what is missing: no method returns the consent token. If a student
/// could read it they could confirm their own guardian, and the whole
/// double opt-in would be theatre. The token goes from the database to the
/// mail sender without passing through the browser.
class GuardianRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Guardian>> list() async {
    final rows = await _db
        .from('report_recipients')
        .select('id, email, display_name, status')
        .eq('student_id', _db.auth.currentUser!.id)
        .neq('status', 'revoked')
        .order('requested_at');

    return (rows as List)
        .map((r) => Guardian.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Adds somebody to the list and asks them whether they want to be on it.
  ///
  /// Two steps on purpose. The first records the request as pending; the
  /// second sends the email that turns pending into agreed. If the email
  /// fails, the row stays pending and the guardian receives nothing, which
  /// is the safe direction to fail in.
  Future<void> add(String email, String? name) async {
    await _db.rpc('request_report_recipient',
        params: {'p_email': email, 'p_name': name});

    // The consent token never reaches this code. The function below reads it
    // server-side, which is what stops a student confirming on behalf of
    // their own guardian.
    await _db.functions.invoke('send-consent-email');
  }

  Future<void> remove(int recipientId) async {
    await _db
        .rpc('remove_report_recipient', params: {'p_recipient_id': recipientId});
  }

  /// Who would receive a report right now, and whether one has already gone
  /// today. Drives the Send now button.
  Future<Map<String, dynamic>> status() async {
    final row = await _db.rpc('my_report_status');
    return Map<String, dynamic>.from(row as Map);
  }

  /// Sends a report immediately, rather than waiting for Sunday.
  ///
  /// This calls an Edge Function rather than doing the work here, because
  /// sending needs the service key and the consent tokens, neither of which
  /// may ever reach a browser. The function identifies the student from
  /// their own sign-in token, so it can only ever send that student's report.
  Future<String> sendNow() async {
    final response = await _db.functions.invoke('send-report-now');

    final body = response.data;
    if (body is Map && body['error'] != null) {
      throw Exception(body['error'].toString());
    }
    final sent = (body is Map ? body['sent'] : null) as int? ?? 0;
    if (sent == 0) {
      throw Exception(
        'Nothing was sent. Either nobody has agreed to receive reports yet, '
        'or one has already gone today.',
      );
    }
    return sent == 1
        ? 'Sent to 1 person.'
        : 'Sent to $sent people.';
  }
}

// ==========================================================================
// 4. APP SHELL
// ==========================================================================

Future<void> main() async {
  // Required because Supabase.initialize is async and runs before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MathTutorApp());
}

class MathTutorApp extends StatelessWidget {
  const MathTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Tutor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent),
        scaffoldBackgroundColor: kSurface,

        // Setting the look of fields and buttons once, here, keeps every
        // screen below about layout instead of repeating decoration.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kLine),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAccent, width: 2),
          ),
          labelStyle: const TextStyle(color: kInkSoft),
          floatingLabelStyle: const TextStyle(
            color: kAccent,
            fontWeight: FontWeight.w600,
          ),
          helperStyle: const TextStyle(color: kInkSoft, fontSize: 12),
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
            backgroundColor: Colors.white,
            side: const BorderSide(color: kLine),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
      home: const AuthGate(),
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

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
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
  int _grade = 10;
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    // Controllers hold resources, so hand them back when the screen goes.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (_registering && _nameController.text.trim().length < 2) {
      setState(
          () => _error = 'Enter your name so your teacher knows who you are.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });

    try {
      if (_registering) {
        final signedIn = await widget.auth.register(
          email: email,
          password: password,
          fullName: _nameController.text.trim(),
          grade: _grade,
        );
        // If email confirmation is switched on there is no session yet.
        if (!signedIn && mounted) {
          setState(() {
            _notice = 'Account created. Check your email for a confirmation '
                'link, then sign in.';
            _registering = false;
          });
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

                  // The divided box is the app's mark: a fraction bar, drawn
                  // rather than illustrated.
                  Center(
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: kCardShadow,
                      ),
                      child: const Center(
                        child: Text(
                          'x',
                          style: TextStyle(
                            fontFamily: kSerif,
                            fontFamilyFallback: kSerifFallback,
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Math Tutor',
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
                    style: const TextStyle(
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
                      helperText: 'At least 6 characters',
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
                    DropdownButtonFormField<int>(
                      initialValue: _grade,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        border: OutlineInputBorder(),
                      ),
                      items: kGradeCourses.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(
                                'Grade ${e.key} — ${e.value}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _grade = v ?? 10),
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

class RoleGate extends StatefulWidget {
  final AuthRepository auth;

  const RoleGate({super.key, required this.auth});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  final _classes = ClassRepository();
  bool? _isTeacher;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final teacher = await _classes.amITeacher();
      if (!mounted) return;
      setState(() => _isTeacher = teacher);
    } catch (_) {
      // If the check fails, fall back to the student app. Erring toward less
      // access rather than more is the right default here.
      if (!mounted) return;
      setState(() => _isTeacher = false);
    }
  }

  /// Called after a teacher code is redeemed, to switch screens without a
  /// sign out and back in.
  void _recheck() => setState(() => _isTeacher = null);

  @override
  Widget build(BuildContext context) {
    if (_isTeacher == null) {
      _check();
      return const Scaffold(
        backgroundColor: kSurface,
        body: Center(child: CircularProgressIndicator(color: kAccent)),
      );
    }

    if (_isTeacher!) {
      return TeacherHome(auth: widget.auth);
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

  /// Classes the student is in or has been invited to. Loaded on every visit
  /// because a student should never have to go looking to find out who can
  /// see their work.
  List<StudentClass> _myClasses = [];

  Profile? _profile;
  bool _loading = true;
  String? _error;

  List<UnitSummary> _units = [];
  Map<String, UnitProgress> _unitProgress = {};
  String? _selectedUnit;
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
  int _hardFirstTryCount = 0;
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _profiles.loadOrCreate();
      final units = await _questions.fetchUnits(profile.grade);
      final progress = await _progress.fetchProgress(profile.grade);
      // Not fatal if this fails — the quiz still works without it.
      var classes = <StudentClass>[];
      try {
        classes = await _classes.myClassesAsStudent();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _units = units;
        _unitProgress = progress;
        _myClasses = classes;
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
  Future<void> _changeGrade() async {
    final chosen = await showDialog<int>(
      context: context,
      builder: (_) => GradeDialog(current: _profile!.grade),
    );

    // Backed out, or picked the grade they were already in.
    if (chosen == null || chosen == _profile!.grade) return;

    setState(() {
      _loading = true;
      _error = null;
      _selectedUnit = null;
      _resetProgress();
    });

    try {
      final profile = await _profiles.updateGrade(chosen);
      final units = await _questions.fetchUnits(profile.grade);
      final progress = await _progress.fetchProgress(profile.grade);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _units = units;
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

  Future<void> _selectUnit(String unit) async {
    setState(() {
      _selectedUnit = unit;
      _loadingUnit = true;
      _error = null;
      _resetProgress();
    });

    try {
      final questions = await _questions.fetchQuestions(_profile!.grade, unit);
      final saved = _unitProgress[unit];
      if (!mounted) return;
      setState(() {
        _current = questions;
        _alreadySolved = saved?.solved ?? {};
        _firstTryCount = saved?.firstTry ?? 0;
        // Land on the first question not yet answered correctly, rather than
        // on question one.
        _index = _firstUnansweredIndex(questions, _alreadySolved);
        _finished = _index >= questions.length;
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

  void _resetProgress() {
    _current = [];
    _index = 0;
    _tried.clear();
    _verdicts.clear();
    _foundIndex = null;
    _showingFeedbackFor = null;
    _solved = false;
    _firstTryCount = 0;
    _hardFirstTryCount = 0;
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
        grade: _profile!.grade,
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
            if (question.isHard) _hardFirstTryCount++;
          }
          _alreadySolved = {..._alreadySolved, question.sortOrder};
        } else {
          _tried.add(i);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _grading = false;
        _error = 'That answer could not be sent. Check your connection.';
      });
    }
  }

  Future<void> _refreshClasses() async {
    try {
      final classes = await _classes.myClassesAsStudent();
      if (!mounted) return;
      setState(() => _myClasses = classes);
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
        onJoin: (code) async {
          final name = await _classes.joinClass(code);
          await _refreshClasses();
          return name;
        },
        onLeave: (id) async {
          await _classes.leaveClass(id);
          await _refreshClasses();
        },
      ),
    );
    await _refreshClasses();
  }

  Future<void> _openGuardians() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const GuardiansDialog(),
    );
  }

  /// Redeeming a teacher access code.
  ///
  /// Deliberately not a switch that simply makes somebody a teacher. Being a
  /// teacher means being able to read the work of children, so it takes a
  /// code issued by whoever runs the project.
  Future<void> _becomeTeacher() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const TeacherCodeDialog(),
    );
    if (code == null || code.isEmpty || !mounted) return;

    try {
      await _classes.claimTeacherRole(code);
      if (!mounted) return;
      widget.onBecameTeacher?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    }
  }

  /// Offers the reset, and carries it out if the student confirms.
  ///
  /// Worth being clear with them about what it does and does not touch,
  /// because "reset" usually means "delete" and here it does not.
  Future<void> _resetGrade() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ResetDialog(grade: _profile!.grade),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _selectedUnit = null;
      _resetProgress();
    });

    try {
      await _progress.resetGrade(_profile!.grade);
      final progress = await _progress.fetchProgress(_profile!.grade);
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
        grade: _profile!.grade,
        unit: unit.name,
      );
      final progress = await _progress.fetchProgress(_profile!.grade);
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
      _hardFirstTryCount = 0;
      _finished = false;
      _earned = Medal.none;
      _alreadySolved = {};
    });
  }

  void _backToUnits() {
    setState(() {
      _selectedUnit = null;
      _resetProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
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
        AccountBar(
          courseLabel: _profile!.courseLabel,
          grade: _profile!.grade,
          classCount: _myClasses.where((c) => !c.isInvitation).length,
          onChangeGrade: _changeGrade,
          onResetProgress: _resetGrade,
          onOpenClasses: _openClasses,
          onOpenGuardians: _openGuardians,
          onBecomeTeacher: _becomeTeacher,
          onSignOut: widget.auth.signOut,
        ),

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

        // Only worth showing when they are not already inside a unit.
        if (_selectedUnit == null && _resumable != null) ...[
          const SizedBox(height: 16),
          ResumeCard(
            unit: _resumable!,
            progress: _unitProgress[_resumable!.name]!,
            onContinue: () => _selectUnit(_resumable!.name),
          ),
        ],

        if (_units.isNotEmpty) ...[
          const SizedBox(height: 14),
          MasteryHeader(units: _units, progress: _unitProgress),
        ],

        // Units already finished but not finished well. Not a medal and not a
        // scold — just a note that the feedback in these is worth rereading.
        if (_selectedUnit == null && _revisit.isNotEmpty) ...[
          const SizedBox(height: 14),
          RevisitShelf(units: _revisit, onSelect: _selectUnit),
        ],

        const SizedBox(height: 22),
        UnitSelector(
          units: _units,
          progress: _unitProgress,
          selected: _selectedUnit,
          onSelect: _selectUnit,
        ),
        const SizedBox(height: 24),
        _buildQuizArea(),
      ],
    );
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
        message: 'No questions for Grade ${_profile!.grade} yet.',
      );
    }

    if (_selectedUnit == null) {
      return EmptyPrompt(
        message: _unitProgress.isEmpty
            ? 'Pick a unit above to begin.'
            : 'Pick a unit above to carry on.',
      );
    }

    if (_finished) {
      return ResultsView(
        firstTry: _firstTryCount,
        total: _current.length,
        medal: _earned,
        onRestart: _restartUnit,
        onChangeUnit: _backToUnits,
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
        ),
        const SizedBox(height: 18),
        QuestionCard(prompt: q.prompt),
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
            style: const TextStyle(fontSize: 13, color: kInkSoft),
          ),
        ],
      ],
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
                            const Text(
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
                              style: const TextStyle(
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(color: kAccent),
                      ),
                    )
                  else if (_error != null)
                    ErrorView(message: _error!, onRetry: _load)
                  else if (_list.isEmpty)
                    const EmptyPrompt(
                      message: 'No classes yet.\n\nCreate one, then read the '
                          'join code out to your students.',
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
      color: Colors.white,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        'Grade ${info.grade}',
                        info.students == 1
                            ? '1 student'
                            : '${info.students} students',
                        if (info.invited > 0) '${info.invited} invited',
                        if (info.activeToday > 0)
                          '${info.activeToday} active today',
                      ].join('  ·  '),
                      style: const TextStyle(fontSize: 12.5, color: kInkSoft),
                    ),
                  ],
                ),
              ),
              JoinCodeChip(code: info.joinCode),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: kInkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// The join code, set in a monospace so an O never gets read as a zero.
class JoinCodeChip extends StatelessWidget {
  final String code;

  const JoinCodeChip({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kLine),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamilyFallback: kMonoFallback,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: kInk,
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
  int _grade = 12;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ClassRepository().createClass(_name.text.trim(), _grade);
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
      backgroundColor: Colors.white,
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
            DropdownButtonFormField<int>(
              initialValue: _grade,
              // isExpanded lets the item shrink to the field. Without it a
              // dropdown sizes itself to its widest child and pushes past
              // the dialog, which is what the overflow stripes were.
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Grade'),
              items: kGradeCourses.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        // Course code only. The full course name is what
                        // made this too wide, and nobody choosing a class
                        // grade needs "Principles of Mathematics" spelled
                        // out.
                        child: Text(
                          'Grade ${e.key} — ${e.value.split(' — ').first}',
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _grade = v ?? 12),
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
  List<HardQuestion> _hard = [];
  bool _loading = true;
  String? _error;
  int _tab = 0;
  late String _code;

  @override
  void initState() {
    super.initState();
    _code = widget.info.joinCode;
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
      final hard = await _classes.hardQuestions(widget.info.id);
      if (!mounted) return;
      setState(() {
        _roster = roster;
        _topics = topics;
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

  Future<void> _newCode() async {
    final code = await _classes.regenerateCode(widget.info.id);
    if (!mounted) return;
    setState(() => _code = code);
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
          IconButton(
            tooltip: 'New join code',
            onPressed: _newCode,
            icon: const Icon(Icons.autorenew_rounded, size: 20),
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
                    const Text(
                      'Students join with',
                      style: TextStyle(fontSize: 13, color: kInkSoft),
                    ),
                    const SizedBox(width: 10),
                    JoinCodeChip(code: _code),
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
                    ? const Center(
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
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
        color: Colors.white,
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
                  color: isOn ? kAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                    color: isOn ? Colors.white : kInkSoft,
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(13),
        child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  // The name, not the address. A roster is a list of people.
                  entry.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kHint,
                        ),
                      )
                    else
                      Text(
                        entry.lastSeen,
                        style: const TextStyle(
                            fontSize: 12, color: kInkSoft),
                      ),
                    const Text('  ·  ',
                        style: TextStyle(fontSize: 12, color: kInkSoft)),
                    Text(
                      entry.questionsSeen == 0
                          ? 'no questions yet'
                          : '${entry.questionsSeen} questions'
                              '${entry.firstTryRate == null ? '' : ', '
                                  '${entry.firstTryRate}% first try'}',
                      style: const TextStyle(fontSize: 12, color: kInkSoft),
                    ),
                  ],
                ),
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
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                    ),
                  ),
                ],
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded,
                size: 20, color: kInkSoft),
            color: Colors.white,
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
              const Expanded(child: Divider(height: 1, color: kLine)),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            note,
            style: const TextStyle(fontSize: 12.5, height: 1.45,
                color: kInkSoft),
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
        color: Colors.white,
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
                  style: const TextStyle(
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
            style: const TextStyle(fontSize: 12, color: kInkSoft),
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
                    style: const TextStyle(
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
        color: Colors.white,
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
                        style: const TextStyle(
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
                        style: const TextStyle(
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
                  style: const TextStyle(
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
                      color: const Color(0xFFFCF5E9),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          const Border(left: BorderSide(color: kHint, width: 3)),
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
                          style: const TextStyle(
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
                            style: const TextStyle(
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
                            style: const TextStyle(
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
                    style: const TextStyle(fontSize: 11.5, color: kInkSoft),
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _classes.studentOverview(widget.entry.studentId);
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
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
                  ? const Center(
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
          style: const TextStyle(fontSize: 12.5, color: kInkSoft),
        ),
        const SizedBox(height: 3),
        Text(
          'Grade ${d.grade}  ·  ${kGradeCourses[d.grade] ?? ''}',
          style: const TextStyle(fontSize: 12.5, color: kInkSoft),
        ),
        const SizedBox(height: 20),

        // The one-line answer, in words, before any number. Same opening the
        // parent report uses.
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _summaryLine(d),
                style: const TextStyle(
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
                color: Colors.white,
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
                      style: const TextStyle(fontSize: 14, color: kInk),
                    ),
                  ),
                  Text(
                    '${u.firstTry} of ${u.questions} first try',
                    style: const TextStyle(fontSize: 12.5, color: kInkSoft),
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
              color: const Color(0xFFFCF5E9),
              borderRadius: BorderRadius.circular(13),
              border: const Border(left: BorderSide(color: kHint, width: 3)),
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
                        const Text('•  ',
                            style: TextStyle(fontSize: 14, color: kInk)),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: w.label,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                    color: kInk,
                                  ),
                                ),
                                TextSpan(
                                  text: '  (${w.unit}, ${w.times}×)',
                                  style: const TextStyle(
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
                const Text(
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

        const SizedBox(height: 20),
        Text(
          d.lastActive == null
              ? 'Has not opened the app yet.'
              : 'Last practised ${widget.entry.lastSeen}. '
                  '${d.wrongTaps} wrong taps in total, which is where the '
                  'learning happens — every one showed them the mistake '
                  'before the answer.',
          style: const TextStyle(fontSize: 12.5, height: 1.55,
              color: kInkSoft),
        ),
      ],
    );
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
            style: const TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: kAccent,
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(fontSize: 11.5, color: kInkSoft)),
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
      backgroundColor: Colors.white,
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
            const Text(
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
          backgroundColor: kAccent,
          disabledBackgroundColor: kAccent.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
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
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
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

class AccountBar extends StatelessWidget {
  final String courseLabel;
  final int grade;
  final int classCount;
  final VoidCallback onChangeGrade;
  final VoidCallback onResetProgress;
  final VoidCallback onOpenClasses;
  final VoidCallback onOpenGuardians;
  final VoidCallback onBecomeTeacher;
  final VoidCallback onSignOut;

  const AccountBar({
    super.key,
    required this.courseLabel,
    required this.grade,
    this.classCount = 0,
    required this.onChangeGrade,
    required this.onResetProgress,
    required this.onOpenClasses,
    required this.onOpenGuardians,
    required this.onBecomeTeacher,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // The grade as a numeral in a tile — reads at a glance, and gives
          // the bar something to anchor on other than text.
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                '$grade',
                style: const TextStyle(
                  fontFamily: kSerif,
                  fontFamilyFallback: kSerifFallback,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: kAccent,
                ),
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
                  style: const TextStyle(
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
                  style: const TextStyle(fontSize: 12.5, color: kInkSoft),
                ),
              ],
            ),
          ),
          // Change grade and reset are both rare and both destructive-ish,
          // so they sit behind a menu rather than tempting a stray tap.
          PopupMenuButton<String>(
            tooltip: 'Account',
            icon: const Icon(Icons.more_horiz_rounded, color: kInkSoft),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              // A switch statement rather than a switch expression: these
              // arms return nothing, and an expression needs a value.
              switch (value) {
                case 'classes':
                  onOpenClasses();
                case 'guardians':
                  onOpenGuardians();
                case 'grade':
                  onChangeGrade();
                case 'reset':
                  onResetProgress();
                case 'teacher':
                  onBecomeTeacher();
                default:
                  onSignOut();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'classes', child: Text('My classes')),
              PopupMenuItem(
                value: 'guardians',
                child: Text('Weekly reports'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(value: 'grade', child: Text('Change grade')),
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset my progress'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'teacher',
                child: Text('I am a teacher'),
              ),
              PopupMenuItem(value: 'signout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
    );
  }
}

class GradeDialog extends StatelessWidget {
  final int current;

  const GradeDialog({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Change grade', style: TextStyle(fontSize: 18)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: kGradeCourses.entries.map((entry) {
            final isCurrent = entry.key == current;
            return ListTile(
              dense: true,
              title: Text(
                'Grade ${entry.key}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              subtitle: Text(
                entry.value,
                style: const TextStyle(fontSize: 12, color: kInkSoft),
              ),
              trailing: isCurrent
                  ? const Icon(Icons.check, size: 18, color: kAccent)
                  : null,
              onTap: () => Navigator.of(context).pop(entry.key),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
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
            const Expanded(child: Divider(height: 1, color: kLine)),
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

            return AnimatedContainer(
              duration: _motion(context),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected ? kAccent : Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected ? kCardShadow : null,
                border: Border.all(color: isSelected ? kAccent : kLine),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => onSelect(unit.name),
                  borderRadius: BorderRadius.circular(999),
                  hoverColor: isSelected
                      ? Colors.white.withValues(alpha: 0.10)
                      : kAccent.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: size * 0.58,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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

    final label = earned == 0
        ? 'No units finished yet'
        : '$earned of ${units.length} units earned a medal';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: kLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
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
                    style: const TextStyle(fontSize: 12, color: kInkSoft),
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
        border: const Border(left: BorderSide(color: kHint, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            units.length == 1
                ? 'One unit worth another look'
                : '${units.length} units worth another look',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: kHint,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'You finished these, but a few took more than one try.',
            style: TextStyle(fontSize: 12.5, height: 1.4, color: kInkSoft),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: units.map((unit) {
              return Material(
                color: Colors.white,
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
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
        color: kAccent,
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
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            unit.name,
            style: const TextStyle(
              fontFamily: kSerif,
              fontFamilyFallback: kSerifFallback,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            left == 1 ? '1 question left' : '$left questions left',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.85),
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
                backgroundColor: Colors.white,
                foregroundColor: kAccent,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: kCardShadow,
        border: const Border(left: BorderSide(color: kAccent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitation to join ${invite.name}',
            style: const TextStyle(
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
            style: const TextStyle(fontSize: 13, height: 1.5, color: kInkSoft),
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
                      backgroundColor: kAccent,
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
  final Future<String> Function(String code) onJoin;
  final Future<void> Function(int classId) onLeave;

  const MyClassesDialog({
    super.key,
    required this.classes,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  State<MyClassesDialog> createState() => _MyClassesDialogState();
}

class _MyClassesDialogState extends State<MyClassesDialog> {
  final _code = TextEditingController();
  late List<StudentClass> _list;
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _list = widget.classes.where((c) => !c.isInvitation).toList();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (_code.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final name = await widget.onJoin(_code.text.trim());
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'Joined $name.';
        _code.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('My classes', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_list.isEmpty)
              const Text(
                'You are not in any class, so nobody can see your work '
                'except you.',
                style: TextStyle(fontSize: 13.5, height: 1.5, color: kInkSoft),
              )
            else ...[
              const Text(
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
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kInk,
                              ),
                            ),
                            Text(
                              c.teacherEmail,
                              style: const TextStyle(
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
            const SizedBox(height: 18),
            const Divider(height: 1, color: kLine),
            const SizedBox(height: 16),
            const Text(
              'Join a class',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Class code',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _busy ? null : _join,
                  child: Text(_busy ? '…' : 'Join'),
                ),
              ],
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

/// Who receives the weekly report.
///
/// The status column is the honest part: adding somebody does not start the
/// reports. They stay Pending until that person clicks the link in their
/// email, and the student can see that they have not.
class GuardiansDialog extends StatefulWidget {
  const GuardiansDialog({super.key});

  @override
  State<GuardiansDialog> createState() => _GuardiansDialogState();
}

class _GuardiansDialogState extends State<GuardiansDialog> {
  final _repo = GuardianRepository();
  final _email = TextEditingController();
  final _name = TextEditingController();

  List<Guardian> _list = [];
  Map<String, dynamic> _status = const {};
  bool _loading = true;
  bool _busy = false;
  bool _sending = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await _repo.list();
      final status = await _repo.status();
      if (!mounted) return;
      setState(() {
        _list = list;
        _status = status;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = friendlyError(e);
      });
    }
  }

  Future<void> _add() async {
    if (_email.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _repo.add(_email.text.trim(),
          _name.text.trim().isEmpty ? null : _name.text.trim());
      _email.clear();
      _name.clear();
      await _load();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'Asked. They will get an email explaining what would be '
            'shared, and nothing is sent until they agree.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = friendlyError(e);
      });
    }
  }

  Future<void> _sendNow() async {
    setState(() {
      _sending = true;
      _message = null;
    });
    try {
      final result = await _repo.sendNow();
      await _load();
      if (!mounted) return;
      setState(() {
        _sending = false;
        _message = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _message = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _status['can_send_now'] == true;
    final active = (_status['recipients'] as num?)?.toInt() ?? 0;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Weekly reports', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A short summary every Sunday evening: how much you '
                'practised, which units, and what you kept getting wrong. It '
                'never includes the questions themselves or your answers. '
                'You can also send one whenever you like.',
                style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
              ),
              const SizedBox(height: 16),

              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: kAccent),
                  ),
                )
              else if (_list.isEmpty)
                const Text(
                  'Nobody is receiving reports.',
                  style: TextStyle(fontSize: 13.5, color: kInkSoft),
                )
              else
                ..._list.map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.name ?? g.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kInk,
                                ),
                              ),
                              Text(
                                g.status == 'active'
                                    ? g.email
                                    : '${g.email}  ·  waiting for them to '
                                        'agree',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: g.status == 'active'
                                      ? kInkSoft
                                      : kHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _repo.remove(g.id);
                            await _load();
                          },
                          style: TextButton.styleFrom(foregroundColor: kWrong),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Sending on demand. A student who has just earned a Gold
              // should not have to wait until Sunday to show somebody.
              if (active > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: (canSend && !_sending) ? _sendNow : null,
                    icon: Icon(
                      _sending
                          ? Icons.hourglass_empty_rounded
                          : Icons.send_rounded,
                      size: 17,
                    ),
                    label: Text(
                      _sending
                          ? 'Sending…'
                          : canSend
                              ? 'Send a report now'
                              : 'Already sent one today',
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  canSend
                      ? 'Goes to everyone above, covering this week so far. '
                          'One a day, so the weekly one still means something.'
                      : 'You can send another tomorrow. The Sunday report '
                          'still goes out as normal.',
                  style: const TextStyle(
                      fontSize: 11.5, height: 1.45, color: kInkSoft),
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1, color: kLine),
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Their name (optional)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Their email',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _busy ? null : _add,
                  child: Text(_busy ? 'Adding…' : 'Add'),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 6),
                _Banner(message: _message!, colour: kAccent),
              ],
            ],
          ),
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

/// Redeeming a teacher access code.
class TeacherCodeDialog extends StatefulWidget {
  const TeacherCodeDialog({super.key});

  @override
  State<TeacherCodeDialog> createState() => _TeacherCodeDialogState();
}

class _TeacherCodeDialogState extends State<TeacherCodeDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Teacher access', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teacher accounts can see the work of every student who joins '
              'their class, so they are not self-serve. If you are a teacher, '
              'whoever set this up will have given you a code.',
              style: TextStyle(fontSize: 12.5, height: 1.5, color: kInkSoft),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Access code',
                isDense: true,
              ),
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
          onPressed: () => Navigator.of(context).pop(_code.text.trim()),
          child: const Text('Continue'),
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
  final int grade;

  const ResetDialog({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Start Grade $grade again?',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Every unit in this grade goes back to the first question.',
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
          style: const TextStyle(
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

  const ProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.courseCode,
    required this.difficulty,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                    ),
                  ),
                  TextSpan(
                    text: ' / $total',
                    style: const TextStyle(fontSize: 13, color: kInkSoft),
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
                valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
              ),
            );
          },
        ),
      ],
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String prompt;

  const QuestionCard({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Text(
        prompt,
        style: const TextStyle(
          fontFamily: kSerif,
          fontFamilyFallback: kSerifFallback,
          fontSize: 21,
          height: 1.55,
          color: kInk,
        ),
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

  @override
  Widget build(BuildContext context) {
    final hot = _hovering && widget.enabled;

    Color border = kLine;
    Color background = Colors.white;
    Color textColor = kInk;
    Color tokenBg = kSurface;
    Color tokenFg = kInkSoft;

    if (widget.isFound) {
      border = kAccent;
      background = const Color(0xFFEDF5F2);
      tokenBg = kAccent;
      tokenFg = Colors.white;
    } else if (widget.isRuledOut) {
      border = const Color(0xFFEADFDC);
      background = const Color(0xFFFBF6F5);
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
                          ? Border.all(color: const Color(0xFFEADFDC))
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
                    const Icon(Icons.check_rounded, size: 20, color: kAccent)
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
          color: correct ? const Color(0xFFEDF5F2) : const Color(0xFFFCF5E9),
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
              style: const TextStyle(
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
  final int firstTry;
  final int total;
  final Medal medal;
  final VoidCallback onRestart;
  final VoidCallback onChangeUnit;

  const ResultsView({
    super.key,
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
        Medal.silver =>
          'Gold needs 9 of $total on the first try, including the hard ones.',
        _ => null,
      };

  String get _medalLine => switch (medal) {
        Medal.gold => 'Gold — this unit is yours',
        Medal.silver => 'Silver earned',
        Medal.bronze => 'Bronze earned — unit complete',
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
            color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 20),
              ] else
                Text(
                  'UNIT COMPLETE',
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
                          style: const TextStyle(
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
                          style: const TextStyle(
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
              const Text(
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
                style: const TextStyle(fontSize: 15, height: 1.5, color: kInk),
              ),
              if (_nextUp != null) ...[
                const SizedBox(height: 10),
                Text(
                  _nextUp!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF1EF),
            borderRadius: BorderRadius.circular(14),
            border: const Border(left: BorderSide(color: kWrong, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: kWrong,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'That did not load',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kWrong,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Check that the SQL setup file has been run, and that the '
                'questions and profiles tables both have read policies.',
                style: TextStyle(fontSize: 12.5, height: 1.45, color: kInkSoft),
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

