-- ===========================================================================
-- ASTRO MATH ASSIST — Grade 12 — MCV4U, Calculus and Vectors
-- ===========================================================================
--
-- 240 questions, 12 figures.
--
-- One course, safe to run on its own, in any order relative to the other
-- courses. Run it AFTER astro_math_assist_setup.sql has created the schema.
--
-- This is the per-unit files concatenated, with the figure file last, which is required:
-- every unit file opens with a delete for its own unit, and that delete takes
-- the figure reference with the row, so a figure file that ran first would
-- leave the course imageless.
--
-- Student attempts key on course, unit and sort_order rather than on question
-- ids, so re-running this keeps the history of every student.
-- ===========================================================================


-- --- questions_mcv4u_u1.sql ---

-- ===========================================================================
-- MCV4U — Unit 1: Derivative Rules — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Derivatives of polynomial functions
--   Lesson 2  Product rule
--   Lesson 3  Displacement, velocity and acceleration
--   Lesson 4  Quotient rule
--   Lesson 5  Chain rule
--   Lesson 6  Applications of rates of change
--
-- Six lessons, six subtopics, one for each. That is unusual for this bank
-- and it is the right call here: a student who cannot do the quotient rule
-- and a student who cannot do the chain rule look identical on a test score
-- and need completely different lessons. Six separate traffic lights on the
-- dashboard say which rule broke.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. The two that repeat across every rule in this unit are worth
-- naming here because the dashboard will show them constantly:
--
--   * multiplying the derivatives instead of applying the product rule
--   * forgetting the inner derivative in a chain rule
--
-- Feedback names the mistake and stops there.
--
-- Every derivative, root, tangent line and evaluated rate in this file was
-- recomputed independently with sympy before delivery; nothing was copied
-- from the source PDFs.
--
-- FIGURES: one, on question 29, and it is the only question in the unit
-- where a picture is the question rather than a decoration.
--
--   * Q29 shows a position-time curve with NO vertical scale and no grid,
--     and asks on which interval the particle is speeding up. That answer
--     is the sign of the slope multiplied by the sign of the concavity, and
--     both live in the shape. Nothing on the figure can be counted into a
--     number, so it cannot leak.
--
-- Rejected: any curve with a tangent line drawn on it. A drawn tangent on a
-- grid lets a student count rise over run and skip the differentiation
-- entirely, which is the whole skill the unit is teaching. Every tangent
-- question here is asked from the equation.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file must come last, and must be re-run after any re-run of
-- this one: the delete at the top wipes the figure column with the rest of
-- the row. Student attempts (keyed on course, unit and sort_order) survive
-- the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCV4U' and unit = 'Derivative Rules';

insert into misconception_labels (tag, label) values
  ('sub-power-rule',       'Power, constant and sum rules'),
  ('sub-product-rule',     'The product rule'),
  ('sub-quotient-rule',    'The quotient rule'),
  ('sub-chain-rule',       'The chain rule'),
  ('sub-motion',           'Displacement, velocity and acceleration'),
  ('sub-roc-applications', 'Applications of rates of change')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one rule, one application. Recognition and vocabulary.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivative Rules', 1, 1, 'Easy',
 'What is the derivative of f(x) = 3x^5?',
 '[{"text": "3x^4", "feedback": "The exponent was reduced but the old exponent was never brought down as a multiplier."},
   {"text": "15x^6", "feedback": "The exponent went up instead of down. Differentiating lowers a power; it is integrating that raises one."},
   {"text": "15x^4", "feedback": "Correct."},
   {"text": "15x^5", "feedback": "The coefficient was multiplied correctly but the exponent was never reduced. The power rule drops it by one."}]'::jsonb,
 2, 'sub-power-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 2, 'Easy',
 'What is the derivative of f(x) = 71?',
 '[{"text": "71", "feedback": "The function was copied out again. A constant function has a flat graph, so its slope is the same everywhere."},
   {"text": "71x", "feedback": "That is what you get by integrating, not differentiating."},
   {"text": "1", "feedback": "The slope of y = x is 1. A horizontal line is not the same thing."},
   {"text": "0", "feedback": "Correct."}]'::jsonb,
 3, 'sub-power-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 3, 'Easy',
 'If h(x) = f(x)g(x), which expression gives h prime of x?',
 '[{"text": "the derivative of f times the derivative of g", "feedback": "The derivative of a product is not the product of the derivatives. Test the idea on x times x: it would give 1, when differentiating x squared gives 2x."},
   {"text": "f prime g - f g prime", "feedback": "That is the top of the QUOTIENT rule. A product does not subtract."},
   {"text": "(f prime g - f g prime) divided by g squared", "feedback": "That is the whole quotient rule. It is being used on a product."},
   {"text": "f prime g + f g prime", "feedback": "Correct."}]'::jsonb,
 3, 'sub-product-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 4, 'Easy',
 'If h(x) = f(x) divided by g(x), which expression gives h prime of x?',
 '[{"text": "(f prime g - f g prime) divided by g squared", "feedback": "Correct."},
   {"text": "(f g prime - f prime g) divided by g squared", "feedback": "The two terms on top are the right way round in the wrong order, which flips the sign of every answer you get."},
   {"text": "the derivative of f divided by the derivative of g", "feedback": "The derivative of a quotient is not the quotient of the derivatives. Test it on x squared over x."},
   {"text": "(f prime g + f g prime) divided by g squared", "feedback": "The top of the PRODUCT rule was used over a squared denominator. A quotient subtracts."}]'::jsonb,
 0, 'sub-quotient-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 5, 'Easy',
 'What is the derivative of y = (2x + 1)^4?',
 '[{"text": "8(2x + 1)^3", "feedback": "Correct."},
   {"text": "4(2x + 1)^3", "feedback": "The inner derivative was forgotten. After the power rule, multiply by the derivative of what is inside the bracket."},
   {"text": "8(2x + 1)^4", "feedback": "The inner derivative was applied but the exponent was never reduced."},
   {"text": "4(2)^3", "feedback": "The bracket was replaced by its derivative instead of being kept. The bracket itself stays put."}]'::jsonb,
 0, 'sub-chain-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 6, 'Easy',
 'What is the derivative of y = (x^2 + 3)^5?',
 '[{"text": "10x(x^2 + 3)^4", "feedback": "Correct."},
   {"text": "5(x^2 + 3)^4", "feedback": "The inner derivative was forgotten. The bracket contains an x squared, so differentiating it gives 2x, not 1."},
   {"text": "10x(x^2 + 3)^5", "feedback": "The inner derivative is there but the exponent was never reduced."},
   {"text": "5(2x)^4", "feedback": "The bracket was replaced by its derivative. The original bracket stays and the inner derivative multiplies on the outside."}]'::jsonb,
 0, 'sub-chain-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 7, 'Easy',
 'If s(t) gives the displacement of an object, which expression gives its acceleration?',
 '[{"text": "s double prime of t", "feedback": "Correct."},
   {"text": "the derivative s prime of t", "feedback": "That is the velocity. Acceleration is the rate of change OF the velocity, so it is one derivative further along."},
   {"text": "s of t divided by t squared", "feedback": "The units happen to work out but the mathematics does not. Acceleration is a derivative, not a division."},
   {"text": "the function s of t itself", "feedback": "That is the displacement itself. Two derivatives separate it from acceleration."}]'::jsonb,
 0, 'sub-motion'),

(12, 'MCV4U', 'Derivative Rules', 1, 8, 'Easy',
 E'A hammer falls from a height of 90 m, with s(t) = 90 - 4.9t^2 metres.\nWhat is its velocity function?',
 '[{"text": "v(t) = 9.8t", "feedback": "The negative sign was lost. The hammer is falling towards the ground, so its displacement is decreasing."},
   {"text": "v(t) = -4.9t", "feedback": "The exponent was reduced but the old exponent was never brought down as a multiplier."},
   {"text": "v(t) = 90 - 9.8t", "feedback": "The constant was carried through. The derivative of a constant is zero, so the 90 disappears."},
   {"text": "v(t) = -9.8t", "feedback": "Correct."}]'::jsonb,
 3, 'sub-motion'),

(12, 'MCV4U', 'Derivative Rules', 1, 9, 'Easy',
 'Economists give a special name to the derivative of the cost function C(x). What is it?',
 '[{"text": "The fixed cost", "feedback": "That is the constant term in C of x, the part that does not change with the number of units."},
   {"text": "Marginal cost", "feedback": "Correct."},
   {"text": "The total cost", "feedback": "That is C of x itself, before any differentiating."},
   {"text": "The average cost", "feedback": "That is the total cost divided by the number of units, which is a ratio rather than a derivative."}]'::jsonb,
 1, 'sub-roc-applications'),

(12, 'MCV4U', 'Derivative Rules', 1, 10, 'Easy',
 'What is the slope of the tangent to f(x) = x^2 at x = 3?',
 '[{"text": "6", "feedback": "Correct."},
   {"text": "9", "feedback": "That is f of 3, the height of the curve. The slope comes from the DERIVATIVE evaluated at 3."},
   {"text": "3", "feedback": "That is the x-value itself. It has to be substituted into the derivative first."},
   {"text": "2", "feedback": "That is the exponent brought down on its own. The x that comes with it still has to be evaluated."}]'::jsonb,
 0, 'sub-roc-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): several terms, or one rule applied properly end to end.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivative Rules', 1, 11, 'Medium',
 'Differentiate y = 5x^6 - 4x^3 + 6.',
 '[{"text": "5x^5 - 4x^2", "feedback": "The exponents were reduced but never brought down as multipliers."},
   {"text": "30x^5 - 12x^2", "feedback": "Correct."},
   {"text": "30x^5 - 12x^2 + 6", "feedback": "The constant was carried through untouched. A constant has zero slope, so it drops out."},
   {"text": "30x^5 - 12x^2 + 1", "feedback": "The constant was differentiated as if it were 6x. There is no x on it, so it goes to zero."}]'::jsonb,
 1, 'sub-power-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 12, 'Medium',
 'Differentiate f(x) = -3x^5 + 8sqrt(x) - 9.3.',
 '[{"text": "-15x^4 + 4/sqrt(x) - 9.3", "feedback": "The constant was carried through untouched. A constant has zero slope, so it drops out."},
   {"text": "-15x^4 + 4sqrt(x)", "feedback": "The exponent one half was reduced to negative one half, but the result was written as if it were still positive."},
   {"text": "-15x^4 + 4/sqrt(x)", "feedback": "Correct."},
   {"text": "-15x^4 + 8/sqrt(x)", "feedback": "The root was rewritten as a power of one half, but that one half was never used as a multiplier."}]'::jsonb,
 2, 'sub-power-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 13, 'Medium',
 'Use the product rule to differentiate g(x) = (2x - 3)(x + 1).',
 '[{"text": "2", "feedback": "The two derivatives were multiplied. That is not the product rule, and you can see it fails by expanding first and differentiating."},
   {"text": "4x + 1", "feedback": "A sign was lost while collecting. The negative 3 multiplies the derivative of the second bracket."},
   {"text": "2x^2 - x - 3", "feedback": "That is the expanded ORIGINAL function. It still has to be differentiated."},
   {"text": "4x - 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-product-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 14, 'Medium',
 'Use the product rule to differentiate h(x) = x^2(3x + 5).',
 '[{"text": "3x^2 + 10x", "feedback": "The second term is right but the first lost its coefficient when 2x met 3x."},
   {"text": "9x^2 + 10x", "feedback": "Correct."},
   {"text": "6x", "feedback": "The two derivatives were multiplied. The product rule needs two terms, each keeping one factor undifferentiated."},
   {"text": "6x^2 + 10x", "feedback": "Only the first term of the rule was written out. The x squared also has to multiply the derivative of the bracket."}]'::jsonb,
 1, 'sub-product-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 15, 'Medium',
 'Differentiate y = (x + 1)/(x - 1).',
 '[{"text": "-2/(x - 1)^2", "feedback": "Correct."},
   {"text": "2/(x - 1)^2", "feedback": "The two terms on top of the quotient rule were subtracted in the wrong order, which flips the sign."},
   {"text": "1", "feedback": "The derivatives of top and bottom were divided. Test that idea on x squared over x and it falls apart."},
   {"text": "-2/(x - 1)", "feedback": "The denominator was never squared. The quotient rule puts g squared underneath."}]'::jsonb,
 0, 'sub-quotient-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 16, 'Medium',
 'Differentiate y = x^2/(x + 3).',
 '[{"text": "(x^2 + 6x)/(x + 3)", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "(-x^2 - 6x)/(x + 3)^2", "feedback": "The two terms on top were subtracted in the wrong order, so both terms came out negative."},
   {"text": "2x", "feedback": "The derivatives of top and bottom were divided. The quotient rule has four pieces, not two."},
   {"text": "(x^2 + 6x)/(x + 3)^2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-quotient-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 17, 'Medium',
 'Differentiate y = sqrt(3x + 1).',
 '[{"text": "3/sqrt(3x + 1)", "feedback": "The inner derivative is there but the one half from the power rule was dropped."},
   {"text": "3/(2sqrt(3x))", "feedback": "The plus 1 was dropped from inside the root. The bracket stays intact under the radical."},
   {"text": "3/(2sqrt(3x + 1))", "feedback": "Correct."},
   {"text": "1/(2sqrt(3x + 1))", "feedback": "The inner derivative was forgotten. Differentiating 3x plus 1 gives 3, not 1."}]'::jsonb,
 2, 'sub-chain-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 18, 'Medium',
 'Differentiate y = (x^3 - 2x)^6.',
 '[{"text": "(3x^2 - 2)^6", "feedback": "Only the inside was differentiated. The outer power rule was never applied at all."},
   {"text": "6(x^3 - 2x)^5(3x^2 - 2)", "feedback": "Correct."},
   {"text": "6(x^3 - 2x)^5", "feedback": "The inner derivative was forgotten. The chain rule multiplies by the derivative of what is inside."},
   {"text": "6(3x^2 - 2)^5", "feedback": "The bracket was replaced by its derivative. The original bracket stays and the inner derivative multiplies on the outside."}]'::jsonb,
 1, 'sub-chain-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 19, 'Medium',
 E'A particle moves with s(t) = t^3 - 6t^2 + 9t.\nAt which times is the particle at rest?',
 '[{"text": "t = 2", "feedback": "That is where the ACCELERATION is zero. At rest means the velocity is zero."},
   {"text": "t = 1 and t = 3", "feedback": "Correct."},
   {"text": "t = 0 and t = 3", "feedback": "The POSITION was set to zero instead of the velocity. Those are the times the particle is back at the origin, not the times it stops."},
   {"text": "t = 1 only", "feedback": "The quadratic was only half solved. It factors into two brackets and both give a time."}]'::jsonb,
 1, 'sub-motion'),

(12, 'MCV4U', 'Derivative Rules', 1, 20, 'Medium',
 'Find the equation of the tangent to f(x) = 4x^3 + 3x^2 - 5 at x = -1.',
 '[{"text": "y = -6x", "feedback": "The slope came out with the wrong sign. The derivative at negative 1 is 12 take away 6."},
   {"text": "y = 6x", "feedback": "Correct."},
   {"text": "y = 6x - 6", "feedback": "The slope is right but the point was mishandled. Substitute the point into y equals mx plus b and solve for b rather than using the y-value as the intercept."},
   {"text": "y = 6x + 12", "feedback": "A sign slipped when the point was substituted. The y-value at x equals negative 1 is negative, not positive."}]'::jsonb,
 1, 'sub-roc-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): simplify before differentiating, or combine two rules.
-- Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivative Rules', 1, 21, 'Challenge',
 'Differentiate h(x) = (-8x^6 + 8x^2)/(4x^5) by simplifying first.',
 '[{"text": "-2 - 2/x^4", "feedback": "The exponent was reduced but the negative 3 was never brought down as a multiplier."},
   {"text": "-2 - 6/x^4", "feedback": "Correct."},
   {"text": "-2 + 6/x^4", "feedback": "The second term of the simplified function is 2 times x to the negative 3. Differentiating that brings down a negative 3, so the sign turns over."},
   {"text": "-2 - 6x^4", "feedback": "The negative exponent was moved to the top instead of the bottom. A negative power means a reciprocal."}]'::jsonb,
 1, 'sub-power-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 22, 'Challenge',
 'At which points on the graph of y = x^2(x + 3) is the slope of the tangent equal to 24?',
 '[{"text": "(2, 20) only", "feedback": "The quadratic was only half solved. Setting the derivative equal to 24 gives two x-values, and both are on the curve."},
   {"text": "(4, 112) and (-2, 4)", "feedback": "Both x-values had their signs flipped when the factored quadratic was read out."},
   {"text": "(-4, 0) and (2, 0)", "feedback": "The x-values are right but the heights were never found. Substitute each one back into the ORIGINAL function."},
   {"text": "(-4, -16) and (2, 20)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-applications'),

(12, 'MCV4U', 'Derivative Rules', 1, 23, 'Challenge',
 'Differentiate y = (x^2 + 1)(x^3 - 2x) and simplify.',
 '[{"text": "5x^4 - 3x^2 - 2", "feedback": "Correct."},
   {"text": "6x^3 - 4x", "feedback": "The two derivatives were multiplied. The product rule keeps one factor whole in each of its two terms."},
   {"text": "5x^4 - 3x^2 + 2", "feedback": "The constant term came out with the wrong sign. The 1 in the first bracket multiplies the negative 2 in the second derivative."},
   {"text": "2x^4 - 4x^2", "feedback": "Only the first term of the product rule was written out. The second term is missing entirely."}]'::jsonb,
 0, 'sub-product-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 24, 'Challenge',
 E'Let y = (3x - 1)(2x + 5).\nEvaluate the derivative at x = 2.',
 '[{"text": "37", "feedback": "Correct."},
   {"text": "27", "feedback": "Only the first term of the product rule was evaluated. The second term contributes as well."},
   {"text": "10", "feedback": "Only the second term of the product rule was evaluated. The first term contributes as well."},
   {"text": "6", "feedback": "The two derivatives were multiplied. That gives a constant, which cannot be right for a quadratic."}]'::jsonb,
 0, 'sub-product-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 25, 'Challenge',
 'Differentiate y = (2x - 3)/(x^2 + 1).',
 '[{"text": "(-2x^2 + 6x + 2)/(x^2 + 1)^2", "feedback": "Correct."},
   {"text": "(2x^2 - 6x - 2)/(x^2 + 1)^2", "feedback": "The two terms on top were subtracted in the wrong order, which flips every sign in the numerator."},
   {"text": "(-2x^2 + 6x + 2)/(x^2 + 1)", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "2/(2x)", "feedback": "The derivatives of top and bottom were divided. The quotient rule has four pieces, not two."}]'::jsonb,
 0, 'sub-quotient-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 26, 'Challenge',
 E'The value of a car t years after purchase is V(t) = (50000 + 6t)/(1 + 0.4t) dollars.\nWhat is the rate of change of its value at t = 2, to the nearest dollar per year?',
 '[{"text": "-6171 dollars per year", "feedback": "Correct."},
   {"text": "-11108 dollars per year", "feedback": "The denominator was never squared. The quotient rule puts the whole bottom, squared, underneath."},
   {"text": "6171 dollars per year", "feedback": "The two terms on top were subtracted in the wrong order. A car losing value has a negative rate."},
   {"text": "15 dollars per year", "feedback": "The top and the bottom were differentiated separately and then divided. That is not the quotient rule."}]'::jsonb,
 0, 'sub-quotient-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 27, 'Challenge',
 E'Let y = (x^2 + 3x)^3.\nEvaluate the derivative at x = 1.',
 '[{"text": "48", "feedback": "The inner derivative was forgotten. After the outer power rule, multiply by the derivative of what is inside."},
   {"text": "64", "feedback": "That is the value of the FUNCTION at x equals 1, not of its derivative."},
   {"text": "5", "feedback": "Only the inner derivative was evaluated. The outer power rule contributes the rest."},
   {"text": "240", "feedback": "Correct."}]'::jsonb,
 3, 'sub-chain-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 28, 'Challenge',
 'Differentiate y = 1/(2x - 5)^3.',
 '[{"text": "6/(2x - 5)^4", "feedback": "The sign was lost. The negative 3 comes down as a multiplier and stays negative."},
   {"text": "-6/(2x - 5)^4", "feedback": "Correct."},
   {"text": "-3/(2x - 5)^4", "feedback": "The inner derivative was forgotten. Differentiating 2x take away 5 gives 2."},
   {"text": "-6/(2x - 5)^2", "feedback": "Rewriting as a power of negative 3 and reducing gives negative 4, so the bracket on the bottom ends up to the fourth."}]'::jsonb,
 1, 'sub-chain-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 29, 'Challenge',
 E'The graph shows the position s(t) of a particle moving in a straight line.\nOn which of these intervals is the particle SPEEDING UP?',
 '[{"text": "4 < t < 6", "feedback": "The curve is falling here and bending upwards, so the slope and the bending have opposite signs."},
   {"text": "0 < t < 4", "feedback": "This stretch spans the turning point at the top, where the slope changes sign. The motion cannot be one thing across the whole of it."},
   {"text": "2 < t < 4", "feedback": "Correct."},
   {"text": "0 < t < 2", "feedback": "The curve is rising here, but check which way it is bending. When the slope is positive and the bending is downwards, the two signs disagree."}]'::jsonb,
 2, 'sub-motion'),

