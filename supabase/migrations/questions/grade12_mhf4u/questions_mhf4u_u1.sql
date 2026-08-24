-- ===========================================================================
-- MHF4U — Unit 1: Polynomial Functions — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  Power functions
--   Lesson 2  Characteristics of polynomial functions
--   Lesson 3  Factored form polynomial functions
--   Lesson 4  Transformations of polynomial functions
--   Lesson 5  Symmetry in polynomial functions
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- END BEHAVIOUR is written in the quadrant notation the Jensen material
-- uses: Q3 to Q1 means the curve comes up out of the third quadrant on the
-- left and leaves through the first on the right.
--
-- FIGURES: none, and this is the unit where that decision is hardest to
-- like. Half of the Jensen questions here print a curve and ask a student to
-- read the degree, the sign of the leading coefficient, the turning points
-- and the intervals where the function is negative straight off it. Those
-- questions cannot survive the transfer: the picture holds every one of
-- those answers, and it holds them for free — you count the humps. So each
-- one is asked from the other end, giving the characteristics and asking for
-- the conclusion, or giving the equation and asking for the shape. That is
-- the same skill run in the direction that cannot be read off a drawing.
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

delete from questions where course_code = 'MHF4U' and unit = 'Polynomial Functions';

insert into misconception_labels (tag, label) values
  ('sub-power-functions',      'Power functions and end behaviour'),
  ('sub-poly-characteristics', 'Characteristics of polynomials'),
  ('sub-factored-form',        'Factored form and zeros'),
  ('sub-poly-transformations', 'Transforming polynomials'),
  ('sub-poly-symmetry',        'Even, odd and symmetry')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Polynomial Functions', 1, 1, 'Easy',
 'State the degree and the leading coefficient of y = x³ - 2x² - 5x⁴ + 3.',
 '[{"text": "Degree 4, leading coefficient -5", "feedback": "Correct."},
   {"text": "Degree 3, leading coefficient 1", "feedback": "The terms are out of order. The degree is the HIGHEST power present, and that is the x⁴ term."},
   {"text": "Degree 4, leading coefficient 3", "feedback": "The degree is right, but 3 is the constant term. The leading coefficient belongs to the highest-power term."},
   {"text": "Degree 5, leading coefficient -5", "feedback": "That reads the 5 from the coefficient as the power. The degree is the exponent written on the term, not the number in front of it."}]'::jsonb,
 0, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 2, 'Easy',
 'What is the end behaviour of y = 3x⁷?',
 '[{"text": "Q2 to Q4", "feedback": "That is what a NEGATIVE leading coefficient does to an odd-degree function. This one is positive."},
   {"text": "Q2 to Q1", "feedback": "Both ends going up needs an EVEN degree. An odd power sends the two ends in opposite directions."},
   {"text": "Q3 to Q4", "feedback": "Both ends going down needs an even degree and a negative leading coefficient. Neither is true here."},
   {"text": "Q3 to Q1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 3, 'Easy',
 'What is the greatest number of turning points a degree 5 polynomial can have?',
 '[{"text": "4", "feedback": "Correct."},
   {"text": "5", "feedback": "5 is the degree, which is the greatest number of ZEROS. Turning points top out one below that."},
   {"text": "3", "feedback": "One too few. A degree n polynomial can turn as many as n - 1 times."},
   {"text": "6", "feedback": "Turning points never exceed the degree, let alone beat it by one."}]'::jsonb,
 0, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 4, 'Easy',
 'A polynomial has constant 5th differences. What is its degree?',
 '[{"text": "120", "feedback": "120 is 5 factorial, which turns up when the leading coefficient is worked out. It is not a degree."},
   {"text": "5", "feedback": "Correct."},
   {"text": "4", "feedback": "Constant 4th differences belong to a degree 4 polynomial. The number of the difference and the degree match."},
   {"text": "6", "feedback": "A degree 6 polynomial has constant 6th differences, not 5th."}]'::jsonb,
 1, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 5, 'Easy',
 'What are the x-intercepts of f(x) = (x + 1)(x - 3)(x + 2)?',
 '[{"text": "1, -3 and 2", "feedback": "Every sign is flipped. Setting x + 1 = 0 gives x = -1, not +1."},
   {"text": "-1, 3 and 2", "feedback": "Two are right. The bracket x + 2 gives a NEGATIVE intercept."},
   {"text": "1, 3 and 2", "feedback": "Those are the numbers inside the brackets read straight off. Each bracket has to be set to zero and solved."},
   {"text": "-1, 3 and -2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 6, 'Easy',
 'What is the y-intercept of f(x) = (x + 1)(x - 3)(x + 2)?',
 '[{"text": "-6", "feedback": "Correct."},
   {"text": "6", "feedback": "The bracket x - 3 gives -3 at x = 0, and one negative among three factors leaves the product negative."},
   {"text": "0", "feedback": "None of the three brackets is zero when x = 0, so the product is not zero either."},
   {"text": "-4", "feedback": "That adds the three bracket constants rather than multiplying them, and takes -2 from the bracket x + 2 on the way."}]'::jsonb,
 0, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 7, 'Easy',
 'In g(x) = 2[-4(x + 7)]⁴ - 1, what is the value of a?',
 '[{"text": "-4", "feedback": "-4 is k. It sits inside the bracket, where it acts on the x-values."},
   {"text": "7", "feedback": "7 comes from d. It also sits inside the bracket, and it moves the curve sideways."},
   {"text": "-1", "feedback": "-1 is c, the vertical shift on the end."},
   {"text": "2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 8, 'Easy',
 'What does g(x) = f(x) - 1 do to the graph of f?',
 '[{"text": "Moves it down 1 unit", "feedback": "Correct."},
   {"text": "Moves it up 1 unit", "feedback": "The 1 is being subtracted from every output, which lowers the curve."},
   {"text": "Moves it right 1 unit", "feedback": "A sideways move needs the 1 inside the bracket with the x. Out here it acts on the outputs."},
   {"text": "Moves it left 1 unit", "feedback": "A sideways move needs the 1 inside the bracket with the x."}]'::jsonb,
 0, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 9, 'Easy',
 'A function whose graph has line symmetry about the y-axis is called what?',
 '[{"text": "Neither", "feedback": "Line symmetry about the y-axis is exactly the definition of one of the two named types."},
   {"text": "Periodic", "feedback": "A periodic function repeats along the x-axis. That is a different property altogether."},
   {"text": "Even", "feedback": "Correct."},
   {"text": "Odd", "feedback": "An odd function has POINT symmetry about the origin instead, so its graph looks the same after a half turn."}]'::jsonb,
 2, 'sub-poly-symmetry'),

