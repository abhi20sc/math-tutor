# AUTHORING GUIDE — turning lesson material into AMA questions

This is the pipeline for the new bank. Send the material, get back a SQL
file per unit that loads straight into the database. Read this before
sending the first batch, because the shape of what you send decides the
quality of what comes back.

---

## What to send, per unit

1. **Lesson notes** — what was actually taught, in the order it was taught
2. **Lesson solutions** — worked examples, because the *working* is where
   the misconceptions live
3. **Practice worksheets**
4. **Worksheet solutions**

The solutions matter more than the questions. A wrong option is only worth
writing when it is the answer a real student reaches by a real mistake, and
the mistakes are visible in worked solutions: the sign that gets dropped,
the step that gets skipped, the formula that gets half-remembered.

Also send, or approve, a **list of subtopics for the unit**. This drives
the whole reporting layer — see below.

---

## What comes back, per unit

One SQL file containing 40 questions:

| Level | sort_order | Access |
|---|---|---|
| Easy | 1–10 | Free |
| Medium | 11–20 | Free |
| Challenge | 21–30 | Astro+ |
| Advanced | 31–40 | Astro+ |

Every file starts with `delete from questions where grade = N and unit =
'...'`, so re-running a corrected file replaces the unit cleanly, and
student history survives (attempts key on grade/unit/sort_order, never on
question ids).

---

## Subtopic tags — the change from the old bank