(12, 'MCV4U', 'Derivative Rules', 1, 30, 'Challenge',
 E'A shop sells 1500 DVDs a month at 10 dollars each. Sales fall by 125 a month for each 0.25 dollar rise in price, giving the demand function p(x) = 13 - 0.002x.\nWhat is the marginal revenue when sales are 1000 DVDs a month?',
 '[{"text": "11 dollars", "feedback": "That is the total revenue at 1000 divided by 1000, which is the average revenue per DVD, not the marginal one."},
   {"text": "13 dollars", "feedback": "Only the constant term of the demand function survived. Revenue is x times p of x, so differentiating leaves an x term behind."},
   {"text": "10 dollars", "feedback": "That is the current selling price. Marginal revenue is the derivative of the revenue function, not the price."},
   {"text": "9 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): two rules at once, or a rate that has to be interpreted
-- as well as computed. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivative Rules', 1, 31, 'Advanced',
 'For f(x) = (1/3)x^3 - x^2 - 3x + 4, at which value of x is the second derivative equal to zero?',
 '[{"text": "x = 0", "feedback": "Differentiating twice leaves 2x take away 2, and that is not zero at the origin."},
   {"text": "x = -1", "feedback": "A sign was flipped when the linear equation was solved. Setting 2x take away 2 to zero gives a positive value."},
   {"text": "x = 1", "feedback": "Correct."},
   {"text": "x = -1 and x = 3", "feedback": "Those are the values where the FIRST derivative is zero. The question asks about the second."}]'::jsonb,
 2, 'sub-power-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 32, 'Advanced',
 'Differentiate y = (x + 1)^2(x - 3)^3 and write the result in factored form.',
 '[{"text": "(x + 1)(x - 3)^2(5x + 3)", "feedback": "A sign slipped inside the last bracket. The constants coming out of the two product-rule terms were combined incorrectly."},
   {"text": "2(x + 1)(x - 3)^3", "feedback": "Only the first term of the product rule was written out. The second term contributes the rest."},
   {"text": "(x + 1)(x - 3)^2(5x - 3)", "feedback": "Correct."},
   {"text": "6(x + 1)(x - 3)^2", "feedback": "The two derivatives were multiplied. This is a product, so both terms of the product rule are needed."}]'::jsonb,
 2, 'sub-product-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 33, 'Advanced',
 'Differentiate y = x/sqrt(x^2 + 1).',
 '[{"text": "-1/(x^2 + 1)^(3/2)", "feedback": "The two terms on top were subtracted in the wrong order, which flips the sign."},
   {"text": "1/(x^2 + 1)", "feedback": "The denominator was squared but the root inside it was dropped. Squaring the square root of a quantity leaves the quantity itself, not the quantity to the three halves."},
   {"text": "1/(x^2 + 1)^(3/2)", "feedback": "Correct."},
   {"text": "1/sqrt(x^2 + 1)", "feedback": "Only the first term of the quotient rule was kept. The second term is not zero, because the bottom depends on x."}]'::jsonb,
 2, 'sub-quotient-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 34, 'Advanced',
 'Differentiate y = ((2x + 1)/(x - 1))^3.',
 '[{"text": "-9(2x + 1)^2/(x - 1)^2", "feedback": "The two denominators were not combined. The outer power leaves one squared bracket and the inner quotient rule leaves another."},
   {"text": "-9(2x + 1)^2/(x - 1)^4", "feedback": "Correct."},
   {"text": "3(2x + 1)^2/(x - 1)^2", "feedback": "The chain rule stopped at the outer power. The inside is a quotient, so its derivative has to be found and multiplied in."},
   {"text": "9(2x + 1)^2/(x - 1)^4", "feedback": "The inner quotient derivative came out positive. Its numerator is 2(x take away 1) take away (2x plus 1), which is negative."}]'::jsonb,
 1, 'sub-chain-rule'),

(12, 'MCV4U', 'Derivative Rules', 1, 35, 'Advanced',
 E'A hammer falls from 90 m with s(t) = 90 - 4.9t^2 metres.\nWhat is its velocity when it hits the ground, to one decimal place?',
 '[{"text": "-4.3 m/s", "feedback": "That is the TIME the hammer takes to land, in seconds. It still has to be substituted into the velocity function."},
   {"text": "-21.0 m/s", "feedback": "The 4.9 was used where the 9.8 belongs. Differentiating doubles that coefficient before the time is substituted."},
   {"text": "-42.0 m/s", "feedback": "Correct."},
   {"text": "42.0 m/s", "feedback": "The magnitude is right but the sign is not. The hammer is moving downwards, towards the origin at ground level."}]'::jsonb,
 2, 'sub-motion'),

(12, 'MCV4U', 'Derivative Rules', 1, 36, 'Advanced',
 E'A particle moves with s(t) = t^3 - 12t^2 + 36t for t >= 0.\nWhat is its acceleration the SECOND time it comes to rest?',
 '[{"text": "36", "feedback": "That is a coefficient from the position function. The acceleration has to be evaluated at the time in question."},
   {"text": "12", "feedback": "Correct."},
   {"text": "-12", "feedback": "The first time it comes to rest was used. The velocity has two zeros, and the question asks about the later one."},
   {"text": "0", "feedback": "At rest means the VELOCITY is zero. The acceleration has no reason to vanish at the same instant."}]'::jsonb,
 1, 'sub-motion'),

(12, 'MCV4U', 'Derivative Rules', 1, 37, 'Advanced',
 'At a certain instant a particle has negative velocity and negative acceleration. What is it doing?',
 '[{"text": "Momentarily at rest", "feedback": "At rest means the velocity is zero. Here it is negative, so the particle is definitely moving."},
   {"text": "Moving in the positive direction", "feedback": "A negative velocity means the particle is moving back towards the origin, not away from it."},
   {"text": "Speeding up", "feedback": "Correct."},
   {"text": "Slowing down", "feedback": "That happens when velocity and acceleration have OPPOSITE signs. Here they agree, so the acceleration is pushing the particle further in the direction it is already going."}]'::jsonb,
 2, 'sub-motion'),

(12, 'MCV4U', 'Derivative Rules', 1, 38, 'Advanced',
 E'A 0.35 kg ball is thrown upward with v(t) = 40 - 9.8t m/s. Its kinetic energy is K = 0.5mv^2 joules.\nWhat is the rate of change of its kinetic energy at t = 3 seconds, to one decimal place?',
 '[{"text": "3.7 J/s", "feedback": "The chain rule was stopped after the outer square. The bracket contains a t, so its derivative has to multiply in."},
   {"text": "19.7 J/s", "feedback": "That is the kinetic energy itself at 3 seconds, not its rate of change."},
   {"text": "-36.4 J/s", "feedback": "Correct."},
   {"text": "36.4 J/s", "feedback": "The inner derivative was taken as positive 9.8. The velocity function is decreasing, so its derivative is negative."}]'::jsonb,
 2, 'sub-roc-applications'),

(12, 'MCV4U', 'Derivative Rules', 1, 39, 'Advanced',
 E'The mass in kg of the first x metres of a wire is f(x) = sqrt(3x + 1).\nWhat is the average linear density of the wire from x = 5 to x = 8, to three decimal places?',
 '[{"text": "0.375 kg/m", "feedback": "That is the derivative at x equals 5, which is the linear density AT that point. An average needs the change in mass over the change in length."},
   {"text": "1.000 kg/m", "feedback": "That is the change in mass on its own. A density divides it by the length it was spread over."},
   {"text": "3.000 kg/m", "feedback": "The fraction is upside down. Mass goes on top and length underneath."},
   {"text": "0.333 kg/m", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-applications'),

(12, 'MCV4U', 'Derivative Rules', 1, 40, 'Advanced',
 E'The cost of producing x DVDs is C(x) = -0.004x^2 + 9.2x + 5000 dollars.\nWhat is the marginal cost at a production level of 1000 DVDs a month?',
 '[{"text": "9.20 dollars", "feedback": "Only the linear term was differentiated. The squared term also contributes, and at 1000 units it contributes a lot."},
   {"text": "10.20 dollars", "feedback": "That is the total cost at 1000 divided by 1000, which is the average cost per DVD, not the marginal one."},
   {"text": "-8.00 dollars", "feedback": "Only the squared term was differentiated. The linear term contributes as well, and it is the larger of the two."},
   {"text": "1.20 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-applications');

-- --- questions_mcv4u_u2.sql ---

-- ===========================================================================
-- MCV4U — Unit 2: Curve Sketching — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Increasing versus decreasing
--   Lesson 2  Local and absolute maxima and minima
--   Lesson 3  The second derivative and concavity
--   Lesson 4  Rational functions
--   Lesson 5  Curve sketching
--   Lesson 6  Optimization
--
-- Six lessons, six subtopics. The split that matters most on the dashboard
-- is CRITICAL POINTS against CONCAVITY. Both are about a derivative being
-- zero, and a student who has fused the two will confidently answer that
-- every zero of the second derivative is a point of inflection, and that
-- every critical number is a turning point. Neither is true, and neither
-- shows up as a distinct weakness unless the two are counted separately.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Three of them repeat all through this unit and the dashboard
-- will show them constantly:
--
--   * treating a zero of a derivative as automatically an extremum or an
--     inflection point, without checking that the sign changes
--   * finding the critical x-values and stopping, without substituting them
--     back to get the actual maximum or minimum VALUE
--   * forgetting that on a closed interval the endpoints compete
--
-- Feedback names the mistake and stops there.
--
-- Every derivative, critical number, interval and optimised value in this
-- file was recomputed independently with sympy before delivery; nothing was
-- copied from the source PDFs.
--
-- FIGURES: three, and this is the most visual unit in the course, so that
-- is the honest count rather than a generous one.
--
--   * Q8 shows a curve on a closed interval with five labelled points and
--     asks which is the ABSOLUTE maximum. The tallest local maximum is not
--     it; the left-hand endpoint is higher. No grid and no vertical scale.
--   * Q10 shows the lifeguard rectangle with the beach on the open side.
--     The picture carries which side is not roped, which is the whole setup.
--     It is drawn near square although the answer is two to one, so a
--     student who measures it and trusts the proportion is misled.
--   * Q18 shows the graph of f PRIME crossing the axis at two named values
--     and asks where f has a local maximum. The answer is the sign change,
--     which is the only thing the picture shows.
--
-- Rejected: any sketch of f itself with its features already marked. That
-- is the answer sheet for the unit. Every question about a specific
-- function here is asked from the equation.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file must come last, and must be re-run after any re-run of
-- this one: the delete at the top wipes the figure column with the rest of
-- the row. Student attempts (keyed on course, unit and sort_order) survive
-- the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCV4U' and unit = 'Curve Sketching';

insert into misconception_labels (tag, label) values
  ('sub-increasing-decreasing', 'Increasing and decreasing intervals'),
  ('sub-critical-extrema',      'Critical numbers and extrema'),
  ('sub-concavity',             'Concavity and the second derivative'),
  ('sub-rational-sketching',    'Sketching rational functions'),
  ('sub-curve-sketching',       'Putting a full sketch together'),
  ('sub-optimization',          'Optimization')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the vocabulary, and one derivative at a time.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 1, 'Easy',
 'If f prime of x is positive throughout an interval, what is f doing on that interval?',
 '[{"text": "Increasing", "feedback": "Correct."},
   {"text": "Decreasing", "feedback": "A positive slope tilts upward as you move to the right, so the values are going up rather than down."},
   {"text": "Concave up", "feedback": "Concavity is decided by the SECOND derivative. The first one only says which way the curve is heading."},
   {"text": "At a maximum", "feedback": "A maximum needs the derivative to be zero and to change sign. Here it is positive right across the interval."}]'::jsonb,
 0, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 2, 'Easy',
 'On which interval is f(x) = x^2 - 6x + 8 decreasing?',
 '[{"text": "x < 0", "feedback": "The vertex was placed at the origin. Setting 2x take away 6 to zero moves it."},
   {"text": "All real numbers", "feedback": "A parabola turns around. It cannot be decreasing on both sides of its vertex."},
   {"text": "x < 3", "feedback": "Correct."},
   {"text": "x > 3", "feedback": "The wrong side of the vertex was taken. To the right of the turning point of an upward parabola the values are climbing."}]'::jsonb,
 2, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 3, 'Easy',
 'What is a critical number of a function f?',
 '[{"text": "Any value where f is undefined", "feedback": "A critical number has to be IN the domain. A vertical asymptote is outside it, so it does not count."},
   {"text": "A value in the domain of f where f prime is zero or does not exist", "feedback": "Correct."},
   {"text": "A value where f itself is zero", "feedback": "That is an x-intercept. It says where the curve crosses the axis, not where it turns."},
   {"text": "A value where the second derivative is zero", "feedback": "That is a candidate for a point of INFLECTION. A critical number comes from the first derivative."}]'::jsonb,
 1, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 4, 'Easy',
 'What is the critical number of f(x) = x^2 - 6x + 8?',
 '[{"text": "x = 8", "feedback": "That is the constant term. Differentiating removes it entirely."},
   {"text": "x = -3", "feedback": "A sign was flipped. Setting 2x take away 6 to zero gives a positive value."},
   {"text": "x = 3", "feedback": "Correct."},
   {"text": "x = 2 and x = 4", "feedback": "Those are the zeros of the FUNCTION. A critical number comes from setting the derivative to zero."}]'::jsonb,
 2, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 5, 'Easy',
 'If f double prime of x is negative throughout an interval, what is the shape of the graph there?',
 '[{"text": "Concave down", "feedback": "Correct."},
   {"text": "Concave up", "feedback": "The sign was read backwards. A positive second derivative is the one that bends the curve upward."},
   {"text": "Decreasing", "feedback": "That is what a negative FIRST derivative gives. The second derivative describes bending, not direction."},
   {"text": "Increasing", "feedback": "Direction comes from the first derivative. A curve can be rising and still bending downward."}]'::jsonb,
 0, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 6, 'Easy',
 'In the second derivative test, if f prime of c is zero and f double prime of c is positive, what is at x = c?',
 '[{"text": "An absolute maximum", "feedback": "The test is local; it only describes the immediate neighbourhood. It also gives the wrong kind of turning point here."},
   {"text": "A local minimum", "feedback": "Correct."},
   {"text": "A local maximum", "feedback": "The two cases were swapped. A curve bending upward at a flat point sits in a valley, not on a hill."},
   {"text": "A point of inflection", "feedback": "An inflection point needs the second derivative to be ZERO and to change sign. Here it is positive."}]'::jsonb,
 1, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 7, 'Easy',
 E'The graph of y = 1/x is concave down to the left of x = 0 and concave up to the right of it.\nIs x = 0 a point of inflection?',
 '[{"text": "Yes, because the second derivative is zero there", "feedback": "The second derivative is not zero at that value; it is undefined, along with the function itself."},
   {"text": "Only if the graph is continuous everywhere else", "feedback": "What happens elsewhere is irrelevant. The test is whether this particular value is in the domain."},
   {"text": "No, because the function is not defined at x = 0", "feedback": "Correct."},
   {"text": "Yes, because the concavity changes there", "feedback": "The concavity does change, but a point of inflection has to BE a point on the curve. There is nothing there to be one."}]'::jsonb,
 2, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 8, 'Easy',
 E'The graph shows a function on the closed interval from 0 to 10, with five points marked.\nWhich point is the ABSOLUTE maximum?',
 '[{"text": "A", "feedback": "Correct."},
   {"text": "C", "feedback": "That is the tallest LOCAL maximum, the highest turning point. On a closed interval the endpoints compete too, and one of them is above it."},
   {"text": "E", "feedback": "That is an endpoint, so it is a candidate, but it is not the highest point on the graph. Compare it with the other end."},
   {"text": "D", "feedback": "That is the lowest point on the whole graph, which makes it the absolute MINIMUM."}]'::jsonb,
 0, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 9, 'Easy',
 'In an optimization problem, once the quantity has been written as a function of a single variable, what is the next step?',
 '[{"text": "Set the second derivative equal to zero and solve", "feedback": "That finds points of inflection. The maximum or minimum is where the FIRST derivative vanishes."},
   {"text": "Substitute the endpoints of the given domain", "feedback": "The endpoints do have to be checked, but only alongside the critical numbers, which have to be found first."},
   {"text": "Set the derivative equal to zero and solve", "feedback": "Correct."},
   {"text": "Set the function itself equal to zero and solve", "feedback": "That finds where the quantity is ZERO, which is usually the worst possible answer rather than the best."}]'::jsonb,
 2, 'sub-optimization'),

(12, 'MCV4U', 'Curve Sketching', 2, 10, 'Easy',
 E'A lifeguard has 200 m of rope to enclose a rectangular swimming area, with the beach forming the fourth side as shown.\nIf each of the two sides perpendicular to the beach is x metres, what is the length of the third roped side?',
 '[{"text": "200 - 2x", "feedback": "Correct."},
   {"text": "200 - x", "feedback": "Only one of the perpendicular sides was subtracted. There are two of them, and both use rope."},
   {"text": "(200 - x)/2", "feedback": "x was taken as the side parallel to the beach, so the leftover rope was split between the other two sides. The prompt puts x on each of the sides perpendicular to the beach."},
   {"text": "100 - x", "feedback": "The full perimeter formula for a four-sided rectangle was used. Here only three sides are roped."}]'::jsonb,
 0, 'sub-optimization'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): a full sign analysis, or an interval that has to be tested.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 11, 'Medium',
 'On which intervals is f(x) = 2x^3 + 3x^2 - 36x + 5 increasing?',
 '[{"text": "-3 < x < 2", "feedback": "The wrong side of the sign chart was chosen. Between the two critical numbers the derivative is negative."},
   {"text": "x < -2 or x > 3", "feedback": "The two critical numbers had their signs swapped when the factored derivative was read out."},
   {"text": "x > 2 only", "feedback": "Only one of the two stretches was found. The derivative is also positive to the left of the smaller critical number."},
   {"text": "x < -3 or x > 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 12, 'Medium',
 'Is f(x) = x^3 + 2 ever decreasing?',
 '[{"text": "Yes, for x > 0", "feedback": "The derivative 3x squared is positive there, so the function is climbing, not falling."},
   {"text": "Yes, at x = 0 only", "feedback": "The derivative is zero at that single point, which makes the tangent flat. A flat tangent at one point is not a decreasing interval."},
   {"text": "No, because its derivative is never negative", "feedback": "Correct."},
   {"text": "Yes, for x < 0", "feedback": "The cubic itself is negative there, but the DERIVATIVE is 3x squared, which cannot be negative for any real x."}]'::jsonb,
 2, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 13, 'Medium',
 'Find the local extrema of f(x) = 2x^3 + 3x^2 - 36x + 5.',
 '[{"text": "Local min at (-3, 86) and local max at (2, -39)", "feedback": "The two classifications were swapped. Check the sign of the second derivative at each critical number, or the sign chart of the first."},
   {"text": "Local max at x = -3 and local min at x = 2, with no y-values", "feedback": "The critical x-values are right but a turning POINT needs both coordinates. Substitute each one back into the original function."},
   {"text": "Local max at (3, 86) and local min at (-2, -39)", "feedback": "Both critical numbers had their signs flipped when the factored derivative was read out."},
   {"text": "Local max at (-3, 86) and local min at (2, -39)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 14, 'Medium',
 'What is the absolute MINIMUM value of f(x) = x^3 - 12x - 3 on the interval from -3 to 4?',
 '[{"text": "-19", "feedback": "Correct."},
   {"text": "6", "feedback": "That is the value at the left endpoint. It is a candidate, but a critical number inside the interval goes lower."},
   {"text": "13", "feedback": "That is the largest value on the interval, so it is the absolute MAXIMUM rather than the minimum."},
   {"text": "-3", "feedback": "That is the constant term of the function, which happens to be its value at zero. Zero is not a critical number here."}]'::jsonb,
 0, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 15, 'Medium',
 'For f(x) = x^4 - 2x^3 - 5, at which values of x is the second derivative equal to zero?',
 '[{"text": "x = 0 and x = 3/2", "feedback": "Those are the values where the FIRST derivative is zero. The question asks about the second."},
   {"text": "x = 1 only", "feedback": "The second derivative factors into 12x times the bracket, and the bare 12x gives a value of its own."},
   {"text": "x = 3/2 only", "feedback": "That value comes from the first derivative, and it is only half of what that one gives anyway."},
   {"text": "x = 0 and x = 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 16, 'Medium',
 E'For f(x) = x^4 the second derivative is zero at x = 0.\nIs x = 0 a point of inflection?',
 '[{"text": "It is an inflection point from the left but not from the right", "feedback": "The second derivative is 12x squared, which is positive on both sides. The bending is the same either way."},
   {"text": "No, because the concavity does not change there", "feedback": "Correct."},
   {"text": "Yes, because the second derivative is zero there", "feedback": "A zero of the second derivative is only a CANDIDATE. It has to be checked for an actual change of concavity, and here there is none."},
   {"text": "Yes, because the first derivative is zero there too", "feedback": "Both derivatives do vanish there, but that makes it a flat point at the bottom of the curve rather than a change of bending."}]'::jsonb,
 1, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 17, 'Medium',
 'On which interval is f(x) = 1/(x - 2) concave up?',
 '[{"text": "x > 2", "feedback": "Correct."},
   {"text": "x < 2", "feedback": "The wrong branch was chosen. Cubing a negative quantity keeps it negative, so the second derivative is negative on that side."},
   {"text": "Everywhere except x = 2", "feedback": "The two branches bend in opposite directions. Only one of them curves upward."},
   {"text": "Nowhere", "feedback": "The second derivative is 2 over the cube of the bracket, which is positive on one side of the asymptote."}]'::jsonb,
 0, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 18, 'Medium',
 E'The graph shows y = f prime of x, crossing the horizontal axis at p and at q.\nAt which value does f itself have a local MAXIMUM?',
 '[{"text": "At q", "feedback": "The derivative goes from negative to positive there, so f stops falling and starts climbing. That is the shape of a valley."},
   {"text": "At the lowest point of the curve shown", "feedback": "That is where f PRIME is smallest, which makes it the steepest downhill point of f. It is a point of inflection on f, not a turning point."},
   {"text": "At neither, because the curve shown has no maximum", "feedback": "The picture is the graph of the DERIVATIVE. What f does is decided by where that graph crosses the axis, not by its own shape."},
   {"text": "At p", "feedback": "Correct."}]'::jsonb,
 3, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 19, 'Medium',
 E'A lifeguard uses 200 m of rope for three sides of a rectangle, the fourth side being the beach.\nWhich dimensions give the maximum enclosed area?',
 '[{"text": "66.7 m by 66.7 m", "feedback": "The rope was split equally between three sides. A square is optimal when all FOUR sides are fenced, which is not the case here."},
   {"text": "50 m by 100 m", "feedback": "Correct."},
   {"text": "50 m by 50 m", "feedback": "The area function was maximised for one variable and then the same value was used for the other. Substitute back into the expression for the third side."},
   {"text": "100 m by 100 m", "feedback": "That uses 300 m of rope on the three sides. Only 200 m is available."}]'::jsonb,
 1, 'sub-optimization'),

