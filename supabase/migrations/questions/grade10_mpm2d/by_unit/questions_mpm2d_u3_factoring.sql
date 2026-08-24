-- ===========================================================================
-- ASTRO MATH ASSIST — GRADE 10 (MPM2D), complete
-- ===========================================================================
--
-- 240 questions across six units, plus the 33 figures that attach to them.
-- Questions and figures used to be two files that had to be run in order,
-- and running the second one was easy to forget — which showed up as
-- questions that reference a diagram nobody can see. They are one file now.
--
-- RUN ORDER:  supabase_full_setup.sql  ->  this file.
--
-- Safe to re-run on its own at any time: each unit is deleted and reinserted,
-- and the figures are reattached at the end. Student attempts are NOT touched
-- by this file — they live in attempts and unit_mastery, keyed on course, unit
-- and sort_order, so a corrected question keeps its history.
--
-- ---------------------------------------------------------------------------
-- The six units
-- ---------------------------------------------------------------------------
--   1  Linear systems                 40
--   2  Analytic geometry              40
--   3  Factoring                      40
--   4  Quadratics                     40
--   5  Solving quadratic equations    40
--   6  Trigonometry                   40
--
-- Each unit is 10 Easy, 10 Medium, 10 Challenge, 10 Advanced, in sort_order
-- 1-40. Easy and Medium are free; Challenge and Advanced need Astro+, and
-- that is enforced in the database, not in the app.
--
-- ---------------------------------------------------------------------------
-- The figures
-- ---------------------------------------------------------------------------
-- 33 PNGs, mostly Trigonometry. They live in web/figures/ and ship inside
-- every deploy, so this file only stores the path. A null figure renders no
-- image; a missing file shows a short "could not load" line rather than a
-- broken icon.
--
-- Every figure was measured against a ruler before it shipped: if a student
-- could get the answer by measuring the drawing instead of doing the
-- mathematics, the figure is wrong, however pretty it looks. Two were caught
-- and redrawn by that test.
--
-- ---------------------------------------------------------------------------
-- What a question owes the student
-- ---------------------------------------------------------------------------
-- Every wrong option is a SPECIFIC mistake, and its feedback names the
-- mistake without revealing the answer. "Not quite, try again" is not
-- feedback. Neither is anything that states the correct value.
-- ===========================================================================

-- This file loads ONE unit of MPM2D. It deletes only that unit, so the
-- other five are untouched. Run figures_grade10.sql after all six.

delete from questions where course_code = 'MPM2D' and unit = 'Factoring';

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

(10, 'MPM2D', 'Factoring', 3, 1, 'Easy',
 'Expand: (x + 3)(x + 2)',
 '[{"text": "x² + 5", "feedback": "The outer and inner products make a middle term. FOIL has four products, not two."}, {"text": "x² + 5x + 6", "feedback": "Correct."}, {"text": "x² + 6x + 5", "feedback": "The middle term is the SUM 3 + 2 and the last is the PRODUCT 3 times 2. They are swapped here."}, {"text": "x² + 6x + 6", "feedback": "The x terms add to 5x: 3x from the inner and 2x from the outer."}]'::jsonb, 1, 'sub-multiplying-binomials'),

(10, 'MPM2D', 'Factoring', 3, 2, 'Easy',
 'Expand: (x - 4)(x + 1)',
 '[{"text": "x² - 4x - 4", "feedback": "The middle term collects BOTH cross products: -4x plus 1x."}, {"text": "x² - 3x + 4", "feedback": "The last term is -4 times +1, and a negative times a positive stays negative."}, {"text": "x² - 3x - 4", "feedback": "Correct."}, {"text": "x² + 3x - 4", "feedback": "The -4 outweighs the +1: the middle term is -4x + x, which is negative."}]'::jsonb, 2, 'sub-multiplying-binomials'),

(10, 'MPM2D', 'Factoring', 3, 3, 'Easy',
 'Simplify: (3x)(4x)',
 '[{"text": "12x²", "feedback": "Correct."}, {"text": "12x", "feedback": "The variables multiply too: x times x is x squared."}, {"text": "7x", "feedback": "Both the coefficients and the variables were added instead of multiplied."}, {"text": "7x²", "feedback": "The coefficients MULTIPLY: 3 times 4. Adding them belongs to 3x + 4x."}]'::jsonb, 0, 'sub-multiplying-binomials'),

