-- ===========================================================================
-- MCV4U — Unit 5: Algebraic Vectors — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Cartesian (algebraic) vectors
--   Lesson 2  The dot product
--   Lesson 3  Applications of the dot product
--   Lesson 4  Vectors in 3-space
--   Lesson 5  The cross product
--   Lesson 6  Applications of the dot and cross products
--
-- Six lessons, six subtopics, one for each. Splitting each product from its
-- applications matters more here than anywhere else in the course. A student
-- can compute a cross product flawlessly and still not know that its
-- magnitude is an area; a student can know that fact and still lose every
-- mark to a sign in the middle component. Those are different lessons, and
-- the dashboard has to be able to tell them apart.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Five repeat all through the unit:
--
--   * getting a vector where a scalar belongs, or the reverse — the dot
--     product returns a number and the cross product returns a vector
--   * reversing the order of a cross product, which flips every component
--   * the sign of the MIDDLE component of a cross product, which runs the
--     opposite way to the other two
--   * subtracting position vectors the wrong way round when building the
--     vector between two points
--   * forgetting to convert centimetres to metres before computing a torque
--
-- Feedback names the mistake and stops there.
--
-- Every component, magnitude, angle, area, projection and volume in this
-- file was recomputed independently with sympy before delivery; nothing was
-- copied from the source PDFs.
--
-- FIGURES: three. This is an algebraic unit and most of it needs no picture
-- at all, but three questions are about an arrangement rather than an
-- arithmetic.
--
--   * Q25 shows a projection: two vectors from a common tail, a dashed
--     perpendicular, and the piece of the line along b picked out. No
--     numbers. The picture is what makes clear the result lies along b.
--   * Q28 shows two vectors in the plane of the page and asks which way
--     their cross product points. No numbers, and nothing on the figure
--     names a direction.
--   * Q39 shows a wrench. RULER TEST: the angle is labelled 80 degrees and
--     drawn at about 30, so a student who measures it computes about 6.0
--     N m, whose nearest option is 2.08 and is wrong. Sine is flat near 90
--     degrees, so the usual 15 to 20 degrees of distortion would not have
--     been enough — anything above about 55 degrees rounds back onto the
--     correct answer, and the drawn angle had to go well below that.
--
-- Rejected: a 3-space axis diagram with a vector drawn on it. The
-- components are countable off the axes, which is the whole question.
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

delete from questions where course_code = 'MCV4U' and unit = 'Algebraic Vectors';