(12, 'MCV4U', 'Curve Sketching', 2, 20, 'Medium',
 'Why must the endpoints be tested in an optimization problem on a restricted domain?',
 '[{"text": "The second derivative test always fails at an endpoint", "feedback": "The test is about classifying interior critical points. The reason endpoints matter is that they are candidates in their own right."},
   {"text": "The largest or smallest value can occur at an endpoint, where the derivative need not be zero", "feedback": "Correct."},
   {"text": "The derivative is always undefined at an endpoint", "feedback": "That is not generally true, and it would not matter if it were. The reason is that the extreme value can simply sit there."},
   {"text": "Critical numbers can never be maxima or minima", "feedback": "They very often are. Endpoints are checked ALONGSIDE them, not instead of them."}]'::jsonb,
 1, 'sub-optimization'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): rational functions, awkward derivatives, and a full
-- optimization. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 21, 'Challenge',
 'On which interval is f(x) = x/(x^2 + 1) increasing?',
 '[{"text": "x < -1 or x > 1", "feedback": "The wrong side of the sign chart was chosen. The numerator of the derivative is 1 take away x squared, which is negative out there."},
   {"text": "x > 0", "feedback": "The function is odd, so it behaves the same way on both sides of the origin. The turning points are what bound the interval."},
   {"text": "Everywhere", "feedback": "The derivative does change sign. Its numerator is a difference of squares, which has two zeros."},
   {"text": "-1 < x < 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 22, 'Challenge',
 'Describe the intervals of increase and decrease for f(x) = x^(2/3).',
 '[{"text": "Increasing everywhere", "feedback": "The graph has a sharp point at the origin with a valley either side. It cannot be climbing on both sides of that."},
   {"text": "Decreasing everywhere", "feedback": "Once past the origin the cube root is positive, so the derivative is positive and the curve climbs."},
   {"text": "Decreasing for x < 0 and increasing for x > 0", "feedback": "Correct."},
   {"text": "Increasing for x < 0 and decreasing for x > 0", "feedback": "The two sides were swapped. The derivative is 2 over 3 times the cube root of x, which is negative when x is negative."}]'::jsonb,
 2, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 23, 'Challenge',
 E'For f(x) = x^(2/3), the derivative does not exist at x = 0.\nIs x = 0 a critical number?',
 '[{"text": "No, because the derivative does not exist there", "feedback": "That is exactly the second way a critical number arises. A cusp is a critical point, and this function has one."},
   {"text": "No, because f of 0 is zero", "feedback": "The VALUE of the function has nothing to do with it. What matters is whether the value is in the domain and what the derivative does."},
   {"text": "Only if the second derivative exists there", "feedback": "Critical numbers are decided by the first derivative alone. The second is not consulted."},
   {"text": "Yes, because the derivative fails to exist there and f itself is defined there", "feedback": "Correct."}]'::jsonb,
 3, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 24, 'Challenge',
 E'A cylinder of surface area 100 cm^2 has volume V(r) = 50r - pi r^3, where the radius cannot exceed 3 cm.\nWhat is the maximum volume, to one decimal place?',
 '[{"text": "2.3 cm^3", "feedback": "That is the RADIUS that maximises the volume, not the volume itself. It still has to be substituted back."},
   {"text": "150.0 cm^3", "feedback": "Only the first term of the volume function was evaluated at r equals 3. The cubic term takes a large amount back off."},
   {"text": "76.8 cm^3", "feedback": "Correct."},
   {"text": "65.2 cm^3", "feedback": "That is the volume at the endpoint r equals 3. The endpoint has to be checked, but a critical number inside the interval beats it here."}]'::jsonb,
 2, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 25, 'Challenge',
 'On which interval is f(x) = x^3 - 3x^2 + 1 concave down?',
 '[{"text": "x > 1", "feedback": "The inequality was read the wrong way. The second derivative is 6x take away 6, which is positive out there."},
   {"text": "-1 < x < 1", "feedback": "A cubic has one point of inflection, so its concavity changes exactly once. What you are looking for is a half line, not a strip between two values."},
   {"text": "x < 0", "feedback": "The inflection point was placed at the origin. Setting 6x take away 6 to zero moves it."},
   {"text": "x < 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 26, 'Challenge',
 'What is the oblique asymptote of f(x) = (x^2 + 1)/x?',
 '[{"text": "y = 0", "feedback": "That is the horizontal asymptote rule for when the bottom has the higher degree. Here the top is one degree higher, which produces a slanted line instead."},
   {"text": "x = 0", "feedback": "That is the VERTICAL asymptote. It is real, but it is not the oblique one."},
   {"text": "y = x + 1", "feedback": "Dividing out gives x plus 1 over x. The leftover term goes to zero, so the constant 1 does not belong to the line."},
   {"text": "y = x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 27, 'Challenge',
 'How many local extrema does f(x) = x/(x - 3) have?',
 '[{"text": "One local minimum, at x = 0", "feedback": "That is the x-intercept, where the curve crosses the axis rather than turns."},
   {"text": "None", "feedback": "Correct."},
   {"text": "One local minimum, at x = 3", "feedback": "That value is the vertical asymptote, so it is not in the domain and cannot be a turning point."},
   {"text": "One local maximum, at x = 0", "feedback": "That is the x-intercept. The derivative there is negative three ninths, which is not zero."}]'::jsonb,
 1, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 28, 'Challenge',
 'A function has f prime of x positive and f double prime of x negative throughout an interval. Which describes its graph there?',
 '[{"text": "Falling, but bending upwards", "feedback": "Both signs were read backwards. Positive first means rising and negative second means bending down."},
   {"text": "Rising, but bending downwards", "feedback": "Correct."},
   {"text": "Rising, and bending upwards", "feedback": "The direction is right but the bending is not. A negative second derivative curves the graph downwards."},
   {"text": "Falling, and bending downwards", "feedback": "The bending is right but the direction is not. A positive first derivative makes the graph climb."}]'::jsonb,
 1, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 29, 'Challenge',
 E'A function satisfies f(2) = 0, f prime of 2 = 0, and f double prime of 2 > 0.\nWhat feature does the graph have at x = 2?',
 '[{"text": "A local minimum sitting on the x-axis", "feedback": "Correct."},
   {"text": "A local maximum sitting on the x-axis", "feedback": "The second derivative test was applied backwards. Bending upwards at a flat point puts the graph in a valley."},
   {"text": "A point of inflection on the x-axis", "feedback": "An inflection point needs the second derivative to be zero and to change sign. Here it is strictly positive."},
   {"text": "A vertical asymptote", "feedback": "The function has a value there, namely zero, so the graph passes through the point rather than running away from it."}]'::jsonb,
 0, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 30, 'Challenge',
 E'A closed cardboard box with a square base is to hold 8000 cm^3.\nWhat is the minimum surface area of cardboard needed?',
 '[{"text": "20 cm^2", "feedback": "That is the side LENGTH that minimises the area, not the area itself. It still has to be substituted back."},
   {"text": "2400 cm^2", "feedback": "Correct."},
   {"text": "800 cm^2", "feedback": "Only the two square ends were counted. The four rectangular sides make up the larger part of the surface."},
   {"text": "1600 cm^2", "feedback": "Only the four sides were counted. The top and the bottom have to be included as well."}]'::jsonb,
 1, 'sub-optimization'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): sign charts with three critical numbers, a failing
-- second derivative test, and two full optimizations. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 31, 'Advanced',
 'On which intervals is f(x) = x^4 - 8x^2 increasing?',
 '[{"text": "x < -2 or 0 < x < 2", "feedback": "Every interval on the sign chart was taken the wrong way. The derivative factors into three brackets, so it alternates."},
   {"text": "x > 0", "feedback": "The critical numbers at plus and minus 2 were missed. The derivative is a cubic with three zeros, not one."},
   {"text": "-2 < x < 2", "feedback": "The whole strip between the outer critical numbers was taken. The derivative changes sign again at the origin, in the middle of it."},
   {"text": "-2 < x < 0 or x > 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 32, 'Advanced',
 'Classify the critical points of f(x) = 3x^5 - 5x^3.',
 '[{"text": "Local min at x = -1, local max at x = 1, and neither at x = 0", "feedback": "The two outer classifications were swapped. Check the sign of the second derivative at each of them."},
   {"text": "Local max at x = -1 and local min at x = 1 only, because x = 0 is not a critical number", "feedback": "It is a critical number: the derivative factors into 15x squared times a bracket, so the origin does make it vanish. It simply is not a turning point."},
   {"text": "Local max at x = -1, local min at x = 1, and neither at x = 0", "feedback": "Correct."},
   {"text": "Local max at x = -1, local min at x = 1, and a local max at x = 0", "feedback": "The second derivative test returns zero at the origin, so it fails there and tells you nothing. The first derivative is negative on BOTH sides, so nothing turns around."}]'::jsonb,
 2, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 33, 'Advanced',
 'On which intervals is f(x) = x^4 - 2x^3 - 5 concave up?',
 '[{"text": "0 < x < 1", "feedback": "The wrong side of the sign chart was taken. Between the two zeros of the second derivative the product 12x times the bracket comes out negative."},
   {"text": "x > 1 only", "feedback": "Only one of the two stretches was found. To the left of the origin both factors are negative, so their product is positive."},
   {"text": "x < 0 or x > 3/2", "feedback": "The larger boundary came from the FIRST derivative. The second derivative has its own zeros."},
   {"text": "x < 0 or x > 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 34, 'Advanced',
 'If f double prime of c equals zero, what can be concluded about the graph at x = c?',
 '[{"text": "The graph is a straight line near x = c", "feedback": "That would need the second derivative to be zero on a whole interval, not at a single value."},
   {"text": "Nothing yet — the concavity has to be checked on both sides", "feedback": "Correct."},
   {"text": "There is a point of inflection at x = c", "feedback": "That is the assumption this question exists to break. The fourth power function has a zero second derivative at the origin and no change of bending at all."},
   {"text": "There is a local maximum or minimum at x = c", "feedback": "Turning points come from the FIRST derivative vanishing, not the second."}]'::jsonb,
 1, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 35, 'Advanced',
 'For f(x) = (x^2 - 4)/(x^2 - 1), how many vertical asymptotes and how many x-intercepts does the graph have?',
 '[{"text": "Only one vertical asymptote and two x-intercepts", "feedback": "The denominator factors into two brackets, so it vanishes at two separate values."},
   {"text": "Two vertical asymptotes and no x-intercepts", "feedback": "The numerator does reach zero. Setting x squared take away 4 to zero gives two real values."},
   {"text": "Two vertical asymptotes and two x-intercepts", "feedback": "Correct."},
   {"text": "Two vertical asymptotes and one x-intercept", "feedback": "The numerator is also a difference of squares, so it has two zeros rather than one."}]'::jsonb,
 2, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 36, 'Advanced',
 'What are the coordinates of the local minimum of f(x) = x + 3/x for x > 0, to two decimal places?',
 '[{"text": "(1.73, 4.73)", "feedback": "The two terms were added as if the second were 3 rather than 3 divided by x. Substitute the critical number into the second term as it is written."},
   {"text": "(1.73, 3.46)", "feedback": "Correct."},
   {"text": "(1.73, 1.73)", "feedback": "The x-value is right but was reused as the height. Substitute it back into the whole function, which has two terms."},
   {"text": "(3.00, 4.00)", "feedback": "The 3 from the numerator was taken as the critical value. Setting 1 take away 3 over x squared to zero gives its square root instead."}]'::jsonb,
 1, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 37, 'Advanced',
 E'The graph of f prime is an upward parabola with x-intercepts at -1 and 3.\nWhat does the graph of f have at those two values?',
 '[{"text": "Points of inflection at both values", "feedback": "Inflection points come from the second derivative, which here is the SLOPE of the drawn parabola. That is zero only at its vertex."},
   {"text": "A local maximum at x = 1, the vertex of the parabola", "feedback": "The picture is the graph of f prime, so its vertex marks where f is steepest downhill, which is a point of inflection on f."},
   {"text": "A local maximum at x = -1 and a local minimum at x = 3", "feedback": "Correct."},
   {"text": "A local minimum at x = -1 and a local maximum at x = 3", "feedback": "The two were swapped. An upward parabola is positive to the left of its first root, so f is climbing before it reaches negative 1."}]'::jsonb,
 2, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 38, 'Advanced',
 'A function is decreasing and concave up throughout an interval. What is its derivative doing there?',
 '[{"text": "Negative and increasing", "feedback": "Correct."},
   {"text": "Negative and decreasing", "feedback": "The sign is right but the trend is not. Concave up means the SLOPES are climbing, even while they stay below zero."},
   {"text": "Positive and increasing", "feedback": "The trend is right but the sign is not. A decreasing function has a negative derivative."},
   {"text": "Positive and decreasing", "feedback": "Both parts were read backwards. Decreasing gives a negative derivative and concave up makes it climb."}]'::jsonb,
 0, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 39, 'Advanced',
 E'A can of volume 500 cm^3 has a top costing 0.4 cents per cm^2 and a bottom and sides costing 0.2 cents per cm^2.\nWhat radius minimises the cost, to two decimal places?',
 '[{"text": "3.76 cm", "feedback": "Correct."},
   {"text": "4.30 cm", "feedback": "The top and the bottom were priced the same. The dearer top pulls the best radius smaller, because it shrinks the two circular faces."},
   {"text": "5.42 cm", "feedback": "The 500 was used where the cost coefficients belong. Build the cost function first, then differentiate it."},
   {"text": "79.84 cm", "feedback": "That is the minimum COST in cents, not the radius. The radius still has to be read off the critical number."}]'::jsonb,
 0, 'sub-optimization'),

(12, 'MCV4U', 'Curve Sketching', 2, 40, 'Advanced',
 E'A rectangular field of area 1200 m^2 is to be fenced, with one side running along a river and needing no fence.\nWhat is the least length of fence needed, to one decimal place?',
 '[{"text": "98.0 m", "feedback": "Correct."},
   {"text": "69.3 m", "feedback": "The two perpendicular sides were counted once instead of twice. Only the river side is saved; the opposite pair still needs fencing on both sides."},
   {"text": "138.6 m", "feedback": "All four sides were fenced. The side along the river is free, so it comes out of the total."},
   {"text": "49.0 m", "feedback": "That is the length of the side along the river, which is one of the DIMENSIONS. The question asks for the total fence."}]'::jsonb,
 0, 'sub-optimization');

-- --- questions_mcv4u_u3.sql ---

-- ===========================================================================
-- MCV4U — Unit 3: Derivatives of Trig and Exponential Functions — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Derivatives of trig functions
--   Lesson 2  Derivative rules with trig functions
--   Lesson 3  Derivatives of exponential functions
--   Lesson 4  Derivative rules with exponential functions
--   Lesson 5  Implicit differentiation and derivatives of logarithms
--   Lesson 6  Applications of trig and exponential derivatives
--
-- Six lessons, six subtopics. Jensen splits each family into KNOW THE
-- DERIVATIVE and COMBINE IT WITH A RULE, and that split is worth keeping:
-- a student who has memorised that the derivative of tangent is secant
-- squared and a student who can carry that through a quotient rule are two
-- different students, and only the second one passes the unit.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Four repeat right through the unit:
--
--   * losing the minus sign that belongs to the derivative of cosine
--   * dropping the natural logarithm of the base when differentiating an
--     exponential whose base is not e
--   * forgetting the inner derivative, which now costs a factor buried
--     inside a trig or exponential argument rather than inside a bracket
--   * differentiating a term in y without attaching dy/dx
--
-- Feedback names the mistake and stops there.
--
-- Every derivative, decay constant, half-life and evaluated rate in this
-- file was recomputed independently with sympy before delivery; nothing was
-- copied from the source PDFs. One near miss is worth recording: the
-- derivative of a base-4 logarithm can be written with ln 4 on the bottom
-- or with ln 2 and the 2 cancelled, and those two are the SAME number. A
-- distractor was rewritten once sympy showed the collision.
--
-- FIGURES: none, and the reason is uniform across the unit. Every candidate
-- here is a sine or exponential curve drawn on a grid, and on a grid the
-- amplitude, the period and the y-intercept are all countable. The questions
-- that would use one are asked from the equation instead, which is what a
-- student has to be able to do anyway.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file wipes and re-attaches the whole course, so it must be
-- re-run after any re-run of this one even though this unit has no figures
-- of its own. Student attempts (keyed on course, unit and sort_order)
-- survive the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions
 where course_code = 'MCV4U' and unit = 'Derivatives of Trig and Exponential Functions';

