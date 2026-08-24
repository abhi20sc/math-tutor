-- ===========================================================================
-- MCR3U — Unit 4: Exponential Functions — 40 questions
-- ===========================================================================
-- Grade 11 Exponential Functions, authored from the Jensen MCR3U lesson
-- material for this unit:
--
--   Lesson 1  Exponential growth
--   Lesson 2  Exponential decay
--   Lesson 3  Compound interest
--   Lesson 4  Properties of exponential functions
--   Lesson 5  Transformations of exponential functions
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every number in this file was recomputed independently with sympy and
-- Python before delivery; nothing was copied from the source PDFs. Money is
-- rounded to the nearest cent and populations to whole individuals, and the
-- distractors are rounded the same way so rounding alone can never pick out
-- the answer.
--
-- The mistake this unit exists to catch, and the reason half the distractors
-- here are the same shape: compound change is not repeated simple change.
-- A student who answers 13 percent for ten years with 20000 x 1.13 x 10 has
-- made the single most expensive error in the unit, and it is the same error
-- whether the context is a population, a half-life or a bank balance.
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
--
-- No figures. The graph-matching questions in the Jensen review need four
-- pictures to be answerable, and a picture of the curve gives away the shape
-- that IS the answer. Those questions are asked here through their key
-- points instead, which is strictly harder and cannot leak.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Exponential Functions';

