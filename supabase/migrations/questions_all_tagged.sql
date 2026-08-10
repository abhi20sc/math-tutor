-- ===========================================================================
-- All 200 questions, tagged  —  Grades 9 to 12
-- ===========================================================================
-- Every question from the four grade files, in one place, now carrying a
-- misconception_tag.
--
-- Run AFTER supabase_full_setup.sql, which creates the tables and the
-- misconception_tag column this file writes into.
--
-- Safe to re-run. Each grade section deletes only its own grade first, so
-- running the whole file replaces all 200 questions and nothing else. Student
-- attempts are untouched: attempts key on (grade, unit, sort_order), never on
-- the question row id, precisely so that re-running this file cannot orphan
-- or delete a single piece of student history.
--
-- ---------------------------------------------------------------------------
-- About misconception_tag
-- ---------------------------------------------------------------------------
-- A short slug naming the specific mistake a question is built to catch. It
-- is recorded on an attempt only when the student taps a WRONG option, since
-- a correct answer represents no misconception.
--
-- Slugs are reused across grades wherever the underlying error is the same.
-- That reuse is the whole point: 'sign-error-negatives' appearing in Grade 9
-- arithmetic and 'distributive-sign-error' in Grade 9 algebra and
-- 'quadratic-formula-sign' in Grade 11 are related failures, and a teacher
-- looking at the misconception_counts view can see a student who drops signs
-- everywhere rather than four unrelated bad scores.
--
-- 200 questions, 166 distinct slugs.
--
-- Grade  Course  Units  Questions
--   9    MTH1W     5        50
--  10    MPM2D     5        50
--  11    MCR3U     5        50
--  12    MHF4U     5        50

-- ===========================================================================
-- Grade 9 — MTH1W Mathematics (destreamed)
-- ===========================================================================

delete from questions where grade = 9;

insert into questions
  (grade, unit_order, sort_order, difficulty, course_code, unit, prompt,
   correct_index, options, misconception_tag)
values

-- ------ Unit 1: Number sense ------
(9, 1, 1, 'Easy', 'MTH1W', 'Number sense',
 'Evaluate:   −3 + 7 × 2', 2,
 '[
   {"text": "8", "feedback": "It looks like you worked left to right, doing −3 + 7 first. Multiplication comes before addition."},
   {"text": "−14", "feedback": "This adds first, then multiplies. Check the order of operations: which comes first?"},
   {"text": "11", "feedback": "Correct. Multiplication first gives 7 × 2 = 14, then −3 + 14 = 11."},
   {"text": "17", "feedback": "Close, but check the sign on the 3. You are adding it rather than subtracting."}
 ]'::jsonb,
 'order-of-operations'),
(9, 1, 2, 'Easy', 'MTH1W', 'Number sense',
 'Evaluate:   (−2)³', 1,
 '[
   {"text": "8", "feedback": "The size is right, but check the sign. An odd number of negative factors keeps the result negative."},
   {"text": "−8", "feedback": "Correct. (−2) × (−2) × (−2) gives 4 × (−2) = −8."},
   {"text": "−6", "feedback": "That is −2 × 3. The exponent means multiply −2 by itself three times, not multiply by 3."},
   {"text": "6", "feedback": "This multiplies rather than using the exponent, and drops the sign as well."}
 ]'::jsonb,
 'negative-base-exponent-parity'),
(9, 1, 3, 'Easy', 'MTH1W', 'Number sense',
 'Evaluate:   3/4 + 1/6', 3,
 '[
   {"text": "4/10", "feedback": "Adding the tops and the bottoms separately does not work for fractions. You need a common denominator first."},
   {"text": "1", "feedback": "Check the size: 3/4 alone is already 0.75, and 1/6 is small, so the total lands just under 1."},
   {"text": "4/6", "feedback": "This is smaller than 3/4 on its own, so something has gone wrong. Adding cannot make the total shrink."},
   {"text": "11/12", "feedback": "Correct. The common denominator is 12, giving 9/12 + 2/12 = 11/12."}
 ]'::jsonb,
 'fraction-common-denominator'),
(9, 1, 4, 'Easy', 'MTH1W', 'Number sense',
 'Evaluate:   2⁴ ÷ 2²', 0,
 '[
   {"text": "4", "feedback": "Correct. 16 ÷ 4 = 4. You can also subtract the exponents: 2⁴⁻² = 2² = 4."},
   {"text": "2", "feedback": "It looks like you divided the exponents, 4 ÷ 2. When dividing powers of the same base you subtract them instead."},
   {"text": "8", "feedback": "That is 2³. Check the subtraction of the exponents once more."},
   {"text": "64", "feedback": "That is 2⁶, which comes from adding the exponents. Adding is for multiplying powers, not dividing."}
 ]'::jsonb,
 'exponent-division-rule'),
(9, 1, 5, 'Medium', 'MTH1W', 'Number sense',
 'Which of these is the largest?', 1,
 '[
   {"text": "3/5", "feedback": "As a decimal this is 0.6. Convert the others the same way and compare."},
   {"text": "0.7", "feedback": "Correct. As decimals: 3/5 is 0.6, 65% is 0.65, and 0.7 is the largest."},
   {"text": "65%", "feedback": "This is 0.65, which is bigger than 3/5 but not the largest of the three."},
   {"text": "They are all equal", "feedback": "Convert each to a decimal and you will see three different values."}
 ]'::jsonb,
 'decimal-fraction-comparison'),
(9, 1, 6, 'Easy', 'MTH1W', 'Number sense',
 'Write the ratio 18 : 24 in simplest form.', 2,
 '[
   {"text": "9 : 12", "feedback": "You divided by 2, which helps, but both numbers can still be divided further."},
   {"text": "18 : 24", "feedback": "Both numbers share a common factor, so this can be reduced."},
   {"text": "3 : 4", "feedback": "Correct. Dividing both by 6, their greatest common factor, gives 3 : 4."},
   {"text": "6 : 8", "feedback": "You divided by 3. There is still a common factor of 2 left in both numbers."}
 ]'::jsonb,
 'ratio-not-fully-simplified'),
(9, 1, 7, 'Easy', 'MTH1W', 'Number sense',
 'Evaluate:   (−12) ÷ (−3) + 5', 0,
 '[
   {"text": "9", "feedback": "Correct. A negative divided by a negative gives +4, and 4 + 5 = 9."},
   {"text": "1", "feedback": "Check the sign of the division. Two negatives divided give a positive result."},
   {"text": "−9", "feedback": "The size is right but the sign is not. Dividing two negatives gives a positive."},
   {"text": "−1.4", "feedback": "It looks like the addition happened before the division. Division comes first."}
 ]'::jsonb,
 'sign-error-negatives'),
(9, 1, 8, 'Easy', 'MTH1W', 'Number sense',
 'What is 15% of 80?', 2,
 '[
   {"text": "15", "feedback": "That is the percentage itself, not the amount. You need 15% of the 80."},
   {"text": "5.33", "feedback": "This divides 80 by 15. Finding a percentage means multiplying instead."},
   {"text": "12", "feedback": "Correct. 15% is 0.15, and 0.15 × 80 = 12."},
   {"text": "120", "feedback": "That is 15 × 8. Check where the decimal point goes when converting 15% to a decimal."}
 ]'::jsonb,
 'percent-as-decimal'),
(9, 1, 9, 'Medium', 'MTH1W', 'Number sense',
 'Evaluate:   5 − 2(3 − 7)', 3,
 '[
   {"text": "−3", "feedback": "You worked left to right. The bracket has to be done first, before the subtraction."},
   {"text": "12", "feedback": "Close. Recheck the sign: 3 − 7 is negative, and subtracting a negative adds."},
   {"text": "−13", "feedback": "The size is right but the sign is flipped. Subtracting 2 × (−4) means subtracting a negative."},
   {"text": "13", "feedback": "Correct. The bracket gives −4, then 2 × (−4) = −8, and 5 − (−8) = 13."}
 ]'::jsonb,
 'distributive-sign-error'),
(9, 1, 10, 'Medium', 'MTH1W', 'Number sense',
 'Between which two whole numbers does √50 lie?', 1,
 '[
   {"text": "6 and 7", "feedback": "6² is 36 and 7² is 49. Both are below 50, so the root is larger than this range."},
   {"text": "7 and 8", "feedback": "Correct. 7² = 49 and 8² = 64, and 50 sits between them."},
   {"text": "24 and 26", "feedback": "That is roughly half of 50. A square root is much smaller than half for numbers this size."},
   {"text": "8 and 9", "feedback": "8² is already 64, which is well past 50. Try one pair lower."}
 ]'::jsonb,
 'square-root-estimation'),

-- ------ Unit 2: Algebraic expressions ------
(9, 2, 1, 'Easy', 'MTH1W', 'Algebraic expressions',
 'Simplify:   3x + 5x − 2x', 0,
 '[
   {"text": "6x", "feedback": "Correct. The coefficients combine: 3 + 5 − 2 = 6."},
   {"text": "10x", "feedback": "It looks like all three were added. The last term is being subtracted."},
   {"text": "6x³", "feedback": "The exponent should not change. Adding like terms combines the numbers in front, not the powers."},
   {"text": "8x", "feedback": "This adds the first two but leaves out the −2x. All three terms need combining."}
 ]'::jsonb,
 'combines-unlike-terms'),
(9, 2, 2, 'Easy', 'MTH1W', 'Algebraic expressions',
 'Expand:   4(x + 3)', 1,
 '[
   {"text": "4x + 3", "feedback": "The 4 has to multiply everything inside the bracket, not just the first term."},
   {"text": "4x + 12", "feedback": "Correct. The 4 multiplies both terms: 4 × x and 4 × 3."},
   {"text": "7x", "feedback": "You added the 4 and 3. Distributing means multiplying, and x and 3 are not like terms anyway."},
   {"text": "4x + 7", "feedback": "The 4 was added to the 3 rather than multiplied by it."}
 ]'::jsonb,
 'distributive-incomplete'),
(9, 2, 3, 'Medium', 'MTH1W', 'Algebraic expressions',
 'Simplify:   2(3x − 1) + 5', 2,
 '[
   {"text": "6x + 4", "feedback": "Recheck the constant. Expanding gives −2, and −2 + 5 is not 4."},
   {"text": "6x − 1 + 5", "feedback": "The 2 needs to multiply the −1 as well as the 3x, and then the constants combine."},
   {"text": "6x + 3", "feedback": "Correct. Expanding gives 6x − 2, then −2 + 5 = 3."},
   {"text": "11x − 2", "feedback": "The 5 was combined with the 6x, but they are not like terms — one has an x and one does not."}
 ]'::jsonb,
 'distributive-then-collect'),
(9, 2, 4, 'Easy', 'MTH1W', 'Algebraic expressions',
 'Evaluate   3a − 2b   when a = 4 and b = 5.', 3,
 '[
   {"text": "22", "feedback": "It looks like the two products were added. The expression subtracts the second one."},
   {"text": "−2", "feedback": "Check which value goes with which letter. a is 4 and b is 5."},
   {"text": "7", "feedback": "This substitutes without multiplying, giving something like 4 + 5 − 2. Each letter has a coefficient."},
   {"text": "2", "feedback": "Correct. 3 × 4 = 12 and 2 × 5 = 10, so 12 − 10 = 2."}
 ]'::jsonb,
 'substitution-sign-error'),
(9, 2, 5, 'Easy', 'MTH1W', 'Algebraic expressions',
 'Solve for x:   2x + 7 = 19', 1,
 '[
   {"text": "13", "feedback": "You subtracted 7 but stopped there. The x is still multiplied by 2."},
   {"text": "6", "feedback": "Correct. Subtracting 7 gives 2x = 12, then dividing by 2 gives x = 6."},
   {"text": "26", "feedback": "It looks like 7 was added instead of subtracted. Do the opposite of what the equation does."},
   {"text": "12", "feedback": "That is 2x, not x. One step remains."}
 ]'::jsonb,
 'inverse-operation-order'),
(9, 2, 6, 'Medium', 'MTH1W', 'Algebraic expressions',
 'Solve for x:   5x − 3 = 2x + 12', 2,
 '[
   {"text": "3", "feedback": "Substitute 3 back in: the left side gives 12 and the right gives 18. Not equal, so try again."},
   {"text": "9", "feedback": "Check the step where you collect the x terms. 5x − 2x gives 3x, not x."},
   {"text": "5", "feedback": "Correct. Collecting terms gives 3x = 15, so x = 5. Both sides then equal 22."},
   {"text": "15", "feedback": "That is 3x. You still need to divide by the coefficient."}
 ]'::jsonb,
 'variables-both-sides'),
(9, 2, 7, 'Easy', 'MTH1W', 'Algebraic expressions',
 'Simplify:   x² × x³', 0,
 '[
   {"text": "x⁵", "feedback": "Correct. Multiplying powers of the same base means adding the exponents: 2 + 3 = 5."},
   {"text": "x⁶", "feedback": "You multiplied the exponents. That rule is for a power raised to another power, not for multiplying."},
   {"text": "2x⁵", "feedback": "The exponent is right, but no coefficient appears. There is nothing to add out front."},
   {"text": "x", "feedback": "That comes from subtracting the exponents, which is the rule for dividing rather than multiplying."}
 ]'::jsonb,
 'exponent-multiplication-rule'),
(9, 2, 8, 'Easy', 'MTH1W', 'Algebraic expressions',
 'Solve for x:   x ÷ 4 = 3', 2,
 '[
   {"text": "0.75", "feedback": "This divides 3 by 4. To undo a division you multiply instead."},
   {"text": "7", "feedback": "It looks like 4 was added to 3. The equation divides, so undo it with multiplication."},
   {"text": "12", "feedback": "Correct. Multiplying both sides by 4 gives x = 12, and 12 ÷ 4 = 3."},
   {"text": "3", "feedback": "Substitute this back: 3 ÷ 4 is 0.75, not 3."}
 ]'::jsonb,
 'inverse-operation-direction'),
(9, 2, 9, 'Medium', 'MTH1W', 'Algebraic expressions',
 'Expand:   −3(2x − 5)', 1,
 '[
   {"text": "−6x − 15", "feedback": "The sign on the second term needs care. A negative times a negative gives a positive."},
   {"text": "−6x + 15", "feedback": "Correct. −3 × 2x = −6x, and −3 × −5 = +15."},
   {"text": "6x + 15", "feedback": "Both signs flipped. Only the second one changes, because it multiplies two negatives."},
   {"text": "−6x − 5", "feedback": "The −3 has to multiply the −5 as well, not just the first term."}
 ]'::jsonb,
 'distributive-sign-error'),
(9, 2, 10, 'Medium', 'MTH1W', 'Algebraic expressions',
 'Solve for x:   3(x − 2) = 12', 3,
 '[
   {"text": "2", "feedback": "Substitute back: 3(2 − 2) gives 0, not 12."},
   {"text": "10", "feedback": "It looks like 2 was added to 12 without dealing with the 3 outside the bracket."},
   {"text": "4", "feedback": "Close. You divided by 3 correctly to get x − 2 = 4, but there is one step left."},
   {"text": "6", "feedback": "Correct. Dividing by 3 gives x − 2 = 4, then adding 2 gives x = 6."}
 ]'::jsonb,
 'bracket-before-divide'),

-- ------ Unit 3: Linear relations ------
(9, 3, 1, 'Easy', 'MTH1W', 'Linear relations',
 'What is the slope of   y = 4x − 7 ?', 0,
 '[
   {"text": "4", "feedback": "Correct. In y = mx + b the slope is m, the number multiplying x."},
   {"text": "−7", "feedback": "That is the y-intercept, where the line crosses the vertical axis."},
   {"text": "7", "feedback": "That is the intercept with its sign changed. The slope is elsewhere in the equation."},
   {"text": "4x", "feedback": "Close, but the slope is just the number. The x is not part of it."}
 ]'::jsonb,
 'slope-vs-intercept-confusion'),
(9, 3, 2, 'Easy', 'MTH1W', 'Linear relations',
 'What is the y-intercept of   y = −2x + 5 ?', 1,
 '[
   {"text": "−2", "feedback": "That is the slope, which tells you how steep the line is rather than where it starts."},
   {"text": "5", "feedback": "Correct. Setting x = 0 gives y = 5, so the line crosses the y-axis there."},
   {"text": "2", "feedback": "That is the slope without its sign. The intercept is the constant on the end."},
   {"text": "−5", "feedback": "Right number, wrong sign. The 5 is being added, not subtracted."}
 ]'::jsonb,
 'reads-sign-from-equation'),
(9, 3, 3, 'Easy', 'MTH1W', 'Linear relations',
 'Find the slope of the line through (1, 2) and (3, 8).', 2,
 '[
   {"text": "2", "feedback": "That is the run, the change in x. Slope compares it to the rise."},
   {"text": "1/3", "feedback": "The fraction is upside down. Slope is rise over run."},
   {"text": "3", "feedback": "Correct. The rise is 8 − 2 = 6, the run is 3 − 1 = 2, and 6 ÷ 2 = 3."},
   {"text": "6", "feedback": "That is the rise on its own. It still needs comparing to the run."}
 ]'::jsonb,
 'slope-formula-inverted'),
(9, 3, 4, 'Easy', 'MTH1W', 'Linear relations',
 'Is the point (2, 5) on the line   y = 2x + 1 ?', 0,
 '[
   {"text": "Yes", "feedback": "Correct. Substituting x = 2 gives 2(2) + 1 = 5, which matches the y-value."},
   {"text": "No", "feedback": "Try substituting x = 2 into the equation and compare the result to 5."},
   {"text": "Only if the line is extended", "feedback": "A straight line already continues forever in both directions, so this is not a factor."},
   {"text": "There is not enough information", "feedback": "There is enough — substitute the x-value and see whether the y-value comes out right."}
 ]'::jsonb,
 'point-verification'),
(9, 3, 5, 'Easy', 'MTH1W', 'Linear relations',
 'Write the equation of a line with slope 2 and y-intercept −3.', 1,
 '[
   {"text": "y = −3x + 2", "feedback": "The slope and the intercept have swapped places. In y = mx + b, which one multiplies x?"},
   {"text": "y = 2x − 3", "feedback": "Correct. The slope 2 goes in front of x, and the intercept −3 goes on the end."},
   {"text": "y = 2x + 3", "feedback": "Almost. Check the sign on the intercept — it is below the origin."},
   {"text": "y = 2 − 3x", "feedback": "This has slope −3 and intercept 2, which is the two values the wrong way round."}
 ]'::jsonb,
 'slope-intercept-form-order'),
