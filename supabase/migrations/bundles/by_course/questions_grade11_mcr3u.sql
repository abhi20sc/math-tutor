-- ===========================================================================
-- ASTRO MATH ASSIST — Grade 11 — MCR3U, Functions
-- ===========================================================================
--
-- 280 questions, 8 figures.
--
-- One course, safe to run on its own, in any order relative to the other
-- courses. Run it AFTER astro_math_assist_setup.sql has created the schema.
--
-- This is the per-unit files concatenated, with the figure file last, which is required:
-- every unit file opens with a delete for its own unit, and that delete takes
-- the figure reference with the row, so a figure file that ran first would
-- leave the course imageless.
--
-- Student attempts key on course, unit and sort_order rather than on question
-- ids, so re-running this keeps the history of every student.
-- ===========================================================================


-- --- questions_mcr3u_u1.sql ---

-- ===========================================================================
-- MCR3U — Unit 1: Functions — 40 questions
-- ===========================================================================
-- Grade 11 Functions, authored from the Jensen MCR3U lesson material for
-- this unit:
--
--   Lesson 1  Domain and range
--   Lesson 2  Function notation
--   Lesson 3  Max or min of a quadratic (completing the square)
--   Lesson 4  Working with radicals
--   Lesson 5  Solving quadratics by factoring
--   Lesson 6  The quadratic formula and the discriminant
--   Lesson 7  Linear-quadratic systems
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own
-- at any time; the delete at the top makes a corrected copy replace the unit
-- cleanly, and student attempts (keyed on course, unit and sort_order)
-- survive the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- ANSWER POSITIONS, corrected 18 Aug 2026. The first cut of this file put the
-- correct answer at option A in 39 of its 40 questions. main.dart does not
-- shuffle options, so that taught a student to tap A without reading, and it
-- inflated the first-try rate the tutor dashboard reports. The options here
-- have been rotated so the answer sits at A, B, C and D ten times each. The
-- questions, the options and the feedback are untouched; only their order on
-- screen changed, so student attempts keyed on sort_order still line up.
-- Regenerate with tools/balance_answer_positions.py.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Functions';

insert into misconception_labels (tag, label) values
  ('sub-domain-range',      'Domain and range'),
  ('sub-function-notation', 'Function notation'),
  ('sub-max-min',           'Max and min of quadratics'),
  ('sub-radicals',          'Working with radicals'),
  ('sub-solve-factoring',   'Solving by factoring'),
  ('sub-quadratic-formula', 'The quadratic formula'),
  ('sub-linear-quadratic',  'Linear-quadratic systems')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Functions', 1, 1, 'Easy',
 'Which of these relations is NOT a function?',
 '[{"text": "y = -x²", "feedback": "Flipping a parabola upside down does not stop each x having one y."},
   {"text": "y = x²", "feedback": "Every x gives exactly one y here, so it passes the vertical line test."},
   {"text": "y = 3x + 1", "feedback": "A straight line that is not vertical is always a function."},
   {"text": "x = y²", "feedback": "Correct."}]'::jsonb,
 3, 'sub-domain-range'),

(11, 'MCR3U', 'Functions', 1, 2, 'Easy',
 'What is the domain of y = x²?',
 '[{"text": "y ≥ 0", "feedback": "That describes the outputs. The domain is about which x values are allowed IN."},
   {"text": "x ≠ 0", "feedback": "Zero squares perfectly well. There is no division here to forbid it."},
   {"text": "All real numbers", "feedback": "Correct."},
   {"text": "x ≥ 0", "feedback": "Any number can be squared, negative inputs included. Nothing restricts x here."}]'::jsonb,
 2, 'sub-domain-range'),

(11, 'MCR3U', 'Functions', 1, 3, 'Easy',
 'If f(x) = 2x + 5, find f(3).',
 '[{"text": "16", "feedback": "That computes 2(3 + 5), adding before multiplying. Substitute 3 for x first."},
   {"text": "11", "feedback": "Correct."},
   {"text": "6", "feedback": "That stops after multiplying. The + 5 still needs adding."},
   {"text": "10", "feedback": "That adds 2 + 3 + 5. The 2 multiplies x, it does not add to it."}]'::jsonb,
 1, 'sub-function-notation'),

(11, 'MCR3U', 'Functions', 1, 4, 'Easy',
 'If g(x) = x² - 4, find g(-2).',
 '[{"text": "0", "feedback": "Correct."},
   {"text": "-8", "feedback": "The square of -2 is +4, not -4. A square is never negative."},
   {"text": "4", "feedback": "That squares -2 and stops. The - 4 in the rule still applies."},
   {"text": "8", "feedback": "That adds the 4 instead of subtracting it. Read the sign in the rule."}]'::jsonb,
 0, 'sub-function-notation'),

(11, 'MCR3U', 'Functions', 1, 5, 'Easy',
 'The quadratic y = 2(x - 3)² + 1 is in vertex form. What is its vertex?',
 '[{"text": "(3, 1)", "feedback": "Correct."},
   {"text": "(-3, 1)", "feedback": "The sign inside the bracket flips: (x - h) means the vertex is at x = h, so x - 3 puts it at positive 3."},
   {"text": "(1, 3)", "feedback": "The coordinates are swapped. The number inside the bracket is the x-coordinate."},
   {"text": "(2, 1)", "feedback": "The 2 out front is the stretch factor a. It is not part of the vertex."}]'::jsonb,
 0, 'sub-max-min'),

(11, 'MCR3U', 'Functions', 1, 6, 'Easy',
 'Simplify √50 as a mixed radical.',
 '[{"text": "5√2", "feedback": "Correct."},
   {"text": "25√2", "feedback": "The perfect square 25 comes OUT as its square root, which is 5, not as 25 itself."},
   {"text": "2√5", "feedback": "The numbers are the wrong way round. It is the square root of the perfect square factor that moves out front."},
   {"text": "5√10", "feedback": "That splits 50 as 5 × 10 and takes the root of the 5. Neither 5 nor 10 is a perfect square — use 25 × 2."}]'::jsonb,
 0, 'sub-radicals'),

(11, 'MCR3U', 'Functions', 1, 7, 'Easy',
 'Solve by factoring: x² - 7x + 12 = 0',
 '[{"text": "x = 3 or x = 4", "feedback": "Correct."},
   {"text": "x = -3 or x = -4", "feedback": "The factors are (x - 3)(x - 4), and x - 3 = 0 gives POSITIVE 3. The sign flips when solving each factor."},
   {"text": "x = 2 or x = 6", "feedback": "2 and 6 multiply to 12 but add to 8. The pair must also add to 7."},
   {"text": "x = 1 or x = 12", "feedback": "1 and 12 multiply to 12 but add to 13, and the middle term needs 7."}]'::jsonb,
 0, 'sub-solve-factoring'),

(11, 'MCR3U', 'Functions', 1, 8, 'Easy',
 'In the quadratic formula, which expression is the discriminant?',
 '[{"text": "b² - 4ac", "feedback": "Correct."},
   {"text": "b² + 4ac", "feedback": "The sign is wrong: the 4ac is subtracted from b squared."},
   {"text": "4ac - b²", "feedback": "That is the discriminant backwards, which flips its sign and every conclusion drawn from it."},
   {"text": "2a", "feedback": "That is the denominator of the formula, not the part under the root."}]'::jsonb,
 0, 'sub-quadratic-formula'),

(11, 'MCR3U', 'Functions', 1, 9, 'Easy',
 'What is the greatest number of points at which a straight line can intersect a parabola?',
 '[{"text": "2", "feedback": "Correct."},
   {"text": "1", "feedback": "One touch is the tangent case, but a line can also cut clean through both arms."},
   {"text": "3", "feedback": "Three crossings would need the line to bend back, and lines do not bend."},
   {"text": "4", "feedback": "Substituting the line into the parabola gives a quadratic, and a quadratic has at most two solutions."}]'::jsonb,
 0, 'sub-linear-quadratic'),

(11, 'MCR3U', 'Functions', 1, 10, 'Easy',
 'Evaluate: √9 × √4',
 '[{"text": "13", "feedback": "That adds 9 + 4. The radicals here are multiplied, not added."},
   {"text": "12", "feedback": "One root was taken and the other forgotten: 3 × 4 uses the un-rooted 4."},
   {"text": "6", "feedback": "Correct."},
   {"text": "36", "feedback": "That multiplies 9 by 4 and never takes the roots. Root first, or root the product 36 at the end — either way finish the root."}]'::jsonb,
 2, 'sub-radicals'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Functions', 1, 11, 'Medium',
 'What is the domain of y = √(x - 4)?',
 '[{"text": "x > 4", "feedback": "x = 4 itself is allowed: the root of zero is zero. Only negatives under the root are forbidden."},
   {"text": "x ≤ 4", "feedback": "The inequality points the wrong way. The inside of the root must be zero or MORE."},
   {"text": "x ≥ -4", "feedback": "Setting x - 4 ≥ 0 moves the 4 across as +4, not -4."},
   {"text": "x ≥ 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-domain-range'),

(11, 'MCR3U', 'Functions', 1, 12, 'Medium',
 'If f(x) = x² - 3x, find f(-1).',
 '[{"text": "2", "feedback": "The square of -1 is +1, not -1. The first term does not stay negative."},
   {"text": "-4", "feedback": "Both signs went astray: the square is positive and -3 times -1 is positive."},
   {"text": "4", "feedback": "Correct."},
   {"text": "-2", "feedback": "The second term is -3 times -1, which is +3, not -3. Two negatives multiply to a positive."}]'::jsonb,
 2, 'sub-function-notation'),

(11, 'MCR3U', 'Functions', 1, 13, 'Medium',
 'Complete the square: y = x² + 6x + 2',
 '[{"text": "y = (x + 3)² - 9", "feedback": "The 9 was subtracted, but the original + 2 vanished. Combine them."},
   {"text": "y = (x + 6)² - 34", "feedback": "The bracket takes HALF the x coefficient. Half of 6 is 3."},
   {"text": "y = (x + 3)² - 7", "feedback": "Correct."},
   {"text": "y = (x + 3)² + 2", "feedback": "The bracket quietly added 9 to the expression. That 9 has to be subtracted back off the constant."}]'::jsonb,
 2, 'sub-max-min'),

(11, 'MCR3U', 'Functions', 1, 14, 'Medium',
 'Does y = -2(x - 1)² + 8 have a maximum or a minimum, and what is it?',
 '[{"text": "A maximum of 8", "feedback": "Correct."},
   {"text": "A minimum of 8", "feedback": "A negative a opens the parabola downward, so its vertex is the top, not the bottom."},
   {"text": "A maximum of 1", "feedback": "1 is where the vertex sits along x. The max or min VALUE is the k, the height of the vertex."},
   {"text": "A minimum of -2", "feedback": "-2 is the stretch factor a. It tells you which way the parabola opens, not its value there."}]'::jsonb,
 0, 'sub-max-min'),

(11, 'MCR3U', 'Functions', 1, 15, 'Medium',
 'Multiply and simplify fully: 2√3 × 4√6',
 '[{"text": "72√2", "feedback": "When the 9 leaves the radical it becomes 3, not 9. Multiply 8 by 3."},
   {"text": "24√2", "feedback": "Correct."},
   {"text": "8√18", "feedback": "The multiplication is right but 18 still hides a perfect square. Pull the 9 out."},
   {"text": "6√18", "feedback": "The numbers out front multiply, they do not add: 2 × 4, not 2 + 4."}]'::jsonb,
 1, 'sub-radicals'),

(11, 'MCR3U', 'Functions', 1, 16, 'Medium',
 'Solve: 2x² - 8x - 42 = 0',
 '[{"text": "x = -7 or x = 3", "feedback": "This is the factor pair itself, read straight off as the roots. Each bracket still has to be set to zero and solved."},
   {"text": "x = 7 or x = 3", "feedback": "Two positive roots would add to a positive middle term, and this one has -4x after dividing out the 2."},
   {"text": "x = 21 or x = -1", "feedback": "21 and -1 multiply to -21, but they add to 20, and the pair must add to -4."},
   {"text": "x = 7 or x = -3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-solve-factoring'),

(11, 'MCR3U', 'Functions', 1, 17, 'Medium',
 'Solve: -6 = x² - 5x',
 '[{"text": "x = 6 or x = -1", "feedback": "Moving the -6 across makes it +6, so the equation ends in +6, not -6."},
   {"text": "x = 0 or x = 5", "feedback": "That solves x² - 5x = 0. The -6 disappeared before it was moved across."},
   {"text": "x = 2 or x = 3", "feedback": "Correct."},
   {"text": "x = -2 or x = -3", "feedback": "The factors (x - 2)(x - 3) each flip sign when set to zero. Solve x - 2 = 0 carefully."}]'::jsonb,
 2, 'sub-solve-factoring'),

(11, 'MCR3U', 'Functions', 1, 18, 'Medium',
 'Use the quadratic formula to solve: 2x² + 7x - 4 = 0',
 '[{"text": "x = 1 or x = -8", "feedback": "The denominator is 2a = 4, not 2. Everything gets divided by 4."},
   {"text": "x = 1/2 or x = -4", "feedback": "Correct."},
   {"text": "x = -1/2 or x = 4", "feedback": "The formula starts with MINUS b. With b = 7 that opening term is -7, and these two came from +7."},
   {"text": "x = (-7 ± √17)/4", "feedback": "The discriminant is 49 - 4(2)(-4). Subtracting a negative ADDS 32, it does not take 32 away."}]'::jsonb,
 1, 'sub-quadratic-formula'),

(11, 'MCR3U', 'Functions', 1, 19, 'Medium',
 'Find the x-coordinates where the line y = 2x + 3 meets the parabola y = x².',
 '[{"text": "x = 1 and x = 3", "feedback": "Check by multiplying: (x - 1)(x - 3) ends in +3, and this equation ends in -3."},
   {"text": "They never meet", "feedback": "The discriminant is 4 - 4(1)(-3), and subtracting a negative makes it positive, not negative."},
   {"text": "x = 3 and x = -1", "feedback": "Correct."},
   {"text": "x = -3 and x = 1", "feedback": "x² - 2x - 3 factors as (x - 3)(x + 1). Each bracket flips sign when solved."}]'::jsonb,
 2, 'sub-linear-quadratic'),

(11, 'MCR3U', 'Functions', 1, 20, 'Medium',
 'A line is substituted into a parabola and the resulting quadratic has a discriminant of exactly zero. What does this mean?',
 '[{"text": "The line passes through the vertex", "feedback": "A tangent line can touch anywhere on the curve. The vertex is not special here."},
   {"text": "The line touches the parabola at exactly one point", "feedback": "Correct."},
   {"text": "The line misses the parabola entirely", "feedback": "Missing entirely is the NEGATIVE discriminant case — no real solutions at all."},
   {"text": "The line crosses the parabola at two points", "feedback": "Two crossings need two different solutions, which takes a positive discriminant."}]'::jsonb,
 1, 'sub-linear-quadratic'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): multi-step, word problems, choosing the method.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Functions', 1, 21, 'Challenge',
 'What is the range of y = -3(x - 2)² + 5?',
 '[{"text": "y ≥ 5", "feedback": "The negative a opens this parabola downward, so 5 is the ceiling, not the floor."},
   {"text": "y ≤ 2", "feedback": "2 is the x-coordinate of the vertex. The range is measured in y, from the k value."},
   {"text": "All real numbers", "feedback": "A parabola is capped at its vertex on one side. Only its domain runs over all the reals."},
   {"text": "y ≤ 5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-domain-range'),

(11, 'MCR3U', 'Functions', 1, 22, 'Challenge',
 'If f(x) = x² + 2x, find all values of x for which f(x) = 15.',
 '[{"text": "x = -3 or x = 5", "feedback": "x² + 2x - 15 factors as (x + 5)(x - 3). Solve each bracket and watch the signs flip."},
   {"text": "x = 3 only", "feedback": "The equation is quadratic, and this one genuinely has two solutions. Nothing rules the negative one out."},
   {"text": "x = 5 or x = 3", "feedback": "5 and 3 multiply to 15, but after moving 15 across, the pair must multiply to -15 and add to +2."},
   {"text": "x = 3 or x = -5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-function-notation'),

(11, 'MCR3U', 'Functions', 1, 23, 'Challenge',
 'A repair company charges by C(n) = 25n + 500, where n is the number of hours. What does C(40) cost?',
 '[{"text": "1000", "feedback": "That is the hourly part alone. The fixed 500 is charged on top of it."},
   {"text": "540", "feedback": "That adds 40 to the 500 and drops the 25. The 25 multiplies the hours."},
   {"text": "12500", "feedback": "That put the 500 in as the number of hours. The input to C is 40."},
   {"text": "1500", "feedback": "Correct."}]'::jsonb,
 3, 'sub-function-notation'),

(11, 'MCR3U', 'Functions', 1, 24, 'Challenge',
 'By completing the square, find the minimum value of y = 2x² - 12x + 7.',
 '[{"text": "3", "feedback": "3 is the x-value where the minimum happens. The minimum itself is the y-value there."},
   {"text": "7", "feedback": "The constant term is only the minimum when there is no x term to shift the vertex — and this has -12x."},
   {"text": "-11", "feedback": "Correct."},
   {"text": "-2", "feedback": "The 9 completed inside the bracket sits behind a factor of 2, so 18 comes off the constant, not 9."}]'::jsonb,
 2, 'sub-max-min'),

(11, 'MCR3U', 'Functions', 1, 25, 'Challenge',
 'A rectangle has a perimeter of 40 m. What is the largest area it can enclose?',
 '[{"text": "100 m²", "feedback": "Correct."},
   {"text": "400 m²", "feedback": "Length plus width is 20, so the sides cannot BOTH be 20. Each side of the best square is half of that."},
   {"text": "40 m²", "feedback": "That repeats the perimeter. The area comes from multiplying the two sides."},
   {"text": "96 m²", "feedback": "12 by 8 fits the perimeter but is not the top of the curve. The maximum happens when the sides are equal."}]'::jsonb,
 0, 'sub-max-min'),

(11, 'MCR3U', 'Functions', 1, 26, 'Challenge',
 'Expand and simplify: (3 + √2)(3 - √2)',
 '[{"text": "9", "feedback": "The middle terms cancel, but √2 × √2 = 2 survives and must be subtracted."},
   {"text": "11 - 6√2", "feedback": "That squares (3 - √2) instead of multiplying the two different brackets together."},
   {"text": "7", "feedback": "Correct."},
   {"text": "11", "feedback": "The product of conjugates SUBTRACTS the squares: the √2 terms cancel and their product comes off the 9."}]'::jsonb,
 2, 'sub-radicals'),

(11, 'MCR3U', 'Functions', 1, 27, 'Challenge',
 'A ball follows h = -5t² + 20t, with h in metres and t in seconds. When does it hit the ground?',
 '[{"text": "t = 2", "feedback": "That is the top of the flight — the vertex. The ground is where h returns to zero."},
   {"text": "t = 0", "feedback": "That is the launch moment. The question asks when it comes back down."},
   {"text": "t = -4", "feedback": "Factoring gives t(-5t + 20) = 0, and -5t + 20 = 0 solves to a positive time."},
   {"text": "t = 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-solve-factoring'),

(11, 'MCR3U', 'Functions', 1, 28, 'Challenge',
 'How many real solutions does 3x² - 2x + 5 = 0 have?',
 '[{"text": "It cannot be determined without graphing", "feedback": "The discriminant settles it from the coefficients alone — that is the whole point of it."},
   {"text": "None", "feedback": "Correct."},
   {"text": "Two", "feedback": "The discriminant is 4 - 60, which is negative. A negative discriminant leaves nothing to square root."},
   {"text": "One", "feedback": "Exactly one solution needs the discriminant to be exactly zero, and 4 - 60 is well below zero."}]'::jsonb,
 1, 'sub-quadratic-formula'),

(11, 'MCR3U', 'Functions', 1, 29, 'Challenge',
 'Solve 3x² - 5x - 1 = 0, giving the exact answer.',
 '[{"text": "x = (5 ± √37)/3", "feedback": "The denominator is 2a, which is 6 here, not 3."},
   {"text": "x = (5 ± √37)/6", "feedback": "Correct."},
   {"text": "x = (-5 ± √37)/6", "feedback": "The formula opens with -b, and b here is -5, so the front becomes +5."},
   {"text": "x = (5 ± √13)/6", "feedback": "The discriminant is 25 - 4(3)(-1). With c negative, the 12 is ADDED to 25."}]'::jsonb,
 1, 'sub-quadratic-formula'),

(11, 'MCR3U', 'Functions', 1, 30, 'Challenge',
 'Find the points where the line y = x - 5 meets the parabola y = x² - 2x - 3.',
 '[{"text": "(1, -4) only", "feedback": "The algebra produced two x-values, and both are genuine crossings. Neither can be discarded."},
   {"text": "(-1, -6) and (-2, -7)", "feedback": "x² - 3x + 2 factors as (x - 1)(x - 2), and each bracket solves to a POSITIVE x."},
   {"text": "They never meet", "feedback": "The discriminant of x² - 3x + 2 is 9 - 8, which is positive, so there are two crossings."},
   {"text": "(1, -4) and (2, -3)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-linear-quadratic'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): parameters, combined subtopics, the 90s-from-70s tier.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Functions', 1, 31, 'Advanced',
 'What is the domain of f(x) = 1/√(3 - x)?',
 '[{"text": "x ≤ 3", "feedback": "x = 3 makes the inside zero, and the root of zero sits in the denominator. Division by zero rules that point out."},
   {"text": "x > 3", "feedback": "The inequality points the wrong way: 3 - x must stay positive, which happens for SMALL x, not large."},
   {"text": "x ≠ 3", "feedback": "That only removes one point. Every x above 3 makes the inside negative, and a negative cannot sit under the root."},
   {"text": "x < 3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-domain-range'),

(11, 'MCR3U', 'Functions', 1, 32, 'Advanced',
 'What is the range of f(x) = √(x - 2) + 3?',
 '[{"text": "y > 3", "feedback": "At x = 2 the root is exactly zero, so the output 3 is actually reached."},
   {"text": "y ≥ 3", "feedback": "Correct."},
   {"text": "y ≥ 2", "feedback": "The 2 shifts the graph sideways, which changes the domain. It is the + 3 that sets the lowest output."},
   {"text": "y ≥ 0", "feedback": "The bare root starts at zero, but the + 3 lifts every output up by three."}]'::jsonb,
 1, 'sub-domain-range'),

(11, 'MCR3U', 'Functions', 1, 33, 'Advanced',
 'If f(x) = 4x - 1, solve f(2a) = f(a) + 9 for a.',
 '[{"text": "a = 9/8", "feedback": "The 4a on the right has to come across before dividing: 8a - 4a leaves 4a, not 8a."},
   {"text": "a = -9/4", "feedback": "The two -1 terms cancel, and moving 4a to the left keeps the 9 positive."},
   {"text": "a = 9/4", "feedback": "Correct."},
   {"text": "a = 5/2", "feedback": "f(2a) means substituting 2a into the rule: 4(2a) - 1. It is not 2 times f(a), which would double the -1 as well."}]'::jsonb,
 2, 'sub-function-notation'),

(11, 'MCR3U', 'Functions', 1, 34, 'Advanced',
 E'Tickets cost $8 and 200 people attend. Each $1 increase in price loses 10 attendees.\nWhat ticket price gives the maximum revenue?',
 '[{"text": "$8", "feedback": "Staying put is not optimal: the revenue expression is a downward parabola whose vertex sits at a higher price."},
   {"text": "$20", "feedback": "By $20 the lost attendees outweigh the higher price. Find the vertex of (8 + x)(200 - 10x) rather than guessing high."},
   {"text": "$14", "feedback": "Correct."},
   {"text": "$6", "feedback": "That is the number of increases at the vertex, not the price. The increases are added onto the original $8."}]'::jsonb,
 2, 'sub-max-min'),

