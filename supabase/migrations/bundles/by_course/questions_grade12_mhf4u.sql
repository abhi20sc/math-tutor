-- ===========================================================================
-- ASTRO MATH ASSIST — Grade 12 — MHF4U, Advanced Functions
-- ===========================================================================
--
-- 280 questions, 2 figures.
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


-- --- questions_mhf4u_u1.sql ---

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

-- --- questions_mhf4u_u2.sql ---

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

-- --- questions_mhf4u_u3.sql ---

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

-- --- questions_mhf4u_u4.sql ---

-- ===========================================================================
-- MHF4U — Unit 4: Trig in Radians — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  Radian measure
--   Lesson 2  Finding exact trig ratios
--   Lesson 3  Graphing all six trig functions
--   Lesson 4  Transforming trig functions
--   Lesson 5  Trig applications
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs. Exact values are given
-- in the form the Jensen material uses (1/√3 rather than √3/3), and no
-- distractor is ever an equivalent form of the answer in other clothes.
--
-- THE CONVERSION THAT BITES. Half the wrong answers in this unit come from
-- multiplying by π/180 when the job called for 180/π, or the reverse. Those
-- distractors are deliberately kept realistic — the numbers a student would
-- actually write down — rather than being made obviously silly, because a
-- student who cannot tell 71.0 from 0.0216 has not learned anything from
-- being shown an absurdity.
--
-- FIGURES. One question carries one: 20, the ski lodge built against a
-- cliff. That question genuinely cannot be asked without a picture — which
-- angle sits where, and which of the two nested right triangles the 15 m
-- belongs to, is the entire difficulty. The drawing is deliberately out of
-- proportion: measuring it against the stated 15 m gives a base of about
-- 12 m, whose nearest option is wrong, while the answer is about 6.5.
--
-- Nothing else here earns one. The graphing questions would need a curve on
-- a grid, and a grid states the period, the asymptotes and the amplitude
-- outright; those are asked from key values instead.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file -> figures_mhf4u.sql.
-- The figure file must come second, because the delete below clears the
-- figure column along with the rest of each row.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MHF4U' and unit = 'Trig in Radians';

insert into misconception_labels (tag, label) values
  ('sub-radian-measure',    'Radian measure and arc length'),
  ('sub-exact-ratios-rad',  'Exact trig ratios in radians'),
  ('sub-six-trig-graphs',   'The six trig functions and their graphs'),
  ('sub-trig-transform-rad','Transforming trig functions'),
  ('sub-trig-apps-rad',     'Trig applications in radians')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig in Radians', 4, 1, 'Easy',
 'How many radians are there in 180°?',
 '[{"text": "2π", "feedback": "2π is a FULL turn, which is 360 degrees. Half a turn is half of that."},
   {"text": "π/2", "feedback": "π/2 is a quarter turn, which is 90 degrees."},
   {"text": "360", "feedback": "360 is a count of degrees, not radians. The two systems measure the same turn with different units."},
   {"text": "π", "feedback": "Correct."}]'::jsonb,
 3, 'sub-radian-measure'),

(12, 'MHF4U', 'Trig in Radians', 4, 2, 'Easy',
 'Convert 75° to an exact radian measure.',
 '[{"text": "5π/12", "feedback": "Correct."},
   {"text": "12π/5", "feedback": "The fraction is upside down. Multiply by π/180 and cancel."},
   {"text": "75π", "feedback": "The 180 in the denominator was dropped. Multiplying by π alone leaves the answer 180 times too big."},
   {"text": "5π/6", "feedback": "That is the radian measure of 150 degrees. Check the cancelling: 75 and 180 share a factor of 15."}]'::jsonb,
 0, 'sub-radian-measure'),

(12, 'MHF4U', 'Trig in Radians', 4, 3, 'Easy',
 'What is the exact value of sin(π/6)?',
 '[{"text": "√3/2", "feedback": "That is sin(π/3). In the special triangle the side opposite the smaller angle is the short one."},
   {"text": "1/√2", "feedback": "That is sin(π/4), from the other special triangle."},
   {"text": "π/6", "feedback": "A sine is a ratio between -1 and 1. It is never the angle itself."},
   {"text": "1/2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exact-ratios-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 4, 'Easy',
 'In which quadrant does the angle 5π/3 lie?',
 '[{"text": "The second", "feedback": "The second quadrant runs from π/2 to π. 5π/3 is well beyond a half turn."},
   {"text": "The first", "feedback": "The first quadrant stops at π/2, and 5π/3 is nearly a full turn."},
   {"text": "The fourth", "feedback": "Correct."},
   {"text": "The third", "feedback": "The third quadrant runs from π to 3π/2, and 5π/3 is past 3π/2."}]'::jsonb,
 2, 'sub-exact-ratios-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 5, 'Easy',
 'What is the period of y = tan x, in radians?',
 '[{"text": "π/2", "feedback": "π/2 is where the first asymptote sits. The pattern does not start over until π."},
   {"text": "4π", "feedback": "Nothing stretches this graph. The plain tangent repeats faster than sine, not slower."},
   {"text": "π", "feedback": "Correct."},
   {"text": "2π", "feedback": "2π is the period of sine and cosine. Tangent repeats twice as often, because it is built from their ratio."}]'::jsonb,
 2, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 6, 'Easy',
 'Where does y = csc x have its vertical asymptotes?',
 '[{"text": "Wherever sin x = 1", "feedback": "Where sine is 1 the cosecant is also 1, which is a perfectly ordinary point."},
   {"text": "Wherever sin x = 0", "feedback": "Correct."},
   {"text": "Wherever cos x = 0", "feedback": "That gives the asymptotes of SECANT, which is built from cosine."},
   {"text": "Nowhere", "feedback": "Cosecant is one over sine, and sine does reach zero, so the reciprocal blows up there."}]'::jsonb,
 1, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 7, 'Easy',
 'What is the amplitude of y = 5 sin[2(x - π/4)] - 1?',
 '[{"text": "2", "feedback": "2 is k, which sits inside the bracket and changes the period."},
   {"text": "1", "feedback": "1 is the vertical shift, which moves the curve down rather than changing its height."},
   {"text": "-1", "feedback": "Amplitude is a distance, so it is never negative. -1 is the vertical shift."},
   {"text": "5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 8, 'Easy',
 'What is the period of y = cos(x + π/3) + 1?',
 '[{"text": "π", "feedback": "Halving the period would need k = 2 inside. Here k is 1, so the curve keeps the parent period."},
   {"text": "2π/3", "feedback": "π/3 is the phase shift, which slides the curve sideways without changing how often it repeats."},
   {"text": "π/3", "feedback": "π/3 is the phase shift. Only k affects the period, and k is 1 here."},
   {"text": "2π", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 9, 'Easy',
 'The arc length formula a = rθ needs θ measured in what?',
 '[{"text": "Radian measure", "feedback": "Correct."},
   {"text": "Degree measure", "feedback": "In degrees the formula picks up an extra factor of π/180. Radians are defined precisely so this formula comes out clean."},
   {"text": "Either one works", "feedback": "It makes an enormous difference: the same angle in degrees is about 57 times the number it is in radians."},
   {"text": "Revolutions", "feedback": "A revolution is 2π radians, so using it would leave the formula short by that factor."}]'::jsonb,
 0, 'sub-trig-apps-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 10, 'Easy',
 E'A circle has radius 4 cm and a central angle of 2 radians.\nHow long is the arc it cuts off?',
 '[{"text": "8π cm", "feedback": "No π is needed. The angle is already given in radians, which is exactly what makes the formula this simple."},
   {"text": "8 cm", "feedback": "Correct."},
   {"text": "2 cm", "feedback": "That reports the angle. The arc length is the radius multiplied by it."},
   {"text": "0.5 cm", "feedback": "The formula multiplies rather than divides: a = rθ."}]'::jsonb,
 1, 'sub-trig-apps-rad'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig in Radians', 4, 11, 'Medium',
 'Convert 4π/9 radians to an exact degree measure.',
 '[{"text": "20°", "feedback": "The 4 in the numerator was dropped. Multiply the whole fraction by 180/π."},
   {"text": "160°", "feedback": "That multiplies by 360/π, using a full turn where the conversion takes a half turn."},
   {"text": "45°", "feedback": "That divides 180 by 4 and ignores the 9. Multiply the fraction as a whole."},
   {"text": "80°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-radian-measure'),

(12, 'MHF4U', 'Trig in Radians', 4, 12, 'Medium',
 'Convert 1.24 radians to degrees, to one decimal place.',
 '[{"text": "0.4°", "feedback": "That divides by π and stops. The 180 still has to be multiplied in."},
   {"text": "71.0°", "feedback": "Correct."},
   {"text": "0.0216°", "feedback": "That multiplies by π/180, which is the conversion the other way. Going TO degrees multiplies by 180/π."},
   {"text": "142.1°", "feedback": "That doubles the answer, as though the conversion factor were 360/π."}]'::jsonb,
 1, 'sub-radian-measure'),

