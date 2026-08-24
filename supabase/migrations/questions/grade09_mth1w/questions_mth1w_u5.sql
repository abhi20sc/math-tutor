-- ===========================================================================
-- MTH1W — Unit 5: Linear Relations Part 1 — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Plotting points on the Cartesian plane
--   Lesson 2  Linear vs non-linear relationships (first differences)
--   Lesson 3  Slope
--   Lesson 4  Equation of a line in slope-intercept form
--   Lesson 5  Standard form and intercepts
--   Lesson 6  Parallel and perpendicular lines
--   Lesson 7  Determining the equation of a line
--
-- Seven lessons, so seven subtopics. Every one appears in every difficulty
-- band, so no traffic light is decided on a single questions worth of
-- evidence.
--
-- Every question is answerable from the text alone - coordinates and tables
-- are written out rather than shown on a grid - so this unit needs no
-- figures. The distractors are the slips the worked solutions keep
-- correcting: inverting rise over run, reading b as the slope, dropping the
-- negative when taking a reciprocal, and reading the x-intercept off the
-- wrong axis.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Linear relations part 1';

insert into misconception_labels (tag, label) values
  ('sub-plotting-points',  'Plotting points and the Cartesian plane'),
  ('sub-linear-nonlinear', 'Linear vs non-linear and first differences'),
  ('sub-slope',            'Slope and rate of change'),
  ('sub-slope-intercept',  'Slope-intercept form'),
  ('sub-standard-form',    'Standard form and intercepts'),
  ('sub-parallel-perp',    'Parallel and perpendicular lines'),
  ('sub-line-from-points', 'Finding the equation of a line')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 1', 5, 1, 'Easy',
 'In which quadrant does the point (3, -2) lie?',
 '[{"text": "Quadrant 4", "feedback": "Correct."},
   {"text": "Quadrant 3", "feedback": "That needs both coordinates negative. The x here is positive."},
   {"text": "Quadrant 1", "feedback": "Both coordinates would have to be positive. One of these is not."},
   {"text": "Quadrant 2", "feedback": "That needs a negative x and a positive y. Here it is the other way round."}]'::jsonb,
 0, 'sub-plotting-points'),

(9, 'MTH1W', 'Linear relations part 1', 5, 2, 'Easy',
 'Which of these points lies on the y-axis?',
 '[{"text": "(0, -4)", "feedback": "Correct."},
   {"text": "(3, 4)", "feedback": "Neither coordinate is zero, so this point sits inside a quadrant."},
   {"text": "(-1, -1)", "feedback": "Neither coordinate is zero, so this point sits inside a quadrant."},
   {"text": "(2, 0)", "feedback": "A zero in the second slot puts a point on the x-axis, not the y-axis."}]'::jsonb,
 0, 'sub-plotting-points'),

(9, 'MTH1W', 'Linear relations part 1', 5, 3, 'Easy',
 'A table of values has x going up by 1 each row, and its first differences are 2, 2, 2, 2. What does this tell you?',
 '[{"text": "It is linear, because all of the y-values are even numbers", "feedback": "Whether the values are even has nothing to do with it. Look at the differences between them."},
   {"text": "It is non-linear, because the first differences are not zero", "feedback": "First differences of zero would mean a horizontal line. Constant is what matters, not zero."},
   {"text": "It is linear, because the first differences are constant", "feedback": "Correct."},
   {"text": "It is non-linear, because the y-values keep changing from row to row", "feedback": "The y-values change in every relationship. What matters is whether they change by the same amount each time."}]'::jsonb,
 2, 'sub-linear-nonlinear'),

(9, 'MTH1W', 'Linear relations part 1', 5, 4, 'Easy',
 'A table of values has x going up by 1 each row, and its first differences are -5, -3, -1, 1, 3, 5. What does this tell you?',
 '[{"text": "It is non-linear, because the first differences are not constant", "feedback": "Correct."},
   {"text": "It is linear, because the first differences go up by 2 each time", "feedback": "The differences themselves have to be equal, not merely follow a pattern."},
   {"text": "It is linear, because the x-values go up by 1", "feedback": "Evenly spaced x-values are what makes the test valid. They do not make the relationship linear."},
   {"text": "It is non-linear, because some first differences are negative", "feedback": "A line can have negative first differences all the way down. Being negative is not the problem."}]'::jsonb,
 0, 'sub-linear-nonlinear'),

