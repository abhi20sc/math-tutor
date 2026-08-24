-- ===========================================================================
-- MHF4U — Unit 7: Rational Functions — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  Reciprocal of linear and quadratic functions
--   Lesson 2  Quotient of linear functions
--   Lesson 3  Sum, difference, product and quotient of functions
--   Lesson 4  Composite functions
--   Lesson 5  Solving rational equations and inequalities
--
-- Five lessons, six subtopics. Lesson 5 is split into EQUATIONS and
-- INEQUALITIES because they fail differently. A student who loses an
-- equation loses it to an extraneous root — a value that solves the
-- polynomial but is a restriction. A student who loses an inequality loses
-- it to the sign table, usually by including the vertical asymptote in the
-- answer. Two separate traffic lights on the dashboard tell the tutor which
-- of those two it is without opening a single paper.
--
-- This unit also carries the rational-equation and rational-inequality work
-- that appears in the Unit 6 review package. It is authored here, once, so
-- nothing is asked twice across the two units.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value, factorisation, limit, composition and solution set in this
-- file was recomputed independently with sympy before delivery; nothing was
-- copied from the source PDFs.
--
-- FIGURES: none, and this unit is the clearest case in the whole bank for
-- why. Three families were considered and all three leak:
--
--   * A drawn rational curve on a grid. The vertical asymptote is the
--     dashed line and the horizontal asymptote is the other dashed line.
--     Asking for either from a picture is asking the student to read a
--     label, not to find a zero of a denominator.
--   * A superposition sketch for sum or difference of functions. The
--     y-values of the combined curve are countable off the squares, so the
--     answer is on the page.
--   * A factor table or sign chart for an inequality. That IS the answer,
--     laid out in a grid.
--
-- Every question here is asked from the equation instead, which is what a
-- student has to be able to do once the picture is taken away.
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

delete from questions where course_code = 'MHF4U' and unit = 'Rational Functions';

insert into misconception_labels (tag, label) values
  ('sub-reciprocal-functions', 'Reciprocal of a linear or quadratic function'),
  ('sub-quotient-linear',      'Quotient of linear functions'),
  ('sub-combining-functions',  'Combining functions'),
  ('sub-composite-functions',  'Composite functions'),
  ('sub-rational-equations',   'Solving rational equations'),
  ('sub-rational-inequalities','Solving rational inequalities')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Asymptotes, intercepts, one substitution.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rational Functions', 7, 1, 'Easy',
 'What is the equation of the vertical asymptote of y = 1 / (x - 5)?',
 '[{"text": "y = 5", "feedback": "A vertical asymptote is a vertical line, so its equation starts with x, not y."},
   {"text": "x = 0", "feedback": "That is where the denominator equals -5, not 0. The asymptote sits where the denominator vanishes."},
   {"text": "x = 5", "feedback": "Correct."},
   {"text": "x = -5", "feedback": "The sign has been flipped. Set the denominator equal to zero and solve: x take away 5 equals 0."}]'::jsonb,
 2, 'sub-reciprocal-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 2, 'Easy',
 'What is the equation of the horizontal asymptote of y = 1 / (2x + 7)?',
 '[{"text": "y = 2", "feedback": "The 2 belongs to the denominator. It stretches the curve; it does not move the level it flattens out to."},
   {"text": "y = 7", "feedback": "The 7 shifts the vertical asymptote sideways. It has no effect on the height the curve settles at."},
   {"text": "y = 0", "feedback": "Correct."},
   {"text": "y = 1/2", "feedback": "That is the ratio of leading coefficients rule, which applies when the top and bottom have the SAME degree. Here the top is a constant."}]'::jsonb,
 2, 'sub-reciprocal-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 3, 'Easy',
 'What is the equation of the vertical asymptote of f(x) = (x - 3) / (x + 2)?',
 '[{"text": "x = 3", "feedback": "That is the zero of the NUMERATOR. A zero on top gives an x-intercept, not an asymptote."},
   {"text": "x = 2", "feedback": "The sign has been flipped. Solve x plus 2 equals 0."},
   {"text": "x = -3", "feedback": "Two errors at once: the numerator was used, and its sign was flipped as well."},
   {"text": "x = -2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-quotient-linear'),

(12, 'MHF4U', 'Rational Functions', 7, 4, 'Easy',
 'What is the equation of the horizontal asymptote of f(x) = (2x - 3) / (x - 1)?',
 '[{"text": "y = 0", "feedback": "That is the rule for when the bottom has a higher degree than the top. Here both are degree one."},
   {"text": "y = 2", "feedback": "Correct."},
   {"text": "y = 3", "feedback": "That is the ratio of the CONSTANT terms. The rule uses the coefficients of the highest power of x."},
   {"text": "y = 1", "feedback": "Only the bottom coefficient was used. The rule needs both, as a ratio."}]'::jsonb,
 1, 'sub-quotient-linear'),