insert into misconception_labels (tag, label) values
  ('sub-trig-derivatives',      'Derivatives of trig functions'),
  ('sub-trig-rules',            'Derivative rules with trig functions'),
  ('sub-exp-derivatives',       'Derivatives of exponential functions'),
  ('sub-exp-rules',             'Derivative rules with exponential functions'),
  ('sub-implicit-log',          'Implicit differentiation and logarithms'),
  ('sub-trig-exp-applications', 'Applications of trig and exponential derivatives')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the six derivatives themselves, straight out of the table.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 1, 'Easy',
 'What is the derivative of sin x?',
 '[{"text": "-cos x", "feedback": "The minus sign belongs to the other one. Differentiating COSINE is what introduces it."},
   {"text": "-sin x", "feedback": "That is the SECOND derivative of sine, after differentiating twice."},
   {"text": "sec^2 x", "feedback": "That is the derivative of tangent."},
   {"text": "cos x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 2, 'Easy',
 'What is the derivative of cos x?',
 '[{"text": "-cos x", "feedback": "That is the SECOND derivative of cosine, after differentiating twice."},
   {"text": "sec^2 x", "feedback": "That is the derivative of tangent."},
   {"text": "-sin x", "feedback": "Correct."},
   {"text": "sin x", "feedback": "The minus sign was dropped. Cosine is falling where sine is positive, so its derivative has to be the negative one."}]'::jsonb,
 2, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 3, 'Easy',
 'What is the derivative of tan x?',
 '[{"text": "cot x", "feedback": "That is the reciprocal of tangent, not its derivative."},
   {"text": "-csc^2 x", "feedback": "That is the derivative of COTANGENT. Note the minus sign, which tangent does not have."},
   {"text": "sec^2 x", "feedback": "Correct."},
   {"text": "sec x tan x", "feedback": "That is the derivative of SECANT, which is a different function."}]'::jsonb,
 2, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 4, 'Easy',
 'What is the derivative of e^x?',
 '[{"text": "e", "feedback": "That is the base, a constant. The function itself is what comes back out."},
   {"text": "e^x", "feedback": "Correct."},
   {"text": "x e^(x - 1)", "feedback": "The power rule was applied. That rule is for a variable BASE with a constant exponent, which is the other way round here."},
   {"text": "1", "feedback": "The exponent was differentiated on its own. The whole expression is what has to be differentiated."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 5, 'Easy',
 'What is the derivative of 2^x?',
 '[{"text": "2^x / ln 2", "feedback": "The logarithm ended up underneath. It multiplies rather than divides."},
   {"text": "2^x ln 2", "feedback": "Correct."},
   {"text": "2^x", "feedback": "That is the rule for base e only. Any other base picks up the natural logarithm of that base as a factor."},
   {"text": "x 2^(x - 1)", "feedback": "The power rule was applied. That rule is for a variable base with a constant exponent, which is the other way round here."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 6, 'Easy',
 'What is the derivative of e^(3x)?',
 '[{"text": "3e^x", "feedback": "The 3 came down correctly but the exponent lost it. The exponent is untouched by differentiating."},
   {"text": "e^(3x)/3", "feedback": "The 3 ended up underneath. That is what integrating would do, not differentiating."},
   {"text": "3e^(3x)", "feedback": "Correct."},
   {"text": "e^(3x)", "feedback": "The inner derivative was forgotten. The exponent is 3x, and differentiating that gives 3."}]'::jsonb,
 2, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 7, 'Easy',
 'When differentiating with respect to x, what does y^2 become?',
 '[{"text": "y^2 times dy/dx", "feedback": "The dy/dx is right but the power rule was never applied. The exponent has to come down and drop by one."},
   {"text": "2y times dy/dx", "feedback": "Correct."},
   {"text": "2y", "feedback": "The chain rule was stopped one step early. y is itself a function of x, so its derivative has to be attached."},
   {"text": "2 times dy/dx", "feedback": "The power rule was not applied to the y. It should leave a 2y, not a bare 2."}]'::jsonb,
 1, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 8, 'Easy',
 'What is the derivative of ln x?',
 '[{"text": "1/x", "feedback": "Correct."},
   {"text": "1/(x ln 10)", "feedback": "That is the derivative of the base-10 logarithm. For a natural logarithm the base is e, and the natural logarithm of e is 1."},
   {"text": "ln x", "feedback": "The function was copied out again. That happens with the exponential, not the logarithm."},
   {"text": "x/1", "feedback": "The reciprocal was turned the wrong way up."}]'::jsonb,
 0, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 9, 'Easy',
 E'A power supply delivers a voltage V(t) = 5sin(t) + 12 volts.\nWhat is the maximum voltage?',
 '[{"text": "12 volts", "feedback": "That is the DC part on its own, the level the signal oscillates about. The alternating part rides on top of it."},
   {"text": "5 volts", "feedback": "That is the amplitude, the size of the swing. It has to be added to the level the signal sits at."},
   {"text": "7 volts", "feedback": "That is the MINIMUM voltage. The amplitude was subtracted rather than added."},
   {"text": "17 volts", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-exp-applications'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 10, 'Easy',
 E'A radioactive sample decays according to N(t) = N0 e^(-kt), where N is the mass remaining after t days.\nWhat does N prime of t represent?',
 '[{"text": "How fast the sample is decaying, in mass per day", "feedback": "Correct."},
   {"text": "The mass of the sample still remaining after t days", "feedback": "That is N of t itself, before any differentiating."},
   {"text": "The number of days it takes for half the sample to decay", "feedback": "That is a single number, not a function of time, and it comes from solving rather than differentiating."},
   {"text": "The value of the disintegration constant k for the sample", "feedback": "That is k, a fixed number in the exponent. The derivative is a function that changes with time."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): one chain rule, or one rule combined with one derivative.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 11, 'Medium',
 'Differentiate y = sin(3x).',
 '[{"text": "3cos(3x)", "feedback": "Correct."},
   {"text": "cos(3x)", "feedback": "The inner derivative was forgotten. Differentiating 3x gives 3, which multiplies on the outside."},
   {"text": "3cos x", "feedback": "The 3 came out but the argument lost it. The 3x stays inside the cosine untouched."},
   {"text": "-3cos(3x)", "feedback": "A minus sign appeared from nowhere. It belongs to the derivative of cosine, not of sine."}]'::jsonb,
 0, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 12, 'Medium',
 'Differentiate y = cos(x^2).',
 '[{"text": "-sin(x^2)", "feedback": "The inner derivative was forgotten. Differentiating x squared gives 2x, which multiplies on the outside."},
   {"text": "2x sin(x^2)", "feedback": "The minus sign was dropped. Differentiating cosine always introduces one."},
   {"text": "-2x sin(2x)", "feedback": "The inner function was replaced by its derivative. The x squared stays inside the sine."},
   {"text": "-2x sin(x^2)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 13, 'Medium',
 'Differentiate y = x sin x.',
 '[{"text": "sin x + cos x", "feedback": "The x was dropped from the second term. Each term keeps one factor exactly as it was."},
   {"text": "sin x + x cos x", "feedback": "Correct."},
   {"text": "x cos x", "feedback": "Only the second term of the product rule was written. The derivative of x also multiplies the sine."},
   {"text": "cos x", "feedback": "The two derivatives were multiplied. The product rule needs two terms, each keeping one factor whole."}]'::jsonb,
 1, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 14, 'Medium',
 'Differentiate y = e^(x^2).',
 '[{"text": "2x e^(2x)", "feedback": "The exponent was replaced by its own derivative. The exponent stays exactly as it was."},
   {"text": "x^2 e^(x^2 - 1)", "feedback": "The power rule was applied to the exponent. That rule is for a variable base, not a variable exponent."},
   {"text": "2x e^(x^2)", "feedback": "Correct."},
   {"text": "e^(x^2)", "feedback": "The inner derivative was forgotten. Differentiating x squared gives 2x, which multiplies on the outside."}]'::jsonb,
 2, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 15, 'Medium',
 'Differentiate y = 3^(2x).',
 '[{"text": "3^(2x) times ln 3", "feedback": "The inner derivative was forgotten. The exponent is 2x, and differentiating that gives 2."},
   {"text": "2 times 3^(2x)", "feedback": "The natural logarithm of the base was dropped. Only base e escapes it."},
   {"text": "2 times 3^(2x) times ln 2", "feedback": "The logarithm was taken of the wrong number. It is the BASE that goes inside it, not the coefficient in the exponent."},
   {"text": "2 times 3^(2x) times ln 3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 16, 'Medium',
 'Differentiate y = x^2 e^x.',
 '[{"text": "2x e^x + x^2 e^x", "feedback": "Correct."},
   {"text": "2x e^x", "feedback": "Only the first term of the product rule was written. The x squared also multiplies the derivative of the exponential."},
   {"text": "x^2 e^x", "feedback": "Only the second term of the product rule was written. The derivative of x squared also multiplies the exponential."},
   {"text": "2x e^x + x^3 e^(x - 1)", "feedback": "The power rule was applied to the exponential in the second term. That rule is for a variable base with a constant exponent, which is the other way round here."}]'::jsonb,
 0, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 17, 'Medium',
 'For the circle x^2 + y^2 = 16, what is dy/dx?',
 '[{"text": "-y/x", "feedback": "The fraction is upside down. Isolating dy/dx divides by the coefficient that came from the y term."},
   {"text": "-2x", "feedback": "Only the x side was differentiated. The y squared also produces a term, and it carries dy/dx."},
   {"text": "-x/y", "feedback": "Correct."},
   {"text": "x/y", "feedback": "The sign was lost while isolating. The 2x term has to cross to the other side, which flips it."}]'::jsonb,
 2, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 18, 'Medium',
 'Differentiate y = 2 ln(1 + x^2).',
 '[{"text": "2/(1 + x^2)", "feedback": "The inner derivative was forgotten. Differentiating 1 plus x squared gives 2x, which goes on top."},
   {"text": "4x", "feedback": "The bracket was never put underneath. The derivative of a logarithm is a fraction with the inner function on the bottom."},
   {"text": "4x/(1 + x^2)", "feedback": "Correct."},
   {"text": "2x/(1 + x^2)", "feedback": "The coefficient 2 in front of the logarithm was dropped somewhere. It multiplies the whole derivative."}]'::jsonb,
 2, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 19, 'Medium',
 E'A 6.0 mg sample of Au-198 decays to 4.6 mg after 1 day, following N(t) = N0 e^(-kt).\nWhat is the disintegration constant k, to four decimal places?',
 '[{"text": "0.2657", "feedback": "Correct."},
   {"text": "-0.2657", "feedback": "The minus sign is already in the exponent of the model, so k itself comes out positive. Taking logarithms of the ratio the other way round gives this."},
   {"text": "0.7667", "feedback": "That is the RATIO of the two masses. A logarithm still has to be taken, and the result divided by the time."},
   {"text": "1.3043", "feedback": "That is the ratio the other way up. It is what goes inside the logarithm, not the answer itself."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 20, 'Medium',
 E'Au-198 has a disintegration constant of 0.2657 per day in the model N(t) = N0 e^(-kt).\nWhat is its half-life, to two decimal places?',
 '[{"text": "3.76 days", "feedback": "The logarithm was left out entirely and 1 was divided by the constant. The reciprocal of the disintegration constant is the mean lifetime, not the half-life."},
   {"text": "2.61 days", "feedback": "Correct."},
   {"text": "7.53 days", "feedback": "The 2 was divided by the constant instead of its natural logarithm. Setting the model equal to half is what brings the logarithm in."},
   {"text": "0.26 days", "feedback": "That is the disintegration constant itself, which is the rate rather than the time."}]'::jsonb,
 1, 'sub-trig-exp-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): a rule and a chain rule together. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 21, 'Challenge',
 'Differentiate y = (sin x)^2.',
 '[{"text": "2 sin x", "feedback": "The inner derivative was forgotten. The outer power rule leaves a sine, and differentiating that sine supplies a cosine."},
   {"text": "2 cos^2 x", "feedback": "The sine was replaced by its derivative before the power rule was applied. The original function stays and the inner derivative multiplies on."},
   {"text": "-2 sin x cos x", "feedback": "A minus sign appeared from nowhere. It would belong if the outer function were built on cosine."},
   {"text": "2 sin x cos x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 22, 'Challenge',
 'Differentiate y = tan(3x).',
 '[{"text": "3 sec^2 x", "feedback": "The 3 came out but the argument lost it. The 3x stays inside the secant untouched."},
   {"text": "3 tan(3x) sec(3x)", "feedback": "That is built from the derivative of SECANT. The derivative of tangent is a secant squared."},
   {"text": "3 sec^2(3x)", "feedback": "Correct."},
   {"text": "sec^2(3x)", "feedback": "The inner derivative was forgotten. Differentiating 3x gives 3, which multiplies on the outside."}]'::jsonb,
 2, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 23, 'Challenge',
 'Differentiate y = (sin x)/x.',
 '[{"text": "(sin x - x cos x)/x^2", "feedback": "The two terms on top were subtracted in the wrong order, which flips the sign of the whole thing."},
   {"text": "(x cos x - sin x)/x", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "cos x", "feedback": "The top and the bottom were differentiated separately and then divided. That is not the quotient rule."},
   {"text": "(x cos x - sin x)/x^2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 24, 'Challenge',
 'Differentiate y = x^2 cos x.',
 '[{"text": "2x cos x - x^2 sin x", "feedback": "Correct."},
   {"text": "2x cos x + x^2 sin x", "feedback": "The minus sign from the derivative of cosine was lost."},
   {"text": "-2x sin x", "feedback": "The two derivatives were multiplied. The product rule adds two terms, each keeping one factor whole."},
   {"text": "-x^2 sin x", "feedback": "Only the second term of the product rule was written. The derivative of x squared also multiplies the cosine."}]'::jsonb,
 0, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 25, 'Challenge',
 'Differentiate y = e^(sin x).',
 '[{"text": "sin x times e^(sin x - 1)", "feedback": "The power rule was applied to the exponent. That rule is for a variable base, not a variable exponent."},
   {"text": "cos x times e^(sin x)", "feedback": "Correct."},
   {"text": "e^(sin x)", "feedback": "The inner derivative was forgotten. The exponent is a sine, and differentiating it supplies a cosine."},
   {"text": "e^(cos x)", "feedback": "The exponent was replaced by its own derivative. The exponent stays exactly as it was and the derivative multiplies on the outside."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 26, 'Challenge',
 'What is the equation of the tangent to y = e^x at x = 0?',
 '[{"text": "y = ex", "feedback": "The base was used as the slope. The slope is the derivative evaluated at zero, and e to the power zero is 1."},
   {"text": "y = 1", "feedback": "That is the height of the curve there, drawn as a horizontal line. The tangent has the slope of the curve, which is not zero."},
   {"text": "y = x + 1", "feedback": "Correct."},
   {"text": "y = x", "feedback": "The slope is right but the point was forgotten. The curve passes through a height of 1 at the origin, not zero."}]'::jsonb,
 2, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 27, 'Challenge',
 'Differentiate y = (e^x)/x.',
 '[{"text": "e^x(1 - x)/x^2", "feedback": "The two terms on top were subtracted in the wrong order, which flips the sign."},
   {"text": "e^x(x - 1)/x", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "e^x", "feedback": "The top and the bottom were differentiated separately and then divided. That is not the quotient rule."},
   {"text": "e^x(x - 1)/x^2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 28, 'Challenge',
 'Differentiate y = 3^x e^(sin x) and factor the result.',
 '[{"text": "3^x e^(sin x)(ln 3 times cos x)", "feedback": "The two derivatives were multiplied. The product rule adds its two terms, which is why they collect into a sum inside the bracket."},
   {"text": "3^x e^(sin x)(1 + cos x)", "feedback": "The natural logarithm of the base was dropped. Only base e escapes it."},
   {"text": "3^x e^(sin x)(ln 3 + 1)", "feedback": "The inner derivative was forgotten. The exponent of the second factor is a sine rather than x, so the chain rule still owes a factor there."},
   {"text": "3^x e^(sin x)(ln 3 + cos x)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 29, 'Challenge',
 'Find dy/dx for y^2 + x^3 - y^3 + 6 = 3y.',
 '[{"text": "3x^2/(2y - 3y^2 - 3)", "feedback": "The sign is inverted throughout. Collecting the dy/dx terms on the other side flips every one of them."},
   {"text": "3x^2/(3y^2 - 2y)", "feedback": "The 3y on the right-hand side was left out of the collection. Both sides of the equation get differentiated, so the right-hand side contributes a term too."},
   {"text": "3x^2/(2y - 3y^2)", "feedback": "Two errors at once: the signs were not flipped and the term from the right-hand side was left out."},
   {"text": "3x^2/(3y^2 - 2y + 3)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 30, 'Challenge',
 E'A voltage signal is V(t) = 5sin(t) + 12 volts, with t in seconds.\nWhat is its frequency, to three decimal places?',
 '[{"text": "0.159 Hz", "feedback": "Correct."},
   {"text": "6.283 Hz", "feedback": "That is the PERIOD in seconds. Frequency is its reciprocal, the number of cycles per second."},
   {"text": "5.000 Hz", "feedback": "That is the amplitude in volts. It says how big the swing is, not how often it happens."},
   {"text": "0.500 Hz", "feedback": "The period was taken as 2 seconds. With a coefficient of 1 on t the period is a full 2 pi."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): three layers, or a rate that has to be built before it
-- can be evaluated. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 31, 'Advanced',
 'Differentiate y = (cos(2x))^3.',
 '[{"text": "-6 cos^2(2x) sin(2x)", "feedback": "Correct."},
   {"text": "3 cos^2(2x) sin(2x)", "feedback": "Two things went missing: the minus sign from the derivative of cosine, and the 2 from differentiating the argument."},
   {"text": "-3 cos^2(2x) sin(2x)", "feedback": "The innermost derivative was forgotten. There are two layers inside the cube, and differentiating 2x supplies a factor of 2."},
   {"text": "-6 cos^2(2x)", "feedback": "The middle layer was skipped. Differentiating the cosine itself supplies a sine as well."}]'::jsonb,
 0, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 32, 'Advanced',
 'Differentiate y = (sin x)/(1 + cos x) and simplify fully.',
 '[{"text": "(2 cos x - 1)/(1 + cos x)", "feedback": "The minus sign from differentiating the cosine underneath was dropped, so the second term of the quotient rule came out with the wrong sign."},
   {"text": "cos x/(1 + cos x)", "feedback": "Only the first term of the quotient rule was kept. The second term is not zero, because the denominator depends on x."},
   {"text": "-1/(1 + cos x)^2", "feedback": "The two terms on top were subtracted in the wrong order, and the cancellation was then missed."},
   {"text": "1/(1 + cos x)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 33, 'Advanced',
 'What is the slope of the tangent to y = x sin x at x = pi?',
 '[{"text": "-1", "feedback": "Only the cosine was evaluated. The x that multiplies it in the product rule still has to be substituted."},
   {"text": "-pi", "feedback": "Correct."},
   {"text": "pi", "feedback": "The sign was lost. The cosine of pi is negative 1, not positive 1."},
   {"text": "0", "feedback": "That is the VALUE of the function at pi, since the sine vanishes there. The slope comes from the derivative."}]'::jsonb,
 1, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 34, 'Advanced',
 'At which value of x does y = x e^x have a horizontal tangent?',
 '[{"text": "Nowhere, because an exponential is never zero", "feedback": "The exponential factor indeed never vanishes, but the product rule leaves a bracket alongside it, and that bracket can."},
   {"text": "x = -1", "feedback": "Correct."},
   {"text": "x = 0", "feedback": "The derivative there is 1, not zero. The exponential never vanishes, so the bracket that comes with it is what has to."},
   {"text": "x = 1", "feedback": "A sign was flipped when the bracket was solved. Setting 1 plus x to zero gives a negative value."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 35, 'Advanced',
 'Differentiate y = e^(2x)/(x^2 + 1) and factor the numerator.',
 '[{"text": "2e^(2x)(x^2 - x + 1)/(x^2 + 1)", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "2e^(2x)(x^2 - x + 1)/(x^2 + 1)^2", "feedback": "Correct."},
   {"text": "e^(2x)(x^2 - 2x + 1)/(x^2 + 1)^2", "feedback": "The inner derivative of the exponential was forgotten. Differentiating e to the 2x brings down a 2, which multiplies the first term of the quotient rule."},
   {"text": "2e^(2x)(x^2 + x + 1)/(x^2 + 1)^2", "feedback": "The subtraction in the quotient rule was carried out as an addition, so the middle term came out with the wrong sign."}]'::jsonb,
 1, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 36, 'Advanced',
 E'A 6.0 mg sample of Au-198 decays as N(t) = 6e^(-0.2657t) mg.\nHow fast is it decaying after 3 days, to three decimal places?',
 '[{"text": "2.704 mg per day", "feedback": "That is the MASS remaining after 3 days, not the rate at which it is falling."},
   {"text": "0.718 mg per day", "feedback": "The magnitude is right but the sign is not. The sample is losing mass, so the rate is negative."},
   {"text": "-0.718 mg per day", "feedback": "Correct."},
   {"text": "-1.594 mg per day", "feedback": "That is the rate at time ZERO. The exponential factor still has to be evaluated at 3 days, and it has shrunk by then."}]'::jsonb,
 2, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 37, 'Advanced',
 'Differentiate f(x) = 1 - log base 4 of (2x - 1).',
 '[{"text": "-1/((2x - 1) ln 4)", "feedback": "The inner derivative was forgotten. Differentiating 2x take away 1 gives 2, which goes on top."},
   {"text": "-2/(2x - 1)", "feedback": "The natural logarithm of the base was dropped from the denominator. Only a natural logarithm escapes it."},
   {"text": "-2/((2x - 1) ln 4)", "feedback": "Correct."},
   {"text": "2/((2x - 1) ln 4)", "feedback": "The minus sign in front of the logarithm was dropped. It carries through to the whole derivative."}]'::jsonb,
 2, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 38, 'Advanced',
 'What is the slope of the tangent to the circle x^2 + y^2 = 25 at the point (3, 4)?',
 '[{"text": "4/3", "feedback": "The coordinates were swapped and the sign was lost as well."},
   {"text": "-3/4", "feedback": "Correct."},
   {"text": "3/4", "feedback": "The sign was lost while isolating dy/dx. At this point the circle is falling as you move right."},
   {"text": "-4/3", "feedback": "The two coordinates were substituted the wrong way round. The x-coordinate belongs on top."}]'::jsonb,
 1, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 39, 'Advanced',
 E'A voltage signal is V(t) = 5sin(t) + 12 volts, with t in seconds.\nAt what time does it FIRST reach its maximum, to two decimal places?',
 '[{"text": "1.57 s", "feedback": "Correct."},
   {"text": "4.71 s", "feedback": "That is the other value where the derivative vanishes, but the second derivative is positive there, so it is the minimum."},
   {"text": "3.14 s", "feedback": "The sine is zero there, so the voltage is back at its middle level rather than at a peak."},
   {"text": "6.28 s", "feedback": "That is the full period. The signal has returned to its starting level by then, not to a peak."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 40, 'Advanced',
 E'A population grows as P(t) = 500e^(0.04t).\nHow fast is it growing at the moment the population reaches 2000?',
 '[{"text": "80 per unit time", "feedback": "Correct."},
   {"text": "20 per unit time", "feedback": "That is the growth rate at the START, when the population was 500. It grows as the population does."},
   {"text": "2000 per unit time", "feedback": "That is the population itself at that moment, not the rate at which it is changing."},
   {"text": "0.04 per unit time", "feedback": "That is the growth CONSTANT. It has to be multiplied by the population to give an actual rate."}]'::jsonb,
 0, 'sub-trig-exp-applications');

-- --- questions_mcv4u_u4.sql ---

