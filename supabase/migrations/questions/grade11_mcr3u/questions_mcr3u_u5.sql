-- ===========================================================================
-- MCR3U — Unit 5: Trig Geometry — 40 questions
-- ===========================================================================
-- Grade 11 Trigonometry, authored from the Jensen MCR3U lesson material for
-- this unit:
--
--   Lesson 1  Special angles and the two special triangles
--   Lesson 2  Ratios for angles greater than 90 degrees, CAST, coterminal
--   Lesson 3  Solving trig equations
--   Lesson 4  Reciprocal trig ratios
--   Lesson 5  Problems in two and three dimensions
--   Lesson 6  The ambiguous case of the sine law
--   Lesson 7  Trig identities
--
-- Six subtopics rather than seven: the ambiguous case is folded in with the
-- sine and cosine laws, because a student who gets it wrong has not made a
-- separate mistake, they have made a sine-law mistake with a second triangle
-- in it, and the dashboard should say so.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs. Exact values are given
-- in the form the Jensen material uses (1/√2 rather than √2/2), and no
-- distractor is ever an equivalent form of the answer wearing different
-- clothes.
--
-- FIGURES. Five questions carry one: 9, 19, 26, 27 and 38 — every question
-- in this unit that describes a triangle or a scene a student has to picture
-- before any trigonometry can start. That is far fewer than the 28 the Grade
-- 10 trigonometry unit needed, and the reason is the shape of the unit
-- rather than restraint: most of MCR3U Unit 5 is exact values, CAST and
-- identities, where there is no scene at all. Four families were considered
-- and REJECTED, each because the picture would do the question:
--   * the special-triangle questions (1, 2, 11, 12, 31) — a labelled 30-60-90
--     or 45-45-90 triangle has the exact value written on it
--   * the CAST and terminal-arm questions (23, 24, 32, 35) — these need axes,
--     and AUTHORING_GUIDE.md rejects anything with axes or a grid
--   * the ambiguous-case question (37) — the diagram is the hinge with side a
--     swinging on an arc, and it shows the two intersection points, which is
--     precisely what the question asks the student to work out
--   * reciprocal-ratio questions (17, 18, 21, 28, 36) — nothing to draw that
--     is not either a special triangle or a quadrant diagram
-- The five that survive are drawn by tools/make_figures.py, which asserts the
-- ruler test on each: what a student measuring the drawing computes must land
-- nearest a WRONG option.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcr3u.sql.
-- The figure file must come second, because the delete below clears the
-- figure column along with the rest of each row.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Trig Geometry';

