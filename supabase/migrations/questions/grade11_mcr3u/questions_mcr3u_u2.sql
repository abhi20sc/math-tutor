-- ===========================================================================
-- MCR3U — Unit 2: Rational Expressions — 40 questions
-- ===========================================================================
-- Grade 11 Rational Expressions, authored from the Jensen MCR3U lesson
-- material for this unit:
--
--   Lesson 1  Review of exponent rules
--   Lesson 2  Rational exponents
--   Lesson 3  Restricting, simplifying, multiplying and dividing
--   Lesson 4  Adding and subtracting rational expressions
--
-- Restrictions are pulled out as their own subtopic rather than being folded
-- into Lesson 3. Stating them is where students in this unit actually lose
-- marks, and it is the one skill that carries forward into every later unit,
-- so it deserves its own traffic light on the dashboard.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every answer in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs. Two of the Jensen
-- worked solutions state an incomplete restriction set part-way through
-- (their own answer keys correct it later) and those omissions are used
-- here as distractors rather than as answers.
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
--
-- No figures. Every question here is symbolic; the one candidate for a
-- picture, the hole in the graph of a cancelled factor, puts the answer on
-- the diagram and so was rejected.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Rational Expressions';

insert into misconception_labels (tag, label) values
  ('sub-exponent-rules',      'Exponent rules'),
  ('sub-rational-exponents',  'Rational exponents'),
  ('sub-restrictions',        'Restrictions on the variable'),
  ('sub-simplify-mult-div',   'Simplifying, multiplying and dividing'),
  ('sub-add-subtract-rat',    'Adding and subtracting')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 1, 'Easy',
 'Simplify: x⁵ × x³',
 '[{"text": "x¹⁵", "feedback": "That multiplies the exponents. Multiplying powers of the same base adds them instead."},
   {"text": "x⁸", "feedback": "Correct."},
   {"text": "x²", "feedback": "That subtracts the exponents, which is the rule for dividing powers, not multiplying."},
   {"text": "2x⁸", "feedback": "The two bases do not add together to make a coefficient. There is still only one x being built up."}]'::jsonb,
 1, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 2, 'Easy',
 'Simplify: (x⁴)³',
 '[{"text": "x⁷", "feedback": "That adds the exponents. A power raised to another power multiplies them."},
   {"text": "x⁴", "feedback": "The outer exponent 3 was ignored entirely."},
   {"text": "3x⁴", "feedback": "The outer 3 was turned into a coefficient. It is an exponent acting on the whole power."},
   {"text": "x¹²", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 3, 'Easy',
 'Write ∛x using a rational exponent.',
 '[{"text": "x^(1/3)", "feedback": "Correct."},
   {"text": "x³", "feedback": "The index of the root became a whole-number power. A root is a fractional power."},
   {"text": "3x", "feedback": "The index was turned into a multiplier. It belongs on the bottom of the exponent."},
   {"text": "x^(-3)", "feedback": "A root is not a reciprocal power. Nothing here flips the base."}]'::jsonb,
 0, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 4, 'Easy',
 'Evaluate: 8^(1/3)',
 '[{"text": "24", "feedback": "That multiplies 8 by 3. A fractional exponent asks for a root, not a product."},
   {"text": "512", "feedback": "That cubes the 8. An exponent of one third undoes a cube, it does not apply one."},
   {"text": "2", "feedback": "Correct."},
   {"text": "8/3", "feedback": "That divides 8 by 3. The 3 on the bottom of the exponent is the index of a root."}]'::jsonb,
 2, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 5, 'Easy',
 'State the restriction on the variable: (x + 2)/(x - 5)',
 '[{"text": "x ≠ -5", "feedback": "Solving x - 5 = 0 moves the 5 across as a positive number."},
   {"text": "x ≠ 5", "feedback": "Correct."},
   {"text": "x ≠ -2", "feedback": "That is the value making the numerator zero. A zero on top is allowed; only the bottom is forbidden."},
   {"text": "x ≠ 0", "feedback": "The denominator here is x - 5, not x on its own, so it reaches zero somewhere other than the origin."}]'::jsonb,
 1, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 6, 'Easy',
 'State all restrictions on the variable: 7/(x(x + 3))',
 '[{"text": "x ≠ 0 and x ≠ 3", "feedback": "The bracket x + 3 hits zero at a negative value. The sign flips when the bracket is solved."},
   {"text": "x ≠ -3 only", "feedback": "There are two factors on the bottom, and the bare x is one of them."},
   {"text": "x ≠ 0 only", "feedback": "The bracket x + 3 can reach zero as well, and that value is forbidden too."},
   {"text": "x ≠ 0 and x ≠ -3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 7, 'Easy',
 'Simplify: 3x²/(yx)',
 '[{"text": "3x/y", "feedback": "Correct."},
   {"text": "3x³/y", "feedback": "The x exponents were added. Dividing powers of the same base subtracts them."},
   {"text": "3/y", "feedback": "The whole x² was cancelled against a single x. Only one factor of x is available to cancel."},
   {"text": "3xy", "feedback": "The y was moved to the top. Cancelling never relocates a factor that has no partner."}]'::jsonb,
 0, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 8, 'Easy',
 'Simplify: (x² + 10x + 21)/(x + 3)',
 '[{"text": "x + 3", "feedback": "The bracket that cancels is the one matching the bottom. What survives is the other factor."},
   {"text": "(x² + 10x + 21)/x", "feedback": "Only the number 3 was struck out. Cancelling works on whole factors, never on one term inside a bracket."},
   {"text": "x + 7", "feedback": "Correct."},
   {"text": "7", "feedback": "The x and the 3 were struck out separately. A bracket cancels as one piece or not at all."}]'::jsonb,
 2, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 9, 'Easy',
 'Simplify: 3/x + 4/x',
 '[{"text": "7/(2x)", "feedback": "The denominators were added as well. With a common denominator already in place it stays exactly as it is."},
   {"text": "12/x²", "feedback": "The two fractions were multiplied. The sign between them is a plus."},
   {"text": "1/x", "feedback": "That subtracts the numerators. Read the sign between the two fractions again."},
   {"text": "7/x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 10, 'Easy',
 'Simplify: 1/(5x) + 1/(2x)',
 '[{"text": "2/(7x)", "feedback": "Numerators and denominators were added straight across. Fractions are never combined that way."},
   {"text": "7/(10x)", "feedback": "Correct."},
   {"text": "2/(10x)", "feedback": "The common denominator is right, but the numerators were not rescaled to match it."},
   {"text": "7/(10x²)", "feedback": "The x was multiplied along with the numbers. Each denominator already carries exactly one x."}]'::jsonb,
 1, 'sub-add-subtract-rat'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 11, 'Medium',
 'Simplify, leaving only positive exponents: 12k²m⁸/(4k⁵m⁵)',
 '[{"text": "3k³m³", "feedback": "The k exponents were subtracted the wrong way round. The larger power of k sits on the bottom here."},
   {"text": "3k⁷m¹³", "feedback": "The exponents were added. Division subtracts them."},
   {"text": "3m³/k³", "feedback": "Correct."},
   {"text": "8m³/k³", "feedback": "The coefficients were subtracted: 12 take away 4. Coefficients divide, they do not subtract."}]'::jsonb,
 2, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 12, 'Medium',
 'Simplify: (3xy)³/(9x⁴y⁴)',
 '[{"text": "3/(xy)", "feedback": "Correct."},
   {"text": "1/(3xy)", "feedback": "The 3 inside the bracket was not cubed. Everything inside takes the outer power."},
   {"text": "3xy", "feedback": "The exponents were subtracted the wrong way round. The denominator carries the larger powers."},
   {"text": "3x⁷y⁷", "feedback": "The exponents were added instead of subtracted."}]'::jsonb,
 0, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 13, 'Medium',
 'Evaluate: 8^(2/3)',
 '[{"text": "2", "feedback": "The cube root was taken and then the power 2 was never applied."},
   {"text": "64", "feedback": "That squares 8 and forgets the 3 on the bottom of the exponent."},
   {"text": "16/3", "feedback": "That multiplies 8 by two thirds. A fractional exponent is a root and a power, not a product."},
   {"text": "4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 14, 'Medium',
 'Evaluate: 81^(5/4)',
 '[{"text": "3", "feedback": "The fourth root was taken and the power 5 was never applied."},
   {"text": "243", "feedback": "Correct."},
   {"text": "405", "feedback": "That multiplies 81 by 5. The 5 is an exponent applied to the root, not a multiplier."},
   {"text": "15", "feedback": "The fourth root was found correctly and then multiplied by 5 instead of being raised to the power 5."}]'::jsonb,
 1, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 15, 'Medium',
 'State all restrictions on the variable: (x - 3)/(x² + 3x - 18)',
 '[{"text": "x ≠ -6, with no other restriction", "feedback": "The expression cancels down to a single bracket, but the restriction from the cancelled factor still stands."},
   {"text": "x ≠ 6 and x ≠ -3", "feedback": "The numbers were copied straight out of the brackets as the restricted values. Each bracket still has to be set to zero and solved."},
   {"text": "x ≠ -6 and x ≠ 3", "feedback": "Correct."},
   {"text": "x ≠ 3, with no other restriction", "feedback": "The denominator has two factors, and both of them can reach zero."}]'::jsonb,
 2, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 16, 'Medium',
 'State all restrictions on the variable: (x + 12)/(x + 10) ÷ (x + 12)/(x - 5)',
 '[{"text": "x ≠ -10, x ≠ -12 and x ≠ 5", "feedback": "Correct."},
   {"text": "x ≠ -10 and x ≠ 5", "feedback": "Once the second fraction is flipped, its numerator becomes a denominator, so that bracket is restricted too."},
   {"text": "x ≠ -10 only", "feedback": "A division brings two more brackets into play: the one being divided by, and the one it turns into after the flip."},
   {"text": "x ≠ -10 and x ≠ -12", "feedback": "The second fraction has a denominator of its own before the flip, and that value is forbidden as well."}]'::jsonb,
 0, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 17, 'Medium',
 'Simplify: (x² - 9)/(x² + 7x + 12)',
 '[{"text": "-9/(7x + 12)", "feedback": "The x² terms were struck out across a subtraction and an addition. Cancelling works only on whole factors."},
   {"text": "(x - 3)/(x + 3)", "feedback": "The bracket that goes is the one appearing on both the top and the bottom. Check which factor the two share."},
   {"text": "(x + 3)/(x + 4)", "feedback": "A difference of squares factors into one plus bracket and one minus bracket, not two pluses."},
   {"text": "(x - 3)/(x + 4)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 18, 'Medium',
 'Simplify: (4x + 24)/(x² + 8x) × 12x²/(3x + 18)',
 '[{"text": "48x/(x + 8)", "feedback": "The 3 in the second denominator was never divided out."},
   {"text": "16x/(x + 8)", "feedback": "Correct."},
   {"text": "16x²/(x + 8)", "feedback": "One factor of x on the bottom was left uncancelled. There is an x hiding inside x² + 8x."},
   {"text": "16/(x + 8)", "feedback": "Both factors of x on the top were cancelled, but the bottom only offers one to cancel against."}]'::jsonb,
 1, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 19, 'Medium',
 'Simplify: 5/(7x) - 3/(4x)',
 '[{"text": "-1/(28x)", "feedback": "Correct."},
   {"text": "1/(28x)", "feedback": "The subtraction ran the wrong way round: 21 taken from 20 lands below zero."},
   {"text": "2/(3x)", "feedback": "Numerators and denominators were subtracted straight across. Fractions are never combined that way."},
   {"text": "41/(28x)", "feedback": "The two rescaled numerators were added instead of subtracted."}]'::jsonb,
 0, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 20, 'Medium',
 'Simplify: 4/(ab) + 9/(2b)',
 '[{"text": "13/(ab + 2b)", "feedback": "Numerators and denominators were added straight across. Fractions are never combined that way."},
   {"text": "13/(2ab²)", "feedback": "The numerators were added and the denominators multiplied. A common denominator is not the product of everything in sight."},
   {"text": "(8 + 9a)/(2ab)", "feedback": "Correct."},
   {"text": "17/(2ab)", "feedback": "The denominators were brought to 2ab correctly, but the numerators were not rescaled by the same factors."}]'::jsonb,
 2, 'sub-add-subtract-rat'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): multi-step, choosing the method, stating what is hidden.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 21, 'Challenge',
 'Simplify, leaving only positive exponents: (2z³)⁻²/(w⁵z²)',
 '[{"text": "1/(2w⁵z⁸)", "feedback": "The 2 inside the bracket also takes the power -2, so it lands on the bottom as 4 rather than 2."},
   {"text": "1/(4w⁵z⁸)", "feedback": "Correct."},
   {"text": "1/(4w⁵z⁴)", "feedback": "The z exponents were combined by adding. The z² sits on the bottom, so its power is taken away."},
   {"text": "-1/(4w⁵z⁸)", "feedback": "A minus in the exponent moves the power across the fraction bar. It never becomes a minus sign out front."}]'::jsonb,
 1, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 22, 'Challenge',
 'Simplify, leaving only positive exponents: (x⁻⁴)⁵x³/(3x⁻¹)',
 '[{"text": "1/(3x¹⁸)", "feedback": "Dividing by x to the power -1 subtracts a negative, which adds one to the exponent rather than taking one away."},
   {"text": "x¹⁶/3", "feedback": "The exponent finished negative, so the power belongs on the bottom of the fraction."},
   {"text": "1/(3x¹⁷)", "feedback": "The x to the power -1 in the denominator was never dealt with at all."},
   {"text": "1/(3x¹⁶)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 23, 'Challenge',
 'Simplify: (5x^(1/2))² × 4x^(-1/2)',
 '[{"text": "20√x", "feedback": "Only the x inside the bracket was squared. The 5 takes the outer power as well."},
   {"text": "40√x", "feedback": "The 5 was doubled rather than squared."},
   {"text": "100√x", "feedback": "Correct."},
   {"text": "100x^(3/2)", "feedback": "The minus on the second exponent was dropped, so the two half-powers were added instead of one being taken away."}]'::jsonb,
 2, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 24, 'Challenge',
 'Evaluate: (49/81)^(-3/2)',
 '[{"text": "729/343", "feedback": "Correct."},
   {"text": "343/729", "feedback": "A negative exponent flips the base before the power is applied, and this is what the same power gives without that flip."},
   {"text": "9/7", "feedback": "The base was flipped and square rooted, but the 3 on the top of the exponent was never applied."},
   {"text": "-729/343", "feedback": "A negative exponent turns the fraction over. It does not make the value negative."}]'::jsonb,
 0, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 25, 'Challenge',
 E'State ALL restrictions on the variable:\n(x² - 7x + 10)/(x² - 4) ÷ (x² - 4x - 5)/(3x + 6)',
 '[{"text": "x ≠ -2 and x ≠ 2", "feedback": "Only the first denominator was checked. A division adds the thing being divided by to the list of what cannot be zero."},
   {"text": "x ≠ -2, x ≠ -1 and x ≠ 2", "feedback": "The expression being divided by factors into two brackets, and only one of them was recorded."},
   {"text": "x ≠ -1 only", "feedback": "Those are the restrictions of the simplified result. The original expression forbids more values than that."},
   {"text": "x ≠ -2, x ≠ -1, x ≠ 2 and x ≠ 5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 26, 'Challenge',
 'State all restrictions on the variable: (2x² + 7x - 15)/(2x² + 3x - 9)',
 '[{"text": "x ≠ -3, with no other restriction", "feedback": "The denominator has two factors, and the one that cancels away still counts."},
   {"text": "x ≠ -3 and x ≠ 3/2", "feedback": "Correct."},
   {"text": "x ≠ 3/2, with no other restriction", "feedback": "The bracket x + 3 on the bottom also reaches zero, and that value is forbidden too."},
   {"text": "x ≠ -5 and x ≠ 3/2", "feedback": "The value -5 comes from the numerator. A zero on the top is perfectly legal."}]'::jsonb,
 1, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 27, 'Challenge',
 'Simplify: (6x² - 7x - 5)/(3x² + x - 10)',
 '[{"text": "(2x + 1)/(x + 2)", "feedback": "Correct."},
   {"text": "(2x - 1)/(x + 2)", "feedback": "Multiply the numerator factors back out: pairing 2x - 1 with 3x - 5 gives a constant of +5, and this numerator ends in -5."},
   {"text": "(2x + 1)/(x - 2)", "feedback": "Multiply the denominator factors back out: that version ends in +10, and this denominator ends in -10."},
   {"text": "(2x + 1)/(3x - 5)", "feedback": "The shared bracket 3x - 5 is what cancels, and it has to go from the top and the bottom at the same time."}]'::jsonb,
 0, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 28, 'Challenge',
 E'Simplify:\n(2x² - 8x)/(x² - 3x - 10) ÷ 4x²/(x² - 9x + 20)',
 '[{"text": "8x³/((x - 5)²(x + 2))", "feedback": "The second fraction was multiplied in as it stood. Dividing means turning it over first."},
   {"text": "2x(x + 2)/(x - 4)²", "feedback": "The wrong fraction was flipped. It is the one after the division sign that turns over."},
   {"text": "(x - 4)²/(2x(x + 2))", "feedback": "Correct."},
   {"text": "(x - 4)²/(2x(x - 2))", "feedback": "x² - 3x - 10 needs a pair multiplying to -10, so one of the two numbers has to be positive."}]'::jsonb,
 2, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 29, 'Challenge',
 'Simplify: 2/(x - 3) - 5/(x + 3)',
 '[{"text": "(-3x - 9)/((x - 3)(x + 3))", "feedback": "The minus reached the 5x but not the -15 behind it. It has to hit every term in the bracket."},
   {"text": "(-3x + 21)/((x - 3)(x + 3))", "feedback": "Correct."},
   {"text": "(7x - 9)/((x - 3)(x + 3))", "feedback": "The two rescaled numerators were added. The sign between the fractions is a minus."},
   {"text": "-3/((x - 3)(x + 3))", "feedback": "The numerators were subtracted as they stood, without first being rescaled by the bracket each one was missing."}]'::jsonb,
 1, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 30, 'Challenge',
 'Simplify: 4x/(x² - 9x + 18) + (2x - 1)/(x - 6)',
 '[{"text": "(6x - 1)/((x - 3)(x - 6))", "feedback": "The numerators were added as they stood. The second one still needs rescaling by the bracket it is missing."},
   {"text": "(2x² - 9x + 6)/((x - 3)(x - 6))", "feedback": "The second fraction was rescaled by x - 6, which it already has. The bracket it lacks is x - 3."},
   {"text": "(2x² - 3x + 3)/((x² - 9x + 18)(x - 6))", "feedback": "The denominators were multiplied together. One of them already contains the other as a factor."},
   {"text": "(2x² - 3x + 3)/((x - 3)(x - 6))", "feedback": "Correct."}]'::jsonb,
 3, 'sub-add-subtract-rat'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): combined subtopics, the 90s-from-70s tier.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Rational Expressions', 2, 31, 'Advanced',
 'Simplify: (5c³d × 4c²d²)/((2c²d)²)',
 '[{"text": "5cd", "feedback": "Correct."},
   {"text": "10cd", "feedback": "The 2 inside the bracket was not squared. Everything inside a bracket takes the outer power."},
   {"text": "5cd²", "feedback": "The d inside the bracket was left un-squared while the c was squared."},
   {"text": "5c⁹d⁵", "feedback": "The exponents were added across the fraction bar. Division subtracts them."}]'::jsonb,
 0, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 32, 'Advanced',
 'Which expression is equal to (a + b)⁻¹?',
 '[{"text": "1/a + 1/b", "feedback": "A negative exponent does not spread over a sum. Try a = 1 and b = 1 and watch the two disagree."},
   {"text": "-(a + b)", "feedback": "A negative exponent turns the expression over. It does not change its sign."},
   {"text": "1/(a + b)", "feedback": "Correct."},
   {"text": "a⁻¹b⁻¹", "feedback": "That treats the plus as a multiplication. The power applies to the whole sum as one object."}]'::jsonb,
 2, 'sub-exponent-rules'),