-- ===========================================================================
-- MCV4U — Unit 4: Geometric Vectors — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Introduction to vectors
--   Lesson 2  Vector addition
--   Lesson 3  Scalar multiplication of vectors
--   Lesson 4  Force, velocity and tension
--   Lesson 5  Resolution of vectors into rectangular components
--
-- Five lessons, six subtopics. Lesson 4 is split into FORCES and VELOCITIES
-- because they fail differently. A force question is lost to the geometry of
-- the triangle; a velocity question is lost to the direction convention,
-- when a student reports a bearing measured from the wrong reference line.
-- Two separate traffic lights say which of those it is.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Four repeat right through the unit:
--
--   * swapping sine and cosine when resolving, which puts the component
--     next to the wrong side of the right triangle
--   * adding magnitudes instead of adding vectors, which is only correct
--     when the two point the same way
--   * measuring a bearing from the wrong line, or in the wrong rotational
--     direction
--   * giving the resultant when the equilibrant was asked for, or the other
--     way round
--
-- Feedback names the mistake and stops there.
--
-- Every magnitude, bearing, component and tension in this file was
-- recomputed independently before delivery; nothing was copied from the
-- source PDFs.
--
-- FIGURES: four, the most of any unit in this bank, and this is the unit
-- that earns them. A vector diagram is not decoration here; the arrangement
-- of the arrows IS the question.
--
--   * Q6 shows a force resolved into components, with no numbers at all,
--     and asks which of sine or cosine gives the horizontal one. The answer
--     is which side sits next to the marked angle.
--   * Q13 shows three vectors closing a triangle head to tail and asks
--     which equation the diagram states. Settled by the arrowheads alone.
--   * Q27 shows a mass on two ropes. RULER TEST: the ropes are labelled 60
--     and 45 degrees but drawn at about 42 and 62, so a student who
--     measures them computes about 95 N, whose nearest option is 98.0 and
--     is wrong.
--   * Q39 shows a box on a ramp. RULER TEST: the ramp is labelled 20
--     degrees and drawn at about 35, so a student who measures it computes
--     about 80 N, whose nearest option is 51.0 and is wrong.
--
-- Both ruler tests are registered in tools/make_figures.py and the script
-- refuses to write either PNG if the measured value ever drifts nearest to
-- the correct option.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file must come last, and must be re-run after any re-run of
-- this one: the delete at the top wipes the figure column with the rest of
-- the row. Student attempts (keyed on course, unit and sort_order) survive
-- the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCV4U' and unit = 'Geometric Vectors';

insert into misconception_labels (tag, label) values
  ('sub-vector-basics',         'What a vector is, and how direction is written'),
  ('sub-vector-addition',       'Adding and subtracting vectors'),
  ('sub-scalar-multiplication', 'Scalar multiplication of vectors'),
  ('sub-resultant-forces',      'Resultant and equilibrant forces'),
  ('sub-velocity-problems',     'Resultant velocity problems'),
  ('sub-vector-components',     'Resolving a vector into components')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the vocabulary, the conventions, and one right triangle.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 1, 'Easy',
 'Which of these is a vector quantity?',
 '[{"text": "10 kg", "feedback": "Mass has size but no direction, so it is a scalar."},
   {"text": "-5 degrees C", "feedback": "The minus sign is part of the temperature scale, not a direction in space. Temperature is a scalar."},
   {"text": "80 km/h west", "feedback": "Correct."},
   {"text": "100 km/h", "feedback": "That is a speed, which is magnitude only. Adding a direction to it would turn it into a velocity."}]'::jsonb,
 2, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 2, 'Easy',
 'A true bearing is measured from which line, and in which rotational direction?',
 '[{"text": "From north, turning clockwise", "feedback": "Correct."},
   {"text": "From north, turning counter-clockwise", "feedback": "The reference line is right but the rotation is not. A compass runs the other way, so a bearing of 090 is east."},
   {"text": "From east, turning clockwise", "feedback": "The rotation is right but the reference line is not. A bearing of zero points north."},
   {"text": "From the horizontal, turning counter-clockwise", "feedback": "That is the OTHER convention, the one used for an angle to the horizontal. A bearing uses the compass."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 3, 'Easy',
 'For any three points A, B and C, what does the vector AB plus the vector BC equal?',
 '[{"text": "The vector CA", "feedback": "The direction is reversed. Head to tail addition starts where the first vector starts and finishes where the second one finishes."},
   {"text": "The vector AB", "feedback": "That is only the first of the two. The second one moves you further along."},
   {"text": "The vector BA", "feedback": "That is the first one reversed. Adding does not send you back where you came from."},
   {"text": "The vector AC", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 4, 'Easy',
 'The vector AB with a minus sign in front of it can also be written how?',
 '[{"text": "AB", "feedback": "The minus sign has to do something. Reversing a vector swaps its start and its finish."},
   {"text": "The magnitude of AB", "feedback": "A magnitude is a number with no direction at all, and it is never negative."},
   {"text": "A plus B", "feedback": "A and B are points, not vectors, so they cannot be added."},
   {"text": "BA", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 5, 'Easy',
 'A vector v has magnitude 6. What is the magnitude of 3v?',
 '[{"text": "9", "feedback": "The 3 was added rather than multiplied."},
   {"text": "2", "feedback": "The magnitude was divided by the scalar. Multiplying by a number bigger than 1 lengthens a vector."},
   {"text": "18", "feedback": "Correct."},
   {"text": "6", "feedback": "The scalar was applied to the direction only. Multiplying by 3 makes the vector three times as long."}]'::jsonb,
 2, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 6, 'Easy',
 E'The diagram shows a force f resolved into its horizontal and vertical components, with the angle marked at the tail.\nWhich expression gives the magnitude of the HORIZONTAL component?',
 '[{"text": "The magnitude of f times sin of the angle", "feedback": "That gives the VERTICAL component. Sine reaches the side across from the marked angle, not the one beside it."},
   {"text": "The magnitude of f times tan of the angle", "feedback": "Tangent compares the two components with each other. Neither of them is the hypotenuse, which is what f is here."},
   {"text": "The magnitude of f divided by cos of the angle", "feedback": "That would make the component LONGER than the force itself, which no component of a right triangle can be."},
   {"text": "The magnitude of f times cos of the angle", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 7, 'Easy',
 E'Kayla pulls a sleigh with a force of 200 N along a rope at 20 degrees to the horizontal.\nWhat is the forward component of that force, to one decimal place?',
 '[{"text": "212.8 N", "feedback": "The cosine ended up underneath. A component can never be larger than the force it came from."},
   {"text": "187.9 N", "feedback": "Correct."},
   {"text": "68.4 N", "feedback": "That is the component that lifts the sleigh. Sine reaches the vertical side; the forward one sits beside the angle."},
   {"text": "200.0 N", "feedback": "That is the whole force along the rope. Only part of it acts in the forward direction."}]'::jsonb,
 1, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 8, 'Easy',
 'What is the equilibrant of a system of forces?',
 '[{"text": "The sum of all the forces acting", "feedback": "That is the RESULTANT. The equilibrant is what you would add to it to reach zero."},
   {"text": "The largest of the forces acting", "feedback": "The size of any one force is beside the point. The equilibrant balances the whole system at once."},
   {"text": "A force equal in magnitude to the resultant and opposite in direction", "feedback": "Correct."},
   {"text": "A force equal to the resultant, in the same direction", "feedback": "That would double the push rather than cancel it. The equilibrant has to oppose."}]'::jsonb,
 2, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 9, 'Easy',
 'Two perpendicular forces of 3 N and 4 N act at the same point. What is the magnitude of the resultant?',
 '[{"text": "1 N", "feedback": "The magnitudes were subtracted. That only works when the two forces point in opposite directions."},
   {"text": "12 N", "feedback": "The magnitudes were multiplied. Vector addition uses the Pythagorean theorem when the two are perpendicular."},
   {"text": "5 N", "feedback": "Correct."},
   {"text": "7 N", "feedback": "The magnitudes were added. That only works when the two forces point in the same direction, and these are at right angles."}]'::jsonb,
 2, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 10, 'Easy',
 'For an aircraft, the air velocity added to the wind velocity gives which quantity?',
 '[{"text": "The wind speed", "feedback": "That is the magnitude of the second of the two, on its own."},
   {"text": "Zero", "feedback": "The two would have to be equal and opposite for that, which would leave the plane hovering."},
   {"text": "The ground velocity", "feedback": "Correct."},
   {"text": "The airspeed", "feedback": "That is the magnitude of the FIRST of the two, before the wind has been taken into account."}]'::jsonb,
 2, 'sub-velocity-problems'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): a bearing conversion, or one resultant built properly.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 11, 'Medium',
 'Write the true bearing 150 degrees as a quadrant bearing.',
 '[{"text": "S30E", "feedback": "Correct."},
   {"text": "N30E", "feedback": "The wrong end of the north-south line was used. A bearing of 150 has already swung past east and into the southern half."},
   {"text": "S30W", "feedback": "The direction is on the wrong side. Turning clockwise from north by 150 degrees ends up east of south."},
   {"text": "N150E", "feedback": "A quadrant bearing has to be between 0 and 90 degrees. This one has to be measured back from the nearer axis."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 12, 'Medium',
 'Write the quadrant bearing N50W as a true bearing.',
 '[{"text": "050 degrees", "feedback": "The turn was made clockwise from north. The W says to turn the other way, which lands in the last quarter of the compass."},
   {"text": "230 degrees", "feedback": "The measurement was made from SOUTH rather than north. The letter in front tells you which axis to start at."},
   {"text": "130 degrees", "feedback": "The angle was subtracted from 180. A true bearing is measured clockwise from north all the way round."},
   {"text": "310 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 13, 'Medium',
 E'The diagram shows three vectors u, v and w drawn on the triangle ABC.\nWhich equation does the diagram state?',
 '[{"text": "u = v + w", "feedback": "That would need v and w to run head to tail from A to B, and they do not. Follow the arrows from A."},
   {"text": "u + v + w = 0", "feedback": "That is what you get when all three run head to tail in a closed loop. Here w runs the other way, from A rather than back to it."},
   {"text": "w = u + v", "feedback": "Correct."},
   {"text": "w = u - v", "feedback": "Subtraction would need one of the arrowheads reversed. Both u and v run head to tail in the same sense around the triangle."}]'::jsonb,
 2, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 14, 'Medium',
 'Two vectors have the same magnitude and point in opposite directions. What is their sum?',
 '[{"text": "A vector of twice the magnitude", "feedback": "That is what happens when they point the SAME way. Opposite directions cancel instead."},
   {"text": "A vector with the same magnitude as either one", "feedback": "Nothing is left over. Placed head to tail they return you exactly to where you started."},
   {"text": "A vector at right angles to both", "feedback": "Adding two vectors keeps you on the line or in the plane they span; it does not create a new direction here."},
   {"text": "The zero vector", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 15, 'Medium',
 'If u = 2v, what is the relationship between u and v?',
 '[{"text": "They are parallel, and u is twice as long in the same direction", "feedback": "Correct."},
   {"text": "They are parallel, and u is twice as long in the opposite direction", "feedback": "The scalar is positive, so the direction is preserved. A negative scalar is what reverses it."},
   {"text": "They are perpendicular", "feedback": "A scalar multiple never changes the line a vector lies along, so the two cannot be at right angles."},
   {"text": "They have the same magnitude", "feedback": "The 2 does exactly what it looks like: it doubles the length."}]'::jsonb,
 0, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 16, 'Medium',
 E'A clown of mass 80 kg is fired horizontally with a force of 2000 N, while gravity pulls him down with a force of 784 N.\nWhat is the magnitude of the resultant force, to one decimal place?',
 '[{"text": "2784.0 N", "feedback": "The two magnitudes were added. That only works when the forces point the same way, and these are at right angles."},
   {"text": "1216.0 N", "feedback": "The two magnitudes were subtracted. That only works when the forces point in opposite directions."},
   {"text": "2000.0 N", "feedback": "Only the horizontal force was reported. Gravity pulls the resultant off the horizontal and makes it longer."},
   {"text": "2148.2 N", "feedback": "Correct."}]'::jsonb,
 3, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 17, 'Medium',
 E'The resultant force on the clown has magnitude 2148.2 N.\nWhat is the equilibrant force?',
 '[{"text": "2148.2 N, directed opposite to the resultant", "feedback": "Correct."},
   {"text": "2148.2 N, in the same direction as the resultant", "feedback": "The magnitude is right but that would push him harder rather than hold him still."},
   {"text": "784 N, directed upward", "feedback": "That balances gravity alone. The horizontal force still has to be opposed as well."},
   {"text": "0 N, because the forces already balance", "feedback": "They do not balance: the resultant is over 2000 N. The equilibrant is what would have to be added to make it zero."}]'::jsonb,
 0, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 18, 'Medium',
 E'A sailboat travels 8 km east and 6 km north.\nWhat is the magnitude and true bearing of the resultant displacement?',
 '[{"text": "14 km at a bearing of 053 degrees", "feedback": "The bearing is right but the two distances were added. They are at right angles, so the Pythagorean theorem applies."},
   {"text": "10 km at a bearing of 143 degrees", "feedback": "The rotation went the wrong way past east. The boat ends up north AND east of where it started, so the bearing is less than 090."},
   {"text": "10 km at a bearing of 053 degrees", "feedback": "Correct."},
   {"text": "10 km at a bearing of 037 degrees", "feedback": "The magnitude is right but the angle was measured from EAST rather than from north. A bearing starts at north and turns clockwise."}]'::jsonb,
 2, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 19, 'Medium',
 E'A tow truck pulls a car with a cable tension of 15000 N at 40 degrees to the horizontal.\nWhat is the vertical component, to the nearest newton?',
 '[{"text": "12586 N", "feedback": "Tangent was used instead of sine. Tangent compares the two components with each other, not either one with the cable."},
   {"text": "9642 N", "feedback": "Correct."},
   {"text": "11491 N", "feedback": "That is the HORIZONTAL component. Cosine reaches the side beside the angle; the vertical one is across from it."},
   {"text": "15000 N", "feedback": "That is the whole tension along the cable. Only part of it acts vertically."}]'::jsonb,
 1, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 20, 'Medium',
 E'Kayla pulls a sleigh with 200 N along a rope at 20 degrees to the horizontal.\nWhat is the component that tends to LIFT the sleigh, to one decimal place?',
 '[{"text": "68.4 N", "feedback": "Correct."},
   {"text": "187.9 N", "feedback": "That is the forward component. Cosine reaches the side beside the angle; the lifting one is across from it."},
   {"text": "72.8 N", "feedback": "Tangent was used instead of sine. Tangent compares the two components with each other, not either one with the rope."},
   {"text": "200.0 N", "feedback": "That is the whole force along the rope. Only part of it acts upward."}]'::jsonb,
 0, 'sub-vector-components'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): a cosine law, a wind triangle, and a hanging mass.
-- Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 21, 'Challenge',
 'Which statement about the vectors AB and BA is correct?',
 '[{"text": "They have equal magnitude but opposite direction, so they are not equal vectors", "feedback": "Correct."},
   {"text": "They are equal vectors, because they join the same two points", "feedback": "Joining the same points is not enough. A vector carries a direction, and these two run opposite ways along the segment."},
   {"text": "They have equal magnitude and the same direction", "feedback": "Reversing the letters reverses the arrow. The lengths match but the directions do not."},
   {"text": "They have different magnitudes", "feedback": "The distance from A to B is the same as from B to A, so the magnitudes are identical. It is the direction that differs."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 22, 'Challenge',
 'Two vectors are EQUIVALENT when which condition holds?',
 '[{"text": "They have the same direction", "feedback": "Same direction with different lengths makes them PARALLEL, which is a weaker condition than equivalent."},
   {"text": "They have the same magnitude and the same direction, wherever they are drawn", "feedback": "Correct."},
   {"text": "They have the same magnitude", "feedback": "Two vectors of the same length can point anywhere. Direction has to match as well."},
   {"text": "They start at the same point", "feedback": "Where a vector is drawn does not matter at all. It can be slid anywhere without changing."}]'::jsonb,
 1, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 23, 'Challenge',
 E'Vectors u and v have magnitudes 5 and 8, with an angle of 60 degrees between them.\nWhat is the magnitude of u + v, to two decimal places?',
 '[{"text": "9.43", "feedback": "The Pythagorean theorem was used on its own. That only works at right angles; at any other angle the cosine law is needed."},
   {"text": "11.36", "feedback": "Correct."},
   {"text": "13.00", "feedback": "The magnitudes were added. That only works when the two point the same way, and there are 60 degrees between them."},
   {"text": "7.00", "feedback": "That is the magnitude of u take away v. The cosine term was subtracted where it should have been added."}]'::jsonb,
 1, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 24, 'Challenge',
 E'Vectors u and v have magnitudes 5 and 8, with an angle of 60 degrees between them.\nWhat is the magnitude of u - v, to two decimal places?',
 '[{"text": "3.00", "feedback": "The magnitudes were subtracted. That only works when the two point the same way, and there are 60 degrees between them."},
   {"text": "9.43", "feedback": "The Pythagorean theorem was used on its own. That only works at right angles; at any other angle the cosine law is needed."},
   {"text": "7.00", "feedback": "Correct."},
   {"text": "11.36", "feedback": "That is the magnitude of the SUM. Subtracting flips the sign of the cosine term."}]'::jsonb,
 2, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 25, 'Challenge',
 'A vector v has magnitude 4. What is the magnitude of -2.5v?',
 '[{"text": "6.5", "feedback": "The scalar was added to the magnitude rather than multiplied by it."},
   {"text": "10", "feedback": "Correct."},
   {"text": "-10", "feedback": "A magnitude is a length, so it can never be negative. The minus sign is carried by the DIRECTION instead."},
   {"text": "1.6", "feedback": "The magnitude was divided by the scalar rather than multiplied by it."}]'::jsonb,
 1, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 26, 'Challenge',
 'A vector v has magnitude 5. Which expression gives a unit vector in the same direction as v?',
 '[{"text": "One fifth of v", "feedback": "Correct."},
   {"text": "Five times v", "feedback": "That makes it five times longer still. A unit vector has a magnitude of exactly 1."},
   {"text": "v itself", "feedback": "Its magnitude is 5, not 1. It has to be scaled down before it counts as a unit vector."},
   {"text": "Negative one fifth of v", "feedback": "The magnitude would be right but the direction would be reversed. The question asks for the SAME direction."}]'::jsonb,
 0, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 27, 'Challenge',
 E'The diagram shows a 20 kg mass suspended from a ceiling by two ropes, at 60 degrees and 45 degrees to the ceiling. Take gravity as 9.8 m/s^2.\nWhat is the tension in the rope at 60 degrees, to one decimal place?',
 '[{"text": "196.0 N", "feedback": "That is the whole weight of the mass. It is shared between the two ropes, and neither one carries all of it."},
   {"text": "143.5 N", "feedback": "Correct."},
   {"text": "101.5 N", "feedback": "That is the tension in the OTHER rope. The steeper rope carries more of the load, so it is the larger of the two."},
   {"text": "98.0 N", "feedback": "The weight was simply halved. The ropes are at different angles, so they do not share the load equally."}]'::jsonb,
 1, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 28, 'Challenge',
 E'A plane flies N40E at an airspeed of 1000 km/h. The ground track is measured as N45E at 1050 km/h.\nWhat is the speed of the wind, to one decimal place?',
 '[{"text": "50.0 km/h", "feedback": "The two speeds were subtracted. That would only be right if the plane and the ground track pointed the same way, and they differ by 5 degrees."},
   {"text": "1050.0 km/h", "feedback": "That is the ground speed. The wind is the DIFFERENCE between the ground velocity and the air velocity, as vectors."},
   {"text": "2050.0 km/h", "feedback": "The two speeds were added. The wind is what you get by subtracting the air velocity from the ground velocity."},
   {"text": "102.4 km/h", "feedback": "Correct."}]'::jsonb,
 3, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 29, 'Challenge',
 E'For that same plane, the wind velocity works out to about 99.7 km/h east and 23.6 km/h south.\nWhat is its true bearing, to the nearest degree?',
 '[{"text": "077 degrees", "feedback": "The angle was measured on the north side of east rather than the south side. A southward component pushes the bearing past 090, not below it."},
   {"text": "103 degrees", "feedback": "Correct."},
   {"text": "013 degrees", "feedback": "The wind has a SOUTHWARD component, so its bearing has to be past 090. This one points into the north-east quarter."},
   {"text": "283 degrees", "feedback": "The direction was reversed. This wind blows towards the east, not away from it."}]'::jsonb,
 1, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 30, 'Challenge',
 E'A box weighing 140 N rests on a ramp inclined at 20 degrees.\nWhat is the component of its weight PERPENDICULAR to the ramp surface, to one decimal place?',
 '[{"text": "51.0 N", "feedback": "Tangent was used instead of cosine. Tangent compares the two components with each other, not either one with the weight."},
   {"text": "131.6 N", "feedback": "Correct."},
   {"text": "47.9 N", "feedback": "That is the component along the SLOPE, the one that would slide the box. Sine and cosine have been swapped."},
   {"text": "140.0 N", "feedback": "That is the whole weight, straight down. Only part of it presses into the ramp surface."}]'::jsonb,
 1, 'sub-vector-components'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): conventions under pressure, and problems where the
