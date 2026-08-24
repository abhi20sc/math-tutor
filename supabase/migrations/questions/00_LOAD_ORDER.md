# Question banks — what to run, and in what order

Everything in `supabase/migrations/questions/` is a **question bank file**: it
loads one unit of one course and nothing else. The schema lives one level up.

Each file is safe to run on its own, at any time. Every one opens with

```sql
delete from questions where course_code = '...' and unit = '...';
```

so re-running a corrected copy replaces that unit cleanly. Student attempts key
on course, unit and `sort_order`, never on question ids, so a student who has
already answered a question still has that history after a reload.

---

## Order

Run these once, in this order, before any question file:

| # | File | What it does |
|---|---|---|
| 1 | `../astro_math_assist_setup.sql` | Everything: tables, RLS, all 103 functions, the avatar bucket, the admin drill-down. |

Then any question file, in any order. They do not depend on each other.

**Do not run `../avatars.sql` or `../admin_teacher_students.sql`.** Both are
folded into the setup file above. `admin_teacher_students.sql` now fails with
*cannot change return type of existing function*, because the copy in the setup
file returns more columns than the old standalone one. They are kept only for a
database that predates the merge. The three-step order printed here previously
would have stopped the install at step 2.

**Or skip all of this and run `../questions_all.sql`**, which is every file
below concatenated in the one order that works — question files first, each
course's figure file straight after its own. One paste, 1600 questions, 60
figures.

**One exception.** Each course with figures has a `figures_*.sql` file, and it
must be run AFTER every question file for that course. It wipes the `figure`
column for the whole course and re-attaches every image, so re-running a single
unit — whose `delete` takes the figure with the row — leaves that unit
imageless until the figure file runs again.

---

## The banks

Forty units, 1600 questions, across six courses.

**All of them were audited end to end in August 2026 and repaired.** 314
defects were found — one live wrong answer key, two more wrong keys, one
distractor that was secretly correct, 14 pairs of options that were the same
answer written two ways, and 247 feedback lines that either named a mistake
which does not produce their option or handed the answer over. A second
independent pass over every changed question found 27 further problems and
those were fixed too. See `docs/QUESTION_BANK_AUDIT.md` and
`docs/QUESTION_BANK_REPAIR.md`.

304 questions were edited. **No option changed position and no `correct_index`
moved** — that property was enforced by reloading every file into a scratch
Postgres and diffing it row by row against the pristine original.

**All 40 units pass all thirteen checks.** MPM2D was the last holdout on check
12 and has now been rotated; see Grade 10 below.

A student who picks the longest option every time scores 398 of 1600 — 24.9%,
against a chance baseline of 25%. Two checks now guard this and the
same-answer-twice rule: `tools/check_option_lengths.py` and
`tools/check_distinct_options.py`.

### Grade 9 — MTH1W · `grade09_mth1w/`

| File | Unit | Questions | Figures |
|---|---|---|---|
| `questions_mth1w_u1.sql` … `_u9.sql` | Units 1–9 | 40 each, 360 total | none |

Nothing in Grade 9 needed a diagram.

### Grade 10 — MPM2D · `grade10_mpm2d/`

| File | Units | Questions | Figures |
|---|---|---|---|
| `questions_grade10.sql` | all six | 240 | 33, via `figures_grade10.sql` |

A single file covering six units, written before the one-file-per-unit
convention.

**This is the live course, and it carried the worst defects in the bank.**
Factoring Q21 had a wrong key — `2(6m² − mn + 4) − (7m² + 4mn − 2)` is
`5m² − 6mn + 10`, the key said `5m² − 5mn + 10`, and none of the four options
was correct, so every student who attempted it was marked wrong. That, four
duplicate-option pairs, an answer leak in Factoring Q22 and 46 feedback defects
are all fixed. 27 questions were also retagged, which brought all six units
through checks 11a and 11b for the first time.

**Reloading it changes what students see today.** It is worth doing — Q21 alone
is worth doing — but do it deliberately, and run `figures_grade10.sql` straight
after.

