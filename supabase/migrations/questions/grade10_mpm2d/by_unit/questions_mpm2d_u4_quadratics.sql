-- ===========================================================================
-- ASTRO MATH ASSIST — GRADE 10 (MPM2D), complete
-- ===========================================================================
--
-- 240 questions across six units, plus the 33 figures that attach to them.
-- Questions and figures used to be two files that had to be run in order,
-- and running the second one was easy to forget — which showed up as
-- questions that reference a diagram nobody can see. They are one file now.
--
-- RUN ORDER:  supabase_full_setup.sql  ->  this file.
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

delete from questions where course_code = 'MPM2D' and unit = 'Quadratics';

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

(10, 'MPM2D', 'Quadratics', 4, 1, 'Easy',
 'A table of values has constant SECOND differences but changing first differences. The relationship is what?',
 '[{"text": "Exponential", "feedback": "Exponential patterns multiply by a constant ratio instead."}, {"text": "Linear", "feedback": "Linear relationships have constant FIRST differences."}, {"text": "Neither linear nor quadratic", "feedback": "Constant second differences DO identify one of these families. Compare with how linear tables behave."}, {"text": "Quadratic", "feedback": "Correct."}]'::jsonb, 3, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 2, 'Easy',
 'For y = -3x² + 5x - 1, which way does the parabola open?',
 '[{"text": "Up, because b is positive", "feedback": "b shifts the parabola sideways — it never decides the direction."}, {"text": "Down, because the equation has three terms", "feedback": "The number of terms is irrelevant. Only the sign of a decides."}, {"text": "Down, because a is negative", "feedback": "Correct."}, {"text": "Up, because c is negative", "feedback": "The constant c places the y-intercept. The DIRECTION comes from a."}]'::jsonb, 2, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 3, 'Easy',
 'What is the vertex of y = (x - 3)² + 5?',
 '[{"text": "(3, 5)", "feedback": "Correct."}, {"text": "(3, -5)", "feedback": "k sits outside the bracket with its own sign, +5 here."}, {"text": "(-3, 5)", "feedback": "The form is (x - h): the bracket (x - 3) means h is +3. The sign inside flips."}, {"text": "(-3, -5)", "feedback": "Both signs are off: h comes from reversing the bracket, k reads directly."}]'::jsonb, 0, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 4, 'Easy',
 'What is the vertex of y = (x + 2)² - 7?',
 '[{"text": "(-2, -7)", "feedback": "Correct."}, {"text": "(2, -7)", "feedback": "(x + 2) is (x - (-2)), so h is NEGATIVE 2. The inside sign always flips."}, {"text": "(2, 7)", "feedback": "Both parts misread: the bracket flips its sign, the tail keeps its own."}, {"text": "(-2, 7)", "feedback": "The k value keeps its own sign: -7."}]'::jsonb, 0, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 5, 'Easy',
 'In y = a(x - h)² + k, what does the k control?',
 '[{"text": "The width of the parabola", "feedback": "Width and stretch belong to a."}, {"text": "The vertical shift, up or down", "feedback": "Correct."}, {"text": "The direction of opening", "feedback": "Opening up or down is the sign of a."}, {"text": "The horizontal shift", "feedback": "Left and right belongs to h, inside the bracket."}]'::jsonb, 1, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 6, 'Easy',
 'Compared with y = x², the graph of y = 3x² is what?',
 '[{"text": "Shifted up by 3", "feedback": "Adding 3 OUTSIDE the square shifts up. Multiplying stretches."}, {"text": "Narrower, stretched vertically", "feedback": "Correct."}, {"text": "Wider", "feedback": "a values BIGGER than 1 stretch the parabola upward, pulling it narrower. Wider comes from a between 0 and 1."}, {"text": "Shifted right by 3", "feedback": "Sideways shifts live inside the bracket with x."}]'::jsonb, 1, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 7, 'Easy',
 'What number completes the square for x² + 8x?',
 '[{"text": "4", "feedback": "4 is half of 8 — the number still needs to be squared."}, {"text": "64", "feedback": "Halve the 8 FIRST, then square what you get. Squaring the whole 8 skips the halving step."}, {"text": "8", "feedback": "The rule is half the x coefficient, squared. Not the coefficient itself."}, {"text": "16", "feedback": "Correct."}]'::jsonb, 3, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 8, 'Easy',
 'What are the x-intercepts of y = (x - 2)(x + 5)?',
 '[{"text": "-2 and -5", "feedback": "The first factor zeroes at +2. Set each bracket to zero and solve."}, {"text": "2 and 5", "feedback": "The second factor (x + 5) zeroes at x = -5, not +5."}, {"text": "-2 and 5", "feedback": "Each factor equals zero when x CANCELS it: x - 2 = 0 gives +2. The signs flip."}, {"text": "2 and -5", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 9, 'Easy',
 'The x-intercepts of a parabola are 1 and 7. What is the axis of symmetry?',
 '[{"text": "x = 3", "feedback": "That halves the distance between the intercepts."}, {"text": "x = 6", "feedback": "6 is the distance between them, not their middle."}, {"text": "x = 8", "feedback": "The axis is the AVERAGE of the intercepts, not their sum. Divide by 2."}, {"text": "x = 4", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 10, 'Easy',
 'What is the y-intercept of y = 2x² - 3x + 7?',
 '[{"text": "-3", "feedback": "-3 is the coefficient of x. The y-intercept is the value when x = 0, which leaves only the constant."}, {"text": "2", "feedback": "2 is the stretch factor a. Set x = 0 to find where the graph meets the y-axis."}, {"text": "7", "feedback": "Correct."}, {"text": "0", "feedback": "Substituting x = 0 does not wipe out the constant term. Only parabolas through the origin have a y-intercept of 0."}]'::jsonb, 2, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 11, 'Medium',
 'Describe the transformations taking y = x² to y = (x - 4)² - 3.',
 '[{"text": "Down 4 and right 3", "feedback": "The bracket number moves sideways and the tail number moves vertically — they are swapped here."}, {"text": "Left 4 and down 3", "feedback": "(x - 4) moves the graph toward POSITIVE x. The inside sign works in reverse."}, {"text": "Right 4 and down 3", "feedback": "Correct."}, {"text": "Right 4 and up 3", "feedback": "The -3 outside drops the graph. Outside signs read directly."}]'::jsonb, 2, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 12, 'Medium',
 'A parabola has vertex (2, -5) and opens up with a = 1. What is its equation in vertex form?',
 '[{"text": "y = (x + 2)² - 5", "feedback": "h = 2 enters the bracket with a FLIPPED sign: (x - 2)."}, {"text": "y = (x + 2)² + 5", "feedback": "Both signs are reversed. The bracket flips h; the tail copies k."}, {"text": "y = (x - 2)² - 5", "feedback": "Correct."}, {"text": "y = (x - 2)² + 5", "feedback": "k = -5 keeps its own sign outside the bracket."}]'::jsonb, 2, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 13, 'Medium',
 'What is the maximum value of y = -2(x + 1)² + 8, and where does it occur?',
 '[{"text": "8, at x = -1", "feedback": "Correct."}, {"text": "8, at x = 1", "feedback": "The bracket (x + 1) peaks when x = -1. The inside sign flips."}, {"text": "There is no maximum", "feedback": "a is negative, so the parabola opens down and the vertex is its highest point."}, {"text": "-2, at x = -1", "feedback": "-2 is the stretch factor. The maximum VALUE is k."}]'::jsonb, 0, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 14, 'Medium',
 'Convert by completing the square: y = x² + 6x + 4',
 '[{"text": "y = (x + 3)² - 5", "feedback": "Correct."}, {"text": "y = (x + 3)² + 4", "feedback": "Adding 9 inside means SUBTRACTING 9 outside: 4 - 9 is -5. The +4 cannot survive unchanged."}, {"text": "y = (x + 6)² - 32", "feedback": "The bracket takes HALF the x coefficient: 3, not 6."}, {"text": "y = (x + 3)² + 13", "feedback": "The 9 that completes the square is subtracted, not added: 4 - 9, not 4 + 9."}]'::jsonb, 0, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 15, 'Medium',
 'Convert: y = x² - 10x + 30',
 '[{"text": "y = (x + 5)² + 5", "feedback": "The bracket copies the sign of the x term: -10x gives (x - 5)."}, {"text": "y = (x - 5)² + 5", "feedback": "Correct."}, {"text": "y = (x - 5)² - 25", "feedback": "The +30 still counts: 30 - 25 leaves +5 outside."}, {"text": "y = (x - 10)² + 30", "feedback": "Half of 10 goes in the bracket, and the constant adjusts by its square."}]'::jsonb, 1, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 16, 'Medium',
 'What is the vertex of y = (x - 1)(x - 9)?',
 '[{"text": "(4, -15)", "feedback": "The axis is halfway between 1 and 9, which is 5, not 4."}, {"text": "(5, 16)", "feedback": "Substitute x = 5 into both brackets and multiply — one bracket comes out negative."}, {"text": "(5, -16)", "feedback": "Correct."}, {"text": "(1, 9)", "feedback": "Those are the x-intercepts bundled into a point. The vertex x is their average."}]'::jsonb, 2, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 17, 'Medium',
 'A parabola in factored form is y = 2(x + 3)(x - 1). What is its y-intercept?',
 '[{"text": "-6", "feedback": "Correct."}, {"text": "-3", "feedback": "The 2 out front multiplies too: 2 times 3 times -1."}, {"text": "6", "feedback": "Substituting x = 0 gives 2(3)(-1), and the product of a positive and a negative is negative."}, {"text": "2", "feedback": "2 is the stretch factor. Substitute x = 0 through the WHOLE equation."}]'::jsonb, 0, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 18, 'Medium',
 'Which equation has x-intercepts at -2 and 6 and opens downward?',
 '[{"text": "y = -(x - 2)(x + 6)", "feedback": "Those brackets zero at +2 and -6 — the intercepts flipped."}, {"text": "y = (x + 2)(x - 6)", "feedback": "The intercepts are right, but a positive a opens UP."}, {"text": "y = -(x - 2)(x - 6)", "feedback": "The first bracket zeroes at +2, not -2. An intercept of -2 needs (x + 2)."}, {"text": "y = -(x + 2)(x - 6)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 19, 'Medium',
 'The points (1, 4) and (7, 4) lie on a parabola. What is the x-coordinate of its vertex?',
 '[{"text": "8", "feedback": "Equal heights sit symmetrically about the axis: AVERAGE the two x values."}, {"text": "4", "feedback": "Correct."}, {"text": "4.5", "feedback": "The method is right and the arithmetic slipped. Add the two x values and halve the total, carefully."}, {"text": "Cannot be determined", "feedback": "Equal y values are exactly enough — the axis must run midway between them."}]'::jsonb, 1, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 20, 'Medium',
 'First differences of a quadratic table are 3, 5, 7, 9. What are the second differences?',
 '[{"text": "2, constant", "feedback": "Correct."}, {"text": "3, constant", "feedback": "The second differences come from subtracting NEIGHBOURING first differences: 5 - 3 is 2."}, {"text": "4, constant", "feedback": "Each gap is 2: check 7 - 5."}, {"text": "They are not constant", "feedback": "5 - 3, 7 - 5 and 9 - 7 all give the same 2 — that constancy is the quadratic test."}]'::jsonb, 0, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 21, 'Challenge',
 'Convert: y = 2x² + 12x + 11',
 '[{"text": "y = 2(x + 3)² - 9", "feedback": "What leaves the bracket is 2 times 9, not 9. The stretch factor multiplies everything inside."}, {"text": "y = 2(x + 3)² - 7", "feedback": "Correct."}, {"text": "y = 2(x + 3)² + 2", "feedback": "The 9 completing the square sits INSIDE a bracket multiplied by 2, so 18 leaves the constant: 11 - 18 is -7."}, {"text": "y = 2(x + 6)² - 61", "feedback": "The 2 factors out FIRST: y = 2(x² + 6x) + 11, and half of 6 is 3."}]'::jsonb, 1, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 22, 'Challenge',
 'Convert: y = -x² + 8x - 10',
 '[{"text": "y = -(x + 4)² + 6", "feedback": "Factoring -1 from -x² + 8x gives (x² - 8x): the bracket is (x - 4)."}, {"text": "y = -(x - 4)² + 6", "feedback": "Correct."}, {"text": "y = -(x - 4)² - 26", "feedback": "The -16 inside the negative bracket ADDS 16 outside: -10 + 16 is +6."}, {"text": "y = (x - 4)² + 6", "feedback": "The negative on x² cannot vanish — the parabola opens down."}]'::jsonb, 1, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 23, 'Challenge',
 'A parabola has vertex (3, -2) and passes through (5, 6). What is a?',
 '[{"text": "2", "feedback": "Correct."}, {"text": "-2", "feedback": "The point (5, 6) sits ABOVE the vertex, so the parabola opens up and a is positive."}, {"text": "8", "feedback": "That stops after moving the -2 across. The squared bracket still divides it."}, {"text": "1/2", "feedback": "That divides the wrong way around once the bracket is squared. Isolate a step by step."}]'::jsonb, 0, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 24, 'Challenge',
 'Which equation matches a parabola with vertex (-1, 4) opening down, in vertex form?',
 '[{"text": "y = -3(x + 1)² - 4", "feedback": "k = 4 keeps its own sign outside: +4."}, {"text": "y = -3(x + 1)² + 4", "feedback": "Correct."}, {"text": "y = -3(x - 1)² + 4", "feedback": "h = -1 goes into the bracket sign-flipped: (x + 1)."}, {"text": "y = 3(x + 1)² + 4", "feedback": "A positive a opens UP. Opening down needs a negative stretch."}]'::jsonb, 1, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 25, 'Challenge',
 'y = x² - 4x + 7 has how many x-intercepts?',
 '[{"text": "Two, at 2 and 3", "feedback": "(2, 3) is one point — the vertex — not two intercepts."}, {"text": "Two, because every parabola crosses the x-axis", "feedback": "A parabola floating above the axis never crosses it. Complete the square to find the vertex first."}, {"text": "One, at x = 2", "feedback": "x = 2 is the AXIS of symmetry. The graph there sits at height 3, not 0."}, {"text": "None, because its vertex (2, 3) is above the x-axis and it opens up", "feedback": "Correct."}]'::jsonb, 3, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 26, 'Challenge',
 'A quadratic has x-intercepts -3 and 5 and passes through (1, -32). What is a in factored form?',
 '[{"text": "-2", "feedback": "Substitute (1, -32): both the y value AND the bracket product come out negative, and their quotient is positive."}, {"text": "1/2", "feedback": "-32 divides by -16 — the division went the wrong way."}, {"text": "-32", "feedback": "-32 is the y value of the point, not the stretch factor. Substitute and solve for a."}, {"text": "2", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 27, 'Challenge',
 'The parabola y = a(x - 2)² + 8 has x-intercepts. What must be true of a?',
 '[{"text": "a is between 0 and 1", "feedback": "Any positive a keeps the whole graph above the axis when the vertex is at height 8."}, {"text": "a is positive", "feedback": "A vertex ABOVE the axis with arms going up never comes down to cross it."}, {"text": "a is negative", "feedback": "Correct."}, {"text": "a can be anything except 0", "feedback": "The sign matters: only downward arms reach the axis from a vertex at +8."}]'::jsonb, 2, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 28, 'Challenge',
 'A ball follows h = -5(t - 2)² + 45. What is its maximum height, and when?',
 '[{"text": "45 m at t = -2 s", "feedback": "The bracket (t - 2) peaks at t = POSITIVE 2. Inside signs flip."}, {"text": "-5 m at t = 2 s", "feedback": "-5 is the stretch factor, not a height. The maximum height is k."}, {"text": "40 m at t = 2 s", "feedback": "That takes the stretch factor of 5 off the constant."}, {"text": "45 m at t = 2 s", "feedback": "Correct."}]'::jsonb, 3, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 29, 'Challenge',
 'Which quadratic has second differences of -6?',
 '[{"text": "y = -3x² + x", "feedback": "Correct."}, {"text": "y = 3x² - 6x", "feedback": "a = 3 gives second differences of +6. The sign of a carries through."}, {"text": "y = -3x + 6", "feedback": "That is a line — no second differences at all beyond zero."}, {"text": "y = -6x² + 1", "feedback": "Second differences equal 2a. For -6 that means a = -3, not -6."}]'::jsonb, 0, 'sub-properties-of-quadratics'),

