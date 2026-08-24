-- ===========================================================================
-- ASTRO MATH ASSIST — Grade 9 — MTH1W, Mathematics (de-streamed)
-- ===========================================================================
--
-- 360 questions, 0 figures.
--
-- One course, safe to run on its own, in any order relative to the other
-- courses. Run it AFTER astro_math_assist_setup.sql has created the schema.
--
-- This is the per-unit files concatenated:
-- every unit file opens with a delete for its own unit, and that delete takes
-- the figure reference with the row, so a figure file that ran first would
-- leave the course imageless.
--
-- Student attempts key on course, unit and sort_order rather than on question
-- ids, so re-running this keeps the history of every student.
-- ===========================================================================


-- --- questions_mth1w_u1.sql ---

-- ===========================================================================
-- MTH1W — Unit 1: Number Sense — 40 questions
-- ===========================================================================
-- Grade 9 de-streamed mathematics, authored from the Jensen MTH1W lesson
-- solutions for this unit:
--
--   Lesson 1  Integers
--   Lesson 2  Fractions
--   Lesson 3  Ratios, rates and proportions
--   Lesson 4  Number sets
--   Lesson 5  Density, infinity and limits
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake, taken from the worked solutions — the sign that gets dropped, the
-- step that gets skipped, the rule from the previous lesson applied to this
-- one. Feedback names that mistake and stops there.
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
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Number sense';

insert into misconception_labels (tag, label) values
  ('sub-integers',        'Integers'),
  ('sub-fractions',       'Fractions'),
  ('sub-ratios-rates',    'Ratios, rates and proportions'),
  ('sub-number-sets',     'Number sets'),
  ('sub-density-limits',  'Density and limits')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Number sense', 1, 1, 'Easy',
 'Which of these is NOT an integer?',
 '[{"text": "13", "feedback": "Positive whole numbers are integers. Look for the one that is not whole."},
   {"text": "-7", "feedback": "Negative whole numbers are integers. Look for the one that is not whole."},
   {"text": "0", "feedback": "Zero is an integer. Look for the one that is not a whole number."},
   {"text": "2.5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 2, 'Easy',
 'Evaluate: -5 + 2',
 '[{"text": "3", "feedback": "The sign is wrong. Starting at -5 and moving 2 to the right does not reach the positive side."},
   {"text": "-3", "feedback": "Correct."},
   {"text": "-7", "feedback": "Adding a positive moves RIGHT along the number line, not further left."},
   {"text": "7", "feedback": "That adds the two sizes and ignores the negative sign on the first number."}]'::jsonb,
 1, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 3, 'Easy',
 'Evaluate: 15 - (-6)',
 '[{"text": "9", "feedback": "Subtracting a negative is not the same as subtracting a positive. Add the opposite."},
   {"text": "21", "feedback": "Correct."},
   {"text": "-21", "feedback": "The sign is wrong. Both numbers here pull the answer above 15, not below zero."},
   {"text": "-9", "feedback": "Two mistakes at once: the double negative was not resolved, and the sign was flipped."}]'::jsonb,
 1, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 4, 'Easy',
 'A bag holds circles and squares in the ratio 2 : 4. How many parts does that ratio have in total?',
 '[{"text": "6", "feedback": "Correct."},
   {"text": "8", "feedback": "That multiplied the two parts. A total is found by adding them."},
   {"text": "2", "feedback": "That is one part of the ratio only. The total counts both parts."},
   {"text": "4", "feedback": "That is the other part on its own. Add the two together."}]'::jsonb,
 0, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 5, 'Easy',
 'Convert the mixed number 3 and 2/5 to an improper fraction.',
 '[{"text": "17/5", "feedback": "Correct."},
   {"text": "32/5", "feedback": "That writes the digits side by side rather than doing the arithmetic."},
   {"text": "5/5", "feedback": "That adds the whole number to the numerator. The whole number has to be multiplied by the denominator first."},
   {"text": "6/5", "feedback": "That multiplies the whole number by the NUMERATOR. It is the denominator that says how many parts make one whole."}]'::jsonb,
 0, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 6, 'Easy',
 'Simplify the fraction 15/20 to lowest terms.',
 '[{"text": "5/10", "feedback": "That subtracted 10 from each part. Simplifying divides, it does not subtract."},
   {"text": "5/20", "feedback": "That divided the top by 3 and left the bottom untouched. A factor has to come out of both parts at once."},
   {"text": "1/5", "feedback": "That divided the top and bottom by different numbers. Both must be divided by the same one."},
   {"text": "3/4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 7, 'Easy',
 'Evaluate: 2/3 x 5/7',
 '[{"text": "10/21", "feedback": "Correct."},
   {"text": "14/15", "feedback": "That multiplied each numerator by the other denominator. Multiplying fractions goes straight across."},
   {"text": "7/10", "feedback": "That added the tops and added the bottoms, which is not how any fraction operation works."},
   {"text": "10/10", "feedback": "The numerators multiplied correctly, but the denominators did not."}]'::jsonb,
 0, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 8, 'Easy',
 'Which set contains 0 but NOT any negative numbers?',
 '[{"text": "Whole numbers", "feedback": "Correct."},
   {"text": "Integers", "feedback": "Integers do include zero, but they also run in the negative direction."},
   {"text": "Rational numbers", "feedback": "Rationals include zero, but they include far more than this question allows."},
   {"text": "Natural numbers", "feedback": "The natural numbers are the counting numbers, and counting starts at 1."}]'::jsonb,
 0, 'sub-number-sets'),

(9, 'MTH1W', 'Number sense', 1, 9, 'Easy',
 'Which of these numbers is IRRATIONAL?',
 '[{"text": "4", "feedback": "Any integer can be written over 1, which makes it a fraction of two integers."},
   {"text": "0.125", "feedback": "This decimal stops. A decimal that terminates can always be written as a fraction."},
   {"text": "-9/2", "feedback": "This is already written as a fraction of two integers."},
   {"text": "the square root of 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-number-sets'),

(9, 'MTH1W', 'Number sense', 1, 10, 'Easy',
 'A set is DENSE when:',
 '[{"text": "all its elements are close to zero", "feedback": "Density is about the spacing between elements, not about where they sit."},
   {"text": "it has a largest and a smallest element", "feedback": "That describes a bounded set. Density says nothing about the ends."},
   {"text": "it has infinitely many elements", "feedback": "The integers are infinite too, and they are not dense. Density is about gaps, not about size."},
   {"text": "between any two of its numbers there is always another one from the same set", "feedback": "Correct."}]'::jsonb,
 3, 'sub-density-limits'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Number sense', 1, 11, 'Medium',
 'Evaluate: -6 x (-4) + 3',
 '[{"text": "-27", "feedback": "The arithmetic is right but the sign is not. Two negatives multiplied do not stay negative."},
   {"text": "42", "feedback": "That did the addition before the multiplication and dropped both minus signs on the way."},
   {"text": "27", "feedback": "Correct."},
   {"text": "-21", "feedback": "The product of two negatives is positive. That treated it as negative."}]'::jsonb,
 2, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 12, 'Medium',
 'Evaluate: 20 divided by (-4) - 3',
 '[{"text": "-2", "feedback": "The 3 was added at the end instead of taken away."},
   {"text": "8", "feedback": "Two mistakes: the sign of the quotient, and then subtracting in the wrong direction."},
   {"text": "-8", "feedback": "Correct."},
   {"text": "-20/7", "feedback": "That divided 20 by the whole expression -4 - 3 instead of dividing first."}]'::jsonb,
 2, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 13, 'Medium',
 'Evaluate: 2/3 divided by 5/4',
 '[{"text": "8/15", "feedback": "Correct."},
   {"text": "15/8", "feedback": "That flipped the FIRST fraction. Keep the first, flip the second."},
   {"text": "6/5", "feedback": "Both fractions were turned over. Only one of them is flipped when you divide."},
   {"text": "10/12", "feedback": "That multiplied straight across without flipping. Division needs the reciprocal first."}]'::jsonb,
 0, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 14, 'Medium',
 'Evaluate: 2/5 + 3/10',
 '[{"text": "6/50", "feedback": "That multiplied the fractions instead of adding them."},
   {"text": "5/15", "feedback": "That added the tops and added the bottoms. Only the numerators are added, once the denominators match."},
   {"text": "7/10", "feedback": "Correct."},
   {"text": "5/10", "feedback": "The denominators were matched correctly, but the first numerator was not rescaled with it."}]'::jsonb,
 2, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 15, 'Medium',
 'Convert the improper fraction 11/3 to a mixed number.',
 '[{"text": "3 and 2/3", "feedback": "Correct."},
   {"text": "3 and 1/3", "feedback": "The whole number part is right. Check what is actually left over after taking those wholes away."},
   {"text": "4 and 1/3", "feedback": "That went one group of 3 too far and then used the overshoot as the leftover."},
   {"text": "3 and 2/11", "feedback": "The denominator does not change when you convert. Only the numerator does."}]'::jsonb,
 0, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 16, 'Medium',
 'Simplify the ratio 18 : 24',
 '[{"text": "4 : 3", "feedback": "The numbers are right but the order is not. A ratio has to keep the order it was given in."},
   {"text": "12 : 18", "feedback": "That took the same amount away from each part. Ratios simplify by division, not by subtraction."},
   {"text": "3 : 4", "feedback": "Correct."},
   {"text": "1 : 6", "feedback": "That divided the two parts by different numbers. Both parts have to be divided by the same one."}]'::jsonb,
 2, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 17, 'Medium',
 'A shop sells 4 chocolate bars for 10 dollars. What is the unit rate?',
 '[{"text": "0.40 dollars per bar", "feedback": "That divided the number of bars by the price. A cost per bar puts the money on top."},
   {"text": "2.50 dollars per bar", "feedback": "Correct."},
   {"text": "14 dollars per bar", "feedback": "That added the two numbers. A rate compares them by division."},
   {"text": "40 dollars per bar", "feedback": "That multiplied. A unit rate is what ONE bar costs, so it must be less than the total."}]'::jsonb,
 1, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 18, 'Medium',
 'Convert 58 percent to a decimal.',
 '[{"text": "5800", "feedback": "That multiplied by 100. Going from percent to decimal divides by 100."},
   {"text": "0.058", "feedback": "The decimal moved three places instead of two."},
   {"text": "5.8", "feedback": "The decimal moved one place. Percent means out of 100, so it moves two."},
   {"text": "0.58", "feedback": "Correct."}]'::jsonb,
 3, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 19, 'Medium',
 'Which subsets does the number 0 belong to?',
 '[{"text": "Natural, whole, integer and rational", "feedback": "One of these starts counting at 1, so zero is not in it."},
   {"text": "Whole, integer and rational", "feedback": "Correct."},
   {"text": "Integer and rational only", "feedback": "That ruled a set out too soon. Test zero against the definition of each set before leaving it off the list."},
   {"text": "Rational only", "feedback": "Zero sits in more of these sets than this. Check what each definition actually allows in."}]'::jsonb,
 1, 'sub-number-sets'),

(9, 'MTH1W', 'Number sense', 1, 20, 'Medium',
 'How many elements are in the set of WHOLE numbers between 5 and 10?',
 '[{"text": "Infinitely many", "feedback": "That is true for the rationals in this range, but whole numbers have gaps between them."},
   {"text": "4", "feedback": "Correct."},
   {"text": "6", "feedback": "That counted 5 and 10 themselves. Between means strictly inside."},
   {"text": "5", "feedback": "One of the two endpoints was counted. Between excludes both."}]'::jsonb,
 1, 'sub-density-limits'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): multi-step, word problems, choosing the method.
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Number sense', 1, 21, 'Challenge',
 'The temperature at 6 pm was 4 degrees. Overnight it fell 11 degrees, then rose 3 degrees by morning. What was the morning temperature?',
 '[{"text": "-10 degrees", "feedback": "The fall was handled correctly but the rise was subtracted as well. A rise moves back up."},
   {"text": "4 degrees", "feedback": "That treated the fall and the rise as cancelling out. They are different sizes."},
   {"text": "-4 degrees", "feedback": "Correct."},
   {"text": "18 degrees", "feedback": "That added the fall instead of subtracting it. A fall moves down the number line."}]'::jsonb,
 2, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 22, 'Challenge',
 'A diver is 12 m below sea level. She descends until she is 3 times as deep. What is her new depth, written as an integer?',
 '[{"text": "-4 m", "feedback": "That divided by 3. Going three times as deep makes the number further from zero, not closer."},
   {"text": "36 m", "feedback": "The size is right but the sign is not. Below sea level stays negative."},
   {"text": "-15 m", "feedback": "That went 3 metres deeper rather than to 3 times the depth."},
   {"text": "-36 m", "feedback": "Correct."}]'::jsonb,
 3, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 23, 'Challenge',
 'A recipe uses 3 cups of flour to 2 eggs. You have only 1 egg. How much flour do you need?',
 '[{"text": "3 cups", "feedback": "The flour has to change too — the ratio between them must stay the same."},
   {"text": "6 cups", "feedback": "That doubled instead of halved. Fewer eggs means less flour, not more."},
   {"text": "1.5 cups", "feedback": "Correct."},
   {"text": "2 cups", "feedback": "That subtracted 1 from the flour instead of scaling it. Halving the eggs halves everything."}]'::jsonb,
 2, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 24, 'Challenge',
 'Which is the better buy: 8.49 dollars for 0.45 kg, or 34.81 dollars for 2.14 kg?',
 '[{"text": "The 34.81 dollar option", "feedback": "Correct."},
   {"text": "They cost the same per kilogram", "feedback": "Work out the cost per kilogram for each — they are more than two dollars apart."},
   {"text": "There is not enough information", "feedback": "There is: a price and a mass for each. That is all a unit rate needs."},
   {"text": "The 8.49 dollar option, because it costs less in total", "feedback": "A smaller total price buys a smaller amount. Compare what one kilogram costs in each."}]'::jsonb,
 0, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 25, 'Challenge',
 'Callum types 100 words in 4 minutes. At that rate, how many words does he type in 10 minutes?',
 '[{"text": "40 words", "feedback": "That divided when it should have multiplied. More time means more words."},
   {"text": "250 words", "feedback": "Correct."},
   {"text": "106 words", "feedback": "That added the extra 6 minutes as 6 words. Find the rate per minute first."},
   {"text": "400 words", "feedback": "That multiplied 100 by 4. The 4 minutes is what the 100 words already took."}]'::jsonb,
 1, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 26, 'Challenge',
 'There are 60 shapes in a ratio of 1 circle to 2 squares. How many circles are there?',
 '[{"text": "30", "feedback": "That split the 60 into two equal halves. A ratio of 1 to 2 is not an even split."},
   {"text": "20", "feedback": "Correct."},
   {"text": "15", "feedback": "That divided by 4. Count how many parts the ratio actually has in total."},
   {"text": "40", "feedback": "That is the other part of the ratio. The question asks for the smaller share."}]'::jsonb,
 1, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 27, 'Challenge',
 'Which list puts the number sets in order so that each one is completely contained inside the next?',
 '[{"text": "Natural, whole, integer, rational", "feedback": "Correct."},
   {"text": "Whole, natural, integer, rational", "feedback": "The first two are the wrong way round. Adding zero to the counting numbers makes the larger set, not the smaller one."},
   {"text": "Integer, whole, natural, rational", "feedback": "The integers already contain both of the sets listed after them."},
   {"text": "Rational, integer, whole, natural", "feedback": "The rationals already contain every set listed after them. The list has to start with the smallest set."}]'::jsonb,
 0, 'sub-number-sets'),

(9, 'MTH1W', 'Number sense', 1, 28, 'Challenge',
 'Evaluate: 7/12 + 5/8',
 '[{"text": "29/96", "feedback": "The numerators were rescaled correctly, but the denominator was multiplied out instead of matched."},
   {"text": "35/96", "feedback": "That multiplied the two fractions instead of adding them."},
   {"text": "12/20", "feedback": "That added the tops and the bottoms. The denominators have to be made equal first."},
   {"text": "29/24", "feedback": "Correct."}]'::jsonb,
 3, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 29, 'Challenge',
 'The set of RATIONAL numbers between 5 and 10 contains how many elements?',
 '[{"text": "Infinitely many", "feedback": "Correct."},
   {"text": "5", "feedback": "That counts a few obvious values. Between any two of them there is always another."},
   {"text": "It cannot be determined", "feedback": "It can. Ask whether a number always exists between any two you name."},
   {"text": "4", "feedback": "That is the count of whole numbers in that range. Rationals include everything in between them."}]'::jsonb,
 0, 'sub-density-limits'),

(9, 'MTH1W', 'Number sense', 1, 30, 'Challenge',
 'What is the limit of the set of WHOLE numbers as the values decrease?',
 '[{"text": "0", "feedback": "Correct."},
   {"text": "1", "feedback": "That is where the NATURAL numbers stop. The whole numbers include one more value below it."},
   {"text": "There is no limit", "feedback": "Decreasing whole numbers do run out — they cannot go below their smallest member."},
   {"text": "Negative infinity", "feedback": "That is the answer for the integers. The whole numbers stop somewhere the integers do not."}]'::jsonb,
 0, 'sub-density-limits'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): parameters, combined subtopics, the questions that