(9, 3, 6, 'Medium', 'MTH1W', 'Linear relations',
 'A plumber charges a $50 call-out fee plus $40 per hour. What is the cost of a 3 hour job?', 2,
 '[
   {"text": "$120", "feedback": "This is the hourly charge only. The call-out fee is paid on top."},
   {"text": "$90", "feedback": "It looks like the $40 was charged once rather than for each of the three hours."},
   {"text": "$170", "feedback": "Correct. Three hours at $40 is $120, plus the $50 fee gives $170."},
   {"text": "$270", "feedback": "This charges the $50 fee for each hour as well. The call-out fee is a one-off."}
 ]'::jsonb,
 'confuses-fixed-and-rate'),
(9, 3, 7, 'Easy', 'MTH1W', 'Linear relations',
 'In the relation   C = 40h + 50,   what does the 50 represent?', 3,
 '[
   {"text": "The cost per hour", "feedback": "That is the 40, the number attached to h. The 50 stands apart from h."},
   {"text": "The number of hours", "feedback": "Hours are represented by h, the variable. The 50 is a fixed number."},
   {"text": "The total cost", "feedback": "The total cost is C, which changes as h changes. The 50 stays the same."},
   {"text": "The fixed starting cost", "feedback": "Correct. When h = 0 the cost is already 50, so it is the fixed or initial value."}
 ]'::jsonb,
 'confuses-fixed-and-rate'),
(9, 3, 8, 'Medium', 'MTH1W', 'Linear relations',
 'What does a line with slope 0 look like?', 0,
 '[
   {"text": "Horizontal", "feedback": "Correct. Zero slope means no rise for any run, so the line stays level."},
   {"text": "Vertical", "feedback": "A vertical line has an undefined slope, because the run is zero and you cannot divide by it."},
   {"text": "A 45 degree diagonal", "feedback": "That is slope 1, where the rise equals the run."},
   {"text": "A curve", "feedback": "Any equation of the form y = mx + b graphs as a straight line, whatever m is."}
 ]'::jsonb,
 'zero-slope-vs-undefined'),
(9, 3, 9, 'Medium', 'MTH1W', 'Linear relations',
 'Where does   y = 3x − 6   cross the x-axis?', 1,
 '[
   {"text": "(0, −6)", "feedback": "That is the y-intercept, found by setting x = 0. Crossing the x-axis means y = 0 instead."},
   {"text": "(2, 0)", "feedback": "Correct. Setting y = 0 gives 3x = 6, so x = 2."},
   {"text": "(−2, 0)", "feedback": "Check the sign. Solving 3x − 6 = 0 means adding 6 to both sides."},
   {"text": "(6, 0)", "feedback": "It looks like the division by 3 was missed after moving the 6 across."}
 ]'::jsonb,
 'intercept-solves-wrong-variable'),
(9, 3, 10, 'Easy', 'MTH1W', 'Linear relations',
 'What is the slope of any line parallel to   y = 5x + 1 ?', 2,
 '[
   {"text": "1", "feedback": "That is the y-intercept. Parallel lines can have any intercept — it is the slope that must match."},
   {"text": "−1/5", "feedback": "That is the perpendicular slope, which gives a line crossing at a right angle instead."},
   {"text": "5", "feedback": "Correct. Parallel lines have equal slopes, so any line parallel to this one also has slope 5."},
   {"text": "−5", "feedback": "This line would slope downwards while the original slopes up, so they would cross rather than stay parallel."}
 ]'::jsonb,
 'parallel-slope'),

-- ------ Unit 4: Geometry and measurement ------
(9, 4, 1, 'Easy', 'MTH1W', 'Geometry and measurement',
 'Find the area of a triangle with base 10 cm and height 6 cm.', 1,
 '[
   {"text": "60 cm²", "feedback": "That is base times height, which gives the area of a rectangle. A triangle is half of that."},
   {"text": "30 cm²", "feedback": "Correct. Area is half the base times the height: ½ × 10 × 6 = 30."},
   {"text": "16 cm²", "feedback": "That is base plus height. Area needs multiplication, not addition."},
   {"text": "32 cm²", "feedback": "This looks like the perimeter of something. Area of a triangle uses base and height multiplied, then halved."}
 ]'::jsonb,
 'forgets-half-in-triangle-area'),
(9, 4, 2, 'Easy', 'MTH1W', 'Geometry and measurement',
 'Find the circumference of a circle with radius 5 cm. Use π ≈ 3.14.', 2,
 '[
   {"text": "15.7 cm", "feedback": "This used the radius where the diameter belongs. Circumference is π times the diameter."},
   {"text": "78.5 cm", "feedback": "That is the area, πr². Circumference measures the distance around the edge."},
   {"text": "31.4 cm", "feedback": "Correct. C = 2πr = 2 × 3.14 × 5 = 31.4 cm."},
   {"text": "10 cm", "feedback": "That is the diameter. There is still a π to apply."}
 ]'::jsonb,
 'circumference-vs-area'),
(9, 4, 3, 'Medium', 'MTH1W', 'Geometry and measurement',
 'Find the area of a circle with radius 4 cm. Use π ≈ 3.14.', 0,
 '[
   {"text": "50.24 cm²", "feedback": "Correct. A = πr² = 3.14 × 16 = 50.24 cm²."},
   {"text": "25.12 cm²", "feedback": "That is the circumference, 2πr. Area squares the radius instead of doubling it."},
   {"text": "12.56 cm²", "feedback": "This is π times the radius without squaring it. The r has an exponent."},
   {"text": "100.48 cm²", "feedback": "It looks like the radius was doubled to 8 before squaring. Use the radius as given."}
 ]'::jsonb,
 'radius-not-squared'),
(9, 4, 4, 'Easy', 'MTH1W', 'Geometry and measurement',
 'Find the volume of a rectangular prism measuring 3 cm by 4 cm by 5 cm.', 3,
 '[
   {"text": "12 cm³", "feedback": "This multiplies only two of the three dimensions. Volume needs all three."},
   {"text": "24 cm³", "feedback": "Check your multiplication of all three numbers once more."},
   {"text": "94 cm³", "feedback": "That is the surface area, the total of all six faces. Volume is the space inside."},
   {"text": "60 cm³", "feedback": "Correct. Volume is length × width × height: 3 × 4 × 5 = 60 cm³."}
 ]'::jsonb,
 'volume-vs-surface-area'),
(9, 4, 5, 'Easy', 'MTH1W', 'Geometry and measurement',
 'Two angles in a triangle are 50° and 60°. What is the third angle?', 2,
 '[
   {"text": "110°", "feedback": "That is the two given angles added together. The third is what remains from the total."},
   {"text": "50°", "feedback": "Check the total: the three angles in a triangle must add to 180°."},
   {"text": "70°", "feedback": "Correct. 180 − 50 − 60 = 70°."},
   {"text": "250°", "feedback": "This adds when it should subtract. A single angle in a triangle cannot exceed 180°."}
 ]'::jsonb,
 'angle-sum-triangle'),
(9, 4, 6, 'Easy', 'MTH1W', 'Geometry and measurement',
 'What do the interior angles of a quadrilateral add up to?', 1,
 '[
   {"text": "180°", "feedback": "That is the total for a triangle. A quadrilateral splits into two triangles."},
   {"text": "360°", "feedback": "Correct. A quadrilateral can be divided into two triangles, so 2 × 180° = 360°."},
   {"text": "90°", "feedback": "That is a single right angle, not the total of four angles."},
   {"text": "540°", "feedback": "That is the total for a pentagon, which splits into three triangles rather than two."}
 ]'::jsonb,
 'angle-sum-polygon'),
(9, 4, 7, 'Easy', 'MTH1W', 'Geometry and measurement',
 'Find the perimeter of a rectangle 8 m long and 5 m wide.', 0,
 '[
   {"text": "26 m", "feedback": "Correct. Perimeter is 2(8 + 5) = 26 m."},
   {"text": "40 m", "feedback": "That is the area, in square metres. Perimeter is the distance around the outside."},
   {"text": "13 m", "feedback": "This adds one length and one width. A rectangle has two of each."},
   {"text": "80 m", "feedback": "This doubles the area. Perimeter adds the four sides rather than multiplying."}
 ]'::jsonb,
 'perimeter-vs-area'),
(9, 4, 8, 'Medium', 'MTH1W', 'Geometry and measurement',
 'Find the volume of a cylinder with radius 3 cm and height 10 cm. Use π ≈ 3.14.', 2,
 '[
   {"text": "94.2 cm³", "feedback": "This used 2πr, the circumference, rather than the circular area of the base."},
   {"text": "30 cm³", "feedback": "The π has gone missing. The base is a circle, so its area involves π."},
   {"text": "282.6 cm³", "feedback": "Correct. V = πr²h = 3.14 × 9 × 10 = 282.6 cm³."},
   {"text": "942 cm³", "feedback": "It looks like the radius was not squared before multiplying, or an extra factor crept in. Check πr² first."}
 ]'::jsonb,
 'cylinder-volume-formula'),
(9, 4, 9, 'Easy', 'MTH1W', 'Geometry and measurement',
 'What is the complement of a 35° angle?', 3,
 '[
   {"text": "145°", "feedback": "That is the supplement, which pairs with the angle to make 180°."},
   {"text": "325°", "feedback": "That pairs to make a full turn of 360°, which is neither complement nor supplement."},
   {"text": "35°", "feedback": "An angle is its own complement only at 45°, since 45 + 45 = 90."},
   {"text": "55°", "feedback": "Correct. Complementary angles add to 90°, and 90 − 35 = 55°."}
 ]'::jsonb,
 'complement-vs-supplement'),
(9, 4, 10, 'Medium', 'MTH1W', 'Geometry and measurement',
 'Find the surface area of a cube with side length 4 cm.', 1,
 '[
   {"text": "64 cm²", "feedback": "That is the volume, 4³, and it would be in cubic centimetres. Surface area covers the outside."},
   {"text": "96 cm²", "feedback": "Correct. Each face is 4 × 4 = 16 cm², and a cube has 6 faces: 6 × 16 = 96 cm²."},
   {"text": "16 cm²", "feedback": "That is one face only. A cube has six of them."},
   {"text": "24 cm²", "feedback": "This looks like 6 × 4, using the side length rather than the area of a face."}
 ]'::jsonb,
 'surface-area-face-count'),

-- ------ Unit 5: Data and financial literacy ------
(9, 5, 1, 'Easy', 'MTH1W', 'Data and financial literacy',
 'Find the mean of:   4, 8, 10, 6, 2', 2,
 '[
   {"text": "30", "feedback": "That is the total. The mean divides that total by how many values there are."},
   {"text": "8", "feedback": "Check your division: there are five values, not fewer."},
   {"text": "6", "feedback": "Correct. The values sum to 30, and 30 ÷ 5 = 6."},
   {"text": "5", "feedback": "This is the number of values, not their average."}
 ]'::jsonb,
 'mean-calculation'),
(9, 5, 2, 'Easy', 'MTH1W', 'Data and financial literacy',
 'Find the median of:   3, 7, 2, 9, 5', 1,
 '[
   {"text": "2", "feedback": "That is the smallest value. The median sits in the middle once the list is ordered."},
   {"text": "5", "feedback": "Correct. Ordered, the list is 2, 3, 5, 7, 9, and 5 is the middle value."},
   {"text": "7", "feedback": "This takes the middle of the list as written. Sort the numbers into order first."},
   {"text": "5.2", "feedback": "That is the mean. The median is a position in the ordered list, not an average."}
 ]'::jsonb,
 'unsorted-median'),
(9, 5, 3, 'Easy', 'MTH1W', 'Data and financial literacy',
 'Find the mode of:   2, 3, 3, 5, 7, 3', 0,
 '[
   {"text": "3", "feedback": "Correct. The mode is the value that appears most often, and 3 appears three times."},
   {"text": "5", "feedback": "That is the middle-ish value. The mode is about how often a value appears, not where it sits."},
   {"text": "7", "feedback": "That is the largest value. Count how many times each number shows up instead."},
   {"text": "3.83", "feedback": "That is the mean. The mode is always one of the values in the list."}
 ]'::jsonb,
 'mode-vs-frequency'),
(9, 5, 4, 'Easy', 'MTH1W', 'Data and financial literacy',
 'Find the range of:   12, 5, 20, 8', 3,
 '[
   {"text": "45", "feedback": "That is the sum of all the values. Range compares only the extremes."},
   {"text": "10", "feedback": "That is close to the mean. The range measures spread rather than centre."},
   {"text": "20", "feedback": "That is the largest value. The range subtracts the smallest from it."},
   {"text": "15", "feedback": "Correct. The largest is 20 and the smallest is 5, so the range is 20 − 5 = 15."}
 ]'::jsonb,
 'range-calculation'),
(9, 5, 5, 'Easy', 'MTH1W', 'Data and financial literacy',
 'Which graph is best for showing how a whole is divided into parts?', 2,
 '[
   {"text": "A line graph", "feedback": "Line graphs are best for showing change over time, not division of a total."},
   {"text": "A scatter plot", "feedback": "Scatter plots show the relationship between two variables, not parts of one total."},
   {"text": "A circle graph", "feedback": "Correct. A circle graph, or pie chart, shows each category as a slice of the whole."},
   {"text": "A histogram", "feedback": "Histograms show how often values fall into ranges, rather than shares of a total."}
 ]'::jsonb,
 'graph-type-choice'),
(9, 5, 6, 'Medium', 'MTH1W', 'Data and financial literacy',
 'Find the simple interest on $500 at 4% per year for 3 years.', 1,
 '[
   {"text": "$20", "feedback": "That is one year of interest. The money is invested for three."},
   {"text": "$60", "feedback": "Correct. I = Prt = 500 × 0.04 × 3 = $60."},
   {"text": "$560", "feedback": "That is the total amount at the end. The question asks for the interest alone."},
   {"text": "$600", "feedback": "It looks like the percentage was applied without converting 4% to 0.04."}
 ]'::jsonb,
 'simple-interest-formula'),
(9, 5, 7, 'Medium', 'MTH1W', 'Data and financial literacy',
 'A jacket costs $80 and is discounted by 15%. What is the sale price?', 0,
 '[
   {"text": "$68", "feedback": "Correct. The discount is 0.15 × 80 = $12, so the sale price is 80 − 12 = $68."},
   {"text": "$12", "feedback": "That is the discount itself. The question asks what you actually pay."},
   {"text": "$92", "feedback": "The discount was added rather than subtracted. A discount lowers the price."},
   {"text": "$65", "feedback": "Check the discount calculation: 15% of 80 is not 15."}
 ]'::jsonb,
 'percent-discount-not-subtracted'),
(9, 5, 8, 'Medium', 'MTH1W', 'Data and financial literacy',
 'You deposit $200 at 5% simple interest per year. What is the total after 2 years?', 2,
 '[
   {"text": "$20", "feedback": "That is the interest earned. The question asks for the total including the original deposit."},
   {"text": "$210", "feedback": "This counts only one year of interest. The money sits for two."},
   {"text": "$220", "feedback": "Correct. Interest is 200 × 0.05 × 2 = $20, and 200 + 20 = $220."},
   {"text": "$400", "feedback": "This doubles the deposit. At 5% a year it would take far longer than two years to double."}
 ]'::jsonb,
 'interest-not-added-to-principal'),
(9, 5, 9, 'Easy', 'MTH1W', 'Data and financial literacy',
 'A monthly income is $2000 and total expenses are $1650. How much is left to save?', 1,
 '[
   {"text": "$3650", "feedback": "This adds the two figures. Savings are what remains after expenses are taken out."},
   {"text": "$350", "feedback": "Correct. 2000 − 1650 = $350 left over."},
   {"text": "$450", "feedback": "Check the subtraction once more, looking carefully at the tens and units."},
   {"text": "$1650", "feedback": "That is the expenses figure. Savings are the difference between income and expenses."}
 ]'::jsonb,
 'budget-subtraction'),
(9, 5, 10, 'Medium', 'MTH1W', 'Data and financial literacy',
 'In a set of data, what is an outlier?', 3,
 '[
   {"text": "The most common value", "feedback": "That is the mode. An outlier is about distance from the rest, not frequency."},
   {"text": "The middle value", "feedback": "That is the median, which sits at the centre of the ordered data."},
   {"text": "The difference between the largest and smallest", "feedback": "That is the range, a measure of spread rather than a single unusual value."},
   {"text": "A value far away from the others", "feedback": "Correct. An outlier sits well apart from the rest, and can pull the mean noticeably."}
 ]'::jsonb,
 'outlier-definition');

-- ===========================================================================
-- Grade 10 — MPM2D Principles of Mathematics
-- ===========================================================================

delete from questions where grade = 10;

insert into questions
  (grade, unit_order, sort_order, difficulty, course_code, unit, prompt,
   correct_index, options, misconception_tag)
values

-- ------ Unit 1: Quadratic relations ------
(10, 1, 1, 'Easy', 'MPM2D', 'Quadratic relations',
 'Solve for x:   x² − 5x + 6 = 0', 1,
 '[
   {"text": "x = −2 and x = −3", "feedback": "Right factor pair, wrong signs. Check what value of x makes the bracket (x − 2) equal zero."},
   {"text": "x = 2 and x = 3", "feedback": "Correct. The factors of 6 that add to −5 are −2 and −3, so the expression factors as (x − 2)(x − 3)."},
   {"text": "x = 1 and x = 6", "feedback": "These multiply to 6, but they add to 7, not −5. The pair has to satisfy both conditions at once."},
   {"text": "x = 5 and x = 6", "feedback": "These are the coefficients from the equation, not the roots. Try factoring first."}
 ]'::jsonb,
 'quadratic-vertex-reading'),
(10, 1, 2, 'Easy', 'MPM2D', 'Quadratic relations',
 'What is the vertex of   y = (x − 3)² + 4 ?', 2,
 '[
   {"text": "(−3, 4)", "feedback": "Watch the sign. Ask yourself what value of x makes the bracket equal zero."},
   {"text": "(3, −4)", "feedback": "The x-coordinate is right. But the 4 is added here, so think again about whether the parabola shifts up or down."},
   {"text": "(3, 4)", "feedback": "Correct. In vertex form y = a(x − h)² + k the vertex is at (h, k), and the bracket is zero when x = 3."},
   {"text": "(4, 3)", "feedback": "These are the right two numbers in the wrong order. The x-value comes from the bracket."}
 ]'::jsonb,
 'quadratic-roots-from-factors'),