(12, 'MHF4U', 'Polynomial Functions', 1, 10, 'Easy',
 'Which of these functions is EVEN?',
 '[{"text": "f(x) = x⁵", "feedback": "That one is ODD: replacing x with -x flips the whole thing rather than leaving it alone."},
   {"text": "f(x) = 3x⁶ + 2x² - 5", "feedback": "Correct."},
   {"text": "f(x) = x³ - 4x² + 1", "feedback": "The x³ term changes sign when x is replaced by -x while the x² term does not, so the two do not match."},
   {"text": "f(x) = x⁴ + 5x", "feedback": "The lone 5x term has an odd power, and that is enough to break the symmetry."}]'::jsonb,
 1, 'sub-poly-symmetry'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Polynomial Functions', 1, 11, 'Medium',
 'What is the end behaviour of y = -0.25x⁶?',
 '[{"text": "Q2 to Q4", "feedback": "That needs an odd degree with a negative leading coefficient. The degree here is 6."},
   {"text": "Q3 to Q4", "feedback": "Correct."},
   {"text": "Q2 to Q1", "feedback": "That is what a POSITIVE leading coefficient does to an even-degree function. This one is negative."},
   {"text": "Q3 to Q1", "feedback": "Ends going in opposite directions needs an ODD degree. An even power sends both the same way."}]'::jsonb,
 1, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 12, 'Medium',
 'State the degree and the leading coefficient of y = 21 - 2x + 4x² - 6x³.',
 '[{"text": "Degree 3, leading coefficient 21", "feedback": "The degree is right, but 21 is the constant term. The leading coefficient belongs to the highest power."},
   {"text": "Degree 4, leading coefficient 4", "feedback": "There is no x⁴ term here. The 4 sits on x squared."},
   {"text": "Degree 1, leading coefficient -2", "feedback": "That reads the second term. The polynomial is written lowest power first, so the leading term is at the END."},
   {"text": "Degree 3, leading coefficient -6", "feedback": "Correct."}]'::jsonb,
 3, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 13, 'Medium',
 'How many turning points could g(x) = -20x⁶ - 5x³ + x² - 17 have?',
 '[{"text": "6, 4, 2 or 0", "feedback": "An even-degree polynomial has an ODD number of turning points, because both ends go the same way."},
   {"text": "Any number up to 6", "feedback": "6 is the degree, and turning points top out one below it. They also cannot be even here."},
   {"text": "Exactly 5, no more and no fewer", "feedback": "5 is the maximum. The curve can have fewer, as long as the count stays odd."},
   {"text": "5, 3 or 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 14, 'Medium',
 E'A polynomial has constant third differences equal to 42.\nWhat are its degree and its leading coefficient?',
 '[{"text": "Degree 3, leading coefficient 7", "feedback": "Correct."},
   {"text": "Degree 3, leading coefficient 42", "feedback": "The degree is right. The constant difference is a times 3 factorial, so the 42 still has to be divided by 6."},
   {"text": "Degree 4, leading coefficient 7", "feedback": "Third differences go with degree 3. The number of the difference matches the degree."},
   {"text": "Degree 3, leading coefficient 14", "feedback": "That divides by 3 rather than by 3 factorial, which is 6."}]'::jsonb,
 0, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 15, 'Medium',
 'For h(x) = (x - 4)²(x + 3)³, give the degree and the end behaviour.',
 '[{"text": "Degree 6, Q3 to Q1", "feedback": "The exponents on the two brackets were MULTIPLIED together. Multiplying powers of x adds them instead."},
   {"text": "Degree 5, Q2 to Q1", "feedback": "Both ends going the same way needs an even degree, and 5 is odd."},
   {"text": "Degree 5, Q3 to Q1", "feedback": "Correct."},
   {"text": "Degree 5, Q2 to Q4", "feedback": "The degree is right, but nothing here is negative. Multiplying the leading terms gives a positive coefficient."}]'::jsonb,
 2, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 16, 'Medium',
 'What is the leading coefficient of p(x) = -4(2x + 5)(x - 2)(x + 4)?',
 '[{"text": "8", "feedback": "The size is right but the sign is not. There is one minus out front and none inside the leading terms."},
   {"text": "-8", "feedback": "Correct."},
   {"text": "-4", "feedback": "The -4 out front is only part of it. The 2 in front of the x in the first bracket multiplies in too."},
   {"text": "-160", "feedback": "That multiplies -4 by the bracket CONSTANTS and drops the minus on the -2 along the way. The constants settle the y-intercept, not the leading coefficient."}]'::jsonb,
 1, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 17, 'Medium',
 'If f(x) = x³, what is the equation of g(x) = (1/2)f(x + 2) - 4?',
 '[{"text": "g(x) = 2(x + 2)³ - 4", "feedback": "The 1/2 was turned over. It multiplies the whole function, which squashes it toward the x-axis."},
   {"text": "g(x) = (1/2)(x + 2)³ + 4", "feedback": "The 4 is being subtracted, so it stays negative on the end."},
   {"text": "g(x) = (1/2)(x + 2)³ - 4", "feedback": "Correct."},
   {"text": "g(x) = (1/2)(x - 2)³ - 4", "feedback": "The bracket reads x + 2, and it goes into the parent function exactly as written."}]'::jsonb,
 2, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 18, 'Medium',
 'In g(x) = 2[-4(x + 7)]⁴ - 1, describe the HORIZONTAL change.',
 '[{"text": "Reflection in the y-axis and compression by a factor of 1/4", "feedback": "Correct."},
   {"text": "Reflection in the y-axis and stretch by a factor of 4", "feedback": "k = -4 squeezes the curve rather than stretching it. The scale factor is 1 over k."},
   {"text": "Compression by a factor of 1/4, with no reflection in the y-axis", "feedback": "The minus sign on the 4 flips the curve across the y-axis as well as squeezing it."},
   {"text": "A horizontal shift to the left of 4 units", "feedback": "The 4 multiplies the bracket rather than being added to x, so it scales rather than slides. The shift comes from the 7."}]'::jsonb,
 0, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 19, 'Medium',
 'Is f(x) = x³ - 4x² + 1 even, odd or neither?',
 '[{"text": "Neither", "feedback": "Correct."},
   {"text": "Odd, with point symmetry about the origin", "feedback": "An odd function needs f(-x) to be the exact negative of f(x), and the -4x² term keeps its sign. The graph does have point symmetry, but about its own inflection point rather than the origin."},
   {"text": "Even, with line symmetry about the y-axis", "feedback": "An even function needs f(-x) to match f(x), and the x³ term changes sign."},
   {"text": "Both even and odd", "feedback": "Only the zero function manages both, and this one is not it."}]'::jsonb,
 0, 'sub-poly-symmetry'),

