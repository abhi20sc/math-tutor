# Astro Math Assist — question bank repair

Companion to `QUESTION_BANK_AUDIT.md`. That document reported 314 defects across
1600 questions. This one records what was done about them.

**All 314 were fixed.** The bank was then re-audited from scratch — every changed
question re-verified by independent computation — which surfaced 27 further
problems: 24 introduced by the repair itself, and 3 the first audit had missed.
Those were fixed and re-checked in turn, which surfaced one more, now also
fixed. A final pass against the figure files caught a tenth-hour regression on
figure-bearing questions, described below.

Three verification rounds in total. The bank now stands at **304 questions
edited, 39 of 40 units passing the full gate, and no option anywhere having
moved position.**

---

## Where it landed

| | Before | After |
|---|---|---|
| Units passing the 13-check gate | 34 / 40 | **40 / 40** |
| Questions with a wrong or non-unique key | 3 | **0** |
| Questions with two options that are the same answer | 14 | **0** |
| Feedback lines that misdescribe or leak | 247 | **0 known** |
| Longest-option guesser | 28.3% | **24.9%** (chance 25.0%) |
| Questions loading cleanly | 1600 | 1600 |

Every gate check now passes on every unit. MPM2D → Quadratics was the last
holdout on check 12 and was fixed by rotating option lists, once it was agreed
that historical `attempts.chosen_index` need not keep pointing at the same
option. See the second phase below.

---

## What actually changed

| | |
|---|---|
| Questions touched | 538 of 1600 |
| Questions with a feedback line rewritten | 217 |
| Questions with an option reworded | 238 |
| Prompts rewritten | 18 |
| Option lists rotated (MPM2D only) | 178 |
| Misconception tags corrected | 34 |
| **Options moved position, outside the deliberate MPM2D rotation** | **0** |

That last line is the safety property. Every file was reloaded into a scratch
Postgres and diffed row by row against the pristine original, and the diff
refuses to pass if any option changed position or any key moved. The one place
positions did change — the MPM2D rotation, done last and on purpose — was
verified separately to be a pure cyclic shift with the key still pointing at the
same option content.

The final state was also loaded together with all five `figures_*.sql` files
and checked three further ways: all 60 figures still attach, all 28 ruler tests
still pass against the repaired option values, and no figure-bearing question
has a prompt differing from the one it was authored with.

---

## The five that mattered most

**1. MPM2D → Factoring → Q21 — the live wrong key.**
`2(6m² − mn + 4) − (7m² + 4mn − 2)` is `5m² − 6mn + 10`. The key said
`5m² − 5mn + 10` and no option was correct, so every student who ever attempted
it was marked wrong. The keyed option's text is now correct, and its three
distractors were re-derived against the corrected answer.

**2 and 3. MDM4U → Displays of Data → Q18 and Q28 — two wrong keys.**
Both came from options generated against unrounded regression output while the
prompt printed rounded coefficients. `r² = 0.9653`, not 0.9654. `73.89`, not
73.91 — and two of that question's distractors were drifting by the same cause
and were recomputed as well.

**4. MHF4U → Trig Identities → Q1 — a wrong answer that was right.**
The question asks which expression equals `cos θ`. `sin(π/2 + θ)` was offered as
a distractor, and it is identically `cos θ` — a true cofunction identity. Its
feedback claimed otherwise, which is a false mathematical statement printed in
front of a student. That option was replaced. The re-audit then found that two
of the *remaining* distractors, `sin(θ − π/2)` and `−sin(π/2 − θ)`, were the same
expression written two ways — a defect the first audit missed. That was fixed too.

**5. MCV4U → Geometric Vectors → Q38 — the question that couldn't be answered.**
It asked only how long the crossing takes, and two options answered 3.0 minutes,
differing in a justification clause the prompt never requested. The prompt now
asks for both the time and whether the current affects it, so exactly one option
answers what is asked.

---

## The feedback layer

247 lines either named a mistake that does not produce their option, or handed
the answer over. That was the real finding of the audit, because it is the layer
the whole bank is built on. Each was rewritten so that the named mistake, carried
out, lands on that option's exact value — and so that the line stops at the
diagnosis.

