# Astro Math Assist — project state

**The single source of truth. Written so a chat can be discarded without
losing anything.** Current as of 18 Aug 2026.

---

## What this is

A maths practice web app for Ontario high school, built by Jithu for his
uncle, who tutors.

**The thesis, which drives every design decision:** wrong answers are the
product. Each question has four options; the three wrong ones are the answers
produced by specific, named mistakes, and the feedback tells the student
*which mistake they made* **without revealing the answer**, so they try again.
Anything that undermines that — leaking the answer in feedback, punishing
mistakes, hiding the hint below the fold — is a bug, not a preference.

---

## Stack and locations

| Thing | Where |
|---|---|
| App | Flutter Web, one file: `lib/main.dart` (~11,800 lines). **Keep it one file** — deliberate, for a solo beginner maintainer. Do not split. |
| Database | Supabase, project ref `frkswzowskeqmgdrrwab`, name `Maths_Tutoring` |
| Hosting | Netlify — `https://math-tutortesting.netlify.app`, deploy by dragging `build/web` |
| Payments | Stripe (test mode) + Interac e-transfer (manual, admin-confirmed) |
| **Project folder** | **`~/Downloads/math_tutor`** |

### The folder moved, and why it matters

The project used to live at `~/Desktop/math_tutor`. **Do not go back there.**
The Desktop is iCloud-synced, and with the disk near full macOS evicted files
to placeholders mid-session — silently reverting edits, breaking builds, and
producing deploys with files missing. A whole afternoon was lost to it. The
old folder is retired-in-place as a backup; the live project is in Downloads,
which iCloud does not sync.

Related: keep **5 GB+ free**. A build needs ~1 GB, but below a couple of GB
macOS itself starts misbehaving. `dart2js` failing with `No space left on
device` is the loud version; silent file eviction is the quiet one.

---

## Build and deploy

```bash
cd ~/Downloads/math_tutor
flutter pub get          # needed after any pubspec change
flutter build web
# then drag build/web onto Netlify
```

Expect **98 files** in `build/web` (38 app + 60 figures). If figures are
missing, check `web/figures/` has 60 PNGs — they ship from source, and their
absence once caused questions to reference invisible diagrams.

After deploying, close the site tab completely and reopen. Flutter's service
worker serves the old app for a load or two otherwise.

---

## Question banks

| Course | Grade | Units | Questions | Figures | Status |
|---|---|---|---|---|---|
| MTH1W | 9 | 9 | 360 | 0 | Audited, repaired, ready to load |
| MPM2D | 10 | 6 | 240 | 33 | **Live** — reload changes what students see |
| MCR3U | 11 | 7 | 280 | 8 | Audited, repaired, ready to load |
| MHF4U | 12 | 7 | 280 | 2 | Audited, repaired, ready to load |
| MCV4U | 12 | 6 | 240 | 12 | Audited, repaired, ready to load |
| MDM4U | 12 | 5 | 200 | 5 | Audited, repaired, ready to load |

**Installing is two files.** `supabase/migrations/astro_math_assist_setup.sql`
then `supabase/migrations/questions_all.sql`. `docs/INSTALL.md` is the whole
procedure. `avatars.sql` and `admin_teacher_students.sql` are folded into the
setup file and **must not be run separately** — the second one now fails with
*cannot change return type of existing function*, because the copy in the setup
file returns more columns.

The `courses` table also seeds **MPM1D**, the pre-2021 Grade 9 academic course,
which has no bank. Harmless: `list_courses()` returns only courses with
questions loaded, so it never reaches the signup screen.

**The bank is complete: 40 units, 1600 questions, 60 figures.**
`supabase/migrations/questions/00_LOAD_ORDER.md` is the manifest — what to run,
in what order, and which figure file follows which course.

