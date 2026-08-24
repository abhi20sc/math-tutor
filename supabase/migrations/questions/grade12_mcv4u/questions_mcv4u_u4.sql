-- ===========================================================================
-- MCV4U — Unit 4: Geometric Vectors — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Introduction to vectors
--   Lesson 2  Vector addition
--   Lesson 3  Scalar multiplication of vectors
--   Lesson 4  Force, velocity and tension
--   Lesson 5  Resolution of vectors into rectangular components
--
-- Five lessons, six subtopics. Lesson 4 is split into FORCES and VELOCITIES
-- because they fail differently. A force question is lost to the geometry of
-- the triangle; a velocity question is lost to the direction convention,
-- when a student reports a bearing measured from the wrong reference line.
-- Two separate traffic lights say which of those it is.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Four repeat right through the unit:
--
--   * swapping sine and cosine when resolving, which puts the component
--     next to the wrong side of the right triangle
--   * adding magnitudes instead of adding vectors, which is only correct
--     when the two point the same way
--   * measuring a bearing from the wrong line, or in the wrong rotational
--     direction
--   * giving the resultant when the equilibrant was asked for, or the other
--     way round
--
-- Feedback names the mistake and stops there.
--
-- Every magnitude, bearing, component and tension in this file was
-- recomputed independently before delivery; nothing was copied from the
-- source PDFs.
--
-- FIGURES: four, the most of any unit in this bank, and this is the unit
-- that earns them. A vector diagram is not decoration here; the arrangement
-- of the arrows IS the question.
--
--   * Q6 shows a force resolved into components, with no numbers at all,
--     and asks which of sine or cosine gives the horizontal one. The answer
--     is which side sits next to the marked angle.
--   * Q13 shows three vectors closing a triangle head to tail and asks
--     which equation the diagram states. Settled by the arrowheads alone.
--   * Q27 shows a mass on two ropes. RULER TEST: the ropes are labelled 60
--     and 45 degrees but drawn at about 42 and 62, so a student who
--     measures them computes about 95 N, whose nearest option is 98.0 and
--     is wrong.
--   * Q39 shows a box on a ramp. RULER TEST: the ramp is labelled 20
--     degrees and drawn at about 35, so a student who measures it computes
--     about 80 N, whose nearest option is 51.0 and is wrong.
--
-- Both ruler tests are registered in tools/make_figures.py and the script
-- refuses to write either PNG if the measured value ever drifts nearest to
-- the correct option.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file must come last, and must be re-run after any re-run of
-- this one: the delete at the top wipes the figure column with the rest of
-- the row. Student attempts (keyed on course, unit and sort_order) survive
-- the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCV4U' and unit = 'Geometric Vectors';

