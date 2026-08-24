-- ===========================================================================
-- MCV4U — Unit 2: Curve Sketching — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Increasing versus decreasing
--   Lesson 2  Local and absolute maxima and minima
--   Lesson 3  The second derivative and concavity
--   Lesson 4  Rational functions
--   Lesson 5  Curve sketching
--   Lesson 6  Optimization
--
-- Six lessons, six subtopics. The split that matters most on the dashboard
-- is CRITICAL POINTS against CONCAVITY. Both are about a derivative being
-- zero, and a student who has fused the two will confidently answer that
-- every zero of the second derivative is a point of inflection, and that
-- every critical number is a turning point. Neither is true, and neither
-- shows up as a distinct weakness unless the two are counted separately.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Three of them repeat all through this unit and the dashboard
-- will show them constantly:
--
--   * treating a zero of a derivative as automatically an extremum or an
--     inflection point, without checking that the sign changes
--   * finding the critical x-values and stopping, without substituting them
--     back to get the actual maximum or minimum VALUE
--   * forgetting that on a closed interval the endpoints compete
--
-- Feedback names the mistake and stops there.
--
-- Every derivative, critical number, interval and optimised value in this
-- file was recomputed independently with sympy before delivery; nothing was
-- copied from the source PDFs.
--
-- FIGURES: three, and this is the most visual unit in the course, so that
-- is the honest count rather than a generous one.
--
--   * Q8 shows a curve on a closed interval with five labelled points and
--     asks which is the ABSOLUTE maximum. The tallest local maximum is not
--     it; the left-hand endpoint is higher. No grid and no vertical scale.
--   * Q10 shows the lifeguard rectangle with the beach on the open side.
--     The picture carries which side is not roped, which is the whole setup.
--     It is drawn near square although the answer is two to one, so a
--     student who measures it and trusts the proportion is misled.
--   * Q18 shows the graph of f PRIME crossing the axis at two named values
--     and asks where f has a local maximum. The answer is the sign change,
--     which is the only thing the picture shows.
--
-- Rejected: any sketch of f itself with its features already marked. That
-- is the answer sheet for the unit. Every question about a specific
-- function here is asked from the equation.
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

delete from questions where course_code = 'MCV4U' and unit = 'Curve Sketching';

