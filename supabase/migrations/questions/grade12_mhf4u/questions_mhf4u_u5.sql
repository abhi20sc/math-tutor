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
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mhf4u.sql.
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
