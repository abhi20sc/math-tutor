-- ===========================================================================
-- MHF4U — Unit 2: Factoring Polynomials — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  Long division of polynomials
--   Lesson 2  Synthetic division
--   Lesson 3  The factor theorem
--   Lesson 4  Solving polynomial equations
--   Lesson 5  Families of polynomial functions
--   Lesson 6  Polynomial inequalities
--
-- The remainder theorem gets its own subtopic even though Jensen teaches it
-- inside the division lessons. A student who can divide but cannot see that
-- the remainder equals P(a) has a specific, nameable gap, and it is the one
-- that makes the factor theorem look like magic.
--
-- Families of polynomials sits with solving equations rather than on its
-- own, because the work is the same: build the factors, then use one point
-- to pin down k.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every division, factorisation and inequality in this file was recomputed
-- independently with sympy before delivery; nothing was copied from the
-- source PDFs.
--
-- FIGURES: none. The inequality questions are solved with a sign chart in
-- the Jensen material, and a sign chart is a table of the answer. Drawing
-- the curve is worse still — the intervals where it dips below the axis are
-- the whole question. Every one of those is asked here from the factored
-- form and the end behaviour instead, which is the reasoning the sign chart
-- is a shorthand for.
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

delete from questions where course_code = 'MHF4U' and unit = 'Factoring Polynomials';

