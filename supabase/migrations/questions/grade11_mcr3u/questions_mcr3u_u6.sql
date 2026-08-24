-- ===========================================================================
-- MCR3U — Unit 6: Trig Functions — 40 questions
-- ===========================================================================
-- Grade 11 Trig Functions, authored from the Jensen MCR3U lesson material
-- for this unit:
--
--   Lesson 1  Periodic behaviour
--   Lesson 2  Graphing sine and cosine
--   Lesson 3  The transformed graph from the equation
--   Lesson 4  The transformed equation from the graph
--   Lesson 5  Trig applications 1
--   Lesson 6  Trig applications 2
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Feedback names that mistake and stops there.
--
-- Every value in this file was recomputed independently with sympy before
-- delivery; nothing was copied from the source PDFs.
--
-- A NOTE ON HOW THE GRAPH QUESTIONS ARE ASKED. Jensen asks Lesson 4 with a
-- printed curve on a grid: read the amplitude, period and shift off the
-- picture, then write the equation. That question cannot be asked here.
-- A grid IS the answer — the amplitude and the period can be counted off
-- the squares, and AUTHORING_GUIDE.md rejects any figure with axes for
-- exactly that reason. So every one of those questions is posed through the
-- values a student would have had to read first: the maximum, the minimum,
-- the period and where the curve starts. That is strictly harder than
-- reading a graph, it is what the exam expects a student to be able to do
-- from a table or a description, and it cannot leak.
--
-- FIGURES. Two questions carry one, 29 and 39, and both are scenes rather
-- than graphs: a windmill and a ferris wheel. Neither picture contains the
-- answer — one asks for a height that the drawing is deliberately out of
-- proportion about, and the other asks for an equation, which no drawing
-- can state. Every other question in this unit is about a curve, and a
-- picture of the curve would do the work.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file -> figures_mcr3u.sql.
-- The figure file must come second, because the delete below clears the
-- figure column along with the rest of each row.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MCR3U' and unit = 'Trig Functions';