insert into misconception_labels (tag, label) values
  ('sub-increasing-decreasing', 'Increasing and decreasing intervals'),
  ('sub-critical-extrema',      'Critical numbers and extrema'),
  ('sub-concavity',             'Concavity and the second derivative'),
  ('sub-rational-sketching',    'Sketching rational functions'),
  ('sub-curve-sketching',       'Putting a full sketch together'),
  ('sub-optimization',          'Optimization')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the vocabulary, and one derivative at a time.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 1, 'Easy',
 'If f prime of x is positive throughout an interval, what is f doing on that interval?',
 '[{"text": "Increasing", "feedback": "Correct."},
   {"text": "Decreasing", "feedback": "A positive slope tilts upward as you move to the right, so the values are going up rather than down."},
   {"text": "Concave up", "feedback": "Concavity is decided by the SECOND derivative. The first one only says which way the curve is heading."},
   {"text": "At a maximum", "feedback": "A maximum needs the derivative to be zero and to change sign. Here it is positive right across the interval."}]'::jsonb,
 0, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 2, 'Easy',
 'On which interval is f(x) = x^2 - 6x + 8 decreasing?',
 '[{"text": "x < 0", "feedback": "The vertex was placed at the origin. Setting 2x take away 6 to zero moves it."},
   {"text": "All real numbers", "feedback": "A parabola turns around. It cannot be decreasing on both sides of its vertex."},
   {"text": "x < 3", "feedback": "Correct."},
   {"text": "x > 3", "feedback": "The wrong side of the vertex was taken. To the right of the turning point of an upward parabola the values are climbing."}]'::jsonb,
 2, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 3, 'Easy',
 'What is a critical number of a function f?',
 '[{"text": "Any value where f is undefined", "feedback": "A critical number has to be IN the domain. A vertical asymptote is outside it, so it does not count."},
   {"text": "A value in the domain of f where f prime is zero or does not exist", "feedback": "Correct."},
   {"text": "A value where f itself is zero", "feedback": "That is an x-intercept. It says where the curve crosses the axis, not where it turns."},
   {"text": "A value where the second derivative is zero", "feedback": "That is a candidate for a point of INFLECTION. A critical number comes from the first derivative."}]'::jsonb,
 1, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 4, 'Easy',
 'What is the critical number of f(x) = x^2 - 6x + 8?',
 '[{"text": "x = 8", "feedback": "That is the constant term. Differentiating removes it entirely."},
   {"text": "x = -3", "feedback": "A sign was flipped. Setting 2x take away 6 to zero gives a positive value."},
   {"text": "x = 3", "feedback": "Correct."},
   {"text": "x = 2 and x = 4", "feedback": "Those are the zeros of the FUNCTION. A critical number comes from setting the derivative to zero."}]'::jsonb,
 2, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 5, 'Easy',
 'If f double prime of x is negative throughout an interval, what is the shape of the graph there?',
 '[{"text": "Concave down", "feedback": "Correct."},
   {"text": "Concave up", "feedback": "The sign was read backwards. A positive second derivative is the one that bends the curve upward."},
   {"text": "Decreasing", "feedback": "That is what a negative FIRST derivative gives. The second derivative describes bending, not direction."},
   {"text": "Increasing", "feedback": "Direction comes from the first derivative. A curve can be rising and still bending downward."}]'::jsonb,
 0, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 6, 'Easy',
 'In the second derivative test, if f prime of c is zero and f double prime of c is positive, what is at x = c?',
 '[{"text": "An absolute maximum", "feedback": "The test is local; it only describes the immediate neighbourhood. It also gives the wrong kind of turning point here."},
   {"text": "A local minimum", "feedback": "Correct."},
   {"text": "A local maximum", "feedback": "The two cases were swapped. A curve bending upward at a flat point sits in a valley, not on a hill."},
   {"text": "A point of inflection", "feedback": "An inflection point needs the second derivative to be ZERO and to change sign. Here it is positive."}]'::jsonb,
 1, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 7, 'Easy',
 E'The graph of y = 1/x is concave down to the left of x = 0 and concave up to the right of it.\nIs x = 0 a point of inflection?',
 '[{"text": "Yes, because the second derivative is zero there", "feedback": "The second derivative is not zero at that value; it is undefined, along with the function itself."},
   {"text": "Only if the graph is continuous everywhere else", "feedback": "What happens elsewhere is irrelevant. The test is whether this particular value is in the domain."},
   {"text": "No, because the function is not defined at x = 0", "feedback": "Correct."},
   {"text": "Yes, because the concavity changes there", "feedback": "The concavity does change, but a point of inflection has to BE a point on the curve. There is nothing there to be one."}]'::jsonb,
 2, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 8, 'Easy',
 E'The graph shows a function on the closed interval from 0 to 10, with five points marked.\nWhich point is the ABSOLUTE maximum?',
 '[{"text": "A", "feedback": "Correct."},
   {"text": "C", "feedback": "That is the tallest LOCAL maximum, the highest turning point. On a closed interval the endpoints compete too, and one of them is above it."},
   {"text": "E", "feedback": "That is an endpoint, so it is a candidate, but it is not the highest point on the graph. Compare it with the other end."},
   {"text": "D", "feedback": "That is the lowest point on the whole graph, which makes it the absolute MINIMUM."}]'::jsonb,
 0, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 9, 'Easy',
 'In an optimization problem, once the quantity has been written as a function of a single variable, what is the next step?',
 '[{"text": "Set the second derivative equal to zero and solve", "feedback": "That finds points of inflection. The maximum or minimum is where the FIRST derivative vanishes."},
   {"text": "Substitute the endpoints of the given domain", "feedback": "The endpoints do have to be checked, but only alongside the critical numbers, which have to be found first."},
   {"text": "Set the derivative equal to zero and solve", "feedback": "Correct."},
   {"text": "Set the function itself equal to zero and solve", "feedback": "That finds where the quantity is ZERO, which is usually the worst possible answer rather than the best."}]'::jsonb,
 2, 'sub-optimization'),