(10, 'MPM2D', 'Factoring', 3, 4, 'Easy',
 'What is the greatest common factor of 12x³ and 18x²?',
 '[{"text": "2x", "feedback": "2 divides both but is not the GREATEST number that does. 6 is."}, {"text": "6x³", "feedback": "The variable part takes the LOWEST power the terms share. 12x³ has x³ but 18x² does not."}, {"text": "36x²", "feedback": "36 is a common MULTIPLE of 12 and 18. The greatest common factor of them is 6."}, {"text": "6x²", "feedback": "Correct."}]'::jsonb, 3, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 5, 'Easy',
 'Factor: 5x + 20',
 '[{"text": "x(5 + 20)", "feedback": "x is not a factor of the plain number 20. Only the 5 is common to both terms."}, {"text": "5(x + 15)", "feedback": "That takes 5 away from the 20 instead of dividing it by the common factor."}, {"text": "5(x + 4)", "feedback": "Correct."}, {"text": "5(x + 20)", "feedback": "After removing the 5, the 20 divides by it too: 20 over 5 is 4."}]'::jsonb, 2, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 6, 'Easy',
 'Factor completely: 8x² - 6x',
 '[{"text": "2(4x² - 3x)", "feedback": "An x is still common inside the brackets. The greatest common factor includes it."}, {"text": "2x(4x - 6)", "feedback": "The 6x divides by the FULL common factor 2x, leaving 3, not 6."}, {"text": "x(8x - 6)", "feedback": "The 2 is still common inside. Take out the greatest common factor, 2x, in one step."}, {"text": "2x(4x - 3)", "feedback": "Correct."}]'::jsonb, 3, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 7, 'Easy',
 'To factor x² + 7x + 12, what two numbers are needed?',
 '[{"text": "Numbers that add to 12 and multiply to give 7", "feedback": "The roles are swapped: the middle coefficient is the SUM, the constant is the PRODUCT."}, {"text": "Numbers that add to 7 and multiply to 12", "feedback": "Correct."}, {"text": "Numbers that subtract to 7 and divide to 12", "feedback": "The pattern from expanding (x + m)(x + n) is add and multiply."}, {"text": "Numbers that both divide 7 without a remainder", "feedback": "7 is prime — this rule would find nothing. The pair works with 7 and 12 together."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 8, 'Easy',
 'Factor: x² + 7x + 12',
 '[{"text": "(x + 7)(x + 12)", "feedback": "Those are the coefficients themselves. Expanding gives x² + 19x + 84 — much too big."}, {"text": "(x + 1)(x + 12)", "feedback": "1 and 12 add to 13, not 7. Try the factor pairs of 12 until one sums to 7."}, {"text": "(x + 3)(x + 4)", "feedback": "Correct."}, {"text": "(x + 6)(x + 2)", "feedback": "6 and 2 multiply to 12 but add to 8. Both conditions must hold at once."}]'::jsonb, 2, 'sub-factoring-simple-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 9, 'Easy',
 'Which expression is a difference of squares?',
 '[{"text": "x² + 49", "feedback": "A SUM of squares does not factor over the integers. The pattern needs a subtraction."}, {"text": "x³ - 49", "feedback": "The powers must be squares too — x³ is not one."}, {"text": "x² - 49", "feedback": "Correct."}, {"text": "x² - 48", "feedback": "48 is not a perfect square. Both terms must be squares."}]'::jsonb, 2, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 10, 'Easy',
 'Factor: x² - 49',
 '[{"text": "(x - 7)(x + 7)", "feedback": "Correct."}, {"text": "(x - 7)(x - 7)", "feedback": "Both signs negative gives +49 at the end, not -49. The signs must differ."}, {"text": "(x + 7)(x + 7)", "feedback": "Two positive signs give +49 at the end and a middle term of +14x. A difference of squares has NO middle term."}, {"text": "(x - 49)(x + 1)", "feedback": "Those multiply to x² - 48x - 49. Take the square root of each term instead: x and 7."}]'::jsonb, 0, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 11, 'Medium',
 'Expand and simplify: (2x + 3)(x - 5)',
 '[{"text": "2x² - 7x - 15", "feedback": "Correct."}, {"text": "2x² - 10x - 15", "feedback": "The inner product 3x is missing. All four FOIL products count."}, {"text": "2x² + 7x - 15", "feedback": "The outer product -10x outweighs the inner +3x. The middle term is negative."}, {"text": "2x² - 7x + 15", "feedback": "+3 times -5 is -15. A positive times a negative stays negative."}]'::jsonb, 0, 'sub-multiplying-binomials'),