The re-audit was strict about that second half, and caught the repair over-
reaching in a consistent way: several rewrites diagnosed the error correctly and
then added a corrective clause — *instead of averaging them*, *it changes sign as
it crosses the equals sign*, *it is not subtracted from the height* — which hands
the student the step that produces the answer. Those clauses were cut. The
diagnosis alone is the product; a student who knows what they did wrong can do
the rest.

---

## Two questions were replaced outright

Both to close a gate-check-11a coverage hole created by an otherwise-correct
retag — a subtopic that ended up with no question in one difficulty band.

- **MDM4U → Displays of Data → Q8** was *What does the correlation coefficient r
  measure?*, which duplicated Q16, Q35 and Q36 and was tagged regression despite
  being about correlation. It is now an Easy regression question: *What is the
  line of best fit on a scatter plot?*
- **MHF4U → Logarithmic Functions → Q39** was *Solve log 4ˣ = 7*, which overlapped
  the exponential-equation items at Q35 and Q36. It is now an Advanced
  application on the decibel scale — comparing a 110 dB concert with a 70 dB
  vacuum cleaner, answer 10 000 times.

---

## MPM2D subtopic tagging

All six Grade 10 units failed gate checks 11a and 11b, which predate that file.
Subtopics were badly skewed — `sub-special-products` carried 15 of Factoring's 40
questions with 7 in the Advanced band, while `sub-multiplying-binomials` had 4 and
none above Easy; Linear systems had 16 questions on applications and 5 on
substitution.

27 questions were retagged by reading what each one actually asks. All six units
now pass both checks. **Retagging is safe on live data** — `attempts` snapshots
the misconception tag at the moment of the attempt, so historical dashboards keep
the tag they recorded and only future attempts use the corrected one. This is the
one thing that could be improved on a live course, and it is worth having done:
the tags are what drive the tutor dashboard and the adaptive engine.

---

## A regression I caught at the end, and what caused it

When the repaired bank was checked against the figures, **ten figure-bearing
questions had had their prompts rewritten to describe the picture in words** —
and several of those descriptions stated the answer. The MDM4U Venn question
came to read *"only the crescent of A outside the lens where the two circles
cross is shaded"*, which is the answer. The MCV4U vector question named which
arrow ran from which vertex to which, which is the answer. The curve-sketching
question said which marked point was highest, which is the answer.

**The cause was mine.** When I exported the questions for review I omitted the
`figure` column, so every reviewer read a prompt saying *"as shown"* against a
record with no image and concluded, reasonably, that the diagram did not exist
and the question was unanswerable. They filed it as MINOR. The repair agents
then did the obvious thing and wrote the picture into the prompt.

That is exactly backwards for this bank: on these questions **the picture is
the question**. All ten prompts were reverted to the originals, which were
authored with the figure in hand and pass the ruler test.

The feedback edits on figure-bearing questions were checked separately and are
fine — none describes the drawing, and several removed real leaks.

Four figure questions did have a distractor's value changed, and only one of
those carries a ruler test: MPM2D Solving quadratic equations Q31, where
`16/28` became `8/7`. Measuring that drawing gives 2.0, whose nearest option is
still the wrong one, so the test holds. Its register in `make_figures.py` was
stale — it recorded `16`, read off the leading digits of `16/28` — and has been
corrected.

**The lesson for next time:** never review a question bank from an export that
drops a column the question depends on. A reviewer who cannot see the figure
will always conclude the figure is missing.

---

## Two mechanical sweeps at the end

The audit's own weak point is that it was one reading pass per question, and the
re-audit proved a single pass misses things — it found three hard defects the
first had not. So the last step was to check mechanically what a reader misses,
across all 1600 rather than only the ones that had been edited.

**Distractor uniqueness.** Every option in the bank was parsed into a symbolic
expression and compared with the other three. That is now a permanent tool,
`tools/check_distinct_options.py`, and it is the single highest-value check
missing from the gate: it catches thirteen of the seventeen CRITICALs the audit
found, and it needs no human judgement to run.

It surfaced two defects that had survived everything else:

- **MPM2D Factoring Q6** — `Factor: 8x² - 6x`, where `x(8x - 6)`, `2x(4x - 3)`
  and `2(4x² - 3x)` are all valid factorings and only the middle one is complete.
  The feedback made the intent clear but the prompt never demanded it. Now reads
  `Factor completely:`, matching the rest of its unit.