insert into misconception_labels (tag, label) values
  ('sub-cartesian-vectors',  'Cartesian vectors and magnitude'),
  ('sub-dot-product',        'The dot product'),
  ('sub-dot-applications',   'Applications of the dot product'),
  ('sub-vectors-3space',     'Vectors in three dimensions'),
  ('sub-cross-product',      'The cross product'),
  ('sub-cross-applications', 'Applications of the cross product')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): what each object IS, and one computation of each kind.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 1, 'Easy',
 'P is the point (2, -3) and Q is the point (7, 1). What is the vector PQ in component form?',
 '[{"text": "[-5, -4]", "feedback": "The subtraction went the wrong way round. That is the vector QP, which points back the other way."},
   {"text": "[9, -2]", "feedback": "The two points were added. A vector between points comes from subtracting the start from the finish."},
   {"text": "[5, -4]", "feedback": "The second component was subtracted the other way round from the first. Both of them have to run from the start point to the finish point."},
   {"text": "[5, 4]", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 2, 'Easy',
 'What is the magnitude of the vector [3, -4]?',
 '[{"text": "5", "feedback": "Correct."},
   {"text": "-1", "feedback": "The components were added. A magnitude comes from squaring each one first, which removes the signs."},
   {"text": "7", "feedback": "The absolute values were added. That is the distance you would walk in two straight legs, not the direct distance."},
   {"text": "25", "feedback": "The square root was never taken. That is the SQUARE of the magnitude."}]'::jsonb,
 0, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 3, 'Easy',
 'What is the dot product of [3, -4] and [2, 5]?',
 '[{"text": "-14", "feedback": "Correct."},
   {"text": "14", "feedback": "The signs were stripped off the two products and the smaller size taken from the larger. Each product keeps the sign of the components it came from."},
   {"text": "[6, -20]", "feedback": "The two products were left as a pair. A dot product adds them together into a single number."},
   {"text": "26", "feedback": "The two products were subtracted rather than added."}]'::jsonb,
 0, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 4, 'Easy',
 'What kind of quantity is a dot product?',
 '[{"text": "An angle", "feedback": "An angle can be recovered FROM a dot product, but only after dividing by both magnitudes and taking an inverse cosine."},
   {"text": "A scalar, a single number with no direction", "feedback": "Correct."},
   {"text": "A vector perpendicular to both", "feedback": "That is the CROSS product. The dot product collapses everything into a single number."},
   {"text": "A vector in the same plane as both", "feedback": "There is no vector at the end of a dot product at all."}]'::jsonb,
 1, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 5, 'Easy',
 'Two non-zero vectors have a dot product of zero. What does that tell you?',
 '[{"text": "They point in opposite directions", "feedback": "Opposite vectors give a negative dot product, as large in size as it can be, rather than zero."},
   {"text": "They are perpendicular to each other", "feedback": "Correct."},
   {"text": "They are parallel", "feedback": "Parallel vectors give the LARGEST possible dot product for their lengths, not zero. It is the CROSS product that vanishes when they are parallel."},
   {"text": "They are equal", "feedback": "Equal vectors have a dot product equal to the square of their magnitude, which is positive."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 6, 'Easy',
 'What is the magnitude of the vector [2, -3, 6]?',
 '[{"text": "5", "feedback": "The components were added. A magnitude squares each one first, which removes the signs."},
   {"text": "11", "feedback": "The absolute values were added. That is not the direct distance from the origin."},
   {"text": "49", "feedback": "The square root was never taken. That is the SQUARE of the magnitude."},
   {"text": "7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 7, 'Easy',
 'In three dimensions, the vector [1, 0, 0] is usually written with which single letter?',
 '[{"text": "j", "feedback": "That is the unit vector along the y-axis, which is [0, 1, 0]."},
   {"text": "k", "feedback": "That is the unit vector along the z-axis, which is [0, 0, 1]."},
   {"text": "The zero vector", "feedback": "The zero vector has every component zero. This one has a length of 1."},
   {"text": "i", "feedback": "Correct."}]'::jsonb,
 3, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 8, 'Easy',
 'What kind of quantity is a cross product?',
 '[{"text": "A vector in the same plane as both of the originals", "feedback": "It leaves that plane entirely, at right angles to it. That is what makes it useful for finding a normal."},
   {"text": "An angle", "feedback": "An angle is hidden inside its magnitude, but the product itself is a vector."},
   {"text": "A vector perpendicular to both of the original vectors", "feedback": "Correct."},
   {"text": "A scalar", "feedback": "That is the DOT product. The cross product returns a vector, which is why it only exists in three dimensions."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 9, 'Easy',
 'What is i cross j?',
 '[{"text": "The zero vector", "feedback": "A cross product vanishes only when the two vectors are collinear, and these two are at right angles."},
   {"text": "k", "feedback": "Correct."},
   {"text": "Negative k", "feedback": "The order was reversed. That is j cross i, which points the opposite way."},
   {"text": "i", "feedback": "The result has to be perpendicular to BOTH of the originals, and this one is not perpendicular to itself."}]'::jsonb,
 1, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 10, 'Easy',
 'What does the magnitude of u cross v measure?',
 '[{"text": "The area of the triangle defined by u and v", "feedback": "That is HALF of it. The parallelogram is made of two such triangles."},
   {"text": "The perimeter of the parallelogram defined by u and v", "feedback": "A perimeter is a sum of lengths, and it would not vanish when the two vectors line up. This quantity does."},
   {"text": "The volume of the box built on u and v", "feedback": "A volume needs three vectors. Two of them span a flat region."},
   {"text": "The area of the parallelogram defined by u and v", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): one full computation of each product, and what it means.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 11, 'Medium',
 'Compute [3, -4] + 2[-1, 6].',
 '[{"text": "[4, 4]", "feedback": "The scalar was applied to the first vector as well as the second."},
   {"text": "[1, 8]", "feedback": "Correct."},
   {"text": "[1, -8]", "feedback": "The negative sign from the first vector was carried down into the second component instead of being added in."},
   {"text": "[2, 2]", "feedback": "The scalar 2 was never applied. It multiplies BOTH components of the second vector."}]'::jsonb,
 1, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 12, 'Medium',
 'What is the unit vector in the direction of [3, -4]?',
 '[{"text": "[0.6, -0.8]", "feedback": "Correct."},
   {"text": "[3, -4]", "feedback": "Its magnitude is 5, not 1. It has to be divided by that magnitude first."},
   {"text": "[-0.6, 0.8]", "feedback": "The magnitude is right but the direction is reversed. Dividing by a positive length cannot flip a vector."},
   {"text": "[0.8, -0.6]", "feedback": "The two components were swapped. Each one is divided by the magnitude in place."}]'::jsonb,
 0, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 13, 'Medium',
 'What does the dot product of a vector u with itself equal?',
 '[{"text": "The magnitude of u", "feedback": "The square root was taken one step too early. Each component is squared and the results are added, with no root at the end."},
   {"text": "Twice the magnitude of u", "feedback": "The dot product multiplies corresponding components; it does not double anything."},
   {"text": "Zero", "feedback": "That would need u to be perpendicular to itself, which only the zero vector manages."},
   {"text": "The square of the magnitude of u", "feedback": "Correct."}]'::jsonb,
 3, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 14, 'Medium',
 'What is the angle between [4, 5, 2] and [3, 2, 7], to one decimal place?',
 '[{"text": "133.0 degrees", "feedback": "A sign was lost somewhere. The dot product here is positive, so the angle has to be acute."},
   {"text": "36.0 degrees", "feedback": "That is the dot product itself, read as though it were already an angle. It still has to be divided by both magnitudes."},
   {"text": "47.0 degrees", "feedback": "Correct."},
   {"text": "43.0 degrees", "feedback": "The inverse SINE was taken instead of the inverse cosine, which gives the complement of the angle wanted."}]'::jsonb,
 2, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 15, 'Medium',
 E'A force F = [300, 700, 500] newtons moves an object through a displacement d = [3, 1, 12] metres.\nHow much work is done?',
 '[{"text": "7600 J", "feedback": "Correct."},
   {"text": "6000 J", "feedback": "Only the third pair of components was multiplied. All three pairs contribute to the work."},
   {"text": "900 J", "feedback": "Only the first pair of components was multiplied."},
   {"text": "1500 J", "feedback": "Only the force components were added up. The displacement has to be paired with them component by component."}]'::jsonb,
 0, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 16, 'Medium',
 'What is the distance between the points (1, 2, 3) and (4, 6, 3)?',
 '[{"text": "25", "feedback": "The square root was never taken."},
   {"text": "3", "feedback": "Only the x-difference was used. The y-coordinates differ as well."},
   {"text": "5", "feedback": "Correct."},
   {"text": "7", "feedback": "The differences were added rather than squared and rooted."}]'::jsonb,
 2, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 17, 'Medium',
 'If p = [-1, 3, 2] and q = [2, -5, 6], what is p cross q?',
 '[{"text": "[28, -10, -1]", "feedback": "The middle component came out with the wrong sign. It is the one built the opposite way round from the other two."},
   {"text": "[-2, -15, 12]", "feedback": "The components were multiplied straight across. A cross product pairs each component with the OTHER two."},
   {"text": "[28, 10, -1]", "feedback": "Correct."},
   {"text": "[-28, -10, 1]", "feedback": "The order was reversed. That is q cross p, which points the opposite way."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 18, 'Medium',
 'Two non-zero vectors have a cross product equal to the zero vector. What does that tell you?',
 '[{"text": "They are equal", "feedback": "Equal vectors do give a zero cross product, but so do many pairs that are not equal. The condition is weaker than that."},
   {"text": "They are both unit vectors", "feedback": "Length has nothing to do with it. Two unit vectors at any angle other than zero or 180 degrees give a non-zero cross product."},
   {"text": "They are collinear, lying along the same line", "feedback": "Correct."},
   {"text": "They are perpendicular", "feedback": "Perpendicular vectors give the LARGEST possible cross product for their lengths. It is the DOT product that vanishes at right angles."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 19, 'Medium',
 'What is the area of the parallelogram defined by u = [4, 5, 2] and v = [3, 2, 7], to two decimal places?',
 '[{"text": "19.33", "feedback": "That is the area of the TRIANGLE. The parallelogram is twice as big."},
   {"text": "1494.00", "feedback": "The square root was never taken. That is the sum of the squares of the components of the cross product."},
   {"text": "36.00", "feedback": "That is the DOT product of the two vectors. Area comes from the cross product."},
   {"text": "38.65", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 20, 'Medium',
 'What is the area of the TRIANGLE defined by u = [4, 5, 2] and v = [3, 2, 7], to two decimal places?',
 '[{"text": "9.66", "feedback": "The parallelogram area was quartered. Halving it once is enough."},
   {"text": "19.33", "feedback": "Correct."},
   {"text": "38.65", "feedback": "That is the area of the parallelogram. A triangle is half of it."},
   {"text": "77.30", "feedback": "The parallelogram area was doubled rather than halved."}]'::jsonb,
 1, 'sub-cross-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): solve for a component, or read a picture. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 21, 'Challenge',
 'For what value of k are [2, k] and [6, 9] parallel?',
 '[{"text": "k = 27", "feedback": "The scale factor between the two vectors was applied in the wrong direction. It carries the first vector onto the second, and here you need to come back the other way."},
   {"text": "k = 4.5", "feedback": "The second component of one vector was divided by the FIRST component of the other. Matching components have to be compared with matching components."},
   {"text": "k = 3", "feedback": "Correct."},
   {"text": "k = -3", "feedback": "A sign was flipped. Both given vectors have positive first components, so the scalar linking them is positive."}]'::jsonb,
 2, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 22, 'Challenge',
 E'A vector has magnitude 10 and makes an angle of 30 degrees with the positive x-axis.\nWhat is it in component form, to two decimal places?',
 '[{"text": "[8.66, 5.00]", "feedback": "Correct."},
   {"text": "[5.00, 8.66]", "feedback": "The two components were swapped. Cosine reaches the side beside the angle, which is the horizontal one."},
   {"text": "[10.00, 30.00]", "feedback": "The magnitude and the angle were written down as though they were components. They still have to be resolved."},
   {"text": "[5.77, 5.00]", "feedback": "Tangent was used for the first component. Tangent compares the two components with each other, not either one with the magnitude."}]'::jsonb,
 0, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 23, 'Challenge',
 'For what value of k are [2, k, 3] and [4, -1, 2] perpendicular?',
 '[{"text": "k = 14", "feedback": "Correct."},
   {"text": "k = -14", "feedback": "A sign was flipped when isolating. The middle term of the dot product is negative k, so moving it across makes k positive."},
   {"text": "k = 2", "feedback": "The sign of the third term was flipped, so that product was taken away instead of added."},
   {"text": "k = -2", "feedback": "Two signs went astray at once: the middle term was taken as positive k and the third product was subtracted."}]'::jsonb,
 0, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 24, 'Challenge',
 E'Vectors u and v have magnitudes 5 and 8, with an angle of 60 degrees between them.\nWhat is u dot v?',
 '[{"text": "34.64", "feedback": "Sine was used where cosine belongs. Sine is what appears in the magnitude of the CROSS product."},
   {"text": "40", "feedback": "The two magnitudes were multiplied and the angle was ignored. That is the answer only when the two point the same way."},
   {"text": "3", "feedback": "The magnitudes were subtracted. A dot product multiplies them and then scales by the cosine."},
   {"text": "20", "feedback": "Correct."}]'::jsonb,
 3, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 25, 'Challenge',
 E'The diagram shows the projection of a onto b: the piece of the line carrying b that reaches the foot of the perpendicular from the head of a.\nWhich formula produces that piece?',
 '[{"text": "(a dot b divided by a dot a) times a", "feedback": "That produces a piece lying along A, not along b. The picture shows the result on the other line."},
   {"text": "(a dot b) times b", "feedback": "The scaling is wrong. Without dividing by b dot b the result grows with the SQUARE of the length of b."},
   {"text": "a dot b divided by the magnitude of b", "feedback": "That is a number, the length of the projection. The picture shows a vector, so a direction has to be attached to it."},
   {"text": "(a dot b divided by b dot b) times b", "feedback": "Correct."}]'::jsonb,
 3, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 26, 'Challenge',
 E'Let v = [4, 2, 7] and u = [6, 3, 8].\nWhat is the MAGNITUDE of the projection of v onto u, to three decimal places?',
 '[{"text": "4.734", "feedback": "That is the FIRST COMPONENT of the projection vector. Its magnitude uses all three components."},
   {"text": "8.237", "feedback": "Correct."},
   {"text": "10.440", "feedback": "That is the magnitude of u itself. The projection is shorter, because only part of v lies along it."},
   {"text": "86.000", "feedback": "That is the dot product of the two vectors, before any dividing has been done."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 27, 'Challenge',
 'What is the vector from the point (1, -2, 4) to the point (-3, 0, 5)?',
 '[{"text": "[-2, -2, 9]", "feedback": "The two points were added. A vector between points comes from subtracting the start from the finish."},
   {"text": "[-4, -2, 1]", "feedback": "The middle component kept the sign it carried in the starting point instead of being subtracted at all."},
   {"text": "[-4, 2, 1]", "feedback": "Correct."},
   {"text": "[4, -2, -1]", "feedback": "The subtraction went the wrong way round. That vector points from the second point back to the first."}]'::jsonb,
 2, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 28, 'Challenge',
 E'The diagram shows two vectors a and b lying in the plane of the page, with b turned counter-clockwise from a.\nIn which direction does a cross b point?',
 '[{"text": "Along a", "feedback": "A cross product is perpendicular to BOTH of the vectors it came from, so it cannot lie along either one."},
   {"text": "Along b", "feedback": "A cross product is perpendicular to BOTH of the vectors it came from, so it cannot lie along either one."},
   {"text": "Out of the page", "feedback": "Correct."},
   {"text": "Into the page", "feedback": "That is the direction of b cross a. Point your fingers along a and curl them towards b, and the thumb goes the other way."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 29, 'Challenge',
 'Evaluate the triple scalar product (u cross v) dot w for u = [4, 3, 1], v = [2, 5, 6] and w = [10, -3, -14].',
 '[{"text": "0", "feedback": "Correct."},
   {"text": "130", "feedback": "Only the first pair of components was multiplied in the final dot product. All three pairs contribute."},
   {"text": "-196", "feedback": "Only the third pair of components was multiplied in the final dot product."},
   {"text": "66", "feedback": "Only the middle pair of components was multiplied in the final dot product."}]'::jsonb,
 0, 'sub-cross-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 30, 'Challenge',
 'Three non-zero vectors have a triple scalar product of zero. What does that tell you?',
 '[{"text": "They are mutually perpendicular", "feedback": "Three mutually perpendicular vectors build the largest possible box for their lengths, so their triple scalar product is as far from zero as it gets."},
   {"text": "They are all unit vectors", "feedback": "Length has nothing to do with it. The quantity measures a volume, and a volume can vanish at any length."},
   {"text": "Two of them are equal", "feedback": "That would force it to zero, but so would many arrangements where no two are equal. The condition is weaker than that."},
   {"text": "They all lie in the same plane", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): build a vector to order, or carry a product through an
