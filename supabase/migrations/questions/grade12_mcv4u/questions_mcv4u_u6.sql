-- ===========================================================================
-- MCV4U — Unit 6: Lines and Planes — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Vector equation of a line in 2-space
--   Lesson 2  Vector equation of a line in 3-space
--   Lesson 3  Vector equation of a plane
--   Lesson 4  Scalar equation of a plane
--   Lesson 5  Intersections of lines in 2-space and 3-space
--   Lesson 6  Intersections of lines and planes
--   Lesson 7  Intersections of planes
--
-- Seven lessons, six subtopics: the two intersection lessons that involve a
-- plane are counted together, because a student who can handle two planes
-- can almost always handle a line and a plane, and splitting them would put
-- fewer than five questions in each.
--
-- The split that matters most on the dashboard is the DIRECTION vector
-- against the NORMAL vector. Both are triples of numbers pulled out of an
-- equation, both are written in square brackets, and a student who has
-- fused the two will confidently read the coefficients of a plane as a
-- direction lying in it. Every question in this unit that can be lost that
-- way offers exactly that answer as a distractor.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Four repeat all through the unit:
--
--   * using a position vector to a point ON a line as a direction vector
--     FOR the line
--   * reading the coefficients of a scalar equation as a direction rather
--     than as a normal
--   * checking one coordinate against a parametric equation and stopping,
--     when it is the AGREEMENT of the parameter across every coordinate
--     that decides whether a point is on the line
--   * concluding that two lines in 3-space with non-parallel directions
--     must therefore meet
--
-- Feedback names the mistake and stops there.
--
-- Every direction vector, normal, scalar equation, intersection and
-- distance in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- FIGURES: one, on question 1.
--
--   * Q1 shows a line, the origin, and four labelled vectors, exactly one
--     of which lies along the line. This is the picture the whole vector
--     equation of a line comes from, and it is where the position-vector
--     confusion is born: two of the other three reach points that are ON
--     the line, which makes them look like candidates. No coordinates, no
--     grid, nothing to count.
--
-- Rejected: the three-dimensional renders of intersecting planes. Those
-- pictures show the answer — a drawing of two planes crossing in a line is
-- a drawing of the words "they cross in a line". Every intersection
-- question here is asked from the equations.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file -> figures_mcv4u.sql.
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

delete from questions where course_code = 'MCV4U' and unit = 'Lines and Planes';

