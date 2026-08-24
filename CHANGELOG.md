# Changelog

What each release of this repository added, and what it took away. The
running account of *why* things are the way they are lives in
`docs/PROJECT_STATE.md`; this file is only the record of what changed.

---

## 24 August 2026 — Astro Math Assist

The app in the previous release was a single quiz screen over 200 questions,
with a teacher dashboard and a weekly email to parents. This release keeps the
thesis and rebuilds almost everything around it.

The thesis is unchanged and still governs every decision below. Every question
has four options; the three wrong ones are each the answer a student reaches by
making one specific, named mistake, and the feedback names that mistake without
revealing the answer, so the student goes back and takes the turn again.

### Four sections instead of one screen

The app is now a loop of four sections, each handing off to the next.

| Section | What it does |
|---|---|
| **Learn** | A three to six minute read per subtopic, with a worked example, a diagram and a Common Mistakes block naming the same errors the questions test. Reads are tracked per student. |
| **Quiz** | Forty questions per unit in four bands: Easy 1 to 10, Medium 11 to 20, Challenge 21 to 30, Advanced 31 to 40. Graded server side, one question at a time. |
| **Improve** | Reads which misconception tags a student keeps failing on and builds a drill from exactly those. This is the first query in the database that can select questions by tag. |
| **Test** | A cumulative paper. No feedback until it is submitted, only the best score counts, and test attempts are excluded from the practice pool so a test never burns questions a student has not studied yet. |

All of it arrives in one migration, `supabase/migrations/astro_sections.sql`:
five tables (`lessons`, `lesson_reads`, `practice_tests`, `practice_test_items`,
`enrolment_requests`), two nullable columns, and 25 functions. It touches
nothing that already existed, so no student loses a row by it being applied,
and re-running it is safe.

### Question bank: 200 to 1,600

Six Ontario courses, forty units, forty questions each.

| Course | Grade | Units | Questions | Figures |
|---|---|---|---|---|
| MTH1W | 9 | 9 | 360 | 0 |
| MPM2D | 10 | 6 | 240 | 33 |
| MCR3U | 11 | 7 | 280 | 8 |
| MHF4U | 12 | 7 | 280 | 2 |
| MCV4U | 12 | 6 | 240 | 12 |
| MDM4U | 12 | 5 | 200 | 5 |

Every one of the 1,600 was then audited end to end and repaired. 314 defects
were found and fixed, and a second independent pass over every changed question
found 27 more. The keys were strong, 1,597 of 1,600 correct, but the feedback
layer was not, which matters more here than it would anywhere else because the
feedback layer *is* the product.

The three that mattered: MPM2D Factoring Q21 had a wrong key with no correct
option at all, and it was live, so every student who attempted it was marked
wrong; MDM4U Displays of Data Q18 and Q28 had keys generated from unrounded
regression output while their prompts printed rounded coefficients.

304 questions were edited without a single option changing position, a property
enforced by reloading every file into a scratch Postgres and diffing it row by
row against the pristine original. `docs/QUESTION_BANK_AUDIT.md` and
`docs/QUESTION_BANK_REPAIR.md` are the full reports.

Two properties the bank now holds that it did not before. All forty units pass
all thirteen checks in `tools/check_questions.sql`. And the length tell is gone:
a student who picks the longest option every time scores 398 of 1,600, which is
24.9% against a chance baseline of 25%.

### 219 lessons

One per subtopic, across all six courses, keyed to the same misconception tags
the questions carry. Zero subtopics are left without a lesson, which is the
property `docs/SQL_ORDER.md` asks you to check after loading.

51 of them started as Dileep Kumar's Grade 9 and 10 lesson set and were remapped
onto this app's units and tags. The other 168 were authored for this project.

### 376 figures

60 question diagrams and 158 lesson diagrams rendered in both light and dark,
all drawn from code rather than hand-placed.