insert into misconception_labels (tag, label) values
  ('sub-periodic-behaviour', 'Periodic behaviour'),
  ('sub-graph-sin-cos',      'Graphing sine and cosine'),
  ('sub-trig-from-equation', 'Reading a trig equation'),
  ('sub-trig-from-graph',    'Building a trig equation'),
  ('sub-trig-applications',  'Trig applications')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one concept, one step. Vocabulary and recognition.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 1, 'Easy',
 'What is the period of y = sin x, in degrees?',
 '[{"text": "360°", "feedback": "Correct."},
   {"text": "180°", "feedback": "At 180 degrees the curve is only half way through: it has come back to the axis but it is heading down, not up."},
   {"text": "90°", "feedback": "90 degrees is a quarter of the way round, where the curve reaches its first maximum."},
   {"text": "1", "feedback": "1 is the amplitude, the height of the curve. The period is measured along the x-axis."}]'::jsonb,
 0, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 2, 'Easy',
 'What is the amplitude of y = sin x?',
 '[{"text": "360", "feedback": "360 is the period, measured along the x-axis. Amplitude is measured up the y-axis."},
   {"text": "0", "feedback": "0 is the equation of the axis the curve waves about. The amplitude is how far it strays from it."},
   {"text": "1", "feedback": "Correct."},
   {"text": "2", "feedback": "2 is the full distance from the lowest point to the highest. Amplitude is HALF of that."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 3, 'Easy',
 'What is the value of sin 90°?',
 '[{"text": "0", "feedback": "sin 0 and sin 180 are zero. At 90 the sine curve is at the top of its first hill."},
   {"text": "-1", "feedback": "-1 is sin 270, at the bottom of the trough."},
   {"text": "90", "feedback": "A sine is a ratio between -1 and 1. It is never the angle itself."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 4, 'Easy',
 'Between 0° and 360°, where does y = cos x reach its maximum?',
 '[{"text": "At 180°", "feedback": "At 180 cosine is at its lowest, not its highest."},
   {"text": "At 270°", "feedback": "At 270 cosine is back on the axis, half way up from its trough."},
   {"text": "At 0°", "feedback": "Correct."},
   {"text": "At 90°", "feedback": "That is where SINE peaks. Cosine starts at the top and is already coming down by 90."}]'::jsonb,
 2, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 5, 'Easy',
 'What is the amplitude of y = 4 sin x?',
 '[{"text": "1/4", "feedback": "The 4 multiplies the outputs, so it makes the curve taller rather than shorter."},
   {"text": "4", "feedback": "Correct."},
   {"text": "1", "feedback": "1 is the amplitude of the plain sine curve. The 4 out front stretches it."},
   {"text": "8", "feedback": "8 is the full distance from the lowest point to the highest. Amplitude is half of that."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 6, 'Easy',
 'What is the equation of the axis of y = sin x + 5?',
 '[{"text": "y = 0", "feedback": "That is the axis of the plain sine curve, before the + 5 lifted it."},
   {"text": "y = 1", "feedback": "1 is the amplitude. The axis is the level the curve waves about."},
   {"text": "x = 5", "feedback": "The axis of a sinusoid is a horizontal line, so its equation names y."},
   {"text": "y = 5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 7, 'Easy',
 'A sine curve has a maximum of 7 and a minimum of 1. What is its amplitude?',
 '[{"text": "3", "feedback": "Correct."},
   {"text": "6", "feedback": "6 is the full distance from the minimum to the maximum. Amplitude is half of that."},
   {"text": "4", "feedback": "4 is the equation of the axis, the level half way between the two."},
   {"text": "8", "feedback": "That adds the maximum and the minimum. Amplitude comes from their difference."}]'::jsonb,
 0, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 8, 'Easy',
 'A sine curve has a maximum of 7 and a minimum of 1. What is the equation of its axis?',
 '[{"text": "y = 3", "feedback": "3 is the amplitude, which comes from the DIFFERENCE. The axis comes from the average."},
   {"text": "y = 6", "feedback": "6 is the difference between the two. The axis sits half way between them."},
   {"text": "y = 8", "feedback": "That adds the two without halving. The axis is the average of the maximum and the minimum."},
   {"text": "y = 4", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 9, 'Easy',
 E'A ferris wheel takes 40 seconds to turn once.\nWhat is the period of the height function of one seat?',
 '[{"text": "40 seconds", "feedback": "Correct."},
   {"text": "20 seconds", "feedback": "20 seconds is half a turn, which takes a seat from the bottom to the top. A full cycle brings it back down again."},
   {"text": "80 seconds", "feedback": "80 seconds is two full turns. The pattern has already repeated once by then."},
   {"text": "360 seconds", "feedback": "360 is the number of DEGREES in a full turn, not the number of seconds this wheel takes."}]'::jsonb,
 0, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 10, 'Easy',
 E'A lake has a highest tide of 5.2 m and a lowest tide of 0.6 m.\nWhat is the amplitude of the tide function?',
 '[{"text": "4.6 m", "feedback": "4.6 is the full range from lowest to highest. Amplitude is half of that."},
   {"text": "2.9 m", "feedback": "2.9 is the equation of the axis, the level half way between the two tides."},
   {"text": "5.8 m", "feedback": "That adds the two heights. Amplitude comes from their difference, halved."},
   {"text": "2.3 m", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): the standard procedure, two or three steps.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 11, 'Medium',
 'A sine function repeats every 90°. What is k in y = sin(kx)?',
 '[{"text": "270", "feedback": "That is 360 take away 90. The two are related by division, not subtraction."},
   {"text": "4", "feedback": "Correct."},
   {"text": "1/4", "feedback": "The relationship is upside down. A SHORTER period needs a LARGER k, because k is 360 divided by the period."},
   {"text": "90", "feedback": "90 is the period itself. k is what you divide 360 by to get it."}]'::jsonb,
 1, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 12, 'Medium',
 'What is the period of y = cos(3x)?',
 '[{"text": "3°", "feedback": "3 is the value of k. The period is 360 divided by it."},
   {"text": "360°", "feedback": "360 is the period of the plain cosine curve, before the 3 squeezed it."},
   {"text": "120°", "feedback": "Correct."},
   {"text": "1080°", "feedback": "The 3 was multiplied instead of divided. A larger k squeezes the curve, so the period gets shorter."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 13, 'Medium',
 'What is the graph of y = sin x doing at x = 180°?',
 '[{"text": "Reaching a maximum", "feedback": "The maximum is at 90. By 180 the curve has come all the way back down to the axis."},
   {"text": "Reaching a minimum", "feedback": "The minimum is at 270. At 180 the curve is level with the axis, not below it."},
   {"text": "Undefined", "feedback": "Sine is defined for every angle. It is tangent that has gaps in it."},
   {"text": "Crossing the axis on its way down", "feedback": "Correct."}]'::jsonb,
 3, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 14, 'Medium',
 'Between 0° and 360°, at what value of x does y = cos x equal -1?',
 '[{"text": "180°", "feedback": "Correct."},
   {"text": "0°", "feedback": "At 0 the cosine curve is at its highest, at +1."},
   {"text": "90°", "feedback": "At 90 cosine is 0, half way down from its peak."},
   {"text": "270°", "feedback": "270 is where SINE bottoms out. Cosine is back on the axis there."}]'::jsonb,
 0, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 15, 'Medium',
 'For y = 4 cos[3(x - 20°)] + 5, give the amplitude and the period.',
 '[{"text": "Amplitude 3, period 120°", "feedback": "3 is k, and it sits inside the bracket where it changes the period. The amplitude is out front."},
   {"text": "Amplitude 4, period 120°", "feedback": "Correct."},
   {"text": "Amplitude 4, period 1080°", "feedback": "The 3 was multiplied by 360 instead of divided into it. A larger k squeezes the curve."},
   {"text": "Amplitude 5, period 120°", "feedback": "5 is the vertical shift, which moves the curve up. The amplitude is the number in front of the cosine."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 16, 'Medium',
 'For y = 4 cos[3(x - 20°)] + 5, give the maximum and minimum values.',
 '[{"text": "Maximum 9, minimum 1", "feedback": "Correct."},
   {"text": "Maximum 4, minimum -4", "feedback": "That is the plain 4 cos curve, before the + 5 lifted the whole thing."},
   {"text": "Maximum 5, minimum -5", "feedback": "5 is the level the curve waves about. The amplitude of 4 is added and subtracted from it."},
   {"text": "Maximum 9, minimum -9", "feedback": "The minimum was taken as the negative of the maximum. That only works for a curve waving about zero, and the + 5 has lifted this one."}]'::jsonb,
 0, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 17, 'Medium',
 E'A sinusoid has a maximum at (0, 2/3), a vertical shift of 1/3 up\nand a period of 120°. What is its amplitude?',
 '[{"text": "1/3", "feedback": "Correct."},
   {"text": "2/3", "feedback": "2/3 is the height of the maximum above zero. Amplitude is measured from the AXIS, which is already 1/3 up."},
   {"text": "1", "feedback": "That adds the maximum to the shift. Amplitude is the maximum take away the axis."},
   {"text": "1/2", "feedback": "That averages the maximum with the vertical shift. Averaging belongs to a maximum and a minimum, and the axis here is given already."}]'::jsonb,
 0, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 18, 'Medium',
 'A sinusoid has a period of 120°. What is its k value?',
 '[{"text": "120", "feedback": "120 is the period itself. k is what 360 has to be divided by to get it."},
   {"text": "240", "feedback": "That is 360 take away 120. The two are related by division, not subtraction."},
   {"text": "3", "feedback": "Correct."},
   {"text": "1/3", "feedback": "The relationship is upside down. k is 360 divided by the period, not the period divided by 360."}]'::jsonb,
 2, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 19, 'Medium',
 E'A lake has its highest tide at 8:00 am and its lowest at 8:00 pm,\nand the pattern repeats daily. What is the period?',
 '[{"text": "24 hours", "feedback": "Correct."},
   {"text": "12 hours", "feedback": "12 hours is high tide to low tide, which is HALF a cycle. A full cycle returns to high tide."},
   {"text": "8 hours", "feedback": "8 is when the high tide happens, measured from midnight. That is the phase shift, not the period."},
   {"text": "20 hours", "feedback": "That adds 8 and 12. The period is the time from one high tide to the next."}]'::jsonb,
 0, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 20, 'Medium',
 E'A lake has a highest tide of 5.2 m and a lowest of 0.6 m.\nWhat is the equation of the axis of the tide function?',
 '[{"text": "y = 5.8", "feedback": "That adds the two heights without halving them."},
   {"text": "y = 0.6", "feedback": "0.6 is the lowest tide, the bottom of the curve. The axis is half way up."},
   {"text": "y = 2.9", "feedback": "Correct."},
   {"text": "y = 2.3", "feedback": "2.3 is the amplitude, which comes from the DIFFERENCE. The axis comes from the average."}]'::jsonb,
 2, 'sub-trig-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): several parameters at once, and building equations.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 21, 'Challenge',
 'What is the period of y = (1/4) sin[(1/2)(x + 90°)] - 2?',
 '[{"text": "180°", "feedback": "The 1/2 was multiplied by 360 instead of divided into it. A k below 1 stretches the curve out."},
   {"text": "90°", "feedback": "90 is the phase shift, which slides the curve sideways. The period comes from k."},
   {"text": "360°", "feedback": "360 is the period of the plain sine curve, before the 1/2 stretched it."},
   {"text": "720°", "feedback": "Correct."}]'::jsonb,
 3, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 22, 'Challenge',
 'For y = (1/4) sin[(1/2)(x + 90°)] - 2, give the amplitude and the maximum value.',
 '[{"text": "Amplitude 4, maximum 2", "feedback": "The 1/4 was turned over. A quarter out front squashes the curve rather than stretching it."},
   {"text": "Amplitude 0.25, maximum -2.25", "feedback": "That is the MINIMUM. The amplitude is added to the axis for the peak and subtracted for the trough."},
   {"text": "Amplitude 0.25, maximum -1.75", "feedback": "Correct."},
   {"text": "Amplitude 0.25, maximum 0.25", "feedback": "That reports the amplitude twice. The - 2 on the end moves the whole curve before any peak is read off it."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 23, 'Challenge',
 'Which single transformation turns the graph of y = sin x into y = cos x?',
 '[{"text": "A shift up of 1", "feedback": "That would lift the whole curve off the axis. Both sine and cosine still wave about y = 0."},
   {"text": "A shift left of 90°", "feedback": "Correct."},
   {"text": "A shift right of 90°", "feedback": "That takes cosine to sine, not the other way. Cosine peaks a quarter turn EARLIER than sine."},
   {"text": "A reflection in the x-axis", "feedback": "That gives y = -sin x, which is zero at 0 rather than at its maximum."}]'::jsonb,
 1, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 24, 'Challenge',
 'What is the value of y = sin(x + 60°) + 1 when x = 30°?',
 '[{"text": "1.5", "feedback": "That takes the sine of 30, which is a half, and adds 1. The sine is of 90, not of 30."},
   {"text": "2", "feedback": "Correct."},
   {"text": "1", "feedback": "That reads the cosine at 90 rather than the sine, the across value on the unit circle instead of the up one."},
   {"text": "0.5", "feedback": "That misses both the shift inside and the + 1 outside."}]'::jsonb,
 1, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 25, 'Challenge',
 'Which list of steps turns y = sin x into y = -3 sin[4(x + 30°)] + 1?',
 '[{"text": "Reflect in the x-axis, stretch vertically by 3, STRETCH horizontally by 4, left 30°, up 1", "feedback": "k = 4 squeezes the curve rather than stretching it. The scale factor is 1 over k."},
   {"text": "Reflect in the x-axis, stretch vertically by 3, compress horizontally by 1/4, RIGHT 30°, up 1", "feedback": "The bracket reads x + 30, and a plus inside moves the curve left."},
   {"text": "Stretch vertically by 3, compress horizontally by 1/4, left 30°, up 1", "feedback": "The minus in front of the 3 was read as part of the number. It flips the curve over as well as stretching it."},
   {"text": "Reflect in the x-axis, stretch vertically by 3, compress horizontally by 1/4, left 30°, up 1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 26, 'Challenge',
 'For y = (1/4) sin[(1/2)(x + 90°)] - 2, give the phase shift and the vertical shift.',
 '[{"text": "Left 45°, down 2", "feedback": "The 1/2 was applied to the 90 as well. The 90 is already outside the k, sitting in the (x - d) bracket, so it is the shift as it stands."},
   {"text": "Left 90°, down 2", "feedback": "Correct."},
   {"text": "Right 90°, down 2", "feedback": "The bracket reads x + 90, and a plus inside moves the curve left."},
   {"text": "Left 90°, up 2", "feedback": "The 2 is being subtracted, so the whole curve drops."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 27, 'Challenge',
 E'A curve has a maximum of 0.75, a minimum of -0.75 and a period of 90°,\nand it starts at zero and rises. Which SINE equation fits?',
 '[{"text": "y = 0.75 sin(x/4)", "feedback": "That k stretches the curve to a period of 1440. A period shorter than 360 needs a k bigger than 1."},
   {"text": "y = 0.75 sin(4x)", "feedback": "Correct."},
   {"text": "y = 0.75 sin(90x)", "feedback": "90 is the period. k is 360 divided by the period, not the period itself."},
   {"text": "y = 1.5 sin(4x)", "feedback": "1.5 is the full distance from the minimum to the maximum. The amplitude is half of that."}]'::jsonb,
 1, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 28, 'Challenge',
 E'The same curve — maximum 0.75, minimum -0.75, period 90°, starting at zero\nand rising. Which COSINE equation fits?',
 '[{"text": "y = 0.75 cos(4x)", "feedback": "That curve starts at its maximum, and this one starts at zero. A quarter period of shift is needed."},
   {"text": "y = 0.75 cos[4(x - 22.5°)]", "feedback": "Correct."},
   {"text": "y = 0.75 cos[4(x + 22.5°)]", "feedback": "Cosine peaks at the start of its own cycle, so it has to be pushed RIGHT to line up with a sine curve, not left."},
   {"text": "y = 0.75 cos(4x - 22.5°)", "feedback": "The 22.5 has to sit inside the bracket WITH the k. Written like this the shift is only 22.5 divided by 4."}]'::jsonb,
 1, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 29, 'Challenge',
 E'A windmill tower is 40 m tall and each blade is 10 m long.\nWhat is the greatest height reached by the tip of a blade?',
 '[{"text": "80 m", "feedback": "That doubles the tower. It is the blade that is added on top, and the blade is 10 m."},
   {"text": "50 m", "feedback": "Correct."},
   {"text": "30 m", "feedback": "30 m is the LOWEST the tip gets, when the blade points straight down."},
   {"text": "40 m", "feedback": "40 m is the height of the hub, the level the tip waves about. The blade carries the tip above it."}]'::jsonb,
 1, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 30, 'Challenge',
 E'A lake has its highest tide of 5.2 m at 8:00 am and its lowest of 0.6 m at\n8:00 pm, repeating daily. Which cosine equation gives the height y in terms\nof the hours after midnight, x?',
 '[{"text": "y = 2.3 cos[15(x + 8)] + 2.9", "feedback": "High tide is 8 hours AFTER midnight, so the curve is pushed right, which needs x - 8 inside the bracket."},
   {"text": "y = 2.3 cos[24(x - 8)] + 2.9", "feedback": "24 is the period. k is 360 divided by the period, which is 15."},
   {"text": "y = 2.9 cos[15(x - 8)] + 2.3", "feedback": "The amplitude and the axis have swapped places. The bigger of the two is the level the tide waves about."},
   {"text": "y = 2.3 cos[15(x - 8)] + 2.9", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): comparing curves, counting cycles, full equations.