- **MTH1W Powers Q30** — two distractors, `y^-36 / x^-28` and `x^28 / y^36`,
  were the same value. One was replaced with `1 / (x^28 y^9)`, the answer a
  student reaches by applying the outer power to the numerator alone.

Ten questions still flag, and all ten are correct by design: nine are
"factor completely" items where the distractors are deliberately valid but
incomplete factorings, and one asks which number is *written* correctly in
scientific notation, where every option is the same quantity. The tool's own
documentation records this so the next person does not re-litigate it.

**The app test suite.** `tests/test_ama.sql` was run against the repaired
Grade 10 file on a scratch database: **all 212 checks pass**, including the
twelve in Block B that assert the answer never reaches the browser.

---

## Second phase: the two things that had been left open

Both of the limitations this report originally recorded as "still open" were
then closed.

### Answer position — all 40 units now pass check 12

MPM2D was the last course failing it, with the answer at option D in 17 of
Quadratics' 40 questions. The fix is a cyclic rotation of each option list so
the answer lands at A, B, C and D ten times per unit, scattered by a hash of the
question rather than by sort order so the position never tracks the question
number. 178 of the 240 Grade 10 questions were rotated.

Rotation was verified to be exactly that and nothing more: for every question
the four option objects are the same four, the key still points at the same
option *content*, the shift is genuinely cyclic, and the keyed feedback is still
`Correct.`

The cost — that `attempts.chosen_index` now points at a different option than it
did when a student tapped it — was raised and accepted. Scores, `was_correct`
and the tutor dashboard's diagnosis are all unaffected, because those were
computed at answer time and `misconception_tag` is snapshotted per attempt.

### The length tell — now at chance

**The original figure in this report was wrong and is corrected here.** It said
799 of 1600, "roughly 50% by picking the longest option". That counted ties as
wins. A tie is not exploitable: a student facing two equally long options still
has to guess between them.

Measured properly — the expected score of a student who always picks the longest
option and breaks ties at random — the bank was at **453.5 of 1600, or 28.3%**,
against a chance baseline of 25%. A real edge, but a fifth the size of the one
originally reported, and concentrated in about fifteen units.

It now stands at **398.3 of 1600, or 24.9%**. Twenty-five files were reworked,
the rule throughout being to bring a terse distractor up to the answer's level
of detail rather than to cut the answer short. No value was changed, no option
moved, no prompt touched.

The shortest-option direction was measured at the same time so that fixing one
could not open the other. Two units end below the floor and cannot be fixed:

- **MCV4U Derivatives of Trig and Exponential Functions**, shortest-guesser 5.1
- **MTH1W Powers**, shortest-guesser 5.4

In both, the distractors are either bare values or the correct derivative with a
factor dropped — necessarily shorter, and only paddable by inventing symbols.
Two independent agents reached that conclusion separately, each after listing
the specific questions that block it. That is a property of the mathematics, not
a defect, and it is recorded rather than papered over.

`tools/check_option_lengths.py` now measures both directions and fails a unit
outside 5 to 15 out of 40.

---

## Still open

~~**The longest option is still the answer too often.**~~ **Closed** — see the
second phase above. The bank is at 24.9% against a chance 25%, and
`tools/check_option_lengths.py` guards it.

**Notation is still inconsistent.** MPM2D, MCR3U and MHF4U units 1–6 use Unicode
(`x²`, `√`, `θ`, `π`); MTH1W, MCV4U and MHF4U unit 7 use ASCII (`x^2`, `sqrt(`,
`pi`). MHF4U is the one course inconsistent with itself, at exactly the seam where
the authoring session was interrupted. Nothing was violated — `AUTHORING_GUIDE.md`
has no notation rule. It should get one, and then MHF4U unit 7 should be brought
into line.

**Two MINOR findings were not fixable in the question files.** MDM4U Displays Q10
and MCV4U Lines and Planes Q1 were flagged for referring to a diagram not present
in the record; the figure is attached by the separate `figures_*.sql` run, so
there is nothing to change in the question file.

---

## Two gate checks worth adding

Both would have caught things this audit found by reading:

1. ~~**Distractor uniqueness.**~~ **Written** — `tools/check_distinct_options.py`,
   described above. Run it alongside the gate.
2. ~~**Longest-option tell.**~~ **Written** — `tools/check_option_lengths.py`.

---

## Per-unit changes