(10, 1, 3, 'Medium', 'MPM2D', 'Quadratic relations',
 'Where does   y = x² − 4x + 3   cross the x-axis?', 3,
 '[
   {"text": "(0, 3) only", "feedback": "That is the y-intercept, found by setting x = 0. The x-axis crossings need y = 0 instead."},
   {"text": "(−1, 0) and (−3, 0)", "feedback": "Signs are flipped. Substitute x = −1 into the equation and see whether you actually get zero."},
   {"text": "(2, −1)", "feedback": "That is the vertex, the lowest point of the curve. It sits below the axis, so it cannot be a crossing."},
   {"text": "(1, 0) and (3, 0)", "feedback": "Correct. Setting y = 0 and factoring gives (x − 1)(x − 3), so the curve crosses at x = 1 and x = 3."}
 ]'::jsonb,
 'quadratic-axis-of-symmetry'),
(10, 1, 4, 'Medium', 'MPM2D', 'Quadratic relations',
 'What is the axis of symmetry of   y = 2(x + 5)² − 1 ?', 0,
 '[
   {"text": "x = −5", "feedback": "Correct. The axis of symmetry runs vertically through the vertex, and the bracket is zero when x = −5."},
   {"text": "x = 5", "feedback": "Close, but check the sign. What do you substitute for x to make (x + 5) equal zero?"},
   {"text": "y = −1", "feedback": "That is a horizontal line. The axis of symmetry of a parabola like this one is vertical, so it starts with x."},
   {"text": "x = 2", "feedback": "The 2 is the stretch factor — it controls how narrow the parabola is, not where it sits."}
 ]'::jsonb,
 'quadratic-direction-of-opening'),
(10, 1, 5, 'Easy', 'MPM2D', 'Quadratic relations',
 'Expand and simplify:   (x − 4)(x + 7)', 2,
 '[
   {"text": "x² − 28", "feedback": "You multiplied the first terms and the last terms, but the two middle products are missing."},
   {"text": "x² − 3x − 28", "feedback": "The constant is right. Recheck the middle term: you get −4x and +7x, so what do those add to?"},
   {"text": "x² + 3x − 28", "feedback": "Correct. The outer and inner products give −4x + 7x = 3x, and −4 × 7 = −28."},
   {"text": "x² + 11x − 28", "feedback": "It looks like the middle terms were subtracted rather than added. Try −4x + 7x again."}
 ]'::jsonb,
 'quadratic-y-intercept'),
(10, 1, 6, 'Easy', 'MPM2D', 'Quadratic relations',
 'Factor:   x² + 8x + 15', 2,
 '[
   {"text": "(x − 3)(x + 5)", "feedback": "Expand this and check the constant: two numbers with different signs cannot multiply to a positive 15."},
   {"text": "(x + 1)(x + 15)", "feedback": "These multiply to 15 but add to 16, not 8. The pair has to satisfy both conditions at once."},
   {"text": "(x + 3)(x + 5)", "feedback": "Correct. 3 and 5 multiply to 15 and add to 8, which matches both the constant and the middle term."},
   {"text": "(x + 2)(x + 6)", "feedback": "These add to 8 but multiply to 12, not 15. Check the constant term as well as the middle one."}
 ]'::jsonb,
 'factor-pair-sum-and-product'),
(10, 1, 7, 'Medium', 'MPM2D', 'Quadratic relations',
 'How many times does   y = x² + 2x + 5   cross the x-axis?', 3,
 '[
   {"text": "Twice", "feedback": "Two crossings need a positive discriminant. Work out b² − 4ac before deciding."},
   {"text": "Once", "feedback": "One crossing happens only when the discriminant is exactly zero. Check the value of b² − 4ac here."},
   {"text": "Three times", "feedback": "A parabola is a single curve that turns once, so it can never meet a straight line three times."},
   {"text": "It does not cross at all", "feedback": "Correct. b² − 4ac = 4 − 20 = −16, and a negative discriminant means the curve never reaches the axis."}
 ]'::jsonb,
 'discriminant-sign-meaning'),
(10, 1, 8, 'Medium', 'MPM2D', 'Quadratic relations',
 'Complete the square:   y = x² + 6x + 2', 1,
 '[
   {"text": "y = (x + 3)² + 11", "feedback": "The 9 produced by squaring the bracket has been added on instead of taken back off."},
   {"text": "y = (x + 3)² − 7", "feedback": "Correct. Half of 6 is 3, and (x + 3)² expands to x² + 6x + 9, so 9 has to be subtracted: 2 − 9 = −7."},
   {"text": "y = (x + 6)² − 34", "feedback": "The whole 6 has been placed inside the bracket. Only half of the middle coefficient goes in there."},
   {"text": "y = (x − 3)² − 7", "feedback": "The sign inside the bracket does not match a positive middle term. Expand it and compare with the original."}
 ]'::jsonb,
 'completing-square-sign'),
(10, 1, 9, 'Hard', 'MPM2D', 'Quadratic relations',
 E'A ball is thrown so that its height in metres is h = −5t² + 20t, with t in seconds.\nWhat is its maximum height?', 0,
 '[
   {"text": "20 m", "feedback": "Correct. The vertex sits at t = 2 seconds, and substituting gives −5(4) + 40 = 20."},
   {"text": "2 m", "feedback": "That is the time at which the highest point happens, not the height. Substitute it back into the equation."},
   {"text": "4 m", "feedback": "That is when the ball lands, found by setting the height to zero. The peak comes halfway through the flight."},
   {"text": "40 m", "feedback": "Only part of the equation has been evaluated. Both terms have to be worked out at the vertex."}
 ]'::jsonb,
 'vertex-time-vs-height'),
(10, 1, 10, 'Hard', 'MPM2D', 'Quadratic relations',
 'Solve for x:   2x² + 5x − 3 = 0', 2,
 '[
   {"text": "x = −1/2 and x = 3", "feedback": "Both signs are flipped. Substitute x = 3 back into the equation and see whether it gives zero."},
   {"text": "x = 1/2 and x = 3", "feedback": "One of these is right. Check the other by substituting it back into the equation."},
   {"text": "x = 1/2 and x = −3", "feedback": "Correct. The expression factors as (2x − 1)(x + 3), so each bracket set to zero gives one root."},
   {"text": "x = 2 and x = −3", "feedback": "The leading coefficient does not become a root on its own. Set the bracket 2x − 1 equal to zero and solve it."}
 ]'::jsonb,
 'factoring-with-leading-coefficient'),

-- ------ Unit 2: Analytic geometry ------
(10, 2, 1, 'Easy', 'MPM2D', 'Analytic geometry',
 'Find the midpoint of the segment joining A(2, 5) and B(8, 1).', 0,
 '[
   {"text": "(5, 3)", "feedback": "Correct. Average each coordinate separately: (2 + 8) ÷ 2 = 5 and (5 + 1) ÷ 2 = 3."},
   {"text": "(10, 6)", "feedback": "You added the coordinates. There is one more step before you land halfway between the points."},
   {"text": "(3, 2)", "feedback": "That looks like the differences halved. The midpoint adds the coordinates first, rather than subtracting them."},
   {"text": "(6, −4)", "feedback": "These are the differences B − A. Useful for slope or length, but not for the point in the middle."}
 ]'::jsonb,
 'slope-formula-inverted'),
(10, 2, 2, 'Easy', 'MPM2D', 'Analytic geometry',
 'What is the length of the segment from (1, 2) to (4, 6)?', 1,
 '[
   {"text": "7", "feedback": "That is the two differences added together. Length needs Pythagoras, not addition."},
   {"text": "5", "feedback": "Correct. The differences are 3 and 4, and √(3² + 4²) = 5."},
   {"text": "25", "feedback": "You found 3² + 4² correctly, but stopped one step early. What do you still need to do to that?"},
   {"text": "12", "feedback": "That is 3 × 4. The distance formula squares and adds rather than multiplying."}
 ]'::jsonb,
 'midpoint-vs-distance'),
(10, 2, 3, 'Medium', 'MPM2D', 'Analytic geometry',
 'Find the slope of the line through (−2, 3) and (4, 15).', 2,
 '[
   {"text": "1/2", "feedback": "The fraction is upside down. Slope is rise over run, so which difference goes on top?"},
   {"text": "−2", "feedback": "Check your signs. Going from x = −2 to x = 4, and y = 3 up to y = 15, both changes are increases."},
   {"text": "2", "feedback": "Correct. The rise is 15 − 3 = 12, the run is 4 − (−2) = 6, and 12 ÷ 6 = 2."},
   {"text": "6", "feedback": "That is the run on its own. You still need to compare it to the rise."}
 ]'::jsonb,
 'perpendicular-negative-reciprocal'),
(10, 2, 4, 'Easy', 'MPM2D', 'Analytic geometry',
 'A line has slope 3 and passes through (0, −4). What is its equation?', 3,
 '[
   {"text": "y = −4x + 3", "feedback": "The slope and the intercept have swapped places. In y = mx + b, which one multiplies x?"},
   {"text": "y = 3x + 4", "feedback": "Substitute x = 0 into this and see what y comes out as. Compare that to the point you were given."},
   {"text": "y = 3x", "feedback": "This line passes through the origin. The given point is four units below that."},
   {"text": "y = 3x − 4", "feedback": "Correct. The point has x = 0, so −4 is the y-intercept, and the slope 3 is the coefficient of x."}
 ]'::jsonb,
 'distance-formula'),
(10, 2, 5, 'Medium', 'MPM2D', 'Analytic geometry',
 'A line is perpendicular to   y = ½x + 3.   What is its slope?', 0,
 '[
   {"text": "−2", "feedback": "Correct. Perpendicular slopes are negative reciprocals, and flipping ½ gives 2, then negating gives −2."},
   {"text": "½", "feedback": "That is the same slope, which gives a parallel line rather than a perpendicular one."},
   {"text": "2", "feedback": "You flipped the fraction correctly. There is one more step involving the sign."},
   {"text": "−½", "feedback": "You changed the sign but did not flip the fraction. Perpendicular slopes need both."}
 ]'::jsonb,
 'slope-intercept-form-order'),
(10, 2, 6, 'Easy', 'MPM2D', 'Analytic geometry',
 'A line is parallel to   y = −2x + 7.   What is its slope?', 1,
 '[
   {"text": "1/2", "feedback": "That is the negative reciprocal, which belongs to a perpendicular line rather than a parallel one."},
   {"text": "−2", "feedback": "Correct. Parallel lines have identical slopes, so the coefficient of x carries straight across."},
   {"text": "2", "feedback": "The size is right but the sign is not. Parallel lines match exactly, sign included."},
   {"text": "7", "feedback": "That is the y-intercept, which says where the line sits rather than how steep it is."}
 ]'::jsonb,
 'parallel-slope'),
(10, 2, 7, 'Easy', 'MPM2D', 'Analytic geometry',
 'A line has slope −3 and passes through (0, 5). What is its equation?', 3,
 '[
   {"text": "y = 5x − 3", "feedback": "The slope and the intercept have swapped places. In y = mx + b the slope is what multiplies x."},
   {"text": "y = −3x − 5", "feedback": "The given point sits above the origin, so the constant term should be positive."},
   {"text": "y = 3x + 5", "feedback": "The slope here is negative, which means the line falls from left to right."},
   {"text": "y = −3x + 5", "feedback": "Correct. The point lies on the y-axis, so 5 is the intercept, and the slope goes in front of x."}
 ]'::jsonb,
 'slope-intercept-form-order'),
(10, 2, 8, 'Medium', 'MPM2D', 'Analytic geometry',
 'How far is the point (−3, 4) from the origin?', 0,
 '[
   {"text": "5", "feedback": "Correct. √((−3)² + 4²) = √(9 + 16) = √25 = 5."},
   {"text": "1", "feedback": "The two coordinates have been added directly. They need to be squared and combined under a root."},
   {"text": "7", "feedback": "The two distances have been added straight together, but they are the legs of a right triangle."},
   {"text": "25", "feedback": "This is the value sitting under the root sign. One more step finishes the calculation."}
 ]'::jsonb,
 'distance-formula'),
(10, 2, 9, 'Medium', 'MPM2D', 'Analytic geometry',
 'What is the equation of a circle centred at the origin with radius 6?', 2,
 '[
   {"text": "x² + y² = 6", "feedback": "The radius has to be squared before it appears on the right-hand side."},
   {"text": "x² + y² = 12", "feedback": "This doubles the radius rather than squaring it."},
   {"text": "x² + y² = 36", "feedback": "Correct. A circle centred at the origin has equation x² + y² = r², and 6² = 36."},
   {"text": "x + y = 6", "feedback": "This describes a straight line. A circle needs squared terms in both variables."}
 ]'::jsonb,
 'circle-radius-not-squared'),
(10, 2, 10, 'Hard', 'MPM2D', 'Analytic geometry',
 'A triangle has vertices A(0, 0), B(4, 0) and C(0, 3). What is its perimeter?', 1,
 '[
   {"text": "7", "feedback": "This adds only the two sides lying along the axes. The slanted side still has to be found."},
   {"text": "12", "feedback": "Correct. The legs measure 3 and 4, the slanted side works out to 5, and 3 + 4 + 5 = 12."},
   {"text": "6", "feedback": "That is the area of the triangle. Perimeter is the distance all the way around it."},
   {"text": "9", "feedback": "One side length appears to be missing or too short. Use the distance formula on the slanted side."}
 ]'::jsonb,
 'perimeter-missing-side'),

-- ------ Unit 3: Trigonometry ------
(10, 3, 1, 'Easy', 'MPM2D', 'Trigonometry',
 'In a right triangle, the side opposite angle θ is 5 and the hypotenuse is 13. What is sin θ ?', 1,
 '[
   {"text": "13/5", "feedback": "The hypotenuse is always the longest side, so a ratio bigger than 1 cannot be a sine. Try flipping it."},
   {"text": "5/13", "feedback": "Correct. SOH tells you sine is opposite over hypotenuse."},
   {"text": "12/13", "feedback": "The 12 is the adjacent side, found by Pythagoras. That makes this a different ratio — which one?"},
   {"text": "5/12", "feedback": "This is opposite over adjacent. Check what SOH says goes on the bottom for sine."}
 ]'::jsonb,
 'chooses-wrong-ratio'),
(10, 3, 2, 'Easy', 'MPM2D', 'Trigonometry',
 'A right triangle has legs of 6 and 8. How long is the hypotenuse?', 2,
 '[
   {"text": "14", "feedback": "That is the two legs added. Pythagoras squares them first, which gives a shorter result than simple addition."},
   {"text": "48", "feedback": "That is 6 × 8. The theorem uses squares and a sum, not a product."},
   {"text": "10", "feedback": "Correct. 6² + 8² = 36 + 64 = 100, and √100 = 10."},
   {"text": "100", "feedback": "You got 6² + 8² right. One step remains before that becomes a length."}
 ]'::jsonb,
 'special-angle-ratio'),
(10, 3, 3, 'Easy', 'MPM2D', 'Trigonometry',
 'The side opposite θ is 7 and the adjacent side is 24. What is tan θ ?', 0,
 '[
   {"text": "7/24", "feedback": "Correct. TOA tells you tangent is opposite over adjacent."},
   {"text": "24/7", "feedback": "The ratio is inverted. In TOA, which letter comes first?"},
   {"text": "7/25", "feedback": "The 25 is the hypotenuse, from Pythagoras. Tangent does not use the hypotenuse at all."},
   {"text": "24/25", "feedback": "This is adjacent over hypotenuse, which names a different ratio. Check what TOA stands for."}
 ]'::jsonb,
 'pythagorean-leg-vs-hypotenuse'),
(10, 3, 4, 'Medium', 'MPM2D', 'Trigonometry',
 'The side adjacent to θ is 9 and the hypotenuse is 15. What is cos θ, as a fraction in lowest terms?', 3,
 '[
   {"text": "9/15", "feedback": "The right ratio, but not yet simplified. What number divides into both 9 and 15?"},
   {"text": "4/5", "feedback": "That is sin θ — the opposite side is 12 by Pythagoras. Cosine uses the adjacent side instead."},
   {"text": "5/3", "feedback": "This is upside down, and bigger than 1, which no cosine in a right triangle can be."},
   {"text": "3/5", "feedback": "Correct. CAH gives 9/15, and dividing both by 3 gives 3/5."}
 ]'::jsonb,
 'chooses-wrong-ratio'),
(10, 3, 5, 'Medium', 'MPM2D', 'Trigonometry',
 'In a right triangle, the hypotenuse is 20 and one angle is 30°. How long is the side opposite that angle?', 1,
 '[
   {"text": "20/30", "feedback": "Angles and side lengths are different kinds of quantity, so they cannot be divided like this. Start from sin 30° instead."},
   {"text": "10", "feedback": "Correct. sin 30° = 0.5, and since sine is opposite over hypotenuse, the opposite side is 0.5 × 20 = 10."},
   {"text": "40", "feedback": "The opposite side must be shorter than the hypotenuse, so the answer has to be less than 20."},
   {"text": "17.3", "feedback": "That is the adjacent side, using cos 30°. The question asks for the one opposite the 30° angle."}
 ]'::jsonb,
 'inverse-trig-needed'),
(10, 3, 6, 'Easy', 'MPM2D', 'Trigonometry',
 'Which ratio compares the opposite side with the adjacent side?', 2,
 '[
   {"text": "sin θ", "feedback": "Sine compares the opposite side with the hypotenuse, not with the adjacent side."},
   {"text": "cos θ", "feedback": "Cosine compares the adjacent side with the hypotenuse."},
   {"text": "tan θ", "feedback": "Correct. Tangent is opposite divided by adjacent, the only one of the three that leaves out the hypotenuse."},
   {"text": "The Pythagorean theorem", "feedback": "That connects the three side lengths, but it does not involve an angle at all."}
 ]'::jsonb,
 'chooses-wrong-ratio'),
(10, 3, 7, 'Medium', 'MPM2D', 'Trigonometry',
 'If   tan θ = 3/4,   what is θ to the nearest degree?', 0,
 '[
   {"text": "37°", "feedback": "Correct. θ = tan⁻¹(0.75), which comes to about 36.9 degrees."},
   {"text": "53°", "feedback": "That is the other acute angle in the same triangle, the one found from tan⁻¹(4/3)."},
   {"text": "0.75°", "feedback": "That is the value of the ratio itself. The inverse tangent turns a ratio into an angle."},
   {"text": "45°", "feedback": "An angle of 45 degrees has a tangent of exactly 1, which needs the two legs to be equal."}
 ]'::jsonb,
 'inverse-trig-needed'),
