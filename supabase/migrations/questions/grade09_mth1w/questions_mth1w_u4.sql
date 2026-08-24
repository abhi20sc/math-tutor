-- ===========================================================================
-- MTH1W — Unit 4: Solving Equations — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  One, two and multi-step equations
--   Lesson 2  Equations involving fractions
--   Lesson 3  Simple quadratic and cubic equations
--   Lesson 4  Rearranging formulas
--   Lesson 5  Solving linear inequalities
--   Lesson 6  Applications of equations
--
-- Six lessons, so this unit carries SIX subtopics rather than the usual five.
-- Each one appears in every difficulty band, so the traffic light for it is
-- never decided on one questions worth of evidence.
--
-- The distractors are the slips the worked solutions keep correcting:
-- applying an inverse operation in the wrong direction, distributing a minus
-- to only the first term, forgetting that a square root has two signs, and
-- the one this unit is really about — failing to REVERSE an inequality after
-- dividing by a negative.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Solving equations';

insert into misconception_labels (tag, label) values
  ('sub-solve-linear',       'Solving multi-step linear equations'),
  ('sub-equations-fractions','Equations involving fractions'),
  ('sub-quad-cubic',         'Simple quadratic and cubic equations'),
  ('sub-rearrange-formulas', 'Rearranging formulas'),
  ('sub-inequalities',       'Linear inequalities'),
  ('sub-word-equations',     'Turning word problems into equations')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Solving equations', 4, 1, 'Easy',
 'Solve x - 5 = 10.',
 '[{"text": "x = 15", "feedback": "Correct."},
   {"text": "x = 5", "feedback": "The 5 was subtracted again. The inverse of subtracting 5 is adding 5."},
   {"text": "x = -5", "feedback": "That took 10 away from 5. Start from the 10 and undo the subtraction."},
   {"text": "x = 2", "feedback": "That divided instead. The 5 is being subtracted, not multiplied."}]'::jsonb,
 0, 'sub-solve-linear'),

(9, 'MTH1W', 'Solving equations', 4, 2, 'Easy',
 'Solve 3x = 12.',
 '[{"text": "x = 15", "feedback": "The 3 was added. Look at how it is attached to the x."},
   {"text": "x = 36", "feedback": "The two numbers were multiplied. The inverse of multiplying by 3 is dividing by 3."},
   {"text": "x = 9", "feedback": "The 3 was subtracted. It is attached to x by multiplication, so it comes off by division."},
   {"text": "x = 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-solve-linear'),

(9, 'MTH1W', 'Solving equations', 4, 3, 'Easy',
 'Solve x / 3 = 10.',
 '[{"text": "x = 10 / 3", "feedback": "That divided again. The x is already being divided by 3, so undo it by multiplying."},
   {"text": "x = 30", "feedback": "Correct."},
   {"text": "x = 13", "feedback": "The 3 was added across. It is attached by division, so it comes off by multiplication."},
   {"text": "x = 7", "feedback": "The 3 was subtracted across. Look at how it is attached to the x."}]'::jsonb,
 1, 'sub-equations-fractions'),

(9, 'MTH1W', 'Solving equations', 4, 4, 'Easy',
 'Solve 2x / 5 = 10.',
 '[{"text": "x = 50", "feedback": "Multiplying by 5 is the right first move, but the 2 in front of x still has to be divided out."},
   {"text": "x = 4", "feedback": "The 5 was divided and the 2 multiplied. Both inverse operations are the wrong way round."},
   {"text": "x = 1", "feedback": "Both steps were done as divisions. Only the 2 comes off by dividing."},
   {"text": "x = 25", "feedback": "Correct."}]'::jsonb,
 3, 'sub-equations-fractions'),

(9, 'MTH1W', 'Solving equations', 4, 5, 'Easy',
 'Solve x^2 = 9.',
 '[{"text": "x = 81", "feedback": "That squared both sides again. Undo a square by taking the square root."},
   {"text": "x = 3", "feedback": "Only one root was recorded. Check the sign rule that comes with taking a square root."},
   {"text": "x = 3 or x = -3", "feedback": "Correct."},
   {"text": "x = 4.5", "feedback": "That halved the 9. Squaring is not the same as multiplying by 2."}]'::jsonb,
 2, 'sub-quad-cubic'),