insert into misconception_labels (tag, label) values
  ('sub-poly-division',     'Long and synthetic division'),
  ('sub-remainder-theorem', 'The remainder theorem'),
  ('sub-factor-theorem',    'The factor theorem and factoring'),
  ('sub-poly-equations',    'Solving polynomial equations'),
  ('sub-poly-inequalities', 'Polynomial inequalities')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Factoring Polynomials', 2, 1, 'Easy',
 E'To divide a polynomial by x + 1 using synthetic division,\nwhich number goes in the box?',
 '[{"text": "1", "feedback": "The box holds the value that makes the DIVISOR zero, and solving x + 1 = 0 moves the 1 across with its sign changed."},
   {"text": "0", "feedback": "0 would be the right box for a divisor of x on its own."},
   {"text": "x", "feedback": "The box holds a number, not a variable. Solve x + 1 = 0 to find it."},
   {"text": "-1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 2, 'Easy',
 E'A degree 4 polynomial is divided by a linear expression.\nWhat is the degree of the quotient?',
 '[{"text": "1", "feedback": "1 is the degree of the DIVISOR. The quotient keeps most of the original degree."},
   {"text": "3", "feedback": "Correct."},
   {"text": "4", "feedback": "Dividing by a degree 1 expression takes one off the degree."},
   {"text": "5", "feedback": "Dividing lowers the degree. Multiplying by a linear expression would raise it to 5."}]'::jsonb,
 1, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 3, 'Easy',
 'By the remainder theorem, dividing P(x) by x - a leaves a remainder of what?',
 '[{"text": "P(a)", "feedback": "Correct."},
   {"text": "P(-a)", "feedback": "The sign flips when the bracket is solved: x - a is zero at positive a."},
   {"text": "the number a", "feedback": "a is the input, not the output. The remainder is what the polynomial EVALUATES to there."},
   {"text": "P(x) divided by a", "feedback": "The theorem replaces the whole division with a single substitution. No dividing is left to do."}]'::jsonb,
 0, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 4, 'Easy',
 'What is the remainder when x⁴ - 4x² - 2x + 3 is divided by x + 1?',
 '[{"text": "0", "feedback": "A remainder of zero would make x + 1 a factor, and substituting -1 does not give zero here."},
   {"text": "2", "feedback": "Correct."},
   {"text": "-2", "feedback": "The -2x term becomes +2 when x is -1, because a negative times a negative is positive."},
   {"text": "8", "feedback": "That takes (-1)⁴ as -1. An even power of a negative is positive."}]'::jsonb,
 1, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 5, 'Easy',
 'x - 3 is a factor of P(x) exactly when which of these is true?',
 '[{"text": "P(3) = 0", "feedback": "Correct."},
   {"text": "P(-3) = 0", "feedback": "The sign flips when the bracket is solved: x - 3 is zero at positive 3."},
   {"text": "P(0) = 3", "feedback": "That is about the y-intercept, which has nothing to do with whether a bracket divides in."},
   {"text": "P(3) = 3", "feedback": "A factor leaves NO remainder, so the value has to be zero rather than 3."}]'::jsonb,
 0, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 6, 'Easy',
 'Is x - 3 a factor of 3x² - 8x - 3?',
 '[{"text": "No, because substituting 3 gives 6 rather than 0", "feedback": "That adds the constant term instead of subtracting it. The polynomial ends in -3."},
   {"text": "Yes, because substituting -3 gives 0", "feedback": "The conclusion is right but the test is not. x - 3 is zero at positive 3, and substituting -3 gives 48."},
   {"text": "No, because the constant term is -3 rather than a multiple of 3", "feedback": "The constant term does not settle it. The factor theorem is a substitution, not a look at the coefficients."},
   {"text": "Yes, because substituting 3 gives 0", "feedback": "Correct."}]'::jsonb,
 3, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 7, 'Easy',
 'Solve (x - 2)(x + 5) = 0.',
 '[{"text": "x = 2 or x = -5", "feedback": "Correct."},
   {"text": "x = -2 or x = 5", "feedback": "Both signs are flipped. Setting x - 2 = 0 gives POSITIVE 2."},
   {"text": "x = 2 or x = 5", "feedback": "The first is right. The bracket x + 5 is zero at a negative value."},
   {"text": "x = -2 or x = -5", "feedback": "The second is right. The bracket x - 2 is zero at a positive value."}]'::jsonb,
 0, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 8, 'Easy',
 'What is the greatest number of real roots a cubic equation can have?',
 '[{"text": "2", "feedback": "2 is the maximum number of TURNING points for a cubic. The roots can go one higher."},
   {"text": "4", "feedback": "A polynomial never has more roots than its degree."},
   {"text": "1", "feedback": "1 is the MINIMUM for a cubic, because an odd degree has to cross the axis at least once."},
   {"text": "3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 9, 'Easy',
 'Solve (x - 1)(x + 2) > 0.',
 '[{"text": "x > 1 only", "feedback": "Half the answer. Below -2 both brackets are negative, and two negatives multiply to a positive."},
   {"text": "All real numbers", "feedback": "Between the roots the product dips below zero, so it is not positive everywhere."},
   {"text": "x < -2 or x > 1", "feedback": "Correct."},
   {"text": "-2 < x < 1", "feedback": "That is where the product is NEGATIVE. Between the two roots exactly one bracket is negative."}]'::jsonb,
 2, 'sub-poly-inequalities'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 10, 'Easy',
 'In interval notation, what does a square bracket mean?',
 '[{"text": "The interval runs to infinity", "feedback": "Infinity always takes a round bracket, precisely because it can never be reached."},
   {"text": "The interval turns out to be empty", "feedback": "An empty set is written with its own symbol. Brackets say whether the ends belong."},
   {"text": "The endpoint is included", "feedback": "Correct."},
   {"text": "The endpoint is not included", "feedback": "That is what a round bracket means. A square bracket takes the endpoint in."}]'::jsonb,
 2, 'sub-poly-inequalities'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Factoring Polynomials', 2, 11, 'Medium',
 'Write (x⁴ - 4x² - 2x + 3) divided by (x - 2) in quotient form.',
 '[{"text": "x³ - 2x² - 2 - 1/(x - 2)", "feedback": "The second coefficient is wrong. Bringing 1 down and multiplying by 2 gives +2, not -2."},
   {"text": "x³ + 2x² + 2 - 1/(x - 2)", "feedback": "The constant in the quotient came out negative. Check the third step of the synthetic division."},
   {"text": "x³ + 2x² - 2 - 1/(x - 2)", "feedback": "Correct."},
   {"text": "x³ + 2x² - 2 + 1/(x - 2)", "feedback": "The remainder came out as -1, so the fraction on the end is subtracted."}]'::jsonb,
 2, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 12, 'Medium',
 'Divide 12x³ - 2x² + x - 11 by 3x + 1. What are the quotient and the remainder?',
 '[{"text": "Quotient 4x² - 2x + 1, remainder -12", "feedback": "Correct."},
   {"text": "Quotient 4x² - 2x + 1, remainder 12", "feedback": "The quotient is right. Subtracting 3x + 1 from 3x - 11 leaves a negative."},
   {"text": "Quotient 4x² + 2x + 1, remainder -12", "feedback": "The middle term of the quotient is negative. Check the sign after the first subtraction."},
   {"text": "Quotient 12x² - 2x + 1, remainder -12", "feedback": "The leading term of the quotient comes from dividing 12x³ by 3x, which gives 4x², not 12x²."}]'::jsonb,
 0, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 13, 'Medium',
 E'Find k so that dividing f(x) = x⁴ + kx³ - 3x - 5 by x - 3\nleaves a remainder of -10.',
 '[{"text": "k = -77/27", "feedback": "Correct."},
   {"text": "k = 77/27", "feedback": "Moving 67 across the equals sign from -10 makes the left side -77, so k comes out negative."},
   {"text": "k = -10/27", "feedback": "The -10 was divided by 27 on its own. The other terms 81, -9 and -5 also have to be moved across first."},
   {"text": "k = -67/27", "feedback": "That divides the 67 rather than the -77. The -10 on the left still has to be brought over."}]'::jsonb,
 0, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 14, 'Medium',
 'A division leaves a remainder of 0. What does that tell you?',
 '[{"text": "Nothing in particular", "feedback": "A zero remainder is exactly the factor theorem: the divisor goes in a whole number of times."},
   {"text": "The divisor is a factor of the polynomial", "feedback": "Correct."},
   {"text": "The polynomial being divided is the zero polynomial", "feedback": "Only dividing zero by something gives a zero QUOTIENT. A zero remainder says the division came out exactly."},
   {"text": "The quotient is zero", "feedback": "The quotient is what the division produces, and it is usually far from zero. It is the leftover that vanished."}]'::jsonb,
 1, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 15, 'Medium',
 'Factor x³ - 4x² + x + 6 fully.',
 '[{"text": "(x + 1)(x - 2)(x - 3)", "feedback": "Correct."},
   {"text": "(x - 1)(x + 2)(x + 3)", "feedback": "Every sign is flipped. Multiply this out and the constant comes to -6 rather than +6."},
   {"text": "(x + 1)(x + 2)(x - 3)", "feedback": "Multiply this out: the constant becomes -6, and the x² coefficient becomes 0 rather than -4."},
   {"text": "(x - 1)(x - 2)(x - 3)", "feedback": "Multiply this out: the constant comes to -6, and substituting 1 into the original gives 4 rather than 0."}]'::jsonb,
 0, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 16, 'Medium',
 'Factor x³ - 64 fully over the real numbers.',
 '[{"text": "(x - 4)(x² + 4x - 16)", "feedback": "The last term of the second bracket is b squared, which is positive."},
   {"text": "(x - 4)³", "feedback": "Multiply that out and it gives x³ - 12x² + 48x - 64. A difference of cubes is not a perfect cube."},
   {"text": "(x - 4)(x² + 4x + 16)", "feedback": "Correct."},
   {"text": "(x - 4)(x² - 4x + 16)", "feedback": "In the difference of cubes the middle term of the second bracket is PLUS ab. Only the first bracket carries the minus."}]'::jsonb,
 2, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 17, 'Medium',
 'Solve x³ + 6x² + 11x + 6 = 0.',
 '[{"text": "x = -1, -2 and -3", "feedback": "Correct."},
   {"text": "x = 1, 2 and 3", "feedback": "Every coefficient here is positive, so a positive x can never make the total zero. The roots have to be negative."},
   {"text": "x = -1, 2 and 3", "feedback": "Only the first is right. Substituting 2 gives 60, not 0."},
   {"text": "x = -1, -2 and 3", "feedback": "Two are right. Substituting 3 gives 120, not 0."}]'::jsonb,
 0, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 18, 'Medium',
 'Solve 2x³ + 1 = x² + 2x.',
 '[{"text": "x = -1/2, 1 and -1", "feedback": "The bracket 2x - 1 is zero at a POSITIVE half."},
   {"text": "x = 2, 1 and -1", "feedback": "The bracket 2x - 1 has a coefficient on the x, and that coefficient divides the root."},
   {"text": "x = 1/2 only", "feedback": "After grouping, the second factor is x² - 1, which supplies two more roots of its own."},
   {"text": "x = 1/2, 1 and -1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 19, 'Medium',
 'Solve x³ + 6x² + 11x + 6 > 0.',
 '[{"text": "x < -3 or -2 < x < -1", "feedback": "Those are the intervals where the cubic is NEGATIVE. With a positive leading coefficient it starts below the axis on the far left."},
   {"text": "-3 < x < -2 only", "feedback": "Half the answer. To the right of the largest root the curve heads up and stays positive."},
   {"text": "x > -1 only", "feedback": "Half the answer. The curve also pokes above the axis in the gap between -3 and -2."},
   {"text": "-3 < x < -2 or x > -1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-inequalities'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 20, 'Medium',
 'For which values of x is y = 8x³ + 1 positive?',
 '[{"text": "Every x except -1/2", "feedback": "That would need an even-order root, where the curve touches the axis and turns back. This one crosses cleanly."},
   {"text": "x > -1/2", "feedback": "Correct."},
   {"text": "x < -1/2", "feedback": "A positive leading coefficient on an odd degree means the curve is BELOW the axis to the left of its root."},
   {"text": "x > 1/2", "feedback": "The root comes from 8x³ = -1, so the cube root is negative."}]'::jsonb,
 1, 'sub-poly-inequalities'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): non-monic divisors, two unknowns, full factorisations.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Factoring Polynomials', 2, 21, 'Challenge',
 'Divide -8x⁴ + 10x³ - x² - 4x + 15 by 2x - 1.',
 '[{"text": "Quotient -8x³ + 3x² + x - 3/2, remainder 27/2", "feedback": "The leading term comes from dividing -8x⁴ by 2x, which gives -4x³."},
   {"text": "Quotient -4x³ + 3x² + x - 3/2, remainder 27/2", "feedback": "Correct."},
   {"text": "Quotient -4x³ + 3x² + x - 3/2, remainder -27/2", "feedback": "The quotient is right. Subtracting -3x + 3/2 from -3x + 15 leaves a positive remainder."},
   {"text": "Quotient -4x³ + 3x² + x + 3/2, remainder 27/2", "feedback": "The constant term of the quotient is negative. Dividing -3x by 2x gives -3/2."}]'::jsonb,
 1, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 22, 'Challenge',
 E'A division gives (x³ + 4x² - 3) ÷ (x - 2) = x² + 6x + 12 with remainder 21.\nWhich statement checks it?',
 '[{"text": "x³ + 4x² - 3 = (x - 2)(x² + 6x + 12 + 21)", "feedback": "The remainder sits outside the bracket. Putting it inside would multiply it by the divisor as well."},
   {"text": "x³ + 4x² - 3 = (x - 2)(x² + 6x + 12) + 21", "feedback": "Correct."},
   {"text": "x³ + 4x² - 3 = (x - 2)(x² + 6x + 12) - 21", "feedback": "The remainder is what is LEFT OVER, so it is added back on, not taken away."},
   {"text": "x³ + 4x² - 3 = (x² + 6x + 12) + 21(x - 2)", "feedback": "The divisor and the remainder have swapped roles. The divisor multiplies the quotient."}]'::jsonb,
 1, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 23, 'Challenge',
 E'To find the remainder when P(x) is divided by 3x + 1,\nwhich value do you substitute?',
 '[{"text": "3", "feedback": "Substituting 3 would suit a divisor of x - 3. Set the actual divisor to zero and solve it."},
   {"text": "-1/3", "feedback": "Correct."},
   {"text": "1/3", "feedback": "The sign flips when the divisor is solved: 3x + 1 is zero at a negative value."},
   {"text": "-3", "feedback": "The 3 and the 1 have swapped roles. Solving 3x + 1 = 0 divides the 1 by the 3, it does not divide the 3 by the 1."}]'::jsonb,
 1, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 24, 'Challenge',
 E'The cubic 8x³ + mx² + nx - 6 has both 2x + 3 and x - 1 as factors.\nFind m and n.',
 '[{"text": "m = 8 and n = 10", "feedback": "m is right. Substituting 1 gives 8 + m + n - 6 = 0, and with m = 8 that forces n below zero."},
   {"text": "m = -8 and n = -10", "feedback": "n is right, but solving the pair of equations gives a positive m."},
   {"text": "m = 8 and n = -10", "feedback": "Correct."},
   {"text": "m = -10 and n = 8", "feedback": "The two values are the right pair but they have swapped places. m belongs to the x² term."}]'::jsonb,
 2, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 25, 'Challenge',
 'Factor 3x³ - 5x² - 26x - 8 fully.',
 '[{"text": "(x + 2)(x - 4)(3x + 1)", "feedback": "Correct."},
   {"text": "(x - 2)(x + 4)(3x - 1)", "feedback": "Every sign is flipped. Multiply out and the constant becomes +8 rather than -8."},
   {"text": "(x + 2)(x + 4)(3x - 1)", "feedback": "Multiply out: the constant becomes -8, which is right, but the x² coefficient comes to 17 rather than -5."},
   {"text": "(x + 2)(x - 4)(3x - 1)", "feedback": "That takes the third root to be 1/3. Substituting 1/3 into the original leaves -154/9 rather than zero."}]'::jsonb,
 0, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 26, 'Challenge',
 'Factor -4x³ - 4x² + 16x + 16 fully.',
 '[{"text": "-4(x + 1)(x - 4)(x + 4)", "feedback": "The difference of squares left after grouping is x² - 4, not x² - 16."},
   {"text": "-4(x + 1)(x - 2)(x + 2)", "feedback": "Correct."},
   {"text": "-4(x - 1)(x - 2)(x + 2)", "feedback": "Grouping gives x²(x + 1) - 4(x + 1), so the common bracket is x + 1."},
   {"text": "4(x + 1)(x - 2)(x + 2)", "feedback": "The common factor pulled out is -4, not 4. Check the sign of the leading term."}]'::jsonb,
 1, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 27, 'Challenge',
 'Find the REAL roots of (5x² + 20)(3x² - 48) = 0.',
 '[{"text": "x = 4, -4, 2 and -2", "feedback": "The first bracket gives x² = -4, and no real number squares to a negative."},
   {"text": "x = 4 and no other value", "feedback": "x² = 16 has two solutions, one on each side of zero."},
   {"text": "There are no real roots", "feedback": "The first bracket has none, but the second gives x² = 16, which is perfectly solvable."},
   {"text": "x = 4 and x = -4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 28, 'Challenge',
 'Find the real solutions of x⁵ - 4x³ - x² + 4 = 0.',
 '[{"text": "x = 2 and x = -2 only", "feedback": "The second grouped factor x³ - 1 also contributes a real root."},
   {"text": "x = 1 and no other value", "feedback": "The first grouped factor x² - 4 supplies two more real roots."},
   {"text": "x = 2, -2 and 1", "feedback": "Correct."},
   {"text": "x = 2, -2, 1 and -1", "feedback": "Grouping leaves x² - 4 and x³ - 1. The cubic factor has only ONE real root, and -1 is not it."}]'::jsonb,
 2, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 29, 'Challenge',
 'Solve 2x³ + 1 < x² + 2x.',
 '[{"text": "-1 < x < 1/2 or x > 1", "feedback": "Those are the intervals where the cubic is POSITIVE. With a positive leading coefficient it starts below the axis on the far left."},
   {"text": "x < -1 only", "feedback": "Half the answer. The curve dips back below the axis between the two larger roots."},
   {"text": "1/2 < x < 1 only", "feedback": "Half the answer. Far to the left the curve is below the axis as well."},
   {"text": "x < -1 or 1/2 < x < 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-inequalities'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 30, 'Challenge',
 'Solve 6x³ + 13x² - 41x + 12 ≤ 0.',
 '[{"text": "1/3 ≤ x ≤ 3/2 only", "feedback": "Half the answer. Far to the left the curve is below the axis as well."},
   {"text": "x ≤ -4 or 1/3 ≤ x ≤ 3/2", "feedback": "Correct."},
   {"text": "x ≤ -4 only", "feedback": "Half the answer. Between the two positive roots the curve dips back below the axis."},
   {"text": "-4 ≤ x ≤ 1/3 or x ≥ 3/2", "feedback": "Those are the intervals where the cubic is at or above zero. The inequality asks for where it is at or below."}]'::jsonb,
 1, 'sub-poly-inequalities'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): quadratic divisors, unknown coefficients, families.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Factoring Polynomials', 2, 31, 'Advanced',
 'Divide x⁵ - x⁴ + 2x³ + 3x - 2 by x² + 2.',
 '[{"text": "Quotient x³ - x² + 2, remainder 3x + 6", "feedback": "The quotient is right. Subtracting 2x² + 4 from 2x² + 3x - 2 leaves a negative constant."},
   {"text": "Quotient x³ + x² + 2, remainder 3x - 6", "feedback": "The x² term of the quotient is negative. The -x⁴ in the dividend divides by x² to give -x²."},
   {"text": "Quotient x³ - x² - 2, remainder 3x - 6", "feedback": "The constant in the quotient is positive. Check the last step before the remainder."},
   {"text": "Quotient x³ - x² + 2, remainder 3x - 6", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 32, 'Advanced',
 'Why can synthetic division not be used to divide by x² + 2?',
 '[{"text": "Because its leading coefficient is 1", "feedback": "A leading coefficient of 1 is the easiest case, not an obstacle."},
   {"text": "It can be used, provided the division is set up with two boxes instead of one", "feedback": "The method depends on the divisor having a single root to substitute, so a second box does not rescue it."},
   {"text": "Because synthetic division only works when the divisor is linear", "feedback": "Correct."},
   {"text": "Because x² + 2 has no real roots", "feedback": "Having no real roots is true but beside the point. Even x² - 1, which has two, is out of reach for the method."}]'::jsonb,
 2, 'sub-poly-division'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 33, 'Advanced',
 E'P(x) leaves a remainder of 5 when divided by x - 2, and a remainder of -3\nwhen divided by x + 1. What is P(2) + P(-1)?',
 '[{"text": "8", "feedback": "The second remainder is negative, so the two are added as 5 and -3 rather than 5 and 3."},
   {"text": "-15", "feedback": "That multiplies the two remainders. The question asks for their sum."},
   {"text": "1", "feedback": "That adds the two x-values, 2 and -1, rather than the two remainders."},
   {"text": "2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 34, 'Advanced',
 'For P(x) = x³ + ax + b, both P(1) = 0 and P(-2) = 0. Find a and b.',
 '[{"text": "a = -3 and b = -2", "feedback": "a is right. Substituting 1 gives 1 + a + b = 0, so with a = -3 the constant has to be positive."},
   {"text": "a = 2 and b = -3", "feedback": "The two values have swapped places. a is the coefficient of x and b is the constant."},
   {"text": "a = -3 and b = 2", "feedback": "Correct."},
   {"text": "a = 3 and b = -2", "feedback": "Both signs are flipped. Substituting 1 gives 1 + a + b = 0, and this pair makes that come to 2."}]'::jsonb,
 2, 'sub-remainder-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 35, 'Advanced',
 'Which of these is a possible rational zero of 3x³ - 5x² - 26x - 8?',
 '[{"text": "-1/3", "feedback": "Correct."},
   {"text": "1/2", "feedback": "The denominator has to divide the LEADING coefficient, which is 3. There is no 2 in it."},
   {"text": "3", "feedback": "The numerator has to divide the CONSTANT term, which is -8. 3 does not."},
   {"text": "8/5", "feedback": "The numerator divides 8, which is fine, but the denominator has to divide 3, and 5 does not."}]'::jsonb,
 0, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 36, 'Advanced',
 E'Find the family of quartic polynomials with real roots at 3 (order 2)\nand at 2 plus or minus √2.',
 '[{"text": "y = k(x - 3)²(x² + 4x + 2)", "feedback": "Squaring x - 2 gives a middle term of -4x. The pair of roots sits at positive 2, so the bracket subtracts."},
   {"text": "y = k(x - 3)(x² - 4x + 2)", "feedback": "The root at 3 has order 2, so its bracket appears twice. As written this is only a cubic."},
   {"text": "y = k(x - 3)²(x² - 4x - 2)", "feedback": "Rearranging (x - 2)² = 2 gives x² - 4x + 4 - 2, which leaves +2 on the end."},
   {"text": "y = k(x - 3)²(x² - 4x + 2)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-factor-theorem'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 37, 'Advanced',
 E'A family of cubics has roots -2, -3 and -5. The member passing through\n(2, -35) has what y-intercept?',
 '[{"text": "-30", "feedback": "That is the product of the three roots themselves, not the value of the brackets at x = 0, and no k has been applied."},
   {"text": "-1/4", "feedback": "-1/4 is k itself. The y-intercept is k times the product of the brackets at x = 0."},
   {"text": "-15/2", "feedback": "Correct."},
   {"text": "15/2", "feedback": "k comes out negative, and the three brackets at x = 0 give a positive 30, so the intercept lands below the axis."}]'::jsonb,
 2, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 38, 'Advanced',
 E'A cubic touches the x-axis at -2, crosses it at 1, and has a y-intercept\nof 12. Write its equation.',
 '[{"text": "f(x) = -3(x - 2)²(x + 1)", "feedback": "Both signs are flipped. Touching at -2 comes from the bracket x + 2."},
   {"text": "f(x) = -12(x + 2)²(x - 1)", "feedback": "12 is the y-intercept, not k. Substitute x = 0 and solve for k rather than reading it off."},
   {"text": "f(x) = -3(x + 2)²(x - 1)", "feedback": "Correct."},
   {"text": "f(x) = 3(x + 2)²(x - 1)", "feedback": "At x = 0 the brackets give 4 times -1, which is -4, so k has to be negative to land on a positive 12."}]'::jsonb,
 2, 'sub-poly-equations'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 39, 'Advanced',
 'Why is x² + 1 > 0 for every real value of x?',
 '[{"text": "It is not true; the expression is negative when x is a negative number", "feedback": "Squaring a negative gives a positive, so the negative sign disappears before the 1 is added."},
   {"text": "Because a square is never negative, so the total is always at least 1", "feedback": "Correct."},
   {"text": "Because x² + 1 factors into two real brackets", "feedback": "It does not factor over the reals, and factoring would not settle the sign anyway."},
   {"text": "Because its discriminant is positive", "feedback": "The discriminant here is -4. A NEGATIVE discriminant is what tells you the curve never touches the axis."}]'::jsonb,
 1, 'sub-poly-inequalities'),

(12, 'MHF4U', 'Factoring Polynomials', 2, 40, 'Advanced',
 'Which interval notation matches x < -1 or 1/2 < x < 1?',
 '[{"text": "(-∞, -1) ∪ (1/2, 1)", "feedback": "Correct."},
   {"text": "(-∞, -1] ∪ [1/2, 1]", "feedback": "Every inequality here is strict, so all four ends are excluded and the brackets stay round."},
   {"text": "(-1, 1/2) ∪ (1, ∞)", "feedback": "That is the complement, the part of the line left over."},
   {"text": "(-∞, -1) ∩ (1/2, 1)", "feedback": "An intersection asks for values in BOTH pieces at once, and no number is in both. The word or calls for a union."}]'::jsonb,
 0, 'sub-poly-inequalities');