(12, 'MHF4U', 'Trig in Radians', 4, 13, 'Medium',
 'What is the exact value of sin(5π/3)?',
 '[{"text": "-1/√2", "feedback": "The sign is right but the related acute angle is not. 2π - 5π/3 gives π/3, not π/4."},
   {"text": "-√3/2", "feedback": "Correct."},
   {"text": "√3/2", "feedback": "The related acute angle is right, but 5π/3 lands in the fourth quadrant, where sine is negative."},
   {"text": "-1/2", "feedback": "The sign is right but the related acute angle is not. 2π - 5π/3 gives π/3, not π/6."}]'::jsonb,
 1, 'sub-exact-ratios-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 14, 'Medium',
 'What is the exact value of cos(5π/4)?',
 '[{"text": "-√3/2", "feedback": "The sign is right but the related acute angle is not. 5π/4 - π gives π/4, not π/6."},
   {"text": "-1/2", "feedback": "The sign is right but the related acute angle is not. 5π/4 - π gives π/4, not π/3."},
   {"text": "-1/√2", "feedback": "Correct."},
   {"text": "1/√2", "feedback": "The related acute angle is right, but 5π/4 lands in the third quadrant, where cosine is negative."}]'::jsonb,
 2, 'sub-exact-ratios-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 15, 'Medium',
 'What is the value of tan(3π)?',
 '[{"text": "1", "feedback": "Tangent is 1 at π/4 and at angles coterminal with it. 3π is a whole number of half turns."},
   {"text": "-1", "feedback": "That is cos(3π), not the tangent. Tangent is sine over cosine, so the sine still has to be worked out."},
   {"text": "0", "feedback": "Correct."},
   {"text": "Undefined", "feedback": "Tangent is undefined where COSINE is zero, and cos(3π) is -1. It is the sine on top that vanishes here."}]'::jsonb,
 2, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 16, 'Medium',
 'What is the value of sin(3π/2)?',
 '[{"text": "Undefined", "feedback": "Sine is defined everywhere. It is tangent and secant that have gaps."},
   {"text": "-1", "feedback": "Correct."},
   {"text": "1", "feedback": "That is sin(π/2), a quarter turn round. Three quarters of a turn puts the point at the BOTTOM of the circle."},
   {"text": "0", "feedback": "Sine is zero at 0, π and 2π. Three quarters of a turn is between two of those, at the extreme."}]'::jsonb,
 1, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 17, 'Medium',
 'For y = cos(x + π/3) + 1, give the phase shift and the vertical shift.',
 '[{"text": "π/3 left, 1 down", "feedback": "The 1 is being added, so the whole curve rises."},
   {"text": "1 left, π/3 up", "feedback": "The two numbers have swapped jobs. What sits inside the bracket moves the curve sideways."},
   {"text": "π/3 left, 1 up", "feedback": "Correct."},
   {"text": "π/3 right, 1 up", "feedback": "The bracket reads x + π/3, and a plus inside moves the curve left."}]'::jsonb,
 2, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 18, 'Medium',
 'Give the maximum and minimum values of y = 5 sin[2(x - π/4)] - 1.',
 '[{"text": "Maximum 6, minimum -4", "feedback": "The vertical shift is -1, so the axis moves DOWN, taking both turning points with it."},
   {"text": "Maximum 4, minimum -5", "feedback": "The vertical shift was taken off the maximum but never off the minimum. Both turning points move with the axis."},
   {"text": "Maximum 4, minimum -6", "feedback": "Correct."},
   {"text": "Maximum 5, minimum -5", "feedback": "That is the plain 5 sin curve, before the - 1 pulled the whole thing down."}]'::jsonb,
 2, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 19, 'Medium',
 E'An arc of 22.5 cm subtends a central angle of 4π/3 radians.\nWhat is the radius, to one decimal place?',
 '[{"text": "5.4 cm", "feedback": "Correct."},
   {"text": "94.2 cm", "feedback": "That multiplies rather than divides. Rearranging a = rθ for r puts the angle underneath."},
   {"text": "5.6 cm", "feedback": "That divides by 4 rather than by 4π/3. The π has to stay in the denominator."},
   {"text": "16.9 cm", "feedback": "That divides by 4/3 and drops the π entirely."}]'::jsonb,
 0, 'sub-trig-apps-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 20, 'Medium',
 E'A ski lodge is built against a vertical cliff, as shown. The cliff face\nis 15 m, the angle at the base between the cliff and the brace is π/3,\nand the angle between the brace and the ground is π/6. Find the exact\nlength of the base b.',
 '[{"text": "15√3/4 m", "feedback": "Correct."},
   {"text": "15√3/2 m", "feedback": "The cosine of π/6 was applied to the 15 m cliff instead of to the brace. The brace is only half as long as the cliff."},
   {"text": "15/2 m", "feedback": "That is the length of the BRACE. One more step is needed to get from the brace down to the base."},
   {"text": "15√3 m", "feedback": "That takes the 15 m as a leg and applies tan(π/3) to it, in one triangle. The cliff is the hypotenuse of the upper one."}]'::jsonb,
 0, 'sub-trig-apps-rad'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): reciprocal ratios, quadrant work, building equations.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig in Radians', 4, 21, 'Challenge',
 'Convert 6.91 radians to degrees, to one decimal place.',
 '[{"text": "2.2°", "feedback": "That divides by π and stops. The 180 still has to be multiplied in."},
   {"text": "395.9°", "feedback": "Correct."},
   {"text": "35.9°", "feedback": "That takes the answer down by a full turn. 6.91 radians is more than 2π, so its degree measure is above 360."},
   {"text": "0.121°", "feedback": "That multiplies by π/180, which is the conversion the other way round."}]'::jsonb,
 1, 'sub-radian-measure'),

(12, 'MHF4U', 'Trig in Radians', 4, 22, 'Challenge',
 'Convert 9° to an exact radian measure.',
 '[{"text": "20π", "feedback": "The fraction was turned upside down before the π was attached."},
   {"text": "π/20", "feedback": "Correct."},
   {"text": "20/π", "feedback": "The π and the 20 have swapped. Multiplying by π/180 leaves the π on top."},
   {"text": "π/9", "feedback": "That reads the 9 straight into the denominator and loses the 180 altogether."}]'::jsonb,
 1, 'sub-radian-measure'),

(12, 'MHF4U', 'Trig in Radians', 4, 23, 'Challenge',
 'What is the exact value of cot(π/3)?',
 '[{"text": "2/√3", "feedback": "2/√3 is csc(π/3). Cotangent comes from tangent, not from sine."},
   {"text": "1/√3", "feedback": "Correct."},
   {"text": "√3", "feedback": "That is tan(π/3). Cotangent is its reciprocal, so the fraction turns over."},
   {"text": "1/2", "feedback": "1/2 is cos(π/3). Cotangent is cosine over SINE, not cosine on its own."}]'::jsonb,
 1, 'sub-exact-ratios-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 24, 'Challenge',
 'What is the exact value of sec(11π/6)?',
 '[{"text": "2/√3", "feedback": "Correct."},
   {"text": "-2/√3", "feedback": "11π/6 lands in the FOURTH quadrant, where cosine and therefore secant are positive."},
   {"text": "2", "feedback": "2 is sec(π/3). The related acute angle here is π/6, not π/3."},
   {"text": "√3/2", "feedback": "That is cos(11π/6) itself. Secant is its reciprocal, so the fraction turns over."}]'::jsonb,
 0, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 25, 'Challenge',
 E'The terminal arm of θ passes through the point (-4, 2).\nFind the exact values of cot θ and sin θ.',
 '[{"text": "cot θ = -2 and sin θ = -1/√5", "feedback": "The minus belongs to the x-coordinate. Sine is built from y over r, and both of those are positive here."},
   {"text": "cot θ = 2 and sin θ = 1/√5", "feedback": "The x-coordinate is negative and the y-coordinate is positive, so their ratio comes out negative."},
   {"text": "cot θ = -2 and sin θ = 1/√5", "feedback": "Correct."},
   {"text": "cot θ = -1/2 and sin θ = 1/√5", "feedback": "The cotangent is upside down. It is x over y, so the 4 sits on top."}]'::jsonb,
 2, 'sub-exact-ratios-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 26, 'Challenge',
 'Why does the graph of y = sec x never take a value strictly between -1 and 1?',
 '[{"text": "Because cosine is always positive", "feedback": "Cosine is negative for half of every turn, and secant is negative there too. The bound is about SIZE, not sign."},
   {"text": "It does take those values, near its asymptotes", "feedback": "Near an asymptote secant grows without bound. It is at cosine peaks that it comes closest to zero, and even then it only reaches 1."},
   {"text": "Because cos x is never bigger than 1 in size, so its reciprocal is never smaller than 1", "feedback": "Correct."},
   {"text": "Because secant is undefined", "feedback": "Secant is undefined only where cosine is zero. Everywhere else it has a perfectly good value."}]'::jsonb,
 2, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 27, 'Challenge',
 'Give the period and the phase shift of y = 5 sin[2(x - π/4)] - 1.',
 '[{"text": "Period π, shifted π/4 left", "feedback": "The period is right. The bracket reads x - π/4, and a minus inside moves the curve right."},
   {"text": "Period π, shifted π/8 right", "feedback": "The π/4 is already outside the k, sitting in the (x - d) bracket, so it is the shift as it stands rather than being divided by 2."},
   {"text": "Period π, shifted π/4 right", "feedback": "Correct."},
   {"text": "Period 2π, shifted π/4 right", "feedback": "The shift is right. k = 2 halves the period, so it comes to π rather than 2π."}]'::jsonb,
 2, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 28, 'Challenge',
 E'Write the equation of a cosine function with amplitude 3, period π,\nshifted π/2 to the right and 2 down.',
 '[{"text": "y = 3 cos[2(x - π/2)] - 2", "feedback": "Correct."},
   {"text": "y = 3 cos[2(x + π/2)] - 2", "feedback": "A shift RIGHT is written x - π/2. The sign inside the bracket is the opposite of the direction."},
   {"text": "y = 3 cos[(1/2)(x - π/2)] - 2", "feedback": "k is 2π divided by the period, so a period of π needs k = 2. A k below 1 would stretch the curve instead."},
   {"text": "y = 3 cos[2(x - π/2)] + 2", "feedback": "A shift down subtracts from the output, so the constant on the end is negative."}]'::jsonb,
 0, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 29, 'Challenge',
 E'A satellite orbits 700 km above the surface of the Earth, whose radius is\n6400 km. It sweeps through a central angle of 0.8 radians.\nHow far does it travel, to the nearest kilometre?',
 '[{"text": "5120 km", "feedback": "That uses the radius of the Earth alone. The satellite is 700 km further out, so its own circle is larger."},
   {"text": "8875 km", "feedback": "That divides by the angle rather than multiplying. a = rθ multiplies."},
   {"text": "560 km", "feedback": "That multiplies only the 700 km of altitude by the angle. The satellite travels on a circle centred at the Earth centre, so the whole distance from there counts."},
   {"text": "5680 km", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-apps-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 30, 'Challenge',
 'Determine the exact value of cot(π/4) divided by [cos(π/3) csc(π/2)].',
 '[{"text": "2", "feedback": "Correct."},
   {"text": "1/2", "feedback": "The expression was turned upside down, dividing the product by the cotangent rather than the other way round."},
   {"text": "1", "feedback": "csc(π/2) is 1, but cos(π/3) is a half, and that half still has to divide into the numerator."},
   {"text": "√2", "feedback": "That reads cos(π/3) as 1/√2, which belongs to π/4. The 60 degree angle has a different cosine in the special triangle."}]'::jsonb,
 0, 'sub-exact-ratios-rad'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): combined ratios, arc length in context, full analysis.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig in Radians', 4, 31, 'Advanced',
 E'An angle measures 2.82 radians.\nWhich quadrant is it in, and what is its degree measure to one decimal place?',
 '[{"text": "Second quadrant, 161.6°", "feedback": "Correct."},
   {"text": "Third quadrant, 161.6°", "feedback": "The degree measure is right, and 161.6 is still short of 180, so the arm has not reached the third quadrant."},
   {"text": "First quadrant, 161.6°", "feedback": "The degree measure is right, but the first quadrant stops at 90 degrees."},
   {"text": "Second quadrant, 0.049°", "feedback": "The quadrant is right. Converting TO degrees multiplies by 180/π, not by π/180."}]'::jsonb,
 0, 'sub-radian-measure'),