(11, 'MCR3U', 'Functions', 1, 35, 'Advanced',
 'Simplify fully: √12 + √27',
 '[{"text": "√39", "feedback": "Roots do not add through the radicand: √12 + √27 is not √(12 + 27). Simplify each first."},
   {"text": "6√3", "feedback": "The coefficients 2 and 3 are ADDED once the radicands match, not multiplied."},
   {"text": "5√6", "feedback": "Both radicals simplify to a radicand of 3: check 12 = 4 × 3 and 27 = 9 × 3."},
   {"text": "5√3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-radicals'),

(11, 'MCR3U', 'Functions', 1, 36, 'Advanced',
 'Evaluate: (2√5)²',
 '[{"text": "4√5", "feedback": "The 2 was squared but the radical was left standing. Squaring removes the root entirely."},
   {"text": "20", "feedback": "Correct."},
   {"text": "10", "feedback": "Only the radical was squared. The 2 out front gets squared as well."},
   {"text": "100", "feedback": "Squaring √5 gives 5, not 25. The root and the square undo each other."}]'::jsonb,
 1, 'sub-radicals'),

(11, 'MCR3U', 'Functions', 1, 37, 'Advanced',
 'Solve: 3x² + 10x - 8 = 0',
 '[{"text": "x = -4/3 or x = 2", "feedback": "Check the middle term: (3x + 4)(x - 2) gives -2x, and this equation needs +10x."},
   {"text": "x = 2/3 or x = -4", "feedback": "Correct."},
   {"text": "x = -2/3 or x = 4", "feedback": "The factors are (3x - 2)(x + 4). Setting 3x - 2 = 0 gives a positive fraction."},
   {"text": "x = 2 or x = -4", "feedback": "The first factor is 3x - 2, and its 3 divides the root: the solution is a third of 2."}]'::jsonb,
 1, 'sub-solve-factoring'),

(11, 'MCR3U', 'Functions', 1, 38, 'Advanced',
 'For what values of k does x² + kx + 9 = 0 have exactly one real solution?',
 '[{"text": "k = 18 or k = -18", "feedback": "4ac is 4 times 9, not 4 times 9 squared. Keep the 9 un-squared."},
   {"text": "k = 6 or k = -6", "feedback": "Correct."},
   {"text": "k = 6 only", "feedback": "k² = 36 has two solutions, one on each side of zero, and both make the discriminant vanish."},
   {"text": "k = 3 or k = -3", "feedback": "The discriminant needs k² = 4ac = 4 × 1 × 9, which is 36, not 9."}]'::jsonb,
 1, 'sub-quadratic-formula'),

(11, 'MCR3U', 'Functions', 1, 39, 'Advanced',
 E'A rectangle is 3 m longer than it is wide, and its area is 30 m².\nWhat is its exact width?',
 '[{"text": "(-3 + √129)/2 m", "feedback": "Correct."},
   {"text": "(3 + √129)/2 m", "feedback": "In w² + 3w - 30 = 0, b is +3, so the formula opens with MINUS 3."},
   {"text": "There is no real width", "feedback": "The discriminant is 9 - 4(1)(-30), and subtracting a negative adds 120 — it is comfortably positive."},
   {"text": "(-3 + √129) m", "feedback": "The whole expression is divided by 2a = 2, the root included."}]'::jsonb,
 0, 'sub-quadratic-formula'),

(11, 'MCR3U', 'Functions', 1, 40, 'Advanced',
 'For what value of k is the line y = 2x + k tangent to the parabola y = x² + 3x + 5?',
 '[{"text": "k = 19/4", "feedback": "Correct."},
   {"text": "k = -19/4", "feedback": "From 1 - 4(5 - k) = 0, expanding gives -20 + 4k, and solving that keeps k positive."},
   {"text": "k = 21/4", "feedback": "The 4ac term has been added here instead of subtracted. The discriminant is b² - 4ac."},
   {"text": "k = 5", "feedback": "Matching the constant terms is not tangency. Tangency is the combined discriminant hitting exactly zero."}]'::jsonb,
 0, 'sub-linear-quadratic');

-- --- questions_mcr3u_u2.sql ---

-- ===========================================================================
-- MCR3U — Unit 2: Rational Expressions — 40 questions
-- ===========================================================================
-- Grade 11 Rational Expressions, authored from the Jensen MCR3U lesson
-- material for this unit:
--
--   Lesson 1  Review of exponent rules
--   Lesson 2  Rational exponents
--   Lesson 3  Restricting, simplifying, multiplying and dividing
--   Lesson 4  Adding and subtracting rational expressions
--
-- Restrictions are pulled out as their own subtopic rather than being folded
-- into Lesson 3. Stating them is where students in this unit actually lose
-- marks, and it is the one skill that carries forward into every later unit,
-- so it deserves its own traffic light on the dashboard.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every answer in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs. Two of the Jensen
-- worked solutions state an incomplete restriction set part-way through
-- (their own answer keys correct it later) and those omissions are used
-- here as distractors rather than as answers.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own
-- at any time; the delete at the top makes a corrected copy replace the unit
-- cleanly, and student attempts (keyed on course, unit and sort_order)
-- survive the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
--
-- No figures. Every question here is symbolic; the one candidate for a
-- picture, the hole in the graph of a cancelled factor, puts the answer on
-- the diagram and so was rejected.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Rational Expressions';

insert into misconception_labels (tag, label) values
  ('sub-exponent-rules',      'Exponent rules'),
  ('sub-rational-exponents',  'Rational exponents'),
  ('sub-restrictions',        'Restrictions on the variable'),
  ('sub-simplify-mult-div',   'Simplifying, multiplying and dividing'),
  ('sub-add-subtract-rat',    'Adding and subtracting')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 1, 'Easy',
 'Simplify: x⁵ × x³',
 '[{"text": "x¹⁵", "feedback": "That multiplies the exponents. Multiplying powers of the same base adds them instead."},
   {"text": "x⁸", "feedback": "Correct."},
   {"text": "x²", "feedback": "That subtracts the exponents, which is the rule for dividing powers, not multiplying."},
   {"text": "2x⁸", "feedback": "The two bases do not add together to make a coefficient. There is still only one x being built up."}]'::jsonb,
 1, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 2, 'Easy',
 'Simplify: (x⁴)³',
 '[{"text": "x⁷", "feedback": "That adds the exponents. A power raised to another power multiplies them."},
   {"text": "x⁴", "feedback": "The outer exponent 3 was ignored entirely."},
   {"text": "3x⁴", "feedback": "The outer 3 was turned into a coefficient. It is an exponent acting on the whole power."},
   {"text": "x¹²", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 3, 'Easy',
 'Write ∛x using a rational exponent.',
 '[{"text": "x^(1/3)", "feedback": "Correct."},
   {"text": "x³", "feedback": "The index of the root became a whole-number power. A root is a fractional power."},
   {"text": "3x", "feedback": "The index was turned into a multiplier. It belongs on the bottom of the exponent."},
   {"text": "x^(-3)", "feedback": "A root is not a reciprocal power. Nothing here flips the base."}]'::jsonb,
 0, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 4, 'Easy',
 'Evaluate: 8^(1/3)',
 '[{"text": "24", "feedback": "That multiplies 8 by 3. A fractional exponent asks for a root, not a product."},
   {"text": "512", "feedback": "That cubes the 8. An exponent of one third undoes a cube, it does not apply one."},
   {"text": "2", "feedback": "Correct."},
   {"text": "8/3", "feedback": "That divides 8 by 3. The 3 on the bottom of the exponent is the index of a root."}]'::jsonb,
 2, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 5, 'Easy',
 'State the restriction on the variable: (x + 2)/(x - 5)',
 '[{"text": "x ≠ -5", "feedback": "Solving x - 5 = 0 moves the 5 across as a positive number."},
   {"text": "x ≠ 5", "feedback": "Correct."},
   {"text": "x ≠ -2", "feedback": "That is the value making the numerator zero. A zero on top is allowed; only the bottom is forbidden."},
   {"text": "x ≠ 0", "feedback": "The denominator here is x - 5, not x on its own, so it reaches zero somewhere other than the origin."}]'::jsonb,
 1, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 6, 'Easy',
 'State all restrictions on the variable: 7/(x(x + 3))',
 '[{"text": "x ≠ 0 and x ≠ 3", "feedback": "The bracket x + 3 hits zero at a negative value. The sign flips when the bracket is solved."},
   {"text": "x ≠ -3 only", "feedback": "There are two factors on the bottom, and the bare x is one of them."},
   {"text": "x ≠ 0 only", "feedback": "The bracket x + 3 can reach zero as well, and that value is forbidden too."},
   {"text": "x ≠ 0 and x ≠ -3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 7, 'Easy',
 'Simplify: 3x²/(yx)',
 '[{"text": "3x/y", "feedback": "Correct."},
   {"text": "3x³/y", "feedback": "The x exponents were added. Dividing powers of the same base subtracts them."},
   {"text": "3/y", "feedback": "The whole x² was cancelled against a single x. Only one factor of x is available to cancel."},
   {"text": "3xy", "feedback": "The y was moved to the top. Cancelling never relocates a factor that has no partner."}]'::jsonb,
 0, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 8, 'Easy',
 'Simplify: (x² + 10x + 21)/(x + 3)',
 '[{"text": "x + 3", "feedback": "The bracket that cancels is the one matching the bottom. What survives is the other factor."},
   {"text": "(x² + 10x + 21)/x", "feedback": "Only the number 3 was struck out. Cancelling works on whole factors, never on one term inside a bracket."},
   {"text": "x + 7", "feedback": "Correct."},
   {"text": "7", "feedback": "The x and the 3 were struck out separately. A bracket cancels as one piece or not at all."}]'::jsonb,
 2, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 9, 'Easy',
 'Simplify: 3/x + 4/x',
 '[{"text": "7/(2x)", "feedback": "The denominators were added as well. With a common denominator already in place it stays exactly as it is."},
   {"text": "12/x²", "feedback": "The two fractions were multiplied. The sign between them is a plus."},
   {"text": "1/x", "feedback": "That subtracts the numerators. Read the sign between the two fractions again."},
   {"text": "7/x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 10, 'Easy',
 'Simplify: 1/(5x) + 1/(2x)',
 '[{"text": "2/(7x)", "feedback": "Numerators and denominators were added straight across. Fractions are never combined that way."},
   {"text": "7/(10x)", "feedback": "Correct."},
   {"text": "2/(10x)", "feedback": "The common denominator is right, but the numerators were not rescaled to match it."},
   {"text": "7/(10x²)", "feedback": "The x was multiplied along with the numbers. Each denominator already carries exactly one x."}]'::jsonb,
 1, 'sub-add-subtract-rat'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 11, 'Medium',
 'Simplify, leaving only positive exponents: 12k²m⁸/(4k⁵m⁵)',
 '[{"text": "3k³m³", "feedback": "The k exponents were subtracted the wrong way round. The larger power of k sits on the bottom here."},
   {"text": "3k⁷m¹³", "feedback": "The exponents were added. Division subtracts them."},
   {"text": "3m³/k³", "feedback": "Correct."},
   {"text": "8m³/k³", "feedback": "The coefficients were subtracted: 12 take away 4. Coefficients divide, they do not subtract."}]'::jsonb,
 2, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 12, 'Medium',
 'Simplify: (3xy)³/(9x⁴y⁴)',
 '[{"text": "3/(xy)", "feedback": "Correct."},
   {"text": "1/(3xy)", "feedback": "The 3 inside the bracket was not cubed. Everything inside takes the outer power."},
   {"text": "3xy", "feedback": "The exponents were subtracted the wrong way round. The denominator carries the larger powers."},
   {"text": "3x⁷y⁷", "feedback": "The exponents were added instead of subtracted."}]'::jsonb,
 0, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 13, 'Medium',
 'Evaluate: 8^(2/3)',
 '[{"text": "2", "feedback": "The cube root was taken and then the power 2 was never applied."},
   {"text": "64", "feedback": "That squares 8 and forgets the 3 on the bottom of the exponent."},
   {"text": "16/3", "feedback": "That multiplies 8 by two thirds. A fractional exponent is a root and a power, not a product."},
   {"text": "4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 14, 'Medium',
 'Evaluate: 81^(5/4)',
 '[{"text": "3", "feedback": "The fourth root was taken and the power 5 was never applied."},
   {"text": "243", "feedback": "Correct."},
   {"text": "405", "feedback": "That multiplies 81 by 5. The 5 is an exponent applied to the root, not a multiplier."},
   {"text": "15", "feedback": "The fourth root was found correctly and then multiplied by 5 instead of being raised to the power 5."}]'::jsonb,
 1, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 15, 'Medium',
 'State all restrictions on the variable: (x - 3)/(x² + 3x - 18)',
 '[{"text": "x ≠ -6, with no other restriction", "feedback": "The expression cancels down to a single bracket, but the restriction from the cancelled factor still stands."},
   {"text": "x ≠ 6 and x ≠ -3", "feedback": "The numbers were copied straight out of the brackets as the restricted values. Each bracket still has to be set to zero and solved."},
   {"text": "x ≠ -6 and x ≠ 3", "feedback": "Correct."},
   {"text": "x ≠ 3, with no other restriction", "feedback": "The denominator has two factors, and both of them can reach zero."}]'::jsonb,
 2, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 16, 'Medium',
 'State all restrictions on the variable: (x + 12)/(x + 10) ÷ (x + 12)/(x - 5)',
 '[{"text": "x ≠ -10, x ≠ -12 and x ≠ 5", "feedback": "Correct."},
   {"text": "x ≠ -10 and x ≠ 5", "feedback": "Once the second fraction is flipped, its numerator becomes a denominator, so that bracket is restricted too."},
   {"text": "x ≠ -10 only", "feedback": "A division brings two more brackets into play: the one being divided by, and the one it turns into after the flip."},
   {"text": "x ≠ -10 and x ≠ -12", "feedback": "The second fraction has a denominator of its own before the flip, and that value is forbidden as well."}]'::jsonb,
 0, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 17, 'Medium',
 'Simplify: (x² - 9)/(x² + 7x + 12)',
 '[{"text": "-9/(7x + 12)", "feedback": "The x² terms were struck out across a subtraction and an addition. Cancelling works only on whole factors."},
   {"text": "(x - 3)/(x + 3)", "feedback": "The bracket that goes is the one appearing on both the top and the bottom. Check which factor the two share."},
   {"text": "(x + 3)/(x + 4)", "feedback": "A difference of squares factors into one plus bracket and one minus bracket, not two pluses."},
   {"text": "(x - 3)/(x + 4)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 18, 'Medium',
 'Simplify: (4x + 24)/(x² + 8x) × 12x²/(3x + 18)',
 '[{"text": "48x/(x + 8)", "feedback": "The 3 in the second denominator was never divided out."},
   {"text": "16x/(x + 8)", "feedback": "Correct."},
   {"text": "16x²/(x + 8)", "feedback": "One factor of x on the bottom was left uncancelled. There is an x hiding inside x² + 8x."},
   {"text": "16/(x + 8)", "feedback": "Both factors of x on the top were cancelled, but the bottom only offers one to cancel against."}]'::jsonb,
 1, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 19, 'Medium',
 'Simplify: 5/(7x) - 3/(4x)',
 '[{"text": "-1/(28x)", "feedback": "Correct."},
   {"text": "1/(28x)", "feedback": "The subtraction ran the wrong way round: 21 taken from 20 lands below zero."},
   {"text": "2/(3x)", "feedback": "Numerators and denominators were subtracted straight across. Fractions are never combined that way."},
   {"text": "41/(28x)", "feedback": "The two rescaled numerators were added instead of subtracted."}]'::jsonb,
 0, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 20, 'Medium',
 'Simplify: 4/(ab) + 9/(2b)',
 '[{"text": "13/(ab + 2b)", "feedback": "Numerators and denominators were added straight across. Fractions are never combined that way."},
   {"text": "13/(2ab²)", "feedback": "The numerators were added and the denominators multiplied. A common denominator is not the product of everything in sight."},
   {"text": "(8 + 9a)/(2ab)", "feedback": "Correct."},
   {"text": "17/(2ab)", "feedback": "The denominators were brought to 2ab correctly, but the numerators were not rescaled by the same factors."}]'::jsonb,
 2, 'sub-add-subtract-rat'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): multi-step, choosing the method, stating what is hidden.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 21, 'Challenge',
 'Simplify, leaving only positive exponents: (2z³)⁻²/(w⁵z²)',
 '[{"text": "1/(2w⁵z⁸)", "feedback": "The 2 inside the bracket also takes the power -2, so it lands on the bottom as 4 rather than 2."},
   {"text": "1/(4w⁵z⁸)", "feedback": "Correct."},
   {"text": "1/(4w⁵z⁴)", "feedback": "The z exponents were combined by adding. The z² sits on the bottom, so its power is taken away."},
   {"text": "-1/(4w⁵z⁸)", "feedback": "A minus in the exponent moves the power across the fraction bar. It never becomes a minus sign out front."}]'::jsonb,
 1, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 22, 'Challenge',
 'Simplify, leaving only positive exponents: (x⁻⁴)⁵x³/(3x⁻¹)',
 '[{"text": "1/(3x¹⁸)", "feedback": "Dividing by x to the power -1 subtracts a negative, which adds one to the exponent rather than taking one away."},
   {"text": "x¹⁶/3", "feedback": "The exponent finished negative, so the power belongs on the bottom of the fraction."},
   {"text": "1/(3x¹⁷)", "feedback": "The x to the power -1 in the denominator was never dealt with at all."},
   {"text": "1/(3x¹⁶)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 23, 'Challenge',
 'Simplify: (5x^(1/2))² × 4x^(-1/2)',
 '[{"text": "20√x", "feedback": "Only the x inside the bracket was squared. The 5 takes the outer power as well."},
   {"text": "40√x", "feedback": "The 5 was doubled rather than squared."},
   {"text": "100√x", "feedback": "Correct."},
   {"text": "100x^(3/2)", "feedback": "The minus on the second exponent was dropped, so the two half-powers were added instead of one being taken away."}]'::jsonb,
 2, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 24, 'Challenge',
 'Evaluate: (49/81)^(-3/2)',
 '[{"text": "729/343", "feedback": "Correct."},
   {"text": "343/729", "feedback": "A negative exponent flips the base before the power is applied, and this is what the same power gives without that flip."},
   {"text": "9/7", "feedback": "The base was flipped and square rooted, but the 3 on the top of the exponent was never applied."},
   {"text": "-729/343", "feedback": "A negative exponent turns the fraction over. It does not make the value negative."}]'::jsonb,
 0, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 25, 'Challenge',
 E'State ALL restrictions on the variable:\n(x² - 7x + 10)/(x² - 4) ÷ (x² - 4x - 5)/(3x + 6)',
 '[{"text": "x ≠ -2 and x ≠ 2", "feedback": "Only the first denominator was checked. A division adds the thing being divided by to the list of what cannot be zero."},
   {"text": "x ≠ -2, x ≠ -1 and x ≠ 2", "feedback": "The expression being divided by factors into two brackets, and only one of them was recorded."},
   {"text": "x ≠ -1 only", "feedback": "Those are the restrictions of the simplified result. The original expression forbids more values than that."},
   {"text": "x ≠ -2, x ≠ -1, x ≠ 2 and x ≠ 5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 26, 'Challenge',
 'State all restrictions on the variable: (2x² + 7x - 15)/(2x² + 3x - 9)',
 '[{"text": "x ≠ -3, with no other restriction", "feedback": "The denominator has two factors, and the one that cancels away still counts."},
   {"text": "x ≠ -3 and x ≠ 3/2", "feedback": "Correct."},
   {"text": "x ≠ 3/2, with no other restriction", "feedback": "The bracket x + 3 on the bottom also reaches zero, and that value is forbidden too."},
   {"text": "x ≠ -5 and x ≠ 3/2", "feedback": "The value -5 comes from the numerator. A zero on the top is perfectly legal."}]'::jsonb,
 1, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 27, 'Challenge',
 'Simplify: (6x² - 7x - 5)/(3x² + x - 10)',
 '[{"text": "(2x + 1)/(x + 2)", "feedback": "Correct."},
   {"text": "(2x - 1)/(x + 2)", "feedback": "Multiply the numerator factors back out: pairing 2x - 1 with 3x - 5 gives a constant of +5, and this numerator ends in -5."},
   {"text": "(2x + 1)/(x - 2)", "feedback": "Multiply the denominator factors back out: that version ends in +10, and this denominator ends in -10."},
   {"text": "(2x + 1)/(3x - 5)", "feedback": "The shared bracket 3x - 5 is what cancels, and it has to go from the top and the bottom at the same time."}]'::jsonb,
 0, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 28, 'Challenge',
 E'Simplify:\n(2x² - 8x)/(x² - 3x - 10) ÷ 4x²/(x² - 9x + 20)',
 '[{"text": "8x³/((x - 5)²(x + 2))", "feedback": "The second fraction was multiplied in as it stood. Dividing means turning it over first."},
   {"text": "2x(x + 2)/(x - 4)²", "feedback": "The wrong fraction was flipped. It is the one after the division sign that turns over."},
   {"text": "(x - 4)²/(2x(x + 2))", "feedback": "Correct."},
   {"text": "(x - 4)²/(2x(x - 2))", "feedback": "x² - 3x - 10 needs a pair multiplying to -10, so one of the two numbers has to be positive."}]'::jsonb,
 2, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 29, 'Challenge',
 'Simplify: 2/(x - 3) - 5/(x + 3)',
 '[{"text": "(-3x - 9)/((x - 3)(x + 3))", "feedback": "The minus reached the 5x but not the -15 behind it. It has to hit every term in the bracket."},
   {"text": "(-3x + 21)/((x - 3)(x + 3))", "feedback": "Correct."},
   {"text": "(7x - 9)/((x - 3)(x + 3))", "feedback": "The two rescaled numerators were added. The sign between the fractions is a minus."},
   {"text": "-3/((x - 3)(x + 3))", "feedback": "The numerators were subtracted as they stood, without first being rescaled by the bracket each one was missing."}]'::jsonb,
 1, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 30, 'Challenge',
 'Simplify: 4x/(x² - 9x + 18) + (2x - 1)/(x - 6)',
 '[{"text": "(6x - 1)/((x - 3)(x - 6))", "feedback": "The numerators were added as they stood. The second one still needs rescaling by the bracket it is missing."},
   {"text": "(2x² - 9x + 6)/((x - 3)(x - 6))", "feedback": "The second fraction was rescaled by x - 6, which it already has. The bracket it lacks is x - 3."},
   {"text": "(2x² - 3x + 3)/((x² - 9x + 18)(x - 6))", "feedback": "The denominators were multiplied together. One of them already contains the other as a factor."},
   {"text": "(2x² - 3x + 3)/((x - 3)(x - 6))", "feedback": "Correct."}]'::jsonb,
 3, 'sub-add-subtract-rat'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): combined subtopics, the 90s-from-70s tier.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 31, 'Advanced',
 'Simplify: (5c³d × 4c²d²)/((2c²d)²)',
 '[{"text": "5cd", "feedback": "Correct."},
   {"text": "10cd", "feedback": "The 2 inside the bracket was not squared. Everything inside a bracket takes the outer power."},
   {"text": "5cd²", "feedback": "The d inside the bracket was left un-squared while the c was squared."},
   {"text": "5c⁹d⁵", "feedback": "The exponents were added across the fraction bar. Division subtracts them."}]'::jsonb,
 0, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 32, 'Advanced',
 'Which expression is equal to (a + b)⁻¹?',
 '[{"text": "1/a + 1/b", "feedback": "A negative exponent does not spread over a sum. Try a = 1 and b = 1 and watch the two disagree."},
   {"text": "-(a + b)", "feedback": "A negative exponent turns the expression over. It does not change its sign."},
   {"text": "1/(a + b)", "feedback": "Correct."},
   {"text": "a⁻¹b⁻¹", "feedback": "That treats the plus as a multiplication. The power applies to the whole sum as one object."}]'::jsonb,
 2, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 33, 'Advanced',
 E'Simplify, leaving only positive exponents:\n((m⁻²)³√(m⁴))/(m√(pq⁻³))',
 '[{"text": "m⁵q^(3/2)/√p", "feedback": "The m exponent finished negative, so that power belongs on the bottom of the fraction."},
   {"text": "q^(3/2)/(m⁵√p)", "feedback": "Correct."},
   {"text": "1/(m⁵√p q^(3/2))", "feedback": "The q carried a negative exponent inside the root on the bottom, so it travels up to the top."},
   {"text": "q^(3/2)/(m⁴√p)", "feedback": "The lone m in the denominator was never divided out, and it costs one more power of m."}]'::jsonb,
 1, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 34, 'Advanced',
 'Simplify, leaving only positive exponents: (y^(1/4))² × (y^(-1/3))²',
 '[{"text": "y^(1/6)", "feedback": "The combined exponent finishes negative, because two thirds is larger than one half."},
   {"text": "1/y^(1/12)", "feedback": "The outer squares were never applied. Both exponents double before they combine."},
   {"text": "1/y^(1/3)", "feedback": "The exponents were multiplied. Multiplying powers of the same base adds them."},
   {"text": "1/y^(1/6)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 35, 'Advanced',
 E'State ALL restrictions on the variable:\n(x² + 3x + 2)/(x² - 1) × (x - 1)/(x² - 2x - 8)',
 '[{"text": "x ≠ -2, x ≠ -1, x ≠ 1 and x ≠ 4", "feedback": "Correct."},
   {"text": "x ≠ -1, x ≠ 1 and x ≠ 4", "feedback": "x² - 2x - 8 factors into two brackets, and only one of them was recorded."},
   {"text": "x ≠ -2, x ≠ 1 and x ≠ 4", "feedback": "x² - 1 is a difference of squares, so it has two roots, one on each side of zero."},
   {"text": "x ≠ 4 only", "feedback": "Those are the restrictions of the simplified result. Every bracket that cancelled on the way still counts."}]'::jsonb,
 0, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 36, 'Advanced',
 'Simplify (x² - 25)/(x² - 10x + 25) and state the restrictions.',
 '[{"text": "(x + 5)/(x - 5), with x ≠ 5 and x ≠ -5", "feedback": "The value -5 makes the numerator zero, not the denominator. A zero on the top is allowed."},
   {"text": "(x - 5)/(x + 5), with x ≠ -5", "feedback": "The denominator is a perfect square, and the bracket being squared is x - 5, not x + 5."},
   {"text": "(x + 5)/(x - 5), with x ≠ 5", "feedback": "Correct."},
   {"text": "(x + 5)/(x - 5), with no restrictions", "feedback": "Simplifying does not repair the original expression. It was already undefined at that value before any cancelling happened."}]'::jsonb,
 2, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 37, 'Advanced',
 E'Simplify:\n(x² - 1)/(x² - 4) × (x² + 3x - 4)/(x² + 5x + 4)',
 '[{"text": "(x + 1)²/((x - 2)(x + 2))", "feedback": "The bracket the two fractions share is x + 1, and it cancels away. The one left doubled is the other."},
   {"text": "(x - 1)/((x - 2)(x + 2))", "feedback": "The two x - 1 brackets come from different fractions and both survive. Only a top and a bottom cancel each other."},
   {"text": "(x - 1)²/((x + 1)(x - 2)(x + 2))", "feedback": "The x + 1 on the bottom has a partner on the top and should have gone."},
   {"text": "(x - 1)²/((x - 2)(x + 2))", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 38, 'Advanced',
 E'Simplify:\n(x² - 9)/(x² - x - 6) ÷ (x² + 7x + 12)/(x² + 2x - 8)',
 '[{"text": "(x + 2)/(x - 2)", "feedback": "The result came out upside down, which is what happens when the first fraction is flipped instead of the second."},
   {"text": "(x - 2)/(x + 2)", "feedback": "Correct."},
   {"text": "(x - 3)/(x + 2)", "feedback": "The x - 2 on the top was struck out against the x - 3 on the bottom. Brackets cancel only when they are identical."},
   {"text": "(x - 2)/(x + 3)", "feedback": "The x + 3 cancels away completely. The bracket left on the bottom comes from x² - x - 6."}]'::jsonb,
 1, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 39, 'Advanced',
 E'Simplify:\n(3x + 9)/(x² + 5x + 6) - (2x - 2)/(x² + x - 2)',
 '[{"text": "5/(x + 2)", "feedback": "The two reduced fractions were added. The sign between them is a minus."},
   {"text": "-1/(x + 2)", "feedback": "The subtraction ran backwards. It is the second numerator that comes off the first."},
   {"text": "1/(x + 2)", "feedback": "Correct."},
   {"text": "1/(x + 3)", "feedback": "Both fractions reduce to the same denominator, and it is the bracket they have in common, not the one only the first carries."}]'::jsonb,
 2, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 40, 'Advanced',
 'Simplify: (3x + 2)/(3 - 4x) + (2x + 1)/(4x - 3)',
 '[{"text": "(x + 1)/(3 - 4x)", "feedback": "Correct."},
   {"text": "(5x + 3)/(3 - 4x)", "feedback": "The two denominators differ by a factor of -1, and pulling that minus out turns the addition into a subtraction."},
   {"text": "(5x + 3)/((3 - 4x)(4x - 3))", "feedback": "The denominators were multiplied together. They are already the same apart from a factor of -1."},
   {"text": "(x + 3)/(3 - 4x)", "feedback": "The minus that came out of the second fraction reached the 2x but not the 1 behind it."}]'::jsonb,
 0, 'sub-add-subtract-rat');

