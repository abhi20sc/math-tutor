-- ===========================================================================
-- MTH1W — Unit 6: Linear Relations Part 2 — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Solving linear systems by graphing
--   Lesson 2  Transformations of linear functions
--   Lesson 3  Graphing inequalities in two variables
--   Lesson 4  Reciprocal relationships (xy = k)
--
-- Lesson 1 carries two separate skills - finding the point of intersection,
-- and reading off how MANY solutions a system has from the slopes and
-- intercepts - so it splits into two subtopics. Five in total, two per
-- difficulty band each.
--
-- The distractors are the slips the worked solutions keep correcting: the
-- coordinates of the intersection written in the wrong order, a horizontal
-- shift applied to y instead of to x, a solid boundary line drawn for a
-- strict inequality, and shading the side the test point is on when the test
-- came out false.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Linear relations part 2';

insert into misconception_labels (tag, label) values
  ('sub-linear-systems',    'Solving linear systems'),
  ('sub-solution-count',    'How many solutions a system has'),
  ('sub-transformations',   'Transformations of linear functions'),
  ('sub-graph-inequality',  'Graphing inequalities in two variables'),
  ('sub-reciprocal',        'Reciprocal relationships')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 2', 6, 1, 'Easy',
 'What does it mean to solve a linear system?',
 '[{"text": "Find the y-intercept of each line", "feedback": "The intercepts help you draw the lines, but they are not the solution to the system."},
   {"text": "Find the ordered pair where each line in the system crosses the x-axis", "feedback": "Those are the x-intercepts. The solution is where the lines meet each other, not the axis."},
   {"text": "Add the two equations together", "feedback": "Adding equations is a step in one method, not the answer the method produces."},
   {"text": "Find the ordered pair that satisfies every equation in the system", "feedback": "Correct."}]'::jsonb,
 3, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 2, 'Easy',
 'Where do the lines y = x + 4 and y = -x + 2 intersect?',
 '[{"text": "(-1, -3)", "feedback": "The x-value is right. Substitute it back into either equation to get the matching y."},
   {"text": "(3, -1)", "feedback": "The two coordinates have been written in the wrong order. The x comes first."},
   {"text": "(1, 3)", "feedback": "The y-value is right, but check the sign of x. Setting x + 4 equal to -x + 2 gives a negative x."},
   {"text": "(-1, 3)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 3, 'Easy',
 'Two lines in a system have different slopes. How many solutions does the system have?',
 '[{"text": "None", "feedback": "Lines that lean differently must cross somewhere. They cannot stay apart forever."},
   {"text": "Exactly one", "feedback": "Correct."},
   {"text": "Infinitely many", "feedback": "That happens only when the two equations describe the same line, which needs matching slopes."},
   {"text": "It depends on the intercepts", "feedback": "Once the slopes differ, the intercepts cannot change the answer."}]'::jsonb,
 1, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 4, 'Easy',
 'Two lines in a system have the same slope AND the same y-intercept. How many solutions does the system have?',
 '[{"text": "Infinitely many", "feedback": "Correct."},
   {"text": "Two", "feedback": "Two straight lines can never cross at exactly two places."},
   {"text": "Exactly one", "feedback": "That needs the lines to cross at a single place. These two lie exactly on top of each other."},
   {"text": "None", "feedback": "That happens when the slopes match but the intercepts differ. Here both match."}]'::jsonb,
 0, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 5, 'Easy',
 'How does the graph of y = 2x + 3 compare with the graph of y = 2x?',
 '[{"text": "Translated up 3 units", "feedback": "Correct."},
   {"text": "Translated right 3 units", "feedback": "A horizontal shift changes what is subtracted from x inside a bracket, not what is added at the end."},
   {"text": "Translated down 3 units", "feedback": "The constant is being added, which lifts the line rather than lowering it."},
   {"text": "Reflected in the x-axis", "feedback": "A reflection changes the sign of the slope. Here the slope is unchanged."}]'::jsonb,
 0, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 6, 'Easy',
 'How does the graph of y = 2(x - 3) compare with the graph of y = 2x?',
 '[{"text": "Translated 3 units left", "feedback": "A subtraction inside the bracket moves the graph the opposite way to what it looks like."},
   {"text": "Translated 3 units down", "feedback": "A vertical shift changes what is added at the end, outside the bracket."},
   {"text": "Translated 3 units right", "feedback": "Correct."},
   {"text": "Translated 6 units right", "feedback": "The 3 was multiplied by the slope. The shift is read straight off the bracket."}]'::jsonb,
 2, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 7, 'Easy',
 'When graphing y < 2x + 3, should the boundary line be solid or dashed?',
 '[{"text": "Dashed, because the slope is positive", "feedback": "The slope has nothing to do with it. Look at the inequality symbol."},
   {"text": "Solid, because the inequality has two variables", "feedback": "Every inequality of this kind has two variables. Look at the symbol instead."},
   {"text": "Solid, because the line is the boundary", "feedback": "Being the boundary is not enough. What matters is whether points ON the line count as solutions."},
   {"text": "Dashed, because points on the line are not solutions", "feedback": "Correct."}]'::jsonb,
 3, 'sub-graph-inequality'),