(12, 'MHF4U', 'Rational Functions', 7, 5, 'Easy',
 E'Given f(x) = 3x + 1 and g(x) = x^2 - 4.\nWhat is (f + g)(x)?',
 '[{"text": "x^2 - 3x - 3", "feedback": "The 3x lost its sign along the way. Nothing here is being subtracted."},
   {"text": "x^2 + 3x - 3", "feedback": "Correct."},
   {"text": "x^2 + 3x + 5", "feedback": "The two constants were combined as 1 plus 4. The constant in g is negative four."},
   {"text": "x^2 + 3x - 4", "feedback": "The constant from f was dropped. Both constants have to be collected."}]'::jsonb,
 1, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 6, 'Easy',
 E'Given f(x) = 3x + 1 and g(x) = x^2 - 4.\nWhat is (f - g)(x)?',
 '[{"text": "-x^2 - 3x + 5", "feedback": "The 3x belongs to f, not g, so it is not affected by the subtraction at all."},
   {"text": "-x^2 + 3x + 5", "feedback": "Correct."},
   {"text": "-x^2 + 3x - 3", "feedback": "The subtraction was not distributed to the second term of g. Taking away negative four adds four."},
   {"text": "x^2 + 3x + 5", "feedback": "The x squared kept its sign. Subtracting g flips the sign of every term in g."}]'::jsonb,
 1, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 7, 'Easy',
 E'Given f(x) = x^2 and g(x) = x + 3.\nWhat is (f o g)(x)?',
 '[{"text": "x^2 + 6x + 9", "feedback": "Correct."},
   {"text": "x^2 + 3", "feedback": "That is g of f, not f of g. The inner function is the one substituted in."},
   {"text": "x^2 + 9", "feedback": "The bracket was expanded by squaring each term separately. A binomial squared has a middle term."},
   {"text": "x^2 + 6x + 3", "feedback": "The middle term is right but the last one is not. The 3 gets squared too."}]'::jsonb,
 0, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 8, 'Easy',
 E'Let u(x) = 2x - 1 and v(x) = x + 4.\nWhat is v(u(3))?',
 '[{"text": "7", "feedback": "That is v of 3. The inner function was skipped entirely."},
   {"text": "9", "feedback": "Correct."},
   {"text": "13", "feedback": "The functions were applied in the wrong order. The one written inside the brackets goes first."},
   {"text": "5", "feedback": "That is u of 3. The outer function still has to be applied to it."}]'::jsonb,
 1, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 9, 'Easy',
 'Solve 4 / (3x - 5) = 4.',
 '[{"text": "x = 5/3", "feedback": "That is the value that makes the denominator zero, so it is the one value x is not allowed to be."},
   {"text": "x = 2", "feedback": "Correct."},
   {"text": "x = 3", "feedback": "The denominator was set equal to 4 instead of to 1. Multiply both sides by the denominator first."},
   {"text": "x = 1/3", "feedback": "The 5 was left behind. Bring it across before dividing by 3."}]'::jsonb,
 1, 'sub-rational-equations'),