-- --- questions_mcr3u_u3.sql ---

-- ===========================================================================
-- MCR3U — Unit 3: Transformations — 40 questions
-- ===========================================================================
-- Grade 11 Transformations, authored from the Jensen MCR3U lesson material
-- for this unit:
--
--   Lesson 1  Intro to transformations, the general form af[k(x - d)] + c
--   Lesson 2  Transforming y = x²
--   Lesson 3  Transforming y = √x
--   Lesson 4  Transforming y = 1/x
--   Lesson 5  Inverse of a function
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every answer in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- The two mistakes this unit exists to catch, both visible all over the
-- worked solutions:
--   * d moves the graph the OPPOSITE way to how the sign reads: x - 3 goes
--     right, x + 3 goes left. Half the distractors here are that slip.
--   * k does not scale the graph by k, it scales by 1/k. A student who reads
--     f(2x) as a stretch by 2 has it exactly backwards.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own
-- at any time; the delete at the top makes a corrected copy replace the unit
-- cleanly, and student attempts (keyed on course, unit and sort_order)
-- survive the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
--
-- No figures. This unit is the clearest case of the rejection rule in
-- AUTHORING_GUIDE.md: every candidate picture here is a graph on a grid, and
-- a graph on a grid IS the answer. The questions carry the graph in words
-- and in image points instead, which is also how the exam asks them.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Transformations';

insert into misconception_labels (tag, label) values
  ('sub-transform-basics',     'Reading a, k, d and c'),
  ('sub-transform-quadratic',  'Transforming x squared'),
  ('sub-transform-radical',    'Transforming the square root'),
  ('sub-transform-reciprocal', 'Transforming 1 over x'),
  ('sub-inverse-function',     'Inverse of a function')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Transformations', 3, 1, 'Easy',
 'In g(x) = af[k(x - d)] + c, which parameter moves the graph up and down?',
 '[{"text": "a", "feedback": "a stretches the graph vertically or flips it. Stretching pins the graph to the x-axis rather than lifting it off."},
   {"text": "d", "feedback": "d moves the graph sideways. It sits inside the bracket with the x."},
   {"text": "k", "feedback": "k stretches or squashes the graph horizontally. It sits inside the bracket too."},
   {"text": "c", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 2, 'Easy',
 'What does g(x) = f(x) + 5 do to the graph of f?',
 '[{"text": "Stretches it vertically by 5", "feedback": "A stretch multiplies the outputs, as 5f(x). Adding shifts, it does not scale."},
   {"text": "Shifts it up 5 units", "feedback": "Correct."},
   {"text": "Shifts it right 5 units", "feedback": "A sideways shift needs the 5 inside the bracket, as f(x - 5). Out here it acts on the y-values."},
   {"text": "Shifts it down 5 units", "feedback": "Adding 5 to every output raises the graph. Subtracting would lower it."}]'::jsonb,
 1, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 3, 'Easy',
 'What is the vertex of y = (x - 4)² + 1?',
 '[{"text": "(-4, 1)", "feedback": "The sign inside the bracket flips: x - 4 puts the vertex at positive 4."},
   {"text": "(1, 4)", "feedback": "The coordinates are swapped. The number inside the bracket is the x-coordinate."},
   {"text": "(4, -1)", "feedback": "The constant outside the bracket is added, so the vertex sits above the axis, not below it."},
   {"text": "(4, 1)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-quadratic'),

(11, 'MCR3U', 'Transformations', 3, 4, 'Easy',
 'How does the graph of y = -x² compare with y = x²?',
 '[{"text": "It is shifted down", "feedback": "A shift needs a number added or subtracted outside. The minus multiplies every output instead."},
   {"text": "It is compressed vertically", "feedback": "A compression needs a factor between -1 and 1. The factor here is exactly -1, so the shape is unchanged."},
   {"text": "It is reflected in the x-axis", "feedback": "Correct."},
   {"text": "It is reflected in the y-axis", "feedback": "A reflection in the y-axis needs the minus inside, as (-x)², and squaring would undo it anyway."}]'::jsonb,
 2, 'sub-transform-quadratic'),

(11, 'MCR3U', 'Transformations', 3, 5, 'Easy',
 'The graph of y = √x is moved to give y = √(x - 3). Which way did it move?',
 '[{"text": "Down 3 units", "feedback": "The 3 is inside the root, so it acts on x. A vertical move needs it outside."},
   {"text": "Up 3 units", "feedback": "The 3 is inside the root, so it acts on x, and it is being subtracted rather than added."},
   {"text": "Right 3 units", "feedback": "Correct."},
   {"text": "Left 3 units", "feedback": "The minus sign was read as the direction of travel. Inside the root the sign is the opposite of the way the graph moves."}]'::jsonb,
 2, 'sub-transform-radical'),

(11, 'MCR3U', 'Transformations', 3, 6, 'Easy',
 'Where does the graph of y = √x + 2 start?',
 '[{"text": "(2, 0)", "feedback": "The 2 sits outside the root, so it moves the graph up. Inside the root it would move it sideways."},
   {"text": "(-2, 0)", "feedback": "The 2 is outside the root and positive, so it lifts the start point rather than sliding it left."},
   {"text": "(0, 2)", "feedback": "Correct."},
   {"text": "(0, -2)", "feedback": "The 2 is being added, so the starting point rises rather than drops."}]'::jsonb,
 2, 'sub-transform-radical'),

(11, 'MCR3U', 'Transformations', 3, 7, 'Easy',
 'What is the vertical asymptote of y = 1/x?',
 '[{"text": "x = 0", "feedback": "Correct."},
   {"text": "y = 0", "feedback": "That is the HORIZONTAL asymptote. A vertical asymptote is a vertical line, so its equation names x."},
   {"text": "x = 1", "feedback": "The 1 is the numerator. The asymptote comes from what makes the DENOMINATOR zero."},
   {"text": "There is no asymptote", "feedback": "The denominator can reach zero, and where it does the function has no value at all."}]'::jsonb,
 0, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 8, 'Easy',
 'What is the vertical asymptote of y = 1/(x - 5)?',
 '[{"text": "x = -5", "feedback": "Solving x - 5 = 0 moves the 5 across as a positive number."},
   {"text": "y = 5", "feedback": "A vertical asymptote is a vertical line, so its equation names x, not y."},
   {"text": "x = 0", "feedback": "That is the parent asymptote of 1/x. The - 5 has dragged it sideways."},
   {"text": "x = 5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 9, 'Easy',
 'If f(3) = 7, what is f inverse of 7?',
 '[{"text": "3", "feedback": "Correct."},
   {"text": "7", "feedback": "That repeats the input. The inverse sends an output back to the input it came from."},
   {"text": "1/7", "feedback": "The -1 in the inverse notation is not an exponent, so nothing is being flipped over here."},
   {"text": "-3", "feedback": "The inverse swaps the coordinates. It does not change any signs."}]'::jsonb,
 0, 'sub-inverse-function'),

(11, 'MCR3U', 'Transformations', 3, 10, 'Easy',
 'The graph of the inverse of f is the graph of f reflected in which line?',
 '[{"text": "y = -x", "feedback": "That line has the right slant but the wrong sign, and reflecting in it would negate both coordinates as well as swapping them."},
   {"text": "y = x", "feedback": "Correct."},
   {"text": "The x-axis", "feedback": "Reflecting in the x-axis flips the y-values only. An inverse swaps x and y with each other."},
   {"text": "The y-axis", "feedback": "Reflecting in the y-axis flips the x-values only. An inverse swaps x and y with each other."}]'::jsonb,
 1, 'sub-inverse-function'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Transformations', 3, 11, 'Medium',
 'List the transformations in g(x) = -f(x - 3) - 4.',
 '[{"text": "Reflection in the x-axis, right 3, down 4", "feedback": "Correct."},
   {"text": "Reflection in the x-axis, left 3, down 4", "feedback": "x - d moves the graph RIGHT when d is positive. The minus sign reads the opposite way to the movement."},
   {"text": "Reflection in the y-axis, right 3, down 4", "feedback": "The minus sits outside f, so it multiplies the outputs. A y-axis reflection needs the minus inside the bracket, next to the x."},
   {"text": "Reflection in the x-axis, right 3, up 4", "feedback": "The 4 is being subtracted, so every output drops by 4."}]'::jsonb,
 0, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 12, 'Medium',
 'In h(x) = -(1/3)f(2x) + 10, describe the HORIZONTAL change.',
 '[{"text": "Horizontal compression by a factor of 1/2", "feedback": "Correct."},
   {"text": "Horizontal stretch by a factor of 2", "feedback": "k = 2 squashes the graph rather than stretching it. The factor is 1 over k, and it is the reciprocal that decides which way."},
   {"text": "Horizontal compression by a factor of 1/3", "feedback": "The 1/3 sits outside f, so it changes the y-values. Only what is inside the bracket touches x."},
   {"text": "Horizontal reflection in the y-axis", "feedback": "A horizontal reflection needs a negative inside the bracket, and the 2 there is positive."}]'::jsonb,
 0, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 13, 'Medium',
 E'Write the equation for y = x² after a vertical stretch by 3,\na shift left 2 and a shift down 1.',
 '[{"text": "y = 3(x - 2)² - 1", "feedback": "A shift LEFT is written x + 2. The sign inside the bracket is the opposite of the direction."},
   {"text": "y = 3(x + 2)² + 1", "feedback": "A shift down subtracts from the output, so the constant on the end is negative."},
   {"text": "y = (3x + 2)² - 1", "feedback": "The 3 has slipped inside the bracket, where it would stretch the graph sideways instead of upward."},
   {"text": "y = 3(x + 2)² - 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-quadratic'),

(11, 'MCR3U', 'Transformations', 3, 14, 'Medium',
 'The point (3, 9) lies on y = x². Where does it land on y = 2(x - 1)² + 5?',
 '[{"text": "(4, 14)", "feedback": "The shift up was applied but the stretch was not. The y-value doubles before the 5 is added."},
   {"text": "(2, 23)", "feedback": "The x-coordinate moved the wrong way. x - 1 slides the graph right, so 3 becomes 4."},
   {"text": "(4, 23)", "feedback": "Correct."},
   {"text": "(4, 18)", "feedback": "The stretch was applied but the shift up was not. The + 5 still has to be added on."}]'::jsonb,
 2, 'sub-transform-quadratic'),

(11, 'MCR3U', 'Transformations', 3, 15, 'Medium',
 'Write the equation for y = √x translated up 4 and right 9.',
 '[{"text": "y = √(x - 4) + 9", "feedback": "The two numbers have swapped jobs. The 9 is the horizontal move and the 4 is the vertical one."},
   {"text": "y = √(x - 9) + 4", "feedback": "Correct."},
   {"text": "y = √(x + 9) + 4", "feedback": "A shift RIGHT is written x - 9. The sign inside the root is the opposite of the direction."},
   {"text": "y = √(x - 9) - 4", "feedback": "A shift up adds to the output, so the constant on the end is positive."}]'::jsonb,
 1, 'sub-transform-radical'),

(11, 'MCR3U', 'Transformations', 3, 16, 'Medium',
 'State the domain and range of y = -√(x + 2) + 1.',
 '[{"text": "x ≥ -2 and y ≥ 1", "feedback": "The minus in front of the root flips the graph downward, so 1 is its ceiling rather than its floor."},
   {"text": "x ≤ -2 and y ≤ 1", "feedback": "The inside of a root must be zero or MORE, so the domain runs upward from -2."},
   {"text": "x ≥ -2 and y ≤ 1", "feedback": "Correct."},
   {"text": "x ≥ 2 and y ≤ 1", "feedback": "Setting x + 2 ≥ 0 moves the 2 across as a negative number."}]'::jsonb,
 2, 'sub-transform-radical'),

(11, 'MCR3U', 'Transformations', 3, 17, 'Medium',
 'State both asymptotes of y = 1/(x + 3) - 2.',
 '[{"text": "x = -3 and y = 2", "feedback": "The 2 is being subtracted, so the whole graph drops and its horizontal asymptote drops with it."},
   {"text": "x = -2 and y = -3", "feedback": "The two numbers have swapped jobs. The one inside the bracket sets the vertical asymptote."},
   {"text": "x = -3 and y = -2", "feedback": "Correct."},
   {"text": "x = 3 and y = -2", "feedback": "Solving x + 3 = 0 moves the 3 across as a negative number."}]'::jsonb,
 2, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 18, 'Medium',
 'For f(x) = 1/x, what is the horizontal asymptote of g(x) = (1/2)f(x + 1) - 1?',
 '[{"text": "y = 0", "feedback": "That is the parent asymptote of 1/x, before the graph was moved down."},
   {"text": "x = -1", "feedback": "That is the VERTICAL asymptote, set by the bracket. A horizontal asymptote names y."},
   {"text": "y = 1/2", "feedback": "The 1/2 squashes the graph toward its asymptote. It is the - 1 that says where that asymptote sits."},
   {"text": "y = -1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 19, 'Medium',
 'Find the inverse of h(x) = 4x + 3.',
 '[{"text": "4x - 3", "feedback": "The operations were reversed in place rather than solved for. Swap x and y first, then isolate y."},
   {"text": "1/(4x + 3)", "feedback": "The -1 in the inverse notation is not an exponent, so the function is not flipped over."},
   {"text": "(x - 3)/4", "feedback": "Correct."},
   {"text": "(x + 3)/4", "feedback": "Moving the 3 to the other side of x = 4y + 3 makes it negative."}]'::jsonb,
 2, 'sub-inverse-function'),

(11, 'MCR3U', 'Transformations', 3, 20, 'Medium',
 'If f(x) = 2x - 6, find the value of f inverse at 10.',
 '[{"text": "14", "feedback": "That computes f(10). The inverse runs the other way: it asks which input gives 10."},
   {"text": "2", "feedback": "Moving the -6 across makes it +6, so the 6 is added to the 10 before dividing, not taken off it."},
   {"text": "1/14", "feedback": "The -1 in the inverse notation is not an exponent, so nothing is being flipped over."},
   {"text": "8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-inverse-function'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): several parameters at once, and reading them backwards.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Transformations', 3, 21, 'Challenge',
 'List ALL the transformations in g(x) = -5f[-(1/4)(x + 2)] + 7.',
 '[{"text": "Vertical stretch 5 and reflection in the x-axis; horizontal stretch 4 and reflection in the y-axis; left 2; up 7", "feedback": "Correct."},
   {"text": "Vertical stretch 5 and reflection in the x-axis; horizontal COMPRESSION by 1/4 and reflection in the y-axis; left 2; up 7", "feedback": "k = -1/4 stretches the graph rather than squashing it. The factor is 1 over k, and 1 over a quarter is 4."},
   {"text": "Vertical stretch 5 and reflection in the x-axis; horizontal stretch 4 and reflection in the y-axis; RIGHT 2; up 7", "feedback": "The bracket reads x + 2, and a plus inside moves the graph left."},
   {"text": "Vertical stretch 5 only; horizontal stretch 4 and reflection in the y-axis; left 2; up 7", "feedback": "The minus in front of the 5 was read as part of the number. It flips the graph vertically as well as stretching it."}]'::jsonb,
 0, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 22, 'Challenge',
 'The point (6, -2) lies on y = f(x). Where does it land on y = 3f(2x) - 1?',
 '[{"text": "(3, -6)", "feedback": "The stretch was applied but the shift down was not. The - 1 still comes off at the end."},
   {"text": "(3, -9)", "feedback": "The - 1 was applied before the stretch, so it got tripled too. Stretches happen first, translations last."},
   {"text": "(3, -7)", "feedback": "Correct."},
   {"text": "(12, -7)", "feedback": "k = 2 DIVIDES the x-coordinate. Multiplying by k stretches the graph when it should squash it."}]'::jsonb,
 2, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 23, 'Challenge',
 E'Write the equation for y = x² after a vertical stretch by 2, a horizontal\nstretch by 3, a reflection in the x-axis, a shift up 2 and a shift left 6.',
 '[{"text": "y = 2[(1/3)(x + 6)]² + 2", "feedback": "The reflection in the x-axis never reached a. It is the minus in front that flips the graph over."},
   {"text": "y = -2[(1/3)(x + 6)]² + 2", "feedback": "Correct."},
   {"text": "y = -2[3(x + 6)]² + 2", "feedback": "A horizontal stretch by 3 needs k = 1/3, because the graph is scaled by 1 over k. Putting 3 in squashes it instead."},
   {"text": "y = -2[(1/3)(x - 6)]² + 2", "feedback": "A shift LEFT is written x + 6. The sign inside the bracket is the opposite of the direction."}]'::jsonb,
 1, 'sub-transform-quadratic'),

