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
-- RUN ORDER: astro_math_assist_setup.sql -> this file. Safe to re-run on its own
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