(9, 'MTH1W', 'Solving equations', 4, 6, 'Easy',
 'Solve x^3 - 125 = 0.',
 '[{"text": "x = 5 or x = -5", "feedback": "Both signs were attached as if this were a square root. Check what cubing does to the sign of a negative base."},
   {"text": "x = 5", "feedback": "Correct."},
   {"text": "x = 375", "feedback": "That multiplied by 3. Undo a cube by taking the cube root, not by multiplying."},
   {"text": "x = 11.18", "feedback": "That took the square root. The exponent here is 3."}]'::jsonb,
 1, 'sub-quad-cubic'),

(9, 'MTH1W', 'Solving equations', 4, 7, 'Easy',
 'Rearrange d = a + b to isolate a.',
 '[{"text": "a = b - d", "feedback": "The two letters were swapped. Start from d and take b off it."},
   {"text": "a = d / b", "feedback": "The b is being added to a, not multiplied by it, so it comes off by subtraction."},
   {"text": "a = d - b", "feedback": "Correct."},
   {"text": "a = d + b", "feedback": "The b was added again. Treat the other letters like numbers and undo the addition."}]'::jsonb,
 2, 'sub-rearrange-formulas'),

(9, 'MTH1W', 'Solving equations', 4, 8, 'Easy',
 'The circumference of a circle is C = 2 x pi x r. Rearrange it to isolate r.',
 '[{"text": "r = C / (2 x pi)", "feedback": "Correct."},
   {"text": "r = (2 x pi) / C", "feedback": "The fraction is upside down. C is the one being divided."},
   {"text": "r = 2 x pi x C", "feedback": "That multiplied again. Everything attached to r by multiplication comes off by division."},
   {"text": "r = C - 2 x pi", "feedback": "The 2 and the pi are multiplying r, not being added to it."}]'::jsonb,
 0, 'sub-rearrange-formulas'),

(9, 'MTH1W', 'Solving equations', 4, 9, 'Easy',
 'Solve the inequality x + 4 < 10.',
 '[{"text": "x > 6", "feedback": "The number is right, but the sign was flipped. It only reverses when you multiply or divide by a negative."},
   {"text": "x < 14", "feedback": "The 4 was added to both sides. Subtract it to isolate x."},
   {"text": "x < 2.5", "feedback": "That divided by 4. The 4 is being added, so it comes off by subtraction."},
   {"text": "x < 6", "feedback": "Correct."}]'::jsonb,
 3, 'sub-inequalities'),

(9, 'MTH1W', 'Solving equations', 4, 10, 'Easy',
 'Five more than a number is twenty-seven. Which equation says this?',
 '[{"text": "5x = 27", "feedback": "That is five times the number. More than is not multiplication."},
   {"text": "x + 5 = 27", "feedback": "Correct."},
   {"text": "5 - x = 27", "feedback": "That subtracts the number from 5, which reverses the whole statement."},
   {"text": "x - 5 = 27", "feedback": "That is five LESS than the number. More than means addition."}]'::jsonb,
 1, 'sub-word-equations'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Solving equations', 4, 11, 'Medium',
 'Solve 7 - 2x = 8 - 5x.',
 '[{"text": "x = 1/3", "feedback": "Correct."},
   {"text": "x = -1/3", "feedback": "The constants were combined the wrong way round, which flipped the sign of the answer."},
   {"text": "x = 3", "feedback": "The final division was done upside down. Check which number is being divided by which."},
   {"text": "x = -3", "feedback": "Both the sign and the final division went the wrong way."}]'::jsonb,
 0, 'sub-solve-linear'),

(9, 'MTH1W', 'Solving equations', 4, 12, 'Medium',
 'Solve 5(x - 3) - (x - 2) = 19.',
 '[{"text": "x = 8", "feedback": "Correct."},
   {"text": "x = 32", "feedback": "That stopped at 4x = 32. There is one division left to do."},
   {"text": "x = 9", "feedback": "The minus in front of the second bracket reached the x but not the 2. That term becomes +2."},
   {"text": "x = 5", "feedback": "The 5 was multiplied by the x but not by the 3. It reaches both terms."}]'::jsonb,
 0, 'sub-solve-linear'),

(9, 'MTH1W', 'Solving equations', 4, 13, 'Medium',
 'Solve (1/3)(x - 2) = 5.',
 '[{"text": "x = 21", "feedback": "The 3 was multiplied into only one term of the bracket. It multiplies the whole bracket at once."},
   {"text": "x = 15", "feedback": "That stopped at x - 2 = 15. The 2 still has to be moved."},
   {"text": "x = 13", "feedback": "The 2 was subtracted. It is already being subtracted, so undo it by adding."},
   {"text": "x = 17", "feedback": "Correct."}]'::jsonb,
 3, 'sub-equations-fractions'),