-- separate 90s from 70s.
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Number sense', 1, 31, 'Advanced',
 'A submarine sits at -80 m. It rises 25 m, then descends twice the distance it rose. What is its final depth?',
 '[{"text": "-5 m", "feedback": "That treated both moves as upward. Only the first one is a rise."},
   {"text": "-55 m", "feedback": "That stopped after the rise. There is still a descent to apply."},
   {"text": "-105 m", "feedback": "Correct."},
   {"text": "-130 m", "feedback": "That descended from the starting depth. The rise happens first."}]'::jsonb,
 2, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 32, 'Advanced',
 'A student writes: -3 squared equals 9. Their teacher marks it wrong. Why?',
 '[{"text": "The answer should be -6, for the same reason", "feedback": "Two mistakes: squaring is not doubling, and the sign handling is separate."},
   {"text": "Nothing is wrong; the teacher made a mistake", "feedback": "Brackets matter here. Consider what the exponent is actually attached to."},
   {"text": "The answer should be -9, because without brackets only the 3 is squared", "feedback": "Correct."},
   {"text": "The answer should be 6, because squaring means doubling", "feedback": "Squaring means multiplying a number by itself, not adding it to itself."}]'::jsonb,
 2, 'sub-integers'),

(9, 'MTH1W', 'Number sense', 1, 33, 'Advanced',
 'Express 5/4 as a multiple of a unit fraction.',
 '[{"text": "4 lots of 1/5", "feedback": "The numerator and denominator have been swapped. The unit fraction keeps the original denominator."},
   {"text": "5 lots of 1/4", "feedback": "Correct."},
   {"text": "1 lot of 5/4", "feedback": "A unit fraction has 1 on top. This is just the original fraction restated."},
   {"text": "5 lots of 1/5", "feedback": "That would come to 1, which is less than the fraction given."}]'::jsonb,
 1, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 34, 'Advanced',
 'Evaluate: 5/6 divided by 4/3, simplified fully.',
 '[{"text": "20/18", "feedback": "That multiplied straight across without taking the reciprocal."},
   {"text": "8/5", "feedback": "That flipped the first fraction instead of the second."},
   {"text": "9/10", "feedback": "Both fractions were turned over. Only the second one gets flipped."},
   {"text": "5/8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-fractions'),

(9, 'MTH1W', 'Number sense', 1, 35, 'Advanced',
 'A 1.8 m tall person casts a 2.4 m shadow. At the same moment a tree casts a 14 m shadow. How tall is the tree?',
 '[{"text": "25.2 m", "feedback": "That multiplied the height by the whole shadow length, skipping the ratio."},
   {"text": "10.5 m", "feedback": "Correct."},
   {"text": "18.7 m", "feedback": "That multiplied by the shadow ratio the wrong way round. The tree is taller than its shadow only if the person is too."},
   {"text": "13.4 m", "feedback": "That subtracted rather than scaled. The two triangles are related by multiplication."}]'::jsonb,
 1, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 36, 'Advanced',
 'A jacket costs 80 dollars. Its price rises 25 percent, then falls 25 percent. What is the final price?',
 '[{"text": "80 dollars", "feedback": "The two percentages are taken from different amounts, so they do not cancel."},
   {"text": "75 dollars", "feedback": "Correct."},
   {"text": "85 dollars", "feedback": "That worked the rise out from the raised price and the fall from the original. Each percentage is taken from the price in force at the time."},
   {"text": "100 dollars", "feedback": "That applied only the rise. The fall happens afterwards."}]'::jsonb,
 1, 'sub-ratios-rates'),

(9, 'MTH1W', 'Number sense', 1, 37, 'Advanced',
 'How many subsets does a set with 5 elements have?',
 '[{"text": "10", "feedback": "That doubled the number of elements. The rule uses the count as an exponent, not a multiplier."},
   {"text": "25", "feedback": "That squared the number of elements. The base and the exponent are the other way round."},
   {"text": "32", "feedback": "Correct."},
   {"text": "5", "feedback": "That counts only the single-element subsets, and forgets the empty set and the larger ones."}]'::jsonb,
 2, 'sub-density-limits'),

(9, 'MTH1W', 'Number sense', 1, 38, 'Advanced',
 'A student claims every square root is irrational. Which number proves them wrong?',
 '[{"text": "pi", "feedback": "Pi is irrational, and it is not a square root either."},
   {"text": "the square root of 2", "feedback": "This one is genuinely irrational, so it supports the claim rather than disproving it."},
   {"text": "the square root of 3", "feedback": "This one is irrational too. Look for a root that comes out exactly."},
   {"text": "the square root of 16", "feedback": "Correct."}]'::jsonb,
 3, 'sub-number-sets'),

(9, 'MTH1W', 'Number sense', 1, 39, 'Advanced',
 'What is the limit of the values in the sequence 1/3, 1/9, 1/27, ... as the terms continue?',
 '[{"text": "Infinity", "feedback": "The terms are shrinking, not growing. Check which direction they move."},
   {"text": "There is no limit, because the sequence never ends", "feedback": "An endless sequence can still settle on a value. Endless and unbounded are different things."},
   {"text": "0", "feedback": "Correct."},
   {"text": "1/3", "feedback": "That is the first term. The limit is what the terms head towards, not where they start."}]'::jsonb,
 2, 'sub-density-limits'),

(9, 'MTH1W', 'Number sense', 1, 40, 'Advanced',
 'The triangular numbers begin 1, 3, 6, 10, 15, ... What is the 10th triangular number?',
 '[{"text": "50", "feedback": "That added 5 to the 9th term. Each step adds the term number itself."},
   {"text": "100", "feedback": "That squared the term number. The rule multiplies by the NEXT number and then halves."},
   {"text": "45", "feedback": "That is the 9th. One more step is needed."},
   {"text": "55", "feedback": "Correct."}]'::jsonb,
 3, 'sub-integers');

-- ---------------------------------------------------------------------------
-- Check it loaded
-- ---------------------------------------------------------------------------

select difficulty, count(*) as questions,
       count(misconception_tag) as tagged
from questions
where course_code = 'MTH1W' and unit = 'Number sense'
group by difficulty
order by min(sort_order);

-- --- questions_mth1w_u2.sql ---

-- ===========================================================================
-- MTH1W — Unit 2: Powers — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Powers and scientific notation
--   Lesson 2  Product, quotient and power of a power rules
--   Lesson 3  Power of a product and power of a quotient
--   Lesson 4  Negative exponents
--
-- The distractors are the mistakes the worked solutions themselves point at:
-- multiplying the base by the exponent instead of repeating it, losing the
-- brackets that decide whether -3^4 is negative, adding exponents where the
-- rule multiplies them, and — the one this unit is really about — forgetting
-- that the exponent on a product lands on the COEFFICIENT as well as the
-- variable.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Powers';