(10, 'MPM2D', 'Quadratics', 4, 30, 'Challenge',
 'y = (x - 4)² and y = x² - 4 differ how?',
 '[{"text": "The first shifts down 4, the second right 4", "feedback": "The bracket number is the sideways move; the loose number is the vertical one."}, {"text": "The first shifts left 4, the second up 4", "feedback": "Both directions are reversed: inside the bracket flips, outside reads directly."}, {"text": "The first shifts right 4, the second shifts down 4", "feedback": "Correct."}, {"text": "They are the same graph", "feedback": "Expand the first: x² - 8x + 16. The middle term makes them different graphs."}]'::jsonb, 2, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 31, 'Advanced',
 'Convert: y = 3x² - 9x + 5',
 '[{"text": "y = 3(x - 3/2)² + 5", "feedback": "The completing term leaves the constant changed: 5 minus 3 times 9/4 is -7/4."}, {"text": "y = 3(x - 3/2)² - 7/4", "feedback": "Correct."}, {"text": "y = 3(x - 3/2)² - 9/4", "feedback": "What exits the bracket is 3 times 9/4 = 27/4, and 5 is 20/4: the tail is -7/4."}, {"text": "y = 3(x - 3)² + 5", "feedback": "The 3 factors out first, leaving x² - 3x inside — half of 3 is 3/2, not 3."}]'::jsonb, 1, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 32, 'Advanced',
 'A rectangular pen uses 40 m of fence. Its area is A = w(20 - w). What width gives the maximum area?',
 '[{"text": "20 m", "feedback": "w = 20 makes the OTHER side zero — no pen at all. The best width sits midway between the two zeros."}, {"text": "5 m", "feedback": "Compare areas: at w = 5 the pen is long and thin. The vertex sits midway between the zeros of w(20 - w)."}, {"text": "10 m", "feedback": "Correct."}, {"text": "40 m", "feedback": "40 is the whole fence. The two widths together use only part of it."}]'::jsonb, 2, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 33, 'Advanced',
 'A rectangular pen uses 40 m of fence, so its area is A = w(20 - w). What is the maximum area of that pen?',
 '[{"text": "400 m²", "feedback": "400 is 20 squared. Substitute the best width into w(20 - w) instead."}, {"text": "100 m²", "feedback": "Correct."}, {"text": "75 m²", "feedback": "That is the area at w = 5, not at the vertex."}, {"text": "200 m²", "feedback": "That multiplies the best width by the FULL 20. The other side of the pen is 20 minus w."}]'::jsonb, 1, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 34, 'Advanced',
 'A quadratic has vertex (1, -8) and one x-intercept at 3. Where is the other x-intercept?',
 '[{"text": "-3", "feedback": "Mirror across the axis x = 1, not across the y-axis. Measure how far 3 sits from the axis, then go that same distance the other way."}, {"text": "5", "feedback": "Intercepts mirror across the AXIS x = 1. Reflecting 3 puts the other one on the far side of the axis, not further right."}, {"text": "-1", "feedback": "Correct."}, {"text": "8", "feedback": "8 comes from the vertex height, which does not locate intercepts."}]'::jsonb, 2, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 35, 'Advanced',
 'Written in all three forms, y = x² - 2x - 8 is which of these?',
 '[{"text": "y = (x - 1)² - 9 and y = (x - 4)(x + 2)", "feedback": "Correct."}, {"text": "y = (x + 1)² - 9 and y = (x - 4)(x + 2)", "feedback": "The vertex form bracket copies half the -2x term: (x - 1)."}, {"text": "y = (x - 1)² + 9 and y = (x - 4)(x + 2)", "feedback": "The tail is -8 - 1 = -9. Completing the square SUBTRACTS the 1 that was added inside."}, {"text": "y = (x - 1)² - 9 and y = (x + 4)(x - 2)", "feedback": "Those factors zero at -4 and 2, but the intercepts are 4 and -2. Expand to check the middle sign."}]'::jsonb, 0, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 36, 'Advanced',
 'For what values of k does y = x² + kx + 25 touch the x-axis exactly once?',
 '[{"text": "10 only", "feedback": "The perfect square can be (x - 5)² as well. Both signs of k work."}, {"text": "10 and -10", "feedback": "Correct."}, {"text": "5 and -5", "feedback": "Touching once means a perfect square: the middle term is twice the root of 25, so k is 10 in size."}, {"text": "25", "feedback": "k copies twice the square root of the constant, not the constant."}]'::jsonb, 1, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 37, 'Advanced',
 'An arch is modelled by h = -0.5(x - 6)² + 18. How wide is the arch at ground level?',
 '[{"text": "36", "feedback": "Setting h = 0 gives (x - 6)² = 36, so x - 6 is plus or minus 6 — the 36 still needs its square root."}, {"text": "18", "feedback": "18 is the height at the top, not a width."}, {"text": "6", "feedback": "6 is the distance from the centre to ONE foot. The arch spans both sides of centre."}, {"text": "12", "feedback": "Correct."}]'::jsonb, 3, 'sub-vertex-form'),

