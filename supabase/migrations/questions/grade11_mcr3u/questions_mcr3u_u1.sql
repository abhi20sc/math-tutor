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
