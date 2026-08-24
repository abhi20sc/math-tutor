# Astro Math Assist — question bank audit

**Scope:** all 1600 questions, 40 units, 6 courses. Two axes, as asked: **syntax**
(does it load, does it pass the gate, is it structurally sound) and **semantics**
(is the keyed answer actually right, is every distractor genuinely wrong and distinct,
does each feedback line describe the mistake that really produces that option, and
does any feedback give the answer away).

Every question was recomputed independently — sympy, scipy, or brute-force enumeration —
rather than checked against the source it was authored from. All 17 CRITICAL findings
below were then re-verified by hand a second time; none was a false positive. A random
sample of 5 MAJOR findings was also re-verified by hand; all 5 held.

---

## Headline

| | |
|---|---|
| Questions checked | 1600 |
| Units checked | 40 |
| Load cleanly into Postgres | 1600 / 1600 |
| Pass the 13-check gate | **34 / 40 units** (all six failures are MPM2D) |
| **CRITICAL** — key wrong, or two options are the same answer | **17** |
| **MAJOR** — feedback misdescribes the mistake, or leaks the answer | **247** |
| MINOR — ambiguous prompt or mis-tagged misconception | 50 |

The keys are in good shape: **1597 of 1600 questions have a correct, uniquely correct
key**. The damage is concentrated in the feedback layer — which is the layer the whole
bank is built around.

---

## The three that a student cannot answer correctly

These are the ones to fix first, because a student who does the mathematics perfectly
is still marked wrong.

### 1. MPM2D → Factoring → Q21 — **live right now**

```
Simplify: 2(6m² - mn + 4) - (7m² + 4mn - 2)
```

True value: `5m² - 6mn + 10`. The key says `5m² - 5mn + 10`. **None of the four options
is correct.** The author treated `2 × (-mn)` as `-mn`. Every student who has attempted
this question has been marked wrong.

**Fix:** change the keyed option's text from `5m² - 5mn + 10` to `5m² - 6mn + 10`. Text
only, no reordering — safe on live data.

### 2. MDM4U → Displays of Data → Q18

`r = 0.9825` → `r² = 0.96530625` → **0.9653**. The key says `0.9654`. The options were
generated from an unrounded `r` that the prompt then rounded.

### 3. MDM4U → Displays of Data → Q28

`y = -0.864 + 1.150(65) = 73.886` → **73.89**. The key says `73.91`. Same cause — and it
has spread: distractor `74.77` should be `74.75`, distractor `75.64` should be `75.61`.
Only `64.14` is right. The whole item needs regenerating from the rounded coefficients
printed in the prompt.

---

## The one where the wrong answer is also right

**MHF4U → Trig Identities and Equations → Q1.** The question asks which expression equals
`cos θ`. The key is `sin(π/2 - θ)`. But option B is `sin(π/2 + θ)`, and that is *also*
identically `cos θ` — it is a true cofunction identity, not an approximation. Its feedback
says it "comes to cos θ for some angles, but not in general," which is a false
mathematical claim printed in front of a student.

**Fix:** replace option B with `cos(π/2 - θ)` (which equals `sin θ`) and rewrite its
feedback around confusing sine with cosine.

---

## Two options that are the same answer (13 items)

In each of these the four options are really three: two of them are the identical value
or expression wearing different clothes. Nobody is marked wrong for being right, but a
distractor slot is wasted and the one-mistake-per-option design breaks.

| Unit | Q | The duplicate pair | Why they are the same |
|---|---|---|---|
| MPM2D / Factoring **(live)** | 5 | `x(5 + 20)` and `5x(1 + 4)` | both are `25x` |
| MPM2D / Factoring **(live)** | 10 | `(x - 7)(x - 7)` and `(x - 7)²` | the same expression |
| MPM2D / Factoring **(live)** | 13 | `7x²y²(3x - 4y²)` and `7x²y²(3x - 4y² + 0)` | the `+ 0` is vacuous |
| MPM2D / Factoring **(live)** | 24 | `(4x - 6y)(x + y)` and `(2x - 3y)(2x + 2y)` | both expand to `4x² - 2xy - 6y²` |
| MPM2D / Linear systems **(live)** | 31 | `2` and `12/6` | `12/6 = 2` |
| MTH1W / Number sense | 13 | `5/6` and `10/12` | the same fraction unreduced |
| MTH1W / Powers | 16 | `3^16` and `9^8` | both are 43 046 721 |
| MHF4U / Polynomial Functions | 20 | `Even` and `Even, because the highest power is even` | the same verdict twice |
| MHF4U / Trig Identities | 24 | `-(√6 - √2)/4` and `(√2 - √6)/4` | the same number |
| MCV4U / Curve Sketching | 10 | `(200 - 2x)/2` and `100 - x` | identical after dividing |
| MCV4U / Deriv. Trig & Exp | 28 | `3^x e^(sin x)(ln 3 × cos x)` and `3^x ln 3 × e^(sin x) cos x` | identical after regrouping |
| MCV4U / Deriv. Trig & Exp | 29 | `-3x²/(3y² - 2y)` and `3x²/(2y - 3y²)` | identical after negating |
| MCV4U / Geometric Vectors | 38 | `3.0 minutes, but the current makes it longer` and `3.0 minutes, and the current does not change it` | the prompt asks only *how long*, and both say 3.0 |

Q38 is the sharpest of these: the prompt asks *"How long does the crossing take?"* and
two options answer 3.0 minutes. A student who computes correctly then has to guess on a
justification clause the question never asked for. Either the prompt gains a second half
("…and does the current affect it?") or one option loses its clause.

---

## The systemic problem: 247 feedback lines

This is the finding that matters most, because the bank's whole premise is that a wrong
answer teaches something. Across all 40 units, an average of **6 feedback lines per unit**
either name a mistake that does not produce that option, or hand the answer over.

Four worked examples, each verified by hand:

**MTH1W / Linear relations part 2 / Q11** — system `2x + y = 5`, `x - 2y = 10`, key `(4, -3)`.
The distractor `(2, 1)` is fed back as *"Those values satisfy neither equation."* But
`2(2) + 1 = 5` — it satisfies the first one exactly. A student who checks, as instructed,
finds the feedback is lying to them.

**MHF4U / Trig in Radians / Q11** — convert `4π/9`, key `80°`. The distractor `160°` is fed
back as *"Cancelling 180 by 9 gives 20, and 4 times 20 is 80."* That sentence contains the
answer. The distractor `40°` is fed back as *"the 4 in the numerator was dropped"* — but
dropping the 4 gives 20, not 40. One question, two defects, opposite kinds.

**MPM2D / Analytic geometry / Q36 (live)** — key `1/2`. The distractor `1` is fed back as
*"MN rises 2 over a run of 4. Simplify 2/4."* Simplifying 2/4 *is* the answer, and failing
to simplify gives 2/4, not 1. It leaks and misdescribes at the same time.

**MCV4U / Algebraic Vectors / Q15** — work done, key `7600 J`. The distractor `1500 J` is fed
back as summing the components and multiplying the totals — but that gives 24 000. 1500 is
just the force-component sum.

Per-unit counts are in the table further down. The heaviest are **MCR3U Discrete Functions
(17)**, **MTH1W Solving equations (16)**, **MHF4U Logarithmic Functions (15)** and **MHF4U
Trig in Radians (15)**.

---

## Syntax

All 1600 rows load. 34 of 40 units pass all thirteen gate checks. **All six failures are
MPM2D**, and they are not new mistakes — that file was written before checks 11 and 12
existed, so it has never been held to them:

| Unit | Failing checks |
|---|---|
| Analytic geometry | 11a, 11b (subtopic coverage) |
| Factoring | 10 (answer leak, Q22), 11a, 11b |
| Linear systems | 11a, 11b |
| Quadratics | 11a, 11b — **and 12**: the answer sits at option D in 17 of 40 (42.5%) |
| Solving quadratic equations | 11a, 11b |
| Trigonometry | 11a, 11b |

### Notation is not consistent across the bank

Three different conventions are in use, and there is no rule in `AUTHORING_GUIDE.md`
saying which is right — so nothing was violated, but a student moving between courses
sees the same mathematics written two ways:

- **Unicode** (`x²`, `√`, `θ`, `°`, `π`) — MPM2D, MCR3U, and MHF4U units 1–6
- **ASCII** (`x^2`, `sqrt(`, `pi`, `degrees`) — MTH1W, MCV4U, and **MHF4U unit 7**

MHF4U is the one course that is internally inconsistent: units 1–6 are Unicode and unit 7
is ASCII. That seam is exactly where the authoring session was interrupted and resumed.

### The longest option is the answer far too often

This is bank-wide, not confined to one course, and I had it wrong earlier when I called it
an MDM4U problem. Chance says the correct option should be the longest of the four about
**10 times in 40**. The actual figure:

| Course | Median | Worst unit |
|---|---|---|
| MTH1W | 20/40 | Financial literacy 24/40 |
| MPM2D | 21/40 | Trigonometry 24/40 |
| MCR3U | 20/40 | Exponential Functions 24/40 |
| MHF4U | 20/40 | Factoring Polynomials 23/40 |
| MCV4U | 21/40 | Derivative Rules 24/40 |
| MDM4U | 24/40 | **Collecting Data 27/40** |

Only one unit in the whole bank sits at chance: **MCV4U Algebraic Vectors, 9/40**. Everywhere
else a student who knows no mathematics at all can score roughly 50% by picking the longest
option. That is worth a gate check of its own.

### Answer position

Every course except MPM2D is perfectly balanced — exactly 10 answers at each of A, B, C, D
in all 34 units. That is `balance_answer_positions.py` doing its job. MPM2D ranges from 12
to 17 at a single position.

**But MPM2D cannot be rebalanced.** `attempts.chosen_index` stores the integer index, and
there is an index on `(course, unit, sort_order, chosen_index)`. Rotating the options on a
live unit silently re-points every historical wrong answer at a different misconception, so
every tutor dashboard reading back over past attempts starts lying. Editing feedback text
and retagging misconceptions are both safe; **reordering options is not**.

---

## Every unit, at a glance

`Tell` = how often the correct option is the longest of the four (chance is 10).

| Course | Unit | Gate | CRIT | MAJOR | MINOR | Tell |
|---|---|---|---|---|---|---|
| MTH1W | Number sense | pass | **1** | 8 | 6 | 21/40 |
| MTH1W | Powers | pass | **1** | 4 | 0 | 18/40 |
| MTH1W | Algebraic expressions | pass | — | 8 | 0 | 22/40 |
| MTH1W | Solving equations | pass | — | 16 | 0 | 17/40 |
| MTH1W | Linear relations part 1 | pass | — | 5 | 2 | 20/40 |
| MTH1W | Linear relations part 2 | pass | — | 5 | 1 | 21/40 |
| MTH1W | Geometry | pass | — | 3 | 0 | 18/40 |
| MTH1W | Data | pass | — | 4 | 1 | 16/40 |
| MTH1W | Financial literacy | pass | — | 5 | 0 | 24/40 |
| MPM2D | Linear systems | FAIL | **1** | 6 | 1 | 23/40 |
| MPM2D | Analytic geometry | FAIL | — | 10 | 1 | 19/40 |
| MPM2D | Factoring | FAIL | **5** | 4 | 1 | 19/40 |
| MPM2D | Quadratics | FAIL | — | 2 | 1 | 22/40 |
| MPM2D | Solving quadratic equations | FAIL | — | 6 | 2 | 19/40 |
| MPM2D | Trigonometry | FAIL | — | 3 | 3 | 24/40 |
| MCR3U | Functions | pass | — | 2 | 0 | 16/40 |
| MCR3U | Rational Expressions | pass | — | 3 | 0 | 17/40 |
| MCR3U | Transformations | pass | — | 2 | 1 | 20/40 |
| MCR3U | Exponential Functions | pass | — | 2 | 1 | 24/40 |
| MCR3U | Trig Geometry | pass | — | 5 | 3 | 21/40 |
| MCR3U | Trig Functions | pass | — | 7 | 0 | 20/40 |
| MCR3U | Discrete Functions | pass | — | 17 | 0 | 21/40 |
| MHF4U | Polynomial Functions | pass | **1** | 8 | 0 | 23/40 |
| MHF4U | Factoring Polynomials | pass | — | 3 | 0 | 23/40 |
| MHF4U | Logarithmic Functions | pass | — | 15 | 2 | 20/40 |
| MHF4U | Trig in Radians | pass | — | 15 | 1 | 18/40 |
| MHF4U | Trig Identities and Equations | pass | **2** | 4 | 2 | 22/40 |
| MHF4U | Rates of Change | pass | — | 6 | 2 | 18/40 |
| MHF4U | Rational Functions | pass | — | 5 | 0 | 20/40 |
| MCV4U | Derivative Rules | pass | — | 5 | 1 | 24/40 |
| MCV4U | Curve Sketching | pass | **1** | 2 | 2 | 18/40 |
| MCV4U | Derivatives of Trig and Exponential Functions | pass | **2** | 5 | 0 | 22/40 |
| MCV4U | Geometric Vectors | pass | **1** | 1 | 2 | 21/40 |
| MCV4U | Algebraic Vectors | pass | — | 12 | 1 | 9/40 |
| MCV4U | Lines and Planes | pass | — | 7 | 3 | 22/40 |
| MDM4U | Displays of Data | pass | **2** | 13 | 3 | 24/40 |
| MDM4U | Collecting Data | pass | — | 6 | 2 | 27/40 |
| MDM4U | Normal Distributions | pass | — | 8 | 1 | 23/40 |
| MDM4U | Probability | pass | — | 2 | 3 | 23/40 |
| MDM4U | Probability Distributions | pass | — | 3 | 1 | 26/40 |

---

## Full finding list

Every one of the 314 findings, by unit. Each line: question number, severity, what is wrong,
and the computation that shows it.


## Grade 9 — MTH1W

### MTH1W — Number sense

- **Q13 · CRITICAL** — Two distractors are the same answer written two ways: option "5/6" and option "10/12" have identical value, so one misconception label is attached to a duplicate.
  <br>_Verified:_ 2/3 ÷ 5/4 = 2/3 x 4/5 = 8/15 (key, correct). 10/12 = 5/6 = 0.8333... exactly; both are the "multiplied straight across" result 2/3 x 5/4 = 10/12.
- **Q11 · MAJOR** — Feedback for "42" names only "did the addition before the multiplication", but that mistake does not produce 42.
  <br>_Verified:_ -6 x (-4+3) = -6 x (-1) = 6, not 42. 42 requires a second error (dropping both minus signs): 6 x (4+3) = 42. Key -6 x (-4) + 3 = 24 + 3 = 27 verified.
- **Q12 · MAJOR** — Feedback for "-2" says "subtracted before dividing", which does not yield -2.
  <br>_Verified:_ 20 ÷ (-4 - 3) = 20 ÷ (-7) = -2.857..., not -2. -2 actually comes from -5 + 3 (adding instead of subtracting after a correct division). Key: 20 ÷ (-4) - 3 = -5 - 3 = -8 verified.
- **Q12 · MAJOR** — Feedback for "-2.5" claims the student "divided 20 by the whole expression -4 - 3", but that computation gives a different number.
  <br>_Verified:_ 20 ÷ (-4 - 3) = 20 ÷ (-7) = -2.857..., not -2.5. (-2.5 = 20 ÷ (-8), i.e. dividing by the correct final answer.) Also this is the same described mistake as the "-2" option's feedback.
- **Q13 · MAJOR** — Feedback for "5/6" describes "divided the numerators and the denominators separately", a procedure that actually produces the CORRECT answer, not 5/6.
  <br>_Verified:_ (2 ÷ 5)/(3 ÷ 4) = 0.4/0.75 = 8/15 = the keyed answer. 5/6 is instead 2/3 x 5/4 = 10/12, already claimed by the "10/12" option.
- **Q16 · MAJOR** — Feedback for "1 : 6" says the student subtracted instead of dividing, but no common subtraction produces 1 : 6.
  <br>_Verified:_ (18-k) : (24-k) gives 1:7 at k=17 and 0:6 at k=18; the difference 24-18 = 6 never pairs with 1. 1:6 arises from dividing the two parts by different numbers (18÷18, 24÷4). Key 18:24 = 3:4 (gcd 6) verified.
- **Q19 · MAJOR** — Distractor feedback hands over the correct answer verbatim.
  <br>_Verified:_ Option "Rational only" feedback reads "Zero is a whole number and an integer as well as a rational number", which is exactly the key (Whole, integer and rational); option "Integer and rational only" likewise names the missing set as "the counting numbers plus zero" = whole numbers.
- **Q27 · MAJOR** — Distractor feedback tells the student the key is the reversal of that option.
  <br>_Verified:_ Option "Rational, integer, whole, natural" feedback says "That is the correct chain read backwards", so reversing the listed sets gives Natural, whole, integer, rational — the keyed option — with no reasoning required.
- **Q36 · MAJOR** — Feedback for "85 dollars" describes taking both percentages from the original price, which produces 80, not 85.
  <br>_Verified:_ 80 + 0.25(80) - 0.25(80) = 80 + 20 - 20 = 80 dollars, which is the value of a different option (whose own feedback covers that error). Key: 80 x 1.25 = 100, 100 x 0.75 = 75 verified.
- **Q6 · MINOR** — Distractor "15/20" is numerically equal to the keyed answer "3/4"; only the prompt's "to lowest terms" wording keeps the key unique.
  <br>_Verified:_ 15/20 = 3/4 exactly (divide both by 5).
- **Q15 · MINOR** — Distractor "2 and 5/3" is numerically equal to the keyed answer "3 and 2/3"; only the requirement that a mixed number have a proper fraction part separates them.
  <br>_Verified:_ 2 + 5/3 = 11/3 = 3 + 2/3.
- **Q16 · MINOR** — Distractor "9 : 12" is the same ratio as the keyed "3 : 4"; only the word "simplify" distinguishes them.
  <br>_Verified:_ 9:12 = 3:4 (both reduce to the fraction 3/4).
- **Q34 · MINOR** — Distractor "15/24" equals the keyed answer "5/8", and its feedback ("the division was done correctly, but this fraction can still be reduced further") lets the student read off the key.
  <br>_Verified:_ 5/6 ÷ 4/3 = 5/6 x 3/4 = 15/24 = 5/8 exactly.
- **Q37 · MINOR** — misconception_tag "sub-number-sets" is mismatched: this is power-set counting, not classification of number systems (every other sub-number-sets item, Q8/Q9/Q19/Q27/Q38, is natural/whole/integer/rational classification).
  <br>_Verified:_ 2^5 = 32 verified; content is combinatorial, not a number-set property.
