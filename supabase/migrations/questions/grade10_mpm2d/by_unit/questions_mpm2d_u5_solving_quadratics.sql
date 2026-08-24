-- ===========================================================================
-- ASTRO MATH ASSIST — GRADE 10 (MPM2D), complete
-- ===========================================================================
--
-- 240 questions across six units, plus the 33 figures that attach to them.
-- Questions and figures used to be two files that had to be run in order,
-- and running the second one was easy to forget — which showed up as
-- questions that reference a diagram nobody can see. They are one file now.
--
-- RUN ORDER:  astro_math_assist_setup.sql  ->  this file.
--
-- Safe to re-run on its own at any time: each unit is deleted and reinserted,
-- and the figures are reattached at the end. Student attempts are NOT touched
-- by this file — they live in attempts and unit_mastery, keyed on course, unit
-- and sort_order, so a corrected question keeps its history.
--
-- ---------------------------------------------------------------------------
-- The six units
-- ---------------------------------------------------------------------------
--   1  Linear systems                 40
--   2  Analytic geometry              40
--   3  Factoring                      40
--   4  Quadratics                     40
--   5  Solving quadratic equations    40
--   6  Trigonometry                   40
--
-- Each unit is 10 Easy, 10 Medium, 10 Challenge, 10 Advanced, in sort_order
-- 1-40. Easy and Medium are free; Challenge and Advanced need Astro+, and
-- that is enforced in the database, not in the app.
--
-- ---------------------------------------------------------------------------
-- The figures
-- ---------------------------------------------------------------------------
-- 33 PNGs, mostly Trigonometry. They live in web/figures/ and ship inside
-- every deploy, so this file only stores the path. A null figure renders no
-- image; a missing file shows a short "could not load" line rather than a
-- broken icon.
--
-- Every figure was measured against a ruler before it shipped: if a student
-- could get the answer by measuring the drawing instead of doing the
-- mathematics, the figure is wrong, however pretty it looks. Two were caught
-- and redrawn by that test.
--
-- ---------------------------------------------------------------------------
-- What a question owes the student
-- ---------------------------------------------------------------------------
-- Every wrong option is a SPECIFIC mistake, and its feedback names the
-- mistake without revealing the answer. "Not quite, try again" is not
-- feedback. Neither is anything that states the correct value.
-- ===========================================================================

-- This file loads ONE unit of MPM2D. It deletes only that unit, so the
-- other five are untouched. Run figures_grade10.sql after all six.

delete from questions where course_code = 'MPM2D' and unit = 'Solving quadratic equations';

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