(11, 'MCR3U', 'Transformations', 3, 24, 'Challenge',
 'Give the vertex of f(x) = -(x + 6)² + 4 and say which way it opens.',
 '[{"text": "Vertex (4, -6), opens downward", "feedback": "The coordinates are swapped. The number inside the bracket gives x and the one outside gives y."},
   {"text": "Vertex (-6, 4), opens downward", "feedback": "Correct."},
   {"text": "Vertex (6, 4), opens downward", "feedback": "The sign inside the bracket flips: x + 6 puts the vertex at negative 6."},
   {"text": "Vertex (-6, 4), opens upward", "feedback": "The minus in front of the bracket turns every output negative, which tips the parabola over."}]'::jsonb,
 1, 'sub-transform-quadratic'),

(11, 'MCR3U', 'Transformations', 3, 25, 'Challenge',
 'Which point lies on g(x) = 2√(-2x) - 3?',
 '[{"text": "(-2, 4)", "feedback": "The stretch was applied but the shift down was not. The - 3 still comes off at the end."},
   {"text": "(-2, 1)", "feedback": "Correct."},
   {"text": "(2, 1)", "feedback": "At x = 2 the inside of the root is negative, so the graph does not exist there at all. The minus on the 2x flips it to the left of the axis."},
   {"text": "(-8, 1)", "feedback": "k = -2 divides the x-coordinate rather than multiplying it, so the parent point does not travel that far out."}]'::jsonb,
 1, 'sub-transform-radical'),

(11, 'MCR3U', 'Transformations', 3, 26, 'Challenge',
 'State the domain and range of g(x) = √(-4x) + 1.',
 '[{"text": "x ≤ 0 and y ≤ 1", "feedback": "Nothing here puts a minus in FRONT of the root, so the graph still climbs away from its starting point."},
   {"text": "x ≤ 0 and y ≥ 1", "feedback": "Correct."},
   {"text": "x ≥ 0 and y ≥ 1", "feedback": "Dividing -4x ≥ 0 by a negative flips the inequality, and that flip was skipped."},
   {"text": "x ≤ 0 and y ≥ 0", "feedback": "The root itself starts at zero, but the + 1 lifts every output by one."}]'::jsonb,
 1, 'sub-transform-radical'),

(11, 'MCR3U', 'Transformations', 3, 27, 'Challenge',
 'State both asymptotes of y = 1/(2x - 6) + 1.',
 '[{"text": "x = 3 and y = 1", "feedback": "Correct."},
   {"text": "x = 6 and y = 1", "feedback": "The 2 in front of the x has to be divided out. Solve 2x - 6 = 0 rather than reading the 6 straight off."},
   {"text": "x = -3 and y = 1", "feedback": "Solving 2x - 6 = 0 moves the 6 across as a positive number."},
   {"text": "x = 3 and y = 0", "feedback": "That is the parent horizontal asymptote. The + 1 lifts the whole graph, and the asymptote rises with it."}]'::jsonb,
 0, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 28, 'Challenge',
 'As x grows very large, what happens to y = 3/(x + 2) - 4?',
 '[{"text": "y approaches -4 from above", "feedback": "Correct."},
   {"text": "y approaches -4 from below", "feedback": "For large positive x the fraction 3/(x + 2) is a small POSITIVE number, not a negative one. Check its sign at x = 1000."},
   {"text": "y approaches 0", "feedback": "That is the parent behaviour of 1/x, before the graph was pulled down by the - 4."},
   {"text": "y grows without bound", "feedback": "That happens close to the vertical asymptote, not far out. Out here the fraction is shrinking toward nothing."}]'::jsonb,
 0, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 29, 'Challenge',
 'Find the inverse of f(x) = x² - 1.',
 '[{"text": "±√(x - 1)", "feedback": "Moving the -1 across the equals sign makes it positive."},
   {"text": "1/(x² - 1)", "feedback": "The -1 in the inverse notation is not an exponent, so the function is not flipped over."},
   {"text": "±√(x + 1)", "feedback": "Correct."},
   {"text": "√(x + 1)", "feedback": "Only half the inverse. A parabola sends two different x values to each y, so undoing it needs both branches of the root."}]'::jsonb,
 2, 'sub-inverse-function'),

(11, 'MCR3U', 'Transformations', 3, 30, 'Challenge',
 'Find the inverse of f(x) = (4x + 3)/5.',
 '[{"text": "(5x - 3)/4", "feedback": "Correct."},
   {"text": "(5x + 3)/4", "feedback": "Moving the 3 to the other side of 5x = 4y + 3 makes it negative."},
   {"text": "(4x - 3)/5", "feedback": "The 4 and the 5 never traded places. Multiply both sides by 5 first, then divide by 4."},
   {"text": "5/(4x + 3)", "feedback": "The -1 in the inverse notation is not an exponent, so the function is not flipped over."}]'::jsonb,
 0, 'sub-inverse-function'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): parameters, general points, and inverses that need work.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Transformations', 3, 31, 'Advanced',
 E'The point (a, b) lies on y = f(x).\nWhere does it land on y = -2f[3(x + 1)] + 5?',
 '[{"text": "(a/3 - 1, -2(b + 5))", "feedback": "The + 5 is added after the stretch, not carried inside it. Stretches happen first, translations last."},
   {"text": "(a/3 - 1, -2b + 5)", "feedback": "Correct."},
   {"text": "(3a - 1, -2b + 5)", "feedback": "k = 3 divides the x-coordinate rather than multiplying it. Multiplying stretches the graph when k should squash it."},
   {"text": "(a/3 + 1, -2b + 5)", "feedback": "The bracket reads x + 1, and a plus inside moves the graph left, so the 1 comes off."}]'::jsonb,
 1, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 32, 'Advanced',
 E'Every point of y = f(x) is moved so its y-coordinate doubles and its\nx-coordinate is 3 larger. Which equation describes the result?',
 '[{"text": "g(x) = f(2x - 3)", "feedback": "The doubling ended up inside f, where it acts on the x-coordinates. To double y it has to multiply the whole function."},
   {"text": "g(x) = 2f(x) + 3", "feedback": "The 3 ended up outside, where it raises the graph. To move x it has to sit inside the bracket."},
   {"text": "g(x) = 2f(x - 3)", "feedback": "Correct."},
   {"text": "g(x) = 2f(x + 3)", "feedback": "Moving the graph right is written x - 3. The sign inside the bracket is the opposite of the direction."}]'::jsonb,
 2, 'sub-transform-basics'),

(11, 'MCR3U', 'Transformations', 3, 33, 'Advanced',
 'Find the inverse of f(x) = 2x² + 16x + 30 by completing the square first.',
 '[{"text": "-4 ± √((x + 2)/2)", "feedback": "Correct."},
   {"text": "4 ± √((x + 2)/2)", "feedback": "The completed square is (x + 4)², so when the 4 crosses the equals sign it stays negative."},
   {"text": "-4 ± √((x - 2)/2)", "feedback": "The vertex form ends in - 2, so moving that constant across the equals sign makes it positive."},
   {"text": "-4 ± √(2(x + 2))", "feedback": "The 2 in front of the bracket is undone by dividing, not by multiplying."}]'::jsonb,
 0, 'sub-inverse-function'),

(11, 'MCR3U', 'Transformations', 3, 34, 'Advanced',
 'Which transformations of y = x² produce y = x² - 6x + 11?',
 '[{"text": "Left 3 and up 2", "feedback": "Completing the square gives a bracket of (x - 3), and a minus inside moves the graph right."},
   {"text": "Right 6 and up 11", "feedback": "The coefficients were read straight off the expanded form. Complete the square first to see the real shifts."},
   {"text": "Right 3 and up 11", "feedback": "Completing the square puts a 9 inside the bracket, and that 9 has to be taken back off the 11."},
   {"text": "Right 3 and up 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-quadratic'),

(11, 'MCR3U', 'Transformations', 3, 35, 'Advanced',
 'Find the inverse of f(x) = √x + 2 and state the domain of that inverse.',
 '[{"text": "√(x - 2), with x ≥ 2", "feedback": "A square root is undone by squaring. Taking another root applies the same operation twice instead of reversing it."},
   {"text": "(x - 2)², with x ≥ 2", "feedback": "Correct."},
   {"text": "(x - 2)², with x ≥ 0", "feedback": "The domain of an inverse is the RANGE of the original, and the original never outputs anything below 2."},
   {"text": "(x + 2)², with x ≥ 2", "feedback": "Moving the 2 across the equals sign before squaring makes it negative."}]'::jsonb,
 1, 'sub-inverse-function'),

(11, 'MCR3U', 'Transformations', 3, 36, 'Advanced',
 'Which point lies on h(x) = (1/2)√(2x) - 3?',
 '[{"text": "(2, 1)", "feedback": "The compression was applied but the shift down was not. The - 3 still comes off at the end."},
   {"text": "(2, -2)", "feedback": "Correct."},
   {"text": "(8, -2)", "feedback": "k = 2 divides the x-coordinate rather than multiplying it, so the parent point does not travel that far out."},
   {"text": "(2, -1)", "feedback": "The shift down was applied but the vertical compression was not. The output is halved before the 3 comes off."}]'::jsonb,
 1, 'sub-transform-radical'),