insert into misconception_labels (tag, label) values
  ('sub-exp-growth',          'Exponential growth'),
  ('sub-exp-decay',           'Exponential decay'),
  ('sub-compound-interest',   'Compound interest'),
  ('sub-exp-properties',      'Properties of exponential functions'),
  ('sub-exp-transformations', 'Transforming exponential functions')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 1, 'Easy',
 E'An insect colony starts at 15 and QUADRUPLES every day.\nWhich function models the population after n days?',
 '[{"text": "P(n) = 15 + 4n", "feedback": "That adds 4 each day, which is straight-line growth. Quadrupling multiplies, so the 4 belongs in the exponent position."},
   {"text": "P(n) = 4(15)ⁿ", "feedback": "The starting amount and the growth factor have swapped places. The colony starts at 15, not at 4."},
   {"text": "P(n) = 15(4n)", "feedback": "That multiplies by 4n, so day 2 would only be eight times the start. Each day multiplies by 4 again, which is a power."},
   {"text": "P(n) = 15(4)ⁿ", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 2, 'Easy',
 'In y = 200(3)ˣ, what is the initial amount?',
 '[{"text": "0", "feedback": "The initial amount is the value at x = 0, and an exponential with a positive front number is never zero."},
   {"text": "200", "feedback": "Correct."},
   {"text": "3", "feedback": "The 3 is the growth factor, the number the amount is multiplied by each step."},
   {"text": "600", "feedback": "That multiplies the two numbers together. At x = 0 the power is 1, so only the front number survives."}]'::jsonb,
 1, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 3, 'Easy',
 'In y = a(b)ˣ with a positive, which value of b gives DECAY?',
 '[{"text": "b = 0.8", "feedback": "Correct."},
   {"text": "b = 1.2", "feedback": "Anything above 1 makes the amount larger each step, which is growth."},
   {"text": "b = 2", "feedback": "A base of 2 doubles the amount every step, which is the fastest growth on this list."},
   {"text": "b = 1", "feedback": "A base of exactly 1 leaves the amount unchanged forever, so it neither grows nor decays."}]'::jsonb,
 0, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 4, 'Easy',
 'A car loses 20 percent of its value each year. What is the base b in y = a(b)ˣ?',
 '[{"text": "0.8", "feedback": "Correct."},
   {"text": "0.2", "feedback": "0.2 is the fraction LOST. The base is the fraction that survives, which is what is left of the whole."},
   {"text": "1.2", "feedback": "Adding the 20 percent makes the car gain value. A loss subtracts from 1."},
   {"text": "20", "feedback": "The percent has to become a decimal before it can be used, and it has to be subtracted from 1."}]'::jsonb,
 0, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 5, 'Easy',
 'In A = P(1 + i)ⁿ, what is i for 7 percent per year compounded annually?',
 '[{"text": "1.07", "feedback": "That is the whole bracket, 1 + i, already worked out. On its own i is just the rate."},
   {"text": "0.7", "feedback": "7 percent is 7 hundredths, not 7 tenths. The decimal point moved one place too few."},
   {"text": "0.07", "feedback": "Correct."},
   {"text": "7", "feedback": "The percent has to be divided by 100 before it goes into the formula."}]'::jsonb,
 2, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 6, 'Easy',
 'What is $1000 worth after 1 year at 5 percent compounded annually?',
 '[{"text": "$950.00", "feedback": "Interest is earned, so it is added. Subtracting would be a loss."},
   {"text": "$1050.00", "feedback": "Correct."},
   {"text": "$1005.00", "feedback": "That uses 0.005 as the rate. 5 percent is 5 hundredths, which is 0.05."},
   {"text": "$1500.00", "feedback": "That adds 50 percent. The rate is 5 percent, ten times smaller."}]'::jsonb,
 1, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 7, 'Easy',
 'What is the horizontal asymptote of y = 2ˣ?',
 '[{"text": "y = 2", "feedback": "The 2 is the base, which sets how fast the curve climbs. It does not set the floor."},
   {"text": "y = 1", "feedback": "1 is where the curve crosses the y-axis. The asymptote is the level it heads toward far to the left."},
   {"text": "y = 0", "feedback": "Correct."},
   {"text": "x = 0", "feedback": "A horizontal asymptote is a horizontal line, so its equation names y. This curve has no vertical asymptote at all."}]'::jsonb,
 2, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 8, 'Easy',
 'What is the y-intercept of y = 5(3)ˣ?',
 '[{"text": "3", "feedback": "The 3 is the base. At x = 0 the base raised to the power 0 is 1, so it disappears."},
   {"text": "15", "feedback": "That multiplies the two numbers. Anything to the power 0 is 1, not itself."},
   {"text": "1", "feedback": "That is only what the power on its own is worth at x = 0. The y-intercept is the whole value of y there, not just the power."},
   {"text": "5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 9, 'Easy',
 'How does the graph of y = 2ˣ + 4 compare with y = 2ˣ?',
 '[{"text": "It is 4 units to the left", "feedback": "A sideways move needs the 4 in the exponent. Out here it acts on the y-values."},
   {"text": "It is 4 units further down", "feedback": "The 4 is being added to every output, which lifts the curve."},
   {"text": "It is 4 units higher", "feedback": "Correct."},
   {"text": "It is 4 units to the right", "feedback": "A sideways move needs the 4 in the exponent, as 2 to the power x - 4. Out here it acts on the y-values."}]'::jsonb,
 2, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 10, 'Easy',
 'How does the graph of y = -2ˣ compare with y = 2ˣ?',
 '[{"text": "It is reflected in the y-axis", "feedback": "A y-axis reflection needs the minus on the x, as 2 to the power -x. Out here the minus multiplies the output."},
   {"text": "It is shifted downward by 1 unit", "feedback": "A shift needs a number added or subtracted. The minus multiplies every output by -1 instead."},
   {"text": "It is reflected in the x-axis", "feedback": "Correct."},
   {"text": "It decays away instead of growing", "feedback": "The base is still 2, so the size of the output keeps doubling. The minus flips the curve rather than slowing it."}]'::jsonb,
 2, 'sub-exp-transformations'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 11, 'Medium',
 'An ant colony of 213 doubles every week. What is the population after 4 weeks?',
 '[{"text": "3408", "feedback": "Correct."},
   {"text": "1704", "feedback": "Only three doublings were counted. Four weeks means the 2 is used four times."},
   {"text": "6816", "feedback": "One doubling too many. After four weeks the exponent is 4, not 5."},
   {"text": "852", "feedback": "That multiplies by 4 once. Doubling four times multiplies by 2 to the power 4, which is a good deal more."}]'::jsonb,
 0, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 12, 'Medium',
 E'A town of 20000 grows by 13 percent each year.\nWhat is the population after 10 years, to the nearest whole person?',
 '[{"text": "275 717", "feedback": "The growth factor was written as 1.3. A 13 percent rise makes the factor 1.13, not 1.3."},
   {"text": "67 891", "feedback": "Correct."},
   {"text": "46 000", "feedback": "That adds 13 percent of the ORIGINAL ten times over. Each year the percentage is taken of the new, larger number."},
   {"text": "22 600", "feedback": "Only one year of growth was applied. The exponent has to be 10."}]'::jsonb,
 1, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 13, 'Medium',
 E'Radium has a half-life of 1620 years. A hospital buys 0.5 g.\nHow much is left after 4860 years?',
 '[{"text": "0.03125 g", "feedback": "One half-life too many. 4860 divided by 1620 is exactly three, not four."},
   {"text": "0.1667 g", "feedback": "That divides the amount by 3. Three half-lives halve it three times over, which is a division by 8."},
   {"text": "0.0625 g", "feedback": "Correct."},
   {"text": "0.125 g", "feedback": "Only two half-lives were counted. 4860 divided by 1620 gives three."}]'::jsonb,
 2, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 14, 'Medium',
 E'Polonium-210 has a half-life of 20 days. A sample starts at 40 mg.\nWhich equation gives the mass remaining after t days?',
 '[{"text": "f(t) = 40(2)^(t/20)", "feedback": "A base of 2 doubles the sample every 20 days. A half-life halves it."},
   {"text": "f(t) = 20(1/2)^(t/40)", "feedback": "The starting mass and the half-life have swapped places. The sample starts at 40 mg."},
   {"text": "f(t) = 40(1/2)^(t/20)", "feedback": "Correct."},
   {"text": "f(t) = 40(1/2)^(20t)", "feedback": "The half-life multiplies t here instead of dividing it, so the sample would be halved 20 times on day 1. The exponent has to count halvings, not days."}]'::jsonb,
 2, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 15, 'Medium',
 'How much is $1500 worth after 8 years at 3.5 percent compounded annually?',
 '[{"text": "$16 548.61", "feedback": "The growth factor was written as 1.35. A 3.5 percent rate makes it 1.035."},
   {"text": "$1975.21", "feedback": "Correct."},
   {"text": "$1920.00", "feedback": "That is simple interest: 3.5 percent of the original, eight times. Compounding takes the percentage of the new balance each year."},
   {"text": "$1552.50", "feedback": "Only one year of interest was applied. The exponent has to be 8."}]'::jsonb,
 1, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 16, 'Medium',
 E'An investment earns 7 percent per year compounded annually.\nHow much must be invested now to have $13 450 in 9 years?',
 '[{"text": "$7315.91", "feedback": "Correct."},
   {"text": "$24 727.28", "feedback": "That grows the money forward for another nine years. To find the starting amount, divide rather than multiply."},
   {"text": "$4976.50", "feedback": "That takes 7 percent off nine times as a simple percentage of the original, which strips away far too much."},
   {"text": "$12 570.09", "feedback": "Only one year was undone. The 1.07 has to be raised to the power 9."}]'::jsonb,
 0, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 17, 'Medium',
 'What are the domain and range of y = 3(2)ˣ?',
 '[{"text": "Domain all positive numbers, range y > 0", "feedback": "Negative exponents are perfectly legal here; they just give small positive outputs."},
   {"text": "Domain all real numbers, range y > 3", "feedback": "3 is the y-intercept, not the floor. Far to the left the outputs drop below 3 and keep going."},
   {"text": "Domain all real numbers, range y > 0", "feedback": "Correct."},
   {"text": "Domain all real numbers, range y ≥ 0", "feedback": "The curve gets as close to zero as you like but never lands on it, so zero itself is not in the range."}]'::jsonb,
 2, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 18, 'Medium',
 'An exponential curve passes through (0, 6) and (1, 12). Which equation fits?',
 '[{"text": "y = 2(6)ˣ", "feedback": "The starting value and the base have swapped places. At x = 0 the output has to be 6."},
   {"text": "y = 6 + 6x", "feedback": "That fits both given points but grows by adding, so at x = 2 it gives 18 where the curve gives 24."},
   {"text": "y = 6(2)ˣ", "feedback": "Correct."},
   {"text": "y = 6(0.5)ˣ", "feedback": "This curve falls, and the given points climb from 6 to 12. The base is found by DIVIDING the second output by the first."}]'::jsonb,
 2, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 19, 'Medium',
 'Write the equation for y = 3ˣ shifted right 2 and down 5.',
 '[{"text": "y = 3^(x - 2) - 5", "feedback": "Correct."},
   {"text": "y = 3^(x + 2) - 5", "feedback": "A shift RIGHT is written x - 2. The sign in the exponent is the opposite of the direction."},
   {"text": "y = 3^(x - 2) + 5", "feedback": "A shift down subtracts from the output, so the constant on the end is negative."},
   {"text": "y = 3^(x - 5) - 2", "feedback": "The two numbers have swapped jobs. The 2 is the sideways move and the 5 is the vertical one."}]'::jsonb,
 0, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 20, 'Medium',
 'What is the horizontal asymptote of y = 2ˣ - 7?',
 '[{"text": "y = 0", "feedback": "That is the parent asymptote of 2 to the power x, before the curve was pulled down."},
   {"text": "y = 7", "feedback": "The 7 is being subtracted, so the whole curve drops and its floor drops with it."},
   {"text": "x = -7", "feedback": "A horizontal asymptote is a horizontal line, so its equation names y. This curve has no vertical asymptote."},
   {"text": "y = -7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-transformations'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): word problems, solving for the exponent, choosing a model.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 21, 'Challenge',
 E'A bacteria culture starts at 12 000 and doubles every four hours.\nHow many are present after one day?',
 '[{"text": "288 000", "feedback": "That multiplies by 24. The 24 hours has to be divided by the four-hour period first, and the result used as an exponent."},
   {"text": "201 326 592 000", "feedback": "The four-hour period was ignored, so 24 doublings were counted instead of six."},
   {"text": "768 000", "feedback": "Correct."},
   {"text": "96 000", "feedback": "That is the count after 12 hours. One day is 24 hours, which is six doubling periods, not three."}]'::jsonb,
 2, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 22, 'Challenge',
 E'A culture of 20 bacteria doubles every 15 minutes.\nHow long does it take to reach 163 840?',
 '[{"text": "180 minutes", "feedback": "Twelve doublings gets to 81 920, which is only half way. One more period is needed."},
   {"text": "8192 minutes", "feedback": "8192 is how many times the colony has multiplied, not a length of time. Write it as a power of 2 first."},
   {"text": "195 minutes", "feedback": "Correct."},
   {"text": "13 minutes", "feedback": "13 is the number of DOUBLINGS. Each one takes 15 minutes, so they still have to be multiplied out."}]'::jsonb,
 2, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 23, 'Challenge',
 E'A coffee contains 96 mg of caffeine, and the amount in the body halves\nevery 5 hours. How long until only 12 mg is left?',
 '[{"text": "40 hours", "feedback": "That multiplies the 5 hours by 8. The 8 is the division factor; the number of halvings is the power of 2 inside it."},
   {"text": "15 hours", "feedback": "Correct."},
   {"text": "3 hours", "feedback": "3 is the number of HALVINGS. Each one takes 5 hours, so they still have to be multiplied out."},
   {"text": "8 hours", "feedback": "8 is how many times smaller the amount has become, not a length of time. Write it as a power of 2 first."}]'::jsonb,
 1, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 24, 'Challenge',
 E'A motorcycle costs $13 500 and depreciates by 20 percent of its current\nvalue every year. What is it worth after 6 years?',
 '[{"text": "$4423.68", "feedback": "Only five years were counted. The 0.8 has to be used six times."},
   {"text": "$10 800.00", "feedback": "Only one year was counted. The 0.8 has to be raised to the power 6."},
   {"text": "$0.00", "feedback": "That takes 20 percent of the ORIGINAL price six times, which wipes the value out entirely. Each year the percentage is of the current, smaller value."},
   {"text": "$3538.94", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 25, 'Challenge',
 E'Five years ago Denise deposited money at 7.5 percent compounded annually.\nToday the balance is $4200. What was the deposit?',
 '[{"text": "$6029.64", "feedback": "That grows the money forward another five years. Going back in time means dividing by the growth factor."},
   {"text": "$2625.00", "feedback": "That takes 7.5 percent of $4200 away five times over. Compounding does not work backwards as a flat percentage."},
   {"text": "$3906.98", "feedback": "Only one year was undone. The 1.075 has to be raised to the power 5."},
   {"text": "$2925.55", "feedback": "Correct."}]'::jsonb,
 3, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 26, 'Challenge',
 E'Money is invested at 3.5 percent compounded annually.\nRoughly how long does it take to double?',
 '[{"text": "About 20 years", "feedback": "Correct."},
   {"text": "About 29 years", "feedback": "That is 100 divided by 3.5, which is the rule for SIMPLE interest. Compounding gets there noticeably sooner."},
   {"text": "About 10 years", "feedback": "After 10 years the balance has grown by roughly 41 percent, which is well short of doubling."},
   {"text": "About 2 years", "feedback": "That divides 2 by 1.035. Solving for an exponent needs logarithms: log 2 divided by log 1.035."}]'::jsonb,
 0, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 27, 'Challenge',
 'Which equation gives a DECREASING curve with a y-intercept of 3?',
 '[{"text": "y = -3ˣ", "feedback": "This one falls, but it starts at -1 and lives entirely below the x-axis."},
   {"text": "y = 3(1/3)ˣ", "feedback": "Correct."},
   {"text": "y = 3(3ˣ)", "feedback": "The y-intercept is right, but a base above 1 makes the curve climb."},
   {"text": "y = (1/3)(3ˣ)", "feedback": "The base and the front number are the wrong way round: this crosses the y-axis at one third and then climbs."}]'::jsonb,
 1, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 28, 'Challenge',
 'A curve passes through (0, 8), (1, 4) and (2, 2). Which equation fits?',
 '[{"text": "y = 8(1/2)ˣ", "feedback": "Correct."},
   {"text": "y = 8(2)ˣ", "feedback": "The outputs are falling, so the base has to be below 1. Divide each output by the one before it to find it."},
   {"text": "y = 4(1/2)ˣ", "feedback": "The base is right but the starting value is not. At x = 0 the output has to be 8."},
   {"text": "y = 8 - 4x", "feedback": "That fits the first two points but reaches 0 at x = 2, where the curve is still at 2. Halving never gets to zero."}]'::jsonb,
 0, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 29, 'Challenge',
 E'For f(x) = -2(1/2)^(x + 1) - 2, is the function increasing or decreasing,\nand where is its horizontal asymptote?',
 '[{"text": "Increasing, asymptote y = 2", "feedback": "The 2 on the end is being subtracted, so the asymptote sits below the axis."},
   {"text": "Increasing, asymptote y = -2", "feedback": "Correct."},
   {"text": "Decreasing, asymptote y = -2", "feedback": "The base below 1 does fall, but the minus in front turns the whole curve over, so it climbs."},
   {"text": "Increasing, asymptote y = 0", "feedback": "The - 2 on the end drags the whole curve down, and its asymptote goes with it."}]'::jsonb,
 1, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 30, 'Challenge',
 'What is the y-intercept of y = 4(3)^(x - 1) + 2?',
 '[{"text": "4/3", "feedback": "The power was handled correctly but the + 2 was never added on."},
   {"text": "10/3", "feedback": "Correct."},
   {"text": "6", "feedback": "The shift was ignored, so 3 to the power 0 was used. At x = 0 the exponent is -1, not 0."},
   {"text": "14", "feedback": "The exponent came out as +1 rather than -1. Substituting x = 0 into x - 1 gives a negative."}]'::jsonb,
 1, 'sub-exp-transformations'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): solving for the period, comparing models, combined shifts.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Exponential Functions', 4, 31, 'Advanced',
 E'A culture starts with 50 bacteria. After 3 minutes there are 204 800.\nWhat is the doubling period?',
 '[{"text": "15 seconds", "feedback": "Correct."},
   {"text": "12 minutes", "feedback": "12 is the number of DOUBLINGS that happened in those 3 minutes, not how long one of them takes."},
   {"text": "4 minutes", "feedback": "The equation 12 = 3/t was solved upside down. Solving it properly makes t a fraction of a minute, not several minutes."},
   {"text": "0.25 seconds", "feedback": "The working gives 0.25 MINUTES. A quarter of a minute is not a quarter of a second."}]'::jsonb,
 0, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 32, 'Advanced',
 'Insects follow P(n) = 15(4)ⁿ with n in days. How many are there after one week?',
 '[{"text": "61 440", "feedback": "Six days were counted. A week is seven."},
   {"text": "983 040", "feedback": "Eight days were counted. A week is seven."},
   {"text": "420", "feedback": "That works out 15 times 4 times 7. The 7 is an exponent, so the 4 is used seven times over."},
   {"text": "245 760", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-growth'),

(11, 'MCR3U', 'Exponential Functions', 4, 33, 'Advanced',
 E'Polonium-210 has a half-life of 20 days.\nHow long until a sample decays to 8 percent of its initial mass?',
 '[{"text": "About 73 days", "feedback": "Correct."},
   {"text": "About 3.6 days", "feedback": "3.6 is the number of HALF-LIVES needed. Each one lasts 20 days, so they still have to be multiplied out."},
   {"text": "About 60 days", "feedback": "Three whole half-lives leaves 12.5 percent, which has not fallen far enough. It does not land on a whole number of half-lives."},
   {"text": "About 160 days", "feedback": "That counts eight half-lives because the 8 in 8 percent was read as a number of halvings."}]'::jsonb,
 0, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 34, 'Advanced',
 E'A motorcycle depreciates by 20 percent of its current value each year.\nHow long until it is worth half of what it cost?',
 '[{"text": "About 2.5 years", "feedback": "That divides 50 by 20, which treats the loss as a flat amount each year. Each year takes 20 percent of a smaller value than the year before."},
   {"text": "About 0.32 years", "feedback": "The logarithms are the wrong way up. It is log 0.5 divided by log 0.8, not the other way round."},
   {"text": "About 10 years", "feedback": "By then it is worth about a tenth of its cost, not half."},
   {"text": "About 3.1 years", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-decay'),

(11, 'MCR3U', 'Exponential Functions', 4, 35, 'Advanced',
 E'An account pays 7.5 percent compounded annually and holds $4200 today.\nWhat was in it two years ago, and what will be in it two years from now?',
 '[{"text": "$3634.40 two years ago, $4853.63 in two years", "feedback": "Correct."},
   {"text": "$4853.63 two years ago, $3634.40 in two years", "feedback": "The two directions are swapped. Going back in time divides by the growth factor and going forward multiplies."},
   {"text": "$3570.00 two years ago, $4830.00 in two years", "feedback": "That applies 7.5 percent of the CURRENT balance twice in each direction, which is simple interest rather than compounding."},
   {"text": "$3906.98 two years ago, $4515.00 in two years", "feedback": "Only one year was applied in each direction. The 1.075 has to be squared."}]'::jsonb,
 0, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 36, 'Advanced',
 E'$5000 is put into one account at 6 percent compounded annually, and $5000\ninto another at 6.5 percent SIMPLE interest. After 10 years, which is worth\nmore and by roughly how much?',
 '[{"text": "The two accounts end up worth the same", "feedback": "They would only match if the compounding never happened. Work both out to ten years and the totals are several hundred dollars apart."},
   {"text": "The compound account, by about $704", "feedback": "Correct."},
   {"text": "The simple interest account, by about $704", "feedback": "The gap is about that size, so the arithmetic held up; what has not been checked is which of the two balances the subtraction started from. Work both out to year 10 before deciding the direction."},
   {"text": "The simple account, because its rate is higher", "feedback": "A higher rate does win at first, but simple interest only ever earns on the original $5000 while the other earns on everything accumulated."}]'::jsonb,
 1, 'sub-compound-interest'),