(12, 'MHF4U', 'Trig in Radians', 4, 32, 'Advanced',
 E'A wheel of radius 30 cm turns through 5π/6 radians.\nHow far does a point on the rim travel, to one decimal place?',
 '[{"text": "11.5 cm", "feedback": "That divides by the angle rather than multiplying. a = rθ multiplies."},
   {"text": "78.5 cm", "feedback": "Correct."},
   {"text": "25.0 cm", "feedback": "That works out 5π/6 times 30 and then divides by π, dropping it. The π belongs in the answer."},
   {"text": "157.1 cm", "feedback": "That uses the DIAMETER of 60 cm. The arc length formula takes the radius."}]'::jsonb,
 1, 'sub-trig-apps-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 33, 'Advanced',
 'For θ = 5π/3, which pair of exact values is right?',
 '[{"text": "sec θ = 1/2 and cot θ = -1/√3", "feedback": "1/2 is cos(5π/3) itself. Secant is its reciprocal."},
   {"text": "sec θ = 2 and cot θ = -1/√3", "feedback": "Correct."},
   {"text": "sec θ = -2 and cot θ = -1/√3", "feedback": "5π/3 is in the fourth quadrant, where cosine and therefore secant are positive."},
   {"text": "sec θ = 2 and cot θ = -√3", "feedback": "The secant is right. tan(5π/3) is -√3, so its reciprocal is the fraction turned over."}]'::jsonb,
 1, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 34, 'Advanced',
 'Determine the exact value of cos(π/6) csc(π/3) + sin(π/4).',
 '[{"text": "1 + √2", "feedback": "The second term is sin(π/4), and its root belongs underneath, not out front."},
   {"text": "2/√2", "feedback": "The two terms were combined over a single √2 denominator. Only the second term has a root underneath it, so the first cannot be written over that root."},
   {"text": "√2/2", "feedback": "That is the second term on its own. The product in front of it was dropped instead of being evaluated."},
   {"text": "(√2 + 1)/√2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exact-ratios-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 35, 'Advanced',
 'How many vertical asymptotes does y = sec x have between 0 and 2π inclusive?',
 '[{"text": "1", "feedback": "Cosine hits zero twice in a full turn, once on the way down and once on the way back up."},
   {"text": "3", "feedback": "Three would need cosine to cross zero three times in one turn. It crosses at π/2 and 3π/2 only."},
   {"text": "4", "feedback": "Four zeros in a turn belongs to a function of double the frequency. Plain cosine has two."},
   {"text": "2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 36, 'Advanced',
 'How does the graph of y = csc x relate to the graph of y = sin x?',
 '[{"text": "It has an asymptote wherever sine crosses zero, and it touches sine at every peak and trough", "feedback": "Correct."},
   {"text": "It is sine reflected in the x-axis", "feedback": "A reflection would keep the same shape upside down. Cosecant has asymptotes, which sine does not."},
   {"text": "It is sine with half the period", "feedback": "The period is unchanged at 2π. Taking a reciprocal does not speed the pattern up."},
   {"text": "It is sine shifted π/2 to the right", "feedback": "That would give a cosine curve, not a reciprocal. Cosecant is unbounded, and no shift can do that."}]'::jsonb,
 0, 'sub-six-trig-graphs'),

(12, 'MHF4U', 'Trig in Radians', 4, 37, 'Advanced',
 E'For y = cos(x + π/3) + 1, give the maximum, the minimum,\nand the x-value where the first maximum happens.',
 '[{"text": "Maximum 2, minimum 0, first maximum at x = π/3", "feedback": "The turning points are right. The bracket reads x + π/3, and the curve peaks when that bracket is zero, which is at a negative x."},
   {"text": "Maximum 1, minimum -1, first maximum at x = -π/3", "feedback": "The position is right, but the + 1 lifts the whole curve, taking both turning points up with it."},
   {"text": "Maximum 2, minimum 0, first maximum at x = 0", "feedback": "The turning points are right. At x = 0 the bracket is π/3 rather than 0, so the curve is already past its peak."},
   {"text": "Maximum 2, minimum 0, first maximum at x = -π/3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 38, 'Advanced',
 E'A sinusoid has amplitude 5, period π, a phase shift of π/4 right\nand a vertical shift of 1 down. What is its k value?',
 '[{"text": "2", "feedback": "Correct."},
   {"text": "π", "feedback": "π is the period itself. k is 2π divided by the period."},
   {"text": "1/2", "feedback": "The fraction is upside down. A period SHORTER than 2π needs a k above 1."},
   {"text": "1", "feedback": "k = 1 leaves the period at 2π. This curve repeats twice as often as that."}]'::jsonb,
 0, 'sub-trig-transform-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 39, 'Advanced',
 E'A pendulum on a 1.2 m string swings through an angle of π/5 radians.\nHow far does the bob travel, to two decimal places?',
 '[{"text": "3.77 m", "feedback": "That multiplies by π and forgets to divide by 5."},
   {"text": "1.91 m", "feedback": "That divides 1.2 by π/5 rather than multiplying. a = rθ multiplies."},
   {"text": "0.75 m", "feedback": "Correct."},
   {"text": "0.24 m", "feedback": "That works out 1.2 divided by 5 and drops the π."}]'::jsonb,
 2, 'sub-trig-apps-rad'),