(12, 'MHF4U', 'Rational Functions', 7, 10, 'Easy',
 'At which x-values can the expression (x + 5) / (x - 1) change sign?',
 '[{"text": "x = -5 and x = 1", "feedback": "Correct."},
   {"text": "x = -5 only", "feedback": "The zero of the top was found, but the expression also flips sign as it jumps across the value that makes the bottom zero."},
   {"text": "x = 1 only", "feedback": "The bottom was found, but the expression also changes sign where the top passes through zero."},
   {"text": "x = 5 and x = -1", "feedback": "Both signs have been flipped. Set each part equal to zero and solve rather than reading the numbers off."}]'::jsonb,
 0, 'sub-rational-inequalities'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): two steps. Factor first, or combine then simplify.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rational Functions', 7, 11, 'Medium',
 'What are the vertical asymptotes of y = 1 / (x^2 - 9)?',
 '[{"text": "x = 9 and x = -9", "feedback": "The square root was never taken. Solving x squared equals 9 gives 3, not 9."},
   {"text": "x = 3 and no others", "feedback": "A square has two square roots. The negative one makes the denominator zero just as well."},
   {"text": "There are no vertical asymptotes", "feedback": "x squared take away 9 does have real zeros. Factor it as a difference of squares."},
   {"text": "x = 3 and x = -3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-reciprocal-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 12, 'Medium',
 'How many vertical asymptotes does y = 1 / (x^2 + 4) have?',
 '[{"text": "0", "feedback": "Correct."},
   {"text": "2", "feedback": "The 4 was treated as if it were negative. x squared plus 4 is never zero for a real x."},
   {"text": "1", "feedback": "A quadratic denominator gives either two asymptotes or none, never exactly one, unless it is a perfect square."},
   {"text": "4", "feedback": "The constant was counted as the number of asymptotes. The count comes from the real zeros of the denominator."}]'::jsonb,
 0, 'sub-reciprocal-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 13, 'Medium',
 'What is the x-intercept of f(x) = (3x + 6) / (x - 4)?',
 '[{"text": "x = 2", "feedback": "The sign was flipped. Solving 3x plus 6 equals 0 gives a negative value."},
   {"text": "x = -6", "feedback": "The coefficient 3 was ignored. Divide by it after moving the 6 across."},
   {"text": "x = -2", "feedback": "Correct."},
   {"text": "x = 4", "feedback": "That is the zero of the denominator, which is a vertical asymptote. A fraction is zero when its TOP is zero."}]'::jsonb,
 2, 'sub-quotient-linear'),

(12, 'MHF4U', 'Rational Functions', 7, 14, 'Medium',
 'What is the y-intercept of f(x) = (2x - 8) / (x + 4)?',
 '[{"text": "-8", "feedback": "Only the numerator was evaluated. The denominator has to be evaluated at zero as well."},
   {"text": "4", "feedback": "That is the value of the denominator at zero. The intercept is the whole fraction."},
   {"text": "-2", "feedback": "Correct."},
   {"text": "2", "feedback": "The sign was dropped. Substituting zero gives negative eight over four."}]'::jsonb,
 2, 'sub-quotient-linear'),