-- ---------------------------------------------------------------------------

(11, 'MCR3U', 'Trig Functions', 6, 31, 'Advanced',
 E'Two sinusoids have the same amplitude, but the second has a k value\ntwice as large. How do their graphs compare?',
 '[{"text": "The second fits twice as many cycles into the same stretch of x", "feedback": "Correct."},
   {"text": "The second is twice as tall", "feedback": "Height comes from a, and the two have the same amplitude. k works along the x-axis."},
   {"text": "The second has twice the period", "feedback": "Period is 360 divided by k, so doubling k HALVES the period."},
   {"text": "They are identical", "feedback": "k genuinely changes the graph. Only a change that cancels itself out would leave the curve alone."}]'::jsonb,
 0, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 32, 'Advanced',
 E'A function has a period of 720°.\nHow many complete cycles does it make between 0° and 2160°?',
 '[{"text": "1.5", "feedback": "That divides 2160 by 1440, which is two periods rather than one."},
   {"text": "8.64", "feedback": "That divides 2160 by 250. The period here is 720."},
   {"text": "3", "feedback": "Correct."},
   {"text": "6", "feedback": "That divides by 360 rather than by the period of this particular curve."}]'::jsonb,
 2, 'sub-periodic-behaviour'),

(11, 'MCR3U', 'Trig Functions', 6, 33, 'Advanced',
 'How many solutions does sin x = 0.5 have between 0° and 720°?',
 '[{"text": "3", "feedback": "The solutions come in pairs, one pair per turn, so the total is even."},
   {"text": "8", "feedback": "That counts four per turn. Sine takes each value between -1 and 1 exactly twice in one turn."},
   {"text": "4", "feedback": "Correct."},
   {"text": "2", "feedback": "Two is right for a single turn. 720 degrees is two full turns, and the pattern repeats."}]'::jsonb,
 2, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 34, 'Advanced',
 E'Three curves: y = sin x, y = sin(x + 60°) + 1, and y = 2 sin[(2/3)(x - 60°)] - 1.\nWhich has the LONGEST period?',
 '[{"text": "The third, at 540°", "feedback": "Correct."},
   {"text": "The first, at 360°", "feedback": "That assumes the plain sine curve is the slowest one on offer. The period comes from k, so the k inside every bracket has to be checked."},
   {"text": "The second, at 360°", "feedback": "The + 60 and the + 1 slide the curve about but leave its period alone. Only k changes the period."},
   {"text": "They all have the same period", "feedback": "That treats every transformation as leaving the period alone. Sliding a curve sideways or up does, but a k in front of x inside the bracket does not."}]'::jsonb,
 0, 'sub-graph-sin-cos'),