(9, 'MTH1W', 'Solving equations', 4, 14, 'Medium',
 'Solve -14 = 2(x - 3) / 5.',
 '[{"text": "x = -38", "feedback": "After multiplying by 5 you get -70 = 2x - 6. The 6 is being subtracted, so it moves across as an addition."},
   {"text": "x = -35", "feedback": "The 2 in front of the bracket was never divided out, and the 6 was dropped."},
   {"text": "x = -76", "feedback": "The 6 was moved across with the wrong sign, and the answer was left at the value of 2x."},
   {"text": "x = -32", "feedback": "Correct."}]'::jsonb,
 3, 'sub-equations-fractions'),

(9, 'MTH1W', 'Solving equations', 4, 15, 'Medium',
 'Solve x^2 + 100 = 0.',
 '[{"text": "x = -10", "feedback": "Squaring -10 gives +100, not -100. The minus sign cannot be carried in by the root."},
   {"text": "There is no real solution", "feedback": "Correct."},
   {"text": "x = 50 or x = -50", "feedback": "That halved the 100. Undo a square with a square root."},
   {"text": "x = 10 or x = -10", "feedback": "Those both give +100 when squared, not -100. Check the sign after moving the 100 across."}]'::jsonb,
 1, 'sub-quad-cubic'),

(9, 'MTH1W', 'Solving equations', 4, 16, 'Medium',
 'Rearrange y = mx + b to isolate x.',
 '[{"text": "x = m(y - b)", "feedback": "The m is multiplying x, so it comes off by division, not by multiplying the other side."},
   {"text": "x = (y + b) / m", "feedback": "The b is being added, so it moves across as a subtraction."},
   {"text": "x = (y - b) / m", "feedback": "Correct."},
   {"text": "x = y / m - b", "feedback": "The b was taken off after dividing. It has to come off first, while it is still added to the whole term."}]'::jsonb,
 2, 'sub-rearrange-formulas'),

(9, 'MTH1W', 'Solving equations', 4, 17, 'Medium',
 'Solve the inequality -4x <= -16.',
 '[{"text": "x <= 4", "feedback": "The number is right, but dividing both sides by a negative reverses the inequality sign."},
   {"text": "x >= 4", "feedback": "Correct."},
   {"text": "x >= -4", "feedback": "A negative divided by a negative is positive. Check the sign of the answer."},
   {"text": "x <= -4", "feedback": "Neither the sign of the answer nor the direction of the inequality was handled."}]'::jsonb,
 1, 'sub-inequalities'),

(9, 'MTH1W', 'Solving equations', 4, 18, 'Medium',
 'Solve the inequality 3 - x < 4.',
 '[{"text": "x > 1", "feedback": "The direction was reversed correctly, but the sign of the number was not."},
   {"text": "x < -1", "feedback": "The number is right, but dividing by -1 reverses the inequality."},
   {"text": "x > -1", "feedback": "Correct."},
   {"text": "x < 1", "feedback": "The 3 moves across to give -x < 1. Dividing by -1 reverses the sign."}]'::jsonb,
 2, 'sub-inequalities'),

(9, 'MTH1W', 'Solving equations', 4, 19, 'Medium',
 'Three consecutive integers have a sum of 75. What are the three integers?',
 '[{"text": "23, 25, 27", "feedback": "Those add to 75, but they go up in twos. Consecutive integers go up by one."},
   {"text": "25, 25, 25", "feedback": "Those add to 75, but they are the same number three times, not three consecutive integers."},
   {"text": "24, 26, 28", "feedback": "Those go up in twos and do not add to 75."},
   {"text": "24, 25, 26", "feedback": "Correct."}]'::jsonb,
 3, 'sub-word-equations'),