(11, 'MCR3U', 'Exponential Functions', 4, 37, 'Advanced',
 'Why can y = a(b)ˣ, with a and b both positive, never output zero?',
 '[{"text": "Because the exponent x is not allowed to take the value zero", "feedback": "x = 0 is perfectly legal and gives the y-intercept. It is the OUTPUT that never reaches zero."},
   {"text": "Because the base b is only ever allowed to be greater than 1", "feedback": "b can be a fraction, and the curve then falls forever without ever landing on zero."},
   {"text": "Because the graph of y = a(b)ˣ is a straight line and not a curve", "feedback": "The graph is a curve. A straight line with a non-zero slope actually would cross zero, which is the opposite of what happens here."},
   {"text": "Because a positive base raised to any power stays positive", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 38, 'Advanced',
 'How does the graph of y = (1/3)(3ˣ) differ from the graph of y = 3(3ˣ)?',
 '[{"text": "The new curve settles onto a different horizontal asymptote from the first one", "feedback": "Multiplying by 1/3 leaves zero at zero, so both curves settle onto the same floor."},
   {"text": "Same shape and same asymptote, but it crosses the y-axis at 1/3 instead of 3", "feedback": "Correct."},
   {"text": "It decays as x increases instead of growing", "feedback": "The base is 3 in both, so both climb. The 1/3 out front only scales the outputs."},
   {"text": "It is the first curve shifted straight down", "feedback": "The 1/3 multiplies every output rather than subtracting from it, so the curve is squashed toward the axis rather than slid down it."}]'::jsonb,
 1, 'sub-exp-properties'),

