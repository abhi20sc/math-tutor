-- ===========================================================================
-- MTH1W — Unit 3: Algebraic Expressions — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Communicate with algebra  (terms, coefficient, degree,
--             classifying polynomials, turning sentences into expressions)
--   Lesson 2  Collecting like terms
--   Lesson 3  Adding and subtracting polynomials
--   Lesson 4  Distributive property, distributing variables, nested
--             brackets, and multiplying binomials with FOIL
--
-- The distractors are the slips the worked solutions themselves keep
-- correcting: adding exponents when collecting like terms, distributing the
-- minus sign to only the first term inside a bracket, forgetting the inside
-- product in FOIL, and reading the degree of a polynomial off a single
-- exponent instead of the sum on the highest term.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Algebraic expressions';

insert into misconception_labels (tag, label) values
  ('sub-algebra-terms',     'Terms, degree and naming polynomials'),
  ('sub-like-terms',        'Collecting like terms'),
  ('sub-poly-add-sub',      'Adding and subtracting polynomials'),
  ('sub-distributive',      'Distributive property'),
  ('sub-binomial-product',  'Multiplying binomials')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 1, 'Easy',
 'The depth of a falling stone after t seconds is given by the term -4.9t^2. What is the coefficient of that term?',
 '[{"text": "-4.9", "feedback": "Correct."},
   {"text": "4.9", "feedback": "The minus sign belongs to the coefficient. It is not separate from it."},
   {"text": "t^2", "feedback": "That is the variable part. The coefficient is the number multiplying it."},
   {"text": "2", "feedback": "That is the exponent on the variable, not the number in front."}]'::jsonb,
 0, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 2, 'Easy',
 'What is the degree of the term -2a^2b?',
 '[{"text": "2", "feedback": "That used only the exponent on a. The degree adds the exponents on every variable."},
   {"text": "3", "feedback": "Correct."},
   {"text": "1", "feedback": "That counted only the b. Every variable in the term contributes."},
   {"text": "0", "feedback": "Only a constant has degree 0. This term has variables in it."}]'::jsonb,
 1, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 3, 'Easy',
 'In the expression 7 + 3x + 3y - 2xy - 1, which pair are like terms?',
 '[{"text": "3x and 3y", "feedback": "The coefficients match, but the variables do not. Like terms need the same variable."},
   {"text": "3x and -2xy", "feedback": "Both contain x, but one also carries a y. Every variable has to match."},
   {"text": "7 and -1", "feedback": "Correct."},
   {"text": "3y and -2xy", "feedback": "Both contain y, but one also carries an x. Every variable has to match."}]'::jsonb,
 2, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 4, 'Easy',
 'Simplify 3x + 4x.',
 '[{"text": "7", "feedback": "The variable does not disappear. It is carried through unchanged."},
   {"text": "12x", "feedback": "The coefficients were multiplied. Collecting like terms adds them."},
   {"text": "7x^2", "feedback": "The coefficients are right, but the variable stays as it is. Only the numbers in front combine."},
   {"text": "7x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 5, 'Easy',
 'Simplify (4x + 3) + (7x + 2).',
 '[{"text": "-3x + 1", "feedback": "That subtracted the second bracket. The operator between them is a plus."},
   {"text": "11x^2 + 5", "feedback": "The exponents were added along with the coefficients. Only the coefficients combine."},
   {"text": "11x + 5", "feedback": "Correct."},
   {"text": "16x", "feedback": "The constants were folded into the x term. A number and an x term are not like terms."}]'::jsonb,
 2, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 6, 'Easy',
 'Simplify (3y + 5) + (7y - 4).',
 '[{"text": "10y + 9", "feedback": "The -4 was treated as a positive 4. Keep the sign that sits in front of it."},
   {"text": "10y + 1", "feedback": "Correct."},
   {"text": "10y - 1", "feedback": "The constants were combined the wrong way round. Start from the 5."},
   {"text": "4y + 1", "feedback": "The y terms were subtracted. Both brackets are being added."}]'::jsonb,
 1, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 7, 'Easy',
 'Expand 5(x + 4).',
 '[{"text": "9x", "feedback": "The 5 and the 4 were added and the bracket dropped. Distributing multiplies, it does not add."},
   {"text": "x + 20", "feedback": "Only the second term inside was multiplied. The 5 reaches both."},
   {"text": "5x + 4", "feedback": "Only the first term inside was multiplied. The 5 reaches every term in the bracket."},
   {"text": "5x + 20", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 8, 'Easy',
 'Expand -2(7x - 4).',
 '[{"text": "-14x - 8", "feedback": "A negative times a negative gives a positive. Check the sign on the second term."},
   {"text": "14x - 8", "feedback": "The minus in front of the 2 was dropped before distributing."},
   {"text": "-14x - 4", "feedback": "Only the first term inside was multiplied. The -2 reaches both."},
   {"text": "-14x + 8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 9, 'Easy',
 'Expand and simplify (x + 2)(x + 3).',
 '[{"text": "x^2 + 5x + 6", "feedback": "Correct."},
   {"text": "x^2 + 6x + 5", "feedback": "The middle number and the last number have been swapped. The two constants multiply, they do not add."},
   {"text": "2x + 5", "feedback": "The brackets were added rather than multiplied."},
   {"text": "x^2 + 6", "feedback": "Only the first terms and the last terms were multiplied. FOIL has four products, not two."}]'::jsonb,
 0, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 10, 'Easy',
 'Expand and simplify (x + 4)(x - 5).',
 '[{"text": "x^2 - x - 20", "feedback": "Correct."},
   {"text": "x^2 + x - 20", "feedback": "The two middle products are -5x and +4x. Check which one is larger."},
   {"text": "x^2 - 20", "feedback": "The outside and inside products were left out. They do not cancel here."},
   {"text": "x^2 - 9x - 20", "feedback": "The middle products were added as if both were negative. Only one of them is."}]'::jsonb,
 0, 'sub-binomial-product'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 11, 'Medium',
 'What is the degree of the polynomial 7x^2y^4 + x^6y?',
 '[{"text": "7", "feedback": "Correct."},
   {"text": "13", "feedback": "That added the exponents across the whole polynomial. Only the highest term counts."},
   {"text": "2", "feedback": "That counted the terms. The number of terms names the polynomial, it does not give the degree."},
   {"text": "6", "feedback": "That is the largest single exponent. Add the exponents within each term first, then compare the terms."}]'::jsonb,
 0, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 12, 'Medium',
 'Write an algebraic expression for 10 times the result of 6 less than x.',
 '[{"text": "6 - 10x", "feedback": "Both the order and the bracket are lost here. Multiply the whole result by 10."},
   {"text": "10x - 6", "feedback": "That takes 6 off after multiplying. The subtraction happens first, so it needs a bracket."},
   {"text": "10(6 - x)", "feedback": "6 less than x means x take away 6, not the other way round."},
   {"text": "10(x - 6)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 13, 'Medium',
 'Simplify 2b - b + 7 - 8 + 3b.',
 '[{"text": "5b - 1", "feedback": "The -b was dropped instead of subtracted."},
   {"text": "6b - 1", "feedback": "The -b was counted as +b. A lone b in front of a minus sign carries a coefficient of -1."},
   {"text": "4b - 1", "feedback": "Correct."},
   {"text": "4b - 15", "feedback": "The 7 and the 8 were both taken as negative. Only the 8 has a minus in front of it."}]'::jsonb,
 2, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 14, 'Medium',
 'Simplify 3x^2 + 2 - 6x + 9x - 3x^2.',
 '[{"text": "3x^2 + 3x + 2", "feedback": "Only one squared term was used. There are two, and they cancel each other."},
   {"text": "-3x + 2", "feedback": "The x terms were combined the wrong way round. Start from the -6x and add 9x."},
   {"text": "3x + 2", "feedback": "Correct."},
   {"text": "6x^4 + 3x + 2", "feedback": "The two squared terms were combined by adding exponents. They are like terms, so their coefficients add and cancel."}]'::jsonb,
 2, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 15, 'Medium',
 'Simplify (4x + 3) - (7x + 2).',
 '[{"text": "-3x + 1", "feedback": "Correct."},
   {"text": "-3x + 5", "feedback": "The subtraction reached the 7x but not the 2. Every term in the second bracket changes sign."},
   {"text": "11x + 5", "feedback": "The brackets were added. The operator between them is a minus."},
   {"text": "3x + 1", "feedback": "The x terms were subtracted the wrong way round. Start from the 4x."}]'::jsonb,
 0, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 16, 'Medium',
 'Simplify (6x - 12) + (-9x - 4) + (x + 14).',
 '[{"text": "-2x - 30", "feedback": "All three constants were taken as negative. The 14 is being added."},
   {"text": "16x - 2", "feedback": "The minus on the 9x was dropped. Keep the sign attached to the term."},
   {"text": "-4x - 2", "feedback": "The final x was subtracted rather than added."},
   {"text": "-2x - 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 17, 'Medium',
 'Expand -3(2x^2 - 5x + 4).',
 '[{"text": "-6x^2 + 15x - 12", "feedback": "Correct."},
   {"text": "-6x^2 + 15x + 12", "feedback": "The first two signs are right. Check the last one: -3 times +4."},
   {"text": "-6x^2 - 5x + 4", "feedback": "Only the first term was multiplied. The -3 reaches all three terms."},
   {"text": "-6x^2 - 15x - 12", "feedback": "Every term was multiplied, but the signs inside the bracket were ignored. A negative times a negative is positive."}]'::jsonb,
 0, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 18, 'Medium',
 'Expand and simplify 2(6m - 3) + 3(16 + 4m).',
 '[{"text": "24m - 42", "feedback": "The constants were combined the wrong way round. The 48 is larger than the 6."},
   {"text": "24m + 54", "feedback": "The -3 was added instead of subtracted. 48 take away 6 is not 54."},
   {"text": "12m + 42", "feedback": "The 3 never reached the 4m. Both terms inside the second bracket get multiplied."},
   {"text": "24m + 42", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 19, 'Medium',
 'Expand and simplify (3x + 1)(2x + 7).',
 '[{"text": "6x^2 + 23x + 8", "feedback": "The two constants were added at the end rather than multiplied."},
   {"text": "6x^2 + 23x + 7", "feedback": "Correct."},
   {"text": "5x + 8", "feedback": "The brackets were added rather than multiplied out."},
   {"text": "6x^2 + 21x + 7", "feedback": "The inside product was left out. 1 times 2x also belongs in the middle."}]'::jsonb,
 1, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 20, 'Medium',
 'Expand and simplify (2x - 3)(x + 5).',
 '[{"text": "2x^2 - 15", "feedback": "The outside and inside products were left out. They do not cancel here."},
   {"text": "2x^2 + 7x - 15", "feedback": "Correct."},
   {"text": "2x^2 - 7x - 15", "feedback": "The middle products are +10x and -3x. Check which one is larger."},
   {"text": "2x^2 + 13x - 15", "feedback": "The middle products were added as if both were positive. The -3 stays negative."}]'::jsonb,
 1, 'sub-binomial-product'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 21, 'Challenge',
 'A golf instructor earns 5000 dollars for the season, plus 20 dollars for each childrens lesson (C) and 30 dollars for each adult lesson (A). His earnings are E = 20C + 30A + 5000. What does he earn after 8 childrens lessons and 6 adult lessons?',
 '[{"text": "340 dollars in total", "feedback": "The 5000 dollar season fee was left out of the total."},
   {"text": "5700 dollars", "feedback": "The two rates were added and applied to all 14 lessons. Each rate belongs to its own lesson type."},
   {"text": "5340 dollars", "feedback": "Correct."},
   {"text": "5360 dollars", "feedback": "The two lesson counts were swapped. The 8 goes with the 20 dollar rate."}]'::jsonb,
 2, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 22, 'Challenge',
 'What is the degree of the polynomial 3x^2y^4 + 11x^2y^2 + y^5?',
 '[{"text": "15", "feedback": "That added the exponents across every term. Only the highest term decides."},
   {"text": "6", "feedback": "Correct."},
   {"text": "5", "feedback": "That is the degree of the last term. Another term adds up higher."},
   {"text": "4", "feedback": "That is the largest single exponent, not the largest sum on one term."}]'::jsonb,
 1, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 23, 'Challenge',
 'Simplify a^2b + 2ab - ab^2 + 2ab^2 - 3ab + a^2b.',
 '[{"text": "2a^2b^2 + ab^2 - ab", "feedback": "The exponents were added when the a^2b terms were collected. Only the coefficients combine."},
   {"text": "2a^2b + ab^2 - ab", "feedback": "Correct."},
   {"text": "2a^2b - ab^2 - ab", "feedback": "The two ab^2 terms were combined the wrong way round. Start from the -1 and add 2."},
   {"text": "2a^2b + ab^2 + ab", "feedback": "The ab terms were combined the wrong way round. 2 take away 3 is negative."}]'::jsonb,
 1, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 24, 'Challenge',
 'Simplify 2x^2 - 3y^2 + xy + 2y^2 - 8x^3, writing the terms in descending order of degree.',
 '[{"text": "-8x^3 + 2x^2 + y^2 + xy", "feedback": "The y^2 terms were combined the wrong way round. Start from the -3."},
   {"text": "-8x^3 + 2x^2 - 5y^2 + xy", "feedback": "The two y^2 terms were both taken as negative. The second one is being added."},
   {"text": "-6x^5 - y^2 + xy", "feedback": "The x^3 and x^2 terms were combined. Different exponents means they are not like terms."},
   {"text": "-8x^3 + 2x^2 - y^2 + xy", "feedback": "Correct."}]'::jsonb,
 3, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 25, 'Challenge',
 'Simplify (a^2 - 2a + 1) - (-a^2 - 2a - 5).',
 '[{"text": "-4a - 4", "feedback": "The brackets were simply dropped. Subtracting flips the sign of every term in the second bracket."},
   {"text": "2a^2 - 4a + 6", "feedback": "The squared terms and the constants were flipped, but the -2a was not. It becomes +2a and cancels."},
   {"text": "2a^2 + 6", "feedback": "Correct."},
   {"text": "2a^2 - 4", "feedback": "The constants were subtracted as 1 take away 5. Subtracting a negative 5 adds it."}]'::jsonb,
 2, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 26, 'Challenge',
 'Simplify (3x + y - 4z) - (7x + 3y - 2z).',
 '[{"text": "4x + 2y + 2z", "feedback": "Each pair was subtracted the wrong way round. Start from the first bracket every time."},
   {"text": "-4x - 2y - 6z", "feedback": "The subtraction reached the first two terms but not the -2z. It becomes +2z."},
   {"text": "-4x - 2y - 2z", "feedback": "Correct."},
   {"text": "10x + 4y - 6z", "feedback": "The brackets were added. The operator between them is a minus."}]'::jsonb,
 2, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 27, 'Challenge',
 'Expand -3x(2x^2 - 5x + 4).',
 '[{"text": "-6x^3 + 15x^2 - 12", "feedback": "The last term lost its x. Multiplying 4 by -3x still leaves an x behind."},
   {"text": "-6x^3 - 15x^2 - 12x", "feedback": "The powers are right, but the signs inside the bracket were ignored."},
   {"text": "-6x^2 + 15x - 12", "feedback": "The x in the -3x was never multiplied through. Each exponent should climb by one."},
   {"text": "-6x^3 + 15x^2 - 12x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 28, 'Challenge',
 'Expand and simplify 3m(m - 5) - (2m^2 - m).',
 '[{"text": "5m^2 - 16m", "feedback": "The second bracket was added rather than subtracted."},
   {"text": "3m^2 - 14m", "feedback": "The 2m^2 was never taken off. It cancels most of the 3m^2."},
   {"text": "m^2 - 14m", "feedback": "Correct."},
   {"text": "m^2 - 16m", "feedback": "The -m in the second bracket was not flipped. Subtracting it adds an m back."}]'::jsonb,
 2, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 29, 'Challenge',
 'Expand and simplify (x - 4)^2.',
 '[{"text": "x^2 - 8x + 16", "feedback": "Correct."},
   {"text": "x^2 - 8x - 16", "feedback": "The middle term is right. The last term is -4 times -4, which is positive."},
   {"text": "x^2 + 16", "feedback": "Each term was squared on its own. Squaring a bracket means multiplying it by itself, which gives a middle term."},
   {"text": "x^2 - 16", "feedback": "That is what (x - 4)(x + 4) gives. A square is the same bracket twice, so the middle products do not cancel."}]'::jsonb,
 0, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 30, 'Challenge',
 'Expand and simplify (2x + 3)(2x - 3).',
 '[{"text": "2x^2 - 9", "feedback": "The first product is 2x times 2x, not 2x times x."},
   {"text": "4x^2 - 9", "feedback": "Correct."},
   {"text": "4x^2 + 9", "feedback": "The last product is +3 times -3, which is negative."},
   {"text": "4x^2 + 12x - 9", "feedback": "The two middle products are -6x and +6x. They cancel."}]'::jsonb,
 1, 'sub-binomial-product'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Algebraic expressions', 3, 31, 'Advanced',
 'A polynomial has four terms, and its highest degree term is 5x^2y^3. Which description is correct?',
 '[{"text": "A polynomial with three terms and degree 5", "feedback": "The degree is right, but this polynomial has four terms, not three, so it is not a trinomial."},
   {"text": "A polynomial with four terms and degree 6", "feedback": "The exponents were multiplied. Degree adds them."},
   {"text": "A polynomial with four terms and degree 5", "feedback": "Correct."},
   {"text": "A polynomial with four terms and degree 3", "feedback": "That used only the exponent on y. Add the exponents on every variable in the term."}]'::jsonb,
 2, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 32, 'Advanced',
 'A four-sided shape has sides of length 18x + 7, 9x - 2, 3x + 5 and 3x + 5. What is its perimeter when x = 5?',
 '[{"text": "184", "feedback": "The -2 was treated as a positive 2 when the constants were collected."},
   {"text": "180", "feedback": "Correct."},
   {"text": "48", "feedback": "The 33 and the 15 were added straight away. The 33 has to be multiplied by x first."},
   {"text": "165", "feedback": "The x terms collect to 33x, but the constants were dropped. They collect to 15."}]'::jsonb,
 1, 'sub-algebra-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 33, 'Advanced',
 'Which of these expressions cannot be simplified any further?',
 '[{"text": "4xy + 6xy", "feedback": "Both terms carry exactly x and y, so they are like terms and combine."},
   {"text": "3x + 4x^2", "feedback": "Correct."},
   {"text": "9 - 4 + 2", "feedback": "These are all constants, which are always like terms."},
   {"text": "5a + 2a", "feedback": "Both terms are plain a terms, so their coefficients add."}]'::jsonb,
 1, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 34, 'Advanced',
 'Simplify 5p^2q - 3pq^2 + 2p^2q + 4pq^2 - p^2q.',
 '[{"text": "6p^2q + pq^2", "feedback": "Correct."},
   {"text": "6p^2q - pq^2", "feedback": "The pq^2 terms were combined the wrong way round. Start from the -3 and add 4."},
   {"text": "7p^2q + pq^2", "feedback": "The last term was added rather than subtracted. A lone p^2q behind a minus sign has coefficient -1."},
   {"text": "6p^3q^3 + pq^2", "feedback": "The exponents were added when the p^2q terms were collected. Only the coefficients combine."}]'::jsonb,
 0, 'sub-like-terms'),