(9, 'MTH1W', 'Linear relations part 1', 5, 5, 'Easy',
 'Moving from one point on a line to another, you go up 6 and right 3. What is the slope of the line?',
 '[{"text": "2", "feedback": "Correct."},
   {"text": "1/2", "feedback": "The fraction is upside down. Slope is rise over run, not run over rise."},
   {"text": "9", "feedback": "The two numbers were added. Slope divides the rise by the run."},
   {"text": "18", "feedback": "The two numbers were multiplied. Slope divides the rise by the run."}]'::jsonb,
 0, 'sub-slope'),

(9, 'MTH1W', 'Linear relations part 1', 5, 6, 'Easy',
 'What is the slope of a horizontal line?',
 '[{"text": "1", "feedback": "A slope of 1 rises one unit for every unit across, which is a diagonal line."},
   {"text": "0", "feedback": "Correct."},
   {"text": "It depends on the line", "feedback": "Every horizontal line behaves the same way. The rise is always zero."},
   {"text": "Undefined", "feedback": "That belongs to a vertical line, where the run is zero and you would be dividing by zero."}]'::jsonb,
 1, 'sub-slope'),

(9, 'MTH1W', 'Linear relations part 1', 5, 7, 'Easy',
 'For the line y = 3x - 5, what is the y-intercept?',
 '[{"text": "3", "feedback": "That is the slope. In y = mx + b the intercept is the constant term."},
   {"text": "-3", "feedback": "That is the slope with a sign added. The intercept is the constant term."},
   {"text": "-5", "feedback": "Correct."},
   {"text": "5", "feedback": "The sign was dropped. The constant is being subtracted."}]'::jsonb,
 2, 'sub-slope-intercept'),

(9, 'MTH1W', 'Linear relations part 1', 5, 8, 'Easy',
 'What is the x-intercept of the line 4x + 6y = 12?',
 '[{"text": "(3, 0)", "feedback": "Correct."},
   {"text": "(12, 0)", "feedback": "The 4 in front of x was never divided out."},
   {"text": "(0, 3)", "feedback": "The number is right, but it is written in the wrong slot. An x-intercept has y equal to zero."},
   {"text": "(0, 2)", "feedback": "That is the y-intercept. For the x-intercept you set y to zero instead."}]'::jsonb,
 0, 'sub-standard-form'),

(9, 'MTH1W', 'Linear relations part 1', 5, 9, 'Easy',
 'A line has a slope of 3. What is the slope of any line parallel to it?',
 '[{"text": "-1/3", "feedback": "That is the negative reciprocal, which gives a perpendicular line."},
   {"text": "-3", "feedback": "That would be a line sloping the other way. Parallel lines never meet, so they lean the same way."},
   {"text": "1/3", "feedback": "That is the reciprocal. Parallel lines keep the slope exactly as it is."},
   {"text": "3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-parallel-perp'),

(9, 'MTH1W', 'Linear relations part 1', 5, 10, 'Easy',
 'A line has a slope of 2 and passes through (0, 7). What is its equation?',
 '[{"text": "y = 2x - 7", "feedback": "The point has a positive y-value, so the constant is positive."},
   {"text": "y = 2x", "feedback": "That line passes through the origin. This one crosses the y-axis higher up."},
   {"text": "y = 2x + 7", "feedback": "Correct."},
   {"text": "y = 7x + 2", "feedback": "The slope and the intercept have swapped places. In y = mx + b the slope multiplies x."}]'::jsonb,
 2, 'sub-line-from-points'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 1', 5, 11, 'Medium',
 'A triangle has vertices at A(-5, -3), B(3, -3) and C(3, 8). What is its area?',
 '[{"text": "19 square units", "feedback": "The base and height were added rather than multiplied."},
   {"text": "22 square units", "feedback": "The base was halved as well as the product. Only halve once."},
   {"text": "88 square units", "feedback": "That is base times height. The formula for a triangle takes half of that."},
   {"text": "44 square units", "feedback": "Correct."}]'::jsonb,
 3, 'sub-plotting-points'),