(9, 'MTH1W', 'Linear relations part 2', 6, 8, 'Easy',
 'How do you decide which side of the boundary line to shade?',
 '[{"text": "Shade whichever side of the boundary line contains the y-intercept", "feedback": "The y-intercept sits on the boundary line itself, so it cannot separate the two sides."},
   {"text": "Substitute a test point that is off the line and see if it makes the inequality true", "feedback": "Correct."},
   {"text": "Shade whichever side of the boundary line holds all the points with positive x-values", "feedback": "The axes play no part in this. The boundary line decides the two regions."},
   {"text": "Always shade the region above the boundary line", "feedback": "That is right only some of the time. It depends on the inequality."}]'::jsonb,
 1, 'sub-graph-inequality'),

(9, 'MTH1W', 'Linear relations part 2', 6, 9, 'Easy',
 'Which of these points lies on the graph of xy = 6?',
 '[{"text": "(2, 3)", "feedback": "Correct."},
   {"text": "(2, 4)", "feedback": "Those coordinates add to 6 rather than multiplying to 6."},
   {"text": "(3, 3)", "feedback": "Those coordinates add to 6. On this curve they have to multiply to 6."},
   {"text": "(1, 5)", "feedback": "Those coordinates add to 6. On this curve they have to multiply to 6."}]'::jsonb,
 0, 'sub-reciprocal'),

