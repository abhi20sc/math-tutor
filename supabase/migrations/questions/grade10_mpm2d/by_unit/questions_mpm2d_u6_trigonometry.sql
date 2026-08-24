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

delete from questions where course_code = 'MPM2D' and unit = 'Trigonometry';

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

(10, 'MPM2D', 'Trigonometry', 6, 1, 'Easy',
 'Two similar triangles have what in common?',
 '[{"text": "Equal sides and equal angles", "feedback": "Equal SIDES too would make them congruent. Similar allows different sizes."}, {"text": "Equal corresponding angles and proportional sides", "feedback": "Correct."}, {"text": "The same perimeter", "feedback": "Perimeters scale with the triangles. Only the angles are untouched by scaling."}, {"text": "Equal areas", "feedback": "Similar triangles usually have different areas — the shape matches, not the size."}]'::jsonb, 1, 'sub-similar-triangles'),

(10, 'MPM2D', 'Trigonometry', 6, 2, 'Easy',
 'Triangle DEF is similar to ABC with a scale factor of 3. Side AB is 4 cm. How long is DE?',
 '[{"text": "12 cm", "feedback": "Correct."}, {"text": "4 cm", "feedback": "Equal sides belong to congruent triangles. Similar ones scale."}, {"text": "7 cm", "feedback": "That adds the scale factor instead of multiplying by it. A scale factor stretches, it does not shift."}, {"text": "4/3 cm", "feedback": "Dividing shrinks — but DEF is the LARGER triangle here, three times ABC."}]'::jsonb, 0, 'sub-similar-triangles'),

(10, 'MPM2D', 'Trigonometry', 6, 3, 'Easy',
 'In a right triangle, the hypotenuse is which side?',
 '[{"text": "The horizontal side", "feedback": "Orientation on the page means nothing — rotate the triangle and the hypotenuse stays itself."}, {"text": "Either of the two sides that meet to form the right angle", "feedback": "Those are the legs. The hypotenuse faces the right angle from across the triangle."}, {"text": "The side opposite the smallest angle", "feedback": "Opposite the smallest angle sits the SHORTEST side."}, {"text": "The side opposite the right angle, always the longest", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-ratios'),

(10, 'MPM2D', 'Trigonometry', 6, 4, 'Easy',
 'Relative to angle θ in a right triangle, sin θ equals what?',
 '[{"text": "Opposite over hypotenuse", "feedback": "Correct."}, {"text": "Hypotenuse over opposite", "feedback": "The hypotenuse goes UNDERNEATH for sine."}, {"text": "Adjacent over hypotenuse", "feedback": "Adjacent over hypotenuse is COSINE. SOH: sine takes the opposite side."}, {"text": "Opposite over adjacent", "feedback": "That ratio is tangent, the TOA in the memory aid."}]'::jsonb, 0, 'sub-trig-ratios'),

(10, 'MPM2D', 'Trigonometry', 6, 5, 'Easy',
 'In a right triangle with the angle θ at one corner, the side touching θ that is not the hypotenuse is called what?',
 '[{"text": "The opposite side", "feedback": "Opposite means ACROSS from the angle, not touching it."}, {"text": "The adjacent side", "feedback": "Correct."}, {"text": "The hypotenuse", "feedback": "The hypotenuse also touches θ, but it is the special side facing the right angle — the question excludes it."}, {"text": "The base", "feedback": "Base describes position on the page, which changes when the triangle rotates."}]'::jsonb, 1, 'sub-trig-ratios'),

(10, 'MPM2D', 'Trigonometry', 6, 6, 'Easy',
 'A right triangle has legs 3 and 4 with hypotenuse 5. For the angle opposite the side of length 3, what is tan θ?',
 '[{"text": "3/4", "feedback": "Correct."}, {"text": "3/5", "feedback": "3/5 is sin θ — the hypotenuse crept into the tangent."}, {"text": "4/3", "feedback": "4/3 belongs to the OTHER acute angle. Opposite this angle is 3; adjacent is 4."}, {"text": "4/5", "feedback": "That is cos θ. Tangent never uses the hypotenuse."}]'::jsonb, 0, 'sub-trig-ratios'),