(9, 'MTH1W', 'Solving equations', 4, 20, 'Medium',
 'Curtis is paid 6 dollars per hour plus 50 cents for every bag of peanuts he sells. What does he earn for selling 42 bags during a 4 hour shift?',
 '[{"text": "24 dollars", "feedback": "That is the hourly pay only. The commission on 42 bags still has to be added."},
   {"text": "45 dollars", "feedback": "Correct."},
   {"text": "21 dollars", "feedback": "That is the commission only. The 4 hours of pay still has to be added."},
   {"text": "66 dollars", "feedback": "The commission was counted as one dollar a bag. It is 50 cents."}]'::jsonb,
 1, 'sub-word-equations'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Solving equations', 4, 21, 'Challenge',
 'Solve 2(x - 3) = -3(x + 5) - 6.',
 '[{"text": "x = -3/5", "feedback": "The -6 on the right was added instead of subtracted when it moved across."},
   {"text": "x = 3", "feedback": "The final division dropped the negative. 5x = -15 gives a negative answer."},
   {"text": "x = 1", "feedback": "The -3 reached the x but not the 5. That term becomes -15."},
   {"text": "x = -3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-solve-linear'),

(9, 'MTH1W', 'Solving equations', 4, 22, 'Challenge',
 'Solve 5(5x - 13) = 23x - 13.',
 '[{"text": "x = 39", "feedback": "The -13 lost its minus sign when the two constants were combined."},
   {"text": "x = 13", "feedback": "That stopped one step early. 2x = 52 still has to be divided out."},
   {"text": "x = 26", "feedback": "Correct."},
   {"text": "x = -26", "feedback": "The constants were combined the wrong way round, which flipped the sign of the answer."}]'::jsonb,
 2, 'sub-solve-linear'),

(9, 'MTH1W', 'Solving equations', 4, 23, 'Challenge',
 'Solve (2x - 1) / 3 = (3x - 2) / 5.',
 '[{"text": "x = -1", "feedback": "Correct."},
   {"text": "x = 1", "feedback": "Each bracket was multiplied out only into its constant term. The multiplier reaches the x as well."},
   {"text": "x = 7/9", "feedback": "The cross multiplication paired each numerator with its own denominator. Each numerator meets the OTHER denominator."},
   {"text": "x = -11", "feedback": "The -5 crossed the equals sign but kept its minus sign."}]'::jsonb,
 0, 'sub-equations-fractions'),

(9, 'MTH1W', 'Solving equations', 4, 24, 'Challenge',
 'The area of a circle is 30 cm^2. What is its radius, to the nearest tenth of a cm? Use A = pi x r^2.',
 '[{"text": "9.5 cm", "feedback": "That is the value of r squared. There is still a square root to take."},
   {"text": "3.1 cm", "feedback": "Correct."},
   {"text": "5.5 cm", "feedback": "That is the square root of 30. The 30 has to be divided by pi first."},
   {"text": "4.8 cm", "feedback": "That used the circumference formula. This question gives an area."}]'::jsonb,
 1, 'sub-quad-cubic'),

(9, 'MTH1W', 'Solving equations', 4, 25, 'Challenge',
 'Solve x^3 = 100, to the nearest hundredth.',
 '[{"text": "x = 10", "feedback": "That took the square root. The exponent is 3, so it needs a cube root."},
   {"text": "x = 33.33", "feedback": "That divided by 3. A cube is repeated multiplication, not multiplication by 3."},
   {"text": "x = 4.64", "feedback": "Correct."},
   {"text": "x = 300", "feedback": "That multiplied by 3 instead of undoing the cube."}]'::jsonb,
 2, 'sub-quad-cubic'),

