-- ===========================================================================
-- MTH1W — Unit 7: Geometry — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Angle relationships (parallel lines, polygons)
--   Lesson 2  Angles in triangles and circles
--   Lesson 3  Area and perimeter of composite shapes
--   Lesson 4  Pythagorean theorem
--   Lesson 5  3D geometry (surface area and volume)
--
-- Every configuration is described in words rather than drawn, so this unit
-- is answerable without figures. Where a diagram would normally carry the
-- information, the prompt states it: which angles are co-interior, which
-- side is the slant height, which piece is removed from the composite shape.
--
-- The distractors are the slips the worked solutions keep correcting:
-- treating co-interior angles as equal, halving instead of doubling at the
-- centre of a circle, adding the two legs instead of their squares, and
-- returning the surface area when the question asked for volume.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Geometry';

insert into misconception_labels (tag, label) values
  ('sub-angle-relationships',   'Angle relationships and polygons'),
  ('sub-triangle-circle-angles','Angles in triangles and circles'),
  ('sub-composite-shapes',      'Area and perimeter of composite shapes'),
  ('sub-pythagoras',            'Pythagorean theorem'),
  ('sub-3d-geometry',           'Surface area and volume')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 1, 'Easy',
 'Two angles are complementary. One of them measures 35 degrees. What is the other?',
 '[{"text": "145 degrees", "feedback": "That pair would be supplementary. Complementary angles add to a right angle."},
   {"text": "65 degrees", "feedback": "Check the subtraction. A right angle is 90 degrees."},
   {"text": "35 degrees", "feedback": "Two equal 35 degree angles do not add to a right angle."},
   {"text": "55 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 2, 'Easy',
 'What is the sum of the interior angles of an octagon?',
 '[{"text": "1440 degrees", "feedback": "The 2 was not subtracted from the number of sides before multiplying."},
   {"text": "1080 degrees", "feedback": "Correct."},
   {"text": "900 degrees", "feedback": "That is the sum for a seven-sided polygon. An octagon has eight sides."},
   {"text": "360 degrees", "feedback": "That is the sum of the EXTERIOR angles, which is the same for every polygon."}]'::jsonb,
 1, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 3, 'Easy',
 'Two angles of a triangle each measure 70 degrees. What is the third angle?',
 '[{"text": "60 degrees", "feedback": "That would make the triangle equilateral, but two of these angles are 70."},
   {"text": "40 degrees", "feedback": "Correct."},
   {"text": "20 degrees", "feedback": "The angles of a triangle add to 180 degrees, not 160."},
   {"text": "140 degrees", "feedback": "That is the sum of the two given angles, not what is left over."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 4, 'Easy',
 'An angle is inscribed in a semicircle. What does it measure?',
 '[{"text": "It depends where the point sits on the arc", "feedback": "Every point on the arc gives the same inscribed angle here."},
   {"text": "90 degrees, a right angle wherever the point sits", "feedback": "Correct."},
   {"text": "180 degrees", "feedback": "That is the arc of the semicircle itself. The inscribed angle is half of it."},
   {"text": "45 degrees", "feedback": "That would be half of a right angle. An inscribed angle is half the angle at the centre."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 5, 'Easy',
 'What is the area of a rectangle measuring 2.4 m by 3.8 m?',
 '[{"text": "4.56 square metres", "feedback": "That halves the product, which is the rule for a triangle rather than a rectangle."},
   {"text": "9.12 square metres", "feedback": "Correct."},
   {"text": "12.4 square metres", "feedback": "That is the perimeter, and it is measured in metres rather than square metres."},
   {"text": "6.2 square metres", "feedback": "The two side lengths were added. Area multiplies them."}]'::jsonb,
 1, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 6, 'Easy',
 'Which formula gives the area of a circle?',
 '[{"text": "2 x pi x r^2", "feedback": "That is twice the area. There is no 2 in the area formula for a circle."},
   {"text": "2 x pi x r", "feedback": "That is the circumference, which is a distance rather than an area."},
   {"text": "pi x r^2", "feedback": "Correct."},
   {"text": "pi x d", "feedback": "That is the circumference written using the diameter."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 7, 'Easy',
 'A right triangle has legs of 3 units and 7 units. What is the hypotenuse, to the nearest tenth?',
 '[{"text": "58.0 units", "feedback": "That is the sum of the squares. There is still a square root to take."},
   {"text": "6.3 units", "feedback": "The squares were subtracted rather than added. Subtraction is for finding a leg."},
   {"text": "10.0 units", "feedback": "The two legs were added. It is their SQUARES that add."},
   {"text": "7.6 units", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 8, 'Easy',
 'In the Pythagorean theorem a^2 + b^2 = c^2, what does c represent?',
 '[{"text": "Either of the two shorter sides", "feedback": "Those are a and b, the legs that form the right angle."},
   {"text": "The side that forms the right angle with a", "feedback": "That describes the other leg. The right angle is formed by a and b."},
   {"text": "The perimeter of the triangle", "feedback": "The theorem relates side lengths to each other, not to the distance around."},
   {"text": "The hypotenuse, the longest side, opposite the right angle", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 9, 'Easy',
 'What is the volume of a rectangular prism measuring 17 m by 4 m by 10 m?',
 '[{"text": "31 cubic metres", "feedback": "The three dimensions were added. Volume multiplies them."},
   {"text": "68 cubic metres", "feedback": "Only two of the three dimensions were multiplied."},
   {"text": "680 cubic metres", "feedback": "Correct."},
   {"text": "556 cubic metres", "feedback": "That is the surface area of this prism, which is measured in square metres."}]'::jsonb,
 2, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 10, 'Easy',
 'Which formula gives the volume of a sphere?',
 '[{"text": "(4/3) x pi x r^3", "feedback": "Correct."},
   {"text": "(1/3) x pi x r^2 x h", "feedback": "That is the volume of a cone."},
   {"text": "4 x pi x r^2", "feedback": "That is the surface area of a sphere, which is measured in square units."},
   {"text": "pi x r^2 x h", "feedback": "That is the volume of a cylinder. A sphere has no height to measure."}]'::jsonb,
 0, 'sub-3d-geometry'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 11, 'Medium',
 'Two parallel lines are cut by a transversal. One of a pair of co-interior angles measures 65 degrees. What is the other?',
 '[{"text": "115 degrees", "feedback": "Correct."},
   {"text": "25 degrees", "feedback": "That pair would be complementary. Co-interior angles add to 180 degrees."},
   {"text": "295 degrees", "feedback": "The 65 was subtracted from a full turn. Co-interior angles add to a straight line."},
   {"text": "65 degrees", "feedback": "Alternate interior and corresponding angles are equal. Co-interior angles are the pair that add to a straight line."}]'::jsonb,
 0, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 12, 'Medium',
 'A regular polygon has interior angles of 140 degrees each. How many sides does it have?',
 '[{"text": "10", "feedback": "A ten-sided polygon has interior angles of 144 degrees, which is slightly too large."},
   {"text": "9", "feedback": "Correct."},
   {"text": "8", "feedback": "An octagon has interior angles of 135 degrees. This polygon needs slightly larger ones."},
   {"text": "7", "feedback": "A seven-sided polygon has interior angles under 130 degrees."}]'::jsonb,
 1, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 13, 'Medium',
 'An isosceles triangle has an apex angle of 100 degrees. What does each base angle measure?',
 '[{"text": "100 degrees", "feedback": "Three angles of 100 degrees would add to far more than a triangle allows."},
   {"text": "80 degrees", "feedback": "That is what the two base angles add to. They still have to be shared between the two of them."},
   {"text": "50 degrees", "feedback": "The 100 was halved. It is the REMAINING 80 degrees that gets shared."},
   {"text": "40 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 14, 'Medium',
 'An arc subtends an angle of 35 degrees at a point on the circumference. What angle does the same arc subtend at the centre?',
 '[{"text": "145 degrees", "feedback": "That subtracts from 180. The relationship here is a doubling."},
   {"text": "17.5 degrees", "feedback": "That halves it. The angle at the CENTRE is the larger of the two."},
   {"text": "35 degrees", "feedback": "Equal angles come from two points on the circumference. The centre is different."},
   {"text": "70 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 15, 'Medium',
 'A composite figure is made of a rectangle measuring 2.4 m by 3.8 m together with a full circle of radius 1.2 m. What is the total area, to the nearest hundredth?',
 '[{"text": "9.12 square metres", "feedback": "That is the rectangle on its own. The circle still has to be added."},
   {"text": "4.52 square metres", "feedback": "That is the circle on its own. The rectangle still has to be added."},
   {"text": "13.64 square metres", "feedback": "Correct."},
   {"text": "11.38 square metres", "feedback": "Only half the circle was counted. The question gives a full circle."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 16, 'Medium',
 'What is the area of a triangle with a base of 3.2 m and a height of 3.8 m?',
 '[{"text": "3.04 square metres", "feedback": "The halving was done twice."},
   {"text": "12.16 square metres", "feedback": "The half was left out. That product is the area of a rectangle with those dimensions."},
   {"text": "6.08 square metres", "feedback": "Correct."},
   {"text": "7.00 square metres", "feedback": "The base and height were added. Area multiplies them and then halves."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 17, 'Medium',
 'A right triangle has a hypotenuse of 11 units and one leg of 3.9 units. What is the other leg, to the nearest tenth?',
 '[{"text": "105.8 units", "feedback": "That is the difference of the squares. There is still a square root to take."},
   {"text": "11.7 units", "feedback": "The squares were added. When you know the hypotenuse, you subtract."},
   {"text": "7.1 units", "feedback": "The two side lengths were subtracted directly. It is their SQUARES that subtract."},
   {"text": "10.3 units", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 18, 'Medium',
 'A television screen measures 30 inches by 22.5 inches. What is the length of its diagonal?',
 '[{"text": "1406.25 inches", "feedback": "That is the sum of the squares. There is still a square root to take."},
   {"text": "52.5 inches", "feedback": "The two sides were added. It is their squares that add, before a square root is taken."},
   {"text": "37.5 inches", "feedback": "Correct."},
   {"text": "26.25 inches", "feedback": "That is the average of the two sides. The diagonal is longer than either of them."}]'::jsonb,
 2, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 19, 'Medium',
 'A sphere has a diameter of 12 cm. What is its volume, to the nearest hundredth?',
 '[{"text": "7238.23 cubic centimetres", "feedback": "The diameter was used in place of the radius. Halve it first."},
   {"text": "904.78 cubic centimetres", "feedback": "Correct."},
   {"text": "226.19 cubic centimetres", "feedback": "That is the volume of a CONE with this radius and height. A sphere is four times as large."},
   {"text": "452.39 cubic centimetres", "feedback": "That is the surface area of this sphere, which is measured in square centimetres."}]'::jsonb,
 1, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 20, 'Medium',
 'What is the surface area of a rectangular prism measuring 17 m by 4 m by 10 m?',
 '[{"text": "556 square metres", "feedback": "Correct."},
   {"text": "680 square metres", "feedback": "That is the volume of this prism, which is measured in cubic metres."},
   {"text": "278 square metres", "feedback": "The three face areas were added but never doubled. Every face has a matching one opposite it."},
   {"text": "62 square metres", "feedback": "The three dimensions were added and doubled. Each face is a product of two dimensions."}]'::jsonb,
 0, 'sub-3d-geometry'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 21, 'Challenge',
 'The interior angles of a pentagon measure 110, 138, 100, x and 2x degrees. What is x?',
 '[{"text": "124", "feedback": "That uses a total of 720, which belongs to a six-sided polygon."},
   {"text": "48", "feedback": "That uses a total of 540 but treats the last two angles as x and x rather than x and 2x."},
   {"text": "64", "feedback": "Correct."},
   {"text": "128", "feedback": "That is the value of the LARGER unknown angle. The question asks for x itself."}]'::jsonb,
 2, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 22, 'Challenge',
 'Each exterior angle of a regular polygon measures 24 degrees. How many sides does it have?',
 '[{"text": "15 sides", "feedback": "Correct."},
   {"text": "8 sides", "feedback": "That comes from dividing 180 by 24 and rounding. The exterior angles add to 360."},
   {"text": "24 sides", "feedback": "That copies the angle straight across. Divide a full turn by the angle instead."},
   {"text": "30 sides", "feedback": "Each vertex was counted as having two exterior angles, so 720 was divided by 24 instead of one full turn."}]'::jsonb,
 0, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 23, 'Challenge',
 'An exterior angle of a triangle measures 120 degrees. One of the two opposite interior angles is 45 degrees. What is the other?',
 '[{"text": "15 degrees", "feedback": "Check the subtraction. The exterior angle is 120, not 60."},
   {"text": "75 degrees", "feedback": "Correct."},
   {"text": "60 degrees", "feedback": "That is the interior angle beside the exterior one, taken as 180 minus 120. It is not one of the two opposite interior angles."},
   {"text": "165 degrees", "feedback": "The two were added. The exterior angle EQUALS their sum, so one subtracts from it."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 24, 'Challenge',
 'The three angles of a triangle measure 2x, 3x + 10 and 4x - 1 degrees. What is x?',
 '[{"text": "x = 19", "feedback": "Correct."},
   {"text": "x = 20", "feedback": "The two constants were dropped before dividing. The +10 and the -1 have to be dealt with first."},
   {"text": "x = 21", "feedback": "The constants were added to the 180 instead of being taken off it."},
   {"text": "x = 39", "feedback": "A total of 360 was used. The interior angles of a TRIANGLE add to 180."}]'::jsonb,
 0, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 25, 'Challenge',
 'A rectangle measures 5 m by 2 m. A semicircle of diameter 2 m is cut out of one of the short ends. What area remains, to the nearest hundredth?',
 '[{"text": "10.00 square metres", "feedback": "That is the whole rectangle. The cut-out still has to be taken off."},
   {"text": "6.86 square metres", "feedback": "A full circle was removed. Only half of one is cut out here."},
   {"text": "8.43 square metres", "feedback": "Correct."},
   {"text": "11.57 square metres", "feedback": "The semicircle was added rather than removed."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 26, 'Challenge',
 'A rectangle measures 10 m by 3 m. A semicircle of diameter 3 m is attached to one of the short ends. What is the perimeter of the composite shape, to the nearest hundredth?',
 '[{"text": "27.71 metres", "feedback": "Correct."},
   {"text": "30.71 metres", "feedback": "The 3 m end was counted as well as the arc. Once the semicircle is attached, that edge is inside the shape."},
   {"text": "26.00 metres", "feedback": "That is the rectangle on its own. One straight edge is replaced by a curved one."},
   {"text": "32.42 metres", "feedback": "The whole circumference of the circle was used. Only half of it forms the outside edge."}]'::jsonb,
 0, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 27, 'Challenge',
 'An isosceles triangle has two equal sides of 7 units and a base of 10 units. What is its area, to the nearest hundredth?',
 '[{"text": "24.49 square units", "feedback": "Correct."},
   {"text": "48.99 square units", "feedback": "The height is right, but the halving was left out."},
   {"text": "12.50 square units", "feedback": "Half the base was used as the height as well as the base."},
   {"text": "35.00 square units", "feedback": "The equal side was used as the height. The height is the perpendicular drop to the base, which is shorter."}]'::jsonb,
 0, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 28, 'Challenge',
 'Zeke drives 64 km east and then 135 km north. A new expressway runs in a straight line between his start and finish. How much travel distance does the expressway save, to the nearest tenth?',
 '[{"text": "49.6 km", "feedback": "Correct."},
   {"text": "71.0 km", "feedback": "The two distances were subtracted from each other. Find the straight-line route first."},
   {"text": "149.4 km", "feedback": "That is the length of the expressway itself. The saving is what is left of the old route."},
   {"text": "199.0 km", "feedback": "That is the old route. The expressway still has to be subtracted from it."}]'::jsonb,
 0, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 29, 'Challenge',
 'A cone has a radius of 8 cm and a slant height of 17.9 cm. What is its vertical height, to the nearest tenth?',
 '[{"text": "9.9 cm", "feedback": "The radius was subtracted from the slant height directly. It is their SQUARES that subtract."},
   {"text": "19.6 cm", "feedback": "The squares were added. The slant height is the hypotenuse here, so you subtract."},
   {"text": "25.9 cm", "feedback": "The two lengths were added. The height is shorter than the slant height."},
   {"text": "16.0 cm", "feedback": "Correct."}]'::jsonb,
 3, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 30, 'Challenge',
 'A cylinder has a diameter of 20 m and a height of 13 m. What is its volume, to the nearest hundredth?',
 '[{"text": "1445.13 cubic metres", "feedback": "That is the surface area of this cylinder, which is measured in square metres."},
   {"text": "314.16 cubic metres", "feedback": "The height was left out of the calculation."},
   {"text": "16336.28 cubic metres", "feedback": "The diameter was used in place of the radius. Halve it first."},
   {"text": "4084.07 cubic metres", "feedback": "Correct."}]'::jsonb,
 3, 'sub-3d-geometry'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Geometry', 7, 31, 'Advanced',
 'Two parallel lines are cut by a transversal. An angle of 125 degrees is corresponding to angle z, and angle y sits on a straight line with z. What is y?',
 '[{"text": "125 degrees", "feedback": "That is the value of z itself. Angle y is the one that completes the straight line with it."},
   {"text": "55 degrees", "feedback": "Correct."},
   {"text": "35 degrees", "feedback": "That subtracts from 90. Angles on a straight line add to 180."},
   {"text": "235 degrees", "feedback": "That subtracts from a full turn. Angles on a straight line add to 180."}]'::jsonb,
 1, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 32, 'Advanced',
 'In a regular polygon each interior angle is three times its exterior angle. How many sides does the polygon have?',
 '[{"text": "12 sides", "feedback": "That polygon has interior angles of 150 and exterior angles of 30, a ratio of five to one."},
   {"text": "4 sides", "feedback": "A square has interior angles of 90 and exterior angles of 90, a ratio of one to one."},
   {"text": "8 sides", "feedback": "Correct."},
   {"text": "6 sides", "feedback": "A hexagon has interior angles of 120 and exterior angles of 60, which is a ratio of two to one."}]'::jsonb,
 2, 'sub-angle-relationships'),