(10, 'MPM2D', 'Trigonometry', 6, 7, 'Easy',
 'Which tool finds a missing ANGLE from two known sides of a right triangle?',
 '[{"text": "The regular tan function used on its own", "feedback": "tan turns angles INTO ratios. Getting the angle back needs the inverse."}, {"text": "An inverse trig function such as tan⁻¹", "feedback": "Correct."}, {"text": "The Pythagorean theorem applied to the two sides", "feedback": "Pythagoras relates the three sides. It never mentions angles."}, {"text": "Doubling the ratio of the two known sides", "feedback": "No doubling rule connects ratios to angles. The inverse functions do that."}]'::jsonb, 1, 'sub-trig-angles'),

(10, 'MPM2D', 'Trigonometry', 6, 8, 'Easy',
 'In a right triangle, the hypotenuse is 10 cm and one angle is 35°. What is the side opposite that angle, to one decimal?',
 '[{"text": "8.2 cm", "feedback": "That used cos 35°. Opposite over hypotenuse calls for SINE."}, {"text": "7.0 cm", "feedback": "That used tan, which pairs opposite with the ADJACENT side, not the hypotenuse."}, {"text": "35.0 cm", "feedback": "35 is the angle. The side comes from 10 times sin 35°."}, {"text": "5.7 cm", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-side-lengths'),

(10, 'MPM2D', 'Trigonometry', 6, 9, 'Easy',
 'The sine law relates what quantities?',
 '[{"text": "Each side to the sine of its opposite angle", "feedback": "Correct."}, {"text": "The two legs and the hypotenuse", "feedback": "Legs and hypotenuse language belongs to RIGHT triangles. The sine law works on any triangle."}, {"text": "Each side to the sine of its adjacent angle", "feedback": "The pairing is strictly OPPOSITE: a with A, across the triangle."}, {"text": "The three angles only", "feedback": "Angles alone come from the 180° sum. The sine law brings the sides in."}]'::jsonb, 0, 'sub-sine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 10, 'Easy',
 'In a triangle with no right angle, when is the cosine law needed rather than the sine law?',
 '[{"text": "Whenever the triangle has an obtuse angle", "feedback": "An obtuse angle does not decide which law applies. What matters is which sides and angles are given."}, {"text": "When the triangle is small", "feedback": "Size is irrelevant. The choice of law rests on which parts are known."}, {"text": "When only angles are known", "feedback": "Only angles fixes the shape but not the size — no law finds sides from angles alone."}, {"text": "When no side has its opposite angle known", "feedback": "Correct."}]'::jsonb, 3, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 11, 'Medium',
 'Triangles are similar. One has sides 6 and x; the matching sides of the other are 9 and 12. What is x?',
 '[{"text": "9", "feedback": "6 + 3 borrows the additive gap between 6 and 9. Similarity scales by MULTIPLICATION: the factor is 9/6."}, {"text": "8", "feedback": "Correct."}, {"text": "4.5", "feedback": "That halves the 9 with no basis. Cross multiply the proportion 6/9 = x/12."}, {"text": "18", "feedback": "That multiplies 6 by 3. The scale factor is 12/9 in that direction — set up 6/9 = x/12."}]'::jsonb, 1, 'sub-similar-triangles'),

(10, 'MPM2D', 'Trigonometry', 6, 12, 'Medium',
 'Which condition proves two triangles are similar?',
 '[{"text": "Equal perimeters in both of the triangles", "feedback": "Perimeters can match on wildly different shapes."}, {"text": "One pair of equal corresponding angles only", "feedback": "One angle is shared by many shapes. Two pins the third down through the 180° sum."}, {"text": "Two pairs of equal corresponding side lengths", "feedback": "Equal sides without the contained angle proves nothing — and similarity wants proportional, not equal."}, {"text": "Two pairs of equal corresponding angles", "feedback": "Correct."}]'::jsonb, 3, 'sub-similar-triangles'),