(9, 'MTH1W', 'Linear relations part 1', 5, 12, 'Medium',
 'Rory starts with 0 dollars saved and earns 20 dollars per hour. Cal starts with 100 dollars saved and also earns 20 dollars per hour. Which statement is true?',
 '[{"text": "Only the relationship for Rory is linear, because it starts at zero", "feedback": "Starting at zero is not what makes a relationship linear. A constant rate of change is."},
   {"text": "Both relationships are linear and have the same rate of change", "feedback": "Correct."},
   {"text": "Neither relationship is linear, because the amounts keep rising", "feedback": "Rising steadily is exactly what a linear relationship does. What matters is that it rises by the same amount each hour."},
   {"text": "Cal has a larger rate of change, because he starts with more money", "feedback": "The starting amount is the intercept, not the rate. Both earn the same per hour."}]'::jsonb,
 1, 'sub-linear-nonlinear'),

(9, 'MTH1W', 'Linear relations part 1', 5, 13, 'Medium',
 'What is the slope of the line through A(5, -7) and B(1, 3)?',
 '[{"text": "-2/5", "feedback": "The fraction is upside down. Slope divides the change in y by the change in x."},
   {"text": "2/5", "feedback": "The fraction is upside down and the sign was dropped as well."},
   {"text": "-5/2", "feedback": "Correct."},
   {"text": "5/2", "feedback": "The run came out negative here, because you move left from A to B. That sign belongs in the answer."}]'::jsonb,
 2, 'sub-slope'),

(9, 'MTH1W', 'Linear relations part 1', 5, 14, 'Medium',
 'What is the slope of the line through P1(-4, 6) and P2(-2, 10)?',
 '[{"text": "1/2", "feedback": "The fraction is upside down. Slope divides the change in y by the change in x."},
   {"text": "2", "feedback": "Correct."},
   {"text": "8", "feedback": "The two y-values were added rather than subtracted, so the top of the fraction is a total instead of a change."},
   {"text": "-2", "feedback": "Both x-values are negative, but the change between them is positive. Moving from -4 to -2 is a move to the right."}]'::jsonb,
 1, 'sub-slope'),

(9, 'MTH1W', 'Linear relations part 1', 5, 15, 'Medium',
 'State the slope and the y-intercept of the line y = -3x - 1.',
 '[{"text": "Slope -1, y-intercept -3", "feedback": "The two have been swapped. In y = mx + b the slope is what multiplies x."},
   {"text": "Slope -3, y-intercept -1", "feedback": "Correct."},
   {"text": "Slope 3, y-intercept -1", "feedback": "The minus in front of the 3 belongs to the slope."},
   {"text": "Slope -3, y-intercept 1", "feedback": "The constant is being subtracted, so the intercept is negative."}]'::jsonb,
 1, 'sub-slope-intercept'),

