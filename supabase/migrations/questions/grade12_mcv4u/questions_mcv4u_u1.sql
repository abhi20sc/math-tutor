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