28 of the 60 question figures carry a **ruler test**: `tools/make_figures.py`
computes what a student measuring the drawing would get and refuses to write the
file unless that value lands nearest a *wrong* option. It has caught real leaks
twice. On the MCV4U wrench it forced a 50 degree distortion rather than the
usual 15 to 20, because sine is flat near 90 degrees and anything milder rounded
straight back onto the answer.

Most questions correctly get no figure. Every figure file header records which
candidates were rejected and why, and that list is the more useful half: most of
what looks like an obvious diagram turns out to be the answer sheet.

Lesson diagrams are authored as SVG and rendered to PNG in both themes ahead of
time, so the app needs no SVG package and reuses the same `Image.network` path
the question figures already use.

### Dark mode

Every colour was a top level `const Color` used in roughly five hundred places,
most of them inside `const` widgets. Threading a `BuildContext` to all of them
would have been a change to five hundred call sites, so instead the names stay
and become getters onto whichever palette is in force. `kInk`, `kSurface` and
`kLine` still mean what they meant. The only cost is that a `const` widget can
no longer hold one, and those `const` keywords are gone.

`Theme.of(context).brightness` stays the source of truth, so Material's own
widgets and ours can never disagree. The choice is stored per profile as
`theme_pref` and offered as Light, Dark or System.

### Report, topic map and progress

Eight unit identity colours, all AA on white and on cream, and deliberately no
green or orange so a unit colour can never be mistaken for a traffic light band.
Mastery colouring across the topic map and the tree, medals, a day streak, and
first try percentages a tutor or a parent can read. A tutor can share a
read only link to the report.

Profile photos are private: signed URLs, re-encoded in the browser to a 256px
JPEG. The re-encode is not about file size. A JPEG straight off a phone carries
EXIF, and EXIF carries the GPS coordinates of where the picture was taken. These
users are children. Photos are visible to the student, their own tutors and the
admin, and never on a share link, which is asserted three ways in the suite.

### Payments

Stripe checkout and a subscription status webhook, both as Deno Edge Functions
under `supabase/functions/`, alongside manual Interac e-transfer confirmed by an
admin. Every credential is read through `Deno.env.get`. The paywall is enforced
server side in four places, and Challenge and Advanced are the bands behind it.

### Branding and legal

An Astro mark, a wordmark and the full app icon set, generated by
`tools/make_icons.py`, with five earlier SVG directions kept in `brand/`. The
privacy policy and terms are authored as Markdown in `docs/` and rendered to
`web/privacy.html` and `web/terms.html` by `tools/render_legal.py`, so there is
one copy of each and it is the one under version control.

### The content pipeline

`tools/` is now the whole authoring apparatus rather than a scratch folder:

```
make_figures.py              60 question diagrams, with the ruler test
render_diagrams.py           158 lesson diagrams x 2 themes = 316 PNGs
import_lessons.py            maps external lesson HTML onto our units and tags
make_icons.py                the brand mark and every app icon
render_legal.py              docs/PRIVACY.md + TERMS.md -> web/*.html
check_questions.sql          the thirteen-check gate every unit must pass
check_distinct_options.py    parses options symbolically, flags two that are equal
check_option_lengths.py      measures what a length-guesser actually scores
balance_answer_positions.py  rotates option lists so the answer is not predictable
```

`check_distinct_options.py` and `check_option_lengths.py` are new, and both were
written because the audit found defect classes no text comparison can see.
Duplicate options accounted for thirteen of the seventeen criticals.

### Tests

The three older SQL suites are replaced by three that assert rather than print.
The old ones had been running against a retired question bank for some time and
passing by looking blank.

| Suite | Checks |
|---|---|
| `tests/test_ama.sql` | 212, in ten blocks from the paywall to profile photos |
| `tests/test_sections.sql` | 66, covering Learn, Improve, Test, percentages and enrolment |
| `tests/test_rpc_names.sql` | 12, calling every RPC by named argument |
| `test/widget_test.dart` | 14, pinning the percentage rule in the browser |

`test_rpc_names.sql` earns its place on its own. PostgREST resolves a function by
its **named arguments**, so renaming a SQL parameter breaks every call from the
app at runtime while `flutter analyze` stays perfectly happy. Nothing else
catches that.