(10, 3, 8, 'Medium', 'MPM2D', 'Trigonometry',
 'A right triangle has a hypotenuse of 10 and an angle of 40°. How long is the side opposite that angle?', 3,
 '[
   {"text": "7.7", "feedback": "This uses cosine, which pairs the adjacent side with the hypotenuse rather than the opposite one."},
   {"text": "8.4", "feedback": "This uses tangent, but tangent does not involve the hypotenuse at all."},
   {"text": "15.6", "feedback": "The 10 has been divided by the ratio instead of multiplied. A leg cannot be longer than the hypotenuse."},
   {"text": "6.4", "feedback": "Correct. sin 40° = opposite ÷ 10, so the opposite side is 10 × sin 40°."}
 ]'::jsonb,
 'chooses-wrong-ratio'),
(10, 3, 9, 'Hard', 'MPM2D', 'Trigonometry',
 'A 5 m ladder leans against a wall and reaches 4 m up it. What angle does the ladder make with the ground?', 1,
 '[
   {"text": "37°", "feedback": "That is the angle at the top, between the ladder and the wall. The question asks about the angle at the ground."},
   {"text": "53°", "feedback": "Correct. sin θ = 4/5, so θ = sin⁻¹(0.8), which is about 53 degrees."},
   {"text": "0.8°", "feedback": "That is the ratio itself. Applying the inverse sine converts a ratio into an angle."},
   {"text": "45°", "feedback": "That would require the height up the wall and the distance along the ground to be equal."}
 ]'::jsonb,
 'complementary-angle-confusion'),
(10, 3, 10, 'Hard', 'MPM2D', 'Trigonometry',
 'From a point 30 m from the base of a tower, the angle of elevation to the top is 25°. How tall is the tower?', 2,
 '[
   {"text": "12.7 m", "feedback": "This treats the 30 m as the hypotenuse, but it is the distance along the ground, which is adjacent to the angle."},
   {"text": "27.2 m", "feedback": "This uses cosine, which would give a horizontal length rather than the height."},
   {"text": "14.0 m", "feedback": "Correct. The 30 m is adjacent and the height is opposite, so the height is 30 × tan 25°."},
   {"text": "64.3 m", "feedback": "The 30 has been divided by the tangent instead of multiplied, which makes the tower far taller than the ground distance."}
 ]'::jsonb,
 'divides-instead-of-multiplies'),

-- ------ Unit 4: Linear systems ------
(10, 4, 1, 'Easy', 'MPM2D', 'Linear systems',
 E'Solve the system:\n\ny = 2x + 1\ny = −x + 7', 3,
 '[
   {"text": "(1, 3)", "feedback": "Substitute x = 1 into the second equation and see what y you get. It has to work in both, not just one."},
   {"text": "(3, 2)", "feedback": "The two coordinates look swapped. Solve for x first, then put that value back in to find y."},
   {"text": "(−2, −3)", "feedback": "Sign slip when collecting terms. Set 2x + 1 = −x + 7 and move the x terms carefully to one side."},
   {"text": "(2, 5)", "feedback": "Correct. Setting 2x + 1 = −x + 7 gives 3x = 6, so x = 2, and substituting back gives y = 5."}
 ]'::jsonb,
 'system-satisfies-both'),
(10, 4, 2, 'Easy', 'MPM2D', 'Linear systems',
 E'Solve the system:\n\nx + y = 10\nx − y = 4', 1,
 '[
   {"text": "(5, 5)", "feedback": "This satisfies the first equation, but check it in the second one. Does 5 − 5 give you 4?"},
   {"text": "(7, 3)", "feedback": "Correct. Adding the two equations eliminates y and gives 2x = 14, so x = 7 and y = 3."},
   {"text": "(3, 7)", "feedback": "Right pair of numbers, wrong way round. Which one did you solve for first?"},
   {"text": "(6, 4)", "feedback": "These add to 10, but check the second equation. Their difference needs to be 4."}
 ]'::jsonb,
 'elimination-sign-error'),
(10, 4, 3, 'Medium', 'MPM2D', 'Linear systems',
 E'How many solutions does this system have?\n\ny = 3x + 2\ny = 3x − 5', 2,
 '[
   {"text": "Exactly one", "feedback": "Compare the two slopes. What has to be true about slopes for lines to cross at a point?"},
   {"text": "Infinitely many", "feedback": "That happens when the lines are identical. These two have the same slope but different y-intercepts."},
   {"text": "None", "feedback": "Correct. Both lines have slope 3 but different intercepts, so they are parallel and never meet."},
   {"text": "Exactly two", "feedback": "Two straight lines can never cross at two separate points. Think about what shapes these graphs are."}
 ]'::jsonb,
 'parallel-lines-no-solution'),
(10, 4, 4, 'Medium', 'MPM2D', 'Linear systems',
 E'Solve by elimination:\n\n2x + 3y = 12\n2x − y = 4', 0,
 '[
   {"text": "(3, 2)", "feedback": "Correct. Subtracting the second equation from the first gives 4y = 8, so y = 2 and then x = 3."},
   {"text": "(2, 3)", "feedback": "The numbers are right but swapped. Which variable did the subtraction actually eliminate?"},
   {"text": "(6, 0)", "feedback": "Try this in the second equation: 2(6) − 0 = 12, not 4. A solution must satisfy both."},
   {"text": "(0, 4)", "feedback": "Check the first equation with these values. You should get 12, so see what comes out instead."}
 ]'::jsonb,
 'substitution-incomplete'),
(10, 4, 5, 'Medium', 'MPM2D', 'Linear systems',
 'Two numbers add to 25. Their difference is 7. What are the numbers?', 2,
 '[
   {"text": "18 and 7", "feedback": "These do differ by 11, not 7. Try setting up two equations: one for the sum, one for the difference."},
   {"text": "15 and 10", "feedback": "The sum is right, but check the difference. You need it to come out as 7."},
   {"text": "16 and 9", "feedback": "Correct. Adding the equations x + y = 25 and x − y = 7 gives 2x = 32, so x = 16 and y = 9."},
   {"text": "20 and 13", "feedback": "The difference is right, but these add to 33. Both conditions have to hold at once."}
 ]'::jsonb,
 'word-problem-variable-choice'),
(10, 4, 6, 'Easy', 'MPM2D', 'Linear systems',
 E'Solve the system:\n\ny = x − 2\nx + y = 8', 1,
 '[
   {"text": "(3, 5)", "feedback": "The right two numbers, but assigned to the wrong variables. Substitute them back to see which is which."},
   {"text": "(5, 3)", "feedback": "Correct. Substituting gives x + (x − 2) = 8, so 2x = 10 and x = 5, which makes y = 3."},
   {"text": "(8, 6)", "feedback": "The 8 is the total of the two variables, not the value of one of them."},
   {"text": "(4, 4)", "feedback": "These do add to 8, but check whether they also satisfy the first equation."}
 ]'::jsonb,
 'variable-order-swapped'),
(10, 4, 7, 'Medium', 'MPM2D', 'Linear systems',
 E'How many solutions does this system have?\n\n2x − y = 4\n4x − 2y = 8', 3,
 '[
   {"text": "Exactly one", "feedback": "A single solution needs two lines with different slopes. Divide the second equation by 2 and compare it with the first."},
   {"text": "None", "feedback": "No solution means the lines are parallel but distinct. Check whether these two equations describe the very same line."},
   {"text": "Two", "feedback": "Two straight lines can meet at most once, so they can never cross exactly twice."},
   {"text": "Infinitely many", "feedback": "Correct. Dividing the second equation by 2 produces the first, so both describe one single line."}
 ]'::jsonb,
 'coincident-lines'),
(10, 4, 8, 'Medium', 'MPM2D', 'Linear systems',
 E'Adult tickets cost 12 dollars and child tickets cost 8 dollars.\n10 tickets were bought for a total of 104 dollars. How many were adult tickets?', 0,
 '[
   {"text": "6", "feedback": "Correct. With a adult tickets, 12a + 8(10 − a) = 104, which gives 4a = 24."},
   {"text": "4", "feedback": "That is the number of child tickets. Check which of the two the question is asking for."},
   {"text": "8", "feedback": "That many adult tickets would come to 112 dollars, which is more than was actually spent."},
   {"text": "5", "feedback": "An even split of the ten tickets comes to 100 dollars, which falls short of the total."}
 ]'::jsonb,
 'word-problem-variable-choice'),
(10, 4, 9, 'Hard', 'MPM2D', 'Linear systems',
 E'Solve the system:\n\n2x + y = 7\n3x − 2y = 0', 2,
 '[
   {"text": "(3, 2)", "feedback": "The right pair of numbers, but swapped around. Test them in both equations to see which order works."},
   {"text": "(1, 5)", "feedback": "These satisfy the first equation but not the second. A solution has to make both true at once."},
   {"text": "(2, 3)", "feedback": "Correct. Substituting y = 7 − 2x into the second equation gives 7x = 14."},
   {"text": "(0, 7)", "feedback": "This works in the first equation, but substituting it into the second does not give zero."}
 ]'::jsonb,
 'system-satisfies-both'),
(10, 4, 10, 'Hard', 'MPM2D', 'Linear systems',
 E'A boat travels 30 km downstream in 2 hours and makes the return trip upstream in 3 hours.\nWhat is the speed of the boat in still water?', 1,
 '[
   {"text": "15 km/h", "feedback": "That is the downstream speed, which includes the push of the current."},
   {"text": "12.5 km/h", "feedback": "Correct. Downstream is 15 and upstream is 10, and the still-water speed sits halfway between them."},
   {"text": "10 km/h", "feedback": "That is the upstream speed, which is being slowed by the current."},
   {"text": "2.5 km/h", "feedback": "That is the speed of the current itself, half the difference between the two trips."}
 ]'::jsonb,
 'rate-sum-and-difference'),

-- ------ Unit 5: Similar triangles ------
(10, 5, 1, 'Easy', 'MPM2D', 'Similar triangles',
 'Two triangles are similar. The first has sides 3, 4, 5. The second has sides 6, 8, and one unknown. What is the unknown side?', 1,
 '[
   {"text": "7", "feedback": "You added 2, matching 3→6 and 4→8 by addition. But similar triangles scale by multiplication, not addition."},
   {"text": "10", "feedback": "Correct. Each side doubles, since 3 → 6 and 4 → 8, so 5 → 10."},
   {"text": "9", "feedback": "Check the pattern in the sides you know. What do you multiply 3 by to get 6?"},
   {"text": "5", "feedback": "That would make the third side the same in both triangles, but the other two clearly grew."}
 ]'::jsonb,
 'similar-corresponding-angles'),
(10, 5, 2, 'Easy', 'MPM2D', 'Similar triangles',
 'A triangle is enlarged so that a side of length 4 becomes 10. What is the scale factor?', 0,
 '[
   {"text": "2.5", "feedback": "Correct. The scale factor is the new length divided by the old one, and 10 ÷ 4 = 2.5."},
   {"text": "6", "feedback": "That is the difference between the lengths. Scale factor compares them by division instead."},
   {"text": "0.4", "feedback": "This is the old length over the new one, which would be the factor for shrinking rather than enlarging."},
   {"text": "40", "feedback": "That is the two lengths multiplied. Try dividing the new length by the old one."}
 ]'::jsonb,
 'scale-factor-direction'),
(10, 5, 3, 'Medium', 'MPM2D', 'Similar triangles',
 'Triangle ABC is similar to triangle DEF. AB = 6, DE = 9, and BC = 8. How long is EF?', 3,
 '[
   {"text": "11", "feedback": "You added 3, the difference between AB and DE. Similar triangles scale by a multiplier instead."},
   {"text": "6", "feedback": "Check which sides correspond. BC matches EF, and the triangle is getting larger, not staying the same."},
   {"text": "10.5", "feedback": "Close, but recheck the scale factor. What is 9 divided by 6?"},
   {"text": "12", "feedback": "Correct. The scale factor is 9 ÷ 6 = 1.5, so EF = 8 × 1.5 = 12."}
 ]'::jsonb,
 'corresponding-sides-mismatched'),
(10, 5, 4, 'Easy', 'MPM2D', 'Similar triangles',
 'If two triangles are similar, what must be true about their corresponding angles?', 2,
 '[
   {"text": "They are doubled", "feedback": "Angles do not scale with the triangle. A triangle can grow while keeping exactly the same shape."},
   {"text": "They add to 180° in total across both", "feedback": "Each triangle on its own has angles summing to 180°. This asks about how the two triangles compare."},
   {"text": "They are equal", "feedback": "Correct. Similar triangles have the same shape, so corresponding angles are equal while the sides scale."},
   {"text": "They are proportional to the sides", "feedback": "The sides are proportional, but the angles behave differently. Picture a small triangle enlarged on a photocopier."}
 ]'::jsonb,
 'congruent-vs-similar'),
(10, 5, 5, 'Medium', 'MPM2D', 'Similar triangles',
 'A 2 m stick casts a 3 m shadow. At the same time a tree casts a 12 m shadow. How tall is the tree?', 1,
 '[
   {"text": "18 m", "feedback": "The ratio looks inverted. The stick is shorter than its shadow, so the tree should be shorter than its shadow too."},
   {"text": "8 m", "feedback": "Correct. The stick gives a height-to-shadow ratio of 2:3, and 12 × (2 ÷ 3) = 8."},
   {"text": "24 m", "feedback": "That is the shadow multiplied by the stick height. Set up a proportion of height to shadow instead."},
   {"text": "12 m", "feedback": "That is the shadow length itself. The tree and its shadow are different measurements."}
 ]'::jsonb,
 'shadow-proportion-setup'),
(10, 5, 6, 'Easy', 'MPM2D', 'Similar triangles',
 'In two similar triangles, what is true about the corresponding sides?', 2,
 '[
   {"text": "They are equal in length", "feedback": "That describes congruent triangles, which match in size as well as in shape."},
   {"text": "They add to the same total", "feedback": "Perimeters only match when the scale factor is 1. Similar triangles are allowed to be different sizes."},
   {"text": "They are all in the same ratio", "feedback": "Correct. Every pair of corresponding sides shares one single scale factor."},
   {"text": "They are perpendicular to each other", "feedback": "That describes how two lines meet, not how the sizes of two triangles compare."}
 ]'::jsonb,
 'congruent-vs-similar'),
(10, 5, 7, 'Medium', 'MPM2D', 'Similar triangles',
 'Two triangles are similar with a scale factor of 3. How many times larger is the area of the bigger one?', 3,
 '[
   {"text": "3 times", "feedback": "That is the ratio of the sides. Area covers two dimensions, so it grows differently."},
   {"text": "6 times", "feedback": "This doubles the scale factor. Area is affected by the factor once for each dimension, which is not the same as doubling."},
   {"text": "1/9 of the area", "feedback": "The bigger triangle has the larger area, so the answer should be greater than 1, not smaller."},
   {"text": "9 times", "feedback": "Correct. Area scales by the square of the scale factor, and 3² = 9."}
 ]'::jsonb,
 'area-scale-factor'),
(10, 5, 8, 'Medium', 'MPM2D', 'Similar triangles',
 E'Triangle PQR is similar to triangle STU.\nPQ = 4, ST = 10 and PR = 6. How long is SU?', 0,
 '[
   {"text": "15", "feedback": "Correct. The scale factor is 10 ÷ 4 = 2.5, and 6 × 2.5 = 15."},
   {"text": "12", "feedback": "This uses a scale factor of 2, but 4 has to be multiplied by 2.5 to reach 10."},
   {"text": "2.4", "feedback": "The scale factor has been applied upside down, which shrinks the side instead of enlarging it."},
   {"text": "10", "feedback": "That length is already given. The question asks for the side that matches the one measuring 6."}
 ]'::jsonb,
 'scale-factor-direction'),
(10, 5, 9, 'Hard', 'MPM2D', 'Similar triangles',
 E'In triangle ABC, DE is parallel to BC, with D on AB and E on AC.\nAD = 3, DB = 6 and AE = 4. How long is EC?', 1,
 '[
   {"text": "2", "feedback": "The ratio has been applied upside down. On the first side the lower piece is the larger of the two."},
   {"text": "8", "feedback": "Correct. AD to DB is 3 to 6, or 1 to 2, so AE to EC must also be 1 to 2, making EC = 8."},
   {"text": "12", "feedback": "That is the length of the whole side AC. The piece already measuring 4 still has to be taken off."},
   {"text": "6", "feedback": "That is the length of DB, which sits on the other side of the triangle."}
 ]'::jsonb,
 'parallel-line-ratio'),
(10, 5, 10, 'Hard', 'MPM2D', 'Similar triangles',
 E'A person 1.6 m tall stands 2 m from a mirror lying flat on the ground.\nA flagpole is 10 m from the mirror on the other side, and the person can just see its top in the mirror. How tall is the flagpole?', 2,
 '[
   {"text": "3.2 m", "feedback": "This doubles the height of the person instead of using the ratio of the two ground distances."},
   {"text": "12.5 m", "feedback": "The ratio has been applied to the wrong measurement. Scale the height by the ratio of the distances."},
   {"text": "8 m", "feedback": "Correct. The two triangles are similar, so height ÷ 10 = 1.6 ÷ 2, which gives 8."},
   {"text": "5 m", "feedback": "That is the ratio of the two ground distances on its own. The height of the person still has to be used."}
 ]'::jsonb,
 'mirror-proportion-setup');

-- ===========================================================================
-- Grade 11 — MCR3U Functions
-- ===========================================================================

delete from questions where grade = 11;

insert into questions
  (grade, unit_order, sort_order, difficulty, course_code, unit, prompt,
   correct_index, options, misconception_tag)
values

-- ------ Unit 1: Introduction to functions ------
(11, 1, 1, 'Easy', 'MCR3U', 'Introduction to functions',
 'Which relation is a function?', 2,
 '[
   {"text": "{(1, 2), (1, 5), (2, 3)}", "feedback": "The input 1 maps to two different outputs, 2 and 5. A function cannot do that."},
   {"text": "A circle x² + y² = 9", "feedback": "For most x-values a circle gives two y-values, one above and one below the axis, so it fails the vertical line test."},
   {"text": "{(1, 4), (2, 4), (3, 7)}", "feedback": "Correct. Every input has exactly one output. Two inputs sharing the same output is still allowed."},
   {"text": "A vertical line x = 3", "feedback": "This single x-value would need to map to every possible y-value at once, which no function can do."}
 ]'::jsonb,
 'vertical-line-test'),