**Option positions were rotated in August 2026**, which is what finally brought
Quadratics — and the other five units — through check 12. The answer now sits at
A, B, C and D ten times each in every unit.

The cost, accepted deliberately: `attempts.chosen_index` stores the integer
position a student tapped, so a historical row now points at a different option
than it did at the time. Scores, `was_correct` and the tutor dashboard's
diagnosis are all unaffected — those were computed and stored at answer time,
and `misconception_tag` is snapshotted per attempt. Only code that re-reads
today's option list to display a past choice would be wrong, and nothing does
that. If you ever need to avoid the cost, pair the rotation with an update that
applies the same cyclic shift to `attempts.chosen_index`.

### Grade 11 — MCR3U · `grade11_mcr3u/`

| File | Unit | Questions | Figures |
|---|---|---|---|
| `questions_mcr3u_u1.sql` | Functions | 40 | — |
| `questions_mcr3u_u2.sql` | Rational Expressions | 40 | — |
| `questions_mcr3u_u3.sql` | Transformations | 40 | — |
| `questions_mcr3u_u4.sql` | Exponential Functions | 40 | — |
| `questions_mcr3u_u5.sql` | Trig Geometry | 40 | 5 |
| `questions_mcr3u_u6.sql` | Trig Functions | 40 | 2 |
| `questions_mcr3u_u7.sql` | Discrete Functions | 40 | 1 |

Then `figures_mcr3u.sql`. **280 questions, 8 figures.**

Unit 1 was reloaded once after shipping with the correct answer at option A in
39 of its 40 questions. That defect is what check 12 exists to catch.

### Grade 12 — MHF4U · `grade12_mhf4u/`

| File | Unit | Questions | Figures |
|---|---|---|---|
| `questions_mhf4u_u1.sql` | Polynomial Functions | 40 | — |
| `questions_mhf4u_u2.sql` | Factoring Polynomials | 40 | — |
| `questions_mhf4u_u3.sql` | Logarithmic Functions | 40 | — |
| `questions_mhf4u_u4.sql` | Trig in Radians | 40 | 1 |
| `questions_mhf4u_u5.sql` | Trig Identities and Equations | 40 | 1 |
| `questions_mhf4u_u6.sql` | Rates of Change | 40 | — |
| `questions_mhf4u_u7.sql` | Rational Functions | 40 | — |

Then `figures_mhf4u.sql`. **280 questions, 2 figures.**

Unit 6 and Unit 7 share a boundary the source material blurs: the Jensen review
package for Rates of Change also covers rational equations and inequalities.
Those are authored in Unit 7 only, so nothing is asked twice.

### Grade 12 — MCV4U · `grade12_mcv4u/`

| File | Unit | Questions | Figures |
|---|---|---|---|
| `questions_mcv4u_u1.sql` | Derivative Rules | 40 | 1 |
| `questions_mcv4u_u2.sql` | Curve Sketching | 40 | 3 |
| `questions_mcv4u_u3.sql` | Derivatives of Trig and Exponential Functions | 40 | — |
| `questions_mcv4u_u4.sql` | Geometric Vectors | 40 | 4 |
| `questions_mcv4u_u5.sql` | Algebraic Vectors | 40 | 3 |
| `questions_mcv4u_u6.sql` | Lines and Planes | 40 | 1 |

Then `figures_mcv4u.sql`. **240 questions, 12 figures** — the most of any
course, because vectors are the one topic where the arrangement of the arrows
IS the question.

Note the unit name for Unit 3 is long: `Derivatives of Trig and Exponential
Functions`. It has to be quoted exactly when running the gate.

### Grade 12 — MDM4U · `grade12_mdm4u/`

| File | Unit | Questions | Figures |
|---|---|---|---|
| `questions_mdm4u_u1.sql` | Displays of Data | 40 | 2 |
| `questions_mdm4u_u2.sql` | Collecting Data | 40 | — |
| `questions_mdm4u_u3.sql` | Normal Distributions | 40 | 1 |
| `questions_mdm4u_u4.sql` | Probability | 40 | 1 |
| `questions_mdm4u_u5.sql` | Probability Distributions | 40 | 1 |