(11, 'MCR3U', 'Trig Functions', 6, 35, 'Advanced',
 'For y = -3 sin[4(x + 30°)] + 1, give the maximum, the minimum and the axis.',
 '[{"text": "Maximum -2, minimum 4, axis y = 1", "feedback": "The reflection was taken to swap which value is the maximum. Turning the curve over changes where the peak happens, not which number is larger."},
   {"text": "Maximum 4, minimum -2, axis y = 1", "feedback": "Correct."},
   {"text": "Maximum 3, minimum -3, axis y = 0", "feedback": "The + 1 was never applied. It lifts the axis and both turning points with it."},
   {"text": "Maximum 4, minimum -2, axis y = -1", "feedback": "The minus in front of the 3 flips the curve over, but it does not move the axis. The axis comes from the constant on the end."}]'::jsonb,
 1, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 36, 'Advanced',
 'What is the phase shift of y = 4 cos[3(x - 20°)] + 5?',
 '[{"text": "Right 60°", "feedback": "The 20 was multiplied by k. It is already outside the k, sitting in the (x - d) bracket, so it is the shift as it stands."},
   {"text": "Right 20/3°", "feedback": "The 20 was divided by k. That would be needed if the bracket read 3x - 20, but here the 3 has already been factored out."},
   {"text": "Right 20°", "feedback": "Correct."},
   {"text": "Left 20°", "feedback": "The bracket reads x - 20, and a minus inside moves the curve right."}]'::jsonb,
 2, 'sub-trig-from-equation'),