- **Q40 · MINOR** — misconception_tag "sub-density-limits" is mismatched: the item is a triangular-number pattern with no density or limiting behaviour.
  <br>_Verified:_ T(10) = 10 x 11 / 2 = 55 verified; T(9) = 45. Nothing in the item concerns gaps between elements or a limit.

### MTH1W — Powers

- **Q16 · CRITICAL** — Distractors A (3^16) and B (9^8) are the same number written two ways, so two options share one mathematical value.
  <br>_Verified:_ 3^16 = 43046721 and 9^8 = 43046721 (sympy: 3**16 == 9**8 -> True); keyed answer 3^8 = 6561 is still uniquely correct, but the two wrong options are numerically identical.
- **Q25 · MAJOR** — Feedback on option "3^11" names a mistake ("all three exponents were added") that produces 3^9, i.e. the value of a different option, not 3^11.
  <br>_Verified:_ (3^2 x 3^4)^3 = 3^18 = 387420489 (correct). Adding all three exponents gives 2+4+3 = 9 -> 3^9, which is option C's value; 3^11 would require 2x4+3 = 11, a different error.
- **Q31 · MAJOR** — Feedback on the distractor "0^0 equals 0" states that 0^0 "does not have a value at all", which hands the student the keyed answer "Because 0^0 is undefined".
  <br>_Verified:_ Correct option (index 3) is verbatim "Because 0^0 is undefined"; the distractor feedback asserts exactly that fact, so a student reading it is handed the key.
- **Q33 · MAJOR** — Feedback on option "3 x 10^10" claims the front numbers were "divided the wrong way round", but that error gives 0.5, not 3.
  <br>_Verified:_ (6 x 10^8)/(3 x 10^-2) = 2 x 10^10 (correct). Wrong-way division is 3/6 = 0.5 -> 0.5 x 10^10. The value 3 comes from subtracting the coefficients (6 - 3 = 3), a different mistake.
- **Q37 · MAJOR** — Feedback on option "-16uv" says "the 4 on the bottom was not squared", but that error yields -4uv; -16uv requires dropping the coefficient 4 entirely.
  <br>_Verified:_ Top = (-2uv^3)(8u^2v^2) = -16u^3v^5; bottom = (4uv^2)^2 = 16u^2v^4; answer -uv (correct). With bottom = 4u^2v^4 (4 unsquared): -16u^3v^5 / 4u^2v^4 = -4uv. Only bottom = u^2v^4 (coefficient gone) gives -16uv.

### MTH1W — Algebraic expressions

- **Q5 · MAJOR** — The distractor "3x + 1" is labelled as the result of subtracting the second bracket, but that mistake produces -3x + 1, not 3x + 1.
  <br>_Verified:_ sympy: (4x+3)-(7x+2) = -3x+1. The option 3x+1 comes from taking the x terms the wrong way round (7x-4x=3x) while doing 3-2=1, so the named mistake does not yield this option; the same bank uses -3x+1 as the key in Q15 and calls 3x+1 "subtracted the wrong way round".
- **Q17 · MAJOR** — The distractor "-6x^2 - 15x + 12" is labelled "the signs inside the bracket were ignored", but that mistake produces -6x^2 - 15x - 12.
  <br>_Verified:_ sympy: -3(2x^2+5x+4) = -6x^2-15x-12, whereas the option equals 3(2x^2-5x+4) = 6x^2-15x+12 with the minus applied only to the first term. Key -6x^2+15x-12 verified correct.
- **Q22 · MAJOR** — The distractor "13" is labelled "added the exponents across every term", but that sum is 15 for this polynomial, not 13.
  <br>_Verified:_ Term degrees of 3x^2y^4 + 11x^2y^2 + y^5 are 6, 4, 5; 6+4+5 = 15 and the raw exponent sum 2+4+2+2+5 = 15. Key 6 = max(6,4,5) verified correct. 13 is the value that fits Q11's polynomial (6+7), so it appears copied from there.
- **Q27 · MAJOR** — The distractor "-6x^3 - 15x^2 + 12x" is labelled "the signs inside the bracket were ignored", but that mistake produces -6x^3 - 15x^2 - 12x.
  <br>_Verified:_ sympy: -3x(2x^2+5x+4) = -6x^3-15x^2-12x; the option is 3x(2x^2-5x+4) = 6x^3-15x^2+12x with the minus attached only to the leading term. Key -6x^3+15x^2-12x verified correct.
- **Q28 · MAJOR** — The distractor "5m^2 - 14m" is labelled as adding the second bracket instead of subtracting it, but adding it gives 5m^2 - 16m.
  <br>_Verified:_ sympy: 3m(m-5)+(2m^2-m) = 5m^2-16m; 3m(m-5)-(2m^2-m) = m^2-14m (key correct). The option mixes an added 2m^2 with a correctly subtracted -m, which no single named slip produces.
- **Q29 · MAJOR** — The distractor "x^2 - 16" is told "the sign is handled, but the two middle products are missing", yet dropping the middle products gives x^2 + 16 (option 2) and the -16 is itself the sign error.
  <br>_Verified:_ sympy: (x-4)^2 = x^2-8x+16; the last product is (-4)(-4) = +16, so x^2-16 carries a sign error the feedback explicitly certifies as correct, and the mistake it names already produces the other distractor x^2+16.
- **Q32 · MAJOR** — The distractor "195" is labelled as collecting the constants as 30, but no slip on the -2 yields 30; mistaking -2 for +2 gives 19 and a perimeter of 184.
  <br>_Verified:_ Perimeter = (18x+7)+(9x-2)+(3x+5)+(3x+5) = 33x+15, at x=5 gives 180 (key correct). 195 = 33(5)+30, while 7+2+5+5 = 19 gives 165+19 = 184, so the described mistake does not produce this option.
- **Q36 · MAJOR** — The distractor "2x - 2y + 10" is labelled "the -y stayed negative", but that mistake makes the y terms vanish, giving 2x + 10.
  <br>_Verified:_ y terms: -4y+5y-y = 0y, so the failure to flip yields 2x+10; correct is -4y+5y+y = 2y, i.e. 2x+2y+10 (key verified by sympy). The -2y in the option corresponds to no described slip.

### MTH1W — Solving equations

- **Q5 · MAJOR** — Class D: feedback on wrong option [1] ("x = 3") confirms 3 is a solution and announces a second negative one, which hands over correct option [2] "x = 3 or x = -3".
  <br>_Verified:_ solve(x**2-9) = [-3, 3]; feedback text "That is one of them. A negative number multiplied by itself is also positive, so there is a second value" leaves only option [2] as a possible answer.
- **Q6 · MAJOR** — Class D: feedback on wrong option [0] ("x = 5 or x = -5") rules out -5 and says "Only one of these works", which names correct option [1] "x = 5".
  <br>_Verified:_ Real solve(x**3-125) = [5] ((-5)**3 = -125, not 125); the feedback eliminates -5 from the pair it is attached to, leaving 5 stated for the student.
- **Q11 · MAJOR** — Class C: feedback on wrong option [1] ("x = -1/3") blames moving -5x across without changing sign, but that mistake does not give -1/3.
  <br>_Verified:_ 7-2x = 8-5x -> 3x = 1 -> x = 1/3 (key). Keeping -5x negative: 7-2x-5x = 8 -> -7x = 1 -> x = -1/7; moving -2x right unchanged gives 1/7. -1/3 actually comes from collecting the constants backwards: 3x = 7-8 = -1.
- **Q11 · MAJOR** — Class D: feedback on wrong option [2] ("x = 3") states the correct answer in words - "3x = 1 means x is one third".
  <br>_Verified:_ Key option [0] is "x = 1/3"; the feedback string spells out "x is one third".
- **Q14 · MAJOR** — Class C: feedback on wrong option [2] ("x = -76") says the student stopped at -64 = 2x and then subtracted rather than divided, which does not produce -76.
  <br>_Verified:_ -14 = 2(x-3)/5 -> -70 = 2x-6 -> 2x = -64 -> x = -32 (key). From -64 = 2x, subtracting 2 gives -66 and dividing gives -32. -76 is the value of 2x on the sign-error path (2x = -70-6 = -76), i.e. the option is "stopped at 2x = -76", not anything involving -64.
- **Q15 · MAJOR** — Class D: feedback on wrong option [0] ("x = -10") ends with "No real number squares to a negative", which is the correct option stated outright.
  <br>_Verified:_ x**2 + 100 = 0 -> solveset over the reals = EmptySet; correct option [1] text is "No real solution", and the feedback asserts exactly that fact.
- **Q22 · MAJOR** — Class C: feedback on wrong option [0] ("x = 39") blames the -65 keeping its sign when it moved, but that mistake gives -39, not +39.
  <br>_Verified:_ 5(5x-13) = 23x-13 -> 25x-65 = 23x-13 -> 2x = -13+65 = 52 -> x = 26 (key). -65 keeping its sign: 2x = -13-65 = -78 -> x = -39. The option 39 comes from the OTHER constant keeping its sign: 2x = 13+65 = 78 -> x = 39.
- **Q23 · MAJOR** — Class C: feedback on wrong option [3] ("x = -11") blames a bracket that was not fully multiplied out, but no partial expansion gives -11.
  <br>_Verified:_ Cross multiply: 5(2x-1) = 3(3x-2) -> 10x-5 = 9x-6 -> x = -1 (key). All partial-expansion variants checked: (10x-1 = 9x-6) -> -5, (10x-5 = 9x-2) -> 3, (10x-1 = 9x-2) -> -1, (2x-5 = 9x-6) -> 1/7, (10x-5 = 3x-6) -> -1/7, (2x-5 = 3x-6) -> 1, (10x-1 = 3x-6) -> -5/7, (2x-5 = 9x-2) -> -3/7. -11 only arises from collecting constants backwards: x = -6-5 = -11 - which is the mistake option [1] is already assigned.
- **Q23 · MAJOR** — Class D: feedback on wrong option [1] ("x = 1") gives the arithmetic "-6 + 5", which evaluates to -1, the correct answer.
  <br>_Verified:_ 10x-5 = 9x-6 -> x = -6+5 = -1 = correct option [0] "x = -1"; the feedback hands the student the exact sum that is the answer.
- **Q29 · MAJOR** — Class C: feedback on wrong option [0] ("x > 1") says the two fractions were added as if both were halves, which gives x > 5, not x > 1.
  <br>_Verified:_ x/2 + x/3 > 5 -> 5x/6 > 5 -> x > 6 (key). Treating both as halves: x/2 + x/2 = x > 5 -> x > 5. Adding numerators and denominators (2x/5 > 5) gives x > 12.5. x > 1 comes from multiplying only the left side by 6: 5x > 5.
- **Q31 · MAJOR** — Class D: feedback on wrong options [0] and [1] state the criterion and the conclusion for the correct answer - "the x terms match but the constants do not" and "no single value can be the answer".
  <br>_Verified:_ 3(2x+5)-2(x-4) = 4x+23 and 4(x+6)-5 = 4x+19; sympy solve returns [] (no solution) = correct option [2]. Telling the student the x terms match while the constants differ is the whole derivation of "No solution".