insert into misconception_labels (tag, label) values
  ('sub-special-angles',   'Special angles and exact ratios'),
  ('sub-angles-beyond-90', 'Ratios for angles beyond 90 degrees'),
  ('sub-trig-equations',   'Solving trig equations'),
  ('sub-reciprocal-ratios','Reciprocal trig ratios'),
  ('sub-sine-cosine-law',  'Sine law, cosine law and the ambiguous case'),
  ('sub-trig-identities',  'Trig identities')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 1, 'Easy',
 E'In the 30-60-90 special triangle whose shortest side is 1,\nhow long is the hypotenuse?',
 '[{"text": "√2", "feedback": "√2 is the hypotenuse of the OTHER special triangle, the 45-45-90 one."},
   {"text": "1", "feedback": "1 is the shortest side, opposite the 30 degree angle. The hypotenuse is opposite the right angle."},
   {"text": "2", "feedback": "Correct."},
   {"text": "√3", "feedback": "√3 is the side opposite the 60 degree angle. The hypotenuse is longer than both legs."}]'::jsonb,
 2, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 2, 'Easy',
 'What is the exact value of sin 45°?',
 '[{"text": "√3/2", "feedback": "That is sin 60, which comes from the other special triangle."},
   {"text": "1/2", "feedback": "That is sin 30. In the 45-45-90 triangle the two legs are equal, so the ratio is not a half."},
   {"text": "√2", "feedback": "√2 is the HYPOTENUSE of the 45-45-90 triangle. A sine is a ratio, and it cannot exceed 1."},
   {"text": "1/√2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 3, 'Easy',
 'In which quadrant are all three primary trig ratios positive?',
 '[{"text": "The first", "feedback": "Correct."},
   {"text": "The second", "feedback": "In the second quadrant only sine is positive, which is the S in CAST."},
   {"text": "The third", "feedback": "In the third quadrant only tangent is positive, which is the T in CAST."},
   {"text": "The fourth", "feedback": "In the fourth quadrant only cosine is positive, which is the C in CAST."}]'::jsonb,
 0, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 4, 'Easy',
 'What is the reference angle for 330°?',
 '[{"text": "60°", "feedback": "That would be the reference angle for 300 degrees. Subtract 330 from a full turn."},
   {"text": "150°", "feedback": "A reference angle is measured to the nearest part of the x-axis, so it is never more than 90 degrees."},
   {"text": "330°", "feedback": "That is the angle itself. The reference angle is the acute angle it makes with the x-axis."},
   {"text": "30°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 5, 'Easy',
 'If sin θ = 1/2, what is the ACUTE angle θ?',
 '[{"text": "150°", "feedback": "150 does have a sine of a half, but it is obtuse. The question asks for the acute angle."},
   {"text": "30°", "feedback": "Correct."},
   {"text": "60°", "feedback": "sin 60 is √3/2. The angle whose sine is a half is the smaller one in the special triangle."},
   {"text": "45°", "feedback": "sin 45 is 1/√2, which is about 0.71 rather than 0.5."}]'::jsonb,
 1, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 6, 'Easy',
 'How many solutions does sin θ = 0.4 have between 0° and 360°?',
 '[{"text": "4", "feedback": "Four solutions would need two full turns. Between 0 and 360 there is only one turn."},
   {"text": "2", "feedback": "Correct."},
   {"text": "1", "feedback": "The calculator gives one, but sine is positive in two quadrants, so a second angle shares the same value."},
   {"text": "3", "feedback": "Sine repeats once per full turn, and it takes each value between -1 and 1 exactly twice in a single turn."}]'::jsonb,
 1, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 7, 'Easy',
 'What is csc θ equal to?',
 '[{"text": "sin θ/cos θ", "feedback": "That is tan θ, and it is not a reciprocal ratio at all."},
   {"text": "1/sin θ", "feedback": "Correct."},
   {"text": "1/cos θ", "feedback": "That is sec θ. The names do not line up with the letters they start with, which is exactly what makes them easy to swap."},
   {"text": "1/tan θ", "feedback": "That is cot θ."}]'::jsonb,
 1, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 8, 'Easy',
 'Which law do you use when you are given two sides and the angle BETWEEN them?',
 '[{"text": "The Pythagorean theorem", "feedback": "Pythagoras only works in a right triangle, and nothing here says the contained angle is 90 degrees."},
   {"text": "The ambiguous case test", "feedback": "That test is for two sides and an angle NOT between them, where a second triangle might fit the same numbers."},
   {"text": "The cosine law", "feedback": "Correct."},
   {"text": "The sine law", "feedback": "The sine law needs a side and the angle OPPOSITE it as a matched pair, and a contained angle is not opposite either of the given sides."}]'::jsonb,
 2, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 9, 'Easy',
 'Two angles of a triangle are 40° and 75°. What is the third?',
 '[{"text": "105°", "feedback": "That is what would be left if only the 75 were taken off 180. Both given angles come off."},
   {"text": "65°", "feedback": "Correct."},
   {"text": "115°", "feedback": "That is the sum of the two given angles, not what is left over from 180."},
   {"text": "45°", "feedback": "That would make the three angles add to 160. They have to add to exactly 180."}]'::jsonb,
 1, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 10, 'Easy',
 'Which of these is the Pythagorean identity?',
 '[{"text": "sin²θ + cos²θ = 1", "feedback": "Correct."},
   {"text": "sin²θ - cos²θ = 1", "feedback": "The sign is wrong. Try θ = 0: that version gives -1, not 1."},
   {"text": "sin θ + cos θ = 1", "feedback": "The squares matter. Try θ = 45: that version gives about 1.41."},
   {"text": "tan²θ + 1 = sin²θ", "feedback": "The right-hand side is wrong. Dividing the real identity through by cos²θ gives sec²θ there, not sin²θ."}]'::jsonb,
 0, 'sub-trig-identities'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 11, 'Medium',
 'What is the exact value of cos 60°?',
 '[{"text": "1/2", "feedback": "Correct."},
   {"text": "√3/2", "feedback": "That is cos 30. In the special triangle the side adjacent to 60 is the SHORT one."},
   {"text": "1/√2", "feedback": "That is cos 45, from the other special triangle."},
   {"text": "2", "feedback": "2 is the hypotenuse of the 30-60-90 triangle. A cosine is a ratio and cannot exceed 1."}]'::jsonb,
 0, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 12, 'Medium',
 'What is the exact value of tan 30°?',
 '[{"text": "√3", "feedback": "That is tan 60. The ratio is upside down: at 30 degrees the opposite side is the short one."},
   {"text": "1/2", "feedback": "1/2 is sin 30. Tangent divides by the ADJACENT side, not by the hypotenuse."},
   {"text": "√3/2", "feedback": "√3/2 is cos 30. Tangent divides by the adjacent side, not by the hypotenuse."},
   {"text": "1/√3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 13, 'Medium',
 'What is the exact value of sin 225°?',
 '[{"text": "-1/√2", "feedback": "Correct."},
   {"text": "1/√2", "feedback": "The reference angle is right but 225 lands in the third quadrant, where sine is negative."},
   {"text": "-√3/2", "feedback": "The sign is right but the reference angle is not. 225 - 180 gives 45, not 60."},
   {"text": "-1/2", "feedback": "The sign is right but the reference angle is not. 225 - 180 gives 45, not 30."}]'::jsonb,
 0, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 14, 'Medium',
 'Which pair of angles is coterminal with 97°?',
 '[{"text": "457° and 817°", "feedback": "Correct."},
   {"text": "263° and 623°", "feedback": "263 is 360 - 97, which is a reflection rather than a full turn. Coterminal angles differ by whole turns."},
   {"text": "97° and 187°", "feedback": "187 is 97 + 90, which is a quarter turn. A full turn is 360."},
   {"text": "-97° and 277°", "feedback": "-97 flips the angle to the other side of the axis rather than turning it all the way round."}]'::jsonb,
 0, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 15, 'Medium',
 'Find both angles between 0° and 360° with tan θ = -√3.',
 '[{"text": "60° and 120°", "feedback": "Only the second of these has a negative tangent. Tangent is positive in the first quadrant."},
   {"text": "150° and 330°", "feedback": "The related acute angle is 60, not 30. tan 60 is √3."},
   {"text": "120° and 300°", "feedback": "Correct."},
   {"text": "60° and 240°", "feedback": "Those are the angles where the tangent is POSITIVE √3. A negative tangent lives in the second and fourth quadrants."}]'::jsonb,
 2, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 16, 'Medium',
 'Find both angles between 0° and 360° with sin θ = √3/2.',
 '[{"text": "30° and 150°", "feedback": "The related acute angle is 60, not 30. sin 30 is a half."},
   {"text": "120° and 240°", "feedback": "The first-quadrant solution went missing. Sine is positive in both the first and second quadrants."},
   {"text": "60° and 120°", "feedback": "Correct."},
   {"text": "60° and 240°", "feedback": "240 is in the third quadrant, where sine is negative. The second solution comes from 180 MINUS the first."}]'::jsonb,
 2, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 17, 'Medium',
 'What is the exact value of sec 120°?',
 '[{"text": "-√3", "feedback": "That is tan 120. Secant comes from cosine, not from tangent."},
   {"text": "-2", "feedback": "Correct."},
   {"text": "2", "feedback": "The size is right but 120 sits in the second quadrant, where cosine and therefore secant are negative."},
   {"text": "-1/2", "feedback": "That is cos 120 itself. Secant is its RECIPROCAL, so the fraction turns over."}]'::jsonb,
 1, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 18, 'Medium',
 'What is the exact value of csc 150°?',
 '[{"text": "-2", "feedback": "150 is in the second quadrant, where sine is positive, so its reciprocal is positive too."},
   {"text": "√2", "feedback": "√2 is csc 45. The related acute angle for 150 is 30, not 45."},
   {"text": "2", "feedback": "Correct."},
   {"text": "1/2", "feedback": "That is sin 150 itself. Cosecant is its RECIPROCAL, so the fraction turns over."}]'::jsonb,
 2, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 19, 'Medium',
 E'In triangle ABC, angle A = 40°, angle B = 75° and side b = 12 cm.\nFind side a, to one decimal place.',
 '[{"text": "11.3 cm", "feedback": "The third angle, 65 degrees, was used in place of angle A. Side a is opposite A."},
   {"text": "7.7 cm", "feedback": "That treats the triangle as right-angled and works out 12 sin 40. There is no right angle here, so the sine law is needed."},
   {"text": "8.0 cm", "feedback": "Correct."},
   {"text": "18.0 cm", "feedback": "The ratio was set up upside down. Side a pairs with angle A on the same side of the equation."}]'::jsonb,
 2, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 20, 'Medium',
 'Simplify: sin θ / cos θ',
 '[{"text": "1", "feedback": "Sine and cosine are different numbers for almost every angle, so they do not cancel."},
   {"text": "tan θ", "feedback": "Correct."},
   {"text": "cot θ", "feedback": "That is the same fraction upside down, cos over sin."},
   {"text": "sec θ", "feedback": "sec θ is 1 over cos θ. There is a sine on top here, not a 1."}]'::jsonb,
 1, 'sub-trig-identities'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): reference angles, quadrant work, solving whole triangles.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 21, 'Challenge',
 'What is the exact value of cot 300°?',
 '[{"text": "-1/√3", "feedback": "Correct."},
   {"text": "1/√3", "feedback": "The size is right but 300 sits in the fourth quadrant, where tangent and therefore cotangent are negative."},
   {"text": "-√3", "feedback": "That is tan 300. Cotangent is its reciprocal, so the fraction turns over."},
   {"text": "√3", "feedback": "Both the size and the sign are off: the reciprocal is needed, and the fourth quadrant makes it negative."}]'::jsonb,
 0, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 22, 'Challenge',
 'What is the exact value of tan 135°?',
 '[{"text": "-1/√3", "feedback": "The sign is right but the reference angle is not. 180 - 135 gives 45, not 30."},
   {"text": "-1", "feedback": "Correct."},
   {"text": "1", "feedback": "The related acute angle 45 gives 1, but 135 is in the second quadrant, where tangent is negative."},
   {"text": "-√3", "feedback": "The sign is right but the reference angle is not. 180 - 135 gives 45, not 60."}]'::jsonb,
 1, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 23, 'Challenge',
 E'cos A = -8/17 and the terminal arm of A lies in the second quadrant.\nFind sin A and tan A.',
 '[{"text": "sin A = 15/17 and tan A = 15/8", "feedback": "The sine is right, but a positive sine over a negative cosine has to give a negative tangent."},
   {"text": "sin A = 15/17 and tan A = -15/8", "feedback": "Correct."},
   {"text": "sin A = -15/17 and tan A = 15/8", "feedback": "The quadrant was not used. In the second quadrant sine is positive and tangent is negative."},
   {"text": "sin A = 15/17 and tan A = -8/15", "feedback": "The tangent is upside down. It is the opposite side over the adjacent one."}]'::jsonb,
 1, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 24, 'Challenge',
 E'The point P(-3, 4) lies on the terminal arm of an angle in standard\nposition. Find sin θ and tan θ.',
 '[{"text": "sin θ = -4/5 and tan θ = -4/3", "feedback": "The minus belongs to the x-coordinate, not to the y-coordinate. Sine is built from y over r."},
   {"text": "sin θ = -3/5 and tan θ = -3/4", "feedback": "The two coordinates have swapped roles. Sine uses the y value, tangent is y over x."},
   {"text": "sin θ = 4/5 and tan θ = 4/3", "feedback": "The sine is right, but tangent divides by the x value, and that x value is negative."},
   {"text": "sin θ = 4/5 and tan θ = -4/3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 25, 'Challenge',
 E'Find both angles between 0° and 360° with tan θ = -0.32,\neach to one decimal place.',
 '[{"text": "197.7° and 342.3°", "feedback": "The second-quadrant solution was placed in the third instead. Tangent is positive in the third quadrant."},
   {"text": "162.3° and 197.7°", "feedback": "Both solutions were put on the same side of the axis. Tangent is negative in the second and fourth quadrants, not the second and third."},
   {"text": "162.3° and 342.3°", "feedback": "Correct."},
   {"text": "17.7° and 197.7°", "feedback": "The minus on the ratio was dropped. Those are the two angles whose tangent is POSITIVE 0.32."}]'::jsonb,
 2, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 26, 'Challenge',
 E'In triangle ABC, a = 42 cm, b = 21 cm and c = 28 cm.\nFind angle A, to one decimal place.',
 '[{"text": "36.3°", "feedback": "That is angle C. Angle A is opposite side a, which is the longest side here."},
   {"text": "117.3°", "feedback": "Correct."},
   {"text": "62.7°", "feedback": "The cosine came out negative, and a negative cosine means an obtuse angle. That value is its supplement."},
   {"text": "26.4°", "feedback": "That is angle B. Angle A is opposite side a, which is the LONGEST side, so A is the largest angle."}]'::jsonb,
 1, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 27, 'Challenge',
 E'A tree 18.5 m tall casts a shadow 10.2 m long.\nWhat is the angle of elevation of the sun, to one decimal place?',
 '[{"text": "61.1°", "feedback": "Correct."},
   {"text": "28.9°", "feedback": "The opposite and adjacent sides are the wrong way round. The tree is opposite the angle of elevation, and it is the taller of the two."},
   {"text": "33.5°", "feedback": "That uses sine with the shadow over the tree, which treats the tree as the hypotenuse. The tree is a vertical leg, not the slanted side."},
   {"text": "1.1°", "feedback": "That is the answer in RADIANS. The calculator was left in the wrong mode; 1.07 radians is the same angle."}]'::jsonb,
 0, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 28, 'Challenge',
 'If cot θ = 1 and θ lies between 180° and 270°, what is θ?',
 '[{"text": "225°", "feedback": "Correct."},
   {"text": "45°", "feedback": "45 does satisfy cot θ = 1, but it sits in the first quadrant and the question restricts θ to between 180 and 270."},
   {"text": "135°", "feedback": "At 135 the cotangent is -1. Cotangent is positive in the first and third quadrants."},
   {"text": "315°", "feedback": "At 315 the cotangent is -1, and 315 is outside the range asked for as well."}]'::jsonb,
 0, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 29, 'Challenge',
 'Simplify: sec θ cos θ + sec θ sin θ',
 '[{"text": "1 + cot θ", "feedback": "The second term gives sine over cosine, and that fraction is tangent. Cotangent is the other way up."},
   {"text": "sec θ + tan θ", "feedback": "The first term simplifies all the way: secant times cosine leaves 1, because the two are reciprocals."},
   {"text": "cos θ + sin θ", "feedback": "The secant was dropped rather than combined. Write it as 1 over cosine and multiply through."},
   {"text": "1 + tan θ", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-identities'),

(11, 'MCR3U', 'Trig Geometry', 5, 30, 'Challenge',
 'Simplify: tan²x + cos²x + sin²x',
 '[{"text": "1/cos²x", "feedback": "Correct."},
   {"text": "1/sin²x", "feedback": "That is what cot²x + 1 gives. The term here is tan²x, so a different Pythagorean identity applies."},
   {"text": "2", "feedback": "The last two terms do collapse to 1, but tan²x is not 1 as well. It stays as a term."},
   {"text": "cos²x", "feedback": "The tan²x term was cancelled away rather than converted. Write it as sin²x over cos²x and combine."}]'::jsonb,
 0, 'sub-trig-identities'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): the ambiguous case, three dimensions, and identities.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Geometry', 5, 31, 'Advanced',
 'What is the exact value of sin 60° cos 30° + cos 60° sin 30°?',
 '[{"text": "3/4", "feedback": "That is the first product on its own. The second product still has to be added to it."},
   {"text": "1/2", "feedback": "The two products were averaged rather than added."},
   {"text": "√3/2", "feedback": "That is sin 60 by itself, with the rest of the expression left out."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-special-angles'),

(11, 'MCR3U', 'Trig Geometry', 5, 32, 'Advanced',
 E'Find both angles between 0° and 360° with sin θ = -0.46,\neach to one decimal place.',
 '[{"text": "27.4° and 152.6°", "feedback": "The minus on the ratio was dropped. Those are the two angles whose sine is POSITIVE 0.46."},
   {"text": "152.6° and 332.6°", "feedback": "The first solution is in the second quadrant, where sine is positive. A negative sine lives in the third and fourth."},
   {"text": "207.4° and 27.4°", "feedback": "The first solution is right, but the second was left as the bare related acute angle, where the sine comes out positive."},
   {"text": "207.4° and 332.6°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 33, 'Advanced',
 'Solve 2 sin θ - 1 = 0 for 0° ≤ θ ≤ 360°.',
 '[{"text": "60° and 120°", "feedback": "Rearranging gives sin θ = 1/2, not √3/2. The 2 divides rather than multiplies."},
   {"text": "30° and 150°", "feedback": "Correct."},
   {"text": "30° only", "feedback": "The calculator gives one angle, but sine is positive in two quadrants, so a second solution shares the value."},
   {"text": "30° and 210°", "feedback": "210 is in the third quadrant, where sine is negative. The second solution comes from 180 MINUS the first."}]'::jsonb,
 1, 'sub-trig-equations'),

(11, 'MCR3U', 'Trig Geometry', 5, 34, 'Advanced',
 'Solve tan θ = -1 for 0° ≤ θ ≤ 360°.',
 '[{"text": "45° and 135°", "feedback": "At 45 the tangent is positive. Only one of these two actually satisfies the equation."},
   {"text": "225° and 315°", "feedback": "At 225 the tangent is positive, because tangent is positive in the third quadrant."},
   {"text": "135° and 315°", "feedback": "Correct."},
   {"text": "45° and 225°", "feedback": "Those are the angles where the tangent is POSITIVE 1. The minus sign moves both solutions a quadrant along."}]'::jsonb,
 2, 'sub-angles-beyond-90'),

