# Astro STEM Labs — Maths

Ontario high-school maths practice that shows a student *what they got wrong
and why*. Grades 9 to 12, six courses, 1,600 questions and 219 lessons, with a
progress report a tutor or a parent can read.

Flutter Web on the front, Supabase Postgres on the back.

One subject inside Astro STEM Labs. Physics and Tech appear in the app as
named-but-closed options; nothing is stubbed in behind them.

---

## The idea this is built on

**Wrong answers are the product.**

Every question has four options. The three wrong ones are not filler — each is
the answer a student actually arrives at by making one specific, named mistake.
Sign dropped when expanding a bracket. Second differences taken from the wrong
pair. Slope read as run-over-rise.

When a student taps a wrong option, the app names the mistake and says nothing
about the right answer. It does not reveal the answer, and it does not say
"try again". It says which turn was missed, and lets them go back and take it.

That is why the schema carries `misconception_tag` on every question, why
`attempts` records which wrong option was chosen rather than just a score, and
why the report can say *"You're consistently distributing the negative"*
instead of *"You got 6 out of 10"*.

Everything else in the codebase exists to serve that.

---

## What a student sees

Four sections, in order, and each one hands off to the next.

| Section | What it does |
|---|---|
| **Learn** | A path, one node per subtopic. A three to six minute read with a worked example, a diagram and a Common Mistakes block naming the same errors the questions test — then three questions on it to open the next node. Wrong answers cost nothing at the gate: they name the mistake and you go again, which is the whole app in miniature. |
| **Quiz** | Forty questions per unit in four difficulty bands: Easy 1–10, Medium 11–20, Challenge 21–30, Advanced 31–40. Graded server-side, one question at a time, with feedback on every wrong tap. |
| **Improve** | Looks at which misconception tags a student keeps failing on, and builds a drill from exactly those. Not "practise more" — practise *this*. |
| **Test** | A cumulative paper. No feedback until it is submitted, only the best score counts, and test attempts are deliberately excluded from the practice pool so a test never burns questions a student hasn't studied yet. Once it is submitted, the review shows every question with all four options, which one was tapped, which was right, and the mistake behind each wrong one. |

The topic map colours every unit and subtopic by mastery, and there is a report
behind it with first-try percentages, medals and a day streak. A tutor can share
a read-only link to it with a parent.

---

## Repository layout

```
lib/main.dart              The entire Flutter app. One file, ~15,600 lines.
                           Deliberately — see "Why one file" below.

supabase/
  migrations/
    astro_math_assist_setup.sql   Schema, policies, functions. Run this first.
    astro_sections.sql            Learn / Improve / Test / preferences.
    test_review_answers.sql       The end-of-test review, answers included.
    learn_journey.sql             The Learn path: read, prove it, unlock.
    my_progress.sql               Per-unit progress, reduced server-side.
    student_safeguarding.sql      Age gate, guardian consent, export, delete,
                                  rate limiting.
    indexes_and_policy_perf.sql   Indexes Postgres does not create for you.
    questions/                    Source of truth: 40 per-unit files + figures.
    lessons/                      Source of truth: 6 per-course files.
    bundles/                      Generated. Same content, fewer pastes.
    _superseded/                  Kept for old databases. Do not run.
  functions/
    create-checkout/              Stripe checkout session (Deno).
    stripe-webhook/               Subscription status webhook (Deno).

web/                       index.html, manifest, icons, privacy, terms,
                           and 376 rendered figures (60 question diagrams,
                           158 lesson diagrams x light and dark).

tools/                     The content pipeline. Python.
docs/                      Everything below, in detail.
tests/                     SQL test suites, run against a scratch database.
test/                      Dart widget tests.
```

### Why one file

`lib/main.dart` is one file on purpose. The app is a single coherent screen
graph with heavy shared state, and splitting it early would have meant
inventing module boundaries before the shape was known. It is now big enough
that this is a genuine liability, and splitting it is the next structural
job — but it should be split along boundaries the code has actually revealed,
not guessed ones.

---

## Getting it running

### The app

```bash
flutter --version          # needs >= 3.27.0, Dart >= 3.7.0
flutter pub get
flutter analyze            # expect zero issues
flutter test               # 14 widget tests
flutter run -d chrome
```

To build for deployment:

```bash
flutter clean
flutter build web --release
# then deploy build/web/
```

### The database

Read **`docs/SQL_ORDER.md`** before running anything. It has two routes — one
for a database that already has the question bank, one for an empty project —
and running the wrong one is the main way to waste an afternoon.

From an empty Supabase project, the short version:

1. `astro_math_assist_setup.sql` — every table, policy and function
2. `bundles/questions_all.sql` — 1,600 questions and 60 figures
3. `astro_sections.sql` — the Learn / Improve / Test tables and functions
4. the six `lessons/*.sql` — 219 lessons
5. `test_review_answers.sql`, `learn_journey.sql`, `my_progress.sql`,
   `student_safeguarding.sql`, `indexes_and_policy_perf.sql` — in that order,
   any time after 3

**One ordering rule that is easy to miss.** Inside every question file the
figure statements come last, and they have to. Each unit block opens with
`delete from questions where course_code = ... and unit = ...`, and that delete
takes the figure reference with the row. A figure block that ran first would
attach 60 images and then have them deleted straight back out — leaving the
course imageless, with no error to show for it.

Verify afterwards:

```sql
select course_code, count(*) from questions group by 1 order by 1;
-- MCR3U 280 · MCV4U 240 · MDM4U 200 · MHF4U 280 · MPM2D 240 · MTH1W 360
select count(*) from questions where figure is not null;   -- 60
select count(*) from lessons;                              -- 219
```

---

## The security model

Four rules. They are load-bearing, and three of them are invisible in the Dart.

**1. Answers never reach the browser, with one named exception.**
`questions` has RLS enabled with *no policy at all*, so no client can select
from it. `list_questions` returns prompts and option text but never
`correct_index` and never the feedback strings. Grading happens inside
`submit_answer`, server-side, and the response carries back only whether the
tap was right and the one feedback line for the option chosen.

The exception is `test_item_review`, and only for a paper that is **yours,
finished, and only for the items you actually answered**. It returns all four options, their feedback and the correct
index, so the end-of-test review can show a student which fifteen they got
wrong and why. A live paper still reveals nothing — `test_paper` ships no
answer and `answer_test_item` returns nothing, which suite checks T6, T9 and
D7c pin. And the review is a review of your work rather than an answer key:
an item you left blank produces no row, which is what stops a student
finishing an untouched paper to read fifteen answers out of a unit they are
about to practise. D12 pins that. The reasoning is written out at the top of
`supabase/migrations/test_review_answers.sql`.

**2. Every RLS policy is `for select` only.**
Nothing writes to the database through PostgREST. Every write goes through a
`security definer` function that checks `auth.uid()` itself.

**3. Five functions are protected only by the absence of a grant.**
`grant_teacher_role`, `report_payload`, `upsert_subscription`,
`update_subscription_by_sid` and `set_stripe_customer` have no grant to
`authenticated`. That is the whole protection. **A blanket
`grant execute on all functions in schema public to authenticated` lets any
student make themselves an admin.** Never run one.

**4. The SQL editor bypasses RLS entirely.**
Anything you check in the Supabase SQL editor runs as the table owner and will
happily return rows a signed-in student could never see. Permission changes have
to be tested through the app, signed in as the relevant person.

Secrets: `main.dart` carries the Supabase URL and the publishable key, which are
public by design and useless without a policy that grants access. The Stripe
secret key, the webhook secret and the service-role key exist only as
`Deno.env.get(...)` lookups inside the Edge Functions. **None of the three
belongs in `main.dart`, in the SQL, or in this repository.**

---

## The content pipeline

```
tools/make_figures.py       60 question diagrams -> web/figures/
tools/render_diagrams.py    158 lesson diagrams x 2 themes -> 316 PNGs
tools/import_lessons.py     Maps external lesson HTML onto our units and tags
tools/make_icons.py         The brand mark and every app icon
tools/render_legal.py       docs/PRIVACY.md + TERMS.md -> web/*.html
tools/check_questions.sql   The thirteen-check gate every unit must pass
tools/check_distinct_options.py, check_option_lengths.py,
tools/balance_answer_positions.py
```

Lesson diagrams are authored as SVG and rendered to PNG in both themes ahead of
time, so the app needs no SVG package and reuses the same `Image.network` path
the question figures already use.

Question authoring rules live in `docs/AUTHORING_GUIDE.md`; lesson format in
`docs/LESSON_AUTHORING.md`.

---

## Tests

| Suite | Count | Run against |
|---|---|---|
| `tests/test_ama.sql` | 212 checks | a scratch database — **never the live one**, it creates fixture users |
| `tests/test_sections.sql` | 70 checks | a *different* scratch database from the above, or the same one before it |
| `tests/test_rpc_names.sql` | 12 checks | calls every RPC by named argument |
| `tests/test_safeguarding.sql` | 41 checks | the age gate, guardian consent, export, deletion and rate limiting — every refusal, demonstrated |
| `test/widget_test.dart` | 14 tests | `flutter test` |