insert into misconception_labels (tag, label) values
  ('sub-powers-basics',       'Powers and exponent form'),
  ('sub-scientific-notation', 'Scientific notation'),
  ('sub-exponent-laws',       'Product, quotient and power laws'),
  ('sub-power-of-product',    'Power of a product or quotient'),
  ('sub-negative-exponents',  'Negative exponents')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 1, 'Easy',
 'Write 3 x 3 x 3 x 3 as a power.',
 '[{"text": "3^3", "feedback": "That counted the multiplication signs. Count the factors themselves."},
   {"text": "3^4", "feedback": "Correct."},
   {"text": "4^3", "feedback": "The base and the exponent have been swapped. The base is the number being repeated."},
   {"text": "12", "feedback": "That multiplied the base by how many times it appears. A power repeats the multiplication instead."}]'::jsonb,
 1, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 2, 'Easy',
 'Evaluate 4^3.',
 '[{"text": "64", "feedback": "Correct."},
   {"text": "43", "feedback": "That wrote the two digits side by side rather than working the power out."},
   {"text": "16", "feedback": "That used an exponent of 2. Check how many factors of 4 the exponent asks for."},
   {"text": "12", "feedback": "That multiplied the base by the exponent. The exponent says how many times to multiply the base by ITSELF."}]'::jsonb,
 0, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 3, 'Easy',
 'Which of these is written correctly in scientific notation?',
 '[{"text": "4.5 x 9^3", "feedback": "Scientific notation always uses a power of ten, whatever the number."},
   {"text": "45 x 10^2", "feedback": "The number in front has to be at least 1 and less than 10. This one is too large."},
   {"text": "0.45 x 10^4", "feedback": "The number in front has to be at least 1. This one is too small."},
   {"text": "4.5 x 10^3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 4, 'Easy',
 'Write 3.2 x 10^4 in standard form.',
 '[{"text": "3 200", "feedback": "The decimal moved three places. The exponent says how many."},
   {"text": "320 000", "feedback": "The decimal moved five places, one too many."},
   {"text": "0.00032", "feedback": "That moved the decimal LEFT. A positive exponent moves it right."},
   {"text": "32 000", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 5, 'Easy',
 'Simplify 2^3 x 2^4 as a single power.',
 '[{"text": "2^1", "feedback": "That subtracted the exponents, which is the rule for dividing, not multiplying."},
   {"text": "2^12", "feedback": "That multiplied the exponents. Multiplying powers of the same base adds them."},
   {"text": "4^7", "feedback": "The exponents were handled correctly, but the bases were multiplied as well. The base stays as it is."},
   {"text": "2^7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 6, 'Easy',
 'What is the value of 7^0?',
 '[{"text": "0", "feedback": "An exponent of zero does not make the whole power zero. Follow the pattern down from 7^2, 7^1."},
   {"text": "7", "feedback": "That is 7^1. Take one more step down the pattern."},
   {"text": "1", "feedback": "Correct."},
   {"text": "Undefined", "feedback": "Only 0^0 is undefined. This base is not zero."}]'::jsonb,
 2, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 7, 'Easy',
 'Simplify (xy)^3.',
 '[{"text": "x^3y^3", "feedback": "Correct."},
   {"text": "x^3y", "feedback": "The exponent only reached the first factor. Both are inside the brackets."},
   {"text": "3xy", "feedback": "That multiplied by 3. The exponent repeats the whole bracket, it does not multiply it."},
   {"text": "xy^3", "feedback": "The exponent only reached one of the two factors. Everything inside the brackets is being cubed."}]'::jsonb,
 0, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 8, 'Easy',
 'Evaluate (2/3)^2.',
 '[{"text": "4/3", "feedback": "Only the numerator was squared. The exponent applies to the bottom as well."},
   {"text": "4/6", "feedback": "The top was squared but the bottom was only doubled."},
   {"text": "4/9", "feedback": "Correct."},
   {"text": "2/9", "feedback": "Only the denominator was squared. The exponent applies to the top as well."}]'::jsonb,
 2, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 9, 'Easy',
 'Evaluate 5^-2.',
 '[{"text": "-1/25", "feedback": "The reciprocal is right, but the minus sign should not survive the move."},
   {"text": "1/25", "feedback": "Correct."},
   {"text": "1/10", "feedback": "That multiplied the base by the exponent before taking the reciprocal."},
   {"text": "-25", "feedback": "A negative exponent does not make the answer negative. It moves the power to the bottom of a fraction."}]'::jsonb,
 1, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 10, 'Easy',
 'The negative exponent rule says a^-3 is equal to:',
 '[{"text": "-a^3", "feedback": "The minus sign does not move onto the front of the power. It signals a reciprocal."},
   {"text": "-3a", "feedback": "That multiplied the base by the exponent. The exponent still means repeated multiplication."},
   {"text": "a^3", "feedback": "The sign was simply dropped. It has a meaning that has to be honoured."},
   {"text": "1/a^3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-negative-exponents'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 11, 'Medium',
 'Evaluate (-2)^4.',
 '[{"text": "8", "feedback": "That multiplied the base by the exponent, and dropped the sign along the way."},
   {"text": "-16", "feedback": "A negative base does not always give a negative answer. Count how many negative factors there are."},
   {"text": "16", "feedback": "Correct."},
   {"text": "-8", "feedback": "That used an exponent of 3. Check how many factors the exponent asks for."}]'::jsonb,
 2, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 12, 'Medium',
 'Evaluate -3^4.',
 '[{"text": "12", "feedback": "Two mistakes: the base was multiplied by the exponent, and the sign was dropped."},
   {"text": "81", "feedback": "That treated the expression as if the minus sign were inside brackets with the 3. It is not."},
   {"text": "-81", "feedback": "Correct."},
   {"text": "-12", "feedback": "That multiplied the base by the exponent instead of repeating it."}]'::jsonb,
 2, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 13, 'Medium',
 'Write 0.00047 in scientific notation.',
 '[{"text": "47 x 10^-5", "feedback": "The power of ten is consistent, but the number in front must be at least 1 and less than 10."},
   {"text": "4.7 x 10^-3", "feedback": "The decimal was counted one place short. Count every place it has to move."},
   {"text": "4.7 x 10^-4", "feedback": "Correct."},
   {"text": "4.7 x 10^4", "feedback": "The exponent has the wrong sign. A number smaller than 1 needs a negative power of ten."}]'::jsonb,
 2, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 14, 'Medium',
 'Write 947 000 000 in scientific notation.',
 '[{"text": "9.47 x 10^8", "feedback": "Correct."},
   {"text": "9.47 x 10^-8", "feedback": "The sign is wrong. A number larger than 1 needs a positive power of ten."},
   {"text": "9.47 x 10^7", "feedback": "One place short. Count the places the decimal moves from the end of the number."},
   {"text": "947 x 10^6", "feedback": "The power of ten works, but the number in front has to be less than 10."}]'::jsonb,
 0, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 15, 'Medium',
 'Simplify 8^7 divided by 8^5, then evaluate.',
 '[{"text": "8^12", "feedback": "That added the exponents. Dividing powers of the same base subtracts them."},
   {"text": "1", "feedback": "That cancelled the exponents completely. Subtracting them does not always leave zero."},
   {"text": "8^35", "feedback": "That multiplied the exponents, which is the rule for a power of a power."},
   {"text": "64", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 16, 'Medium',
 'Simplify (3^2)^4 as a single power.',
 '[{"text": "3^16", "feedback": "That raised the inner exponent to the outer one instead of multiplying the two."},
   {"text": "6^4", "feedback": "That multiplied the base by the inner exponent instead of repeating it, then applied the outer exponent."},
   {"text": "3^6", "feedback": "That added the exponents. A power raised to a power multiplies them."},
   {"text": "3^8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 17, 'Medium',
 'Simplify (3x^2)^4.',
 '[{"text": "81x^8", "feedback": "Correct."},
   {"text": "81x^6", "feedback": "The coefficient is right, but the exponents on x were added instead of multiplied."},
   {"text": "3x^8", "feedback": "The variable was handled correctly, but the coefficient is inside the brackets too."},
   {"text": "12x^8", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."}]'::jsonb,
 0, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 18, 'Medium',
 'Simplify (x^2 / y^3)^4.',
 '[{"text": "x^2 / y^12", "feedback": "The exponent only reached the denominator. It applies to the numerator as well."},
   {"text": "x^8 / y^12", "feedback": "Correct."},
   {"text": "x^8 / y^3", "feedback": "The exponent only reached the numerator. It applies to the denominator as well."},
   {"text": "x^6 / y^7", "feedback": "The exponents were added. A power of a power multiplies them."}]'::jsonb,
 1, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 19, 'Medium',
 'Simplify x^5 / x^9, writing the answer without a negative exponent.',
 '[{"text": "x^4", "feedback": "The exponents were subtracted the other way round. Take the bottom from the top."},
   {"text": "1 / x^14", "feedback": "That added the exponents. Dividing subtracts them."},
   {"text": "1 / x^4", "feedback": "Correct."},
   {"text": "x^45", "feedback": "That multiplied the exponents, which is the rule for a power of a power."}]'::jsonb,
 2, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 20, 'Medium',
 'Evaluate (3/4)^-2.',
 '[{"text": "6/8", "feedback": "That multiplied top and bottom by 2 instead of squaring them."},
   {"text": "9/16", "feedback": "The fraction was squared but never flipped. A negative exponent on a fraction takes its reciprocal first."},
   {"text": "16/9", "feedback": "Correct."},
   {"text": "-16/9", "feedback": "The flip is right, but the minus sign should not survive it."}]'::jsonb,
 2, 'sub-negative-exponents'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 21, 'Challenge',
 'Evaluate 6x^2 when x = 5.',
 '[{"text": "150", "feedback": "Correct."},
   {"text": "30", "feedback": "That substituted but never applied the exponent."},
   {"text": "900", "feedback": "That multiplied 6 by 5 first and then squared the result. The exponent belongs to x alone."},
   {"text": "60", "feedback": "That multiplied 6 by 5 by 2. The 2 is an exponent, not a factor."}]'::jsonb,
 0, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 22, 'Challenge',
 'Evaluate 6x^2 - 2x - 24 when x = -6.',
 '[{"text": "252", "feedback": "The middle term was handled correctly but the constant was added instead of subtracted."},
   {"text": "204", "feedback": "Correct."},
   {"text": "180", "feedback": "The squared term is right, but the middle term lost its sign. Subtracting a negative adds."},
   {"text": "-228", "feedback": "The negative was not enclosed in brackets before squaring, so the first term came out negative."}]'::jsonb,
 1, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 23, 'Challenge',
 'Which of these numbers is the largest?',
 '[{"text": "8.7 x 10^3", "feedback": "This has the smallest power of ten of all four."},
   {"text": "5.0 x 10^4", "feedback": "Its power of ten is beaten by one of the others."},
   {"text": "9.9 x 10^4", "feedback": "This has the biggest number in front, but that is not what decides the size. Compare the powers of ten first."},
   {"text": "3.2 x 10^5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 24, 'Challenge',
 'Evaluate (2 x 10^3)(4 x 10^5), leaving the answer in scientific notation.',
 '[{"text": "6 x 10^8", "feedback": "The power of ten is right, but the numbers in front were added rather than multiplied."},
   {"text": "8 x 10^8", "feedback": "Correct."},
   {"text": "8 x 10^2", "feedback": "The exponents were subtracted, which is the rule for dividing."},
   {"text": "8 x 10^15", "feedback": "The exponents were multiplied. Multiplying powers of ten adds them."}]'::jsonb,
 1, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 25, 'Challenge',
 'Simplify (3^2 x 3^4)^3 as a single power.',
 '[{"text": "3^11", "feedback": "The two exponents inside the bracket were multiplied together and the outer one was then added on. Inside the bracket they are added."},
   {"text": "3^18", "feedback": "Correct."},
   {"text": "3^9", "feedback": "The bracket was simplified correctly, but the outer exponent was added rather than multiplied."},
   {"text": "3^24", "feedback": "That multiplied all three exponents together. Inside the bracket they are added first."}]'::jsonb,
 1, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 26, 'Challenge',
 'Simplify x^20 / (x^5 . x^6).',
 '[{"text": "x^14", "feedback": "Only the other factor was divided out. Both are on the bottom."},
   {"text": "x^9", "feedback": "Correct."},
   {"text": "x^11", "feedback": "That is the bottom combined. The division by the top still has to happen."},
   {"text": "x^15", "feedback": "Only one of the two factors on the bottom was divided out. Combine them first."}]'::jsonb,
 1, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 27, 'Challenge',
 'Simplify (-2x^4y^5)^2.',
 '[{"text": "-2x^8y^10", "feedback": "The variables were raised correctly, but the coefficient was left untouched."},
   {"text": "-4x^8y^10", "feedback": "Everything else is right, but an even exponent on a negative base does not leave it negative."},
   {"text": "4x^8y^10", "feedback": "Correct."},
   {"text": "4x^6y^7", "feedback": "The coefficient is right, but the exponents were added rather than multiplied."}]'::jsonb,
 2, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 28, 'Challenge',
 'Simplify (3a^2b)^5.',
 '[{"text": "15a^10b^5", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."},
   {"text": "243a^7b^5", "feedback": "The coefficient is right, but the exponents on a were added instead of multiplied."},
   {"text": "243a^10b^5", "feedback": "Correct."},
   {"text": "3a^10b^5", "feedback": "The variables are right, but the coefficient is inside the brackets and has to be raised too."}]'::jsonb,
 2, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 29, 'Challenge',
 'Simplify (2m^2)^-3, writing the answer without a negative exponent.',
 '[{"text": "1 / (8m^6)", "feedback": "Correct."},
   {"text": "1 / (6m^6)", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."},
   {"text": "-8m^6", "feedback": "The minus sign was moved to the front instead of signalling a reciprocal."},
   {"text": "1 / (2m^6)", "feedback": "The reciprocal and the variable are right, but the 2 is inside the brackets and must be cubed as well."}]'::jsonb,
 0, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 30, 'Challenge',
 'Simplify (x^7 / y^9)^-4, writing the answer without negative exponents.',
 '[{"text": "y^36 / x^28", "feedback": "Correct."},
   {"text": "y^13 / x^11", "feedback": "The flip is right, but the exponents were added rather than multiplied."},
   {"text": "1 / (x^28 y^9)", "feedback": "The outer power was applied to the numerator only. It reaches every factor inside the bracket, top and bottom."},
   {"text": "x^28 / y^36", "feedback": "The exponents were applied correctly, but the fraction was never flipped."}]'::jsonb,
 0, 'sub-negative-exponents'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 31, 'Advanced',
 'The zero exponent rule is written a^0 = 1, with the condition that a is not 0. Why is that condition needed?',
 '[{"text": "Because a negative base is not allowed in the rule", "feedback": "Negative bases are fine here. The restriction names one specific value."},
   {"text": "Because zero cannot be used as an exponent", "feedback": "Zero is exactly the exponent this rule is about. The restriction is on the base."},
   {"text": "Because 0^0 equals 0, which breaks the pattern", "feedback": "0^0 does not equal 0. Compare what the zero exponent rule says with what the pattern of powers of 0 says, and see whether they agree."},
   {"text": "Because 0^0 is undefined", "feedback": "Correct."}]'::jsonb,
 3, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 32, 'Advanced',
 'Evaluate (-2)^5.',
 '[{"text": "-32", "feedback": "Correct."},
   {"text": "-10", "feedback": "That multiplied the base by the exponent rather than repeating it."},
   {"text": "10", "feedback": "Two mistakes: the base was multiplied by the exponent, and the sign was dropped."},
   {"text": "32", "feedback": "The size is right but the sign is not. Count whether the number of negative factors is odd or even."}]'::jsonb,
 0, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 33, 'Advanced',
 'Evaluate (6 x 10^8) divided by (3 x 10^-2), leaving the answer in scientific notation.',
 '[{"text": "2 x 10^-16", "feedback": "The exponents were multiplied. Dividing powers of ten subtracts them."},
   {"text": "2 x 10^10", "feedback": "Correct."},
   {"text": "3 x 10^10", "feedback": "The power of ten is right, but the numbers in front were subtracted instead of divided."},
   {"text": "2 x 10^6", "feedback": "Subtracting a negative exponent adds. This went the other way."}]'::jsonb,
 1, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 34, 'Advanced',
 'Evaluate 3.5 x 10^4 + 2.1 x 10^5, leaving the answer in scientific notation.',
 '[{"text": "5.6 x 10^9", "feedback": "Adding does not combine the powers of ten. That is what multiplying does."},
   {"text": "2.45 x 10^5", "feedback": "Correct."},
   {"text": "2.45 x 10^4", "feedback": "The addition is right, but the answer was left on the smaller power of ten."},
   {"text": "5.6 x 10^5", "feedback": "The numbers in front were added without first putting both terms on the same power of ten."}]'::jsonb,
 1, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 35, 'Advanced',
 'Simplify (-4)^4 divided by (-4)^3.',
 '[{"text": "-4", "feedback": "Correct."},
   {"text": "(-4)^12", "feedback": "That multiplied the exponents. Dividing powers of the same base subtracts them."},
   {"text": "1", "feedback": "That cancelled the exponents to zero. Subtracting them leaves something behind here."},
   {"text": "4", "feedback": "The exponent arithmetic is right, but the sign of the base was dropped on the way out."}]'::jsonb,
 0, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 36, 'Advanced',
 'Use the quotient of powers rule to simplify 5^2 / 5^2.',
 '[{"text": "5", "feedback": "The exponents were subtracted to 1 rather than to 0. They are equal."},
   {"text": "25", "feedback": "That worked out the top and forgot to divide by the bottom."},
   {"text": "1", "feedback": "Correct."},
   {"text": "0", "feedback": "The exponents do subtract to zero, but a zero exponent does not make the whole power zero."}]'::jsonb,
 2, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 37, 'Advanced',
 'Simplify (-2uv^3)(8u^2v^2) divided by (4uv^2)^2.',
 '[{"text": "uv", "feedback": "Everything else is right, but the minus sign from the first bracket was lost."},
   {"text": "-16uv", "feedback": "The variables divided correctly, but the 4 in the bottom bracket was dropped instead of being squared."},
   {"text": "-16u^3v^5", "feedback": "That is the top simplified. The bottom still has to be squared and divided out."},
   {"text": "-uv", "feedback": "Correct."}]'::jsonb,
 3, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 38, 'Advanced',
 'Simplify (3m^3n)^2 divided by (2mn)(3m^2n).',
 '[{"text": "m^3 / 2", "feedback": "The 3 in the top bracket was not squared before dividing."},
   {"text": "3m^3 / 2", "feedback": "Correct."},
   {"text": "3m^9 / 2", "feedback": "The exponents on m were added rather than subtracted after the bracket was squared."},
   {"text": "3m^3", "feedback": "The variables are right, but the numbers do not divide evenly. Check 9 against 6."}]'::jsonb,
 1, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 39, 'Advanced',
 'Simplify (y/4)^-3, writing the answer without a negative exponent.',
 '[{"text": "12 / y^3", "feedback": "The flip is right, but the 4 was multiplied by 3 instead of cubed."},
   {"text": "-y^3 / 64", "feedback": "Neither the flip nor the sign was handled. A negative exponent means a reciprocal, not a minus."},
   {"text": "y^3 / 64", "feedback": "The cube is right, but the fraction was never flipped."},
   {"text": "64 / y^3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 40, 'Advanced',
 'Simplify (2x^-2)^3, writing the answer without a negative exponent.',
 '[{"text": "8 / x^6", "feedback": "Correct."},
   {"text": "2 / x^6", "feedback": "The variable is right, but the 2 is inside the brackets and has to be cubed as well."},
   {"text": "8x^6", "feedback": "The coefficient is right, but the negative on the exponent was dropped rather than turned into a reciprocal."},
   {"text": "6 / x^6", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."}]'::jsonb,
 0, 'sub-negative-exponents');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Powers'
group by difficulty order by min(sort_order);

-- --- questions_mth1w_u3.sql ---

-- ===========================================================================
-- MTH1W — Unit 3: Algebraic Expressions — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Communicate with algebra  (terms, coefficient, degree,
--             classifying polynomials, turning sentences into expressions)
--   Lesson 2  Collecting like terms
--   Lesson 3  Adding and subtracting polynomials
--   Lesson 4  Distributive property, distributing variables, nested
--             brackets, and multiplying binomials with FOIL
--
-- The distractors are the slips the worked solutions themselves keep
-- correcting: adding exponents when collecting like terms, distributing the
-- minus sign to only the first term inside a bracket, forgetting the inside
-- product in FOIL, and reading the degree of a polynomial off a single
-- exponent instead of the sum on the highest term.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Algebraic expressions';

insert into misconception_labels (tag, label) values
  ('sub-algebra-terms',     'Terms, degree and naming polynomials'),
  ('sub-like-terms',        'Collecting like terms'),
  ('sub-poly-add-sub',      'Adding and subtracting polynomials'),
  ('sub-distributive',      'Distributive property'),
  ('sub-binomial-product',  'Multiplying binomials')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 1, 'Easy',
 'The depth of a falling stone after t seconds is given by the term -4.9t^2. What is the coefficient of that term?',
 '[{"text": "-4.9", "feedback": "Correct."},
   {"text": "4.9", "feedback": "The minus sign belongs to the coefficient. It is not separate from it."},
   {"text": "t^2", "feedback": "That is the variable part. The coefficient is the number multiplying it."},
   {"text": "2", "feedback": "That is the exponent on the variable, not the number in front."}]'::jsonb,
 0, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 2, 'Easy',
 'What is the degree of the term -2a^2b?',
 '[{"text": "2", "feedback": "That used only the exponent on a. The degree adds the exponents on every variable."},
   {"text": "3", "feedback": "Correct."},
   {"text": "1", "feedback": "That counted only the b. Every variable in the term contributes."},
   {"text": "0", "feedback": "Only a constant has degree 0. This term has variables in it."}]'::jsonb,
 1, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 3, 'Easy',
 'In the expression 7 + 3x + 3y - 2xy - 1, which pair are like terms?',
 '[{"text": "3x and 3y", "feedback": "The coefficients match, but the variables do not. Like terms need the same variable."},
   {"text": "3x and -2xy", "feedback": "Both contain x, but one also carries a y. Every variable has to match."},
   {"text": "7 and -1", "feedback": "Correct."},
   {"text": "3y and -2xy", "feedback": "Both contain y, but one also carries an x. Every variable has to match."}]'::jsonb,
 2, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 4, 'Easy',
 'Simplify 3x + 4x.',
 '[{"text": "7", "feedback": "The variable does not disappear. It is carried through unchanged."},
   {"text": "12x", "feedback": "The coefficients were multiplied. Collecting like terms adds them."},
   {"text": "7x^2", "feedback": "The coefficients are right, but the variable stays as it is. Only the numbers in front combine."},
   {"text": "7x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 5, 'Easy',
 'Simplify (4x + 3) + (7x + 2).',
 '[{"text": "-3x + 1", "feedback": "That subtracted the second bracket. The operator between them is a plus."},
   {"text": "11x^2 + 5", "feedback": "The exponents were added along with the coefficients. Only the coefficients combine."},
   {"text": "11x + 5", "feedback": "Correct."},
   {"text": "16x", "feedback": "The constants were folded into the x term. A number and an x term are not like terms."}]'::jsonb,
 2, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 6, 'Easy',
 'Simplify (3y + 5) + (7y - 4).',
 '[{"text": "10y + 9", "feedback": "The -4 was treated as a positive 4. Keep the sign that sits in front of it."},
   {"text": "10y + 1", "feedback": "Correct."},
   {"text": "10y - 1", "feedback": "The constants were combined the wrong way round. Start from the 5."},
   {"text": "4y + 1", "feedback": "The y terms were subtracted. Both brackets are being added."}]'::jsonb,
 1, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 7, 'Easy',
 'Expand 5(x + 4).',
 '[{"text": "9x", "feedback": "The 5 and the 4 were added and the bracket dropped. Distributing multiplies, it does not add."},
   {"text": "x + 20", "feedback": "Only the second term inside was multiplied. The 5 reaches both."},
   {"text": "5x + 4", "feedback": "Only the first term inside was multiplied. The 5 reaches every term in the bracket."},
   {"text": "5x + 20", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 8, 'Easy',
 'Expand -2(7x - 4).',
 '[{"text": "-14x - 8", "feedback": "A negative times a negative gives a positive. Check the sign on the second term."},
   {"text": "14x - 8", "feedback": "The minus in front of the 2 was dropped before distributing."},
   {"text": "-14x - 4", "feedback": "Only the first term inside was multiplied. The -2 reaches both."},
   {"text": "-14x + 8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 9, 'Easy',
 'Expand and simplify (x + 2)(x + 3).',
 '[{"text": "x^2 + 5x + 6", "feedback": "Correct."},
   {"text": "x^2 + 6x + 5", "feedback": "The middle number and the last number have been swapped. The two constants multiply, they do not add."},
   {"text": "2x + 5", "feedback": "The brackets were added rather than multiplied."},
   {"text": "x^2 + 6", "feedback": "Only the first terms and the last terms were multiplied. FOIL has four products, not two."}]'::jsonb,
 0, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 10, 'Easy',
 'Expand and simplify (x + 4)(x - 5).',
 '[{"text": "x^2 - x - 20", "feedback": "Correct."},
   {"text": "x^2 + x - 20", "feedback": "The two middle products are -5x and +4x. Check which one is larger."},
   {"text": "x^2 - 20", "feedback": "The outside and inside products were left out. They do not cancel here."},
   {"text": "x^2 - 9x - 20", "feedback": "The middle products were added as if both were negative. Only one of them is."}]'::jsonb,
 0, 'sub-binomial-product'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 11, 'Medium',
 'What is the degree of the polynomial 7x^2y^4 + x^6y?',
 '[{"text": "7", "feedback": "Correct."},
   {"text": "13", "feedback": "That added the exponents across the whole polynomial. Only the highest term counts."},
   {"text": "2", "feedback": "That counted the terms. The number of terms names the polynomial, it does not give the degree."},
   {"text": "6", "feedback": "That is the largest single exponent. Add the exponents within each term first, then compare the terms."}]'::jsonb,
 0, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 12, 'Medium',
 'Write an algebraic expression for 10 times the result of 6 less than x.',
 '[{"text": "6 - 10x", "feedback": "Both the order and the bracket are lost here. Multiply the whole result by 10."},
   {"text": "10x - 6", "feedback": "That takes 6 off after multiplying. The subtraction happens first, so it needs a bracket."},
   {"text": "10(6 - x)", "feedback": "6 less than x means x take away 6, not the other way round."},
   {"text": "10(x - 6)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 13, 'Medium',
 'Simplify 2b - b + 7 - 8 + 3b.',
 '[{"text": "5b - 1", "feedback": "The -b was dropped instead of subtracted."},
   {"text": "6b - 1", "feedback": "The -b was counted as +b. A lone b in front of a minus sign carries a coefficient of -1."},
   {"text": "4b - 1", "feedback": "Correct."},
   {"text": "4b - 15", "feedback": "The 7 and the 8 were both taken as negative. Only the 8 has a minus in front of it."}]'::jsonb,
 2, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 14, 'Medium',
 'Simplify 3x^2 + 2 - 6x + 9x - 3x^2.',
 '[{"text": "3x^2 + 3x + 2", "feedback": "Only one squared term was used. There are two, and they cancel each other."},
   {"text": "-3x + 2", "feedback": "The x terms were combined the wrong way round. Start from the -6x and add 9x."},
   {"text": "3x + 2", "feedback": "Correct."},
   {"text": "6x^4 + 3x + 2", "feedback": "The two squared terms were combined by adding exponents. They are like terms, so their coefficients add and cancel."}]'::jsonb,
 2, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 15, 'Medium',
 'Simplify (4x + 3) - (7x + 2).',
 '[{"text": "-3x + 1", "feedback": "Correct."},
   {"text": "-3x + 5", "feedback": "The subtraction reached the 7x but not the 2. Every term in the second bracket changes sign."},
   {"text": "11x + 5", "feedback": "The brackets were added. The operator between them is a minus."},
   {"text": "3x + 1", "feedback": "The x terms were subtracted the wrong way round. Start from the 4x."}]'::jsonb,
 0, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 16, 'Medium',
 'Simplify (6x - 12) + (-9x - 4) + (x + 14).',
 '[{"text": "-2x - 30", "feedback": "All three constants were taken as negative. The 14 is being added."},
   {"text": "16x - 2", "feedback": "The minus on the 9x was dropped. Keep the sign attached to the term."},
   {"text": "-4x - 2", "feedback": "The final x was subtracted rather than added."},
   {"text": "-2x - 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 17, 'Medium',
 'Expand -3(2x^2 - 5x + 4).',
 '[{"text": "-6x^2 + 15x - 12", "feedback": "Correct."},
   {"text": "-6x^2 + 15x + 12", "feedback": "The first two signs are right. Check the last one: -3 times +4."},
   {"text": "-6x^2 - 5x + 4", "feedback": "Only the first term was multiplied. The -3 reaches all three terms."},
   {"text": "-6x^2 - 15x - 12", "feedback": "Every term was multiplied, but the signs inside the bracket were ignored. A negative times a negative is positive."}]'::jsonb,
 0, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 18, 'Medium',
 'Expand and simplify 2(6m - 3) + 3(16 + 4m).',
 '[{"text": "24m - 42", "feedback": "The constants were combined the wrong way round. The 48 is larger than the 6."},
   {"text": "24m + 54", "feedback": "The -3 was added instead of subtracted. 48 take away 6 is not 54."},
   {"text": "12m + 42", "feedback": "The 3 never reached the 4m. Both terms inside the second bracket get multiplied."},
   {"text": "24m + 42", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 19, 'Medium',
 'Expand and simplify (3x + 1)(2x + 7).',
 '[{"text": "6x^2 + 23x + 8", "feedback": "The two constants were added at the end rather than multiplied."},
   {"text": "6x^2 + 23x + 7", "feedback": "Correct."},
   {"text": "5x + 8", "feedback": "The brackets were added rather than multiplied out."},
   {"text": "6x^2 + 21x + 7", "feedback": "The inside product was left out. 1 times 2x also belongs in the middle."}]'::jsonb,
 1, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 20, 'Medium',
 'Expand and simplify (2x - 3)(x + 5).',
 '[{"text": "2x^2 - 15", "feedback": "The outside and inside products were left out. They do not cancel here."},
   {"text": "2x^2 + 7x - 15", "feedback": "Correct."},
   {"text": "2x^2 - 7x - 15", "feedback": "The middle products are +10x and -3x. Check which one is larger."},
   {"text": "2x^2 + 13x - 15", "feedback": "The middle products were added as if both were positive. The -3 stays negative."}]'::jsonb,
 1, 'sub-binomial-product'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 21, 'Challenge',
 'A golf instructor earns 5000 dollars for the season, plus 20 dollars for each childrens lesson (C) and 30 dollars for each adult lesson (A). His earnings are E = 20C + 30A + 5000. What does he earn after 8 childrens lessons and 6 adult lessons?',
 '[{"text": "340 dollars in total", "feedback": "The 5000 dollar season fee was left out of the total."},
   {"text": "5700 dollars", "feedback": "The two rates were added and applied to all 14 lessons. Each rate belongs to its own lesson type."},
   {"text": "5340 dollars", "feedback": "Correct."},
   {"text": "5360 dollars", "feedback": "The two lesson counts were swapped. The 8 goes with the 20 dollar rate."}]'::jsonb,
 2, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 22, 'Challenge',
 'What is the degree of the polynomial 3x^2y^4 + 11x^2y^2 + y^5?',
 '[{"text": "15", "feedback": "That added the exponents across every term. Only the highest term decides."},
   {"text": "6", "feedback": "Correct."},
   {"text": "5", "feedback": "That is the degree of the last term. Another term adds up higher."},
   {"text": "4", "feedback": "That is the largest single exponent, not the largest sum on one term."}]'::jsonb,
 1, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 23, 'Challenge',
 'Simplify a^2b + 2ab - ab^2 + 2ab^2 - 3ab + a^2b.',
 '[{"text": "2a^2b^2 + ab^2 - ab", "feedback": "The exponents were added when the a^2b terms were collected. Only the coefficients combine."},
   {"text": "2a^2b + ab^2 - ab", "feedback": "Correct."},
   {"text": "2a^2b - ab^2 - ab", "feedback": "The two ab^2 terms were combined the wrong way round. Start from the -1 and add 2."},
   {"text": "2a^2b + ab^2 + ab", "feedback": "The ab terms were combined the wrong way round. 2 take away 3 is negative."}]'::jsonb,
 1, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 24, 'Challenge',
 'Simplify 2x^2 - 3y^2 + xy + 2y^2 - 8x^3, writing the terms in descending order of degree.',
 '[{"text": "-8x^3 + 2x^2 + y^2 + xy", "feedback": "The y^2 terms were combined the wrong way round. Start from the -3."},
   {"text": "-8x^3 + 2x^2 - 5y^2 + xy", "feedback": "The two y^2 terms were both taken as negative. The second one is being added."},
   {"text": "-6x^5 - y^2 + xy", "feedback": "The x^3 and x^2 terms were combined. Different exponents means they are not like terms."},
   {"text": "-8x^3 + 2x^2 - y^2 + xy", "feedback": "Correct."}]'::jsonb,
 3, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 25, 'Challenge',
 'Simplify (a^2 - 2a + 1) - (-a^2 - 2a - 5).',
 '[{"text": "-4a - 4", "feedback": "The brackets were simply dropped. Subtracting flips the sign of every term in the second bracket."},
   {"text": "2a^2 - 4a + 6", "feedback": "The squared terms and the constants were flipped, but the -2a was not. It becomes +2a and cancels."},
   {"text": "2a^2 + 6", "feedback": "Correct."},
   {"text": "2a^2 - 4", "feedback": "The constants were subtracted as 1 take away 5. Subtracting a negative 5 adds it."}]'::jsonb,
 2, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 26, 'Challenge',
 'Simplify (3x + y - 4z) - (7x + 3y - 2z).',
 '[{"text": "4x + 2y + 2z", "feedback": "Each pair was subtracted the wrong way round. Start from the first bracket every time."},
   {"text": "-4x - 2y - 6z", "feedback": "The subtraction reached the first two terms but not the -2z. It becomes +2z."},
   {"text": "-4x - 2y - 2z", "feedback": "Correct."},
   {"text": "10x + 4y - 6z", "feedback": "The brackets were added. The operator between them is a minus."}]'::jsonb,
 2, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 27, 'Challenge',
 'Expand -3x(2x^2 - 5x + 4).',
 '[{"text": "-6x^3 + 15x^2 - 12", "feedback": "The last term lost its x. Multiplying 4 by -3x still leaves an x behind."},
   {"text": "-6x^3 - 15x^2 - 12x", "feedback": "The powers are right, but the signs inside the bracket were ignored."},
   {"text": "-6x^2 + 15x - 12", "feedback": "The x in the -3x was never multiplied through. Each exponent should climb by one."},
   {"text": "-6x^3 + 15x^2 - 12x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 28, 'Challenge',
 'Expand and simplify 3m(m - 5) - (2m^2 - m).',
 '[{"text": "5m^2 - 16m", "feedback": "The second bracket was added rather than subtracted."},
   {"text": "3m^2 - 14m", "feedback": "The 2m^2 was never taken off. It cancels most of the 3m^2."},
   {"text": "m^2 - 14m", "feedback": "Correct."},
   {"text": "m^2 - 16m", "feedback": "The -m in the second bracket was not flipped. Subtracting it adds an m back."}]'::jsonb,
 2, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 29, 'Challenge',
 'Expand and simplify (x - 4)^2.',
 '[{"text": "x^2 - 8x + 16", "feedback": "Correct."},
   {"text": "x^2 - 8x - 16", "feedback": "The middle term is right. The last term is -4 times -4, which is positive."},
   {"text": "x^2 + 16", "feedback": "Each term was squared on its own. Squaring a bracket means multiplying it by itself, which gives a middle term."},
   {"text": "x^2 - 16", "feedback": "That is what (x - 4)(x + 4) gives. A square is the same bracket twice, so the middle products do not cancel."}]'::jsonb,
 0, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 30, 'Challenge',
 'Expand and simplify (2x + 3)(2x - 3).',
 '[{"text": "2x^2 - 9", "feedback": "The first product is 2x times 2x, not 2x times x."},
   {"text": "4x^2 - 9", "feedback": "Correct."},
   {"text": "4x^2 + 9", "feedback": "The last product is +3 times -3, which is negative."},
   {"text": "4x^2 + 12x - 9", "feedback": "The two middle products are -6x and +6x. They cancel."}]'::jsonb,
 1, 'sub-binomial-product'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 31, 'Advanced',
 'A polynomial has four terms, and its highest degree term is 5x^2y^3. Which description is correct?',
 '[{"text": "A polynomial with three terms and degree 5", "feedback": "The degree is right, but this polynomial has four terms, not three, so it is not a trinomial."},
   {"text": "A polynomial with four terms and degree 6", "feedback": "The exponents were multiplied. Degree adds them."},
   {"text": "A polynomial with four terms and degree 5", "feedback": "Correct."},
   {"text": "A polynomial with four terms and degree 3", "feedback": "That used only the exponent on y. Add the exponents on every variable in the term."}]'::jsonb,
 2, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 32, 'Advanced',
 'A four-sided shape has sides of length 18x + 7, 9x - 2, 3x + 5 and 3x + 5. What is its perimeter when x = 5?',
 '[{"text": "184", "feedback": "The -2 was treated as a positive 2 when the constants were collected."},
   {"text": "180", "feedback": "Correct."},
   {"text": "48", "feedback": "The 33 and the 15 were added straight away. The 33 has to be multiplied by x first."},
   {"text": "165", "feedback": "The x terms collect to 33x, but the constants were dropped. They collect to 15."}]'::jsonb,
 1, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 33, 'Advanced',
 'Which of these expressions cannot be simplified any further?',
 '[{"text": "4xy + 6xy", "feedback": "Both terms carry exactly x and y, so they are like terms and combine."},
   {"text": "3x + 4x^2", "feedback": "Correct."},
   {"text": "9 - 4 + 2", "feedback": "These are all constants, which are always like terms."},
   {"text": "5a + 2a", "feedback": "Both terms are plain a terms, so their coefficients add."}]'::jsonb,
 1, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 34, 'Advanced',
 'Simplify 5p^2q - 3pq^2 + 2p^2q + 4pq^2 - p^2q.',
 '[{"text": "6p^2q + pq^2", "feedback": "Correct."},
   {"text": "6p^2q - pq^2", "feedback": "The pq^2 terms were combined the wrong way round. Start from the -3 and add 4."},
   {"text": "7p^2q + pq^2", "feedback": "The last term was added rather than subtracted. A lone p^2q behind a minus sign has coefficient -1."},
   {"text": "6p^3q^3 + pq^2", "feedback": "The exponents were added when the p^2q terms were collected. Only the coefficients combine."}]'::jsonb,
 0, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 35, 'Advanced',
 'Three players have year end salaries of 100000 + 25x, 75000 + 18x and 90000 + 10x, where x is the bonus paid per goal. What is the total paid when x = 10000?',
 '[{"text": "795000 dollars", "feedback": "Correct."},
   {"text": "318000 dollars", "feedback": "The bonus was worked out as 53 times 10000 = 53000. Count the zeros again."},
   {"text": "530000 dollars", "feedback": "That is the bonus money only. The three base salaries still have to be added on."},
   {"text": "265000 dollars", "feedback": "That is the base salaries only. The bonuses still have to be added on."}]'::jsonb,
 0, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 36, 'Advanced',
 'Simplify (5x - 4y - 1) + (-2x + 5y + 13) - (x - y + 2).',
 '[{"text": "2x + 2y + 10", "feedback": "Correct."},
   {"text": "4x + 14", "feedback": "The third bracket was added rather than subtracted. Every term inside it changes sign."},
   {"text": "2x + 10", "feedback": "The -y stayed negative, so the y terms cancelled. Subtracting a negative y adds a y."},
   {"text": "2x + 2y + 12", "feedback": "The 2 in the last bracket was dropped instead of subtracted."}]'::jsonb,
 0, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 37, 'Advanced',
 'Expand and simplify 3[2 + 5(2k - 1)].',
 '[{"text": "30k + 3", "feedback": "The 5 was multiplied by the k term but not by the -1. Inside the square bracket that leaves 2 + 10k - 1."},
   {"text": "30k - 9", "feedback": "Correct."},
   {"text": "10k - 3", "feedback": "The inner bracket was expanded correctly, but the outer 3 was never distributed."},
   {"text": "30k - 3", "feedback": "The outer 3 reached the k term but not the constant. It multiplies everything inside."}]'::jsonb,
 1, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 38, 'Advanced',
 'Expand and simplify -2[3x - (4 - 2y)] + 5[y - 2(x + 1)].',
 '[{"text": "-16x + 9y - 2", "feedback": "Inside the first square bracket, subtracting (4 - 2y) gives -4 + 2y. The sign on the 2y was missed."},
   {"text": "-16x + y + 3", "feedback": "In the second square bracket the -2 reached the x but not the 1. It multiplies both."},
   {"text": "-16x + y - 2", "feedback": "Correct."},
   {"text": "-16x - y - 2", "feedback": "The y terms are -4y and +5y. Check which one is larger."}]'::jsonb,
 2, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 39, 'Advanced',
 'Expand and simplify (2x - 5)(3x + 4) - (x + 2)(x - 3).',
 '[{"text": "7x^2 - 8x - 26", "feedback": "The second product was added. The minus in front of it flips every term."},
   {"text": "5x^2 - 8x - 26", "feedback": "The subtraction reached the x^2 term but not the rest of the second product."},
   {"text": "5x^2 - 6x - 26", "feedback": "The x terms are handled, but the -6 was not flipped. Subtracting it adds 6."},
   {"text": "5x^2 - 6x - 14", "feedback": "Correct."}]'::jsonb,
 3, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 40, 'Advanced',
 'Expand and simplify (x + 3)(x^2 - 2x + 5).',
 '[{"text": "x^3 + 15", "feedback": "Only the first terms and the last terms were multiplied. Each term in the first bracket meets all three in the second."},
   {"text": "x^3 + 5x^2 - x + 15", "feedback": "The squared terms are -2x^2 and +3x^2. They were added as if both were positive."},
   {"text": "x^3 + x^2 + 11x + 15", "feedback": "The x terms are +5x and -6x. The 3 times -2x product stays negative."},
   {"text": "x^3 + x^2 - x + 15", "feedback": "Correct."}]'::jsonb,
 3, 'sub-binomial-product');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Algebraic expressions'