-- setup has to be built before anything can be computed. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 31, 'Advanced',
 E'A vector is described as 14 cm at 110 degrees to the horizontal, measured counter-clockwise.\nWhat is its true bearing?',
 '[{"text": "340 degrees", "feedback": "Correct."},
   {"text": "020 degrees", "feedback": "The two angles were subtracted the wrong way round, 110 minus 090 rather than the other way about. Check the sign the subtraction gives before reading it as a bearing."},
   {"text": "110 degrees", "feedback": "The angle was copied straight across. The two conventions use different reference lines and opposite rotations, so they never agree by accident."},
   {"text": "200 degrees", "feedback": "The angle was added to 090 rather than subtracted from it. Counter-clockwise and clockwise pull in opposite directions."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 32, 'Advanced',
 'If u + v + w is the zero vector, which statement must be true?',
 '[{"text": "w equals u + v", "feedback": "That would give twice the sum rather than zero. To cancel a vector you need its opposite."},
   {"text": "w equals u - v", "feedback": "Subtracting v does not undo adding it. Both u and v have to be cancelled together."},
   {"text": "The magnitude of w equals the magnitude of u plus the magnitude of v", "feedback": "That only holds when u and v happen to point the same way. In general the magnitude of their sum is smaller."},
   {"text": "w is the opposite of u + v", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 33, 'Advanced',
 E'Vectors a and b satisfy a = -3b, and b has magnitude 4.\nWhat can be said about a?',
 '[{"text": "Its magnitude is 12 and it points the opposite way to b", "feedback": "Correct."},
   {"text": "Its magnitude is 12 and it points the same way as b", "feedback": "The length is right but the negative sign was ignored. A negative scalar reverses the direction."},
   {"text": "Its magnitude is -12 and it points the opposite way to b", "feedback": "The direction is right but a magnitude is a length, so it can never be negative."},
   {"text": "Its magnitude is 1.33 and it points the opposite way to b", "feedback": "The magnitude was divided by the scalar rather than multiplied by it."}]'::jsonb,
 0, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 34, 'Advanced',
 'For which value of k does kv point in the opposite direction to v with half its magnitude?',
 '[{"text": "k = -2", "feedback": "The direction is right but this makes the vector twice as long rather than half."},
   {"text": "k = 2", "feedback": "Both parts are wrong: this keeps the direction and doubles the length."},
   {"text": "k = -0.5", "feedback": "Correct."},
   {"text": "k = 0.5", "feedback": "The length is right but the direction is not. A positive scalar keeps a vector pointing the same way."}]'::jsonb,
 2, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 35, 'Advanced',
 E'A clown is fired with a horizontal force of 2000 N while gravity pulls him down with 784 N.\nAt what angle below the horizontal does the resultant act, to one decimal place?',
 '[{"text": "68.6 degrees", "feedback": "The two sides were used the other way round in the tangent, which gives the angle measured from the vertical instead."},
   {"text": "20.1 degrees", "feedback": "The RESULTANT was used in the tangent where the horizontal force belongs. Tangent needs the two perpendicular sides, not the hypotenuse."},
   {"text": "45.0 degrees", "feedback": "That would need the two forces to be equal. The horizontal one is well over twice the vertical one."},
   {"text": "21.4 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 36, 'Advanced',
 E'A 20 kg mass hangs from two ropes making 60 degrees and 45 degrees with the ceiling. Take gravity as 9.8 m/s^2.\nWhat is the tension in the rope at 45 degrees, to one decimal place?',
 '[{"text": "138.6 N", "feedback": "The whole weight was divided by root 2, as though this rope alone held the mass at 45 degrees. The other rope carries part of it."},
   {"text": "101.5 N", "feedback": "Correct."},
   {"text": "143.5 N", "feedback": "That is the tension in the OTHER rope. The steeper rope carries more of the load, so this one is the smaller of the two."},
   {"text": "98.0 N", "feedback": "The weight was simply halved. The ropes are at different angles, so they do not share the load equally."}]'::jsonb,
 1, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 37, 'Advanced',
 E'A boat heads due north at 12 km/h across a river whose current runs east at 5 km/h.\nWhat is the resultant velocity of the boat?',
 '[{"text": "13 km/h at a bearing of 337 degrees", "feedback": "The current pushes the boat EAST of north, so the bearing is a little more than zero, not a little less."},
   {"text": "13 km/h at a bearing of 023 degrees", "feedback": "Correct."},
   {"text": "13 km/h at a bearing of 067 degrees", "feedback": "The magnitude is right but the angle was measured from EAST rather than from north."},
   {"text": "17 km/h at a bearing of 023 degrees", "feedback": "The bearing is right but the two speeds were added. They are at right angles, so the Pythagorean theorem applies."}]'::jsonb,
 1, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 38, 'Advanced',
 E'The same boat heads due north at 12 km/h across a river 600 m wide, with the current running east at 5 km/h.\nHow long does the crossing take, and does the current change that time?',
 '[{"text": "2.8 minutes, because the resultant speed is higher", "feedback": "The resultant speed is higher, but the extra speed is all sideways. Only the northward part carries the boat across."},
   {"text": "3.0 minutes, but the current makes it longer", "feedback": "The current runs across the crossing rather than against it, so it has been treated as something the boat must fight. Look at which component of the velocity carries the boat toward the far bank."},
   {"text": "7.2 minutes, because the current sets the pace", "feedback": "The width was divided by the CURRENT speed. The boat crosses at its own northward speed."},
   {"text": "3.0 minutes, and the current does not change it", "feedback": "Correct."}]'::jsonb,
 3, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 39, 'Advanced',
 E'The diagram shows a box weighing 140 N at rest on a ramp, with the incline marked.\nWhat is the component of its weight acting DOWN the slope, to one decimal place?',
 '[{"text": "47.9 N", "feedback": "Correct."},
   {"text": "131.6 N", "feedback": "That is the component pressing INTO the ramp. Sine and cosine have been swapped."},
   {"text": "140.0 N", "feedback": "That is the whole weight, straight down. Only part of it acts along the slope."},
   {"text": "51.0 N", "feedback": "Tangent was used instead of sine. Tangent compares the two components with each other, not either one with the weight."}]'::jsonb,
 0, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 40, 'Advanced',
 E'A force has a horizontal component of 120 N and a vertical component of 90 N.\nWhat is its magnitude and its angle to the horizontal?',
 '[{"text": "210 N at 36.9 degrees", "feedback": "The angle is right but the two components were added. They are at right angles, so the Pythagorean theorem applies."},
   {"text": "150 N at 0.8 degrees", "feedback": "The ratio of the components was reported instead of the angle. An inverse tangent still has to be taken."},
   {"text": "150 N at 36.9 degrees", "feedback": "Correct."},
   {"text": "150 N at 53.1 degrees", "feedback": "The magnitude is right but the two components were used the other way round in the tangent, giving the angle from the vertical."}]'::jsonb,
 2, 'sub-vector-components');

-- --- questions_mcv4u_u5.sql ---

-- ===========================================================================
-- MCV4U — Unit 5: Algebraic Vectors — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Cartesian (algebraic) vectors
--   Lesson 2  The dot product
--   Lesson 3  Applications of the dot product
--   Lesson 4  Vectors in 3-space
--   Lesson 5  The cross product
--   Lesson 6  Applications of the dot and cross products
--
-- Six lessons, six subtopics, one for each. Splitting each product from its
-- applications matters more here than anywhere else in the course. A student
-- can compute a cross product flawlessly and still not know that its
-- magnitude is an area; a student can know that fact and still lose every
-- mark to a sign in the middle component. Those are different lessons, and
-- the dashboard has to be able to tell them apart.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Five repeat all through the unit:
--
--   * getting a vector where a scalar belongs, or the reverse — the dot
--     product returns a number and the cross product returns a vector
--   * reversing the order of a cross product, which flips every component
--   * the sign of the MIDDLE component of a cross product, which runs the
--     opposite way to the other two
--   * subtracting position vectors the wrong way round when building the
--     vector between two points
--   * forgetting to convert centimetres to metres before computing a torque
--
-- Feedback names the mistake and stops there.
--
-- Every component, magnitude, angle, area, projection and volume in this
-- file was recomputed independently with sympy before delivery; nothing was
-- copied from the source PDFs.
--
-- FIGURES: three. This is an algebraic unit and most of it needs no picture
-- at all, but three questions are about an arrangement rather than an
-- arithmetic.
--
--   * Q25 shows a projection: two vectors from a common tail, a dashed
--     perpendicular, and the piece of the line along b picked out. No
--     numbers. The picture is what makes clear the result lies along b.
--   * Q28 shows two vectors in the plane of the page and asks which way
--     their cross product points. No numbers, and nothing on the figure
--     names a direction.
--   * Q39 shows a wrench. RULER TEST: the angle is labelled 80 degrees and
--     drawn at about 30, so a student who measures it computes about 6.0
--     N m, whose nearest option is 2.08 and is wrong. Sine is flat near 90
--     degrees, so the usual 15 to 20 degrees of distortion would not have
--     been enough — anything above about 55 degrees rounds back onto the
--     correct answer, and the drawn angle had to go well below that.
--
-- Rejected: a 3-space axis diagram with a vector drawn on it. The
-- components are countable off the axes, which is the whole question.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file must come last, and must be re-run after any re-run of
-- this one: the delete at the top wipes the figure column with the rest of
-- the row. Student attempts (keyed on course, unit and sort_order) survive
-- the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCV4U' and unit = 'Algebraic Vectors';

insert into misconception_labels (tag, label) values
  ('sub-cartesian-vectors',  'Cartesian vectors and magnitude'),
  ('sub-dot-product',        'The dot product'),
  ('sub-dot-applications',   'Applications of the dot product'),
  ('sub-vectors-3space',     'Vectors in three dimensions'),
  ('sub-cross-product',      'The cross product'),
  ('sub-cross-applications', 'Applications of the cross product')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): what each object IS, and one computation of each kind.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 1, 'Easy',
 'P is the point (2, -3) and Q is the point (7, 1). What is the vector PQ in component form?',
 '[{"text": "[-5, -4]", "feedback": "The subtraction went the wrong way round. That is the vector QP, which points back the other way."},
   {"text": "[9, -2]", "feedback": "The two points were added. A vector between points comes from subtracting the start from the finish."},
   {"text": "[5, -4]", "feedback": "The second component was subtracted the other way round from the first. Both of them have to run from the start point to the finish point."},
   {"text": "[5, 4]", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 2, 'Easy',
 'What is the magnitude of the vector [3, -4]?',
 '[{"text": "5", "feedback": "Correct."},
   {"text": "-1", "feedback": "The components were added. A magnitude comes from squaring each one first, which removes the signs."},
   {"text": "7", "feedback": "The absolute values were added. That is the distance you would walk in two straight legs, not the direct distance."},
   {"text": "25", "feedback": "The square root was never taken. That is the SQUARE of the magnitude."}]'::jsonb,
 0, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 3, 'Easy',
 'What is the dot product of [3, -4] and [2, 5]?',
 '[{"text": "-14", "feedback": "Correct."},
   {"text": "14", "feedback": "The signs were stripped off the two products and the smaller size taken from the larger. Each product keeps the sign of the components it came from."},
   {"text": "[6, -20]", "feedback": "The two products were left as a pair. A dot product adds them together into a single number."},
   {"text": "26", "feedback": "The two products were subtracted rather than added."}]'::jsonb,
 0, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 4, 'Easy',
 'What kind of quantity is a dot product?',
 '[{"text": "An angle", "feedback": "An angle can be recovered FROM a dot product, but only after dividing by both magnitudes and taking an inverse cosine."},
   {"text": "A scalar, a single number with no direction", "feedback": "Correct."},
   {"text": "A vector perpendicular to both", "feedback": "That is the CROSS product. The dot product collapses everything into a single number."},
   {"text": "A vector in the same plane as both", "feedback": "There is no vector at the end of a dot product at all."}]'::jsonb,
 1, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 5, 'Easy',
 'Two non-zero vectors have a dot product of zero. What does that tell you?',
 '[{"text": "They point in opposite directions", "feedback": "Opposite vectors give a negative dot product, as large in size as it can be, rather than zero."},
   {"text": "They are perpendicular to each other", "feedback": "Correct."},
   {"text": "They are parallel", "feedback": "Parallel vectors give the LARGEST possible dot product for their lengths, not zero. It is the CROSS product that vanishes when they are parallel."},
   {"text": "They are equal", "feedback": "Equal vectors have a dot product equal to the square of their magnitude, which is positive."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 6, 'Easy',
 'What is the magnitude of the vector [2, -3, 6]?',
 '[{"text": "5", "feedback": "The components were added. A magnitude squares each one first, which removes the signs."},
   {"text": "11", "feedback": "The absolute values were added. That is not the direct distance from the origin."},
   {"text": "49", "feedback": "The square root was never taken. That is the SQUARE of the magnitude."},
   {"text": "7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 7, 'Easy',
 'In three dimensions, the vector [1, 0, 0] is usually written with which single letter?',
 '[{"text": "j", "feedback": "That is the unit vector along the y-axis, which is [0, 1, 0]."},
   {"text": "k", "feedback": "That is the unit vector along the z-axis, which is [0, 0, 1]."},
   {"text": "The zero vector", "feedback": "The zero vector has every component zero. This one has a length of 1."},
   {"text": "i", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 8, 'Easy',
 'What kind of quantity is a cross product?',
 '[{"text": "A vector in the same plane as both of the originals", "feedback": "It leaves that plane entirely, at right angles to it. That is what makes it useful for finding a normal."},
   {"text": "An angle", "feedback": "An angle is hidden inside its magnitude, but the product itself is a vector."},
   {"text": "A vector perpendicular to both of the original vectors", "feedback": "Correct."},
   {"text": "A scalar", "feedback": "That is the DOT product. The cross product returns a vector, which is why it only exists in three dimensions."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 9, 'Easy',
 'What is i cross j?',
 '[{"text": "The zero vector", "feedback": "A cross product vanishes only when the two vectors are collinear, and these two are at right angles."},
   {"text": "k", "feedback": "Correct."},
   {"text": "Negative k", "feedback": "The order was reversed. That is j cross i, which points the opposite way."},
   {"text": "i", "feedback": "The result has to be perpendicular to BOTH of the originals, and this one is not perpendicular to itself."}]'::jsonb,
 1, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 10, 'Easy',
 'What does the magnitude of u cross v measure?',
 '[{"text": "The area of the triangle defined by u and v", "feedback": "That is HALF of it. The parallelogram is made of two such triangles."},
   {"text": "The perimeter of the parallelogram defined by u and v", "feedback": "A perimeter is a sum of lengths, and it would not vanish when the two vectors line up. This quantity does."},
   {"text": "The volume of the box built on u and v", "feedback": "A volume needs three vectors. Two of them span a flat region."},
   {"text": "The area of the parallelogram defined by u and v", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): one full computation of each product, and what it means.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 11, 'Medium',
 'Compute [3, -4] + 2[-1, 6].',
 '[{"text": "[4, 4]", "feedback": "The scalar was applied to the first vector as well as the second."},
   {"text": "[1, 8]", "feedback": "Correct."},
   {"text": "[1, -8]", "feedback": "The negative sign from the first vector was carried down into the second component instead of being added in."},
   {"text": "[2, 2]", "feedback": "The scalar 2 was never applied. It multiplies BOTH components of the second vector."}]'::jsonb,
 1, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 12, 'Medium',
 'What is the unit vector in the direction of [3, -4]?',
 '[{"text": "[0.6, -0.8]", "feedback": "Correct."},
   {"text": "[3, -4]", "feedback": "Its magnitude is 5, not 1. It has to be divided by that magnitude first."},
   {"text": "[-0.6, 0.8]", "feedback": "The magnitude is right but the direction is reversed. Dividing by a positive length cannot flip a vector."},
   {"text": "[0.8, -0.6]", "feedback": "The two components were swapped. Each one is divided by the magnitude in place."}]'::jsonb,
 0, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 13, 'Medium',
 'What does the dot product of a vector u with itself equal?',
 '[{"text": "The magnitude of u", "feedback": "The square root was taken one step too early. Each component is squared and the results are added, with no root at the end."},
   {"text": "Twice the magnitude of u", "feedback": "The dot product multiplies corresponding components; it does not double anything."},
   {"text": "Zero", "feedback": "That would need u to be perpendicular to itself, which only the zero vector manages."},
   {"text": "The square of the magnitude of u", "feedback": "Correct."}]'::jsonb,
 3, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 14, 'Medium',
 'What is the angle between [4, 5, 2] and [3, 2, 7], to one decimal place?',
 '[{"text": "133.0 degrees", "feedback": "A sign was lost somewhere. The dot product here is positive, so the angle has to be acute."},
   {"text": "36.0 degrees", "feedback": "That is the dot product itself, read as though it were already an angle. It still has to be divided by both magnitudes."},
   {"text": "47.0 degrees", "feedback": "Correct."},
   {"text": "43.0 degrees", "feedback": "The inverse SINE was taken instead of the inverse cosine, which gives the complement of the angle wanted."}]'::jsonb,
 2, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 15, 'Medium',
 E'A force F = [300, 700, 500] newtons moves an object through a displacement d = [3, 1, 12] metres.\nHow much work is done?',
 '[{"text": "7600 J", "feedback": "Correct."},
   {"text": "6000 J", "feedback": "Only the third pair of components was multiplied. All three pairs contribute to the work."},
   {"text": "900 J", "feedback": "Only the first pair of components was multiplied."},
   {"text": "1500 J", "feedback": "Only the force components were added up. The displacement has to be paired with them component by component."}]'::jsonb,
 0, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 16, 'Medium',
 'What is the distance between the points (1, 2, 3) and (4, 6, 3)?',
 '[{"text": "25", "feedback": "The square root was never taken."},
   {"text": "3", "feedback": "Only the x-difference was used. The y-coordinates differ as well."},
   {"text": "5", "feedback": "Correct."},
   {"text": "7", "feedback": "The differences were added rather than squared and rooted."}]'::jsonb,
 2, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 17, 'Medium',
 'If p = [-1, 3, 2] and q = [2, -5, 6], what is p cross q?',
 '[{"text": "[28, -10, -1]", "feedback": "The middle component came out with the wrong sign. It is the one built the opposite way round from the other two."},
   {"text": "[-2, -15, 12]", "feedback": "The components were multiplied straight across. A cross product pairs each component with the OTHER two."},
   {"text": "[28, 10, -1]", "feedback": "Correct."},
   {"text": "[-28, -10, 1]", "feedback": "The order was reversed. That is q cross p, which points the opposite way."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 18, 'Medium',
 'Two non-zero vectors have a cross product equal to the zero vector. What does that tell you?',
 '[{"text": "They are equal", "feedback": "Equal vectors do give a zero cross product, but so do many pairs that are not equal. The condition is weaker than that."},
   {"text": "They are both unit vectors", "feedback": "Length has nothing to do with it. Two unit vectors at any angle other than zero or 180 degrees give a non-zero cross product."},
   {"text": "They are collinear, lying along the same line", "feedback": "Correct."},
   {"text": "They are perpendicular", "feedback": "Perpendicular vectors give the LARGEST possible cross product for their lengths. It is the DOT product that vanishes at right angles."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 19, 'Medium',
 'What is the area of the parallelogram defined by u = [4, 5, 2] and v = [3, 2, 7], to two decimal places?',
 '[{"text": "19.33", "feedback": "That is the area of the TRIANGLE. The parallelogram is twice as big."},
   {"text": "1494.00", "feedback": "The square root was never taken. That is the sum of the squares of the components of the cross product."},
   {"text": "36.00", "feedback": "That is the DOT product of the two vectors. Area comes from the cross product."},
   {"text": "38.65", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 20, 'Medium',
 'What is the area of the TRIANGLE defined by u = [4, 5, 2] and v = [3, 2, 7], to two decimal places?',
 '[{"text": "9.66", "feedback": "The parallelogram area was quartered. Halving it once is enough."},
   {"text": "19.33", "feedback": "Correct."},
   {"text": "38.65", "feedback": "That is the area of the parallelogram. A triangle is half of it."},
   {"text": "77.30", "feedback": "The parallelogram area was doubled rather than halved."}]'::jsonb,
 1, 'sub-cross-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): solve for a component, or read a picture. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 21, 'Challenge',
 'For what value of k are [2, k] and [6, 9] parallel?',
 '[{"text": "k = 27", "feedback": "The scale factor between the two vectors was applied in the wrong direction. It carries the first vector onto the second, and here you need to come back the other way."},
   {"text": "k = 4.5", "feedback": "The second component of one vector was divided by the FIRST component of the other. Matching components have to be compared with matching components."},
   {"text": "k = 3", "feedback": "Correct."},
   {"text": "k = -3", "feedback": "A sign was flipped. Both given vectors have positive first components, so the scalar linking them is positive."}]'::jsonb,
 2, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 22, 'Challenge',
 E'A vector has magnitude 10 and makes an angle of 30 degrees with the positive x-axis.\nWhat is it in component form, to two decimal places?',
 '[{"text": "[8.66, 5.00]", "feedback": "Correct."},
   {"text": "[5.00, 8.66]", "feedback": "The two components were swapped. Cosine reaches the side beside the angle, which is the horizontal one."},
   {"text": "[10.00, 30.00]", "feedback": "The magnitude and the angle were written down as though they were components. They still have to be resolved."},
   {"text": "[5.77, 5.00]", "feedback": "Tangent was used for the first component. Tangent compares the two components with each other, not either one with the magnitude."}]'::jsonb,
 0, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 23, 'Challenge',
 'For what value of k are [2, k, 3] and [4, -1, 2] perpendicular?',
 '[{"text": "k = 14", "feedback": "Correct."},
   {"text": "k = -14", "feedback": "A sign was flipped when isolating. The middle term of the dot product is negative k, so moving it across makes k positive."},
   {"text": "k = 2", "feedback": "The sign of the third term was flipped, so that product was taken away instead of added."},
   {"text": "k = -2", "feedback": "Two signs went astray at once: the middle term was taken as positive k and the third product was subtracted."}]'::jsonb,
 0, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 24, 'Challenge',
 E'Vectors u and v have magnitudes 5 and 8, with an angle of 60 degrees between them.\nWhat is u dot v?',
 '[{"text": "34.64", "feedback": "Sine was used where cosine belongs. Sine is what appears in the magnitude of the CROSS product."},
   {"text": "40", "feedback": "The two magnitudes were multiplied and the angle was ignored. That is the answer only when the two point the same way."},
   {"text": "3", "feedback": "The magnitudes were subtracted. A dot product multiplies them and then scales by the cosine."},
   {"text": "20", "feedback": "Correct."}]'::jsonb,
 3, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 25, 'Challenge',
 E'The diagram shows the projection of a onto b: the piece of the line carrying b that reaches the foot of the perpendicular from the head of a.\nWhich formula produces that piece?',
 '[{"text": "(a dot b divided by a dot a) times a", "feedback": "That produces a piece lying along A, not along b. The picture shows the result on the other line."},
   {"text": "(a dot b) times b", "feedback": "The scaling is wrong. Without dividing by b dot b the result grows with the SQUARE of the length of b."},
   {"text": "a dot b divided by the magnitude of b", "feedback": "That is a number, the length of the projection. The picture shows a vector, so a direction has to be attached to it."},
   {"text": "(a dot b divided by b dot b) times b", "feedback": "Correct."}]'::jsonb,
 3, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 26, 'Challenge',
 E'Let v = [4, 2, 7] and u = [6, 3, 8].\nWhat is the MAGNITUDE of the projection of v onto u, to three decimal places?',
 '[{"text": "4.734", "feedback": "That is the FIRST COMPONENT of the projection vector. Its magnitude uses all three components."},
   {"text": "8.237", "feedback": "Correct."},
   {"text": "10.440", "feedback": "That is the magnitude of u itself. The projection is shorter, because only part of v lies along it."},
   {"text": "86.000", "feedback": "That is the dot product of the two vectors, before any dividing has been done."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 27, 'Challenge',
 'What is the vector from the point (1, -2, 4) to the point (-3, 0, 5)?',
 '[{"text": "[-2, -2, 9]", "feedback": "The two points were added. A vector between points comes from subtracting the start from the finish."},
   {"text": "[-4, -2, 1]", "feedback": "The middle component kept the sign it carried in the starting point instead of being subtracted at all."},
   {"text": "[-4, 2, 1]", "feedback": "Correct."},
   {"text": "[4, -2, -1]", "feedback": "The subtraction went the wrong way round. That vector points from the second point back to the first."}]'::jsonb,
 2, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 28, 'Challenge',
 E'The diagram shows two vectors a and b lying in the plane of the page, with b turned counter-clockwise from a.\nIn which direction does a cross b point?',
 '[{"text": "Along a", "feedback": "A cross product is perpendicular to BOTH of the vectors it came from, so it cannot lie along either one."},
   {"text": "Along b", "feedback": "A cross product is perpendicular to BOTH of the vectors it came from, so it cannot lie along either one."},
   {"text": "Out of the page", "feedback": "Correct."},
   {"text": "Into the page", "feedback": "That is the direction of b cross a. Point your fingers along a and curl them towards b, and the thumb goes the other way."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 29, 'Challenge',
 'Evaluate the triple scalar product (u cross v) dot w for u = [4, 3, 1], v = [2, 5, 6] and w = [10, -3, -14].',
 '[{"text": "0", "feedback": "Correct."},
   {"text": "130", "feedback": "Only the first pair of components was multiplied in the final dot product. All three pairs contribute."},
   {"text": "-196", "feedback": "Only the third pair of components was multiplied in the final dot product."},
   {"text": "66", "feedback": "Only the middle pair of components was multiplied in the final dot product."}]'::jsonb,
 0, 'sub-cross-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 30, 'Challenge',
 'Three non-zero vectors have a triple scalar product of zero. What does that tell you?',
 '[{"text": "They are mutually perpendicular", "feedback": "Three mutually perpendicular vectors build the largest possible box for their lengths, so their triple scalar product is as far from zero as it gets."},
   {"text": "They are all unit vectors", "feedback": "Length has nothing to do with it. The quantity measures a volume, and a volume can vanish at any length."},
   {"text": "Two of them are equal", "feedback": "That would force it to zero, but so would many arrangements where no two are equal. The condition is weaker than that."},
   {"text": "They all lie in the same plane", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): build a vector to order, or carry a product through an