(11, 1, 2, 'Easy', 'MCR3U', 'Introduction to functions',
 'If f(x) = 2x² − 3, find f(4).', 1,
 '[
   {"text": "13", "feedback": "It looks like 2x was used instead of 2x². Square the 4 first."},
   {"text": "29", "feedback": "Correct. f(4) = 2(4)² − 3 = 2(16) − 3 = 32 − 3 = 29."},
   {"text": "5", "feedback": "This looks like only x² − 3 was computed, without the factor of 2."},
   {"text": "61", "feedback": "Check the order: square 4 first to get 16, then multiply by 2, then subtract 3."}
 ]'::jsonb,
 'substitution-before-squaring'),
(11, 1, 3, 'Medium', 'MCR3U', 'Introduction to functions',
 'What is the domain of   f(x) = 1 / (x − 5) ?', 3,
 '[
   {"text": "All real numbers", "feedback": "One value of x makes the denominator zero, which is not allowed in a fraction."},
   {"text": "x ≥ 5", "feedback": "This restriction is for square roots, not for a denominator. Every value except one is fine here."},
   {"text": "x > 0", "feedback": "Negative x-values work perfectly well here, as long as they do not make the denominator zero."},
   {"text": "x ≠ 5", "feedback": "Correct. The denominator cannot equal zero, and x − 5 = 0 when x = 5, so that single value is excluded."}
 ]'::jsonb,
 'domain-denominator-zero'),
(11, 1, 4, 'Medium', 'MCR3U', 'Introduction to functions',
 'What is the domain of   f(x) = √(x − 3) ?', 1,
 '[
   {"text": "x ≠ 3", "feedback": "That restriction applies to denominators. A square root has a different requirement: the inside cannot be negative."},
   {"text": "x ≥ 3", "feedback": "Correct. The expression under a square root must be zero or positive, so x − 3 ≥ 0 gives x ≥ 3."},
   {"text": "x ≤ 3", "feedback": "Check the direction of the inequality — you need x − 3 to be at least zero, not at most."},
   {"text": "All real numbers", "feedback": "Try x = 0: the inside becomes −3, and the square root of a negative number is not a real number."}
 ]'::jsonb,
 'domain-radicand-negative'),
(11, 1, 5, 'Easy', 'MCR3U', 'Introduction to functions',
 'If f(x) = 3x + 1 and g(x) = x², find f(g(2)).', 3,
 '[
   {"text": "9", "feedback": "This computed g(2) but forgot to feed that result into f. There is one more step."},
   {"text": "49", "feedback": "It looks like g was applied to f(2) instead of f being applied to g(2). The order matters."},
   {"text": "7", "feedback": "Check g(2) first — squaring 2 does not give 2."},
   {"text": "13", "feedback": "Correct. g(2) = 4, then f(4) = 3(4) + 1 = 13."}
 ]'::jsonb,
 'composition-order'),
(11, 1, 6, 'Medium', 'MCR3U', 'Introduction to functions',
 'A function is transformed to   y = f(x) + 3.   How does the graph move?', 0,
 '[
   {"text": "Up 3 units", "feedback": "Correct. Adding outside the function shifts every y-value up by 3."},
   {"text": "Down 3 units", "feedback": "Adding 3 raises the output, which moves the graph up rather than down."},
   {"text": "Right 3 units", "feedback": "A horizontal shift comes from changing what is inside the brackets with x, not adding outside."},
   {"text": "Left 3 units", "feedback": "This is a vertical shift, since the 3 is added after f(x) is evaluated, not before."}
 ]'::jsonb,
 'transformation-vertical-shift'),
(11, 1, 7, 'Medium', 'MCR3U', 'Introduction to functions',
 'A function is transformed to   y = f(x − 2).   How does the graph move?', 2,
 '[
   {"text": "Up 2 units", "feedback": "A number added or subtracted outside f(x) shifts vertically. This one is inside, with the x."},
   {"text": "Left 2 units", "feedback": "The sign is backwards. Subtracting inside the brackets moves the graph to the right."},
   {"text": "Right 2 units", "feedback": "Correct. Subtracting inside the brackets shifts the graph right — f needs x = 2 to produce what f(0) used to."},
   {"text": "Down 2 units", "feedback": "This shift is horizontal, not vertical, because the 2 changes what goes into f rather than what comes out."}
 ]'::jsonb,
 'transformation-horizontal-direction'),
(11, 1, 8, 'Hard', 'MCR3U', 'Introduction to functions',
 'The point (2, 5) lies on y = f(x). What point must lie on y = −f(x)?', 1,
 '[
   {"text": "(−2, 5)", "feedback": "This reflects the x-coordinate. The negative sign is outside f(x), so it flips the output instead."},
   {"text": "(2, −5)", "feedback": "Correct. −f(x) negates the output only, so the point becomes (2, −5)."},
   {"text": "(−2, −5)", "feedback": "Both coordinates were flipped, but the negative sign here only affects the y-value."},
   {"text": "(5, 2)", "feedback": "This swaps the coordinates, which describes an inverse rather than a reflection."}
 ]'::jsonb,
 'reflection-axis-confusion'),
(11, 1, 9, 'Medium', 'MCR3U', 'Introduction to functions',
 'What is the range of   f(x) = x² + 2 ?', 3,
 '[
   {"text": "All real numbers", "feedback": "A squared term can never be negative, so the output has a floor. Not every real number is reachable."},
   {"text": "y ≥ 0", "feedback": "This ignores the +2. The smallest value of x² is 0, but the whole function adds 2 to that."},
   {"text": "x ≥ 0", "feedback": "This describes possible inputs, but the question asks about the outputs, y."},
   {"text": "y ≥ 2", "feedback": "Correct. x² is never negative, so its smallest value is 0, making the smallest output 0 + 2 = 2."}
 ]'::jsonb,
 'range-from-vertex'),
(11, 1, 10, 'Easy', 'MCR3U', 'Introduction to functions',
 'Does the graph of   x = y²   represent a function of x?', 1,
 '[
   {"text": "Yes", "feedback": "Try x = 4: both y = 2 and y = −2 satisfy the equation, so one input gives two outputs."},
   {"text": "No", "feedback": "Correct. This is a sideways parabola, and it fails the vertical line test — most x-values give two y-values."},
   {"text": "Only for positive x", "feedback": "Even restricting to positive x, each of those values still produces two y-values, positive and negative."},
   {"text": "Only for x = 0", "feedback": "x = 0 does give a single output, but the question is about the whole relation, not one special point."}
 ]'::jsonb,
 'vertical-line-test'),

-- ------ Unit 2: Quadratic functions ------
(11, 2, 1, 'Easy', 'MCR3U', 'Quadratic functions',
 'Write   y = x² + 6x + 5   in vertex form by completing the square.', 1,
 '[
   {"text": "y = (x + 6)² − 5", "feedback": "The number added inside the bracket should be half of 6, not 6 itself."},
   {"text": "y = (x + 3)² − 4", "feedback": "Correct. Half of 6 is 3, and 5 − 3² = 5 − 9 = −4."},
   {"text": "y = (x + 3)² + 5", "feedback": "The bracket is right, but the constant needs adjusting once 3² is accounted for, not left as the original 5."},
   {"text": "y = (x − 3)² − 4", "feedback": "The sign inside the bracket should match the sign of the middle term, which is +6x here."}
 ]'::jsonb,
 'completing-square-sign'),
(11, 2, 2, 'Medium', 'MCR3U', 'Quadratic functions',
 'Use the quadratic formula to solve   x² − 4x − 5 = 0.', 2,
 '[
   {"text": "x = 2 and x = −2", "feedback": "This looks like a mix-up with a different equation. Substitute a = 1, b = −4, c = −5 into the formula directly."},
   {"text": "x = 1 and x = −5", "feedback": "These multiply to −5, matching c, but check what they add to — it should be 4, not −4."},
   {"text": "x = 5 and x = −1", "feedback": "Correct. The discriminant is 16 + 20 = 36, and (4 ± 6) ÷ 2 gives x = 5 and x = −1."},
   {"text": "x = −5 and x = 1", "feedback": "Close — these are the right two numbers. Recheck which one is positive and which is negative."}
 ]'::jsonb,
 'quadratic-formula-sign'),
(11, 2, 3, 'Medium', 'MCR3U', 'Quadratic functions',
 'How many real roots does   x² + 2x + 5 = 0   have?', 0,
 '[
   {"text": "Zero", "feedback": "Correct. The discriminant is 4 − 20 = −16, which is negative, so there are no real roots."},
   {"text": "One", "feedback": "One root happens when the discriminant is exactly zero. Calculate b² − 4ac here."},
   {"text": "Two", "feedback": "Two real roots happen when the discriminant is positive. Check whether b² − 4ac comes out positive or negative."},
   {"text": "Infinitely many", "feedback": "A quadratic can have at most two real roots. Calculate the discriminant to see how many exist here."}
 ]'::jsonb,
 'discriminant-sign-meaning'),
(11, 2, 4, 'Easy', 'MCR3U', 'Quadratic functions',
 'What does the discriminant tell you about a quadratic?', 3,
 '[
   {"text": "The y-intercept", "feedback": "The y-intercept comes from the constant term c directly, not from the discriminant."},
   {"text": "The axis of symmetry", "feedback": "That comes from −b/2a. The discriminant answers a different question."},
   {"text": "The maximum value", "feedback": "The maximum or minimum comes from the vertex, found using a, b and c differently than the discriminant does."},
   {"text": "The number of real roots", "feedback": "Correct. A positive discriminant gives two roots, zero gives one, and negative gives none."}
 ]'::jsonb,
 'discriminant-interpretation'),
(11, 2, 5, 'Medium', 'MCR3U', 'Quadratic functions',
 'A ball is thrown so that its height is   h(t) = −5t² + 20t + 1.   At what time does it reach its maximum height?', 2,
 '[
   {"text": "t = 0.5", "feedback": "Check the formula for the axis of symmetry: t = −b ÷ (2a), using a = −5 and b = 20."},
   {"text": "t = 1", "feedback": "This is too early. Substitute a = −5 and b = 20 into −b ÷ (2a) carefully."},
   {"text": "t = 2", "feedback": "Correct. The maximum occurs at t = −b ÷ (2a) = −20 ÷ (2 × −5) = 2."},
   {"text": "t = 4", "feedback": "This doubles the correct answer. Recheck the division in −b ÷ (2a)."}
 ]'::jsonb,
 'vertex-time-vs-height'),
(11, 2, 6, 'Hard', 'MCR3U', 'Quadratic functions',
 'For what value of k does   x² + kx + 9 = 0   have exactly one real root?', 3,
 '[
   {"text": "k = 3", "feedback": "Substitute this into the discriminant b² − 4ac = k² − 36 and check whether it actually equals zero."},
   {"text": "k = 9", "feedback": "This is much too large — check what k² − 4(1)(9) equals when k = 9."},
   {"text": "k = 0", "feedback": "This would make the discriminant −36, which is negative, giving no real roots at all."},
   {"text": "k = 6 or k = −6", "feedback": "Correct. One root needs the discriminant to be zero: k² − 36 = 0, so k² = 36, giving k = ±6."}
 ]'::jsonb,
 'discriminant-zero-condition'),
(11, 2, 7, 'Medium', 'MCR3U', 'Quadratic functions',
 'Factor:   2x² + 7x + 3', 1,
 '[
   {"text": "(2x + 3)(x + 1)", "feedback": "Expand this to check: it gives 2x² + 5x + 3, not the 7x needed here."},
   {"text": "(2x + 1)(x + 3)", "feedback": "Correct. Expanding gives 2x² + 6x + x + 3 = 2x² + 7x + 3."},
   {"text": "(x + 1)(x + 3)", "feedback": "This expands to x² + 4x + 3, missing the factor of 2 on the x² term entirely."},
   {"text": "(2x + 7)(x + 3)", "feedback": "This uses the 7 directly as a factor, but 7 needs to be split across the two brackets instead."}
 ]'::jsonb,
 'factoring-with-leading-coefficient'),
(11, 2, 8, 'Medium', 'MCR3U', 'Quadratic functions',
 'The graph of   y = a(x − 2)² + 3   passes through (0, 11). Find a.', 0,
 '[
   {"text": "2", "feedback": "Correct. Substituting gives 11 = a(0 − 2)² + 3, so 8 = 4a, giving a = 2."},
   {"text": "8", "feedback": "This is 11 − 3, but the division by (0 − 2)² = 4 still needs to happen."},
   {"text": "4", "feedback": "This is (0 − 2)² on its own. It still needs to be matched against 11 − 3."},
   {"text": "0.5", "feedback": "Check the direction of the division: it should be 8 ÷ 4, not 4 ÷ 8."}
 ]'::jsonb,
 'stretch-factor-from-point'),
(11, 2, 9, 'Easy', 'MCR3U', 'Quadratic functions',
 'What is the vertex of   y = 3(x + 1)² − 7 ?', 2,
 '[
   {"text": "(1, −7)", "feedback": "Watch the sign inside the bracket — the vertex x-value makes (x + 1) equal to zero."},
   {"text": "(1, 7)", "feedback": "Both the sign of x and the sign of the constant need checking here."},
   {"text": "(−1, −7)", "feedback": "Correct. The bracket is zero when x = −1, and the constant −7 is the y-value at the vertex."},
   {"text": "(3, −1)", "feedback": "The 3 is the stretch factor, not a coordinate — it controls how narrow the parabola is."}
 ]'::jsonb,
 'vertex-sign-from-brackets'),
(11, 2, 10, 'Hard', 'MCR3U', 'Quadratic functions',
 'Two numbers have a sum of 20. What is the maximum possible value of their product?', 1,
 '[
   {"text": "20", "feedback": "This is far too small. Try a few pairs that sum to 20, like 5 and 15, and compare their products."},
   {"text": "100", "feedback": "Correct. If the numbers are x and 20 − x, the product x(20 − x) = −x² + 20x is maximised at x = 10, giving 10 × 10 = 100."},
   {"text": "400", "feedback": "This is 20², but the two numbers do not have to both equal 20 — they only need to sum to 20."},
   {"text": "200", "feedback": "Try the pair 10 and 10 directly: their product is 100, not 200."}
 ]'::jsonb,
 'optimization-vertex'),

-- ------ Unit 3: Exponential functions ------
(11, 3, 1, 'Easy', 'MCR3U', 'Exponential functions',
 'Simplify:   x⁵ ÷ x²', 1,
 '[
   {"text": "x⁷", "feedback": "Adding exponents is the rule for multiplying powers. Dividing subtracts them instead."},
   {"text": "x³", "feedback": "Correct. Dividing powers of the same base subtracts the exponents: 5 − 2 = 3."},
   {"text": "x^2.5", "feedback": "This divides the exponents rather than subtracting them, which is not the rule for division of powers."},
   {"text": "x^10", "feedback": "This multiplies the exponents, which is the rule for a power raised to another power, not for dividing."}
 ]'::jsonb,
 'exponent-division-rule'),
(11, 3, 2, 'Easy', 'MCR3U', 'Exponential functions',
 'Evaluate:   8^(2/3)', 2,
 '[
   {"text": "2", "feedback": "This is only the cube root of 8. The exponent still needs the outer square applied to that result."},
   {"text": "16", "feedback": "This looks like 8 doubled and then something extra. Take the cube root of 8 first, then square that result."},
   {"text": "4", "feedback": "Correct: the cube root of 8 is 2, and squaring that gives 4."},
   {"text": "64", "feedback": "This treats the exponent as 2 without the root, giving 8² instead of the fractional exponent."}
 ]'::jsonb,
 'fractional-exponent-root-power'),
(11, 3, 3, 'Medium', 'MCR3U', 'Exponential functions',
 'Simplify:   (2x³)⁴', 0,
 '[
   {"text": "16x^12", "feedback": "Correct. Both factors inside the bracket get raised to the 4th power: 2⁴ = 16 and (x³)⁴ = x^12."},
   {"text": "8x^12", "feedback": "The 2 needs to be raised to the 4th power as well, not just multiplied by 4."},
   {"text": "16x⁷", "feedback": "This adds the exponents, 3 + 4, but a power outside the bracket multiplies the inner exponent instead."},
   {"text": "2x^12", "feedback": "The coefficient 2 is inside the bracket too, so it also needs to be raised to the 4th power."}
 ]'::jsonb,
 'power-of-product-rule'),
(11, 3, 4, 'Easy', 'MCR3U', 'Exponential functions',
 'Evaluate:   5⁰', 3,
 '[
   {"text": "0", "feedback": "Zero as an exponent has a specific, fixed value, whatever the base is."},
   {"text": "5", "feedback": "This treats the exponent as if it were 1. An exponent of 0 behaves differently."},
   {"text": "Undefined", "feedback": "Any nonzero base raised to the power 0 has a defined value."},
   {"text": "1", "feedback": "Correct. Any nonzero number raised to the power 0 equals 1."}
 ]'::jsonb,
 'zero-exponent'),
(11, 3, 5, 'Medium', 'MCR3U', 'Exponential functions',
 'A population of bacteria doubles every hour, starting at 100. How many after 4 hours?', 1,
 '[
   {"text": "800", "feedback": "This multiplies 100 by 4 doublings added together rather than applying each doubling in turn."},
   {"text": "1600", "feedback": "Correct. 100 × 2⁴ = 100 × 16 = 1600."},
   {"text": "400", "feedback": "This only doubles twice. There are four hours, so the doubling happens four times."},
   {"text": "500", "feedback": "This adds 100 four times rather than doubling, which is linear growth rather than exponential."}
 ]'::jsonb,
 'exponential-vs-linear-growth'),
(11, 3, 6, 'Medium', 'MCR3U', 'Exponential functions',
 'Which function models exponential decay?', 2,
 '[
   {"text": "y = 3x + 5", "feedback": "This is a straight line, with constant growth per step rather than a shrinking factor."},
   {"text": "y = 5(2)^x", "feedback": "The base here is greater than 1, which produces growth rather than decay."},
   {"text": "y = 5(0.5)^x", "feedback": "Correct. A base between 0 and 1 means each step multiplies by a fraction, shrinking the value."},
   {"text": "y = x²", "feedback": "This is a quadratic, which does not have the repeated-multiplication pattern that defines exponential behaviour."}
 ]'::jsonb,
 'decay-base-less-than-one'),