(12, 'MHF4U', 'Rational Functions', 7, 15, 'Medium',
 E'Given f(x) = x + 3 and g(x) = x^2 + 8x + 15.\nWrite (f / g)(x) in simplest form.',
 '[{"text": "x + 5", "feedback": "The fraction was turned upside down. The common factor cancels out of the top, leaving 1 there."},
   {"text": "1 / (x + 3)", "feedback": "The wrong factor was cancelled. Factor g fully first and see which bracket it shares with f."},
   {"text": "(x + 3) / (x + 5)", "feedback": "The shared bracket was cancelled from the bottom but left on the top."},
   {"text": "1 / (x + 5)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 16, 'Medium',
 E'Given f(x) = x + 3 and g(x) = x^2 + 8x + 15.\nExpand (f x g)(x).',
 '[{"text": "x^2 + 9x + 18", "feedback": "The functions were added rather than multiplied. The product of a linear and a quadratic is cubic."},
   {"text": "x^3 + 8x^2 + 15x", "feedback": "Only the x from f was distributed. The 3 has to multiply every term as well."},
   {"text": "x^3 + 11x^2 + 24x + 45", "feedback": "One of the x terms was missed when collecting. Two separate products land on the plain x term."},
   {"text": "x^3 + 11x^2 + 39x + 45", "feedback": "Correct."}]'::jsonb,
 3, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 17, 'Medium',
 E'Given f(x) = x^2 and g(x) = x + 3.\nWhat is (g o f)(x)?',
 '[{"text": "x^3 + 3x^2", "feedback": "The functions were multiplied instead of composed. Composition substitutes; it does not multiply."},
   {"text": "x^2 + 3", "feedback": "Correct."},
   {"text": "x^2 + 6x + 9", "feedback": "The order was reversed. Here f is the inner function, so f goes into g."},
   {"text": "x^2 + 9", "feedback": "Two errors: the order was reversed and the binomial was squared term by term."}]'::jsonb,
 1, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 18, 'Medium',
 E'Let u(x) = x^2 + 3x + 2 and w(x) = 1 / (x - 1).\nEvaluate (u o w)(2).',
 '[{"text": "6", "feedback": "Correct."},
   {"text": "1/11", "feedback": "The order was reversed. w is the inner function here, so it is evaluated at 2 first."},
   {"text": "3/4", "feedback": "The whole denominator was not kept together. w of 2 is 1 divided by the quantity 2 take away 1."},
   {"text": "12", "feedback": "That is u of 2. The inner function w was skipped."}]'::jsonb,
 0, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 19, 'Medium',
 'Solve 6 / (x - 2) = x - 1.',
 '[{"text": "x = 4 only", "feedback": "The quadratic was only half solved. Both brackets give a valid value here, and neither is a restriction."},
   {"text": "x = -1 only", "feedback": "The quadratic was only half solved. Both brackets give a valid value here, and neither is a restriction."},
   {"text": "x = 1 or x = 2", "feedback": "Each side was set to zero separately. Multiply across by the denominator and collect into one quadratic instead."},
   {"text": "x = 4 or x = -1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-equations'),

(12, 'MHF4U', 'Rational Functions', 7, 20, 'Medium',
 'Solve (x - 3) / (x + 1) < 0.',
 '[{"text": "-1 < x < 3", "feedback": "Correct."},
   {"text": "x < -1 or x > 3", "feedback": "The wrong side of the sign table was chosen. Outside the two critical values the top and bottom share a sign, so the quotient is positive."},
   {"text": "-3 < x < 1", "feedback": "Both critical values had their signs flipped. Set each bracket equal to zero and solve rather than reading the numbers off."},
   {"text": "x < 3", "feedback": "The denominator was ignored. Below negative one the quotient is positive, so that whole stretch does not belong."}]'::jsonb,
 0, 'sub-rational-inequalities'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): factor first, then reason about behaviour. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rational Functions', 7, 21, 'Challenge',
 'What are the vertical asymptotes of y = 1 / (x^2 - 2x - 15)?',
 '[{"text": "x = 15 and x = -1", "feedback": "The numbers 15 and 1 were read off the expression. Factor the quadratic properly first."},
   {"text": "There are no vertical asymptotes", "feedback": "This quadratic does factor over the integers. Look for two numbers multiplying to negative 15 and adding to negative 2."},
   {"text": "x = 5 and x = -3", "feedback": "Correct."},
   {"text": "x = -5 and x = 3", "feedback": "The signs of the roots were taken straight from the brackets. A bracket of x take away 5 is zero at positive 5."}]'::jsonb,
 2, 'sub-reciprocal-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 22, 'Challenge',
 E'The function g(x) = x^2 - 4 has a minimum point at (0, -4).\nWhat is the corresponding point on the graph of y = 1 / g(x)?',
 '[{"text": "(0, -1/4), which is still a minimum", "feedback": "The height is right but the shape is not. Taking reciprocals turns a minimum into a maximum on that branch."},
   {"text": "(0, -4), which is a local maximum", "feedback": "The x-value stays put but the y-value does not. Every y-coordinate gets replaced by its reciprocal."},
   {"text": "(0, 1/4), which is a local maximum", "feedback": "The sign was lost. The reciprocal of a negative number is still negative."},
   {"text": "(0, -1/4), which is a local maximum", "feedback": "Correct."}]'::jsonb,
 3, 'sub-reciprocal-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 23, 'Challenge',
 'The two branches of f(x) = (x - 3) / (x + 2) are equidistant from the point where its asymptotes cross. What are the coordinates of that point?',
 '[{"text": "(-2, 1)", "feedback": "Correct."},
   {"text": "(2, -1)", "feedback": "Both signs were flipped. The vertical asymptote comes from solving x plus 2 equals zero."},
   {"text": "(-2, -3)", "feedback": "The vertical asymptote is right. The second coordinate has to come from the horizontal asymptote, which is set by the leading coefficients, not by the constant on top."},
   {"text": "(3, -2)", "feedback": "The two coordinates have been swapped and the numerator was used for the vertical asymptote."}]'::jsonb,
 0, 'sub-quotient-linear'),