(11, 'MCR3U', 'Exponential Functions', 4, 39, 'Advanced',
 'Give the horizontal asymptote and the y-intercept of y = -5(2)^(x - 3) + 6.',
 '[{"text": "Asymptote y = 6, y-intercept 1", "feedback": "The shift right was ignored, so 2 to the power 0 was used. At x = 0 the exponent is -3."},
   {"text": "Asymptote y = 6, y-intercept -34", "feedback": "The exponent came out as +3 rather than -3. Substituting x = 0 into x - 3 gives a negative."},
   {"text": "Asymptote y = 0, y-intercept 43/8", "feedback": "The + 6 lifts the whole curve, and its asymptote rises with it."},
   {"text": "Asymptote y = 6, y-intercept 43/8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-transformations'),

(11, 'MCR3U', 'Exponential Functions', 4, 40, 'Advanced',
 E'y = 2ˣ is stretched vertically by 3, reflected in the x-axis and shifted up 1.\nGive the equation and the range.',
 '[{"text": "y = -3(2ˣ) + 1, range y > 1", "feedback": "The reflection puts the whole curve BELOW its asymptote, so 1 is the ceiling rather than the floor."},
   {"text": "y = 3(2ˣ) + 1, range y > 1", "feedback": "The reflection in the x-axis never reached the 3. It is the minus in front that flips the curve over."},
   {"text": "y = -3(2ˣ) + 1, range y ≤ 1", "feedback": "The curve creeps toward 1 forever without ever arriving, so 1 itself is not in the range."},
   {"text": "y = -3(2ˣ) + 1, range y < 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-transformations');