(11, 3, 7, 'Hard', 'MCR3U', 'Exponential functions',
 'The half-life of a substance is 3 years. Starting with 80 g, how much remains after 9 years?', 0,
 '[
   {"text": "10 g", "feedback": "Correct. Nine years is three half-lives, so 80 → 40 → 20 → 10 g."},
   {"text": "20 g", "feedback": "This applies the halving only twice, but nine years covers three half-lives of three years each."},
   {"text": "26.7 g", "feedback": "This divides 80 by 3 directly, treating the decay as linear rather than repeated halving."},
   {"text": "40 g", "feedback": "This applies the halving only once. Check how many three-year periods fit into nine years."}
 ]'::jsonb,
 'half-life-count'),
(11, 3, 8, 'Easy', 'MCR3U', 'Exponential functions',
 'What is the y-intercept of   y = 4(3)^x ?', 1,
 '[
   {"text": "3", "feedback": "That is the base, which controls the growth rate rather than the starting value."},
   {"text": "4", "feedback": "Correct. Setting x = 0 gives y = 4(3)⁰ = 4 × 1 = 4."},
   {"text": "12", "feedback": "This multiplies 4 and 3 together, but x = 0 makes 3^x equal to 1, not 3."},
   {"text": "1", "feedback": "This is 3⁰ on its own, but the leading 4 still needs to be included."}
 ]'::jsonb,
 'exponential-y-intercept'),
(11, 3, 9, 'Medium', 'MCR3U', 'Exponential functions',
 'Solve for x:   2^x = 32', 3,
 '[
   {"text": "16", "feedback": "This divides 32 by 2 rather than asking how many times 2 must be multiplied to reach 32."},
   {"text": "2", "feedback": "2² is only 4. You need a larger exponent to reach 32."},
   {"text": "4", "feedback": "2⁴ is 16, which is still short of 32. Try one more factor of 2."},
   {"text": "5", "feedback": "Correct. 2⁵ = 32, since 2 × 2 × 2 × 2 × 2 = 32."}
 ]'::jsonb,
 'solve-exponent-by-inspection'),
(11, 3, 10, 'Hard', 'MCR3U', 'Exponential functions',
 'An investment of $1000 grows at 6% per year, compounded annually. Which expression gives its value after t years?', 2,
 '[
   {"text": "1000 + 60t", "feedback": "This is simple interest, adding a fixed amount each year rather than growing by a percentage of the current total."},
   {"text": "1000 × 6^t", "feedback": "This uses the interest rate itself as the base. The base should reflect keeping the original amount plus adding 6%."},
   {"text": "1000(1.06)^t", "feedback": "Correct. Each year the amount is multiplied by 1 plus the rate, 1.06, and this repeats t times."},
   {"text": "1000(0.06)^t", "feedback": "A base below 1 describes decay. Growing at 6% needs a base above 1, specifically 1.06."}
 ]'::jsonb,
 'compound-interest-form'),

-- ------ Unit 4: Trigonometric functions ------
(11, 4, 1, 'Easy', 'MCR3U', 'Trigonometric functions',
 'What is the exact value of   sin 30° ?', 1,
 '[
   {"text": "√3/2", "feedback": "That is cos 30°. Sine and cosine of 30° are different values."},
   {"text": "1/2", "feedback": "Correct. sin 30° = 1/2, a standard value worth memorising."},
   {"text": "1", "feedback": "That is sin 90°. At 30° the sine has not yet reached its maximum."},
   {"text": "√2/2", "feedback": "That is sin 45°. Check the special triangle for a 30° angle instead."}
 ]'::jsonb,
 'special-angle-ratio'),
(11, 4, 2, 'Medium', 'MCR3U', 'Trigonometric functions',
 'A right triangle has hypotenuse 10 and one angle 40°. Find the side opposite that angle.', 0,
 '[
   {"text": "6.43", "feedback": "Correct. sin 40° ≈ 0.643, and 0.643 × 10 ≈ 6.43."},
   {"text": "7.66", "feedback": "That uses cos 40° instead. The opposite side needs sine, not cosine."},
   {"text": "8.39", "feedback": "That uses tan 40° multiplied by the hypotenuse, but tangent does not directly involve the hypotenuse."},
   {"text": "10", "feedback": "This uses the full hypotenuse without adjusting for the angle at all."}
 ]'::jsonb,
 'chooses-wrong-ratio'),
(11, 4, 3, 'Medium', 'MCR3U', 'Trigonometric functions',
 'In which quadrant is θ = 200° located?', 2,
 '[
   {"text": "First", "feedback": "The first quadrant covers 0° to 90°. 200° is well past that."},
   {"text": "Second", "feedback": "The second quadrant runs from 90° to 180°. 200° is just beyond that boundary."},
   {"text": "Third", "feedback": "Correct. The third quadrant runs from 180° to 270°, and 200° falls inside that range."},
   {"text": "Fourth", "feedback": "The fourth quadrant runs from 270° to 360°. 200° comes before that range starts."}
 ]'::jsonb,
 'quadrant-identification'),
(11, 4, 4, 'Medium', 'MCR3U', 'Trigonometric functions',
 'Find the reference angle for θ = 150°.', 1,
 '[
   {"text": "150°", "feedback": "The reference angle is measured to the nearest x-axis, not the full angle itself."},
   {"text": "30°", "feedback": "Correct. 150° sits in the second quadrant, so the reference angle is 180° − 150° = 30°."},
   {"text": "60°", "feedback": "This subtracts from 90° rather than from 180°, which applies to a different quadrant."},
   {"text": "210°", "feedback": "This adds rather than finding the gap to the nearest axis. Reference angles are always between 0° and 90°."}
 ]'::jsonb,
 'reference-angle'),
(11, 4, 5, 'Hard', 'MCR3U', 'Trigonometric functions',
 'Two sides of a triangle are 8 and 10, with an included angle of 60°. Find the third side, using the law of cosines.', 3,
 '[
   {"text": "6", "feedback": "This is too small for these side lengths and this angle. Recompute 8² + 10² − 2(8)(10)cos60° carefully."},
   {"text": "9", "feedback": "Close, but check the subtraction of 2(8)(10)cos60° from 8² + 10² before taking the square root."},
   {"text": "8.7", "feedback": "This looks like the law of sines was used instead. The law of cosines is needed when you know two sides and the included angle."},
   {"text": "9.17", "feedback": "Correct. c² = 64 + 100 − 160(0.5) = 84, and √84 ≈ 9.17."}
 ]'::jsonb,
 'cosine-law-setup'),
(11, 4, 6, 'Medium', 'MCR3U', 'Trigonometric functions',
 'In triangle ABC, angle A = 50°, side a = 12, side b = 15. Use the law of sines to find angle B.', 2,
 '[
   {"text": "50°", "feedback": "Angle B cannot equal angle A here, since side b is longer than side a, which means angle B must be larger."},
   {"text": "40°", "feedback": "Side b is longer than side a, so angle B should be larger than angle A, not smaller."},
   {"text": "68°", "feedback": "Correct. sin B / 15 = sin 50° / 12 gives sin B ≈ 0.957, and taking the inverse sine gives about 68°."},
   {"text": "90°", "feedback": "This assumes a right angle without checking. Solve sin B = 15 × sin50° / 12 directly."}
 ]'::jsonb,
 'sine-law-setup'),
(11, 4, 7, 'Easy', 'MCR3U', 'Trigonometric functions',
 'What is the period of   y = sin x ?', 1,
 '[
   {"text": "90°", "feedback": "That is a quarter of the way through one cycle, not the full length of a repeat."},
   {"text": "360°", "feedback": "Correct. The sine curve completes one full cycle every 360°, then repeats."},
   {"text": "180°", "feedback": "The curve has not fully repeated after 180° — it has only reached its lowest point by then, not returned to start."},
   {"text": "45°", "feedback": "This is far too short. Picture the sine wave: it takes a full 360° to trace one complete shape."}
 ]'::jsonb,
 'period-of-sine'),
(11, 4, 8, 'Medium', 'MCR3U', 'Trigonometric functions',
 'What is the amplitude of   y = 4sin(x) − 2 ?', 0,
 '[
   {"text": "4", "feedback": "Correct. The amplitude is the coefficient in front of sine, ignoring the vertical shift of −2."},
   {"text": "2", "feedback": "That is the vertical shift. The amplitude only concerns the number multiplying the sine function."},
   {"text": "−2", "feedback": "The amplitude is always reported as a positive size, describing how far the curve swings from its centre."},
   {"text": "6", "feedback": "This adds the 4 and the 2, but the amplitude and the vertical shift are two separate features of the graph."}
 ]'::jsonb,
 'amplitude-vs-vertical-shift'),
(11, 4, 9, 'Hard', 'MCR3U', 'Trigonometric functions',
 'Solve for θ in [0°, 360°):   2sinθ = 1', 2,
 '[
   {"text": "θ = 30° only", "feedback": "This finds one solution, but sine is positive in two quadrants within a full rotation."},
   {"text": "θ = 30° and 330°", "feedback": "330° is in the fourth quadrant, where sine is negative, not the quadrant matching this positive value."},
   {"text": "θ = 30° and 150°", "feedback": "Correct. sinθ = 0.5 in the first quadrant at 30°, and by symmetry also in the second quadrant at 180° − 30° = 150°."},
   {"text": "θ = 150° only", "feedback": "This finds only the second-quadrant solution. There is a matching first-quadrant angle as well."}
 ]'::jsonb,
 'second-quadrant-solution'),
(11, 4, 10, 'Medium', 'MCR3U', 'Trigonometric functions',
 'A ladder leans against a wall, making a 70° angle with the ground, and reaches 5 m up the wall. How long is the ladder?', 3,
 '[
   {"text": "5 × sin70°", "feedback": "The 5 m is already the opposite side, so multiplying by sine again is not the right move here."},
   {"text": "5 × cos70°", "feedback": "Cosine relates the adjacent side to the hypotenuse, but the 5 m given is the side opposite the angle."},
   {"text": "5 × tan70°", "feedback": "Tangent would connect the two legs of the triangle, but the question asks for the hypotenuse, the ladder itself."},
   {"text": "5 ÷ sin70°", "feedback": "Correct. sin70° = opposite ÷ hypotenuse = 5 ÷ ladder length, so ladder length = 5 ÷ sin70°."}
 ]'::jsonb,
 'chooses-wrong-ratio'),

-- ------ Unit 5: Discrete functions ------
(11, 5, 1, 'Easy', 'MCR3U', 'Discrete functions',
 'Find the next term:   3, 7, 11, 15, ...', 2,
 '[
   {"text": "17", "feedback": "Check the pattern between terms — each one increases by the same fixed amount."},
   {"text": "18", "feedback": "Close, but recheck the common difference between consecutive terms."},
   {"text": "19", "feedback": "Correct. This is arithmetic with common difference 4, so the next term is 15 + 4 = 19."},
   {"text": "20", "feedback": "This adds 5 rather than the actual difference between the given terms."}
 ]'::jsonb,
 'arithmetic-common-difference'),
(11, 5, 2, 'Easy', 'MCR3U', 'Discrete functions',
 'Find the 10th term of the arithmetic sequence with first term 5 and common difference 3.', 0,
 '[
   {"text": "32", "feedback": "Correct. tₙ = a + (n − 1)d = 5 + 9(3) = 5 + 27 = 32."},
   {"text": "35", "feedback": "This multiplies by 10 rather than 9 — the formula uses (n − 1), not n."},
   {"text": "27", "feedback": "This is only the added part, 9 × 3. The first term of 5 still needs to be included."},
   {"text": "38", "feedback": "This adds one extra step of 3. Check that (n − 1) uses 9, not 10 or 11."}
 ]'::jsonb,
 'nth-term-off-by-one'),
(11, 5, 3, 'Medium', 'MCR3U', 'Discrete functions',
 'Find the sum of the first 20 terms of the arithmetic sequence 2, 5, 8, 11, ...', 1,
 '[
   {"text": "590", "feedback": "Close — recheck the 20th term: a + 19d = 2 + 57 = 59, not a smaller value."},
   {"text": "610", "feedback": "Correct. Using Sₙ = n/2 × (2a + (n−1)d) = 10 × (4 + 57) = 10 × 61 = 610."},
   {"text": "1220", "feedback": "This looks like the sum was doubled. Recheck the n/2 factor at the start of the formula."},
   {"text": "600", "feedback": "Very close, but recompute (n − 1)d = 19 × 3 = 57 exactly before adding 2a."}
 ]'::jsonb,
 'arithmetic-series-sum'),
(11, 5, 4, 'Easy', 'MCR3U', 'Discrete functions',
 'Is the sequence   4, 8, 16, 32, ...   arithmetic or geometric?', 1,
 '[
   {"text": "Arithmetic", "feedback": "Check the differences between terms: 8 − 4 = 4, but 16 − 8 = 8. They are not the same, so it is not arithmetic."},
   {"text": "Geometric", "feedback": "Correct. Each term is double the one before it, a constant ratio of 2, which is what defines a geometric sequence."},
   {"text": "Neither", "feedback": "There is a clear, consistent pattern here — check whether dividing consecutive terms gives the same result each time."},
   {"text": "Both", "feedback": "A sequence can only be one or the other unless it has just one or two terms. Check the ratio between consecutive terms."}
 ]'::jsonb,
 'arithmetic-vs-geometric'),
(11, 5, 5, 'Medium', 'MCR3U', 'Discrete functions',
 'Find the 6th term of the geometric sequence with first term 3 and common ratio 2.', 2,
 '[
   {"text": "18", "feedback": "This adds 3 six times rather than multiplying repeatedly, which is the arithmetic pattern rather than geometric."},
   {"text": "48", "feedback": "This uses one fewer multiplication than needed. Check that the exponent is n − 1, not n − 2."},
   {"text": "96", "feedback": "Correct. tₙ = ar^(n−1) = 3 × 2⁵ = 3 × 32 = 96."},
   {"text": "192", "feedback": "This uses one extra multiplication by 2. The exponent should be n − 1 = 5, not 6."}
 ]'::jsonb,
 'geometric-nth-term'),
(11, 5, 6, 'Medium', 'MCR3U', 'Discrete functions',
 'Find the sum of the first 5 terms of the geometric sequence 2, 6, 18, 54, ...', 3,
 '[
   {"text": "80", "feedback": "This looks like the terms were simply added up to the 4th term. There is a 5th term still to include."},
   {"text": "150", "feedback": "Check the ratio used in the formula — it should be 3, matching how each term triples."},
   {"text": "486", "feedback": "That is the value of the 6th term, not the sum of the first 5 terms."},
   {"text": "242", "feedback": "Correct. Sₙ = a(rⁿ − 1)/(r − 1) = 2(3⁵ − 1)/(3 − 1) = 2(242)/2 = 242."}
 ]'::jsonb,
 'geometric-series-sum'),
(11, 5, 7, 'Hard', 'MCR3U', 'Discrete functions',
 'Find the sum to infinity of   6 + 3 + 1.5 + 0.75 + ...', 0,
 '[
   {"text": "12", "feedback": "Correct. The ratio is 0.5, and since it is between −1 and 1 the sum converges: S = a/(1 − r) = 6/0.5 = 12."},
   {"text": "6", "feedback": "This is just the first term. The infinite sum accounts for every term added afterwards as well."},
   {"text": "18", "feedback": "Check the formula a/(1 − r) directly — divide 6 by 0.5 rather than multiplying."},
   {"text": "Infinite", "feedback": "The sum only diverges when the size of the ratio is 1 or more. Here the ratio is 0.5, which is small enough for the sum to settle."}
 ]'::jsonb,
 'infinite-series-ratio'),
(11, 5, 8, 'Easy', 'MCR3U', 'Discrete functions',
 'A sequence is defined by t₁ = 5, tₙ = tₙ₋₁ + 4. What is t₄?', 1,
 '[
   {"text": "13", "feedback": "This looks like only two steps of adding 4 were applied. Starting from t₁, three additions are needed to reach t₄."},
   {"text": "17", "feedback": "Correct. t₂ = 9, t₃ = 13, t₄ = 17 — three additions of 4 starting from 5."},
   {"text": "20", "feedback": "This applies four additions of 4, but t₁ is already the first term, so only three more steps are needed."},
   {"text": "9", "feedback": "This is only t₂. Continue applying the rule two more times to reach t₄."}
 ]'::jsonb,
 'recursive-sequence'),
(11, 5, 9, 'Medium', 'MCR3U', 'Discrete functions',
 'The interior angles of polygons form a sequence: triangle 180°, quadrilateral 360°, pentagon 540°. What is the formula for an n-sided polygon?', 2,
 '[
   {"text": "180n", "feedback": "Test this on the triangle: 180 × 3 = 540, but a triangle only has 180° total."},
   {"text": "360(n − 2)", "feedback": "Test with n = 3: 360(1) = 360, which is double what a triangle actually has."},
   {"text": "180(n − 2)", "feedback": "Correct. For n = 3, 180(1) = 180. For n = 4, 180(2) = 360. For n = 5, 180(3) = 540 — all match."},
   {"text": "360(n − 1)", "feedback": "Test with n = 3: 360(2) = 720, which is far more than the 180° a triangle actually has."}
 ]'::jsonb,
 'pattern-generalization'),
(11, 5, 10, 'Hard', 'MCR3U', 'Discrete functions',
 'A ball dropped from 8 m bounces back to half its previous height each time. What total distance has it travelled by the time it comes to rest?', 3,
 '[
   {"text": "16 m", "feedback": "This only counts the initial 8 m drop doubled. The repeated bounces up and down still need to be included."},
   {"text": "8 m", "feedback": "This is just the first drop. Every bounce afterwards adds more distance, both up and back down."},
   {"text": "32 m", "feedback": "Close in spirit, but check the geometric series carefully — the up-and-down bounces form a sum that converges to a specific value."},
   {"text": "24 m", "feedback": "Correct. The first drop is 8 m; after that, each bounce goes up and comes back down, forming 2 × 8 × (0.5)/(1 − 0.5) = 16 m, plus the initial 8 m gives 24 m."}
 ]'::jsonb,
 'bouncing-total-distance');

-- ===========================================================================
-- Grade 12 — MHF4U Advanced Functions
-- ===========================================================================

delete from questions where grade = 12;

insert into questions
  (grade, unit_order, sort_order, difficulty, course_code, unit, prompt,
   correct_index, options, misconception_tag)
values