-- application with units attached. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 31, 'Advanced',
 E'Let u = [2, -1] and v = [3, 4].\nWrite w = [12, 5] in the form a times u plus b times v.',
 '[{"text": "w = -3u + 2v", "feedback": "A sign was flipped on the first coefficient. That would make the first component zero."},
   {"text": "w = 3u + 2v", "feedback": "Correct."},
   {"text": "w = 2u + 3v", "feedback": "The two coefficients were swapped. Substitute this back and the first component comes out as 13, not 12."},
   {"text": "w = 3u - 2v", "feedback": "A sign was flipped. With a minus here the second component comes out as negative 11."}]'::jsonb,
 1, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 32, 'Advanced',
 'What is the angle between [1, 1, 0] and [0, 1, 1]?',
 '[{"text": "60 degrees", "feedback": "Correct."},
   {"text": "45 degrees", "feedback": "Only one of the two magnitudes was divided out. Both vectors have length root 2, and the dot product has to be divided by each of them in turn."},
   {"text": "90 degrees", "feedback": "The dot product is 1, not zero, so the two are not perpendicular. They share a component."},
   {"text": "120 degrees", "feedback": "A sign was lost. The dot product here is positive, so the angle has to be acute."}]'::jsonb,
 0, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 33, 'Advanced',
 E'A force F = [300, 700, 500] newtons moves an object through d = [3, 1, 12] metres. Gravity acts along the negative z-axis.\nHow much work is done against gravity?',
 '[{"text": "500 J", "feedback": "That is the vertical component of the force on its own. It still has to be multiplied by the vertical distance moved."},
   {"text": "6000 J", "feedback": "Correct."},
   {"text": "7600 J", "feedback": "That is the total work in the direction of travel. Work against gravity uses only the VERTICAL components."},
   {"text": "1600 J", "feedback": "The two horizontal pairs were used and the vertical one was left out. It is the only pair that matters here."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 34, 'Advanced',
 'The dot product of a with b comes out negative. What does that say about the projection of a onto b?',
 '[{"text": "It is longer than a", "feedback": "A projection is never longer than the vector being projected, whatever the sign of the dot product."},
   {"text": "It points in the opposite direction to b", "feedback": "Correct."},
   {"text": "It is the zero vector", "feedback": "That happens when the dot product is exactly zero. A negative value still leaves something to project."},
   {"text": "The two vectors are perpendicular", "feedback": "Perpendicular vectors give a dot product of exactly zero, not a negative one."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 35, 'Advanced',
 'What is the unit vector in the direction of [1, 2, 2]?',
 '[{"text": "[1/3, 2/3, 2/3]", "feedback": "Correct."},
   {"text": "[1, 2, 2]", "feedback": "Its magnitude is 3, not 1. It has to be divided by that magnitude first."},
   {"text": "[1/9, 2/9, 2/9]", "feedback": "The components were divided by the SQUARE of the magnitude. The square root was never taken."},
   {"text": "[1/5, 2/5, 2/5]", "feedback": "The components were added to get the divisor. A magnitude squares each one first."}]'::jsonb,
 0, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 36, 'Advanced',
 'What vector has magnitude 6 and points in the direction of [1, 2, 2]?',
 '[{"text": "[2, 4, 4]", "feedback": "Correct."},
   {"text": "[6, 12, 12]", "feedback": "The original was multiplied by 6 without being reduced to unit length first. Its magnitude is already 3, so this one has magnitude 18."},
   {"text": "[3, 6, 6]", "feedback": "The original was tripled instead. That gives a magnitude of 9."},
   {"text": "[1, 2, 2]", "feedback": "That is the original, whose magnitude is 3 rather than 6."}]'::jsonb,
 0, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 37, 'Advanced',
 E'Vectors u and v have magnitudes 30 and 20, with an angle of 40 degrees between them.\nWhat is the magnitude of u cross v, to two decimal places?',
 '[{"text": "459.63", "feedback": "Cosine was used where sine belongs. Cosine is what appears in the DOT product."},
   {"text": "600.00", "feedback": "The two magnitudes were multiplied and the angle was ignored. That is the answer only when the two are perpendicular."},
   {"text": "192.84", "feedback": "The result was halved, as though a triangle had been asked for. The magnitude of a cross product is the whole parallelogram."},
   {"text": "385.67", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 38, 'Advanced',
 'How are u cross v and v cross u related?',
 '[{"text": "They are perpendicular to each other", "feedback": "Both are perpendicular to the same plane, so they lie on the same line rather than at right angles."},
   {"text": "One is a vector and the other is a scalar", "feedback": "Both are vectors. It is the dot product that returns a number."},
   {"text": "Each one is exactly the opposite of the other", "feedback": "Correct."},
   {"text": "They are equal", "feedback": "Order matters for a cross product, unlike a dot product. Swapping the two flips the result."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 39, 'Advanced',
 E'The diagram shows a wrench. A force of 60 N is applied at 80 degrees to the handle, 20 cm from the centre of the bolt.\nWhat is the magnitude of the torque, to two decimal places?',
 '[{"text": "1181.77 N m", "feedback": "The 20 cm was never converted to metres. Torque is measured in newton metres."},
   {"text": "11.82 N m", "feedback": "Correct."},
   {"text": "12.00 N m", "feedback": "The angle was ignored, as though the force were exactly perpendicular to the handle. At 80 degrees a little of it is wasted along the handle."},
   {"text": "2.08 N m", "feedback": "Cosine was used where sine belongs. Only the part of the force ACROSS the handle turns the bolt."}]'::jsonb,
 1, 'sub-cross-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 40, 'Advanced',
 'What is the volume of the parallelepiped defined by a = [6, 3, -2], b = [-4, 6, 9] and c = [3, 3, -11]?',
 '[{"text": "1098", "feedback": "The result was doubled. That step belongs to going from a triangle to a parallelogram, not here."},
   {"text": "183", "feedback": "The result was divided by 3, as though a pyramid had been asked for. The parallelepiped is the whole box."},
   {"text": "549", "feedback": "Correct."},
   {"text": "-549", "feedback": "A volume is never negative. The triple scalar product can come out either way, and its absolute value is taken."}]'::jsonb,
 2, 'sub-cross-applications');

-- --- questions_mcv4u_u6.sql ---

-- ===========================================================================
-- MCV4U — Unit 6: Lines and Planes — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Vector equation of a line in 2-space
--   Lesson 2  Vector equation of a line in 3-space
--   Lesson 3  Vector equation of a plane
--   Lesson 4  Scalar equation of a plane
--   Lesson 5  Intersections of lines in 2-space and 3-space
--   Lesson 6  Intersections of lines and planes
--   Lesson 7  Intersections of planes
--
-- Seven lessons, six subtopics: the two intersection lessons that involve a
-- plane are counted together, because a student who can handle two planes
-- can almost always handle a line and a plane, and splitting them would put
-- fewer than five questions in each.
--
-- The split that matters most on the dashboard is the DIRECTION vector
-- against the NORMAL vector. Both are triples of numbers pulled out of an
-- equation, both are written in square brackets, and a student who has
-- fused the two will confidently read the coefficients of a plane as a
-- direction lying in it. Every question in this unit that can be lost that
-- way offers exactly that answer as a distractor.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Four repeat all through the unit:
--
--   * using a position vector to a point ON a line as a direction vector
--     FOR the line
--   * reading the coefficients of a scalar equation as a direction rather
--     than as a normal
--   * checking one coordinate against a parametric equation and stopping,
--     when it is the AGREEMENT of the parameter across every coordinate
--     that decides whether a point is on the line
--   * concluding that two lines in 3-space with non-parallel directions
--     must therefore meet
--
-- Feedback names the mistake and stops there.
--
-- Every direction vector, normal, scalar equation, intersection and
-- distance in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- FIGURES: one, on question 1.
--
--   * Q1 shows a line, the origin, and four labelled vectors, exactly one
--     of which lies along the line. This is the picture the whole vector
--     equation of a line comes from, and it is where the position-vector
--     confusion is born: two of the other three reach points that are ON
--     the line, which makes them look like candidates. No coordinates, no
--     grid, nothing to count.
--
-- Rejected: the three-dimensional renders of intersecting planes. Those
-- pictures show the answer — a drawing of two planes crossing in a line is
-- a drawing of the words "they cross in a line". Every intersection
-- question here is asked from the equations.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file must come last, and must be re-run after any re-run of
-- this one: the delete at the top wipes the figure column with the rest of
-- the row. Student attempts (keyed on course, unit and sort_order) survive
-- the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCV4U' and unit = 'Lines and Planes';

insert into misconception_labels (tag, label) values
  ('sub-lines-2space',        'Equations of lines in 2-space'),
  ('sub-lines-3space',        'Equations of lines in 3-space'),
  ('sub-planes-vector',       'Vector equation of a plane'),
  ('sub-planes-scalar',       'Scalar equation of a plane'),
  ('sub-line-intersections',  'Intersections of lines'),
  ('sub-plane-intersections', 'Intersections of planes')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): what each piece of an equation IS, and one substitution.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 1, 'Easy',
 E'The diagram shows a line L, the origin O, and four vectors.\nWhich one is a DIRECTION vector for L?',
 '[{"text": "p", "feedback": "That runs from the origin to a point of L, so it is the starting position in the equation rather than the direction term."},
   {"text": "q", "feedback": "Its tip landing on L does not make it parallel to L. A direction runs between two points of the line, not out to one of them."},
   {"text": "s", "feedback": "That one does not even touch the line. It is parallel to nothing in the picture."},
   {"text": "r", "feedback": "Correct."}]'::jsonb,
 3, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 2, 'Easy',
 'A line passes through A(1, 4) and B(3, 1). What is a direction vector for it?',
 '[{"text": "[1, 4]", "feedback": "That is the position vector to A. A point on the line is not the same as a direction along it."},
   {"text": "[2, -3]", "feedback": "Correct."},
   {"text": "[4, 5]", "feedback": "The two points were added. A direction comes from subtracting one from the other."},
   {"text": "[2, 3]", "feedback": "The second component lost its sign. Going from A to B the y-value drops from 4 to 1."}]'::jsonb,
 1, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 3, 'Easy',
 'Why does a line in 3-space have no single scalar equation?',
 '[{"text": "Because a single scalar equation in three variables describes a plane", "feedback": "Correct."},
   {"text": "Because a line in 3-space has no normal vector to build such an equation from", "feedback": "It has infinitely many normals, which is part of the difficulty; the trouble is that one equation is not restrictive enough."},
   {"text": "Because a line in 3-space needs a parameter to pin a point down", "feedback": "It does use one, but that is a consequence rather than the reason. One equation in three variables simply leaves too much freedom."},
   {"text": "Because a line in 3-space is not the graph of a function", "feedback": "Being a function has nothing to do with it. A line in 2-space is often not a function either and still has a scalar equation."}]'::jsonb,
 0, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 4, 'Easy',
 'For the line [x, y, z] = [1, 0, 3] + t[2, -1, 5], which point is on the line when t = 2?',
 '[{"text": "(2, -1, 5)", "feedback": "That is the direction vector on its own. The starting point still has to be added."},
   {"text": "(1, 0, 3)", "feedback": "That is the point at t = 0. Two lots of the direction still have to be added to it."},
   {"text": "(5, -2, 13)", "feedback": "Correct."},
   {"text": "(3, -1, 8)", "feedback": "That is the point at t = 1. The parameter has to multiply every component of the direction."}]'::jsonb,
 2, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 5, 'Easy',
 'How many direction vectors does the vector equation of a plane need?',
 '[{"text": "One", "feedback": "One direction and a point gives a LINE. A plane needs a second, independent way to move."},
   {"text": "Three", "feedback": "Three directions in three-space generally fill all of space rather than a plane."},
   {"text": "None, only a normal vector is needed", "feedback": "That is enough for the SCALAR equation. The vector equation is built from directions instead."},
   {"text": "Two, and they must not be collinear", "feedback": "Correct."}]'::jsonb,
 3, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 6, 'Easy',
 'In the plane equation Ax + By + Cz + D = 0, what does [A, B, C] represent?',
 '[{"text": "One of the points on the plane", "feedback": "Nothing in the coefficients names a point. D shifts the plane, but a point has to be found by substituting."},
   {"text": "The position vector of the origin", "feedback": "That is the zero vector, which has no direction at all."},
   {"text": "A normal vector to the plane", "feedback": "Correct."},
   {"text": "A direction vector lying in the plane", "feedback": "It is the exact opposite: it is perpendicular to every direction lying in the plane. This is the single most common mix-up in the unit."}]'::jsonb,
 2, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 7, 'Easy',
 'What is a normal vector to the plane 3x - 2y + z - 7 = 0?',
 '[{"text": "[3, -2, 1]", "feedback": "Correct."},
   {"text": "[3, -2, -7]", "feedback": "The constant term was collected as a component. Only the three coefficients of x, y and z make up the normal."},
   {"text": "[3, 2, 1]", "feedback": "The sign on the middle component was lost. It has to be read straight off the equation."},
   {"text": "[1, -2, 3]", "feedback": "The first and third components were swapped. They belong to x and z in the order they appear."}]'::jsonb,
 0, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 8, 'Easy',
 'Two lines in 2-space have direction vectors that are not parallel. In how many points do they intersect?',
 '[{"text": "Infinitely many", "feedback": "That would make them the same line, which would need their directions to be parallel."},
   {"text": "Two", "feedback": "Two straight lines that meet twice would have to be the same line. Straight lines cross at most once."},
   {"text": "Exactly one", "feedback": "Correct."},
   {"text": "None", "feedback": "That happens when the directions ARE parallel and the lines are distinct. Non-parallel lines in a plane cannot avoid each other."}]'::jsonb,
 2, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 9, 'Easy',
 'Two distinct planes have normal vectors that are not parallel. What is their intersection?',
 '[{"text": "A line", "feedback": "Correct."},
   {"text": "A single point", "feedback": "Two planes never meet in just a point. Once they share one point they share a whole line through it."},
   {"text": "A plane", "feedback": "That would make them the same plane, which the question rules out by calling them distinct."},
   {"text": "Nothing", "feedback": "That happens only when the normals ARE parallel and the planes are distinct."}]'::jsonb,
 0, 'sub-plane-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 10, 'Easy',
 'Two plane equations are scalar multiples of one another. What does that mean geometrically?',
 '[{"text": "They meet in a line", "feedback": "That needs the normals to point in different directions, and multiples of one another point the same way."},
   {"text": "They are perpendicular", "feedback": "Perpendicular planes have normals with a dot product of zero, which multiples of each other never manage."},
   {"text": "They are the same plane, so every point of one lies on the other", "feedback": "Correct."},
   {"text": "They are parallel and distinct planes, so they never meet at any point", "feedback": "Parallel and distinct planes have normals that are multiples but constants that are NOT in the same ratio. Here the whole equation matches."}]'::jsonb,
 2, 'sub-plane-intersections'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): write one equation, or test one point.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 11, 'Medium',
 'What is a vector equation of the line through A(1, 4) and B(3, 1)?',
 '[{"text": "[x, y] = [2, -3] + t[1, 4]", "feedback": "The point and the direction have swapped places. The point goes first, on its own."},
   {"text": "[x, y] = [1, 4] + t[3, 1]", "feedback": "The second POINT was used as a direction. A direction comes from subtracting one point from the other."},
   {"text": "[x, y] = [1, 4] + t[4, 5]", "feedback": "The two points were added to make the direction. They have to be subtracted."},
   {"text": "[x, y] = [1, 4] + t[2, -3]", "feedback": "Correct."}]'::jsonb,
 3, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 12, 'Medium',
 'Is the point (2, 3) on the line [x, y] = [1, 4] + t[2, -3]?',
 '[{"text": "No, because the two coordinates need different values of t", "feedback": "Correct."},
   {"text": "Yes, at t = 0.5", "feedback": "That value works for the x-coordinate, but substituting it gives a y of 2.5 rather than 3. One coordinate agreeing is not enough."},
   {"text": "Yes, at t = 1", "feedback": "At that value the point is (3, 1), which is neither coordinate of the one being tested."},
   {"text": "Yes, because both coordinates lie between those of the two given points", "feedback": "Lying between two points on a line does not put you on the line; the whole plane between them is off it."}]'::jsonb,
 0, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 13, 'Medium',
 'What are the parametric equations of the line through (2, -1, 4) with direction [3, 0, -2]?',
 '[{"text": "x = 2 + 3t, y = -1, z = 4 + 2t", "feedback": "The sign on the third component of the direction was lost."},
   {"text": "x = 2 + 3t, y = -1 + t, z = 4 - 2t", "feedback": "The middle component of the direction is zero, so y is stuck. Nothing may be invented for it."},
   {"text": "x = 2 + 3t, y = -1, z = 4 - 2t", "feedback": "Correct."},
   {"text": "x = 3 + 2t, y = -t, z = -2 + 4t", "feedback": "The point and the direction have swapped places in every coordinate."}]'::jsonb,
 2, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 14, 'Medium',
 'Two lines in 3-space have non-parallel directions and never meet. What are they called?',
 '[{"text": "Perpendicular", "feedback": "Perpendicular describes the ANGLE between two directions, and perpendicular lines in 3-space may or may not meet."},
   {"text": "Skew", "feedback": "Correct."},
   {"text": "Parallel", "feedback": "Parallel lines have directions that are scalar multiples of one another, which the question rules out."},
   {"text": "Coincident", "feedback": "Coincident lines share every point, which is the opposite of never meeting."}]'::jsonb,
 1, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 15, 'Medium',
 'Which is a vector equation of the plane through (1, 2, 3) containing the directions [1, 0, 0] and [0, 1, 0]?',
 '[{"text": "[x, y, z] = [1, 2, 3] + s[1, 0, 0] + t[0, 1, 0]", "feedback": "Correct."},
   {"text": "[x, y, z] = [1, 2, 3] + t[1, 0, 0]", "feedback": "Only one direction was used, which describes a LINE. A plane needs two independent parameters."},
   {"text": "[x, y, z] = [1, 0, 0] + s[1, 2, 3] + t[0, 1, 0]", "feedback": "The point and the first direction have swapped places."},
   {"text": "[x, y, z] = [1, 2, 3] + s[1, 0, 0] + t[0, 1, 0] + u[0, 0, 1]", "feedback": "Three independent directions fill the whole of space rather than a plane."}]'::jsonb,
 0, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 16, 'Medium',
 'What is the scalar equation of the plane through (2, -1, 5) with normal [3, 4, -2]?',
 '[{"text": "3x + 4y - 2z = 0", "feedback": "The constant was left out, which puts the plane through the origin instead of through the given point."},
   {"text": "3x + 4y - 2z + 8 = 0", "feedback": "Correct."},
   {"text": "3x + 4y - 2z - 8 = 0", "feedback": "The constant was copied with the sign of the substitution instead of the sign that cancels it. Put (2, -1, 5) into this equation and the left side does not come out as zero."},
   {"text": "2x - y + 5z + 8 = 0", "feedback": "The POINT was used as the coefficients. The normal supplies them; the point only fixes the constant."}]'::jsonb,
 1, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 17, 'Medium',
 'Are the planes 2x - 6y + 4z - 7 = 0 and 3x - 9y + 6z - 2 = 0 parallel?',
 '[{"text": "No, because their constant terms are different numbers", "feedback": "The constants decide whether they are the same plane or two distinct ones. Being parallel is decided by the normals alone."},
   {"text": "No, because their coefficients are not the same numbers as one another", "feedback": "Different numbers can still be in the same ratio. Divide one set by the other and every quotient comes out the same."},
   {"text": "No, they are perpendicular to one another", "feedback": "Perpendicular planes have normals with a dot product of zero. These two normals point the same way."},
   {"text": "Yes, because their normal vectors are scalar multiples of one another", "feedback": "Correct."}]'::jsonb,
 3, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 18, 'Medium',
 'How are the lines [x, y] = [1, 2] + t[3, 1] and [x, y] = [0, 5] + s[6, 2] related?',
 '[{"text": "Parallel and distinct, so they never meet", "feedback": "Correct."},
   {"text": "They meet at exactly one point", "feedback": "The second direction is twice the first, so the lines never converge. Two parallel lines meet only if they are the same line."},
   {"text": "Coincident, so they meet everywhere", "feedback": "The directions do match, but the point (0, 5) is not on the first line. Substituting its x-value gives a y of five thirds."},
   {"text": "Skew", "feedback": "Skew is only possible in 3-space. Two lines in a plane are either parallel or they cross."}]'::jsonb,
 0, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 19, 'Medium',
 'How do the planes 2x - y + z - 1 = 0 and x + y + z - 6 = 0 intersect?',
 '[{"text": "At a single point", "feedback": "Two planes never meet in one point alone. Once they share a point they share the whole line through it."},
   {"text": "They do not intersect", "feedback": "That needs parallel normals, and these two are not multiples of one another."},
   {"text": "They are the same plane", "feedback": "The two equations are not multiples of each other, so they describe different planes."},
   {"text": "In a line", "feedback": "Correct."}]'::jsonb,
 3, 'sub-plane-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 20, 'Medium',
 'How do the planes x + y - 2z + 2 = 0 and 2x + 2y - 4z + 4 = 0 intersect?',
 '[{"text": "They meet at a single point, and nowhere else", "feedback": "Two planes never meet in one point alone."},
   {"text": "They are coincident, so every point of one lies on the other", "feedback": "Correct."},
   {"text": "They intersect in a line, and share every point along that line", "feedback": "That needs the normals to point in different directions. Here the second equation is exactly twice the first."},
   {"text": "They do not intersect, so they have no point in common", "feedback": "That would make them parallel and distinct, which needs the constants to be in a different ratio from the coefficients. Here every ratio is 2."}]'::jsonb,
 1, 'sub-plane-intersections'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): convert between forms, and build a plane from
