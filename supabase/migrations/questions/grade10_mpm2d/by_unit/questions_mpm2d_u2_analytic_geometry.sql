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

delete from questions where course_code = 'MPM2D' and unit = 'Analytic geometry';

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

(10, 'MPM2D', 'Analytic geometry', 2, 1, 'Easy',
 'What is the midpoint of the segment from A(2, 3) to B(8, 7)?',
 '[{"text": "(5, 5)", "feedback": "Correct."}, {"text": "(3, 2)", "feedback": "That halves the DIFFERENCE of the endpoints. Both endpoints share in the average: add first, then halve."}, {"text": "(6, 4)", "feedback": "That is the run and the rise from A to B. Subtracting gives a displacement, not a point on the segment."}, {"text": "(10, 10)", "feedback": "The coordinates were added but not divided by 2. A midpoint is an average."}]'::jsonb, 0, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 2, 'Easy',
 'The run of a segment is 3 and the rise is 4. What is its length?',
 '[{"text": "7", "feedback": "3 + 4 adds the legs. The length is the hypotenuse: square, add, then square root."}, {"text": "12", "feedback": "3 times 4 is an area, not a distance. Use the Pythagorean theorem."}, {"text": "25", "feedback": "That is the length SQUARED. Take the square root at the end."}, {"text": "5", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 3, 'Easy',
 'What is the midpoint of the segment from (-1, 2) to (3, -4)?',
 '[{"text": "(1, 1)", "feedback": "Watch the signs in the y average: 2 + (-4) is negative, so halving it cannot leave a positive number."}, {"text": "(2, -2)", "feedback": "The x coordinates average to 1, not 2: -1 + 3 is 2, halved."}, {"text": "(2, -3)", "feedback": "That is half the DIFFERENCE of the endpoints. A midpoint averages them: add, then halve."}, {"text": "(1, -1)", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 4, 'Easy',
 'A median of a triangle joins a vertex to which point?',
 '[{"text": "The closest point on the opposite side", "feedback": "Closest point describes the altitude, which meets the side at a right angle."}, {"text": "The opposite vertex", "feedback": "Vertex to vertex is just a side of the triangle."}, {"text": "The midpoint of an adjacent side", "feedback": "A median crosses the triangle to the side OPPOSITE the vertex."}, {"text": "The midpoint of the opposite side", "feedback": "Correct."}]'::jsonb, 3, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 5, 'Easy',
 'A line has slope 2/3. What is the slope of a line perpendicular to it?',
 '[{"text": "3/2", "feedback": "The reciprocal alone is not enough — perpendicular slopes are NEGATIVE reciprocals."}, {"text": "2/3", "feedback": "Equal slopes make parallel lines, not perpendicular ones."}, {"text": "-2/3", "feedback": "The sign flipped but the fraction did not. Flip the fraction as well."}, {"text": "-3/2", "feedback": "Correct."}]'::jsonb, 3, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 6, 'Easy',
 'What is the equation of a circle centred at the origin with radius 6?',
 '[{"text": "x² + y² = 6", "feedback": "The right side is r SQUARED. The radius itself does not sit there."}, {"text": "x² + y² = 36", "feedback": "Correct."}, {"text": "x + y = 36", "feedback": "Both variables are squared in a circle equation. Without the squares this is a line."}, {"text": "x² + y² = 12", "feedback": "12 is the diameter, and the equation wants the radius squared: 6 times 6."}]'::jsonb, 1, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 7, 'Easy',
 'The circle x² + y² = 25 has what radius?',
 '[{"text": "12.5", "feedback": "The 25 is not halved — it is square rooted."}, {"text": "25", "feedback": "25 is r squared. The radius is its square root."}, {"text": "5", "feedback": "Correct."}, {"text": "10", "feedback": "10 would be the DIAMETER. The equation gives the radius directly, as the root of 25."}]'::jsonb, 2, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 8, 'Easy',
 'Is the point (3, 4) on the circle x² + y² = 25?',
 '[{"text": "Yes, because 3² + 4² = 25", "feedback": "Correct."}, {"text": "No, because 3² + 4² = 7", "feedback": "Check the squares: 3² is 9 and 4² is 16, and squares add, not their roots."}, {"text": "Yes, because 3 and 4 are both less than 25", "feedback": "Being small does not put a point ON a circle. Substitute into the equation."}, {"text": "No, because 3 + 4 is not 25", "feedback": "The coordinates are squared before adding. 9 + 16 makes the call."}]'::jsonb, 0, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 9, 'Easy',
 'An altitude of a triangle meets the opposite side at what angle?',
 '[{"text": "45 degrees", "feedback": "45 is a special case that rarely happens. The definition says perpendicular."}, {"text": "60 degrees", "feedback": "60 belongs to equilateral corners. An altitude is defined by the RIGHT angle it makes."}, {"text": "The same angle as at the vertex", "feedback": "The angle at the foot is fixed at 90, whatever the vertex angle is."}, {"text": "90 degrees", "feedback": "Correct."}]'::jsonb, 3, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 10, 'Easy',
 'Which tool decides whether two segments are parallel?',
 '[{"text": "Check whether they share an endpoint", "feedback": "Sharing a point makes segments MEET — the opposite of parallel."}, {"text": "Compare their slopes", "feedback": "Correct."}, {"text": "Compare their lengths", "feedback": "Equal lengths can point anywhere. Parallel is about direction, which slope measures."}, {"text": "Compare their midpoints", "feedback": "Midpoints locate centres, not directions."}]'::jsonb, 1, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 11, 'Medium',
 'What is the exact length of the segment from (-3, 5) to (7, -1)?',
 '[{"text": "√136", "feedback": "Correct."}, {"text": "√64", "feedback": "The squares of the run and the rise are added under the root, not subtracted."}, {"text": "136", "feedback": "That is the length squared. The square root finishes the job."}, {"text": "16", "feedback": "10 + 6 adds rise and run instead of squaring them. Pythagoras first."}]'::jsonb, 0, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 12, 'Medium',
 'Triangle ABC has A(2, 8), B(-4, 2), C(6, 0). The median from A goes to which point?',
 '[{"text": "(-1, 5)", "feedback": "That is the midpoint of AB. The median from A crosses to the midpoint of BC, the OPPOSITE side."}, {"text": "(4, 4)", "feedback": "That is the midpoint of AC. From A, the opposite side is BC."}, {"text": "(2, 2)", "feedback": "Average the endpoints of BC, x with x and y with y — add, then halve."}, {"text": "(1, 1)", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 13, 'Medium',
 'The median from A(2, 8) to (1, 1) has what slope?',
 '[{"text": "9", "feedback": "The coordinates SUBTRACT: 1 - 8 and 1 - 2, not 1 + 8."}, {"text": "-7", "feedback": "Both differences are negative, and a negative over a negative is positive."}, {"text": "7", "feedback": "Correct."}, {"text": "1/7", "feedback": "That is run over rise. Slope is rise over run: (1 - 8) over (1 - 2)."}]'::jsonb, 2, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 14, 'Medium',
 'The right bisector of the segment from (1, 3) to (7, 5) has what slope?',
 '[{"text": "-1/3", "feedback": "The sign flipped but the fraction did not. Flip the fraction as well: the reciprocal of 1/3 is 3."}, {"text": "3", "feedback": "The reciprocal was taken but the sign was not flipped. Perpendicular slopes are negative reciprocals."}, {"text": "-3", "feedback": "Correct."}, {"text": "1/3", "feedback": "That is the slope of the segment ITSELF. The bisector is perpendicular to it."}]'::jsonb, 2, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 15, 'Medium',
 'A right bisector of a segment must pass through which point?',
 '[{"text": "The vertex of the triangle", "feedback": "A right bisector belongs to a segment and needs no triangle at all."}, {"text": "The midpoint of the segment", "feedback": "Correct."}, {"text": "The origin", "feedback": "Only by coincidence. The defining point is the middle of the segment."}, {"text": "One of the endpoints", "feedback": "Through an endpoint at 90 degrees is a different line. Bisector means it CUTS the segment in half."}]'::jsonb, 1, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 16, 'Medium',
 'What is the equation of the circle centred at the origin passing through (-8, 6)?',
 '[{"text": "x² + y² = -28", "feedback": "Squares cannot be negative. The square of -8 is +64."}, {"text": "x² + y² = 10", "feedback": "10 is the radius. The equation carries the radius SQUARED."}, {"text": "x² + y² = 100", "feedback": "Correct."}, {"text": "x² + y² = 28", "feedback": "The coordinates square to 64 and 36 before adding — they do not add first."}]'::jsonb, 2, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 17, 'Medium',
 'Where is the point (5, -2) relative to the circle x² + y² = 25?',
 '[{"text": "On the circle, because 5² + (-2)² = 25", "feedback": "Check that sum: 25 + 4 is 29, not 25."}, {"text": "On the circle, because x = 5", "feedback": "One coordinate matching the radius means nothing on its own. Substitute BOTH into x² + y²."}, {"text": "Inside, because -2 is small", "feedback": "The y value squares to +4 and still counts. Compare 29 with 25."}, {"text": "Outside, because 25 + 4 is greater than 25", "feedback": "Correct."}]'::jsonb, 3, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 18, 'Medium',
 'Triangle with vertices (0, 0), (4, 0) and (2, 6) is best described as what?',
 '[{"text": "Isosceles, because two sides have equal length", "feedback": "Correct."}, {"text": "Scalene, because the vertices are all different", "feedback": "Different vertices are guaranteed in any triangle. Compare the side LENGTHS."}, {"text": "Right angled at (2, 6)", "feedback": "Check the slopes from (2, 6): 3 and -3 multiply to -9, not -1."}, {"text": "Equilateral, because it looks even", "feedback": "Looks are not a proof. The base is 4 but the other two sides are √40 — only TWO match."}]'::jsonb, 0, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 19, 'Medium',
 'M and N are midpoints of two sides of a triangle. The segment MN compares to the third side how?',
 '[{"text": "Perpendicular to it", "feedback": "A midsegment runs alongside the third side, never across it."}, {"text": "Parallel to it and half its length", "feedback": "Correct."}, {"text": "Parallel to it and equal in length", "feedback": "Equal length would make a parallelogram of the whole triangle. The midsegment is HALF."}, {"text": "Half its length but at a different slope", "feedback": "Same slope is the whole point — the midpoints preserve direction."}]'::jsonb, 1, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 20, 'Medium',
 'To verify the diagonals of a parallelogram bisect each other, what should be compared?',
 '[{"text": "The midpoints of the two opposite sides", "feedback": "The claim is about the diagonals, so their midpoints are what must coincide."}, {"text": "The slopes of each of the two diagonals", "feedback": "Slopes test parallel or perpendicular, not cutting in half."}, {"text": "The lengths of each of the two diagonals", "feedback": "Diagonals of a parallelogram are usually DIFFERENT lengths. Bisecting is about midpoints."}, {"text": "The midpoints of the two diagonals", "feedback": "Correct."}]'::jsonb, 3, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 21, 'Challenge',
 'What is the equation of the right bisector of the segment from (1, 3) to (7, 5)?',
 '[{"text": "y = -3x + 4", "feedback": "The line passes through the MIDPOINT (4, 4): substitute it to find the intercept."}, {"text": "y = -3x + 16", "feedback": "Correct."}, {"text": "y = 3x - 8", "feedback": "The sign of the slope flips as well as the fraction: perpendicular to 1/3 is -3."}, {"text": "y = (1/3)x + 8/3", "feedback": "That slope belongs to the segment itself. The bisector uses the negative reciprocal."}]'::jsonb, 1, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 22, 'Challenge',
 'Triangle has A(1, 7), B(-2, 1), C(6, 5). What is the equation of the altitude from A?',
 '[{"text": "y = -2x + 9", "feedback": "Correct."}, {"text": "y = -2x + 5", "feedback": "The altitude passes through A(1, 7): substituting x = 1 must give 7."}, {"text": "y = 2x + 5", "feedback": "The perpendicular slope keeps the flipped fraction AND the flipped sign: -2, not 2."}, {"text": "y = (1/2)x + 13/2", "feedback": "That line is PARALLEL to BC. An altitude is perpendicular to it."}]'::jsonb, 0, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 23, 'Challenge',
 'How many points do the line y = 7 and the circle x² + y² = 25 share?',
 '[{"text": "None", "feedback": "Correct."}, {"text": "Infinitely many", "feedback": "A line and a circle can share at most two points."}, {"text": "One", "feedback": "One point would need the line to just touch at y = 5 or y = -5."}, {"text": "Two", "feedback": "The circle only reaches heights between -5 and 5. A line at height 7 passes above it."}]'::jsonb, 0, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 24, 'Challenge',
 'Which point lies INSIDE the circle x² + y² = 40?',
 '[{"text": "(5, 4)", "feedback": "5² + 4² is 41, just past 40 — that point is OUTSIDE."}, {"text": "(6, 2)", "feedback": "36 + 4 lands exactly ON the circle, not inside it."}, {"text": "(3, 5)", "feedback": "Correct."}, {"text": "(7, 0)", "feedback": "49 alone already beats 40. Outside."}]'::jsonb, 2, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 25, 'Challenge',
 'Triangle has A(-1, 2), B(3, 4), C(5, 0). Where is its right angle?',
 '[{"text": "It has no right angle", "feedback": "One pair of sides here does meet at a right angle. Test the slopes at each vertex before ruling it out."}, {"text": "At A, because A has a negative coordinate", "feedback": "A negative coordinate says nothing about angles. Multiply slopes of the meeting sides."}, {"text": "At B, because the slopes of AB and BC multiply to -1", "feedback": "Correct."}, {"text": "At C, because C is on the x axis", "feedback": "Sitting on an axis does not create a right angle."}]'::jsonb, 2, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 26, 'Challenge',
 'A triangle has B(1, -6) and C(5, 2). The midsegment parallel to BC has what exact length?',
 '[{"text": "√80", "feedback": "That is BC itself. The midsegment is HALF that length — and halving a length is not the same as halving the number under the root."}, {"text": "6", "feedback": "That adds the rise 8 and the run 4 instead of squaring them, then halves. Use Pythagoras on BC first."}, {"text": "√40", "feedback": "Halving the number under the root does not halve the length. Write half of √80 as one root and simplify it properly."}, {"text": "√20", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 27, 'Challenge',
 'A line from a vertex meets the opposite side at its midpoint but NOT at 90 degrees. What is it?',
 '[{"text": "A right bisector", "feedback": "A right bisector needs the 90 degrees as well as the midpoint — and it need not pass through a vertex."}, {"text": "A median only", "feedback": "Correct."}, {"text": "An altitude", "feedback": "An altitude is defined by the right angle, which is exactly what this line lacks."}, {"text": "Both a median and an altitude", "feedback": "Both at once only happens in special triangles, and the 90 degrees is missing here."}]'::jsonb, 1, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 28, 'Challenge',
 'The circle x² + y² = 100 passes through (k, 6). What are the possible values of k?',
 '[{"text": "8 and -8", "feedback": "Correct."}, {"text": "64", "feedback": "64 is k SQUARED. The values of k are its roots."}, {"text": "8 only", "feedback": "A square root has two signs — the negative one squares to the same 64."}, {"text": "94", "feedback": "k² is 100 - 36 = 64. The 36 subtracts, and then the root is taken."}]'::jsonb, 0, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 29, 'Challenge',
 'To prove a quadrilateral is a parallelogram using slopes, what must be shown?',
 '[{"text": "All four sides of the quadrilateral have the same slope", "feedback": "All the same slope would flatten the shape onto one line."}, {"text": "The two diagonals of the quadrilateral have equal slopes", "feedback": "Equal-slope diagonals would be parallel and could never cross inside the shape."}, {"text": "Both pairs of opposite sides have equal slopes", "feedback": "Correct."}, {"text": "Only one pair of opposite sides has equal slopes", "feedback": "One pair only makes a trapezoid. A parallelogram needs both."}]'::jsonb, 2, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 30, 'Challenge',
 'The shortest distance from a point to a line is measured along which path?',
 '[{"text": "The perpendicular from the point to the line", "feedback": "Correct."}, {"text": "The segment to the nearest endpoint of the line", "feedback": "A line has no endpoints. The shortest route always meets it at 90 degrees."}, {"text": "A segment parallel to the line", "feedback": "A parallel path never reaches the line at all."}, {"text": "The segment to the y-intercept of the line", "feedback": "The y-intercept is just one point on the line, rarely the closest one."}]'::jsonb, 0, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 31, 'Advanced',
 'Triangle has A(0, 0), B(4, 4), C(8, 0). Which description fits it completely?',
 '[{"text": "Right angled AND isosceles", "feedback": "Correct."}, {"text": "Equilateral, with all three sides equal", "feedback": "AC is 8 but the other two sides are √32. Not all three match."}, {"text": "Right angled but not isosceles", "feedback": "AB² and BC² are both 32 — two equal sides make it isosceles as well."}, {"text": "Isosceles but not right angled", "feedback": "32 + 32 equals 64, which is AC². Pythagoras confirms a right angle at B too."}]'::jsonb, 0, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 32, 'Advanced',
 'The right bisectors of the three sides of a triangle all cross at one point. What is special about it?',
 '[{"text": "It is the midpoint of the longest side of the triangle", "feedback": "That only happens for right triangles, and only for the hypotenuse."}, {"text": "It is the same distance from each of the three sides", "feedback": "Equal distance from the SIDES belongs to the angle bisectors, a different centre."}, {"text": "It is the same distance from all three vertices", "feedback": "Correct."}, {"text": "It always lies inside the triangle, never outside it", "feedback": "For an obtuse triangle it falls outside. The equal-distance property is what always holds."}]'::jsonb, 2, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 33, 'Advanced',
 'Which point on the y-axis is the same distance from (2, 3) and (6, 1)?',
 '[{"text": "(0, 6)", "feedback": "Check the sign at the end: -24 = 4y gives a NEGATIVE y."}, {"text": "(4, 2)", "feedback": "That is the midpoint of the two points — it is equidistant but not on the y-axis."}, {"text": "(0, -6)", "feedback": "Correct."}, {"text": "(0, 2)", "feedback": "Substitute back: the distances to the two points are √5 and √37 — not equal. Set the squared distances equal and solve."}]'::jsonb, 2, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 34, 'Advanced',
 'Where does the line y = x + 2 meet the circle x² + y² = 10?',
 '[{"text": "(3, 1) and (-1, -3)", "feedback": "The coordinates are swapped: for each x, y is x + 2, so x = 1 gives y = 3."}, {"text": "(2, 4) and (-2, 0)", "feedback": "Substitute back: 4 + 16 is 20, not 10. Substitute y = x + 2 INTO the circle and solve the quadratic."}, {"text": "(1, 3) and (-3, -1)", "feedback": "Correct."}, {"text": "(1, 3) only", "feedback": "A line through the inside of a circle crosses it TWICE — the quadratic after substituting has two roots."}]'::jsonb, 2, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 35, 'Advanced',
 'In the triangle with A(2, 8), B(-4, 2), C(6, 0), what is the exact length of the median from A?',
 '[{"text": "√98", "feedback": "That uses the rise in place of both differences. The run from A to the midpoint is not the same as the rise."}, {"text": "√50", "feedback": "Correct."}, {"text": "50", "feedback": "50 is the squared length. Keep the square root."}, {"text": "√8", "feedback": "Both differences count: run 1 and rise 7 give 1 + 49 under the root."}]'::jsonb, 1, 'sub-midpoint-length'),