group by difficulty order by min(sort_order);

-- --- questions_mth1w_u4.sql ---

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

-- --- questions_mth1w_u5.sql ---

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
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
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

-- --- questions_mth1w_u6.sql ---

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

-- --- questions_mth1w_u7.sql ---

-- ===========================================================================
-- MTH1W — Unit 7: Geometry — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Angle relationships (parallel lines, polygons)
--   Lesson 2  Angles in triangles and circles
--   Lesson 3  Area and perimeter of composite shapes
--   Lesson 4  Pythagorean theorem
--   Lesson 5  3D geometry (surface area and volume)
--
-- Every configuration is described in words rather than drawn, so this unit
-- is answerable without figures. Where a diagram would normally carry the
-- information, the prompt states it: which angles are co-interior, which
-- side is the slant height, which piece is removed from the composite shape.
--
-- The distractors are the slips the worked solutions keep correcting:
-- treating co-interior angles as equal, halving instead of doubling at the
-- centre of a circle, adding the two legs instead of their squares, and
-- returning the surface area when the question asked for volume.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Geometry';

insert into misconception_labels (tag, label) values
  ('sub-angle-relationships',   'Angle relationships and polygons'),
  ('sub-triangle-circle-angles','Angles in triangles and circles'),
  ('sub-composite-shapes',      'Area and perimeter of composite shapes'),
  ('sub-pythagoras',            'Pythagorean theorem'),
  ('sub-3d-geometry',           'Surface area and volume')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 1, 'Easy',
 'Two angles are complementary. One of them measures 35 degrees. What is the other?',
 '[{"text": "145 degrees", "feedback": "That pair would be supplementary. Complementary angles add to a right angle."},
   {"text": "65 degrees", "feedback": "Check the subtraction. A right angle is 90 degrees."},
   {"text": "35 degrees", "feedback": "Two equal 35 degree angles do not add to a right angle."},
   {"text": "55 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 2, 'Easy',
 'What is the sum of the interior angles of an octagon?',
 '[{"text": "1440 degrees", "feedback": "The 2 was not subtracted from the number of sides before multiplying."},
   {"text": "1080 degrees", "feedback": "Correct."},
   {"text": "900 degrees", "feedback": "That is the sum for a seven-sided polygon. An octagon has eight sides."},
   {"text": "360 degrees", "feedback": "That is the sum of the EXTERIOR angles, which is the same for every polygon."}]'::jsonb,
 1, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 3, 'Easy',
 'Two angles of a triangle each measure 70 degrees. What is the third angle?',
 '[{"text": "60 degrees", "feedback": "That would make the triangle equilateral, but two of these angles are 70."},
   {"text": "40 degrees", "feedback": "Correct."},
   {"text": "20 degrees", "feedback": "The angles of a triangle add to 180 degrees, not 160."},
   {"text": "140 degrees", "feedback": "That is the sum of the two given angles, not what is left over."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 4, 'Easy',
 'An angle is inscribed in a semicircle. What does it measure?',
 '[{"text": "It depends where the point sits on the arc", "feedback": "Every point on the arc gives the same inscribed angle here."},
   {"text": "90 degrees, a right angle wherever the point sits", "feedback": "Correct."},
   {"text": "180 degrees", "feedback": "That is the arc of the semicircle itself. The inscribed angle is half of it."},
   {"text": "45 degrees", "feedback": "That would be half of a right angle. An inscribed angle is half the angle at the centre."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 5, 'Easy',
 'What is the area of a rectangle measuring 2.4 m by 3.8 m?',
 '[{"text": "4.56 square metres", "feedback": "That halves the product, which is the rule for a triangle rather than a rectangle."},
   {"text": "9.12 square metres", "feedback": "Correct."},
   {"text": "12.4 square metres", "feedback": "That is the perimeter, and it is measured in metres rather than square metres."},
   {"text": "6.2 square metres", "feedback": "The two side lengths were added. Area multiplies them."}]'::jsonb,
 1, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 6, 'Easy',
 'Which formula gives the area of a circle?',
 '[{"text": "2 x pi x r^2", "feedback": "That is twice the area. There is no 2 in the area formula for a circle."},
   {"text": "2 x pi x r", "feedback": "That is the circumference, which is a distance rather than an area."},
   {"text": "pi x r^2", "feedback": "Correct."},
   {"text": "pi x d", "feedback": "That is the circumference written using the diameter."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 7, 'Easy',
 'A right triangle has legs of 3 units and 7 units. What is the hypotenuse, to the nearest tenth?',
 '[{"text": "58.0 units", "feedback": "That is the sum of the squares. There is still a square root to take."},
   {"text": "6.3 units", "feedback": "The squares were subtracted rather than added. Subtraction is for finding a leg."},
   {"text": "10.0 units", "feedback": "The two legs were added. It is their SQUARES that add."},
   {"text": "7.6 units", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 8, 'Easy',
 'In the Pythagorean theorem a^2 + b^2 = c^2, what does c represent?',
 '[{"text": "Either of the two shorter sides", "feedback": "Those are a and b, the legs that form the right angle."},
   {"text": "The side that forms the right angle with a", "feedback": "That describes the other leg. The right angle is formed by a and b."},
   {"text": "The perimeter of the triangle", "feedback": "The theorem relates side lengths to each other, not to the distance around."},
   {"text": "The hypotenuse, the longest side, opposite the right angle", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 9, 'Easy',
 'What is the volume of a rectangular prism measuring 17 m by 4 m by 10 m?',
 '[{"text": "31 cubic metres", "feedback": "The three dimensions were added. Volume multiplies them."},
   {"text": "68 cubic metres", "feedback": "Only two of the three dimensions were multiplied."},
   {"text": "680 cubic metres", "feedback": "Correct."},
   {"text": "556 cubic metres", "feedback": "That is the surface area of this prism, which is measured in square metres."}]'::jsonb,
 2, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 10, 'Easy',
 'Which formula gives the volume of a sphere?',
 '[{"text": "(4/3) x pi x r^3", "feedback": "Correct."},
   {"text": "(1/3) x pi x r^2 x h", "feedback": "That is the volume of a cone."},
   {"text": "4 x pi x r^2", "feedback": "That is the surface area of a sphere, which is measured in square units."},
   {"text": "pi x r^2 x h", "feedback": "That is the volume of a cylinder. A sphere has no height to measure."}]'::jsonb,
 0, 'sub-3d-geometry'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 11, 'Medium',
 'Two parallel lines are cut by a transversal. One of a pair of co-interior angles measures 65 degrees. What is the other?',
 '[{"text": "115 degrees", "feedback": "Correct."},
   {"text": "25 degrees", "feedback": "That pair would be complementary. Co-interior angles add to 180 degrees."},
   {"text": "295 degrees", "feedback": "The 65 was subtracted from a full turn. Co-interior angles add to a straight line."},
   {"text": "65 degrees", "feedback": "Alternate interior and corresponding angles are equal. Co-interior angles are the pair that add to a straight line."}]'::jsonb,
 0, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 12, 'Medium',
 'A regular polygon has interior angles of 140 degrees each. How many sides does it have?',
 '[{"text": "10", "feedback": "A ten-sided polygon has interior angles of 144 degrees, which is slightly too large."},
   {"text": "9", "feedback": "Correct."},
   {"text": "8", "feedback": "An octagon has interior angles of 135 degrees. This polygon needs slightly larger ones."},
   {"text": "7", "feedback": "A seven-sided polygon has interior angles under 130 degrees."}]'::jsonb,
 1, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 13, 'Medium',
 'An isosceles triangle has an apex angle of 100 degrees. What does each base angle measure?',
 '[{"text": "100 degrees", "feedback": "Three angles of 100 degrees would add to far more than a triangle allows."},
   {"text": "80 degrees", "feedback": "That is what the two base angles add to. They still have to be shared between the two of them."},
   {"text": "50 degrees", "feedback": "The 100 was halved. It is the REMAINING 80 degrees that gets shared."},
   {"text": "40 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 14, 'Medium',
 'An arc subtends an angle of 35 degrees at a point on the circumference. What angle does the same arc subtend at the centre?',
 '[{"text": "145 degrees", "feedback": "That subtracts from 180. The relationship here is a doubling."},
   {"text": "17.5 degrees", "feedback": "That halves it. The angle at the CENTRE is the larger of the two."},
   {"text": "35 degrees", "feedback": "Equal angles come from two points on the circumference. The centre is different."},
   {"text": "70 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 15, 'Medium',
 'A composite figure is made of a rectangle measuring 2.4 m by 3.8 m together with a full circle of radius 1.2 m. What is the total area, to the nearest hundredth?',
 '[{"text": "9.12 square metres", "feedback": "That is the rectangle on its own. The circle still has to be added."},
   {"text": "4.52 square metres", "feedback": "That is the circle on its own. The rectangle still has to be added."},
   {"text": "13.64 square metres", "feedback": "Correct."},
   {"text": "11.38 square metres", "feedback": "Only half the circle was counted. The question gives a full circle."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 16, 'Medium',
 'What is the area of a triangle with a base of 3.2 m and a height of 3.8 m?',
 '[{"text": "3.04 square metres", "feedback": "The halving was done twice."},
   {"text": "12.16 square metres", "feedback": "The half was left out. That product is the area of a rectangle with those dimensions."},
   {"text": "6.08 square metres", "feedback": "Correct."},
   {"text": "7.00 square metres", "feedback": "The base and height were added. Area multiplies them and then halves."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 17, 'Medium',
 'A right triangle has a hypotenuse of 11 units and one leg of 3.9 units. What is the other leg, to the nearest tenth?',
 '[{"text": "105.8 units", "feedback": "That is the difference of the squares. There is still a square root to take."},
   {"text": "11.7 units", "feedback": "The squares were added. When you know the hypotenuse, you subtract."},
   {"text": "7.1 units", "feedback": "The two side lengths were subtracted directly. It is their SQUARES that subtract."},
   {"text": "10.3 units", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 18, 'Medium',
 'A television screen measures 30 inches by 22.5 inches. What is the length of its diagonal?',
 '[{"text": "1406.25 inches", "feedback": "That is the sum of the squares. There is still a square root to take."},
   {"text": "52.5 inches", "feedback": "The two sides were added. It is their squares that add, before a square root is taken."},
   {"text": "37.5 inches", "feedback": "Correct."},
   {"text": "26.25 inches", "feedback": "That is the average of the two sides. The diagonal is longer than either of them."}]'::jsonb,
 2, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 19, 'Medium',
 'A sphere has a diameter of 12 cm. What is its volume, to the nearest hundredth?',
 '[{"text": "7238.23 cubic centimetres", "feedback": "The diameter was used in place of the radius. Halve it first."},
   {"text": "904.78 cubic centimetres", "feedback": "Correct."},
   {"text": "226.19 cubic centimetres", "feedback": "That is the volume of a CONE with this radius and height. A sphere is four times as large."},
   {"text": "452.39 cubic centimetres", "feedback": "That is the surface area of this sphere, which is measured in square centimetres."}]'::jsonb,
 1, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 20, 'Medium',
 'What is the surface area of a rectangular prism measuring 17 m by 4 m by 10 m?',
 '[{"text": "556 square metres", "feedback": "Correct."},
   {"text": "680 square metres", "feedback": "That is the volume of this prism, which is measured in cubic metres."},
   {"text": "278 square metres", "feedback": "The three face areas were added but never doubled. Every face has a matching one opposite it."},
   {"text": "62 square metres", "feedback": "The three dimensions were added and doubled. Each face is a product of two dimensions."}]'::jsonb,
 0, 'sub-3d-geometry'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 21, 'Challenge',
 'The interior angles of a pentagon measure 110, 138, 100, x and 2x degrees. What is x?',
 '[{"text": "124", "feedback": "That uses a total of 720, which belongs to a six-sided polygon."},
   {"text": "48", "feedback": "That uses a total of 540 but treats the last two angles as x and x rather than x and 2x."},
   {"text": "64", "feedback": "Correct."},
   {"text": "128", "feedback": "That is the value of the LARGER unknown angle. The question asks for x itself."}]'::jsonb,
 2, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 22, 'Challenge',
 'Each exterior angle of a regular polygon measures 24 degrees. How many sides does it have?',
 '[{"text": "15 sides", "feedback": "Correct."},
   {"text": "8 sides", "feedback": "That comes from dividing 180 by 24 and rounding. The exterior angles add to 360."},
   {"text": "24 sides", "feedback": "That copies the angle straight across. Divide a full turn by the angle instead."},
   {"text": "30 sides", "feedback": "Each vertex was counted as having two exterior angles, so 720 was divided by 24 instead of one full turn."}]'::jsonb,
 0, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 23, 'Challenge',
 'An exterior angle of a triangle measures 120 degrees. One of the two opposite interior angles is 45 degrees. What is the other?',
 '[{"text": "15 degrees", "feedback": "Check the subtraction. The exterior angle is 120, not 60."},
   {"text": "75 degrees", "feedback": "Correct."},
   {"text": "60 degrees", "feedback": "That is the interior angle beside the exterior one, taken as 180 minus 120. It is not one of the two opposite interior angles."},
   {"text": "165 degrees", "feedback": "The two were added. The exterior angle EQUALS their sum, so one subtracts from it."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 24, 'Challenge',
 'The three angles of a triangle measure 2x, 3x + 10 and 4x - 1 degrees. What is x?',
 '[{"text": "x = 19", "feedback": "Correct."},
   {"text": "x = 20", "feedback": "The two constants were dropped before dividing. The +10 and the -1 have to be dealt with first."},
   {"text": "x = 21", "feedback": "The constants were added to the 180 instead of being taken off it."},
   {"text": "x = 39", "feedback": "A total of 360 was used. The interior angles of a TRIANGLE add to 180."}]'::jsonb,
 0, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 25, 'Challenge',
 'A rectangle measures 5 m by 2 m. A semicircle of diameter 2 m is cut out of one of the short ends. What area remains, to the nearest hundredth?',
 '[{"text": "10.00 square metres", "feedback": "That is the whole rectangle. The cut-out still has to be taken off."},
   {"text": "6.86 square metres", "feedback": "A full circle was removed. Only half of one is cut out here."},
   {"text": "8.43 square metres", "feedback": "Correct."},
   {"text": "11.57 square metres", "feedback": "The semicircle was added rather than removed."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 26, 'Challenge',
 'A rectangle measures 10 m by 3 m. A semicircle of diameter 3 m is attached to one of the short ends. What is the perimeter of the composite shape, to the nearest hundredth?',
 '[{"text": "27.71 metres", "feedback": "Correct."},
   {"text": "30.71 metres", "feedback": "The 3 m end was counted as well as the arc. Once the semicircle is attached, that edge is inside the shape."},
   {"text": "26.00 metres", "feedback": "That is the rectangle on its own. One straight edge is replaced by a curved one."},
   {"text": "32.42 metres", "feedback": "The whole circumference of the circle was used. Only half of it forms the outside edge."}]'::jsonb,
 0, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 27, 'Challenge',
 'An isosceles triangle has two equal sides of 7 units and a base of 10 units. What is its area, to the nearest hundredth?',
 '[{"text": "24.49 square units", "feedback": "Correct."},
   {"text": "48.99 square units", "feedback": "The height is right, but the halving was left out."},
   {"text": "12.50 square units", "feedback": "Half the base was used as the height as well as the base."},
   {"text": "35.00 square units", "feedback": "The equal side was used as the height. The height is the perpendicular drop to the base, which is shorter."}]'::jsonb,
 0, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 28, 'Challenge',
 'Zeke drives 64 km east and then 135 km north. A new expressway runs in a straight line between his start and finish. How much travel distance does the expressway save, to the nearest tenth?',
 '[{"text": "49.6 km", "feedback": "Correct."},
   {"text": "71.0 km", "feedback": "The two distances were subtracted from each other. Find the straight-line route first."},
   {"text": "149.4 km", "feedback": "That is the length of the expressway itself. The saving is what is left of the old route."},
   {"text": "199.0 km", "feedback": "That is the old route. The expressway still has to be subtracted from it."}]'::jsonb,
 0, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 29, 'Challenge',
 'A cone has a radius of 8 cm and a slant height of 17.9 cm. What is its vertical height, to the nearest tenth?',
 '[{"text": "9.9 cm", "feedback": "The radius was subtracted from the slant height directly. It is their SQUARES that subtract."},
   {"text": "19.6 cm", "feedback": "The squares were added. The slant height is the hypotenuse here, so you subtract."},
   {"text": "25.9 cm", "feedback": "The two lengths were added. The height is shorter than the slant height."},
   {"text": "16.0 cm", "feedback": "Correct."}]'::jsonb,
 3, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 30, 'Challenge',
 'A cylinder has a diameter of 20 m and a height of 13 m. What is its volume, to the nearest hundredth?',
 '[{"text": "1445.13 cubic metres", "feedback": "That is the surface area of this cylinder, which is measured in square metres."},
   {"text": "314.16 cubic metres", "feedback": "The height was left out of the calculation."},
   {"text": "16336.28 cubic metres", "feedback": "The diameter was used in place of the radius. Halve it first."},
   {"text": "4084.07 cubic metres", "feedback": "Correct."}]'::jsonb,
 3, 'sub-3d-geometry'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 31, 'Advanced',
 'Two parallel lines are cut by a transversal. An angle of 125 degrees is corresponding to angle z, and angle y sits on a straight line with z. What is y?',
 '[{"text": "125 degrees", "feedback": "That is the value of z itself. Angle y is the one that completes the straight line with it."},
   {"text": "55 degrees", "feedback": "Correct."},
   {"text": "35 degrees", "feedback": "That subtracts from 90. Angles on a straight line add to 180."},
   {"text": "235 degrees", "feedback": "That subtracts from a full turn. Angles on a straight line add to 180."}]'::jsonb,
 1, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 32, 'Advanced',
 'In a regular polygon each interior angle is three times its exterior angle. How many sides does the polygon have?',
 '[{"text": "12 sides", "feedback": "That polygon has interior angles of 150 and exterior angles of 30, a ratio of five to one."},
   {"text": "4 sides", "feedback": "A square has interior angles of 90 and exterior angles of 90, a ratio of one to one."},
   {"text": "8 sides", "feedback": "Correct."},
   {"text": "6 sides", "feedback": "A hexagon has interior angles of 120 and exterior angles of 60, which is a ratio of two to one."}]'::jsonb,
 2, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 33, 'Advanced',
 'The three angles of a triangle are in the ratio 2 to 3 to 4. What is the largest angle?',
 '[{"text": "60 degrees", "feedback": "That is the middle share of the three."},
   {"text": "90 degrees", "feedback": "That assumes the triangle is right-angled. Share 180 out in the given ratio instead."},
   {"text": "40 degrees", "feedback": "That is the SMALLEST of the three shares. The question asks for the largest."},
   {"text": "80 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 34, 'Advanced',
 'Two inscribed angles in a circle are subtended by the same arc. One measures 3x degrees and the other measures x + 40 degrees. What is x?',
 '[{"text": "x = -20", "feedback": "The 40 was moved across without changing sign."},
   {"text": "x = 20", "feedback": "Correct."},
   {"text": "x = 10", "feedback": "The two expressions were added and set equal to 40 rather than being set equal to each other."},
   {"text": "x = 35", "feedback": "The two were treated as supplementary. Inscribed angles on the same arc are EQUAL."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 35, 'Advanced',
 'A square of side 8 cm has a quarter circle of radius 8 cm removed from one corner. What area remains, to the nearest hundredth?',
 '[{"text": "13.73 square centimetres", "feedback": "Correct."},
   {"text": "51.43 square centimetres", "feedback": "A quarter of the CIRCUMFERENCE was subtracted. What is removed is an area."},
   {"text": "50.27 square centimetres", "feedback": "That is the piece that was removed, not what is left behind."},
   {"text": "64.00 square centimetres", "feedback": "That is the whole square. The quarter circle still has to be taken off."}]'::jsonb,
 0, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 36, 'Advanced',
 'A running track encloses a rectangle 50 m by 30 m with a semicircle of diameter 30 m at each end. What is the total enclosed area, to the nearest hundredth?',
 '[{"text": "1853.43 square metres", "feedback": "Only one of the two semicircular ends was counted."},
   {"text": "1500.00 square metres", "feedback": "That is the rectangle on its own. The two semicircular ends still have to be added."},
   {"text": "2206.86 square metres", "feedback": "Correct."},
   {"text": "2913.72 square metres", "feedback": "Two FULL circles were added. Each end is only half a circle."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 37, 'Advanced',
 'A 5 m ladder leans against a wall with its foot 1.4 m from the base of the wall. How far up the wall does it reach, to the nearest tenth?',
 '[{"text": "6.4 m", "feedback": "The two lengths were added. The wall height is shorter than the ladder."},
   {"text": "3.6 m", "feedback": "The two lengths were subtracted directly. It is their SQUARES that subtract."},
   {"text": "5.2 m", "feedback": "The squares were added. The ladder is the hypotenuse here, so you subtract."},
   {"text": "4.8 m", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 38, 'Advanced',
 'Is a triangle with sides of 9, 40 and 41 units right-angled?',
 '[{"text": "No, because the three numbers are not consecutive", "feedback": "The numbers do not have to follow any pattern. Test them in the theorem."},
   {"text": "No, because 9 plus 40 does not equal 41", "feedback": "The theorem adds the SQUARES of the two shorter sides, not the sides themselves."},
   {"text": "Yes, because 9 squared plus 40 squared equals 41 squared", "feedback": "Correct."},
   {"text": "Yes, because all three sides are different", "feedback": "That describes a scalene triangle, which need not have a right angle."}]'::jsonb,
 2, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 39, 'Advanced',
 'A baseball has a surface area of 215 square centimetres. What is its radius, to the nearest tenth?',
 '[{"text": "5.8 cm", "feedback": "A 2 was used where the formula needs a 4. The surface area of a sphere is four pi r squared."},
   {"text": "4.1 cm", "feedback": "Correct."},
   {"text": "17.1 cm", "feedback": "That is the value of r squared. There is still a square root to take."},
   {"text": "8.3 cm", "feedback": "That is the diameter. The question asks for the radius."}]'::jsonb,
 1, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 40, 'Advanced',
 'A rectangular prism measures 5 cm by 2 cm by 3 cm. Both its length and its height are doubled. What happens to its volume?',
 '[{"text": "It is multiplied by 4", "feedback": "Correct."},
   {"text": "It stays the same", "feedback": "Volume depends on all three dimensions, so changing any of them changes it."},
   {"text": "It is doubled", "feedback": "Only one dimension doubling would double it. Two of them changed here."},
   {"text": "It is multiplied by 8", "feedback": "That is what happens when all THREE dimensions double. The width is unchanged."}]'::jsonb,
 0, 'sub-3d-geometry');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Geometry'