(12, 'MHF4U', 'Trig in Radians', 4, 40, 'Advanced',
 'Determine the exact value of sec(5π/4) + cot(2π/3) sin(11π/6).',
 '[{"text": "(1 + 2√6)/(2√3)", "feedback": "sec(5π/4) is negative, because 5π/4 sits in the third quadrant where cosine is below zero."},
   {"text": "(2√6 - 1)/(2√3)", "feedback": "Both signs are flipped. The secant term is negative and the product of the two negative ratios is positive."},
   {"text": "-√2 - 1/(2√3)", "feedback": "The secant term is right. The other two ratios are both negative, so their product comes out positive and is ADDED."},
   {"text": "(1 - 2√6)/(2√3)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exact-ratios-rad');

-- --- questions_mhf4u_u5.sql ---

-- ===========================================================================
-- MHF4U — Unit 5: Trig Identities and Equations — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  Cofunction and transformation identities
--   Lesson 2  Compound angle identities
--   Lesson 3  Double angle identities
--   Lesson 4  Proving trig identities
--   Lesson 5  Solving linear trig equations
--   Lesson 6  Solving double angle trig equations
--   Lesson 7  Solving quadratic trig equations
--
-- The three solving lessons are one subtopic. A student who can solve a
-- linear trig equation and stumbles on a quadratic one has not failed at
-- quadratics — they have failed to notice that a quadratic in sin x still
-- needs every solution of sin x = k found afterwards, and that is the same
-- gap the double-angle case exposes. Splitting them would put three
-- traffic lights on one skill.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- THE MISSING SOLUTION. In this unit the commonest wrong answer is not a
-- wrong number but a short list: a student finds one solution and stops,
-- or finds two where a double angle demands four. Those partial lists are
-- offered as distractors throughout, because the feedback can then say how
-- many solutions the interval should hold and why.
--
-- FIGURES. One question carries one: 31, the ladder against a wall. The
-- angle in that question is measured to the WALL rather than to the ground,
-- which is the whole trap, and no wording makes that as plain as a picture.
-- The drawing is deliberately out of true: measuring it gives a foot
-- distance of about 8 m, whose nearest option is wrong, against an answer
-- of about 3.9 m.
--
-- Nothing else here earns one. Identities are symbolic, and the solving
-- questions would need a CAST diagram, which states which quadrants to use.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file -> figures_mhf4u.sql.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MHF4U' and unit = 'Trig Identities and Equations';

insert into misconception_labels (tag, label) values
  ('sub-cofunction-identities', 'Cofunction and transformation identities'),
  ('sub-compound-angles',       'Compound angle formulas'),
  ('sub-double-angles',         'Double angle formulas'),
  ('sub-proving-identities',    'Proving trig identities'),
  ('sub-solving-trig-eqns',     'Solving trig equations')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. The formulas themselves.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig Identities and Equations', 5, 1, 'Easy',
 'Which expression is equal to cos θ?',
 '[{"text": "sin(π/2 - θ)", "feedback": "Correct."},
   {"text": "cos(π/2 - θ)", "feedback": "The complement is right but the cofunction identity was applied to the wrong ratio. Try θ = 0: cosine gives 1, and this expression gives 0."},
   {"text": "sin(θ - π/2)", "feedback": "The bracket is the wrong way round, and reversing it flips the sign of the whole thing."},
   {"text": "sin(π/2) - sin θ", "feedback": "Sine does not distribute across a subtraction, so the bracket cannot be split into two terms. The whole angle has to go inside one sine."}]'::jsonb,
 0, 'sub-cofunction-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 2, 'Easy',
 'What does sin(-θ) equal?',
 '[{"text": "-sin θ", "feedback": "Correct."},
   {"text": "sin θ", "feedback": "That is how COSINE behaves. Sine is odd, so reversing the angle reverses the output."},
   {"text": "cos θ", "feedback": "Negating an angle does not turn one ratio into another. It reflects the point across the x-axis."},
   {"text": "-cos θ", "feedback": "Negating an angle reflects the point across the x-axis, which changes the sign of the y-coordinate. That is sine, not cosine."}]'::jsonb,
 0, 'sub-cofunction-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 3, 'Easy',
 'What is the compound angle formula for sin(A + B)?',
 '[{"text": "sin A cos B - cos A sin B", "feedback": "That is the formula for sin(A - B). The sign inside matches the sign in the formula for sine."},
   {"text": "cos A cos B - sin A sin B", "feedback": "That is the formula for cos(A + B). The cosine formula keeps the two functions matched; the sine formula mixes them."},
   {"text": "sin A sin B + cos A cos B", "feedback": "That is cos(A - B). Notice both terms here pair like with like, which is the signature of the cosine formula."},
   {"text": "sin A cos B + cos A sin B", "feedback": "Correct."}]'::jsonb,
 3, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 4, 'Easy',
 'What is the compound angle formula for cos(A + B)?',
 '[{"text": "sin A cos B + cos A sin B", "feedback": "That is sin(A + B). The sine formula mixes the two functions; the cosine one pairs like with like."},
   {"text": "cos A + cos B", "feedback": "Cosine does not distribute over a sum. Try A = B = π/3 and the two sides disagree."},
   {"text": "cos A cos B - sin A sin B", "feedback": "Correct."},
   {"text": "cos A cos B + sin A sin B", "feedback": "That is cos(A - B). The cosine formula reverses the sign: a plus inside becomes a minus in the middle."}]'::jsonb,
 2, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 5, 'Easy',
 'What does 2 sin θ cos θ equal?',
 '[{"text": "sin²θ", "feedback": "The two factors are different functions, so their product is not a square."},
   {"text": "sin 2θ", "feedback": "Correct."},
   {"text": "cos 2θ", "feedback": "cos 2θ comes from the DIFFERENCE of the two squares, not from twice their product."},
   {"text": "2 sin θ", "feedback": "The cosine cannot simply be dropped. It is doing real work in the formula."}]'::jsonb,
 1, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 6, 'Easy',
 'What does cos²θ - sin²θ equal?',
 '[{"text": "cos 2θ", "feedback": "Correct."},
   {"text": "sin 2θ", "feedback": "sin 2θ is twice the PRODUCT of the two, not the difference of their squares."},
   {"text": "1", "feedback": "The SUM of the two squares comes to 1. The difference does not."},
   {"text": "cos²2θ", "feedback": "The angle doubles but the square does not survive. The result is a plain cosine of the doubled angle."}]'::jsonb,
 0, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 7, 'Easy',
 'Which of these is the Pythagorean identity?',
 '[{"text": "sin²x - cos²x = 1", "feedback": "The sign is wrong. Try x = 0: that version gives -1."},
   {"text": "tan²x + 1 = sin²x", "feedback": "Dividing the real identity by cos²x gives sec²x on the right, not sin²x."},
   {"text": "sin x + cos x = 1", "feedback": "The squares matter. Try x = π/4 and the left side comes to about 1.41."},
   {"text": "sin²x + cos²x = 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 8, 'Easy',
 'When proving a trig identity, what are you NOT allowed to do?',
 '[{"text": "Rewrite everything in terms of sine and cosine", "feedback": "That is usually the first move, and it is always allowed."},
   {"text": "Work on the two sides separately and meet in the middle", "feedback": "That is allowed too, as long as the two sides are never mixed together."},
   {"text": "Move terms across the equals sign as though it were an equation", "feedback": "Correct."},
   {"text": "Simplify one side on its own", "feedback": "That is exactly the standard method: work down one side until it matches the other."}]'::jsonb,
 2, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 9, 'Easy',
 'Solve sin x = 1/2 for 0 ≤ x ≤ 2π, giving exact values.',
 '[{"text": "x = π/6 and x = 7π/6", "feedback": "7π/6 is in the third quadrant, where sine is negative. The second solution comes from π MINUS the first."},
   {"text": "x = π/3 and x = 2π/3", "feedback": "Those are the angles whose sine is √3/2. The related acute angle for a half is π/6."},
   {"text": "x = π/6 and x = 5π/6", "feedback": "Correct."},
   {"text": "x = π/6 and no other value", "feedback": "The calculator gives one, but sine is positive in TWO quadrants, so a second solution shares the value."}]'::jsonb,
 2, 'sub-solving-trig-eqns'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 10, 'Easy',
 'How many solutions does sin x = 2.5 have?',
 '[{"text": "One", "feedback": "Sine never leaves the interval from -1 to 1, so no angle produces 2.5."},
   {"text": "Two", "feedback": "Two would be right for any value BETWEEN -1 and 1. This one is outside the range entirely."},
   {"text": "Infinitely many", "feedback": "Sine is periodic, so values it does take repeat forever. 2.5 is not one of them."},
   {"text": "None", "feedback": "Correct."}]'::jsonb,
 3, 'sub-solving-trig-eqns'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): applying one formula.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig Identities and Equations', 5, 11, 'Medium',
 E'Given that sin(2π/7) is about 0.7818, evaluate cos(3π/14)\nusing an equivalent trig expression.',
 '[{"text": "About -0.7818", "feedback": "The size is right but the sign is not. 3π/14 is a first-quadrant angle, so its cosine is positive."},
   {"text": "About 0.6235", "feedback": "That is cos(2π/7). The cofunction identity turns the cosine into a SINE of the complementary angle."},
   {"text": "About 0.2182", "feedback": "That is 1 minus the given value. The cofunction identity is not a subtraction of the ratio."},
   {"text": "About 0.7818", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cofunction-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 12, 'Medium',
 E'Given that sin(2π/7) is about 0.7818, evaluate cos(11π/14).',
 '[{"text": "About -0.7818", "feedback": "Correct."},
   {"text": "About 0.7818", "feedback": "11π/14 is more than a quarter turn, so it sits in the second quadrant where cosine is negative."},
   {"text": "About -0.6235", "feedback": "That is -cos(2π/7). The cofunction identity turns the cosine into a sine of the complementary angle."},
   {"text": "About 0.2182", "feedback": "That is 1 minus the given value. The cofunction identity is not a subtraction of the ratio."}]'::jsonb,
 0, 'sub-cofunction-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 13, 'Medium',
 'Find the exact value of sin(π/3)cos(π/6) + cos(π/3)sin(π/6).',
 '[{"text": "1", "feedback": "Correct."},
   {"text": "0", "feedback": "That would be sin of a half turn. The two angles ADD to a quarter turn, not a half."},
   {"text": "√3/2", "feedback": "That is cos(π/3 - π/6), which is what the cosine formula for a difference returns. This expression mixes sine with cosine, so it is not the cosine formula."},
   {"text": "1/2", "feedback": "That is sin(π/3 - π/6). The sign in the middle was read as a minus."}]'::jsonb,
 0, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 14, 'Medium',
 'Find the exact value of cos(π/3)cos(5π/12) - sin(π/3)sin(5π/12).',
 '[{"text": "-1/2", "feedback": "The related acute angle is π/4, not π/3. Adding π/3 and 5π/12 gives 3π/4."},
   {"text": "-√3/2", "feedback": "The related acute angle is π/4, not π/6. Adding π/3 and 5π/12 gives 3π/4."},
   {"text": "-√2/2", "feedback": "Correct."},
   {"text": "√2/2", "feedback": "The two angles add to 3π/4, which lands in the second quadrant where cosine is negative."}]'::jsonb,
 2, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 15, 'Medium',
 'Express 2 sin(π/12)cos(π/12) as a single trig ratio and evaluate it exactly.',
 '[{"text": "sin(π/24), which is about 0.13", "feedback": "The double angle formula doubles the angle rather than halving it."},
   {"text": "sin(π/6), which is 1/2", "feedback": "Correct."},
   {"text": "sin(π/6), which is √3/2", "feedback": "The ratio is right but the value is not. √3/2 is sin(π/3), not sin(π/6)."},
   {"text": "cos(π/6), which is √3/2", "feedback": "Twice the product of sine and cosine gives a SINE of the doubled angle."}]'::jsonb,
 1, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 16, 'Medium',
 'Express cos²(π/12) - sin²(π/12) as a single trig ratio and evaluate it exactly.',
 '[{"text": "cos(π/6), which is √3/2", "feedback": "Correct."},
   {"text": "cos(π/6), which is 1/2", "feedback": "The ratio is right but the value is not. 1/2 is cos(π/3), not cos(π/6)."},
   {"text": "sin(π/6), which is 1/2", "feedback": "The difference of the two squares gives a COSINE of the doubled angle."},
   {"text": "1, because the two squares always add to 1", "feedback": "They add to 1. Here they are being subtracted, which is a different identity altogether."}]'::jsonb,
 0, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 17, 'Medium',
 'Simplify sin²x (1 + cot²x).',
 '[{"text": "cos²x", "feedback": "That would follow from cos²x times csc²x times sin²x. The bracket here is 1 + cot²x, which is csc²x on its own."},
   {"text": "1", "feedback": "Correct."},
   {"text": "sin²x", "feedback": "The bracket does not simplify to 1. It becomes csc²x, which is one over sin²x."},
   {"text": "cot²x", "feedback": "The 1 inside the bracket cannot be dropped. Together with cot²x it forms a Pythagorean identity."}]'::jsonb,
 1, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 18, 'Medium',
 'What does 1 - cos²x equal?',
 '[{"text": "-sin²x", "feedback": "The sign is wrong. Moving the cosine term across the Pythagorean identity leaves a positive square, not a negative one."},
   {"text": "tan²x", "feedback": "tan²x is what is left when 1 is taken from sec²x, which is a different rearrangement."},
   {"text": "1", "feedback": "cos²x is not zero for most angles, so it does not simply disappear."},
   {"text": "sin²x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 19, 'Medium',
 'Solve tan x + 1 = 0 for 0 ≤ x ≤ 2π, giving exact values.',
 '[{"text": "x = 3π/4 and x = 7π/4", "feedback": "Correct."},
   {"text": "x = π/4 and x = 5π/4", "feedback": "Those are the angles where the tangent is POSITIVE 1. A negative tangent moves both solutions a quadrant along."},
   {"text": "x = 3π/4 and no other value", "feedback": "Tangent is negative in TWO quadrants, the second and the fourth, so a second solution exists."},
   {"text": "x = π/4 and x = 3π/4", "feedback": "At π/4 the tangent is positive. Only one of these two satisfies the equation."}]'::jsonb,
 0, 'sub-solving-trig-eqns'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 20, 'Medium',
 'Solve cos x + 0.6 = 0 for 0 ≤ x ≤ 2π, to two decimal places.',
 '[{"text": "x = 2.21 and x = 4.07", "feedback": "Correct."},
   {"text": "x = 0.93 and x = 5.36", "feedback": "0.93 is the RELATED ACUTE angle, where the cosine is positive 0.6. A negative cosine lives in the second and third quadrants."},
   {"text": "x = 2.21 and no other value", "feedback": "Cosine is negative in two quadrants, so a second solution sits below the axis at the same related acute angle."},
   {"text": "x = 0.93 and x = 2.21", "feedback": "0.93 is the related acute angle used to build the solutions, not a solution itself. Put it back into the equation and the cosine comes out positive."}]'::jsonb,
 0, 'sub-solving-trig-eqns'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): exact values that need a formula, and real proofs.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig Identities and Equations', 5, 21, 'Challenge',
 'Simplify sin(2π - x).',
 '[{"text": "cos x", "feedback": "Turning by a whole or half turn keeps a ratio as itself or its negative. Only quarter turns swap sine for cosine."},
   {"text": "-cos x", "feedback": "Turning by a full turn keeps sine as sine. Only quarter turns swap the two functions."},
   {"text": "-sin x", "feedback": "Correct."},
   {"text": "sin x", "feedback": "Subtracting from a full turn reflects the angle across the x-axis, which flips the sign of the sine."}]'::jsonb,
 2, 'sub-cofunction-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 22, 'Challenge',
 'Which expression equals cos(x - π/2)?',
 '[{"text": "-sin x", "feedback": "Expanding with the cosine formula kills the first product, because cos(π/2) is zero, and what survives has both factors positive."},
   {"text": "cos x", "feedback": "A quarter turn genuinely swaps the two functions. It cannot leave cosine as cosine."},
   {"text": "-cos x", "feedback": "A quarter turn swaps the functions rather than negating one. A half turn is what negates."},
   {"text": "sin x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cofunction-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 23, 'Challenge',
 'Find the exact value of cos(3π/4 - π/6).',
 '[{"text": "(√6 + √2)/4", "feedback": "The cosine formula for a DIFFERENCE has a plus in the middle, but cos(3π/4) is itself negative, so the first term is below zero."},
   {"text": "-(√6 + √2)/4", "feedback": "The first term is negative but the second is positive, so they partly cancel rather than piling up."},
   {"text": "(√2 - √6)/4", "feedback": "Correct."},
   {"text": "(√6 - √2)/4", "feedback": "The signs are swapped. cos(3π/4) is negative, so the term it appears in comes out negative."}]'::jsonb,
 2, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 24, 'Challenge',
 'Find the exact value of sin(11π/12).',
 '[{"text": "-(√6 - √2)/4", "feedback": "11π/12 is in the second quadrant, where sine is positive."},
   {"text": "(√6 - √2)/4", "feedback": "Correct."},
   {"text": "(√6 + √2)/4", "feedback": "Splitting 11π/12 as 2π/3 plus π/4 gives a cos(2π/3) of -1/2, so one of the two terms comes out negative."},
   {"text": "-(√6 + √2)/4", "feedback": "That is cos(11π/12). Splitting the angle was fine, but the two products were combined with the cosine formula instead of the sine one."}]'::jsonb,
 1, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 25, 'Challenge',
 'Angle x is in the third quadrant and tan x = 7/24. Find the exact value of cos 2x.',
 '[{"text": "527/625", "feedback": "Correct."},
   {"text": "-527/625", "feedback": "cos 2x is cos²x minus sin²x, and the cosine term is the larger of the two here, so the result is positive."},
   {"text": "336/625", "feedback": "That is sin 2x, which is twice the product rather than the difference of the squares."},
   {"text": "49/625", "feedback": "That is sin²x on its own. The cos²x term has to be subtracted from, not dropped."}]'::jsonb,
 0, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 26, 'Challenge',
 'Given sin x = 5/13 and 0 ≤ x ≤ π/2, find the exact value of sin 2x.',
 '[{"text": "10/13", "feedback": "That doubles the sine. Doubling an angle is not the same as doubling its sine."},
   {"text": "119/169", "feedback": "That is cos 2x, which comes from the difference of the two squares."},
   {"text": "120/169", "feedback": "Correct."},
   {"text": "60/169", "feedback": "The 2 in front of the formula was left out. sin 2x is TWICE the product."}]'::jsonb,
 2, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 27, 'Challenge',
 'Simplify (cos x - sin x)².',
 '[{"text": "1 + sin 2x", "feedback": "Expanding gives a middle term of MINUS 2 sin x cos x, so the double angle is subtracted."},
   {"text": "cos 2x", "feedback": "cos 2x is the difference of the SQUARES. Here the bracket is squared, which produces a cross term as well."},
   {"text": "1", "feedback": "The two squares do add to 1, but the cross term -2 sin x cos x survives and does not vanish."},
   {"text": "1 - sin 2x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 28, 'Challenge',
 'Simplify 1/(1 + cos x) + 1/(1 - cos x).',
 '[{"text": "2", "feedback": "The denominator does not cancel away. It becomes 1 - cos²x, which is sin²x rather than 1."},
   {"text": "2csc²x", "feedback": "Correct."},
   {"text": "2sec²x", "feedback": "The common denominator comes to 1 - cos²x, which is sin²x. One over sin²x is cosecant squared."},
   {"text": "csc²x", "feedback": "The numerators add to 2, not 1. Both fractions contribute a 1 on top."}]'::jsonb,
 1, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 29, 'Challenge',
 'Solve csc x + 3 = 0 for 0 ≤ x ≤ 2π, to two decimal places.',
 '[{"text": "x = 2.80 and x = 5.94", "feedback": "5.94 is right, but 2.80 is in the second quadrant, where sine is positive."},
   {"text": "x = 3.48 and x = 5.94", "feedback": "Correct."},
   {"text": "x = 0.34 and x = 2.80", "feedback": "Those are the angles whose sine is POSITIVE one third. A negative cosecant means a negative sine."},
   {"text": "x = 3.48 and no other value", "feedback": "Sine is negative in two quadrants, the third and the fourth, so a second solution exists."}]'::jsonb,
 1, 'sub-solving-trig-eqns'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 30, 'Challenge',
 'Solve sec x - √2 = 0 for 0 ≤ x ≤ 2π, giving exact values.',
 '[{"text": "x = π/4 and no other value", "feedback": "Cosine is positive in two quadrants, so a second solution sits below the axis at the same related acute angle."},
   {"text": "x = π/4 and x = 7π/4", "feedback": "Correct."},
   {"text": "x = π/4 and x = 3π/4", "feedback": "At 3π/4 the cosine is negative, so its secant is negative too. Cosine is positive in the first and FOURTH quadrants."},
   {"text": "x = 3π/4 and x = 5π/4", "feedback": "Both of those have a negative cosine, and the equation needs a positive one."}]'::jsonb,
 1, 'sub-solving-trig-eqns'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): compound and double angles from given ratios.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Trig Identities and Equations', 5, 31, 'Advanced',
 E'A 15 m ladder leaning against a wall is unsafe if it makes an angle of\nless than π/12 with the WALL, as shown. Using a compound angle formula,\nfind the exact minimum distance from the foot of the ladder to the wall.',
 '[{"text": "15√6/4 m", "feedback": "Only the first term of the expansion was kept. The second product still has to be subtracted."},
   {"text": "15(√6 - √2)/4 m", "feedback": "Correct."},
   {"text": "15(√6 + √2)/4 m", "feedback": "Splitting π/12 as π/3 minus π/4 gives a sine formula with a MINUS in the middle, so the two terms partly cancel."},
   {"text": "15(√2 - √6)/4 m", "feedback": "The signs are swapped, which makes the distance negative. A length cannot be below zero."}]'::jsonb,
 1, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 32, 'Advanced',
 'Simplify cos(π - x).',
 '[{"text": "-cos x", "feedback": "Correct."},
   {"text": "cos x", "feedback": "A half turn puts the angle in the mirror quadrant across the y-axis, which flips the sign of the cosine."},
   {"text": "sin x", "feedback": "Only quarter turns swap sine for cosine. A half turn keeps the function and changes the sign."},
   {"text": "-sin x", "feedback": "A half turn keeps cosine as cosine. It is a quarter turn that swaps the two functions."}]'::jsonb,
 0, 'sub-cofunction-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 33, 'Advanced',
 E'Angle x is in the first quadrant with cos x = 12/13, and angle y is in the\nsecond quadrant with sin y = 7/25. Find the exact value of sin(x + y).',
 '[{"text": "-323/325", "feedback": "That is cos(x + y). The sine formula mixes the two functions; the cosine formula pairs like with like."},
   {"text": "-36/325", "feedback": "Correct."},
   {"text": "36/325", "feedback": "cos y is negative in the second quadrant, and that term is the larger of the two, so the total comes out below zero."},
   {"text": "-204/325", "feedback": "That is sin(x - y). The formula for a sum has a PLUS between the two products."}]'::jsonb,
 1, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 34, 'Advanced',
 E'With the same angles — x in the first quadrant with cos x = 12/13, and y in\nthe second with sin y = 7/25 — find the exact value of cos(x - y).',
 '[{"text": "-204/325", "feedback": "That is sin(x - y). The cosine formula pairs cosine with cosine; the sine formula mixes them."},
   {"text": "-253/325", "feedback": "Correct."},
   {"text": "-323/325", "feedback": "That is cos(x + y). The formula for a difference has a PLUS between the two products."},
   {"text": "253/325", "feedback": "cos y is negative in the second quadrant, and that first product outweighs the second, so the total is below zero."}]'::jsonb,
 1, 'sub-compound-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 35, 'Advanced',
 'Given cos x = -4/5 and π ≤ x ≤ 3π/2, find the exact value of tan 2x.',
 '[{"text": "7/24", "feedback": "The fraction is upside down. The denominator of the formula is 1 - tan²x, which comes to 7/16, and dividing by it flips it up."},
   {"text": "3/2", "feedback": "That is the numerator, 2 tan x, on its own. It still has to be divided by 1 - tan²x."},
   {"text": "24/7", "feedback": "Correct."},
   {"text": "-24/7", "feedback": "In the third quadrant both sine and cosine are negative, so tan x is POSITIVE, and the double angle formula keeps it positive here."}]'::jsonb,
 2, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 36, 'Advanced',
 E'Express [2 tan(π/6)]/[1 - tan²(π/6)] as a single trig ratio\nand evaluate it exactly.',
 '[{"text": "tan(π/12), which is 2 - √3", "feedback": "The double angle formula DOUBLES the angle rather than halving it."},
   {"text": "tan(π/3), which is 1/√3", "feedback": "The ratio is right but the value is not. 1/√3 is tan(π/6), the angle we started from."},
   {"text": "2 tan(π/6), which is 2/√3", "feedback": "The denominator 1 - tan²(π/6) is not 1, so it cannot simply be dropped."},
   {"text": "tan(π/3), which is √3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-double-angles'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 37, 'Advanced',
 'Simplify [sin 2x](tan x + cot x).',
 '[{"text": "1", "feedback": "The bracket comes to 1 over (sin x cos x), but sin 2x is not that same product, so the cancellation does not clear everything away."},
   {"text": "sin 2x", "feedback": "The bracket does not simplify to 1. Written over a common denominator it becomes 1 over sin x cos x."},
   {"text": "2 sin 2x", "feedback": "The bracket cancels the sine and cosine in sin 2x completely, leaving only the numerical factor."},
   {"text": "2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 38, 'Advanced',
 'Simplify (csc x - cot x)².',
 '[{"text": "1", "feedback": "csc²x minus cot²x comes to 1, but this is the SQUARE of their difference, which is not the same thing."},
   {"text": "sin²x", "feedback": "The denominator does become sin²x on the way, but the numerator is (1 - cos x)², so the two do not cancel to leave sin²x."},
   {"text": "(1 - cos x)/(1 + cos x)", "feedback": "Correct."},
   {"text": "(1 + cos x)/(1 - cos x)", "feedback": "The fraction is upside down. The squared numerator is (1 - cos x)², and it is the (1 - cos x) that survives on top."}]'::jsonb,
 2, 'sub-proving-identities'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 39, 'Advanced',
 'Solve 2sin²x - sin x - 1 = 0 for 0 ≤ x ≤ 2π, giving exact values.',
 '[{"text": "x = π/2 and no other value", "feedback": "That comes from sin x = 1. The other factor gives sin x = -1/2, which supplies two more solutions."},
   {"text": "x = π/6, 5π/6 and 3π/2", "feedback": "The signs are swapped. Factoring gives sin x = -1/2 and sin x = 1, not the other way round."},
   {"text": "x = π/2, 7π/6 and 11π/6", "feedback": "Correct."},
   {"text": "x = 7π/6 and 11π/6", "feedback": "Those come from sin x = -1/2. The other factor gives sin x = 1, which supplies a third solution."}]'::jsonb,
 2, 'sub-solving-trig-eqns'),