(12, 'MHF4U', 'Rational Functions', 7, 24, 'Challenge',
 'What happens to the graph of f(x) = (x^2 - 9) / (x - 3) at x = 3?',
 '[{"text": "There is a hole at (3, 6)", "feedback": "Correct."},
   {"text": "There is a vertical asymptote at x = 3", "feedback": "An asymptote needs the bottom to be zero while the top is NOT. Here the top is zero at 3 as well, so the factor cancels."},
   {"text": "There is a hole at (3, 0)", "feedback": "The position is right but the height is not. Cancel the common factor first, then substitute 3 into what is left."},
   {"text": "There is a hole at (3, 3)", "feedback": "The height was taken as the x-value. Substitute 3 into the simplified expression to find it."}]'::jsonb,
 0, 'sub-quotient-linear'),

(12, 'MHF4U', 'Rational Functions', 7, 25, 'Challenge',
 E'Let f(x) = sqrt(x - 2) and g(x) = 1 / (x - 5).\nWhat is the domain of (f + g)(x)?',
 '[{"text": "x not equal to 5", "feedback": "Only the fraction was considered. A square root cannot take a negative input, which rules out a whole stretch of the line."},
   {"text": "x > 2, x not equal to 5", "feedback": "The endpoint was excluded without cause. A square root of zero is perfectly well defined."},
   {"text": "x >= 2, x not equal to 5", "feedback": "Correct."},
   {"text": "x >= 2", "feedback": "Only the root was considered. The domain of a sum is the OVERLAP of both domains, and g has a restriction too."}]'::jsonb,
 2, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 26, 'Challenge',
 E'Let f(x) = 2^x and g(x) = x^2.\nEvaluate (f x g)(3).',
 '[{"text": "64", "feedback": "The functions were composed the other way round. Multiplication evaluates each at 3 first, then multiplies."},
   {"text": "36", "feedback": "The bases were multiplied and then squared. Each function must be evaluated separately before the two results meet."},
   {"text": "72", "feedback": "Correct."},
   {"text": "512", "feedback": "The functions were composed rather than multiplied. That is f of g of 3, not f times g at 3."}]'::jsonb,
 2, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 27, 'Challenge',
 E'Let f(x) = sqrt(x) and g(x) = x - 7.\nWhat is the domain of (f o g)(x)?',
 '[{"text": "x >= 0", "feedback": "That is the domain of f on its own. The inner function has to land inside that domain, which shifts the boundary."},
   {"text": "x >= -7", "feedback": "The shift went the wrong way. Set x take away 7 greater than or equal to zero and solve."},
   {"text": "All real numbers", "feedback": "The square root still cannot take a negative input after the substitution."},
   {"text": "x >= 7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 28, 'Challenge',
 E'The rabbits in a reserve are modelled by R(t) = 50cos(t) + 100, with t in years.\nThe wolves are modelled by W(t) = 0.2[R(t - 2)].\nFind the full equation for W(t).',
 '[{"text": "W(t) = 10cos(t) - 2 + 20", "feedback": "The 2 was subtracted after the function was applied. Inside the square brackets it replaces the input of R."},
   {"text": "W(t) = 50cos(t - 2) + 20", "feedback": "The 0.2 was applied to the constant only. It multiplies every term of R, amplitude included."},
   {"text": "W(t) = 10cos(t - 2) + 100", "feedback": "The 0.2 was applied to the amplitude only. It multiplies the vertical shift as well."},
   {"text": "W(t) = 10cos(t - 2) + 20", "feedback": "Correct."}]'::jsonb,
 3, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 29, 'Challenge',
 'Solve 1/x + 1/(x + 3) = 1/2.',
 '[{"text": "x = 3 and no others", "feedback": "Only one bracket was used. Neither root here is a restriction, so both survive."},
   {"text": "x = -3 or x = 2", "feedback": "Both signs were flipped when reading the roots out of the factored quadratic."},
   {"text": "x = 1 or x = -4", "feedback": "The two fractions were added by putting the sum of the numerators over the product of the denominators."},
   {"text": "x = 3 or x = -2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-equations'),

(12, 'MHF4U', 'Rational Functions', 7, 30, 'Challenge',
 'Solve (x + 4) / (x - 1) >= 0.',
 '[{"text": "x <= -4 or x > 1", "feedback": "Correct."},
   {"text": "x <= -4 or x >= 1", "feedback": "The endpoint at the vertical asymptote was included. The expression is undefined there, so it can never be part of a solution set."},
   {"text": "-4 <= x < 1", "feedback": "The wrong side of the sign table was chosen. Between the two critical values the top and bottom have opposite signs."},
   {"text": "x < -4 or x > 1", "feedback": "The endpoint at the zero of the numerator was excluded. The sign here is greater than OR EQUAL to zero, and the fraction does reach zero there."}]'::jsonb,
 0, 'sub-rational-inequalities'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): build a function from features, or watch for a root