group by difficulty order by min(sort_order);

-- --- questions_mth1w_u8.sql ---

-- ===========================================================================
-- MTH1W — Unit 8: Data — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Measures of central tendency (including frequency tables)
--   Lesson 2  Measures of spread and boxplots
--   Lesson 3  Scatterplots and regression models
--
-- Three lessons but five distinct skills, so the unit splits into five
-- subtopics: the frequency-table version of an average is a separate skill
-- from the list version, and reading a boxplot is separate from computing
-- the quartiles that build it.
--
-- Every data set is written out in the prompt, so this unit is answerable
-- without figures. Where a boxplot would normally carry the information, the
-- prompt states the five-number summary instead.
--
-- The distractors are the slips the worked solutions keep correcting: taking
-- the middle of an UNORDERED list, averaging the distinct values of a
-- frequency table instead of weighting them, subtracting the quartiles the
-- wrong way round, and reading a correlation as a cause.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Data';

insert into misconception_labels (tag, label) values
  ('sub-central-tendency', 'Mean, median and mode'),
  ('sub-frequency-tables', 'Averages from a frequency table'),
  ('sub-spread',           'Range, quartiles and interquartile range'),
  ('sub-boxplots',         'Boxplots and the five-number summary'),
  ('sub-scatterplots',     'Scatterplots and correlation')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 1, 'Easy',
 'Find the mean of the test scores 72, 85, 78, 90, 85, 88, 78, 85, 92, 75.',
 '[{"text": "82.8", "feedback": "Correct."},
   {"text": "85", "feedback": "That is the value that appears most often. The mean shares the total out evenly instead."},
   {"text": "82", "feedback": "The total is right, but it was rounded down rather than divided exactly."},
   {"text": "8.28", "feedback": "The total was divided by 100 rather than by the number of scores."}]'::jsonb,
 0, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 2, 'Easy',
 'Find the mode of the test scores 72, 85, 78, 90, 85, 88, 78, 85, 92, 75.',
 '[{"text": "85", "feedback": "Correct."},
   {"text": "92", "feedback": "That is the largest score. The mode is about frequency, not size."},
   {"text": "78", "feedback": "That value does repeat, but another one repeats more often."},
   {"text": "82.8", "feedback": "That is the mean. The mode is a value that actually appears in the list."}]'::jsonb,
 0, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 3, 'Easy',
 'A frequency table shows hourly wages: 17 dollars for 20 employees, 19 dollars for 8, 20 dollars for 5, 25 dollars for 7 and 30 dollars for 3. What is the modal wage?',
 '[{"text": "20 dollars", "feedback": "That wage is paid to only five employees. Look for the largest frequency, not the roundest wage."},
   {"text": "30 dollars", "feedback": "That is the highest wage. The mode is the one paid most often."},
   {"text": "17 dollars", "feedback": "Correct."},
   {"text": "19.93 dollars", "feedback": "That is the mean wage. The mode has to be a wage that actually appears in the table."}]'::jsonb,
 2, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 4, 'Easy',
 'In that same wage table (frequencies 20, 8, 5, 7 and 3), how many employees are there altogether?',
 '[{"text": "5", "feedback": "That is the number of different wage levels, not the number of people."},
   {"text": "43", "feedback": "Correct."},
   {"text": "111", "feedback": "The wages were added instead of the frequencies."},
   {"text": "20", "feedback": "That is the largest single frequency. All five have to be added."}]'::jsonb,
 1, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 5, 'Easy',
 'Find the range of the data set 12, 15, 18, 22, 27.',
 '[{"text": "15", "feedback": "Correct."},
   {"text": "27", "feedback": "That is the largest value. The range subtracts the smallest from it."},
   {"text": "18", "feedback": "That is the middle value. The range uses the two extremes."},
   {"text": "39", "feedback": "The two extremes were added. The range subtracts them."}]'::jsonb,
 0, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 6, 'Easy',
 'What does the interquartile range measure?',
 '[{"text": "The value that appears most often", "feedback": "That is the mode, which describes the centre rather than the spread."},
   {"text": "The spread of the middle half of the data", "feedback": "Correct."},
   {"text": "The difference between the largest and smallest values", "feedback": "That is the range. The interquartile range ignores the extremes."},
   {"text": "The average distance of each value from the mean", "feedback": "That is a different measure of spread. This one is built from quartiles."}]'::jsonb,
 1, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 7, 'Easy',
 'Which five values make up the summary a boxplot is drawn from?',
 '[{"text": "Q1, Q2, Q3, range and interquartile range", "feedback": "The quartiles are right, but a boxplot also needs the two extreme values."},
   {"text": "Mean, median, mode, range and interquartile range", "feedback": "Those are summary statistics, but a boxplot is built from positions in the ordered data."},
   {"text": "Minimum, Q1, median, Q3 and maximum", "feedback": "Correct."},
   {"text": "Minimum, mean, median, mode and maximum", "feedback": "The mean and mode never appear on a boxplot. The quartiles do."}]'::jsonb,
 2, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 8, 'Easy',
 'On a boxplot, what does the rectangular box span?',
 '[{"text": "From the median to the maximum", "feedback": "That is the upper half of the data. The box covers the middle half."},
   {"text": "From Q1 to Q3", "feedback": "Correct."},
   {"text": "From the mean to the median", "feedback": "The mean is never plotted on a boxplot."},
   {"text": "From the minimum to the maximum", "feedback": "That is the whole plot including the whiskers. The box is narrower."}]'::jsonb,
 1, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 9, 'Easy',
 'On a scatterplot, which variable goes on the x-axis?',
 '[{"text": "Whichever variable has the larger values", "feedback": "The size of the numbers does not decide it. The roles of the variables do."},
   {"text": "Whichever variable has more data points", "feedback": "Both variables have the same number of points, since they come in pairs."},
   {"text": "The independent variable", "feedback": "Correct."},
   {"text": "The dependent variable", "feedback": "That one goes on the vertical axis, because it responds to the other."}]'::jsonb,
 2, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 10, 'Easy',
 'On a scatterplot of hours studied against test score, the points run from the lower left to the upper right. What kind of correlation is this?',
 '[{"text": "Negative", "feedback": "That pattern runs from the upper left down to the lower right instead."},
   {"text": "No correlation", "feedback": "A clear direction in the points means there is a relationship to describe."},
   {"text": "It cannot be told from a scatterplot", "feedback": "The direction of the pattern is exactly what a scatterplot shows."},
   {"text": "Positive", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatterplots'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 11, 'Medium',
 'Find the median of the points scored: 0, 8, 6, 0, 3, 5, 3, 4, 2, 9, 12.',
 '[{"text": "4", "feedback": "Correct."},
   {"text": "5", "feedback": "That is the sixth value of the list as written. The list has to be sorted first."},
   {"text": "6", "feedback": "That is the position of the middle value, not the value sitting in that position."},
   {"text": "4.73", "feedback": "That is the mean. The median is an actual position in the ordered list."}]'::jsonb,
 0, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 12, 'Medium',
 'Find the mean of the points scored: 0, 8, 6, 0, 3, 5, 3, 4, 2, 9, 12. Round to two decimal places.',
 '[{"text": "5.20", "feedback": "The total is right, but it was divided by ten. The two zeros still count as players."},
   {"text": "4.73", "feedback": "Correct."},
   {"text": "4.00", "feedback": "That is the median of this set. The mean shares the total out evenly instead."},
   {"text": "52.00", "feedback": "That is the total. It still has to be divided by how many players there are."}]'::jsonb,
 1, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 13, 'Medium',
 'From the wage table (17 dollars for 20 employees, 19 for 8, 20 for 5, 25 for 7, 30 for 3), what is the mean wage, to two decimal places?',
 '[{"text": "22.20 dollars", "feedback": "The five different wages were averaged. Each one has to be weighted by how many people earn it."},
   {"text": "857.00 dollars", "feedback": "That is the total payroll per hour. It still has to be divided by the number of employees."},
   {"text": "19.93 dollars", "feedback": "Correct."},
   {"text": "18.08 dollars", "feedback": "Only the largest group was weighted; the other four wages were each counted once."}]'::jsonb,
 2, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 14, 'Medium',
 'From that same wage table, what is the median wage?',
 '[{"text": "22 dollars", "feedback": "That is the POSITION of the middle employee, not the wage that employee earns."},
   {"text": "17 dollars", "feedback": "That is the modal wage. Twenty employees earn it, but the middle position falls just past them."},
   {"text": "19 dollars", "feedback": "Correct."},
   {"text": "20 dollars", "feedback": "The middle position falls inside a smaller group than that. Build up the running totals."}]'::jsonb,
 2, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 15, 'Medium',
 'For the data set 8, 12, 15, 18, 22, 27, 30, 35, 40, what is Q1?',
 '[{"text": "15", "feedback": "That is one of the two middle values of the lower half. The two of them get averaged."},
   {"text": "13.5", "feedback": "Correct."},
   {"text": "12", "feedback": "That is the other middle value of the lower half. The two of them get averaged."},
   {"text": "22", "feedback": "That is the overall median, which is Q2 rather than Q1."}]'::jsonb,
 1, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 16, 'Medium',
 'For the data set 8, 12, 15, 18, 22, 27, 30, 35, 40, what is the interquartile range?',
 '[{"text": "32", "feedback": "That is the range, which uses the two extreme values rather than the quartiles."},
   {"text": "46", "feedback": "The two quartiles were added. The interquartile range subtracts them."},
   {"text": "22", "feedback": "That is the overall median, not a measure of spread."},
   {"text": "19", "feedback": "Correct."}]'::jsonb,
 3, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 17, 'Medium',
 'For the ordered data 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6, 7, 8, 9, 10, 10, 12, 15, 26, what is the median?',
 '[{"text": "5", "feedback": "Correct."},
   {"text": "6", "feedback": "That is one place past the middle. With nineteen values the middle sits at the tenth."},
   {"text": "26", "feedback": "That is the largest value, which is the maximum rather than the middle."},
   {"text": "3", "feedback": "That is the most common value, which is the mode rather than the middle one."}]'::jsonb,
 0, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 18, 'Medium',
 'For that same ordered data set of nineteen values, what is Q3?',
 '[{"text": "10", "feedback": "Correct."},
   {"text": "26", "feedback": "That is the maximum. Q3 is the middle of the upper half, not its top."},
   {"text": "12", "feedback": "That is one place past Q3. The upper half here has nine values, so its middle is the fifth of them."},
   {"text": "9", "feedback": "That is one place before Q3. Count the upper half again, starting just above the overall median."}]'::jsonb,
 0, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 19, 'Medium',
 'Two variables have a correlation coefficient of -0.9. What does that tell you?',
 '[{"text": "No linear correlation", "feedback": "That would need a value close to zero."},
   {"text": "A strong negative linear correlation", "feedback": "Correct."},
   {"text": "A weak negative linear correlation", "feedback": "The minus sign gives the direction, but the size tells the strength, and this one sits close to the extreme."},
   {"text": "A strong positive linear correlation", "feedback": "The strength is right, but the sign says the two variables move in opposite directions."}]'::jsonb,
 1, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 20, 'Medium',
 'Two variables have a correlation coefficient of 0.05. What does that tell you?',
 '[{"text": "A strong positive linear correlation", "feedback": "That would need a value close to one. This one sits close to zero."},
   {"text": "A strong negative linear correlation", "feedback": "That would need a value close to minus one, and this value is not even negative."},
   {"text": "Little or no linear correlation", "feedback": "Correct."},
   {"text": "A perfect correlation", "feedback": "That would need a value of exactly one or minus one."}]'::jsonb,
 2, 'sub-scatterplots'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 21, 'Challenge',
 'In the data set 0, 8, 6, 0, 3, 5, 3, 4, 2, 9, 12, the player with 12 points instead scores 20. Which measures of central tendency change?',
 '[{"text": "The mean and the median", "feedback": "The changed value is already the largest, so it stays at the top of the ordered list and the middle position is untouched."},
   {"text": "Only the mean", "feedback": "Correct."},
   {"text": "The median and the mode", "feedback": "Neither of those depends on how large the biggest value is, only on where it sits and how often values repeat."},
   {"text": "All three", "feedback": "Only one of the three uses the actual size of every value."}]'::jsonb,
 1, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 22, 'Challenge',
 'A set of five numbers has a mean of 20. One number is removed and the mean of the remaining four is 22. What was the number that was removed?',
 '[{"text": "18", "feedback": "Removing that value would barely move the mean. Work with the two totals instead."},
   {"text": "42", "feedback": "The two means were added. It is the totals behind them that have to be compared."},
   {"text": "12", "feedback": "Correct."},
   {"text": "2", "feedback": "That is the change in the mean, not the value that left the set."}]'::jsonb,
 2, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 23, 'Challenge',
 'In the wage table (17 dollars for 20 employees, 19 for 8, 20 for 5, 25 for 7, 30 for 3), one more employee is hired at 30 dollars an hour, taking that group from 3 people to 4. What happens to the modal wage?',
 '[{"text": "It stays at 17 dollars", "feedback": "Correct."},
   {"text": "There are now two modes", "feedback": "Two modes would need two groups tied for the largest frequency. These are not close."},
   {"text": "It rises slightly", "feedback": "The mode always equals a value from the table. It cannot drift between them."},
   {"text": "It becomes 30 dollars", "feedback": "Four people is still far short of the largest group in the table."}]'::jsonb,
 0, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 24, 'Challenge',
 'Every employee in the wage table is given a raise of 2 dollars an hour. What happens to the mean wage?',
 '[{"text": "It rises by 2 divided by the number of employees", "feedback": "That would be right if only one person got the raise. Everybody got it here."},
   {"text": "It stays the same", "feedback": "The total payroll grows, and the number of employees does not, so the average has to move."},
   {"text": "It doubles", "feedback": "The raise is added to each wage, not multiplied into it."},
   {"text": "It rises by exactly 2 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 25, 'Challenge',
 'Data set A is 50, 50, 50, 50, 50 and data set B is 10, 30, 50, 70, 90. What distinguishes them?',
 '[{"text": "Their spread: A has a range of 0 and B has a range of 80", "feedback": "Correct."},
   {"text": "Nothing, they are equivalent data sets", "feedback": "The centres agree, but one set is identical values and the other stretches widely."},
   {"text": "Their means", "feedback": "Both totals come to 250 across five values, so the means match."},
   {"text": "Their medians", "feedback": "The middle value of each ordered set is the same."}]'::jsonb,
 0, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 26, 'Challenge',
 'A data set has a range of 15 but an interquartile range of only 4. What does that suggest?',
 '[{"text": "The mean must equal the median", "feedback": "These two measures say nothing about where the mean sits."},
   {"text": "The data are evenly spread across the whole range", "feedback": "Even spreading would put the quartiles far apart, giving a much larger middle spread."},
   {"text": "The middle half is tightly packed, with a few values far out at the ends", "feedback": "Correct."},
   {"text": "The data set must contain a calculation error", "feedback": "Nothing is wrong. A middle spread smaller than the full spread is entirely normal."}]'::jsonb,
 2, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 27, 'Challenge',
 'A boxplot has the five-number summary minimum 1, Q1 3, median 5, Q3 10, maximum 26. What is the interquartile range?',
 '[{"text": "5", "feedback": "That is the median. The interquartile range is a distance between two quartiles."},
   {"text": "13", "feedback": "The two quartiles were added. The interquartile range subtracts them."},
   {"text": "25", "feedback": "That is the range, which uses the two extreme values rather than the quartiles."},
   {"text": "7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 28, 'Challenge',
 'For that boxplot (minimum 1, Q1 3, median 5, Q3 10, maximum 26), which whisker is longer and what does it tell you?',
 '[{"text": "Whisker length says nothing about the data", "feedback": "A whisker shows how far the outer quarter of the data reaches, which is exactly what spread means."},
   {"text": "The upper whisker, so the data stretch out at the high end", "feedback": "Correct."},
   {"text": "The lower whisker, so the data trail off at the low end", "feedback": "The lower whisker runs only from 1 to 3. Compare that with the gap above the box."},
   {"text": "They are the same length", "feedback": "Measure each one: the gap below the box and the gap above it are very different."}]'::jsonb,
 1, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 29, 'Challenge',
 'A line of best fit for hours studied (x) against test score (y) is y = 5.4x + 48. Predict the score for 8 hours of study.',
 '[{"text": "91.2", "feedback": "Correct."},
   {"text": "53.4", "feedback": "The slope was counted once instead of once for every hour studied."},
   {"text": "43.2", "feedback": "The starting value of 48 was left out of the prediction."},
   {"text": "427.2", "feedback": "The whole expression was multiplied by 8. Only the x term is."}]'::jsonb,
 0, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 30, 'Challenge',
 'A scatterplot rises steeply at first and then flattens out as x grows, never turning back downward. Which regression model is likely to fit it best?',
 '[{"text": "No model can fit a curved pattern", "feedback": "Regression is not limited to straight lines. Several curved models are available."},
   {"text": "Linear", "feedback": "A straight line rises at the same rate the whole way. This pattern changes its rate."},
   {"text": "Quadratic", "feedback": "A quadratic curve turns and comes back down. This one keeps rising while flattening."},
   {"text": "Logarithmic", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatterplots'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 31, 'Advanced',
 'A class of 20 students has a mean score of 70. A new student joins with a score of 91. What is the new mean?',
 '[{"text": "71.05", "feedback": "The extra marks were shared across the wrong number of students."},
   {"text": "74.55", "feedback": "The new total was divided by the old class size rather than the new one."},
   {"text": "80.5", "feedback": "That averages the old mean with the new score. The old mean already stands for twenty students."},
   {"text": "71", "feedback": "Correct."}]'::jsonb,
 3, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 32, 'Advanced',
 'A data set has a mean of 50 but a median of 30. What does this suggest about the data?',
 '[{"text": "A few unusually small values are pulling the mean downward", "feedback": "That would push the mean BELOW the median. Here the mean sits above it."},
   {"text": "The data are symmetric about their centre", "feedback": "Symmetric data have a mean and median that sit on top of each other."},
   {"text": "There must be a calculation error", "feedback": "Nothing is wrong. The two measures often disagree, and the gap is informative."},
   {"text": "A few unusually large values are pulling the mean upward", "feedback": "Correct."}]'::jsonb,
 3, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 33, 'Advanced',
 'In a frequency table of test marks, 6 students scored 5, 4 students scored 7, and n students scored 10. The mean mark is exactly 7. What is n?',
 '[{"text": "n = 6", "feedback": "Substitute it back: the total comes to 118 across 16 students, which is above the target mean."},
   {"text": "n = 4", "feedback": "Correct."},
   {"text": "n = 2", "feedback": "Substitute it back: the total comes to 78 across 12 students, which falls short of the target mean."},
   {"text": "n = 10", "feedback": "That copies the mark rather than solving for the frequency."}]'::jsonb,
 1, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 34, 'Advanced',
 'Why does the mean of a frequency table use the sum of each value times its frequency, divided by the total frequency?',
 '[{"text": "Because the mode has to be found first", "feedback": "The three measures are found independently of one another."},
   {"text": "Because the values are not always whole numbers", "feedback": "Whole numbers or not, the issue is how many people sit behind each value."},
   {"text": "Because a frequency table is already sorted", "feedback": "Sorting matters for the median. It has nothing to do with how the mean is weighted."},
   {"text": "Because each value stands for several data points, not just one", "feedback": "Correct."}]'::jsonb,
 3, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 35, 'Advanced',
 'Find the interquartile range of 4, 7, 9, 12, 15, 18, 21, 24.',
 '[{"text": "27.5", "feedback": "The two quartiles were added. The interquartile range subtracts them."},
   {"text": "20", "feedback": "That is the range, which uses the two extreme values rather than the quartiles."},
   {"text": "13.5", "feedback": "That is the overall median. With eight values it falls between the fourth and fifth."},
   {"text": "11.5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 36, 'Advanced',
 'A data set currently has a maximum of 40. A single new value of 100 is added. Which is affected more, the range or the interquartile range?',
 '[{"text": "Neither changes", "feedback": "At least one measure has to react, because the largest value in the set has moved a long way."},
   {"text": "The range, because it depends only on the extreme values", "feedback": "Correct."},
   {"text": "The interquartile range, because it uses the middle half", "feedback": "Using the middle half is exactly what protects it from one extreme value."},
   {"text": "Both change by the same amount", "feedback": "One of the two is built from the extremes and the other deliberately avoids them."}]'::jsonb,
 1, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 37, 'Advanced',
 'Parallel boxplots compare resting pulse rates. Females: Q1 68, median 74, Q3 80. Males: Q1 62, median 70, Q3 76. What can you conclude?',
 '[{"text": "Nothing can be compared from boxplots", "feedback": "Comparing centre and spread across groups is exactly what parallel boxplots are for."},
   {"text": "The male rates are centred higher", "feedback": "Compare the two medians. The one for males sits four beats lower."},
   {"text": "The female rates are centred higher, and the two middle spreads are similar", "feedback": "Correct."},
   {"text": "The female rates are much more spread out", "feedback": "Work out each middle spread by subtracting the quartiles. They come out within two beats of each other."}]'::jsonb,
 2, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 38, 'Advanced',
 'On a boxplot, what fraction of the data lies below Q1?',
 '[{"text": "It depends on how many values are in the set", "feedback": "The quartiles are defined by fractions of the data, so this holds for every set no matter how large."},
   {"text": "One half", "feedback": "That fraction lies below the MEDIAN. Q1 sits lower than that."},
   {"text": "One quarter", "feedback": "Correct."},
   {"text": "Three quarters", "feedback": "That fraction lies below Q3, at the far end of the box."}]'::jsonb,
 2, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 39, 'Advanced',
 'Opening week revenue and lifetime gross revenue for a set of films have a correlation coefficient of 0.68. How should this be described?',
 '[{"text": "A moderate positive linear correlation", "feedback": "Correct."},
   {"text": "A strong negative correlation", "feedback": "The value is positive, so the two revenues rise together."},
   {"text": "Sixty-eight percent of the films sit exactly on the trend line", "feedback": "The coefficient measures how closely the points follow a line, not how many land on it."},
   {"text": "No correlation", "feedback": "That would need a value close to zero. This one is well away from it."}]'::jsonb,
 0, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 40, 'Advanced',
 'Ice cream sales and drowning numbers show a strong positive correlation across the year. What does this establish?',
 '[{"text": "That buying ice cream causes drownings", "feedback": "A pattern in the data cannot by itself show which way, if either, the influence runs."},
   {"text": "That drownings cause ice cream sales", "feedback": "Reversing the claim does not fix it. Neither direction follows from the correlation alone."},
   {"text": "That the correlation must be a calculation error", "feedback": "The correlation is real. It is the causal reading of it that does not follow."},
   {"text": "Only that the two move together, possibly because of a third factor such as hot weather", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatterplots');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Data'
group by difficulty order by min(sort_order);

-- --- questions_mth1w_u9.sql ---

-- ===========================================================================
-- MTH1W — Unit 9: Financial Literacy — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Simple interest
--   Lesson 2  Compound interest
--   Lesson 3  Appreciation and depreciation
--   Lesson 4  Budgeting
--   Lesson 5  Payment options and loan repayment
--
-- Every money figure in this file was recomputed rather than copied, because
-- two of the worked solutions in the source contain slips: the Rory example
-- in Lesson 1 solves for the total amount as though it were the interest,
-- and one of the Lesson 2 comparison tables is captioned semi-annual when
-- the rate shown is quarterly. The questions here use the corrected values.
--
-- The distractors are the slips the worked solutions keep correcting:
-- returning the total amount when the question asked for the interest,
-- applying a percentage rate to the ORIGINAL value every year instead of to
-- the current one, and dividing a loan principal by the number of payments
-- as though borrowing were free.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Financial literacy';

insert into misconception_labels (tag, label) values
  ('sub-simple-interest',    'Simple interest'),
  ('sub-compound-interest',  'Compound interest'),
  ('sub-appreciation',       'Appreciation and depreciation'),
  ('sub-budgeting',          'Budgeting'),
  ('sub-payment-options',    'Loans, credit and repayment')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 1, 'Easy',
 'Calculate the simple interest on a loan of 10000 dollars at 5 percent per annum for 6 years.',
 '[{"text": "300 dollars", "feedback": "The rate was used as 0.005 rather than 0.05. Five percent is five hundredths."},
   {"text": "3000 dollars", "feedback": "Correct."},
   {"text": "500 dollars", "feedback": "That is one year of interest. The loan runs for six."},
   {"text": "13000 dollars", "feedback": "That is the total owed at the end. The question asks for the interest alone."}]'::jsonb,
 1, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 2, 'Easy',
 'In the simple interest formula I = P x r x t, what does P stand for?',
 '[{"text": "The percentage charged for the use of the money", "feedback": "That is r, the rate, which is written as a decimal."},
   {"text": "The principal, the amount invested or borrowed at the start", "feedback": "Correct."},
   {"text": "The profit made on the investment once it is cashed in", "feedback": "The profit is the interest itself, which is what the formula works out."},
   {"text": "The payment made each month until the whole loan is paid off", "feedback": "Monthly payments belong to a repayment formula. This one has no payments in it."}]'::jsonb,
 1, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 3, 'Easy',
 'Which formula gives the amount in an account when interest is compounded once a year?',
 '[{"text": "A = P(1 + r)^t", "feedback": "Correct."},
   {"text": "A = P(1 + rt)", "feedback": "That is the simple interest version, where the interest never earns interest of its own."},
   {"text": "A = P + rt", "feedback": "That adds a fixed dollar amount each year, which is linear growth rather than compounding."},
   {"text": "A = P(1 - r)^t", "feedback": "The minus sign shrinks the balance. That version models depreciation."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 4, 'Easy',
 'What is 1000 dollars worth after 3 years at 5 percent compounded annually?',
 '[{"text": "1157.63 dollars", "feedback": "Correct."},
   {"text": "1102.50 dollars", "feedback": "That is the balance after only two years."},
   {"text": "3375.00 dollars", "feedback": "The rate was applied as 50 percent rather than 5 percent."},
   {"text": "1150.00 dollars", "feedback": "That is simple interest. Under compounding, each year the interest earns interest too."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 5, 'Easy',
 'Which of these is an example of depreciation?',
 '[{"text": "Gold rising in value", "feedback": "Rising value is appreciation. Depreciation goes the other way."},
   {"text": "A new car losing value every year it is driven", "feedback": "Correct."},
   {"text": "A savings account earning interest", "feedback": "A growing balance is a kind of appreciation."},
   {"text": "A house rising in value over ten years", "feedback": "Rising value is appreciation. Depreciation goes the other way."}]'::jsonb,
 1, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 6, 'Easy',
 'A rookie card is worth 100 dollars now and is expected to gain 20 dollars in value every year. Which equation models its value after t years?',
 '[{"text": "A = 100 + 20t", "feedback": "Correct."},
   {"text": "A = 100(1.20)^t", "feedback": "That grows by 20 PERCENT each year. Here the gain is a fixed 20 dollars."},
   {"text": "A = 100 - 20t", "feedback": "The minus sign makes the value fall. This card is gaining value."},
   {"text": "A = 20 + 100t", "feedback": "The starting value and the yearly gain have swapped places."}]'::jsonb,
 0, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 7, 'Easy',
 'Which of these is a fixed expense in a monthly budget?',
 '[{"text": "A weekend trip", "feedback": "That is discretionary. You can cut it back without losing anything essential."},
   {"text": "Rent", "feedback": "Correct."},
   {"text": "Dining out", "feedback": "That is discretionary. You can cut it back without losing anything essential."},
   {"text": "Concert tickets", "feedback": "That is discretionary. You can cut it back without losing anything essential."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 8, 'Easy',
 'Max has a monthly income of 1146.99 dollars and monthly expenses of 900 dollars. What is his net profit for the month?',
 '[{"text": "2046.99 dollars", "feedback": "The two figures were added. Net profit subtracts expenses from income."},
   {"text": "900.00 dollars", "feedback": "That is what he spends, not what he has left."},
   {"text": "246.99 dollars", "feedback": "Correct."},
   {"text": "-246.99 dollars", "feedback": "The subtraction went the wrong way round. His income is larger than his expenses."}]'::jsonb,
 2, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 9, 'Easy',
 'In the monthly loan payment formula, what does r stand for?',
 '[{"text": "The total amount repaid by the end of the loan", "feedback": "That is what the formula helps you work out, not one of its inputs."},
   {"text": "The annual interest rate, the percentage charged for a year", "feedback": "The payments happen monthly, so the rate has to be scaled down to match them."},
   {"text": "The monthly interest rate, which is the annual rate divided by 12", "feedback": "Correct."},
   {"text": "The number of payments to be made across the whole term of the loan", "feedback": "That is n, the loan term counted in months."}]'::jsonb,
 2, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 10, 'Easy',
 'Why is cash or debit usually a better choice than credit for buying groceries?',
 '[{"text": "Because you spend only money you already have and pay no interest", "feedback": "Correct."},
   {"text": "Because debit cards give more rewards than credit cards", "feedback": "Rewards are usually a credit card feature. The advantage of debit lies elsewhere."},
   {"text": "Because credit cards never charge interest", "feedback": "They do charge interest on any balance not paid off in full."},
   {"text": "Because debit builds your credit score faster", "feedback": "Building a credit score is actually an argument FOR responsible credit card use."}]'::jsonb,
 0, 'sub-payment-options'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 11, 'Medium',
 'Max invests 3240 dollars at 2.4 percent simple interest. How much interest does he earn in 20 years?',
 '[{"text": "155.52 dollars", "feedback": "The rate was used as 0.0024 rather than 0.024."},
   {"text": "77.76 dollars", "feedback": "That is one year of interest. The investment runs for twenty."},
   {"text": "1555.20 dollars", "feedback": "Correct."},
   {"text": "4795.20 dollars", "feedback": "That is the total value of the investment. The question asks for the interest alone."}]'::jsonb,
 2, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 12, 'Medium',
 'Rory invests 750 dollars at 10 percent per annum simple interest. How long until his investment is worth 1000 dollars?',
 '[{"text": "0.3 years", "feedback": "The rate was left out of the division. Interest is principal times rate times time."},
   {"text": "13.3 years", "feedback": "The whole 1000 was treated as interest. Only the 250 dollar GAIN is interest."},
   {"text": "2.5 years", "feedback": "The final value of 1000 was used as the principal. The principal is the amount actually invested."},
   {"text": "3.3 years", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 13, 'Medium',
 'What is 1000 dollars worth after 1 year at 6 percent compounded monthly?',
 '[{"text": "1060.90 dollars", "feedback": "That is the semi-annual result, where interest is added only twice."},
   {"text": "1061.36 dollars", "feedback": "That is the quarterly result, where interest is added four times."},
   {"text": "1061.68 dollars", "feedback": "Correct."},
   {"text": "1060.00 dollars", "feedback": "That is simple interest for the year. Compounding monthly adds a little more."}]'::jsonb,
 2, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 14, 'Medium',
 'At the same annual rate, which compounding frequency leaves you with the most money?',
 '[{"text": "Quarterly", "feedback": "That beats annual compounding, but there is a more frequent option on the list."},
   {"text": "They all give exactly the same amount", "feedback": "More frequent compounding means each period starts with a slightly larger balance."},
   {"text": "Daily", "feedback": "Correct."},
   {"text": "Annually", "feedback": "That adds interest only once a year, so the interest has the least chance to earn interest of its own."}]'::jsonb,
 2, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 15, 'Medium',
 'A car bought for 30000 dollars depreciates by 2000 dollars every year. How long until it is worth 10000 dollars?',
 '[{"text": "10 years", "feedback": "Correct."},
   {"text": "20 years", "feedback": "That is the size of the drop in dollars, not the number of years it takes."},
   {"text": "5 years", "feedback": "After that long the car would still be worth twice the target value."},
   {"text": "15 years", "feedback": "That divides the purchase price by the yearly loss. Only the DROP of 20000 has to be covered."}]'::jsonb,
 0, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 16, 'Medium',
 'A car worth 30000 dollars new is worth 21000 dollars after one year. By what percentage did it depreciate?',
 '[{"text": "21 percent", "feedback": "That reads the remaining value in thousands as a percentage."},
   {"text": "70 percent", "feedback": "That is the percentage of its value the car KEEPS. The question asks how much it lost."},
   {"text": "30 percent", "feedback": "Correct."},
   {"text": "9 percent", "feedback": "That is the drop in thousands of dollars, not a percentage of the original price."}]'::jsonb,
 2, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 17, 'Medium',
 'Arthur has a monthly income of 2100 dollars and monthly expenses totalling 2185 dollars. Is his budget balanced?',
 '[{"text": "No, he has a surplus of 85 dollars", "feedback": "The subtraction went the wrong way. His expenses are the larger of the two."},
   {"text": "No, he has a deficit of 185 dollars", "feedback": "Check the subtraction. The gap between the two totals is smaller than that."},
   {"text": "No, he has a deficit of 85 dollars", "feedback": "Correct."},
   {"text": "Yes, it is exactly balanced", "feedback": "The two totals differ. Subtract one from the other."}]'::jsonb,
 2, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 18, 'Medium',
 'Arthur needs to close an 85 dollar monthly gap. Which adjustment cuts only discretionary spending?',
 '[{"text": "Move somewhere with cheaper monthly rent", "feedback": "Rent is a fixed expense. It is not easy to minimise month to month."},
   {"text": "Cancel the car insurance he pays for every month", "feedback": "Insurance is a fixed expense, and cancelling it creates a much larger risk."},
   {"text": "Cut the amount of money he spends on food each month in half", "feedback": "Food is treated as a fixed expense, because it is essential."},
   {"text": "Reduce his entertainment and gym membership spending", "feedback": "Correct."}]'::jsonb,
 3, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 19, 'Medium',
 'Sarah borrows 15000 dollars at 6 percent compounded monthly over a 5 year term. What is her monthly payment?',
 '[{"text": "312.50 dollars", "feedback": "That spreads the loan over four years rather than five, and still ignores the interest."},
   {"text": "325.00 dollars", "feedback": "Five years of simple interest was added at the start rather than compounding on the falling balance."},
   {"text": "250.00 dollars", "feedback": "That divides the loan by the number of payments, which ignores the interest completely."},
   {"text": "289.99 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 20, 'Medium',
 'Jacob borrows 12000 dollars and repays it at 381.60 dollars a month for 3 years. How much does he repay in total?',
 '[{"text": "13737.60 dollars", "feedback": "Correct."},
   {"text": "4579.20 dollars", "feedback": "That is one year of payments. The term runs for three years."},
   {"text": "12000.00 dollars", "feedback": "That is only the amount he borrowed. The payments come to more than that."},
   {"text": "1737.60 dollars", "feedback": "That is the interest portion. The question asks for everything he hands over."}]'::jsonb,
 0, 'sub-payment-options'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 21, 'Challenge',
 'How long does 2000 dollars have to sit at 4 percent simple interest to earn 560 dollars in interest?',
 '[{"text": "14 years", "feedback": "The rate was halved somewhere. Divide the interest by the principal times the rate."},
   {"text": "7 years", "feedback": "Correct."},
   {"text": "3.5 years", "feedback": "The rate was doubled somewhere. Divide the interest by the principal times the rate."},
   {"text": "28 years", "feedback": "The rate was read as 1 percent rather than 4 percent. Divide the interest by the principal times the rate."}]'::jsonb,
 1, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 22, 'Challenge',
 'An investment of 1200 dollars grows to 1560 dollars in 5 years under simple interest. What is the annual rate?',
 '[{"text": "26 percent", "feedback": "The whole 1560 was treated as interest. Only the growth above the original investment is interest."},
   {"text": "3 percent", "feedback": "The gain was halved somewhere in the division."},
   {"text": "30 percent", "feedback": "That is the total percentage gain across all five years, not the annual rate."},
   {"text": "6 percent", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 23, 'Challenge',
 'Bank A offers 4.8 percent compounded quarterly and Bank B offers 4.6 percent compounded monthly. For 5000 dollars over 3 years, which is better and by roughly how much?',
 '[{"text": "Bank B, by about 31 dollars", "feedback": "The more frequent compounding does not make up for the lower rate here."},
   {"text": "Bank A, by about 31 dollars", "feedback": "Correct."},
   {"text": "Bank A, by about 200 dollars", "feedback": "The direction is right, but the gap between the two is far smaller than that."},
   {"text": "They come out the same", "feedback": "Work each one out separately. The two totals differ by a modest amount."}]'::jsonb,
 1, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 24, 'Challenge',
 'You need 3000 dollars in 3 years. An account pays 3.2 percent compounded monthly. How much do you need to invest now?',
 '[{"text": "2712.00 dollars", "feedback": "That subtracts three years of simple interest instead of dividing by the growth factor."},
   {"text": "2905.64 dollars", "feedback": "Only one year of growth was divided out. The money has three years to grow."},
   {"text": "3300.00 dollars", "feedback": "That grows the target instead of working backwards from it. You need LESS than 3000 today."},
   {"text": "2725.74 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 25, 'Challenge',
 'A car bought for 30000 dollars keeps 70 percent of its value each year. What is it worth after 10 years?',
 '[{"text": "847.43 dollars", "feedback": "Correct."},
   {"text": "0 dollars", "feedback": "That treats the loss as a fixed 30 percent of the ORIGINAL price each year. It is 30 percent of the CURRENT value."},
   {"text": "21000.00 dollars", "feedback": "That is its value after one year."},
   {"text": "1210.61 dollars", "feedback": "That is its value after nine years. One more year of depreciation is still to come."}]'::jsonb,
 0, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 26, 'Challenge',
 'Over 10 years, which grows more: 100 dollars gaining 20 dollars a year, or 100 dollars gaining 20 percent a year?',
 '[{"text": "The fixed 20 dollars a year", "feedback": "A fixed gain adds the same amount every year. A percentage gain grows along with the value."},
   {"text": "They reach the same value", "feedback": "They match in the first year only. After that the percentage version pulls ahead."},
   {"text": "The percentage, but only after about 20 years", "feedback": "The crossover comes much sooner than that. Work out both at 10 years."},
   {"text": "The percentage, reaching about 619 dollars against 300 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 27, 'Challenge',
 'Max earns 1146.99 dollars a month and wants to save 20 percent of it. His rent is 500, food 250 and transport 50 dollars. How much is left for discretionary spending?',
 '[{"text": "232.29 dollars", "feedback": "Only 10 percent was set aside. He wants to save twice that."},
   {"text": "117.59 dollars", "feedback": "Correct."},
   {"text": "2.89 dollars", "feedback": "30 percent was set aside rather than 20."},
   {"text": "346.99 dollars", "feedback": "The savings were never set aside. Twenty percent of his income has to come off as well."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 28, 'Challenge',
 'Why should every dollar of income be accounted for in a budget, even the leftover money?',
 '[{"text": "So that income always works out to exactly zero on paper", "feedback": "The aim is not to reach zero. It is to give every dollar a job."},
   {"text": "Because fixed expenses change from one month to the next", "feedback": "Fixed expenses are the ones that stay steady. That is what makes them fixed."},
   {"text": "Because banks require you to hand in a complete budget before they will open an account", "feedback": "No bank asks for this. The reason is about your own money, not theirs."},
   {"text": "So that the leftover money is deliberately saved or invested rather than quietly spent", "feedback": "Correct."}]'::jsonb,
 3, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 29, 'Challenge',
 'Emma owes 5000 dollars on a credit card charging 18 percent compounded monthly. She plans to clear it in 2 years with equal monthly payments. What is each payment?',
 '[{"text": "249.62 dollars", "feedback": "Correct."},
   {"text": "283.33 dollars", "feedback": "That charges 18 percent on the full balance for both years. The balance falls as she pays it down."},
   {"text": "312.50 dollars", "feedback": "That spreads the debt over sixteen months rather than twenty-four, and still ignores the interest."},
   {"text": "208.33 dollars", "feedback": "That divides the balance by the number of payments, which ignores the interest completely."}]'::jsonb,
 0, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 30, 'Challenge',
 'Emma pays 249.62 dollars a month for 24 months to clear a 5000 dollar credit card balance. Roughly how much interest does she pay?',
 '[{"text": "About 900 dollars", "feedback": "Close, but work it out exactly: total the payments, then take off what she borrowed."},
   {"text": "About 1800 dollars", "feedback": "That charges 18 percent on the full 5000 for both years. The balance shrinks as she pays."},
   {"text": "None, because she clears the balance in full", "feedback": "Clearing a balance over time still costs interest along the way. Only paying immediately avoids it."},
   {"text": "About 990 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-payment-options'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 31, 'Advanced',
 'How long does any amount of money take to double at 5 percent simple interest?',
 '[{"text": "14 years", "feedback": "That rule of thumb belongs to COMPOUND interest. Simple interest takes longer."},
   {"text": "5 years", "feedback": "That copies the rate. Doubling means the interest has to grow to equal the principal."},
   {"text": "20 years", "feedback": "Correct."},
   {"text": "10 years", "feedback": "After that long the interest would equal only half the original amount."}]'::jsonb,
 2, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 32, 'Advanced',
 'Compare 5000 dollars over 10 years at 6 percent simple interest against 6 percent compounded annually. What is the difference?',
 '[{"text": "Compounding wins by about 3000 dollars", "feedback": "That is the whole simple interest amount, not the gap between the two methods."},
   {"text": "Simple interest wins by about 954 dollars", "feedback": "Compounding lets the interest earn interest, so it is the larger of the two."},
   {"text": "Compounding wins by about 954 dollars", "feedback": "Correct."},
   {"text": "They come out equal, because the rate is the same", "feedback": "The rate matches, but simple interest never pays interest on the interest already earned."}]'::jsonb,
 2, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 33, 'Advanced',
 'What is 2000 dollars worth after 4 years at 5 percent compounded quarterly?',
 '[{"text": "2439.78 dollars", "feedback": "Correct."},
   {"text": "2400.00 dollars", "feedback": "That is simple interest. Compounding adds a little more."},
   {"text": "2431.01 dollars", "feedback": "That compounds only once a year. Quarterly means four times."},
   {"text": "2441.79 dollars", "feedback": "That compounds monthly, which is more often than the question asks."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 34, 'Advanced',
 'If you double how often interest is compounded per year, does the interest you earn double?',
 '[{"text": "No, the gain is much smaller than that", "feedback": "Correct."},
   {"text": "It depends entirely on the size of the principal", "feedback": "The principal scales everything equally, so it does not change the comparison."},
   {"text": "Yes, exactly", "feedback": "The annual rate is split across more periods, so each period pays proportionally less."},
   {"text": "No, the interest is halved instead", "feedback": "More frequent compounding never lowers the total. It raises it slightly."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 35, 'Advanced',
 'A house bought for 400000 dollars appreciates at 4 percent a year. What is it worth after 12 years, to the nearest dollar?',
 '[{"text": "592000 dollars", "feedback": "That adds 4 percent of the ORIGINAL price twelve times. Each year the percentage applies to the current value."},
   {"text": "416000 dollars", "feedback": "That is the value after one year only."},
   {"text": "615782 dollars", "feedback": "That compounds for eleven years rather than twelve."},
   {"text": "640413 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 36, 'Advanced',
 'A laptop bought for 1500 dollars depreciates 25 percent a year. After how many whole years is it worth less than 500 dollars?',
 '[{"text": "3 years", "feedback": "Work out the value at that point: it is still above the 500 dollar mark, though not by much."},
   {"text": "4 years", "feedback": "Correct."},
   {"text": "5 years", "feedback": "It drops below the mark before that, so this is one year later than needed."},
   {"text": "2 years", "feedback": "After that long it is still worth well over 800 dollars."}]'::jsonb,
 1, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 37, 'Advanced',
 'Someone earns 3200 dollars a month but spends 3400 dollars. What is the most sensible first step?',
 '[{"text": "Stop paying rent until the budget recovers", "feedback": "Rent is a fixed expense with serious consequences if it goes unpaid."},
   {"text": "Cut discretionary spending such as dining out and entertainment", "feedback": "Correct."},
   {"text": "Nothing, a small monthly deficit is not a problem", "feedback": "A deficit repeats every month, so it compounds into a large shortfall over a year."},
   {"text": "Put the 200 dollar shortfall on a credit card each month", "feedback": "That turns a monthly gap into a growing debt that charges interest on top."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 38, 'Advanced',
 'A budget shows a surplus of 400 dollars a month. What is the best use of it?',
 '[{"text": "Nothing, a surplus means the budget was worked out wrongly", "feedback": "A surplus is the goal of a healthy budget, not an error in it."},
   {"text": "Save or invest it so it earns interest and covers unexpected costs", "feedback": "Correct."},
   {"text": "Leave it sitting in the chequing account and do not record it", "feedback": "Unrecorded money tends to get spent without a decision being made about it."},
   {"text": "Raise discretionary spending until the surplus is used up", "feedback": "That converts a real advantage into ordinary spending and leaves nothing for emergencies."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 39, 'Advanced',
 'Sarah could take her 15000 dollar loan at 6 percent compounded monthly over 7 years instead of 5. What happens?',
 '[{"text": "Both the monthly payment and the total interest fall", "feedback": "Stretching a loan out means the balance carries interest for longer, so the total cost goes up."},
   {"text": "Both the monthly payment and the total interest rise", "feedback": "Spreading the same principal over more payments makes each one smaller, not larger."},
   {"text": "The monthly payment falls and the total interest stays the same", "feedback": "Interest is charged on the outstanding balance each month, so more months means more interest."},
   {"text": "The monthly payment falls but the total interest paid rises", "feedback": "Correct."}]'::jsonb,
 3, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 40, 'Advanced',
 'Jacob borrows 12000 dollars at 9 percent compounded monthly for 3 years, paying 381.60 dollars a month. How much interest does he pay in total?',
 '[{"text": "13737.60 dollars", "feedback": "That is everything he hands over. The interest is what is left after the loan itself is taken off."},
   {"text": "1080.00 dollars", "feedback": "That is one year of interest on the full balance. The loan runs for three years."},
   {"text": "1737.60 dollars", "feedback": "Correct."},
   {"text": "3240.00 dollars", "feedback": "That charges 9 percent on the full 12000 for all three years. The balance falls with every payment."}]'::jsonb,
 2, 'sub-payment-options');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Financial literacy'
group by difficulty order by min(sort_order);