(9, 'MTH1W', 'Linear relations part 1', 5, 16, 'Medium',
 'What is the equation of the horizontal line through the point (2, 4)?',
 '[{"text": "y = 2x", "feedback": "That line has a slope of 2, so it is not horizontal."},
   {"text": "x = 4", "feedback": "That is vertical, and it uses the wrong coordinate as well."},
   {"text": "x = 2", "feedback": "That is a vertical line. It holds x fixed while y varies."},
   {"text": "y = 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-slope-intercept'),

(9, 'MTH1W', 'Linear relations part 1', 5, 17, 'Medium',
 'Convert y = -4x - 11 to standard form, with integer values and a positive coefficient on x.',
 '[{"text": "4x + y = -11", "feedback": "Correct."},
   {"text": "4x + y = 11", "feedback": "The x term was moved correctly, but the constant on the right kept the wrong sign."},
   {"text": "-4x + y = -11", "feedback": "The -4x was carried to the other side but kept its sign. A term changes sign when it crosses the equals sign."},
   {"text": "4x - y = -11", "feedback": "The y term was flipped as well, but it never crossed the equals sign, so its sign should have stayed."}]'::jsonb,
 0, 'sub-standard-form'),

(9, 'MTH1W', 'Linear relations part 1', 5, 18, 'Medium',
 'What is the y-intercept of the line 3x - 6y = 24?',
 '[{"text": "(0, 4)", "feedback": "The sign was lost. Dividing 24 by -6 gives a negative."},
   {"text": "(0, -24)", "feedback": "The -6 in front of y was never divided out."},
   {"text": "(8, 0)", "feedback": "That is the x-intercept. For the y-intercept you set x to zero instead."},
   {"text": "(0, -4)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-standard-form'),

(9, 'MTH1W', 'Linear relations part 1', 5, 19, 'Medium',
 'A line has the equation y = -(2/3)x + 20. What is the slope of a line perpendicular to it?',
 '[{"text": "-3/2", "feedback": "The fraction was flipped but the sign was kept. A negative reciprocal changes both."},
   {"text": "2/3", "feedback": "The sign was changed but the fraction was not flipped."},
   {"text": "-2/3", "feedback": "That is the same slope, which would give a parallel line."},
   {"text": "3/2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-parallel-perp'),

(9, 'MTH1W', 'Linear relations part 1', 5, 20, 'Medium',
 'Find the equation of the line with slope -2 that passes through (-3, -7).',
 '[{"text": "y = -2x - 1", "feedback": "When -2 is multiplied by -3 the result is positive 6. Check the sign in that step."},
   {"text": "y = -2x + 13", "feedback": "The constant was moved to the wrong side when solving for b."},
   {"text": "y = -2x - 7", "feedback": "The y-value of the point was used as the intercept directly. It is only the intercept if x is zero."},
   {"text": "y = -2x - 13", "feedback": "Correct."}]'::jsonb,
 3, 'sub-line-from-points'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 1', 5, 21, 'Challenge',
 'The points D(1, 1), E(1, -2), F(-5, -2) and G(-5, 1) are joined in order to close a figure. What is it, and what is its area?',
 '[{"text": "A rectangle with area 12 square units", "feedback": "The width is 6 units, not 4. Count from -5 across to 1."},
   {"text": "A square with area 18 square units", "feedback": "The area is right, but the two side lengths are not equal, so it is not a square."},
   {"text": "A rectangle with area 9 square units", "feedback": "The side lengths were added rather than multiplied."},
   {"text": "A rectangle with area 18 square units", "feedback": "Correct."}]'::jsonb,
 3, 'sub-plotting-points'),

(9, 'MTH1W', 'Linear relations part 1', 5, 22, 'Challenge',
 'A table has x-values 0, 1, 2, 3 and y-values 5, 8, 13, 20. Which statement is correct?',
 '[{"text": "It is linear, because the first differences increase by a constant 2", "feedback": "That is a pattern in the SECOND differences. The first differences themselves have to be equal."},
   {"text": "It is non-linear, because the first differences are not constant", "feedback": "Correct."},
   {"text": "It is linear, because the x-values increase by 1 in every row of the table", "feedback": "Evenly spaced x-values only make the test valid. They do not make the relationship linear."},
   {"text": "It is non-linear, because none of the y-values are equal to each other", "feedback": "A line never repeats a y-value unless it is horizontal. That is not the test."}]'::jsonb,
 1, 'sub-linear-nonlinear'),

(9, 'MTH1W', 'Linear relations part 1', 5, 23, 'Challenge',
 'A table has x-values -20, -18, -16, -14 and y-values 75, 70, 65, 60. What is the rate of change?',
 '[{"text": "-5", "feedback": "That is the change in y between rows. The x-values step by 2, so that has to be divided out."},
   {"text": "-5/2", "feedback": "Correct."},
   {"text": "5/2", "feedback": "The y-values are falling, so the rate of change is negative."},
   {"text": "-2/5", "feedback": "The fraction is upside down. Rate of change divides the change in y by the change in x."}]'::jsonb,
 1, 'sub-slope'),

(9, 'MTH1W', 'Linear relations part 1', 5, 24, 'Challenge',
 'Rearrange 3x - 6y = 24 into slope-intercept form.',
 '[{"text": "y = 2x - 4", "feedback": "The fraction was inverted. Divide the 3 by the 6, not the other way round."},
   {"text": "y = -(1/2)x - 4", "feedback": "Dividing -3x by -6 gives a positive result. Two negatives make a positive."},
   {"text": "y = (1/2)x + 4", "feedback": "Dividing 24 by -6 gives a negative constant."},
   {"text": "y = (1/2)x - 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-slope-intercept'),

(9, 'MTH1W', 'Linear relations part 1', 5, 25, 'Challenge',
 'A line has a slope of 0 and passes through the point (3, 1). What is its equation?',
 '[{"text": "y = x + 1", "feedback": "That line has a slope of 1, so it is not flat."},
   {"text": "y = 1", "feedback": "Correct."},
   {"text": "x = 3", "feedback": "That is a vertical line, which has an undefined slope rather than a slope of zero."},
   {"text": "y = 3", "feedback": "The wrong coordinate was used. A horizontal line is fixed at its y-value."}]'::jsonb,
 1, 'sub-slope-intercept'),

(9, 'MTH1W', 'Linear relations part 1', 5, 26, 'Challenge',
 'Convert y = (5/3)x - 8 to standard form, with integers and a positive coefficient on x.',
 '[{"text": "5x - 3y = 24", "feedback": "Correct."},
   {"text": "5x + 3y = 24", "feedback": "The equation was negated to make the x coefficient positive, but the y term was left with its old sign."},
   {"text": "5x - 3y = -24", "feedback": "The constant was multiplied by 3 but kept the wrong sign after both terms moved."},
   {"text": "5x - 3y = 8", "feedback": "Only the x term was multiplied by 3 when the fraction was cleared. The constant took no part in it."}]'::jsonb,
 0, 'sub-standard-form'),

(9, 'MTH1W', 'Linear relations part 1', 5, 27, 'Challenge',
 'What is the x-intercept of the line 2x - 5y = 20?',
 '[{"text": "(20, 0)", "feedback": "The 2 in front of x was never divided out."},
   {"text": "(0, 10)", "feedback": "The number is right, but it is in the wrong slot. An x-intercept has y equal to zero."},
   {"text": "(10, 0)", "feedback": "Correct."},
   {"text": "(0, -4)", "feedback": "That is the y-intercept. For the x-intercept you set y to zero instead."}]'::jsonb,
 2, 'sub-standard-form'),