-- directions. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 21, 'Challenge',
 'A line has parametric equations x = 3 + 2t and y = -5 + 4t. What is its scalar equation?',
 '[{"text": "2x - y + 11 = 0", "feedback": "The constant came out with the wrong sign. Substitute (3, -5) and this one gives 22."},
   {"text": "2x - y - 11 = 0", "feedback": "Correct."},
   {"text": "4x - 2y - 11 = 0", "feedback": "The two sides were not reduced to lowest terms consistently, so the constant no longer fits. Substitute the point (3, -5) and see."},
   {"text": "2x + y - 11 = 0", "feedback": "A sign was flipped while rearranging. Substitute (3, -5) and this one gives negative 10 rather than zero."}]'::jsonb,
 1, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 22, 'Challenge',
 'Which vector is a direction vector for the line 3x + 2y - 11 = 0?',
 '[{"text": "[3, 2]", "feedback": "Those are the coefficients, which give the NORMAL. A direction has to be perpendicular to it."},
   {"text": "[3, -2]", "feedback": "The signs were swapped without the components being swapped. Check the dot product with the normal: it comes out as 5, not zero."},
   {"text": "[2, 3]", "feedback": "The components were swapped but no sign was changed. Its dot product with the normal is 12, not zero."},
   {"text": "[2, -3]", "feedback": "Correct."}]'::jsonb,
 3, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 23, 'Challenge',
 'What are the symmetric equations of the line through (1, -2, 4) with direction [3, 5, -1]?',
 '[{"text": "(x - 3)/1 = (y - 5)/(-2) = (z + 1)/4", "feedback": "The point and the direction have swapped places."},
   {"text": "(x - 1)/3 = (y - 2)/5 = (z - 4)/(-1)", "feedback": "The middle term is wrong. Subtracting negative 2 from y gives a plus sign there."},
   {"text": "(x - 1)/3 = (y + 2)/5 = (z - 4)/(-1)", "feedback": "Correct."},
   {"text": "(x + 1)/3 = (y - 2)/5 = (z + 4)/(-1)", "feedback": "Every sign on the point was flipped. The coordinates of the point are SUBTRACTED, so a negative coordinate becomes an addition."}]'::jsonb,
 2, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 24, 'Challenge',
 'Is the point (7, 8, 2) on the line [x, y, z] = [1, -2, 4] + t[3, 5, -1]?',
 '[{"text": "Yes, at t = 6", "feedback": "The starting x was subtracted from 7, but the difference was never divided by the first component of the direction. Test any candidate in all three coordinates."},
   {"text": "Yes, at t = 2", "feedback": "Correct."},
   {"text": "No, because the coordinates need different values of t", "feedback": "They do not. One value satisfies all three, which is exactly what puts the point on the line."},
   {"text": "Yes, at t = 3", "feedback": "At that value the point is (10, 13, 1), which is not the one being tested."}]'::jsonb,
 1, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 25, 'Challenge',
 'A plane has vector equation [x, y, z] = [1, 0, 2] + s[2, 1, 0] + t[0, 3, 1]. What is a normal vector to it?',
 '[{"text": "[1, 0, 2]", "feedback": "That is the position vector of the given point. Where the plane sits says nothing about which way it faces."},
   {"text": "[1, 2, 6]", "feedback": "The middle component came out with the wrong sign. In a cross product it is built the opposite way round from the other two."},
   {"text": "[1, -2, 6]", "feedback": "Correct."},
   {"text": "[2, 1, 0]", "feedback": "That is one of the DIRECTIONS lying in the plane. A normal has to be perpendicular to both of them."}]'::jsonb,
 2, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 26, 'Challenge',
 'Why must the two direction vectors in the vector equation of a plane be non-collinear?',
 '[{"text": "Because otherwise the given point would not lie on the plane", "feedback": "The point lies on it either way, at s and t both zero. What collapses is everything else."},
   {"text": "Because two collinear directions sweep out only a line", "feedback": "Correct."},
   {"text": "Because their cross product has to come out equal to zero", "feedback": "It has to be non-zero. That cross product is exactly what supplies the normal, and collinear directions would leave you without one."},
   {"text": "Because the normal vector is required to have magnitude 1", "feedback": "A normal of any length will do. The requirement is that a normal exists at all."}]'::jsonb,
 1, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 27, 'Challenge',
 'What is the scalar equation of the plane through (1, 0, 2) containing the directions [2, 1, 0] and [0, 3, 1]?',
 '[{"text": "x + 2y + 6z - 13 = 0", "feedback": "The middle coefficient came out with the wrong sign in the cross product. It is built the opposite way round from the other two."},
   {"text": "x - 2y + 6z - 13 = 0", "feedback": "Correct."},
   {"text": "x - 2y + 6z + 13 = 0", "feedback": "The constant was copied with the sign of the substitution instead of the sign that cancels it. Put (1, 0, 2) into this equation and the left side does not come out as zero."},
   {"text": "2x + y + 0z - 2 = 0", "feedback": "One of the DIRECTIONS was used as the normal. A normal is perpendicular to both directions, which means taking their cross product first."}]'::jsonb,
 1, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 28, 'Challenge',
 'What is the angle between the planes x + y + z = 0 and x - y = 0?',
 '[{"text": "90 degrees", "feedback": "Correct."},
   {"text": "45 degrees", "feedback": "That would be the angle if the normals had a dot product equal to the product of one magnitude with the other over root 2. Here the dot product is exactly zero."},
   {"text": "60 degrees", "feedback": "The dot product of the two normals is zero, which forces the cosine to zero and the angle to a right angle."},
   {"text": "0 degrees", "feedback": "That would need the normals to be parallel, and one has a z-component while the other does not."}]'::jsonb,
 0, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 29, 'Challenge',
 'How are the lines [x, y, z] = [1, 0, 2] + t[1, 2, -1] and [x, y, z] = [2, 3, 1] + s[2, 4, -2] related?',
 '[{"text": "They meet at exactly one point", "feedback": "The second direction is twice the first, so the lines never converge on each other."},
   {"text": "Coincident, so they meet everywhere", "feedback": "The directions do match, but (2, 3, 1) is not on the first line. Its x-coordinate needs t equal to 1, and that gives a y of 2 rather than 3."},
   {"text": "Skew", "feedback": "Skew lines have non-parallel directions. These two directions are multiples of one another."},
   {"text": "Parallel and distinct, so they never meet", "feedback": "Correct."}]'::jsonb,
 3, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 30, 'Challenge',
 'Two planes are parallel and distinct. How many solutions does the system of their two equations have?',
 '[{"text": "Two", "feedback": "A system of linear equations has no solutions, one solution or infinitely many. Two is never available."},
   {"text": "None", "feedback": "Correct."},
   {"text": "Exactly one", "feedback": "Two planes never share exactly one point, whether they are parallel or not."},
   {"text": "Infinitely many", "feedback": "That happens when the two are COINCIDENT. Distinct parallel planes share nothing at all."}]'::jsonb,
 1, 'sub-plane-intersections'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): distances, intersections built from scratch, and the
-- three-plane cases. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 31, 'Advanced',
 'What is the distance from the point (4, 1) to the line 3x + 4y - 10 = 0?',
 '[{"text": "1.2", "feedback": "Correct."},
   {"text": "6", "feedback": "That is the value of the left-hand side at the point, before dividing by the magnitude of the normal."},
   {"text": "5.2", "feedback": "The constant term was added when the point was substituted rather than subtracted."},
   {"text": "0", "feedback": "The point is not on the line. Substituting it gives 6, not zero."}]'::jsonb,
 0, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 32, 'Advanced',
 'What is a direction vector for the line of intersection of 2x - y + z - 1 = 0 and x + y + z - 6 = 0?',
 '[{"text": "[1, 1, 1]", "feedback": "That is the normal of the second plane. The line of intersection lies in that plane too."},
   {"text": "[-2, -1, 3]", "feedback": "Correct."},
   {"text": "[3, 0, 2]", "feedback": "The two normals were added. A direction along the intersection has to be perpendicular to BOTH normals, which calls for a cross product."},
   {"text": "[2, -1, 1]", "feedback": "That is the normal of the first plane. The line of intersection lies IN that plane, so it is perpendicular to this."}]'::jsonb,
 1, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 33, 'Advanced',
 'What is the scalar equation of the plane through the points (1, 0, 0), (0, 1, 0) and (0, 0, 1)?',
 '[{"text": "x + y + z - 1 = 0", "feedback": "Correct."},
   {"text": "x + y + z = 0", "feedback": "That plane passes through the origin, and none of the three given points is the origin. Substitute any one of them and it gives 1."},
   {"text": "x + y + z - 3 = 0", "feedback": "The three coordinates were added across all three points. Substituting one point into the first three terms gives 1, so the constant is negative 1."},
   {"text": "x - y + z - 1 = 0", "feedback": "A sign was flipped in the normal. Substituting the second point gives negative 2 rather than zero."}]'::jsonb,
 0, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 34, 'Advanced',
 'Which plane does [x, y, z] = [0, 0, 0] + s[1, 1, 0] + t[1, -1, 0] describe?',
 '[{"text": "The xz-plane, y = 0", "feedback": "The two directions were subtracted and the difference read off as a normal. A normal has to be perpendicular to both directions, and that difference is perpendicular to neither."},
   {"text": "The plane x + y = 0", "feedback": "That would be a plane containing the z-axis, and neither of these directions has any z-component at all."},
   {"text": "A line through the origin", "feedback": "The two directions are not multiples of one another, so together they sweep out a full plane rather than a line."},
   {"text": "The xy-plane, z = 0", "feedback": "Correct."}]'::jsonb,
 3, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 35, 'Advanced',
 'What is the distance from the origin to the plane 2x - y + 2z - 9 = 0?',
 '[{"text": "1", "feedback": "The divisor was the sum of the SQUARES of the components, with the square root never taken."},
   {"text": "4.5", "feedback": "Only the first component of the normal was used as the divisor. The whole magnitude of the normal belongs underneath."},
   {"text": "3", "feedback": "Correct."},
   {"text": "9", "feedback": "That is the size of the constant term, before dividing by the magnitude of the normal."}]'::jsonb,
 2, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 36, 'Advanced',
 'How are the lines [x, y, z] = [1, 0, 2] + t[1, 2, -1] and [x, y, z] = [0, 1, 1] + s[2, 1, 1] related?',
 '[{"text": "They are parallel and distinct", "feedback": "The two directions are not multiples of one another, so the lines are not parallel."},
   {"text": "They are coincident", "feedback": "Coincident lines share every point, and these two share none at all."},
   {"text": "They are skew", "feedback": "Correct."},
   {"text": "They meet at exactly one point", "feedback": "Two of the three equations can be satisfied together, at t equal to two thirds, but the first one then fails. All three have to agree."}]'::jsonb,
 2, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 37, 'Advanced',
 'Two lines in 2-space have the same direction vector and share one point. How are they related?',
 '[{"text": "They are parallel and distinct, so they never share a point", "feedback": "Distinct parallel lines share NO points. One shared point plus a common direction forces the rest to follow."},
   {"text": "They meet at exactly one point", "feedback": "That needs different directions. With the same direction, one shared point drags the whole line along."},
   {"text": "They are skew", "feedback": "Skew is only possible in 3-space, and skew lines never meet at all."},
   {"text": "They are coincident, so they share every point", "feedback": "Correct."}]'::jsonb,
 3, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 38, 'Advanced',
 'Two lines in 3-space have direction vectors that are not parallel. What can be concluded?',
 '[{"text": "They either meet at exactly one point or they are skew", "feedback": "Correct."},
   {"text": "They must meet at exactly one point, since they are not parallel", "feedback": "That is what happens in 2-space. In three dimensions two lines can pass each other at different heights without ever touching."},
   {"text": "They must be skew, so they never meet at any point", "feedback": "They may well meet. Non-parallel directions leave both possibilities open, which is why the system has to be solved."},
   {"text": "They must be parallel", "feedback": "The question rules that out: parallel lines have directions that are scalar multiples of one another."}]'::jsonb,
 0, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 39, 'Advanced',
 'Three planes have normals that are neither parallel nor coplanar. How do they intersect?',
 '[{"text": "In a line", "feedback": "That is the case where the normals are not parallel but ARE coplanar. Here they are independent enough to pin down a single point."},
   {"text": "In a plane", "feedback": "That needs all three equations to be multiples of one another, which would make the normals parallel."},
   {"text": "They do not intersect", "feedback": "Independent normals guarantee a solution. It is when the normals become coplanar that a system can turn inconsistent."},
   {"text": "At exactly one point", "feedback": "Correct."}]'::jsonb,
 3, 'sub-plane-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 40, 'Advanced',
 'How do you test whether the normals of three planes are coplanar?',
 '[{"text": "Check whether all three are unit vectors", "feedback": "Length has nothing to do with it. Scaling a normal does not move the plane it belongs to."},
   {"text": "Check whether the three normals add together to give exactly the zero vector", "feedback": "That would force them to be coplanar, but plenty of coplanar triples do not add to zero. The test is too strict."},
   {"text": "Check whether the triple scalar product of the three normals is zero", "feedback": "Correct."},
   {"text": "Check whether all three pairwise dot products come out as zero", "feedback": "That tests whether they are mutually perpendicular, which is as far from coplanar as three vectors can get."}]'::jsonb,
 2, 'sub-plane-intersections');

-- --- figures_mcv4u.sql  (must be last) ---

-- ======================================================================
-- figures_mcv4u.sql — attaches figures to questions
-- ======================================================================
-- GENERATED by tools/make_figures.py — edit that script, not this file.
--
-- Run AFTER the question files for this course, and after any re-run of
-- one: the per-unit delete wipes the figure column with the rest of the
-- row. Safe to re-run on its own at any time.
--
-- The PNGs live in web/figures/ and ship inside every deploy. A null
-- figure renders no image, and a missing file shows a short "could not
-- load" line in the app rather than a broken icon.

update questions set figure = null where course_code = 'MCV4U';

update questions set figure = 'figures/mcv4u_motion_29.png'
 where course_code = 'MCV4U' and unit = 'Derivative Rules' and sort_order = 29;
update questions set figure = 'figures/mcv4u_extrema_08.png'
 where course_code = 'MCV4U' and unit = 'Curve Sketching' and sort_order = 8;
update questions set figure = 'figures/mcv4u_optim_10.png'
 where course_code = 'MCV4U' and unit = 'Curve Sketching' and sort_order = 10;
update questions set figure = 'figures/mcv4u_deriv_18.png'
 where course_code = 'MCV4U' and unit = 'Curve Sketching' and sort_order = 18;
update questions set figure = 'figures/mcv4u_vect_06.png'
 where course_code = 'MCV4U' and unit = 'Geometric Vectors' and sort_order = 6;
update questions set figure = 'figures/mcv4u_vect_13.png'
 where course_code = 'MCV4U' and unit = 'Geometric Vectors' and sort_order = 13;
update questions set figure = 'figures/mcv4u_vect_27.png'
 where course_code = 'MCV4U' and unit = 'Geometric Vectors' and sort_order = 27;
update questions set figure = 'figures/mcv4u_vect_39.png'
 where course_code = 'MCV4U' and unit = 'Geometric Vectors' and sort_order = 39;
update questions set figure = 'figures/mcv4u_vect_25.png'
 where course_code = 'MCV4U' and unit = 'Algebraic Vectors' and sort_order = 25;
update questions set figure = 'figures/mcv4u_vect_28.png'
 where course_code = 'MCV4U' and unit = 'Algebraic Vectors' and sort_order = 28;
update questions set figure = 'figures/mcv4u_vect_39b.png'
 where course_code = 'MCV4U' and unit = 'Algebraic Vectors' and sort_order = 39;
update questions set figure = 'figures/mcv4u_line_01.png'
 where course_code = 'MCV4U' and unit = 'Lines and Planes' and sort_order = 1;

-- Check: every figure attached, and none orphaned.
select unit, sort_order, figure from questions
 where course_code = 'MCV4U' and figure is not null
 order by unit, sort_order;
