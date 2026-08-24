-- ===========================================================================
-- MHF4U — Unit 3: Logarithmic Functions — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  The logarithm as the inverse of the exponential
--   Lesson 2  The power law of logarithms
--   Lesson 3  The product and quotient laws
--   Lesson 4  Solving exponential equations
--   Lesson 5  Solving logarithmic equations
--   Lesson 6  Applications of logarithms
--   Lesson 7  Transformations of log and exponential functions
--   Lesson 8  e and the natural logarithm
--
-- Eight lessons, five subtopics. Transformations, applications and the
-- natural logarithm are pooled, because a student who can transform a log
-- graph can almost always transform an exponential one, and the dashboard
-- gains nothing from splitting a hair that fine. The four that stay separate
-- are the four that genuinely come apart in practice: knowing what a log IS,
-- knowing the laws, solving for an exponent, and solving for what is inside
-- a log.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- THE EXTRANEOUS ROOT. Question 18, 28 and 37 all end in a quadratic with
-- two solutions, one of which asks for the logarithm of a negative number.
-- Offering the full pair as a distractor is the single most useful wrong
-- option in the unit, because a student who has not learned to go back and
-- check will pick it every time, and the feedback is then able to say
-- exactly which value fails and why.
--
-- FIGURES: none. Every picture this unit could carry is a log or exponential
-- curve on a grid, and the domain, the asymptote and the intercept — which
-- is most of what the questions ask — can be read straight off it.
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

delete from questions where course_code = 'MHF4U' and unit = 'Logarithmic Functions';

