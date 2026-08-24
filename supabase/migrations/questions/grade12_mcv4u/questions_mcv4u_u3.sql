-- ===========================================================================
-- MCV4U — Unit 3: Derivatives of Trig and Exponential Functions — 40 questions
-- ===========================================================================
-- Grade 12 Calculus and Vectors, authored from the Jensen MCV4U lesson
-- material for this unit:
--
--   Lesson 1  Derivatives of trig functions
--   Lesson 2  Derivative rules with trig functions
--   Lesson 3  Derivatives of exponential functions
--   Lesson 4  Derivative rules with exponential functions
--   Lesson 5  Implicit differentiation and derivatives of logarithms
--   Lesson 6  Applications of trig and exponential derivatives
--
-- Six lessons, six subtopics. Jensen splits each family into KNOW THE
-- DERIVATIVE and COMBINE IT WITH A RULE, and that split is worth keeping:
-- a student who has memorised that the derivative of tangent is secant
-- squared and a student who can carry that through a quotient rule are two
-- different students, and only the second one passes the unit.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Four repeat right through the unit:
--
--   * losing the minus sign that belongs to the derivative of cosine
--   * dropping the natural logarithm of the base when differentiating an
--     exponential whose base is not e
--   * forgetting the inner derivative, which now costs a factor buried
--     inside a trig or exponential argument rather than inside a bracket
--   * differentiating a term in y without attaching dy/dx
--
-- Feedback names the mistake and stops there.
--
-- Every derivative, decay constant, half-life and evaluated rate in this
-- file was recomputed independently with sympy before delivery; nothing was
-- copied from the source PDFs. One near miss is worth recording: the
-- derivative of a base-4 logarithm can be written with ln 4 on the bottom
-- or with ln 2 and the 2 cancelled, and those two are the SAME number. A
-- distractor was rewritten once sympy showed the collision.
--
-- FIGURES: none, and the reason is uniform across the unit. Every candidate
-- here is a sine or exponential curve drawn on a grid, and on a grid the
-- amplitude, the period and the y-intercept are all countable. The questions
-- that would use one are asked from the equation instead, which is what a
-- student has to be able to do anyway.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file -> figures_mcv4u.sql.
-- The figure file wipes and re-attaches the whole course, so it must be
-- re-run after any re-run of this one even though this unit has no figures
-- of its own. Student attempts (keyed on course, unit and sort_order)
-- survive the reload.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions
 where course_code = 'MCV4U' and unit = 'Derivatives of Trig and Exponential Functions';