-- ------ Unit 1: Polynomial functions ------
(12, 1, 1, 'Easy', 'MHF4U', 'Polynomial functions',
 'What is the degree of   f(x) = 3x⁴ − 2x⁷ + 5x ?', 2,
 '[
   {"text": "4", "feedback": "That is the exponent on the first term written down, but the terms are not in descending order here. Look for the largest exponent anywhere in the expression."},
   {"text": "3", "feedback": "That is a coefficient, not an exponent. Degree comes from the powers of x only."},
   {"text": "7", "feedback": "Correct. The degree is the largest exponent on x, which is 7 in the term −2x⁷."},
   {"text": "12", "feedback": "Exponents are not added together. The degree is the single largest power of x, not a total."}
 ]'::jsonb,
 'degree-largest-exponent'),
(12, 1, 2, 'Easy', 'MHF4U', 'Polynomial functions',
 'Describe the end behaviour of   f(x) = −2x³ + 5x − 1.', 1,
 '[
   {"text": "Both ends point upward", "feedback": "Both ends can only agree when the degree is even. The highest power here is odd."},
   {"text": "As x → −∞, y → +∞ and as x → +∞, y → −∞", "feedback": "Correct. An odd degree sends the two ends in opposite directions, and the negative leading coefficient pulls the right end downward."},
   {"text": "As x → −∞, y → −∞ and as x → +∞, y → +∞", "feedback": "This is the behaviour of an odd-degree polynomial with a positive leading coefficient. Check the sign of the leading term."},
   {"text": "Both ends point downward", "feedback": "Matching ends require an even degree. This polynomial has an odd one."}
 ]'::jsonb,
 'end-behaviour-odd-even'),
(12, 1, 3, 'Easy', 'MHF4U', 'Polynomial functions',
 'What are the x-intercepts of   f(x) = (x − 3)(x + 2)(x − 5) ?', 0,
 '[
   {"text": "3, −2, 5", "feedback": "Correct. Each factor is set equal to zero, so x − 3 = 0, x + 2 = 0 and x − 5 = 0."},
   {"text": "−3, 2, −5", "feedback": "The numbers have been copied straight out of the brackets with their signs unchanged. Solve each factor equal to zero instead."},
   {"text": "3, 2, 5", "feedback": "One of the brackets has a plus sign inside it, and that changes the sign of the root it produces."},
   {"text": "0, 3, 5", "feedback": "Zero is a root only when x on its own is a factor. Every factor here contains a constant."}
 ]'::jsonb,
 'roots-sign-from-factors'),
(12, 1, 4, 'Medium', 'MHF4U', 'Polynomial functions',
 'What is the maximum number of turning points a degree 5 polynomial can have?', 3,
 '[
   {"text": "5", "feedback": "That is the degree itself. A polynomial always changes direction fewer times than its degree."},
   {"text": "6", "feedback": "This is one more than the degree. The relationship goes the other way."},
   {"text": "2", "feedback": "This is the limit for a quadratic. A higher degree allows more direction changes."},
   {"text": "4", "feedback": "Correct. A polynomial of degree n has at most n − 1 turning points, so degree 5 allows 4."}
 ]'::jsonb,
 'turning-points-count'),
(12, 1, 5, 'Medium', 'MHF4U', 'Polynomial functions',
 'What is the remainder when   x³ − 4x² + 2x + 1   is divided by   (x − 2) ?', 1,
 '[
   {"text": "3", "feedback": "The size is right but the sign is not. Recheck the subtraction when substituting."},
   {"text": "−3", "feedback": "Correct. The remainder theorem says to evaluate at x = 2: 8 − 16 + 4 + 1 = −3."},
   {"text": "−11", "feedback": "This comes from substituting x = −2. The divisor x − 2 is zero when x is positive 2."},
   {"text": "1", "feedback": "That is the constant term, which is only the remainder when dividing by x itself."}
 ]'::jsonb,
 'remainder-theorem-substitution'),
(12, 1, 6, 'Medium', 'MHF4U', 'Polynomial functions',
 'Which of these is a factor of   x³ − 7x + 6 ?', 0,
 '[
   {"text": "(x − 1)", "feedback": "Correct. Substituting x = 1 gives 1 − 7 + 6 = 0, so by the factor theorem this bracket divides evenly."},
   {"text": "(x + 1)", "feedback": "Substituting x = −1 gives a nonzero value, so this bracket leaves a remainder."},
   {"text": "(x − 6)", "feedback": "The constant 6 does suggest testing 6, but substituting it gives a large nonzero value. The smaller divisors of 6 are worth testing too."},
   {"text": "(x + 2)", "feedback": "Substituting x = −2 does not produce zero, so this bracket leaves a remainder."}
 ]'::jsonb,
 'factor-theorem-test'),
(12, 1, 7, 'Medium', 'MHF4U', 'Polynomial functions',
 'Solve the inequality   (x − 1)(x + 4) > 0.', 2,
 '[
   {"text": "−4 < x < 1", "feedback": "Between the two roots the factors have opposite signs, so their product is negative there."},
   {"text": "x > 1 only", "feedback": "This is one piece of the answer. Test a large negative value as well, where both factors are negative."},
   {"text": "x < −4 or x > 1", "feedback": "Correct. Outside both roots the two factors share the same sign, so the product is positive."},
   {"text": "x > −4", "feedback": "This ignores the second root, where the product changes sign again. Test a value between the two roots."}
 ]'::jsonb,
 'inequality-sign-regions'),
(12, 1, 8, 'Hard', 'MHF4U', 'Polynomial functions',
 E'A cubic has zeros at −1, 2 and 3, so f(x) = a(x + 1)(x − 2)(x − 3).\nIts y-intercept is 12. What is the value of a?', 1,
 '[
   {"text": "1", "feedback": "This assumes the brackets already produce the y-intercept on their own. Evaluate the brackets at x = 0 first."},
   {"text": "2", "feedback": "Correct. At x = 0 the brackets give (1)(−2)(−3) = 6, and 6a = 12."},
   {"text": "12", "feedback": "That is the y-intercept itself, not the stretch factor. It still has to be divided by what the brackets produce at x = 0."},
   {"text": "−2", "feedback": "Two of the brackets give negative values at x = 0, and they multiply to a positive, so no sign change is needed."}
 ]'::jsonb,
 'stretch-factor-from-point'),
(12, 1, 9, 'Hard', 'MHF4U', 'Polynomial functions',
 'Which function is even, meaning its graph is symmetric about the y-axis?', 1,
 '[
   {"text": "f(x) = x³ − x", "feedback": "Replacing x with −x flips the sign of the whole expression here, which is the test for a different kind of symmetry."},
   {"text": "f(x) = x⁴ − 3x² + 1", "feedback": "Correct. Every exponent is even, so f(−x) = f(x) and the two halves of the graph mirror each other across the y-axis."},
   {"text": "f(x) = x³ + x²", "feedback": "Mixing odd and even powers breaks the symmetry. Compare f(−1) with f(1) to see."},
   {"text": "f(x) = 2x + 5", "feedback": "A slanted line with a nonzero constant is not symmetric about the y-axis. Test f(−1) against f(1)."}
 ]'::jsonb,
 'even-odd-symmetry'),
(12, 1, 10, 'Hard', 'MHF4U', 'Polynomial functions',
 'Solve   x³ − 3x² − x + 3 = 0.', 3,
 '[
   {"text": "x = 3 only", "feedback": "Grouping does produce a factor of x − 3, but the other bracket factors further and gives more roots."},
   {"text": "x = 1 and x = −1 only", "feedback": "The difference of squares has been spotted, but the first bracket from the grouping also gives a root."},
   {"text": "x = 0, 1, 3", "feedback": "Zero can only be a root when the constant term is zero. Substituting x = 0 leaves 3, not 0."},
   {"text": "x = 3, 1, −1", "feedback": "Correct. Grouping gives (x − 3)(x² − 1), and the second bracket is a difference of squares."}
 ]'::jsonb,
 'factor-by-grouping'),

-- ------ Unit 2: Rational functions ------
(12, 2, 1, 'Easy', 'MHF4U', 'Rational functions',
 'Where is the vertical asymptote of   f(x) = 1 / (x + 4) ?', 2,
 '[
   {"text": "x = 4", "feedback": "The sign has been read straight from the bracket. Set the denominator equal to zero and solve it."},
   {"text": "y = 4", "feedback": "This describes a horizontal line. A vertical asymptote is written as x equals a number."},
   {"text": "x = −4", "feedback": "Correct. The denominator x + 4 is zero when x = −4, so the function is undefined there."},
   {"text": "x = 0", "feedback": "At x = 0 the denominator is 4, which is perfectly fine, so the function is defined there."}
 ]'::jsonb,
 'vertical-asymptote-sign'),
(12, 2, 2, 'Easy', 'MHF4U', 'Rational functions',
 'What is the horizontal asymptote of   f(x) = (3x + 1) / (x − 2) ?', 0,
 '[
   {"text": "y = 3", "feedback": "Correct. The degrees match, so the asymptote is the ratio of the leading coefficients, 3 over 1."},
   {"text": "y = 0", "feedback": "That happens when the denominator has the higher degree. Here the two degrees are the same."},
   {"text": "y = 2", "feedback": "That value breaks the denominator, which locates a vertical asymptote instead."},
   {"text": "y = −1/2", "feedback": "This uses the constant terms. Far from the origin the x terms dominate, so compare those instead."}
 ]'::jsonb,
 'horizontal-asymptote-degrees'),
(12, 2, 3, 'Easy', 'MHF4U', 'Rational functions',
 'What is the horizontal asymptote of   f(x) = 2x / (x² + 1) ?', 1,
 '[
   {"text": "y = 2", "feedback": "Comparing leading coefficients only works when the two degrees are equal. Compare the degrees first."},
   {"text": "y = 0", "feedback": "Correct. The denominator grows much faster than the numerator, so the fraction shrinks toward zero."},
   {"text": "y = 1", "feedback": "This uses the constant in the denominator rather than comparing the degrees of the two polynomials."},
   {"text": "There is no horizontal asymptote", "feedback": "That happens when the numerator has the higher degree. Here it is lower, which does give an asymptote."}
 ]'::jsonb,
 'horizontal-asymptote-degrees'),
(12, 2, 4, 'Medium', 'MHF4U', 'Rational functions',
 'What feature does the graph of   f(x) = (x² − 9) / (x − 3)   have at x = 3?', 3,
 '[
   {"text": "A vertical asymptote", "feedback": "That happens when the factor stays in the denominator. Try factoring the numerator first and see what cancels."},
   {"text": "An x-intercept", "feedback": "An intercept needs the function value to be zero. Simplify the fraction and evaluate near this point."},
   {"text": "A horizontal asymptote", "feedback": "Horizontal asymptotes describe behaviour far out as x grows large, not what happens at one particular x-value."},
   {"text": "A hole", "feedback": "Correct. The numerator factors as (x − 3)(x + 3), so the common bracket cancels and leaves a single missing point."}
 ]'::jsonb,
 'hole-vs-asymptote'),
(12, 2, 5, 'Medium', 'MHF4U', 'Rational functions',
 'What is the domain of   f(x) = (x + 1) / (x² − 4) ?', 0,
 '[
   {"text": "x ≠ 2 and x ≠ −2", "feedback": "Correct. The denominator factors as (x − 2)(x + 2), so both of those values make it zero."},
   {"text": "x ≠ 4", "feedback": "The 4 sits under a square. Factor the denominator before deciding what to exclude."},
   {"text": "x ≠ −1", "feedback": "That value makes the numerator zero, which produces an intercept rather than an exclusion."},
   {"text": "x ≠ 2 only", "feedback": "Squaring means two different values produce 4. Check the negative one as well."}
 ]'::jsonb,
 'domain-factor-denominator'),
(12, 2, 6, 'Medium', 'MHF4U', 'Rational functions',
 'Solve   1 / (x − 1) = 3.', 2,
 '[
   {"text": "x = 4", "feedback": "The 3 has to be distributed across both terms in the bracket before rearranging."},
   {"text": "x = 1/3", "feedback": "This solves 3x = 1 and drops the −1 that came from inside the bracket."},
   {"text": "x = 4/3", "feedback": "Correct. Multiplying both sides by x − 1 gives 1 = 3x − 3, so 3x = 4."},
   {"text": "x = 2/3", "feedback": "Check the sign when moving the −3 across the equals sign."}
 ]'::jsonb,
 'solve-rational-distribute'),
(12, 2, 7, 'Medium', 'MHF4U', 'Rational functions',
 'What is the x-intercept of   f(x) = (x − 5) / (x + 2) ?', 1,
 '[
   {"text": "x = −2", "feedback": "That value makes the denominator zero, so the function is undefined there rather than equal to zero."},
   {"text": "x = 5", "feedback": "Correct. A fraction equals zero only when its numerator is zero, and x − 5 = 0 at x = 5."},
   {"text": "x = −5", "feedback": "The sign has been read straight out of the bracket. Solve x − 5 = 0 instead."},
   {"text": "x = 2", "feedback": "This comes from the denominator with its sign flipped. Intercepts come from the numerator."}
 ]'::jsonb,
 'intercept-from-numerator'),
(12, 2, 8, 'Hard', 'MHF4U', 'Rational functions',
 'Solve the inequality   (x − 2) / (x + 1) ≥ 0.', 3,
 '[
   {"text": "−1 < x < 2", "feedback": "Between the critical values the numerator and denominator have opposite signs, so the quotient is negative there."},
   {"text": "x ≤ −1 or x ≥ 2", "feedback": "Very close, but one of these endpoints makes the denominator zero, and that value cannot be included."},
   {"text": "x ≥ 2 only", "feedback": "This misses the region far to the left, where the numerator and denominator are both negative."},
   {"text": "x < −1 or x ≥ 2", "feedback": "Correct. Outside the critical values the top and bottom share a sign, and only the zero of the numerator may be included."}
 ]'::jsonb,
 'rational-inequality-endpoints'),
(12, 2, 9, 'Hard', 'MHF4U', 'Rational functions',
 'What is the oblique (slant) asymptote of   f(x) = (x² + 1) / (x − 1) ?', 0,
 '[
   {"text": "y = x + 1", "feedback": "Correct. Long division gives x + 1 with a remainder of 2, and the remainder term fades away as x grows large."},
   {"text": "y = x", "feedback": "The division has stopped after the first term. Continue until the remainder has a lower degree than the divisor."},
   {"text": "y = 1", "feedback": "A horizontal asymptote needs the numerator degree to be no larger than the denominator degree. Here it is one higher."},
   {"text": "x = 1", "feedback": "That is the vertical asymptote from the denominator, not the slanted line the graph approaches."}
 ]'::jsonb,
 'oblique-asymptote-division'),
(12, 2, 10, 'Hard', 'MHF4U', 'Rational functions',
 'For   f(x) = 1 / (x − 3),   what happens to y as x approaches 3 from the left?', 2,
 '[
   {"text": "y approaches 0", "feedback": "The denominator is shrinking toward zero, which makes the fraction grow without bound rather than shrink."},
   {"text": "y approaches +∞", "feedback": "That is the behaviour from the other side. Just to the left of 3, check the sign of the denominator."},
   {"text": "y approaches −∞", "feedback": "Correct. Just left of 3 the denominator is a tiny negative number, so the fraction is large and negative."},
   {"text": "y approaches 3", "feedback": "The value 3 is where x is heading, not where y goes. Substitute x = 2.9 and see what comes out."}
 ]'::jsonb,
 'one-sided-limit-sign'),

-- ------ Unit 3: Exponential and logarithmic functions ------
(12, 3, 1, 'Easy', 'MHF4U', 'Exponential and logarithmic functions',
 'Evaluate   log₂ 32.', 1,
 '[
   {"text": "6", "feedback": "That exponent would give 64. Count the factors of 2 needed: 2 × 2 × 2 × 2 × 2."},
   {"text": "5", "feedback": "Correct. 2⁵ = 32, and a logarithm asks for the exponent."},
   {"text": "16", "feedback": "This halves 32 rather than asking which power of 2 produces 32."},
   {"text": "4", "feedback": "2⁴ is only 16, so one more factor of 2 is needed."}
 ]'::jsonb,
 'log-as-exponent'),
(12, 3, 2, 'Easy', 'MHF4U', 'Exponential and logarithmic functions',
 'Rewrite   log₃ 81 = 4   in exponential form.', 0,
 '[
   {"text": "3⁴ = 81", "feedback": "Correct. The base stays the base, the value of the logarithm becomes the exponent, and the argument is the result."},
   {"text": "4³ = 81", "feedback": "The base and the exponent have swapped places. The small number written after log is always the base."},
   {"text": "81³ = 4", "feedback": "The argument has been used as the base. The subscript is the base."},
   {"text": "3⁸¹ = 4", "feedback": "The exponent and the argument have swapped, which would give an enormous number rather than 4."}
 ]'::jsonb,
 'log-exponential-form-swap'),
(12, 3, 3, 'Easy', 'MHF4U', 'Exponential and logarithmic functions',
 'Solve   2ˣ = 64.', 3,
 '[
   {"text": "x = 32", "feedback": "This divides 64 by 2 once. The question asks for the exponent, not for half the number."},
   {"text": "x = 8", "feedback": "That is the square root of 64, which would answer x² = 64 instead."},
   {"text": "x = 5", "feedback": "2⁵ gives 32, which is only half of 64."},
   {"text": "x = 6", "feedback": "Correct. 2⁶ = 64, so the exponent is 6."}
 ]'::jsonb,
 'solve-exponent-by-inspection'),
(12, 3, 4, 'Medium', 'MHF4U', 'Exponential and logarithmic functions',
 'Simplify   log₂ 8 + log₂ 4.', 2,
 '[
   {"text": "6", "feedback": "This looks like the arguments were divided, or the two results multiplied. Evaluate each logarithm separately and add."},
   {"text": "12", "feedback": "This multiplies the two arguments and stops. A logarithm still has to be taken of that product."},
   {"text": "5", "feedback": "Correct. log₂ 8 = 3 and log₂ 4 = 2, and the product rule agrees because log₂ 32 = 5."},
   {"text": "32", "feedback": "That is the product of the two arguments. One more step turns it into an exponent."}
 ]'::jsonb,
 'log-product-rule'),
(12, 3, 5, 'Medium', 'MHF4U', 'Exponential and logarithmic functions',
 'Solve   log(x − 1) = 2,   where log means base 10.', 0,
 '[
   {"text": "x = 101", "feedback": "Correct. Base 10 gives x − 1 = 10² = 100, so x = 101."},
   {"text": "x = 21", "feedback": "This uses 10 multiplied by 2 instead of 10 raised to the power of 2."},
   {"text": "x = 3", "feedback": "This treats the 2 as the value of x − 1 directly, without undoing the logarithm."},
   {"text": "x = 100", "feedback": "The right side was undone correctly, but the −1 inside the bracket still has to be moved across."}
 ]'::jsonb,
 'log-undo-with-base'),