insert into misconception_labels (tag, label) values
  ('sub-vector-basics',         'What a vector is, and how direction is written'),
  ('sub-vector-addition',       'Adding and subtracting vectors'),
  ('sub-scalar-multiplication', 'Scalar multiplication of vectors'),
  ('sub-resultant-forces',      'Resultant and equilibrant forces'),
  ('sub-velocity-problems',     'Resultant velocity problems'),
  ('sub-vector-components',     'Resolving a vector into components')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the vocabulary, the conventions, and one right triangle.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 1, 'Easy',
 'Which of these is a vector quantity?',
 '[{"text": "10 kg", "feedback": "Mass has size but no direction, so it is a scalar."},
   {"text": "-5 degrees C", "feedback": "The minus sign is part of the temperature scale, not a direction in space. Temperature is a scalar."},
   {"text": "80 km/h west", "feedback": "Correct."},
   {"text": "100 km/h", "feedback": "That is a speed, which is magnitude only. Adding a direction to it would turn it into a velocity."}]'::jsonb,
 2, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 2, 'Easy',
 'A true bearing is measured from which line, and in which rotational direction?',
 '[{"text": "From north, turning clockwise", "feedback": "Correct."},
   {"text": "From north, turning counter-clockwise", "feedback": "The reference line is right but the rotation is not. A compass runs the other way, so a bearing of 090 is east."},
   {"text": "From east, turning clockwise", "feedback": "The rotation is right but the reference line is not. A bearing of zero points north."},
   {"text": "From the horizontal, turning counter-clockwise", "feedback": "That is the OTHER convention, the one used for an angle to the horizontal. A bearing uses the compass."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 3, 'Easy',
 'For any three points A, B and C, what does the vector AB plus the vector BC equal?',
 '[{"text": "The vector CA", "feedback": "The direction is reversed. Head to tail addition starts where the first vector starts and finishes where the second one finishes."},
   {"text": "The vector AB", "feedback": "That is only the first of the two. The second one moves you further along."},
   {"text": "The vector BA", "feedback": "That is the first one reversed. Adding does not send you back where you came from."},
   {"text": "The vector AC", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 4, 'Easy',
 'The vector AB with a minus sign in front of it can also be written how?',
 '[{"text": "AB", "feedback": "The minus sign has to do something. Reversing a vector swaps its start and its finish."},
   {"text": "The magnitude of AB", "feedback": "A magnitude is a number with no direction at all, and it is never negative."},
   {"text": "A plus B", "feedback": "A and B are points, not vectors, so they cannot be added."},
   {"text": "BA", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 5, 'Easy',
 'A vector v has magnitude 6. What is the magnitude of 3v?',
 '[{"text": "9", "feedback": "The 3 was added rather than multiplied."},
   {"text": "2", "feedback": "The magnitude was divided by the scalar. Multiplying by a number bigger than 1 lengthens a vector."},
   {"text": "18", "feedback": "Correct."},
   {"text": "6", "feedback": "The scalar was applied to the direction only. Multiplying by 3 makes the vector three times as long."}]'::jsonb,
 2, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 6, 'Easy',
 E'The diagram shows a force f resolved into its horizontal and vertical components, with the angle marked at the tail.\nWhich expression gives the magnitude of the HORIZONTAL component?',
 '[{"text": "The magnitude of f times sin of the angle", "feedback": "That gives the VERTICAL component. Sine reaches the side across from the marked angle, not the one beside it."},
   {"text": "The magnitude of f times tan of the angle", "feedback": "Tangent compares the two components with each other. Neither of them is the hypotenuse, which is what f is here."},
   {"text": "The magnitude of f divided by cos of the angle", "feedback": "That would make the component LONGER than the force itself, which no component of a right triangle can be."},
   {"text": "The magnitude of f times cos of the angle", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 7, 'Easy',
 E'Kayla pulls a sleigh with a force of 200 N along a rope at 20 degrees to the horizontal.\nWhat is the forward component of that force, to one decimal place?',
 '[{"text": "212.8 N", "feedback": "The cosine ended up underneath. A component can never be larger than the force it came from."},
   {"text": "187.9 N", "feedback": "Correct."},
   {"text": "68.4 N", "feedback": "That is the component that lifts the sleigh. Sine reaches the vertical side; the forward one sits beside the angle."},
   {"text": "200.0 N", "feedback": "That is the whole force along the rope. Only part of it acts in the forward direction."}]'::jsonb,
 1, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 8, 'Easy',
 'What is the equilibrant of a system of forces?',
 '[{"text": "The sum of all the forces acting", "feedback": "That is the RESULTANT. The equilibrant is what you would add to it to reach zero."},
   {"text": "The largest of the forces acting", "feedback": "The size of any one force is beside the point. The equilibrant balances the whole system at once."},
   {"text": "A force equal in magnitude to the resultant and opposite in direction", "feedback": "Correct."},
   {"text": "A force equal to the resultant, in the same direction", "feedback": "That would double the push rather than cancel it. The equilibrant has to oppose."}]'::jsonb,
 2, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 9, 'Easy',
 'Two perpendicular forces of 3 N and 4 N act at the same point. What is the magnitude of the resultant?',
 '[{"text": "1 N", "feedback": "The magnitudes were subtracted. That only works when the two forces point in opposite directions."},
   {"text": "12 N", "feedback": "The magnitudes were multiplied. Vector addition uses the Pythagorean theorem when the two are perpendicular."},
   {"text": "5 N", "feedback": "Correct."},
   {"text": "7 N", "feedback": "The magnitudes were added. That only works when the two forces point in the same direction, and these are at right angles."}]'::jsonb,
 2, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 10, 'Easy',
 'For an aircraft, the air velocity added to the wind velocity gives which quantity?',
 '[{"text": "The wind speed", "feedback": "That is the magnitude of the second of the two, on its own."},
   {"text": "Zero", "feedback": "The two would have to be equal and opposite for that, which would leave the plane hovering."},
   {"text": "The ground velocity", "feedback": "Correct."},
   {"text": "The airspeed", "feedback": "That is the magnitude of the FIRST of the two, before the wind has been taken into account."}]'::jsonb,
 2, 'sub-velocity-problems'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): a bearing conversion, or one resultant built properly.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 11, 'Medium',
 'Write the true bearing 150 degrees as a quadrant bearing.',
 '[{"text": "S30E", "feedback": "Correct."},
   {"text": "N30E", "feedback": "The wrong end of the north-south line was used. A bearing of 150 has already swung past east and into the southern half."},
   {"text": "S30W", "feedback": "The direction is on the wrong side. Turning clockwise from north by 150 degrees ends up east of south."},
   {"text": "N150E", "feedback": "A quadrant bearing has to be between 0 and 90 degrees. This one has to be measured back from the nearer axis."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 12, 'Medium',
 'Write the quadrant bearing N50W as a true bearing.',
 '[{"text": "050 degrees", "feedback": "The turn was made clockwise from north. The W says to turn the other way, which lands in the last quarter of the compass."},
   {"text": "230 degrees", "feedback": "The measurement was made from SOUTH rather than north. The letter in front tells you which axis to start at."},
   {"text": "130 degrees", "feedback": "The angle was subtracted from 180. A true bearing is measured clockwise from north all the way round."},
   {"text": "310 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 13, 'Medium',
 E'The diagram shows three vectors u, v and w drawn on the triangle ABC.\nWhich equation does the diagram state?',
 '[{"text": "u = v + w", "feedback": "That would need v and w to run head to tail from A to B, and they do not. Follow the arrows from A."},
   {"text": "u + v + w = 0", "feedback": "That is what you get when all three run head to tail in a closed loop. Here w runs the other way, from A rather than back to it."},
   {"text": "w = u + v", "feedback": "Correct."},
   {"text": "w = u - v", "feedback": "Subtraction would need one of the arrowheads reversed. Both u and v run head to tail in the same sense around the triangle."}]'::jsonb,
 2, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 14, 'Medium',
 'Two vectors have the same magnitude and point in opposite directions. What is their sum?',
 '[{"text": "A vector of twice the magnitude", "feedback": "That is what happens when they point the SAME way. Opposite directions cancel instead."},
   {"text": "A vector with the same magnitude as either one", "feedback": "Nothing is left over. Placed head to tail they return you exactly to where you started."},
   {"text": "A vector at right angles to both", "feedback": "Adding two vectors keeps you on the line or in the plane they span; it does not create a new direction here."},
   {"text": "The zero vector", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 15, 'Medium',
 'If u = 2v, what is the relationship between u and v?',
 '[{"text": "They are parallel, and u is twice as long in the same direction", "feedback": "Correct."},
   {"text": "They are parallel, and u is twice as long in the opposite direction", "feedback": "The scalar is positive, so the direction is preserved. A negative scalar is what reverses it."},
   {"text": "They are perpendicular", "feedback": "A scalar multiple never changes the line a vector lies along, so the two cannot be at right angles."},
   {"text": "They have the same magnitude", "feedback": "The 2 does exactly what it looks like: it doubles the length."}]'::jsonb,
 0, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 16, 'Medium',
 E'A clown of mass 80 kg is fired horizontally with a force of 2000 N, while gravity pulls him down with a force of 784 N.\nWhat is the magnitude of the resultant force, to one decimal place?',
 '[{"text": "2784.0 N", "feedback": "The two magnitudes were added. That only works when the forces point the same way, and these are at right angles."},
   {"text": "1216.0 N", "feedback": "The two magnitudes were subtracted. That only works when the forces point in opposite directions."},
   {"text": "2000.0 N", "feedback": "Only the horizontal force was reported. Gravity pulls the resultant off the horizontal and makes it longer."},
   {"text": "2148.2 N", "feedback": "Correct."}]'::jsonb,
 3, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 17, 'Medium',
 E'The resultant force on the clown has magnitude 2148.2 N.\nWhat is the equilibrant force?',
 '[{"text": "2148.2 N, directed opposite to the resultant", "feedback": "Correct."},
   {"text": "2148.2 N, in the same direction as the resultant", "feedback": "The magnitude is right but that would push him harder rather than hold him still."},
   {"text": "784 N, directed upward", "feedback": "That balances gravity alone. The horizontal force still has to be opposed as well."},
   {"text": "0 N, because the forces already balance", "feedback": "They do not balance: the resultant is over 2000 N. The equilibrant is what would have to be added to make it zero."}]'::jsonb,
 0, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 18, 'Medium',
 E'A sailboat travels 8 km east and 6 km north.\nWhat is the magnitude and true bearing of the resultant displacement?',
 '[{"text": "14 km at a bearing of 053 degrees", "feedback": "The bearing is right but the two distances were added. They are at right angles, so the Pythagorean theorem applies."},
   {"text": "10 km at a bearing of 143 degrees", "feedback": "The rotation went the wrong way past east. The boat ends up north AND east of where it started, so the bearing is less than 090."},
   {"text": "10 km at a bearing of 053 degrees", "feedback": "Correct."},
   {"text": "10 km at a bearing of 037 degrees", "feedback": "The magnitude is right but the angle was measured from EAST rather than from north. A bearing starts at north and turns clockwise."}]'::jsonb,
 2, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 19, 'Medium',
 E'A tow truck pulls a car with a cable tension of 15000 N at 40 degrees to the horizontal.\nWhat is the vertical component, to the nearest newton?',
 '[{"text": "12586 N", "feedback": "Tangent was used instead of sine. Tangent compares the two components with each other, not either one with the cable."},
   {"text": "9642 N", "feedback": "Correct."},
   {"text": "11491 N", "feedback": "That is the HORIZONTAL component. Cosine reaches the side beside the angle; the vertical one is across from it."},
   {"text": "15000 N", "feedback": "That is the whole tension along the cable. Only part of it acts vertically."}]'::jsonb,
 1, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 20, 'Medium',
 E'Kayla pulls a sleigh with 200 N along a rope at 20 degrees to the horizontal.\nWhat is the component that tends to LIFT the sleigh, to one decimal place?',
 '[{"text": "68.4 N", "feedback": "Correct."},
   {"text": "187.9 N", "feedback": "That is the forward component. Cosine reaches the side beside the angle; the lifting one is across from it."},
   {"text": "72.8 N", "feedback": "Tangent was used instead of sine. Tangent compares the two components with each other, not either one with the rope."},
   {"text": "200.0 N", "feedback": "That is the whole force along the rope. Only part of it acts upward."}]'::jsonb,
 0, 'sub-vector-components'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): a cosine law, a wind triangle, and a hanging mass.
-- Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 21, 'Challenge',
 'Which statement about the vectors AB and BA is correct?',
 '[{"text": "They have equal magnitude but opposite direction, so they are not equal vectors", "feedback": "Correct."},
   {"text": "They are equal vectors, because they join the same two points", "feedback": "Joining the same points is not enough. A vector carries a direction, and these two run opposite ways along the segment."},
   {"text": "They have equal magnitude and the same direction", "feedback": "Reversing the letters reverses the arrow. The lengths match but the directions do not."},
   {"text": "They have different magnitudes", "feedback": "The distance from A to B is the same as from B to A, so the magnitudes are identical. It is the direction that differs."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 22, 'Challenge',
 'Two vectors are EQUIVALENT when which condition holds?',
 '[{"text": "They have the same direction", "feedback": "Same direction with different lengths makes them PARALLEL, which is a weaker condition than equivalent."},
   {"text": "They have the same magnitude and the same direction, wherever they are drawn", "feedback": "Correct."},
   {"text": "They have the same magnitude", "feedback": "Two vectors of the same length can point anywhere. Direction has to match as well."},
   {"text": "They start at the same point", "feedback": "Where a vector is drawn does not matter at all. It can be slid anywhere without changing."}]'::jsonb,
 1, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 23, 'Challenge',
 E'Vectors u and v have magnitudes 5 and 8, with an angle of 60 degrees between them.\nWhat is the magnitude of u + v, to two decimal places?',
 '[{"text": "9.43", "feedback": "The Pythagorean theorem was used on its own. That only works at right angles; at any other angle the cosine law is needed."},
   {"text": "11.36", "feedback": "Correct."},
   {"text": "13.00", "feedback": "The magnitudes were added. That only works when the two point the same way, and there are 60 degrees between them."},
   {"text": "7.00", "feedback": "That is the magnitude of u take away v. The cosine term was subtracted where it should have been added."}]'::jsonb,
 1, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 24, 'Challenge',
 E'Vectors u and v have magnitudes 5 and 8, with an angle of 60 degrees between them.\nWhat is the magnitude of u - v, to two decimal places?',
 '[{"text": "3.00", "feedback": "The magnitudes were subtracted. That only works when the two point the same way, and there are 60 degrees between them."},
   {"text": "9.43", "feedback": "The Pythagorean theorem was used on its own. That only works at right angles; at any other angle the cosine law is needed."},
   {"text": "7.00", "feedback": "Correct."},
   {"text": "11.36", "feedback": "That is the magnitude of the SUM. Subtracting flips the sign of the cosine term."}]'::jsonb,
 2, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 25, 'Challenge',
 'A vector v has magnitude 4. What is the magnitude of -2.5v?',
 '[{"text": "6.5", "feedback": "The scalar was added to the magnitude rather than multiplied by it."},
   {"text": "10", "feedback": "Correct."},
   {"text": "-10", "feedback": "A magnitude is a length, so it can never be negative. The minus sign is carried by the DIRECTION instead."},
   {"text": "1.6", "feedback": "The magnitude was divided by the scalar rather than multiplied by it."}]'::jsonb,
 1, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 26, 'Challenge',
 'A vector v has magnitude 5. Which expression gives a unit vector in the same direction as v?',
 '[{"text": "One fifth of v", "feedback": "Correct."},
   {"text": "Five times v", "feedback": "That makes it five times longer still. A unit vector has a magnitude of exactly 1."},
   {"text": "v itself", "feedback": "Its magnitude is 5, not 1. It has to be scaled down before it counts as a unit vector."},
   {"text": "Negative one fifth of v", "feedback": "The magnitude would be right but the direction would be reversed. The question asks for the SAME direction."}]'::jsonb,
 0, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 27, 'Challenge',
 E'The diagram shows a 20 kg mass suspended from a ceiling by two ropes, at 60 degrees and 45 degrees to the ceiling. Take gravity as 9.8 m/s^2.\nWhat is the tension in the rope at 60 degrees, to one decimal place?',
 '[{"text": "196.0 N", "feedback": "That is the whole weight of the mass. It is shared between the two ropes, and neither one carries all of it."},
   {"text": "143.5 N", "feedback": "Correct."},
   {"text": "101.5 N", "feedback": "That is the tension in the OTHER rope. The steeper rope carries more of the load, so it is the larger of the two."},
   {"text": "98.0 N", "feedback": "The weight was simply halved. The ropes are at different angles, so they do not share the load equally."}]'::jsonb,
 1, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 28, 'Challenge',
 E'A plane flies N40E at an airspeed of 1000 km/h. The ground track is measured as N45E at 1050 km/h.\nWhat is the speed of the wind, to one decimal place?',
 '[{"text": "50.0 km/h", "feedback": "The two speeds were subtracted. That would only be right if the plane and the ground track pointed the same way, and they differ by 5 degrees."},
   {"text": "1050.0 km/h", "feedback": "That is the ground speed. The wind is the DIFFERENCE between the ground velocity and the air velocity, as vectors."},
   {"text": "2050.0 km/h", "feedback": "The two speeds were added. The wind is what you get by subtracting the air velocity from the ground velocity."},
   {"text": "102.4 km/h", "feedback": "Correct."}]'::jsonb,
 3, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 29, 'Challenge',
 E'For that same plane, the wind velocity works out to about 99.7 km/h east and 23.6 km/h south.\nWhat is its true bearing, to the nearest degree?',
 '[{"text": "077 degrees", "feedback": "The angle was measured on the north side of east rather than the south side. A southward component pushes the bearing past 090, not below it."},
   {"text": "103 degrees", "feedback": "Correct."},
   {"text": "013 degrees", "feedback": "The wind has a SOUTHWARD component, so its bearing has to be past 090. This one points into the north-east quarter."},
   {"text": "283 degrees", "feedback": "The direction was reversed. This wind blows towards the east, not away from it."}]'::jsonb,
 1, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 30, 'Challenge',
 E'A box weighing 140 N rests on a ramp inclined at 20 degrees.\nWhat is the component of its weight PERPENDICULAR to the ramp surface, to one decimal place?',
 '[{"text": "51.0 N", "feedback": "Tangent was used instead of cosine. Tangent compares the two components with each other, not either one with the weight."},
   {"text": "131.6 N", "feedback": "Correct."},
   {"text": "47.9 N", "feedback": "That is the component along the SLOPE, the one that would slide the box. Sine and cosine have been swapped."},
   {"text": "140.0 N", "feedback": "That is the whole weight, straight down. Only part of it presses into the ramp surface."}]'::jsonb,
 1, 'sub-vector-components'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): conventions under pressure, and problems where the