All four were re-run on 24 August 2026 against a scratch Postgres built from
this repository alone, and all four pass.

### Security

Four rules, unchanged in intent and now pinned by the suite.

1. **Answers never reach the browser.** `questions` has RLS enabled with no
   policy at all, so no client can select from it. `list_questions` returns
   prompts and option text but never `correct_index` and never the feedback
   strings. Grading happens inside `submit_answer`.
2. **Every RLS policy is `for select` only.** Every write goes through a
   `security definer` function that checks `auth.uid()` itself.
3. **Five functions are protected only by the absence of a grant.**
   `grant_teacher_role`, `report_payload`, `upsert_subscription`,
   `update_subscription_by_sid` and `set_stripe_customer` have no grant to
   `authenticated`. A blanket
   `grant execute on all functions in schema public to authenticated` lets any
   student make themselves an admin. Check F5 exists because that mistake was
   actually made once.
4. **The Supabase SQL editor bypasses RLS entirely.** Permission changes have to
   be tested through the app, signed in as the relevant person.

Grants were hardened in this release as well. A signed out browser could dial 49
functions; it can now dial exactly two, `list_courses` for the signup screen and
`shared_report`.

### Repository layout

The question bank exists three times over, on purpose: 40 per-unit files, 6
per-course files, and one combined file, because the Supabase SQL editor
struggles with a 1.2 MB paste. Side by side in one directory they read as three
competing versions, so the derived copies now sit apart from the sources.

```
supabase/migrations/
  astro_math_assist_setup.sql   schema, policies, functions   <- run 1st
  astro_sections.sql            Learn / Improve / Test        <- run 3rd
  questions/                    source of truth, per unit
  lessons/                      source of truth, per course
  bundles/                      generated: questions_all, lessons_all, by_course
  _superseded/                  do not run, kept for old databases
```

Nothing was deleted and the two setup files did not move, so every instruction
that names them still works.

`supabase_full_setup.sql` moved into `_superseded/`. It is byte for byte
identical to `astro_math_assist_setup.sql` apart from its comment header, and
the newer name is the one that folds in the wiring fixes, the avatar bucket and
the admin drill-down. Forty-eight SQL headers and six docs that still opened
with `RUN ORDER: supabase_full_setup.sql` were repointed at the file that
exists.

### Removed

- `send-weekly-reports`, `send-report-now` and `send-consent-email`, the three
  Resend Edge Functions, along with `web-pages/confirm.html`,
  `web-pages/unsubscribe.html` and `docs/parent_report_template.html`. Parent
  facing email is being rebuilt around the Astro+ enrolment flow and is not
  written yet. The old versions remain in this repository's history at `a1e0b7d`.
- `questions_all_tagged.sql`, superseded by the current bank.
- `tests/test_suite.sql`, `tests/test_security.sql` and `tests/test_retry.sql`,
  superseded by the three suites above.

### Known gaps

- The hosted site still serves an older build. Deploying is the next step, not
  more features.
- The privacy policy and terms are not yet linked from inside the app.
- The brand mark is not yet on the sign in screen.
- `test_scores` is not yet wired into `report_payload`, so the topic map shows
  first try rate rather than best test score.
- The Astro+ enrolment form and the Edge Function that emails parents.
- Mobile layout pass.
- `lib/main.dart` is one file at 15,570 lines. That was the right call while the
  shape was unknown and is now a genuine liability. Splitting it is the next
  structural job, along boundaries the code has revealed rather than guessed
  ones.

---

## 10 August 2026 — Math Tutor

The first version put under version control. A Flutter Web app over a Supabase
Postgres, 200 questions in one tagged SQL file, a teacher dashboard with class
rosters and invite codes, share links for guardians, and a weekly report emailed
through Resend by three Edge Functions. One file, `lib/main.dart`, at roughly
5,700 lines.

The wrong-answers-are-the-product thesis was already the point, and everything
in the release above is built on it.