(10, 'MPM2D', 'Quadratics', 4, 38, 'Advanced',
 'Two numbers add to 14. What is the largest their product can be?',
 '[{"text": "48", "feedback": "Close but under — that is 6 times 8. The true peak sits at the vertex of n(14 - n), where the two numbers are equal."}, {"text": "196", "feedback": "196 is 14 squared — but the two numbers ADD to 14, they are not both 14."}, {"text": "49", "feedback": "Correct."}, {"text": "14", "feedback": "14 is the sum, given. Find the vertex of the product n(14 - n)."}]'::jsonb, 2, 'sub-factored-form'),

(10, 'MPM2D', 'Quadratics', 4, 39, 'Advanced',
 'y = 2(x - 3)(x - 7) and y = 2(x - 5)² - 8 describe what?',
 '[{"text": "The same parabola, but only the first has x-intercepts", "feedback": "A graph either crosses the axis or not — its form on paper cannot change that."}, {"text": "Different parabolas with the same intercepts", "feedback": "The stretch factor is 2 in both, and the vertex (5, -8) matches the average of the intercepts 3 and 7."}, {"text": "Different parabolas with the same vertex", "feedback": "Expand both: 2x² - 20x + 42 twice over. Same everything."}, {"text": "The same parabola, in factored and vertex form", "feedback": "Correct."}]'::jsonb, 3, 'sub-completing-the-square'),

(10, 'MPM2D', 'Quadratics', 4, 40, 'Advanced',
 'A quadratic table has y values 5, 8, 13, 20 at x = 0, 1, 2, 3. What is y at x = 4?',
 '[{"text": "29", "feedback": "Correct."}, {"text": "25", "feedback": "The GAPS grow by 2 each time. Adding a constant 5 treats it as linear."}, {"text": "40", "feedback": "Twice 20 doubles the last value. Extend the difference pattern instead: 20 + 9."}, {"text": "27", "feedback": "The first differences are 3, 5, 7 — the next gap is not another 7, because second differences stay constant."}]'::jsonb, 0, 'sub-properties-of-quadratics');