-- setup has to be built before anything can be computed. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Geometric Vectors', 4, 31, 'Advanced',
 E'A vector is described as 14 cm at 110 degrees to the horizontal, measured counter-clockwise.\nWhat is its true bearing?',
 '[{"text": "340 degrees", "feedback": "Correct."},
   {"text": "020 degrees", "feedback": "The two angles were subtracted the wrong way round, 110 minus 090 rather than the other way about. Check the sign the subtraction gives before reading it as a bearing."},
   {"text": "110 degrees", "feedback": "The angle was copied straight across. The two conventions use different reference lines and opposite rotations, so they never agree by accident."},
   {"text": "200 degrees", "feedback": "The angle was added to 090 rather than subtracted from it. Counter-clockwise and clockwise pull in opposite directions."}]'::jsonb,
 0, 'sub-vector-basics'),

(12, 'MCV4U', 'Geometric Vectors', 4, 32, 'Advanced',
 'If u + v + w is the zero vector, which statement must be true?',
 '[{"text": "w equals u + v", "feedback": "That would give twice the sum rather than zero. To cancel a vector you need its opposite."},
   {"text": "w equals u - v", "feedback": "Subtracting v does not undo adding it. Both u and v have to be cancelled together."},
   {"text": "The magnitude of w equals the magnitude of u plus the magnitude of v", "feedback": "That only holds when u and v happen to point the same way. In general the magnitude of their sum is smaller."},
   {"text": "w is the opposite of u + v", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vector-addition'),

(12, 'MCV4U', 'Geometric Vectors', 4, 33, 'Advanced',
 E'Vectors a and b satisfy a = -3b, and b has magnitude 4.\nWhat can be said about a?',
 '[{"text": "Its magnitude is 12 and it points the opposite way to b", "feedback": "Correct."},
   {"text": "Its magnitude is 12 and it points the same way as b", "feedback": "The length is right but the negative sign was ignored. A negative scalar reverses the direction."},
   {"text": "Its magnitude is -12 and it points the opposite way to b", "feedback": "The direction is right but a magnitude is a length, so it can never be negative."},
   {"text": "Its magnitude is 1.33 and it points the opposite way to b", "feedback": "The magnitude was divided by the scalar rather than multiplied by it."}]'::jsonb,
 0, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 34, 'Advanced',
 'For which value of k does kv point in the opposite direction to v with half its magnitude?',
 '[{"text": "k = -2", "feedback": "The direction is right but this makes the vector twice as long rather than half."},
   {"text": "k = 2", "feedback": "Both parts are wrong: this keeps the direction and doubles the length."},
   {"text": "k = -0.5", "feedback": "Correct."},
   {"text": "k = 0.5", "feedback": "The length is right but the direction is not. A positive scalar keeps a vector pointing the same way."}]'::jsonb,
 2, 'sub-scalar-multiplication'),