**All 1600 were then audited end to end and repaired.** Reports:
`docs/QUESTION_BANK_AUDIT.md` (what was wrong) and
`docs/QUESTION_BANK_REPAIR.md` (what was done). The short version: the keys
were strong — 1597 of 1600 correct — but the *feedback* layer was not, which
matters because the feedback layer is the product. 314 defects were found and
fixed, then a second independent pass over every changed question found 27
more, and those were fixed too.

The three that mattered: **MPM2D → Factoring → Q21 had a wrong key with no
correct option at all** and is live, so every student who attempted it was
marked wrong; MDM4U → Displays of Data Q18 and Q28 had keys generated from
unrounded regression output while their prompts printed rounded coefficients.

### Never review a question from an export that drops the figure

The audit's one real self-inflicted wound. The questions were exported for
review without the `figure` column, so every reviewer read a prompt saying
*"as shown"* against a record with no image, concluded the diagram did not
exist, and filed the question as unanswerable. Ten prompts were then rewritten
to describe the picture in words — and several of those descriptions stated the
answer outright. The Venn question came to say which region was shaded; the
vector question named which arrow ran between which vertices.

On a figure-bearing question **the picture IS the question**. All ten were
reverted. If you ever export this bank for review, export `figure` with it, or
say plainly in the brief that the diagrams are attached separately and their
absence is not a defect.

**All 40 units now pass all thirteen checks.** MPM2D was the last holdout on
check 12 — the answer sat at option D in 17 of Quadratics' 40 questions — and
its option lists have now been rotated, with Jithu's agreement that historical
`attempts.chosen_index` need not keep pointing at the same option. See the
rotation note under Authoring rules.

**The length tell is gone.** A student who picks the longest option every time
now scores **398 of 1600, which is 24.9% against a chance baseline of 25%**. It
was 453 (28.3%) before, concentrated in about fifteen units, worst at MDM4U
Displays of Data on 21 of 40. Note that an earlier reading of this put the edge
at roughly 50% — that was wrong, because it counted ties as wins, and a tie is
not exploitable. `tools/check_option_lengths.py` measures it properly.

Source material for all of it is in **`~/Downloads/GRADE NN - COURSE/`**,
organised as `Unit N - Name/Lesson N - Name/{Lesson,Worksheet}{,_Solutions}.pdf`.
The solutions PDFs matter most — the misconceptions live in the worked steps.

### What each Grade 11 and 12 unit covers

**MCR3U** — Functions · Rational Expressions · Transformations · Exponential
Functions · Trig Geometry (5 figures) · Trig Functions (2) · Discrete Functions (1)

**MHF4U** — Polynomial Functions · Factoring Polynomials · Logarithmic
Functions · Trig in Radians (1 figure) · Trig Identities and Equations (1) ·
Rates of Change · Rational Functions

**MCV4U** — Derivative Rules (1 figure) · Curve Sketching (3) · Derivatives of
Trig and Exponential Functions · Geometric Vectors (4) · Algebraic Vectors (3) ·
Lines and Planes (1)

**MDM4U** — Displays of Data (2 figures) · Collecting Data · Normal
Distributions (1) · Probability (1) · Probability Distributions (1)

Two boundaries in the source material needed a decision, and both are recorded
in the relevant file headers. MHF4U Unit 6 and Unit 7 both carry rational
equations in Jensen; they are authored in Unit 7 only. MCV4U Unit 6 has seven
lessons but six subtopics — the two intersection lessons involving a plane are
counted together, because splitting them would put fewer than five questions in
each and trip check 11b.

### Authoring rules

Full detail in `docs/AUTHORING_GUIDE.md`. The load-bearing ones:

- 40 questions per unit: 1–10 Easy, 11–20 Medium, 21–30 Challenge,
  31–40 Advanced. Easy/Medium free; Challenge/Advanced need Astro+.
- Four options, `correct_index` 0-based; correct feedback is **exactly**
  `Correct.` (anything longer leaks through length).
- Every distractor is a *named* mistake, and its feedback must describe the
  mistake that actually produces that number.