(11, 'MCR3U', 'Rational Expressions', 2, 33, 'Advanced',
 E'Simplify, leaving only positive exponents:\n((m⁻²)³√(m⁴))/(m√(pq⁻³))',
 '[{"text": "m⁵q^(3/2)/√p", "feedback": "The m exponent finished negative, so that power belongs on the bottom of the fraction."},
   {"text": "q^(3/2)/(m⁵√p)", "feedback": "Correct."},
   {"text": "1/(m⁵√p q^(3/2))", "feedback": "The q carried a negative exponent inside the root on the bottom, so it travels up to the top."},
   {"text": "q^(3/2)/(m⁴√p)", "feedback": "The lone m in the denominator was never divided out, and it costs one more power of m."}]'::jsonb,
 1, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 34, 'Advanced',
 'Simplify, leaving only positive exponents: (y^(1/4))² × (y^(-1/3))²',
 '[{"text": "y^(1/6)", "feedback": "The combined exponent finishes negative, because two thirds is larger than one half."},
   {"text": "1/y^(1/12)", "feedback": "The outer squares were never applied. Both exponents double before they combine."},
   {"text": "1/y^(1/3)", "feedback": "The exponents were multiplied. Multiplying powers of the same base adds them."},
   {"text": "1/y^(1/6)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-exponents'),

(11, 'MCR3U', 'Rational Expressions', 2, 35, 'Advanced',
 E'State ALL restrictions on the variable:\n(x² + 3x + 2)/(x² - 1) × (x - 1)/(x² - 2x - 8)',
 '[{"text": "x ≠ -2, x ≠ -1, x ≠ 1 and x ≠ 4", "feedback": "Correct."},
   {"text": "x ≠ -1, x ≠ 1 and x ≠ 4", "feedback": "x² - 2x - 8 factors into two brackets, and only one of them was recorded."},
   {"text": "x ≠ -2, x ≠ 1 and x ≠ 4", "feedback": "x² - 1 is a difference of squares, so it has two roots, one on each side of zero."},
   {"text": "x ≠ 4 only", "feedback": "Those are the restrictions of the simplified result. Every bracket that cancelled on the way still counts."}]'::jsonb,
 0, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 36, 'Advanced',
 'Simplify (x² - 25)/(x² - 10x + 25) and state the restrictions.',
 '[{"text": "(x + 5)/(x - 5), with x ≠ 5 and x ≠ -5", "feedback": "The value -5 makes the numerator zero, not the denominator. A zero on the top is allowed."},
   {"text": "(x - 5)/(x + 5), with x ≠ -5", "feedback": "The denominator is a perfect square, and the bracket being squared is x - 5, not x + 5."},
   {"text": "(x + 5)/(x - 5), with x ≠ 5", "feedback": "Correct."},
   {"text": "(x + 5)/(x - 5), with no restrictions", "feedback": "Simplifying does not repair the original expression. It was already undefined at that value before any cancelling happened."}]'::jsonb,
 2, 'sub-restrictions'),