(10, 'MPM2D', 'Trigonometry', 6, 13, 'Medium',
 'A 14 m ladder leans at 52° to the ground. How far is its base from the wall, to one decimal?',
 '[{"text": "22.7 m", "feedback": "That divides by cos instead of multiplying — and it comes out LONGER than the ladder itself, impossible for a leg."}, {"text": "11.0 m", "feedback": "That is the HEIGHT up the wall, from sin 52°. The ground distance is adjacent: cos."}, {"text": "8.6 m", "feedback": "Correct."}, {"text": "7.0 m", "feedback": "Halving the ladder assumes 60°. Use the cosine of the actual angle."}]'::jsonb, 2, 'sub-trig-side-lengths'),

(10, 'MPM2D', 'Trigonometry', 6, 14, 'Medium',
 'From 25 m away, the angle of elevation to the top of a tree is 41°. How tall is the tree, to one decimal?',
 '[{"text": "21.7 m", "feedback": "Correct."}, {"text": "25.0 m", "feedback": "Equal height and distance happens only at 45°. This angle is 41°."}, {"text": "16.4 m", "feedback": "sin pairs opposite with the HYPOTENUSE, but 25 m is the ground distance — adjacent. Use tan."}, {"text": "28.8 m", "feedback": "That divides by tan. The height is the OPPOSITE side and 25 m is the ADJACENT — rearrange the tan ratio for the opposite."}]'::jsonb, 0, 'sub-trig-side-lengths'),

(10, 'MPM2D', 'Trigonometry', 6, 15, 'Medium',
 'The side opposite a 32° angle is 8 cm. What is the hypotenuse, to one decimal?',
 '[{"text": "9.4 cm", "feedback": "Opposite and hypotenuse pair with SINE. cos would need the adjacent side."}, {"text": "4.0 cm", "feedback": "The hypotenuse is the LONGEST side — it cannot be shorter than the 8 cm leg."}, {"text": "4.2 cm", "feedback": "That MULTIPLIED by sin 32°. In sine, the hypotenuse sits on the BOTTOM of the ratio — isolating it means dividing."}, {"text": "15.1 cm", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-side-lengths'),

(10, 'MPM2D', 'Trigonometry', 6, 16, 'Medium',
 'A right triangle has opposite side 5 and adjacent side 12. What is the angle, to one decimal?',
 '[{"text": "22.6°", "feedback": "Correct."}, {"text": "24.6°", "feedback": "sin⁻¹ of 5/12 treats 12 as the hypotenuse, but 12 is the adjacent side here — 13 would be the hypotenuse."}, {"text": "0.4°", "feedback": "0.42 is the RATIO 5/12 itself. The inverse tan turns it into an angle."}, {"text": "67.4°", "feedback": "That is tan⁻¹ of 12/5 — the ratio upside down, giving the OTHER acute angle."}]'::jsonb, 0, 'sub-trig-angles'),

(10, 'MPM2D', 'Trigonometry', 6, 17, 'Medium',
 'The side opposite angle θ is 7 and the hypotenuse is 10. What is θ, to one decimal?',
 '[{"text": "35.0°", "feedback": "A guess of half of 70 is not how ratios become angles. sin⁻¹(0.7) is the tool."}, {"text": "45.6°", "feedback": "cos⁻¹ answers a different question — 0.7 here is opposite over hypotenuse, which belongs to sin."}, {"text": "44.4°", "feedback": "Correct."}, {"text": "0.7°", "feedback": "0.7 is the ratio. Feed it to sin⁻¹ for the angle."}]'::jsonb, 2, 'sub-trig-ratios'),