(12, 'MHF4U', 'Polynomial Functions', 1, 20, 'Medium',
 'Is f(x) = x⁴ + 5x even, odd or neither?',
 '[{"text": "Even, with line symmetry about the y-axis", "feedback": "The x⁴ term is even, but the 5x term flips sign, so f(-x) does not match f(x)."},
   {"text": "Odd, with point symmetry about the origin", "feedback": "The 5x term is odd, but the x⁴ term does not flip sign, so f(-x) is not the negative of f(x)."},
   {"text": "Both even and odd", "feedback": "That labels each term on its own and reports the two labels together. A function has to be tested as a whole, and only the zero function carries both."},
   {"text": "Neither", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-symmetry'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): reading characteristics both ways.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Polynomial Functions', 1, 21, 'Challenge',
 'Which function has end behaviour running from Q2 to Q4?',
 '[{"text": "y = -0.25x⁶", "feedback": "The leading coefficient is negative, which is right, but an even degree sends both ends down: Q3 to Q4."},
   {"text": "y = -(1/2)x³", "feedback": "Correct."},
   {"text": "y = 3x⁷", "feedback": "The degree is odd, which is right, but a positive leading coefficient sends it from Q3 to Q1 instead."},
   {"text": "y = 2x⁴", "feedback": "An even degree sends both ends the same way, so this one runs Q2 to Q1."}]'::jsonb,
 1, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 22, 'Challenge',
 E'A power function has domain all real numbers, range y ≥ 0, line symmetry\nabout the y-axis and end behaviour Q2 to Q1. What can be said about it?',
 '[{"text": "Odd degree with a positive leading coefficient", "feedback": "An odd degree gives a range of all real numbers and point symmetry, not a floor at zero and line symmetry."},
   {"text": "Even degree with a negative leading coefficient", "feedback": "A negative leading coefficient with an even degree sends both ends DOWN, which is Q3 to Q4, and the range would be capped above rather than below."},
   {"text": "Odd degree with a negative leading coefficient", "feedback": "That runs Q2 to Q4 and has point symmetry, so neither the end behaviour nor the symmetry matches."},
   {"text": "Even degree with a positive leading coefficient", "feedback": "Correct."}]'::jsonb,
 3, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 23, 'Challenge',
 E'A table of values for a polynomial has constant third differences of -24.\nWhat are its degree and its leading coefficient?',
 '[{"text": "Degree 4, leading coefficient -1", "feedback": "That reads third differences as belonging to degree 4 and divides by 4 factorial. The number of the constant difference is the degree itself."},
   {"text": "Degree 3, leading coefficient -12", "feedback": "That divides by 2 rather than by 3 factorial, which is 6."},
   {"text": "Degree 3, leading coefficient -4", "feedback": "Correct."},
   {"text": "Degree 3, leading coefficient -24", "feedback": "The degree is right. The constant difference is a times 3 factorial, so the -24 still has to be divided by 6."}]'::jsonb,
 2, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 24, 'Challenge',
 'How many x-intercepts could h(x) = -x⁵ + x⁴ - x³ + x² - x + 1 have?',
 '[{"text": "5, 4, 3, 2 or 1", "feedback": "Correct."},
   {"text": "5, 4, 3, 2, 1 or 0", "feedback": "An odd-degree polynomial runs from one end of the y-axis to the other, so it has to cross at least once. Zero is impossible."},
   {"text": "Exactly 5, no more and no fewer", "feedback": "5 is the maximum. Repeated or complex roots can leave it with fewer crossings."},
   {"text": "Anything from 0 to 4", "feedback": "4 is the maximum number of TURNING points. The number of intercepts can reach the degree itself."}]'::jsonb,
 0, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 25, 'Challenge',
 'Give the x-intercepts of g(x) = -x(x + 1)(x + 2)², including the order of each.',
 '[{"text": "0 and -2 of order 1, and -1 of order 2", "feedback": "The squared bracket is x + 2, not x + 1."},
   {"text": "0 and -1 of order 1, and -2 of order 2", "feedback": "Correct."},
   {"text": "0 and 1 of order 1, and 2 of order 2", "feedback": "Every sign is flipped. Setting x + 1 = 0 gives x = -1."},
   {"text": "0, -1 and -2, all three of them of order 1", "feedback": "The bracket x + 2 is squared, so that zero is repeated and the curve touches the axis there rather than crossing."}]'::jsonb,
 1, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 26, 'Challenge',
 'What is the y-intercept of h(x) = (x - 4)²(x + 3)³?',
 '[{"text": "108", "feedback": "That takes 4 straight off the first bracket instead of the value it has at x = 0, and drops its exponent as well."},
   {"text": "0", "feedback": "Neither bracket is zero at x = 0, so the product is not zero. The intercepts on the x-axis are at 4 and -3."},
   {"text": "432", "feedback": "Correct."},
   {"text": "-432", "feedback": "The -4 is SQUARED, and squaring turns it positive before it meets the 27."}]'::jsonb,
 2, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 27, 'Challenge',
 E'f(x) = x⁴ is compressed vertically by 3/5, stretched horizontally by 2,\nreflected in the y-axis, and moved 1 up and 4 left. Write g(x).',
 '[{"text": "g(x) = (3/5)[-(1/2)(x + 4)]⁴ + 1", "feedback": "Correct."},
   {"text": "g(x) = (3/5)[-2(x + 4)]⁴ + 1", "feedback": "A horizontal stretch by 2 needs k = 1/2, because the graph is scaled by 1 over k. Putting 2 in squeezes it."},
   {"text": "g(x) = (5/3)[-(1/2)(x + 4)]⁴ + 1", "feedback": "A compression by 3/5 means a is 3/5. Turning it over would stretch the curve instead."},
   {"text": "g(x) = (3/5)[-(1/2)(x - 4)]⁴ + 1", "feedback": "A move LEFT is written x + 4. The sign inside the bracket is the opposite of the direction."}]'::jsonb,
 0, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 28, 'Challenge',
 E'f(x) = x³ is compressed horizontally by 1/4, stretched vertically by 5,\nreflected in the x-axis, and moved 2 left and 7 up. Write g(x).',
 '[{"text": "g(x) = 5[4(x + 2)]³ + 7", "feedback": "The reflection in the x-axis never reached a. It is the minus in front that flips the curve over."},
   {"text": "g(x) = -5[4(x - 2)]³ + 7", "feedback": "A move LEFT is written x + 2. The sign inside the bracket is the opposite of the direction."},
   {"text": "g(x) = -5[4(x + 2)]³ + 7", "feedback": "Correct."},
   {"text": "g(x) = -5[(1/4)(x + 2)]³ + 7", "feedback": "A horizontal compression by 1/4 needs k = 4, because the graph is scaled by 1 over k."}]'::jsonb,
 2, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 29, 'Challenge',
 'Is f(x) = -3x⁴ + 6x² - 10 even, odd or neither, and why?',
 '[{"text": "Neither, because of the constant term -10", "feedback": "A constant is an even-power term, x to the power 0, so it does not break the symmetry."},
   {"text": "Both even and odd", "feedback": "Only the zero function manages both, and this one has a constant of -10."},
   {"text": "Even, because f(-x) works out identical to f(x)", "feedback": "Correct."},
   {"text": "Odd, because every term changes sign when x is replaced by -x", "feedback": "Substituting -x leaves all three terms exactly as they were, because every power present is even."}]'::jsonb,
 2, 'sub-poly-symmetry'),