(12, 'MCV4U', 'Geometric Vectors', 4, 35, 'Advanced',
 E'A clown is fired with a horizontal force of 2000 N while gravity pulls him down with 784 N.\nAt what angle below the horizontal does the resultant act, to one decimal place?',
 '[{"text": "68.6 degrees", "feedback": "The two sides were used the other way round in the tangent, which gives the angle measured from the vertical instead."},
   {"text": "20.1 degrees", "feedback": "The RESULTANT was used in the tangent where the horizontal force belongs. Tangent needs the two perpendicular sides, not the hypotenuse."},
   {"text": "45.0 degrees", "feedback": "That would need the two forces to be equal. The horizontal one is well over twice the vertical one."},
   {"text": "21.4 degrees", "feedback": "Correct."}]'::jsonb,
 3, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 36, 'Advanced',
 E'A 20 kg mass hangs from two ropes making 60 degrees and 45 degrees with the ceiling. Take gravity as 9.8 m/s^2.\nWhat is the tension in the rope at 45 degrees, to one decimal place?',
 '[{"text": "138.6 N", "feedback": "The whole weight was divided by root 2, as though this rope alone held the mass at 45 degrees. The other rope carries part of it."},
   {"text": "101.5 N", "feedback": "Correct."},
   {"text": "143.5 N", "feedback": "That is the tension in the OTHER rope. The steeper rope carries more of the load, so this one is the smaller of the two."},
   {"text": "98.0 N", "feedback": "The weight was simply halved. The ropes are at different angles, so they do not share the load equally."}]'::jsonb,
 1, 'sub-resultant-forces'),