(12, 'MHF4U', 'Trig Identities and Equations', 5, 40, 'Advanced',
 'Solve sin 2x = 1/2 for 0 ≤ x ≤ 2π, giving exact values.',
 '[{"text": "x = π/12 and 5π/12", "feedback": "As x runs over one turn, 2x runs over TWO, so the pattern repeats and there are four solutions rather than two."},
   {"text": "x = π/6 and 5π/6", "feedback": "Those solve sin x = 1/2. The angle inside is 2x, so each of those still has to be halved, and two more come from the second turn."},
   {"text": "x = π/12, 5π/12 and 13π/12", "feedback": "One is missing. The second turn of 2x contributes a pair, not a single value."},
   {"text": "x = π/12, 5π/12, 13π/12 and 17π/12", "feedback": "Correct."}]'::jsonb,
 3, 'sub-solving-trig-eqns');

-- --- questions_mhf4u_u6.sql ---

-- ===========================================================================
-- MHF4U — Unit 6: Rates of Change — 40 questions
-- ===========================================================================
-- Grade 12 Advanced Functions, authored from the Jensen MHF4U lesson
-- material for this unit:
--
--   Lesson 1  Average rates of change
--   Lesson 2  Instantaneous rates of change
--   Lesson 3  Newton quotient
--   Lesson 4  Limits
--
-- Four lessons, five subtopics. The extra one is INTERPRETATION — units,
-- sign, and what a rate actually means in the context it came from. Jensen
-- asks for it constantly ("explain the meaning of this rate using proper
-- units") and it is where a student who can do all the arithmetic still
-- loses marks. Giving it its own traffic light means the dashboard can say
-- "the calculation is fine, the reading of it is not".
--
-- Note on scope: the Jensen review package for this unit also carries a
-- long section on rational equations and inequalities. Those belong to
-- Unit 7 in the lesson folders, and they are authored there rather than
-- here, so the two units do not overlap and no question is asked twice.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value and every limit in this file was recomputed independently
-- with sympy before delivery; nothing was copied from the source PDFs.
--
-- FIGURES: none. Half the Jensen questions here hand a student a
-- distance-time graph and ask for the slope of a secant or the shape of the
-- motion. A graph on a grid states both: you count the squares. Every one
-- of those is asked here from the coordinates or the table instead, which is
-- what a student has to be able to do anyway once the picture is taken away.
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

delete from questions where course_code = 'MHF4U' and unit = 'Rates of Change';

insert into misconception_labels (tag, label) values
  ('sub-average-roc',       'Average rate of change'),
  ('sub-instantaneous-roc', 'Instantaneous rate of change'),
  ('sub-newtons-quotient',  'The Newton quotient'),
  ('sub-limits',            'Limits'),
  ('sub-roc-interpretation','Interpreting a rate of change')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 1, 'Easy',
 'The average rate of change between two points on a curve is the slope of what?',
 '[{"text": "The curve at its steepest point", "feedback": "The average takes no notice of what happens in between. It depends only on the two endpoints."},
   {"text": "The secant line joining them", "feedback": "Correct."},
   {"text": "The tangent line at one of them", "feedback": "A tangent touches at a single point and gives the INSTANTANEOUS rate. An average needs two points."},
   {"text": "The horizontal x-axis of the graph", "feedback": "The axis has a slope of zero, which would make every average rate of change zero."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 2, 'Easy',
 E'A tire loses pressure from 400 kPa to 170 kPa over 30 minutes.\nWhat is the average rate of change?',
 '[{"text": "-0.13 kPa per minute", "feedback": "The fraction is upside down. The change in pressure goes on top and the change in time underneath."},
   {"text": "-7.67 kPa per minute", "feedback": "Correct."},
   {"text": "7.67 kPa per minute", "feedback": "The pressure is falling, so the rate has to be negative. The change in y is 170 take away 400."},
   {"text": "-230 kPa per minute", "feedback": "That is the total CHANGE in pressure. A rate divides it by the time it took."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 3, 'Easy',
 'The instantaneous rate of change at a point is the slope of what?',
 '[{"text": "The chord joining the endpoints of the graph", "feedback": "That is the average rate over the whole domain, which says nothing about one particular moment."},
   {"text": "The horizontal x-axis at that point", "feedback": "The axis is a fixed horizontal line and has nothing to do with the curve."},
   {"text": "The tangent line at that point", "feedback": "Correct."},
   {"text": "The secant line through two points", "feedback": "A secant gives the AVERAGE rate over an interval. Shrinking that interval to nothing is what produces the tangent."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 4, 'Easy',
 'How do you ESTIMATE an instantaneous rate of change from a table of values?',
 '[{"text": "Use the first two values in the table", "feedback": "Those give a rate near the START, which is only useful if the point of interest happens to be there."},
   {"text": "Average every value in the table", "feedback": "Averaging the VALUES gives a typical height, not a rate. A rate needs a change divided by a change."},
   {"text": "Use a small interval surrounding the point", "feedback": "Correct."},
   {"text": "Use the whole interval the table covers", "feedback": "That gives the average over everything, which can be nowhere near the rate at one particular moment."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 5, 'Easy',
 'What is the Newton quotient for a function f at a point a?',
 '[{"text": "f(a + h)/h", "feedback": "The starting value f(a) has to be subtracted. Without it this is not a change at all."},
   {"text": "[f(a + h) + f(a)]/h", "feedback": "A rate of change needs a DIFFERENCE on top, not a sum."},
   {"text": "[f(a + h) - f(a)]/h", "feedback": "Correct."},
   {"text": "[f(a) - f(a + h)]/h", "feedback": "The two terms are the wrong way round, which flips the sign of every rate it produces."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 6, 'Easy',
 'In the Newton quotient, what happens to h?',
 '[{"text": "It stays fixed", "feedback": "Leaving h fixed gives an average rate. The instantaneous rate is what appears as the interval closes up."},
   {"text": "It approaches infinity", "feedback": "A growing h widens the interval, which takes the estimate further from the point rather than closer."},
   {"text": "It approaches 0", "feedback": "Correct."},
   {"text": "It approaches 1", "feedback": "h is the width of the interval, and shrinking it to 1 still leaves a whole unit of averaging in the answer."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 7, 'Easy',
 'What is the limit of (x + 3) as x approaches 2?',
 '[{"text": "2", "feedback": "2 is the value x is heading toward. The limit is what the EXPRESSION heads toward."},
   {"text": "3", "feedback": "3 is the constant in the expression, not the value the whole thing approaches."},
   {"text": "Undefined", "feedback": "This expression is perfectly well behaved at x = 2, so the limit is simply its value there."},
   {"text": "5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 8, 'Easy',
 'A limit exists at x = a only when which of these is true?',
 '[{"text": "The left and right limits agree", "feedback": "Correct."},
   {"text": "The value of f(a) is defined there", "feedback": "A limit can exist at a point where the function has a hole. What matters is where the values are heading, not whether they arrive."},
   {"text": "The function is a polynomial there", "feedback": "Polynomials always have limits, but plenty of other functions do too."},
   {"text": "The graph is a straight line there", "feedback": "Any continuous curve has limits. Straightness is not required."}]'::jsonb,
 0, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 9, 'Easy',
 E'A tire pressure in kilopascals is measured against time in minutes.\nWhat units does its rate of change carry?',
 '[{"text": "Kilopascals on their own", "feedback": "Those are the units of the pressure itself. A rate carries the units of both quantities."},
   {"text": "Minutes of elapsed time", "feedback": "Those are the units of the time. A rate divides one quantity by the other, so both appear."},
   {"text": "Kilopascals times minutes", "feedback": "A rate DIVIDES, so the time unit ends up underneath rather than multiplied in."},
   {"text": "Kilopascals per minute", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 10, 'Easy',
 'What does a negative rate of change tell you about a quantity?',
 '[{"text": "It is undefined", "feedback": "A negative number is a perfectly ordinary answer. It only means the quantity is heading downward."},
   {"text": "It is decreasing", "feedback": "Correct."},
   {"text": "It is increasing", "feedback": "A rising quantity has a positive change on top of the fraction, so its rate is positive."},
   {"text": "It is constant", "feedback": "A constant quantity has a change of zero, so its rate is zero rather than negative."}]'::jsonb,
 1, 'sub-roc-interpretation'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 11, 'Medium',
 'For f(x) = x² - 3x + 2, find the average rate of change on -1 ≤ x ≤ 2.',
 '[{"text": "2", "feedback": "f(2) is 0 and f(-1) is 6, so the change on top is negative."},
   {"text": "-6", "feedback": "That is the total change in f. A rate divides it by the width of the interval, which is 3."},
   {"text": "6", "feedback": "That is the size of the change with the wrong sign, and it has not been divided by the interval width."},
   {"text": "-2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 12, 'Medium',
 'For f(x) = x² - 3x + 2, find the average rate of change on 4 ≤ x ≤ 8.',
 '[{"text": "4", "feedback": "4 is the width of the interval, which belongs underneath the fraction rather than being the answer."},
   {"text": "9", "feedback": "Correct."},
   {"text": "12", "feedback": "That ADDS the two function values instead of subtracting them. The top of the fraction has to be a difference."},
   {"text": "36", "feedback": "That is the total change in f. It still has to be divided by the width of the interval."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 13, 'Medium',
 E'A tire reads 400 kPa at 0 min, 335 kPa at 5 min and 295 kPa at 10 min.\nEstimate the instantaneous rate at 5 minutes using the surrounding interval.',
 '[{"text": "-13 kPa per minute", "feedback": "That uses only the interval from 0 to 5. A surrounding interval takes one reading on each side of the point."},
   {"text": "-8 kPa per minute", "feedback": "That uses only the interval from 5 to 10. A surrounding interval straddles the point."},
   {"text": "-105 kPa per minute", "feedback": "That is the total change in pressure across the interval. It still has to be divided by the 10 minutes it took."},
   {"text": "-10.5 kPa per minute", "feedback": "Correct."}]'::jsonb,
 3, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 14, 'Medium',
 E'A vole is at 0 m at 0 s, 2 m at 2 s and 8 m at 4 s. Estimate its speed at\n2 seconds by averaging the two surrounding secant slopes.',
 '[{"text": "4 m/s", "feedback": "That ADDS the two secant slopes. Averaging them means halving the total."},
   {"text": "2 m/s", "feedback": "Correct."},
   {"text": "1 m/s", "feedback": "That is the secant over the first interval alone. The second interval has to be averaged in with it."},
   {"text": "3 m/s", "feedback": "That is the secant over the second interval alone. The first interval has to be averaged in with it."}]'::jsonb,
 1, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 15, 'Medium',
 'For f(x) = x², simplify the Newton quotient [f(a + h) - f(a)]/h.',
 '[{"text": "2a + h", "feedback": "Correct."},
   {"text": "2a", "feedback": "That is the value the quotient approaches as h shrinks. Before the limit is taken, an h survives."},
   {"text": "2ah + h²", "feedback": "That is the numerator after expanding. Every term still has to be divided by h."},
   {"text": "a² + h", "feedback": "Expanding (a + h)² gives a² + 2ah + h², and the a² cancels against the one being subtracted."}]'::jsonb,
 0, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 16, 'Medium',
 'For f(x) = 3x + 1, what does the Newton quotient simplify to?',
 '[{"text": "3h", "feedback": "The numerator is 3h, and it still has to be divided by the h underneath."},
   {"text": "1", "feedback": "1 is the constant term of f, read straight off the rule. The two constants cancel in the numerator, so neither of them survives into the quotient."},
   {"text": "3", "feedback": "Correct."},
   {"text": "3 + h", "feedback": "The h terms cancel completely for a linear function. Expanding 3(a + h) + 1 leaves only 3h on top."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 17, 'Medium',
 'Find the limit of (x² - 9)/(x - 3) as x approaches 3.',
 '[{"text": "3", "feedback": "3 is the value x approaches. Factoring the top gives x + 3, and that is what has to be evaluated."},
   {"text": "6", "feedback": "Correct."},
   {"text": "0", "feedback": "Substituting 3 gives 0 over 0, which is not a value but a signal to factor first."},
   {"text": "Undefined", "feedback": "The function is undefined AT 3, but the limit asks where the values head as x gets close, and they head somewhere perfectly definite."}]'::jsonb,
 1, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 18, 'Medium',
 'Find the limit of 2x/x as x approaches 0.',
 '[{"text": "2", "feedback": "Correct."},
   {"text": "0", "feedback": "Substituting gives 0 over 0. Cancelling the x first leaves a constant."},
   {"text": "Undefined", "feedback": "The expression is undefined AT 0, but the limit asks where the values head as x gets close, and they head somewhere perfectly definite."},
   {"text": "1", "feedback": "That cancels the x on top against the x underneath and throws away the coefficient standing in front of it."}]'::jsonb,
 0, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 19, 'Medium',
 E'A vole is 8 m from its burrow at 4 s and 10 m at 12 s.\nWhat is its average speed over that interval?',
 '[{"text": "4 m/s", "feedback": "That divides the time by the distance, which turns the units upside down."},
   {"text": "0.25 m/s", "feedback": "Correct."},
   {"text": "0.125 m/s", "feedback": "That divides by 16 rather than by 8. The interval runs from 4 to 12, which is 8 seconds."},
   {"text": "2 m/s", "feedback": "2 m is the total DISTANCE covered. A speed divides it by the time it took."}]'::jsonb,
 1, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 20, 'Medium',
 E'A wood-fired oven is at 25 °C at 0 minutes and 285 °C at 25 minutes.\nWhat is the average rate of change of temperature?',
 '[{"text": "10.4 °C per minute", "feedback": "Correct."},
   {"text": "11.4 °C per minute", "feedback": "That divides 285 by 25 and forgets to subtract the starting temperature."},
   {"text": "260 °C per minute", "feedback": "That is the total change in temperature. A rate divides it by the time it took."},
   {"text": "0.096 °C per minute", "feedback": "The fraction is upside down. The change in temperature goes on top."}]'::jsonb,
 0, 'sub-roc-interpretation'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): choosing the interval, and limits that need work.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 21, 'Challenge',
 'For f(x) = x² - 3x + 2, on which interval is the average rate of change ZERO?',
 '[{"text": "2 ≤ x ≤ 4", "feedback": "f(2) is 0 and f(4) is 6, so the average rate is +3."},
   {"text": "0 ≤ x ≤ 3", "feedback": "Correct."},
   {"text": "0 ≤ x ≤ 2", "feedback": "f(0) is 2 and f(2) is 0, so the average rate is -1."},
   {"text": "1 ≤ x ≤ 3", "feedback": "f(1) is 0 and f(3) is 2, so the average rate is +1."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 22, 'Challenge',
 E'An oven reads 290 °C at 13 minutes and 280 °C at 15 minutes.\nWhat is the average rate of change over that interval?',
 '[{"text": "-0.2 °C per minute", "feedback": "The fraction is upside down. The change in temperature goes on top and the change in time underneath."},
   {"text": "-5 °C per minute", "feedback": "Correct."},
   {"text": "5 °C per minute", "feedback": "The temperature fell over this interval, so the rate is negative."},
   {"text": "-10 °C per minute", "feedback": "That is the total change. It still has to be divided by the 2 minutes it took."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 23, 'Challenge',
 E'An oven reads 205 °C at 8 minutes, 250 °C at 10 minutes and 290 °C at\n13 minutes. Estimate the instantaneous rate at 10 minutes using the\nsurrounding interval.',
 '[{"text": "13.3 °C per minute", "feedback": "That uses only the interval from 10 to 13. A surrounding interval straddles the point."},
   {"text": "45 °C per minute", "feedback": "45 is a change in temperature, not a rate. It still has to be divided by the time it took."},
   {"text": "17 °C per minute", "feedback": "Correct."},
   {"text": "22.5 °C per minute", "feedback": "That uses only the interval from 8 to 10. A surrounding interval takes one reading on each side."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 24, 'Challenge',
 E'An oven reads 205 °C at 8 minutes, 250 °C at 10 minutes and 290 °C at\n13 minutes. Estimate the rate at 10 minutes by averaging the preceding\ninterval [8, 10] and the following interval [10, 13].',
 '[{"text": "17.0 °C per minute", "feedback": "That is the surrounding-interval estimate, which uses 8 and 13 directly. Averaging the two separate secants gives a slightly different number."},
   {"text": "35.8 °C per minute", "feedback": "That ADDS the two secant slopes. Averaging them means halving the total."},
   {"text": "9.0 °C per minute", "feedback": "That halves the answer a second time. The two slopes are added once and halved once."},
   {"text": "17.9 °C per minute", "feedback": "Correct."}]'::jsonb,
 3, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 25, 'Challenge',
 'For f(x) = x² - 3x + 2, simplify the Newton quotient at a general point a.',
 '[{"text": "2a + h", "feedback": "The -3x term contributes a -3h to the numerator, which leaves a -3 behind after dividing."},
   {"text": "a + h - 3", "feedback": "Expanding (a + h)² gives 2ah in the cross term, so dividing by h leaves 2a rather than a."},
   {"text": "2a + h - 3", "feedback": "Correct."},
   {"text": "2a - 3", "feedback": "That is the value the quotient approaches as h shrinks. Before the limit is taken, an h survives."}]'::jsonb,
 2, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 26, 'Challenge',
 E'Using the Newton quotient, find the instantaneous rate of change\nof f(x) = x² - 3x + 2 at x = 2.',
 '[{"text": "0", "feedback": "0 is the VALUE of the function at x = 2, not its rate of change there."},
   {"text": "4", "feedback": "That evaluates only the 2a part and forgets the -3."},
   {"text": "-3", "feedback": "That evaluates only the -3 and forgets the 2a."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 27, 'Challenge',
 'Find the limit of (x² - 3x + 2)/(x - 2) as x approaches 2.',
 '[{"text": "0", "feedback": "Substituting gives 0 over 0, which is a signal to factor rather than an answer."},
   {"text": "2", "feedback": "2 is the value x approaches. Factoring the top and cancelling leaves x - 1, and that has to be evaluated."},
   {"text": "Undefined", "feedback": "The function is undefined at 2, but the limit asks where the values head as x gets close, and they head somewhere definite."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 28, 'Challenge',
 'Find the limit of (x³ - 1)/(x - 1) as x approaches 1.',
 '[{"text": "0", "feedback": "Substituting gives 0 over 0, which is a signal to factor as a difference of cubes."},
   {"text": "Undefined", "feedback": "The function has a hole at 1, but the values on either side head toward a perfectly definite number."},
   {"text": "3", "feedback": "Correct."},
   {"text": "1", "feedback": "Factoring gives x² + x + 1 after the cancellation, and substituting 1 into that adds three terms together."}]'::jsonb,
 2, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 29, 'Challenge',
 E'The secant slopes over the intervals [2, 2.5], [2, 2.1], [2, 2.01] and\n[2, 2.001] come to 1.5, 1.1, 1.01 and 1.001. What is the instantaneous\nrate at x = 2?',
 '[{"text": "1", "feedback": "Correct."},
   {"text": "1.001", "feedback": "That is the last estimate in the list, not the value they are heading toward. The pattern is still closing in."},
   {"text": "1.5", "feedback": "That is the first and crudest estimate, taken over the widest interval."},
   {"text": "0", "feedback": "The slopes are settling on a clear positive value, and none of them is anywhere near zero."}]'::jsonb,
 0, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 30, 'Challenge',
 E'A vole bolts from a hawk, running hard at first and gradually slowing to\na stop. What does its distance-time graph look like?',
 '[{"text": "Steep at first, then flattening out", "feedback": "Correct."},
   {"text": "Straight, with a constant slope", "feedback": "A constant slope means a constant speed. This vole slows down, so the slope has to change."},
   {"text": "Flat at first, then getting steeper", "feedback": "That describes something SPEEDING UP. The steep part comes first when the fastest running does."},
   {"text": "Falling as time goes on", "feedback": "A falling distance graph means moving back toward the burrow. The vole keeps going, just more slowly."}]'::jsonb,
 0, 'sub-roc-interpretation'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): working backwards, harder limits, reading a rate.
-- ---------------------------------------------------------------------------

(12, 'MHF4U', 'Rates of Change', 6, 31, 'Advanced',
 E'For f(x) = x² - 3x + 2, find the value of b for which the average rate of\nchange on 1 ≤ x ≤ b is exactly 4.',
 '[{"text": "b = 4", "feedback": "4 is the target rate copied straight into the answer. It is the value the average rate has to reach, not the endpoint that makes it happen."},
   {"text": "b = 5", "feedback": "At b = 5 the average rate is 3. One more unit is needed."},
   {"text": "b = 3", "feedback": "At b = 3 the average rate is 1, which is well short."},
   {"text": "b = 6", "feedback": "Correct."}]'::jsonb,
 3, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 32, 'Advanced',
 E'A function is never constant on an interval, yet its average rate of change\nover that interval is zero. How is that possible?',
 '[{"text": "The interval must have zero width", "feedback": "A zero-width interval makes the rate undefined rather than zero, because the denominator vanishes."},
   {"text": "The function can wander away and come back to the same value at the far end", "feedback": "Correct."},
   {"text": "The slope must be zero everywhere on the interval", "feedback": "That would make the function constant, which is exactly what is ruled out."},
   {"text": "The function has to be constant, so the situation cannot arise", "feedback": "The average depends only on the two ENDPOINTS. Everything in between is invisible to it."}]'::jsonb,
 1, 'sub-average-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 33, 'Advanced',
 E'Why does averaging the preceding and the following secant usually beat\nusing just one of them?',
 '[{"text": "It needs fewer data points", "feedback": "It needs one more, not fewer. The gain is in accuracy rather than effort."},
   {"text": "The tangent slope is the sum of the two secant slopes", "feedback": "It sits BETWEEN them, which is why they are averaged rather than added."},
   {"text": "The two secants err in opposite directions, so their average lands closer", "feedback": "Correct."},
   {"text": "A single secant always over-estimates the rate", "feedback": "It over-estimates on one side and under-estimates on the other, which is precisely why the pair is useful."}]'::jsonb,
 2, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 34, 'Advanced',
 E'A secant over [2, 2.001] has slope 1.001, and over [2, 2.0001] it has\nslope 1.0001. What does this suggest about the rate at x = 2?',
 '[{"text": "It is exactly 1", "feedback": "Correct."},
   {"text": "It is exactly 1.001", "feedback": "That is one of the estimates, and the next one is already closer to a rounder number. Follow where the sequence is heading."},
   {"text": "It is exactly 0.001", "feedback": "0.001 is the width of the interval, not the slope."},
   {"text": "It cannot be found from estimates like these", "feedback": "The whole point of shrinking the interval is that the estimates close in on the exact value."}]'::jsonb,
 0, 'sub-instantaneous-roc'),