`Q` = questions touched · `PR` = prompts rewritten · `TXT` = option texts
rewritten · `FB` = feedback lines rewritten · `TAG` = misconception retags.

| Course | Unit | Q | PR | TXT | FB | TAG |
|---|---|---|---|---|---|---|
| MCR3U | Discrete Functions | 14 | — | 6 | 14 | — |
| MCR3U | Exponential Functions | 3 | — | — | 3 | — |
| MCR3U | Functions | 2 | — | — | 2 | — |
| MCR3U | Rational Expressions | 3 | — | 1 | 2 | — |
| MCR3U | Transformations | 3 | — | — | 2 | 1 |
| MCR3U | Trig Functions | 6 | — | 1 | 7 | — |
| MCR3U | Trig Geometry | 8 | — | 1 | 6 | 2 |
| MCV4U | Algebraic Vectors | 10 | — | 4 | 10 | — |
| MCV4U | Curve Sketching | 2 | — | 2 | 2 | — |
| MCV4U | Derivative Rules | 5 | — | 3 | 3 | — |
| MCV4U | Derivatives of Trig and Exponential Functions | 5 | — | 5 | 6 | — |
| MCV4U | Geometric Vectors | 2 | 1 | 1 | 2 | — |
| MCV4U | Lines and Planes | 8 | — | — | 9 | 1 |
| MDM4U | Collecting Data | 26 | 2 | 30 | 11 | — |
| MDM4U | Displays of Data | 15 | 2 | 9 | 18 | — |
| MDM4U | Normal Distributions | 6 | — | 4 | 4 | — |
| MDM4U | Probability | 4 | 2 | 1 | 4 | — |
| MDM4U | Probability Distributions | 3 | — | — | 3 | — |
| MHF4U | Factoring Polynomials | 3 | — | — | 3 | — |
| MHF4U | Logarithmic Functions | 14 | 1 | 12 | 11 | 1 |
| MHF4U | Polynomial Functions | 9 | — | 1 | 9 | — |
| MHF4U | Rates of Change | 6 | 1 | 2 | 5 | — |
| MHF4U | Rational Functions | 4 | — | 2 | 4 | — |
| MHF4U | Trig Identities and Equations | 5 | — | 4 | 7 | — |
| MHF4U | Trig in Radians | 12 | — | 8 | 10 | — |
| MPM2D | Analytic geometry | 12 | 1 | 1 | 11 | 4 |
| MPM2D | Factoring | 18 | 3 | 7 | 12 | 7 |
| MPM2D | Linear systems | 11 | 1 | 3 | 6 | 6 |
| MPM2D | Quadratics | 7 | 1 | — | 2 | 4 |
| MPM2D | Solving quadratic equations | 9 | — | 1 | 7 | 3 |
| MPM2D | Trigonometry | 9 | 1 | 3 | 7 | 3 |
| MTH1W | Algebraic expressions | 8 | — | 7 | 3 | — |
| MTH1W | Data | 5 | 1 | 2 | 3 | — |
| MTH1W | Financial literacy | 4 | — | 1 | 4 | — |
| MTH1W | Geometry | 3 | — | 2 | 2 | — |
| MTH1W | Linear relations part 1 | 3 | — | 2 | 5 | — |
| MTH1W | Linear relations part 2 | 6 | 1 | — | 5 | — |
| MTH1W | Number sense | 12 | — | 6 | 12 | 2 |
| MTH1W | Powers | 6 | — | 2 | 6 | — |
| MTH1W | Solving equations | 13 | — | 3 | 16 | — |

---

## How to load this

Nothing about the load procedure changed. Every file still opens with its own
`delete from questions where course_code=… and unit=…`, so a corrected file
replaces that unit cleanly, and student attempts key on course, unit and
`sort_order` rather than on question ids.

The one thing to remember: **re-run each course's `figures_*.sql` afterwards.**
The per-unit delete takes the figure reference with the row, so a unit reloaded
without its figure file is imageless until that file runs again.

```bash
cd ~/Downloads/math_tutor
psql "$DB" -f supabase/migrations/questions/grade10_mpm2d/questions_grade10.sql
psql "$DB" -f supabase/migrations/questions/grade10_mpm2d/figures_grade10.sql
```

Grade 10 is the live course and the only one where reloading changes what a
student sees today. The other five are not yet loaded, so their corrections cost
nothing to apply.