(12, 'MCV4U', 'Geometric Vectors', 4, 37, 'Advanced',
 E'A boat heads due north at 12 km/h across a river whose current runs east at 5 km/h.\nWhat is the resultant velocity of the boat?',
 '[{"text": "13 km/h at a bearing of 337 degrees", "feedback": "The current pushes the boat EAST of north, so the bearing is a little more than zero, not a little less."},
   {"text": "13 km/h at a bearing of 023 degrees", "feedback": "Correct."},
   {"text": "13 km/h at a bearing of 067 degrees", "feedback": "The magnitude is right but the angle was measured from EAST rather than from north."},
   {"text": "17 km/h at a bearing of 023 degrees", "feedback": "The bearing is right but the two speeds were added. They are at right angles, so the Pythagorean theorem applies."}]'::jsonb,
 1, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 38, 'Advanced',
 E'The same boat heads due north at 12 km/h across a river 600 m wide, with the current running east at 5 km/h.\nHow long does the crossing take, and does the current change that time?',
 '[{"text": "2.8 minutes, because the resultant speed is higher", "feedback": "The resultant speed is higher, but the extra speed is all sideways. Only the northward part carries the boat across."},
   {"text": "3.0 minutes, but the current makes it longer", "feedback": "The current runs across the crossing rather than against it, so it has been treated as something the boat must fight. Look at which component of the velocity carries the boat toward the far bank."},
   {"text": "7.2 minutes, because the current sets the pace", "feedback": "The width was divided by the CURRENT speed. The boat crosses at its own northward speed."},
   {"text": "3.0 minutes, and the current does not change it", "feedback": "Correct."}]'::jsonb,
 3, 'sub-velocity-problems'),