(9, 'MTH1W', 'Linear relations part 1', 5, 28, 'Challenge',
 'What is the slope of a line perpendicular to 2x - 3y - 6 = 0?',
 '[{"text": "-3/2", "feedback": "Correct."},
   {"text": "-2/3", "feedback": "The sign was changed but the fraction was not flipped."},
   {"text": "2/3", "feedback": "That is the slope of the given line itself, which would give a parallel line."},
   {"text": "3/2", "feedback": "The fraction was flipped but the sign was kept. A negative reciprocal changes both."}]'::jsonb,
 0, 'sub-parallel-perp'),

(9, 'MTH1W', 'Linear relations part 1', 5, 29, 'Challenge',
 'One line has a slope of 4 and another has a slope of -1/4. What is the relationship between them?',
 '[{"text": "Neither parallel nor perpendicular, because the slopes are not equal", "feedback": "Unequal slopes only rule out parallel. There is a second relationship worth testing."},
   {"text": "They are parallel, because their slopes are reciprocals of each other", "feedback": "Parallel lines have identical slopes, not reciprocal ones."},
   {"text": "They are perpendicular, because the product of their slopes is -1", "feedback": "Correct."},
   {"text": "They are perpendicular, because their y-intercepts are different numbers", "feedback": "The conclusion is right but the reason is not. Intercepts play no part in this test."}]'::jsonb,
 2, 'sub-parallel-perp'),