(12, 'MHF4U', 'Rates of Change', 6, 35, 'Advanced',
 'For f(x) = 1/x, simplify the Newton quotient [f(a + h) - f(a)]/h.',
 '[{"text": "-1/[a(a + h)]", "feedback": "Correct."},
   {"text": "1/[a(a + h)]", "feedback": "Combining the two fractions gives a - (a + h) on top, which is -h. That minus survives the division."},
   {"text": "-1/a²", "feedback": "That is the value the quotient approaches as h shrinks. Before the limit is taken, an h is still there."},
   {"text": "-1/(a + h)", "feedback": "The common denominator is a(a + h), so both factors stay underneath."}]'::jsonb,
 0, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 36, 'Advanced',
 'Using the Newton quotient, find the instantaneous rate of change of f(x) = 1/x at x = 2.',
 '[{"text": "-1/4", "feedback": "Correct."},
   {"text": "1/4", "feedback": "The function is falling everywhere it is defined, so its rate of change is negative."},
   {"text": "-1/2", "feedback": "That is f(2) with a minus attached. The rate involves the square of the a value."},
   {"text": "-4", "feedback": "The fraction is upside down. The a² sits in the DENOMINATOR."}]'::jsonb,
 0, 'sub-newtons-quotient'),

(12, 'MHF4U', 'Rates of Change', 6, 37, 'Advanced',
 'Find the limit of (√(x + 4) - 2)/x as x approaches 0.',
 '[{"text": "1/4", "feedback": "Correct."},
   {"text": "0", "feedback": "Substituting gives 0 over 0, which is a signal to multiply by the conjugate rather than an answer."},
   {"text": "1/2", "feedback": "After multiplying by the conjugate the denominator becomes √(x + 4) + 2, and at x = 0 that comes to 4, not 2."},
   {"text": "Undefined", "feedback": "The expression is undefined at 0, but the values on either side head toward a perfectly definite number."}]'::jsonb,
 0, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 38, 'Advanced',
 'Find the limit of (3x² + 5)/(x² - 2) as x approaches infinity.',
 '[{"text": "0", "feedback": "The top and bottom have the SAME degree, so neither runs away from the other. The ratio settles on the leading coefficients."},
   {"text": "Infinity", "feedback": "That happens when the top has the higher degree. Here the two degrees match."},
   {"text": "-5/2", "feedback": "That is the ratio of the CONSTANT terms, which is what matters as x approaches 0 rather than infinity."},
   {"text": "3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-limits'),

(12, 'MHF4U', 'Rates of Change', 6, 39, 'Advanced',
 E'An oven has an average rate of change of +10.4 °C per minute over 25\nminutes, yet its instantaneous rate at 21 minutes is negative.\nWhat does that mean?',
 '[{"text": "The temperature never actually fell", "feedback": "A negative instantaneous rate is exactly a moment when the temperature was falling."},
   {"text": "The units must have been mixed up", "feedback": "Both figures are in degrees per minute. The two simply describe different things: a whole span and a single moment."},
   {"text": "It cooled for part of the time, even though it finished hotter than it started", "feedback": "Correct."},
   {"text": "One of the two calculations must be wrong", "feedback": "Both can be right at once. The average sees only the endpoints and is blind to everything in between."}]'::jsonb,
 2, 'sub-roc-interpretation'),