(12, 'MHF4U', 'Polynomial Functions', 1, 30, 'Challenge',
 'Which statement is true of EVERY cubic function?',
 '[{"text": "It is an odd function", "feedback": "Only cubics whose point of symmetry sits at the origin are odd. Adding a constant moves that point without destroying the symmetry."},
   {"text": "It has line symmetry about the y-axis", "feedback": "Line symmetry about the y-axis belongs to even functions, and a cubic sends its two ends in opposite directions."},
   {"text": "It has no symmetry of any kind, about a line or a point", "feedback": "Every cubic is symmetric about the point where it changes concavity, even when that point is nowhere near the origin."},
   {"text": "It has point symmetry about its inflection point", "feedback": "Correct."}]'::jsonb,
 3, 'sub-poly-symmetry'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): building equations and reasoning backwards.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Polynomial Functions', 1, 31, 'Advanced',
 'For very large positive values of x, which of these functions is largest?',
 '[{"text": "y = 2x⁴", "feedback": "The bigger coefficient loses to the bigger degree in the long run. By x = 10 the degree 7 term is already thousands of times larger."},
   {"text": "y = -0.25x⁶", "feedback": "The leading coefficient is negative, so this function heads DOWN for large x rather than up."},
   {"text": "y = -(1/2)x³", "feedback": "This one is negative for large positive x, so it is the smallest on the list rather than the largest."},
   {"text": "y = 3x⁷", "feedback": "Correct."}]'::jsonb,
 3, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 32, 'Advanced',
 'A power function y = ax⁵ passes through (2, 32). What is a?',
 '[{"text": "2", "feedback": "That reads the x-value straight off. Substitute the point in and solve for a."},
   {"text": "1/32", "feedback": "That divides 1 by 32 rather than 32 by 32."},
   {"text": "1", "feedback": "Correct."},
   {"text": "32", "feedback": "That reads the y-value straight off. The 2 raised to the power 5 is already 32, so a has nothing left to contribute."}]'::jsonb,
 2, 'sub-power-functions'),