(11, 'MCR3U', 'Rational Expressions', 2, 37, 'Advanced',
 E'Simplify:\n(x² - 1)/(x² - 4) × (x² + 3x - 4)/(x² + 5x + 4)',
 '[{"text": "(x + 1)²/((x - 2)(x + 2))", "feedback": "The bracket the two fractions share is x + 1, and it cancels away. The one left doubled is the other."},
   {"text": "(x - 1)/((x - 2)(x + 2))", "feedback": "The two x - 1 brackets come from different fractions and both survive. Only a top and a bottom cancel each other."},
   {"text": "(x - 1)²/((x + 1)(x - 2)(x + 2))", "feedback": "The x + 1 on the bottom has a partner on the top and should have gone."},
   {"text": "(x - 1)²/((x - 2)(x + 2))", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 38, 'Advanced',
 E'Simplify:\n(x² - 9)/(x² - x - 6) ÷ (x² + 7x + 12)/(x² + 2x - 8)',
 '[{"text": "(x + 2)/(x - 2)", "feedback": "The result came out upside down, which is what happens when the first fraction is flipped instead of the second."},
   {"text": "(x - 2)/(x + 2)", "feedback": "Correct."},
   {"text": "(x - 3)/(x + 2)", "feedback": "The x - 2 on the top was struck out against the x - 3 on the bottom. Brackets cancel only when they are identical."},
   {"text": "(x - 2)/(x + 3)", "feedback": "The x + 3 cancels away completely. The bracket left on the bottom comes from x² - x - 6."}]'::jsonb,
 1, 'sub-simplify-mult-div'),