- **No apostrophes anywhere** — one ends the SQL string and kills the file.
- Every subtopic appears in every band; 5–10 questions per subtopic per unit.
- Each file opens with `delete from questions where course_code=… and unit=…`
  so a corrected file replaces the unit cleanly. Student attempts key on
  course/unit/sort_order and survive reloads.
- **No two options may be the same answer** — not the same value, and not the
  same expression written two ways. `(x−7)(x−7)` and `(x−7)²` are one option
  offered twice. So are `5/6` and `10/12`, and `3^16` and `9^8`. This rule was
  implicit and got broken 13 times; `tools/check_distinct_options.py` now
  enforces it.
- **The correct option must not be spottable by length.** Bring a distractor up
  to the answer's level of detail rather than cutting the answer short.
  `tools/check_option_lengths.py` enforces it, in both directions.

### Reordering options on a LIVE course, and what it costs

`attempts.chosen_index` stores the **integer position** of the option a student
tapped, and there is an index on `(course, unit, sort_order, chosen_index)`. So
rotating an option list on a live unit means a historical row saying
`chosen_index = 2` now points at a different option than it did at the time.

What that does and does not break:

| | |
|---|---|
| The student's score and `was_correct` | **Unaffected** — computed and stored at answer time |
| The tutor dashboard's diagnosis of past work | **Unaffected** — `misconception_tag` is snapshotted per attempt |
| Any code that re-reads today's option list to show which option a past attempt chose | **Wrong** |

MPM2D was rotated in August 2026 with Jithu's explicit agreement that the last
row was acceptable, which is what finally brought all six of its units through
check 12. Nothing in the app currently does that third thing.

If you ever need to avoid the cost, the fix is not to skip the rotation but to
pair it with a migration that applies the same shift to `attempts.chosen_index`
for the same questions: rotation is cyclic, so `new = (old + r) mod 4` restores
the mapping exactly.

### Verification, every unit, no exceptions

1. **Recompute every answer independently with sympy** — never copy from the
   source PDF. Two genuine errors in the Jensen material were caught this way.
2. **Run the gate:**
   ```
   psql -d <db> -v course=MCR3U -v unit=Functions -f tools/check_questions.sql
   ```
   13 checks; zero rows everywhere. Check 10 is the leak detector and has
   caught real leaks in fourteen places across the bank. Check 12, added after
   MCR3U Unit 1 shipped with the answer at option A in 39 of 40 questions,
   catches a predictable answer position; `tools/balance_answer_positions.py`
   fixes it by rotating each option list.

   Check 10 has two deliberate exemptions on its substring arm — one-character
   answers, and answers the prompt already contains — so it can still miss a
   leak phrased around a word the question itself uses. One did, in MDM4U Unit
   1, and was found by reading rather than by the gate. If a feedback line
   names which option is bigger, larger or first, read it again.

3. **Check what the gate cannot.** The August audit found 314 defects in a bank
   where 34 of 40 units passed all thirteen checks. The gate is necessary and
   nowhere near sufficient. What it misses:

   - **Feedback that names the wrong mistake.** 247 lines described an error
     that does not produce the option they sit on. Nothing mechanical catches
     this; the only method is to carry out the named mistake and see where it
     lands. Do that for every distractor.
   - **Two options that are the same answer.** 13 questions offered a duplicate
     wearing different clothes.
   - **A distractor that is also correct.** MHF4U Trig Identities Q1 offered
     `sin(π/2 + θ)` as wrong when it is identically `cos θ`.
   - **A leak the substring arm cannot see** — feedback that gives the
     arithmetic landing on the answer, or tells the student the step that
     produces it, without printing the answer itself.

### Two checks worth adding

Both would have caught real defects this bank actually had:

- ~~**Distractor uniqueness**~~ — **written**, as `tools/check_distinct_options.py`.
  Parses every option into a symbolic expression and flags any two that are
  equal. Catches 13 of the 17 CRITICALs the audit found. Run it after the gate:

  ```bash
  python3 tools/check_distinct_options.py ama
  ```

  It flags ten questions on the current bank and all ten are correct by design —
  nine "factor completely" items whose distractors are deliberately incomplete
  factorings, and one asking which number is *written* correctly in scientific
  notation. Read a flag, do not obey it.
- ~~**Longest-option tell**~~ — **written**, as `tools/check_option_lengths.py`.
  It measures what a length-guesser actually scores rather than counting ties,
  in both the longest and shortest directions, and fails a unit outside 5–15
  out of 40. The whole bank now sits at 24.9% against a chance 25%.

  Two units warn and cannot be fixed: **MCV4U Derivatives of Trig and
  Exponential Functions** (shortest-guesser 5.1) and **MTH1W Powers** (5.4). In
  both, every distractor is either a bare value or the correct derivative with a
  factor dropped, so it is *necessarily* shorter and can only be padded by
  inventing symbols. That is inherent to the pedagogy, not a defect.

### Figures

`tools/make_figures.py` draws all 60 from code and asserts the **ruler test**:
what a student measuring the picture would compute must land nearest a
*wrong* option. 28 of the 60 carry one. Draw angles 15–20° off, never 5 — and
sometimes far more than 20. On the MCV4U wrench the answer depends on sin 80°,
and sine is so flat near 90° that anything drawn above about 55° rounded
straight back onto the correct answer; that figure is drawn at 30°.

Most questions correctly get no figure, and every figure file header records
which candidates were REJECTED and why. That list is the useful part. The
recurring reasons:

- **Anything on a numbered grid.** A histogram, a box plot, a trig curve, a
  rational curve with its asymptotes drawn: the answer is countable.
- **A picture that states the answer.** Three planes drawn crossing in a line
  is a drawing of the words "they cross in a line". A normal curve with 68, 95
  and 99.7 printed under it is the answer sheet for a third of MDM4U Unit 3.
- **A table.** Sign charts, factor tables, distribution tables and Pascal
  triangles all belong in prompt text if they belong anywhere.

What earns a figure is a question the picture IS: which arrow lies along the
line, which rope carries more load, which region is shaded, which curve is
wider. Grade 9 needed zero across nine units. MCV4U needed twelve, because
vectors are the one topic where the arrangement of the arrows is the whole
question.

---

## The app's security model

Verified live and pinned by the test suite. Do not weaken any of these.

- **The answer never reaches the browser.** `questions` has RLS on with no
  policy — a signed-in student selecting from it gets 0 rows. `list_questions`
  returns no `correct_index` and no `feedback`. Grading happens server-side in
  `submit_answer`.
- **Every RLS policy is `for select` only.** All writes go through
  `security definer` functions that re-check the caller.
- **Consent:** an invited student is not on the roster until they accept.
- **Paywall** enforced server-side in four places.
- **Photos** are private, tutor/admin-scoped, and never on a share link.
- **Five deliberate denials** whose only protection is the *absence* of a
  grant to `authenticated`: `grant_teacher_role`, `report_payload`,
  `upsert_subscription`, `update_subscription_by_sid`, `set_stripe_customer`.
  A blanket `grant execute on all functions to authenticated` re-opens all
  five and lets a student make themselves admin. Suite check **F5** exists
  because that mistake was actually made.
- **The Supabase SQL editor bypasses RLS entirely.** Permission checks must
  be done through the app, signed in as the relevant person.

### Never do these

- `delete from attempts` unqualified — the only record of every student's
  work, and nothing regenerates it.
- Run `tests/test_ama.sql` against the live database — it creates its own
  fixture users.
- Put the Stripe secret key or the Supabase service key in `main.dart`.

---

## Test suite

`tests/test_ama.sql` — **212 checks, all passing**, re-run against the repaired
Grade 10 question file in August 2026. Run on a scratch Postgres:

```
dropdb --if-exists ama && createdb ama
psql -d ama -f tests/00_supabase_stub.sql
psql -d ama -f supabase/migrations/astro_math_assist_setup.sql
psql -d ama -f supabase/migrations/questions/grade10_mpm2d/questions_grade10.sql
psql -d ama -f tests/test_ama.sql
```

Blocks: A paywall (15) · B answer never leaks (12) · C teachers and consent
(23) · D share links (12) · E admin and e-transfer (33) · F security-audit
regressions (12) · G tutor review and diagnosis (22) · H the five wired
functions (27) · I admin tutor drill-down (24) · J profile photos (32).

The stub in `00_supabase_stub.sql` fakes enough of Supabase's `auth` and
`storage` schemas that the storage policies are genuinely created and tested
locally rather than only on the live project.

---

## Recently shipped (this session)

- **Full audit and repair of all 1600 questions.** Syntax and semantics, every
  answer recomputed independently rather than checked against the source it was
  written from. 314 defects found and fixed; a second pass over every changed
  question found 27 more and fixed those. One live wrong key, two more wrong
  keys, one distractor that was secretly correct, 14 duplicate-option pairs and
  247 misdescribing or leaking feedback lines. 304 questions were edited without
  a single option changing position. Reports in `docs/`.
- **Admin → tutor drill-down.** Tap a tutor to see their classes and students,
  grouped by class, quietest first, read-only.
- **Colour pass.** Eight unit identity colours (all AA on white *and* cream,
  deliberately no green/orange so they can never be mistaken for the
  traffic-light bands); level cards with a difficulty ramp; person avatars;
  band-coloured first-try rates on rosters. Lettered tiles in front of topics
  were tried and cut — Jithu disliked them, and they repeated a word that was
  already beside them. Letters are for people; colour alone is for things.
- **Profile photos.** Private bucket, signed URLs, re-encoded to 256px JPEG in
  the browser (which strips the EXIF GPS tag — these users are children).
  Visible to the student, their own tutors, and the admin. **Never on a share
  link** — asserted three ways in Block J.
- **Grant hardening.** A signed-out browser could dial 49 functions; now
  exactly two (`list_courses` for the signup screen, `shared_report`).

## Outstanding

**Jithu's:**
- Supabase → Authentication → **enable Confirm email** before real students
- Supabase → Authentication → **enable leaked-password protection** (advisor)
- Stripe live keys + live prices + live webhook before real money
- Load the Grade 9, 11 and 12 banks (27 files, ready and verified), then run
  each course's `figures_*.sql` last — see `questions/00_LOAD_ORDER.md`
- Copy `web/figures/` into the deploy so the 60 images ship with the app
- Run `avatars.sql` if not already done, then rebuild with `flutter pub get`

**Mine:**
- The bank is authored, audited and repaired. All 40 units are on disk and
  39 of 40 pass the full gate; the exception is deliberate and documented
  above.
- Three things were found and deliberately not fixed, each a project of its
  own: the **longest-option tell** (799 of 1600 against a chance 400), the
  **notation split** between Unicode and ASCII files, and **MPM2D Quadratics
  check 12**, which cannot be fixed without breaking live attempt history.
- If a unit ever needs a correction: fix the SQL, re-run the 13-check gate,
  then re-run that course's `figures_*.sql` — the per-unit delete takes the
  figure with the row. Run `balance_answer_positions.py` **only on a course
  that is not live**.

**Discussed, not chosen:** dark mode; tutor booking / "Uber for tutors"
(a project in itself, not a feature); logo directions (5 SVGs exist in
`brand/`, Jithu declined them).

---

## Working agreement

Learned the hard way this session:

- **One file at a time**, and after writing to the Mac, read it back and
  hash-check before saying it landed. A `main.dart` lost inside a seven-file
  batch cost an afternoon.
- **Unit-by-unit delivery** for question banks, so nothing sits untestable.
- When a build misbehaves, check **disk space and file integrity first** —
  three separate "code" bugs turned out to be a full disk and iCloud.
