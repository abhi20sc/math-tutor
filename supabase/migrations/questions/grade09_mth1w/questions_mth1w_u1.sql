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