(12, 'MCV4U', 'Curve Sketching', 2, 10, 'Easy',
 E'A lifeguard has 200 m of rope to enclose a rectangular swimming area, with the beach forming the fourth side as shown.\nIf each of the two sides perpendicular to the beach is x metres, what is the length of the third roped side?',
 '[{"text": "200 - 2x", "feedback": "Correct."},
   {"text": "200 - x", "feedback": "Only one of the perpendicular sides was subtracted. There are two of them, and both use rope."},
   {"text": "(200 - x)/2", "feedback": "x was taken as the side parallel to the beach, so the leftover rope was split between the other two sides. The prompt puts x on each of the sides perpendicular to the beach."},
   {"text": "100 - x", "feedback": "The full perimeter formula for a four-sided rectangle was used. Here only three sides are roped."}]'::jsonb,
 0, 'sub-optimization'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): a full sign analysis, or an interval that has to be tested.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 11, 'Medium',
 'On which intervals is f(x) = 2x^3 + 3x^2 - 36x + 5 increasing?',
 '[{"text": "-3 < x < 2", "feedback": "The wrong side of the sign chart was chosen. Between the two critical numbers the derivative is negative."},
   {"text": "x < -2 or x > 3", "feedback": "The two critical numbers had their signs swapped when the factored derivative was read out."},
   {"text": "x > 2 only", "feedback": "Only one of the two stretches was found. The derivative is also positive to the left of the smaller critical number."},
   {"text": "x < -3 or x > 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 12, 'Medium',
 'Is f(x) = x^3 + 2 ever decreasing?',
 '[{"text": "Yes, for x > 0", "feedback": "The derivative 3x squared is positive there, so the function is climbing, not falling."},
   {"text": "Yes, at x = 0 only", "feedback": "The derivative is zero at that single point, which makes the tangent flat. A flat tangent at one point is not a decreasing interval."},
   {"text": "No, because its derivative is never negative", "feedback": "Correct."},
   {"text": "Yes, for x < 0", "feedback": "The cubic itself is negative there, but the DERIVATIVE is 3x squared, which cannot be negative for any real x."}]'::jsonb,
 2, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 13, 'Medium',
 'Find the local extrema of f(x) = 2x^3 + 3x^2 - 36x + 5.',
 '[{"text": "Local min at (-3, 86) and local max at (2, -39)", "feedback": "The two classifications were swapped. Check the sign of the second derivative at each critical number, or the sign chart of the first."},
   {"text": "Local max at x = -3 and local min at x = 2, with no y-values", "feedback": "The critical x-values are right but a turning POINT needs both coordinates. Substitute each one back into the original function."},
   {"text": "Local max at (3, 86) and local min at (-2, -39)", "feedback": "Both critical numbers had their signs flipped when the factored derivative was read out."},
   {"text": "Local max at (-3, 86) and local min at (2, -39)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 14, 'Medium',
 'What is the absolute MINIMUM value of f(x) = x^3 - 12x - 3 on the interval from -3 to 4?',
 '[{"text": "-19", "feedback": "Correct."},
   {"text": "6", "feedback": "That is the value at the left endpoint. It is a candidate, but a critical number inside the interval goes lower."},
   {"text": "13", "feedback": "That is the largest value on the interval, so it is the absolute MAXIMUM rather than the minimum."},
   {"text": "-3", "feedback": "That is the constant term of the function, which happens to be its value at zero. Zero is not a critical number here."}]'::jsonb,
 0, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 15, 'Medium',
 'For f(x) = x^4 - 2x^3 - 5, at which values of x is the second derivative equal to zero?',
 '[{"text": "x = 0 and x = 3/2", "feedback": "Those are the values where the FIRST derivative is zero. The question asks about the second."},
   {"text": "x = 1 only", "feedback": "The second derivative factors into 12x times the bracket, and the bare 12x gives a value of its own."},
   {"text": "x = 3/2 only", "feedback": "That value comes from the first derivative, and it is only half of what that one gives anyway."},
   {"text": "x = 0 and x = 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 16, 'Medium',
 E'For f(x) = x^4 the second derivative is zero at x = 0.\nIs x = 0 a point of inflection?',
 '[{"text": "It is an inflection point from the left but not from the right", "feedback": "The second derivative is 12x squared, which is positive on both sides. The bending is the same either way."},
   {"text": "No, because the concavity does not change there", "feedback": "Correct."},
   {"text": "Yes, because the second derivative is zero there", "feedback": "A zero of the second derivative is only a CANDIDATE. It has to be checked for an actual change of concavity, and here there is none."},
   {"text": "Yes, because the first derivative is zero there too", "feedback": "Both derivatives do vanish there, but that makes it a flat point at the bottom of the curve rather than a change of bending."}]'::jsonb,
 1, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 17, 'Medium',
 'On which interval is f(x) = 1/(x - 2) concave up?',
 '[{"text": "x > 2", "feedback": "Correct."},
   {"text": "x < 2", "feedback": "The wrong branch was chosen. Cubing a negative quantity keeps it negative, so the second derivative is negative on that side."},
   {"text": "Everywhere except x = 2", "feedback": "The two branches bend in opposite directions. Only one of them curves upward."},
   {"text": "Nowhere", "feedback": "The second derivative is 2 over the cube of the bracket, which is positive on one side of the asymptote."}]'::jsonb,
 0, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 18, 'Medium',
 E'The graph shows y = f prime of x, crossing the horizontal axis at p and at q.\nAt which value does f itself have a local MAXIMUM?',
 '[{"text": "At q", "feedback": "The derivative goes from negative to positive there, so f stops falling and starts climbing. That is the shape of a valley."},
   {"text": "At the lowest point of the curve shown", "feedback": "That is where f PRIME is smallest, which makes it the steepest downhill point of f. It is a point of inflection on f, not a turning point."},
   {"text": "At neither, because the curve shown has no maximum", "feedback": "The picture is the graph of the DERIVATIVE. What f does is decided by where that graph crosses the axis, not by its own shape."},
   {"text": "At p", "feedback": "Correct."}]'::jsonb,
 3, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 19, 'Medium',
 E'A lifeguard uses 200 m of rope for three sides of a rectangle, the fourth side being the beach.\nWhich dimensions give the maximum enclosed area?',
 '[{"text": "66.7 m by 66.7 m", "feedback": "The rope was split equally between three sides. A square is optimal when all FOUR sides are fenced, which is not the case here."},
   {"text": "50 m by 100 m", "feedback": "Correct."},
   {"text": "50 m by 50 m", "feedback": "The area function was maximised for one variable and then the same value was used for the other. Substitute back into the expression for the third side."},
   {"text": "100 m by 100 m", "feedback": "That uses 300 m of rope on the three sides. Only 200 m is available."}]'::jsonb,
 1, 'sub-optimization'),