(9, 'MTH1W', 'Algebraic expressions', 3, 35, 'Advanced',
 'Three players have year end salaries of 100000 + 25x, 75000 + 18x and 90000 + 10x, where x is the bonus paid per goal. What is the total paid when x = 10000?',
 '[{"text": "795000 dollars", "feedback": "Correct."},
   {"text": "318000 dollars", "feedback": "The bonus was worked out as 53 times 10000 = 53000. Count the zeros again."},
   {"text": "530000 dollars", "feedback": "That is the bonus money only. The three base salaries still have to be added on."},
   {"text": "265000 dollars", "feedback": "That is the base salaries only. The bonuses still have to be added on."}]'::jsonb,
 0, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 36, 'Advanced',
 'Simplify (5x - 4y - 1) + (-2x + 5y + 13) - (x - y + 2).',
 '[{"text": "2x + 2y + 10", "feedback": "Correct."},
   {"text": "4x + 14", "feedback": "The third bracket was added rather than subtracted. Every term inside it changes sign."},
   {"text": "2x + 10", "feedback": "The -y stayed negative, so the y terms cancelled. Subtracting a negative y adds a y."},
   {"text": "2x + 2y + 12", "feedback": "The 2 in the last bracket was dropped instead of subtracted."}]'::jsonb,
 0, 'sub-poly-add-sub'),