(11, 'MCR3U', 'Transformations', 3, 37, 'Advanced',
 E'Rewrite g(x) = (2x + 7)/(x + 3) as a transformation of 1/x,\nand give both asymptotes.',
 '[{"text": "g(x) = 1/(x + 3) + 2, with x = 3 and y = 2", "feedback": "The rewrite is right but the vertical asymptote is not. Solving x + 3 = 0 moves the 3 across as a negative."},
   {"text": "g(x) = 1/(x + 3) + 7/3, with x = -3 and y = 7/3", "feedback": "The horizontal asymptote was read from the two constants. It comes from the leading coefficients, which are 2 and 1."},
   {"text": "g(x) = 1/(x + 3), with x = -3 and y = 0", "feedback": "The whole-number part of the division was dropped. Dividing 2x + 7 by x + 3 leaves something before the remainder."},
   {"text": "g(x) = 1/(x + 3) + 2, with x = -3 and y = 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 38, 'Advanced',
 'The point (0.5, 2) lies on y = 1/x. Where does it land on y = -1/(x - 2) + 3?',
 '[{"text": "(2.5, 5)", "feedback": "The reflection was skipped. The minus in front turns the y-value negative before the 3 is added."},
   {"text": "(2.5, -2)", "feedback": "The reflection was applied but the shift up was not. The + 3 still has to be added on."},
   {"text": "(-1.5, 1)", "feedback": "The x-coordinate moved the wrong way. x - 2 slides the graph right, so 0.5 becomes 2.5."},
   {"text": "(2.5, 1)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transform-reciprocal'),

(11, 'MCR3U', 'Transformations', 3, 39, 'Advanced',
 'Find the inverse of f(x) = 2(x - 1)² + 2.',
 '[{"text": "1 ± √((x - 2)/2)", "feedback": "Correct."},
   {"text": "-1 ± √((x - 2)/2)", "feedback": "The bracket reads y - 1, so when the 1 crosses the equals sign it becomes positive."},
   {"text": "1 ± √((x + 2)/2)", "feedback": "The + 2 on the end moves across the equals sign as a subtraction."},
   {"text": "1 ± √(2(x - 2))", "feedback": "The 2 in front of the bracket is undone by dividing, not by multiplying."}]'::jsonb,
 0, 'sub-inverse-function'),

(11, 'MCR3U', 'Transformations', 3, 40, 'Advanced',
 'Which statement about a function and its inverse is true?',
 '[{"text": "The domain of the inverse is the domain of the original", "feedback": "Swapping x and y swaps domain and range with each other, so the two do not stay put."},
   {"text": "The inverse of f is the same as 1 divided by f", "feedback": "The -1 in the inverse notation is not an exponent. An inverse undoes the function; a reciprocal divides into 1."},
   {"text": "Every function has an inverse that is also a function", "feedback": "Squaring is the counterexample: two inputs share an output, so reversing it gives two outputs for one input."},
   {"text": "The domain of the inverse is the range of the original", "feedback": "Correct."}]'::jsonb,
 3, 'sub-inverse-function');

-- --- questions_mcr3u_u4.sql ---

-- ===========================================================================
-- MCR3U — Unit 4: Exponential Functions — 40 questions
-- ===========================================================================
-- Grade 11 Exponential Functions, authored from the Jensen MCR3U lesson
-- material for this unit:
--
--   Lesson 1  Exponential growth
--   Lesson 2  Exponential decay
--   Lesson 3  Compound interest
--   Lesson 4  Properties of exponential functions
--   Lesson 5  Transformations of exponential functions
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every number in this file was recomputed independently with sympy and
-- Python before delivery; nothing was copied from the source PDFs. Money is
-- rounded to the nearest cent and populations to whole individuals, and the
-- distractors are rounded the same way so rounding alone can never pick out
-- the answer.
--
-- The mistake this unit exists to catch, and the reason half the distractors
-- here are the same shape: compound change is not repeated simple change.
-- A student who answers 13 percent for ten years with 20000 x 1.13 x 10 has
-- made the single most expensive error in the unit, and it is the same error
-- whether the context is a population, a half-life or a bank balance.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own
-- at any time; the delete at the top makes a corrected copy replace the unit
-- cleanly, and student attempts (keyed on course, unit and sort_order)
-- survive the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
--
-- No figures. The graph-matching questions in the Jensen review need four
-- pictures to be answerable, and a picture of the curve gives away the shape
-- that IS the answer. Those questions are asked here through their key
-- points instead, which is strictly harder and cannot leak.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Exponential Functions';

insert into misconception_labels (tag, label) values
  ('sub-exp-growth',          'Exponential growth'),
  ('sub-exp-decay',           'Exponential decay'),
  ('sub-compound-interest',   'Compound interest'),
  ('sub-exp-properties',      'Properties of exponential functions'),
  ('sub-exp-transformations', 'Transforming exponential functions')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 1, 'Easy',
 E'An insect colony starts at 15 and QUADRUPLES every day.\nWhich function models the population after n days?',
 '[{"text": "P(n) = 15 + 4n", "feedback": "That adds 4 each day, which is straight-line growth. Quadrupling multiplies, so the 4 belongs in the exponent position."},
   {"text": "P(n) = 4(15)ⁿ", "feedback": "The starting amount and the growth factor have swapped places. The colony starts at 15, not at 4."},
   {"text": "P(n) = 15(4n)", "feedback": "That multiplies by 4n, so day 2 would only be eight times the start. Each day multiplies by 4 again, which is a power."},
   {"text": "P(n) = 15(4)ⁿ", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 2, 'Easy',
 'In y = 200(3)ˣ, what is the initial amount?',
 '[{"text": "0", "feedback": "The initial amount is the value at x = 0, and an exponential with a positive front number is never zero."},
   {"text": "200", "feedback": "Correct."},
   {"text": "3", "feedback": "The 3 is the growth factor, the number the amount is multiplied by each step."},
   {"text": "600", "feedback": "That multiplies the two numbers together. At x = 0 the power is 1, so only the front number survives."}]'::jsonb,
 1, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 3, 'Easy',
 'In y = a(b)ˣ with a positive, which value of b gives DECAY?',
 '[{"text": "b = 0.8", "feedback": "Correct."},
   {"text": "b = 1.2", "feedback": "Anything above 1 makes the amount larger each step, which is growth."},
   {"text": "b = 2", "feedback": "A base of 2 doubles the amount every step, which is the fastest growth on this list."},
   {"text": "b = 1", "feedback": "A base of exactly 1 leaves the amount unchanged forever, so it neither grows nor decays."}]'::jsonb,
 0, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 4, 'Easy',
 'A car loses 20 percent of its value each year. What is the base b in y = a(b)ˣ?',
 '[{"text": "0.8", "feedback": "Correct."},
   {"text": "0.2", "feedback": "0.2 is the fraction LOST. The base is the fraction that survives, which is what is left of the whole."},
   {"text": "1.2", "feedback": "Adding the 20 percent makes the car gain value. A loss subtracts from 1."},
   {"text": "20", "feedback": "The percent has to become a decimal before it can be used, and it has to be subtracted from 1."}]'::jsonb,
 0, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 5, 'Easy',
 'In A = P(1 + i)ⁿ, what is i for 7 percent per year compounded annually?',
 '[{"text": "1.07", "feedback": "That is the whole bracket, 1 + i, already worked out. On its own i is just the rate."},
   {"text": "0.7", "feedback": "7 percent is 7 hundredths, not 7 tenths. The decimal point moved one place too few."},
   {"text": "0.07", "feedback": "Correct."},
   {"text": "7", "feedback": "The percent has to be divided by 100 before it goes into the formula."}]'::jsonb,
 2, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 6, 'Easy',
 'What is $1000 worth after 1 year at 5 percent compounded annually?',
 '[{"text": "$950.00", "feedback": "Interest is earned, so it is added. Subtracting would be a loss."},
   {"text": "$1050.00", "feedback": "Correct."},
   {"text": "$1005.00", "feedback": "That uses 0.005 as the rate. 5 percent is 5 hundredths, which is 0.05."},
   {"text": "$1500.00", "feedback": "That adds 50 percent. The rate is 5 percent, ten times smaller."}]'::jsonb,
 1, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 7, 'Easy',
 'What is the horizontal asymptote of y = 2ˣ?',
 '[{"text": "y = 2", "feedback": "The 2 is the base, which sets how fast the curve climbs. It does not set the floor."},
   {"text": "y = 1", "feedback": "1 is where the curve crosses the y-axis. The asymptote is the level it heads toward far to the left."},
   {"text": "y = 0", "feedback": "Correct."},
   {"text": "x = 0", "feedback": "A horizontal asymptote is a horizontal line, so its equation names y. This curve has no vertical asymptote at all."}]'::jsonb,
 2, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 8, 'Easy',
 'What is the y-intercept of y = 5(3)ˣ?',
 '[{"text": "3", "feedback": "The 3 is the base. At x = 0 the base raised to the power 0 is 1, so it disappears."},
   {"text": "15", "feedback": "That multiplies the two numbers. Anything to the power 0 is 1, not itself."},
   {"text": "1", "feedback": "That is only what the power on its own is worth at x = 0. The y-intercept is the whole value of y there, not just the power."},
   {"text": "5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 9, 'Easy',
 'How does the graph of y = 2ˣ + 4 compare with y = 2ˣ?',
 '[{"text": "It is 4 units to the left", "feedback": "A sideways move needs the 4 in the exponent. Out here it acts on the y-values."},
   {"text": "It is 4 units further down", "feedback": "The 4 is being added to every output, which lifts the curve."},
   {"text": "It is 4 units higher", "feedback": "Correct."},
   {"text": "It is 4 units to the right", "feedback": "A sideways move needs the 4 in the exponent, as 2 to the power x - 4. Out here it acts on the y-values."}]'::jsonb,
 2, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 10, 'Easy',
 'How does the graph of y = -2ˣ compare with y = 2ˣ?',
 '[{"text": "It is reflected in the y-axis", "feedback": "A y-axis reflection needs the minus on the x, as 2 to the power -x. Out here the minus multiplies the output."},
   {"text": "It is shifted downward by 1 unit", "feedback": "A shift needs a number added or subtracted. The minus multiplies every output by -1 instead."},
   {"text": "It is reflected in the x-axis", "feedback": "Correct."},
   {"text": "It decays away instead of growing", "feedback": "The base is still 2, so the size of the output keeps doubling. The minus flips the curve rather than slowing it."}]'::jsonb,
 2, 'sub-exp-transformations'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 11, 'Medium',
 'An ant colony of 213 doubles every week. What is the population after 4 weeks?',
 '[{"text": "3408", "feedback": "Correct."},
   {"text": "1704", "feedback": "Only three doublings were counted. Four weeks means the 2 is used four times."},
   {"text": "6816", "feedback": "One doubling too many. After four weeks the exponent is 4, not 5."},
   {"text": "852", "feedback": "That multiplies by 4 once. Doubling four times multiplies by 2 to the power 4, which is a good deal more."}]'::jsonb,
 0, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 12, 'Medium',
 E'A town of 20000 grows by 13 percent each year.\nWhat is the population after 10 years, to the nearest whole person?',
 '[{"text": "275 717", "feedback": "The growth factor was written as 1.3. A 13 percent rise makes the factor 1.13, not 1.3."},
   {"text": "67 891", "feedback": "Correct."},
   {"text": "46 000", "feedback": "That adds 13 percent of the ORIGINAL ten times over. Each year the percentage is taken of the new, larger number."},
   {"text": "22 600", "feedback": "Only one year of growth was applied. The exponent has to be 10."}]'::jsonb,
 1, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 13, 'Medium',
 E'Radium has a half-life of 1620 years. A hospital buys 0.5 g.\nHow much is left after 4860 years?',
 '[{"text": "0.03125 g", "feedback": "One half-life too many. 4860 divided by 1620 is exactly three, not four."},
   {"text": "0.1667 g", "feedback": "That divides the amount by 3. Three half-lives halve it three times over, which is a division by 8."},
   {"text": "0.0625 g", "feedback": "Correct."},
   {"text": "0.125 g", "feedback": "Only two half-lives were counted. 4860 divided by 1620 gives three."}]'::jsonb,
 2, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 14, 'Medium',
 E'Polonium-210 has a half-life of 20 days. A sample starts at 40 mg.\nWhich equation gives the mass remaining after t days?',
 '[{"text": "f(t) = 40(2)^(t/20)", "feedback": "A base of 2 doubles the sample every 20 days. A half-life halves it."},
   {"text": "f(t) = 20(1/2)^(t/40)", "feedback": "The starting mass and the half-life have swapped places. The sample starts at 40 mg."},
   {"text": "f(t) = 40(1/2)^(t/20)", "feedback": "Correct."},
   {"text": "f(t) = 40(1/2)^(20t)", "feedback": "The half-life multiplies t here instead of dividing it, so the sample would be halved 20 times on day 1. The exponent has to count halvings, not days."}]'::jsonb,
 2, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 15, 'Medium',
 'How much is $1500 worth after 8 years at 3.5 percent compounded annually?',
 '[{"text": "$16 548.61", "feedback": "The growth factor was written as 1.35. A 3.5 percent rate makes it 1.035."},
   {"text": "$1975.21", "feedback": "Correct."},
   {"text": "$1920.00", "feedback": "That is simple interest: 3.5 percent of the original, eight times. Compounding takes the percentage of the new balance each year."},
   {"text": "$1552.50", "feedback": "Only one year of interest was applied. The exponent has to be 8."}]'::jsonb,
 1, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 16, 'Medium',
 E'An investment earns 7 percent per year compounded annually.\nHow much must be invested now to have $13 450 in 9 years?',
 '[{"text": "$7315.91", "feedback": "Correct."},
   {"text": "$24 727.28", "feedback": "That grows the money forward for another nine years. To find the starting amount, divide rather than multiply."},
   {"text": "$4976.50", "feedback": "That takes 7 percent off nine times as a simple percentage of the original, which strips away far too much."},
   {"text": "$12 570.09", "feedback": "Only one year was undone. The 1.07 has to be raised to the power 9."}]'::jsonb,
 0, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 17, 'Medium',
 'What are the domain and range of y = 3(2)ˣ?',
 '[{"text": "Domain all positive numbers, range y > 0", "feedback": "Negative exponents are perfectly legal here; they just give small positive outputs."},
   {"text": "Domain all real numbers, range y > 3", "feedback": "3 is the y-intercept, not the floor. Far to the left the outputs drop below 3 and keep going."},
   {"text": "Domain all real numbers, range y > 0", "feedback": "Correct."},
   {"text": "Domain all real numbers, range y ≥ 0", "feedback": "The curve gets as close to zero as you like but never lands on it, so zero itself is not in the range."}]'::jsonb,
 2, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 18, 'Medium',
 'An exponential curve passes through (0, 6) and (1, 12). Which equation fits?',
 '[{"text": "y = 2(6)ˣ", "feedback": "The starting value and the base have swapped places. At x = 0 the output has to be 6."},
   {"text": "y = 6 + 6x", "feedback": "That fits both given points but grows by adding, so at x = 2 it gives 18 where the curve gives 24."},
   {"text": "y = 6(2)ˣ", "feedback": "Correct."},
   {"text": "y = 6(0.5)ˣ", "feedback": "This curve falls, and the given points climb from 6 to 12. The base is found by DIVIDING the second output by the first."}]'::jsonb,
 2, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 19, 'Medium',
 'Write the equation for y = 3ˣ shifted right 2 and down 5.',
 '[{"text": "y = 3^(x - 2) - 5", "feedback": "Correct."},
   {"text": "y = 3^(x + 2) - 5", "feedback": "A shift RIGHT is written x - 2. The sign in the exponent is the opposite of the direction."},
   {"text": "y = 3^(x - 2) + 5", "feedback": "A shift down subtracts from the output, so the constant on the end is negative."},
   {"text": "y = 3^(x - 5) - 2", "feedback": "The two numbers have swapped jobs. The 2 is the sideways move and the 5 is the vertical one."}]'::jsonb,
 0, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 20, 'Medium',
 'What is the horizontal asymptote of y = 2ˣ - 7?',
 '[{"text": "y = 0", "feedback": "That is the parent asymptote of 2 to the power x, before the curve was pulled down."},
   {"text": "y = 7", "feedback": "The 7 is being subtracted, so the whole curve drops and its floor drops with it."},
   {"text": "x = -7", "feedback": "A horizontal asymptote is a horizontal line, so its equation names y. This curve has no vertical asymptote."},
   {"text": "y = -7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-transformations'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): word problems, solving for the exponent, choosing a model.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 21, 'Challenge',
 E'A bacteria culture starts at 12 000 and doubles every four hours.\nHow many are present after one day?',
 '[{"text": "288 000", "feedback": "That multiplies by 24. The 24 hours has to be divided by the four-hour period first, and the result used as an exponent."},
   {"text": "201 326 592 000", "feedback": "The four-hour period was ignored, so 24 doublings were counted instead of six."},
   {"text": "768 000", "feedback": "Correct."},
   {"text": "96 000", "feedback": "That is the count after 12 hours. One day is 24 hours, which is six doubling periods, not three."}]'::jsonb,
 2, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 22, 'Challenge',
 E'A culture of 20 bacteria doubles every 15 minutes.\nHow long does it take to reach 163 840?',
 '[{"text": "180 minutes", "feedback": "Twelve doublings gets to 81 920, which is only half way. One more period is needed."},
   {"text": "8192 minutes", "feedback": "8192 is how many times the colony has multiplied, not a length of time. Write it as a power of 2 first."},
   {"text": "195 minutes", "feedback": "Correct."},
   {"text": "13 minutes", "feedback": "13 is the number of DOUBLINGS. Each one takes 15 minutes, so they still have to be multiplied out."}]'::jsonb,
 2, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 23, 'Challenge',
 E'A coffee contains 96 mg of caffeine, and the amount in the body halves\nevery 5 hours. How long until only 12 mg is left?',
 '[{"text": "40 hours", "feedback": "That multiplies the 5 hours by 8. The 8 is the division factor; the number of halvings is the power of 2 inside it."},
   {"text": "15 hours", "feedback": "Correct."},
   {"text": "3 hours", "feedback": "3 is the number of HALVINGS. Each one takes 5 hours, so they still have to be multiplied out."},
   {"text": "8 hours", "feedback": "8 is how many times smaller the amount has become, not a length of time. Write it as a power of 2 first."}]'::jsonb,
 1, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 24, 'Challenge',
 E'A motorcycle costs $13 500 and depreciates by 20 percent of its current\nvalue every year. What is it worth after 6 years?',
 '[{"text": "$4423.68", "feedback": "Only five years were counted. The 0.8 has to be used six times."},
   {"text": "$10 800.00", "feedback": "Only one year was counted. The 0.8 has to be raised to the power 6."},
   {"text": "$0.00", "feedback": "That takes 20 percent of the ORIGINAL price six times, which wipes the value out entirely. Each year the percentage is of the current, smaller value."},
   {"text": "$3538.94", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 25, 'Challenge',
 E'Five years ago Denise deposited money at 7.5 percent compounded annually.\nToday the balance is $4200. What was the deposit?',
 '[{"text": "$6029.64", "feedback": "That grows the money forward another five years. Going back in time means dividing by the growth factor."},
   {"text": "$2625.00", "feedback": "That takes 7.5 percent of $4200 away five times over. Compounding does not work backwards as a flat percentage."},
   {"text": "$3906.98", "feedback": "Only one year was undone. The 1.075 has to be raised to the power 5."},
   {"text": "$2925.55", "feedback": "Correct."}]'::jsonb,
 3, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 26, 'Challenge',
 E'Money is invested at 3.5 percent compounded annually.\nRoughly how long does it take to double?',
 '[{"text": "About 20 years", "feedback": "Correct."},
   {"text": "About 29 years", "feedback": "That is 100 divided by 3.5, which is the rule for SIMPLE interest. Compounding gets there noticeably sooner."},
   {"text": "About 10 years", "feedback": "After 10 years the balance has grown by roughly 41 percent, which is well short of doubling."},
   {"text": "About 2 years", "feedback": "That divides 2 by 1.035. Solving for an exponent needs logarithms: log 2 divided by log 1.035."}]'::jsonb,
 0, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 27, 'Challenge',
 'Which equation gives a DECREASING curve with a y-intercept of 3?',
 '[{"text": "y = -3ˣ", "feedback": "This one falls, but it starts at -1 and lives entirely below the x-axis."},
   {"text": "y = 3(1/3)ˣ", "feedback": "Correct."},
   {"text": "y = 3(3ˣ)", "feedback": "The y-intercept is right, but a base above 1 makes the curve climb."},
   {"text": "y = (1/3)(3ˣ)", "feedback": "The base and the front number are the wrong way round: this crosses the y-axis at one third and then climbs."}]'::jsonb,
 1, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 28, 'Challenge',
 'A curve passes through (0, 8), (1, 4) and (2, 2). Which equation fits?',
 '[{"text": "y = 8(1/2)ˣ", "feedback": "Correct."},
   {"text": "y = 8(2)ˣ", "feedback": "The outputs are falling, so the base has to be below 1. Divide each output by the one before it to find it."},
   {"text": "y = 4(1/2)ˣ", "feedback": "The base is right but the starting value is not. At x = 0 the output has to be 8."},
   {"text": "y = 8 - 4x", "feedback": "That fits the first two points but reaches 0 at x = 2, where the curve is still at 2. Halving never gets to zero."}]'::jsonb,
 0, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 29, 'Challenge',
 E'For f(x) = -2(1/2)^(x + 1) - 2, is the function increasing or decreasing,\nand where is its horizontal asymptote?',
 '[{"text": "Increasing, asymptote y = 2", "feedback": "The 2 on the end is being subtracted, so the asymptote sits below the axis."},
   {"text": "Increasing, asymptote y = -2", "feedback": "Correct."},
   {"text": "Decreasing, asymptote y = -2", "feedback": "The base below 1 does fall, but the minus in front turns the whole curve over, so it climbs."},
   {"text": "Increasing, asymptote y = 0", "feedback": "The - 2 on the end drags the whole curve down, and its asymptote goes with it."}]'::jsonb,
 1, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 30, 'Challenge',
 'What is the y-intercept of y = 4(3)^(x - 1) + 2?',
 '[{"text": "4/3", "feedback": "The power was handled correctly but the + 2 was never added on."},
   {"text": "10/3", "feedback": "Correct."},
   {"text": "6", "feedback": "The shift was ignored, so 3 to the power 0 was used. At x = 0 the exponent is -1, not 0."},
   {"text": "14", "feedback": "The exponent came out as +1 rather than -1. Substituting x = 0 into x - 1 gives a negative."}]'::jsonb,
 1, 'sub-exp-transformations'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): solving for the period, comparing models, combined shifts.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 31, 'Advanced',
 E'A culture starts with 50 bacteria. After 3 minutes there are 204 800.\nWhat is the doubling period?',
 '[{"text": "15 seconds", "feedback": "Correct."},
   {"text": "12 minutes", "feedback": "12 is the number of DOUBLINGS that happened in those 3 minutes, not how long one of them takes."},
   {"text": "4 minutes", "feedback": "The equation 12 = 3/t was solved upside down. Solving it properly makes t a fraction of a minute, not several minutes."},
   {"text": "0.25 seconds", "feedback": "The working gives 0.25 MINUTES. A quarter of a minute is not a quarter of a second."}]'::jsonb,
 0, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 32, 'Advanced',
 'Insects follow P(n) = 15(4)ⁿ with n in days. How many are there after one week?',
 '[{"text": "61 440", "feedback": "Six days were counted. A week is seven."},
   {"text": "983 040", "feedback": "Eight days were counted. A week is seven."},
   {"text": "420", "feedback": "That works out 15 times 4 times 7. The 7 is an exponent, so the 4 is used seven times over."},
   {"text": "245 760", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 33, 'Advanced',
 E'Polonium-210 has a half-life of 20 days.\nHow long until a sample decays to 8 percent of its initial mass?',
 '[{"text": "About 73 days", "feedback": "Correct."},
   {"text": "About 3.6 days", "feedback": "3.6 is the number of HALF-LIVES needed. Each one lasts 20 days, so they still have to be multiplied out."},
   {"text": "About 60 days", "feedback": "Three whole half-lives leaves 12.5 percent, which has not fallen far enough. It does not land on a whole number of half-lives."},
   {"text": "About 160 days", "feedback": "That counts eight half-lives because the 8 in 8 percent was read as a number of halvings."}]'::jsonb,
 0, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 34, 'Advanced',
 E'A motorcycle depreciates by 20 percent of its current value each year.\nHow long until it is worth half of what it cost?',
 '[{"text": "About 2.5 years", "feedback": "That divides 50 by 20, which treats the loss as a flat amount each year. Each year takes 20 percent of a smaller value than the year before."},
   {"text": "About 0.32 years", "feedback": "The logarithms are the wrong way up. It is log 0.5 divided by log 0.8, not the other way round."},
   {"text": "About 10 years", "feedback": "By then it is worth about a tenth of its cost, not half."},
   {"text": "About 3.1 years", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 35, 'Advanced',
 E'An account pays 7.5 percent compounded annually and holds $4200 today.\nWhat was in it two years ago, and what will be in it two years from now?',
 '[{"text": "$3634.40 two years ago, $4853.63 in two years", "feedback": "Correct."},
   {"text": "$4853.63 two years ago, $3634.40 in two years", "feedback": "The two directions are swapped. Going back in time divides by the growth factor and going forward multiplies."},
   {"text": "$3570.00 two years ago, $4830.00 in two years", "feedback": "That applies 7.5 percent of the CURRENT balance twice in each direction, which is simple interest rather than compounding."},
   {"text": "$3906.98 two years ago, $4515.00 in two years", "feedback": "Only one year was applied in each direction. The 1.075 has to be squared."}]'::jsonb,
 0, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 36, 'Advanced',
 E'$5000 is put into one account at 6 percent compounded annually, and $5000\ninto another at 6.5 percent SIMPLE interest. After 10 years, which is worth\nmore and by roughly how much?',
 '[{"text": "The two accounts end up worth the same", "feedback": "They would only match if the compounding never happened. Work both out to ten years and the totals are several hundred dollars apart."},
   {"text": "The compound account, by about $704", "feedback": "Correct."},
   {"text": "The simple interest account, by about $704", "feedback": "The gap is about that size, so the arithmetic held up; what has not been checked is which of the two balances the subtraction started from. Work both out to year 10 before deciding the direction."},
   {"text": "The simple account, because its rate is higher", "feedback": "A higher rate does win at first, but simple interest only ever earns on the original $5000 while the other earns on everything accumulated."}]'::jsonb,
 1, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 37, 'Advanced',
 'Why can y = a(b)ˣ, with a and b both positive, never output zero?',
 '[{"text": "Because the exponent x is not allowed to take the value zero", "feedback": "x = 0 is perfectly legal and gives the y-intercept. It is the OUTPUT that never reaches zero."},
   {"text": "Because the base b is only ever allowed to be greater than 1", "feedback": "b can be a fraction, and the curve then falls forever without ever landing on zero."},
   {"text": "Because the graph of y = a(b)ˣ is a straight line and not a curve", "feedback": "The graph is a curve. A straight line with a non-zero slope actually would cross zero, which is the opposite of what happens here."},
   {"text": "Because a positive base raised to any power stays positive", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 38, 'Advanced',
 'How does the graph of y = (1/3)(3ˣ) differ from the graph of y = 3(3ˣ)?',
 '[{"text": "The new curve settles onto a different horizontal asymptote from the first one", "feedback": "Multiplying by 1/3 leaves zero at zero, so both curves settle onto the same floor."},
   {"text": "Same shape and same asymptote, but it crosses the y-axis at 1/3 instead of 3", "feedback": "Correct."},
   {"text": "It decays as x increases instead of growing", "feedback": "The base is 3 in both, so both climb. The 1/3 out front only scales the outputs."},
   {"text": "It is the first curve shifted straight down", "feedback": "The 1/3 multiplies every output rather than subtracting from it, so the curve is squashed toward the axis rather than slid down it."}]'::jsonb,
 1, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 39, 'Advanced',
 'Give the horizontal asymptote and the y-intercept of y = -5(2)^(x - 3) + 6.',
 '[{"text": "Asymptote y = 6, y-intercept 1", "feedback": "The shift right was ignored, so 2 to the power 0 was used. At x = 0 the exponent is -3."},
   {"text": "Asymptote y = 6, y-intercept -34", "feedback": "The exponent came out as +3 rather than -3. Substituting x = 0 into x - 3 gives a negative."},
   {"text": "Asymptote y = 0, y-intercept 43/8", "feedback": "The + 6 lifts the whole curve, and its asymptote rises with it."},
   {"text": "Asymptote y = 6, y-intercept 43/8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 40, 'Advanced',
 E'y = 2ˣ is stretched vertically by 3, reflected in the x-axis and shifted up 1.\nGive the equation and the range.',
 '[{"text": "y = -3(2ˣ) + 1, range y > 1", "feedback": "The reflection puts the whole curve BELOW its asymptote, so 1 is the ceiling rather than the floor."},
   {"text": "y = 3(2ˣ) + 1, range y > 1", "feedback": "The reflection in the x-axis never reached the 3. It is the minus in front that flips the curve over."},
   {"text": "y = -3(2ˣ) + 1, range y ≤ 1", "feedback": "The curve creeps toward 1 forever without ever arriving, so 1 itself is not in the range."},
   {"text": "y = -3(2ˣ) + 1, range y < 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-transformations');

-- --- questions_mcr3u_u5.sql ---

-- ===========================================================================
-- MCR3U — Unit 5: Trig Geometry — 40 questions
-- ===========================================================================
-- Grade 11 Trigonometry, authored from the Jensen MCR3U lesson material for
-- this unit:
--
--   Lesson 1  Special angles and the two special triangles
--   Lesson 2  Ratios for angles greater than 90 degrees, CAST, coterminal
--   Lesson 3  Solving trig equations
--   Lesson 4  Reciprocal trig ratios
--   Lesson 5  Problems in two and three dimensions
--   Lesson 6  The ambiguous case of the sine law
--   Lesson 7  Trig identities
--
-- Six subtopics rather than seven: the ambiguous case is folded in with the
-- sine and cosine laws, because a student who gets it wrong has not made a
-- separate mistake, they have made a sine-law mistake with a second triangle
-- in it, and the dashboard should say so.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs. Exact values are given
-- in the form the Jensen material uses (1/√2 rather than √2/2), and no
-- distractor is ever an equivalent form of the answer wearing different
-- clothes.
--
-- FIGURES. Five questions carry one: 9, 19, 26, 27 and 38 — every question
-- in this unit that describes a triangle or a scene a student has to picture
-- before any trigonometry can start. That is far fewer than the 28 the Grade
-- 10 trigonometry unit needed, and the reason is the shape of the unit
-- rather than restraint: most of MCR3U Unit 5 is exact values, CAST and
-- identities, where there is no scene at all. Four families were considered
-- and REJECTED, each because the picture would do the question:
--   * the special-triangle questions (1, 2, 11, 12, 31) — a labelled 30-60-90
--     or 45-45-90 triangle has the exact value written on it
--   * the CAST and terminal-arm questions (23, 24, 32, 35) — these need axes,
--     and AUTHORING_GUIDE.md rejects anything with axes or a grid
--   * the ambiguous-case question (37) — the diagram is the hinge with side a
--     swinging on an arc, and it shows the two intersection points, which is
--     precisely what the question asks the student to work out
--   * reciprocal-ratio questions (17, 18, 21, 28, 36) — nothing to draw that
--     is not either a special triangle or a quadrant diagram
-- The five that survive are drawn by tools/make_figures.py, which asserts the
-- ruler test on each: what a student measuring the drawing computes must land
-- nearest a WRONG option.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcr3u.sql.
-- The figure file must come second, because the delete below clears the
-- figure column along with the rest of each row.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Trig Geometry';

insert into misconception_labels (tag, label) values
  ('sub-special-angles',   'Special angles and exact ratios'),
  ('sub-angles-beyond-90', 'Ratios for angles beyond 90 degrees'),
  ('sub-trig-equations',   'Solving trig equations'),
  ('sub-reciprocal-ratios','Reciprocal trig ratios'),
  ('sub-sine-cosine-law',  'Sine law, cosine law and the ambiguous case'),
  ('sub-trig-identities',  'Trig identities')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 1, 'Easy',
 E'In the 30-60-90 special triangle whose shortest side is 1,\nhow long is the hypotenuse?',
 '[{"text": "√2", "feedback": "√2 is the hypotenuse of the OTHER special triangle, the 45-45-90 one."},
   {"text": "1", "feedback": "1 is the shortest side, opposite the 30 degree angle. The hypotenuse is opposite the right angle."},
   {"text": "2", "feedback": "Correct."},
   {"text": "√3", "feedback": "√3 is the side opposite the 60 degree angle. The hypotenuse is longer than both legs."}]'::jsonb,
 2, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 2, 'Easy',
 'What is the exact value of sin 45°?',
 '[{"text": "√3/2", "feedback": "That is sin 60, which comes from the other special triangle."},
   {"text": "1/2", "feedback": "That is sin 30. In the 45-45-90 triangle the two legs are equal, so the ratio is not a half."},
   {"text": "√2", "feedback": "√2 is the HYPOTENUSE of the 45-45-90 triangle. A sine is a ratio, and it cannot exceed 1."},
   {"text": "1/√2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 3, 'Easy',
 'In which quadrant are all three primary trig ratios positive?',
 '[{"text": "The first", "feedback": "Correct."},
   {"text": "The second", "feedback": "In the second quadrant only sine is positive, which is the S in CAST."},
   {"text": "The third", "feedback": "In the third quadrant only tangent is positive, which is the T in CAST."},
   {"text": "The fourth", "feedback": "In the fourth quadrant only cosine is positive, which is the C in CAST."}]'::jsonb,
 0, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 4, 'Easy',
 'What is the reference angle for 330°?',
 '[{"text": "60°", "feedback": "That would be the reference angle for 300 degrees. Subtract 330 from a full turn."},
   {"text": "150°", "feedback": "A reference angle is measured to the nearest part of the x-axis, so it is never more than 90 degrees."},
   {"text": "330°", "feedback": "That is the angle itself. The reference angle is the acute angle it makes with the x-axis."},
   {"text": "30°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 5, 'Easy',
 'If sin θ = 1/2, what is the ACUTE angle θ?',
 '[{"text": "150°", "feedback": "150 does have a sine of a half, but it is obtuse. The question asks for the acute angle."},
   {"text": "30°", "feedback": "Correct."},
   {"text": "60°", "feedback": "sin 60 is √3/2. The angle whose sine is a half is the smaller one in the special triangle."},
   {"text": "45°", "feedback": "sin 45 is 1/√2, which is about 0.71 rather than 0.5."}]'::jsonb,
 1, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 6, 'Easy',
 'How many solutions does sin θ = 0.4 have between 0° and 360°?',
 '[{"text": "4", "feedback": "Four solutions would need two full turns. Between 0 and 360 there is only one turn."},
   {"text": "2", "feedback": "Correct."},
   {"text": "1", "feedback": "The calculator gives one, but sine is positive in two quadrants, so a second angle shares the same value."},
   {"text": "3", "feedback": "Sine repeats once per full turn, and it takes each value between -1 and 1 exactly twice in a single turn."}]'::jsonb,
 1, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 7, 'Easy',
 'What is csc θ equal to?',
 '[{"text": "sin θ/cos θ", "feedback": "That is tan θ, and it is not a reciprocal ratio at all."},
   {"text": "1/sin θ", "feedback": "Correct."},
   {"text": "1/cos θ", "feedback": "That is sec θ. The names do not line up with the letters they start with, which is exactly what makes them easy to swap."},
   {"text": "1/tan θ", "feedback": "That is cot θ."}]'::jsonb,
 1, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 8, 'Easy',
 'Which law do you use when you are given two sides and the angle BETWEEN them?',
 '[{"text": "The Pythagorean theorem", "feedback": "Pythagoras only works in a right triangle, and nothing here says the contained angle is 90 degrees."},
   {"text": "The ambiguous case test", "feedback": "That test is for two sides and an angle NOT between them, where a second triangle might fit the same numbers."},
   {"text": "The cosine law", "feedback": "Correct."},
   {"text": "The sine law", "feedback": "The sine law needs a side and the angle OPPOSITE it as a matched pair, and a contained angle is not opposite either of the given sides."}]'::jsonb,
 2, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 9, 'Easy',
 'Two angles of a triangle are 40° and 75°. What is the third?',
 '[{"text": "105°", "feedback": "That is what would be left if only the 75 were taken off 180. Both given angles come off."},
   {"text": "65°", "feedback": "Correct."},
   {"text": "115°", "feedback": "That is the sum of the two given angles, not what is left over from 180."},
   {"text": "45°", "feedback": "That would make the three angles add to 160. They have to add to exactly 180."}]'::jsonb,
 1, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 10, 'Easy',
 'Which of these is the Pythagorean identity?',
 '[{"text": "sin²θ + cos²θ = 1", "feedback": "Correct."},
   {"text": "sin²θ - cos²θ = 1", "feedback": "The sign is wrong. Try θ = 0: that version gives -1, not 1."},
   {"text": "sin θ + cos θ = 1", "feedback": "The squares matter. Try θ = 45: that version gives about 1.41."},
   {"text": "tan²θ + 1 = sin²θ", "feedback": "The right-hand side is wrong. Dividing the real identity through by cos²θ gives sec²θ there, not sin²θ."}]'::jsonb,
 0, 'sub-trig-identities'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 11, 'Medium',
 'What is the exact value of cos 60°?',
 '[{"text": "1/2", "feedback": "Correct."},
   {"text": "√3/2", "feedback": "That is cos 30. In the special triangle the side adjacent to 60 is the SHORT one."},
   {"text": "1/√2", "feedback": "That is cos 45, from the other special triangle."},
   {"text": "2", "feedback": "2 is the hypotenuse of the 30-60-90 triangle. A cosine is a ratio and cannot exceed 1."}]'::jsonb,
 0, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 12, 'Medium',
 'What is the exact value of tan 30°?',
 '[{"text": "√3", "feedback": "That is tan 60. The ratio is upside down: at 30 degrees the opposite side is the short one."},
   {"text": "1/2", "feedback": "1/2 is sin 30. Tangent divides by the ADJACENT side, not by the hypotenuse."},
   {"text": "√3/2", "feedback": "√3/2 is cos 30. Tangent divides by the adjacent side, not by the hypotenuse."},
   {"text": "1/√3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 13, 'Medium',
 'What is the exact value of sin 225°?',
 '[{"text": "-1/√2", "feedback": "Correct."},
   {"text": "1/√2", "feedback": "The reference angle is right but 225 lands in the third quadrant, where sine is negative."},
   {"text": "-√3/2", "feedback": "The sign is right but the reference angle is not. 225 - 180 gives 45, not 60."},
   {"text": "-1/2", "feedback": "The sign is right but the reference angle is not. 225 - 180 gives 45, not 30."}]'::jsonb,
 0, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 14, 'Medium',
 'Which pair of angles is coterminal with 97°?',
 '[{"text": "457° and 817°", "feedback": "Correct."},
   {"text": "263° and 623°", "feedback": "263 is 360 - 97, which is a reflection rather than a full turn. Coterminal angles differ by whole turns."},
   {"text": "97° and 187°", "feedback": "187 is 97 + 90, which is a quarter turn. A full turn is 360."},
   {"text": "-97° and 277°", "feedback": "-97 flips the angle to the other side of the axis rather than turning it all the way round."}]'::jsonb,
 0, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 15, 'Medium',
 'Find both angles between 0° and 360° with tan θ = -√3.',
 '[{"text": "60° and 120°", "feedback": "Only the second of these has a negative tangent. Tangent is positive in the first quadrant."},
   {"text": "150° and 330°", "feedback": "The related acute angle is 60, not 30. tan 60 is √3."},
   {"text": "120° and 300°", "feedback": "Correct."},
   {"text": "60° and 240°", "feedback": "Those are the angles where the tangent is POSITIVE √3. A negative tangent lives in the second and fourth quadrants."}]'::jsonb,
 2, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 16, 'Medium',
 'Find both angles between 0° and 360° with sin θ = √3/2.',
 '[{"text": "30° and 150°", "feedback": "The related acute angle is 60, not 30. sin 30 is a half."},
   {"text": "120° and 240°", "feedback": "The first-quadrant solution went missing. Sine is positive in both the first and second quadrants."},
   {"text": "60° and 120°", "feedback": "Correct."},
   {"text": "60° and 240°", "feedback": "240 is in the third quadrant, where sine is negative. The second solution comes from 180 MINUS the first."}]'::jsonb,
 2, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 17, 'Medium',
 'What is the exact value of sec 120°?',
 '[{"text": "-√3", "feedback": "That is tan 120. Secant comes from cosine, not from tangent."},
   {"text": "-2", "feedback": "Correct."},
   {"text": "2", "feedback": "The size is right but 120 sits in the second quadrant, where cosine and therefore secant are negative."},
   {"text": "-1/2", "feedback": "That is cos 120 itself. Secant is its RECIPROCAL, so the fraction turns over."}]'::jsonb,
 1, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 18, 'Medium',
 'What is the exact value of csc 150°?',
 '[{"text": "-2", "feedback": "150 is in the second quadrant, where sine is positive, so its reciprocal is positive too."},
   {"text": "√2", "feedback": "√2 is csc 45. The related acute angle for 150 is 30, not 45."},
   {"text": "2", "feedback": "Correct."},
   {"text": "1/2", "feedback": "That is sin 150 itself. Cosecant is its RECIPROCAL, so the fraction turns over."}]'::jsonb,
 2, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 19, 'Medium',
 E'In triangle ABC, angle A = 40°, angle B = 75° and side b = 12 cm.\nFind side a, to one decimal place.',
 '[{"text": "11.3 cm", "feedback": "The third angle, 65 degrees, was used in place of angle A. Side a is opposite A."},
   {"text": "7.7 cm", "feedback": "That treats the triangle as right-angled and works out 12 sin 40. There is no right angle here, so the sine law is needed."},
   {"text": "8.0 cm", "feedback": "Correct."},
   {"text": "18.0 cm", "feedback": "The ratio was set up upside down. Side a pairs with angle A on the same side of the equation."}]'::jsonb,
 2, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 20, 'Medium',
 'Simplify: sin θ / cos θ',
 '[{"text": "1", "feedback": "Sine and cosine are different numbers for almost every angle, so they do not cancel."},
   {"text": "tan θ", "feedback": "Correct."},
   {"text": "cot θ", "feedback": "That is the same fraction upside down, cos over sin."},
   {"text": "sec θ", "feedback": "sec θ is 1 over cos θ. There is a sine on top here, not a 1."}]'::jsonb,
 1, 'sub-trig-identities'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): reference angles, quadrant work, solving whole triangles.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 21, 'Challenge',
 'What is the exact value of cot 300°?',
 '[{"text": "-1/√3", "feedback": "Correct."},
   {"text": "1/√3", "feedback": "The size is right but 300 sits in the fourth quadrant, where tangent and therefore cotangent are negative."},
   {"text": "-√3", "feedback": "That is tan 300. Cotangent is its reciprocal, so the fraction turns over."},
   {"text": "√3", "feedback": "Both the size and the sign are off: the reciprocal is needed, and the fourth quadrant makes it negative."}]'::jsonb,
 0, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 22, 'Challenge',
 'What is the exact value of tan 135°?',
 '[{"text": "-1/√3", "feedback": "The sign is right but the reference angle is not. 180 - 135 gives 45, not 30."},
   {"text": "-1", "feedback": "Correct."},
   {"text": "1", "feedback": "The related acute angle 45 gives 1, but 135 is in the second quadrant, where tangent is negative."},
   {"text": "-√3", "feedback": "The sign is right but the reference angle is not. 180 - 135 gives 45, not 60."}]'::jsonb,
 1, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 23, 'Challenge',
 E'cos A = -8/17 and the terminal arm of A lies in the second quadrant.\nFind sin A and tan A.',
 '[{"text": "sin A = 15/17 and tan A = 15/8", "feedback": "The sine is right, but a positive sine over a negative cosine has to give a negative tangent."},
   {"text": "sin A = 15/17 and tan A = -15/8", "feedback": "Correct."},
   {"text": "sin A = -15/17 and tan A = 15/8", "feedback": "The quadrant was not used. In the second quadrant sine is positive and tangent is negative."},
   {"text": "sin A = 15/17 and tan A = -8/15", "feedback": "The tangent is upside down. It is the opposite side over the adjacent one."}]'::jsonb,
 1, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 24, 'Challenge',
 E'The point P(-3, 4) lies on the terminal arm of an angle in standard\nposition. Find sin θ and tan θ.',
 '[{"text": "sin θ = -4/5 and tan θ = -4/3", "feedback": "The minus belongs to the x-coordinate, not to the y-coordinate. Sine is built from y over r."},
   {"text": "sin θ = -3/5 and tan θ = -3/4", "feedback": "The two coordinates have swapped roles. Sine uses the y value, tangent is y over x."},
   {"text": "sin θ = 4/5 and tan θ = 4/3", "feedback": "The sine is right, but tangent divides by the x value, and that x value is negative."},
   {"text": "sin θ = 4/5 and tan θ = -4/3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 25, 'Challenge',
 E'Find both angles between 0° and 360° with tan θ = -0.32,\neach to one decimal place.',
 '[{"text": "197.7° and 342.3°", "feedback": "The second-quadrant solution was placed in the third instead. Tangent is positive in the third quadrant."},
   {"text": "162.3° and 197.7°", "feedback": "Both solutions were put on the same side of the axis. Tangent is negative in the second and fourth quadrants, not the second and third."},
   {"text": "162.3° and 342.3°", "feedback": "Correct."},
   {"text": "17.7° and 197.7°", "feedback": "The minus on the ratio was dropped. Those are the two angles whose tangent is POSITIVE 0.32."}]'::jsonb,
 2, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 26, 'Challenge',
 E'In triangle ABC, a = 42 cm, b = 21 cm and c = 28 cm.\nFind angle A, to one decimal place.',
 '[{"text": "36.3°", "feedback": "That is angle C. Angle A is opposite side a, which is the longest side here."},
   {"text": "117.3°", "feedback": "Correct."},
   {"text": "62.7°", "feedback": "The cosine came out negative, and a negative cosine means an obtuse angle. That value is its supplement."},
   {"text": "26.4°", "feedback": "That is angle B. Angle A is opposite side a, which is the LONGEST side, so A is the largest angle."}]'::jsonb,
 1, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 27, 'Challenge',
 E'A tree 18.5 m tall casts a shadow 10.2 m long.\nWhat is the angle of elevation of the sun, to one decimal place?',
 '[{"text": "61.1°", "feedback": "Correct."},
   {"text": "28.9°", "feedback": "The opposite and adjacent sides are the wrong way round. The tree is opposite the angle of elevation, and it is the taller of the two."},
   {"text": "33.5°", "feedback": "That uses sine with the shadow over the tree, which treats the tree as the hypotenuse. The tree is a vertical leg, not the slanted side."},
   {"text": "1.1°", "feedback": "That is the answer in RADIANS. The calculator was left in the wrong mode; 1.07 radians is the same angle."}]'::jsonb,
 0, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 28, 'Challenge',
 'If cot θ = 1 and θ lies between 180° and 270°, what is θ?',
 '[{"text": "225°", "feedback": "Correct."},
   {"text": "45°", "feedback": "45 does satisfy cot θ = 1, but it sits in the first quadrant and the question restricts θ to between 180 and 270."},
   {"text": "135°", "feedback": "At 135 the cotangent is -1. Cotangent is positive in the first and third quadrants."},
   {"text": "315°", "feedback": "At 315 the cotangent is -1, and 315 is outside the range asked for as well."}]'::jsonb,
 0, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 29, 'Challenge',
 'Simplify: sec θ cos θ + sec θ sin θ',
 '[{"text": "1 + cot θ", "feedback": "The second term gives sine over cosine, and that fraction is tangent. Cotangent is the other way up."},
   {"text": "sec θ + tan θ", "feedback": "The first term simplifies all the way: secant times cosine leaves 1, because the two are reciprocals."},
   {"text": "cos θ + sin θ", "feedback": "The secant was dropped rather than combined. Write it as 1 over cosine and multiply through."},
   {"text": "1 + tan θ", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-identities'),

(11, 'MCR3U', 'Trig Geometry', 5, 30, 'Challenge',
 'Simplify: tan²x + cos²x + sin²x',
 '[{"text": "1/cos²x", "feedback": "Correct."},
   {"text": "1/sin²x", "feedback": "That is what cot²x + 1 gives. The term here is tan²x, so a different Pythagorean identity applies."},
   {"text": "2", "feedback": "The last two terms do collapse to 1, but tan²x is not 1 as well. It stays as a term."},
   {"text": "cos²x", "feedback": "The tan²x term was cancelled away rather than converted. Write it as sin²x over cos²x and combine."}]'::jsonb,
 0, 'sub-trig-identities'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): the ambiguous case, three dimensions, and identities.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 31, 'Advanced',
 'What is the exact value of sin 60° cos 30° + cos 60° sin 30°?',
 '[{"text": "3/4", "feedback": "That is the first product on its own. The second product still has to be added to it."},
   {"text": "1/2", "feedback": "The two products were averaged rather than added."},
   {"text": "√3/2", "feedback": "That is sin 60 by itself, with the rest of the expression left out."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 32, 'Advanced',
 E'Find both angles between 0° and 360° with sin θ = -0.46,\neach to one decimal place.',
 '[{"text": "27.4° and 152.6°", "feedback": "The minus on the ratio was dropped. Those are the two angles whose sine is POSITIVE 0.46."},
   {"text": "152.6° and 332.6°", "feedback": "The first solution is in the second quadrant, where sine is positive. A negative sine lives in the third and fourth."},
   {"text": "207.4° and 27.4°", "feedback": "The first solution is right, but the second was left as the bare related acute angle, where the sine comes out positive."},
   {"text": "207.4° and 332.6°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 33, 'Advanced',
 'Solve 2 sin θ - 1 = 0 for 0° ≤ θ ≤ 360°.',
 '[{"text": "60° and 120°", "feedback": "Rearranging gives sin θ = 1/2, not √3/2. The 2 divides rather than multiplies."},
   {"text": "30° and 150°", "feedback": "Correct."},
   {"text": "30° only", "feedback": "The calculator gives one angle, but sine is positive in two quadrants, so a second solution shares the value."},
   {"text": "30° and 210°", "feedback": "210 is in the third quadrant, where sine is negative. The second solution comes from 180 MINUS the first."}]'::jsonb,
 1, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 34, 'Advanced',
 'Solve tan θ = -1 for 0° ≤ θ ≤ 360°.',
 '[{"text": "45° and 135°", "feedback": "At 45 the tangent is positive. Only one of these two actually satisfies the equation."},
   {"text": "225° and 315°", "feedback": "At 225 the tangent is positive, because tangent is positive in the third quadrant."},
   {"text": "135° and 315°", "feedback": "Correct."},
   {"text": "45° and 225°", "feedback": "Those are the angles where the tangent is POSITIVE 1. The minus sign moves both solutions a quadrant along."}]'::jsonb,
 2, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 35, 'Advanced',
 E'The point Q(-12, -5) lies on the terminal arm of an angle in standard\nposition. Find sec θ and cot θ.',
 '[{"text": "sec θ = 13/12 and cot θ = 12/5", "feedback": "The cotangent is right, but the x value is negative, so the secant built from it is negative too."},
   {"text": "sec θ = -13/12 and cot θ = -12/5", "feedback": "Both coordinates are negative, and a negative divided by a negative gives a positive cotangent."},
   {"text": "sec θ = -13/12 and cot θ = 12/5", "feedback": "Correct."},
   {"text": "sec θ = -12/13 and cot θ = 5/12", "feedback": "Those are cos θ and tan θ. Both still need turning over to become the reciprocal ratios."}]'::jsonb,
 2, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 36, 'Advanced',
 E'csc θ = -13/5 and the terminal arm of θ lies in the third quadrant.\nWhat is cos θ?',
 '[{"text": "12/13", "feedback": "The size is right, but in the third quadrant cosine is negative as well as sine."},
   {"text": "-5/12", "feedback": "That divides the opposite side by the adjacent one and keeps the minus from the sine alone. Cosine is the adjacent side over the hypotenuse."},
   {"text": "-13/12", "feedback": "That is sec θ, the reciprocal. The question asks for cosine itself."},
   {"text": "-12/13", "feedback": "Correct."}]'::jsonb,
 3, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 37, 'Advanced',
 E'In triangle ABC, a = 12 cm, b = 17 cm and angle A = 21°.\nHow many triangles are possible, and what can angle B be?',
 '[{"text": "Two triangles, with B = 30.5° or B = 210.5°", "feedback": "The second angle comes from 180 MINUS the first, not from adding 180. An angle of 210 degrees cannot sit inside a triangle."},
   {"text": "No triangle exists", "feedback": "No triangle would need a to be shorter than the height b sin A, which is about 6.1 cm. Side a is twice that."},
   {"text": "Two triangles, with B = 30.5° or B = 149.5°", "feedback": "Correct."},
   {"text": "One triangle, with B = 30.5°", "feedback": "The height b sin A is about 6.1 cm, and a sits between that and b. When h is less than a and a is less than b, a second triangle fits the same numbers."}]'::jsonb,
 2, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 38, 'Advanced',
 E'Dave is in a balloon 400 m up, exactly above the midpoint of two houses.\nRhonda stands 4.6 km from House 1 and 3.4 km from House 2, and the two\nhouses are 64° apart as she sees them. Find her angle of elevation to Dave.',
 '[{"text": "About 5.2°", "feedback": "The distance used was the whole gap between the houses. Rhonda is not standing on that line, so her distance to the midpoint has to be found separately."},
   {"text": "About 10.4°", "feedback": "The distance used was half the gap between the houses, which would only be right if Rhonda were standing at one of them."},
   {"text": "About 71.5°", "feedback": "That is the angle at House 2 inside the ground triangle, found on the way. The elevation is measured from where Rhonda stands."},
   {"text": "About 6.7°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 39, 'Advanced',
 'Simplify: (1 - cos²x)/(sin x cos x)',
 '[{"text": "cot x", "feedback": "The numerator was read as cos²x. The 1 - in front of it has to be resolved with the Pythagorean identity first."},
   {"text": "sin x cos x", "feedback": "The cosine underneath was multiplied through rather than divided out. 1 - cos²x is sin²x, which shares a factor with the bottom."},
   {"text": "sec x", "feedback": "The numerator is not 1. It becomes sin²x, and one factor of sine cancels with the bottom rather than all of it."},
   {"text": "tan x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-identities'),

(11, 'MCR3U', 'Trig Geometry', 5, 40, 'Advanced',
 'Simplify: (sec²θ - 1)/sec²θ',
 '[{"text": "sin²θ", "feedback": "Correct."},
   {"text": "cos²θ", "feedback": "The numerator was treated as 1, leaving nothing but the reciprocal of sec²θ. The - 1 is subtracted from sec²θ rather than standing alone on top."},
   {"text": "tan²θ", "feedback": "The numerator was simplified correctly, but the division by sec²θ was never carried out."},
   {"text": "1", "feedback": "The sec²θ terms were cancelled top and bottom, but the - 1 stops sec²θ being a factor of the numerator."}]'::jsonb,
 0, 'sub-trig-identities');

-- --- questions_mcr3u_u6.sql ---

-- ===========================================================================
-- MCR3U — Unit 6: Trig Functions — 40 questions
-- ===========================================================================
-- Grade 11 Trig Functions, authored from the Jensen MCR3U lesson material
-- for this unit:
--
--   Lesson 1  Periodic behaviour
--   Lesson 2  Graphing sine and cosine
--   Lesson 3  The transformed graph from the equation
--   Lesson 4  The transformed equation from the graph
--   Lesson 5  Trig applications 1
--   Lesson 6  Trig applications 2
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- A NOTE ON HOW THE GRAPH QUESTIONS ARE ASKED. Jensen asks Lesson 4 with a
-- printed curve on a grid: read the amplitude, period and shift off the
-- picture, then write the equation. That question cannot be asked here.
-- A grid IS the answer — the amplitude and the period can be counted off
-- the squares, and AUTHORING_GUIDE.md rejects any figure with axes for
-- exactly that reason. So every one of those questions is posed through the
-- values a student would have had to read first: the maximum, the minimum,
-- the period and where the curve starts. That is strictly harder than
-- reading a graph, it is what the exam expects a student to be able to do
-- from a table or a description, and it cannot leak.
--
-- FIGURES. Two questions carry one, 29 and 39, and both are scenes rather
-- than graphs: a windmill and a ferris wheel. Neither picture contains the
-- answer — one asks for a height that the drawing is deliberately out of
-- proportion about, and the other asks for an equation, which no drawing
-- can state. Every other question in this unit is about a curve, and a
-- picture of the curve would do the work.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcr3u.sql.
-- The figure file must come second, because the delete below clears the
-- figure column along with the rest of each row.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Trig Functions';

insert into misconception_labels (tag, label) values
  ('sub-periodic-behaviour', 'Periodic behaviour'),
  ('sub-graph-sin-cos',      'Graphing sine and cosine'),
  ('sub-trig-from-equation', 'Reading a trig equation'),
  ('sub-trig-from-graph',    'Building a trig equation'),
  ('sub-trig-applications',  'Trig applications')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 1, 'Easy',
 'What is the period of y = sin x, in degrees?',
 '[{"text": "360°", "feedback": "Correct."},
   {"text": "180°", "feedback": "At 180 degrees the curve is only half way through: it has come back to the axis but it is heading down, not up."},
   {"text": "90°", "feedback": "90 degrees is a quarter of the way round, where the curve reaches its first maximum."},
   {"text": "1", "feedback": "1 is the amplitude, the height of the curve. The period is measured along the x-axis."}]'::jsonb,
 0, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 2, 'Easy',
 'What is the amplitude of y = sin x?',
 '[{"text": "360", "feedback": "360 is the period, measured along the x-axis. Amplitude is measured up the y-axis."},
   {"text": "0", "feedback": "0 is the equation of the axis the curve waves about. The amplitude is how far it strays from it."},
   {"text": "1", "feedback": "Correct."},
   {"text": "2", "feedback": "2 is the full distance from the lowest point to the highest. Amplitude is HALF of that."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 3, 'Easy',
 'What is the value of sin 90°?',
 '[{"text": "0", "feedback": "sin 0 and sin 180 are zero. At 90 the sine curve is at the top of its first hill."},
   {"text": "-1", "feedback": "-1 is sin 270, at the bottom of the trough."},
   {"text": "90", "feedback": "A sine is a ratio between -1 and 1. It is never the angle itself."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 4, 'Easy',
 'Between 0° and 360°, where does y = cos x reach its maximum?',
 '[{"text": "At 180°", "feedback": "At 180 cosine is at its lowest, not its highest."},
   {"text": "At 270°", "feedback": "At 270 cosine is back on the axis, half way up from its trough."},
   {"text": "At 0°", "feedback": "Correct."},
   {"text": "At 90°", "feedback": "That is where SINE peaks. Cosine starts at the top and is already coming down by 90."}]'::jsonb,
 2, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 5, 'Easy',
 'What is the amplitude of y = 4 sin x?',
 '[{"text": "1/4", "feedback": "The 4 multiplies the outputs, so it makes the curve taller rather than shorter."},
   {"text": "4", "feedback": "Correct."},
   {"text": "1", "feedback": "1 is the amplitude of the plain sine curve. The 4 out front stretches it."},
   {"text": "8", "feedback": "8 is the full distance from the lowest point to the highest. Amplitude is half of that."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 6, 'Easy',
 'What is the equation of the axis of y = sin x + 5?',
 '[{"text": "y = 0", "feedback": "That is the axis of the plain sine curve, before the + 5 lifted it."},
   {"text": "y = 1", "feedback": "1 is the amplitude. The axis is the level the curve waves about."},
   {"text": "x = 5", "feedback": "The axis of a sinusoid is a horizontal line, so its equation names y."},
   {"text": "y = 5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 7, 'Easy',
 'A sine curve has a maximum of 7 and a minimum of 1. What is its amplitude?',
 '[{"text": "3", "feedback": "Correct."},
   {"text": "6", "feedback": "6 is the full distance from the minimum to the maximum. Amplitude is half of that."},
   {"text": "4", "feedback": "4 is the equation of the axis, the level half way between the two."},
   {"text": "8", "feedback": "That adds the maximum and the minimum. Amplitude comes from their difference."}]'::jsonb,
 0, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 8, 'Easy',
 'A sine curve has a maximum of 7 and a minimum of 1. What is the equation of its axis?',
 '[{"text": "y = 3", "feedback": "3 is the amplitude, which comes from the DIFFERENCE. The axis comes from the average."},
   {"text": "y = 6", "feedback": "6 is the difference between the two. The axis sits half way between them."},
   {"text": "y = 8", "feedback": "That adds the two without halving. The axis is the average of the maximum and the minimum."},
   {"text": "y = 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 9, 'Easy',
 E'A ferris wheel takes 40 seconds to turn once.\nWhat is the period of the height function of one seat?',
 '[{"text": "40 seconds", "feedback": "Correct."},
   {"text": "20 seconds", "feedback": "20 seconds is half a turn, which takes a seat from the bottom to the top. A full cycle brings it back down again."},
   {"text": "80 seconds", "feedback": "80 seconds is two full turns. The pattern has already repeated once by then."},
   {"text": "360 seconds", "feedback": "360 is the number of DEGREES in a full turn, not the number of seconds this wheel takes."}]'::jsonb,
 0, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 10, 'Easy',
 E'A lake has a highest tide of 5.2 m and a lowest tide of 0.6 m.\nWhat is the amplitude of the tide function?',
 '[{"text": "4.6 m", "feedback": "4.6 is the full range from lowest to highest. Amplitude is half of that."},
   {"text": "2.9 m", "feedback": "2.9 is the equation of the axis, the level half way between the two tides."},
   {"text": "5.8 m", "feedback": "That adds the two heights. Amplitude comes from their difference, halved."},
   {"text": "2.3 m", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 11, 'Medium',
 'A sine function repeats every 90°. What is k in y = sin(kx)?',
 '[{"text": "270", "feedback": "That is 360 take away 90. The two are related by division, not subtraction."},
   {"text": "4", "feedback": "Correct."},
   {"text": "1/4", "feedback": "The relationship is upside down. A SHORTER period needs a LARGER k, because k is 360 divided by the period."},
   {"text": "90", "feedback": "90 is the period itself. k is what you divide 360 by to get it."}]'::jsonb,
 1, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 12, 'Medium',
 'What is the period of y = cos(3x)?',
 '[{"text": "3°", "feedback": "3 is the value of k. The period is 360 divided by it."},
   {"text": "360°", "feedback": "360 is the period of the plain cosine curve, before the 3 squeezed it."},
   {"text": "120°", "feedback": "Correct."},
   {"text": "1080°", "feedback": "The 3 was multiplied instead of divided. A larger k squeezes the curve, so the period gets shorter."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 13, 'Medium',
 'What is the graph of y = sin x doing at x = 180°?',
 '[{"text": "Reaching a maximum", "feedback": "The maximum is at 90. By 180 the curve has come all the way back down to the axis."},
   {"text": "Reaching a minimum", "feedback": "The minimum is at 270. At 180 the curve is level with the axis, not below it."},
   {"text": "Undefined", "feedback": "Sine is defined for every angle. It is tangent that has gaps in it."},
   {"text": "Crossing the axis on its way down", "feedback": "Correct."}]'::jsonb,
 3, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 14, 'Medium',
 'Between 0° and 360°, at what value of x does y = cos x equal -1?',
 '[{"text": "180°", "feedback": "Correct."},
   {"text": "0°", "feedback": "At 0 the cosine curve is at its highest, at +1."},
   {"text": "90°", "feedback": "At 90 cosine is 0, half way down from its peak."},
   {"text": "270°", "feedback": "270 is where SINE bottoms out. Cosine is back on the axis there."}]'::jsonb,
 0, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 15, 'Medium',
 'For y = 4 cos[3(x - 20°)] + 5, give the amplitude and the period.',
 '[{"text": "Amplitude 3, period 120°", "feedback": "3 is k, and it sits inside the bracket where it changes the period. The amplitude is out front."},
   {"text": "Amplitude 4, period 120°", "feedback": "Correct."},
   {"text": "Amplitude 4, period 1080°", "feedback": "The 3 was multiplied by 360 instead of divided into it. A larger k squeezes the curve."},
   {"text": "Amplitude 5, period 120°", "feedback": "5 is the vertical shift, which moves the curve up. The amplitude is the number in front of the cosine."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 16, 'Medium',
 'For y = 4 cos[3(x - 20°)] + 5, give the maximum and minimum values.',
 '[{"text": "Maximum 9, minimum 1", "feedback": "Correct."},
   {"text": "Maximum 4, minimum -4", "feedback": "That is the plain 4 cos curve, before the + 5 lifted the whole thing."},
   {"text": "Maximum 5, minimum -5", "feedback": "5 is the level the curve waves about. The amplitude of 4 is added and subtracted from it."},
   {"text": "Maximum 9, minimum -9", "feedback": "The minimum was taken as the negative of the maximum. That only works for a curve waving about zero, and the + 5 has lifted this one."}]'::jsonb,
 0, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 17, 'Medium',
 E'A sinusoid has a maximum at (0, 2/3), a vertical shift of 1/3 up\nand a period of 120°. What is its amplitude?',
 '[{"text": "1/3", "feedback": "Correct."},
   {"text": "2/3", "feedback": "2/3 is the height of the maximum above zero. Amplitude is measured from the AXIS, which is already 1/3 up."},
   {"text": "1", "feedback": "That adds the maximum to the shift. Amplitude is the maximum take away the axis."},
   {"text": "1/2", "feedback": "That averages the maximum with the vertical shift. Averaging belongs to a maximum and a minimum, and the axis here is given already."}]'::jsonb,
 0, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 18, 'Medium',
 'A sinusoid has a period of 120°. What is its k value?',
 '[{"text": "120", "feedback": "120 is the period itself. k is what 360 has to be divided by to get it."},
   {"text": "240", "feedback": "That is 360 take away 120. The two are related by division, not subtraction."},
   {"text": "3", "feedback": "Correct."},
   {"text": "1/3", "feedback": "The relationship is upside down. k is 360 divided by the period, not the period divided by 360."}]'::jsonb,
 2, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 19, 'Medium',
 E'A lake has its highest tide at 8:00 am and its lowest at 8:00 pm,\nand the pattern repeats daily. What is the period?',
 '[{"text": "24 hours", "feedback": "Correct."},
   {"text": "12 hours", "feedback": "12 hours is high tide to low tide, which is HALF a cycle. A full cycle returns to high tide."},
   {"text": "8 hours", "feedback": "8 is when the high tide happens, measured from midnight. That is the phase shift, not the period."},
   {"text": "20 hours", "feedback": "That adds 8 and 12. The period is the time from one high tide to the next."}]'::jsonb,
 0, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 20, 'Medium',
 E'A lake has a highest tide of 5.2 m and a lowest of 0.6 m.\nWhat is the equation of the axis of the tide function?',
 '[{"text": "y = 5.8", "feedback": "That adds the two heights without halving them."},
   {"text": "y = 0.6", "feedback": "0.6 is the lowest tide, the bottom of the curve. The axis is half way up."},
   {"text": "y = 2.9", "feedback": "Correct."},
   {"text": "y = 2.3", "feedback": "2.3 is the amplitude, which comes from the DIFFERENCE. The axis comes from the average."}]'::jsonb,
 2, 'sub-trig-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): several parameters at once, and building equations.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 21, 'Challenge',
 'What is the period of y = (1/4) sin[(1/2)(x + 90°)] - 2?',
 '[{"text": "180°", "feedback": "The 1/2 was multiplied by 360 instead of divided into it. A k below 1 stretches the curve out."},
   {"text": "90°", "feedback": "90 is the phase shift, which slides the curve sideways. The period comes from k."},
   {"text": "360°", "feedback": "360 is the period of the plain sine curve, before the 1/2 stretched it."},
   {"text": "720°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 22, 'Challenge',
 'For y = (1/4) sin[(1/2)(x + 90°)] - 2, give the amplitude and the maximum value.',
 '[{"text": "Amplitude 4, maximum 2", "feedback": "The 1/4 was turned over. A quarter out front squashes the curve rather than stretching it."},
   {"text": "Amplitude 0.25, maximum -2.25", "feedback": "That is the MINIMUM. The amplitude is added to the axis for the peak and subtracted for the trough."},
   {"text": "Amplitude 0.25, maximum -1.75", "feedback": "Correct."},
   {"text": "Amplitude 0.25, maximum 0.25", "feedback": "That reports the amplitude twice. The - 2 on the end moves the whole curve before any peak is read off it."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 23, 'Challenge',
 'Which single transformation turns the graph of y = sin x into y = cos x?',
 '[{"text": "A shift up of 1", "feedback": "That would lift the whole curve off the axis. Both sine and cosine still wave about y = 0."},
   {"text": "A shift left of 90°", "feedback": "Correct."},
   {"text": "A shift right of 90°", "feedback": "That takes cosine to sine, not the other way. Cosine peaks a quarter turn EARLIER than sine."},
   {"text": "A reflection in the x-axis", "feedback": "That gives y = -sin x, which is zero at 0 rather than at its maximum."}]'::jsonb,
 1, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 24, 'Challenge',
 'What is the value of y = sin(x + 60°) + 1 when x = 30°?',
 '[{"text": "1.5", "feedback": "That takes the sine of 30, which is a half, and adds 1. The sine is of 90, not of 30."},
   {"text": "2", "feedback": "Correct."},
   {"text": "1", "feedback": "That reads the cosine at 90 rather than the sine, the across value on the unit circle instead of the up one."},
   {"text": "0.5", "feedback": "That misses both the shift inside and the + 1 outside."}]'::jsonb,
 1, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 25, 'Challenge',
 'Which list of steps turns y = sin x into y = -3 sin[4(x + 30°)] + 1?',
 '[{"text": "Reflect in the x-axis, stretch vertically by 3, STRETCH horizontally by 4, left 30°, up 1", "feedback": "k = 4 squeezes the curve rather than stretching it. The scale factor is 1 over k."},
   {"text": "Reflect in the x-axis, stretch vertically by 3, compress horizontally by 1/4, RIGHT 30°, up 1", "feedback": "The bracket reads x + 30, and a plus inside moves the curve left."},
   {"text": "Stretch vertically by 3, compress horizontally by 1/4, left 30°, up 1", "feedback": "The minus in front of the 3 was read as part of the number. It flips the curve over as well as stretching it."},
   {"text": "Reflect in the x-axis, stretch vertically by 3, compress horizontally by 1/4, left 30°, up 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 26, 'Challenge',
 'For y = (1/4) sin[(1/2)(x + 90°)] - 2, give the phase shift and the vertical shift.',
 '[{"text": "Left 45°, down 2", "feedback": "The 1/2 was applied to the 90 as well. The 90 is already outside the k, sitting in the (x - d) bracket, so it is the shift as it stands."},
   {"text": "Left 90°, down 2", "feedback": "Correct."},
   {"text": "Right 90°, down 2", "feedback": "The bracket reads x + 90, and a plus inside moves the curve left."},
   {"text": "Left 90°, up 2", "feedback": "The 2 is being subtracted, so the whole curve drops."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 27, 'Challenge',
 E'A curve has a maximum of 0.75, a minimum of -0.75 and a period of 90°,\nand it starts at zero and rises. Which SINE equation fits?',
 '[{"text": "y = 0.75 sin(x/4)", "feedback": "That k stretches the curve to a period of 1440. A period shorter than 360 needs a k bigger than 1."},
   {"text": "y = 0.75 sin(4x)", "feedback": "Correct."},
   {"text": "y = 0.75 sin(90x)", "feedback": "90 is the period. k is 360 divided by the period, not the period itself."},
   {"text": "y = 1.5 sin(4x)", "feedback": "1.5 is the full distance from the minimum to the maximum. The amplitude is half of that."}]'::jsonb,
 1, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 28, 'Challenge',
 E'The same curve — maximum 0.75, minimum -0.75, period 90°, starting at zero\nand rising. Which COSINE equation fits?',
 '[{"text": "y = 0.75 cos(4x)", "feedback": "That curve starts at its maximum, and this one starts at zero. A quarter period of shift is needed."},
   {"text": "y = 0.75 cos[4(x - 22.5°)]", "feedback": "Correct."},
   {"text": "y = 0.75 cos[4(x + 22.5°)]", "feedback": "Cosine peaks at the start of its own cycle, so it has to be pushed RIGHT to line up with a sine curve, not left."},
   {"text": "y = 0.75 cos(4x - 22.5°)", "feedback": "The 22.5 has to sit inside the bracket WITH the k. Written like this the shift is only 22.5 divided by 4."}]'::jsonb,
 1, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 29, 'Challenge',
 E'A windmill tower is 40 m tall and each blade is 10 m long.\nWhat is the greatest height reached by the tip of a blade?',
 '[{"text": "80 m", "feedback": "That doubles the tower. It is the blade that is added on top, and the blade is 10 m."},
   {"text": "50 m", "feedback": "Correct."},
   {"text": "30 m", "feedback": "30 m is the LOWEST the tip gets, when the blade points straight down."},
   {"text": "40 m", "feedback": "40 m is the height of the hub, the level the tip waves about. The blade carries the tip above it."}]'::jsonb,
 1, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 30, 'Challenge',
 E'A lake has its highest tide of 5.2 m at 8:00 am and its lowest of 0.6 m at\n8:00 pm, repeating daily. Which cosine equation gives the height y in terms\nof the hours after midnight, x?',
 '[{"text": "y = 2.3 cos[15(x + 8)] + 2.9", "feedback": "High tide is 8 hours AFTER midnight, so the curve is pushed right, which needs x - 8 inside the bracket."},
   {"text": "y = 2.3 cos[24(x - 8)] + 2.9", "feedback": "24 is the period. k is 360 divided by the period, which is 15."},
   {"text": "y = 2.9 cos[15(x - 8)] + 2.3", "feedback": "The amplitude and the axis have swapped places. The bigger of the two is the level the tide waves about."},
   {"text": "y = 2.3 cos[15(x - 8)] + 2.9", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): comparing curves, counting cycles, full equations.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 31, 'Advanced',
 E'Two sinusoids have the same amplitude, but the second has a k value\ntwice as large. How do their graphs compare?',
 '[{"text": "The second fits twice as many cycles into the same stretch of x", "feedback": "Correct."},
   {"text": "The second is twice as tall", "feedback": "Height comes from a, and the two have the same amplitude. k works along the x-axis."},
   {"text": "The second has twice the period", "feedback": "Period is 360 divided by k, so doubling k HALVES the period."},
   {"text": "They are identical", "feedback": "k genuinely changes the graph. Only a change that cancels itself out would leave the curve alone."}]'::jsonb,
 0, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 32, 'Advanced',
 E'A function has a period of 720°.\nHow many complete cycles does it make between 0° and 2160°?',
 '[{"text": "1.5", "feedback": "That divides 2160 by 1440, which is two periods rather than one."},
   {"text": "8.64", "feedback": "That divides 2160 by 250. The period here is 720."},
   {"text": "3", "feedback": "Correct."},
   {"text": "6", "feedback": "That divides by 360 rather than by the period of this particular curve."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 33, 'Advanced',
 'How many solutions does sin x = 0.5 have between 0° and 720°?',
 '[{"text": "3", "feedback": "The solutions come in pairs, one pair per turn, so the total is even."},
   {"text": "8", "feedback": "That counts four per turn. Sine takes each value between -1 and 1 exactly twice in one turn."},
   {"text": "4", "feedback": "Correct."},
   {"text": "2", "feedback": "Two is right for a single turn. 720 degrees is two full turns, and the pattern repeats."}]'::jsonb,
 2, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 34, 'Advanced',
 E'Three curves: y = sin x, y = sin(x + 60°) + 1, and y = 2 sin[(2/3)(x - 60°)] - 1.\nWhich has the LONGEST period?',
 '[{"text": "The third, at 540°", "feedback": "Correct."},
   {"text": "The first, at 360°", "feedback": "That assumes the plain sine curve is the slowest one on offer. The period comes from k, so the k inside every bracket has to be checked."},
   {"text": "The second, at 360°", "feedback": "The + 60 and the + 1 slide the curve about but leave its period alone. Only k changes the period."},
   {"text": "They all have the same period", "feedback": "That treats every transformation as leaving the period alone. Sliding a curve sideways or up does, but a k in front of x inside the bracket does not."}]'::jsonb,
 0, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 35, 'Advanced',
 'For y = -3 sin[4(x + 30°)] + 1, give the maximum, the minimum and the axis.',
 '[{"text": "Maximum -2, minimum 4, axis y = 1", "feedback": "The reflection was taken to swap which value is the maximum. Turning the curve over changes where the peak happens, not which number is larger."},
   {"text": "Maximum 4, minimum -2, axis y = 1", "feedback": "Correct."},
   {"text": "Maximum 3, minimum -3, axis y = 0", "feedback": "The + 1 was never applied. It lifts the axis and both turning points with it."},
   {"text": "Maximum 4, minimum -2, axis y = -1", "feedback": "The minus in front of the 3 flips the curve over, but it does not move the axis. The axis comes from the constant on the end."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 36, 'Advanced',
 'What is the phase shift of y = 4 cos[3(x - 20°)] + 5?',
 '[{"text": "Right 60°", "feedback": "The 20 was multiplied by k. It is already outside the k, sitting in the (x - d) bracket, so it is the shift as it stands."},
   {"text": "Right 20/3°", "feedback": "The 20 was divided by k. That would be needed if the bracket read 3x - 20, but here the 3 has already been factored out."},
   {"text": "Right 20°", "feedback": "Correct."},
   {"text": "Left 20°", "feedback": "The bracket reads x - 20, and a minus inside moves the curve right."}]'::jsonb,
 2, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 37, 'Advanced',
 E'A sinusoid has a maximum at (0, 2/3), a vertical shift of 1/3 up and a\nperiod of 120°. Which SINE equation fits?',
 '[{"text": "y = (1/3) sin[3(x + 30°)] + 1/3", "feedback": "Correct."},
   {"text": "y = (1/3) sin[3(x - 30°)] + 1/3", "feedback": "The shift has gone the wrong way round: this curve is at its minimum at x = 0 and does not peak until x = 60."},
   {"text": "y = (1/3) sin(3x) + 1/3", "feedback": "That curve is on its axis and rising at x = 0, not at its maximum. A quarter period of shift is needed."},
   {"text": "y = (2/3) sin[3(x + 30°)] + 1/3", "feedback": "2/3 is the height of the maximum above zero. The amplitude is measured from the axis, which is already 1/3 up."}]'::jsonb,
 0, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 38, 'Advanced',
 E'The same sinusoid — maximum at (0, 2/3), vertical shift 1/3 up, period 120°.\nWhich COSINE equation fits?',
 '[{"text": "y = (2/3) cos(3x) + 1/3", "feedback": "2/3 is the height of the maximum above zero. The amplitude is measured from the axis, which is already 1/3 up."},
   {"text": "y = (1/3) cos(3x) + 2/3", "feedback": "2/3 is the maximum, not the axis. The axis is the vertical shift, which is given as 1/3."},
   {"text": "y = (1/3) cos(3x) + 1/3", "feedback": "Correct."},
   {"text": "y = (1/3) cos[3(x - 30°)] + 1/3", "feedback": "Cosine already starts at its maximum, so with the maximum at x = 0 no sideways shift is needed at all."}]'::jsonb,
 2, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 39, 'Advanced',
 E'A ferris wheel has a radius of 9 m and its centre is 11 m above the ground.\nA rider boards at the lowest point. Which equation gives the height y after\nthe wheel has turned x degrees?',
 '[{"text": "y = 9 cos x + 11", "feedback": "That puts the rider at the TOP when x = 0. Boarding at the lowest point needs the cosine turned over."},
   {"text": "y = -9 cos x + 9", "feedback": "The radius was used as the axis as well. The axis is the height of the centre."},
   {"text": "y = -11 cos x + 9", "feedback": "The radius and the centre height have swapped places. The radius is how far the seat swings from the centre."},
   {"text": "y = -9 cos x + 11", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 40, 'Advanced',
 E'A windmill tower is 40 m tall with 10 m blades. A blade tip starts at the\nbottom and one rotation takes 360° of x. Which SINE equation gives its\nheight?',
 '[{"text": "y = 10 sin(x + 90°) + 40", "feedback": "That puts the tip at the TOP when x = 0. Starting at the bottom needs the curve pushed the other way."},
   {"text": "y = 10 sin(x - 90°) + 30", "feedback": "30 m is the lowest point the tip reaches. The axis is the height of the hub, which is the tower."},
   {"text": "y = 40 sin(x - 90°) + 10", "feedback": "The blade length and the tower height have swapped places. The blade is how far the tip swings from the hub."},
   {"text": "y = 10 sin(x - 90°) + 40", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications');

-- --- questions_mcr3u_u7.sql ---

-- ===========================================================================
-- MCR3U — Unit 7: Discrete Functions — 40 questions
-- ===========================================================================
-- Grade 11 Discrete Functions, authored from the Jensen MCR3U lesson
-- material for this unit:
--
--   Lesson 1  Sequences
--   Lesson 2  Series
--   Lesson 3  More sequences
--   Lesson 4  More series
--   Lesson 5  Recursive functions
--   Lesson 6  Pascal triangle and the binomial theorem
--
-- The subtopics split by SHAPE rather than by lesson — arithmetic and
-- geometric, sequence and series — because that is the split a student
-- actually gets wrong. Someone who can do arithmetic series and cannot do
-- geometric ones has a specific gap, and the dashboard should name it.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs. Sums that are not whole
-- numbers are given as exact fractions, and their distractors are too, so
-- the shape of an answer can never single it out.
--
-- Pascal row numbering follows the Jensen material: the single 1 at the top
-- is row 0, so row n has n + 1 entries and supplies the coefficients of a
-- binomial raised to the power n.
--
-- FIGURES. One question carries one: 20, which asks WHICH row of Pascal
-- triangle to use. Its figure shows rows 0 to 3 with their row numbers
-- written beside them, because the numbering convention is the whole
-- question and there is no way to ask it fairly without showing what a row
-- number means. It deliberately stops at row 3, so it states neither the
-- five entries of row 4 that question 10 asks for nor the coefficients
-- 1, 4, 6, 4, 1 that question 40 needs. Nothing else in this unit is a
-- picture at all: sequences and series are lists of numbers, and printing
-- the list further than the question does hands over the answer.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcr3u.sql.
-- The figure file must come second, because the delete below clears the
-- figure column along with the rest of each row.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Discrete Functions';

insert into misconception_labels (tag, label) values
  ('sub-arith-sequences',  'Arithmetic sequences'),
  ('sub-geom-sequences',   'Geometric sequences'),
  ('sub-arith-series',     'Arithmetic series'),
  ('sub-geom-series',      'Geometric series'),
  ('sub-recursion-pascal', 'Recursion and Pascal triangle')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Discrete Functions', 7, 1, 'Easy',
 'What is the common difference of the sequence 9, 15, 21, ...?',
 '[{"text": "6", "feedback": "Correct."},
   {"text": "9", "feedback": "9 is the first term. The common difference is what gets added to move along."},
   {"text": "15", "feedback": "15 is the second term, not the step between terms."},
   {"text": "5/3", "feedback": "That divides 15 by 9, which is what you would do for a ratio. A common difference is found by SUBTRACTING one term from the next."}]'::jsonb,
 0, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 2, 'Easy',
 'For the sequence 1, 4, 7, 10, ..., what is the 10th term?',
 '[{"text": "27", "feedback": "That is 9 times 3, the total added on, without the first term of 1."},
   {"text": "28", "feedback": "Correct."},
   {"text": "31", "feedback": "That adds the common difference ten times. The first term is already there, so it is added only nine times."},
   {"text": "30", "feedback": "That works out 10 times 3. The first term of 1 still has to be counted."}]'::jsonb,
 1, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 3, 'Easy',
 'What is the common ratio of the sequence 2187, 729, 243, 81, ...?',
 '[{"text": "1/3", "feedback": "Correct."},
   {"text": "3", "feedback": "The terms are getting smaller, so the ratio has to be below 1. Divide a term by the one BEFORE it, not the other way round."},
   {"text": "-1458", "feedback": "That subtracts one term from the next. A common ratio comes from dividing."},
   {"text": "1/2187", "feedback": "2187 is the first term, not the ratio. The ratio is what each term is multiplied by to reach the next."}]'::jsonb,
 0, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 4, 'Easy',
 'For the sequence 5, 15, 45, ..., what is the 4th term?',
 '[{"text": "60", "feedback": "That adds 15 to the third term. This sequence multiplies rather than adds."},
   {"text": "90", "feedback": "That doubles the third term. The common ratio here is 3."},
   {"text": "405", "feedback": "That is the FIFTH term. The ratio has been applied one time too many."},
   {"text": "135", "feedback": "Correct."}]'::jsonb,
 3, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 5, 'Easy',
 'What is the sum 1 + 2 + 3 + ... + 10?',
 '[{"text": "50", "feedback": "That works out 10 times 5. The average of the ten terms is 5.5, not 5."},
   {"text": "45", "feedback": "45 is the sum of 1 to 9. The tenth term is still to be added."},
   {"text": "100", "feedback": "That squares the 10. The sum of the first n whole numbers is not n squared."},
   {"text": "55", "feedback": "Correct."}]'::jsonb,
 3, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 6, 'Easy',
 'How many terms are there in the series 21 + 23 + 25 + ... + 43?',
 '[{"text": "22", "feedback": "22 is the total distance from 21 to 43. It still has to be divided by the step size of 2."},
   {"text": "23", "feedback": "23 is the second term of the series, not how many terms it has."},
   {"text": "12", "feedback": "Correct."},
   {"text": "11", "feedback": "That counts the STEPS from 21 to 43. There is always one more term than there are steps between them."}]'::jsonb,
 2, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 7, 'Easy',
 'What is the sum 1 + 2 + 4 + 8?',
 '[{"text": "16", "feedback": "16 is the next term in the pattern, not the total of the four terms listed."},
   {"text": "8", "feedback": "8 is the last term on its own. The other three still have to be added."},
   {"text": "14", "feedback": "That misses the 1 at the start."},
   {"text": "15", "feedback": "Correct."}]'::jsonb,
 3, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 8, 'Easy',
 'A geometric series has a = 5 and r = 3. What is the sum of the first three terms?',
 '[{"text": "20", "feedback": "That adds 5 + 15 and stops. The third term of 45 is still to come."},
   {"text": "195", "feedback": "That starts the sum at the SECOND term instead of the first. The a in the formula is 5."},
   {"text": "65", "feedback": "Correct."},
   {"text": "45", "feedback": "45 is the third TERM on its own. A series adds all the terms up to that point."}]'::jsonb,
 2, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 9, 'Easy',
 'A sequence has t₁ = -6 and tₙ = tₙ₋₁ + 5. What is t₃?',
 '[{"text": "-1", "feedback": "-1 is the SECOND term. The rule has to be applied once more."},
   {"text": "9", "feedback": "9 is the fourth term. The rule has been applied one time too many."},
   {"text": "-16", "feedback": "That subtracts 5 each time. The rule says plus 5."},
   {"text": "4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-recursion-pascal'),

(11, 'MCR3U', 'Discrete Functions', 7, 10, 'Easy',
 E'In Pascal triangle the single 1 at the top is row 0.\nHow many entries are in row 4?',
 '[{"text": "16", "feedback": "16 is the SUM of row 4. The question asks how many numbers are in it."},
   {"text": "5", "feedback": "Correct."},
   {"text": "4", "feedback": "That is the row number itself. Because the counting starts at row 0, every row has one more entry than its number."},
   {"text": "6", "feedback": "6 entries belong to row 5. Row 4 is one shorter."}]'::jsonb,
 1, 'sub-recursion-pascal'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Discrete Functions', 7, 11, 'Medium',
 'For the sequence 9, 15, 21, ..., what is the 12th term?',
 '[{"text": "69", "feedback": "That adds it ten times. Reaching the 12th term takes eleven steps from the first."},
   {"text": "72", "feedback": "That works out 12 times 6. The first term of 9 has been lost and an extra step added."},
   {"text": "75", "feedback": "Correct."},
   {"text": "81", "feedback": "That adds the common difference twelve times. The first term is already there, so it is added only eleven times."}]'::jsonb,
 2, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 12, 'Medium',
 'In an arithmetic sequence the 3rd term is 25 and the 9th term is 43. What is d?',
 '[{"text": "18", "feedback": "18 is the total change from the 3rd term to the 9th. It still has to be shared out over the steps between them."},
   {"text": "6", "feedback": "6 is the number of STEPS from the 3rd term to the 9th, not the size of each one."},
   {"text": "2", "feedback": "That divides 18 by 9. The steps run from term 3 to term 9, which is 6 steps, not 9."},
   {"text": "3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 13, 'Medium',
 'For the sequence -1, 2, -4, 8, ..., what is the 12th term?',
 '[{"text": "2048", "feedback": "Correct."},
   {"text": "-2048", "feedback": "The ratio -2 is raised to an ODD power here, and a negative first term turns that back to positive. Check the sign pattern: even-numbered terms are positive."},
   {"text": "-4096", "feedback": "The ratio has been applied twelve times. Reaching the 12th term takes only eleven multiplications."},
   {"text": "4096", "feedback": "The size is one doubling too large as well as being the wrong sign trail. The exponent on the ratio is n - 1."}]'::jsonb,
 0, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 14, 'Medium',
 'For the sequence 2187, 729, 243, ..., what is the 10th term?',
 '[{"text": "1/27", "feedback": "The ratio has been applied one time too many. The exponent on the ratio is n - 1, not n."},
   {"text": "9", "feedback": "The ratio was used the right way up but the count is four short. Nine steps from 2187 lands below 1."},
   {"text": "1/9", "feedback": "Correct."},
   {"text": "1/3", "feedback": "The ratio has been applied one time too few. Reaching the 10th term takes nine divisions by 3."}]'::jsonb,
 2, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 15, 'Medium',
 'For the sequence 1, 4, 7, 10, ..., what is the sum of the first 12 terms?',
 '[{"text": "228", "feedback": "That uses 12 steps of the common difference. The bracket in the formula holds (n - 1)d, which is eleven steps."},
   {"text": "192", "feedback": "That uses ten steps. Twelve terms means eleven gaps between them."},
   {"text": "176", "feedback": "That stops at the 11th term. Twelve terms were asked for."},
   {"text": "210", "feedback": "Correct."}]'::jsonb,
 3, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 16, 'Medium',
 'What is the sum of the series 21 + 23 + 25 + ... + 43?',
 '[{"text": "768", "feedback": "The halving was left out. The formula is n over 2 times the first plus the last."},
   {"text": "320", "feedback": "That counts 10 terms, taking one off the number of steps from 21 to 43 instead of adding one."},
   {"text": "384", "feedback": "Correct."},
   {"text": "352", "feedback": "That uses 11 terms. There are 12, because there is always one more term than there are steps."}]'::jsonb,
 2, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 17, 'Medium',
 'How many terms are there in the series -4 - 12 - 36 - ... - 8748?',
 '[{"text": "9", "feedback": "One multiplication too many. Applying the ratio eight times overshoots to -26244."},
   {"text": "2187", "feedback": "2187 is 8748 divided by 4, which is the power of 3 involved. It is not a count of terms."},
   {"text": "8", "feedback": "Correct."},
   {"text": "7", "feedback": "7 is the number of times the ratio is applied. There is always one more term than there are multiplications."}]'::jsonb,
 2, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 18, 'Medium',
 'What is the sum of the series -4 - 12 - 36 - ... - 8748?',
 '[{"text": "-13 120", "feedback": "Correct."},
   {"text": "-13 116", "feedback": "That misses the first term of -4. The formula already includes it."},
   {"text": "13 120", "feedback": "Every term is negative, so the sum has to be negative too. The a in the formula is -4."},
   {"text": "-4372", "feedback": "That stops one term short of the end. Count the terms in the series before summing."}]'::jsonb,
 0, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 19, 'Medium',
 E'A sequence has t₁ = -2, t₂ = -1 and tₙ = tₙ₋₁ × tₙ₋₂.\nWhat are the first four terms?',
 '[{"text": "-2, -1, -2, 2", "feedback": "The third term multiplies two negatives together, and that gives a positive."},
   {"text": "-2, -1, -3, -4", "feedback": "The rule multiplies the two previous terms. This one adds them."},
   {"text": "-2, -1, 2, -2", "feedback": "Correct."},
   {"text": "-2, -1, 2, 2", "feedback": "The fourth term multiplies the third by the SECOND, and the second is -1, so the sign flips."}]'::jsonb,
 2, 'sub-recursion-pascal'),