(9, 'MTH1W', 'Linear relations part 2', 6, 10, 'Easy',
 'In which quadrants does the graph of xy = 6 lie?',
 '[{"text": "All four quadrants", "feedback": "Two of the quadrants always produce a negative product, so the curve cannot reach them."},
   {"text": "Quadrant 1 only", "feedback": "Two negatives also multiply to a positive, so there is a second branch."},
   {"text": "Quadrants 1 and 3", "feedback": "Correct."},
   {"text": "Quadrants 2 and 4", "feedback": "In those quadrants one coordinate is positive and the other negative, so the product would be negative."}]'::jsonb,
 2, 'sub-reciprocal'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 2', 6, 11, 'Medium',
 'Solve the system 2x + y = 5 and x - 2y = 10.',
 '[{"text": "(-3, 4)", "feedback": "The two coordinates have been written in the wrong order. The x comes first."},
   {"text": "(4, 3)", "feedback": "The x-value is right, but check the sign of y. Substitute x back into 2x + y = 5."},
   {"text": "(4, -3)", "feedback": "Correct."},
   {"text": "(2, 1)", "feedback": "Those values fit 2x + y = 5 but not x - 2y = 10. Only one equation was checked."}]'::jsonb,
 2, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 12, 'Medium',
 'Solve the system y = 3x - 1 and y = x + 5.',
 '[{"text": "(-3, 2)", "feedback": "The sign was lost when the x terms were collected. 3x - x is positive."},
   {"text": "(3, 8)", "feedback": "Correct."},
   {"text": "(3, 4)", "feedback": "The x-value is right. Substitute it into either equation to get the matching y."},
   {"text": "(8, 3)", "feedback": "The two coordinates have been written in the wrong order. The x comes first."}]'::jsonb,
 1, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 13, 'Medium',
 'How many solutions does the system y = 2x + 3 and y = 2x - 4 have?',
 '[{"text": "None, because both slopes are positive", "feedback": "Two lines can both slope upward and still cross. It is the equal slopes that matter."},
   {"text": "Exactly one, because the intercepts differ", "feedback": "Different intercepts alone do not force a crossing. Check the slopes first."},
   {"text": "None, because the lines are parallel and distinct", "feedback": "Correct."},
   {"text": "Infinitely many, because the slopes match", "feedback": "Matching slopes are only half of it. The intercepts have to match too."}]'::jsonb,
 2, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 14, 'Medium',
 'How many solutions does the system 2x + 4y = 8 and y = -(1/2)x + 2 have?',
 '[{"text": "Infinitely many", "feedback": "Correct."},
   {"text": "Two", "feedback": "Two straight lines can never cross at exactly two places."},
   {"text": "Exactly one", "feedback": "Rearrange the first equation into slope-intercept form and compare it with the second."},
   {"text": "None", "feedback": "That would need the intercepts to differ. Rearrange the first equation and check."}]'::jsonb,
 0, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 15, 'Medium',
 'The graph of y = -(1/2)x is translated 3 units down. What is the equation of the new line?',
 '[{"text": "y = -(1/2)x + 3", "feedback": "Adding lifts the line. Moving down needs a subtraction."},
   {"text": "y = -(1/2)x - 3", "feedback": "Correct."},
   {"text": "y = -(1/2)(x - 3)", "feedback": "Putting the 3 inside the bracket shifts the line sideways, not up or down."},
   {"text": "y = -(1/2)(x + 3)", "feedback": "Putting the 3 inside the bracket shifts the line sideways, not up or down."}]'::jsonb,
 1, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 16, 'Medium',
 'The graph of y = -(1/2)x is shifted 2 units left. What is the equation of the new line?',
 '[{"text": "y = -(1/2)(x - 2)", "feedback": "A subtraction inside the bracket shifts the graph to the right, not the left."},
   {"text": "y = -(1/2)x + 2", "feedback": "A constant added at the end shifts the line up, not sideways."},
   {"text": "y = -(1/2)(x + 2)", "feedback": "Correct."},
   {"text": "y = -(1/2)x - 2", "feedback": "A constant added at the end shifts the line down, not sideways."}]'::jsonb,
 2, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 17, 'Medium',
 'You are graphing y <= -(1/2)x + 2 and you test the point (0, 0). What happens next?',
 '[{"text": "The statement is true, so shade the region away from the origin", "feedback": "When the test point works, it is inside the solution, so its own side gets shaded."},
   {"text": "The origin is on the line, so choose another test point", "feedback": "Setting x to zero on this line gives y equal to 2, so the origin is not on it."},
   {"text": "The statement is true, so shade the region containing the origin", "feedback": "Correct."},
   {"text": "The statement is false, so shade the region away from the origin", "feedback": "Substituting zero for x and zero for y gives 0 on the left and 2 on the right, and 0 is less than 2."}]'::jsonb,
 2, 'sub-graph-inequality'),

(9, 'MTH1W', 'Linear relations part 2', 6, 18, 'Medium',
 'You are graphing 2x + 3y < 6 and you test the point (5, 0). What happens next?',
 '[{"text": "It is false, so shade the region that does not contain (5, 0)", "feedback": "Correct."},
   {"text": "It is false, so shade the region containing (5, 0)", "feedback": "A failed test point is outside the solution, so the OTHER side gets shaded."},
   {"text": "It is true, so shade the region that does not contain (5, 0)", "feedback": "A test point that works is inside the solution, so its own side would be shaded."},
   {"text": "It is true, so shade the region containing (5, 0)", "feedback": "Substituting gives 10 on the left, and 10 is not less than 6."}]'::jsonb,
 0, 'sub-graph-inequality'),

(9, 'MTH1W', 'Linear relations part 2', 6, 19, 'Medium',
 'Where are the asymptotes of the graph of xy = 6?',
 '[{"text": "There are none", "feedback": "Neither coordinate can ever be zero, because the product would then be zero rather than 6."},
   {"text": "x = 6 and y = 6", "feedback": "The curve crosses those values freely. The asymptotes are the lines it can never reach."},
   {"text": "y = x and y = -x", "feedback": "Those are diagonals. The two branches flatten against the axes instead."},
   {"text": "x = 0 and y = 0", "feedback": "Correct."}]'::jsonb,
 3, 'sub-reciprocal'),