-- application with units attached. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Algebraic Vectors', 5, 31, 'Advanced',
 E'Let u = [2, -1] and v = [3, 4].\nWrite w = [12, 5] in the form a times u plus b times v.',
 '[{"text": "w = -3u + 2v", "feedback": "A sign was flipped on the first coefficient. That would make the first component zero."},
   {"text": "w = 3u + 2v", "feedback": "Correct."},
   {"text": "w = 2u + 3v", "feedback": "The two coefficients were swapped. Substitute this back and the first component comes out as 13, not 12."},
   {"text": "w = 3u - 2v", "feedback": "A sign was flipped. With a minus here the second component comes out as negative 11."}]'::jsonb,
 1, 'sub-cartesian-vectors'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 32, 'Advanced',
 'What is the angle between [1, 1, 0] and [0, 1, 1]?',
 '[{"text": "60 degrees", "feedback": "Correct."},
   {"text": "45 degrees", "feedback": "Only one of the two magnitudes was divided out. Both vectors have length root 2, and the dot product has to be divided by each of them in turn."},
   {"text": "90 degrees", "feedback": "The dot product is 1, not zero, so the two are not perpendicular. They share a component."},
   {"text": "120 degrees", "feedback": "A sign was lost. The dot product here is positive, so the angle has to be acute."}]'::jsonb,
 0, 'sub-dot-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 33, 'Advanced',
 E'A force F = [300, 700, 500] newtons moves an object through d = [3, 1, 12] metres. Gravity acts along the negative z-axis.\nHow much work is done against gravity?',
 '[{"text": "500 J", "feedback": "That is the vertical component of the force on its own. It still has to be multiplied by the vertical distance moved."},
   {"text": "6000 J", "feedback": "Correct."},
   {"text": "7600 J", "feedback": "That is the total work in the direction of travel. Work against gravity uses only the VERTICAL components."},
   {"text": "1600 J", "feedback": "The two horizontal pairs were used and the vertical one was left out. It is the only pair that matters here."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 34, 'Advanced',
 'The dot product of a with b comes out negative. What does that say about the projection of a onto b?',
 '[{"text": "It is longer than a", "feedback": "A projection is never longer than the vector being projected, whatever the sign of the dot product."},
   {"text": "It points in the opposite direction to b", "feedback": "Correct."},
   {"text": "It is the zero vector", "feedback": "That happens when the dot product is exactly zero. A negative value still leaves something to project."},
   {"text": "The two vectors are perpendicular", "feedback": "Perpendicular vectors give a dot product of exactly zero, not a negative one."}]'::jsonb,
 1, 'sub-dot-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 35, 'Advanced',
 'What is the unit vector in the direction of [1, 2, 2]?',
 '[{"text": "[1/3, 2/3, 2/3]", "feedback": "Correct."},
   {"text": "[1, 2, 2]", "feedback": "Its magnitude is 3, not 1. It has to be divided by that magnitude first."},
   {"text": "[1/9, 2/9, 2/9]", "feedback": "The components were divided by the SQUARE of the magnitude. The square root was never taken."},
   {"text": "[1/5, 2/5, 2/5]", "feedback": "The components were added to get the divisor. A magnitude squares each one first."}]'::jsonb,
 0, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 36, 'Advanced',
 'What vector has magnitude 6 and points in the direction of [1, 2, 2]?',
 '[{"text": "[2, 4, 4]", "feedback": "Correct."},
   {"text": "[6, 12, 12]", "feedback": "The original was multiplied by 6 without being reduced to unit length first. Its magnitude is already 3, so this one has magnitude 18."},
   {"text": "[3, 6, 6]", "feedback": "The original was tripled instead. That gives a magnitude of 9."},
   {"text": "[1, 2, 2]", "feedback": "That is the original, whose magnitude is 3 rather than 6."}]'::jsonb,
 0, 'sub-vectors-3space'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 37, 'Advanced',
 E'Vectors u and v have magnitudes 30 and 20, with an angle of 40 degrees between them.\nWhat is the magnitude of u cross v, to two decimal places?',
 '[{"text": "459.63", "feedback": "Cosine was used where sine belongs. Cosine is what appears in the DOT product."},
   {"text": "600.00", "feedback": "The two magnitudes were multiplied and the angle was ignored. That is the answer only when the two are perpendicular."},
   {"text": "192.84", "feedback": "The result was halved, as though a triangle had been asked for. The magnitude of a cross product is the whole parallelogram."},
   {"text": "385.67", "feedback": "Correct."}]'::jsonb,
 3, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 38, 'Advanced',
 'How are u cross v and v cross u related?',
 '[{"text": "They are perpendicular to each other", "feedback": "Both are perpendicular to the same plane, so they lie on the same line rather than at right angles."},
   {"text": "One is a vector and the other is a scalar", "feedback": "Both are vectors. It is the dot product that returns a number."},
   {"text": "Each one is exactly the opposite of the other", "feedback": "Correct."},
   {"text": "They are equal", "feedback": "Order matters for a cross product, unlike a dot product. Swapping the two flips the result."}]'::jsonb,
 2, 'sub-cross-product'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 39, 'Advanced',
 E'The diagram shows a wrench. A force of 60 N is applied at 80 degrees to the handle, 20 cm from the centre of the bolt.\nWhat is the magnitude of the torque, to two decimal places?',
 '[{"text": "1181.77 N m", "feedback": "The 20 cm was never converted to metres. Torque is measured in newton metres."},
   {"text": "11.82 N m", "feedback": "Correct."},
   {"text": "12.00 N m", "feedback": "The angle was ignored, as though the force were exactly perpendicular to the handle. At 80 degrees a little of it is wasted along the handle."},
   {"text": "2.08 N m", "feedback": "Cosine was used where sine belongs. Only the part of the force ACROSS the handle turns the bolt."}]'::jsonb,
 1, 'sub-cross-applications'),

(12, 'MCV4U', 'Algebraic Vectors', 5, 40, 'Advanced',
 'What is the volume of the parallelepiped defined by a = [6, 3, -2], b = [-4, 6, 9] and c = [3, 3, -11]?',
 '[{"text": "1098", "feedback": "The result was doubled. That step belongs to going from a triangle to a parallelogram, not here."},
   {"text": "183", "feedback": "The result was divided by 3, as though a pyramid had been asked for. The parallelepiped is the whole box."},
   {"text": "549", "feedback": "Correct."},
   {"text": "-549", "feedback": "A volume is never negative. The triple scalar product can come out either way, and its absolute value is taken."}]'::jsonb,
 2, 'sub-cross-applications');