insert into misconception_labels (tag, label) values
  ('sub-lines-2space',        'Equations of lines in 2-space'),
  ('sub-lines-3space',        'Equations of lines in 3-space'),
  ('sub-planes-vector',       'Vector equation of a plane'),
  ('sub-planes-scalar',       'Scalar equation of a plane'),
  ('sub-line-intersections',  'Intersections of lines'),
  ('sub-plane-intersections', 'Intersections of planes')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): what each piece of an equation IS, and one substitution.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 1, 'Easy',
 E'The diagram shows a line L, the origin O, and four vectors.\nWhich one is a DIRECTION vector for L?',
 '[{"text": "p", "feedback": "That runs from the origin to a point of L, so it is the starting position in the equation rather than the direction term."},
   {"text": "q", "feedback": "Its tip landing on L does not make it parallel to L. A direction runs between two points of the line, not out to one of them."},
   {"text": "s", "feedback": "That one does not even touch the line. It is parallel to nothing in the picture."},
   {"text": "r", "feedback": "Correct."}]'::jsonb,
 3, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 2, 'Easy',
 'A line passes through A(1, 4) and B(3, 1). What is a direction vector for it?',
 '[{"text": "[1, 4]", "feedback": "That is the position vector to A. A point on the line is not the same as a direction along it."},
   {"text": "[2, -3]", "feedback": "Correct."},
   {"text": "[4, 5]", "feedback": "The two points were added. A direction comes from subtracting one from the other."},
   {"text": "[2, 3]", "feedback": "The second component lost its sign. Going from A to B the y-value drops from 4 to 1."}]'::jsonb,
 1, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 3, 'Easy',
 'Why does a line in 3-space have no single scalar equation?',
 '[{"text": "Because a single scalar equation in three variables describes a plane", "feedback": "Correct."},
   {"text": "Because a line in 3-space has no normal vector to build such an equation from", "feedback": "It has infinitely many normals, which is part of the difficulty; the trouble is that one equation is not restrictive enough."},
   {"text": "Because a line in 3-space needs a parameter to pin a point down", "feedback": "It does use one, but that is a consequence rather than the reason. One equation in three variables simply leaves too much freedom."},
   {"text": "Because a line in 3-space is not the graph of a function", "feedback": "Being a function has nothing to do with it. A line in 2-space is often not a function either and still has a scalar equation."}]'::jsonb,
 0, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 4, 'Easy',
 'For the line [x, y, z] = [1, 0, 3] + t[2, -1, 5], which point is on the line when t = 2?',
 '[{"text": "(2, -1, 5)", "feedback": "That is the direction vector on its own. The starting point still has to be added."},
   {"text": "(1, 0, 3)", "feedback": "That is the point at t = 0. Two lots of the direction still have to be added to it."},
   {"text": "(5, -2, 13)", "feedback": "Correct."},
   {"text": "(3, -1, 8)", "feedback": "That is the point at t = 1. The parameter has to multiply every component of the direction."}]'::jsonb,
 2, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 5, 'Easy',
 'How many direction vectors does the vector equation of a plane need?',
 '[{"text": "One", "feedback": "One direction and a point gives a LINE. A plane needs a second, independent way to move."},
   {"text": "Three", "feedback": "Three directions in three-space generally fill all of space rather than a plane."},
   {"text": "None, only a normal vector is needed", "feedback": "That is enough for the SCALAR equation. The vector equation is built from directions instead."},
   {"text": "Two, and they must not be collinear", "feedback": "Correct."}]'::jsonb,
 3, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 6, 'Easy',
 'In the plane equation Ax + By + Cz + D = 0, what does [A, B, C] represent?',
 '[{"text": "One of the points on the plane", "feedback": "Nothing in the coefficients names a point. D shifts the plane, but a point has to be found by substituting."},
   {"text": "The position vector of the origin", "feedback": "That is the zero vector, which has no direction at all."},
   {"text": "A normal vector to the plane", "feedback": "Correct."},
   {"text": "A direction vector lying in the plane", "feedback": "It is the exact opposite: it is perpendicular to every direction lying in the plane. This is the single most common mix-up in the unit."}]'::jsonb,
 2, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 7, 'Easy',
 'What is a normal vector to the plane 3x - 2y + z - 7 = 0?',
 '[{"text": "[3, -2, 1]", "feedback": "Correct."},
   {"text": "[3, -2, -7]", "feedback": "The constant term was collected as a component. Only the three coefficients of x, y and z make up the normal."},
   {"text": "[3, 2, 1]", "feedback": "The sign on the middle component was lost. It has to be read straight off the equation."},
   {"text": "[1, -2, 3]", "feedback": "The first and third components were swapped. They belong to x and z in the order they appear."}]'::jsonb,
 0, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 8, 'Easy',
 'Two lines in 2-space have direction vectors that are not parallel. In how many points do they intersect?',
 '[{"text": "Infinitely many", "feedback": "That would make them the same line, which would need their directions to be parallel."},
   {"text": "Two", "feedback": "Two straight lines that meet twice would have to be the same line. Straight lines cross at most once."},
   {"text": "Exactly one", "feedback": "Correct."},
   {"text": "None", "feedback": "That happens when the directions ARE parallel and the lines are distinct. Non-parallel lines in a plane cannot avoid each other."}]'::jsonb,
 2, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 9, 'Easy',
 'Two distinct planes have normal vectors that are not parallel. What is their intersection?',
 '[{"text": "A line", "feedback": "Correct."},
   {"text": "A single point", "feedback": "Two planes never meet in just a point. Once they share one point they share a whole line through it."},
   {"text": "A plane", "feedback": "That would make them the same plane, which the question rules out by calling them distinct."},
   {"text": "Nothing", "feedback": "That happens only when the normals ARE parallel and the planes are distinct."}]'::jsonb,
 0, 'sub-plane-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 10, 'Easy',
 'Two plane equations are scalar multiples of one another. What does that mean geometrically?',
 '[{"text": "They meet in a line", "feedback": "That needs the normals to point in different directions, and multiples of one another point the same way."},
   {"text": "They are perpendicular", "feedback": "Perpendicular planes have normals with a dot product of zero, which multiples of each other never manage."},
   {"text": "They are the same plane, so every point of one lies on the other", "feedback": "Correct."},
   {"text": "They are parallel and distinct planes, so they never meet at any point", "feedback": "Parallel and distinct planes have normals that are multiples but constants that are NOT in the same ratio. Here the whole equation matches."}]'::jsonb,
 2, 'sub-plane-intersections'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): write one equation, or test one point.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 11, 'Medium',
 'What is a vector equation of the line through A(1, 4) and B(3, 1)?',
 '[{"text": "[x, y] = [2, -3] + t[1, 4]", "feedback": "The point and the direction have swapped places. The point goes first, on its own."},
   {"text": "[x, y] = [1, 4] + t[3, 1]", "feedback": "The second POINT was used as a direction. A direction comes from subtracting one point from the other."},
   {"text": "[x, y] = [1, 4] + t[4, 5]", "feedback": "The two points were added to make the direction. They have to be subtracted."},
   {"text": "[x, y] = [1, 4] + t[2, -3]", "feedback": "Correct."}]'::jsonb,
 3, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 12, 'Medium',
 'Is the point (2, 3) on the line [x, y] = [1, 4] + t[2, -3]?',
 '[{"text": "No, because the two coordinates need different values of t", "feedback": "Correct."},
   {"text": "Yes, at t = 0.5", "feedback": "That value works for the x-coordinate, but substituting it gives a y of 2.5 rather than 3. One coordinate agreeing is not enough."},
   {"text": "Yes, at t = 1", "feedback": "At that value the point is (3, 1), which is neither coordinate of the one being tested."},
   {"text": "Yes, because both coordinates lie between those of the two given points", "feedback": "Lying between two points on a line does not put you on the line; the whole plane between them is off it."}]'::jsonb,
 0, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 13, 'Medium',
 'What are the parametric equations of the line through (2, -1, 4) with direction [3, 0, -2]?',
 '[{"text": "x = 2 + 3t, y = -1, z = 4 + 2t", "feedback": "The sign on the third component of the direction was lost."},
   {"text": "x = 2 + 3t, y = -1 + t, z = 4 - 2t", "feedback": "The middle component of the direction is zero, so y is stuck. Nothing may be invented for it."},
   {"text": "x = 2 + 3t, y = -1, z = 4 - 2t", "feedback": "Correct."},
   {"text": "x = 3 + 2t, y = -t, z = -2 + 4t", "feedback": "The point and the direction have swapped places in every coordinate."}]'::jsonb,
 2, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 14, 'Medium',
 'Two lines in 3-space have non-parallel directions and never meet. What are they called?',
 '[{"text": "Perpendicular", "feedback": "Perpendicular describes the ANGLE between two directions, and perpendicular lines in 3-space may or may not meet."},
   {"text": "Skew", "feedback": "Correct."},
   {"text": "Parallel", "feedback": "Parallel lines have directions that are scalar multiples of one another, which the question rules out."},
   {"text": "Coincident", "feedback": "Coincident lines share every point, which is the opposite of never meeting."}]'::jsonb,
 1, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 15, 'Medium',
 'Which is a vector equation of the plane through (1, 2, 3) containing the directions [1, 0, 0] and [0, 1, 0]?',
 '[{"text": "[x, y, z] = [1, 2, 3] + s[1, 0, 0] + t[0, 1, 0]", "feedback": "Correct."},
   {"text": "[x, y, z] = [1, 2, 3] + t[1, 0, 0]", "feedback": "Only one direction was used, which describes a LINE. A plane needs two independent parameters."},
   {"text": "[x, y, z] = [1, 0, 0] + s[1, 2, 3] + t[0, 1, 0]", "feedback": "The point and the first direction have swapped places."},
   {"text": "[x, y, z] = [1, 2, 3] + s[1, 0, 0] + t[0, 1, 0] + u[0, 0, 1]", "feedback": "Three independent directions fill the whole of space rather than a plane."}]'::jsonb,
 0, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 16, 'Medium',
 'What is the scalar equation of the plane through (2, -1, 5) with normal [3, 4, -2]?',
 '[{"text": "3x + 4y - 2z = 0", "feedback": "The constant was left out, which puts the plane through the origin instead of through the given point."},
   {"text": "3x + 4y - 2z + 8 = 0", "feedback": "Correct."},
   {"text": "3x + 4y - 2z - 8 = 0", "feedback": "The constant was copied with the sign of the substitution instead of the sign that cancels it. Put (2, -1, 5) into this equation and the left side does not come out as zero."},
   {"text": "2x - y + 5z + 8 = 0", "feedback": "The POINT was used as the coefficients. The normal supplies them; the point only fixes the constant."}]'::jsonb,
 1, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 17, 'Medium',
 'Are the planes 2x - 6y + 4z - 7 = 0 and 3x - 9y + 6z - 2 = 0 parallel?',
 '[{"text": "No, because their constant terms are different numbers", "feedback": "The constants decide whether they are the same plane or two distinct ones. Being parallel is decided by the normals alone."},
   {"text": "No, because their coefficients are not the same numbers as one another", "feedback": "Different numbers can still be in the same ratio. Divide one set by the other and every quotient comes out the same."},
   {"text": "No, they are perpendicular to one another", "feedback": "Perpendicular planes have normals with a dot product of zero. These two normals point the same way."},
   {"text": "Yes, because their normal vectors are scalar multiples of one another", "feedback": "Correct."}]'::jsonb,
 3, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 18, 'Medium',
 'How are the lines [x, y] = [1, 2] + t[3, 1] and [x, y] = [0, 5] + s[6, 2] related?',
 '[{"text": "Parallel and distinct, so they never meet", "feedback": "Correct."},
   {"text": "They meet at exactly one point", "feedback": "The second direction is twice the first, so the lines never converge. Two parallel lines meet only if they are the same line."},
   {"text": "Coincident, so they meet everywhere", "feedback": "The directions do match, but the point (0, 5) is not on the first line. Substituting its x-value gives a y of five thirds."},
   {"text": "Skew", "feedback": "Skew is only possible in 3-space. Two lines in a plane are either parallel or they cross."}]'::jsonb,
 0, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 19, 'Medium',
 'How do the planes 2x - y + z - 1 = 0 and x + y + z - 6 = 0 intersect?',
 '[{"text": "At a single point", "feedback": "Two planes never meet in one point alone. Once they share a point they share the whole line through it."},
   {"text": "They do not intersect", "feedback": "That needs parallel normals, and these two are not multiples of one another."},
   {"text": "They are the same plane", "feedback": "The two equations are not multiples of each other, so they describe different planes."},
   {"text": "In a line", "feedback": "Correct."}]'::jsonb,
 3, 'sub-plane-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 20, 'Medium',
 'How do the planes x + y - 2z + 2 = 0 and 2x + 2y - 4z + 4 = 0 intersect?',
 '[{"text": "They meet at a single point, and nowhere else", "feedback": "Two planes never meet in one point alone."},
   {"text": "They are coincident, so every point of one lies on the other", "feedback": "Correct."},
   {"text": "They intersect in a line, and share every point along that line", "feedback": "That needs the normals to point in different directions. Here the second equation is exactly twice the first."},
   {"text": "They do not intersect, so they have no point in common", "feedback": "That would make them parallel and distinct, which needs the constants to be in a different ratio from the coefficients. Here every ratio is 2."}]'::jsonb,
 1, 'sub-plane-intersections'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): convert between forms, and build a plane from
