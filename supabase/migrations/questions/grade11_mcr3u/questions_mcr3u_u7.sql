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
-- RUN ORDER: astro_math_assist_setup.sql -> this file -> figures_mcr3u.sql.
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