(9, 'MTH1W', 'Linear relations part 1', 5, 30, 'Challenge',
 'Find the equation of the line that passes through A(4, -3) and B(2, 5).',
 '[{"text": "y = 4x - 19", "feedback": "The slope lost its sign. Going from A to B the y rises while the x falls."},
   {"text": "y = -4x + 13", "feedback": "Correct."},
   {"text": "y = -4x + 5", "feedback": "The slope is right, but the y-value of the other point was used as the intercept."},
   {"text": "y = -4x - 3", "feedback": "The slope is right, but the y-value of a point was used as the intercept. It is only the intercept if x is zero."}]'::jsonb,
 1, 'sub-line-from-points'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Linear relations part 1', 5, 31, 'Advanced',
 'Three vertices of a rectangle are (-2, 5), (6, 5) and (6, -1). What are the coordinates of the fourth vertex?',
 '[{"text": "(-2, 1)", "feedback": "The sign on the y was dropped. It has to match the bottom edge of the rectangle."},
   {"text": "(-1, -2)", "feedback": "The two coordinates are the right numbers but in the wrong order. The x comes first."},
   {"text": "(-2, -1)", "feedback": "Correct."},
   {"text": "(6, -2)", "feedback": "That reuses an x-value that is already taken. The missing corner sits below (-2, 5)."}]'::jsonb,
 2, 'sub-plotting-points'),

(9, 'MTH1W', 'Linear relations part 1', 5, 32, 'Advanced',
 'A table has x-values 0, 2, 4, 6 and y-values 3, 11, 19, 27. What equation describes the relationship?',
 '[{"text": "y = 4x + 8", "feedback": "The rate of change is right, but the starting value was taken from the differences instead of the table."},
   {"text": "y = 8x + 3", "feedback": "8 is the change in y between rows, but the x-values step by 2, so that has to be divided out."},
   {"text": "y = 4x + 3", "feedback": "Correct."},
   {"text": "y = 3x + 4", "feedback": "The rate of change and the starting value have swapped places."}]'::jsonb,
 2, 'sub-linear-nonlinear'),

(9, 'MTH1W', 'Linear relations part 1', 5, 33, 'Advanced',
 'A line with slope -2 passes through the points (a, 5) and (7, -3). What is the value of a?',
 '[{"text": "a = 5", "feedback": "That is the y-value of the first point. The unknown here sits in the x slot."},
   {"text": "a = 11", "feedback": "The subtraction was done in opposite orders on the top and bottom. Keep both going the same way."},
   {"text": "a = -3", "feedback": "That is the y-value of the second point, not the missing x-value."},
   {"text": "a = 3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-slope'),

(9, 'MTH1W', 'Linear relations part 1', 5, 34, 'Advanced',
 'A vertical line passes through the point (2, 4). What are its slope and y-intercept?',
 '[{"text": "Undefined slope and no y-intercept", "feedback": "Correct."},
   {"text": "Slope 0 and no y-intercept", "feedback": "The second part is right, but dividing by a run of zero is what makes the slope undefined, not zero."},
   {"text": "Slope 0 and y-intercept 4", "feedback": "A slope of zero belongs to a horizontal line. A vertical line has a run of zero instead."},
   {"text": "Undefined slope and y-intercept 2", "feedback": "The slope is right, but this line runs parallel to the y-axis, so it never crosses it."}]'::jsonb,
 0, 'sub-slope-intercept'),

(9, 'MTH1W', 'Linear relations part 1', 5, 35, 'Advanced',
 'The line 4x + 6y = 12 has intercepts at (3, 0) and (0, 2). Use them to find the slope of the line.',
 '[{"text": "-2/3", "feedback": "Correct."},
   {"text": "-3/2", "feedback": "The fraction is upside down. Slope divides the change in y by the change in x."},
   {"text": "3/2", "feedback": "The fraction is upside down and the sign was dropped as well."},
   {"text": "2/3", "feedback": "Going from the x-intercept to the y-intercept you move left, so the run is negative."}]'::jsonb,
 0, 'sub-standard-form'),

