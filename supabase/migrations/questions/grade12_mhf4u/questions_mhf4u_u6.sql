-- ===========================================================================
-- MHF4U — Unit 6: Rates of Change — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  Average rates of change
--   Lesson 2  Instantaneous rates of change
--   Lesson 3  Newton quotient
--   Lesson 4  Limits
--
-- Four lessons, five subtopics. The extra one is INTERPRETATION — units,
-- sign, and what a rate actually means in the context it came from. Jensen
-- asks for it constantly ("explain the meaning of this rate using proper
-- units") and it is where a student who can do all the arithmetic still
-- loses marks. Giving it its own traffic light means the dashboard can say
-- "the calculation is fine, the reading of it is not".
--
-- Note on scope: the Jensen review package for this unit also carries a
-- long section on rational equations and inequalities. Those belong to
-- Unit 7 in the lesson folders, and they are authored there rather than
-- here, so the two units do not overlap and no question is asked twice.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value and every limit in this file was recomputed independently
-- with sympy before delivery; nothing was copied from the source PDFs.
--
-- FIGURES: none. Half the Jensen questions here hand a student a
-- distance-time graph and ask for the slope of a secant or the shape of the
-- motion. A graph on a grid states both: you count the squares. Every one
-- of those is asked here from the coordinates or the table instead, which is
-- what a student has to be able to do anyway once the picture is taken away.
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
-- ===========================================================================

delete from questions where course_code = 'MHF4U' and unit = 'Rates of Change';

insert into misconception_labels (tag, label) values
  ('sub-average-roc',       'Average rate of change'),
  ('sub-instantaneous-roc', 'Instantaneous rate of change'),
  ('sub-newtons-quotient',  'The Newton quotient'),
  ('sub-limits',            'Limits'),
  ('sub-roc-interpretation','Interpreting a rate of change')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 1, 'Easy',
 'The average rate of change between two points on a curve is the slope of what?',
 '[{"text": "The curve at its steepest point", "feedback": "The average takes no notice of what happens in between. It depends only on the two endpoints."},
   {"text": "The secant line joining them", "feedback": "Correct."},
   {"text": "The tangent line at one of them", "feedback": "A tangent touches at a single point and gives the INSTANTANEOUS rate. An average needs two points."},
   {"text": "The horizontal x-axis of the graph", "feedback": "The axis has a slope of zero, which would make every average rate of change zero."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 2, 'Easy',
 E'A tire loses pressure from 400 kPa to 170 kPa over 30 minutes.\nWhat is the average rate of change?',
 '[{"text": "-0.13 kPa per minute", "feedback": "The fraction is upside down. The change in pressure goes on top and the change in time underneath."},
   {"text": "-7.67 kPa per minute", "feedback": "Correct."},
   {"text": "7.67 kPa per minute", "feedback": "The pressure is falling, so the rate has to be negative. The change in y is 170 take away 400."},
   {"text": "-230 kPa per minute", "feedback": "That is the total CHANGE in pressure. A rate divides it by the time it took."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 3, 'Easy',
 'The instantaneous rate of change at a point is the slope of what?',
 '[{"text": "The chord joining the endpoints of the graph", "feedback": "That is the average rate over the whole domain, which says nothing about one particular moment."},
   {"text": "The horizontal x-axis at that point", "feedback": "The axis is a fixed horizontal line and has nothing to do with the curve."},
   {"text": "The tangent line at that point", "feedback": "Correct."},
   {"text": "The secant line through two points", "feedback": "A secant gives the AVERAGE rate over an interval. Shrinking that interval to nothing is what produces the tangent."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 4, 'Easy',
 'How do you ESTIMATE an instantaneous rate of change from a table of values?',
 '[{"text": "Use the first two values in the table", "feedback": "Those give a rate near the START, which is only useful if the point of interest happens to be there."},
   {"text": "Average every value in the table", "feedback": "Averaging the VALUES gives a typical height, not a rate. A rate needs a change divided by a change."},
   {"text": "Use a small interval surrounding the point", "feedback": "Correct."},
   {"text": "Use the whole interval the table covers", "feedback": "That gives the average over everything, which can be nowhere near the rate at one particular moment."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 5, 'Easy',
 'What is the Newton quotient for a function f at a point a?',
 '[{"text": "f(a + h)/h", "feedback": "The starting value f(a) has to be subtracted. Without it this is not a change at all."},
   {"text": "[f(a + h) + f(a)]/h", "feedback": "A rate of change needs a DIFFERENCE on top, not a sum."},
   {"text": "[f(a + h) - f(a)]/h", "feedback": "Correct."},
   {"text": "[f(a) - f(a + h)]/h", "feedback": "The two terms are the wrong way round, which flips the sign of every rate it produces."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 6, 'Easy',
 'In the Newton quotient, what happens to h?',
 '[{"text": "It stays fixed", "feedback": "Leaving h fixed gives an average rate. The instantaneous rate is what appears as the interval closes up."},
   {"text": "It approaches infinity", "feedback": "A growing h widens the interval, which takes the estimate further from the point rather than closer."},
   {"text": "It approaches 0", "feedback": "Correct."},
   {"text": "It approaches 1", "feedback": "h is the width of the interval, and shrinking it to 1 still leaves a whole unit of averaging in the answer."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 7, 'Easy',
 'What is the limit of (x + 3) as x approaches 2?',
 '[{"text": "2", "feedback": "2 is the value x is heading toward. The limit is what the EXPRESSION heads toward."},
   {"text": "3", "feedback": "3 is the constant in the expression, not the value the whole thing approaches."},
   {"text": "Undefined", "feedback": "This expression is perfectly well behaved at x = 2, so the limit is simply its value there."},
   {"text": "5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 8, 'Easy',
 'A limit exists at x = a only when which of these is true?',
 '[{"text": "The left and right limits agree", "feedback": "Correct."},
   {"text": "The value of f(a) is defined there", "feedback": "A limit can exist at a point where the function has a hole. What matters is where the values are heading, not whether they arrive."},
   {"text": "The function is a polynomial there", "feedback": "Polynomials always have limits, but plenty of other functions do too."},
   {"text": "The graph is a straight line there", "feedback": "Any continuous curve has limits. Straightness is not required."}]'::jsonb,
 0, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 9, 'Easy',
 E'A tire pressure in kilopascals is measured against time in minutes.\nWhat units does its rate of change carry?',
 '[{"text": "Kilopascals on their own", "feedback": "Those are the units of the pressure itself. A rate carries the units of both quantities."},
   {"text": "Minutes of elapsed time", "feedback": "Those are the units of the time. A rate divides one quantity by the other, so both appear."},
   {"text": "Kilopascals times minutes", "feedback": "A rate DIVIDES, so the time unit ends up underneath rather than multiplied in."},
   {"text": "Kilopascals per minute", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 10, 'Easy',
 'What does a negative rate of change tell you about a quantity?',
 '[{"text": "It is undefined", "feedback": "A negative number is a perfectly ordinary answer. It only means the quantity is heading downward."},
   {"text": "It is decreasing", "feedback": "Correct."},
   {"text": "It is increasing", "feedback": "A rising quantity has a positive change on top of the fraction, so its rate is positive."},
   {"text": "It is constant", "feedback": "A constant quantity has a change of zero, so its rate is zero rather than negative."}]'::jsonb,
 1, 'sub-roc-interpretation'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 11, 'Medium',
 'For f(x) = x² - 3x + 2, find the average rate of change on -1 ≤ x ≤ 2.',
 '[{"text": "2", "feedback": "f(2) is 0 and f(-1) is 6, so the change on top is negative."},
   {"text": "-6", "feedback": "That is the total change in f. A rate divides it by the width of the interval, which is 3."},
   {"text": "6", "feedback": "That is the size of the change with the wrong sign, and it has not been divided by the interval width."},
   {"text": "-2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 12, 'Medium',
 'For f(x) = x² - 3x + 2, find the average rate of change on 4 ≤ x ≤ 8.',
 '[{"text": "4", "feedback": "4 is the width of the interval, which belongs underneath the fraction rather than being the answer."},
   {"text": "9", "feedback": "Correct."},
   {"text": "12", "feedback": "That ADDS the two function values instead of subtracting them. The top of the fraction has to be a difference."},
   {"text": "36", "feedback": "That is the total change in f. It still has to be divided by the width of the interval."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 13, 'Medium',
 E'A tire reads 400 kPa at 0 min, 335 kPa at 5 min and 295 kPa at 10 min.\nEstimate the instantaneous rate at 5 minutes using the surrounding interval.',
 '[{"text": "-13 kPa per minute", "feedback": "That uses only the interval from 0 to 5. A surrounding interval takes one reading on each side of the point."},
   {"text": "-8 kPa per minute", "feedback": "That uses only the interval from 5 to 10. A surrounding interval straddles the point."},
   {"text": "-105 kPa per minute", "feedback": "That is the total change in pressure across the interval. It still has to be divided by the 10 minutes it took."},
   {"text": "-10.5 kPa per minute", "feedback": "Correct."}]'::jsonb,
 3, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 14, 'Medium',
 E'A vole is at 0 m at 0 s, 2 m at 2 s and 8 m at 4 s. Estimate its speed at\n2 seconds by averaging the two surrounding secant slopes.',
 '[{"text": "4 m/s", "feedback": "That ADDS the two secant slopes. Averaging them means halving the total."},
   {"text": "2 m/s", "feedback": "Correct."},
   {"text": "1 m/s", "feedback": "That is the secant over the first interval alone. The second interval has to be averaged in with it."},
   {"text": "3 m/s", "feedback": "That is the secant over the second interval alone. The first interval has to be averaged in with it."}]'::jsonb,
 1, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 15, 'Medium',
 'For f(x) = x², simplify the Newton quotient [f(a + h) - f(a)]/h.',
 '[{"text": "2a + h", "feedback": "Correct."},
   {"text": "2a", "feedback": "That is the value the quotient approaches as h shrinks. Before the limit is taken, an h survives."},
   {"text": "2ah + h²", "feedback": "That is the numerator after expanding. Every term still has to be divided by h."},
   {"text": "a² + h", "feedback": "Expanding (a + h)² gives a² + 2ah + h², and the a² cancels against the one being subtracted."}]'::jsonb,
 0, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 16, 'Medium',
 'For f(x) = 3x + 1, what does the Newton quotient simplify to?',
 '[{"text": "3h", "feedback": "The numerator is 3h, and it still has to be divided by the h underneath."},
   {"text": "1", "feedback": "1 is the constant term of f, read straight off the rule. The two constants cancel in the numerator, so neither of them survives into the quotient."},
   {"text": "3", "feedback": "Correct."},
   {"text": "3 + h", "feedback": "The h terms cancel completely for a linear function. Expanding 3(a + h) + 1 leaves only 3h on top."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 17, 'Medium',
 'Find the limit of (x² - 9)/(x - 3) as x approaches 3.',
 '[{"text": "3", "feedback": "3 is the value x approaches. Factoring the top gives x + 3, and that is what has to be evaluated."},
   {"text": "6", "feedback": "Correct."},
   {"text": "0", "feedback": "Substituting 3 gives 0 over 0, which is not a value but a signal to factor first."},
   {"text": "Undefined", "feedback": "The function is undefined AT 3, but the limit asks where the values head as x gets close, and they head somewhere perfectly definite."}]'::jsonb,
 1, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 18, 'Medium',
 'Find the limit of 2x/x as x approaches 0.',
 '[{"text": "2", "feedback": "Correct."},
   {"text": "0", "feedback": "Substituting gives 0 over 0. Cancelling the x first leaves a constant."},
   {"text": "Undefined", "feedback": "The expression is undefined AT 0, but the limit asks where the values head as x gets close, and they head somewhere perfectly definite."},
   {"text": "1", "feedback": "That cancels the x on top against the x underneath and throws away the coefficient standing in front of it."}]'::jsonb,
 0, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 19, 'Medium',
 E'A vole is 8 m from its burrow at 4 s and 10 m at 12 s.\nWhat is its average speed over that interval?',
 '[{"text": "4 m/s", "feedback": "That divides the time by the distance, which turns the units upside down."},
   {"text": "0.25 m/s", "feedback": "Correct."},
   {"text": "0.125 m/s", "feedback": "That divides by 16 rather than by 8. The interval runs from 4 to 12, which is 8 seconds."},
   {"text": "2 m/s", "feedback": "2 m is the total DISTANCE covered. A speed divides it by the time it took."}]'::jsonb,
 1, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 20, 'Medium',
 E'A wood-fired oven is at 25 °C at 0 minutes and 285 °C at 25 minutes.\nWhat is the average rate of change of temperature?',
 '[{"text": "10.4 °C per minute", "feedback": "Correct."},
   {"text": "11.4 °C per minute", "feedback": "That divides 285 by 25 and forgets to subtract the starting temperature."},
   {"text": "260 °C per minute", "feedback": "That is the total change in temperature. A rate divides it by the time it took."},
   {"text": "0.096 °C per minute", "feedback": "The fraction is upside down. The change in temperature goes on top."}]'::jsonb,
 0, 'sub-roc-interpretation'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): choosing the interval, and limits that need work.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 21, 'Challenge',
 'For f(x) = x² - 3x + 2, on which interval is the average rate of change ZERO?',
 '[{"text": "2 ≤ x ≤ 4", "feedback": "f(2) is 0 and f(4) is 6, so the average rate is +3."},
   {"text": "0 ≤ x ≤ 3", "feedback": "Correct."},
   {"text": "0 ≤ x ≤ 2", "feedback": "f(0) is 2 and f(2) is 0, so the average rate is -1."},
   {"text": "1 ≤ x ≤ 3", "feedback": "f(1) is 0 and f(3) is 2, so the average rate is +1."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 22, 'Challenge',
 E'An oven reads 290 °C at 13 minutes and 280 °C at 15 minutes.\nWhat is the average rate of change over that interval?',
 '[{"text": "-0.2 °C per minute", "feedback": "The fraction is upside down. The change in temperature goes on top and the change in time underneath."},
   {"text": "-5 °C per minute", "feedback": "Correct."},
   {"text": "5 °C per minute", "feedback": "The temperature fell over this interval, so the rate is negative."},
   {"text": "-10 °C per minute", "feedback": "That is the total change. It still has to be divided by the 2 minutes it took."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 23, 'Challenge',
 E'An oven reads 205 °C at 8 minutes, 250 °C at 10 minutes and 290 °C at\n13 minutes. Estimate the instantaneous rate at 10 minutes using the\nsurrounding interval.',
 '[{"text": "13.3 °C per minute", "feedback": "That uses only the interval from 10 to 13. A surrounding interval straddles the point."},
   {"text": "45 °C per minute", "feedback": "45 is a change in temperature, not a rate. It still has to be divided by the time it took."},
   {"text": "17 °C per minute", "feedback": "Correct."},
   {"text": "22.5 °C per minute", "feedback": "That uses only the interval from 8 to 10. A surrounding interval takes one reading on each side."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 24, 'Challenge',
 E'An oven reads 205 °C at 8 minutes, 250 °C at 10 minutes and 290 °C at\n13 minutes. Estimate the rate at 10 minutes by averaging the preceding\ninterval [8, 10] and the following interval [10, 13].',
 '[{"text": "17.0 °C per minute", "feedback": "That is the surrounding-interval estimate, which uses 8 and 13 directly. Averaging the two separate secants gives a slightly different number."},
   {"text": "35.8 °C per minute", "feedback": "That ADDS the two secant slopes. Averaging them means halving the total."},
   {"text": "9.0 °C per minute", "feedback": "That halves the answer a second time. The two slopes are added once and halved once."},
   {"text": "17.9 °C per minute", "feedback": "Correct."}]'::jsonb,
 3, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 25, 'Challenge',
 'For f(x) = x² - 3x + 2, simplify the Newton quotient at a general point a.',
 '[{"text": "2a + h", "feedback": "The -3x term contributes a -3h to the numerator, which leaves a -3 behind after dividing."},
   {"text": "a + h - 3", "feedback": "Expanding (a + h)² gives 2ah in the cross term, so dividing by h leaves 2a rather than a."},
   {"text": "2a + h - 3", "feedback": "Correct."},
   {"text": "2a - 3", "feedback": "That is the value the quotient approaches as h shrinks. Before the limit is taken, an h survives."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 26, 'Challenge',
 E'Using the Newton quotient, find the instantaneous rate of change\nof f(x) = x² - 3x + 2 at x = 2.',
 '[{"text": "0", "feedback": "0 is the VALUE of the function at x = 2, not its rate of change there."},
   {"text": "4", "feedback": "That evaluates only the 2a part and forgets the -3."},
   {"text": "-3", "feedback": "That evaluates only the -3 and forgets the 2a."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 27, 'Challenge',
 'Find the limit of (x² - 3x + 2)/(x - 2) as x approaches 2.',
 '[{"text": "0", "feedback": "Substituting gives 0 over 0, which is a signal to factor rather than an answer."},
   {"text": "2", "feedback": "2 is the value x approaches. Factoring the top and cancelling leaves x - 1, and that has to be evaluated."},
   {"text": "Undefined", "feedback": "The function is undefined at 2, but the limit asks where the values head as x gets close, and they head somewhere definite."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 28, 'Challenge',
 'Find the limit of (x³ - 1)/(x - 1) as x approaches 1.',
 '[{"text": "0", "feedback": "Substituting gives 0 over 0, which is a signal to factor as a difference of cubes."},
   {"text": "Undefined", "feedback": "The function has a hole at 1, but the values on either side head toward a perfectly definite number."},
   {"text": "3", "feedback": "Correct."},
   {"text": "1", "feedback": "Factoring gives x² + x + 1 after the cancellation, and substituting 1 into that adds three terms together."}]'::jsonb,
 2, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 29, 'Challenge',
 E'The secant slopes over the intervals [2, 2.5], [2, 2.1], [2, 2.01] and\n[2, 2.001] come to 1.5, 1.1, 1.01 and 1.001. What is the instantaneous\nrate at x = 2?',
 '[{"text": "1", "feedback": "Correct."},
   {"text": "1.001", "feedback": "That is the last estimate in the list, not the value they are heading toward. The pattern is still closing in."},
   {"text": "1.5", "feedback": "That is the first and crudest estimate, taken over the widest interval."},
   {"text": "0", "feedback": "The slopes are settling on a clear positive value, and none of them is anywhere near zero."}]'::jsonb,
 0, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 30, 'Challenge',
 E'A vole bolts from a hawk, running hard at first and gradually slowing to\na stop. What does its distance-time graph look like?',
 '[{"text": "Steep at first, then flattening out", "feedback": "Correct."},
   {"text": "Straight, with a constant slope", "feedback": "A constant slope means a constant speed. This vole slows down, so the slope has to change."},
   {"text": "Flat at first, then getting steeper", "feedback": "That describes something SPEEDING UP. The steep part comes first when the fastest running does."},
   {"text": "Falling as time goes on", "feedback": "A falling distance graph means moving back toward the burrow. The vole keeps going, just more slowly."}]'::jsonb,
 0, 'sub-roc-interpretation'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): working backwards, harder limits, reading a rate.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 31, 'Advanced',
 E'For f(x) = x² - 3x + 2, find the value of b for which the average rate of\nchange on 1 ≤ x ≤ b is exactly 4.',
 '[{"text": "b = 4", "feedback": "4 is the target rate copied straight into the answer. It is the value the average rate has to reach, not the endpoint that makes it happen."},
   {"text": "b = 5", "feedback": "At b = 5 the average rate is 3. One more unit is needed."},
   {"text": "b = 3", "feedback": "At b = 3 the average rate is 1, which is well short."},
   {"text": "b = 6", "feedback": "Correct."}]'::jsonb,
 3, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 32, 'Advanced',
 E'A function is never constant on an interval, yet its average rate of change\nover that interval is zero. How is that possible?',
 '[{"text": "The interval must have zero width", "feedback": "A zero-width interval makes the rate undefined rather than zero, because the denominator vanishes."},
   {"text": "The function can wander away and come back to the same value at the far end", "feedback": "Correct."},
   {"text": "The slope must be zero everywhere on the interval", "feedback": "That would make the function constant, which is exactly what is ruled out."},
   {"text": "The function has to be constant, so the situation cannot arise", "feedback": "The average depends only on the two ENDPOINTS. Everything in between is invisible to it."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 33, 'Advanced',
 E'Why does averaging the preceding and the following secant usually beat\nusing just one of them?',
 '[{"text": "It needs fewer data points", "feedback": "It needs one more, not fewer. The gain is in accuracy rather than effort."},
   {"text": "The tangent slope is the sum of the two secant slopes", "feedback": "It sits BETWEEN them, which is why they are averaged rather than added."},
   {"text": "The two secants err in opposite directions, so their average lands closer", "feedback": "Correct."},
   {"text": "A single secant always over-estimates the rate", "feedback": "It over-estimates on one side and under-estimates on the other, which is precisely why the pair is useful."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 34, 'Advanced',
 E'A secant over [2, 2.001] has slope 1.001, and over [2, 2.0001] it has\nslope 1.0001. What does this suggest about the rate at x = 2?',
 '[{"text": "It is exactly 1", "feedback": "Correct."},
   {"text": "It is exactly 1.001", "feedback": "That is one of the estimates, and the next one is already closer to a rounder number. Follow where the sequence is heading."},
   {"text": "It is exactly 0.001", "feedback": "0.001 is the width of the interval, not the slope."},
   {"text": "It cannot be found from estimates like these", "feedback": "The whole point of shrinking the interval is that the estimates close in on the exact value."}]'::jsonb,
 0, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 35, 'Advanced',
 'For f(x) = 1/x, simplify the Newton quotient [f(a + h) - f(a)]/h.',
 '[{"text": "-1/[a(a + h)]", "feedback": "Correct."},
   {"text": "1/[a(a + h)]", "feedback": "Combining the two fractions gives a - (a + h) on top, which is -h. That minus survives the division."},
   {"text": "-1/a²", "feedback": "That is the value the quotient approaches as h shrinks. Before the limit is taken, an h is still there."},
   {"text": "-1/(a + h)", "feedback": "The common denominator is a(a + h), so both factors stay underneath."}]'::jsonb,
 0, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 36, 'Advanced',
 'Using the Newton quotient, find the instantaneous rate of change of f(x) = 1/x at x = 2.',
 '[{"text": "-1/4", "feedback": "Correct."},
   {"text": "1/4", "feedback": "The function is falling everywhere it is defined, so its rate of change is negative."},
   {"text": "-1/2", "feedback": "That is f(2) with a minus attached. The rate involves the square of the a value."},
   {"text": "-4", "feedback": "The fraction is upside down. The a² sits in the DENOMINATOR."}]'::jsonb,
 0, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 37, 'Advanced',
 'Find the limit of (√(x + 4) - 2)/x as x approaches 0.',
 '[{"text": "1/4", "feedback": "Correct."},
   {"text": "0", "feedback": "Substituting gives 0 over 0, which is a signal to multiply by the conjugate rather than an answer."},
   {"text": "1/2", "feedback": "After multiplying by the conjugate the denominator becomes √(x + 4) + 2, and at x = 0 that comes to 4, not 2."},
   {"text": "Undefined", "feedback": "The expression is undefined at 0, but the values on either side head toward a perfectly definite number."}]'::jsonb,
 0, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 38, 'Advanced',
 'Find the limit of (3x² + 5)/(x² - 2) as x approaches infinity.',
 '[{"text": "0", "feedback": "The top and bottom have the SAME degree, so neither runs away from the other. The ratio settles on the leading coefficients."},
   {"text": "Infinity", "feedback": "That happens when the top has the higher degree. Here the two degrees match."},
   {"text": "-5/2", "feedback": "That is the ratio of the CONSTANT terms, which is what matters as x approaches 0 rather than infinity."},
   {"text": "3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 39, 'Advanced',
 E'An oven has an average rate of change of +10.4 °C per minute over 25\nminutes, yet its instantaneous rate at 21 minutes is negative.\nWhat does that mean?',
 '[{"text": "The temperature never actually fell", "feedback": "A negative instantaneous rate is exactly a moment when the temperature was falling."},
   {"text": "The units must have been mixed up", "feedback": "Both figures are in degrees per minute. The two simply describe different things: a whole span and a single moment."},
   {"text": "It cooled for part of the time, even though it finished hotter than it started", "feedback": "Correct."},
   {"text": "One of the two calculations must be wrong", "feedback": "Both can be right at once. The average sees only the endpoints and is blind to everything in between."}]'::jsonb,
 2, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 40, 'Advanced',
 E'A car position function has a rate of change of zero at t = 5 seconds,\nand a positive rate both just before and just after. What is happening?',
 '[{"text": "The car reverses", "feedback": "Reversing needs the rate to turn NEGATIVE. Here it only touches zero before climbing back."},
   {"text": "The car stops for good", "feedback": "Stopping for good would keep the rate at zero from then on, and here it is positive again straight after."},
   {"text": "The car is at its fastest", "feedback": "A zero rate is the slowest the car gets, not the fastest."},
   {"text": "The car pauses for an instant and then carries on forward", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-interpretation');