(11, 'MCR3U', 'Discrete Functions', 7, 20, 'Medium',
 E'Which row of Pascal triangle gives the coefficients of the expansion\nof (1 - x)¹¹?',
 '[{"text": "Row 10", "feedback": "Row 10 supplies the coefficients for a power of 10. The row number and the power are the same."},
   {"text": "Row 1", "feedback": "Row 1 is just 1 and 1, which handles a bracket raised to the power 1."},
   {"text": "Row 11", "feedback": "Correct."},
   {"text": "Row 12", "feedback": "12 is how many TERMS the expansion has. The row number matches the power itself."}]'::jsonb,
 2, 'sub-recursion-pascal'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): working backwards from terms and sums.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Discrete Functions', 7, 21, 'Challenge',
 E'In an arithmetic sequence the 3rd term is 25 and the 9th term is 43.\nHow many terms are less than 100?',
 '[{"text": "34", "feedback": "That divides 100 by 3 and treats every term as a multiple of the common difference. The sequence starts at 19, not at 0."},
   {"text": "27", "feedback": "Correct."},
   {"text": "28", "feedback": "The 28th term is exactly 100, and 100 is not less than 100."},
   {"text": "26", "feedback": "One term short. The very next term is 97, which is still below 100 and so counts."}]'::jsonb,
 1, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 22, 'Challenge',
 E'In an arithmetic sequence the 17th term is 53 and the 28th term is 86.\nFind a and d.',
 '[{"text": "a = 2, d = 3", "feedback": "The common difference is right, but one step too many was taken back. Getting from the 17th term to the first takes 16 steps."},
   {"text": "a = 5, d = 3", "feedback": "Correct."},
   {"text": "a = 5, d = 11", "feedback": "11 is the number of STEPS between the two given terms, not the size of each step."},
   {"text": "a = 53, d = 3", "feedback": "53 is the 17th term, not the first. Sixteen steps still have to be taken back off it."}]'::jsonb,
 1, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 23, 'Challenge',
 E'The 5th term of a geometric sequence is 405 and the 6th term is 1215.\nWhat is the first term?',
 '[{"text": "15", "feedback": "That divides by the ratio three times. Getting from the 5th term back to the 1st takes four divisions."},
   {"text": "135", "feedback": "That divides by the ratio only once, which lands on the 4th term."},
   {"text": "45", "feedback": "That divides by the ratio twice, which lands on the 3rd term."},
   {"text": "5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 24, 'Challenge',
 'What is the general term of the sequence 2187, 729, 243, 81, 27?',
 '[{"text": "tₙ = 2187(1/3)ⁿ⁻¹", "feedback": "Correct."},
   {"text": "tₙ = 2187(3)ⁿ⁻¹", "feedback": "The terms are shrinking, so the ratio has to be below 1. This one grows."},
   {"text": "tₙ = 2187(1/3)ⁿ", "feedback": "The exponent is one too big. At n = 1 this gives 729, and the first term is 2187."},
   {"text": "tₙ = 27(1/3)ⁿ⁻¹", "feedback": "27 is the LAST term listed. The a in the formula is the first term."}]'::jsonb,
 0, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 25, 'Challenge',
 E'In an arithmetic series the 12th term is 15 and the sum of the first 15\nterms is 105. What is the sum of the first three terms?',
 '[{"text": "15", "feedback": "15 is the 12th term, which the question already gives."},
   {"text": "-21", "feedback": "That is three times the first term, which would only be right if the common difference were zero."},
   {"text": "-9", "feedback": "That adds the second, third and fourth terms instead of the first three."},
   {"text": "-15", "feedback": "Correct."}]'::jsonb,
 3, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 26, 'Challenge',
 'What is the sum of the series 251 + 243 + 235 + ... + (-205)?',
 '[{"text": "2668", "feedback": "The halving was left out. The formula is n over 2 times the first plus the last."},
   {"text": "667", "feedback": "That halves twice. The n over 2 has already done the halving once."},
   {"text": "1334", "feedback": "Correct."},
   {"text": "1288", "feedback": "That uses 56 terms. The count is (251 + 205) divided by 8, plus one for the first term."}]'::jsonb,
 2, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 27, 'Challenge',
 E'The 5th term of a geometric series is 405 and the 6th is 1215.\nWhat is the sum of the first nine terms?',
 '[{"text": "9841", "feedback": "That is the sum with a = 1 rather than a = 5. The first term still has to be worked back from the 5th."},
   {"text": "49 205", "feedback": "Correct."},
   {"text": "49 210", "feedback": "That adds the first term on separately. The formula already includes it."},
   {"text": "98 410", "feedback": "The denominator r - 1 was taken as 1 rather than 2. With r = 3 it is 2."}]'::jsonb,
 1, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 28, 'Challenge',
 'What is the sum of the series 1280 - 640 + 320 - ... + 5?',
 '[{"text": "2555", "feedback": "The alternating minus signs were ignored. The ratio here is negative one half, not positive."},
   {"text": "855", "feedback": "Correct."},
   {"text": "850", "feedback": "That stops one term early, at the eighth. The series ends on +5, which is the ninth term."},
   {"text": "852.5", "feedback": "That runs one term too far. The ninth term is +5, and the series stops there."}]'::jsonb,
 1, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 29, 'Challenge',
 'Which recursive formula generates the sequence 1, 1, 2, 3, 5, 8, ...?',
 '[{"text": "tₙ = tₙ₋₁ × tₙ₋₂", "feedback": "Multiplying the first two 1s gives 1, not 2. The rule adds them."},
   {"text": "tₙ = tₙ₋₁ + tₙ₋₂", "feedback": "Correct."},
   {"text": "tₙ = tₙ₋₁ + 1", "feedback": "That gives 1, 2, 3, 4, 5. The steps here are not all the same size."},
   {"text": "tₙ = 2tₙ₋₁", "feedback": "That gives 1, 2, 4, 8. This sequence grows more slowly than doubling."}]'::jsonb,
 1, 'sub-recursion-pascal'),