(12, 'MCV4U', 'Curve Sketching', 2, 20, 'Medium',
 'Why must the endpoints be tested in an optimization problem on a restricted domain?',
 '[{"text": "The second derivative test always fails at an endpoint", "feedback": "The test is about classifying interior critical points. The reason endpoints matter is that they are candidates in their own right."},
   {"text": "The largest or smallest value can occur at an endpoint, where the derivative need not be zero", "feedback": "Correct."},
   {"text": "The derivative is always undefined at an endpoint", "feedback": "That is not generally true, and it would not matter if it were. The reason is that the extreme value can simply sit there."},
   {"text": "Critical numbers can never be maxima or minima", "feedback": "They very often are. Endpoints are checked ALONGSIDE them, not instead of them."}]'::jsonb,
 1, 'sub-optimization'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): rational functions, awkward derivatives, and a full
-- optimization. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 21, 'Challenge',
 'On which interval is f(x) = x/(x^2 + 1) increasing?',
 '[{"text": "x < -1 or x > 1", "feedback": "The wrong side of the sign chart was chosen. The numerator of the derivative is 1 take away x squared, which is negative out there."},
   {"text": "x > 0", "feedback": "The function is odd, so it behaves the same way on both sides of the origin. The turning points are what bound the interval."},
   {"text": "Everywhere", "feedback": "The derivative does change sign. Its numerator is a difference of squares, which has two zeros."},
   {"text": "-1 < x < 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 22, 'Challenge',
 'Describe the intervals of increase and decrease for f(x) = x^(2/3).',
 '[{"text": "Increasing everywhere", "feedback": "The graph has a sharp point at the origin with a valley either side. It cannot be climbing on both sides of that."},
   {"text": "Decreasing everywhere", "feedback": "Once past the origin the cube root is positive, so the derivative is positive and the curve climbs."},
   {"text": "Decreasing for x < 0 and increasing for x > 0", "feedback": "Correct."},
   {"text": "Increasing for x < 0 and decreasing for x > 0", "feedback": "The two sides were swapped. The derivative is 2 over 3 times the cube root of x, which is negative when x is negative."}]'::jsonb,
 2, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 23, 'Challenge',
 E'For f(x) = x^(2/3), the derivative does not exist at x = 0.\nIs x = 0 a critical number?',
 '[{"text": "No, because the derivative does not exist there", "feedback": "That is exactly the second way a critical number arises. A cusp is a critical point, and this function has one."},
   {"text": "No, because f of 0 is zero", "feedback": "The VALUE of the function has nothing to do with it. What matters is whether the value is in the domain and what the derivative does."},
   {"text": "Only if the second derivative exists there", "feedback": "Critical numbers are decided by the first derivative alone. The second is not consulted."},
   {"text": "Yes, because the derivative fails to exist there and f itself is defined there", "feedback": "Correct."}]'::jsonb,
 3, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 24, 'Challenge',
 E'A cylinder of surface area 100 cm^2 has volume V(r) = 50r - pi r^3, where the radius cannot exceed 3 cm.\nWhat is the maximum volume, to one decimal place?',
 '[{"text": "2.3 cm^3", "feedback": "That is the RADIUS that maximises the volume, not the volume itself. It still has to be substituted back."},
   {"text": "150.0 cm^3", "feedback": "Only the first term of the volume function was evaluated at r equals 3. The cubic term takes a large amount back off."},
   {"text": "76.8 cm^3", "feedback": "Correct."},
   {"text": "65.2 cm^3", "feedback": "That is the volume at the endpoint r equals 3. The endpoint has to be checked, but a critical number inside the interval beats it here."}]'::jsonb,
 2, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 25, 'Challenge',
 'On which interval is f(x) = x^3 - 3x^2 + 1 concave down?',
 '[{"text": "x > 1", "feedback": "The inequality was read the wrong way. The second derivative is 6x take away 6, which is positive out there."},
   {"text": "-1 < x < 1", "feedback": "A cubic has one point of inflection, so its concavity changes exactly once. What you are looking for is a half line, not a strip between two values."},
   {"text": "x < 0", "feedback": "The inflection point was placed at the origin. Setting 6x take away 6 to zero moves it."},
   {"text": "x < 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 26, 'Challenge',
 'What is the oblique asymptote of f(x) = (x^2 + 1)/x?',
 '[{"text": "y = 0", "feedback": "That is the horizontal asymptote rule for when the bottom has the higher degree. Here the top is one degree higher, which produces a slanted line instead."},
   {"text": "x = 0", "feedback": "That is the VERTICAL asymptote. It is real, but it is not the oblique one."},
   {"text": "y = x + 1", "feedback": "Dividing out gives x plus 1 over x. The leftover term goes to zero, so the constant 1 does not belong to the line."},
   {"text": "y = x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 27, 'Challenge',
 'How many local extrema does f(x) = x/(x - 3) have?',
 '[{"text": "One local minimum, at x = 0", "feedback": "That is the x-intercept, where the curve crosses the axis rather than turns."},
   {"text": "None", "feedback": "Correct."},
   {"text": "One local minimum, at x = 3", "feedback": "That value is the vertical asymptote, so it is not in the domain and cannot be a turning point."},
   {"text": "One local maximum, at x = 0", "feedback": "That is the x-intercept. The derivative there is negative three ninths, which is not zero."}]'::jsonb,
 1, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 28, 'Challenge',
 'A function has f prime of x positive and f double prime of x negative throughout an interval. Which describes its graph there?',
 '[{"text": "Falling, but bending upwards", "feedback": "Both signs were read backwards. Positive first means rising and negative second means bending down."},
   {"text": "Rising, but bending downwards", "feedback": "Correct."},
   {"text": "Rising, and bending upwards", "feedback": "The direction is right but the bending is not. A negative second derivative curves the graph downwards."},
   {"text": "Falling, and bending downwards", "feedback": "The bending is right but the direction is not. A positive first derivative makes the graph climb."}]'::jsonb,
 1, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 29, 'Challenge',
 E'A function satisfies f(2) = 0, f prime of 2 = 0, and f double prime of 2 > 0.\nWhat feature does the graph have at x = 2?',
 '[{"text": "A local minimum sitting on the x-axis", "feedback": "Correct."},
   {"text": "A local maximum sitting on the x-axis", "feedback": "The second derivative test was applied backwards. Bending upwards at a flat point puts the graph in a valley."},
   {"text": "A point of inflection on the x-axis", "feedback": "An inflection point needs the second derivative to be zero and to change sign. Here it is strictly positive."},
   {"text": "A vertical asymptote", "feedback": "The function has a value there, namely zero, so the graph passes through the point rather than running away from it."}]'::jsonb,
 0, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 30, 'Challenge',
 E'A closed cardboard box with a square base is to hold 8000 cm^3.\nWhat is the minimum surface area of cardboard needed?',
 '[{"text": "20 cm^2", "feedback": "That is the side LENGTH that minimises the area, not the area itself. It still has to be substituted back."},
   {"text": "2400 cm^2", "feedback": "Correct."},
   {"text": "800 cm^2", "feedback": "Only the two square ends were counted. The four rectangular sides make up the larger part of the surface."},
   {"text": "1600 cm^2", "feedback": "Only the four sides were counted. The top and the bottom have to be included as well."}]'::jsonb,
 1, 'sub-optimization'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): sign charts with three critical numbers, a failing