(9, 'MTH1W', 'Solving equations', 4, 26, 'Challenge',
 'Rearrange k = (1/2)mv^2 to isolate v. Write sqrt() for a square root.',
 '[{"text": "v = +/- sqrt(k / (2m))", "feedback": "The half was divided rather than multiplied away. Multiply both sides by 2 to clear it."},
   {"text": "v = 2k / m", "feedback": "The square on v was never undone. A square root is still needed."},
   {"text": "v = +/- sqrt(2k) / m", "feedback": "The m stayed outside the root. It is under the square with the 2k."},
   {"text": "v = +/- sqrt(2k / m)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rearrange-formulas'),

(9, 'MTH1W', 'Solving equations', 4, 27, 'Challenge',
 'The distance to the horizon is d = 2 x sqrt(3.2h), where h is your height in metres and d is in km. If the horizon is 75.64 km away, how high up are you, to the nearest metre?',
 '[{"text": "894 m", "feedback": "The squaring was done, but the 3.2 was only half divided out."},
   {"text": "1788 m", "feedback": "The 2 out front was never divided away before squaring both sides."},
   {"text": "12 m", "feedback": "The 2 was divided out correctly, but then the square root was never undone."},
   {"text": "447 m", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rearrange-formulas'),

(9, 'MTH1W', 'Solving equations', 4, 28, 'Challenge',
 'Solve the inequality 91 - 4x <= 5x + 10.',
 '[{"text": "x >= 9", "feedback": "Correct."},
   {"text": "x <= 9", "feedback": "The number is right, but nothing was divided by a negative here, so the sign should not have flipped."},
   {"text": "x >= -9", "feedback": "The constants were collected the wrong way round. 91 - 10 is positive."},
   {"text": "x <= -9", "feedback": "Both the sign of the number and the direction of the inequality went the wrong way."}]'::jsonb,
 0, 'sub-inequalities'),

(9, 'MTH1W', 'Solving equations', 4, 29, 'Challenge',
 'Solve the inequality x/2 + x/3 > 5.',
 '[{"text": "x > 1", "feedback": "Only the left side was multiplied by 6. The right side has to be multiplied by 6 as well."},
   {"text": "x > 30", "feedback": "Both sides were multiplied by 6, but the left side was not collected. 3x + 2x is 5x, not x."},
   {"text": "x > 6", "feedback": "Correct."},
   {"text": "x < 6", "feedback": "The number is right, but nothing was divided by a negative, so the sign should not have flipped."}]'::jsonb,
 2, 'sub-inequalities'),

(9, 'MTH1W', 'Solving equations', 4, 30, 'Challenge',
 'The length of a rectangle is 7 m more than its width, and its perimeter is 60 m. What is the width?',
 '[{"text": "13 m", "feedback": "That divided 60 by 4 and then took off 2. The 7 has to be doubled before it is removed."},
   {"text": "26.5 m", "feedback": "The extra 7 was only counted once. A rectangle has two lengths."},
   {"text": "11.5 m", "feedback": "Correct."},
   {"text": "18.5 m", "feedback": "That is the length. The question asks for the width, which is 7 m less."}]'::jsonb,
 2, 'sub-word-equations'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Solving equations', 4, 31, 'Advanced',
 'Solve 3(2x + 5) - 2(x - 4) = 4(x + 6) - 5.',
 '[{"text": "Infinitely many solutions", "feedback": "Matching x terms are not enough for that answer. The constant terms have to match as well."},
   {"text": "x = -1", "feedback": "The 4x was cancelled on the right side only. What comes off one side has to come off both."},
   {"text": "The equation has no solution", "feedback": "Correct."},
   {"text": "x = 0", "feedback": "Substitute 0 into both sides and they do not match. Expand each side fully first."}]'::jsonb,
 2, 'sub-solve-linear'),

(9, 'MTH1W', 'Solving equations', 4, 32, 'Advanced',
 'Solve (1/4)(x - 3) = (1/3)(x - 2).',
 '[{"text": "x = -1", "feedback": "Correct."},
   {"text": "x = 6", "feedback": "The 12 was handed to the wrong sides. A quarter needs the 4 cleared, so that side gets multiplied by 3."},
   {"text": "x = -12", "feedback": "The brackets were multiplied out before the denominators were cleared, and a term was lost."},
   {"text": "x = 1", "feedback": "The constants were collected the wrong way round when they crossed sides."}]'::jsonb,
 0, 'sub-equations-fractions'),

(9, 'MTH1W', 'Solving equations', 4, 33, 'Advanced',
 'Solve (x - 5) / 3 = (x + 10) / 6.',
 '[{"text": "x = 20", "feedback": "Correct."},
   {"text": "x = 15", "feedback": "After multiplying by 6, the 2 in front of the left numerator reached only the x and not the 5."},
   {"text": "x = 5", "feedback": "The brackets were dropped during cross multiplication. The 6 multiplies the whole of x - 5."},
   {"text": "x = -25", "feedback": "The cross multiplication was paired the wrong way. The left numerator meets the RIGHT denominator."}]'::jsonb,
 0, 'sub-equations-fractions'),

(9, 'MTH1W', 'Solving equations', 4, 34, 'Advanced',
 'The volume of a sphere is 52 cm^3. What is its radius, to the nearest tenth of a cm? Use V = (4/3) x pi x r^3.',
 '[{"text": "2.3 cm", "feedback": "Correct."},
   {"text": "3.7 cm", "feedback": "That is the cube root of 52 on its own. The 4/3 and the pi both have to be cleared first."},
   {"text": "2.5 cm", "feedback": "The pi was divided out but the 4/3 was not. Multiply by 3/4 before dividing by pi."},
   {"text": "12.4 cm", "feedback": "That is the value of r cubed. There is still a cube root to take."}]'::jsonb,
 0, 'sub-quad-cubic'),