insert into misconception_labels (tag, label) values
  ('sub-trig-derivatives',      'Derivatives of trig functions'),
  ('sub-trig-rules',            'Derivative rules with trig functions'),
  ('sub-exp-derivatives',       'Derivatives of exponential functions'),
  ('sub-exp-rules',             'Derivative rules with exponential functions'),
  ('sub-implicit-log',          'Implicit differentiation and logarithms'),
  ('sub-trig-exp-applications', 'Applications of trig and exponential derivatives')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the six derivatives themselves, straight out of the table.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 1, 'Easy',
 'What is the derivative of sin x?',
 '[{"text": "-cos x", "feedback": "The minus sign belongs to the other one. Differentiating COSINE is what introduces it."},
   {"text": "-sin x", "feedback": "That is the SECOND derivative of sine, after differentiating twice."},
   {"text": "sec^2 x", "feedback": "That is the derivative of tangent."},
   {"text": "cos x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 2, 'Easy',
 'What is the derivative of cos x?',
 '[{"text": "-cos x", "feedback": "That is the SECOND derivative of cosine, after differentiating twice."},
   {"text": "sec^2 x", "feedback": "That is the derivative of tangent."},
   {"text": "-sin x", "feedback": "Correct."},
   {"text": "sin x", "feedback": "The minus sign was dropped. Cosine is falling where sine is positive, so its derivative has to be the negative one."}]'::jsonb,
 2, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 3, 'Easy',
 'What is the derivative of tan x?',
 '[{"text": "cot x", "feedback": "That is the reciprocal of tangent, not its derivative."},
   {"text": "-csc^2 x", "feedback": "That is the derivative of COTANGENT. Note the minus sign, which tangent does not have."},
   {"text": "sec^2 x", "feedback": "Correct."},
   {"text": "sec x tan x", "feedback": "That is the derivative of SECANT, which is a different function."}]'::jsonb,
 2, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 4, 'Easy',
 'What is the derivative of e^x?',
 '[{"text": "e", "feedback": "That is the base, a constant. The function itself is what comes back out."},
   {"text": "e^x", "feedback": "Correct."},
   {"text": "x e^(x - 1)", "feedback": "The power rule was applied. That rule is for a variable BASE with a constant exponent, which is the other way round here."},
   {"text": "1", "feedback": "The exponent was differentiated on its own. The whole expression is what has to be differentiated."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 5, 'Easy',
 'What is the derivative of 2^x?',
 '[{"text": "2^x / ln 2", "feedback": "The logarithm ended up underneath. It multiplies rather than divides."},
   {"text": "2^x ln 2", "feedback": "Correct."},
   {"text": "2^x", "feedback": "That is the rule for base e only. Any other base picks up the natural logarithm of that base as a factor."},
   {"text": "x 2^(x - 1)", "feedback": "The power rule was applied. That rule is for a variable base with a constant exponent, which is the other way round here."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 6, 'Easy',
 'What is the derivative of e^(3x)?',
 '[{"text": "3e^x", "feedback": "The 3 came down correctly but the exponent lost it. The exponent is untouched by differentiating."},
   {"text": "e^(3x)/3", "feedback": "The 3 ended up underneath. That is what integrating would do, not differentiating."},
   {"text": "3e^(3x)", "feedback": "Correct."},
   {"text": "e^(3x)", "feedback": "The inner derivative was forgotten. The exponent is 3x, and differentiating that gives 3."}]'::jsonb,
 2, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 7, 'Easy',
 'When differentiating with respect to x, what does y^2 become?',
 '[{"text": "y^2 times dy/dx", "feedback": "The dy/dx is right but the power rule was never applied. The exponent has to come down and drop by one."},
   {"text": "2y times dy/dx", "feedback": "Correct."},
   {"text": "2y", "feedback": "The chain rule was stopped one step early. y is itself a function of x, so its derivative has to be attached."},
   {"text": "2 times dy/dx", "feedback": "The power rule was not applied to the y. It should leave a 2y, not a bare 2."}]'::jsonb,
 1, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 8, 'Easy',
 'What is the derivative of ln x?',
 '[{"text": "1/x", "feedback": "Correct."},
   {"text": "1/(x ln 10)", "feedback": "That is the derivative of the base-10 logarithm. For a natural logarithm the base is e, and the natural logarithm of e is 1."},
   {"text": "ln x", "feedback": "The function was copied out again. That happens with the exponential, not the logarithm."},
   {"text": "x/1", "feedback": "The reciprocal was turned the wrong way up."}]'::jsonb,
 0, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 9, 'Easy',
 E'A power supply delivers a voltage V(t) = 5sin(t) + 12 volts.\nWhat is the maximum voltage?',
 '[{"text": "12 volts", "feedback": "That is the DC part on its own, the level the signal oscillates about. The alternating part rides on top of it."},
   {"text": "5 volts", "feedback": "That is the amplitude, the size of the swing. It has to be added to the level the signal sits at."},
   {"text": "7 volts", "feedback": "That is the MINIMUM voltage. The amplitude was subtracted rather than added."},
   {"text": "17 volts", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-exp-applications'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 10, 'Easy',
 E'A radioactive sample decays according to N(t) = N0 e^(-kt), where N is the mass remaining after t days.\nWhat does N prime of t represent?',
 '[{"text": "How fast the sample is decaying, in mass per day", "feedback": "Correct."},
   {"text": "The mass of the sample still remaining after t days", "feedback": "That is N of t itself, before any differentiating."},
   {"text": "The number of days it takes for half the sample to decay", "feedback": "That is a single number, not a function of time, and it comes from solving rather than differentiating."},
   {"text": "The value of the disintegration constant k for the sample", "feedback": "That is k, a fixed number in the exponent. The derivative is a function that changes with time."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): one chain rule, or one rule combined with one derivative.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 11, 'Medium',
 'Differentiate y = sin(3x).',
 '[{"text": "3cos(3x)", "feedback": "Correct."},
   {"text": "cos(3x)", "feedback": "The inner derivative was forgotten. Differentiating 3x gives 3, which multiplies on the outside."},
   {"text": "3cos x", "feedback": "The 3 came out but the argument lost it. The 3x stays inside the cosine untouched."},
   {"text": "-3cos(3x)", "feedback": "A minus sign appeared from nowhere. It belongs to the derivative of cosine, not of sine."}]'::jsonb,
 0, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 12, 'Medium',
 'Differentiate y = cos(x^2).',
 '[{"text": "-sin(x^2)", "feedback": "The inner derivative was forgotten. Differentiating x squared gives 2x, which multiplies on the outside."},
   {"text": "2x sin(x^2)", "feedback": "The minus sign was dropped. Differentiating cosine always introduces one."},
   {"text": "-2x sin(2x)", "feedback": "The inner function was replaced by its derivative. The x squared stays inside the sine."},
   {"text": "-2x sin(x^2)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 13, 'Medium',
 'Differentiate y = x sin x.',
 '[{"text": "sin x + cos x", "feedback": "The x was dropped from the second term. Each term keeps one factor exactly as it was."},
   {"text": "sin x + x cos x", "feedback": "Correct."},
   {"text": "x cos x", "feedback": "Only the second term of the product rule was written. The derivative of x also multiplies the sine."},
   {"text": "cos x", "feedback": "The two derivatives were multiplied. The product rule needs two terms, each keeping one factor whole."}]'::jsonb,
 1, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 14, 'Medium',
 'Differentiate y = e^(x^2).',
 '[{"text": "2x e^(2x)", "feedback": "The exponent was replaced by its own derivative. The exponent stays exactly as it was."},
   {"text": "x^2 e^(x^2 - 1)", "feedback": "The power rule was applied to the exponent. That rule is for a variable base, not a variable exponent."},
   {"text": "2x e^(x^2)", "feedback": "Correct."},
   {"text": "e^(x^2)", "feedback": "The inner derivative was forgotten. Differentiating x squared gives 2x, which multiplies on the outside."}]'::jsonb,
 2, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 15, 'Medium',
 'Differentiate y = 3^(2x).',
 '[{"text": "3^(2x) times ln 3", "feedback": "The inner derivative was forgotten. The exponent is 2x, and differentiating that gives 2."},
   {"text": "2 times 3^(2x)", "feedback": "The natural logarithm of the base was dropped. Only base e escapes it."},
   {"text": "2 times 3^(2x) times ln 2", "feedback": "The logarithm was taken of the wrong number. It is the BASE that goes inside it, not the coefficient in the exponent."},
   {"text": "2 times 3^(2x) times ln 3", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 16, 'Medium',
 'Differentiate y = x^2 e^x.',
 '[{"text": "2x e^x + x^2 e^x", "feedback": "Correct."},
   {"text": "2x e^x", "feedback": "Only the first term of the product rule was written. The x squared also multiplies the derivative of the exponential."},
   {"text": "x^2 e^x", "feedback": "Only the second term of the product rule was written. The derivative of x squared also multiplies the exponential."},
   {"text": "2x e^x + x^3 e^(x - 1)", "feedback": "The power rule was applied to the exponential in the second term. That rule is for a variable base with a constant exponent, which is the other way round here."}]'::jsonb,
 0, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 17, 'Medium',
 'For the circle x^2 + y^2 = 16, what is dy/dx?',
 '[{"text": "-y/x", "feedback": "The fraction is upside down. Isolating dy/dx divides by the coefficient that came from the y term."},
   {"text": "-2x", "feedback": "Only the x side was differentiated. The y squared also produces a term, and it carries dy/dx."},
   {"text": "-x/y", "feedback": "Correct."},
   {"text": "x/y", "feedback": "The sign was lost while isolating. The 2x term has to cross to the other side, which flips it."}]'::jsonb,
 2, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 18, 'Medium',
 'Differentiate y = 2 ln(1 + x^2).',
 '[{"text": "2/(1 + x^2)", "feedback": "The inner derivative was forgotten. Differentiating 1 plus x squared gives 2x, which goes on top."},
   {"text": "4x", "feedback": "The bracket was never put underneath. The derivative of a logarithm is a fraction with the inner function on the bottom."},
   {"text": "4x/(1 + x^2)", "feedback": "Correct."},
   {"text": "2x/(1 + x^2)", "feedback": "The coefficient 2 in front of the logarithm was dropped somewhere. It multiplies the whole derivative."}]'::jsonb,
 2, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 19, 'Medium',
 E'A 6.0 mg sample of Au-198 decays to 4.6 mg after 1 day, following N(t) = N0 e^(-kt).\nWhat is the disintegration constant k, to four decimal places?',
 '[{"text": "0.2657", "feedback": "Correct."},
   {"text": "-0.2657", "feedback": "The minus sign is already in the exponent of the model, so k itself comes out positive. Taking logarithms of the ratio the other way round gives this."},
   {"text": "0.7667", "feedback": "That is the RATIO of the two masses. A logarithm still has to be taken, and the result divided by the time."},
   {"text": "1.3043", "feedback": "That is the ratio the other way up. It is what goes inside the logarithm, not the answer itself."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 20, 'Medium',
 E'Au-198 has a disintegration constant of 0.2657 per day in the model N(t) = N0 e^(-kt).\nWhat is its half-life, to two decimal places?',
 '[{"text": "3.76 days", "feedback": "The logarithm was left out entirely and 1 was divided by the constant. The reciprocal of the disintegration constant is the mean lifetime, not the half-life."},
   {"text": "2.61 days", "feedback": "Correct."},
   {"text": "7.53 days", "feedback": "The 2 was divided by the constant instead of its natural logarithm. Setting the model equal to half is what brings the logarithm in."},
   {"text": "0.26 days", "feedback": "That is the disintegration constant itself, which is the rate rather than the time."}]'::jsonb,
 1, 'sub-trig-exp-applications'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): a rule and a chain rule together. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 21, 'Challenge',
 'Differentiate y = (sin x)^2.',
 '[{"text": "2 sin x", "feedback": "The inner derivative was forgotten. The outer power rule leaves a sine, and differentiating that sine supplies a cosine."},
   {"text": "2 cos^2 x", "feedback": "The sine was replaced by its derivative before the power rule was applied. The original function stays and the inner derivative multiplies on."},
   {"text": "-2 sin x cos x", "feedback": "A minus sign appeared from nowhere. It would belong if the outer function were built on cosine."},
   {"text": "2 sin x cos x", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 22, 'Challenge',
 'Differentiate y = tan(3x).',
 '[{"text": "3 sec^2 x", "feedback": "The 3 came out but the argument lost it. The 3x stays inside the secant untouched."},
   {"text": "3 tan(3x) sec(3x)", "feedback": "That is built from the derivative of SECANT. The derivative of tangent is a secant squared."},
   {"text": "3 sec^2(3x)", "feedback": "Correct."},
   {"text": "sec^2(3x)", "feedback": "The inner derivative was forgotten. Differentiating 3x gives 3, which multiplies on the outside."}]'::jsonb,
 2, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 23, 'Challenge',
 'Differentiate y = (sin x)/x.',
 '[{"text": "(sin x - x cos x)/x^2", "feedback": "The two terms on top were subtracted in the wrong order, which flips the sign of the whole thing."},
   {"text": "(x cos x - sin x)/x", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "cos x", "feedback": "The top and the bottom were differentiated separately and then divided. That is not the quotient rule."},
   {"text": "(x cos x - sin x)/x^2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 24, 'Challenge',
 'Differentiate y = x^2 cos x.',
 '[{"text": "2x cos x - x^2 sin x", "feedback": "Correct."},
   {"text": "2x cos x + x^2 sin x", "feedback": "The minus sign from the derivative of cosine was lost."},
   {"text": "-2x sin x", "feedback": "The two derivatives were multiplied. The product rule adds two terms, each keeping one factor whole."},
   {"text": "-x^2 sin x", "feedback": "Only the second term of the product rule was written. The derivative of x squared also multiplies the cosine."}]'::jsonb,
 0, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 25, 'Challenge',
 'Differentiate y = e^(sin x).',
 '[{"text": "sin x times e^(sin x - 1)", "feedback": "The power rule was applied to the exponent. That rule is for a variable base, not a variable exponent."},
   {"text": "cos x times e^(sin x)", "feedback": "Correct."},
   {"text": "e^(sin x)", "feedback": "The inner derivative was forgotten. The exponent is a sine, and differentiating it supplies a cosine."},
   {"text": "e^(cos x)", "feedback": "The exponent was replaced by its own derivative. The exponent stays exactly as it was and the derivative multiplies on the outside."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 26, 'Challenge',
 'What is the equation of the tangent to y = e^x at x = 0?',
 '[{"text": "y = ex", "feedback": "The base was used as the slope. The slope is the derivative evaluated at zero, and e to the power zero is 1."},
   {"text": "y = 1", "feedback": "That is the height of the curve there, drawn as a horizontal line. The tangent has the slope of the curve, which is not zero."},
   {"text": "y = x + 1", "feedback": "Correct."},
   {"text": "y = x", "feedback": "The slope is right but the point was forgotten. The curve passes through a height of 1 at the origin, not zero."}]'::jsonb,
 2, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 27, 'Challenge',
 'Differentiate y = (e^x)/x.',
 '[{"text": "e^x(1 - x)/x^2", "feedback": "The two terms on top were subtracted in the wrong order, which flips the sign."},
   {"text": "e^x(x - 1)/x", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "e^x", "feedback": "The top and the bottom were differentiated separately and then divided. That is not the quotient rule."},
   {"text": "e^x(x - 1)/x^2", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 28, 'Challenge',
 'Differentiate y = 3^x e^(sin x) and factor the result.',
 '[{"text": "3^x e^(sin x)(ln 3 times cos x)", "feedback": "The two derivatives were multiplied. The product rule adds its two terms, which is why they collect into a sum inside the bracket."},
   {"text": "3^x e^(sin x)(1 + cos x)", "feedback": "The natural logarithm of the base was dropped. Only base e escapes it."},
   {"text": "3^x e^(sin x)(ln 3 + 1)", "feedback": "The inner derivative was forgotten. The exponent of the second factor is a sine rather than x, so the chain rule still owes a factor there."},
   {"text": "3^x e^(sin x)(ln 3 + cos x)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 29, 'Challenge',
 'Find dy/dx for y^2 + x^3 - y^3 + 6 = 3y.',
 '[{"text": "3x^2/(2y - 3y^2 - 3)", "feedback": "The sign is inverted throughout. Collecting the dy/dx terms on the other side flips every one of them."},
   {"text": "3x^2/(3y^2 - 2y)", "feedback": "The 3y on the right-hand side was left out of the collection. Both sides of the equation get differentiated, so the right-hand side contributes a term too."},
   {"text": "3x^2/(2y - 3y^2)", "feedback": "Two errors at once: the signs were not flipped and the term from the right-hand side was left out."},
   {"text": "3x^2/(3y^2 - 2y + 3)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 30, 'Challenge',
 E'A voltage signal is V(t) = 5sin(t) + 12 volts, with t in seconds.\nWhat is its frequency, to three decimal places?',
 '[{"text": "0.159 Hz", "feedback": "Correct."},
   {"text": "6.283 Hz", "feedback": "That is the PERIOD in seconds. Frequency is its reciprocal, the number of cycles per second."},
   {"text": "5.000 Hz", "feedback": "That is the amplitude in volts. It says how big the swing is, not how often it happens."},
   {"text": "0.500 Hz", "feedback": "The period was taken as 2 seconds. With a coefficient of 1 on t the period is a full 2 pi."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): three layers, or a rate that has to be built before it
-- can be evaluated. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 31, 'Advanced',
 'Differentiate y = (cos(2x))^3.',
 '[{"text": "-6 cos^2(2x) sin(2x)", "feedback": "Correct."},
   {"text": "3 cos^2(2x) sin(2x)", "feedback": "Two things went missing: the minus sign from the derivative of cosine, and the 2 from differentiating the argument."},
   {"text": "-3 cos^2(2x) sin(2x)", "feedback": "The innermost derivative was forgotten. There are two layers inside the cube, and differentiating 2x supplies a factor of 2."},
   {"text": "-6 cos^2(2x)", "feedback": "The middle layer was skipped. Differentiating the cosine itself supplies a sine as well."}]'::jsonb,
 0, 'sub-trig-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 32, 'Advanced',
 'Differentiate y = (sin x)/(1 + cos x) and simplify fully.',
 '[{"text": "(2 cos x - 1)/(1 + cos x)", "feedback": "The minus sign from differentiating the cosine underneath was dropped, so the second term of the quotient rule came out with the wrong sign."},
   {"text": "cos x/(1 + cos x)", "feedback": "Only the first term of the quotient rule was kept. The second term is not zero, because the denominator depends on x."},
   {"text": "-1/(1 + cos x)^2", "feedback": "The two terms on top were subtracted in the wrong order, and the cancellation was then missed."},
   {"text": "1/(1 + cos x)", "feedback": "Correct."}]'::jsonb,
 3, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 33, 'Advanced',
 'What is the slope of the tangent to y = x sin x at x = pi?',
 '[{"text": "-1", "feedback": "Only the cosine was evaluated. The x that multiplies it in the product rule still has to be substituted."},
   {"text": "-pi", "feedback": "Correct."},
   {"text": "pi", "feedback": "The sign was lost. The cosine of pi is negative 1, not positive 1."},
   {"text": "0", "feedback": "That is the VALUE of the function at pi, since the sine vanishes there. The slope comes from the derivative."}]'::jsonb,
 1, 'sub-trig-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 34, 'Advanced',
 'At which value of x does y = x e^x have a horizontal tangent?',
 '[{"text": "Nowhere, because an exponential is never zero", "feedback": "The exponential factor indeed never vanishes, but the product rule leaves a bracket alongside it, and that bracket can."},
   {"text": "x = -1", "feedback": "Correct."},
   {"text": "x = 0", "feedback": "The derivative there is 1, not zero. The exponential never vanishes, so the bracket that comes with it is what has to."},
   {"text": "x = 1", "feedback": "A sign was flipped when the bracket was solved. Setting 1 plus x to zero gives a negative value."}]'::jsonb,
 1, 'sub-exp-derivatives'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 35, 'Advanced',
 'Differentiate y = e^(2x)/(x^2 + 1) and factor the numerator.',
 '[{"text": "2e^(2x)(x^2 - x + 1)/(x^2 + 1)", "feedback": "The numerator is right but the denominator was never squared."},
   {"text": "2e^(2x)(x^2 - x + 1)/(x^2 + 1)^2", "feedback": "Correct."},
   {"text": "e^(2x)(x^2 - 2x + 1)/(x^2 + 1)^2", "feedback": "The inner derivative of the exponential was forgotten. Differentiating e to the 2x brings down a 2, which multiplies the first term of the quotient rule."},
   {"text": "2e^(2x)(x^2 + x + 1)/(x^2 + 1)^2", "feedback": "The subtraction in the quotient rule was carried out as an addition, so the middle term came out with the wrong sign."}]'::jsonb,
 1, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 36, 'Advanced',
 E'A 6.0 mg sample of Au-198 decays as N(t) = 6e^(-0.2657t) mg.\nHow fast is it decaying after 3 days, to three decimal places?',
 '[{"text": "2.704 mg per day", "feedback": "That is the MASS remaining after 3 days, not the rate at which it is falling."},
   {"text": "0.718 mg per day", "feedback": "The magnitude is right but the sign is not. The sample is losing mass, so the rate is negative."},
   {"text": "-0.718 mg per day", "feedback": "Correct."},
   {"text": "-1.594 mg per day", "feedback": "That is the rate at time ZERO. The exponential factor still has to be evaluated at 3 days, and it has shrunk by then."}]'::jsonb,
 2, 'sub-exp-rules'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 37, 'Advanced',
 'Differentiate f(x) = 1 - log base 4 of (2x - 1).',
 '[{"text": "-1/((2x - 1) ln 4)", "feedback": "The inner derivative was forgotten. Differentiating 2x take away 1 gives 2, which goes on top."},
   {"text": "-2/(2x - 1)", "feedback": "The natural logarithm of the base was dropped from the denominator. Only a natural logarithm escapes it."},
   {"text": "-2/((2x - 1) ln 4)", "feedback": "Correct."},
   {"text": "2/((2x - 1) ln 4)", "feedback": "The minus sign in front of the logarithm was dropped. It carries through to the whole derivative."}]'::jsonb,
 2, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 38, 'Advanced',
 'What is the slope of the tangent to the circle x^2 + y^2 = 25 at the point (3, 4)?',
 '[{"text": "4/3", "feedback": "The coordinates were swapped and the sign was lost as well."},
   {"text": "-3/4", "feedback": "Correct."},
   {"text": "3/4", "feedback": "The sign was lost while isolating dy/dx. At this point the circle is falling as you move right."},
   {"text": "-4/3", "feedback": "The two coordinates were substituted the wrong way round. The x-coordinate belongs on top."}]'::jsonb,
 1, 'sub-implicit-log'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 39, 'Advanced',
 E'A voltage signal is V(t) = 5sin(t) + 12 volts, with t in seconds.\nAt what time does it FIRST reach its maximum, to two decimal places?',
 '[{"text": "1.57 s", "feedback": "Correct."},
   {"text": "4.71 s", "feedback": "That is the other value where the derivative vanishes, but the second derivative is positive there, so it is the minimum."},
   {"text": "3.14 s", "feedback": "The sine is zero there, so the voltage is back at its middle level rather than at a peak."},
   {"text": "6.28 s", "feedback": "That is the full period. The signal has returned to its starting level by then, not to a peak."}]'::jsonb,
 0, 'sub-trig-exp-applications'),

(12, 'MCV4U', 'Derivatives of Trig and Exponential Functions', 3, 40, 'Advanced',
 E'A population grows as P(t) = 500e^(0.04t).\nHow fast is it growing at the moment the population reaches 2000?',
 '[{"text": "80 per unit time", "feedback": "Correct."},
   {"text": "20 per unit time", "feedback": "That is the growth rate at the START, when the population was 500. It grows as the population does."},
   {"text": "2000 per unit time", "feedback": "That is the population itself at that moment, not the rate at which it is changing."},
   {"text": "0.04 per unit time", "feedback": "That is the growth CONSTANT. It has to be multiplied by the population to give an actual rate."}]'::jsonb,
 0, 'sub-trig-exp-applications');