(10, 'MPM2D', 'Analytic geometry', 2, 36, 'Advanced',
 'M(0, 0) and N(4, 2) are midpoints of two sides of a triangle whose third side is BC. What is the slope of BC?',
 '[{"text": "2", "feedback": "That is run over rise of MN. Slope is rise over run — and BC copies the slope of MN exactly."}, {"text": "1/2", "feedback": "Correct."}, {"text": "1/4", "feedback": "The midsegment is parallel to BC, so BC takes the SAME slope as MN, not half of it."}, {"text": "1", "feedback": "BC is twice as long as MN, but not twice as steep. A midsegment is parallel to the third side."}]'::jsonb, 1, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 37, 'Advanced',
 'The altitude from A(1, 7) of a triangle is y = -2x + 9. Which point lies on BOTH this altitude and the side BC, where BC is y = (1/2)x + 2?',
 '[{"text": "(2.8, 3.4)", "feedback": "Correct."}, {"text": "(2, 5)", "feedback": "That point is on the altitude only. Substitute into BOTH equations; BC gives 3, not 5."}, {"text": "(3.5, 3.75)", "feedback": "Set -2x + 9 equal to (1/2)x + 2 and collect the x terms carefully — they add to 2.5x, not 2x."}, {"text": "(1, 7)", "feedback": "That is vertex A. The foot of the altitude sits on BC, further down the line."}]'::jsonb, 0, 'sub-median-bisector-altitude'),