(11, 'MCR3U', 'Rational Expressions', 2, 39, 'Advanced',
 E'Simplify:\n(3x + 9)/(x² + 5x + 6) - (2x - 2)/(x² + x - 2)',
 '[{"text": "5/(x + 2)", "feedback": "The two reduced fractions were added. The sign between them is a minus."},
   {"text": "-1/(x + 2)", "feedback": "The subtraction ran backwards. It is the second numerator that comes off the first."},
   {"text": "1/(x + 2)", "feedback": "Correct."},
   {"text": "1/(x + 3)", "feedback": "Both fractions reduce to the same denominator, and it is the bracket they have in common, not the one only the first carries."}]'::jsonb,
 2, 'sub-add-subtract-rat'),

(11, 'MCR3U', 'Rational Expressions', 2, 40, 'Advanced',
 'Simplify: (3x + 2)/(3 - 4x) + (2x + 1)/(4x - 3)',
 '[{"text": "(x + 1)/(3 - 4x)", "feedback": "Correct."},
   {"text": "(5x + 3)/(3 - 4x)", "feedback": "The two denominators differ by a factor of -1, and pulling that minus out turns the addition into a subtraction."},
   {"text": "(5x + 3)/((3 - 4x)(4x - 3))", "feedback": "The denominators were multiplied together. They are already the same apart from a factor of -1."},
   {"text": "(x + 3)/(3 - 4x)", "feedback": "The minus that came out of the second fraction reached the 2x but not the 1 behind it."}]'::jsonb,
 0, 'sub-add-subtract-rat');