(10, 'MPM2D', 'Factoring', 3, 12, 'Medium',
 'Expand: (x + 4)²',
 '[{"text": "x² + 16", "feedback": "Squaring a binomial produces a middle term: 2 times x times 4. The square does not distribute onto each term."}, {"text": "x² + 8x + 8", "feedback": "The last term is 4 squared, which is 16."}, {"text": "x² + 4x + 16", "feedback": "The middle term is TWICE the product of x and 4."}, {"text": "x² + 8x + 16", "feedback": "Correct."}]'::jsonb, 3, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 13, 'Medium',
 'Factor completely: 21x³y² - 28x²y⁴ + 7x²y²',
 '[{"text": "7x²y²(3x - 4y²)", "feedback": "Removing the factor from the LAST term leaves 1, which must stay in the brackets — three terms in, three out."}, {"text": "7x²y²(3x - 4y² + 1)", "feedback": "Correct."}, {"text": "7x²y²(3x + 4y² + 1)", "feedback": "The common factor comes out positive, so the sign in front of each term is unchanged. The middle term is still subtracted."}, {"text": "7xy(3x²y - 4xy³ + xy)", "feedback": "A bigger factor is available: every term carries x² and y², not just x and y."}]'::jsonb, 1, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 14, 'Medium',
 'Factor: x² - 2x - 15',
 '[{"text": "(x + 5)(x - 3)", "feedback": "Those add to +2, not -2. The LARGER number takes the negative sign here."}, {"text": "(x - 5)(x - 3)", "feedback": "Two negatives multiply to +15, but the constant is -15. The signs must differ."}, {"text": "(x - 15)(x + 1)", "feedback": "-15 and 1 multiply correctly but add to -14. Both conditions must hold."}, {"text": "(x - 5)(x + 3)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-simple-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 15, 'Medium',
 'Factor: x² - 10x + 24',
 '[{"text": "(x - 4)(x - 6)", "feedback": "Correct."}, {"text": "(x - 12)(x + 2)", "feedback": "-12 and 2 multiply to -24, not +24. The constant is positive."}, {"text": "(x + 4)(x + 6)", "feedback": "A positive product with a NEGATIVE sum needs two negative numbers."}, {"text": "(x - 8)(x - 3)", "feedback": "-8 times -3 is 24, but they add to -11, not -10. Keep testing pairs until the sum matches too."}]'::jsonb, 0, 'sub-factoring-simple-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 16, 'Medium',
 'To factor 3x² + 10x + 8 by decomposition, the middle term splits using two numbers with what properties?',
 '[{"text": "Sum 10 and product 24", "feedback": "Correct."}, {"text": "Sum 13 and product 24", "feedback": "The 3 does not join the sum. It only enters through the product a times c."}, {"text": "Sum 8 and product 30", "feedback": "The sum matches the MIDDLE coefficient, 10. The product uses 3 times 8."}, {"text": "Sum 10 and product 8", "feedback": "The product target is a times c — 3 times 8 — once the leading coefficient is not 1."}]'::jsonb, 0, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 17, 'Medium',
 'Factor: 3x² + 10x + 8',
 '[{"text": "(x + 4)(x + 6)", "feedback": "The leading term must be 3x², so one factor carries the 3x."}, {"text": "(3x + 4)(x + 2)", "feedback": "Correct."}, {"text": "(3x + 2)(x + 4)", "feedback": "Check the middle term: 12x + 2x gives 14x, not 10x. Expand to verify."}, {"text": "(3x + 8)(x + 1)", "feedback": "That expands to a middle term of 11x. The split 6x + 4x is the one that groups."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 18, 'Medium',
 'Factor: 2x² - 7x + 6',
 '[{"text": "(2x - 6)(x - 1)", "feedback": "A common factor of 2 hides in (2x - 6) that the original does not have. Expand and compare."}, {"text": "(2x - 1)(x - 6)", "feedback": "That gives a middle term of -13x. The split of -7x is -3x and -4x."}, {"text": "(2x - 3)(x - 2)", "feedback": "Correct."}, {"text": "(2x + 3)(x + 2)", "feedback": "A positive constant with a NEGATIVE middle term needs both signs negative."}]'::jsonb, 2, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 19, 'Medium',
 'Factor: 9x² - 25',
 '[{"text": "(3x - 25)(3x + 1)", "feedback": "A difference of squares splits into root minus root and root plus root: 3x and 5."}, {"text": "(3x - 5)(3x + 5)", "feedback": "Correct."}, {"text": "(9x - 25)(9x + 25)", "feedback": "The square roots of the terms go in the brackets: √(9x²) is 3x, not 9x."}, {"text": "(3x - 5)²", "feedback": "A square produces a middle term -30x. This expression has no middle term."}]'::jsonb, 1, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 20, 'Medium',
 'Factor: x² + 12x + 36',
 '[{"text": "(x + 6)(x - 6)", "feedback": "That is the pattern for x² MINUS 36. Here the middle term +12x signals a perfect square."}, {"text": "(x + 4)(x + 9)", "feedback": "4 and 9 multiply to 36 but add to 13, not 12, so this pair misses the middle term."}, {"text": "(x + 6)²", "feedback": "Correct."}, {"text": "(x + 12)(x + 3)", "feedback": "Check the product: 12 times 3 is 36, but the sum is 15, not 12."}]'::jsonb, 2, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 21, 'Challenge',
 'Simplify: 2(6m² - mn + 4) - (7m² + 4mn - 2)',
 '[{"text": "5m² - 6mn + 10", "feedback": "Correct."}, {"text": "5m² + 2mn + 10", "feedback": "The subtraction flips EVERY sign in the second bracket, including +4mn to -4mn."}, {"text": "5m² - 5mn + 6", "feedback": "The 2 multiplies every term inside the first bracket, not just the 6m²."}, {"text": "12m² - 6mn + 10", "feedback": "The 7m² is subtracted as well; the m² terms do not pass through untouched."}]'::jsonb, 0, 'sub-multiplying-binomials'),