(12, 'MHF4U', 'Rates of Change', 6, 40, 'Advanced',
 E'A car position function has a rate of change of zero at t = 5 seconds,\nand a positive rate both just before and just after. What is happening?',
 '[{"text": "The car reverses", "feedback": "Reversing needs the rate to turn NEGATIVE. Here it only touches zero before climbing back."},
   {"text": "The car stops for good", "feedback": "Stopping for good would keep the rate at zero from then on, and here it is positive again straight after."},
   {"text": "The car is at its fastest", "feedback": "A zero rate is the slowest the car gets, not the fastest."},
   {"text": "The car pauses for an instant and then carries on forward", "feedback": "Correct."}]'::jsonb,
 3, 'sub-roc-interpretation');

-- --- questions_mhf4u_u7.sql ---

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

-- --- figures_mhf4u.sql  (must be last) ---

-- ======================================================================
-- figures_mhf4u.sql — attaches figures to questions
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

update questions set figure = null where course_code = 'MHF4U';

update questions set figure = 'figures/mhf4u_trig_20.png'
 where course_code = 'MHF4U' and unit = 'Trig in Radians' and sort_order = 20;
update questions set figure = 'figures/mhf4u_trig_31.png'
 where course_code = 'MHF4U' and unit = 'Trig Identities and Equations' and sort_order = 31;

-- Check: every figure attached, and none orphaned.
select unit, sort_order, figure from questions
 where course_code = 'MHF4U' and figure is not null
 order by unit, sort_order;