(11, 'MCR3U', 'Trig Functions', 6, 37, 'Advanced',
 E'A sinusoid has a maximum at (0, 2/3), a vertical shift of 1/3 up and a\nperiod of 120°. Which SINE equation fits?',
 '[{"text": "y = (1/3) sin[3(x + 30°)] + 1/3", "feedback": "Correct."},
   {"text": "y = (1/3) sin[3(x - 30°)] + 1/3", "feedback": "The shift has gone the wrong way round: this curve is at its minimum at x = 0 and does not peak until x = 60."},
   {"text": "y = (1/3) sin(3x) + 1/3", "feedback": "That curve is on its axis and rising at x = 0, not at its maximum. A quarter period of shift is needed."},
   {"text": "y = (2/3) sin[3(x + 30°)] + 1/3", "feedback": "2/3 is the height of the maximum above zero. The amplitude is measured from the axis, which is already 1/3 up."}]'::jsonb,
 0, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 38, 'Advanced',
 E'The same sinusoid — maximum at (0, 2/3), vertical shift 1/3 up, period 120°.\nWhich COSINE equation fits?',
 '[{"text": "y = (2/3) cos(3x) + 1/3", "feedback": "2/3 is the height of the maximum above zero. The amplitude is measured from the axis, which is already 1/3 up."},
   {"text": "y = (1/3) cos(3x) + 2/3", "feedback": "2/3 is the maximum, not the axis. The axis is the vertical shift, which is given as 1/3."},
   {"text": "y = (1/3) cos(3x) + 1/3", "feedback": "Correct."},
   {"text": "y = (1/3) cos[3(x - 30°)] + 1/3", "feedback": "Cosine already starts at its maximum, so with the maximum at x = 0 no sideways shift is needed at all."}]'::jsonb,
 2, 'sub-trig-from-graph'),