(9, 'MTH1W', 'Linear relations part 1', 5, 36, 'Advanced',
 'Find the equation of the line perpendicular to y = (3/4)x + 1 that passes through (0, -5).',
 '[{"text": "y = (4/3)x - 5", "feedback": "The fraction was flipped but the sign was kept. A negative reciprocal changes both."},
   {"text": "y = -(4/3)x - 5", "feedback": "Correct."},
   {"text": "y = (3/4)x - 5", "feedback": "That keeps the original slope, which gives a parallel line."},
   {"text": "y = -(3/4)x - 5", "feedback": "The sign was changed but the fraction was not flipped."}]'::jsonb,
 1, 'sub-parallel-perp'),

(9, 'MTH1W', 'Linear relations part 1', 5, 37, 'Advanced',
 'Are the lines 2x + 4y = 8 and y = -(1/2)x + 3 parallel, perpendicular, or neither?',
 '[{"text": "They are the same line", "feedback": "The slopes do match, but the two lines cross the y-axis at different heights."},
   {"text": "Perpendicular", "feedback": "That would need the slopes to multiply to -1. Rearrange the first equation and compare."},
   {"text": "Neither", "feedback": "Rearranging the first equation into slope-intercept form reveals a slope worth comparing."},
   {"text": "Parallel", "feedback": "Correct."}]'::jsonb,
 3, 'sub-parallel-perp'),

(9, 'MTH1W', 'Linear relations part 1', 5, 38, 'Advanced',
 'Find the equation of the line parallel to y = -(3/5)x + 10 that passes through (20, -4).',
 '[{"text": "y = (5/3)x - 4", "feedback": "That is the negative reciprocal, which gives a perpendicular line, and the point was used as the intercept."},
   {"text": "y = -(3/5)x + 10", "feedback": "The slope is right, but this is the original line. It does not pass through the given point."},
   {"text": "y = -(3/5)x + 8", "feedback": "Correct."},
   {"text": "y = -(3/5)x - 16", "feedback": "The -12 was subtracted rather than moved across. Moving it makes it an addition."}]'::jsonb,
 2, 'sub-line-from-points'),

(9, 'MTH1W', 'Linear relations part 1', 5, 39, 'Advanced',
 'Find the equation of the line perpendicular to 2x - y + 4 = 0 that passes through (-2, 5).',
 '[{"text": "y = 2x + 9", "feedback": "That keeps the slope of the original line, which gives a parallel line."},
   {"text": "y = (1/2)x + 6", "feedback": "The fraction was flipped but the sign was kept. A negative reciprocal changes both."},
   {"text": "y = -(1/2)x + 4", "feedback": "Correct."},
   {"text": "y = -(1/2)x + 6", "feedback": "The slope is right, but -1/2 multiplied by -2 gives a positive 1, which changes the constant."}]'::jsonb,
 2, 'sub-line-from-points'),

(9, 'MTH1W', 'Linear relations part 1', 5, 40, 'Advanced',
 'Find the equation of the line that passes through (-1, 8) and (3, -4).',
 '[{"text": "y = -(1/3)x + 5", "feedback": "The slope fraction is upside down. Divide the change in y by the change in x."},
   {"text": "y = -3x + 5", "feedback": "Correct."},
   {"text": "y = -3x + 11", "feedback": "The slope is right, but -3 multiplied by -1 gives a positive 3, which changes the constant."},
   {"text": "y = 3x + 11", "feedback": "The slope lost its sign. The y-value falls as the x-value rises here."}]'::jsonb,
 1, 'sub-line-from-points');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Linear relations part 1'
group by difficulty order by min(sort_order);