Then `figures_mdm4u.sql`. **200 questions, 5 figures.**

Unit 2 is the only unit in the bank with essentially no arithmetic in it. Every
distractor there is a sentence a student would write on a test and lose the
mark for.

### `_retired/`

`questions_sample.sql` — the demo unit from before the real bank existed. Kept
only so the delete statement inside it can be run if the sample unit is ever
still sitting in a database:

```sql
delete from questions where unit = 'Linear systems (sample)';
```

---

## Figures

60 in total, generated by `tools/make_figures.py` into `web/figures/`. Run:

```bash
python3 tools/make_figures.py
```

It regenerates every PNG and rewrites all five `figures_*.sql` files. 28 of the
60 carry a **ruler test**: the script computes what a student measuring the
drawing would get, and refuses to write the file unless that value lands nearest
a WRONG option. That gate has caught real leaks twice, and on the MCV4U wrench
it forced a 50-degree distortion rather than the usual 15 to 20, because sine is
flat near 90 degrees and a milder one rounded straight back onto the answer.

Every figure file header records which candidate figures were REJECTED and why.
That list is worth reading before adding one: most of what looks like an obvious
diagram turns out to be the answer sheet.

---

## Before a unit file ships

Run the gate on a scratch Postgres. Thirteen checks; every one prints zero rows
when the unit is clean.

```bash
dropdb --if-exists ama && createdb ama
psql -d ama -f tests/00_supabase_stub.sql
psql -d ama -f supabase/migrations/supabase_full_setup.sql
psql -d ama -f supabase/migrations/questions/grade12_mdm4u/questions_mdm4u_u5.sql
psql -d ama -v course=MDM4U -v unit='Probability Distributions' -f tools/check_questions.sql
```

Check 10 is the answer-leak detector and has caught real leaks in fourteen
places across the bank. It has two deliberate exemptions on its substring arm —
one-character answers, and answers the prompt already contains — so it can still
miss a leak phrased around a word the question itself uses. One such slipped
through in MDM4U Unit 1 and was found by reading, not by the gate. If a
feedback line names which option is bigger, larger, or first, read it again.

Check 12 is the answer-position detector, added after MCR3U Unit 1 shipped with
the correct answer at option A in 39 of its 40 questions. If check 12 fires on a
course that is **not live**:

```bash
python3 tools/balance_answer_positions.py <file.sql> --write
```

which rotates each option list so the answer lands at A, B, C and D an equal
number of times. It never changes a question, an option or a feedback line —
only the order they appear in — and running it twice does nothing the second
time.

**Do not run it on `questions_grade10.sql`.** See the Grade 10 note above.

### What the gate does not catch

The August audit found 314 defects in a bank where 34 of 40 units passed all
thirteen checks. Before shipping a unit, also check by hand:

- **Does each distractor's feedback name a mistake that actually produces that
  option?** Carry the mistake out and see where it lands. 247 lines failed this.
- **Are any two options the same answer?** Evaluate all four. `(x-7)(x-7)` and
  `(x-7)²` are one option offered twice; so are `5/6` and `10/12`.
- **Is any distractor actually correct?** `sin(pi/2 + x)` really is `cos x`.
- **Does a feedback line hand over the arithmetic** that lands on the answer, or
  tell the student the step that produces it, without printing the answer?

One of the two checks worth adding now exists:

```bash
python3 tools/check_distinct_options.py <db>
```

It parses every option into a symbolic expression and flags any question where
two of them are equal — the defect class that accounts for thirteen of the
seventeen CRITICALs the audit found, and that no text comparison can see. Run it
straight after the gate. It flags ten questions on the current bank, all correct
by design; its own docstring explains which and why.

Still to write: a longest-option-tell check, failing a unit above roughly 14 of
40. The bank sits at 799 of 1600 against a chance baseline of 400.

The full app test suite is separate and unaffected by question files:

```bash
psql -d ama -f tests/test_ama.sql        # 212 checks
```

Never run `test_ama.sql` against the live database. It creates its own fixture
users.