(10, 'MPM2D', 'Factoring', 3, 22, 'Challenge',
 'Factor completely: 6x² + 14x + 4',
 '[{"text": "(6x + 2)(x + 2)", "feedback": "The middle term is right, but this is not finished: a whole number still divides through one of the brackets. Look for a common factor before splitting the trinomial."}, {"text": "2(3x + 2)(x + 1)", "feedback": "Expand the brackets: the middle term becomes 5x, and doubled that is 10x, not 14x."}, {"text": "(3x + 1)(2x + 4)", "feedback": "The x-terms are right, but a whole number still divides one of these brackets. Completely factored means nothing is left that can be taken out."}, {"text": "2(3x + 1)(x + 2)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 23, 'Challenge',
 'Factor: 6x² + 13x - 5',
 '[{"text": "(3x - 5)(2x + 1)", "feedback": "Check: 3x - 10x gives -7x, not 13x. Try grouping 6x² + 15x - 2x - 5."}, {"text": "(3x + 1)(2x - 5)", "feedback": "Expand: the middle term comes out as -13x. The signs are on the wrong factors."}, {"text": "(6x - 1)(x + 5)", "feedback": "That gives a middle term of 29x. The split of 13x is 15x - 2x."}, {"text": "(3x - 1)(2x + 5)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 24, 'Challenge',
 'Factor: 4x² - 5xy - 6y²',
 '[{"text": "(4x + 6y)(x - y)", "feedback": "6y and -y do give -6y², but the outer and inner products then add to +2xy, and a factor of 2 is trapped in the first bracket."}, {"text": "(4x + 3y)(x - 2y)", "feedback": "Correct."}, {"text": "(4x - 6y)(x + y)", "feedback": "A common factor of 2 is trapped in the first bracket, and the product of the outside terms is wrong."}, {"text": "(4x - 3y)(x + 2y)", "feedback": "The middle term expands to +5xy with these signs. Flip them."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 25, 'Challenge',
 'Factor completely: 16x² + 26x - 12',
 '[{"text": "2(8x - 3)(x + 2)", "feedback": "Correct."}, {"text": "2(4x - 1)(2x + 6)", "feedback": "Another 2 still hides in (2x + 6), and the middle term does not check out."}, {"text": "2(8x + 3)(x - 2)", "feedback": "Expand: the middle term becomes -13x, doubled -26x. The signs are reversed."}, {"text": "(8x - 3)(2x + 4)", "feedback": "The common factor 2 belongs OUT FRONT, not inside (2x + 4)."}]'::jsonb, 0, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 26, 'Challenge',
 'Factor completely: 3x³ - 27x',
 '[{"text": "3x(x - 3)(x + 3)", "feedback": "Correct."}, {"text": "3x(x² - 9)", "feedback": "x² - 9 is a difference of squares and factors further. Completely means all the way."}, {"text": "3x(x - 3)²", "feedback": "(x - 3)² expands with a middle term -6x. The bracket x² - 9 needs (x - 3)(x + 3)."}, {"text": "3(x³ - 9x)", "feedback": "An x is still common inside. Remove 3x, then factor what remains."}]'::jsonb, 0, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 27, 'Challenge',
 'Factor: 25x² - 30x + 9',
 '[{"text": "(5x - 3)(5x + 3)", "feedback": "That pattern is for 25x² - 9 with NO middle term. Here -30x is exactly twice 5x times 3."}, {"text": "(5x - 3)²", "feedback": "Correct."}, {"text": "(25x - 9)(x - 1)", "feedback": "Perfect square trinomials factor from the roots of the outer terms: 5x and 3."}, {"text": "(5x + 3)²", "feedback": "The middle term of that square is +30x. The -30x needs the negative version."}]'::jsonb, 1, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 28, 'Challenge',
 'Expand: (3x - 2y)²',
 '[{"text": "9x² - 6xy + 4y²", "feedback": "The middle term DOUBLES the product of 3x and 2y: 12xy, not 6xy."}, {"text": "9x² - 12xy - 4y²", "feedback": "The last term is (-2y) squared, and a square is positive."}, {"text": "9x² + 12xy + 4y²", "feedback": "The middle term keeps the minus: 2 times 3x times -2y is negative."}, {"text": "9x² - 12xy + 4y²", "feedback": "Correct."}]'::jsonb, 3, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 29, 'Challenge',
 'Which trinomial does NOT factor over the integers?',
 '[{"text": "x² + 5x + 3", "feedback": "Correct."}, {"text": "x² - 5x + 6", "feedback": "-2 and -3 sum to -5 and multiply to 6, so this trinomial does factor."}, {"text": "x² + 4x + 3", "feedback": "1 and 3 do the job there."}, {"text": "x² + 5x + 4", "feedback": "1 and 4 add to 5 and multiply to 4 — it factors as (x + 1)(x + 4)."}]'::jsonb, 0, 'sub-factoring-simple-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 30, 'Challenge',
 'A rectangle has area x² + 9x + 20. Which dimensions fit?',
 '[{"text": "(x + 2) by (x + 10)", "feedback": "2 and 10 multiply to 20 but add to 12, not 9."}, {"text": "(x + 4) by (x + 5)", "feedback": "Correct."}, {"text": "(x + 4) by (x - 5)", "feedback": "A negative factor would make the last term -20. The area ends in +20."}, {"text": "(x + 9) by (x + 20)", "feedback": "Multiplying those gives x² + 29x + 180 — far too big. Factor the area instead."}]'::jsonb, 1, 'sub-factoring-simple-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 31, 'Advanced',
 'Factor completely: x⁴ - 16',
 '[{"text": "(x - 2)²(x + 2)²", "feedback": "That expands to (x² - 4)², which is x⁴ - 8x² + 16 — a middle term this expression does not have."}, {"text": "(x² - 8)(x² + 2)", "feedback": "The square roots of x⁴ and 16 are x² and 4. Start from (x² - 4)(x² + 4)."}, {"text": "(x² + 4)(x - 2)(x + 2)", "feedback": "Correct."}, {"text": "(x² - 4)(x² + 4)", "feedback": "x² - 4 is itself a difference of squares and splits again. Completely means twice here."}]'::jsonb, 2, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 32, 'Advanced',
 'Factor by grouping: x³ + 3x² + 2x + 6',
 '[{"text": "(x² + 3)(x + 2)", "feedback": "Expand it: the middle terms come out as 2x² + 3x, which is not what the polynomial shows."}, {"text": "(x² + 2)(x + 3)", "feedback": "Correct."}, {"text": "(x + 1)(x + 2)(x + 3)", "feedback": "Expanding that gives x³ + 6x² + 11x + 6. The x² coefficient here is 3."}, {"text": "(x² + 2x)(x + 3)", "feedback": "x² + 2x still holds a common x. The first group contributes x² only, the second the 2."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 33, 'Advanced',
 'For which value of k does x² + kx + 36 become a perfect square trinomial?',
 '[{"text": "36", "feedback": "The middle coefficient is twice the root of 36, not 36 itself."}, {"text": "12 or -12", "feedback": "Correct."}, {"text": "12 only", "feedback": "(x - 6)² works too. The middle term can carry either sign."}, {"text": "6 or -6", "feedback": "Twice the product of x and 6 is 12x. The 2 in 2ab is easy to drop."}]'::jsonb, 1, 'sub-factoring-simple-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 34, 'Advanced',
 'Simplify: (x + 5)(x - 5) - (x - 3)²',
 '[{"text": "6x - 16", "feedback": "The subtraction flips ALL of (x² - 6x + 9), turning +9 into -9: -25 - 9 is -34."}, {"text": "-34", "feedback": "The -(-6x) survives as +6x. Only the x² terms cancel."}, {"text": "2x² + 6x - 34", "feedback": "The x² from the first product and the x² from the square cancel each other."}, {"text": "6x - 34", "feedback": "Correct."}]'::jsonb, 3, 'sub-multiplying-binomials'),