-- directions. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 21, 'Challenge',
 'A line has parametric equations x = 3 + 2t and y = -5 + 4t. What is its scalar equation?',
 '[{"text": "2x - y + 11 = 0", "feedback": "The constant came out with the wrong sign. Substitute (3, -5) and this one gives 22."},
   {"text": "2x - y - 11 = 0", "feedback": "Correct."},
   {"text": "4x - 2y - 11 = 0", "feedback": "The two sides were not reduced to lowest terms consistently, so the constant no longer fits. Substitute the point (3, -5) and see."},
   {"text": "2x + y - 11 = 0", "feedback": "A sign was flipped while rearranging. Substitute (3, -5) and this one gives negative 10 rather than zero."}]'::jsonb,
 1, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 22, 'Challenge',
 'Which vector is a direction vector for the line 3x + 2y - 11 = 0?',
 '[{"text": "[3, 2]", "feedback": "Those are the coefficients, which give the NORMAL. A direction has to be perpendicular to it."},
   {"text": "[3, -2]", "feedback": "The signs were swapped without the components being swapped. Check the dot product with the normal: it comes out as 5, not zero."},
   {"text": "[2, 3]", "feedback": "The components were swapped but no sign was changed. Its dot product with the normal is 12, not zero."},
   {"text": "[2, -3]", "feedback": "Correct."}]'::jsonb,
 3, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 23, 'Challenge',
 'What are the symmetric equations of the line through (1, -2, 4) with direction [3, 5, -1]?',
 '[{"text": "(x - 3)/1 = (y - 5)/(-2) = (z + 1)/4", "feedback": "The point and the direction have swapped places."},
   {"text": "(x - 1)/3 = (y - 2)/5 = (z - 4)/(-1)", "feedback": "The middle term is wrong. Subtracting negative 2 from y gives a plus sign there."},
   {"text": "(x - 1)/3 = (y + 2)/5 = (z - 4)/(-1)", "feedback": "Correct."},
   {"text": "(x + 1)/3 = (y - 2)/5 = (z + 4)/(-1)", "feedback": "Every sign on the point was flipped. The coordinates of the point are SUBTRACTED, so a negative coordinate becomes an addition."}]'::jsonb,
 2, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 24, 'Challenge',
 'Is the point (7, 8, 2) on the line [x, y, z] = [1, -2, 4] + t[3, 5, -1]?',
 '[{"text": "Yes, at t = 6", "feedback": "The starting x was subtracted from 7, but the difference was never divided by the first component of the direction. Test any candidate in all three coordinates."},
   {"text": "Yes, at t = 2", "feedback": "Correct."},
   {"text": "No, because the coordinates need different values of t", "feedback": "They do not. One value satisfies all three, which is exactly what puts the point on the line."},
   {"text": "Yes, at t = 3", "feedback": "At that value the point is (10, 13, 1), which is not the one being tested."}]'::jsonb,
 1, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 25, 'Challenge',
 'A plane has vector equation [x, y, z] = [1, 0, 2] + s[2, 1, 0] + t[0, 3, 1]. What is a normal vector to it?',
 '[{"text": "[1, 0, 2]", "feedback": "That is the position vector of the given point. Where the plane sits says nothing about which way it faces."},
   {"text": "[1, 2, 6]", "feedback": "The middle component came out with the wrong sign. In a cross product it is built the opposite way round from the other two."},
   {"text": "[1, -2, 6]", "feedback": "Correct."},
   {"text": "[2, 1, 0]", "feedback": "That is one of the DIRECTIONS lying in the plane. A normal has to be perpendicular to both of them."}]'::jsonb,
 2, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 26, 'Challenge',
 'Why must the two direction vectors in the vector equation of a plane be non-collinear?',
 '[{"text": "Because otherwise the given point would not lie on the plane", "feedback": "The point lies on it either way, at s and t both zero. What collapses is everything else."},
   {"text": "Because two collinear directions sweep out only a line", "feedback": "Correct."},
   {"text": "Because their cross product has to come out equal to zero", "feedback": "It has to be non-zero. That cross product is exactly what supplies the normal, and collinear directions would leave you without one."},
   {"text": "Because the normal vector is required to have magnitude 1", "feedback": "A normal of any length will do. The requirement is that a normal exists at all."}]'::jsonb,
 1, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 27, 'Challenge',
 'What is the scalar equation of the plane through (1, 0, 2) containing the directions [2, 1, 0] and [0, 3, 1]?',
 '[{"text": "x + 2y + 6z - 13 = 0", "feedback": "The middle coefficient came out with the wrong sign in the cross product. It is built the opposite way round from the other two."},
   {"text": "x - 2y + 6z - 13 = 0", "feedback": "Correct."},
   {"text": "x - 2y + 6z + 13 = 0", "feedback": "The constant was copied with the sign of the substitution instead of the sign that cancels it. Put (1, 0, 2) into this equation and the left side does not come out as zero."},
   {"text": "2x + y + 0z - 2 = 0", "feedback": "One of the DIRECTIONS was used as the normal. A normal is perpendicular to both directions, which means taking their cross product first."}]'::jsonb,
 1, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 28, 'Challenge',
 'What is the angle between the planes x + y + z = 0 and x - y = 0?',
 '[{"text": "90 degrees", "feedback": "Correct."},
   {"text": "45 degrees", "feedback": "That would be the angle if the normals had a dot product equal to the product of one magnitude with the other over root 2. Here the dot product is exactly zero."},
   {"text": "60 degrees", "feedback": "The dot product of the two normals is zero, which forces the cosine to zero and the angle to a right angle."},
   {"text": "0 degrees", "feedback": "That would need the normals to be parallel, and one has a z-component while the other does not."}]'::jsonb,
 0, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 29, 'Challenge',
 'How are the lines [x, y, z] = [1, 0, 2] + t[1, 2, -1] and [x, y, z] = [2, 3, 1] + s[2, 4, -2] related?',
 '[{"text": "They meet at exactly one point", "feedback": "The second direction is twice the first, so the lines never converge on each other."},
   {"text": "Coincident, so they meet everywhere", "feedback": "The directions do match, but (2, 3, 1) is not on the first line. Its x-coordinate needs t equal to 1, and that gives a y of 2 rather than 3."},
   {"text": "Skew", "feedback": "Skew lines have non-parallel directions. These two directions are multiples of one another."},
   {"text": "Parallel and distinct, so they never meet", "feedback": "Correct."}]'::jsonb,
 3, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 30, 'Challenge',
 'Two planes are parallel and distinct. How many solutions does the system of their two equations have?',
 '[{"text": "Two", "feedback": "A system of linear equations has no solutions, one solution or infinitely many. Two is never available."},
   {"text": "None", "feedback": "Correct."},
   {"text": "Exactly one", "feedback": "Two planes never share exactly one point, whether they are parallel or not."},
   {"text": "Infinitely many", "feedback": "That happens when the two are COINCIDENT. Distinct parallel planes share nothing at all."}]'::jsonb,
 1, 'sub-plane-intersections'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): distances, intersections built from scratch, and the