(9, 'MTH1W', 'Linear relations part 2', 6, 20, 'Medium',
 'Rewrite xy = 4 in the form y equals an expression in x.',
 '[{"text": "y = x + 4", "feedback": "The x and y are multiplied together, not added."},
   {"text": "y = 4x", "feedback": "That multiplies where it should divide. The x is on the left multiplying y."},
   {"text": "y = 4/x", "feedback": "Correct."},
   {"text": "y = x/4", "feedback": "The fraction is upside down. Divide both sides by x, not by 4."}]'::jsonb,
 2, 'sub-reciprocal'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 2', 6, 21, 'Challenge',
 'Solve the system y = x + 4 and 2x + y = 10.',
 '[{"text": "(2, 6)", "feedback": "Correct."},
   {"text": "(-2, 2)", "feedback": "The sign was lost when the x terms were collected. 2x + x is positive."},
   {"text": "(6, 2)", "feedback": "The two coordinates have been written in the wrong order. The x comes first."},
   {"text": "(2, 4)", "feedback": "The x-value is right, but the 4 was used directly as y. Substitute x back into y = x + 4."}]'::jsonb,
 0, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 22, 'Challenge',
 'Solve the system 2x - 3y = 12 and x + y = 1.',
 '[{"text": "(-2, 3)", "feedback": "The two coordinates have been written in the wrong order. The x comes first."},
   {"text": "(3, 2)", "feedback": "The x-value is right, but check the sign of y. Substitute x back into x + y = 1."},
   {"text": "(-3, 4)", "feedback": "Those values fit x + y = 1 but not 2x - 3y = 12. Only one equation was checked."},
   {"text": "(3, -2)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 23, 'Challenge',
 'A system of two lines has no solution. What must be true of the lines?',
 '[{"text": "One line is horizontal and the other is vertical", "feedback": "Those two always cross at right angles, giving exactly one solution."},
   {"text": "The slopes are equal and the y-intercepts are different", "feedback": "Correct."},
   {"text": "The slopes are equal and the y-intercepts are equal", "feedback": "That makes the two equations describe the same line, which gives infinitely many solutions."},
   {"text": "The slopes are different", "feedback": "Lines that lean differently always cross somewhere, giving exactly one solution."}]'::jsonb,
 1, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 24, 'Challenge',
 'For what value of k does the system 2x + 3y = 6 and 6x + ky = 18 have infinitely many solutions?',
 '[{"text": "k = 6", "feedback": "That matched k to the x-coefficient rather than scaling the y-coefficient by the same factor."},
   {"text": "k = 9", "feedback": "Correct."},
   {"text": "k = 1", "feedback": "Substituting that value gives two lines with different slopes, so they would cross exactly once."},
   {"text": "k = 3", "feedback": "That copies the coefficient straight across. The whole second equation is a multiple of the first, so every coefficient scales."}]'::jsonb,
 1, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 25, 'Challenge',
 'The graph of y = -(1/2)x is reflected in the x-axis. What is the equation of the new line?',
 '[{"text": "y = -2x", "feedback": "The fraction was flipped and the sign was kept. A reflection does not turn the slope upside down."},
   {"text": "y = -(1/2)x + 1", "feedback": "That is a translation upward. A reflection changes the slope, not the intercept."},
   {"text": "y = 2x", "feedback": "Both the sign and the fraction were changed. A reflection only changes the sign of the slope."},
   {"text": "y = (1/2)x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 26, 'Challenge',
 'The graph of y = -(1/2)x is rotated 90 degrees about the origin. What is the equation of the new line?',
 '[{"text": "y = 2x", "feedback": "Correct."},
   {"text": "y = -2x", "feedback": "The fraction was flipped but the sign was kept. A rotation uses the negative reciprocal."},
   {"text": "y = (1/2)x", "feedback": "That is a reflection in the x-axis, which changes only the sign."},
   {"text": "y = -(1/2)x", "feedback": "That is the line you started with. Something has to change."}]'::jsonb,
 0, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 27, 'Challenge',
 'Which description matches the graph of y > 3x - 1?',
 '[{"text": "A dashed line with the region not containing (0, 0) shaded", "feedback": "The line style is right. Test the origin: 0 is greater than -1, so it is a solution."},
   {"text": "A solid line with the region not containing (0, 0) shaded", "feedback": "Neither part holds. The symbol is strict, and the origin does satisfy the inequality."},
   {"text": "A solid line with the region containing (0, 0) shaded", "feedback": "The shading is right, but a strict inequality excludes the line itself."},
   {"text": "A dashed line with the region containing (0, 0) shaded", "feedback": "Correct."}]'::jsonb,
 3, 'sub-graph-inequality'),