-- second derivative test, and two full optimizations. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Curve Sketching', 2, 31, 'Advanced',
 'On which intervals is f(x) = x^4 - 8x^2 increasing?',
 '[{"text": "x < -2 or 0 < x < 2", "feedback": "Every interval on the sign chart was taken the wrong way. The derivative factors into three brackets, so it alternates."},
   {"text": "x > 0", "feedback": "The critical numbers at plus and minus 2 were missed. The derivative is a cubic with three zeros, not one."},
   {"text": "-2 < x < 2", "feedback": "The whole strip between the outer critical numbers was taken. The derivative changes sign again at the origin, in the middle of it."},
   {"text": "-2 < x < 0 or x > 2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-increasing-decreasing'),

(12, 'MCV4U', 'Curve Sketching', 2, 32, 'Advanced',
 'Classify the critical points of f(x) = 3x^5 - 5x^3.',
 '[{"text": "Local min at x = -1, local max at x = 1, and neither at x = 0", "feedback": "The two outer classifications were swapped. Check the sign of the second derivative at each of them."},
   {"text": "Local max at x = -1 and local min at x = 1 only, because x = 0 is not a critical number", "feedback": "It is a critical number: the derivative factors into 15x squared times a bracket, so the origin does make it vanish. It simply is not a turning point."},
   {"text": "Local max at x = -1, local min at x = 1, and neither at x = 0", "feedback": "Correct."},
   {"text": "Local max at x = -1, local min at x = 1, and a local max at x = 0", "feedback": "The second derivative test returns zero at the origin, so it fails there and tells you nothing. The first derivative is negative on BOTH sides, so nothing turns around."}]'::jsonb,
 2, 'sub-critical-extrema'),

