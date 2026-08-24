-- ===========================================================================
-- MTH1W — Unit 2: Powers — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Powers and scientific notation
--   Lesson 2  Product, quotient and power of a power rules
--   Lesson 3  Power of a product and power of a quotient
--   Lesson 4  Negative exponents
--
-- The distractors are the mistakes the worked solutions themselves point at:
-- multiplying the base by the exponent instead of repeating it, losing the
-- brackets that decide whether -3^4 is negative, adding exponents where the
-- rule multiplies them, and — the one this unit is really about — forgetting
-- that the exponent on a product lands on the COEFFICIENT as well as the
-- variable.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Powers';

insert into misconception_labels (tag, label) values
  ('sub-powers-basics',       'Powers and exponent form'),
  ('sub-scientific-notation', 'Scientific notation'),
  ('sub-exponent-laws',       'Product, quotient and power laws'),
  ('sub-power-of-product',    'Power of a product or quotient'),
  ('sub-negative-exponents',  'Negative exponents')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 1, 'Easy',
 'Write 3 x 3 x 3 x 3 as a power.',
 '[{"text": "3^3", "feedback": "That counted the multiplication signs. Count the factors themselves."},
   {"text": "3^4", "feedback": "Correct."},
   {"text": "4^3", "feedback": "The base and the exponent have been swapped. The base is the number being repeated."},
   {"text": "12", "feedback": "That multiplied the base by how many times it appears. A power repeats the multiplication instead."}]'::jsonb,
 1, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 2, 'Easy',
 'Evaluate 4^3.',
 '[{"text": "64", "feedback": "Correct."},
   {"text": "43", "feedback": "That wrote the two digits side by side rather than working the power out."},
   {"text": "16", "feedback": "That used an exponent of 2. Check how many factors of 4 the exponent asks for."},
   {"text": "12", "feedback": "That multiplied the base by the exponent. The exponent says how many times to multiply the base by ITSELF."}]'::jsonb,
 0, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 3, 'Easy',
 'Which of these is written correctly in scientific notation?',
 '[{"text": "4.5 x 9^3", "feedback": "Scientific notation always uses a power of ten, whatever the number."},
   {"text": "45 x 10^2", "feedback": "The number in front has to be at least 1 and less than 10. This one is too large."},
   {"text": "0.45 x 10^4", "feedback": "The number in front has to be at least 1. This one is too small."},
   {"text": "4.5 x 10^3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 4, 'Easy',
 'Write 3.2 x 10^4 in standard form.',
 '[{"text": "3 200", "feedback": "The decimal moved three places. The exponent says how many."},
   {"text": "320 000", "feedback": "The decimal moved five places, one too many."},
   {"text": "0.00032", "feedback": "That moved the decimal LEFT. A positive exponent moves it right."},
   {"text": "32 000", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 5, 'Easy',
 'Simplify 2^3 x 2^4 as a single power.',
 '[{"text": "2^1", "feedback": "That subtracted the exponents, which is the rule for dividing, not multiplying."},
   {"text": "2^12", "feedback": "That multiplied the exponents. Multiplying powers of the same base adds them."},
   {"text": "4^7", "feedback": "The exponents were handled correctly, but the bases were multiplied as well. The base stays as it is."},
   {"text": "2^7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 6, 'Easy',
 'What is the value of 7^0?',
 '[{"text": "0", "feedback": "An exponent of zero does not make the whole power zero. Follow the pattern down from 7^2, 7^1."},
   {"text": "7", "feedback": "That is 7^1. Take one more step down the pattern."},
   {"text": "1", "feedback": "Correct."},
   {"text": "Undefined", "feedback": "Only 0^0 is undefined. This base is not zero."}]'::jsonb,
 2, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 7, 'Easy',
 'Simplify (xy)^3.',
 '[{"text": "x^3y^3", "feedback": "Correct."},
   {"text": "x^3y", "feedback": "The exponent only reached the first factor. Both are inside the brackets."},
   {"text": "3xy", "feedback": "That multiplied by 3. The exponent repeats the whole bracket, it does not multiply it."},
   {"text": "xy^3", "feedback": "The exponent only reached one of the two factors. Everything inside the brackets is being cubed."}]'::jsonb,
 0, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 8, 'Easy',
 'Evaluate (2/3)^2.',
 '[{"text": "4/3", "feedback": "Only the numerator was squared. The exponent applies to the bottom as well."},
   {"text": "4/6", "feedback": "The top was squared but the bottom was only doubled."},
   {"text": "4/9", "feedback": "Correct."},
   {"text": "2/9", "feedback": "Only the denominator was squared. The exponent applies to the top as well."}]'::jsonb,
 2, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 9, 'Easy',
 'Evaluate 5^-2.',
 '[{"text": "-1/25", "feedback": "The reciprocal is right, but the minus sign should not survive the move."},
   {"text": "1/25", "feedback": "Correct."},
   {"text": "1/10", "feedback": "That multiplied the base by the exponent before taking the reciprocal."},
   {"text": "-25", "feedback": "A negative exponent does not make the answer negative. It moves the power to the bottom of a fraction."}]'::jsonb,
 1, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 10, 'Easy',
 'The negative exponent rule says a^-3 is equal to:',
 '[{"text": "-a^3", "feedback": "The minus sign does not move onto the front of the power. It signals a reciprocal."},
   {"text": "-3a", "feedback": "That multiplied the base by the exponent. The exponent still means repeated multiplication."},
   {"text": "a^3", "feedback": "The sign was simply dropped. It has a meaning that has to be honoured."},
   {"text": "1/a^3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-negative-exponents'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 11, 'Medium',
 'Evaluate (-2)^4.',
 '[{"text": "8", "feedback": "That multiplied the base by the exponent, and dropped the sign along the way."},
   {"text": "-16", "feedback": "A negative base does not always give a negative answer. Count how many negative factors there are."},
   {"text": "16", "feedback": "Correct."},
   {"text": "-8", "feedback": "That used an exponent of 3. Check how many factors the exponent asks for."}]'::jsonb,
 2, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 12, 'Medium',
 'Evaluate -3^4.',
 '[{"text": "12", "feedback": "Two mistakes: the base was multiplied by the exponent, and the sign was dropped."},
   {"text": "81", "feedback": "That treated the expression as if the minus sign were inside brackets with the 3. It is not."},
   {"text": "-81", "feedback": "Correct."},
   {"text": "-12", "feedback": "That multiplied the base by the exponent instead of repeating it."}]'::jsonb,
 2, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 13, 'Medium',
 'Write 0.00047 in scientific notation.',
 '[{"text": "47 x 10^-5", "feedback": "The power of ten is consistent, but the number in front must be at least 1 and less than 10."},
   {"text": "4.7 x 10^-3", "feedback": "The decimal was counted one place short. Count every place it has to move."},
   {"text": "4.7 x 10^-4", "feedback": "Correct."},
   {"text": "4.7 x 10^4", "feedback": "The exponent has the wrong sign. A number smaller than 1 needs a negative power of ten."}]'::jsonb,
 2, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 14, 'Medium',
 'Write 947 000 000 in scientific notation.',
 '[{"text": "9.47 x 10^8", "feedback": "Correct."},
   {"text": "9.47 x 10^-8", "feedback": "The sign is wrong. A number larger than 1 needs a positive power of ten."},
   {"text": "9.47 x 10^7", "feedback": "One place short. Count the places the decimal moves from the end of the number."},
   {"text": "947 x 10^6", "feedback": "The power of ten works, but the number in front has to be less than 10."}]'::jsonb,
 0, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 15, 'Medium',
 'Simplify 8^7 divided by 8^5, then evaluate.',
 '[{"text": "8^12", "feedback": "That added the exponents. Dividing powers of the same base subtracts them."},
   {"text": "1", "feedback": "That cancelled the exponents completely. Subtracting them does not always leave zero."},
   {"text": "8^35", "feedback": "That multiplied the exponents, which is the rule for a power of a power."},
   {"text": "64", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 16, 'Medium',
 'Simplify (3^2)^4 as a single power.',
 '[{"text": "3^16", "feedback": "That raised the inner exponent to the outer one instead of multiplying the two."},
   {"text": "6^4", "feedback": "That multiplied the base by the inner exponent instead of repeating it, then applied the outer exponent."},
   {"text": "3^6", "feedback": "That added the exponents. A power raised to a power multiplies them."},
   {"text": "3^8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 17, 'Medium',
 'Simplify (3x^2)^4.',
 '[{"text": "81x^8", "feedback": "Correct."},
   {"text": "81x^6", "feedback": "The coefficient is right, but the exponents on x were added instead of multiplied."},
   {"text": "3x^8", "feedback": "The variable was handled correctly, but the coefficient is inside the brackets too."},
   {"text": "12x^8", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."}]'::jsonb,
 0, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 18, 'Medium',
 'Simplify (x^2 / y^3)^4.',
 '[{"text": "x^2 / y^12", "feedback": "The exponent only reached the denominator. It applies to the numerator as well."},
   {"text": "x^8 / y^12", "feedback": "Correct."},
   {"text": "x^8 / y^3", "feedback": "The exponent only reached the numerator. It applies to the denominator as well."},
   {"text": "x^6 / y^7", "feedback": "The exponents were added. A power of a power multiplies them."}]'::jsonb,
 1, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 19, 'Medium',
 'Simplify x^5 / x^9, writing the answer without a negative exponent.',
 '[{"text": "x^4", "feedback": "The exponents were subtracted the other way round. Take the bottom from the top."},
   {"text": "1 / x^14", "feedback": "That added the exponents. Dividing subtracts them."},
   {"text": "1 / x^4", "feedback": "Correct."},
   {"text": "x^45", "feedback": "That multiplied the exponents, which is the rule for a power of a power."}]'::jsonb,
 2, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 20, 'Medium',
 'Evaluate (3/4)^-2.',
 '[{"text": "6/8", "feedback": "That multiplied top and bottom by 2 instead of squaring them."},
   {"text": "9/16", "feedback": "The fraction was squared but never flipped. A negative exponent on a fraction takes its reciprocal first."},
   {"text": "16/9", "feedback": "Correct."},
   {"text": "-16/9", "feedback": "The flip is right, but the minus sign should not survive it."}]'::jsonb,
 2, 'sub-negative-exponents'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 21, 'Challenge',
 'Evaluate 6x^2 when x = 5.',
 '[{"text": "150", "feedback": "Correct."},
   {"text": "30", "feedback": "That substituted but never applied the exponent."},
   {"text": "900", "feedback": "That multiplied 6 by 5 first and then squared the result. The exponent belongs to x alone."},
   {"text": "60", "feedback": "That multiplied 6 by 5 by 2. The 2 is an exponent, not a factor."}]'::jsonb,
 0, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 22, 'Challenge',
 'Evaluate 6x^2 - 2x - 24 when x = -6.',
 '[{"text": "252", "feedback": "The middle term was handled correctly but the constant was added instead of subtracted."},
   {"text": "204", "feedback": "Correct."},
   {"text": "180", "feedback": "The squared term is right, but the middle term lost its sign. Subtracting a negative adds."},
   {"text": "-228", "feedback": "The negative was not enclosed in brackets before squaring, so the first term came out negative."}]'::jsonb,
 1, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 23, 'Challenge',
 'Which of these numbers is the largest?',
 '[{"text": "8.7 x 10^3", "feedback": "This has the smallest power of ten of all four."},
   {"text": "5.0 x 10^4", "feedback": "Its power of ten is beaten by one of the others."},
   {"text": "9.9 x 10^4", "feedback": "This has the biggest number in front, but that is not what decides the size. Compare the powers of ten first."},
   {"text": "3.2 x 10^5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 24, 'Challenge',
 'Evaluate (2 x 10^3)(4 x 10^5), leaving the answer in scientific notation.',
 '[{"text": "6 x 10^8", "feedback": "The power of ten is right, but the numbers in front were added rather than multiplied."},
   {"text": "8 x 10^8", "feedback": "Correct."},
   {"text": "8 x 10^2", "feedback": "The exponents were subtracted, which is the rule for dividing."},
   {"text": "8 x 10^15", "feedback": "The exponents were multiplied. Multiplying powers of ten adds them."}]'::jsonb,
 1, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 25, 'Challenge',
 'Simplify (3^2 x 3^4)^3 as a single power.',
 '[{"text": "3^11", "feedback": "The two exponents inside the bracket were multiplied together and the outer one was then added on. Inside the bracket they are added."},
   {"text": "3^18", "feedback": "Correct."},
   {"text": "3^9", "feedback": "The bracket was simplified correctly, but the outer exponent was added rather than multiplied."},
   {"text": "3^24", "feedback": "That multiplied all three exponents together. Inside the bracket they are added first."}]'::jsonb,
 1, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 26, 'Challenge',
 'Simplify x^20 / (x^5 . x^6).',
 '[{"text": "x^14", "feedback": "Only the other factor was divided out. Both are on the bottom."},
   {"text": "x^9", "feedback": "Correct."},
   {"text": "x^11", "feedback": "That is the bottom combined. The division by the top still has to happen."},
   {"text": "x^15", "feedback": "Only one of the two factors on the bottom was divided out. Combine them first."}]'::jsonb,
 1, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 27, 'Challenge',
 'Simplify (-2x^4y^5)^2.',
 '[{"text": "-2x^8y^10", "feedback": "The variables were raised correctly, but the coefficient was left untouched."},
   {"text": "-4x^8y^10", "feedback": "Everything else is right, but an even exponent on a negative base does not leave it negative."},
   {"text": "4x^8y^10", "feedback": "Correct."},
   {"text": "4x^6y^7", "feedback": "The coefficient is right, but the exponents were added rather than multiplied."}]'::jsonb,
 2, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 28, 'Challenge',
 'Simplify (3a^2b)^5.',
 '[{"text": "15a^10b^5", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."},
   {"text": "243a^7b^5", "feedback": "The coefficient is right, but the exponents on a were added instead of multiplied."},
   {"text": "243a^10b^5", "feedback": "Correct."},
   {"text": "3a^10b^5", "feedback": "The variables are right, but the coefficient is inside the brackets and has to be raised too."}]'::jsonb,
 2, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 29, 'Challenge',
 'Simplify (2m^2)^-3, writing the answer without a negative exponent.',
 '[{"text": "1 / (8m^6)", "feedback": "Correct."},
   {"text": "1 / (6m^6)", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."},
   {"text": "-8m^6", "feedback": "The minus sign was moved to the front instead of signalling a reciprocal."},
   {"text": "1 / (2m^6)", "feedback": "The reciprocal and the variable are right, but the 2 is inside the brackets and must be cubed as well."}]'::jsonb,
 0, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 30, 'Challenge',
 'Simplify (x^7 / y^9)^-4, writing the answer without negative exponents.',
 '[{"text": "y^36 / x^28", "feedback": "Correct."},
   {"text": "y^13 / x^11", "feedback": "The flip is right, but the exponents were added rather than multiplied."},
   {"text": "1 / (x^28 y^9)", "feedback": "The outer power was applied to the numerator only. It reaches every factor inside the bracket, top and bottom."},
   {"text": "x^28 / y^36", "feedback": "The exponents were applied correctly, but the fraction was never flipped."}]'::jsonb,
 0, 'sub-negative-exponents'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Powers', 2, 31, 'Advanced',
 'The zero exponent rule is written a^0 = 1, with the condition that a is not 0. Why is that condition needed?',
 '[{"text": "Because a negative base is not allowed in the rule", "feedback": "Negative bases are fine here. The restriction names one specific value."},
   {"text": "Because zero cannot be used as an exponent", "feedback": "Zero is exactly the exponent this rule is about. The restriction is on the base."},
   {"text": "Because 0^0 equals 0, which breaks the pattern", "feedback": "0^0 does not equal 0. Compare what the zero exponent rule says with what the pattern of powers of 0 says, and see whether they agree."},
   {"text": "Because 0^0 is undefined", "feedback": "Correct."}]'::jsonb,
 3, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 32, 'Advanced',
 'Evaluate (-2)^5.',
 '[{"text": "-32", "feedback": "Correct."},
   {"text": "-10", "feedback": "That multiplied the base by the exponent rather than repeating it."},
   {"text": "10", "feedback": "Two mistakes: the base was multiplied by the exponent, and the sign was dropped."},
   {"text": "32", "feedback": "The size is right but the sign is not. Count whether the number of negative factors is odd or even."}]'::jsonb,
 0, 'sub-powers-basics'),