(9, 'MTH1W', 'Geometry', 7, 33, 'Advanced',
 'The three angles of a triangle are in the ratio 2 to 3 to 4. What is the largest angle?',
 '[{"text": "60 degrees", "feedback": "That is the middle share of the three."},
   {"text": "90 degrees", "feedback": "That assumes the triangle is right-angled. Share 180 out in the given ratio instead."},
   {"text": "40 degrees", "feedback": "That is the SMALLEST of the three shares. The question asks for the largest."},
   {"text": "80 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 34, 'Advanced',
 'Two inscribed angles in a circle are subtended by the same arc. One measures 3x degrees and the other measures x + 40 degrees. What is x?',
 '[{"text": "x = -20", "feedback": "The 40 was moved across without changing sign."},
   {"text": "x = 20", "feedback": "Correct."},
   {"text": "x = 10", "feedback": "The two expressions were added and set equal to 40 rather than being set equal to each other."},
   {"text": "x = 35", "feedback": "The two were treated as supplementary. Inscribed angles on the same arc are EQUAL."}]'::jsonb,
 1, 'sub-triangle-circle-angles'),

(9, 'MTH1W', 'Geometry', 7, 35, 'Advanced',
 'A square of side 8 cm has a quarter circle of radius 8 cm removed from one corner. What area remains, to the nearest hundredth?',
 '[{"text": "13.73 square centimetres", "feedback": "Correct."},
   {"text": "51.43 square centimetres", "feedback": "A quarter of the CIRCUMFERENCE was subtracted. What is removed is an area."},
   {"text": "50.27 square centimetres", "feedback": "That is the piece that was removed, not what is left behind."},
   {"text": "64.00 square centimetres", "feedback": "That is the whole square. The quarter circle still has to be taken off."}]'::jsonb,
 0, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 36, 'Advanced',
 'A running track encloses a rectangle 50 m by 30 m with a semicircle of diameter 30 m at each end. What is the total enclosed area, to the nearest hundredth?',
 '[{"text": "1853.43 square metres", "feedback": "Only one of the two semicircular ends was counted."},
   {"text": "1500.00 square metres", "feedback": "That is the rectangle on its own. The two semicircular ends still have to be added."},
   {"text": "2206.86 square metres", "feedback": "Correct."},
   {"text": "2913.72 square metres", "feedback": "Two FULL circles were added. Each end is only half a circle."}]'::jsonb,
 2, 'sub-composite-shapes'),