(9, 'MTH1W', 'Linear relations part 2', 6, 28, 'Challenge',
 'Is the point (4, 2) a solution of 2x + 3y < 6?',
 '[{"text": "No, because 14 is not less than 6", "feedback": "Correct."},
   {"text": "Yes, because both coordinates are positive", "feedback": "The signs of the coordinates do not decide it. Substitute them in and compare."},
   {"text": "Yes, because 14 is greater than 6", "feedback": "The arithmetic is right, but the inequality asks for a value LESS than 6."},
   {"text": "It cannot be decided without graphing", "feedback": "Substituting the point into the inequality settles it without any graph."}]'::jsonb,
 0, 'sub-graph-inequality'),

(9, 'MTH1W', 'Linear relations part 2', 6, 29, 'Challenge',
 'In which quadrants does the graph of xy = -8 lie?',
 '[{"text": "Quadrants 2 and 4", "feedback": "Correct."},
   {"text": "Quadrants 3 and 4", "feedback": "Quadrant 3 has both coordinates negative, which multiplies to a positive."},
   {"text": "All four quadrants", "feedback": "Two of the quadrants always produce a positive product, so the curve cannot reach them."},
   {"text": "Quadrants 1 and 3", "feedback": "Those quadrants give a positive product. This constant is negative."}]'::jsonb,
 0, 'sub-reciprocal'),

(9, 'MTH1W', 'Linear relations part 2', 6, 30, 'Challenge',
 'A reciprocal function passes through (1, 3), (3, 1) and (-1, -3). What is its equation?',
 '[{"text": "y = 3x", "feedback": "That is a straight line through the origin, not a hyperbola. Test the point (3, 1) in it."},
   {"text": "xy = 3", "feedback": "Correct."},
   {"text": "xy = -3", "feedback": "The sign is wrong. All three points give a positive product."},
   {"text": "xy = 1", "feedback": "Check by substituting a point: 1 times 3 does not give 1."}]'::jsonb,
 1, 'sub-reciprocal'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 2', 6, 31, 'Advanced',
 'Solve the system 5x + 2y = 4 and 3x - y = 9.',
 '[{"text": "(1, -6)", "feedback": "Those values fit 3x - y = 9 but not 5x + 2y = 4. Only one equation was checked."},
   {"text": "(2, -3)", "feedback": "Correct."},
   {"text": "(-3, 2)", "feedback": "The two coordinates have been written in the wrong order. The x comes first."},
   {"text": "(2, 3)", "feedback": "The x-value is right, but check the sign of y. Substitute x into 3x - y = 9."}]'::jsonb,
 1, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 32, 'Advanced',
 'Phone plan A costs 30 dollars a month plus 10 cents per minute. Plan B costs 20 dollars a month plus 15 cents per minute. After how many minutes do the two plans cost the same?',
 '[{"text": "50 minutes", "feedback": "The two monthly fees were added together instead of compared. That total is not a number of minutes."},
   {"text": "400 minutes", "feedback": "The 10 dollar gap was divided by 2.5 cents. Check the difference between the two per-minute rates."},
   {"text": "100 minutes", "feedback": "The 10 dollar gap was divided by the wrong difference. The rates differ by 5 cents, not 10."},
   {"text": "200 minutes", "feedback": "Correct."}]'::jsonb,
 3, 'sub-linear-systems'),

(9, 'MTH1W', 'Linear relations part 2', 6, 33, 'Advanced',
 'The system y = mx + 2 and 4x - 2y = 6 has no solution. What is the value of m?',
 '[{"text": "m = 2", "feedback": "Correct."},
   {"text": "m = -2", "feedback": "Rearranging 4x - 2y = 6 gives a positive slope, because a negative divided by a negative is positive."},
   {"text": "m = 1/2", "feedback": "The coefficients were divided the wrong way round when rearranging the second equation."},
   {"text": "m = -1/2", "feedback": "That is the negative reciprocal, which would make the lines perpendicular and give one solution."}]'::jsonb,
 0, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 34, 'Advanced',
 'What is the solution of the system x = 3 and y = -1?',
 '[{"text": "(-1, 3)", "feedback": "The two coordinates have been written in the wrong order. The x comes first."},
   {"text": "No solution, because one slope is undefined", "feedback": "An undefined slope does not stop the lines meeting. A vertical and a horizontal line always cross."},
   {"text": "(3, -1)", "feedback": "Correct."},
   {"text": "Infinitely many solutions", "feedback": "That needs the two equations to describe the same line. These two are perpendicular."}]'::jsonb,
 2, 'sub-solution-count'),