(12, 'MHF4U', 'Polynomial Functions', 1, 33, 'Advanced',
 E'For f(x) = -3x⁴ + 6x² - 10, which finite difference is constant,\nand what is its value?',
 '[{"text": "The 3rd, and it equals -18", "feedback": "The degree here is 4, so it is the 4th differences that settle down, not the 3rd."},
   {"text": "The 4th, and it equals -12", "feedback": "That multiplies by 4 rather than by 4 factorial, which is 24."},
   {"text": "The 4th, and it equals -72", "feedback": "Correct."},
   {"text": "The 4th, and it equals -3", "feedback": "The difference which is constant is right. Its value is the leading coefficient times 4 factorial, not the leading coefficient alone."}]'::jsonb,
 2, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 34, 'Advanced',
 E'A polynomial has 4 turning points, 3 x-intercepts and end behaviour\nrunning Q2 to Q4. Give its least possible degree and the sign of its\nleading coefficient.',
 '[{"text": "Degree 3, negative leading coefficient", "feedback": "A cubic turns at most twice, and this curve turns four times."},
   {"text": "Degree 5, negative leading coefficient", "feedback": "Correct."},
   {"text": "Degree 4, negative leading coefficient", "feedback": "4 turning points need a degree of at least 5, and an even degree cannot send its two ends in opposite directions anyway."},
   {"text": "Degree 5, positive leading coefficient", "feedback": "A positive leading coefficient on an odd degree runs Q3 to Q1, which is the other way round."}]'::jsonb,
 1, 'sub-poly-characteristics'),