-- three-plane cases. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Lines and Planes', 6, 31, 'Advanced',
 'What is the distance from the point (4, 1) to the line 3x + 4y - 10 = 0?',
 '[{"text": "1.2", "feedback": "Correct."},
   {"text": "6", "feedback": "That is the value of the left-hand side at the point, before dividing by the magnitude of the normal."},
   {"text": "5.2", "feedback": "The constant term was added when the point was substituted rather than subtracted."},
   {"text": "0", "feedback": "The point is not on the line. Substituting it gives 6, not zero."}]'::jsonb,
 0, 'sub-lines-2space'),

(12, 'MCV4U', 'Lines and Planes', 6, 32, 'Advanced',
 'What is a direction vector for the line of intersection of 2x - y + z - 1 = 0 and x + y + z - 6 = 0?',
 '[{"text": "[1, 1, 1]", "feedback": "That is the normal of the second plane. The line of intersection lies in that plane too."},
   {"text": "[-2, -1, 3]", "feedback": "Correct."},
   {"text": "[3, 0, 2]", "feedback": "The two normals were added. A direction along the intersection has to be perpendicular to BOTH normals, which calls for a cross product."},
   {"text": "[2, -1, 1]", "feedback": "That is the normal of the first plane. The line of intersection lies IN that plane, so it is perpendicular to this."}]'::jsonb,
 1, 'sub-lines-3space'),