The old bank tagged questions with mistake descriptions ("dropping the
minus sign"). The new bank tags them with **subtopics**: every question
carries the slug of the subtopic it tests, and `misconception_label()`
maps slugs to the subtopic names from your material.

So a teacher's dashboard says *"eleven students struggling — Elimination
method"* and a parent's report says *"stuck on: Mixture problems"*. The
labels come from the material's own structure, which means they use the
vocabulary the student hears in class.

Mechanically: labels live in the `misconception_labels` table, and every
unit file upserts its own subtopic names at the top. Loading a unit loads
its vocabulary with it, and re-running a corrected file updates both.

Slug convention: `sub-<short-name>`, e.g. `sub-elimination-method`,
`sub-word-problem-setup`. Reuse a slug across levels when the subtopic is
the same — that is what lets the dashboard aggregate.

---

## The rules every question follows

These are what made the old bank work, kept:

- **Four options, exactly one correct.** `correct_index` is 0-based.
- **Every wrong option is a specific mistake**, reachable by a plausible
  error from this unit — never a random number. If three real mistakes
  cannot be found for a question, the question is too thin to include.
- **Feedback names the mistake without revealing the answer.** "That is
  the slope of the first line" — never "the answer is 0.5". The student
  tries again; that is the pedagogy.
- **Correct option feedback is exactly** `Correct.` — anything longer
  leaks information through length.
- **No apostrophes anywhere in any string.** One `'` ends the SQL string
  and kills the whole file. Write "cannot", "it is", "the students".
- **Multi-line prompts** use `E'...\n...'`.
- Distractors must not duplicate each other or the correct answer —
  checked before delivery.

Level meanings, so the four bands are honest:

- **Easy** — one concept, one step, vocabulary and recognition
- **Medium** — the standard procedure, two or three steps
- **Challenge** — multi-step, word problems, choosing the method
- **Advanced** — parameters, proofs of understanding, combined subtopics,
  the questions that separate 90s from 70s

---

## Figures

Some questions earn a diagram. Most do not, and a surprising number are
actively made worse by one — a figure that can be measured is a leaked
answer, exactly like feedback that states it.

**33 of the 240 currently have figures.** The split is lopsided and that is
the right answer: 28 in Trigonometry (triangles are physical objects, and
the sentence has to describe which angle and which side), 3 in Solving
quadratic equations, 1 in Analytic geometry, and **none at all** in Linear
systems, Quadratics or Factoring.

### The pipeline

`tools/make_figures.py` draws everything from code and regenerates
`figures_grade10.sql`, which attaches the paths.

```bash
python3 tools/make_figures.py     # renders web/figures/*.png + the SQL
```

Run order is setup -> questions -> **figures**. The per-unit delete in a
questions file wipes the figure column with the rest of the row, so the
figures file re-runs after any question reload. The PNGs live in
`web/figures/` and ship inside every deploy.

### The ruler test — this is the part that matters

Every figure carrying a measurable number registers a `Ruler(...)`: what a
student measuring the picture would compute, the real answer, and the four
options. The script asserts the measured value lands nearest a **wrong**
option and refuses to write the file otherwise.

This is not theoretical. The first batch of figures shipped with `trig_13`
drawn at 47 degrees against a stated 52; a student with a protractor
computed 9.5 m, and the nearest option to 9.5 was 8.6 — the correct answer.
The figure was quietly doing the question. Two more had the same flaw, and
the ruler test caught two further leaks the moment it was added.

So: **draw angles 15-20 degrees off, not 5.** Small errors still leak on
multiple choice, where the options are often only 20% apart.

### The five families

Adding a figure is usually calling an existing function with different
arguments, not writing a new one.

| Family | Function | Covers | Kept safe by |
|---|---|---|---|
| A | `right_tri` | 8 right-triangle questions | drawn angle far from the stated one |
| B | `oblique_tri` | 10 sine/cosine-law triangles (+ cevian mode) | two fixed skeletons; labels hung on the shape, never the shape built from the labels |
| C | `similar_pair` | 2 similar-triangle pairs | the drawn scale factor is deliberately not the real one |
| D | `rect_feature` | 2 border/fence problems | border drawn fat; fence labelled purely algebraically |
| E | `algebra_shape` | 2 shapes with algebraic sides | algebraic labels cannot be measured at all |

Plus nine bespoke scenes (ladder, tree, shadows, cliff, tower, roads, kite,
river survey) where the story is the point.

### The selection rubric

Apply in order. The first rule that fires decides it.

1. **No axes, no grid, no coordinate plane. Ever.** If the question mentions
   coordinates, a graph, an intercept, a slope from two points, or "plot" —
   no figure. This alone correctly rejects nearly all of Analytic geometry
   and every graphing question in Linear systems and Quadratics.
2. **Run the ruler test.** Pretend a student measures your drawing, using
   whichever label is numeric as the scale. The number they get must land
   nearest a wrong option. If it lands on the answer, redraw and re-check.
   The script does this for you — add the `Ruler(...)`.
3. **Prefer algebraic labels to numbers.** A figure labelled `w`, `x + 7`,
   `60 - 2w` cannot be measured at all, and never needs rule 2.
4. **Draw what you were told, never what you are meant to work out.**
   "Legs x and x + 7, hypotenuse 13" is the setup — fine. "Run 3, rise 4,
   find the length" is not: drawing the right triangle reveals *that
   Pythagoras applies*, which is the whole question. If you cannot describe
   the figure without naming something from the answer or the method, skip
   it.
5. **If the answer is a word, a picture of that word is the answer.**
   Definition questions ("what is a median?", "which side is the
   hypotenuse?") get nothing.
6. **Draw when the sentence has to describe a configuration.** Green-light
   phrases: "the angle opposite the n side", "the matching side of the
   other triangle", "a path of uniform width around", "fences three sides
   against a wall", "the angle between them". If *you* had to read the
   sentence twice to picture it, a Grade 10 student is blocked.
7. **Every figure must visibly earn its "not drawn to scale".** If someone
   measures it and it checks out, the figure is broken.
8. **Check for an existing function before writing a new one.** A new
   family should only appear for a genuinely new *kind* of picture — and if
   the new kind has one member, add it as a flag on the nearest existing
   function instead.

### Known rejects worth not re-litigating

- Every parabola sketch (Quadratics, and the projectile/profit questions in
  Solving quadratic equations): max height, landing time and the vertex are
  the answers, and all three are visible on any sketch.
- Every circle question in Analytic geometry: draw it and a radius is
  measurable, or "is this point inside" is settled by eye.
- Algebra-tile and area-model diagrams for Factoring: the model *performs*
  the factorisation.
- Table-of-values questions: the table belongs in the prompt text, not in a
  rendered PNG that cannot be selected, scaled or read by a screen reader.
- Money, mixture, age and interest word problems: a drawing of the story is
  not a drawing of the maths.

---

## Review checklist before a unit ships

- [ ] 10 per level, sort_order 1–40 with the right bands
- [ ] Every question tagged with an approved subtopic slug
- [ ] `misconception_label()` entries added for any new slug
- [ ] No apostrophes (grep for `'` inside strings)
- [ ] No distractor equals the correct answer; no duplicate options
- [ ] No feedback reveals the answer, including by elimination
- [ ] File re-runs cleanly (delete-then-insert verified)
- [ ] Every subtopic appears in EVERY difficulty band, and no subtopic falls
      outside 5–10 questions for the unit
- [ ] Every answer independently recomputed, not copied from the source PDF
- [ ] Every distractor is genuinely wrong AND matches the mistake its own
      feedback describes (a distractor whose stated reasoning produces a
      different number is worse than no distractor)

Run the gate rather than eyeballing it:

```
psql -d <db> -v course=MTH1W -v unit='Geometry' -f tools/check_questions.sql
```

Eleven checks; zero rows everywhere means the unit is clean. Check 10 is the
leak detector — it fires on both the phrase forms ("the answer is…") and on
any wrong-option feedback that literally contains the correct option text.

---

## What happens on your side

1. Run `supabase_full_setup.sql` first if it has changed (it creates the
   labels table), then the questions file in the SQL editor
2. The units appear in the app immediately — no deploy
3. Delete the sample unit once the real bank is in:

```sql
delete from questions where unit = 'Linear systems (sample)';
```

## Status

The full Grade 10 bank — `questions_grade10.sql`, 240 questions across all
six units — was authored from the Jensen MPM2D material and is loaded by the
steps above. The full Grade 9 bank — `questions_mth1w_u1.sql` through
`questions_mth1w_u9.sql`, 360 questions across all nine units — was authored
the same way from the MTH1W material, one file per unit, and needs no
figures. Corrections to any single unit can ship as a new copy of just
that unit block: the per-unit delete makes it safe.