(10, 'MPM2D', 'Trigonometry', 6, 18, 'Medium',
 'In triangle ABC, angle A = 40°, angle B = 75°, and b = 12 cm. What is side a, to one decimal?',
 '[{"text": "8.0 cm", "feedback": "Correct."}, {"text": "7.7 cm", "feedback": "The sin 75° divisor went missing. The sine law is a full proportion, not one product."}, {"text": "18.0 cm", "feedback": "The sines are flipped — the unknown side sits on top, multiplied by the sine of ITS OWN opposite angle."}, {"text": "12.0 cm", "feedback": "Side a faces the SMALLER angle, so it must come out shorter than 12."}]'::jsonb, 0, 'sub-sine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 19, 'Medium',
 'In triangle ABC, a = 9, b = 14 and angle B = 80°. What is angle A, to one decimal?',
 '[{"text": "39.3°", "feedback": "Correct."}, {"text": "0.6°", "feedback": "That is the sine RATIO, not the angle. The inverse sine still has to run."}, {"text": "39.1°", "feedback": "That rounds the sine ratio to two decimals before the inverse sine. Keep the digits until the end."}, {"text": "61.0°", "feedback": "That subtracts from 180 too early: find A from the sine law first, then any leftover angle."}]'::jsonb, 0, 'sub-sine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 20, 'Medium',
 'In triangle ABC, b = 7, c = 9 and angle A = 60°. What is side a, to one decimal?',
 '[{"text": "2.0 cm", "feedback": "Order of operations: only the 2bc multiplies cos A. That slip lands on a², and the square root has still to be taken."}, {"text": "8.2 cm", "feedback": "Correct."}, {"text": "67.0 cm", "feedback": "67 is a², the squared side. The square root finishes it."}, {"text": "11.4 cm", "feedback": "The -2bc cos A term was dropped — that is Pythagoras, which needs a right angle."}]'::jsonb, 1, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 21, 'Challenge',
 'A 1.8 m person casts a 2.4 m shadow while a tree casts a 14 m shadow. How tall is the tree?',
 '[{"text": "10.8 m", "feedback": "That rounds the scale factor 14/2.4 up to 6 before multiplying. Keep it exact until the end."}, {"text": "13.4 m", "feedback": "14 - 0.6 borrows the additive gap between 1.8 and 2.4. Similar triangles scale multiplicatively."}, {"text": "10.5 m", "feedback": "Correct."}, {"text": "18.7 m", "feedback": "That scales by 14/1.8 — mixing a height with a shadow. Match shadow to shadow: the factor is 14/2.4."}]'::jsonb, 2, 'sub-similar-triangles'),

(10, 'MPM2D', 'Trigonometry', 6, 22, 'Challenge',
 'From the top of an 80 m cliff, the angle of depression to a boat is 25°. How far is the boat from the base of the cliff, to the nearest metre?',
 '[{"text": "37 m", "feedback": "That multiplied by tan 25°. The 80 m height is OPPOSITE the angle at the boat — check which side of the tan ratio it sits on."}, {"text": "189 m", "feedback": "That is the line of sight TO the boat, the hypotenuse — not the distance along the water."}, {"text": "172 m", "feedback": "Correct."}, {"text": "80 m", "feedback": "Equal height and distance needs 45°. At 25° the boat sits much farther out."}]'::jsonb, 2, 'sub-trig-side-lengths'),

(10, 'MPM2D', 'Trigonometry', 6, 23, 'Challenge',
 'A right triangle has hypotenuse 15 and one leg 9. What is the angle opposite that leg, to one decimal?',
 '[{"text": "36.9°", "feedback": "Correct."}, {"text": "53.1°", "feedback": "cos⁻¹ gives the OTHER acute angle. Opposite over hypotenuse is a sine ratio."}, {"text": "0.6°", "feedback": "0.6 is the ratio 9/15. Push it through sin⁻¹."}, {"text": "31.0°", "feedback": "tan pairs the two LEGS — but 15 is the hypotenuse. Find the other leg first, or just use sin."}]'::jsonb, 0, 'sub-trig-angles'),

