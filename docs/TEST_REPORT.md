# TEST REPORT — Grade 10 only, 17 Aug 2026

Built from scratch in the same order you would use in the Supabase SQL editor,
with **Grade 9 deliberately not loaded**:

```
supabase_full_setup.sql  →  questions_grade10.sql  →  figures_grade10.sql
```

All three loaded with zero errors. 240 questions across 6 units, 33 figures
attached.

---

## What passed

**The 125-check suite: 125 passed, 0 failed.**

| Block | What it covers | Result |
|---|---|---|
| A | Paywall enforced server-side | 15/15 |
| B | The answer never reaches the browser | 12/12 |
| C | Teachers, consent, class boundaries | 23/23 |
| D | Share links | 12/12 |
| E | Admin panel and e-transfer | 33/33 |
| F | The security fixes from the audit stay fixed | 8/8 |
| G | Tutor review and subtopic diagnosis | 22/22 |

**Three journeys were then walked end to end, as the app walks them.**

*Student.* Course picker → 6 units → levels → a free level loads → a locked
level is refused → answer right and wrong → finish the level → claim a medal →
report → share link → revoke → reset progress. Every step behaved.

*Tutor.* Create a class → invite by email → **roster stays empty until the
student accepts** → student works a level getting three wrong → dashboard shows
70% first-try → subtopic diagnosis → hardest questions → write a note → student
sees it unread → a stranger asking about the same student gets nothing.

*Admin and money.* Family has no premium, Challenge locked → family raises an
e-transfer claim → admin sees it in the queue → a non-admin sees nothing and
cannot confirm → admin confirms → **premium goes live, Challenge and Advanced
unlock, Advanced returns its 10 questions** → subscription runs to 17 Aug 2027.

---

## Two things worth seeing for yourself

**The answer key is not merely hidden, it is unreachable.** A signed-in student
running `select * from questions` gets **0 rows** — the table is invisible to
them entirely. Everything arrives through `list_questions`, whose return type is
literally:

```
TABLE(sort_order, difficulty, course_code, unit, prompt, options, subtopic, figure)
```

No `correct_index`. No `feedback`. There is no request a browser can make that
returns the answer.

**The avoidance detector works on real data.** The test student did one Easy
level of Factoring, getting three wrong. The tutor view came back:

| Subtopic | Coverage | First-try | Band | Avoided |
|---|---|---|---|---|
| Factoring x² + bx + c | 2/6 (33%) | 50% | yellow | **yes** |
| Common factoring | 3/4 (75%) | 67% | yellow | no |
| Multiplying binomials | 3/5 (60%) | 67% | yellow | no |
| Special products | 2/15 (13%) | 100% | green | **yes** |

Special products is the row that proves the design. The student is **100% on
first try** there — a score-only dashboard would paint it green and move on.
But they have touched 2 questions out of 15 while covering 75% of another
subtopic. That is the "I only revise what I am already good at" pattern you
described, and it is the only thing on the screen that catches it.

---

## Three false alarms, so they do not worry you later

1. ~~**The suite prints 3 "feedback states the answer" lines**~~ — **fixed.**
   All three were the check being literal-minded: the answer is `12` and the
   question stem says "in 12 years". The substring arm now skips any answer
   text that already appears in the prompt, and any single-character answer.
   Verified both ways: the clean bank reports zero, and three deliberately
   planted leaks — one announcing the answer in words, one repeating the
   correct option verbatim, one saying "it is actually" — are all still
   caught.
2. **`student_subtopics` returns nothing when a student calls it about
   themselves.** By design — it re-checks `teaches_student` and is the tutor
   dashboard function.
3. **The admin list functions return 0 rows to a non-admin rather than
   raising.** Deliberate and consistent with the rest of the codebase; the
   write operations (`admin_confirm_etransfer`, `admin_make_teacher`) do raise
   "Admin only."

---

## Update — the five have buttons now

All five are wired, and wiring them found a real bug.

`student_detail` and `class_unit_summary` both read from `unit_mastery`
alone. That table is the medal cabinet: a row appears only when
`award_medal` runs, which happens only when a student finishes a whole
level. So both screens were blank for any student who practises without
finishing — which is exactly the student a tutor opens the drill-down to
look at. On the test fixture it was stark: 25 attempts across all four
levels of Linear systems, and zero rows returned.

Both are rebuilt in `wire_up_unused_functions.sql` to be driven by attempts,
with `unit_mastery` left-joined for the medal. Neither signature changed.
A student with zero medals now reads:

| Unit | Level | Medal | First try | Wrong taps | Mostly |
|---|---|---|---|---|---|
| Quadratics | Easy | None | 0 of 10 | 10 | Vertex form |
| Quadratics | Medium | None | 0 of 10 | 2 | Vertex form |

`class_unit_summary` gained one correction of meaning as well: `avg_first_try`
used to average over medallists only, so a unit the class had struggled
through without finishing reported NULL — the worst units were the quietest
ones. It now averages over everyone who attempted the unit.

**The suite is now 149 checks, all passing** — Block H adds 24 covering the
five newly reachable paths, including that removing a student and archiving
a class both end the tutor's view without destroying any student data.

## The SQL contract with the Flutter app

Every one of the **52 RPCs `main.dart` calls exists in the schema, with
matching argument names**. Nothing is called that does not exist; nothing is
called with an argument the function does not accept.

Twelve SQL functions are never called from Dart, and all twelve are now
genuinely internal — SQL helpers (`teaches_student`, `owns_class`,
`level_is_free`, `misconception_label`, `report_payload`, `is_enrolled_in`,
`profiles_guard_grade`), edge-function-only (`upsert_subscription`,
`update_subscription_by_sid`, `set_stripe_customer`), and two called by other
SQL (`add_student_to_class`, `grant_teacher_role`).

No user-facing function is orphaned any more.