-- that the restrictions throw away. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rational Functions', 7, 31, 'Advanced',
 'What is the range of y = 2 / (x^2 - 6x + 9)?',
 '[{"text": "y > 2", "feedback": "The 2 on top was read as a floor. The denominator can be large, which drives the whole fraction down towards zero."},
   {"text": "y > 0", "feedback": "Correct."},
   {"text": "y >= 0", "feedback": "Zero was included. A fraction with a non-zero top can get as close to zero as you like but never reaches it."},
   {"text": "y not equal to 0", "feedback": "That would allow negative outputs. Factor the denominator and notice it is a perfect square, so it is never negative."}]'::jsonb,
 1, 'sub-reciprocal-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 32, 'Advanced',
 'Which function has a vertical asymptote at x = 4, a horizontal asymptote at y = 3, and an x-intercept at 2?',
 '[{"text": "f(x) = 3(x - 2) / (x - 4)", "feedback": "Correct."},
   {"text": "f(x) = (3x - 2) / (x - 4)", "feedback": "The first two features are right but the third is not. Check where this numerator equals zero."},
   {"text": "f(x) = 3(x - 4) / (x - 2)", "feedback": "The two brackets have been swapped, so the asymptote and the intercept have traded places."},
   {"text": "f(x) = (x - 2) / (3x - 4)", "feedback": "The 3 was placed on the bottom, which changes both the horizontal asymptote and the vertical one."}]'::jsonb,
 0, 'sub-quotient-linear'),