(11, 'MCR3U', 'Trig Geometry', 5, 35, 'Advanced',
 E'The point Q(-12, -5) lies on the terminal arm of an angle in standard\nposition. Find sec θ and cot θ.',
 '[{"text": "sec θ = 13/12 and cot θ = 12/5", "feedback": "The cotangent is right, but the x value is negative, so the secant built from it is negative too."},
   {"text": "sec θ = -13/12 and cot θ = -12/5", "feedback": "Both coordinates are negative, and a negative divided by a negative gives a positive cotangent."},
   {"text": "sec θ = -13/12 and cot θ = 12/5", "feedback": "Correct."},
   {"text": "sec θ = -12/13 and cot θ = 5/12", "feedback": "Those are cos θ and tan θ. Both still need turning over to become the reciprocal ratios."}]'::jsonb,
 2, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 36, 'Advanced',
 E'csc θ = -13/5 and the terminal arm of θ lies in the third quadrant.\nWhat is cos θ?',
 '[{"text": "12/13", "feedback": "The size is right, but in the third quadrant cosine is negative as well as sine."},
   {"text": "-5/12", "feedback": "That divides the opposite side by the adjacent one and keeps the minus from the sine alone. Cosine is the adjacent side over the hypotenuse."},
   {"text": "-13/12", "feedback": "That is sec θ, the reciprocal. The question asks for cosine itself."},
   {"text": "-12/13", "feedback": "Correct."}]'::jsonb,
 3, 'sub-reciprocal-ratios'),