insert into misconception_labels (tag, label) values
  ('sub-log-as-inverse',   'Logs as the inverse of exponentials'),
  ('sub-log-laws',         'Laws of logarithms and change of base'),
  ('sub-exp-equations',    'Solving exponential equations'),
  ('sub-log-equations',    'Solving logarithmic equations'),
  ('sub-log-applications', 'Applications and transformations')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Logarithmic Functions', 3, 1, 'Easy',
 'Write 4³ = 64 in logarithmic form.',
 '[{"text": "log₃64 = 4", "feedback": "The base of the power becomes the base of the log. Here the base is 4, not the exponent."},
   {"text": "log₆₄4 = 3", "feedback": "The base and the result have swapped. 64 is what the power EQUALS, so it goes inside the log."},
   {"text": "log₄3 = 64", "feedback": "The exponent and the result have swapped. A logarithm gives you the exponent as its answer."},
   {"text": "log₄64 = 3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 2, 'Easy',
 'Write 7 = log₂128 in exponential form.',
 '[{"text": "128⁷ = 2", "feedback": "The base and the result have swapped places entirely."},
   {"text": "2¹²⁸ = 7", "feedback": "The exponent and the result have swapped. A logarithm IS the exponent, so the 7 belongs upstairs."},
   {"text": "2⁷ = 128", "feedback": "Correct."},
   {"text": "7² = 128", "feedback": "The base and the exponent have swapped. The little number on the log is the base of the power."}]'::jsonb,
 2, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 3, 'Easy',
 'What is the domain of y = log₂x?',
 '[{"text": "x > 0", "feedback": "Correct."},
   {"text": "x ≥ 0", "feedback": "Zero itself is not allowed: no power of 2 ever equals 0, it only creeps toward it."},
   {"text": "All real numbers", "feedback": "That is the RANGE. The inputs are restricted, because a positive base never produces a negative output."},
   {"text": "x ≠ 0", "feedback": "That would allow negative inputs, and no power of 2 is negative either."}]'::jsonb,
 0, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 4, 'Easy',
 'Evaluate log₂16.',
 '[{"text": "4", "feedback": "Correct."},
   {"text": "8", "feedback": "8 is half of 16. The question asks what POWER of 2 gives 16."},
   {"text": "2", "feedback": "2 is the base. What a logarithm returns is the exponent the base has to be raised to."},
   {"text": "16", "feedback": "16 is what the power equals. The log returns the exponent instead."}]'::jsonb,
 0, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 5, 'Easy',
 'What does log(ab) equal?',
 '[{"text": "log a × log b", "feedback": "Logs turn multiplication INTO addition, which is the whole point of them. They do not pass the multiplication through."},
   {"text": "log a - log b", "feedback": "Subtraction matches a QUOTIENT inside the log, not a product."},
   {"text": "log a ÷ log b", "feedback": "That expression is the change-of-base formula, which is a different thing entirely."},
   {"text": "log a + log b", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 6, 'Easy',
 'Solve 2ˣ = 32.',
 '[{"text": "x = 4", "feedback": "2 to the power 4 is 16, which is only half of 32. One more doubling is needed."},
   {"text": "x = 6", "feedback": "2 to the power 6 is 64, which overshoots."},
   {"text": "x = 5", "feedback": "Correct."},
   {"text": "x = 16", "feedback": "That divides 32 by 2. The exponent counts how many 2s are multiplied together."}]'::jsonb,
 2, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 7, 'Easy',
 'Write 64 as a power of 4.',
 '[{"text": "4⁴", "feedback": "4 to the power 4 is 256. One factor of 4 too many."},
   {"text": "4⁶", "feedback": "64 is 2 to the power 6, not 4 to the power 6. The base matters."},
   {"text": "4^(1/3)", "feedback": "A fractional exponent SHRINKS the number. 64 is bigger than 4, so the exponent has to be above 1."},
   {"text": "4³", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 8, 'Easy',
 'Solve log₃x = 4.',
 '[{"text": "x = 12", "feedback": "That multiplies the base by the exponent. Rewriting in exponential form RAISES the base to the power instead."},
   {"text": "x = 64", "feedback": "That works out 4 cubed. The base is 3 and the exponent is 4, not the other way round."},
   {"text": "x = 1/81", "feedback": "A negative exponent would give a fraction. This one is positive."},
   {"text": "x = 81", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 9, 'Easy',
 'What is the base of the natural logarithm?',
 '[{"text": "2", "feedback": "Base 2 turns up constantly in computing, but it is not what natural means."},
   {"text": "π", "feedback": "π belongs to circles. The constant behind natural growth is a different one, and slightly smaller."},
   {"text": "e, which is about 2.718", "feedback": "Correct."},
   {"text": "10", "feedback": "Base 10 is the COMMON logarithm, the one written as log with no base at all."}]'::jsonb,
 2, 'sub-log-applications'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 10, 'Easy',
 'Where is the vertical asymptote of y = log(x - 3)?',
 '[{"text": "x = -3", "feedback": "Solving x - 3 = 0 moves the 3 across as a positive number."},
   {"text": "y = 3", "feedback": "A vertical asymptote is a vertical line, so its equation names x."},
   {"text": "x = 0", "feedback": "That is the parent asymptote of y = log x. The - 3 has dragged it sideways."},
   {"text": "x = 3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Logarithmic Functions', 3, 11, 'Medium',
 'What is the inverse of f(x) = (1/4)ˣ?',
 '[{"text": "y = x^(1/4)", "feedback": "That undoes a fourth POWER. Here the variable is the exponent, not the base."},
   {"text": "y = log base 1/4 of x", "feedback": "Correct."},
   {"text": "y = log base 4 of x", "feedback": "That undoes 4ˣ, which is not the function given. Read the base inside the bracket again."},
   {"text": "y = 4ˣ", "feedback": "That is the reciprocal of the original function, not its inverse. An inverse swaps the inputs and the outputs."}]'::jsonb,
 1, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 12, 'Medium',
 'What intercepts does the graph of y = log₂x have?',
 '[{"text": "A y-intercept at (0, 1) and no x-intercept", "feedback": "That describes the EXPONENTIAL. The log is its mirror image, so the intercept swaps axes too."},
   {"text": "An x-intercept at (0, 0)", "feedback": "x = 0 is not even in the domain, so the curve never reaches the origin. That point has been borrowed from graphs that do pass through it."},
   {"text": "Intercepts at both (1, 1) and (0, 1)", "feedback": "log₂1 is 0, not 1, and x = 0 is outside the domain."},
   {"text": "An x-intercept at (1, 0) and no y-intercept", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 13, 'Medium',
 'Evaluate log₄(1/16).',
 '[{"text": "-2", "feedback": "Correct."},
   {"text": "2", "feedback": "4 squared is 16, not one sixteenth. A fraction below 1 needs a NEGATIVE exponent."},
   {"text": "-4", "feedback": "That is log₂(1/16). The base here is 4, so 1/16 has to be written as a power of 4."},
   {"text": "1/2", "feedback": "A fractional exponent gives a root, which would land between 1 and 4. This value is far smaller."}]'::jsonb,
 0, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 14, 'Medium',
 'Evaluate log₂(32³) using the power law.',
 '[{"text": "96", "feedback": "That multiplies 32 by 3 and takes the log of nothing. The power law brings the exponent OUT, it does not fold it in."},
   {"text": "15", "feedback": "Correct."},
   {"text": "5", "feedback": "That is log₂32 on its own. The exponent 3 comes out front and multiplies it."},
   {"text": "3", "feedback": "3 is the exponent that comes out front. It still has to be multiplied by log₂32."}]'::jsonb,
 1, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 15, 'Medium',
 'Solve 3^(5x) = 27^(x - 1).',
 '[{"text": "x = -1/2", "feedback": "27 is 3 cubed, so the right side becomes 3 to the power 3x - 3, not 3x - 1."},
   {"text": "x = -3/2", "feedback": "Correct."},
   {"text": "x = 3/2", "feedback": "Collecting 5x - 3x = -3 gives 2x = -3, so x lands below zero."},
   {"text": "x = -3", "feedback": "The 2 in 2x = -3 was dropped. Both sides still have to be divided by it."}]'::jsonb,
 1, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 16, 'Medium',
 'Solve 8^(2x + 1) = 32^(x - 1).',
 '[{"text": "x = -8", "feedback": "Correct."},
   {"text": "x = 8", "feedback": "Collecting 6x - 5x = -5 - 3 leaves x equal to a negative."},
   {"text": "x = -2", "feedback": "The 1 in the bracket lost its sign when it was tripled. Cubing 8 gives a left exponent of 6x + 3, not 6x - 3."},
   {"text": "x = -8/11", "feedback": "The two exponents were added rather than one being subtracted from the other."}]'::jsonb,
 0, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 17, 'Medium',
 'Solve log₂x = -3.',
 '[{"text": "x = -8", "feedback": "A negative exponent gives a small POSITIVE number, not a negative one. Powers of 2 are never negative."},
   {"text": "x = 8", "feedback": "That ignores the minus sign. A negative exponent flips the power into a fraction."},
   {"text": "x = -1/8", "feedback": "The size is right but the sign is not. 2 to any power stays above zero."},
   {"text": "x = 1/8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 18, 'Medium',
 'Solve log x + log(x - 3) = 1.',
 '[{"text": "There is no solution", "feedback": "One of the two roots survives the check. Only the negative one fails."},
   {"text": "x = 5", "feedback": "Correct."},
   {"text": "x = 5 and x = -2", "feedback": "The quadratic does give both, but -2 makes both logarithms take a negative input. It has to be thrown out."},
   {"text": "x = -2", "feedback": "-2 is the root that has to be REJECTED, because log(-2) does not exist."}]'::jsonb,
 1, 'sub-log-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 19, 'Medium',
 E'An investment is worth A = 1500(1.12)ᵗ dollars after t years.\nWhat is it worth after 4 years?',
 '[{"text": "$1680.00", "feedback": "Only one year of growth was applied. The exponent has to be 4."},
   {"text": "$6720.00", "feedback": "That multiplies 1500 by 1.12 and then by 4. The 4 is an exponent, not a multiplier."},
   {"text": "$2360.28", "feedback": "Correct."},
   {"text": "$2220.00", "feedback": "That adds 12 percent of the ORIGINAL four times over, which is simple interest rather than compounding."}]'::jsonb,
 2, 'sub-log-applications'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 20, 'Medium',
 'Write the equation for y = log x moved 3 right and 2 up.',
 '[{"text": "y = log(x - 3) - 2", "feedback": "A move up adds to the output, so the constant on the end is positive."},
   {"text": "y = log(x - 2) + 3", "feedback": "The two numbers have swapped jobs. The 3 is the sideways move and the 2 is the vertical one."},
   {"text": "y = log(x - 3) + 2", "feedback": "Correct."},
   {"text": "y = log(x + 3) + 2", "feedback": "A move RIGHT is written x - 3. The sign inside the bracket is the opposite of the direction."}]'::jsonb,
 2, 'sub-log-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): the laws combined, and equations that need logs.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Logarithmic Functions', 3, 21, 'Challenge',
 'Give the domain and range of y = log₂x and of y = 2ˣ.',
 '[{"text": "Both have domain x > 0 and range all reals", "feedback": "The exponential accepts any input at all, including negatives, which just give small positive outputs."},
   {"text": "Both have domain and range equal to all real numbers", "feedback": "Neither does. Each has exactly one side restricted, and being inverses is what swaps which side."},
   {"text": "Log: domain x > 0, range all reals. Exponential: domain all reals, range y > 0", "feedback": "Correct."},
   {"text": "Log: domain all reals, range y > 0. Exponential: domain x > 0, range all reals", "feedback": "The two functions have been swapped. The one with the restricted INPUT is the logarithm."}]'::jsonb,
 2, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 22, 'Challenge',
 'Which feature does y = 2ˣ have that y = log₂x does not?',
 '[{"text": "A maximum value", "feedback": "Neither has one. Both climb without bound, just at very different speeds."},
   {"text": "A horizontal asymptote at y = 0", "feedback": "Correct."},
   {"text": "A vertical asymptote", "feedback": "That is the LOG curve, which hugs the y-axis. The exponential has no vertical asymptote at all."},
   {"text": "An x-intercept", "feedback": "The log crosses the x-axis at (1, 0). The exponential never touches it."}]'::jsonb,
 1, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 23, 'Challenge',
 'Write log₇8 + log₇4 - log₇16 as a single logarithm.',
 '[{"text": "log₇(-4)", "feedback": "The three numbers were added and subtracted as they stood. The laws turn those operations into multiplying and dividing INSIDE the log."},
   {"text": "2", "feedback": "That reports what is left INSIDE the logarithm once the laws have been applied. The logarithm of it still has to be taken, and 7 squared is 49."},
   {"text": "log₇2", "feedback": "Correct."},
   {"text": "log₇512", "feedback": "The last term is SUBTRACTED, so its 16 divides rather than multiplies."}]'::jsonb,
 2, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 24, 'Challenge',
 'Evaluate log₆8 + log₆27.',
 '[{"text": "3", "feedback": "Correct."},
   {"text": "216", "feedback": "216 is what goes INSIDE the combined logarithm. The log of it still has to be taken."},
   {"text": "log₆35", "feedback": "The two numbers were added rather than multiplied. A sum of logs becomes a PRODUCT inside."},
   {"text": "6", "feedback": "6 is the base. What a logarithm returns is the power the base has to be raised to in order to reach 216."}]'::jsonb,
 0, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 25, 'Challenge',
 'Solve 3^(x - 2) = 5ˣ, correct to 3 decimal places.',
 '[{"text": "x = -4.301", "feedback": "Correct."},
   {"text": "x = 4.301", "feedback": "Collecting the x terms gives x(log 3 - log 5), and log 3 is smaller than log 5, so that bracket is negative."},
   {"text": "x = -2.151", "feedback": "The 2 log 3 on the right was left as log 3. Expanding (x - 2)log 3 gives x log 3 minus TWO log 3."},
   {"text": "x = 0.301", "feedback": "That is log 2 by itself. Take the log of both whole sides and expand the bracket first."}]'::jsonb,
 0, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 26, 'Challenge',
 'Solve 10 = 2 × 4^(x + 2), correct to 2 decimal places.',
 '[{"text": "x = -2.84", "feedback": "The shift of 2 was taken off twice over. Track the 2 in the exponent through the rearrangement."},
   {"text": "x = -0.84", "feedback": "Correct."},
   {"text": "x = 0.84", "feedback": "log 5 divided by log 4 is about 1.16, and the 2 still has to come off, which pushes the answer below zero."},
   {"text": "x = -1.34", "feedback": "The 2 out front was divided into the 10 twice over. One division by 2 is all the equation allows."}]'::jsonb,
 1, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 27, 'Challenge',
 'Solve log(2m + 6) - log(m² - 9) = 0.',
 '[{"text": "m = 5 and m = -3", "feedback": "5 survives the check, but -3 makes both logarithms take zero as their input."},
   {"text": "m = 5", "feedback": "Correct."},
   {"text": "m = 3", "feedback": "At m = 3 the denominator m² - 9 is zero, so the second logarithm does not exist."},
   {"text": "m = -3", "feedback": "At m = -3 both expressions inside the logarithms are zero, and log 0 does not exist."}]'::jsonb,
 1, 'sub-log-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 28, 'Challenge',
 'Solve log₂x + log₂(x - 2) = 3.',
 '[{"text": "There is no solution", "feedback": "One root survives. Only the negative one fails the check."},
   {"text": "x = 4", "feedback": "Correct."},
   {"text": "x = 4 and x = -2", "feedback": "The quadratic does give both, but -2 makes both logarithms take a negative input, so it has to be thrown out."},
   {"text": "x = -2", "feedback": "-2 is the root that has to be REJECTED. A logarithm of a negative number does not exist."}]'::jsonb,
 1, 'sub-log-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 29, 'Challenge',
 E'An investment follows A = 1500(1.12)ᵗ.\nHow long does it take to double, to 2 decimal places?',
 '[{"text": "8.33 years", "feedback": "That is 100 divided by 12, which is the rule for SIMPLE interest. Compounding gets there sooner."},
   {"text": "2.00 years", "feedback": "That reads the 2 in the doubling as the answer. The 2 goes inside a logarithm, not into the answer directly."},
   {"text": "12.00 years", "feedback": "That reads the 12 percent as a number of years. Solve 2 = 1.12 to the power t with logarithms."},
   {"text": "6.12 years", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-applications'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 30, 'Challenge',
 'How does the graph of y = log(3x) differ from the graph of y = log x?',
 '[{"text": "It is stretched vertically by a factor of 3", "feedback": "A vertical stretch by 3 needs the 3 OUTSIDE, as 3 log x. Inside, the product law turns it into an addition."},
   {"text": "It is moved up by 3 units", "feedback": "The 3 sits inside the logarithm, so it does not lift the graph by 3. A constant multiplied inside does not come out of the log unchanged."},
   {"text": "It is the same curve moved up by log 3, about 0.477", "feedback": "Correct."},
   {"text": "It is moved 3 units to the right", "feedback": "A sideways move needs the 3 ADDED or subtracted inside, as log(x - 3). Multiplying inside does something different."}]'::jsonb,
 2, 'sub-log-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): combined laws, change of base, and checking roots.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Logarithmic Functions', 3, 31, 'Advanced',
 E'The graph of y = 3ˣ and the graph of its inverse are reflections in which\nline, and what is that inverse?',
 '[{"text": "In y = x, and the inverse is y = log₃x", "feedback": "Correct."},
   {"text": "In the x-axis, and the inverse is y = log₃x", "feedback": "The inverse is right. Reflecting in the x-axis only flips the outputs; an inverse swaps inputs with outputs, which is a reflection in y = x."},
   {"text": "In y = x, and the inverse is y = 3^(1/x)", "feedback": "The line is right. A reciprocal in the exponent is not what undoes an exponential."},
   {"text": "In y = x, and the inverse is y = x³", "feedback": "The line is right. Cubing undoes a cube ROOT; here the variable is the exponent, not the base."}]'::jsonb,
 0, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 32, 'Advanced',
 'Why does the logarithm of a negative number not exist for a positive base?',
 '[{"text": "Because the base is not allowed to be negative", "feedback": "That is a separate rule about the base. The question is about what goes inside."},
   {"text": "It does exist, and it comes out negative", "feedback": "A negative OUTPUT is fine, and it happens for inputs between 0 and 1. A negative INPUT is the impossible case."},
   {"text": "Because a positive base raised to any real power stays positive", "feedback": "Correct."},
   {"text": "Because logarithms are only defined for whole numbers", "feedback": "log 2.5 exists perfectly well. It is the SIGN that is the obstacle, not whether the number is whole."}]'::jsonb,
 2, 'sub-log-as-inverse'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 33, 'Advanced',
 'Write 2 log a + log(3b) - (1/2) log c as a single logarithm.',
 '[{"text": "log(3a²b√c)", "feedback": "The last term is subtracted, so the root of c belongs on the BOTTOM."},
   {"text": "log(2a + 3b - c/2)", "feedback": "The three logs were combined as though they were plain numbers. The laws turn addition into multiplication INSIDE the log."},
   {"text": "log(3a²b/√c)", "feedback": "Correct."},
   {"text": "log(6ab/√c)", "feedback": "The 2 in front of log a becomes an EXPONENT on the a, not a multiplier of it."}]'::jsonb,
 2, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 34, 'Advanced',
 'Use the change of base formula to evaluate log₉12, to 1 decimal place.',
 '[{"text": "3.0", "feedback": "That reads the square root of 9. Change of base divides the log of the argument by the log of the base."},
   {"text": "1.1", "feedback": "Correct."},
   {"text": "0.9", "feedback": "The fraction is upside down. It is log 12 divided by log 9, and 12 is the larger of the two."},
   {"text": "1.3", "feedback": "That divides 12 by 9 without taking any logarithms."}]'::jsonb,
 1, 'sub-log-laws'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 35, 'Advanced',
 'Solve 2^(k - 2) = 3^(k + 1), correct to 3 decimal places.',
 '[{"text": "k = -6.129", "feedback": "Correct."},
   {"text": "k = 6.129", "feedback": "Collecting the k terms gives k(log 2 - log 3), and log 2 is smaller than log 3, so that bracket is negative."},
   {"text": "k = -2.710", "feedback": "The constant side came to log 3 rather than log 12. Both the 2 log 2 and the log 3 have to move across."},
   {"text": "k = 0.090", "feedback": "That divides log 12 by 12 rather than by log(2/3)."}]'::jsonb,
 0, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 36, 'Advanced',
 'Solve 3ˣ = 4^(1 - x), correct to 2 decimal places.',
 '[{"text": "x = 1.26", "feedback": "The x log 4 term has to be brought over to the left, which ADDS it to x log 3 rather than leaving it behind."},
   {"text": "x = 0.44", "feedback": "That works out log 3 over log 12. The constant left on the right is log 4, because the 1 sits on the exponent of the 4."},
   {"text": "x = -0.56", "feedback": "The size is right but the sign is not. Both logs are positive, so the quotient is positive."},
   {"text": "x = 0.56", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 37, 'Advanced',
 'Solve log(x + 3) + log x = 1.',
 '[{"text": "x = 2", "feedback": "Correct."},
   {"text": "x = 2 and x = -5", "feedback": "The quadratic gives both, but -5 makes log x take a negative input, so it has to be thrown out."},
   {"text": "x = -5", "feedback": "-5 is the root that has to be REJECTED. A logarithm of a negative number does not exist."},
   {"text": "x = 0.30 and x = -3.30", "feedback": "The 1 on the right was carried inside as it stands. Rewrite log of the product equals 1 in exponential form first."}]'::jsonb,
 0, 'sub-log-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 38, 'Advanced',
 'Why does every solution of a logarithmic equation have to be checked?',
 '[{"text": "Because combining the logs can produce values that make a logarithm take a negative or zero input", "feedback": "Correct."},
   {"text": "Because logarithms are only approximate", "feedback": "The laws are exact. The problem is that combining two logs into one quietly widens what the equation allows."},
   {"text": "Because the base might change during the working", "feedback": "The base stays put throughout. What changes is the set of inputs the combined expression accepts."},
   {"text": "There is no need to check; every root of the quadratic works", "feedback": "The three equations in this unit each produce one root that has to be discarded, so checking is exactly what stops the wrong answer."}]'::jsonb,
 0, 'sub-log-equations'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 39, 'Advanced',
 E'The loudness of a sound in decibels is L = 10 log(I/I₀), where I is its intensity\nand I₀ is the threshold intensity. A concert reads 110 dB and a vacuum cleaner\nreads 70 dB. How many times more intense is the concert?',
 '[{"text": "40 times", "feedback": "That is the gap between the two readings, and a gap in decibels is not a ratio of intensities. The scale is logarithmic, so the gap still has to be undone."},
   {"text": "about 1.6 times", "feedback": "That divides one reading by the other. Decibel readings behave like exponents, and exponents subtract rather than divide."},
   {"text": "10⁴⁰ times", "feedback": "The 10 in front of the logarithm was skipped, so each reading was treated as a power of 10 on its own."},
   {"text": "10 000 times", "feedback": "Correct."}]'::jsonb,
 3, 'sub-log-applications'),

(12, 'MHF4U', 'Logarithmic Functions', 3, 40, 'Advanced',
 'Simplify log(x² + 2x - 15) - log(x² - 7x + 12).',
 '[{"text": "log(x² + 2x - 15) ÷ log(x² - 7x + 12)", "feedback": "Subtracting two logs is not the same as dividing them. The quotient law puts the division INSIDE a single log."},
   {"text": "log((x + 5)/(x - 4))", "feedback": "Correct."},
   {"text": "log((x - 3)/(x - 4))", "feedback": "The bracket x - 3 is the one the two share, so it cancels. What survives on top is the other factor."},
   {"text": "log((x + 5)(x - 4))", "feedback": "A DIFFERENCE of logs becomes a quotient inside, not a product."}]'::jsonb,
 1, 'sub-log-laws');