(12, 'MCV4U', 'Curve Sketching', 2, 33, 'Advanced',
 'On which intervals is f(x) = x^4 - 2x^3 - 5 concave up?',
 '[{"text": "0 < x < 1", "feedback": "The wrong side of the sign chart was taken. Between the two zeros of the second derivative the product 12x times the bracket comes out negative."},
   {"text": "x > 1 only", "feedback": "Only one of the two stretches was found. To the left of the origin both factors are negative, so their product is positive."},
   {"text": "x < 0 or x > 3/2", "feedback": "The larger boundary came from the FIRST derivative. The second derivative has its own zeros."},
   {"text": "x < 0 or x > 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 34, 'Advanced',
 'If f double prime of c equals zero, what can be concluded about the graph at x = c?',
 '[{"text": "The graph is a straight line near x = c", "feedback": "That would need the second derivative to be zero on a whole interval, not at a single value."},
   {"text": "Nothing yet — the concavity has to be checked on both sides", "feedback": "Correct."},
   {"text": "There is a point of inflection at x = c", "feedback": "That is the assumption this question exists to break. The fourth power function has a zero second derivative at the origin and no change of bending at all."},
   {"text": "There is a local maximum or minimum at x = c", "feedback": "Turning points come from the FIRST derivative vanishing, not the second."}]'::jsonb,
 1, 'sub-concavity'),