- **Q32 · MAJOR** — Class C: feedback on wrong option [2] ("x = -6") says the brackets were expanded before the denominators were cleared and a term was lost, but that route gives -12, never -6.
  <br>_Verified:_ (1/4)(x-3) = (1/3)(x-2) -> 3(x-3) = 4(x-2) -> 3x-9 = 4x-8 -> x = -1 (key). Expanding first and losing the denominator on the constants: x/4-3 = x/3-2 -> x = -12; dropping -2 gives -36; dropping -3 gives 24; keeping only one fraction constant gives 15 or -28. -6 requires 3x-9 = 4x-3 or 3x-12 = 4x-6, neither of which the feedback describes (-6 is simply the sign flip of option [1]'s 6).
- **Q32 · MAJOR** — Class D: feedback on wrong option [3] ("x = 1") gives the arithmetic "-9 + 8", which evaluates to -1, the correct answer.
  <br>_Verified:_ 3x-9 = 4x-8 -> x = -9+8 = -1 = correct option [0] "x = -1".
- **Q33 · MAJOR** — Class C: feedback on wrong option [1] ("x = 15") blames collecting the constants the wrong way round after expanding, which cannot give 15.
  <br>_Verified:_ (x-5)/3 = (x+10)/6 -> 6x-30 = 3x+30 -> 3x = 60 -> x = 20 (key). Constants the wrong way: 3x = -30-30 -> x = -20, or 3x = 30-30 -> x = 0. 15 comes from a dropped bracket: multiplying by 6 as 2x-5 = x+10 -> x = 15, which is the same mistake family option [2] is assigned.
- **Q37 · MAJOR** — Class C: feedback on wrong option [2] ("Fewer than 21 days") blames subtracting the daily rates from the wrong flat fees, but no such pairing produces 21.
  <br>_Verified:_ 90+5d < 100+4d -> d < 10 (key). All four fee/rate pairings give d < 10, d > 10, d > -10, d < -10, or a trivially true/false statement - never 21. 190/9 = 21.1 (adding both sides instead of subtracting) is the only route to a 21, and it points the inequality the other way (d > 21.1).
- **Q39 · MAJOR** — Class C: feedback on wrong option [0] ("290 dollars") says the 200 dollars was divided among all three, but no handling of the 200 makes Sidney 290.
  <br>_Verified:_ E + 2E + (2E+200) = 1450 -> 5E = 1250 -> E = 250, Sidney = 500 (key), Jensen = 700. Leaving the 200 in the pot: 1450/5 = 290, but that is one Evgeni-share, so Sidney = 580 on that path (with S as the variable: 2.5S = 1450 -> S = 580). 290 is never a value of Sidney under the described error.

### MTH1W — Linear relations part 1

- **Q14 · MAJOR** — Option 2 ("8") feedback describes a mistake that cannot produce 8: it says the two x-values were added, giving a run of -6.
  <br>_Verified:_ P1(-4,6), P2(-2,10): dy=4, dx=2, slope=2 (key, correct). Adding x-values: -4 + -2 = -6, so 4/(-6) = -2/3, not 8. The option 8 actually comes from adding the y-values: (6+10)/2 = 8. Feedback blames the wrong pair of numbers.
- **Q17 · MAJOR** — Option 2 ("-4x + y = -11") feedback claims "Every term is placed correctly, but standard form requires the x coefficient to be positive" - false, that equation is a different line, not a sign-convention variant of the key.
  <br>_Verified:_ y = -4x - 11 => key 4x + y = -11. Its all-negated form is -4x - y = 11. Option 2 solves to y = 4x - 11 (wrong line). The mistake that actually produces it is moving -4x across without changing its sign, not a positive-coefficient convention slip.
- **Q17 · MAJOR** — Option 3 ("4x - y = 11") feedback says "The y term changed sign but the constant did not follow" - the constant DID change sign in that option.
  <br>_Verified:_ Key 4x + y = -11; option 3 has both the y term and the constant flipped (+11 vs -11); only the x term failed to flip. The described error (y flipped, constant unchanged) would give 4x - y = -11, which is not an option.
- **Q26 · MAJOR** — Option 1 ("5x + 3y = 24") feedback blames the x term, but that option's x term matches the key; the described error does not produce it.
  <br>_Verified:_ y = (5/3)x - 8 => 3y = 5x - 24 => key 5x - 3y = 24 (verified: (5x-3y) with y=(5/3)x-8 gives 24). Option 1 differs from the key only in the sign of the y term. Moving 5x across without changing sign gives 5x + 3y = -24, not +24.
- **Q26 · MAJOR** — Option 3 ("-5x + 3y = 24") feedback claims "Every term is placed correctly, but standard form requires the x coefficient to be positive" - false, that equation is a different line.
  <br>_Verified:_ Option 3 solves to y = (5/3)x + 8, not y = (5/3)x - 8. The genuine negative-x-coefficient version of the key is -5x + 3y = -24. Feedback's stated mistake would produce -24 on the right.
- **Q17 · MINOR** — Options 2 and 3 are the same line written two ways, so the distractor set is redundant (key is unaffected).
  <br>_Verified:_ -4x + y = -11 => y = 4x - 11; 4x - y = 11 => y = 4x - 11 (option 3 = option 2 multiplied by -1).
- **Q26 · MINOR** — Options 2 and 3 are the same line written two ways, so the distractor set is redundant (key is unaffected).
  <br>_Verified:_ 5x - 3y = -24 => y = (5/3)x + 8; -5x + 3y = 24 => y = (5/3)x + 8 (option 3 = option 2 multiplied by -1).

### MTH1W — Linear relations part 2

- **Q11 · MAJOR** — Option 3 ("(2, 1)") feedback states "Those values satisfy neither equation" - false, (2, 1) does satisfy the first equation.
  <br>_Verified:_ System 2x + y = 5, x - 2y = 10 => key (4, -3) (verified). Test (2,1): 2(2) + 1 = 5 = RHS of equation 1 (satisfied); 2 - 2(1) = 0 != 10 (fails only the second). Feedback's factual claim is wrong.
- **Q22 · MAJOR** — Option 2 ("(-3, 4)") feedback blames a lost sign when rearranging x + y = 1, but that error does not produce (-3, 4).
  <br>_Verified:_ Key: 2x - 3y = 12, x + y = 1 => (3, -2). The described slip (x = y - 1 instead of x = 1 - y) gives 2(y-1) - 3y = 12 => y = -14, x = -15. Meanwhile (-3, 4) satisfies x + y = 1 exactly (-3 + 4 = 1), i.e. it is consistent with the CORRECT rearrangement; the error is elsewhere (2(-3) - 3(4) = -18, not 12).
- **Q25 · MAJOR** — Option 0 ("y = -2x") feedback calls -2 "the negative reciprocal" that "rotates the line"; the negative reciprocal of -1/2 is +2, which is option 2, not this option.
  <br>_Verified:_ Start y = -(1/2)x. Reflection in x-axis => y = (1/2)x (key). Reciprocal of -1/2 = -2 (this option); negative reciprocal = -1/(-1/2) = +2 (option 2, y = 2x). The described mistake produces a different listed option; the actual mistake here is flipping the fraction while keeping the sign (exactly what Q26's option 1 feedback says for the same value).
- **Q31 · MAJOR** — Option 0 ("(1, -6)") feedback blames a lost sign when rearranging 3x - y = 9, but that error does not produce (1, -6).
  <br>_Verified:_ Key: 5x + 2y = 4, 3x - y = 9 => (2, -3). Sign-slip y = 9 - 3x gives 5x + 2(9-3x) = 4 => x = 14; y = 3x + 9 gives x = -14/11. Neither is 1. And (1, -6) fits y = 3x - 9 exactly (3-9 = -6), i.e. the rearrangement used was the correct one; it fails only equation 1 (5(1) + 2(-6) = -7, not 4).
- **Q32 · MAJOR** — Option 0 ("50 minutes") feedback says the fees were subtracted and divided by the wrong rate; no rate in the problem gives 50 - 50 is the SUM of the two monthly fees.
  <br>_Verified:_ 30 + 0.10m = 20 + 0.15m => 10 = 0.05m => m = 200 (key). Subtract-then-divide options: 10/0.10 = 100 (that is option 2), 10/0.15 = 66.7, 10/0.25 = 40. None is 50. 50 = 30 + 20, i.e. the fees were added, not subtracted-and-divided.
- **Q40 · MINOR** — "Shade the region that does not contain (2, 2)" is imprecise for xy > 5: the boundary xy = 5 splits the plane into three regions, and the solution set is two disconnected regions, not "the region" that excludes the test point.
  <br>_Verified:_ xy = 5 has two branches; complement of the origin-side region = {x>0, y>5/x} plus {x<0, y<5/x}. Test point (2,2): 2*2 = 4 < 5, so it lies in the middle (non-solution) region. Key is still the intended/best answer; only the singular "region" wording is loose.

### MTH1W — Geometry

- **Q22 · MAJOR** — Distractor "12 sides" feedback says "That divides 180 by the angle", but 180/24 = 7.5, which is the mistake already assigned to the "8 sides" option ("dividing 180 by 24 and rounding"). No stated mistake produces 12.
  <br>_Verified:_ 360/24 = 15 (key, correct); 180/24 = 7.5 -> rounds to 8 (option 1); nothing in the prompt yields 12 (would need 288/24).
- **Q23 · MAJOR** — Distractor "60 degrees" feedback claims it "would make the three interior angles add to more than 180", which is false; 60 comes from taking the supplement of the exterior angle (180-120) and the resulting angle set sums to less than 180.
  <br>_Verified:_ Key: 120 - 45 = 75 (correct). If the second remote interior angle were 60, the interior angles are 45, 60, and 180-120 = 60, summing to 165 < 180, not "more than 180".
- **Q34 · MAJOR** — Distractor "x = 55" feedback says "The 40 was moved across without changing sign", but applying that sign error to the correct equation 3x = x + 40 gives x = -20 (or x = 10, which is a different option), never 55.
  <br>_Verified:_ 3x = x + 40 -> 2x = 40 -> x = 20 (key, correct). Sign error moving 40: 3x + 40 = x -> 2x = -40 -> x = -20. Moving x with sign error: 4x = 40 -> x = 10 (that is option 2). x = 55 only arises from 4x + 40 = 180 -> 4x = 220, i.e. the supplementary-angle error (assigned to option 3, x = 35) plus the sign error.

### MTH1W — Data

- **Q13 · MAJOR** — Distractor "17.14 dollars" feedback ("Only the largest group was weighted. Every wage level contributes.") describes a mistake that does not produce 17.14
  <br>_Verified:_ Weighting only the largest group: 17*20/20 = 17.00; weighting largest group and counting the other four wages once: (340+19+20+25+30)/24 = 434/24 = 18.08. Exhaustive search over subset-weighted numerators/denominators from the table gives only 857/50 = 17.14 (50 is not a quantity in the problem; total frequency is 43). Correct key 857/43 = 19.93 is unaffected.
- **Q22 · MAJOR** — Distractor "42" feedback ("The two totals were added rather than subtracted.") describes a mistake that produces 188, not 42
  <br>_Verified:_ Totals are 5*20 = 100 and 4*22 = 88; 100 + 88 = 188. The value 42 is the sum of the two MEANS (20 + 22), not of the two totals. Correct key 100 - 88 = 12 is unaffected.
- **Q29 · MAJOR** — Distractor "53.4" feedback ("The 8 was added rather than multiplied by the slope.") describes a mistake that produces 61.4, not 53.4
  <br>_Verified:_ 5.4 + 8 + 48 = 61.4 (and 48 + 8 = 56). 53.4 = 5.4 + 48, i.e. the 8 was dropped entirely / x taken as 1. Correct key 5.4*8 + 48 = 91.2 is unaffected.
- **Q31 · MAJOR** — Distractor "70.5" feedback ("The extra marks were shared across the wrong number of students.") describes a mistake that produces 71.05, not 70.5
  <br>_Verified:_ Extra marks = 91 - 70 = 21; sharing over the old size 20 gives 70 + 21/20 = 71.05, over 21 gives the correct 71.00. To land on 70.5 the divisor would have to be 42, which is not a class size in the problem. Correct key (20*70 + 91)/21 = 1491/21 = 71 is unaffected.
- **Q23 · MINOR** — Prompt is not answerable on its own: it says "the wage table" but supplies no wages or frequencies, and the table was last stated 9 items earlier (Q13); the neighbouring chained items Q4, Q13 and Q28 all restate their data
  <br>_Verified:_ Answer "It stays at 17 dollars" requires knowing 17 dollars has frequency 20 versus the new 30-dollar frequency 4; nothing in the Q23 prompt provides 17, 20, or the other four levels.

### MTH1W — Financial literacy

- **Q4 · MAJOR** — Option 2 ("1500.00 dollars") feedback "The rate was applied as 50 percent rather than 5 percent" does not produce 1500 under the compound formula of the prompt
  <br>_Verified:_ 1000*(1.5)^3 = 3375.00 (compound, 3 yr at 50%); 1000*(1+0.5*3) = 2500.00 (simple at 50%); 1500 = 1000*1.5, i.e. one single year only. Key checks out: 1000*1.05^3 = 1157.625 -> 1157.63
- **Q12 · MAJOR** — Option 0 ("0.3 years") feedback says "The principal was left out of the division", but leaving out the principal gives 2500, not 0.3; 0.3 is what you get leaving out the RATE (feedbacks for options 0 and 2 are swapped)
  <br>_Verified:_ I = 1000-750 = 250; correct t = 250/(750*0.10) = 3.333 -> 3.3. Principal omitted: 250/0.10 = 2500. Rate omitted: 250/750 = 0.333 -> 0.3
- **Q12 · MAJOR** — Option 2 ("2.5 years") feedback says "The rate was left out of the division", but that mistake gives 0.333 (option 0's value), not 2.5
  <br>_Verified:_ 250/750 = 0.333; 2.5 = 250/(0.10*1000), i.e. using the final amount 1000 as the principal (equivalently 250/100)
- **Q21 · MAJOR** — Option 3 ("28 years") feedback "That divides by the rate twice over" does not produce 28
  <br>_Verified:_ Correct t = 560/(2000*0.04) = 7. Dividing by the rate a second time: 7/0.04 = 175 (or 560/(2000*0.04*0.04) = 175); 560/0.04/0.04 = 350000. 28 = 560/(2000*0.01), i.e. the rate taken as 1 percent
- **Q22 · MAJOR** — Option 0 ("26 percent") feedback "divides the GAIN by the principal but forgets to spread it over the five years" produces 30 percent, which is option 2's value, not 26 percent; nothing in the data yields 26 percent
  <br>_Verified:_ Gain = 1560-1200 = 360; 360/1200 = 0.30 = 30% (= option 2, whose own feedback already describes exactly this); correct rate 360/(1200*5) = 0.06 = 6%


## Grade 10 — MPM2D (LIVE)

### MPM2D — Linear systems

- **Q31 · CRITICAL** — Class B: two distractors are the same value — option 0 "2" and option 3 "12/6" are numerically identical, so the item offers only three distinct choices
  <br>_Verified:_ 12/6 = 2 exactly (sympy: sympify('12/6') == sympify('2') -> True); key is k = 3 (2x + ky = 6 doubled is 4x + 2ky = 12, matching 4x + 6y = 12 needs 2k = 6), so both duplicates are wrong but indistinguishable
- **Q4 · MAJOR** — Class C: feedback for option 3 "(1, 2)" says "That point sits on the second line only", but (1, 2) lies on NEITHER line
  <br>_Verified:_ y = 3x + 1 at x = 1 gives y = 4; y = -x + 5 at x = 1 gives y = 4. Intersection is (1, 4) = key. (1, 2) satisfies no equation
- **Q22 · MAJOR** — Class C: feedback for option 1 "(5, 0)" says "Setting y = 0 solves only one equation", but (5, 0) satisfies neither equation and y = 0 never yields x = 5
  <br>_Verified:_ 4(5) - 3(0) = 20 != 5; 2(5) + 0 = 10 != 5. Setting y = 0 gives x = 5/4 in eq1 and x = 5/2 in eq2, not 5. True solution (2, 1)
- **Q26 · MAJOR** — Class C: feedback for option 0 "6" blames using l = 2w - 3, but that error produces w = 7, not 6; w = 6 comes from dropping the "+3" entirely (l = 2w)
  <br>_Verified:_ sympy: {l = 2w - 3, 2(l + w) = 36} -> w = 7, l = 11; {l = 2w, 2(l + w) = 36} -> w = 6; correct {l = 2w + 3, 2(l + w) = 36} -> w = 5, l = 13
- **Q33 · MAJOR** — Class C: feedback for option 2 "4333 dollars" blames the setup 0.04(a + b) = 260, but that gives 6500; 4333 comes from 260/0.06 (putting all money at 6 percent)
  <br>_Verified:_ 260/0.04 = 6500 and 0.04(a+b) = 260 with a+b = 5000 is inconsistent; 260/0.06 = 13000/3 = 4333.33. Correct: a = 2000 at 4 percent, b = 3000 at 6 percent
- **Q35 · MAJOR** — Class C: feedback for option 3 "6" states the ages in 12 years would be "18 and 48", which is arithmetically impossible for s = 6
  <br>_Verified:_ If s = 6 then f = 3(6) = 18, and in 12 years the ages are 18 and 30 (ratio 1.67), not 18 and 48. 48 is the father in the CORRECT case (s = 12, f = 36, future 24 and 48)
- **Q36 · MAJOR** — Class C: feedback for option 3 "10" blames using total mass 30 instead of (30 + x), but that error gives x = 6; x = 10 comes from dividing 3 by 0.3 instead of 0.2
  <br>_Verified:_ sympy: 6 + 0.5x = 0.3(30) -> x = 6; 6 + 0.5x = 0.3(30 + x) -> x = 15 (key); 3/0.3 = 10. Also 10 kg gives 27.5 percent, not 30
- **Q24 · MINOR** — Class E: prompt "For the coin jar above" carries no data of its own — the 25 coins and 4.30 dollars exist only in Q23, so the item is unanswerable if shown standalone or shuffled
  <br>_Verified:_ Needed system d + q = 25, 0.10d + 0.25q = 4.30 -> d = 13, q = 12; none of those numbers appear in the Q24 prompt or options

### MPM2D — Analytic geometry

- **Q1 · MAJOR** — Class C: feedback for option 1 "(3, 2)" says "That is half of one endpoint", but no endpoint halves to (3, 2) — that value is half the DIFFERENCE of the endpoints
  <br>_Verified:_ A(2,3), B(8,7): A/2 = (1, 1.5), B/2 = (4, 3.5); (B - A)/2 = (6/2, 4/2) = (3, 2). Key midpoint = (5, 5)
- **Q1 · MAJOR** — Class C: feedback for option 2 "(6, 4)" blames mixing x with y in the averages, but that error cannot produce (6, 4); (6, 4) is simply B - A (the run and rise)
  <br>_Verified:_ Mixed averages give ((2+3)/2, (8+7)/2) = (2.5, 7.5) or ((2+7)/2, (3+8)/2) = (4.5, 5.5); B - A = (8-2, 7-3) = (6, 4)
- **Q3 · MAJOR** — Class D: feedback for option 1 "(1, 1)" states the correct y-coordinate outright ("half of that is -1"), and since the option's x = 1 is not disputed, the key (1, -1) is fully revealed
  <br>_Verified:_ Midpoint of (-1,2) and (3,-4) = ((-1+3)/2, (2-4)/2) = (1, -1) = key option 0. Feedback text: "2 + (-4) is -2, and half of that is -1"
- **Q11 · MAJOR** — Class C: feedback for option 3 "√64" blames using run 8 instead of 10, but run 8 gives √100, not √64; √64 comes from SUBTRACTING 100 - 36
  <br>_Verified:_ Correct: run 10, rise -6, 100 + 36 = 136 -> √136 (key). Run-8 error: 64 + 36 = 100 -> √100 = 10, which is not an option. 100 - 36 = 64
- **Q25 · MAJOR** — Class D: feedback for option 2 "It has no right angle" performs the whole solution and names the vertex, restating key option 0 almost verbatim
  <br>_Verified:_ Feedback says "Slope of AB is 1/2 and slope of BC is -2. Their product is exactly -1"; computed: AB slope = (4-2)/(3+1) = 1/2, BC slope = (0-4)/(5-3) = -2, product = -1. Key option 0 reads "At B, because the slopes of AB and BC multiply to -1"
- **Q26 · MAJOR** — Class C: feedback for option 1 "10" says 10 comes from adding rise 8 and run 4, but 8 + 4 = 12 (and half of it is 6), never 10
  <br>_Verified:_ BC from (1,-6) to (5,2): run 4, rise 8, BC = √80; midsegment = √80/2 = √20 = 2√5 (key). Adding legs: 8 + 4 = 12; half the midsegment legs: 2 + 4 = 6. Nothing yields 10
- **Q35 · MAJOR** — Class C: feedback for option 3 "√98" says it measures from A to the midpoint of the WRONG side, but neither wrong side gives √98
  <br>_Verified:_ A(2,8) to midpoint AC (4,4): 4 + 16 = 20 -> √20; A to midpoint AB (-1,5): 9 + 9 = 18 -> √18; A to midpoint BC (1,1): 1 + 49 = 50 -> √50 (key). Other medians are √68 and √74. 98 = 7² + 7², i.e. squaring the rise twice
- **Q36 · MAJOR** — Class C and D: feedback for option 0 "1" says "MN rises 2 over a run of 4. Simplify 2/4" — failing to simplify 2/4 yields 1/2, not 1, and the instruction hands over the key value
  <br>_Verified:_ MN slope = (2-0)/(4-0) = 2/4 = 1/2 (key). 1 is reachable only by doubling MN slope (side is twice the midsegment), which the feedback never mentions; "simplify 2/4" states the correct answer outright
- **Q38 · MAJOR** — Class D: feedback for option 0 "x² + y² = 50" states "the radius is 5 and r² is 25", which is exactly the key equation
  <br>_Verified:_ Diameter (-3,4) to (3,-4): length = √(36+64) = 10, r = 5, r² = 25 -> key option 1 "x² + y² = 25". The feedback supplies 25 with no work left
- **Q40 · MAJOR** — Class D: feedback for option 2 lists all three squared distances ("68, 20 and 36"), and option 0 adds "16 + 4 under the root", so the key "B, at distance √20" is handed over
  <br>_Verified:_ Computed OA² = 4 + 64 = 68, OB² = 16 + 4 = 20, OC² = 36 + 0 = 36; minimum 20 -> B at √20 = key option 3
- **Q37 · MINOR** — Class E: prompt says "the earlier triangle", a cross-reference to a different item (Q22) that does not exist when this question is shown standalone or shuffled; the numbers needed are present, so the item is still answerable
  <br>_Verified:_ Both lines are given in the prompt: -2x + 9 = (1/2)x + 2 -> 2.5x = 7 -> x = 14/5 = 2.8, y = 17/5 = 3.4 = key. The phrase "earlier triangle" (A(1,7), B(-2,1), C(6,5)) adds no data and appears nowhere in this item

### MPM2D — Factoring

- **Q5 · CRITICAL** — Options 2 and 3 have the same value: x(5 + 20) and 5x(1 + 4) both equal 25x
  <br>_Verified:_ expand(x*(5+20)) = 25x; expand(5x*(1+4)) = 25x. Two distractors are the same product; option 3's own feedback even says "that collapses to 25x". Key 5(x+4) = 5x+20 is correct.
- **Q10 · CRITICAL** — Options 1 and 2 are literally the same expression: "(x - 7)(x - 7)" and "(x - 7)²"
  <br>_Verified:_ Both expand to x² - 14x + 49; they are the same answer written two ways, so a student cannot distinguish them. Key (x-7)(x+7) = x²-49 is correct.
- **Q13 · CRITICAL** — Options 0 and 2 are the same expression: "7x²y²(3x - 4y²)" and "7x²y²(3x - 4y² + 0)"
  <br>_Verified:_ Both expand to 21x³y² - 28x²y⁴ (the "+0" term is vacuous). Key 7x²y²(3x-4y²+1) = 21x³y²-28x²y⁴+7x²y² is correct.
- **Q21 · CRITICAL** — Keyed option (index 3, "5m² - 5mn + 10") is not the correct simplification; NO option is correct
  <br>_Verified:_ 2(6m² - mn + 4) - (7m² + 4mn - 2) = 12m² - 2mn + 8 - 7m² - 4mn + 2 = 5m² - 6mn + 10 (sympy expand). Options are 5m²+3mn+10, 5m²-5mn+6, 12m²-5mn+10, 5m²-5mn+10 — none equals 5m²-6mn+10. Key assumes 2*(-mn) = -mn.
- **Q24 · CRITICAL** — Options 0 and 2 are the same answer: (4x - 6y)(x + y) and (2x - 3y)(2x + 2y) are both 2(2x - 3y)(x + y)
  <br>_Verified:_ expand((4x-6y)(x+y)) = 4x² - 2xy - 6y²; expand((2x-3y)(2x+2y)) = 4x² - 2xy - 6y². Identical polynomials, and both feedbacks state the same two flaws (trapped factor 2, wrong middle term). Key (4x+3y)(x-2y) = 4x²-5xy-6y² is fine.
- **Q15 · MAJOR** — Distractor feedback hands over the key with no work left: option 0's feedback says "Try the pair -4 and -6"
  <br>_Verified:_ Key is option 1, "(x - 4)(x - 6)"; the feedback names exactly its two numbers. (Its own arithmetic is right: -8*-3 = 24, -8 + -3 = -11.)
- **Q20 · MAJOR** — Distractor feedback reveals the key: option 0's feedback says "The perfect square uses 6 and 6"
  <br>_Verified:_ Key is option 1, "(x + 6)²"; expand = x²+12x+36. The feedback states the answer outright rather than diagnosing (x+4)(x+9) = x²+13x+36.
- **Q29 · MAJOR** — In a "which does NOT factor" item, option 1's feedback identifies the key: "Only the pair for 3 with sum 5 fails to exist"
  <br>_Verified:_ Key is option 0, x² + 5x + 3 (sympy factor leaves it irreducible; discriminant 25-12 = 13, not a perfect square). The feedback names the constant-3 trinomial as the non-factorable one.
- **Q32 · MAJOR** — Distractor feedback reveals the whole solution: option 0's feedback gives "Group as x²(x + 3) + 2(x + 3). The shared bracket is (x + 3)."
  <br>_Verified:_ That grouping yields exactly the key (x² + 2)(x + 3); expand = x³+3x²+2x+6. Nothing is left for the student to compute.
- **Q21 · MINOR** — misconception_tag "sub-multiplying-binomials" does not match the task
  <br>_Verified:_ The prompt contains no product of binomials; it is distribution of a scalar over a trinomial plus subtraction of a bracket (2(6m²-mn+4) - (7m²+4mn-2)).

### MPM2D — Quadratics

- **Q9 · MAJOR** — Distractor "x = 3" feedback states the correct answer outright ("Averaging 1 and 7 gives 4") and never explains where 3 comes from (the plausible error is half the gap, (7-1)/2 = 3)
  <br>_Verified:_ Axis = (1+7)/2 = 4 = correct option text "x = 4"; feedback for wrong option 2 names that value directly, so the item is given away
- **Q28 · MAJOR** — Distractor "40 m at t = 2 s" feedback states the correct maximum ("k = 45, no arithmetic needed") and does not diagnose how 40 arises (45 - 5, confusing a with k)
  <br>_Verified:_ h = -5(t-2)^2 + 45, vertex (2, 45); correct option is "45 m at t = 2 s"; the wrong option's feedback supplies 45 and t = 2 verbatim
- **Q33 · MINOR** — Prompt "What is the maximum area of that pen?" is not self-contained: it depends entirely on Q32 for the fence length and the model A = w(20 - w); read alone it is unanswerable
  <br>_Verified:_ Answer 100 m^2 requires A = w(20-w) with vertex w = 10 -> 10(20-10) = 100, none of which appears in the Q33 prompt or option texts

### MPM2D — Solving quadratic equations

- **Q12 · MAJOR** — Class D: the feedback on wrong option [0] ("x = 2 and x = 4") spells out the correct answer verbatim — "2x(x - 4) zeroes at 0 and 4" — which is exactly correct option [3] "x = 0 and x = 4"
  <br>_Verified:_ 2x^2-8x=0 -> 2x(x-4)=0 -> x in {0,4} (sympy: [0, 4]); option [3] text = "x = 0 and x = 4"
- **Q13 · MAJOR** — Class D: the feedback on wrong option [3] ("x = 3 +/- sqrt7") states the correct answer outright — "(x + 3)^2 = 7 unwinds to x = -3 plus or minus sqrt7" — which is correct option [2]
  <br>_Verified:_ solve(x^2+6x+2) = [-3 - sqrt(7), -3 + sqrt(7)]; feedback string contains "x = -3 plus or minus sqrt7" = option [2] text
- **Q22 · MAJOR** — Class D: the feedback on wrong option [3] ("x = 1 and x = 6") ends with "The pair 2 and 3 fits both", naming the correct roots, i.e. correct option [0]
  <br>_Verified:_ x^2 = 5x-6 -> x^2-5x+6=0 -> solve = [2, 3]; option [0] text = "x = 2 and x = 3"
- **Q23 · MAJOR** — Class D: the feedback on wrong option [2] ("x = 1 only") gives both correct roots as arithmetic — "two unwindings: 3 + 2 and 3 - 2" = 5 and 1 — which is correct option [1]
  <br>_Verified:_ solve(2x^2-12x+10) = [1, 5]; 3+2=5, 3-2=1 = option [1] "x = 1 and x = 5"
- **Q23 · MAJOR** — Class C: the feedback on wrong option [3] ("x = 3 +/- sqrt14") blames failure to divide by 2 ("Completing on 2x^2 directly misplaces the constant"), but no not-dividing path yields 14; sqrt14 only arises AFTER dividing by 2, from adding the constant instead of subtracting it
  <br>_Verified:_ Not dividing: 2(x^2-6x)=-10 -> 2(x-3)^2 = -10+18 = 8 -> (x-3)^2=4 (correct); common no-divide slips give (x-3)^2 = -1, 8, or 26, never 14. Dividing first: x^2-6x+5=0, correct (x-3)^2 = 9-5 = 4, sign-error (x-3)^2 = 9+5 = 14 -> x = 3 +/- sqrt14. So the option comes from a moved-constant sign error, not from skipping the division
- **Q40 · MAJOR** — Class C: the feedback on wrong option [2] ("6") says the student forgot the factor of one half (used x(x-3)=27), but that mistake does not give 6; 6 is really the HEIGHT x-3 when x = 9
  <br>_Verified:_ Correct: (1/2)x(x-3)=27 -> x^2-3x-54=0 -> x in {-6, 9}. Forgetting the half: x(x-3)=27 -> x = (3 +/- sqrt117)/2 = 6.9083 or -3.9083, not 6. With x=9 the height x-3 = 6, which is what option [2] actually is
- **Q31 · MINOR** — Distractor option [2] "16/28" (= 4/7) is not produced by any error the feedback describes ("Expand fully before solving"); dropping the quadratic term from either the right or the wrong set-up gives 8/7 or 16/7, so the option value looks like a typo. Still unambiguously wrong, so the key is unaffected
  <br>_Verified:_ Correct: (8+2x)(6+2x)=80 -> x^2+7x-8=0 -> x in {-8, 1}. Dropping 4x^2: 28x=32 -> x=32/28=8/7. Wrong set-up (8+x)(6+x)=80 dropping x^2: 14x=32 -> x=16/7. Neither equals 16/28=4/7
- **Q35 · MINOR** — misconception_tag is "sub-quadratic-formula", but the question is about recognising a perfect-square trinomial and the keyed answer is "Factoring, because it is a perfect square trinomial"; the tag should be the factoring sub-topic
  <br>_Verified:_ x^2-10x+25 = (x-5)^2, double root x=5; correct option [0] is the factoring option, while the quadratic-formula option [3] is a distractor

### MPM2D — Trigonometry

- **Q2 · MAJOR** — Distractor 0's feedback performs the full correct computation ("3 times 4"), handing the student the keyed answer 12 cm
  <br>_Verified:_ 3 x 4 = 12 = option 2 (key). Feedback on a wrong option states the winning calculation outright.
- **Q33 · MAJOR** — Distractor 1 (30.0°) feedback blames early rounding ("Round only at the end"), but no rounding of the cosine ratio produces 30.0° — the option value is unexplained by the stated mistake
  <br>_Verified:_ Correct: cos A = (11²+15²-8²)/(2·11·15) = 282/330 = 0.854545, cos⁻¹ = 31.290° -> 31.3 (key, verified). Rounding the ratio to 0.85 gives cos⁻¹ = 31.788 -> 31.8; to reach 30.0 you would need cos = 0.866. No rounding path yields 30.0.
- **Q38 · MAJOR** — Distractor 2's feedback spells out the exact correct computation for the key ("its cosine is (36 + 36 - 100) over 72")
  <br>_Verified:_ (36+36-100)/72 = -28/72 = -0.38889, cos⁻¹ = 112.885 -> 112.9 = option 3 (key). The wrong option's feedback gives the complete recipe for the correct answer.
- **Q10 · MINOR** — Keyed option 0 ("When the triangle has no right angle") is overbroad — most non-right triangles are solved with the sine law, not the cosine law — and distractor 1's own feedback states the stricter, genuinely correct condition (two sides with contained angle, or all three sides), contradicting the key
  <br>_Verified:_ Distractor-1 feedback text: "Cosine law is for two sides with the contained angle, or all three sides." Q27/Q35 in the same unit key exactly that distinction, so the unit is internally inconsistent with Q10's key.
- **Q19 · MINOR** — Distractor 1 (39.0°) feedback cites "sin⁻¹(0.633)", but that value rounds to the KEY, not to this option; only rounding the ratio to 0.63 produces 39.0
  <br>_Verified:_ sin A = 9·sin80°/14 = 0.6330907 -> sin⁻¹ = 39.2785 -> 39.3 (key). sin⁻¹(0.633) = 39.272 -> 39.3 (still the key). sin⁻¹(0.63) = 39.050 -> 39.0. Feedback's stated number contradicts the option it explains.
- **Q20 · MINOR** — Distractor 0 (2.0 cm) feedback describes only the order-of-operations slip, which yields a² = 2 (a ≈ 1.4); landing on 2.0 also requires omitting the square root, which the feedback never mentions (contrast option 2, which explicitly flags "67 is a²")
  <br>_Verified:_ (b²+c²-2bc)·cos A = (49+81-126)·0.5 = 4·0.5 = 2.0 = a², so a = √2 = 1.414. Key: a² = 49+81-2·7·9·cos60° = 67, a = 8.185 -> 8.2.


## Grade 11 — MCR3U

### MCR3U — Functions

- **Q16 · MAJOR** — Option 0 ("x = -7 or x = 3") feedback does not describe an error that produces it — it states the condition the correct factor pair must satisfy, and the distractor's own numbers satisfy that condition exactly, so a student checking as instructed will conclude the wrong option is right (class C).
  <br>_Verified:_ 2x^2-8x-42=0 -> x^2-4x-21=0, factor pair is (-7, +3): (-7)(3) = -21 and (-7)+(3) = -4, i.e. precisely "multiply to -21 and add to -4" as the feedback asks. Actual roots are x = 7 or x = -3 (sympy solve(2*x**2-8*x-42) = [-3, 7]); the real error is reading the factor constants as the roots, which the feedback never says.
- **Q40 · MAJOR** — Option 2 ("k = 21/4") feedback attributes it to using constant 5 + k instead of 5 - k, but that mistake yields -19/4 (which is option 1), not 21/4 (class C).
  <br>_Verified:_ Correct: x^2+3x+5 = 2x+k -> x^2+x+(5-k)=0, disc 1-4(5-k)=0 -> k = 19/4. With 5+k: disc 1-4(5+k)=0 -> k = -19/4 (option 1). 21/4 only arises from a sign error on the -4ac term: 1+4(5-k)=0 -> k = 21/4 (all verified with sympy discriminant/solve).

### MCR3U — Rational Expressions

- **Q8 · MAJOR** — Feedback for option "x² + 9x + 21" names a mistake ("only the number 3 was struck out") that does not produce that option.
  <br>_Verified:_ Striking only the 3 out of x+3 leaves (x²+10x+21)/x, i.e. numerator unchanged with denominator x; the option instead has the whole denominator gone AND 10x reduced to 9x, i.e. it is (x²+10x+21) − x, which requires striking out the x (against 10x), not the 3. Key checked: (x²+10x+21)/(x+3) = x+7 (index 2) — correct.
- **Q15 · MAJOR** — Feedback for option "x ≠ 6 and x ≠ -3" hands over the correct answer by stating the full factorisation plus the sign rule.
  <br>_Verified:_ "The denominator factors into x + 6 and x - 3, and each bracket flips sign when it is set to zero" gives x+6=0 → x=-6 and x-3=0 → x=3, which is exactly the keyed answer x ≠ -6 and x ≠ 3 (sympy: factor(x²+3x-18) = (x-3)(x+6), roots {-6, 3}). Naming the factors is information beyond what is needed to name the student's sign error.
- **Q38 · MAJOR** — Feedback for option "(x - 3)/(x + 2)" describes a mistake that cannot produce that option.
  <br>_Verified:_ Factored, the flipped product is [(x-3)(x+3)(x+4)(x-2)] / [(x-3)(x+2)(x+3)(x+4)]. Top and bottom each contain exactly one (x-3) and one (x+3), so whether the student pairs them correctly or "cancels x+3 against x-3" as the feedback describes, all four 3-brackets are consumed and the result is (x-2)/(x+2) — the keyed answer — in both cases. Reaching (x-3)/(x+2) additionally requires cancelling the top (x-2) against the bottom (x+3), which the feedback never mentions; the real error in that option is keeping the x-3 from x²-9 instead of the x-2 from x²+2x-8.

### MCR3U — Transformations

- **Q5 · MAJOR** — The distractor "Left 3 units" has feedback that states the correct answer outright ("x - d moves the graph RIGHT when d is positive") when the whole question is only about direction.
  <br>_Verified:_ y = √(x-3) is y = √x shifted right 3 (parent start (0,0) -> (3,0); check √(3-3)=0). The feedback's word "RIGHT" is the exact text of the keyed option 2 "Right 3 units", so the distractor's feedback alone identifies the key with no work.
- **Q28 · MAJOR** — The distractor "y approaches -4 from below" has feedback whose second clause ("so it lands just on the high side") is the correct answer, not a description of the student's mistake.
  <br>_Verified:_ y = 3/(x+2) - 4: limit as x->inf is -4 and 3/(x+2) > 0 for large x, e.g. x=1000 gives -3.99700..., i.e. approach from above = keyed option 0. Naming the error only needed the first clause ("the fraction is a small POSITIVE number"); "lands just on the high side" hands over option 0 verbatim in meaning.
- **Q33 · MINOR** — misconception_tag is "sub-transform-quadratic" although the task is finding an inverse; the structurally identical Q39 ("Find the inverse of f(x) = 2(x-1)^2 + 2") is tagged "sub-inverse-function".
  <br>_Verified:_ Q33 asks for the inverse of f(x) = 2x^2 + 16x + 30 = 2(x+4)^2 - 2, key -4 ± √((x+2)/2) (sympy: solve(x = 2y^2+16y+30, y) = -4 ± sqrt(2x+4)/2, and sqrt(2x+4)/2 = sqrt((x+2)/2)); the graded skill is inverse-of-a-quadratic, matching Q39's tag rather than the transformation tag used here.

### MCR3U — Exponential Functions

- **Q8 · MAJOR** — Class D: the feedback on wrong option [2] ("1") hands over the correct answer by naming it — "The base to the power 0 is 1, but the 5 out front still multiplies it" gives 1 x 5 = 5, which is correct option [3] "5"
  <br>_Verified:_ y = 5(3)^x at x = 0: 3^0 = 1, y = 5*1 = 5 (sympy: (5*3**x).subs(x,0) = 5); correct option [3] text = "5", literally contained in option [2] feedback
- **Q36 · MAJOR** — Class D: the feedback on wrong option [2] ("The simple account, by about $704") states "The gap is the right size but it falls the other way", which uniquely identifies correct option [1] ("The compound account, by about $704") — nothing is left for the student to work out
  <br>_Verified:_ Compound: 5000*1.06^10 = 8954.24; simple: 5000*(1+0.065*10) = 8250.00; difference = 704.24, compound ahead, so "right size, other way" = option [1] verbatim
- **Q14 · MINOR** — Class C (mild): the feedback on wrong option [3] ("f(t) = 40(1/2)^(20t)") says "The exponent is upside down", but literally inverting the correct exponent t/20 gives 20/t, not 20t; the actual slip is multiplying by the half-life instead of dividing (the corrective second sentence is right, and the option is still unambiguously wrong)
  <br>_Verified:_ Correct model 40(1/2)^(t/20): at t = 20 gives 20 mg, at t = 40 gives 10 mg. Option [3] at t = 20 gives 40*(1/2)^400 ~ 0; the "upside down" form 40(1/2)^(20/t) at t = 20 gives 20 mg but is a different expression from the one offered

### MCR3U — Trig Geometry

- **Q28 · MAJOR** — Class D: the feedback on wrong option [1] ("45°") hands over the correct answer — "45 does satisfy the equation ... A second solution sits half a turn further round" is the complete recipe 45 + 180 = 225, which is correct option [0]
  <br>_Verified:_ cot 45 = 1 ✓; cot θ = 1 on (180°,270°) → θ = 45 + 180 = 225°, and cot 225 = 1/tan 225 = 1/1 = 1; the feedback leaves nothing for the student to compute
- **Q30 · MAJOR** — Class D: the feedback on wrong option [1] ("1/sin²x") ends with "the cosine ends up on the bottom", which uniquely identifies correct option [0] "1/cos²x" — the only option with cosine in the denominator
  <br>_Verified:_ tan²x + cos²x + sin²x = tan²x + 1 = sec²x = 1/cos²x (numeric check at x = 1 rad: 3.42552 = 3.42552); the distractor 1/sin²x only needed the contrast "that is cot²x + 1", not the location of the cosine
- **Q36 · MAJOR** — Class C: the feedback on wrong option [1] ("-5/12") asserts "That is tan θ", but in the third quadrant tan θ is POSITIVE, so no named mistake produces -5/12 as a tangent (the option is a sign-sloppy opposite-over-adjacent, not tan θ)
  <br>_Verified:_ csc θ = -13/5 → sin θ = -5/13; quadrant III → cos θ = -12/13; tan θ = (-5/13)/(-12/13) = +5/12 (sympy: Rational(-5,13)/Rational(-12,13) = 5/12), and the bank itself states in Q3 that tangent is the positive ratio in QIII
- **Q39 · MAJOR** — Class D: the feedback on wrong option [0] ("cot x") completes the simplification instead of naming the mistake — "the numerator becomes sin²x, and one of those sines cancels, leaving a sine on TOP of the cosine" states sin x/cos x, i.e. correct option [3] "tan x" in words
  <br>_Verified:_ (1 - cos²x)/(sin x cos x) = sin²x/(sin x cos x) = sin x/cos x = tan x (sympy simplify → tan(x)); "sine on top of the cosine" identifies option [3] uniquely with zero work
- **Q40 · MAJOR** — Class D: the feedback on wrong option [1] ("cos²θ") walks the entire correct derivation — "the numerator becomes tan²θ, and dividing by sec²θ multiplies by cos²θ, which cancels the cosines on the BOTTOM of the tangent" ends at sin²θ, correct option [0]
  <br>_Verified:_ (sec²θ - 1)/sec²θ = tan²θ · cos²θ = (sin²θ/cos²θ)·cos²θ = sin²θ (numeric check at θ = 1 rad: 0.70807 = 0.70807); following the feedback sentence produces the key outright
- **Q24 · MINOR** — Class C (mild): the feedback on wrong option [1] ("sin θ = 3/5 and tan θ = -3/4") says the coordinates "swapped roles", but swapping them gives sin θ = x/r = -3/5, not +3/5 — the tangent matches the described slip and the sine does not (the option is still unambiguously wrong)
  <br>_Verified:_ P(-3,4), r = 5; correct sin = 4/5, tan = 4/(-3) = -4/3; swapping to (4,-3) gives sin = -3/5 and tan = x/y = -3/4, so only the tan component of option [1] is reproduced by the stated mistake
- **Q32 · MINOR** — Class E: misconception_tag is sub-angles-beyond-90, but "Find both angles between 0° and 360° with sin θ = -0.46" is the same solve-the-equation task the bank tags sub-trig-equations everywhere else (Q15, Q16, Q25, Q33, Q34)
  <br>_Verified:_ arcsin(0.46) = 27.387° → solutions 180 + 27.4 = 207.4° and 360 - 27.4 = 332.6°, identical in form to Q25 (tan θ = -0.32 → 162.3°, 342.3°), which is tagged sub-trig-equations
- **Q39 · MINOR** — Class C (mild): the feedback on wrong option [1] ("sin x cos x") blames "the numerator was multiplied out", but expanding 1 - cos²x cannot yield sin x cos x — that option comes from multiplying by cos x instead of dividing (sin²x/sin x · cos x); the corrective second sentence is right
  <br>_Verified:_ sin²x/(sin x cos x) = tan x; sin x cos x = sin²x/sin x × cos x, i.e. the denominator factor cos x was multiplied rather than divided, which the feedback never names

### MCR3U — Trig Functions

- **Q16 · MAJOR** — Feedback on the distractor "Maximum 9, minimum -9" opens with "The maximum is right" and then says the minimum is 4 below the axis of 5, handing the student both correct values.
  <br>_Verified:_ y = 4cos[3(x-20)]+5 has axis 5, amplitude 4, so max = 5+4 = 9 and min = 5-4 = 1; the feedback confirms 9 and computes 5-4 = 1, i.e. option 0, without the student doing any work.
- **Q17 · MAJOR** — Feedback on the distractor 1/2 says "That halves the maximum", but halving the maximum gives the CORRECT answer, not 1/2.
  <br>_Verified:_ Max = 2/3, so (2/3)/2 = 1/3 = the keyed answer; the option 1/2 actually comes from averaging maximum and shift, (2/3 + 1/3)/2 = 1/2. Amplitude = 2/3 - 1/3 = 1/3 (key correct).
- **Q22 · MAJOR** — Feedback on the distractor "Amplitude 0.25, maximum 0.25" states "The amplitude is right, but the curve waves about y = -2, so its peak is a quarter ABOVE that", which spells out the correct answer.
  <br>_Verified:_ Axis = -2, a = 1/4, so max = -2 + 0.25 = -1.75, exactly the value the feedback instructs the student to compute; key (option 2) is correct.
- **Q24 · MAJOR** — Feedback on the distractor "1" describes taking the sine of 30 instead of 90, but that mistake produces 1.5 (which is option 0), not 1.
  <br>_Verified:_ sin 30 deg + 1 = 0.5 + 1 = 1.5; the value 1 requires the sine term to be 0, a different error. Correct answer sin(30+60)+1 = sin 90 + 1 = 2 (key correct).
- **Q24 · MAJOR** — Feedback on the distractor "0" says it "misses both the shift inside and the + 1 outside", but that mistake gives 0.5, not 0.
  <br>_Verified:_ Dropping the +60 and the +1 leaves sin 30 deg = 0.5; nothing in the described error yields 0.
- **Q34 · MAJOR** — The feedback on "The first, at 360 deg" (and on "They all have the same period") identifies the third curve as the stretched, longest-period one, handing over the keyed option.
  <br>_Verified:_ Periods are 360, 360 and 360/(2/3) = 540; feedback text "the third has a k below 1, which stretches it out past them" and "360 divided by two thirds is more than 360" both name option 0 as the answer.
- **Q37 · MAJOR** — Feedback on the distractor y = (1/3) sin[3(x - 30)] + 1/3 ends "which needs x + 30", literally writing out the correct option.
  <br>_Verified:_ Max at (0, 2/3) with axis 1/3 and k = 3 gives y = (1/3) sin[3(x + 30)] + 1/3 (check x = 0: (1/3)sin 90 + 1/3 = 2/3); the distractor's feedback states the winning bracket verbatim.

### MCR3U — Discrete Functions

- **Q1 · MAJOR** — Feedback on option "1.5" claims it comes from dividing 15 by 9, but that division does not give 1.5
  <br>_Verified:_ 15/9 = 5/3 = 1.666..., not 1.5; correct d = 15-9 = 21-15 = 6 (key ok)
- **Q7 · MAJOR** — Feedback on option "16" states the correct answer in words ("a geometric sum always lands one short of it here" -> 16-1)
  <br>_Verified:_ 1+2+4+8 = 15 = 16-1, and 15 is the keyed option, so the feedback hands it over
- **Q8 · MAJOR** — Feedback on option "195" calls it the sum of the first FOUR terms, but S4 is 200
  <br>_Verified:_ S4 = 5+15+45+135 = 5(3^4-1)/2 = 200; 195 is actually 3*S3 = 3*65; S3 = 65 (key ok)
- **Q14 · MAJOR** — Feedback on option "9" says the count is "two short", but two short of nine divisions gives 1, not 9
  <br>_Verified:_ 2187*(1/3)^7 = 1, 2187*(1/3)^5 = 9 (four short); correct t10 = 2187*(1/3)^9 = 1/9 (key ok)
- **Q15 · MAJOR** — Feedback on option "220" says it uses 12 steps of d, but that computation gives 228
  <br>_Verified:_ (12/2)(2*1+12*3) = 6*38 = 228; no n/2(2a+kd) with a=1,d=3 yields 220; correct S12 = 6*(2+33) = 210
- **Q15 · MAJOR** — Feedback on option "190" says it uses ten steps, but that computation gives 192
  <br>_Verified:_ (12/2)(2*1+10*3) = 6*32 = 192; S10 = 145, S11 = 176 - none equal 190
- **Q15 · MAJOR** — Feedback on option "175" says it is the 12th term added to a shorter sum, but no partial sum plus t12 gives 175
  <br>_Verified:_ t12 = 34; 175-34 = 141, and S9 = 117, S10 = 145, S11 = 176; S11+t12 = 210 (the key)
- **Q16 · MAJOR** — Feedback on option "320" blames using 40 as the average of 21 and 43, but that error gives 480 (or 240), not 320
  <br>_Verified:_ 12*40 = 480, (12/2)*40 = 240; 320 = (10/2)(21+43), i.e. a 10-term count; correct S = (12/2)(64) = 384 (key ok)
- **Q18 · MAJOR** — Feedback on option "-4372" blames dividing by 3 instead of r-1 = 2, but that error gives -26240/3
  <br>_Verified:_ -4(3^8-1)/3 = -8746.67; -4372 = -4(3^7-1)/2 = S7, i.e. one term short; correct S8 = -4*3280 = -13120 (key ok)
- **Q25 · MAJOR** — Feedback on option "15" hands over the full solution by stating a = -7 and d = 2 (and it names no error that produces 15)
  <br>_Verified:_ From a+11d = 15 and (15/2)(2a+14d) = 105: d = 2, a = -7, so S3 = 3a+3d = -15 - the feedback gives the student both parameters
- **Q25 · MAJOR** — Feedback on option "-9" says it uses two steps of d, but 3a+2d = -17; -9 needs six steps
  <br>_Verified:_ 3a = -21, 3a+2d = -17, 3a+6d = -9; correct 3a+3d = -15 (key ok)
- **Q27 · MAJOR** — Feedback on option "16 401" calls it the sum with a = 1, but that gives 9841
  <br>_Verified:_ (3^9-1)/2 = 9841; 16401 = 5(3^8-1)/2 + 1 = S8+1; correct S9 = 5*9841 = 49205 (key ok)
- **Q32 · MAJOR** — Feedback on option "30" says it is (500-297) divided by 2, which is 101.5, not 30
  <br>_Verified:_ 203/2 = 101.5; 30 is in fact t2 = a+d = 17+13; solving 3(2a+5d)=297, 4(2a+7d)=500 gives a=17, d=13, t5 = 69 (key ok)
- **Q36 · MAJOR** — Feedback on option "They are equal" states both sums (820 and 930), which hands over both the winner and the gap of 110
  <br>_Verified:_ S20(3,7,11) = 10*82 = 820, S30(2,4,6) = 15*62 = 930, difference 110 - exactly the keyed option
- **Q37 · MAJOR** — Feedback on option "3280" reveals the correct answer by describing it ("the exact value is a fraction just above it")
  <br>_Verified:_ 265720/81 = 3280.4938, the key; the only other fraction option, 265720/243 = 1093.498, is not just above 3280
- **Q38 · MAJOR** — Feedback on option "21" says the signs were ignored, but ignoring signs over 6 terms gives 189, not 21
  <br>_Verified:_ 3+6+12+24+48+96 = 3(2^6-1)/1 = 189 (which is the magnitude of option 4); 21 = 3+6+12, only three terms; correct S6 = 3(64-1)/(-3) = -63 (key ok)
- **Q39 · MAJOR** — Feedback on option "11" describes doubling the first term and subtracting 1 three times, which gives 3 (or 23 if doubled three times)
  <br>_Verified:_ 2*3-1-1-1 = 3; 3*2^3-1 = 23; 11 would need t2 = 2*3 = 6 then 2*6-1; correct chain 3, 5, 9, 17 so t4 = 17 (key ok)


## Grade 12 — MHF4U

### MHF4U — Polynomial Functions

- **Q20 · CRITICAL** — Options 0 ("Even") and 2 ("Even, because the highest power is even") are the same answer written two ways, so the four options are really three.
  <br>_Verified:_ f(x)=x^4+5x: f(-x)=x^4-5x, which is neither f(x) nor -f(x), so "Neither" (index 3) is the key and both option 0 and option 2 assert the identical (wrong) classification "Even"; they cannot be distinguished as separate mistakes.
- **Q1 · MAJOR** — Feedback on "Degree 5, leading coefficient -5" confirms the leading coefficient AND states the degree is 4, which is the complete correct answer.
  <br>_Verified:_ y = -5x^4 + x^3 - 2x^2 + 3: degree 4, LC -5 (option 0). The feedback says "The coefficient is right, but the power on that term is 4", i.e. degree 4 and LC -5, leaving nothing to determine.
- **Q6 · MAJOR** — Feedback on the -4 distractor names a mistake that produces 0, not -4 (and 0 is itself option 2).
  <br>_Verified:_ Adding the three bracket constants gives 1 + (-3) + 2 = 0; adding the numerals gives 1+3+2 = 6 (option 1). -4 requires 1 - 3 - 2, i.e. adding with a sign error on the x+2 bracket. Correct y-intercept (1)(-3)(2) = -6 is unaffected.
- **Q15 · MAJOR** — Feedback on the "Degree 6, Q3 to Q1" distractor states the degree is 5, and that option already carries the correct end behaviour, so it delivers the whole key.
  <br>_Verified:_ Key: (x-4)^2(x+3)^3 expands to degree 2+3 = 5 with positive leading term x^5, so Q3 to Q1 (option 2). Option 0's feedback "2 and 3 give 5" plus the option's own "Q3 to Q1" reconstructs option 2 exactly.
- **Q16 · MAJOR** — Feedback on the -160 distractor states a computation that yields +160, and calls it the y-intercept, but the y-intercept is +160, not -160.
  <br>_Verified:_ -4 x 5 x (-2) x 4 = +160, and p(0) = -4(5)(-2)(4) = +160 (sympy expand: -8x^3 - 36x^2 + 24x + 160). -160 actually comes from -4 x 5 x 2 x 4, i.e. dropping the minus on the -2. Key LC = -4 x 2 = -8 is correct.
- **Q23 · MAJOR** — Feedback on the "Degree 4, leading coefficient -1" distractor states the correct answer outright ("degree 3 ... gives -4"), which is exactly the key.
  <br>_Verified:_ Key: a x 3! = -24 so a = -24/6 = -4, degree 3. The distractor's own mistake is -24/4! = -1; the feedback hands the student both components of option 2 verbatim.
- **Q26 · MAJOR** — Feedback on the 108 distractor claims the -4 was squared correctly, but 108 is only reachable by NOT squaring it.
  <br>_Verified:_ h(0) = (-4)^2(3)^3 = 16 x 27 = 432 (key, correct). 108 = 4 x 27, i.e. the first bracket used as -4/4 rather than 16. The feedback's own arithmetic is impossible: 108/16 = 6.75, and no student mistake produces 6.75 from 3^3.
- **Q36 · MAJOR** — Feedback on the k=2 distractor states "k is a half", which is the entire difference between that option and the key.
  <br>_Verified:_ Key: 8k = 4 so k = 1/2, g(x) = (1/2)(x+3)(x+1)(x-2)^2. Option 0 is the same product with k=2, so telling the student k is a half converts option 0 into option 3 with no work left.
- **Q38 · MAJOR** — Feedback on the (2, -9) distractor walks through the correct x-transformation ("doubles it to 4, and then the shift right adds 1"), and the option already contains the correct y, so the key (5, -9) is handed over.
  <br>_Verified:_ Key: (1/2)(x-1) = 2 gives x = 5; y = -(16) + 7 = -9, so (5, -9). The feedback supplies 4 + 1 = 5 and the option supplies -9.

### MHF4U — Factoring Polynomials

- **Q6 · MAJOR** — Option A ("No, because substituting 3 gives 6") feedback completes the substitution to zero, which is precisely the content of the correct option, so it reveals the answer instead of only naming the arithmetic slip.
  <br>_Verified:_ Feedback text: "3 times 9 is 27, and 27 - 24 - 3 leaves nothing", i.e. it states P(3) = 0; key D is "Yes, because substituting 3 gives 0". Verified P(3) = 27 - 24 - 3 = 0 and P(-3) = 27 + 24 - 3 = 48.
- **Q25 · MAJOR** — Option D "(x + 2)(x - 4)(3x - 1)" feedback hands over the correct answer: it says two brackets are right and then states outright that the third bracket is 3x + 1, which reconstructs the keyed option in full.
  <br>_Verified:_ Feedback text: "Two brackets are right. Substituting -1/3 into the original gives 0, so the third bracket is 3x + 1." Key A = (x + 2)(x - 4)(3x + 1); factor(3x^3 - 5x^2 - 26x - 8) = (x - 4)(x + 2)(3x + 1), roots -2, -1/3, 4.
- **Q37 · MAJOR** — Option A ("-30") feedback claims -30 is "the product of the three brackets at x = 0 without k applied", but that product is +30, so the named mistake does not produce this option (and the same question's option D feedback correctly says the brackets give "a positive 30").
  <br>_Verified:_ Family y = k(x+2)(x+3)(x+5); at x = 0 the brackets give (2)(3)(5) = +30, not -30. Through (2,-35): 140k = -35 so k = -1/4, y-intercept = (-1/4)(30) = -15/2 (key correct).

### MHF4U — Logarithmic Functions

- **Q11 · MAJOR** — Distractor "y = log base 4 of x" feedback hands over the correct base, so the key is identified without any work
  <br>_Verified:_ Feedback says "the inverse keeps the SAME base ... and that base is a quarter"; the key is "y = log base 1/4 of x", the only option with base 1/4 — naming the mistake ("wrong base kept") does not require stating that the base is 1/4
- **Q12 · MAJOR** — Distractor "x-intercept at (0, 0)" feedback states the correct intercept outright
  <br>_Verified:_ Feedback: "x = 0 is not even in the domain. The curve crosses ... at x = 1" — that gives x-intercept (1, 0) and no y-intercept, which is exactly the key (option 3), verified: log2(1)=0, log2 undefined at x=0
- **Q13 · MAJOR** — Feedback on the -4 option names a mistake that produces -16, not -4
  <br>_Verified:_ log4(1/16) = -2 (key, correct). "Reads the 16 in the denominator as the answer" gives -16; the value -4 is actually log2(1/16) = -4, i.e. base-2/base-4 confusion, which the feedback never mentions
- **Q16 · MAJOR** — Feedback on x = -2 names the unexpanded-exponent error, which gives x = 8/3, not -2
  <br>_Verified:_ 2^(6x+3)=2^(5x-5) => x = -8 (key). Stated error "left exponent 2x+3 instead of 6x+3": 2x+3 = 5x-5 => x = 8/3 = 2.67. The value -2 comes from 6x-3 = 5x-5 (sign slip on the +1), not from failing to expand
- **Q19 · MAJOR** — Feedback on $2688.00 names a mistake whose value is $6720.00
  <br>_Verified:_ 1500(1.12)^4 = 2360.279 (key, correct). Stated error 1500 x 1.12 x 4 = 6720.00, not 2688.00; no ordinary error path reaches 2688 (2688/1500 = 1.792, and 1.12^t = 1.792 needs t = 5.15)
- **Q23 · MAJOR** — Feedback on log7(128) names "multiply all three arguments", which gives 512, not 128
  <br>_Verified:_ log7 8 + log7 4 - log7 16 = log7(8*4/16) = log7 2 (key, correct). Multiplying instead of dividing by the last term gives 8*4*16 = 512, so the option should read log7(512)
- **Q25 · MAJOR** — Feedback on x = -1.301 names an error that evaluates to -2.151
  <br>_Verified:_ Correct: x = 2log3/(log3 - log5) = -4.30132 -> -4.301 (key OK). Stated error "2 log 3 left as log 3": log3/(log3-log5) = 0.47712/(-0.22185) = -2.1507, not -1.301 (-1.301 is just the key with its integer part altered; it equals -1 - log2)
- **Q26 · MAJOR** — Feedback on x = -2.84 names an error that evaluates to -3.16
  <br>_Verified:_ Correct: x = log5/log4 - 2 = -0.83904 -> -0.84 (key OK). Stated error "subtracts 2 from a negative log ratio": log(1/5)/log4 - 2 = -1.161 - 2 = -3.161, not -2.84. The value -2.84 is actually (log5/log4 - 2) - 2, i.e. the shift applied twice
- **Q26 · MAJOR** — Feedback on x = -1.84 names two errors, worth -1.34 and -2.84, neither equal to -1.84
  <br>_Verified:_ "10 divided by 2 twice": log2.5/log4 - 2 = -1.3390 -> -1.34; "shift applied twice": log5/log4 - 4 = -2.8390 -> -2.84 (that is the other distractor). -1.84 = log5/log4 - 3, which no stated error produces
- **Q30 · MAJOR** — Feedback on "moved up by 3 units" states the key verbatim
  <br>_Verified:_ Feedback: "the product law gives log 3 + log x, and log 3 is about 0.477" — the key option is "the same curve moved up by log 3, about 0.477", so the answer is handed over; log10(3) = 0.47712
- **Q35 · MAJOR** — Feedback on k = -1.129 names an error that evaluates to -2.710
  <br>_Verified:_ Correct: k = log12/(log2 - log3) = -6.12853 -> -6.129 (key OK). Stated error "constant side came to log 3 rather than log 12": log3/(log2-log3) = 0.47712/(-0.17609) = -2.7095, not -1.129
- **Q35 · MAJOR** — Feedback on k = -0.129 names an error that evaluates to +0.090
  <br>_Verified:_ Stated error "divides log 12 by 12": log12/12 = 1.07918/12 = 0.08993 (positive, magnitude 0.09), not -0.129
- **Q36 · MAJOR** — Feedback on x = 1.56 names an error that evaluates to 1.26 (or -4.82)
  <br>_Verified:_ Correct: x = log4/(log3+log4) = 0.55789 -> 0.56 (key OK). Leaving x log 4 on the right and dropping it: log4/log3 = 1.2619; keeping it with a minus: log4/(log3-log4) = -4.8188. Neither is 1.56 (1.56 = log3 + log12, unrelated to the stated slip)
- **Q37 · MAJOR** — Feedback on "x = 10 and x = -13" names an error whose roots are 0.303 and -3.303
  <br>_Verified:_ Correct: x(x+3) = 10^1 => x^2+3x-10 = 0 => x = 2, -5, key x = 2 OK. Stated error "the 1 on the right becomes 10 inside ... not on top of it" means solving x^2+3x = 1, whose roots are (-3 +/- sqrt13)/2 = 0.3028 and -3.3028; x = 10 and x = -13 (i.e. x^2+3x-130 = 0) come from nothing described
- **Q39 · MAJOR** — Feedback on x = 4.65 names an error that evaluates to 8.28
  <br>_Verified:_ Correct: x = 7/log4 = 11.6267 -> 11.63 (key OK). Stated error "divides 7 by log 7": 7/0.845098 = 8.2831, not 4.65; no plausible slip yields 4.65
- **Q39 · MINOR** — misconception_tag sub-log-applications does not fit; the item is a straight exponent/log equation solve with the power law
  <br>_Verified:_ Prompt "Solve log 4^x = 7" involves no application or graph context; it matches sub-log-equations (or sub-log-laws) as used elsewhere in the bank
- **Q40 · MINOR** — misconception_tag sub-log-applications does not fit; the item is pure log-law manipulation
  <br>_Verified:_ Prompt asks to simplify log(x^2+2x-15) - log(x^2-7x+12) = log((x+5)(x-3)/((x-3)(x-4))) = log((x+5)/(x-4)); this is the quotient law, i.e. sub-log-laws

### MHF4U — Trig in Radians

- **Q11 · MAJOR** — Option "40°" is fed back as "the 4 in the numerator was dropped", but dropping the 4 does not give 40.
  <br>_Verified:_ 4π/9 x 180/π = 720/9 = 80 (key, correct); dropping the 4 gives π/9 x 180/π = 20, not 40. No stated single error yields 40 (40 = half of 80).
- **Q11 · MAJOR** — Feedback on the wrong option "160°" states the correct answer outright.
  <br>_Verified:_ Text reads "Cancelling 180 by 9 gives 20, and 4 times 20 is 80" — 80 is exactly the keyed answer (option 3).
- **Q12 · MAJOR** — Option "22.3°" is fed back as "divides by π and stops", but that computation gives 0.4, not 22.3.
  <br>_Verified:_ 1.24/π = 0.3947 (would round to 0.4); 22.3 is actually 1.24 x 18 = 22.32. Key 1.24 x 180/π = 71.0467 -> 71.0 is correct.
- **Q12 · MAJOR** — Option "141.9°" is fed back as "doubles the answer / factor 360/π", but that computation gives 142.1.
  <br>_Verified:_ 1.24 x 360/π = 142.0935 -> 142.1, and 2 x 71.0 = 142.0; neither is 141.9.
- **Q15 · MAJOR** — Feedback on the wrong option "-1" hands over the correct answer.
  <br>_Verified:_ It says "Sine is zero at 3π, so the whole ratio is zero" — tan(3π) = sin(3π)/cos(3π) = 0/(-1) = 0, which is the keyed option 2.
- **Q18 · MAJOR** — Feedback on the wrong option "Maximum 4, minimum -5" confirms the max and then computes the correct min.
  <br>_Verified:_ It says "The maximum is right" (max = 5 - 1 = 4) and "the minimum sits the same distance of 5 BELOW the axis of -1" = -1 - 5 = -6, i.e. the whole keyed answer "Maximum 4, minimum -6".
- **Q19 · MAJOR** — Option "17.9 cm" is fed back as "divides by 4/3 and drops the π", but that computation gives 16.9.
  <br>_Verified:_ 22.5/(4/3) = 16.875 -> 16.9, not 17.9 (17.9 = 22.5 x 2.5/π = 17.905). Key 22.5/(4π/3) = 5.3715 -> 5.4 is correct.
- **Q21 · MAJOR** — Option "1.99°" is fed back as "divides by π and stops", but that computation gives 2.20.
  <br>_Verified:_ 6.91/π = 2.1995 -> 2.2, not 1.99. Key 6.91 x 180/π = 395.9138 -> 395.9 is correct.
- **Q22 · MAJOR** — Feedback on the wrong option "π/9" hands over the correct answer.
  <br>_Verified:_ It says "Cancelling 9 into 180 gives 20", and the keyed answer is exactly π/20 (9 x π/180 = π/20).
- **Q30 · MAJOR** — Feedback on the wrong option "1/2" states the correct answer outright.
  <br>_Verified:_ It says "cot(π/4) is 1, and dividing 1 by a half gives 2" — 2 is the keyed answer (1/[(1/2)(1)] = 2).
- **Q30 · MAJOR** — Option "√2" is fed back as "cot(π/4) is 1, not √2", but believing cot(π/4) = √2 does not produce √2.
  <br>_Verified:_ With cot(π/4) = √2 the expression becomes √2/[(1/2)(1)] = 2√2 = 2.828, not √2 = 1.414; √2 needs the separate error cos(π/3) = 1/√2.
- **Q32 · MAJOR** — Option "12.5 cm" is fed back as "divides by the angle rather than multiplying", but that computation gives 11.5.
  <br>_Verified:_ 30/(5π/6) = 36/π = 11.459 -> 11.5, not 12.5. Key 30 x 5π/6 = 25π = 78.5398 -> 78.5 is correct.
- **Q34 · MAJOR** — Option "2/√2" is fed back as "the 1 still has to be added to the second term", but that omission produces option 2 (√2/2), not 2/√2.
  <br>_Verified:_ cos(π/6)csc(π/3) = (√3/2)(2/√3) = 1; dropping it leaves sin(π/4) = √2/2 = 0.7071 = option 2. Option 1 is 2/√2 = 1.4142, which comes from mis-adding 1 + 1/√2 as (1+1)/√2. Key (√2+1)/√2 = 1.7071 = 1 + √2/2 is correct.
- **Q39 · MAJOR** — Option "1.88 m" is fed back as "multiplies by π and forgets to divide by 5", but that computation gives 3.77.
  <br>_Verified:_ 1.2 x π = 3.7699 -> 3.77, not 1.88 (1.88 = 1.2π/2 = 1.885). Key 1.2 x π/5 = 0.75398 -> 0.75 is correct.
- **Q39 · MAJOR** — Option "6.00 m" is fed back as "divides 1.2 by π/5 rather than multiplying", but that computation gives 1.91.
  <br>_Verified:_ 1.2/(π/5) = 6/π = 1.9099 -> 1.91, not 6.00 (6.00 = 1.2 x 5, i.e. dividing by 1/5 with the π dropped, which is already the error named on option 3).
- **Q20 · MINOR** — Prompt says "as shown" but the record carries no diagram, and the text alone supports a different answer that is itself an option.
  <br>_Verified:_ Text-only reading (brace from cliff top, 15 m cliff, π/3 to the cliff, π/6 to the ground) gives b = 15 tan(π/3) = 15√3 (option 3). The key 15√3/4 requires brace = 15 cos(π/3) = 7.5 then b = 7.5 cos(π/6) = 15√3/4 = 6.495, which only the missing figure can justify.

### MHF4U — Trig Identities and Equations

- **Q1 · CRITICAL** — Option B "sin(π/2 + θ)" is also identically equal to cos θ, so the question has two correct options, and its feedback ("comes to cos θ for some angles, but not in general") is a false mathematical claim.
  <br>_Verified:_ sympy: simplify(sin(pi/2+θ) - cos(θ)) = 0 exactly; e.g. θ=0.7: sin(2.2708)=0.7648=cos(0.7). Keyed option sin(π/2-θ) is also 0.7648, so A and B are the same function.
- **Q24 · CRITICAL** — Options A "-(√6 - √2)/4" and D "(√2 - √6)/4" are the identical number written two ways (both distractors, but the bank presents them as two different answers with two different named mistakes).
  <br>_Verified:_ -(√6-√2)/4 = (√2-√6)/4; sympy: simplify(-(sqrt(6)-sqrt(2))/4 - (sqrt(2)-sqrt(6))/4) = 0, both = -0.2588. Key (√6-√2)/4 = +0.2588 = sin(11π/12) ✓.
- **Q13 · MAJOR** — Feedback for option C ("√3/2") says it is "the first product alone", but the first product sin(π/3)cos(π/6) equals 3/4, not √3/2.
  <br>_Verified:_ sin(π/3)cos(π/6) = (√3/2)(√3/2) = 3/4 = 0.75; √3/2 = 0.8660. The named mistake does not produce this option (√3/2 is just sin(π/3)).
- **Q13 · MAJOR** — Feedback for option D ("1/2") says it is "the second product alone", but the second product cos(π/3)sin(π/6) equals 1/4, not 1/2.
  <br>_Verified:_ cos(π/3)sin(π/6) = (1/2)(1/2) = 1/4 = 0.25 ≠ 1/2. Total 3/4 + 1/4 = 1 = key ✓.
- **Q20 · MAJOR** — Feedback for option D reveals the whole answer: it confirms "2.21 is right" and then says the other solution is "π PLUS that angle" (π + 0.93 = 4.07), i.e. both keyed values.
  <br>_Verified:_ arccos(-0.6) = 2.21430 → 2.21; π + arccos(0.6) = π + 0.92730 = 4.06889 → 4.07, which is exactly the keyed pair.
- **Q37 · MAJOR** — Feedback for option A ("1") hands over the correct answer by stating "a factor of 2 survives", which uniquely identifies the keyed option 2.
  <br>_Verified:_ Verified sin2x(tan x + cot x) = 2 for x = 0.5, 1.1, 2.0 (all give exactly 2.000000); the feedback states the surviving numerical factor outright rather than only naming the error.
- **Q20 · MINOR** — Option B's second value "5.35" is mis-rounded for the mistake its feedback names (using the related acute angle for cos x = +0.6), which gives 5.36.
  <br>_Verified:_ arccos(0.6) = 0.927295 → 0.93 ✓; 2π - 0.927295 = 5.355890, which rounds to 5.36 at two decimals, not 5.35.
- **Q31 · MINOR** — The prompt says "as shown", but the record carries no diagram/image field, so the referenced figure does not exist (the item is still solvable from the text).
  <br>_Verified:_ JSON keys are only prompt/options/correct_index/etc.; no image field on any record. Math checks out: 15 sin(π/12) = 15(√6-√2)/4 = 3.8823 m.

### MHF4U — Rates of Change

- **Q12 · MAJOR** — Option "12" is fed back with a computation that does not produce 12 (no stated single error yields it).
  <br>_Verified:_ f(8) = 42, f(4) = 6, change 36, width 4, so 36/4 = 9 (key, correct); the distractor 12 = 36/3 requires a width of 3, which the feedback never mentions.
- **Q12 · MAJOR** — That same feedback on "12" hands over the entire calculation of the correct answer.
  <br>_Verified:_ It states "f(8) is 42 and f(4) is 6, so the change is 36 over an interval of width 4" — 36/4 = 9 is exactly the keyed option 1.
- **Q16 · MAJOR** — Feedback on the wrong option "1" names the correct answer instead of only the mistake.
  <br>_Verified:_ It ends "leaving the coefficient of x"; for f(x) = 3x + 1 the coefficient of x is 3, which is the keyed option 2 ([3(a+h)+1-(3a+1)]/h = 3h/h = 3).
- **Q18 · MAJOR** — Feedback on the wrong option "Undefined" states the correct answer outright.
  <br>_Verified:_ It says the expression "everywhere else it is exactly 2" — 2 is the keyed option 0 (lim 2x/x = 2); option 3's feedback ("The 2 does not cancel") leans the same way.
- **Q22 · MAJOR** — Option "-2 °C per minute" is fed back as "the fraction is upside down", but inverting the fraction gives -0.2, not -2.
  <br>_Verified:_ Correct: (280-290)/(15-13) = -10/2 = -5 (key, correct). Inverted: (15-13)/(280-290) = 2/(-10) = -0.2. The value -2 is just the negated time interval (13-15), which is not the named error.
- **Q31 · MAJOR** — Feedback on the wrong option "b = 4" hands over the solution equation for the correct answer.
  <br>_Verified:_ It says "Setting up the fraction and simplifying gives b - 2 = 4", which solves in one step to b = 6, the keyed option 3 (rate on [1,b] = (b-1)(b-2)/(b-1) = b-2; b-2 = 4 -> b = 6).
- **Q24 · MINOR** — Option "8.9 °C per minute" does not match its own named error under the rounding used by every other option in the item.
  <br>_Verified:_ Secants are 22.5 and 40/3 = 13.333; halving twice gives 35.8333/4 = 8.958, which rounds to 9.0 at one decimal (the other options round correctly: 13.3, 35.8, and the key 17.9167 -> 17.9).
- **Q24 · MINOR** — Prompt is not answerable on its own: it says "For the same oven" but carries no temperature data.
  <br>_Verified:_ All three readings (205 °C at 8 min, 250 °C at 10 min, 290 °C at 13 min) live only in Q23; served standalone or shuffled, Q24 has no numbers to work from.

### MHF4U — Rational Functions

- **Q16 · MAJOR** — Feedback for the distractor x^3 + 11x^2 + 24x + 45 claims "Three separate products land on the plain x term", which is false.
  <br>_Verified:_ Expanding (x+3)(x^2+8x+15) = x^3+11x^2+39x+45 (sympy); exactly TWO products give a plain x term: x*15 = 15x and 3*8x = 24x, and 15+24 = 39. The option is the expansion with the 15x omitted, so the mistake naming is right but the stated count of three is wrong.
- **Q29 · MAJOR** — Feedback for the distractor "x = 6 or x = -1" names a mistake (common denominator formed, numerators not combined before cross multiplying) that does not produce those roots.
  <br>_Verified:_ Correct: 1/x + 1/(x+3) = 1/2 -> 2(2x+3) = x(x+3) -> x^2 - x - 6 = 0 -> x = 3, -2 (sympy). Roots {6,-1} require x^2 - 5x - 6 = 0, i.e. x(x+3) = 8x+6, which no step of the equation produces. The described error paths give: 2(x+3) = x(x+3) -> {2,-3}; 2x = x(x+3) -> {0,-1}; 2/(x^2+3x) = 1/2 -> {1,-4}; separate cross multiplication -> {2} and {-1}. None yields {6,-1}.
- **Q35 · MAJOR** — Feedback for the distractor 3/(x - 2) describes substituting 3/x for the whole denominator, which produces a different expression.
  <br>_Verified:_ With f(x)=1/(x-2), g(x)=3/x: correct (f o g)(x) = 1/((3/x)-2) = x/(3-2x) (sympy: -x/(2x-3)). Substituting 3/x for the WHOLE denominator (x-2) gives 1/(3/x) = x/3, not 3/(x-2). The option 3/(x-2) = 3*f(x) comes from dropping g's numerator 3 onto f's top and never replacing x at all; the feedback names the wrong location for the substitution.
- **Q36 · MAJOR** — Feedback for the distractor g(x) = 6x - 6 says the division by 2 was applied only to the constant, but that mistake gives 6x - 3.
  <br>_Verified:_ 2g(x)+5 = 6x-1 -> 2g(x) = 6x-6 -> g(x) = 3x-3 (sympy). Dividing only the constant by 2: 6x - 6/2 = 6x - 3. The option 6x - 6 is the un-divided 2g(x), i.e. the division by 2 was skipped entirely, which is a different error from the one named.
- **Q36 · MAJOR** — Feedback for the distractor g(x) = 12x + 9 says f was applied to 6x - 1, but f(6x - 1) = 12x + 3.
  <br>_Verified:_ f(6x-1) = 2(6x-1)+5 = 12x - 2 + 5 = 12x + 3 (sympy expand), not 12x + 9. No stated or evident single error produces 12x + 9, so the named mistake does not generate this option.


## Grade 12 — MCV4U

### MCV4U — Derivative Rules

- **Q16 · MAJOR** — Option 1 feedback blames the wrong-order subtraction, but that mistake does not produce (-x^2 + 6x)/(x+3)^2.
  <br>_Verified:_ Correct: [2x(x+3) - x^2]/(x+3)^2 = (x^2+6x)/(x+3)^2 (option 3, key OK). Reversing the numerator gives x^2*1 - 2x(x+3) = -x^2 - 6x, i.e. (-x^2 - 6x)/(x+3)^2, not the -x^2 + 6x shown; the option's +6x sign cannot arise from swapping the order.
- **Q17 · MAJOR** — Option 1 feedback names only "the +1 was dropped from inside the root", but that single slip does not give 1/(2sqrt(3x)).
  <br>_Verified:_ Correct: d/dx sqrt(3x+1) = 3/(2sqrt(3x+1)) (option 2, key OK). Dropping the +1 only: d/dx sqrt(3x) = 3/(2sqrt(3x)), coefficient 3, not 1. Option 1 also requires forgetting the inner derivative - which is precisely the mistake already assigned to option 3.
- **Q19 · MAJOR** — Option 2 feedback says the VELOCITY was factored as t times something, but t = 0 and t = 3 cannot come from any factoring of the velocity.
  <br>_Verified:_ v(t) = 3t^2 - 12t + 9 = 3(t-1)(t-3), zeros t = 1, 3 (option 1, key OK). v has no factor of t (v(0) = 9 != 0), so "t times something" is impossible; {0, 3} are the roots of the POSITION, s(t) = t^3-6t^2+9t = t(t-3)^2. The feedback names the wrong function.
- **Q20 · MAJOR** — Option 3 feedback claims y = 6x + 6 comes from a sign slip when the point was substituted, but that substitution yields y = 6x + 12.
  <br>_Verified:_ f'(x) = 12x^2 + 6x, f'(-1) = 6; f(-1) = -4 + 3 - 5 = -6, so tangent is y = 6x (option 1, key OK). Using the sign-flipped y-value: 6 = 6(-1) + b gives b = 12, i.e. y = 6x + 12. To land on y = 6x + 6 the student must ALSO use the y-value directly as the intercept, which is the mistake already assigned to option 2 (y = 6x - 6).
- **Q32 · MAJOR** — Option 0 feedback hands over the correct answer by stating the collected bracket explicitly.
  <br>_Verified:_ y' = 2(x+1)(x-3)^3 + 3(x+1)^2(x-3)^2 = (x+1)(x-3)^2(5x-3), which is option 2, the key. Option 0's feedback says "Collecting 2(x take away 3) with 3(x plus 1) gives 5x take away 3" - the exact final factor that distinguishes the correct option from option 0's (5x+3).
- **Q29 · MINOR** — Prompt says "The graph shows the position s(t)" but the record contains no graph, image or asset field, so the question is unanswerable as stored.
  <br>_Verified:_ Record keys are only course_code, unit, sort_order, difficulty, grade, unit_order, prompt, options, correct_index, misconception_tag - no figure. The four feedback strings are mutually consistent with a curve having a maximum at t = 2 and an inflection at t = 4 (so 2 < t < 4 has v < 0, a < 0 = speeding up, key OK), but nothing in the item supplies that graph.

### MCV4U — Curve Sketching

- **Q10 · CRITICAL** — Options 2 and 3 are the same expression written two ways, so two distractors are mathematically identical.
  <br>_Verified:_ (200 - 2x)/2 simplifies to 100 - x exactly (sympy: simplify((200-2x)/2 - (100-x)) = 0); both are wrong, but they are one answer offered twice, and each carries a different "named mistake" feedback for the same value. Correct third side = 200 - 2x (key, index 0) is right.
- **Q36 · MAJOR** — Option 0's feedback names a mistake ("added as if the second term were 3 rather than 3/x") that does not produce the stated value 5.20.
  <br>_Verified:_ Critical number x = sqrt(3) = 1.7320508. The described mistake gives sqrt(3) + 3 = 4.7320508 -> (1.73, 4.73), not 5.20. The option value 5.20 = 3*sqrt(3) = 5.1961524, i.e. 3 x rather than x + 3. Correct answer (1.73, 3.46) since sqrt(3) + 3/sqrt(3) = 2*sqrt(3) = 3.4641016 (key, index 1, verified).
- **Q36 · MAJOR** — The same option-0 feedback hands over the correct answer with a gratuitous extra sentence.
  <br>_Verified:_ "At that x they happen to be equal" tells the student both terms equal 1.73 at the critical point, so the y-value is 2 x 1.73 = 3.46 - exactly option 1, the key. Rebutting option 0 only requires stating that the second term is 3/x, not 3; the equality remark is not needed and gives the number away.
- **Q8 · MINOR** — Prompt refers to a graph with five marked points, but the record contains no figure and no textual description of the graph, so the item cannot be answered from what is stored.
  <br>_Verified:_ Record keys are prompt/options/feedback/correct_index/tags only - no image or graph-description field (checked all 40 records: keys = course_code, unit, sort_order, difficulty, grade, unit_order, prompt, options, correct_index, misconception_tag). Options name points A, C, E, D of five unnamed points; nothing in the text fixes which is the absolute maximum. (Contrast Q37, which describes its graph fully in words and is self-contained.)
- **Q18 · MINOR** — Prompt refers to the graph of f prime crossing the axis at p and q with no figure supplied, and the text never states p < q or the shape of the curve, so which crossing gives the local maximum is not determined by the prompt.
  <br>_Verified:_ Answer "at p" requires f prime to go + to - at p, which follows only from the missing picture (option 1 even refers to "the lowest point of the curve shown", implying an upward-opening shape that the prompt never states). With the text alone, p and q are interchangeable.

### MCV4U — Derivatives of Trig and Exponential Functions

- **Q28 · CRITICAL** — Options 0 and 2 are the same answer written two ways (both are the "multiply the two derivatives" distractor), so the item has a duplicated distractor.
  <br>_Verified:_ Option 0 = 3^x e^(sin x)(ln3 * cos x); option 2 = 3^x ln3 * e^(sin x) cos x; sympy simplify(opt0 - opt2) = 0. Key (option 3) verified: d/dx[3^x e^(sin x)] = 3^x e^(sin x)(ln 3 + cos x).
- **Q29 · CRITICAL** — Options 1 and 2 are algebraically identical expressions, so two distractors are the same answer.
  <br>_Verified:_ Option 1 = -3x^2/(3y^2 - 2y); option 2 = 3x^2/(2y - 3y^2) = -3x^2/(3y^2 - 2y); sympy simplify(opt1 - opt2) = 0. Key (option 3) verified: 2y y' + 3x^2 - 3y^2 y' = 3y' gives y' = 3x^2/(3y^2 - 2y + 3).
- **Q16 · MAJOR** — Option 3's feedback ("the two derivatives were multiplied") does not produce that option; the product of the two derivatives is option 1, not option 3.
  <br>_Verified:_ d(x^2)/dx * d(e^x)/dx = 2x * e^x = 2x e^x (which is the text of option 1). Option 3 reads "2x e^x times e^x" = 2x e^(2x), an expression no single named slip yields. Key verified: d/dx[x^2 e^x] = 2x e^x + x^2 e^x.
- **Q20 · MAJOR** — Option 0's feedback ("the constant was divided by the logarithm") does not produce 3.76 days.
  <br>_Verified:_ k/ln2 = 0.2657/0.693147 = 0.3833 days, not 3.76. The value 3.76 is 1/k = 1/0.2657 = 3.7636 (ln 2 omitted entirely). Key verified: ln2/k = 0.693147/0.2657 = 2.6088 -> 2.61 days.
- **Q20 · MAJOR** — Option 2's feedback ("the 2 was divided by the constant instead of its natural logarithm") does not produce 1.30 days.
  <br>_Verified:_ 2/k = 2/0.2657 = 7.5273, not 1.30. The value 1.3044 is ln2/(2k), i.e. exactly half the correct half-life (and it also coincides with the ratio 6/4.6 = 1.3043 used in Q19).
- **Q29 · MAJOR** — Option 1's feedback ("the 3y on the right-hand side was left out") does not produce option 1; that omission gives the opposite sign.
  <br>_Verified:_ Dropping d/dx(3y): 2y y' + 3x^2 - 3y^2 y' = 0 -> y' = -3x^2/(2y - 3y^2) = +3x^2/(3y^2 - 2y) (sympy). Option 1 is -3x^2/(3y^2 - 2y), which is the omission PLUS a sign flip, i.e. what option 2's feedback describes.
- **Q32 · MAJOR** — Option 0's feedback ("the Pythagorean identity was not used on the numerator") does not produce (1 - cos x)/(1 + cos x)^2, and it also spells out the simplification that gives the key.
  <br>_Verified:_ Not simplifying leaves [cos x(1+cos x) + sin^2 x]/(1+cos x)^2 = (1 + cos x)/(1 + cos x)^2 (sympy), which is the CORRECT answer unsimplified, not option 0; numerically at x = 1, option 0 = 0.1938 while the correct derivative = 0.6492. Key verified: d/dx[sin x/(1+cos x)] = 1/(1 + cos x).

### MCV4U — Geometric Vectors

- **Q38 · CRITICAL** — Options 1 and 3 give the SAME numeric answer (3.0 minutes) to the question asked ("How long does the crossing take?"), differing only in an appended justification clause the prompt never asks about, and option 1 feedback ("The time is right") confirms 3.0 min as the correct value.
  <br>_Verified:_ Crossing time = width / northward speed = 0.600 km / 12 km/h = 0.05 h = 3.0 min exactly; option 1 "3.0 minutes, but the current makes it longer" and option 3 "3.0 minutes, and the current does not change it" carry the identical value 3.0; the other distractors are distinct (0.6/13 h = 2.77 min -> 2.8; 0.6/5 h = 0.12 h = 7.2 min).
- **Q31 · MAJOR** — Option 1 (020 degrees) feedback names the mistake "the turn was made the wrong way", but reversing the rotation actually produces 200 degrees, which is option 3 (whose feedback already names that same error); 020 arises from computing 110 - 90 instead of 90 - 110.
  <br>_Verified:_ Correct: bearing = 90 - 110 = -20 = 340 (key, option 0, verified). Wrong-way rotation: 90 + 110 = 200 = option 3. Option 1 value 020 = 110 - 90 = 20, i.e. the 20-degree offset placed on the wrong side of north / subtraction done in the wrong order, not a reversed rotation from east.
- **Q13 · MINOR** — Prompt is answerable only from a diagram ("three vectors u, v and w drawn on the triangle ABC"), and these grade-12 records carry no figure field, so nothing in the text distinguishes w = u + v from u = v + w or u + v + w = 0.
  <br>_Verified:_ The JSON records for this unit have keys [correct_index, course_code, difficulty, grade, misconception_tag, options, prompt, sort_order, unit, unit_order] - no figure column (figures exist only for the grade-10 MPM2D bank), so the arrow senses the key depends on are never stated.
- **Q39 · MINOR** — Prompt says "with the incline marked" but never states the incline angle, so the required 20 degrees exists only in an absent diagram and the numeric answer is not determinable from the text.
  <br>_Verified:_ Key 47.9 N = 140 sin20 = 47.883; distractors 131.6 = 140 cos20 = 131.557 and 51.0 = 140 tan20 = 50.956 - all three require the 20 degrees that only Q30 states in words; every option value is angle-dependent.

### MCV4U — Algebraic Vectors

- **Q1 · MAJOR** — Option 2 ([5, -4]) feedback hands over the correct answer by confirming the first component and giving the arithmetic that fixes the second
  <br>_Verified:_ Verified PQ = Q-P = (7-2, 1-(-3)) = [5, 4]; feedback says "the first component is right" (5) and "take away negative 3 and you add 3" (1+3 = 4), which yields [5, 4] exactly
- **Q3 · MAJOR** — Option 1 (14) feedback describes a mistake that produces 26, not 14 (and 26 is already option 3)
  <br>_Verified:_ Correct dot = 3*2 + (-4)*5 = 6 - 20 = -14; "losing the sign of the second product" gives 6 + 20 = 26 (option 3); 14 arises only from -6+20 or from taking|-14|
- **Q11 · MAJOR** — Option 0 ([4, 8]) feedback ("scalar applied to the first vector as well") produces [4, 4], not [4, 8]
  <br>_Verified:_ 2[3,-4] + 2[-1,6] = [6,-8] + [-2,12] = [4, 4]; correct answer is [3,-4] + [-2,12] = [1, 8]; no single error yields [4, 8] (its second component 8 is the correct one)
- **Q11 · MAJOR** — Option 2 ([1, -8]) feedback hands over the correct answer: it confirms the first component and states the arithmetic for the second
  <br>_Verified:_ "The first component is right" (1) plus "negative 4 plus 12 is positive" (-4+12 = 8) gives [1, 8], the keyed answer
- **Q15 · MAJOR** — Option 3 (1500 J) feedback describes summing each vector's components and multiplying the totals, which gives 24000, not 1500
  <br>_Verified:_ Work = 300*3 + 700*1 + 500*12 = 900 + 700 + 6000 = 7600 (key OK); (300+700+500)*(3+1+12) = 1500*16 = 24000; 1500 is only the force-component sum
- **Q21 · MAJOR** — Option 0 (k = 27) feedback hands over the correct answer by telling the student to divide 9 by 3
  <br>_Verified:_ "The 9 was multiplied by 3 rather than divided" plus "the second vector is 3 times the first" gives 9/3 = 3 = the keyed answer (2*3 = 6, 3*3 = 9)
- **Q21 · MAJOR** — Option 1 (k = 4.5) feedback ("the two components of the SECOND vector were divided by each other") produces 1.5 or 0.667, not 4.5
  <br>_Verified:_ [6,9]: 9/6 = 1.5, 6/9 = 0.667; 4.5 = 9/2, i.e. the second vector's 9 divided by the FIRST vector's 2, a different error
- **Q22 · MAJOR** — Option 3 ([5.77, 8.66]) feedback names only the tangent error, which produces [5.77, 5.00]; the printed second component is a second, unnamed error
  <br>_Verified:_ 10cos30 = 8.6603, 10sin30 = 5.0000 (key [8.66, 5.00] OK); 10tan30 = 5.7735; the option's 8.66 is 10cos30 placed in the y-slot, not explained by the tangent mistake
- **Q23 · MAJOR** — Option 2 (k = 2) feedback ("the third pair was left out") produces k = 8, not k = 2
  <br>_Verified:_ Correct: 2*4 + k*(-1) + 3*2 = 14 - k = 0 -> k = 14; dropping the third pair: 8 - k = 0 -> k = 8; k = 2 comes from a SIGN error on the third term (8 - k - 6 = 0)
- **Q23 · MAJOR** — Option 3 (k = -2) feedback ("third pair left out and the sign flipped") produces k = -8, not k = -2
  <br>_Verified:_ 8 - k = 0 with sign flip gives k = -8; k = -2 comes from 8 + k - 6 = 0, i.e. sign errors on the middle and third terms
- **Q27 · MAJOR** — Option 1 ([-4, -2, 1]) feedback states the corrected middle component outright, handing over the keyed answer
  <br>_Verified:_ "Zero take away negative 2 is positive 2" gives 2, and the option already carries the correct -4 and 1, so the feedback spells out [-4, 2, 1] = (-3,0,5) - (1,-2,4)
- **Q32 · MAJOR** — Option 1 (45 degrees) feedback states the two cosine values the wrong way round, so it describes the correct value as the error's result
  <br>_Verified:_ u.v = 1,|u|=|v|= sqrt(2), correct cos = 1/2 -> 60 degrees (key OK); dividing by only one sqrt(2) gives cos = 1/sqrt(2) -> 45 degrees, but the feedback says the cosine "ends up at one half rather than at one over root 2"
- **Q14 · MINOR** — Distractors 42.9 and 132.9 are truncated rather than rounded, so the mistakes their feedback names do not actually produce those printed values
  <br>_Verified:_ dot = 36,|u|= sqrt(45) = 6.7082,|v|= sqrt(62) = 7.8740, cos = 0.68155 -> 47.0347 = 47.0 (key OK); arcsin(0.68155) = 42.9652 -> 43.0 not 42.9; arccos(-0.68155) = 132.9652 -> 133.0 not 132.9

### MCV4U — Lines and Planes

- **Q16 · MAJOR** — Feedback on distractor "3x + 4y - 2z - 8 = 0" hands over the correct answer by stating the correct constant outright ("so D must be positive 8"), which uniquely identifies option B.
  <br>_Verified:_ n·P = 3(2)+4(-1)+(-2)(5) = 6-4-10 = -8, so D = +8 and the plane is 3x+4y-2z+8=0 (= the keyed option); the feedback states "D must be positive 8" verbatim.
- **Q24 · MAJOR** — Feedback on "Yes, at t = 6" describes a mistake (x-coordinate divided by the first direction component) that does not produce 6.
  <br>_Verified:_ 7/3 = 2.33..., not 6; t = 6 actually comes from subtracting the start but omitting the division: 7 - 1 = 6. (Correct: 1+3t=7, -2+5t=8, 4-t=2 all give t = 2.)
- **Q27 · MAJOR** — Feedback on "x - 2y + 6z + 13 = 0" hands over the correct answer by stating the correct constant ("so D must be negative 13"), uniquely identifying option B.
  <br>_Verified:_ [2,1,0]x[0,3,1] = [1,-2,6]; [1,-2,6]·(1,0,2) = 1+0+12 = 13, so D = -13, i.e. x-2y+6z-13=0 = the keyed option, which the feedback names.
- **Q31 · MAJOR** — Feedback on the distractor 5.2 describes "the magnitude of the normal was added to the numerator rather than divided into it", which does not produce 5.2.
  <br>_Verified:_ Adding: 6+5 = 11, not 5.2. 5.2 = 26/5 =|3(4)+4(1)+10|/5, i.e. a sign error on the constant term. (Correct:|12+4-10|/5 = 6/5 = 1.2.)
- **Q34 · MAJOR** — Feedback on "The xz-plane, y = 0" reveals the correct answer by asserting the plane's defining equation ("nothing ever moves off z equal to zero"), which is the keyed option "The xy-plane, z = 0".
  <br>_Verified:_ span{[1,1,0],[1,-1,0]} has normal [1,1,0]x[1,-1,0] = [0,0,-2], i.e. the plane z = 0; the distractor feedback states z = 0 in words.
- **Q35 · MAJOR** — Feedback on the distractor 1 describes "the components of the normal were added to make the divisor", which does not produce 1.
  <br>_Verified:_ 2+(-1)+2 = 3 gives 9/3 = 3 (the correct answer);|2|+|1|+|2|= 5 gives 1.8. The value 1 comes from dividing by the sum of squares without the square root: 9/(4+1+4) = 1.
- **Q35 · MAJOR** — Feedback on the distractor 4.5 reveals the answer by stating the divisor explicitly ("the magnitude of the normal, which here is 3"); with the constant 9 visible in the equation this gives 9/3 = 3, the keyed option.
  <br>_Verified:_ |−9|/|[2,-1,2]|= 9/3 = 3, and "3" is exactly the number printed in the distractor's feedback and is the text of the correct option.
- **Q1 · MINOR** — The item depends on a diagram ("The diagram shows a line L, the origin O, and four vectors") but the record contains no diagram/image field, so the item is unanswerable and unverifiable as stored.
  <br>_Verified:_ Record keys are only: course_code, unit, sort_order, difficulty, grade, unit_order, prompt, options, correct_index, misconception_tag - no figure reference of any kind; options p, q, r, s are undefined without it.
- **Q1 · MINOR** — Distractors p and q carry the same named mistake (a position vector from the origin to a point on the line), breaking the one-distinct-mistake-per-distractor design; p's feedback is also self-contradictory.
  <br>_Verified:_ p: "reaches a point ON the line from the origin, which makes it a position vector"; q: "reaches a point on the line as well, but from the origin" - identical error. p then adds "It runs across the line", contradicting its own claim that p ends on the line.
- **Q33 · MINOR** — misconception_tag is "sub-planes-vector" but the question asks for, and is answered by, the scalar equation of a plane; the bank has a dedicated "sub-planes-scalar" tag used for the identical task in Q16 and Q27.
  <br>_Verified:_ Prompt: "What is the scalar equation of the plane through (1,0,0), (0,1,0) and (0,0,1)?"; answer x+y+z-1 = 0 (each point substitutes to 0) is a scalar equation.


## Grade 12 — MDM4U

### MDM4U — Displays of Data

- **Q18 · CRITICAL** — Class A: the keyed answer 0.9654 is not r squared for the r given in the prompt; no option is correct to four decimal places
  <br>_Verified:_ 0.9825^2 = 0.96530625, which to four decimal places is 0.9653, not 0.9654. (0.9654 corresponds to r = 0.982548, i.e. the prompt rounded r to 0.9825 but kept r-squared from the unrounded value. Distractors check out otherwise: 2 x 0.9825 = 1.9650 exactly.)
- **Q28 · CRITICAL** — Class A: the keyed prediction 73.91 does not follow from the line given in the prompt; no option is correct to two decimal places
  <br>_Verified:_ y = -0.864 + 1.150(65) = -0.864 + 74.75 = 73.886 -> 73.89, not 73.91. (73.91 needs intercept -0.865 and slope 1.15038; the prompt's rounded coefficients were not used to regenerate the options.)
- **Q1 · MAJOR** — Class D: the feedback on "A population is a subset of the sample" states the key outright
  <br>_Verified:_ Feedback reads "It is the other way round. You take the smaller group OUT of the larger one", which is exactly key option 0, "A sample is a subset of the population"; naming the reversal mistake did not require restating the correct relation.
- **Q9 · MAJOR** — Class D: the feedback on "understates the differences" hands over the key
  <br>_Verified:_ Feedback: "It goes the other way ... what is left looks more different than it is" - that is key option 3, "It exaggerates the differences between the bars", stated in words.
- **Q10 · MAJOR** — Class D: the feedback on "The bars are different widths" points the student straight at the key option
  <br>_Verified:_ Feedback: "The widths are equal. Look at where the vertical axis begins instead." The key (option 3) is the only option about where the vertical axis begins, so the answer is identified with no reasoning left to do.
- **Q14 · MAJOR** — Class D: the feedback on "Skewed left" derives the key for the student
  <br>_Verified:_ Feedback: "The name follows the TAIL, not the bulk of the data. The bulk sits on the left here, but the tail points right." Tail right + name follows the tail = "Skewed right", which is key option 2.
- **Q17 · MAJOR** — Class D: three distractor feedbacks supply the word "curve", the one discriminator the prompt deliberately withholds
  <br>_Verified:_ Prompt says only "a clear pattern"; feedback on option 1 says "A symmetric curve genuinely has the flat line as its best straight fit", option 2 says "adding a thousand more points along the same curve", option 3 says "it is the measuring tool that misses it, not the relationship that is absent" - together these are key option 0, "r only measures how well a STRAIGHT line fits, and this pattern is curved".
- **Q18 · MAJOR** — Class C: the 0.9913 distractor's feedback ("the square ROOT was taken") names a mistake that does not produce 0.9913
  <br>_Verified:_ sqrt(0.9825) = 0.99121138 -> 0.9912, and even sqrt(0.982548) = 0.991236 -> 0.9912. No rounding of the square root gives 0.9913.
- **Q20 · MAJOR** — Class D: the feedback on "Nothing, since both dimensions were scaled by the same factor" states the key mechanism
  <br>_Verified:_ Feedback: "The eye reads the area, and the area picks up the factor twice" - i.e. 2 x 2 = 4, which is key option 3, "The area becomes four times as large".
- **Q21 · MAJOR** — Class D: the feedback on the swapped-definition distractor restates the key
  <br>_Verified:_ Feedback on option 3: "The two have been swapped. Describing stops at the data in hand; inferring reaches past it", and option 0's feedback adds "Inference is the step beyond the data" - both spell out key option 2, "Inferential statistics draw conclusions about a population from a sample".
- **Q23 · MAJOR** — Class D: the feedback on "From shortest to tallest" gives the key
  <br>_Verified:_ Feedback: "The order is reversed. Putting the biggest category first is what makes the important ones jump out immediately" - that is key option 1, "From tallest to shortest".
- **Q26 · MAJOR** — Class D: the feedback on "It is skewed left" derives the key from the picture for the student
  <br>_Verified:_ Feedback: "The name follows the long tail, and the long whisker IS the long tail." Since the prompt states the right-hand whisker is the long one, this yields key option 1, "It is skewed right".
- **Q28 · MAJOR** — Class C: two distractors do not equal the values their feedback describes, by the same rounding drift
  <br>_Verified:_ "Intercept left out" = 1.150 x 65 = 74.75, but the option reads 74.77; "intercept added instead of subtracted" = 0.864 + 74.75 = 75.614 -> 75.61, but the option reads 75.64. (Only the fourth option is self-consistent: 65 - 0.864 = 64.136 -> 64.14.)
- **Q36 · MAJOR** — Class D: the feedback on "No, a coefficient of zero rules out any relationship" states the key's reason verbatim
  <br>_Verified:_ Feedback: "It rules out a straight-line one. Plenty of exact relationships are not straight lines" - key option 1 is "Yes, because a non-linear relationship can give a correlation of zero". Option 3's feedback repeats it ("a large sample lying on a symmetric curve still gives a coefficient near zero").
- **Q39 · MAJOR** — Class D: the feedback on "The vertical axis has been truncated" reads out the key almost word for word
  <br>_Verified:_ Feedback: "Here the vertical axis is untouched and the horizontal one has been squeezed"; key option 0 is "The horizontal scale has been compressed to steepen the line".
- **Q8 · MINOR** — Class E: misconception_tag sub-regression is inconsistent with the rest of the bank for an item about what r measures
  <br>_Verified:_ Q16, Q35 and Q36 are all "what does r mean" items tagged sub-scatter-correlation; Q8 ("What does the correlation coefficient r measure?") is the same content but tagged sub-regression, while the genuinely regression-tagged items (Q18, Q19, Q28, Q29, Q37, Q38) concern r-squared, residuals and the line of best fit.
- **Q10 · MINOR** — Class E: the prompt refers to a chart that is not supplied anywhere in the record (no image or data field), so none of the four claims can be checked by the student
  <br>_Verified:_ Record keys are prompt/options/correct_index/misconception_tag only; the key asserts "the vertical axis starts at 85", a fact present nowhere in the item, and the rival claims (bar widths, category order) are equally unverifiable.
- **Q24 · MINOR** — Class E: the prompt asks for "an advantage" without asking for the best or perceptual one, and the feedback itself concedes that distractor 1 is a true advantage
  <br>_Verified:_ Option 1 is "A bar graph can show more categories at once", whose feedback begins "It usually can, but that is a matter of room rather than accuracy"; a true statement that answers the question as literally posed competes with the key. Wording such as "main advantage when comparing category sizes" would remove the overlap.

### MDM4U — Collecting Data

- **Q14 · MAJOR** — Distractor "5" is explained by a mistake that does not produce it: the feedback says dividing sample size by population, but 75/1500 = 0.05, and the feedback itself concedes that route "gives a fraction below 1".
  <br>_Verified:_ 1500/75 = 20 (key, correct); 75 = sample size (fb0 ok); 1500-75 = 1425 (fb1 ok); no stated error yields 5.
- **Q27 · MAJOR** — Distractor feedback hands over the correct answer: option 1's feedback states "A Likert scale rates each item independently, so two items can score the same" (and option 3 adds "A Likert scale is closed, with the levels laid out in advance"), which is the content of correct option 0.
  <br>_Verified:_ Correct option 0 = "Rating one or more items on a common scale"; a student reading fb1/fb3 can construct that answer without knowing it.
- **Q29 · MAJOR** — Two distractor feedbacks restate the correct option's justification: fb0 "every student in the other two periods had a chance of exactly zero" and fb2 "two thirds of the school was never eligible" paraphrase correct option 1 ("students with a different lunch period had no chance of being chosen").
  <br>_Verified:_ Correct option 1 adds only the label "sampling bias"; its reasoning is given away twice.
- **Q30 · MAJOR** — Option 2's feedback spells out the correct answer: "That is single blind. Making it double means hiding it from the assessors as well" = correct option 1 (neither subjects nor assessors know).
  <br>_Verified:_ Option 2 already says subjects do not know; the feedback supplies the missing half verbatim.
- **Q35 · MAJOR** — Option 0's feedback names the correct answer: "A ranking forces them apart" identifies the prompt's 1-to-4 ordering as a ranking, which is correct option 3 ("A ranking question").
  <br>_Verified:_ Correct option 3 text is just "A ranking question"; fb0 supplies the term applied to the prompt.
- **Q40 · MAJOR** — Option 3's feedback hands over the correct answer outright: "The equivalent inside an experiment is blocking, which is what this is."
  <br>_Verified:_ Correct option 0 is "A blocked design"; the feedback names it and asserts it applies here.
- **Q13 · MINOR** — Option set is incoherent read in order: options 0 and 1 are "Both of them" / "Neither of them" with no antecedent, since the two study types are only named later in options 2 and 3.
  <br>_Verified:_ Prompt says "Which type of study follows the SAME subjects over a period of time?" and never introduces a pair; key (longitudinal) is still uniquely correct.
- **Q37 · MINOR** — Prompt is not self-contained: it opens with "A revised plan" without stating the original plan, option 1 ("students in only one lunch period") only makes sense as a carry-over from Q29, and the population 1500 appears only inside feedback.
  <br>_Verified:_ Q29 supplies the 1500-student cafeteria scenario; read alone, Q37 gives no baseline against which "does this NOT fix" is judged.

### MDM4U — Normal Distributions

- **Q12 · MAJOR** — Distractor "62" is not produced by the mistake its feedback names (applying the weights to the wrong scores).
  <br>_Verified:_ Correct: 0.3(80)+0.7(60)=66 (key, option 2, correct). Swapping the weights gives 0.7(80)+0.3(60)=56+18=74, not 62; no standard slip yields 62 (62 would need weights 10/90).
- **Q13 · MAJOR** — Distractor "71.9" is labelled "That is the mean", but the mean of the 16 grades is not 71.9.
  <br>_Verified:_ sum(43,48,56,59,62,64,67,71,72,75,75,78,81,84,88,90)=1113, mean=1113/16=69.5625, not 71.9. Median = (71+72)/2 = 71.5 (key correct); range 90-43=47 and 71/72 distractors all check out.
- **Q16 · MAJOR** — Feedback on "Mean 178 and standard deviation 14.74" states outright that the standard deviation is right, which uniquely hands over the correct option.
  <br>_Verified:_ Only options 0 and 3 carry sd 14.74; telling the student 14.74 is correct and 178 is not leaves option 0 (mean 165, sd 14.74) as the only possibility. Values themselves verified: mean 1155/7=165, pop sd 14.7358->14.74, sample sd 15.9164->15.92, pop variance 217.143.
- **Q24 · MAJOR** — Distractor "18" is given the feedback for adding the change to the old mean in full, but that mistake produces 30, not 18.
  <br>_Verified:_ Old total = 9x12 = 108; 12+18 = 30 (which is the *other* distractor). 18 is just the raw change 38-20. Key 14 verified: (108-20+38)/9 = 126/9 = 14.
- **Q24 · MAJOR** — Distractor "30" is given the feedback "the average of the old value and the new one", but that average is 29, not 30.
  <br>_Verified:_ (20+38)/2 = 29. The value 30 is instead 12+18 (old mean plus the full change), i.e. the two distractor feedbacks are mismatched to their values.
- **Q30 · MAJOR** — Distractor "15.410 to 15.790" is not what "the sample size was used instead of its square root" produces.
  <br>_Verified:_ That mistake gives 15.6 +/- 1.96(1.8/90) = 15.6 +/- 0.0392 = 15.561 to 15.639. The stated interval is 15.6 +/- 1.8/sqrt(90) = 15.6 +/- 0.18974, i.e. the standard error used with no critical value. Key verified: 15.6 +/- 1.96(0.189737) = 15.228 to 15.972.
- **Q37 · MAJOR** — Distractor "0.5040 to 0.5560" does not match its feedback's stated use of the critical value 1.960.
  <br>_Verified:_ 0.53 +/- 1.96*sqrt(0.53*0.47/1500) = 0.53 +/- 0.025258 = 0.5047 to 0.5553, not 0.5040/0.5560 (margin stated is 0.0260, requiring z = 2.017). Key verified: 0.53 +/- 1.645(0.0128867) = 0.5088 to 0.5512.
- **Q37 · MAJOR** — Distractor "0.5288 to 0.5312" does not match its feedback's stated mistake of using n instead of sqrt(n).
  <br>_Verified:_ That mistake gives 0.53 +/- 1.645*sqrt(0.53*0.47)/1500 = 0.53 +/- 0.000547 = 0.5295 to 0.5305 (and the same slip in Q38 does produce its option: 0.3511 +/- 1.645*sqrt(pq)/188 = 0.3469 to 0.3552). The stated margin here is 0.0012, which no such formula yields.
- **Q25 · MINOR** — The prompt refers to a diagram ("The diagram shows two distributions on the same axis") that is not present in the record; the item is only answerable because the option text supplies "B ... is wider".
  <br>_Verified:_ No image/figure field exists in the JSON; curves A and B are never described in the prompt, so the labels A and B are undefined until read off the options.

### MDM4U — Probability

- **Q13 · MAJOR** — Option [2] ("1/3") feedback states the correct answer in words instead of naming a mistake, and option [0] also spells out the denominator, so the answer is handed over twice.
  <br>_Verified:_ Odds 3:7 -> P = 3/(3+7) = 3/10 = option [3]; feedback on [2] reads "Three successes out of ten trials is what these odds describe" (= 3/10 verbatim), and [0] reads "compares successes to the total, which is 3 plus 7"; neither identifies any error that yields 1/3.
- **Q39 · MAJOR** — Option [1] ("924") feedback misnames the mistake: dividing out only the six identical houses does not give 924.
  <br>_Verified:_ Correct 12!/(6!4!2!) = 479001600/34560 = 13860 (key [3], verified). Dividing out only the 6 gives 12!/6! = 665280, not 924; 924 = C(12,6) = 12!/(6!6!), i.e. the error of placing only the one-storey houses and treating the other six as identical - the opposite of "the four and the two still need dividing out".
- **Q14 · MINOR** — The prompt refers to a shaded Venn-diagram region but the record carries no image (keys are only prompt/options/correct_index/...), so the shaded region is undetermined from the text alone.
  <br>_Verified:_ Prompt: "two sets A and B inside a universe S, with one region shaded"; A-not-B, A-and-B, union and neither are all consistent with that sentence, so [0] is only identifiable from the feedback text, not the stem.
- **Q16 · MINOR** — Distractor [0] (8/11) is not obtainable from the numbers this prompt supplies; n(instrument) = 110 first appears in Q17.
  <br>_Verified:_ Prompt gives 200 total, 120 sport, 80 sport-and-instrument -> P(instrument|sport) = 80/120 = 2/3 (key [1], correct). The "reverse conditional" named in [0]'s feedback is 80/110 = 8/11, which needs 110, a figure absent from this stem.
- **Q33 · MINOR** — Distractor [2] ("complementary") is literally a true answer to "when does the subtracted term vanish?", as its own feedback concedes, so the item relies on a best-answer convention.
  <br>_Verified:_ For complementary A, B: P(A and B) = 0, so P(A or B) = P(A) + P(B) - 0; the term vanishes exactly as in the keyed option [0]. Complementary is sufficient but not necessary (mutually exclusive is the full characterisation), which is why [0] remains the intended key.

### MDM4U — Probability Distributions

- **Q2 · MAJOR** — Feedback for option B ("100") hands over the correct answer by stating outright "Written as decimals the total is 1", and "1" is the keyed option.
  <br>_Verified:_ Key check: probabilities sum to 1 ✓ (option D). The feedback names the mistake (percent vs decimal) but then states the keyed value verbatim, so the item is answerable from the distractor's feedback alone.
- **Q20 · MAJOR** — Feedback for option D ("1, 5, 10, 5, 1") reconstructs the correct option verbatim by saying "A 10 has been dropped" plus "every row is symmetric and has one more entry than the exponent".
  <br>_Verified:_ Restoring the dropped 10 in 1,5,10,5,1 gives 1,5,10,10,5,1, which is exactly keyed option B. Row 5 = C(5,k) = 1,5,10,10,5,1 ✓; row 6 = 1,6,15,20,15,6,1 ✓ (option A); row 4 = 1,4,6,4,1 ✓ (option C).
- **Q36 · MAJOR** — Feedback for option C ("1 minus the probability of 5 or fewer") reveals the answer by stating "The cut has to fall between 4 and 5", which uniquely identifies the keyed option.
  <br>_Verified:_ P(X ≥ 5) = 1 - P(X ≤ 4) ✓ = keyed option D; with n=10, p=0.25 the value is 1 - 0.9219 = 0.0781, and 1 - P(X≤5) = 0.0197 (option C, wrong). The feedback states the cut-off location outright rather than only naming the off-by-one error.
- **Q21 · MINOR** — The prompt refers to "The diagram shows two geometric distributions" and to curves labelled A and B, but the record carries no diagram or image field, so the referenced figure does not exist (the item is still answerable because each option embeds its own reasoning).
  <br>_Verified:_ JSON keys on every record are only prompt/options/correct_index/misconception_tag/difficulty/sort_order/etc.; no image or asset field anywhere in the file. Key is defensible: for a geometric distribution P(X=k) = (1-p)^(k-1) p, larger p means faster decay, so the collapsing-bars distribution (B) has the larger p.

---

## What I would do about it

In this order:

1. **MPM2D Factoring Q21** — one option's text. Live, and every attempt at it so far has
   been marked wrong. Safe to ship on its own.
2. **MDM4U Displays Q18 and Q28** — regenerate both items from the rounded coefficients the
   prompts print. Not live.
3. **MHF4U Trig Identities Q1** — replace the second correct option. Not live.
4. **The other 13 duplicate-option items** — replace one member of each pair with a
   distractor that comes from a real, different mistake. Five of these are live, so text
   edits only, no reordering.
5. **The 247 feedback lines.** This is the real work and the real value. Each one is a
   small rewrite: either name the mistake that actually produces that number, or stop
   printing the answer. Best done unit by unit with the same recomputation loop that found
   them, so the replacement is checked as it is written.
6. **Two new gate checks**, so none of this can come back: a longest-option-tell check
   (fail above ~14/40), and a distractor-uniqueness check that evaluates every option and
   fails on ties.
7. **A notation rule in `AUTHORING_GUIDE.md`**, then bring MHF4U unit 7 into line with its
   own course.

Nothing above touches the security model, and nothing requires reordering an option on a
live unit.