(10, 'MPM2D', 'Factoring', 3, 35, 'Advanced',
 'Factor completely: 2x⁴ - 32',
 '[{"text": "2(x² - 4)(x² + 4)", "feedback": "One more step remains: x² - 4 splits into (x - 2)(x + 2)."}, {"text": "(2x² - 8)(x² + 4)", "feedback": "A 2 is trapped inside the first bracket. Common factor out front first."}, {"text": "2(x² + 4)(x - 2)(x + 2)", "feedback": "Correct."}, {"text": "2(x⁴ - 16)", "feedback": "x⁴ - 16 keeps factoring: it is a difference of squares twice over."}]'::jsonb, 2, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 36, 'Advanced',
 'The area of a square is 4x² + 12x + 9. What is its side length?',
 '[{"text": "2x² + 3", "feedback": "Rooting 4x² halves the EXPONENT: it gives 2x, not 2x²."}, {"text": "4x + 9", "feedback": "The side is the square ROOT of the area, and the root of 4x² is 2x."}, {"text": "2x + 9", "feedback": "The last term of the side is the root of 9, which is 3. Check: the middle term 12x is 2 times 2x times 3."}, {"text": "2x + 3", "feedback": "Correct."}]'::jsonb, 3, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 37, 'Advanced',
 'Factor completely: 12x² - 27',
 '[{"text": "3(2x - 3)²", "feedback": "That square has a middle term -36x when expanded times 3. No middle term exists here."}, {"text": "(6x - 9)(2x + 3)", "feedback": "A common factor of 3 is trapped in the first bracket. Take out the 3 before the squares pattern."}, {"text": "3(2x - 3)(2x + 3)", "feedback": "Correct."}, {"text": "3(4x² - 9)", "feedback": "4x² - 9 is a difference of squares and splits further."}]'::jsonb, 2, 'sub-common-factoring'),