(11, 'MCR3U', 'Trig Functions', 6, 39, 'Advanced',
 E'A ferris wheel has a radius of 9 m and its centre is 11 m above the ground.\nA rider boards at the lowest point. Which equation gives the height y after\nthe wheel has turned x degrees?',
 '[{"text": "y = 9 cos x + 11", "feedback": "That puts the rider at the TOP when x = 0. Boarding at the lowest point needs the cosine turned over."},
   {"text": "y = -9 cos x + 9", "feedback": "The radius was used as the axis as well. The axis is the height of the centre."},
   {"text": "y = -11 cos x + 9", "feedback": "The radius and the centre height have swapped places. The radius is how far the seat swings from the centre."},
   {"text": "y = -9 cos x + 11", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications'),

(11, 'MCR3U', 'Trig Functions', 6, 40, 'Advanced',
 E'A windmill tower is 40 m tall with 10 m blades. A blade tip starts at the\nbottom and one rotation takes 360° of x. Which SINE equation gives its\nheight?',
 '[{"text": "y = 10 sin(x + 90°) + 40", "feedback": "That puts the tip at the TOP when x = 0. Starting at the bottom needs the curve pushed the other way."},
   {"text": "y = 10 sin(x - 90°) + 30", "feedback": "30 m is the lowest point the tip reaches. The axis is the height of the hub, which is the tower."},
   {"text": "y = 40 sin(x - 90°) + 10", "feedback": "The blade length and the tower height have swapped places. The blade is how far the tip swings from the hub."},
   {"text": "y = 10 sin(x - 90°) + 40", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-applications');