(12, 'MCV4U', 'Lines and Planes', 6, 33, 'Advanced',
 'What is the scalar equation of the plane through the points (1, 0, 0), (0, 1, 0) and (0, 0, 1)?',
 '[{"text": "x + y + z - 1 = 0", "feedback": "Correct."},
   {"text": "x + y + z = 0", "feedback": "That plane passes through the origin, and none of the three given points is the origin. Substitute any one of them and it gives 1."},
   {"text": "x + y + z - 3 = 0", "feedback": "The three coordinates were added across all three points. Substituting one point into the first three terms gives 1, so the constant is negative 1."},
   {"text": "x - y + z - 1 = 0", "feedback": "A sign was flipped in the normal. Substituting the second point gives negative 2 rather than zero."}]'::jsonb,
 0, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 34, 'Advanced',
 'Which plane does [x, y, z] = [0, 0, 0] + s[1, 1, 0] + t[1, -1, 0] describe?',
 '[{"text": "The xz-plane, y = 0", "feedback": "The two directions were subtracted and the difference read off as a normal. A normal has to be perpendicular to both directions, and that difference is perpendicular to neither."},
   {"text": "The plane x + y = 0", "feedback": "That would be a plane containing the z-axis, and neither of these directions has any z-component at all."},
   {"text": "A line through the origin", "feedback": "The two directions are not multiples of one another, so together they sweep out a full plane rather than a line."},
   {"text": "The xy-plane, z = 0", "feedback": "Correct."}]'::jsonb,
 3, 'sub-planes-vector'),