(10, 'MPM2D', 'Factoring', 3, 38, 'Advanced',
 'Which product expands to 6x² - 7x - 20?',
 '[{"text": "(3x + 4)(2x - 5)", "feedback": "Correct."}, {"text": "(6x + 5)(x - 4)", "feedback": "That expands to a middle term of -19x. Split -7x as -15x + 8x and group."}, {"text": "(3x - 5)(2x + 4)", "feedback": "A common factor of 2 hides in (2x + 4), and 6x² - 7x - 20 has none."}, {"text": "(3x - 4)(2x + 5)", "feedback": "The middle term of that one is +7x. The signs sit on the wrong brackets."}]'::jsonb, 0, 'sub-factoring-complex-trinomials'),

(10, 'MPM2D', 'Factoring', 3, 39, 'Advanced',
 'x² - y² = 40 and x - y = 4. What is x + y?',
 '[{"text": "4", "feedback": "4 is x - y, which the question gave. The other bracket is what it asks for."}, {"text": "160", "feedback": "That multiplies the two givens. The factored form says 40 is already a PRODUCT of the two brackets."}, {"text": "10", "feedback": "Correct."}, {"text": "36", "feedback": "x² - y² FACTORS as (x - y)(x + y) — nothing subtracts from the 40."}]'::jsonb, 2, 'sub-special-products'),

(10, 'MPM2D', 'Factoring', 3, 40, 'Advanced',
 'Factor completely: x² y - 4y + x²z - 4z',
 '[{"text": "(x² + 4)(y - z)", "feedback": "Group as y(x² - 4) + z(x² - 4): the shared bracket is x² MINUS 4, and (y + z) collects."}, {"text": "x²(y + z) - 4(y + z)", "feedback": "That is the grouping STEP, not the factored result. Pull out the common bracket."}, {"text": "(x² - 4)(y + z)", "feedback": "x² - 4 keeps factoring — the difference of squares is still whole."}, {"text": "(x - 2)(x + 2)(y + z)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-complex-trinomials');