(9, 'MTH1W', 'Linear relations part 2', 6, 35, 'Advanced',
 'The graph of y = 4x is translated 5 units right and 2 units down. What is the equation of the new line?',
 '[{"text": "y = 4(x - 5) + 2", "feedback": "The horizontal shift is right, but adding at the end lifts the line rather than lowering it."},
   {"text": "y = 4x - 7", "feedback": "The 5 was subtracted at the end rather than inside the bracket, so it never got multiplied by the slope."},
   {"text": "y = 4(x + 5) - 2", "feedback": "A shift to the right subtracts inside the bracket. The plus sign moves it left."},
   {"text": "y = 4(x - 5) - 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 36, 'Advanced',
 'Which single transformation turns the graph of y = 3x into the graph of y = -3x?',
 '[{"text": "A 90 degree rotation about the origin", "feedback": "A rotation uses the negative reciprocal, which would give a slope of -1/3."},
   {"text": "A reflection in the x-axis", "feedback": "Correct."},
   {"text": "A translation down 6 units", "feedback": "A translation never changes the slope, and these two lines lean opposite ways."},
   {"text": "A translation left 3 units", "feedback": "Shifting a line through the origin sideways leaves it exactly where it was."}]'::jsonb,
 1, 'sub-transformations'),

(9, 'MTH1W', 'Linear relations part 2', 6, 37, 'Advanced',
 'A graph shows a solid boundary line through (0, 2) with a slope of -1/2, and the region containing the origin is shaded. Which inequality does it represent?',
 '[{"text": "y < -(1/2)x + 2", "feedback": "The shading is right, but a strict symbol would need a dashed line."},
   {"text": "y >= -(1/2)x + 2", "feedback": "The solid line is right, but this shades the region away from the origin."},
   {"text": "y <= -(1/2)x + 2", "feedback": "Correct."},
   {"text": "y > -(1/2)x + 2", "feedback": "Neither part matches. A strict symbol needs a dashed line, and this shades the wrong side."}]'::jsonb,
 2, 'sub-graph-inequality'),

(9, 'MTH1W', 'Linear relations part 2', 6, 38, 'Advanced',
 'The point (-2, k) lies on the graph of xy = -8. What is the value of k?',
 '[{"text": "k = -4", "feedback": "A negative times a negative gives a positive product. The constant here is negative, so the two coordinates must have opposite signs."},
   {"text": "k = 16", "feedback": "The two numbers were multiplied. Divide the constant by the known coordinate instead."},
   {"text": "k = -6", "feedback": "The -2 was subtracted from the -8. On this curve the coordinates multiply."},
   {"text": "k = 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-reciprocal'),

(9, 'MTH1W', 'Linear relations part 2', 6, 39, 'Advanced',
 'On the graph of xy = 6, what happens to y as x grows very large?',
 '[{"text": "It approaches 6", "feedback": "The 6 is the product of the two coordinates, not a value y settles on."},
   {"text": "It approaches zero without ever reaching it", "feedback": "Correct."},
   {"text": "It becomes negative", "feedback": "On this branch both coordinates stay positive, because their product has to be positive."},
   {"text": "It grows without limit, getting larger and larger", "feedback": "If both coordinates grew, their product would grow too. The product has to stay at 6."}]'::jsonb,
 1, 'sub-reciprocal'),

(9, 'MTH1W', 'Linear relations part 2', 6, 40, 'Advanced',
 'You are graphing xy > 5 in the first quadrant and you test the point (2, 2). What happens next?',
 '[{"text": "It is true, so shade the region containing (2, 2)", "feedback": "Substituting gives a product of 4, and 4 is not greater than 5."},
   {"text": "It is false, so shade the region containing (2, 2)", "feedback": "A failed test point is outside the solution, so the OTHER region gets shaded."},
   {"text": "It is false, so shade the region that does not contain (2, 2)", "feedback": "Correct."},
   {"text": "The point is on the curve itself, so choose a different test point", "feedback": "A point on this curve would have a product of exactly 5. This one gives 4."}]'::jsonb,
 2, 'sub-graph-inequality');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Linear relations part 2'
group by difficulty order by min(sort_order);