(12, 'MHF4U', 'Polynomial Functions', 1, 35, 'Advanced',
 E'A polynomial has x-intercepts at -2 (order 2), 1/2 and 4, and it passes\nthrough (1, 5). Write its equation.',
 '[{"text": "f(x) = -(5/27)(x + 2)(2x - 1)(x - 4)", "feedback": "The intercept at -2 has order 2, so its bracket appears twice."},
   {"text": "f(x) = -(5/27)(x + 2)²(2x - 1)(x - 4)", "feedback": "Correct."},
   {"text": "f(x) = (5/27)(x + 2)²(2x - 1)(x - 4)", "feedback": "Substituting the point gives -27k = 5, so k comes out negative."},
   {"text": "f(x) = -(5/27)(x - 2)²(2x - 1)(x - 4)", "feedback": "An intercept at -2 comes from the bracket x + 2. The sign inside is the opposite of the intercept."}]'::jsonb,
 1, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 36, 'Advanced',
 E'A quartic has zeros at -3, -1 and 2 (order 2), and passes through (1, 4).\nWrite its equation.',
 '[{"text": "g(x) = 2(x + 3)(x + 1)(x - 2)²", "feedback": "The equation for k was solved upside down, so the value in front came out inverted."},
   {"text": "g(x) = (1/2)(x - 3)(x - 1)(x + 2)²", "feedback": "Every sign is flipped. A zero at -3 comes from the bracket x + 3."},
   {"text": "g(x) = (1/2)(x + 3)(x + 1)(x - 2)", "feedback": "The zero at 2 has order 2, so its bracket appears twice. As written this is only a cubic."},
   {"text": "g(x) = (1/2)(x + 3)(x + 1)(x - 2)²", "feedback": "Correct."}]'::jsonb,
 3, 'sub-factored-form'),