(12, 'MCV4U', 'Curve Sketching', 2, 35, 'Advanced',
 'For f(x) = (x^2 - 4)/(x^2 - 1), how many vertical asymptotes and how many x-intercepts does the graph have?',
 '[{"text": "Only one vertical asymptote and two x-intercepts", "feedback": "The denominator factors into two brackets, so it vanishes at two separate values."},
   {"text": "Two vertical asymptotes and no x-intercepts", "feedback": "The numerator does reach zero. Setting x squared take away 4 to zero gives two real values."},
   {"text": "Two vertical asymptotes and two x-intercepts", "feedback": "Correct."},
   {"text": "Two vertical asymptotes and one x-intercept", "feedback": "The numerator is also a difference of squares, so it has two zeros rather than one."}]'::jsonb,
 2, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 36, 'Advanced',
 'What are the coordinates of the local minimum of f(x) = x + 3/x for x > 0, to two decimal places?',
 '[{"text": "(1.73, 4.73)", "feedback": "The two terms were added as if the second were 3 rather than 3 divided by x. Substitute the critical number into the second term as it is written."},
   {"text": "(1.73, 3.46)", "feedback": "Correct."},
   {"text": "(1.73, 1.73)", "feedback": "The x-value is right but was reused as the height. Substitute it back into the whole function, which has two terms."},
   {"text": "(3.00, 4.00)", "feedback": "The 3 from the numerator was taken as the critical value. Setting 1 take away 3 over x squared to zero gives its square root instead."}]'::jsonb,
 1, 'sub-rational-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 37, 'Advanced',
 E'The graph of f prime is an upward parabola with x-intercepts at -1 and 3.\nWhat does the graph of f have at those two values?',
 '[{"text": "Points of inflection at both values", "feedback": "Inflection points come from the second derivative, which here is the SLOPE of the drawn parabola. That is zero only at its vertex."},
   {"text": "A local maximum at x = 1, the vertex of the parabola", "feedback": "The picture is the graph of f prime, so its vertex marks where f is steepest downhill, which is a point of inflection on f."},
   {"text": "A local maximum at x = -1 and a local minimum at x = 3", "feedback": "Correct."},
   {"text": "A local minimum at x = -1 and a local maximum at x = 3", "feedback": "The two were swapped. An upward parabola is positive to the left of its first root, so f is climbing before it reaches negative 1."}]'::jsonb,
 2, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 38, 'Advanced',
 'A function is decreasing and concave up throughout an interval. What is its derivative doing there?',
 '[{"text": "Negative and increasing", "feedback": "Correct."},
   {"text": "Negative and decreasing", "feedback": "The sign is right but the trend is not. Concave up means the SLOPES are climbing, even while they stay below zero."},
   {"text": "Positive and increasing", "feedback": "The trend is right but the sign is not. A decreasing function has a negative derivative."},
   {"text": "Positive and decreasing", "feedback": "Both parts were read backwards. Decreasing gives a negative derivative and concave up makes it climb."}]'::jsonb,
 0, 'sub-curve-sketching'),

(12, 'MCV4U', 'Curve Sketching', 2, 39, 'Advanced',
 E'A can of volume 500 cm^3 has a top costing 0.4 cents per cm^2 and a bottom and sides costing 0.2 cents per cm^2.\nWhat radius minimises the cost, to two decimal places?',
 '[{"text": "3.76 cm", "feedback": "Correct."},
   {"text": "4.30 cm", "feedback": "The top and the bottom were priced the same. The dearer top pulls the best radius smaller, because it shrinks the two circular faces."},
   {"text": "5.42 cm", "feedback": "The 500 was used where the cost coefficients belong. Build the cost function first, then differentiate it."},
   {"text": "79.84 cm", "feedback": "That is the minimum COST in cents, not the radius. The radius still has to be read off the critical number."}]'::jsonb,
 0, 'sub-optimization'),

(12, 'MCV4U', 'Curve Sketching', 2, 40, 'Advanced',
 E'A rectangular field of area 1200 m^2 is to be fenced, with one side running along a river and needing no fence.\nWhat is the least length of fence needed, to one decimal place?',
 '[{"text": "98.0 m", "feedback": "Correct."},
   {"text": "69.3 m", "feedback": "The two perpendicular sides were counted once instead of twice. Only the river side is saved; the opposite pair still needs fencing on both sides."},
   {"text": "138.6 m", "feedback": "All four sides were fenced. The side along the river is free, so it comes out of the total."},
   {"text": "49.0 m", "feedback": "That is the length of the side along the river, which is one of the DIMENSIONS. The question asks for the total fence."}]'::jsonb,
 0, 'sub-optimization');