(12, 'MCV4U', 'Lines and Planes', 6, 35, 'Advanced',
 'What is the distance from the origin to the plane 2x - y + 2z - 9 = 0?',
 '[{"text": "1", "feedback": "The divisor was the sum of the SQUARES of the components, with the square root never taken."},
   {"text": "4.5", "feedback": "Only the first component of the normal was used as the divisor. The whole magnitude of the normal belongs underneath."},
   {"text": "3", "feedback": "Correct."},
   {"text": "9", "feedback": "That is the size of the constant term, before dividing by the magnitude of the normal."}]'::jsonb,
 2, 'sub-planes-scalar'),

(12, 'MCV4U', 'Lines and Planes', 6, 36, 'Advanced',
 'How are the lines [x, y, z] = [1, 0, 2] + t[1, 2, -1] and [x, y, z] = [0, 1, 1] + s[2, 1, 1] related?',
 '[{"text": "They are parallel and distinct", "feedback": "The two directions are not multiples of one another, so the lines are not parallel."},
   {"text": "They are coincident", "feedback": "Coincident lines share every point, and these two share none at all."},
   {"text": "They are skew", "feedback": "Correct."},
   {"text": "They meet at exactly one point", "feedback": "Two of the three equations can be satisfied together, at t equal to two thirds, but the first one then fails. All three have to agree."}]'::jsonb,
 2, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 37, 'Advanced',
 'Two lines in 2-space have the same direction vector and share one point. How are they related?',
 '[{"text": "They are parallel and distinct, so they never share a point", "feedback": "Distinct parallel lines share NO points. One shared point plus a common direction forces the rest to follow."},
   {"text": "They meet at exactly one point", "feedback": "That needs different directions. With the same direction, one shared point drags the whole line along."},
   {"text": "They are skew", "feedback": "Skew is only possible in 3-space, and skew lines never meet at all."},
   {"text": "They are coincident, so they share every point", "feedback": "Correct."}]'::jsonb,
 3, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 38, 'Advanced',
 'Two lines in 3-space have direction vectors that are not parallel. What can be concluded?',
 '[{"text": "They either meet at exactly one point or they are skew", "feedback": "Correct."},
   {"text": "They must meet at exactly one point, since they are not parallel", "feedback": "That is what happens in 2-space. In three dimensions two lines can pass each other at different heights without ever touching."},
   {"text": "They must be skew, so they never meet at any point", "feedback": "They may well meet. Non-parallel directions leave both possibilities open, which is why the system has to be solved."},
   {"text": "They must be parallel", "feedback": "The question rules that out: parallel lines have directions that are scalar multiples of one another."}]'::jsonb,
 0, 'sub-line-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 39, 'Advanced',
 'Three planes have normals that are neither parallel nor coplanar. How do they intersect?',
 '[{"text": "In a line", "feedback": "That is the case where the normals are not parallel but ARE coplanar. Here they are independent enough to pin down a single point."},
   {"text": "In a plane", "feedback": "That needs all three equations to be multiples of one another, which would make the normals parallel."},
   {"text": "They do not intersect", "feedback": "Independent normals guarantee a solution. It is when the normals become coplanar that a system can turn inconsistent."},
   {"text": "At exactly one point", "feedback": "Correct."}]'::jsonb,
 3, 'sub-plane-intersections'),

(12, 'MCV4U', 'Lines and Planes', 6, 40, 'Advanced',
 'How do you test whether the normals of three planes are coplanar?',
 '[{"text": "Check whether all three are unit vectors", "feedback": "Length has nothing to do with it. Scaling a normal does not move the plane it belongs to."},
   {"text": "Check whether the three normals add together to give exactly the zero vector", "feedback": "That would force them to be coplanar, but plenty of coplanar triples do not add to zero. The test is too strict."},
   {"text": "Check whether the triple scalar product of the three normals is zero", "feedback": "Correct."},
   {"text": "Check whether all three pairwise dot products come out as zero", "feedback": "That tests whether they are mutually perpendicular, which is as far from coplanar as three vectors can get."}]'::jsonb,
 2, 'sub-plane-intersections');