(11, 'MCR3U', 'Discrete Functions', 7, 30, 'Challenge',
 'How many terms are there in the expansion of (1 - x)¹¹?',
 '[{"text": "12", "feedback": "Correct."},
   {"text": "11", "feedback": "11 is the power. The exponent on the first part of the bracket runs from 11 all the way down to 0, which is one more value than 11."},
   {"text": "13", "feedback": "One too many. The exponents run 11, 10, and so on down to 0."},
   {"text": "22", "feedback": "That doubles the power. Each term comes from one exponent, not two."}]'::jsonb,
 0, 'sub-recursion-pascal'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): solving for n, comparing series, the binomial theorem.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Discrete Functions', 7, 31, 'Advanced',
 'An arithmetic sequence has tₙ = 19 + 3(n - 1). Which term is equal to 100?',
 '[{"text": "The 28th", "feedback": "Correct."},
   {"text": "The 27th", "feedback": "The 27th term is 97. One more step of 3 is needed."},
   {"text": "The 34th", "feedback": "That divides 100 by 3 and ignores the starting value of 19."},
   {"text": "No term equals 100", "feedback": "81 divides by 3 exactly, so the sequence does land on 100 rather than stepping over it."}]'::jsonb,
 0, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 32, 'Advanced',
 E'The sum of the first 6 terms of an arithmetic series is 297 and the sum of\nthe first 8 terms is 500. What is the 5th term?',
 '[{"text": "69", "feedback": "Correct."},
   {"text": "56", "feedback": "That uses three steps of the common difference. Reaching the 5th term from the first takes four."},
   {"text": "82", "feedback": "That uses five steps. The exponent-style count is n - 1, so the 5th term is four steps along."},
   {"text": "30", "feedback": "30 is the SECOND term. The 5th is three more steps along."}]'::jsonb,
 0, 'sub-arith-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 33, 'Advanced',
 'Which is the first term of the sequence 5, 15, 45, ... to exceed 100 000?',
 '[{"text": "The 9th", "feedback": "The 9th term is 32 805, well under the target."},
   {"text": "The 11th", "feedback": "Correct."},
   {"text": "The 10th", "feedback": "The 10th term is 98 415, which is still under 100 000."},
   {"text": "The 12th", "feedback": "The 12th does exceed it, but it is not the first to do so. Check the term just before it."}]'::jsonb,
 1, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 34, 'Advanced',
 'In a geometric sequence the 2nd term is 6 and the 5th term is 48. Find a and r.',
 '[{"text": "a = 2, r = 3", "feedback": "The two values have swapped places. Check by building the sequence: this one gives 2, 6, 18, 54, 162."},
   {"text": "a = 3, r = 2", "feedback": "Correct."},
   {"text": "a = 6, r = 2", "feedback": "The ratio is right, but 6 is the SECOND term. One division still has to take it back to the first."},
   {"text": "a = 3, r = 8", "feedback": "8 is what the terms are multiplied by across THREE steps. The ratio is the cube root of that."}]'::jsonb,
 1, 'sub-geom-sequences'),