(9, 'MTH1W', 'Algebraic expressions', 3, 37, 'Advanced',
 'Expand and simplify 3[2 + 5(2k - 1)].',
 '[{"text": "30k + 3", "feedback": "The 5 was multiplied by the k term but not by the -1. Inside the square bracket that leaves 2 + 10k - 1."},
   {"text": "30k - 9", "feedback": "Correct."},
   {"text": "10k - 3", "feedback": "The inner bracket was expanded correctly, but the outer 3 was never distributed."},
   {"text": "30k - 3", "feedback": "The outer 3 reached the k term but not the constant. It multiplies everything inside."}]'::jsonb,
 1, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 38, 'Advanced',
 'Expand and simplify -2[3x - (4 - 2y)] + 5[y - 2(x + 1)].',
 '[{"text": "-16x + 9y - 2", "feedback": "Inside the first square bracket, subtracting (4 - 2y) gives -4 + 2y. The sign on the 2y was missed."},
   {"text": "-16x + y + 3", "feedback": "In the second square bracket the -2 reached the x but not the 1. It multiplies both."},
   {"text": "-16x + y - 2", "feedback": "Correct."},
   {"text": "-16x - y - 2", "feedback": "The y terms are -4y and +5y. Check which one is larger."}]'::jsonb,
 2, 'sub-distributive'),