(12, 3, 6, 'Medium', 'MHF4U', 'Exponential and logarithmic functions',
 'What is the horizontal asymptote of   y = 2ˣ − 3 ?', 1,
 '[
   {"text": "y = 0", "feedback": "That is the asymptote before the vertical shift. Subtracting 3 moves the whole graph."},
   {"text": "y = −3", "feedback": "Correct. As x becomes very negative, 2ˣ approaches 0, so y approaches −3."},
   {"text": "y = 3", "feedback": "The shift is a subtraction, so the graph moves down rather than up."},
   {"text": "x = −3", "feedback": "This names a vertical line. An exponential graph of this form flattens out horizontally instead."}
 ]'::jsonb,
 'exponential-vertical-shift'),
(12, 3, 7, 'Medium', 'MHF4U', 'Exponential and logarithmic functions',
 'What is the domain of   y = log(x − 5) ?', 2,
 '[
   {"text": "x ≥ 5", "feedback": "At x = 5 the argument becomes zero, and the logarithm of zero is undefined, so that endpoint cannot be included."},
   {"text": "x ≠ 5", "feedback": "Negative arguments are also not allowed, so a whole region has to be excluded, not just one point."},
   {"text": "x > 5", "feedback": "Correct. The argument of a logarithm must be strictly positive, so x − 5 > 0."},
   {"text": "All real numbers", "feedback": "Try x = 0: the argument becomes −5, and logarithms of negative numbers are undefined."}
 ]'::jsonb,
 'log-domain-positive-argument'),
(12, 3, 8, 'Hard', 'MHF4U', 'Exponential and logarithmic functions',
 'Solve   3^(2x) = 81.', 3,
 '[
   {"text": "x = 4", "feedback": "This solves for the whole exponent 2x rather than for x. There is one more step."},
   {"text": "x = 27", "feedback": "This divides 81 by 3, which does not undo an exponent."},
   {"text": "x = 1/2", "feedback": "The 2 has been used in the wrong direction. Set the exponents equal and solve 2x = 4."},
   {"text": "x = 2", "feedback": "Correct. Writing 81 as 3⁴ makes the exponents equal, so 2x = 4."}
 ]'::jsonb,
 'equate-exponents-same-base'),
(12, 3, 9, 'Hard', 'MHF4U', 'Exponential and logarithmic functions',
 'A radioactive sample has a half-life of 5 years. What fraction remains after 20 years?', 0,
 '[
   {"text": "1/16", "feedback": "Correct. Twenty years is four half-lives, so the amount halves four times: (1/2)⁴."},
   {"text": "1/4", "feedback": "This halves twice, which matches 10 years. Count how many 5-year periods fit into 20."},
   {"text": "1/20", "feedback": "Decay is not found by dividing by the total time. Each half-life multiplies what is left by one half."},
   {"text": "0", "feedback": "Exponential decay approaches zero but never actually reaches it after a finite number of half-lives."}
 ]'::jsonb,
 'half-life-count'),
(12, 3, 10, 'Hard', 'MHF4U', 'Exponential and logarithmic functions',
 'Solve   log₂ x + log₂ (x − 2) = 3.', 1,
 '[
   {"text": "x = 4 and x = −2", "feedback": "Both values solve the quadratic, but one of them makes a logarithm argument negative and has to be rejected."},
   {"text": "x = 4", "feedback": "Correct. The product rule gives x(x − 2) = 8, and only the positive root keeps both arguments valid."},
   {"text": "x = −2", "feedback": "This root makes the arguments negative, which is outside the domain of a logarithm."},
   {"text": "x = 5", "feedback": "Check the conversion to exponential form: the product x(x − 2) has to equal 2 raised to the power 3."}
 ]'::jsonb,
 'log-reject-extraneous'),

-- ------ Unit 4: Trigonometric functions (radians) ------
(12, 4, 1, 'Easy', 'MHF4U', 'Trigonometric functions (radians)',
 'Convert 60° to radians.', 2,
 '[
   {"text": "π/6", "feedback": "That is 30°, which is half the angle given."},
   {"text": "π/2", "feedback": "That is 90°, a right angle, which is larger than the angle given."},
   {"text": "π/3", "feedback": "Correct. Multiply by π/180: 60 × π/180 = π/3."},
   {"text": "3π", "feedback": "The conversion factor π/180 has been used upside down, which gives a very large angle."}
 ]'::jsonb,
 'radian-degree-conversion'),
(12, 4, 2, 'Easy', 'MHF4U', 'Trigonometric functions (radians)',
 'Convert   π/4   radians to degrees.', 3,
 '[
   {"text": "90°", "feedback": "That is π/2. Halving that gives the angle asked for here."},
   {"text": "180°", "feedback": "That is π on its own, without the division by 4."},
   {"text": "60°", "feedback": "That comes from π/3. Check the denominator carefully."},
   {"text": "45°", "feedback": "Correct. Multiply by 180/π: (π/4)(180/π) = 45."}
 ]'::jsonb,
 'radian-degree-conversion'),
(12, 4, 3, 'Easy', 'MHF4U', 'Trigonometric functions (radians)',
 'What is the exact value of   sin(π/6) ?', 0,
 '[
   {"text": "1/2", "feedback": "Correct. π/6 is 30°, and the sine of 30° is one half."},
   {"text": "√3/2", "feedback": "That is the cosine of this angle, not its sine."},
   {"text": "√2/2", "feedback": "That value belongs to π/4, the 45° angle."},
   {"text": "1", "feedback": "Sine only reaches 1 at π/2, a full right angle."}
 ]'::jsonb,
 'special-angle-ratio'),
(12, 4, 4, 'Medium', 'MHF4U', 'Trigonometric functions (radians)',
 'What is the period of   y = sin(2x) ?', 1,
 '[
   {"text": "2π", "feedback": "That is the period of the basic sine curve. The 2 inside the brackets compresses the graph horizontally."},
   {"text": "π", "feedback": "Correct. The period is 2π divided by the coefficient of x, so 2π/2 = π."},
   {"text": "4π", "feedback": "The 2 has been multiplied rather than divided. A larger coefficient inside makes the cycle finish sooner."},
   {"text": "2", "feedback": "A period measured in radians keeps a factor of π here. Divide 2π by the coefficient."}
 ]'::jsonb,
 'period-from-coefficient'),
(12, 4, 5, 'Medium', 'MHF4U', 'Trigonometric functions (radians)',
 'What is the range of   y = 3sin(x) + 2 ?', 2,
 '[
   {"text": "−3 ≤ y ≤ 3", "feedback": "This is the range after the stretch but before the vertical shift. The +2 lifts the whole graph."},
   {"text": "0 ≤ y ≤ 5", "feedback": "The lowest point is not zero. Start from the minimum of sine, which is −1, then stretch and shift."},
   {"text": "−1 ≤ y ≤ 5", "feedback": "Correct. Sine runs from −1 to 1, tripling gives −3 to 3, and adding 2 gives −1 to 5."},
   {"text": "2 ≤ y ≤ 5", "feedback": "The graph dips below the midline just as much as it rises above it."}
 ]'::jsonb,
 'range-after-transformation'),
(12, 4, 6, 'Medium', 'MHF4U', 'Trigonometric functions (radians)',
 'Solve   sin x = 1/2   for   0 ≤ x ≤ 2π.', 3,
 '[
   {"text": "x = π/6 only", "feedback": "Sine is positive in two different quadrants, so there is a second solution inside this interval."},
   {"text": "x = π/6 and 7π/6", "feedback": "The second angle here sits in a quadrant where sine is negative. Reflect the first angle across the vertical axis instead."},
   {"text": "x = π/3 and 2π/3", "feedback": "These angles belong to a different sine value. Check which special angle has a sine of one half."},
   {"text": "x = π/6 and 5π/6", "feedback": "Correct. The related acute angle is π/6, and sine is positive in the first and second quadrants."}
 ]'::jsonb,
 'second-quadrant-solution'),
(12, 4, 7, 'Medium', 'MHF4U', 'Trigonometric functions (radians)',
 'Simplify   1 − cos²x.', 0,
 '[
   {"text": "sin²x", "feedback": "Correct. Rearranging the Pythagorean identity sin²x + cos²x = 1 gives exactly this."},
   {"text": "tan²x", "feedback": "That comes from a different identity, the one involving secant. This expression only needs the Pythagorean relation."},
   {"text": "sin x", "feedback": "The square has been dropped. Rearranging the identity keeps the exponent intact."},
   {"text": "−sin²x", "feedback": "Check the signs: moving cos²x across the identity leaves a positive term behind."}
 ]'::jsonb,
 'pythagorean-identity'),
(12, 4, 8, 'Hard', 'MHF4U', 'Trigonometric functions (radians)',
 'In   y = 2cos(x − π/3) + 1,   what is the phase shift?', 1,
 '[
   {"text": "Left π/3", "feedback": "The sign inside the bracket is a subtraction, which moves the graph in the positive direction instead."},
   {"text": "Right π/3", "feedback": "Correct. Subtracting inside the bracket delays the cycle, shifting the graph in the positive x direction."},
   {"text": "Up π/3", "feedback": "Vertical movement comes from the number added outside the cosine, which here is 1."},
   {"text": "Right 2", "feedback": "The 2 in front controls the vertical stretch, not any horizontal movement."}
 ]'::jsonb,
 'phase-shift-direction'),
(12, 4, 9, 'Hard', 'MHF4U', 'Trigonometric functions (radians)',
 'What is the exact value of   cos(2π/3) ?', 3,
 '[
   {"text": "1/2", "feedback": "The related acute angle is right, but this angle lies in the second quadrant, where cosine takes the opposite sign."},
   {"text": "√3/2", "feedback": "That is the sine of this angle, and the quadrant still has to be considered."},
   {"text": "−√3/2", "feedback": "The sign is right but the ratio is not. Check which value belongs to the cosine of the related acute angle π/3."},
   {"text": "−1/2", "feedback": "Correct. The related acute angle is π/3, its cosine is one half, and cosine is negative in the second quadrant."}
 ]'::jsonb,
 'quadrant-sign-cosine'),
(12, 4, 10, 'Hard', 'MHF4U', 'Trigonometric functions (radians)',
 E'A Ferris wheel completes one full rotation every 40 seconds.\nIts height is modelled by h(t) = a cos(kt) + c. What is the value of k?', 0,
 '[
   {"text": "π/20", "feedback": "Correct. The period equals 2π divided by k, so k = 2π/40 = π/20."},
   {"text": "40", "feedback": "That is the period itself. The coefficient inside the brackets is 2π divided by the period."},
   {"text": "2π/20", "feedback": "This divides by half the period. The full rotation takes 40 seconds, not 20."},
   {"text": "20/π", "feedback": "The fraction is upside down. Dividing 2π by 40 leaves the π on the top."}
 ]'::jsonb,
 'period-to-coefficient'),

-- ------ Unit 5: Rates of change and combining functions ------
(12, 5, 1, 'Easy', 'MHF4U', 'Rates of change and combining functions',
 'What is the average rate of change of   f(x) = x²   from x = 1 to x = 4?', 1,
 '[
   {"text": "15", "feedback": "That is the change in y only. A rate also needs dividing by the change in x."},
   {"text": "5", "feedback": "Correct. (16 − 1)/(4 − 1) = 15/3 = 5."},
   {"text": "3", "feedback": "That is the change in x, the denominator of the calculation, rather than the whole rate."},
   {"text": "8", "feedback": "This looks like a rate at a single endpoint rather than the average across the whole interval."}
 ]'::jsonb,
 'average-rate-of-change'),
(12, 5, 2, 'Easy', 'MHF4U', 'Rates of change and combining functions',
 'If   f(x) = x²   and   g(x) = 3x − 1,   find   (f + g)(2).', 3,
 '[
   {"text": "20", "feedback": "This multiplies the two results instead of adding them."},
   {"text": "4", "feedback": "That is only f(2). The second function still has to be evaluated and added on."},
   {"text": "5", "feedback": "That is only g(2). The value of the first function has to be added as well."},
   {"text": "9", "feedback": "Correct. f(2) = 4 and g(2) = 5, so the sum is 9."}
 ]'::jsonb,
 'adds-vs-multiplies-functions'),
(12, 5, 3, 'Easy', 'MHF4U', 'Rates of change and combining functions',
 'If   f(x) = x + 3   and   g(x) = 2x,   find   f(g(x)).', 2,
 '[
   {"text": "2x + 6", "feedback": "This applies the doubling last instead of first, which is the other order of composition."},
   {"text": "2x² + 3", "feedback": "No squaring happens here, since neither function contains an x²."},
   {"text": "2x + 3", "feedback": "Correct. g acts first and gives 2x, then f adds 3 to that."},
   {"text": "x + 6", "feedback": "Check which function is applied first. The inner one multiplies before the addition happens."}
 ]'::jsonb,
 'composition-order'),
(12, 5, 4, 'Medium', 'MHF4U', 'Rates of change and combining functions',
 'What does the slope of a tangent line to a curve at a point represent?', 0,
 '[
   {"text": "The instantaneous rate of change at that point", "feedback": "Correct. A tangent touches the curve at a single point, and its slope gives the rate of change right there."},
   {"text": "The average rate of change over an interval", "feedback": "That is the slope of a secant line joining two separate points, not a line touching at one."},
   {"text": "The total change in y", "feedback": "A slope is a ratio of two changes, not a single change on its own."},
   {"text": "The area underneath the curve", "feedback": "Area is a different measurement entirely and is not given by a slope."}
 ]'::jsonb,
 'tangent-vs-secant'),
(12, 5, 5, 'Medium', 'MHF4U', 'Rates of change and combining functions',
 'What is the average rate of change of   f(x) = 2ˣ   from x = 0 to x = 3?', 2,
 '[
   {"text": "8", "feedback": "That is f(3) on its own. The starting value and the width of the interval still have to be used."},
   {"text": "7", "feedback": "That is the rise. Dividing by the run of 3 completes the calculation."},
   {"text": "7/3", "feedback": "Correct. (8 − 1)/(3 − 0) = 7/3."},
   {"text": "3", "feedback": "That is the run, the denominator, rather than the full ratio."}
 ]'::jsonb,
 'average-rate-of-change'),
(12, 5, 6, 'Medium', 'MHF4U', 'Rates of change and combining functions',
 'If   f(x) = √x   and   g(x) = x − 4,   what is the domain of   (f + g)(x) ?', 1,
 '[
   {"text": "All real numbers", "feedback": "One of the two functions has a restricted domain, and the sum inherits that restriction."},
   {"text": "x ≥ 0", "feedback": "Correct. The square root needs a nonnegative input and the linear part accepts everything, so the overlap is x ≥ 0."},
   {"text": "x ≥ 4", "feedback": "The 4 comes from the linear function, which places no restriction of its own."},
   {"text": "x ≠ 0", "feedback": "Zero is perfectly acceptable under a square root. The restriction is about negative inputs."}
 ]'::jsonb,
 'combined-domain-restriction'),
(12, 5, 7, 'Medium', 'MHF4U', 'Rates of change and combining functions',
 'If   f(x) = x² + 2x   and   g(x) = x² − 5,   find   (f − g)(x).', 3,
 '[
   {"text": "2x − 5", "feedback": "The minus sign has to be distributed across both terms of the second function."},
   {"text": "2x² + 2x − 5", "feedback": "The two x² terms are being added. One is subtracted from the other, so look again at what they leave behind."},
   {"text": "2x² + 2x + 5", "feedback": "The sign on the constant is handled correctly, but check what happens to the two x² terms under subtraction."},
   {"text": "2x + 5", "feedback": "Correct. The x² terms cancel, and subtracting −5 gives +5."}
 ]'::jsonb,
 'subtract-distribute-sign'),
(12, 5, 8, 'Hard', 'MHF4U', 'Rates of change and combining functions',
 E'An object moves so that its position in metres is s(t) = t² − 4t, with t in seconds.\nWhat is its average velocity from t = 1 to t = 3?', 0,
 '[
   {"text": "0 m/s", "feedback": "Correct. s(1) = −3 and s(3) = −3, so the displacement across the interval is zero even though the object moved."},
   {"text": "−3 m/s", "feedback": "That is the position at each endpoint, not the change between them."},
   {"text": "2 m/s", "feedback": "This is the width of the time interval rather than a velocity."},
   {"text": "−6 m/s", "feedback": "The two position values have been added rather than subtracted."}
 ]'::jsonb,
 'displacement-vs-distance'),
(12, 5, 9, 'Hard', 'MHF4U', 'Rates of change and combining functions',
 'Which function grows the fastest for very large values of x?', 1,
 '[
   {"text": "y = x²", "feedback": "A polynomial is eventually overtaken by exponential growth, no matter how large its degree."},
   {"text": "y = 2ˣ", "feedback": "Correct. Exponential growth eventually outpaces any polynomial or logarithmic function."},
   {"text": "y = 100x", "feedback": "A big coefficient wins early, but the growth stays linear, so faster-curving functions catch up."},
   {"text": "y = log x", "feedback": "Logarithms grow more slowly than everything else on this list."}
 ]'::jsonb,
 'growth-rate-comparison'),
(12, 5, 10, 'Hard', 'MHF4U', 'Rates of change and combining functions',
 'If   f(x) = x²   and   g(x) = x − 3,   find   (f ∘ g)(5).', 2,
 '[
   {"text": "22", "feedback": "This applies the functions in the opposite order, squaring 5 first and then subtracting 3."},
   {"text": "25", "feedback": "This squares 5 and stops. The inner function has to act on the 5 first."},
   {"text": "4", "feedback": "Correct. g(5) = 2, and squaring that gives 4."},
   {"text": "2", "feedback": "That is the value of g(5). The outer squaring step is still to come."}
 ]'::jsonb,
 'composition-order');

-- ---------------------------------------------------------------------------
-- Check it worked
-- ---------------------------------------------------------------------------
-- 20 rows, 10 questions in every one, and no nulls in the tag column.

select grade, course_code, unit, count(*) as questions,
       count(misconception_tag) as tagged
from questions
group by grade, course_code, unit, unit_order
order by grade, unit_order;

-- The tag vocabulary itself, most reused first. Useful for spotting a slug
-- that was typed two different ways.
select misconception_tag, count(*) as questions
from questions
group by misconception_tag
order by count(*) desc, misconception_tag;