`test_rpc_names.sql` earns its place. PostgREST resolves functions by their
**named arguments**, so renaming a SQL parameter breaks every call from the app
at runtime while `flutter analyze` stays perfectly happy. That suite is the only
thing that catches it.

All five were run on 27 August 2026 against a scratch Postgres built from this
repository alone, every migration applied in order and nothing else in it:
**212, 70, 12, 41 and 39, all passing**, `flutter analyze` clean.

---

## Where it stands

Live in production: the schema, 1,600 questions, 219 lessons, 92 functions,
and real student attempt history.

**Not yet deployed.** Everything below is in this repository and none of it is
in front of a student. That is the single biggest thing outstanding, and it is
a deploy rather than a feature:

- The Astro STEM Labs brand, and a dark theme whose colours are actually
  derived rather than guessed
- Learn / Quiz / Improve / Test as one loop
- The mindmap on the main screen, with Reset view, beside the classroom view
- The end-of-test review, answers included, on a finished paper only
- The Learn path: read it, prove it, and the next one opens
- The age gate, guardian consent, account deletion, data export and rate
  limiting

**Before it can be deployed** — none of these are code, and all of them are
in `docs/LAUNCH_CHECKLIST.md`:

- Turn Confirm email back ON, and leaked-password protection with it
- Nothing to do about the old keyless `rate_limit_hits` on the live project:
  `student_safeguarding.sql` detects and replaces it. Worth knowing it was
  there, because rate limiting fails open and would have been silently absent
- Stripe live keys, live prices and a live webhook secret; redeploy both
  edge functions
- Set `SITE_URL` on `create-checkout` — CORS is locked to it now, and an
  unset value fails closed

Still open, and honestly still open:

- `lib/main.dart` is one file at 17,000 lines. Splitting it is the next
  structural job, and it is also the only real lever left on the payload:
  1,056 KB gzipped, against a sensible budget of about 200 KB, and deferred
  loading needs module boundaries to defer.
- Email needs a Resend key. `supabase/functions/send-link` is written and
  refuses cleanly without one — the app falls back to showing the student
  the link to pass on, which is the path that has actually been used.
- Nothing schedules `purge_rate_limits`. The counters are small and the
  table is harmless, but the tidy-up is a manual one-liner until something
  runs it.
- Mobile layout pass, and a keyboard route through the mindmap.

Closed since the last pass, and worth naming because the README claimed
them as open for a while:

- **The Astro+ enrolment flow now has an interface.** The six functions had
  no caller because nothing ever returned `pay_token` — the parent's link
  was unreachable outside the SQL editor. `enrolment_links.sql` adds the
  two functions that hand it out, and there is now a student form, a link
  to pass on, a parent-facing payment page, and an admin queue.
- **Best test score is on the topic map.** `my_percentages` supplies it.
  The Dart side had been built and tested for months and was receiving an
  empty map.

`docs/PROJECT_STATE.md` is the honest, current account of all of it.

---

## Documentation

| File | What's in it |
|---|---|
| `CHANGELOG.md` | What each release added, and what it removed |
| `docs/PROJECT_STATE.md` | Current state, constraints, and the things that will bite you |
| `docs/SQL_ORDER.md` | Which SQL files to run, in what order, and which never to run again |
| `docs/INSTALL.md` | Setting up from nothing |
| `docs/HOW_IT_WORKS.md` | The architecture |
| `docs/AUTHORING_GUIDE.md` | How to write a question |
| `docs/LESSON_AUTHORING.md` | How to write a lesson |
| `docs/QUESTION_BANK_AUDIT.md` | The full audit of all 1,600 |
| `docs/TESTING.md`, `docs/TEST_PROCEDURE.md` | How to run the suites |
| `docs/RUNBOOK.md` | Operational tasks |
| `docs/LAUNCH_CHECKLIST.md` | What has to be true before launch |

---

## Credits

The topic-mindmap concept, the original Grade 9 and 10 lesson set, and the
mastery-percentage rule come from Dileep Kumar's
[topicmindmap](https://github.com/dileepku077/topicmindmap). 51 of the lessons
here started as his and were remapped onto this app's units and misconception
tags; the other 168 were authored for this project.

---

## A note on this repository being public

The SQL under `supabase/migrations/questions/` contains `correct_index` and the
full feedback text for every one of the 1,600 questions. In a public repository
that is a public answer key, findable by any student who thinks to look.

The running app is unaffected — the database never serves answers to a browser,
whatever is in this repo. But if the question bank is ever meant to be the moat,
this is the file set to move somewhere private.