(9, 'MTH1W', 'Algebraic expressions', 3, 39, 'Advanced',
 'Expand and simplify (2x - 5)(3x + 4) - (x + 2)(x - 3).',
 '[{"text": "7x^2 - 8x - 26", "feedback": "The second product was added. The minus in front of it flips every term."},
   {"text": "5x^2 - 8x - 26", "feedback": "The subtraction reached the x^2 term but not the rest of the second product."},
   {"text": "5x^2 - 6x - 26", "feedback": "The x terms are handled, but the -6 was not flipped. Subtracting it adds 6."},
   {"text": "5x^2 - 6x - 14", "feedback": "Correct."}]'::jsonb,
 3, 'sub-binomial-product'),

(9, 'MTH1W', 'Algebraic expressions', 3, 40, 'Advanced',
 'Expand and simplify (x + 3)(x^2 - 2x + 5).',
 '[{"text": "x^3 + 15", "feedback": "Only the first terms and the last terms were multiplied. Each term in the first bracket meets all three in the second."},
   {"text": "x^3 + 5x^2 - x + 15", "feedback": "The squared terms are -2x^2 and +3x^2. They were added as if both were positive."},
   {"text": "x^3 + x^2 + 11x + 15", "feedback": "The x terms are +5x and -6x. The 3 times -2x product stays negative."},
   {"text": "x^3 + x^2 - x + 15", "feedback": "Correct."}]'::jsonb,
 3, 'sub-binomial-product');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Algebraic expressions'
group by difficulty order by min(sort_order);