(10, 'MPM2D', 'Trigonometry', 6, 24, 'Challenge',
 'In triangle ABC, angle A = 35°, angle B = 65°, and a = 10 cm. What is side c, to one decimal?',
 '[{"text": "5.8 cm", "feedback": "The proportion is upside down: c = a sin C over sin A, with the unknown side on top."}, {"text": "15.8 cm", "feedback": "That found side b. Side c pairs with angle C, which is 180 - 35 - 65 = 80°."}, {"text": "17.2 cm", "feedback": "Correct."}, {"text": "10.0 cm", "feedback": "c faces the LARGEST angle, 80°, so it must be the longest side — longer than 10."}]'::jsonb, 2, 'sub-sine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 25, 'Challenge',
 'A triangle has sides 5, 7 and 10. What is the angle opposite the 10 side, to one decimal?',
 '[{"text": "138.0°", "feedback": "The denominator is 2ab — two times 5 times 7. The 2 was dropped."}, {"text": "68.2°", "feedback": "The sign was dropped: 25 + 49 - 100 is NEGATIVE 26, and the minus is what makes the angle obtuse."}, {"text": "27.7°", "feedback": "The side OPPOSITE the wanted angle goes in the subtracted spot: 10² is subtracted, not 5²."}, {"text": "111.8°", "feedback": "Correct."}]'::jsonb, 3, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 26, 'Challenge',
 'In triangle ABC, b = 6, c = 8 and angle A = 120°. What is side a, to one decimal?',
 '[{"text": "7.2", "feedback": "cos 120° is NEGATIVE 0.5, so the correction term flips to PLUS 48. Using +0.5 shrinks the side."}, {"text": "10.0", "feedback": "The cosine term was dropped. Pythagoras only survives at exactly 90°."}, {"text": "12.2", "feedback": "Correct."}, {"text": "148.0", "feedback": "148 is a squared. Root it."}]'::jsonb, 2, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 27, 'Challenge',
 'A triangle has two known sides and the angle BETWEEN them, no right angle. Which tool finds the third side?',
 '[{"text": "The cosine law", "feedback": "Correct."}, {"text": "The Pythagorean theorem", "feedback": "Pythagoras is the 90° special case of a more general rule — its correction term has been deleted."}, {"text": "The sine law", "feedback": "The sine law needs a side paired with its OPPOSITE angle — the contained angle breaks that pairing."}, {"text": "SOH CAH TOA", "feedback": "The primary ratios need a right angle, and this triangle has none."}]'::jsonb, 0, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 28, 'Challenge',
 'In triangle ABC, angle A = 90°, and sin B = 0.6. What is cos C?',
 '[{"text": "0.8", "feedback": "That comes from a Pythagorean step the question never needed. Think about how angles B and C are related here."}, {"text": "Cannot be found without the sides", "feedback": "The complementary relationship answers it with no sides at all."}, {"text": "0.4", "feedback": "Complementary angles do not subtract ratios from 1. Look at which sides cos C actually compares."}, {"text": "0.6", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-angles'),

(10, 'MPM2D', 'Trigonometry', 6, 29, 'Challenge',
 'A 10 m ladder is safe up to 75° from the ground. What is the highest it can safely reach, to one decimal?',
 '[{"text": "37.3 m", "feedback": "tan is opposite over ADJACENT and can exceed the ladder length — impossible for a height the ladder itself reaches."}, {"text": "9.7 m", "feedback": "Correct."}, {"text": "2.6 m", "feedback": "cos 75° gives the ground distance, about 2.6 m. Height is opposite: sin."}, {"text": "10.0 m", "feedback": "Reaching the full 10 m needs the ladder vertical at 90° — past the safe limit."}]'::jsonb, 1, 'sub-trig-side-lengths'),