(9, 'MTH1W', 'Solving equations', 4, 35, 'Advanced',
 'The area of a trapezoid is A = (1/2)(a + b)h. Rearrange it to isolate b.',
 '[{"text": "b = (2A - a)/h", "feedback": "The a was taken off before the h was divided out. Clear the h first, while a and b are still bracketed together."},
   {"text": "b = 2A/h - a", "feedback": "Correct."},
   {"text": "b = 2A/h + a", "feedback": "The a is inside the bracket being added to b, so it moves across as a subtraction."},
   {"text": "b = A/(2h) - a", "feedback": "The half was divided rather than multiplied away. Multiply both sides by 2 to clear it."}]'::jsonb,
 1, 'sub-rearrange-formulas'),

(9, 'MTH1W', 'Solving equations', 4, 36, 'Advanced',
 'Rearrange d = 2 x sqrt(3.2h) to isolate h.',
 '[{"text": "h = d^2 / 6.4", "feedback": "The 2 was divided away after squaring rather than before. Squaring turns it into a 4."},
   {"text": "h = d^2 / 12.8", "feedback": "Correct."},
   {"text": "h = 3.2(d/2)^2", "feedback": "The 3.2 is multiplying h under the root, so it comes off by division, not multiplication."},
   {"text": "h = d^2 / 3.2", "feedback": "The 2 out front was never divided away before both sides were squared."}]'::jsonb,
 1, 'sub-rearrange-formulas'),

(9, 'MTH1W', 'Solving equations', 4, 37, 'Advanced',
 'Boarding house A charges 90 dollars plus 5 dollars per day. Boarding house B charges 100 dollars plus 4 dollars per day. For how many days is A cheaper than B?',
 '[{"text": "More than ten days", "feedback": "A charges more per day, so its advantage shrinks as the stay gets longer, not the other way round."},
   {"text": "Fewer than ten days", "feedback": "Correct."},
   {"text": "Fewer than 190 days", "feedback": "The 90 kept its sign when it crossed the inequality."},
   {"text": "Exactly ten days", "feedback": "At that point the two are equal, so neither is cheaper. The question asks when A costs less."}]'::jsonb,
 1, 'sub-inequalities'),

(9, 'MTH1W', 'Solving equations', 4, 38, 'Advanced',
 'Solve 2 <= x - 6 and write the answer in interval notation.',
 '[{"text": "(-infinity, 8]", "feedback": "The inequality was read backwards. Here x is at least 8, not at most 8."},
   {"text": "(8, infinity)", "feedback": "The round bracket says 8 is excluded, but this inequality allows equality."},
   {"text": "[8, infinity)", "feedback": "Correct."},
   {"text": "[8, infinity]", "feedback": "Infinity is never reached, so it always takes a round bracket."}]'::jsonb,
 2, 'sub-inequalities'),

(9, 'MTH1W', 'Solving equations', 4, 39, 'Advanced',
 'Sidney makes twice as much per week as Evgeni. Jensen makes 200 dollars a week more than Sidney. The total weekly payroll is 1450 dollars. How much does Sidney make?',
 '[{"text": "580 dollars", "feedback": "The 200 dollars was left in the total and shared out, instead of belonging only to Jensen."},
   {"text": "250 dollars", "feedback": "That is what Evgeni makes. Sidney makes twice as much."},
   {"text": "700 dollars", "feedback": "That is what Jensen makes. Sidney makes 200 dollars less than that."},
   {"text": "500 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-word-equations'),

(9, 'MTH1W', 'Solving equations', 4, 40, 'Advanced',
 'Max cycles 13 km/h faster than Rory runs. Max covers 46 km in the same time it takes Rory to run 23 km. How fast does Rory run?',
 '[{"text": "13 km/h", "feedback": "Correct."},
   {"text": "26 km/h", "feedback": "That is the cycling speed. The question asks for the running speed, which is the slower of the two."},
   {"text": "23 km/h", "feedback": "That is the distance Rory covers, not a speed. Set the two times equal and solve."},
   {"text": "6.5 km/h", "feedback": "That halved the 13. Set 46 over the faster speed equal to 23 over the slower one."}]'::jsonb,
 0, 'sub-word-equations');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Solving equations'
group by difficulty order by min(sort_order);