(9, 'MTH1W', 'Powers', 2, 33, 'Advanced',
 'Evaluate (6 x 10^8) divided by (3 x 10^-2), leaving the answer in scientific notation.',
 '[{"text": "2 x 10^-16", "feedback": "The exponents were multiplied. Dividing powers of ten subtracts them."},
   {"text": "2 x 10^10", "feedback": "Correct."},
   {"text": "3 x 10^10", "feedback": "The power of ten is right, but the numbers in front were subtracted instead of divided."},
   {"text": "2 x 10^6", "feedback": "Subtracting a negative exponent adds. This went the other way."}]'::jsonb,
 1, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 34, 'Advanced',
 'Evaluate 3.5 x 10^4 + 2.1 x 10^5, leaving the answer in scientific notation.',
 '[{"text": "5.6 x 10^9", "feedback": "Adding does not combine the powers of ten. That is what multiplying does."},
   {"text": "2.45 x 10^5", "feedback": "Correct."},
   {"text": "2.45 x 10^4", "feedback": "The addition is right, but the answer was left on the smaller power of ten."},
   {"text": "5.6 x 10^5", "feedback": "The numbers in front were added without first putting both terms on the same power of ten."}]'::jsonb,
 1, 'sub-scientific-notation'),

(9, 'MTH1W', 'Powers', 2, 35, 'Advanced',
 'Simplify (-4)^4 divided by (-4)^3.',
 '[{"text": "-4", "feedback": "Correct."},
   {"text": "(-4)^12", "feedback": "That multiplied the exponents. Dividing powers of the same base subtracts them."},
   {"text": "1", "feedback": "That cancelled the exponents to zero. Subtracting them leaves something behind here."},
   {"text": "4", "feedback": "The exponent arithmetic is right, but the sign of the base was dropped on the way out."}]'::jsonb,
 0, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 36, 'Advanced',
 'Use the quotient of powers rule to simplify 5^2 / 5^2.',
 '[{"text": "5", "feedback": "The exponents were subtracted to 1 rather than to 0. They are equal."},
   {"text": "25", "feedback": "That worked out the top and forgot to divide by the bottom."},
   {"text": "1", "feedback": "Correct."},
   {"text": "0", "feedback": "The exponents do subtract to zero, but a zero exponent does not make the whole power zero."}]'::jsonb,
 2, 'sub-exponent-laws'),