(10, 'MPM2D', 'Analytic geometry', 2, 38, 'Advanced',
 'A circle centred at the origin has the segment from (-3, 4) to (3, -4) as a diameter. What is its equation?',
 '[{"text": "x² + y² = 5", "feedback": "5 is the radius itself. Square it for the right side."}, {"text": "x² + y² = 100", "feedback": "100 is the DIAMETER squared. The equation uses the radius: half the diameter, then squared."}, {"text": "x² + y² = 50", "feedback": "That squares the diameter first and halves afterwards. The halving comes before the squaring."}, {"text": "x² + y² = 25", "feedback": "Correct."}]'::jsonb, 3, 'sub-equation-of-circle'),

(10, 'MPM2D', 'Analytic geometry', 2, 39, 'Advanced',
 'Quadrilateral PQRS has P(-2, 1), Q(3, 3), R(4, -1), S(-1, -3). The midpoints of both diagonals are the same point. What does that prove?',
 '[{"text": "PQRS is a rectangle", "feedback": "A rectangle needs right angles as well. Shared diagonal midpoints alone give a parallelogram."}, {"text": "PQRS is a parallelogram", "feedback": "Correct."}, {"text": "PQRS is a rhombus", "feedback": "A rhombus needs equal SIDES on top of the parallelogram property."}, {"text": "Nothing — every quadrilateral does this", "feedback": "Most quadrilaterals do not. Diagonals bisecting each other is exactly the parallelogram test."}]'::jsonb, 1, 'sub-geometry-applications'),

(10, 'MPM2D', 'Analytic geometry', 2, 40, 'Advanced',
 'Of the vertices A(2, 8), B(-4, 2), C(6, 0), which is closest to the origin?',
 '[{"text": "C, at distance 6", "feedback": "C is 6 from the origin, but another vertex is nearer. Work out each distance before choosing."}, {"text": "B, at distance √20", "feedback": "Correct."}, {"text": "B, at distance 2", "feedback": "That takes the coordinate nearer zero as the distance and ignores the -4."}, {"text": "A, because 2 is the smallest coordinate", "feedback": "One small coordinate is not distance. A is √68 away, the farthest of the three."}]'::jsonb, 1, 'sub-midpoint-length');