(12, 'MCV4U', 'Geometric Vectors', 4, 39, 'Advanced',
 E'The diagram shows a box weighing 140 N at rest on a ramp, with the incline marked.\nWhat is the component of its weight acting DOWN the slope, to one decimal place?',
 '[{"text": "47.9 N", "feedback": "Correct."},
   {"text": "131.6 N", "feedback": "That is the component pressing INTO the ramp. Sine and cosine have been swapped."},
   {"text": "140.0 N", "feedback": "That is the whole weight, straight down. Only part of it acts along the slope."},
   {"text": "51.0 N", "feedback": "Tangent was used instead of sine. Tangent compares the two components with each other, not either one with the weight."}]'::jsonb,
 0, 'sub-vector-components'),

(12, 'MCV4U', 'Geometric Vectors', 4, 40, 'Advanced',
 E'A force has a horizontal component of 120 N and a vertical component of 90 N.\nWhat is its magnitude and its angle to the horizontal?',
 '[{"text": "210 N at 36.9 degrees", "feedback": "The angle is right but the two components were added. They are at right angles, so the Pythagorean theorem applies."},
   {"text": "150 N at 0.8 degrees", "feedback": "The ratio of the components was reported instead of the angle. An inverse tangent still has to be taken."},
   {"text": "150 N at 36.9 degrees", "feedback": "Correct."},
   {"text": "150 N at 53.1 degrees", "feedback": "The magnitude is right but the two components were used the other way round in the tangent, giving the angle from the vertical."}]'::jsonb,
 2, 'sub-vector-components');