(9, 'MTH1W', 'Powers', 2, 37, 'Advanced',
 'Simplify (-2uv^3)(8u^2v^2) divided by (4uv^2)^2.',
 '[{"text": "uv", "feedback": "Everything else is right, but the minus sign from the first bracket was lost."},
   {"text": "-16uv", "feedback": "The variables divided correctly, but the 4 in the bottom bracket was dropped instead of being squared."},
   {"text": "-16u^3v^5", "feedback": "That is the top simplified. The bottom still has to be squared and divided out."},
   {"text": "-uv", "feedback": "Correct."}]'::jsonb,
 3, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 38, 'Advanced',
 'Simplify (3m^3n)^2 divided by (2mn)(3m^2n).',
 '[{"text": "m^3 / 2", "feedback": "The 3 in the top bracket was not squared before dividing."},
   {"text": "3m^3 / 2", "feedback": "Correct."},
   {"text": "3m^9 / 2", "feedback": "The exponents on m were added rather than subtracted after the bracket was squared."},
   {"text": "3m^3", "feedback": "The variables are right, but the numbers do not divide evenly. Check 9 against 6."}]'::jsonb,
 1, 'sub-power-of-product'),

(9, 'MTH1W', 'Powers', 2, 39, 'Advanced',
 'Simplify (y/4)^-3, writing the answer without a negative exponent.',
 '[{"text": "12 / y^3", "feedback": "The flip is right, but the 4 was multiplied by 3 instead of cubed."},
   {"text": "-y^3 / 64", "feedback": "Neither the flip nor the sign was handled. A negative exponent means a reciprocal, not a minus."},
   {"text": "y^3 / 64", "feedback": "The cube is right, but the fraction was never flipped."},
   {"text": "64 / y^3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-negative-exponents'),

(9, 'MTH1W', 'Powers', 2, 40, 'Advanced',
 'Simplify (2x^-2)^3, writing the answer without a negative exponent.',
 '[{"text": "8 / x^6", "feedback": "Correct."},
   {"text": "2 / x^6", "feedback": "The variable is right, but the 2 is inside the brackets and has to be cubed as well."},
   {"text": "8x^6", "feedback": "The coefficient is right, but the negative on the exponent was dropped rather than turned into a reciprocal."},
   {"text": "6 / x^6", "feedback": "The coefficient was multiplied by the exponent rather than raised to it."}]'::jsonb,
 0, 'sub-negative-exponents');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Powers'
group by difficulty order by min(sort_order);