(9, 'MTH1W', 'Geometry', 7, 37, 'Advanced',
 'A 5 m ladder leans against a wall with its foot 1.4 m from the base of the wall. How far up the wall does it reach, to the nearest tenth?',
 '[{"text": "6.4 m", "feedback": "The two lengths were added. The wall height is shorter than the ladder."},
   {"text": "3.6 m", "feedback": "The two lengths were subtracted directly. It is their SQUARES that subtract."},
   {"text": "5.2 m", "feedback": "The squares were added. The ladder is the hypotenuse here, so you subtract."},
   {"text": "4.8 m", "feedback": "Correct."}]'::jsonb,
 3, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 38, 'Advanced',
 'Is a triangle with sides of 9, 40 and 41 units right-angled?',
 '[{"text": "No, because the three numbers are not consecutive", "feedback": "The numbers do not have to follow any pattern. Test them in the theorem."},
   {"text": "No, because 9 plus 40 does not equal 41", "feedback": "The theorem adds the SQUARES of the two shorter sides, not the sides themselves."},
   {"text": "Yes, because 9 squared plus 40 squared equals 41 squared", "feedback": "Correct."},
   {"text": "Yes, because all three sides are different", "feedback": "That describes a scalene triangle, which need not have a right angle."}]'::jsonb,
 2, 'sub-pythagoras'),