(10, 'MPM2D', 'Trigonometry', 6, 30, 'Challenge',
 'Two right triangles share an acute angle of 37°. One has hypotenuse 5, the other 15. How do their sin 37° values compare?',
 '[{"text": "The larger triangle has triple the sine", "feedback": "Sides scale together, so the RATIO cancels the scale factor. That is why sin 37° means anything at all."}, {"text": "They are identical — the ratio depends only on the angle", "feedback": "Correct."}, {"text": "The larger triangle has one third the sine", "feedback": "Enlarging a triangle does not shrink its ratios. Both compute opposite over hypotenuse identically."}, {"text": "They cannot be compared without the sides", "feedback": "Similarity guarantees the comparison: equal angles force equal ratios."}]'::jsonb, 1, 'sub-trig-ratios'),

(10, 'MPM2D', 'Trigonometry', 6, 31, 'Advanced',
 'From a point, the angle of elevation to the top of a tower is 30°. Moving 20 m closer, it is 45°. What is the height of the tower, to one decimal?',
 '[{"text": "12.7 m", "feedback": "The tangents SUBTRACT in the denominator: the two right triangles share the height but differ in base by 20."}, {"text": "11.5 m", "feedback": "20 tan 30° treats the 20 m as the FULL distance to the tower. It is only the gap between the two viewpoints."}, {"text": "27.3 m", "feedback": "Correct."}, {"text": "20.0 m", "feedback": "At 45° the height equals the remaining distance — which is the height itself, not the 20 m walked."}]'::jsonb, 2, 'sub-trig-side-lengths'),

(10, 'MPM2D', 'Trigonometry', 6, 32, 'Advanced',
 'In triangle ABC, angle A = 100°, a = 14 and angle B = 35°. What is b, to one decimal?',
 '[{"text": "0.6", "feedback": "That is the ratio of the two sines alone. The 14 still multiplies it."}, {"text": "24.0", "feedback": "The proportion is inverted — that value comes out LONGER than 14, impossible opposite a smaller angle."}, {"text": "10.1", "feedback": "45 is angle C, from the 180° sum — the wrong partner for side b. Side b pairs with angle B."}, {"text": "8.2", "feedback": "Correct."}]'::jsonb, 3, 'sub-sine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 33, 'Advanced',
 'A triangle has sides 8, 11 and 15. What is its SMALLEST angle, to one decimal?',
 '[{"text": "31.8°", "feedback": "That rounds the cosine ratio to two decimals before taking the inverse. Round only at the end."}, {"text": "45.6°", "feedback": "That angle faces the 11. Opposite the 8 means the 8² is the subtracted square."}, {"text": "31.3°", "feedback": "Correct."}, {"text": "103.1°", "feedback": "That is the angle opposite the 15 — the LARGEST angle. The smallest faces the shortest side, 8."}]'::jsonb, 2, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 34, 'Advanced',
 'Two roads leave a town at 50° to each other. Cars drive 40 km down one and 65 km down the other. How far apart are they, to one decimal?',
 '[{"text": "76.3 km", "feedback": "That is Pythagoras, which needs 90° between the roads. At 50° the cosine term stays."}, {"text": "20.0 km", "feedback": "Order of operations: cos 50° multiplies ONLY the 2ab term. Applying it to the whole bracket is the classic cosine law slip."}, {"text": "49.8 km", "feedback": "Correct."}, {"text": "105.0 km", "feedback": "40 + 65 lays the roads end to end. They fan out at an angle, so the gap is shorter."}]'::jsonb, 2, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 35, 'Advanced',
 'A triangle problem gives sides a and b and angle A, opposite side a. Which tool starts the solution?',
 '[{"text": "The cosine law, because two sides are known", "feedback": "Two sides feed the cosine law only WITH the contained angle. Angle A here is opposite a, which is a sine law pairing."}, {"text": "Neither — more information is needed", "feedback": "A matched pair plus one more side is exactly the sine law setup for finding angle B."}, {"text": "SOH CAH TOA", "feedback": "No right angle was given, so the primary ratios cannot apply."}, {"text": "The sine law, because a side-opposite-angle pair is known", "feedback": "Correct."}]'::jsonb, 3, 'sub-sine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 36, 'Advanced',
 'To measure a river, a surveyor makes a small right triangle with a 1 m base and matching angles to a large one across the river with a 40 m base. The small height is 0.7 m. How wide is the river?',
 '[{"text": "0.7 m", "feedback": "0.7 m is the small model. The river copies the RATIO, at 40 times the size."}, {"text": "28 m", "feedback": "Correct."}, {"text": "40.7 m", "feedback": "That ADDS a height to a base length. Similar shapes multiply by the scale factor instead."}, {"text": "57.1 m", "feedback": "That divides 40 by 0.7 — inverting the ratio. The scale factor 40 multiplies the small height."}]'::jsonb, 1, 'sub-similar-triangles'),