(11, 'MCR3U', 'Trig Geometry', 5, 37, 'Advanced',
 E'In triangle ABC, a = 12 cm, b = 17 cm and angle A = 21°.\nHow many triangles are possible, and what can angle B be?',
 '[{"text": "Two triangles, with B = 30.5° or B = 210.5°", "feedback": "The second angle comes from 180 MINUS the first, not from adding 180. An angle of 210 degrees cannot sit inside a triangle."},
   {"text": "No triangle exists", "feedback": "No triangle would need a to be shorter than the height b sin A, which is about 6.1 cm. Side a is twice that."},
   {"text": "Two triangles, with B = 30.5° or B = 149.5°", "feedback": "Correct."},
   {"text": "One triangle, with B = 30.5°", "feedback": "The height b sin A is about 6.1 cm, and a sits between that and b. When h is less than a and a is less than b, a second triangle fits the same numbers."}]'::jsonb,
 2, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 38, 'Advanced',
 E'Dave is in a balloon 400 m up, exactly above the midpoint of two houses.\nRhonda stands 4.6 km from House 1 and 3.4 km from House 2, and the two\nhouses are 64° apart as she sees them. Find her angle of elevation to Dave.',
 '[{"text": "About 5.2°", "feedback": "The distance used was the whole gap between the houses. Rhonda is not standing on that line, so her distance to the midpoint has to be found separately."},
   {"text": "About 10.4°", "feedback": "The distance used was half the gap between the houses, which would only be right if Rhonda were standing at one of them."},
   {"text": "About 71.5°", "feedback": "That is the angle at House 2 inside the ground triangle, found on the way. The elevation is measured from where Rhonda stands."},
   {"text": "About 6.7°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-sine-cosine-law'),

(11, 'MCR3U', 'Trig Geometry', 5, 39, 'Advanced',
 'Simplify: (1 - cos²x)/(sin x cos x)',
 '[{"text": "cot x", "feedback": "The numerator was read as cos²x. The 1 - in front of it has to be resolved with the Pythagorean identity first."},
   {"text": "sin x cos x", "feedback": "The cosine underneath was multiplied through rather than divided out. 1 - cos²x is sin²x, which shares a factor with the bottom."},
   {"text": "sec x", "feedback": "The numerator is not 1. It becomes sin²x, and one factor of sine cancels with the bottom rather than all of it."},
   {"text": "tan x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-identities'),

(11, 'MCR3U', 'Trig Geometry', 5, 40, 'Advanced',
 'Simplify: (sec²θ - 1)/sec²θ',
 '[{"text": "sin²θ", "feedback": "Correct."},
   {"text": "cos²θ", "feedback": "The numerator was treated as 1, leaving nothing but the reciprocal of sec²θ. The - 1 is subtracted from sec²θ rather than standing alone on top."},
   {"text": "tan²θ", "feedback": "The numerator was simplified correctly, but the division by sec²θ was never carried out."},
   {"text": "1", "feedback": "The sec²θ terms were cancelled top and bottom, but the - 1 stops sec²θ being a factor of the numerator."}]'::jsonb,
 0, 'sub-trig-identities');