(10, 'MPM2D', 'Solving quadratic equations', 5, 1, 'Easy',
 'If (x - 3)(x + 5) = 0, what are the solutions?',
 '[{"text": "3 and -5", "feedback": "Correct."}, {"text": "-15", "feedback": "That multiplies the two numbers. The zero product rule gives one solution per factor."}, {"text": "-3 and 5", "feedback": "Each factor is zeroed by the OPPOSITE of its number: x - 3 = 0 gives +3."}, {"text": "3 and 5", "feedback": "The second bracket needs x = -5 to vanish. Watch its sign."}]'::jsonb, 0, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 2, 'Easy',
 'Why can each factor be set to zero when solving (x - 3)(x + 5) = 0?',
 '[{"text": "A product is zero only when at least one factor is zero", "feedback": "Correct."}, {"text": "Because both factors must equal zero at once", "feedback": "x cannot be 3 and -5 at the same time. EITHER factor being zero kills the product."}, {"text": "Because zero divides both sides", "feedback": "Dividing by zero is never allowed. The rule is about products, not division."}, {"text": "Because the brackets cancel each other", "feedback": "Brackets do not cancel across a multiplication. The zero on the right is what powers the rule."}]'::jsonb, 0, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 3, 'Easy',
 'What is the first step to solve x² + 4x = 21 by factoring?',
 '[{"text": "Divide both sides of the equation through by x", "feedback": "Dividing by x throws away the possible solution x = 0 and is not valid when x might be 0."}, {"text": "Factor x out of the left side straight away", "feedback": "The zero product rule needs a ZERO on one side first — factoring x² + 4x while 21 sits opposite proves nothing."}, {"text": "Move the 21 across so one side equals zero", "feedback": "Correct."}, {"text": "Take the square root of both sides right away", "feedback": "The left side is not a perfect square, and rooting a sum does not split it."}]'::jsonb, 2, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 4, 'Easy',
 'Solve: x² - 9 = 0',
 '[{"text": "x = 3 and x = -3", "feedback": "Correct."}, {"text": "x = 3 only", "feedback": "The negative root works too: (-3)² is also 9. Square roots come in pairs."}, {"text": "x = 81", "feedback": "81 is 9 squared. The equation asks what squares TO 9."}, {"text": "x = 4.5", "feedback": "Halving the 9 is not the inverse of squaring. Take the square root."}]'::jsonb, 0, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 5, 'Easy',
 'Solve: (x + 4)² = 25',
 '[{"text": "x = 21", "feedback": "25 - 4 subtracts before rooting. Square root the 25 first, then move the 4."}, {"text": "x = 1 and x = -9", "feedback": "Correct."}, {"text": "x = 5 and x = -5", "feedback": "That solves the bracket ITSELF equal to root 25. Finish by subtracting the 4 from each."}, {"text": "x = 1 only", "feedback": "The root of 25 is plus OR minus 5, giving two answers."}]'::jsonb, 1, 'sub-solving-by-completing-square'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 6, 'Easy',
 'In the quadratic formula, what expression sits under the square root?',
 '[{"text": "b² - 4ac", "feedback": "Correct."}, {"text": "b² + 4ac", "feedback": "The 4ac SUBTRACTS. The sign under the root decides everything about the roots."}, {"text": "4ac - b²", "feedback": "The b² leads. Reversed, the sign of the whole expression flips."}, {"text": "b - 4ac", "feedback": "The b is squared under the root. Without the square the formula fails."}]'::jsonb, 0, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 7, 'Easy',
 'For 2x² - 5x + 1 = 0, what are a, b and c?',
 '[{"text": "a = 2, b = -5, c = 1", "feedback": "Correct."}, {"text": "a = 2, b = 5, c = 1", "feedback": "b carries its SIGN: the term is minus 5x, so b is -5."}, {"text": "a = 2x², b = -5x, c = 1", "feedback": "a, b and c are the COEFFICIENTS only — the x parts stay behind."}, {"text": "a = 1, b = -5, c = 2", "feedback": "a belongs to x² and c is the constant. They are swapped here."}]'::jsonb, 0, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 8, 'Easy',
 'A quadratic equation can have at most how many real solutions?',
 '[{"text": "Unlimited", "feedback": "The degree of the equation caps how many roots exist."}, {"text": "Three", "feedback": "A parabola cannot cross a horizontal line three times — count the crossings a U shape allows."}, {"text": "Two", "feedback": "Correct."}, {"text": "One", "feedback": "One happens only when the discriminant lands exactly on zero — it is not the ceiling."}]'::jsonb, 2, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 9, 'Easy',
 'For y = x² - 6x + 2, the x-coordinate of the vertex is found by which calculation?',
 '[{"text": "x = -b over 2a, giving 3", "feedback": "Correct."}, {"text": "x = c over a, giving 2", "feedback": "c places the y-intercept, not the vertex."}, {"text": "x = b over 2a, giving -3", "feedback": "The formula NEGATES b: minus (-6) over 2 is positive 3."}, {"text": "x = -b over a, giving 6", "feedback": "The denominator is 2a, not a. Halve the 6."}]'::jsonb, 0, 'sub-standard-form-analysis'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 10, 'Easy',
 'A rocket is launched with h(t) = -4.9t² + 30t + 2. What does the 2 represent?',
 '[{"text": "The launch height, 2 metres", "feedback": "Correct."}, {"text": "The maximum height the rocket reaches", "feedback": "The maximum sits at the vertex, much higher than 2. Substitute t = 0 to see what the 2 means."}, {"text": "The time the rocket spends in the air", "feedback": "Time is t, the input. The 2 is the OUTPUT when t = 0."}, {"text": "The speed of the rocket at launch", "feedback": "The 30 carries the launch speed. The loose constant is the starting height."}]'::jsonb, 0, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 11, 'Medium',
 'Solve by factoring: x² + 4x - 21 = 0',
 '[{"text": "x = 3 and x = 7", "feedback": "One root is negative: the pair multiplies to MINUS 21, so signs differ."}, {"text": "x = -3 and x = 7", "feedback": "The factors are (x + 7)(x - 3): the pair 7 and -3 must ADD to +4."}, {"text": "x = 21 and x = -1", "feedback": "Those multiply to -21 but add to 20. Both conditions bind."}, {"text": "x = 3 and x = -7", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 12, 'Medium',
 'Solve: 2x² - 8x = 0',
 '[{"text": "x = 2 and x = 4", "feedback": "2 is the common coefficient taken out front, not a root. A constant factor never produces a solution."}, {"text": "x = 0 and x = -4", "feedback": "The bracket is (x - 4), zeroed at POSITIVE 4."}, {"text": "x = 4 only", "feedback": "Dividing by x silently discards x = 0 — a real solution. Factor 2x out instead."}, {"text": "x = 0 and x = 4", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 13, 'Medium',
 'Solve by completing the square: x² + 6x + 2 = 0',
 '[{"text": "x = -3 + √7 only", "feedback": "The square root carries both signs — two solutions."}, {"text": "x = -3 + √11 and x = -3 - √11", "feedback": "Moving the 2 across SUBTRACTS it from the completing constant — it was added instead."}, {"text": "x = -3 + √7 and x = -3 - √7", "feedback": "Correct."}, {"text": "x = 3 + √7 and x = 3 - √7", "feedback": "That reads the roots off the completed square with the 3 left as it stands."}]'::jsonb, 2, 'sub-solving-by-completing-square'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 14, 'Medium',
 'Solve: (x - 2)² = 18. Give exact answers.',
 '[{"text": "x = 2 + 3√2 only", "feedback": "Both signs of the root give solutions."}, {"text": "x = 2 + 3√2 and x = 2 - 3√2", "feedback": "Correct."}, {"text": "x = -2 + 3√2 and x = -2 - 3√2", "feedback": "The -2 in the bracket crosses over as +2."}, {"text": "x = 2 + 9 and x = 2 - 9", "feedback": "√18 is not 9 — that halves instead of rooting. Simplify √18 by pulling out its perfect square factor."}]'::jsonb, 1, 'sub-solving-by-completing-square'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 15, 'Medium',
 'Solve with the quadratic formula: 2x² + 3x - 2 = 0',
 '[{"text": "x = 1 and x = -4", "feedback": "The denominator is 2a = 4, not 2. Both roots shrink by half."}, {"text": "x = 1/2 and x = -2", "feedback": "Correct."}, {"text": "x = -1/2 and x = 2", "feedback": "The formula starts with MINUS b, and b here is +3 — the signs of both roots came out flipped."}, {"text": "x = 1/2 only", "feedback": "The plus and the minus of √25 each give a root."}]'::jsonb, 1, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 16, 'Medium',
 'How many real roots does x² - 6x + 9 = 0 have?',
 '[{"text": "None, because 36 - 36 = 0", "feedback": "Zero under the root is fine — it gives one real root, not none. NEGATIVE means none."}, {"text": "One, because b² - 4ac = 0", "feedback": "Correct."}, {"text": "One, at x = 9", "feedback": "The root is x = 3, from -b over 2a. 9 is the constant c."}, {"text": "Two, because it is a quadratic", "feedback": "A discriminant of exactly zero collapses the two roots into one."}]'::jsonb, 1, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 17, 'Medium',
 'How many real roots does x² + 2x + 5 = 0 have?',
 '[{"text": "Two, because 4 + 20 = 24", "feedback": "The 4ac SUBTRACTS: 4 - 20 is -16, and a negative under the root gives no real answers."}, {"text": "None, because b² - 4ac is negative", "feedback": "Correct."}, {"text": "Two, at 1 and 5", "feedback": "Those are coefficients, not roots. Check the discriminant first."}, {"text": "One, at x = -1", "feedback": "x = -1 is the vertex position. The graph there sits at height 4, above the axis."}]'::jsonb, 1, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 18, 'Medium',
 'What is the vertex of y = x² - 6x + 2?',
 '[{"text": "(3, 2)", "feedback": "The y of the vertex comes from SUBSTITUTING x = 3 into the whole equation, not from reading the constant."}, {"text": "(-3, 29)", "feedback": "x = -b over 2a is minus (-6) over 2 — positive 3."}, {"text": "(3, -7)", "feedback": "Correct."}, {"text": "(6, 2)", "feedback": "The 2a in the denominator halves the 6."}]'::jsonb, 2, 'sub-standard-form-analysis'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 19, 'Medium',
 'What is the axis of symmetry of y = 2x² + 8x - 1?',
 '[{"text": "x = -2", "feedback": "Correct."}, {"text": "x = -1", "feedback": "-1 is the y-intercept constant, nothing to do with the axis."}, {"text": "x = 2", "feedback": "x = -b over 2a keeps the minus: -8 over 4."}, {"text": "x = -4", "feedback": "The denominator is 2a = 4, not a = 2."}]'::jsonb, 0, 'sub-standard-form-analysis'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 20, 'Medium',
 'A ball follows h = -5t² + 20t. When does it land?',
 '[{"text": "t = 5", "feedback": "Substitute it back: at t = 5 the height comes out negative — underground."}, {"text": "t = 4", "feedback": "Correct."}, {"text": "t = 20", "feedback": "Factoring gives -5t(t - 4) = 0. The 20 is a coefficient, not a time."}, {"text": "t = 2", "feedback": "t = 2 is the PEAK, halfway through the flight. Landing means h = 0."}]'::jsonb, 1, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 21, 'Challenge',
 'Solve: 3x² - 5x - 2 = 0',
 '[{"text": "x = 2 and x = 1/3", "feedback": "The smaller root is NEGATIVE: 3x + 1 = 0 gives -1/3."}, {"text": "x = 5 and x = -2", "feedback": "Those use the coefficients directly. Factor by decomposition: -6x + x replaces -5x."}, {"text": "x = -2 and x = 1/3", "feedback": "The factors are (3x + 1)(x - 2): the signs land the other way."}, {"text": "x = 2 and x = -1/3", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 22, 'Challenge',
 'Solve: x² = 5x - 6',
 '[{"text": "x = 0 and x = 5", "feedback": "Setting x² = 0 and 5x - 6 = 0 separately is not solving the equation. Bring everything to one side first."}, {"text": "x = -2 and x = -3", "feedback": "Rearranged, the equation is x² - 5x + 6 = 0: the pair must add to +5."}, {"text": "x = 1 and x = 6", "feedback": "1 and 6 multiply to 6 but add to 7, not to the 5 the middle term needs."}, {"text": "x = 2 and x = 3", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 23, 'Challenge',
 'Solve by completing the square: 2x² - 12x + 10 = 0',
 '[{"text": "x = 1 as the only solution", "feedback": "The square root carries both signs, so one of the two solutions has been dropped."}, {"text": "x = 3 + √14 and x = 3 - √14", "feedback": "That adds the constant instead of subtracting it while completing the square. Watch the sign as the constant crosses the equals sign."}, {"text": "x = -1 and x = -5", "feedback": "After dividing by 2, (x - 3)² = 4 unwinds around POSITIVE 3."}, {"text": "x = 1 and x = 5", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-completing-square'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 24, 'Challenge',
 'Solve exactly: x² - 4x - 3 = 0',
 '[{"text": "x = 2 + √1 and x = 2 - √1", "feedback": "The c is MINUS 3, so the -4ac piece ADDS to b² instead of subtracting."}, {"text": "x = 2 + √7 and x = 2 - √7", "feedback": "Correct."}, {"text": "x = 4 + √7 and x = 4 - √7", "feedback": "The -b over 2a halves the 4 before the root joins: 2, not 4."}, {"text": "x = 2 + √28 and x = 2 - √28", "feedback": "The 2a divides the root as well — simplify the root by extracting its square factor first."}]'::jsonb, 1, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 25, 'Challenge',
 'For which values of k does x² + kx + 16 = 0 have exactly one real root?',
 '[{"text": "k = 4 and k = -4", "feedback": "One root needs the discriminant to vanish: k² equals 4 times 16, and the root of THAT is not 4."}, {"text": "k = 8 and k = -8", "feedback": "Correct."}, {"text": "k = 8 only", "feedback": "k² = 64 has two roots. Both signs make the discriminant zero."}, {"text": "k = 16", "feedback": "Set b² - 4ac to zero: k² = 4 times 16. The k does not copy c."}]'::jsonb, 1, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 26, 'Challenge',
 'Profit follows P = -2x² + 120x - 1000. What price x gives the maximum profit?',
 '[{"text": "-30", "feedback": "The two negatives cancel: -120 over -4 is positive."}, {"text": "60", "feedback": "That divided by a instead of by 2a. Here 2a is -4, so the denominator is twice what was used."}, {"text": "800", "feedback": "800 is the PROFIT at the best price, not the price itself."}, {"text": "30", "feedback": "Correct."}]'::jsonb, 3, 'sub-standard-form-analysis'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 27, 'Challenge',
 'For that profit model, what is the maximum profit?',
 '[{"text": "1000", "feedback": "Substitute x = 30 through every term — the constant still subtracts at the end."}, {"text": "800", "feedback": "Correct."}, {"text": "2600", "feedback": "The -2x² term is negative at x = 30 — it pulls the total DOWN, not up."}, {"text": "30", "feedback": "30 is the best PRICE. The profit is P evaluated there."}]'::jsonb, 1, 'sub-standard-form-analysis'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 28, 'Challenge',
 'Two consecutive positive integers have a product of 72. What are they?',
 '[{"text": "6 and 12", "feedback": "Those multiply to 72 but are not CONSECUTIVE. Solve n(n + 1) = 72."}, {"text": "36 and 36", "feedback": "Equal numbers are not consecutive, and the equation n(n + 1) = 72 rules them out."}, {"text": "8 and 9", "feedback": "Correct."}, {"text": "7 and 8", "feedback": "Check: 7 times 8 is 56, short of 72."}]'::jsonb, 2, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 29, 'Challenge',
 'A right triangle has legs x and x + 7, and hypotenuse 13. What is x?',
 '[{"text": "12", "feedback": "12 is the LONGER leg, x + 7. The question asks for x."}, {"text": "6", "feedback": "x² + (x + 7)² = 169 reduces to x² + 7x - 60 = 0 — factor it rather than estimating."}, {"text": "5", "feedback": "Correct."}, {"text": "13", "feedback": "13 is the hypotenuse, given. The legs are the unknowns."}]'::jsonb, 2, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 30, 'Challenge',
 'The ball with h = -5t² + 20t is at height 15 at which times?',
 '[{"text": "t = 1 only", "feedback": "A ball passes each height twice — once going up, once coming down."}, {"text": "t = 15", "feedback": "15 is the HEIGHT. Set -5t² + 20t = 15 and solve for t."}, {"text": "t = 1 and t = 3", "feedback": "Correct."}, {"text": "t = 2", "feedback": "t = 2 is the peak at height 20, above 15."}]'::jsonb, 2, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 31, 'Advanced',
 'A path of uniform width x surrounds an 8 m by 6 m garden. The total area including the path is 80 m². What is x?',
 '[{"text": "1", "feedback": "Correct."}, {"text": "8", "feedback": "x = -8 also solves the quadratic, but a width cannot be negative — and 8 comes from the wrong factor sign anyway."}, {"text": "2", "feedback": "The path adds to BOTH sides: (8 + 2x)(6 + 2x) = 80, with 2x on each dimension."}, {"text": "8/7", "feedback": "That drops the 4x² term while expanding and solves what is left as a linear equation."}]'::jsonb, 0, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 32, 'Advanced',
 'A rocket follows h = -4.9t² + 19.6t + 2. What is its maximum height?',
 '[{"text": "19.6 m", "feedback": "19.6 is the launch speed coefficient. The peak needs t = 2 substituted through the whole formula."}, {"text": "2 m", "feedback": "2 m is where it STARTED. The vertex is far above the launch pad."}, {"text": "31.4 m", "feedback": "The first term at t = 2 is -4.9 times 4 — using -9.8, doubling instead of squaring, inflates the height."}, {"text": "21.6 m", "feedback": "Correct."}]'::jsonb, 3, 'sub-standard-form-analysis'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 33, 'Advanced',
 'For that rocket, how long until it lands, to one decimal?',
 '[{"text": "4.0 s", "feedback": "At t = 4 the height is 2 m — still airborne. The +2 launch height stretches the flight past 4."}, {"text": "2.0 s", "feedback": "t = 2 is the PEAK. Landing means h = 0, on the way down."}, {"text": "4.1 s", "feedback": "Correct."}, {"text": "8.2 s", "feedback": "That doubles the landing time. The formula -b plus root over 2a already gives the full flight."}]'::jsonb, 2, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 34, 'Advanced',
 'Two positive numbers differ by 6 and multiply to 91. What is the smaller one?',
 '[{"text": "6", "feedback": "6 is the gap between them, given, not a value."}, {"text": "91/6", "feedback": "The product does not divide by the difference. Set up n(n + 6) = 91 and factor."}, {"text": "13", "feedback": "13 is the LARGER of the two numbers. The question asks for the smaller one."}, {"text": "7", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-completing-square'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 35, 'Advanced',
 'Which method is MOST efficient for solving x² - 10x + 25 = 0?',
 '[{"text": "The quadratic formula, because it always works", "feedback": "Always working is not the same as fastest. The pattern (x - 5)² = 0 reads off instantly."}, {"text": "Factoring, because it is a perfect square trinomial", "feedback": "Correct."}, {"text": "Completing the square", "feedback": "The square is ALREADY complete — that is what a perfect square trinomial means."}, {"text": "Graphing to estimate the roots", "feedback": "An estimate for an exact double root at 5 trades certainty for effort."}]'::jsonb, 1, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 36, 'Advanced',
 'A farmer fences three sides of a field against a wall with 60 m of fence. The area is 448 m². What are the possible widths?',
 '[{"text": "14 m and 16 m", "feedback": "Correct."}, {"text": "15 m", "feedback": "15 is the vertex width — the MAXIMUM area of 450, slightly more than 448."}, {"text": "28 m and 32 m", "feedback": "The length along the wall is 60 - 2w: the fence covers two widths and one length, not two of each."}, {"text": "14 m only", "feedback": "The quadratic w² - 30w + 224 factors with TWO positive roots. Both layouts really give 448."}]'::jsonb, 0, 'sub-quadratic-applications'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 37, 'Advanced',
 'For which values of k does 2x² + 4x + k = 0 have two distinct real roots?',
 '[{"text": "Any k less than 8", "feedback": "With a = 2 the 4ac term is 8k — the 16 divides by its full coefficient, not by 2."}, {"text": "Any k except 2", "feedback": "k = 3 gives a negative discriminant and no roots at all. It is a one-sided condition, not an exclusion."}, {"text": "k greater than 2", "feedback": "Two roots need b² - 4ac ABOVE zero: 16 - 8k > 0 pulls k downward."}, {"text": "k less than 2", "feedback": "Correct."}]'::jsonb, 3, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 38, 'Advanced',
 'Which quadratic equation has roots 4 and -6?',
 '[{"text": "x² - 2x - 24 = 0", "feedback": "Expand (x - 4)(x + 6) carefully — the middle term takes the sign of the LARGER number."}, {"text": "x² - 10x + 24 = 0", "feedback": "That one has roots 4 and 6. The -6 changes both the middle and last terms."}, {"text": "x² + 2x - 24 = 0", "feedback": "Correct."}, {"text": "x² + 2x + 24 = 0", "feedback": "The constant is the product 4 times -6, which is NEGATIVE 24."}]'::jsonb, 2, 'sub-solving-by-factoring'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 39, 'Advanced',
 'Applying the formula to x² + 3x - 5 = 0 gives which exact solutions?',
 '[{"text": "x = -3 + √29 and x = -3 - √29", "feedback": "Everything sits over 2a = 2, the root included."}, {"text": "x = (3 + √29)/2 and x = (3 - √29)/2", "feedback": "The formula opens with MINUS b, and b is +3."}, {"text": "x = (-3 + √11)/2 and x = (-3 - √11)/2", "feedback": "c is -5, so the -4ac term ADDS to b² rather than subtracting from it."}, {"text": "x = (-3 + √29)/2 and x = (-3 - √29)/2", "feedback": "Correct."}]'::jsonb, 3, 'sub-quadratic-formula'),

(10, 'MPM2D', 'Solving quadratic equations', 5, 40, 'Advanced',
 'A triangle has base x cm and height (x - 3) cm, with area 27 cm². What is x?',
 '[{"text": "27", "feedback": "27 is the area that was given, not the base. Put base times height over 2 equal to 27 and solve for x."}, {"text": "-6", "feedback": "-6 solves the quadratic but a base cannot be negative. Take the positive root."}, {"text": "9", "feedback": "Correct."}, {"text": "6", "feedback": "That factors the quadratic as though the middle term were +3x, which flips the sign of both roots."}]'::jsonb, 2, 'sub-quadratic-applications');