(11, 'MCR3U', 'Discrete Functions', 7, 35, 'Advanced',
 'For the series 5 + 8 + 11 + ..., how many terms are needed to reach a sum of 440?',
 '[{"text": "15", "feedback": "15 terms give 390, which is 50 short."},
   {"text": "17", "feedback": "17 terms give 493, which overshoots by 53."},
   {"text": "20", "feedback": "That divides 440 by an average term of 22, which is nowhere near the true average of 27.5."},
   {"text": "16", "feedback": "Correct."}]'::jsonb,
 3, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 36, 'Advanced',
 E'Which is larger: the sum of the first 20 terms of 3, 7, 11, ...,\nor the sum of the first 30 terms of 2, 4, 6, ...?',
 '[{"text": "The second, by 110", "feedback": "Correct."},
   {"text": "The first, by 110", "feedback": "The gap is the right size but it falls the other way. The second series has ten more terms, and that outweighs its smaller steps."},
   {"text": "They are equal", "feedback": "Ten extra terms and a smaller common difference do not have to cancel out. Work each sum out and compare them."},
   {"text": "The second, by 1750", "feedback": "1750 is the two sums ADDED together. The question asks by how much one beats the other."}]'::jsonb,
 0, 'sub-arith-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 37, 'Advanced',
 E'What is the exact sum of the first 12 terms of the series\n2187 + 729 + 243 + ...?',
 '[{"text": "265 720/81", "feedback": "Correct."},
   {"text": "265 720/243", "feedback": "The denominator carries one power of 3 too many. Check the r - 1 in the formula, which is -2/3."},
   {"text": "3280", "feedback": "That stops at the last whole-number term, which is the eighth. Twelve terms were asked for."},
   {"text": "2187/81", "feedback": "That is the first term divided by 81, which is one of the later terms rather than the sum."}]'::jsonb,
 0, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 38, 'Advanced',
 'What is the sum of the first 6 terms of the series 3 - 6 + 12 - 24 + ...?',
 '[{"text": "21", "feedback": "That adds 3 + 6 + 12 with the minus signs dropped. Six terms were asked for, and they alternate in sign."},
   {"text": "-63", "feedback": "Correct."},
   {"text": "63", "feedback": "With r = -2 the denominator r - 1 is -3, and a negative denominator flips the sign of the whole thing."},
   {"text": "-189", "feedback": "The denominator was taken as -1 rather than -3."}]'::jsonb,
 1, 'sub-geom-series'),

(11, 'MCR3U', 'Discrete Functions', 7, 39, 'Advanced',
 'A sequence has t₁ = 3 and tₙ = 2tₙ₋₁ - 1. What is t₄?',
 '[{"text": "33", "feedback": "That is the fifth term. The rule has been applied one time too many."},
   {"text": "23", "feedback": "That doubles three times over and takes the 1 off only at the end. The minus 1 comes off at every step."},
   {"text": "17", "feedback": "Correct."},
   {"text": "9", "feedback": "9 is the THIRD term. The rule has to be applied once more."}]'::jsonb,
 2, 'sub-recursion-pascal'),

(11, 'MCR3U', 'Discrete Functions', 7, 40, 'Advanced',
 'Using the binomial theorem, what is the THIRD term of the expansion of (x² - 2y)⁴?',
 '[{"text": "-24x⁴y²", "feedback": "The -2y is squared in this term, and squaring a negative gives a positive."},
   {"text": "6x⁴y²", "feedback": "The Pascal coefficient of 6 is right, but the -2 inside the bracket also gets squared and contributes a factor of 4."},
   {"text": "24x²y²", "feedback": "The x² is squared as well, so its exponent doubles rather than staying at 2."},
   {"text": "24x⁴y²", "feedback": "Correct."}]'::jsonb,
 3, 'sub-recursion-pascal');

-- --- figures_mcr3u.sql  (must be last) ---

-- ======================================================================
-- figures_mcr3u.sql — attaches figures to questions
-- ======================================================================
-- GENERATED by tools/make_figures.py — edit that script, not this file.
--
-- Run AFTER the question files for this course, and after any re-run of
-- one: the per-unit delete wipes the figure column with the rest of the
-- row. Safe to re-run on its own at any time.
--
-- The PNGs live in web/figures/ and ship inside every deploy. A null
-- figure renders no image, and a missing file shows a short "could not
-- load" line in the app rather than a broken icon.

update questions set figure = null where course_code = 'MCR3U';

update questions set figure = 'figures/mcr3u_trig_9.png'
 where course_code = 'MCR3U' and unit = 'Trig Geometry' and sort_order = 9;
update questions set figure = 'figures/mcr3u_trig_19.png'
 where course_code = 'MCR3U' and unit = 'Trig Geometry' and sort_order = 19;
update questions set figure = 'figures/mcr3u_trig_26.png'
 where course_code = 'MCR3U' and unit = 'Trig Geometry' and sort_order = 26;
update questions set figure = 'figures/mcr3u_trig_27.png'
 where course_code = 'MCR3U' and unit = 'Trig Geometry' and sort_order = 27;
update questions set figure = 'figures/mcr3u_trig_38.png'
 where course_code = 'MCR3U' and unit = 'Trig Geometry' and sort_order = 38;
update questions set figure = 'figures/mcr3u_trig_29.png'
 where course_code = 'MCR3U' and unit = 'Trig Functions' and sort_order = 29;
update questions set figure = 'figures/mcr3u_trig_39.png'
 where course_code = 'MCR3U' and unit = 'Trig Functions' and sort_order = 39;
update questions set figure = 'figures/mcr3u_disc_20.png'
 where course_code = 'MCR3U' and unit = 'Discrete Functions' and sort_order = 20;

-- Check: every figure attached, and none orphaned.
select unit, sort_order, figure from questions
 where course_code = 'MCR3U' and figure is not null
 order by unit, sort_order;