(10, 'MPM2D', 'Trigonometry', 6, 37, 'Advanced',
 'In a right triangle one acute angle is 45° and the hypotenuse is 12. What is each leg, to one decimal?',
 '[{"text": "12.0", "feedback": "Legs are always SHORTER than the hypotenuse."}, {"text": "6.0", "feedback": "Halving the hypotenuse works at 30°, not 45°. Each leg is 12 sin 45°, about 0.707 of it."}, {"text": "17.0", "feedback": "That divides 12 by sin 45° — but 12 is the hypotenuse, the side everything else divides INTO."}, {"text": "8.5", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-angles'),

(10, 'MPM2D', 'Trigonometry', 6, 38, 'Advanced',
 'A triangle has sides 6, 6 and 10. What is the angle between the two equal sides, to one decimal?',
 '[{"text": "146.4°", "feedback": "That is the supplement of a base angle. The apex is not what is left when a base angle is taken from 180."}, {"text": "112.9°", "feedback": "Correct."}, {"text": "33.6°", "feedback": "That is a BASE angle, opposite one of the 6 sides. The apex angle faces the 10."}, {"text": "60.0°", "feedback": "Equal sides do not force 60° — that needs all THREE sides equal."}]'::jsonb, 1, 'sub-cosine-law'),

(10, 'MPM2D', 'Trigonometry', 6, 39, 'Advanced',
 'Solving a triangle, a student computes sin B = 1.2. What does this mean?',
 '[{"text": "Angle B is obtuse", "feedback": "Obtuse angles still have sines BELOW 1. Past 1 is impossible, full stop."}, {"text": "No such triangle exists with the given measurements", "feedback": "Correct."}, {"text": "Angle B is 90°", "feedback": "sin 90° is exactly 1. Nothing pushes sine past 1."}, {"text": "The calculator must switch to radians", "feedback": "Radians change nothing here — sine never exceeds 1 in any mode."}]'::jsonb, 1, 'sub-trig-ratios'),

(10, 'MPM2D', 'Trigonometry', 6, 40, 'Advanced',
 'A kite is on a 50 m string at 62° to the horizontal, held 1.2 m above the ground. How high is the kite above the ground, to one decimal?',
 '[{"text": "24.7 m", "feedback": "cos 62° gives the horizontal reach. The vertical uses sin."}, {"text": "51.2 m", "feedback": "The string is the hypotenuse — the kite can never sit higher than string plus hand."}, {"text": "45.3 m", "feedback": "Correct."}, {"text": "44.1 m", "feedback": "The hand height ADDS: the trig gives height above the hand, and the hand is 1.2 m up."}]'::jsonb, 2, 'sub-trig-side-lengths');
