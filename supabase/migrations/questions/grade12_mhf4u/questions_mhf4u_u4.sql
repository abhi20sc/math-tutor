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
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mhf4u.sql.
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