(9, 'MTH1W', 'Geometry', 7, 39, 'Advanced',
 'A baseball has a surface area of 215 square centimetres. What is its radius, to the nearest tenth?',
 '[{"text": "5.8 cm", "feedback": "A 2 was used where the formula needs a 4. The surface area of a sphere is four pi r squared."},
   {"text": "4.1 cm", "feedback": "Correct."},
   {"text": "17.1 cm", "feedback": "That is the value of r squared. There is still a square root to take."},
   {"text": "8.3 cm", "feedback": "That is the diameter. The question asks for the radius."}]'::jsonb,
 1, 'sub-3d-geometry'),

(9, 'MTH1W', 'Geometry', 7, 40, 'Advanced',
 'A rectangular prism measures 5 cm by 2 cm by 3 cm. Both its length and its height are doubled. What happens to its volume?',
 '[{"text": "It is multiplied by 4", "feedback": "Correct."},
   {"text": "It stays the same", "feedback": "Volume depends on all three dimensions, so changing any of them changes it."},
   {"text": "It is doubled", "feedback": "Only one dimension doubling would double it. Two of them changed here."},
   {"text": "It is multiplied by 8", "feedback": "That is what happens when all THREE dimensions double. The width is unchanged."}]'::jsonb,
 0, 'sub-3d-geometry');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Geometry'
group by difficulty order by min(sort_order);