(12, 'MHF4U', 'Polynomial Functions', 1, 37, 'Advanced',
 'For g(x) = 2[-4(x + 7)]⁴ - 1, state a, k, d and c.',
 '[{"text": "a = 2, k = -4, d = -7, c = 1", "feedback": "The 1 is being subtracted on the end, so c is negative."},
   {"text": "a = 2, k = -4, d = -7, c = -1", "feedback": "Correct."},
   {"text": "a = 2, k = -4, d = 7, c = -1", "feedback": "The general form is x - d, and the bracket here reads x + 7, so d is negative."},
   {"text": "a = 2, k = 4, d = -7, c = -1", "feedback": "The minus in front of the 4 belongs to k. It reflects the curve across the y-axis."}]'::jsonb,
 1, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 38, 'Advanced',
 E'f(x) = x⁴, so the point (2, 16) lies on it.\nWhere does that point land on g(x) = -f[(1/2)(x - 1)] + 7?',
 '[{"text": "(5, -9)", "feedback": "Correct."},
   {"text": "(2, -9)", "feedback": "The x-coordinate was carried straight across. Both the 1/2 and the subtraction inside the bracket act on it."},
   {"text": "(5, 23)", "feedback": "The x-coordinate is right, but the minus in front of f flips the output before the 7 is added."},
   {"text": "(5, -23)", "feedback": "The + 7 was carried inside the reflection. It is added after the output has been flipped, not before."}]'::jsonb,
 0, 'sub-poly-transformations'),

(12, 'MHF4U', 'Polynomial Functions', 1, 39, 'Advanced',
 'A function has point symmetry about the origin and f(3) = -5. What is f(-3)?',
 '[{"text": "-3", "feedback": "That reports an x-value with its sign changed. The question asks for an output."},
   {"text": "5", "feedback": "Correct."},
   {"text": "-5", "feedback": "That is what an EVEN function would give. Point symmetry about the origin flips the sign of the output as well as the input."},
   {"text": "3", "feedback": "That reports an x-value. The question asks for an output."}]'::jsonb,
 1, 'sub-poly-symmetry'),

(12, 'MHF4U', 'Polynomial Functions', 1, 40, 'Advanced',
 'Which best describes f(x) = x⁵ - x?',
 '[{"text": "Neither even nor odd", "feedback": "Both terms flip sign together, which is exactly what makes a function odd."},
   {"text": "Both even and odd", "feedback": "Only the zero function manages both, and this one takes the value 30 at x = 2."},
   {"text": "Odd, with point symmetry about the origin", "feedback": "Correct."},
   {"text": "Even, with line symmetry about the y-axis", "feedback": "Both powers present are odd, so substituting -x flips the whole thing rather than leaving it alone."}]'::jsonb,
 2, 'sub-poly-symmetry');