(12, 'MHF4U', 'Rational Functions', 7, 33, 'Advanced',
 E'Let f(x) = x^2 - 1 and g(x) = x + 1.\nDescribe the graph of (f / g)(x).',
 '[{"text": "The line y = x + 1 with a hole at (-1, 0)", "feedback": "The wrong factor was cancelled. Factor the top as a difference of squares and see which bracket matches the bottom."},
   {"text": "The line y = x - 1 with a hole at (-1, -2)", "feedback": "Correct."},
   {"text": "The line y = x - 1 with no hole", "feedback": "The simplification is right but the restriction was forgotten. Cancelling a factor removes a point from the graph; it does not fill it in."},
   {"text": "The line y = x - 1 with a vertical asymptote at x = -1", "feedback": "The factor cancelled, so the bottom is not the only place that vanishes there. A shared factor gives a hole, not an asymptote."}]'::jsonb,
 1, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 34, 'Advanced',
 E'Let f(x) = sqrt(x + 3) and g(x) = sqrt(5 - x).\nWhat is the domain of (f x g)(x)?',
 '[{"text": "-5 <= x <= 3", "feedback": "The two numbers were read straight off the expressions. Set each radicand greater than or equal to zero and solve."},
   {"text": "-3 <= x <= 5", "feedback": "Correct."},
   {"text": "x >= -3", "feedback": "Only f was considered. The domain of a product is the overlap of both, and g fails once x passes 5."},
   {"text": "x <= 5", "feedback": "Only g was considered. The domain of a product is the overlap of both, and f fails below negative 3."}]'::jsonb,
 1, 'sub-combining-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 35, 'Advanced',
 E'Let f(x) = 1 / (x - 2) and g(x) = 3 / x.\nSimplify (f o g)(x).',
 '[{"text": "3 / (x - 2)", "feedback": "Only the 3 from g was carried across onto the top of f. The x in the denominator of f was never replaced."},
   {"text": "1 / (3x - 2)", "feedback": "The x was moved into the wrong place. Substitute 3 over x for x, then clear the fraction inside the fraction."},
   {"text": "x / (3 - 2x)", "feedback": "Correct."},
   {"text": "(3 - 2x) / x", "feedback": "The complex fraction was left upside down. After combining the bottom over a common denominator, the whole thing flips."}]'::jsonb,
 2, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 36, 'Advanced',
 E'Let f(x) = 2x + 5 and suppose (f o g)(x) = 6x - 1.\nFind g(x).',
 '[{"text": "g(x) = 3x + 2", "feedback": "The 5 was added instead of subtracted when it was moved across. It is already on the left, so it comes off."},
   {"text": "g(x) = 6x - 6", "feedback": "The 5 was handled correctly but the division by 2 was never carried out."},
   {"text": "g(x) = 12x + 3", "feedback": "f was applied to 6x take away 1. That gives f of the composite, not the inner function."},
   {"text": "g(x) = 3x - 3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-composite-functions'),

(12, 'MHF4U', 'Rational Functions', 7, 37, 'Advanced',
 'Solve 1/(x - 2) + 1/(x + 2) = 4/(x^2 - 4).',
 '[{"text": "x = 2 or x = -2", "feedback": "Both of these make a denominator zero. Neither can be substituted back into the original equation."},
   {"text": "x = 4", "feedback": "The 4 from the right-hand side was carried through as if it were the answer. Clear the denominators and collect first."},
   {"text": "There is no solution", "feedback": "Correct."},
   {"text": "x = 2", "feedback": "The algebra is right but the restrictions were never checked. This value makes a denominator zero, so it has to be thrown out."}]'::jsonb,
 2, 'sub-rational-equations'),

(12, 'MHF4U', 'Rational Functions', 7, 38, 'Advanced',
 'Solve x/(x - 3) + 3/(x + 3) = 18/(x^2 - 9).',
 '[{"text": "x = 3", "feedback": "The root that had to be rejected was kept and the other one was dropped. Check each root against the restrictions."},
   {"text": "x = 9", "feedback": "The sign was flipped when reading the root out of the factored form. A bracket of x plus 9 is zero at negative 9."},
   {"text": "x = -9", "feedback": "Correct."},
   {"text": "x = -9 or x = 3", "feedback": "Both roots of the quadratic were kept. One of them makes a denominator zero, so it has to be rejected."}]'::jsonb,
 2, 'sub-rational-equations'),

(12, 'MHF4U', 'Rational Functions', 7, 39, 'Advanced',
 'Solve x - 2 < 8/x.',
 '[{"text": "x < -2 or 0 < x < 4", "feedback": "Correct."},
   {"text": "-2 < x < 4", "feedback": "Both sides were multiplied by x as if x were always positive. When x is negative the inequality sign turns round, which splits the answer."},
   {"text": "x < -2 or x > 4", "feedback": "The critical value at zero was missed. The expression is undefined there and changes sign across it."},
   {"text": "0 < x < 4", "feedback": "Only half the sign table was read. There is a second stretch where the quotient is negative, to the left of the smaller critical value."}]'::jsonb,
 0, 'sub-rational-inequalities'),

(12, 'MHF4U', 'Rational Functions', 7, 40, 'Advanced',
 'Solve (x^2 + 6x + 5) / (2x^2 - 7x + 3) < 0.',
 '[{"text": "-1 < x < 1/2", "feedback": "Only the middle strip was tested. Factor both quadratics to get all four critical values, then check every strip they create."},
   {"text": "-5 < x < -1 or 1/2 < x < 3", "feedback": "Correct."},
   {"text": "-5 <= x <= -1 or 1/2 <= x <= 3", "feedback": "The endpoints were included. The inequality is strict, and two of those four values make the bottom zero, so they could not be included even if it were not."},
   {"text": "x < -5 or -1 < x < 1/2 or x > 3", "feedback": "The wrong intervals were taken. Test one point inside each strip and keep only the strips where the quotient comes out negative."}]'::jsonb,
 1, 'sub-rational-inequalities');
