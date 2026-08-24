-- ===========================================================================
-- ASTRO MATH ASSIST — Grade 12 — MDM4U, Mathematics of Data Management
-- ===========================================================================
--
-- 200 questions, 5 figures.
--
-- One course, safe to run on its own, in any order relative to the other
-- courses. Run it AFTER astro_math_assist_setup.sql has created the schema.
--
-- This is the per-unit files concatenated, with the figure file last, which is required:
-- every unit file opens with a delete for its own unit, and that delete takes
-- the figure reference with the row, so a figure file that ran first would
-- leave the course imageless.
--
-- Student attempts key on course, unit and sort_order rather than on question
-- ids, so re-running this keeps the history of every student.
-- ===========================================================================


-- --- questions_mdm4u_u1.sql ---

-- ===========================================================================
-- MDM4U — Unit 1: Displays of Data — 40 questions
-- ===========================================================================
-- Grade 12 Data Management, authored from the Jensen MDM4U lesson material
-- for this unit:
--
--   Lesson 1  Introduction to statistics
--   Lesson 2  Displaying categoric data
--   Lesson 3  Displaying numeric data
--   Lesson 4  Scatter plots
--   Lesson 5  Linear regression using technology
--   Lesson 6  Linear regression by hand
--   Lesson 7  Misleading graphs
--
-- Seven lessons, six subtopics: the two regression lessons are counted
-- together, because they teach the same idea with and without a calculator.
--
-- This unit is different from every other one in the bank, and the
-- difference is worth naming. Almost nothing here is arithmetic. A student
-- who loses marks in MDM4U Unit 1 usually loses them for saying something
-- true about a number and false about the world: that a correlation proves
-- a cause, that a coefficient of determination counts points on a line,
-- that a chart is honest because its axis is labelled. The distractors are
-- built to be those sentences.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Four repeat right through the unit:
--
--   * reading a correlation as a cause
--   * treating the correlation coefficient as a measure of ANY relationship
--     rather than of a straight-line one
--   * reporting a value calculated from a sample as though it described the
--     whole population
--   * accepting a chart because it is labelled, without checking where its
--     axis starts
--
-- Feedback names the mistake and stops there.
--
-- Every regression coefficient, correlation, prediction, median and
-- quartile in this file was recomputed independently before delivery. The
-- age-and-income regression reproduces the calculator output printed in the
-- Jensen lesson to six decimal places, which is a useful check that the
-- source itself was read correctly.
--
-- FIGURES: two, and choosing them took some care. Nearly every display in
-- this course is a graph with a numbered axis, and a numbered axis is a
-- leak: asking a student to read a median off a box plot is asking them to
-- count squares. Both figures here are about a PROPERTY of a picture rather
-- than a value in it.
--
--   * Q10 shows a bar chart whose vertical axis starts at 85 rather than
--     zero, so three values within four per cent of one another look like
--     one, two and three. The axis is labelled honestly; noticing where it
--     starts is the question. Nothing on the figure uses the word
--     misleading.
--   * Q17 shows a scatter plot whose points sit on a clean symmetric curve.
--     The axes carry no numbers, so no coefficient can be reconstructed.
--     The shape is the whole content.
--
-- Neither figure carries a ruler test, because neither answer is a number.
-- Both are stamped WITHOUT the usual "not drawn to scale" note: a bar chart
-- is drawn to its own axis, and saying otherwise on Q10 would be both false
-- and a hint.
--
-- Rejected: histograms, box plots and stem-and-leaf plots with values on
-- them. Every question that would have used one is asked from the list of
-- data instead.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mdm4u.sql.
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

delete from questions where course_code = 'MDM4U' and unit = 'Displays of Data';

insert into misconception_labels (tag, label) values
  ('sub-data-types',          'Populations, samples and types of data'),
  ('sub-categoric-displays',  'Displaying categoric data'),
  ('sub-numeric-displays',    'Displaying numeric data'),
  ('sub-scatter-correlation', 'Scatter plots and correlation'),
  ('sub-regression',          'Linear regression'),
  ('sub-misleading-graphs',   'Misleading graphs')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the vocabulary, and which display goes with which data.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Displays of Data', 1, 1, 'Easy',
 'What is the difference between a population and a sample?',
 '[{"text": "A sample is a subset of the population", "feedback": "Correct."},
   {"text": "A population is a subset of the sample", "feedback": "The two terms have been exchanged here. Go back to what each word names before deciding which one sits inside the other."},
   {"text": "They are two words for the same thing", "feedback": "If they were the same there would be no need for statistics at all: you could just measure everybody."},
   {"text": "A population is any group of more than a thousand", "feedback": "Size has nothing to do with it. A population is whatever whole group the question is about, however small."}]'::jsonb,
 0, 'sub-data-types'),

(12, 'MDM4U', 'Displays of Data', 1, 2, 'Easy',
 'Eye colour is which type of data?',
 '[{"text": "Numeric and discrete", "feedback": "Discrete numeric data are counts. Eye colour has no number attached to it at all."},
   {"text": "Numeric and continuous", "feedback": "Continuous numeric data come from measuring. Eye colour is a label rather than a measurement."},
   {"text": "A statistic", "feedback": "A statistic is a number CALCULATED from data. This is the data itself."},
   {"text": "Categoric", "feedback": "Correct."}]'::jsonb,
 3, 'sub-data-types'),

(12, 'MDM4U', 'Displays of Data', 1, 3, 'Easy',
 'Which display is designed for categoric data?',
 '[{"text": "A scatter plot", "feedback": "A scatter plot pairs two numeric variables against each other."},
   {"text": "A bar graph", "feedback": "Correct."},
   {"text": "A frequency histogram", "feedback": "A histogram needs intervals along its horizontal axis, which only numeric data can supply."},
   {"text": "A box-and-whisker plot", "feedback": "A box plot is built from quartiles, and quartiles need the data to be ordered by size."}]'::jsonb,
 1, 'sub-categoric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 4, 'Easy',
 'Why do the bars of a histogram touch when the bars of a bar graph do not?',
 '[{"text": "Because a histogram always has more bars", "feedback": "It may have fewer. The number of bars has nothing to do with whether they touch."},
   {"text": "It is only a matter of style", "feedback": "It carries real information: the gaps in a bar graph say the categories are separate things rather than neighbouring stretches of a number line."},
   {"text": "Because a histogram is always sorted in order from the tallest bar down to the shortest bar", "feedback": "A histogram is sorted by VALUE along the axis, which often puts the tallest bar in the middle."},
   {"text": "Because a histogram covers a continuous run of intervals with no gaps between them", "feedback": "Correct."}]'::jsonb,
 3, 'sub-numeric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 5, 'Easy',
 'What does a stem-and-leaf plot keep that a histogram throws away?',
 '[{"text": "The range", "feedback": "A histogram shows the range perfectly well, from the left edge of the first bar to the right edge of the last."},
   {"text": "The median", "feedback": "Neither one marks the median directly. The difference is that a stem-and-leaf plot lets you count to it exactly."},
   {"text": "The individual data values", "feedback": "Correct."},
   {"text": "The overall shape of the distribution", "feedback": "Both show the shape. Turn a stem-and-leaf plot on its side and it looks like a histogram."}]'::jsonb,
 2, 'sub-numeric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 6, 'Easy',
 'On a scatter plot the points cluster tightly around a line that falls to the right. What does that indicate?',
 '[{"text": "A strong positive correlation", "feedback": "Positive means the two rise together. Here one falls as the other rises."},
   {"text": "A weak negative correlation", "feedback": "The direction is right but not the strength. Weak means the points are scattered widely about the line, and these are tight to it."},
   {"text": "No correlation", "feedback": "No correlation means no line describes the points at all. Here one describes them well."},
   {"text": "A strong negative correlation", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatter-correlation'),

(12, 'MDM4U', 'Displays of Data', 1, 7, 'Easy',
 'A strong correlation between two variables does not establish what?',
 '[{"text": "That there is a pattern in the data", "feedback": "A pattern is what a strong correlation reports."},
   {"text": "That the two move together", "feedback": "Moving together is what correlation measures."},
   {"text": "That one causes the other", "feedback": "Correct."},
   {"text": "That the two are associated", "feedback": "Association is exactly what a correlation does establish. It is the step beyond it that fails."}]'::jsonb,
 2, 'sub-scatter-correlation'),

(12, 'MDM4U', 'Displays of Data', 1, 8, 'Easy',
 'What is the line of best fit on a scatter plot?',
 '[{"text": "The straight line that comes closest to all the points", "feedback": "Correct."},
   {"text": "The straight line joining the first point to the last point", "feedback": "Two points cannot speak for the rest. Every point in the set has a say in where the line sits."},
   {"text": "The line that passes through the greatest number of points", "feedback": "Counting hits is not the test. A few points that happen to fall in a row can drag such a line into a direction the rest of the data never goes."},
   {"text": "The line that separates the points into two equal halves", "feedback": "Splitting the count evenly is not the aim. Endlessly many different lines put half the points above and half below, so this condition never picks out a single one."}]'::jsonb,
 0, 'sub-regression'),

(12, 'MDM4U', 'Displays of Data', 1, 9, 'Easy',
 'A bar chart has a vertical axis that starts at 40 rather than at zero. What effect does that have?',
 '[{"text": "It understates the differences between the bars", "feedback": "This assumes the cut takes something away from each difference. The part removed is the part every bar shares, and the gaps between the bar tops are untouched by it."},
   {"text": "It has no effect, as long as the axis is labelled", "feedback": "A label helps a careful reader, but the shape of the picture still says something the numbers do not."},
   {"text": "It makes the bar heights proportional to the values", "feedback": "That is what starting at zero achieves. Starting anywhere else destroys the proportionality."},
   {"text": "It exaggerates the differences between the bars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-misleading-graphs'),

(12, 'MDM4U', 'Displays of Data', 1, 10, 'Easy',
 E'The chart shows units sold in three regions.\nWhat makes it misleading?',
 '[{"text": "The three bars are drawn at different widths from one another", "feedback": "The three bars are drawn at equal widths, so no comparison between them is being distorted that way."},
   {"text": "There are only three categories", "feedback": "Three is a perfectly reasonable number of categories. Something else about the drawing is doing the distorting."},
   {"text": "The regions are not in alphabetical order", "feedback": "The order of the categories is a matter of taste and does not change any bar height."},
   {"text": "The vertical axis starts at 85 rather than at zero", "feedback": "Correct."}]'::jsonb,
 3, 'sub-misleading-graphs'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): read a shape, or read a coefficient.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Displays of Data', 1, 11, 'Medium',
 'A value calculated from a sample is called what?',
 '[{"text": "A census", "feedback": "A census is the ACT of measuring everybody, not a number that comes out of it."},
   {"text": "A statistic", "feedback": "Correct."},
   {"text": "A parameter", "feedback": "A parameter describes the whole POPULATION. It is usually the thing you cannot measure and are trying to estimate."},
   {"text": "A population", "feedback": "A population is the group itself, not a number computed from it."}]'::jsonb,
 1, 'sub-data-types'),

(12, 'MDM4U', 'Displays of Data', 1, 12, 'Medium',
 'The number of siblings a student has is which type of data?',
 '[{"text": "A parameter", "feedback": "A parameter is a number describing a whole population. This is a measurement on one person."},
   {"text": "Numeric and discrete", "feedback": "Correct."},
   {"text": "Numeric and continuous", "feedback": "Continuous data can take any value in a range. Nobody has 2.4 siblings."},
   {"text": "Categoric", "feedback": "The values are genuine numbers that can be added and averaged, which categories cannot."}]'::jsonb,
 1, 'sub-data-types'),

(12, 'MDM4U', 'Displays of Data', 1, 13, 'Medium',
 'When is a pie chart NOT an appropriate display?',
 '[{"text": "When the categories do not together make up a single whole", "feedback": "Correct."},
   {"text": "When there are more than four categories", "feedback": "Many categories make a pie chart hard to read, but that is a matter of clarity rather than correctness."},
   {"text": "When the data come from a sample of the group rather than from a full census", "feedback": "Where the data came from has no bearing on which display suits them."},
   {"text": "When the percentages are already known", "feedback": "Knowing the percentages is exactly what makes a pie chart easy to build."}]'::jsonb,
 0, 'sub-categoric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 14, 'Medium',
 'A distribution has a long tail stretching to the right. What is its shape called?',
 '[{"text": "Symmetric about its centre", "feedback": "A symmetric distribution has matching tails on both sides."},
   {"text": "Bimodal", "feedback": "Bimodal means two separate peaks. A long tail is not a second peak."},
   {"text": "Skewed right", "feedback": "Correct."},
   {"text": "Skewed left", "feedback": "This names the shape after the side where the data pile up. That is not the convention the names follow."}]'::jsonb,
 2, 'sub-numeric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 15, 'Medium',
 'In a distribution that is skewed right, which is larger, the mean or the median?',
 '[{"text": "The mean", "feedback": "Correct."},
   {"text": "The median", "feedback": "A median only counts positions, so a long tail barely shifts it. Ask which of the two measures actually adds the extreme values in."},
   {"text": "They are equal", "feedback": "They are equal in a symmetric distribution. Skew is exactly what separates them."},
   {"text": "It depends on the sample size", "feedback": "Sample size does not decide the direction. A tail on one side pulls the two measures apart the same way at any size."}]'::jsonb,
 0, 'sub-numeric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 16, 'Medium',
 'What does a correlation coefficient of -0.92 describe?',
 '[{"text": "A strong positive linear relationship", "feedback": "The size is right but the sign says the two move in opposite directions."},
   {"text": "No relationship", "feedback": "That is what a value near zero means. This one is near the extreme."},
   {"text": "A strong negative linear relationship", "feedback": "Correct."},
   {"text": "A weak negative linear relationship", "feedback": "The strength is read from the SIZE, ignoring the sign, and 0.92 is close to 1."}]'::jsonb,
 2, 'sub-scatter-correlation'),

(12, 'MDM4U', 'Displays of Data', 1, 17, 'Medium',
 E'The scatter plot shows a clear pattern, yet the correlation coefficient for this data is close to zero.\nHow can both be true?',
 '[{"text": "Because r only measures how well a STRAIGHT line fits, and this pattern is curved", "feedback": "Correct."},
   {"text": "Because there must be an error in the calculation", "feedback": "This treats a value that surprises you as an arithmetic slip. Nothing has gone wrong in the computing of r."},
   {"text": "Because the sample is too small for r to be meaningful", "feedback": "This blames the sample size. A thousand more points following the same pattern would leave r exactly where it is."},
   {"text": "Because the two variables are not really related", "feedback": "This reads r near zero as a verdict on the whole plot, which contradicts the clear pattern the question describes."}]'::jsonb,
 0, 'sub-scatter-correlation'),

(12, 'MDM4U', 'Displays of Data', 1, 18, 'Medium',
 E'A regression on age against annual income gives r = 0.9825.\nWhat is the coefficient of determination, to four decimal places?',
 '[{"text": "0.9825", "feedback": "That is r itself, copied across without being squared."},
   {"text": "1.9650", "feedback": "The value was doubled rather than squared."},
   {"text": "0.9653", "feedback": "Correct."},
   {"text": "0.9912", "feedback": "The square ROOT was taken instead of the square. Squaring a number below 1 makes it smaller, not larger."}]'::jsonb,
 2, 'sub-regression'),

(12, 'MDM4U', 'Displays of Data', 1, 19, 'Medium',
 'A regression of income on age gives a coefficient of determination of 0.9654. What does that mean?',
 '[{"text": "About 96.5 per cent of the variation in income is explained by the linear relationship with age", "feedback": "Correct."},
   {"text": "About 96.5 per cent of the data points lie exactly on the line", "feedback": "No count of points is involved. Often none of them lie exactly on the line."},
   {"text": "The correlation between age and income is 96.5 per cent", "feedback": "That describes r, and r is the square root of this value rather than this value."},
   {"text": "The slope of the line of best fit is 0.965", "feedback": "The slope is a separate number carried in dollars per year. This one has no units at all."}]'::jsonb,
 0, 'sub-regression'),

(12, 'MDM4U', 'Displays of Data', 1, 20, 'Medium',
 E'A pictograph shows a doubling by drawing an icon at twice the width AND twice the height.\nWhat is wrong with that?',
 '[{"text": "Nothing is wrong here, since both dimensions were scaled by exactly the same factor", "feedback": "Scaling both dimensions is precisely the problem. The eye compares the whole icon rather than one of its dimensions on its own."},
   {"text": "The area is halved", "feedback": "Enlarging in both directions can only make the icon bigger."},
   {"text": "The icon becomes too small to recognise", "feedback": "It becomes larger rather than smaller, and legibility is not what is being distorted."},
   {"text": "The area becomes four times as large, so the change looks four times as big", "feedback": "Correct."}]'::jsonb,
 3, 'sub-misleading-graphs'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): work with a real data set, or judge a claim. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Displays of Data', 1, 21, 'Challenge',
 'What distinguishes inferential statistics from descriptive statistics?',
 '[{"text": "Inferential statistics only summarise the data collected", "feedback": "This is the job of DESCRIPTIVE statistics, attached to the wrong name."},
   {"text": "They are two names for the same activity", "feedback": "They answer different questions. One says what this data looks like; the other says what it suggests about everyone else."},
   {"text": "Inferential statistics draw conclusions about a population from a sample", "feedback": "Correct."},
   {"text": "Descriptive statistics draw conclusions about a population from a sample", "feedback": "Descriptive statistics stay inside the data that was actually collected. Reaching past the sample is not part of what they do."}]'::jsonb,
 2, 'sub-data-types'),

(12, 'MDM4U', 'Displays of Data', 1, 22, 'Challenge',
 'A researcher measures every single member of the population. What is that called?',
 '[{"text": "A statistic", "feedback": "A statistic is a NUMBER computed from data, not the method of collecting it."},
   {"text": "An experiment", "feedback": "An experiment imposes a treatment on its subjects. Measuring everyone imposes nothing."},
   {"text": "A census", "feedback": "Correct."},
   {"text": "A sample", "feedback": "A sample deliberately leaves people out. Nobody is left out here."}]'::jsonb,
 2, 'sub-data-types'),

(12, 'MDM4U', 'Displays of Data', 1, 23, 'Challenge',
 'How are the bars of a Pareto chart ordered?',
 '[{"text": "By the order in which the data were collected", "feedback": "Collection order carries no meaning for categories, and it is not what defines a Pareto chart."},
   {"text": "From tallest to shortest", "feedback": "Correct."},
   {"text": "From shortest to tallest", "feedback": "The sort is by size but it runs the wrong way. Check which end of a Pareto chart is meant to carry the emphasis."},
   {"text": "Alphabetically by category name", "feedback": "Alphabetical order is a plain bar graph. A Pareto chart sorts by size on purpose."}]'::jsonb,
 1, 'sub-categoric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 24, 'Challenge',
 'What is the main advantage a bar graph has over a pie chart when comparing the sizes of categories accurately?',
 '[{"text": "People judge lengths far more accurately than they judge angles or areas", "feedback": "Correct."},
   {"text": "A bar graph can show a larger number of categories at once than a pie chart can", "feedback": "It usually can, but that is a matter of room rather than accuracy. The real gain is in how the eye reads the shape."},
   {"text": "A bar graph can use colour", "feedback": "Both can, and colour is decoration rather than information."},
   {"text": "A bar graph shows percentages and a pie chart does not", "feedback": "A pie chart is built out of percentages. Either display can be labelled with them."}]'::jsonb,
 0, 'sub-categoric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 25, 'Challenge',
 E'A data set is 3, 7, 7, 8, 12, 15, 21.\nWhat are the median and the interquartile range?',
 '[{"text": "Median 8 and IQR 18", "feedback": "The median is right but the RANGE was reported instead of the interquartile range. The IQR uses the quartiles, not the extremes."},
   {"text": "Median 10.4 and IQR 8", "feedback": "The IQR is right but the MEAN was reported instead of the median. The median is the middle value once the data are in order."},
   {"text": "Median 7 and IQR 8", "feedback": "The middle of seven values is the fourth one, not the third."},
   {"text": "Median 8 and IQR 8", "feedback": "Correct."}]'::jsonb,
 3, 'sub-numeric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 26, 'Challenge',
 'On a box plot the right-hand whisker is much longer than the left-hand one. What does that say about the distribution?',
 '[{"text": "It is bimodal", "feedback": "A box plot cannot show a second peak at all, so it can never be the evidence for bimodality."},
   {"text": "It is skewed right", "feedback": "Correct."},
   {"text": "It is skewed left", "feedback": "This takes the direction from the wrong end of the plot."},
   {"text": "It is symmetric about its centre", "feedback": "Symmetric distributions have whiskers of similar length on both sides."}]'::jsonb,
 1, 'sub-numeric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 27, 'Challenge',
 E'Ice cream sales and drowning deaths both rise and fall together across the year, giving r = 0.9.\nWhat is the best explanation?',
 '[{"text": "A lurking variable, the season, drives both", "feedback": "Correct."},
   {"text": "Eating ice cream makes people more likely to drown", "feedback": "This is the causal reading, and it is the trap the whole lesson exists to set. A third factor moves both at once."},
   {"text": "The drownings are what cause ice cream sales to rise", "feedback": "Reversing the direction does not rescue a causal claim that was never supported."},
   {"text": "The correlation must have been calculated incorrectly", "feedback": "The number is real. What is wrong is the story people attach to it."}]'::jsonb,
 0, 'sub-scatter-correlation'),

(12, 'MDM4U', 'Displays of Data', 1, 28, 'Challenge',
 E'For eight employees, income in thousands against age fits the line y = -0.864 + 1.150x.\nWhat income does it predict for a 65-year-old, to two decimal places?',
 '[{"text": "73.89 thousand", "feedback": "Correct."},
   {"text": "74.75 thousand", "feedback": "The intercept was left out. The line is not just the slope times the age."},
   {"text": "75.61 thousand", "feedback": "The intercept was added instead of subtracted. It is negative in this equation."},
   {"text": "64.14 thousand", "feedback": "The intercept was subtracted from the age rather than from the slope times the age."}]'::jsonb,
 0, 'sub-regression'),

(12, 'MDM4U', 'Displays of Data', 1, 29, 'Challenge',
 'What is a residual in linear regression?',
 '[{"text": "The difference between the largest and the smallest y-value", "feedback": "That is the range of the data, which has nothing to do with the line."},
   {"text": "The observed value minus the value the line predicts", "feedback": "Correct."},
   {"text": "The horizontal distance from a data point to the line", "feedback": "Regression measures vertically, because the line is being used to predict y from x."},
   {"text": "The slope of the line of best fit", "feedback": "The slope is one number for the whole line. There is one residual for every data point."}]'::jsonb,
 1, 'sub-regression'),

(12, 'MDM4U', 'Displays of Data', 1, 30, 'Challenge',
 'A graph has a vertical axis with a label but no numbers on it. Why is that misleading?',
 '[{"text": "It is acceptable, as long as the graph itself has been given a title", "feedback": "A title says what is being shown. It does not say how much."},
   {"text": "It forces the reader to extrapolate", "feedback": "Extrapolation is predicting beyond the data. Here the trouble is that even the data cannot be read."},
   {"text": "There is no way to tell how big any of the changes actually are", "feedback": "Correct."},
   {"text": "It makes the graph look symmetric", "feedback": "Removing the numbers does not change the shape of the picture at all; it changes what can be concluded from it."}]'::jsonb,
 2, 'sub-misleading-graphs'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): the claims that sound right. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Displays of Data', 1, 31, 'Advanced',
 'Which of these is a PARAMETER rather than a statistic?',
 '[{"text": "The standard deviation of the 200 sampled heights", "feedback": "Any number computed from a sample is a statistic, whichever measure it is."},
   {"text": "The mean height of every student in Ontario", "feedback": "Correct."},
   {"text": "The mean height of 200 randomly chosen students", "feedback": "That comes from a sample, which makes it a statistic. It is an estimate of the parameter rather than the parameter itself."},
   {"text": "The number of students included in the sample", "feedback": "That is a fact about the sample, so it is a statistic. It says nothing about the population."}]'::jsonb,
 1, 'sub-data-types'),

(12, 'MDM4U', 'Displays of Data', 1, 32, 'Advanced',
 E'A survey asks people to name their favourite of five sports, and 15 per cent answer Other.\nIs a pie chart appropriate?',
 '[{"text": "No, because Other is not a real category", "feedback": "It is a perfectly real category for this purpose: it holds everybody the first five miss, which is what keeps the total complete."},
   {"text": "No, because six separate categories are far too many for a single pie chart to show clearly", "feedback": "Six is comfortably readable. Nothing about the count rules the display out."},
   {"text": "Only if the Other group is left out first", "feedback": "Dropping it is the one thing that would break the chart, because the remaining slices would no longer add to a whole."},
   {"text": "Yes, because every person falls into exactly one category and the six add to the whole", "feedback": "Correct."}]'::jsonb,
 3, 'sub-categoric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 33, 'Advanced',
 'Why should every bar in a bar graph be drawn the same width?',
 '[{"text": "Because graphing software requires it", "feedback": "Software will happily draw uneven bars. The requirement comes from honesty, not from the tool."},
   {"text": "Because the categories have to be equally likely", "feedback": "Categories are almost never equally likely, and a bar graph exists precisely to show that they are not."},
   {"text": "Because a reader judges by area as well as height, so unequal widths distort the comparison", "feedback": "Correct."},
   {"text": "Because otherwise the bars will not fit on the page", "feedback": "Fitting is a practical matter and can always be solved by rescaling. The reason is about how the picture is read."}]'::jsonb,
 2, 'sub-categoric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 34, 'Advanced',
 E'A data set is 4, 8, 9, 11, 14, 40.\nWhich measure of centre represents it best, and why?',
 '[{"text": "The range, because it shows how spread out the data are", "feedback": "The range is a measure of SPREAD rather than of centre, and the outlier distorts it too."},
   {"text": "The median, because the 40 is an outlier that drags the mean upward", "feedback": "Correct."},
   {"text": "The mean, because it uses every value in the data", "feedback": "Using every value is exactly the weakness here. One unusual value pulls the mean above five of the six numbers."},
   {"text": "The mode, because it is the value that occurs most often", "feedback": "Every value here occurs once, so there is no mode to report."}]'::jsonb,
 1, 'sub-numeric-displays'),

(12, 'MDM4U', 'Displays of Data', 1, 35, 'Advanced',
 E'Two variables have a correlation coefficient of 0.05, yet their scatter plot shows the points sitting on a near-perfect curve.\nWhat does that tell you?',
 '[{"text": "There is essentially no relationship between the two variables", "feedback": "The picture says otherwise. A near-perfect curve is about as strong a relationship as data can show."},
   {"text": "The data must have been recorded incorrectly", "feedback": "Nothing is wrong with the data. The mismatch is between what r measures and what the data does."},
   {"text": "The correlation coefficient should have come out as 1", "feedback": "It would if the pattern were a straight line. On a symmetric curve the best straight fit really is flat."},
   {"text": "The relationship is strong but not linear, and r only measures the linear part", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatter-correlation'),

(12, 'MDM4U', 'Displays of Data', 1, 36, 'Advanced',
 'Two variables have a correlation coefficient of exactly zero. Can they still be related?',
 '[{"text": "Only if one of the variables is categoric", "feedback": "A correlation coefficient is only computed for two numeric variables in the first place."},
   {"text": "Yes, because a non-linear relationship can give a correlation of zero", "feedback": "Correct."},
   {"text": "No, a coefficient of zero rules out any relationship", "feedback": "This reads a zero coefficient as a verdict on relationships of every kind. Check what r is actually built to detect."},
   {"text": "Only if the sample is very small", "feedback": "Sample size does not change the point. A coefficient of zero carries the same meaning whatever the size of the sample."}]'::jsonb,
 1, 'sub-scatter-correlation'),

(12, 'MDM4U', 'Displays of Data', 1, 37, 'Advanced',
 E'The line y = -0.864 + 1.150x was fitted to employees aged between 19 and 54.\nWhat is wrong with using it to predict the income of a 5-year-old?',
 '[{"text": "It is interpolation, and interpolation is always unreliable", "feedback": "Interpolation means predicting INSIDE the range of the data, which this is not, and it is generally the reliable case."},
   {"text": "It is extrapolation, but extrapolation is perfectly reliable so long as the correlation is strong", "feedback": "A strong correlation says the line fits the data you HAVE. It promises nothing about a region no data ever came from."},
   {"text": "Nothing is wrong, because the line is defined for every value of x", "feedback": "The equation is defined everywhere; the RELATIONSHIP it describes was only ever observed over a narrow band of ages."},
   {"text": "It is extrapolation: 5 lies far outside the range of the data, so the pattern may not hold there", "feedback": "Correct."}]'::jsonb,
 3, 'sub-regression'),

(12, 'MDM4U', 'Displays of Data', 1, 38, 'Advanced',
 E'For income in thousands of dollars against age in years, the line of best fit has slope 1.150.\nWhat does that slope mean in context?',
 '[{"text": "The income of a person aged zero is about 1150 dollars", "feedback": "That is what the INTERCEPT would say, and here the intercept is negative."},
   {"text": "Income rises by about 1.15 per cent for each additional year", "feedback": "The slope is in the units of the data, which are thousands of dollars per year, not a percentage."},
   {"text": "Each additional year of age is associated with about 1150 dollars more annual income", "feedback": "Correct."},
   {"text": "Each additional year of age CAUSES about 1150 dollars more annual income", "feedback": "The arithmetic is right and the claim is not. A regression line describes an association; it cannot establish a cause."}]'::jsonb,
 2, 'sub-regression'),

(12, 'MDM4U', 'Displays of Data', 1, 39, 'Advanced',
 'A line graph is drawn with its horizontal axis squeezed narrow, so a slow rise over ten years climbs steeply across the page. What has been done?',
 '[{"text": "The horizontal scale has been compressed to steepen the line", "feedback": "Correct."},
   {"text": "The vertical axis has been truncated", "feedback": "Truncating the vertical axis is a different trick with a similar effect. Nothing has been done to the vertical axis in this graph."},
   {"text": "The data have been smoothed", "feedback": "Smoothing removes wobble from a line. It does not change how steep the overall climb appears."},
   {"text": "The sample was biased", "feedback": "Bias is a fault in how the data were COLLECTED. This is a fault in how honest data were drawn."}]'::jsonb,
 0, 'sub-misleading-graphs'),

(12, 'MDM4U', 'Displays of Data', 1, 40, 'Advanced',
 'A pie chart is drawn in three dimensions and tilted so that one slice sits at the front. Why is that a problem?',
 '[{"text": "The labels can no longer be attached to the slices", "feedback": "Labels can be placed on any pie chart. The distortion happens even when every slice is labelled."},
   {"text": "Perspective gives the front slice more visible area than its share of the total", "feedback": "Correct."},
   {"text": "It is not a problem at all, because the underlying percentages themselves are unchanged", "feedback": "The percentages are unchanged and the picture still lies. A reader judges by the area they can see."},
   {"text": "The slices no longer add up to 100 per cent", "feedback": "They still do. What changes is how much of each one the eye is shown."}]'::jsonb,
 1, 'sub-misleading-graphs');

-- --- questions_mdm4u_u2.sql ---

-- ===========================================================================
-- MDM4U — Unit 2: Collecting Data — 40 questions
-- ===========================================================================
-- Grade 12 Data Management, authored from the Jensen MDM4U lesson material
-- for this unit:
--
--   Lesson 1  Developing a thesis
--   Lesson 2  Characteristics of data
--   Lesson 3  Random sampling
--   Lesson 4  Survey design and bias
--   Lesson 5  Experiment design
--
-- Five lessons, six subtopics. Lesson 4 is split into SURVEY DESIGN and
-- BIAS, because a student can write a beautifully worded questionnaire and
-- still hand it to the wrong fifty people. Which of those two went wrong is
-- exactly what the tutor needs to know, and one combined traffic light
-- would hide it.
--
-- This is the only unit in the whole bank with no arithmetic to speak of,
-- and that changes what a wrong option has to be. There is no sign to lose
-- and no exponent to drop. Every distractor here is a SENTENCE a student
-- would write on a test and lose the mark for: a bias named correctly but
-- attached to the wrong stage of the study, a sampling method described by
-- what it feels like rather than by what it guarantees, a confounding
-- variable promoted to a cause.
--
-- The mistakes that repeat right through the unit:
--
--   * confusing WHO was asked with HOW they were asked, which turns every
--     bias question into a coin toss between sampling and response bias
--   * calling a haphazard sample random, when random has a technical
--     meaning that haphazard does not meet
--   * treating an observational study as if it could establish a cause
--   * describing randomisation as something that makes groups equal, rather
--     than something that makes the differences between them fair
--
-- Feedback names the mistake and stops there.
--
-- The two computational questions in the file, the systematic sampling
-- interval and the proportional stratified allocation, were checked
-- independently before delivery.
--
-- FIGURES: none, and for once the reason is not that a picture would leak.
-- There is simply nothing here to draw. Every question in this unit is
-- about a decision someone made while collecting data, and a decision has
-- no shape. The one candidate, Jensen random rectangles activity, is a
-- classroom exercise rather than a question: the point of it is that your
-- eye picks big rectangles, and a student answering on a phone would just
-- be told that in the prompt.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. The figure file for this
-- course does not touch this unit, but it wipes and re-attaches the whole
-- of MDM4U, so it should still be re-run after any reload here.
--
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- Easy and Medium are free; Challenge and Advanced need Astro+.
--
-- No apostrophes anywhere in any string — one would end the SQL string and
-- kill the whole file.
-- ===========================================================================

delete from questions where course_code = 'MDM4U' and unit = 'Collecting Data';

insert into misconception_labels (tag, label) values
  ('sub-thesis-variables',     'Theses, variables and sources of data'),
  ('sub-data-characteristics', 'Characteristics of data'),
  ('sub-sampling-methods',     'Sampling methods'),
  ('sub-survey-design',        'Survey and question design'),
  ('sub-bias',                 'Types of bias'),
  ('sub-experiment-design',    'Experiment design')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): the vocabulary, one term at a time.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Collecting Data', 2, 1, 'Easy',
 'Data that you collect yourself, firsthand, is called what?',
 '[{"text": "Secondary data", "feedback": "Secondary data comes from a study somebody ELSE carried out. The distinction is who did the collecting."},
   {"text": "Aggregate data", "feedback": "Aggregate describes data that has been summarised into totals. It says nothing about who gathered it."},
   {"text": "Microdata", "feedback": "Microdata describes data kept at the level of individual records. Again, that is about its form rather than its source."},
   {"text": "Primary data", "feedback": "Correct."}]'::jsonb,
 3, 'sub-thesis-variables'),

(12, 'MDM4U', 'Collecting Data', 2, 2, 'Easy',
 'A study investigates how the number of hours spent studying affects test scores. Which is the independent variable?',
 '[{"text": "The test scores the students achieve", "feedback": "That is what is being MEASURED in response, which makes it the dependent variable."},
   {"text": "The students", "feedback": "The students are the subjects being studied, not a variable measured on them."},
   {"text": "The school", "feedback": "The setting is not a variable in this study; nothing about it is being changed or measured."},
   {"text": "The number of hours spent studying", "feedback": "Correct."}]'::jsonb,
 3, 'sub-thesis-variables'),

(12, 'MDM4U', 'Collecting Data', 2, 3, 'Easy',
 'What is microdata?',
 '[{"text": "Data that is kept at the level of the individual respondents", "feedback": "Correct."},
   {"text": "Data that has already been summarised into totals", "feedback": "That is AGGREGATE data. Microdata is what those totals were built from."},
   {"text": "Data from a very small sample", "feedback": "The size of the sample is a separate matter. Microdata from a huge survey is still microdata."},
   {"text": "Data whose values happen to be small numbers", "feedback": "The word refers to the level of DETAIL kept, not to the size of any number in it."}]'::jsonb,
 0, 'sub-data-characteristics'),

(12, 'MDM4U', 'Collecting Data', 2, 4, 'Easy',
 'What makes a sample a SIMPLE RANDOM sample?',
 '[{"text": "The population is divided into groups before anyone is chosen", "feedback": "That describes stratified or cluster sampling, both of which add a step before the randomness."},
   {"text": "Every member of the population is equally likely to be chosen, and choices are made independently", "feedback": "Correct."},
   {"text": "The first n people encountered are chosen", "feedback": "That is a convenience sample. Being first through a door is not the same as being chosen by chance."},
   {"text": "The sample is chosen so that it looks representative", "feedback": "Choosing it to look representative is a judgement, and judgements carry bias. Randomness is what makes the process fair."}]'::jsonb,
 1, 'sub-sampling-methods'),

(12, 'MDM4U', 'Collecting Data', 2, 5, 'Easy',
 'A researcher surveys whoever happens to be walking past the entrance of a shopping centre. Which sampling method is that?',
 '[{"text": "Convenience sampling", "feedback": "Correct."},
   {"text": "Simple random sampling", "feedback": "Nobody who was somewhere else at that moment had any chance of being chosen, so the chances were not equal."},
   {"text": "Systematic sampling", "feedback": "Systematic sampling picks every nth member from an ordered list of the whole population. No such list is being used here."},
   {"text": "Stratified sampling", "feedback": "Stratified sampling divides the population into groups first and samples within each. No groups are being formed here."}]'::jsonb,
 0, 'sub-sampling-methods'),

(12, 'MDM4U', 'Collecting Data', 2, 6, 'Easy',
 'A question that gives the respondent a fixed list of answers to choose from is called what?',
 '[{"text": "A loaded question", "feedback": "A loaded question smuggles an assumption into itself. That is about the wording, not about the answer format."},
   {"text": "A closed question", "feedback": "Correct."},
   {"text": "An open question", "feedback": "An open question leaves the answer entirely up to the respondent, in their own words."},
   {"text": "A leading question", "feedback": "A leading question pushes towards one answer. It can be either open or closed."}]'::jsonb,
 1, 'sub-survey-design'),

(12, 'MDM4U', 'Collecting Data', 2, 7, 'Easy',
 'A questionnaire is mailed to 1000 households and only the people with strong opinions bother to send it back. Which type of bias is that?',
 '[{"text": "Sampling bias, because the 1000 households were badly chosen", "feedback": "The sample was chosen fairly. What went wrong happened afterwards, when part of it declined to take part."},
   {"text": "Measurement bias", "feedback": "Measurement bias comes from the way the questions are asked. Nothing here is said about the wording."},
   {"text": "Household bias", "feedback": "Household bias is about which PERSON within a home ends up answering. Here the trouble is which homes answered at all."},
   {"text": "Non-response bias", "feedback": "Correct."}]'::jsonb,
 3, 'sub-bias'),

(12, 'MDM4U', 'Collecting Data', 2, 8, 'Easy',
 'A survey asks: Do you agree that our excellent new recycling policy should continue? Which type of bias does that introduce?',
 '[{"text": "Sampling bias", "feedback": "Sampling bias is about who was asked. Nothing here is said about how the respondents were chosen."},
   {"text": "Household bias", "feedback": "Household bias is about which member of a home answers. This question is about the wording."},
   {"text": "Response bias", "feedback": "Correct."},
   {"text": "Non-response bias", "feedback": "That name is for people who decline to take part at all. Everyone here answers; the problem is what they are being nudged towards."}]'::jsonb,
 2, 'sub-bias'),

(12, 'MDM4U', 'Collecting Data', 2, 9, 'Easy',
 'What distinguishes an experiment from an observational study?',
 '[{"text": "An observational study uses a survey and an experiment does not", "feedback": "A survey is one kind of observational study, but plenty of others watch behaviour instead of asking about it."},
   {"text": "An experiment is always blinded", "feedback": "Blinding is a good idea and many experiments use it, but an experiment is still an experiment without it."},
   {"text": "An experiment imposes a treatment on its subjects rather than merely observing them", "feedback": "Correct."},
   {"text": "An experiment uses a larger sample", "feedback": "Size is not what separates them. Many observational studies are far larger than any experiment."}]'::jsonb,
 2, 'sub-experiment-design'),

(12, 'MDM4U', 'Collecting Data', 2, 10, 'Easy',
 'What is a placebo?',
 '[{"text": "The variable being measured at the end of the study", "feedback": "That is the response variable."},
   {"text": "A dummy treatment that looks like the real one", "feedback": "Correct."},
   {"text": "The real treatment being tested", "feedback": "That is what the placebo is compared AGAINST."},
   {"text": "The group of subjects who receive no treatment at all", "feedback": "That is the control group. The placebo is the thing given to them, not the people."}]'::jsonb,
 1, 'sub-experiment-design'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): apply one idea to one situation.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Collecting Data', 2, 11, 'Medium',
 'You download a table from the Statistics Canada website for your project. What kind of data is that?',
 '[{"text": "Primary data", "feedback": "Primary means you collected it yourself. Somebody else did the collecting here."},
   {"text": "Microdata", "feedback": "It may or may not be microdata, depending on whether individual records are kept. Either way that is a separate question from where it came from."},
   {"text": "A census of the whole population", "feedback": "A census is a method of collection. What you have is the output, and it came from somebody else."},
   {"text": "Secondary data", "feedback": "Correct."}]'::jsonb,
 3, 'sub-thesis-variables'),

(12, 'MDM4U', 'Collecting Data', 2, 12, 'Medium',
 'What makes a good thesis, or research question, for a data management project?',
 '[{"text": "It can be answered with a yes or a no", "feedback": "Plenty of good questions are yes-or-no ones, and plenty are not. What matters is whether data can settle it."},
   {"text": "It can be settled by data that you are able to collect", "feedback": "Correct."},
   {"text": "It is broad enough to cover the whole topic", "feedback": "A question broad enough to cover everything is usually one that no realistic data set can settle."},
   {"text": "It is phrased so the answer is already known", "feedback": "Then there is nothing left to investigate, and the study becomes an exercise in confirming what you started with."}]'::jsonb,
 1, 'sub-thesis-variables'),

(12, 'MDM4U', 'Collecting Data', 2, 13, 'Medium',
 'A researcher is choosing between a longitudinal study and a cross-sectional study. Which of the two follows the SAME subjects throughout?',
 '[{"text": "Both of them", "feedback": "Only one of the two tracks individuals. The other deliberately does not."},
   {"text": "Neither of them", "feedback": "One of them is defined by exactly this property."},
   {"text": "A longitudinal study", "feedback": "Correct."},
   {"text": "A cross-sectional study", "feedback": "A cross-sectional study takes a snapshot of a population at one moment. Different people may appear at different times."}]'::jsonb,
 2, 'sub-data-characteristics'),

(12, 'MDM4U', 'Collecting Data', 2, 14, 'Medium',
 E'A school has 1500 students and a systematic random sample of 75 is wanted.\nWhat is the sampling interval?',
 '[{"text": "75", "feedback": "That is the sample size. The interval is how far apart the chosen names sit on the list."},
   {"text": "1425", "feedback": "That is the number of students left out. The interval comes from dividing, not subtracting."},
   {"text": "5", "feedback": "That is the sample expressed as a percentage of the school. An interval counts places along the list, not per cent."},
   {"text": "20", "feedback": "Correct."}]'::jsonb,
 3, 'sub-sampling-methods'),

(12, 'MDM4U', 'Collecting Data', 2, 15, 'Medium',
 E'A school of 800 students has 240 in grade nine. A stratified random sample of 10 per cent of the school is taken.\nHow many grade nines are in the sample?',
 '[{"text": "24", "feedback": "Correct."},
   {"text": "80", "feedback": "That is the size of the WHOLE sample. Grade nine is only part of the school, so it supplies only part of it."},
   {"text": "20", "feedback": "The 80 places were split evenly among four grades. Stratified sampling makes each grade proportional to its own size instead."},
   {"text": "240", "feedback": "That is the number of grade nines in the school. The sample takes a tenth of them."}]'::jsonb,
 0, 'sub-sampling-methods'),

(12, 'MDM4U', 'Collecting Data', 2, 16, 'Medium',
 'What is the problem with the survey question: Which player would you NOT select first?',
 '[{"text": "The negative wording is easy for a respondent to misread", "feedback": "Correct."},
   {"text": "It offers too many options for anyone to hold in mind", "feedback": "The number of options is reasonable. The difficulty is in reading the question at all."},
   {"text": "It is an open question", "feedback": "It is closed: a list of players is supplied to choose from."},
   {"text": "It collects categoric data", "feedback": "Categoric data is perfectly respectable and is exactly what this question should collect."}]'::jsonb,
 0, 'sub-survey-design'),

(12, 'MDM4U', 'Collecting Data', 2, 17, 'Medium',
 'A telephone survey is carried out only on weekday mornings, so people at work are never reached. Which type of bias is that?',
 '[{"text": "Sampling bias", "feedback": "Correct."},
   {"text": "Non-response bias", "feedback": "Non-response bias needs people to have been asked and to have declined. These people were never reachable in the first place."},
   {"text": "Measurement bias", "feedback": "Measurement bias comes from how the questions are worded. Nothing here is said about the questions."},
   {"text": "Household bias", "feedback": "Household bias is about which member of a home answers. Here whole categories of home are never called at all."}]'::jsonb,
 0, 'sub-bias'),

(12, 'MDM4U', 'Collecting Data', 2, 18, 'Medium',
 'A survey selects households at random and interviews whoever opens the door. What bias does that introduce?',
 '[{"text": "None, because the households were chosen at random", "feedback": "The households were chosen fairly. The individuals within them were not, and it is individuals who answer."},
   {"text": "Household bias, from unequal household sizes", "feedback": "Correct."},
   {"text": "Non-response bias", "feedback": "Somebody does answer at every home visited. The trouble is in WHICH person that turns out to be."},
   {"text": "Measurement bias", "feedback": "Measurement bias comes from the wording. Nothing here is said about the questions."}]'::jsonb,
 1, 'sub-bias'),

(12, 'MDM4U', 'Collecting Data', 2, 19, 'Medium',
 E'Fifty smokers are randomly split into two groups. One group gets nicotine patches containing a new drug and the other gets ordinary nicotine patches.\nWhat is the second group called?',
 '[{"text": "A block", "feedback": "A block is a group of similar subjects formed BEFORE the random assignment, to remove a known source of variation."},
   {"text": "The placebo", "feedback": "The placebo is the dummy treatment itself, not the people who receive it."},
   {"text": "The control group", "feedback": "Correct."},
   {"text": "The treatment group", "feedback": "That is the group receiving the thing being tested, which is the first one here."}]'::jsonb,
 2, 'sub-experiment-design'),

(12, 'MDM4U', 'Collecting Data', 2, 20, 'Medium',
 'What does assigning subjects to treatments at random accomplish?',
 '[{"text": "It guarantees the sample is large enough", "feedback": "Size is the principle of replication, which is a separate requirement."},
   {"text": "It spreads unknown differences across the groups", "feedback": "Correct."},
   {"text": "It makes the two treatment groups exactly the same size", "feedback": "Equal sizes are convenient and are usually arranged separately. Randomness is doing something else entirely."},
   {"text": "It removes the need for a control group", "feedback": "The comparison is still needed. Random assignment decides WHO goes into each group, not whether the groups exist."}]'::jsonb,
 1, 'sub-experiment-design'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): judge a design rather than name a term. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Collecting Data', 2, 21, 'Challenge',
 E'A study finds that children who eat breakfast score higher on tests. Children who eat breakfast also tend to come from wealthier homes.\nWhat role does family income play here?',
 '[{"text": "It is the treatment", "feedback": "Nothing was imposed on anybody. This is an observational study, so there is no treatment at all."},
   {"text": "There is no confounding, because breakfast clearly comes first in time", "feedback": "Coming first in time is not enough. Income was there before both, and it could be producing both effects on its own."},
   {"text": "It is a confounding variable", "feedback": "Correct."},
   {"text": "It is the response variable", "feedback": "The response is the thing measured at the end, which is the test score."}]'::jsonb,
 2, 'sub-thesis-variables'),

(12, 'MDM4U', 'Collecting Data', 2, 22, 'Challenge',
 'Why is primary data often preferred to secondary data?',
 '[{"text": "Because it is cheaper to obtain", "feedback": "It is usually far more expensive in time and effort. Secondary data is often free."},
   {"text": "Because it is always larger", "feedback": "It is almost always much smaller. Secondary sources are where the large data sets live."},
   {"text": "Because you control how it was collected, so you know exactly what its limitations are", "feedback": "Correct."},
   {"text": "Because it is always more accurate", "feedback": "A carefully run national survey will usually beat anything a student can collect. What primary data gives you is knowledge of its own weaknesses."}]'::jsonb,
 2, 'sub-thesis-variables'),

(12, 'MDM4U', 'Collecting Data', 2, 23, 'Challenge',
 'What kind of question can aggregate data NOT answer?',
 '[{"text": "Anything about percentages", "feedback": "Percentages come straight out of totals, so aggregate data handles them easily."},
   {"text": "Anything about how a figure has changed over time", "feedback": "Aggregate figures from several years show a trend perfectly well."},
   {"text": "Anything about the individual respondents behind those totals", "feedback": "Correct."},
   {"text": "Anything about totals", "feedback": "Totals are exactly what aggregate data is made of."}]'::jsonb,
 2, 'sub-data-characteristics'),

(12, 'MDM4U', 'Collecting Data', 2, 24, 'Challenge',
 'A survey records each respondent height to the nearest tenth of a centimetre. What kind of data is that?',
 '[{"text": "Aggregate", "feedback": "These are individual measurements, so they are microdata rather than aggregate."},
   {"text": "Numeric and continuous", "feedback": "Correct."},
   {"text": "Numeric and discrete, because of the rounding", "feedback": "Rounding to a tenth is a limit of the ruler, not of the quantity. A height can in principle take any value in a range."},
   {"text": "Categoric", "feedback": "The values are genuine numbers that can be averaged, which categories cannot."}]'::jsonb,
 1, 'sub-data-characteristics'),

(12, 'MDM4U', 'Collecting Data', 2, 25, 'Challenge',
 'In stratified random sampling, why is the number taken from each stratum made proportional to the size of that stratum?',
 '[{"text": "So that each group keeps its share of the whole population", "feedback": "Correct."},
   {"text": "So that every group carries equal weight in the sample", "feedback": "Equal weight would OVER-represent the small groups. Proportional weight is what keeps the sample looking like the population."},
   {"text": "Because it makes the arithmetic easier", "feedback": "Equal sizes would make the arithmetic easier. Proportional allocation is chosen despite the extra work."},
   {"text": "To reduce non-response", "feedback": "Non-response depends on who agrees to take part, and proportional allocation does nothing about that."}]'::jsonb,
 0, 'sub-sampling-methods'),

(12, 'MDM4U', 'Collecting Data', 2, 26, 'Challenge',
 'A systematic sample takes every tenth name from a list. What hidden risk does that carry?',
 '[{"text": "A pattern of period ten in the list skews the sample", "feedback": "Correct."},
   {"text": "It is never random, because the choices are not independent", "feedback": "The choices genuinely are not independent, but with a randomly chosen starting point every member still has the same chance of being picked."},
   {"text": "The sample will be too small", "feedback": "The interval is chosen to give whatever sample size is wanted, so size is not the issue."},
   {"text": "It is the same as convenience sampling", "feedback": "Convenience sampling takes whoever is easiest to reach. This one works through the entire population in order."}]'::jsonb,
 0, 'sub-sampling-methods'),

(12, 'MDM4U', 'Collecting Data', 2, 27, 'Challenge',
 'What is a Likert scale used for in a survey?',
 '[{"text": "Rating each item on a common scale", "feedback": "Correct."},
   {"text": "Ranking a list of items in order of importance", "feedback": "That is a ranking question, which forces the items into an order against one another."},
   {"text": "Collecting demographic facts such as age and gender", "feedback": "Those are collected with a simple list of categories rather than a scale."},
   {"text": "Asking a question with no fixed answers at all", "feedback": "That is an open question, which leaves the answer entirely in the words of the respondent."}]'::jsonb,
 0, 'sub-survey-design'),

(12, 'MDM4U', 'Collecting Data', 2, 28, 'Challenge',
 'What is wrong with the question: Given the rising problem of obesity among teenagers, do you agree that physical education should be mandatory?',
 '[{"text": "It is a closed question", "feedback": "Closed questions are perfectly acceptable and are usually easier to analyse."},
   {"text": "It collects categoric data rather than numbers", "feedback": "Categoric data is exactly right for an agree-or-disagree question."},
   {"text": "It offers too few options", "feedback": "Adding more options would not undo the effect of the sentence in front of the question."},
   {"text": "The preamble leads towards agreeing", "feedback": "Correct."}]'::jsonb,
 3, 'sub-survey-design'),

(12, 'MDM4U', 'Collecting Data', 2, 29, 'Challenge',
 E'To measure support for a candidate among 1500 students, a campaign manager surveys the first 50 students to enter the cafeteria in period four. Lunch runs in periods two, three and four.\nWhat is the main problem?',
 '[{"text": "Nothing, because the period was chosen by a random draw", "feedback": "Using randomness at one step does not make the result a random sample of the population."},
   {"text": "Sampling bias, from surveying only one lunch period", "feedback": "Correct."},
   {"text": "Non-response bias, because some of the 50 may not hand the form back", "feedback": "Non-response bias needs people who were asked and then declined. Nobody here has refused anything."},
   {"text": "Measurement bias, because of how the questions are worded", "feedback": "Nothing is said here about the wording. The trouble is in who was reachable."}]'::jsonb,
 1, 'sub-bias'),

(12, 'MDM4U', 'Collecting Data', 2, 30, 'Challenge',
 'What is a double-blind experiment?',
 '[{"text": "Nobody sees any of the results until the study has finished", "feedback": "Holding back results is good practice for other reasons, but blinding is about who knows the ASSIGNMENTS."},
   {"text": "Neither the subjects nor the assessors know the assignments", "feedback": "Correct."},
   {"text": "Only the subjects do not know which treatment they received", "feedback": "That is single blind. Only one side of the study is kept in the dark here."},
   {"text": "Only the researchers do not know which subject received which treatment", "feedback": "That is single blind from the other side. One party still knows what each subject received."}]'::jsonb,
 1, 'sub-experiment-design'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): the designs that look fine until you check them.
-- Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Collecting Data', 2, 31, 'Advanced',
 E'Observational studies suggested hormone replacement cut heart attack risk. The women who chose to take hormones were also richer, better educated, and saw doctors more often.\nWhat role do wealth and doctor visits play?',
 '[{"text": "They are the treatments the women received", "feedback": "Nothing was imposed on anybody. The women decided for themselves, which is precisely what makes the study observational."},
   {"text": "They are strata", "feedback": "Strata are groups a researcher DIVIDES a population into on purpose before sampling. These are traits that happened to travel with the choice."},
   {"text": "They are confounding variables", "feedback": "Correct."},
   {"text": "They are response variables", "feedback": "The response is the outcome being measured, which is the rate of heart attacks."}]'::jsonb,
 2, 'sub-thesis-variables'),

(12, 'MDM4U', 'Collecting Data', 2, 32, 'Advanced',
 E'A researcher has survey data from 2015 and from 2025, but the two surveys questioned different people.\nWhat kind of data is that, and what can it not show?',
 '[{"text": "Experimental data", "feedback": "No treatment was imposed on anybody, so nothing here is an experiment."},
   {"text": "A census, so it describes the whole population exactly", "feedback": "A census measures everybody. These are surveys, which sample."},
   {"text": "Two cross-sections: it can show that the population changed, but not that any individual did", "feedback": "Correct."},
   {"text": "Longitudinal data, with no real limitation", "feedback": "Longitudinal data follows the SAME people. Different respondents at each date makes these two separate snapshots."}]'::jsonb,
 2, 'sub-data-characteristics'),

(12, 'MDM4U', 'Collecting Data', 2, 33, 'Advanced',
 'Why can microdata answer questions that aggregate data cannot?',
 '[{"text": "Because it is more accurate", "feedback": "Aggregate figures are computed from microdata, so they are exactly as accurate as their source."},
   {"text": "Because it is more recent", "feedback": "Both forms can be old or new. The difference is in the level of detail retained."},
   {"text": "Because it is smaller and therefore easier to work with", "feedback": "It is far LARGER than the summary built from it, and considerably harder to handle."},
   {"text": "Because it keeps each individual record", "feedback": "Correct."}]'::jsonb,
 3, 'sub-data-characteristics'),

(12, 'MDM4U', 'Collecting Data', 2, 34, 'Advanced',
 'A researcher divides a city into neighbourhoods, chooses four neighbourhoods at random, and surveys every household in those four. Which method is that?',
 '[{"text": "Stratified sampling", "feedback": "Stratified sampling takes some members from EVERY group. This one takes all the members of a few groups, which is the mirror image."},
   {"text": "Systematic sampling", "feedback": "Systematic sampling steps through an ordered list of the whole population at a fixed interval."},
   {"text": "Simple random sampling", "feedback": "Households in the neighbourhoods that were not chosen had no chance at all, so the chances were not equal."},
   {"text": "Cluster sampling", "feedback": "Correct."}]'::jsonb,
 3, 'sub-sampling-methods'),

(12, 'MDM4U', 'Collecting Data', 2, 35, 'Advanced',
 'A survey asks respondents to put four factors in order from 1 to 4, where 1 is most important. Which type of closed question is that?',
 '[{"text": "A Likert scale question", "feedback": "A Likert scale rates each item separately, so two items can receive the same score."},
   {"text": "A checklist question", "feedback": "A checklist lets the respondent tick any number of items with no order among them."},
   {"text": "A demographic question", "feedback": "Demographic questions collect facts about the respondent, such as age or grade."},
   {"text": "A ranking question", "feedback": "Correct."}]'::jsonb,
 3, 'sub-survey-design'),

(12, 'MDM4U', 'Collecting Data', 2, 36, 'Advanced',
 'Why should a survey avoid asking two things at once, as in: Did you find the staff friendly and helpful?',
 '[{"text": "It uses a Likert scale", "feedback": "It does not, and switching to one would not help: a single rating still cannot separate the two qualities."},
   {"text": "Friendly but unhelpful staff leaves no honest answer", "feedback": "Correct."},
   {"text": "It takes too long for the respondent to read and answer", "feedback": "It is a short question. The trouble is that it has two answers hiding inside one."},
   {"text": "It is an open question", "feedback": "It is closed, and would normally be answered yes or no. That is exactly what makes the double barrel a problem."}]'::jsonb,
 1, 'sub-survey-design'),

(12, 'MDM4U', 'Collecting Data', 2, 37, 'Advanced',
 E'A school of 1500 students has 73 homerooms. An earlier survey reached only the students in one lunch period, and let them take the forms away.\nA revised plan gives one questionnaire to a single student in each homeroom, and waits while it is filled in.\nWhat problem does this NOT fix?',
 '[{"text": "Non-response bias", "feedback": "Waiting for the form does fix that: nobody gets to take it away and forget about it."},
   {"text": "Students in only one lunch period being reachable", "feedback": "That is fixed too, since homerooms cover the whole school regardless of when anyone eats."},
   {"text": "The sample being far too small to support any conclusion", "feedback": "Seventy-three out of 1500 is a workable sample. What is wrong with it is its shape rather than its size."},
   {"text": "Unequal chances between large and small homerooms", "feedback": "Correct."}]'::jsonb,
 3, 'sub-bias'),

(12, 'MDM4U', 'Collecting Data', 2, 38, 'Advanced',
 'An interviewer wearing a campaign badge for one candidate stops people in the street and asks whom they support. Which type of bias is that?',
 '[{"text": "Response bias", "feedback": "Correct."},
   {"text": "Sampling bias", "feedback": "Who gets stopped is a separate matter. Here the trouble is what happens once somebody has been stopped."},
   {"text": "Non-response bias", "feedback": "That name needs people who decline to take part. These people do reply; the worry is that they shade what they say."},
   {"text": "Household bias", "feedback": "Household bias is about which member of a home ends up answering, and no homes are involved here."}]'::jsonb,
 0, 'sub-bias'),

(12, 'MDM4U', 'Collecting Data', 2, 39, 'Advanced',
 E'A firm tests four tyre types by buying four cars and fitting each car with one type.\nWhat is the serious weakness?',
 '[{"text": "There is no control group", "feedback": "The four types are being compared against each other, which supplies the comparison a control group would."},
   {"text": "There is no placebo", "feedback": "A placebo is for hiding a treatment from a person. A car cannot be fooled about which tyres it is wearing."},
   {"text": "The car and the tyre type are confounded, so a difference could come from the cars instead", "feedback": "Correct."},
   {"text": "The sample is too small, and that is the only problem", "feedback": "Four is indeed thin, but even four hundred cars fitted this way would carry the same flaw."}]'::jsonb,
 2, 'sub-experiment-design'),

(12, 'MDM4U', 'Collecting Data', 2, 40, 'Advanced',
 E'The firm improves the tyre study by fitting each car with one tyre of each of the four types.\nWhat is this design called, and what does it achieve?',
 '[{"text": "A blocked design: each car is a block, so car differences drop out", "feedback": "Correct."},
   {"text": "A placebo design, which stops the drivers from knowing which tyres they have", "feedback": "The drivers might well be kept in the dark, but that is blinding and it is not what this arrangement fixes."},
   {"text": "A double-blind design, which stops the researchers from knowing which tyres are which", "feedback": "Blinding hides an assignment. This design changes the assignment itself, so that every car carries every type."},
   {"text": "A stratified design, which divides the tyres into groups before assignment", "feedback": "Stratification is a SAMPLING idea, used when choosing who takes part rather than when assigning treatments."}]'::jsonb,
 0, 'sub-experiment-design');

-- --- questions_mdm4u_u3.sql ---

-- ===========================================================================
-- MDM4U — Unit 3: Normal Distributions — 40 questions
-- ===========================================================================
-- Grade 12 Data Management, authored from the Jensen MDM4U lesson material
-- for this unit:
--
--   Lesson 1  Shapes of distributions
--   Lesson 2  Measures of central tendency
--   Lesson 3  Measures of spread
--   Lesson 4  Normal distributions
--   Lesson 5  Applying the normal distribution, part 1
--   Lesson 6  Applying the normal distribution, part 2
--   Lesson 7  Confidence intervals
--
-- Seven lessons, six subtopics: the two application lessons are counted
-- together as Z-SCORES, because they teach one skill in two sittings.
--
-- The split that matters most on the dashboard is SPREAD against Z-SCORES.
-- Both live on the standard deviation, and a student can compute one
-- flawlessly and still not know what it is for. Separate traffic lights say
-- whether the arithmetic broke or the interpretation did.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Five repeat right through the unit:
--
--   * dividing by n where n take away 1 belongs, or the reverse, which is
--     the difference between a population and a sample standard deviation
--   * stopping at the variance and calling it a standard deviation
--   * getting the sign of a z-score wrong, and so reading the wrong tail
--   * reporting a probability where a value was asked for, or the reverse
--   * describing a confidence interval as a statement about the sample
--     rather than about the population
--
-- Feedback names the mistake and stops there.
--
-- Every quartile, standard deviation, z-score, probability and confidence
-- interval in this file was recomputed independently before delivery. The
-- four confidence intervals reproduce the calculator screenshots printed in
-- the Jensen lessons to three decimal places, which is a useful check that
-- the source was read correctly.
--
-- FIGURES: one, on question 25.
--
--   * Q25 shows two distributions on a common axis with the same centre and
--     different widths, and asks which has the larger standard deviation.
--     There is no vertical scale and the only tick marks the shared centre,
--     so no standard deviation can be read off. What the picture supplies is
--     which curve is wider. The taller curve is the NARROWER one, because
--     both enclose the same area, so a student who reads height as spread
--     picks wrong.
--
-- Rejected: the normal curve with the 68, 95 and 99.7 percentages written
-- under it. That picture is the answer sheet for a third of the unit. Every
-- question about the empirical rule here is asked in words.
--
-- Also rejected: a shaded tail on a normal curve. The shading says which
-- side of the mean the question is about, and getting that side right is
-- most of what the z-score questions test.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mdm4u.sql.
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

delete from questions where course_code = 'MDM4U' and unit = 'Normal Distributions';

insert into misconception_labels (tag, label) values
  ('sub-distribution-shapes',   'Shapes of distributions'),
  ('sub-central-tendency',      'Measures of central tendency'),
  ('sub-spread',                'Measures of spread'),
  ('sub-normal-basics',         'The normal distribution'),
  ('sub-z-scores',              'Z-scores and probabilities'),
  ('sub-confidence-intervals',  'Confidence intervals')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one definition or one short calculation each.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Normal Distributions', 3, 1, 'Easy',
 'A distribution has two clearly separated peaks. What is its shape called?',
 '[{"text": "Uniform", "feedback": "A uniform distribution is flat, with no peak anywhere."},
   {"text": "Bimodal", "feedback": "Correct."},
   {"text": "Symmetric", "feedback": "It may happen to be symmetric as well, but that word says nothing about the number of peaks."},
   {"text": "Skewed", "feedback": "Skew describes a single long tail on one side, not a second peak."}]'::jsonb,
 1, 'sub-distribution-shapes'),

(12, 'MDM4U', 'Normal Distributions', 3, 2, 'Easy',
 'What shape does a distribution have when every value occurs about equally often?',
 '[{"text": "Normal", "feedback": "A normal distribution has a definite peak in the middle and thin tails."},
   {"text": "Bimodal", "feedback": "Bimodal needs two peaks, and a flat distribution has none."},
   {"text": "Skewed right", "feedback": "Skewed right needs a bulk on the left and a long tail to the right. A flat shape has neither."},
   {"text": "Uniform", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distribution-shapes'),

(12, 'MDM4U', 'Normal Distributions', 3, 3, 'Easy',
 'Which measure of central tendency is most affected by a single extreme value?',
 '[{"text": "The mode", "feedback": "The mode is whichever value occurs most often, and a single outlier occurs once."},
   {"text": "All three are affected equally", "feedback": "They are not. Only one of the three adds the actual value into a total, and a very large number pulls that one hard."},
   {"text": "The mean", "feedback": "Correct."},
   {"text": "The median", "feedback": "The median only counts positions, so one unusual value moves it by at most one place."}]'::jsonb,
 2, 'sub-central-tendency'),

(12, 'MDM4U', 'Normal Distributions', 3, 4, 'Easy',
 'What is the median of the data set 4, 9, 11, 15, 20?',
 '[{"text": "11.8", "feedback": "That is the MEAN. The median is the middle value once the data are in order."},
   {"text": "16", "feedback": "That is the range, from 4 up to 20."},
   {"text": "9", "feedback": "That is the second value. With five values the middle one is the third."},
   {"text": "11", "feedback": "Correct."}]'::jsonb,
 3, 'sub-central-tendency'),

(12, 'MDM4U', 'Normal Distributions', 3, 5, 'Easy',
 'What does the interquartile range measure?',
 '[{"text": "The average distance of each value from the mean", "feedback": "That describes the standard deviation, which is built from deviations rather than from quartiles."},
   {"text": "The difference between the mean and the median", "feedback": "That difference is a hint about skew, but it is not a measure of spread."},
   {"text": "The spread of the middle half of the data", "feedback": "Correct."},
   {"text": "The spread of the whole data set from lowest to highest", "feedback": "That is the RANGE. The interquartile range deliberately ignores the outer quarters."}]'::jsonb,
 2, 'sub-spread'),

(12, 'MDM4U', 'Normal Distributions', 3, 6, 'Easy',
 'What is the relationship between the variance and the standard deviation?',
 '[{"text": "The standard deviation is the square root of the variance", "feedback": "Correct."},
   {"text": "The variance is equal to the square root of the standard deviation", "feedback": "The two have been swapped. The variance is the larger of the two whenever it is above 1."},
   {"text": "They are the same thing", "feedback": "They measure the same idea in different units. The variance is in squared units, which is why the root is taken."},
   {"text": "The standard deviation is half the variance", "feedback": "There is no fixed multiple between them. The relationship is a square root."}]'::jsonb,
 0, 'sub-spread'),

(12, 'MDM4U', 'Normal Distributions', 3, 7, 'Easy',
 'In a normal distribution, roughly what percentage of the data lies within one standard deviation of the mean?',
 '[{"text": "99.7 per cent", "feedback": "That is the figure for THREE standard deviations."},
   {"text": "50 per cent", "feedback": "Half the data lies below the mean, but one standard deviation on each side reaches considerably further than that."},
   {"text": "68 per cent", "feedback": "Correct."},
   {"text": "95 per cent", "feedback": "That is the figure for TWO standard deviations."}]'::jsonb,
 2, 'sub-normal-basics'),

(12, 'MDM4U', 'Normal Distributions', 3, 8, 'Easy',
 'In a normal distribution, where do the mean, the median and the mode sit?',
 '[{"text": "The mean is above the median, which is above the mode", "feedback": "That is the pattern for a distribution skewed RIGHT. A normal distribution is symmetric."},
   {"text": "The mode is at the centre and the other two are in the tails", "feedback": "Neither the mean nor the median ever sits in a tail of a symmetric distribution."},
   {"text": "Their positions depend on the standard deviation", "feedback": "The standard deviation decides how wide the curve is, not where its centre lies."},
   {"text": "All three are at the centre, in the same place", "feedback": "Correct."}]'::jsonb,
 3, 'sub-normal-basics'),

(12, 'MDM4U', 'Normal Distributions', 3, 9, 'Easy',
 E'A test has a mean of 70 and a standard deviation of 8.\nWhat is the z-score of a mark of 82?',
 '[{"text": "1.5", "feedback": "Correct."},
   {"text": "-1.5", "feedback": "The subtraction went the wrong way round. A mark ABOVE the mean has a positive z-score."},
   {"text": "12", "feedback": "That is the raw difference from the mean. A z-score divides it by the standard deviation."},
   {"text": "10.25", "feedback": "The mark was divided by the standard deviation without the mean being subtracted first."}]'::jsonb,
 0, 'sub-z-scores'),

(12, 'MDM4U', 'Normal Distributions', 3, 10, 'Easy',
 'What does a 95 per cent confidence interval tell you?',
 '[{"text": "That 95 per cent of the population lies inside the interval", "feedback": "The interval brackets a single number, the population mean or proportion, not the spread of individuals."},
   {"text": "A range that, by this method, would capture the true population value 95 times out of 100", "feedback": "Correct."},
   {"text": "That 95 per cent of the sample lies inside the interval", "feedback": "The interval is about the unknown POPULATION value, not about where the sample values sit."},
   {"text": "That the sample mean has a 95 per cent chance of being correct", "feedback": "The sample mean is whatever it is, with no uncertainty. What is uncertain is the population value it estimates."}]'::jsonb,
 1, 'sub-confidence-intervals'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): a full calculation, or a rule applied to a context.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Normal Distributions', 3, 11, 'Medium',
 'Household incomes in a country have a small number of very high values. What shape is that distribution?',
 '[{"text": "Symmetric", "feedback": "A handful of extreme values on one side only is precisely what breaks symmetry."},
   {"text": "Uniform", "feedback": "A uniform distribution is flat, with as many households at every income."},
   {"text": "Skewed right", "feedback": "Correct."},
   {"text": "Skewed left", "feedback": "The name follows the tail. A few very high values make a long tail on the right."}]'::jsonb,
 2, 'sub-distribution-shapes'),

(12, 'MDM4U', 'Normal Distributions', 3, 12, 'Medium',
 E'A student scores 80 on a test worth 30 per cent of the mark and 60 on a test worth 70 per cent.\nWhat is the weighted mean?',
 '[{"text": "74", "feedback": "The weights were applied to the wrong scores. The 70 per cent belongs to the mark of 60."},
   {"text": "140", "feedback": "The weighted contributions were added without being expressed as fractions of the whole."},
   {"text": "66", "feedback": "Correct."},
   {"text": "70", "feedback": "The two scores were simply averaged. The weights are unequal, so the 60 counts more than twice as much."}]'::jsonb,
 2, 'sub-central-tendency'),

(12, 'MDM4U', 'Normal Distributions', 3, 13, 'Medium',
 E'A class has 16 final grades: 43, 48, 56, 59, 62, 64, 67, 71, 72, 75, 75, 78, 81, 84, 88, 90.\nWhat is the median?',
 '[{"text": "71.5", "feedback": "Correct."},
   {"text": "71", "feedback": "With an even number of values the median is halfway BETWEEN the two middle ones, not the lower of them."},
   {"text": "69.56", "feedback": "That is the mean. The median comes from position rather than from adding everything up."},
   {"text": "72", "feedback": "That is the ninth value. The median of sixteen values sits between the eighth and the ninth."}]'::jsonb,
 0, 'sub-central-tendency'),

(12, 'MDM4U', 'Normal Distributions', 3, 14, 'Medium',
 E'For that same set of 16 grades, Q1 is 60.5 and Q3 is 79.5.\nWhat is the interquartile range?',
 '[{"text": "47", "feedback": "That is the RANGE, from the lowest grade to the highest. The interquartile range uses the quartiles instead."},
   {"text": "140", "feedback": "The two quartiles were added rather than subtracted."},
   {"text": "9.5", "feedback": "The difference was halved. The interquartile range is the whole distance between the two quartiles."},
   {"text": "19", "feedback": "Correct."}]'::jsonb,
 3, 'sub-spread'),

(12, 'MDM4U', 'Normal Distributions', 3, 15, 'Medium',
 'What is the difference between the population standard deviation and the sample standard deviation?',
 '[{"text": "The sample version uses the median instead of the mean", "feedback": "Both are built from deviations about the mean."},
   {"text": "The sample version is not square rooted", "feedback": "Both take the square root at the end. Without it you would have a variance, not a standard deviation."},
   {"text": "The sample version divides by n take away 1 rather than by n", "feedback": "Correct."},
   {"text": "The sample version divides by n and the population version by n take away 1", "feedback": "The two have been swapped. It is the SAMPLE that needs the smaller divisor, to stop it underestimating."}]'::jsonb,
 2, 'sub-spread'),

(12, 'MDM4U', 'Normal Distributions', 3, 16, 'Medium',
 E'Heights on a team are 183, 165, 148, 146, 181, 178, 154 cm, and this is the whole population.\nWhat is the mean, and the population standard deviation to two decimal places?',
 '[{"text": "Mean 165 and standard deviation 14.74", "feedback": "Correct."},
   {"text": "Mean 165 and standard deviation 15.92", "feedback": "The mean is right but the sample formula was used, dividing by n take away 1. This set is the whole population."},
   {"text": "Mean 165 and standard deviation 217.14", "feedback": "That is the VARIANCE. The square root still has to be taken."},
   {"text": "Mean 178 and standard deviation 14.74", "feedback": "A height was read straight off the list instead of the centre of the seven being worked out."}]'::jsonb,
 0, 'sub-spread'),

(12, 'MDM4U', 'Normal Distributions', 3, 17, 'Medium',
 E'Marks are normally distributed with a mean of 70 and a standard deviation of 8.\nBetween which two marks does about 95 per cent of the class fall?',
 '[{"text": "62 and 78", "feedback": "That is one standard deviation on each side, which captures about 68 per cent."},
   {"text": "46 and 94", "feedback": "That is three standard deviations on each side, which captures about 99.7 per cent."},
   {"text": "70 and 86", "feedback": "That is only the upper half of the interval. The other two standard deviations below the mean belong as well."},
   {"text": "54 and 86", "feedback": "Correct."}]'::jsonb,
 3, 'sub-normal-basics'),

(12, 'MDM4U', 'Normal Distributions', 3, 18, 'Medium',
 'What happens to the shape of a normal curve when the standard deviation increases and the mean stays the same?',
 '[{"text": "It shifts to the right", "feedback": "Shifting sideways is what changing the MEAN does. The standard deviation controls width."},
   {"text": "It becomes narrower and taller, staying centred in the same place", "feedback": "That is what happens when the standard deviation DECREASES."},
   {"text": "It becomes wider and flatter, staying centred in the same place", "feedback": "Correct."},
   {"text": "It becomes wider and taller", "feedback": "It cannot become both. The area under the curve is always 1, so spreading it out has to bring the peak down."}]'::jsonb,
 2, 'sub-normal-basics'),

(12, 'MDM4U', 'Normal Distributions', 3, 19, 'Medium',
 E'Marks are normally distributed with a mean of 70 and a standard deviation of 8.\nWhat proportion of students score below 82, to four decimal places?',
 '[{"text": "0.9332", "feedback": "Correct."},
   {"text": "0.0668", "feedback": "That is the proportion scoring ABOVE 82. The two add to 1, so one has been read for the other."},
   {"text": "0.8664", "feedback": "That is the proportion between 58 and 82, the symmetric interval. Only one side was asked for here."},
   {"text": "1.5000", "feedback": "That is the z-score. A proportion can never exceed 1."}]'::jsonb,
 0, 'sub-z-scores'),

(12, 'MDM4U', 'Normal Distributions', 3, 20, 'Medium',
 'What happens to the width of a confidence interval when the sample size increases, everything else being equal?',
 '[{"text": "It gets narrower", "feedback": "Correct."},
   {"text": "It gets wider", "feedback": "More data makes an estimate more precise, not less. The sample size sits underneath a square root in the denominator."},
   {"text": "It stays the same", "feedback": "The sample size appears in the margin of error, so changing it changes the width."},
   {"text": "It depends on whether the mean goes up or down", "feedback": "The centre of the interval moves with the mean, but its WIDTH does not depend on the mean at all."}]'::jsonb,
 0, 'sub-confidence-intervals'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): build the interval, or read the picture. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Normal Distributions', 3, 21, 'Challenge',
 'A distribution of ages at a family reunion has one cluster of children and another of grandparents, with few in between. What shape is that?',
 '[{"text": "Bimodal", "feedback": "Correct."},
   {"text": "Skewed left", "feedback": "Skew describes one long tail. Here there are two separate clusters, each with its own peak."},
   {"text": "Normal", "feedback": "A normal distribution has one peak in the middle, which is precisely where this one is thin."},
   {"text": "Uniform", "feedback": "A uniform distribution is flat, with no clustering anywhere."}]'::jsonb,
 0, 'sub-distribution-shapes'),

(12, 'MDM4U', 'Normal Distributions', 3, 22, 'Challenge',
 'A distribution is bimodal. Why is the mean a poor summary of it?',
 '[{"text": "The mean is only defined for symmetric distributions", "feedback": "The mean is defined for any numeric data at all."},
   {"text": "The mean lands in the sparse gap between the two peaks, where almost no data sits", "feedback": "Correct."},
   {"text": "The mean cannot be calculated for a bimodal distribution", "feedback": "It can be calculated perfectly well. The trouble is what it turns out to describe."},
   {"text": "The mean will always equal one of the two modes", "feedback": "It rarely equals either. It usually falls between them."}]'::jsonb,
 1, 'sub-distribution-shapes'),

(12, 'MDM4U', 'Normal Distributions', 3, 23, 'Challenge',
 E'A data set is 4, 8, 9, 11, 14, 40.\nWhat are the mean and the median?',
 '[{"text": "Mean 14.33 and median 11", "feedback": "That is the fourth value. The median of six values sits between the third and the fourth."},
   {"text": "Mean 14.33 and median 10", "feedback": "Correct."},
   {"text": "Mean 10 and median 14.33", "feedback": "The two have been swapped. The 40 pulls the mean well above the middle of the data."},
   {"text": "Mean 14.33 and median 9", "feedback": "With six values the median is halfway between the third and the fourth, not the third alone."}]'::jsonb,
 1, 'sub-central-tendency'),

(12, 'MDM4U', 'Normal Distributions', 3, 24, 'Challenge',
 E'A set of nine numbers has a mean of 12. One value of 20 is replaced by 38.\nWhat is the new mean?',
 '[{"text": "12", "feedback": "Changing a value changes the total, so the mean has to move with it."},
   {"text": "18", "feedback": "That is the difference between the old value and the new one, which is not a mean at all."},
   {"text": "30", "feedback": "The change of 18 was added to the old mean in full. It has to be shared out over all nine values first."},
   {"text": "14", "feedback": "Correct."}]'::jsonb,
 3, 'sub-central-tendency'),

(12, 'MDM4U', 'Normal Distributions', 3, 25, 'Challenge',
 E'The diagram shows two distributions on the same axis, sharing a centre.\nWhich has the larger standard deviation?',
 '[{"text": "There is not enough information to say", "feedback": "There is: the standard deviation is a measure of width, and the picture shows which curve is wider."},
   {"text": "B, because it is wider", "feedback": "Correct."},
   {"text": "A, because it is taller", "feedback": "Height is not spread. Both curves enclose the same total area, so the narrower one has to rise higher to fit it in."},
   {"text": "They are equal, because they share a centre", "feedback": "A shared centre means equal MEANS. Standard deviation is about width, and these two are plainly different."}]'::jsonb,
 1, 'sub-spread'),

(12, 'MDM4U', 'Normal Distributions', 3, 26, 'Challenge',
 'Heights cannot be negative, yet a normal distribution is routinely used to model them. Why is that only an approximation?',
 '[{"text": "Because the mean and the median of real heights are different", "feedback": "For heights they are very close, which is one of the reasons the normal model fits as well as it does."},
   {"text": "Because the standard deviation of heights is too large for the model to apply", "feedback": "A normal distribution accepts any positive standard deviation. Size is not the obstacle."},
   {"text": "The normal curve never quite reaches the axis, so it assigns a tiny probability to impossible values", "feedback": "Correct."},
   {"text": "Because heights are discrete rather than continuous", "feedback": "Heights are continuous: between any two heights there is another. That is not what makes the model approximate."}]'::jsonb,
 2, 'sub-normal-basics'),

(12, 'MDM4U', 'Normal Distributions', 3, 27, 'Challenge',
 E'Marks are normally distributed with a mean of 70 and a standard deviation of 8.\nWhat mark sits at the 90th percentile, to two decimal places?',
 '[{"text": "78.00", "feedback": "That is one standard deviation above the mean, which sits at about the 84th percentile rather than the 90th."},
   {"text": "80.25", "feedback": "Correct."},
   {"text": "1.28", "feedback": "That is the Z-SCORE for the 90th percentile. It still has to be converted back into a mark."},
   {"text": "83.16", "feedback": "That is the 95th percentile. The z-score for 90 per cent is about 1.28, not 1.64."}]'::jsonb,
 1, 'sub-z-scores'),

(12, 'MDM4U', 'Normal Distributions', 3, 28, 'Challenge',
 E'Marks are normally distributed with a mean of 70 and a standard deviation of 8.\nWhat proportion of students score between 58 and 82, to four decimal places?',
 '[{"text": "0.8664", "feedback": "Correct."},
   {"text": "0.9332", "feedback": "That is the proportion below 82 alone. The part below 58 still has to be taken off."},
   {"text": "0.0668", "feedback": "That is the proportion in one tail. The question asks for the middle."},
   {"text": "0.9500", "feedback": "That would be the answer for two full standard deviations each way, reaching 54 and 86. These limits are 1.5 standard deviations out."}]'::jsonb,
 0, 'sub-z-scores'),

(12, 'MDM4U', 'Normal Distributions', 3, 29, 'Challenge',
 E'Drying times for a paint have a standard deviation of 10.5 minutes. Twenty test areas give a mean of 75.4 minutes.\nWhat is the 95 per cent confidence interval, to three decimal places?',
 '[{"text": "70.798 to 80.002 minutes", "feedback": "Correct."},
   {"text": "71.538 to 79.262 minutes", "feedback": "The critical value 1.645 was used, which belongs to a 90 per cent interval. For 95 per cent it is 1.960."},
   {"text": "64.900 to 85.900 minutes", "feedback": "The standard deviation was used as the margin of error directly. It has to be divided by the square root of the sample size and scaled by the critical value."},
   {"text": "69.352 to 81.448 minutes", "feedback": "The critical value 2.576 was used, which belongs to a 99 per cent interval."}]'::jsonb,
 0, 'sub-confidence-intervals'),

(12, 'MDM4U', 'Normal Distributions', 3, 30, 'Challenge',
 E'Julia has jogged 2 miles many times, with a standard deviation of 1.8 minutes. A random sample of 90 of her times has a mean of 15.6 minutes.\nWhat is the 95 per cent confidence interval, to three decimal places?',
 '[{"text": "15.410 to 15.790 minutes", "feedback": "The standard error was used as the margin of error on its own, with no critical value applied to it."},
   {"text": "15.600 to 15.972 minutes", "feedback": "Only the upper half of the interval was given. The margin of error goes both ways from the sample mean."},
   {"text": "15.228 to 15.972 minutes", "feedback": "Correct."},
   {"text": "13.800 to 17.400 minutes", "feedback": "The standard deviation was used as the margin of error directly, without being divided by the square root of 90."}]'::jsonb,
 2, 'sub-confidence-intervals'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): work backwards, or say what an interval actually claims.
-- Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Normal Distributions', 3, 31, 'Advanced',
 'A distribution has a mean of 50 and a median of 62. What can you say about its shape?',
 '[{"text": "It is skewed right, because the mean is a good deal smaller than the median", "feedback": "The relationship runs the other way. In a right-skewed distribution the long tail is on the high side, which pulls the mean ABOVE the median."},
   {"text": "It is symmetric, because the mean and the median are reasonably close together", "feedback": "A gap of twelve is not close. In a symmetric distribution the two coincide."},
   {"text": "Nothing can be said about the shape without knowing the standard deviation", "feedback": "The comparison of mean and median alone settles the direction of the skew."},
   {"text": "It is skewed left, because the mean has been dragged below the median", "feedback": "Correct."}]'::jsonb,
 3, 'sub-distribution-shapes'),

(12, 'MDM4U', 'Normal Distributions', 3, 32, 'Advanced',
 E'A set of five numbers has a mean of 20 and a median of 18.\nWhat can you conclude?',
 '[{"text": "The largest value must be exactly 22", "feedback": "Many different sets fit these two facts. Nothing pins down any single value."},
   {"text": "The data must be normally distributed", "feedback": "In a normal distribution the mean and the median coincide, so this data is not normal."},
   {"text": "The standard deviation must be 2", "feedback": "The gap between mean and median says nothing about the standard deviation."},
   {"text": "At least one value is far enough above 18 to pull the mean upward", "feedback": "Correct."}]'::jsonb,
 3, 'sub-central-tendency'),

(12, 'MDM4U', 'Normal Distributions', 3, 33, 'Advanced',
 'Every value in a data set has 10 added to it. What happens to the mean and to the standard deviation?',
 '[{"text": "The mean increases by 10 and the standard deviation is unchanged", "feedback": "Correct."},
   {"text": "Both increase by 10", "feedback": "Shifting every value by the same amount leaves all the distances between them the same, and the standard deviation is built from distances."},
   {"text": "The mean is unchanged and the standard deviation increases by 10 instead", "feedback": "The two have been swapped. It is the centre that moves and the spread that stays."},
   {"text": "Both are unchanged", "feedback": "The centre certainly moves. Adding 10 to everything adds 10 to the average."}]'::jsonb,
 0, 'sub-spread'),

(12, 'MDM4U', 'Normal Distributions', 3, 34, 'Advanced',
 E'A machine fills bottles with a mean of 500 mL and a standard deviation of 4 mL, normally distributed.\nAbout what percentage of bottles hold less than 492 mL?',
 '[{"text": "About 5 per cent", "feedback": "That is the total in BOTH tails beyond two standard deviations. Only the lower one was asked for."},
   {"text": "About 16 per cent", "feedback": "That is the tail beyond ONE standard deviation. 492 mL is two standard deviations below the mean."},
   {"text": "About 95 per cent", "feedback": "That is the proportion INSIDE two standard deviations. The question asks about the small piece outside it on one side."},
   {"text": "About 2.5 per cent", "feedback": "Correct."}]'::jsonb,
 3, 'sub-normal-basics'),

(12, 'MDM4U', 'Normal Distributions', 3, 35, 'Advanced',
 'Two students take different tests. One scores 78 where the mean is 70 and the standard deviation is 4. The other scores 85 where the mean is 75 and the standard deviation is 10. Who did better relative to their class?',
 '[{"text": "They performed equally, since both beat their class mean by 8 or more", "feedback": "The size of the gap matters relative to the spread. Eight marks in a tight class is a much bigger achievement than ten in a loose one."},
   {"text": "There is not enough information without knowing the class sizes", "feedback": "The mean and the standard deviation are all a z-score needs."},
   {"text": "The first student, whose z-score is 2 against the other 1", "feedback": "Correct."},
   {"text": "The second student, who scored the higher raw mark", "feedback": "Raw marks from different tests cannot be compared. Standardising is exactly what makes them comparable."}]'::jsonb,
 2, 'sub-z-scores'),

(12, 'MDM4U', 'Normal Distributions', 3, 36, 'Advanced',
 'A value has a z-score of -0.8. What does that mean?',
 '[{"text": "It sits at the 80th percentile of the distribution", "feedback": "A negative z-score is below the mean, so it sits below the 50th percentile. This one is at about the 21st."},
   {"text": "It lies 0.8 standard deviations below the mean", "feedback": "Correct."},
   {"text": "It lies 0.8 units below the mean", "feedback": "A z-score counts standard deviations, not units. How many units that is depends on the standard deviation."},
   {"text": "It lies 0.8 standard deviations above the mean", "feedback": "The negative sign puts it below. Above the mean gives a positive score."}]'::jsonb,
 1, 'sub-z-scores'),

(12, 'MDM4U', 'Normal Distributions', 3, 37, 'Advanced',
 E'In an election 53 per cent of 1500 voters supported the mayor.\nWhat is the 90 per cent confidence interval for the true level of support, to four decimal places?',
 '[{"text": "0.4700 to 0.5300", "feedback": "The complement of the proportion was used as the lower limit. A confidence interval is centred on the sample proportion itself."},
   {"text": "0.5088 to 0.5512", "feedback": "Correct."},
   {"text": "0.5047 to 0.5553", "feedback": "The critical value 1.960 was used, which belongs to a 95 per cent interval. For 90 per cent it is 1.645."},
   {"text": "0.5295 to 0.5305", "feedback": "The sample size was used instead of its square root, which makes the interval far too narrow."}]'::jsonb,
 1, 'sub-confidence-intervals'),

(12, 'MDM4U', 'Normal Distributions', 3, 38, 'Advanced',
 E'Of 188 books sold, 66 were murder mysteries.\nWhat is the 90 per cent confidence interval for the proportion of murder mysteries, to four decimal places?',
 '[{"text": "0.2827 to 0.4194", "feedback": "The critical value 1.960 was used, which belongs to a 95 per cent interval. For 90 per cent it is 1.645."},
   {"text": "0.3511 to 0.4083", "feedback": "Only the upper half of the interval was given. The margin of error goes both ways from the sample proportion."},
   {"text": "0.3469 to 0.3552", "feedback": "The sample size was used instead of its square root, which makes the interval far too narrow."},
   {"text": "0.2938 to 0.4083", "feedback": "Correct."}]'::jsonb,
 3, 'sub-confidence-intervals'),

(12, 'MDM4U', 'Normal Distributions', 3, 39, 'Advanced',
 'Why is a 99 per cent confidence interval wider than a 95 per cent one built from the same data?',
 '[{"text": "It is not wider; higher confidence gives a more precise estimate", "feedback": "Confidence and precision pull against each other. You can have a narrow interval or a very safe one, not both."},
   {"text": "Being more certain of capturing the true value requires casting a wider net", "feedback": "Correct."},
   {"text": "Because a 99 per cent interval uses a larger sample", "feedback": "The data is the same in both cases. Only the critical value changes."},
   {"text": "Because the standard deviation is recalculated at the higher confidence level", "feedback": "The standard deviation comes from the data and does not depend on the confidence level chosen."}]'::jsonb,
 1, 'sub-confidence-intervals'),

(12, 'MDM4U', 'Normal Distributions', 3, 40, 'Advanced',
 'A newspaper reports that 46 per cent support a policy, with a margin of error of 3 percentage points. Support has risen from 44 per cent last month. What is the honest conclusion?',
 '[{"text": "The margin of error only applies to the newer figure, so the rise is real", "feedback": "Both figures came from samples and both carry uncertainty, which makes the comparison even less conclusive."},
   {"text": "The apparent rise is smaller than the margin of error, so no real change has been shown", "feedback": "Correct."},
   {"text": "Support has definitely risen by 2 percentage points", "feedback": "A change of 2 sits well inside a margin of 3, so the two figures are consistent with no change at all."},
   {"text": "Support has definitely fallen, because 46 is below 50", "feedback": "Being below half says the policy is a minority view; it says nothing about which direction it has moved."}]'::jsonb,
 1, 'sub-confidence-intervals');

-- --- questions_mdm4u_u4.sql ---

-- ===========================================================================
-- MDM4U — Unit 4: Probability — 40 questions
-- ===========================================================================
-- Grade 12 Data Management, authored from the Jensen MDM4U lesson material
-- for this unit:
--
--   Lesson 1  Experimental probability
--   Lesson 2  Theoretical probability
--   Lesson 3  Probability using sets
--   Lesson 4  Conditional probability
--   Lesson 5  Multiplication of independent events
--   Lesson 6  Permutations
--   Lesson 7  Combinations
--
-- Seven lessons, six subtopics: permutations and combinations are counted
-- together as COUNTING, because they are two answers to the same question
-- and the whole difficulty is telling which one is wanted.
--
-- The split that matters most on the dashboard is CONDITIONAL against
-- INDEPENDENT. They use almost the same formula and a student can apply
-- either one mechanically. What separates them is whether the first event
-- changes the second, and getting that wrong is the single most expensive
-- mistake in the unit.
--
-- Every wrong option is the answer a student actually reaches by one named
-- mistake. Five repeat right through:
--
--   * multiplying probabilities that are not independent, which happens
--     every time a draw is made without replacement
--   * dividing by the wrong total in a conditional probability: the
--     condition narrows the denominator, and forgetting that gives an
--     unconditional answer
--   * adding two probabilities without subtracting the overlap
--   * using a permutation where order does not matter, which overcounts by
--     exactly r factorial
--   * treating a small run of trials as evidence about a long-run
--     probability
--
-- Feedback names the mistake and stops there.
--
-- Every probability, factorial, permutation and combination in this file
-- was recomputed independently with exact fractions before delivery.
--
-- FIGURES: one, on question 14.
--
--   * Q14 shows a Venn diagram with the part of A outside B shaded, and no
--     numbers anywhere. The question asks which set expression that region
--     is, and the answer comes from which overlap is included.
--
-- Rejected: the Jensen Venn diagram with 5, 13 and 7 written in its three
-- regions. Printing the counts turns the additive principle into an
-- addition — a student sums the three numbers and never meets the reason
-- the overlap would otherwise be double counted. Question 15 asks that same
-- question from the three totals instead, where the subtraction has to be
-- done deliberately.
--
-- Also rejected: tree diagrams. A drawn tree with the branch probabilities
-- written on it has already done the work; building the tree IS the skill.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mdm4u.sql.
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

delete from questions where course_code = 'MDM4U' and unit = 'Probability';

insert into misconception_labels (tag, label) values
  ('sub-experimental-prob',   'Experimental probability'),
  ('sub-theoretical-prob',    'Theoretical probability'),
  ('sub-prob-sets',           'Probability using sets'),
  ('sub-conditional-prob',    'Conditional probability'),
  ('sub-independent-events',  'Independent and dependent events'),
  ('sub-counting',            'Permutations and combinations')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): one definition or one short count each.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability', 4, 1, 'Easy',
 'What is experimental probability?',
 '[{"text": "A probability worked out by counting the sample space", "feedback": "That is THEORETICAL probability. It needs no trials at all."},
   {"text": "A probability that is guaranteed to come out equal to the theoretical one", "feedback": "The two usually differ, and the gap between them is often the point of the exercise."},
   {"text": "An estimate made without collecting any data", "feedback": "Experimental probability is built entirely out of collected data."},
   {"text": "A probability worked out from the results of trials actually carried out", "feedback": "Correct."}]'::jsonb,
 3, 'sub-experimental-prob'),

(12, 'MDM4U', 'Probability', 4, 2, 'Easy',
 'A coin is tossed 100 times and lands heads 47 times. What is the experimental probability of heads?',
 '[{"text": "47", "feedback": "That is the count of heads. A probability is that count divided by the number of trials."},
   {"text": "0.47", "feedback": "Correct."},
   {"text": "0.50", "feedback": "That is the THEORETICAL probability for a fair coin. The experimental one comes from what actually happened."},
   {"text": "0.53", "feedback": "That is the experimental probability of TAILS."}]'::jsonb,
 1, 'sub-experimental-prob'),

(12, 'MDM4U', 'Probability', 4, 3, 'Easy',
 'A die with faces numbered 1 to 20 is rolled once. What is the probability of rolling a number divisible by 5?',
 '[{"text": "1/4", "feedback": "The 20 was divided by 5 and used as the denominator. The denominator is the total number of faces."},
   {"text": "1/5", "feedback": "Correct."},
   {"text": "1/20", "feedback": "Only one favourable outcome was counted. There are four multiples of 5 between 1 and 20."},
   {"text": "4/5", "feedback": "The favourable outcomes and the unfavourable ones were swapped. Sixteen of the twenty faces are NOT multiples of 5."}]'::jsonb,
 1, 'sub-theoretical-prob'),

(12, 'MDM4U', 'Probability', 4, 4, 'Easy',
 'If the probability of an event is 0.3, what is the probability that it does NOT happen?',
 '[{"text": "1.3", "feedback": "The value was added to 1 rather than subtracted from it. No probability can exceed 1."},
   {"text": "0.7", "feedback": "Correct."},
   {"text": "0.3", "feedback": "An event and its complement have the same probability only when both are one half."},
   {"text": "-0.3", "feedback": "A probability can never be negative. The complement is found by subtracting FROM 1."}]'::jsonb,
 1, 'sub-theoretical-prob'),

(12, 'MDM4U', 'Probability', 4, 5, 'Easy',
 'What does the intersection of A and B contain?',
 '[{"text": "The elements that are in neither A nor B", "feedback": "That is what is left outside both circles."},
   {"text": "The elements that are in both A and B", "feedback": "Correct."},
   {"text": "The elements that are in A or in B or in both", "feedback": "That is the UNION. The intersection is the smaller of the two."},
   {"text": "The elements that are in A but not in B", "feedback": "That is a different region again, and it deliberately excludes the overlap rather than being it."}]'::jsonb,
 1, 'sub-prob-sets'),

(12, 'MDM4U', 'Probability', 4, 6, 'Easy',
 'Two events that cannot both happen on the same trial are called what?',
 '[{"text": "Conditional", "feedback": "Conditional describes a probability computed once something else is known to have happened."},
   {"text": "Mutually exclusive", "feedback": "Correct."},
   {"text": "Independent", "feedback": "Independent events CAN both happen; the point is that one does not affect the chance of the other."},
   {"text": "Complementary", "feedback": "Complementary events cannot both happen either, but they must also cover every possibility between them, which is a stronger condition."}]'::jsonb,
 1, 'sub-prob-sets'),

(12, 'MDM4U', 'Probability', 4, 7, 'Easy',
 'How is the notation P(A given B) read?',
 '[{"text": "The probability that A or B occurs", "feedback": "That is a union, which uses addition rather than a condition."},
   {"text": "The probability of B, given that A has occurred", "feedback": "The two have been read in the wrong order. The event before the bar is the one being asked about."},
   {"text": "The probability of A, given that B has occurred", "feedback": "Correct."},
   {"text": "The probability that A and B both occur", "feedback": "That is a joint probability, which is usually the smaller of the two."}]'::jsonb,
 2, 'sub-conditional-prob'),

(12, 'MDM4U', 'Probability', 4, 8, 'Easy',
 'When are two events independent?',
 '[{"text": "When they always happen together", "feedback": "Then each one would guarantee the other, which is about as dependent as two events can be."},
   {"text": "When the two events have exactly the same probability of happening", "feedback": "Equal probabilities say nothing about whether one affects the other."},
   {"text": "When one happening does not change the probability of the other", "feedback": "Correct."},
   {"text": "When they cannot both happen", "feedback": "That is MUTUALLY EXCLUSIVE, and it is very nearly the opposite: if one happening rules the other out, it changes its probability to zero."}]'::jsonb,
 2, 'sub-independent-events'),

(12, 'MDM4U', 'Probability', 4, 9, 'Easy',
 'What is 5 factorial?',
 '[{"text": "120", "feedback": "Correct."},
   {"text": "25", "feedback": "The number was squared. A factorial multiplies every whole number down to 1."},
   {"text": "15", "feedback": "The numbers from 1 to 5 were added rather than multiplied."},
   {"text": "5", "feedback": "The factorial sign has to do something. It multiplies 5 by 4 by 3 by 2 by 1."}]'::jsonb,
 0, 'sub-counting'),

(12, 'MDM4U', 'Probability', 4, 10, 'Easy',
 'In a permutation, does the order of the objects matter?',
 '[{"text": "Yes, always", "feedback": "Correct."},
   {"text": "No, never", "feedback": "That describes a COMBINATION. The two exist as separate ideas precisely because of this difference."},
   {"text": "Only when some of the objects are repeated", "feedback": "Repeats change how many arrangements are DISTINGUISHABLE, but order matters either way."},
   {"text": "Only when there are more than three objects", "feedback": "The number of objects makes no difference to whether order counts."}]'::jsonb,
 0, 'sub-counting'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): one calculation, correctly set up.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability', 4, 11, 'Medium',
 'Why does experimental probability move closer to theoretical probability as the number of trials grows?',
 '[{"text": "Because rounding errors cancel out", "feedback": "Rounding is not what is happening. The variation being smoothed out is genuine chance."},
   {"text": "It does not; the two are unrelated", "feedback": "They are closely related, and the way one approaches the other is one of the central facts of the subject."},
   {"text": "Because of the law of large numbers", "feedback": "Correct."},
   {"text": "Because the theoretical probability adjusts to match the results", "feedback": "The theoretical value is fixed by the structure of the experiment. It is the experimental one that settles down."}]'::jsonb,
 2, 'sub-experimental-prob'),

(12, 'MDM4U', 'Probability', 4, 12, 'Medium',
 'Two fair dice are rolled. What is the probability that the sum is 7?',
 '[{"text": "7/36", "feedback": "The target sum was used as the count of favourable outcomes. There are six ways to make 7, not seven."},
   {"text": "1/36", "feedback": "Only one favourable outcome was counted. Six different pairs add to 7."},
   {"text": "1/6", "feedback": "Correct."},
   {"text": "1/12", "feedback": "The sample space was counted as 12 outcomes rather than 36. Each die has six faces, and every pairing is a separate outcome."}]'::jsonb,
 2, 'sub-theoretical-prob'),

(12, 'MDM4U', 'Probability', 4, 13, 'Medium',
 'The odds in favour of an event are 3 to 7. What is the probability of the event?',
 '[{"text": "3/7", "feedback": "Odds compare successes to FAILURES. A probability compares successes to every trial, favourable and unfavourable together."},
   {"text": "7/10", "feedback": "That is the probability that the event does NOT happen."},
   {"text": "7/3", "feedback": "The two numbers were used in the wrong order, which gives the odds AGAINST written as a fraction. No probability can be greater than 1."},
   {"text": "3/10", "feedback": "Correct."}]'::jsonb,
 3, 'sub-theoretical-prob'),

(12, 'MDM4U', 'Probability', 4, 14, 'Medium',
 E'The Venn diagram shows two sets A and B inside a universe S, with one region shaded.\nWhich expression describes the shaded region?',
 '[{"text": "The elements in A that are not in B", "feedback": "Correct."},
   {"text": "The intersection of A and B", "feedback": "The overlap is left white in the picture. The shading deliberately stops where B begins."},
   {"text": "The union of A and B", "feedback": "The union would cover both circles completely, and most of B is unshaded here."},
   {"text": "The elements that are in neither A nor B", "feedback": "That is the region outside both circles, which is also unshaded."}]'::jsonb,
 0, 'sub-prob-sets'),

(12, 'MDM4U', 'Probability', 4, 15, 'Medium',
 E'For two sets, n(A) = 18, n(B) = 20, and n(A and B) = 13.\nWhat is n(A or B)?',
 '[{"text": "51", "feedback": "The overlap was ADDED rather than subtracted, so it has now been counted three times."},
   {"text": "12", "feedback": "The overlap was subtracted from both totals rather than from their sum, which removes it once too often."},
   {"text": "25", "feedback": "Correct."},
   {"text": "38", "feedback": "The two totals were added without the overlap being taken off. The 13 elements in both were counted twice."}]'::jsonb,
 2, 'sub-prob-sets'),

(12, 'MDM4U', 'Probability', 4, 16, 'Medium',
 E'Of 200 students, 120 play a sport and 110 play an instrument, and exactly 80 students do both.\nWhat is the probability that a student plays an instrument, given that they play a sport?',
 '[{"text": "8/11", "feedback": "That is the conditional probability the other way round, given that a student plays an instrument."},
   {"text": "2/3", "feedback": "Correct."},
   {"text": "80/200", "feedback": "The whole school was used as the denominator. The condition narrows it to the students who play a sport."},
   {"text": "120/200", "feedback": "That is the probability of playing a sport at all, which is what was GIVEN rather than what was asked."}]'::jsonb,
 1, 'sub-conditional-prob'),

(12, 'MDM4U', 'Probability', 4, 17, 'Medium',
 E'Of the same 200 students, 110 play an instrument and 80 of those also play a sport.\nWhat is the probability that a student plays a sport, given that they play an instrument?',
 '[{"text": "110/200", "feedback": "That is the probability of playing an instrument at all, which is what was GIVEN rather than what was asked."},
   {"text": "8/11", "feedback": "Correct."},
   {"text": "2/3", "feedback": "That is the conditional probability the other way round, given that a student plays a sport."},
   {"text": "80/200", "feedback": "The whole school was used as the denominator. The condition narrows it to the students who play an instrument."}]'::jsonb,
 1, 'sub-conditional-prob'),

(12, 'MDM4U', 'Probability', 4, 18, 'Medium',
 'A fair coin is tossed twice. What is the probability of getting two heads?',
 '[{"text": "1/4", "feedback": "Correct."},
   {"text": "1/2", "feedback": "That is the probability of a head on one toss. Two independent tosses multiply their probabilities together."},
   {"text": "1/8", "feedback": "That is the answer for THREE tosses. Two tosses give four equally likely outcomes."},
   {"text": "3/4", "feedback": "That is the probability of getting at least one head."}]'::jsonb,
 0, 'sub-independent-events'),

(12, 'MDM4U', 'Probability', 4, 19, 'Medium',
 E'The word MATHEMATICS has 11 letters, with M, A and T each appearing twice.\nHow many distinguishable arrangements are there?',
 '[{"text": "39 916 800", "feedback": "That is 11 factorial, which treats the two M values as different letters. Repeats have to be divided out."},
   {"text": "19 958 400", "feedback": "Only one of the three repeated letters was divided out. Each repeated pair contributes a factor of 2 to divide by."},
   {"text": "9 979 200", "feedback": "Only two of the three repeated letters were divided out. There are three letters appearing twice, not two."},
   {"text": "4 989 600", "feedback": "Correct."}]'::jsonb,
 3, 'sub-counting'),

(12, 'MDM4U', 'Probability', 4, 20, 'Medium',
 E'A baseball team has 15 players.\nHow many different nine-person batting orders can the coach make?',
 '[{"text": "5005", "feedback": "That is the number of ways to CHOOSE nine players with no regard to order. A batting order is an order."},
   {"text": "362 880", "feedback": "That is 9 factorial, the number of ways to arrange a fixed nine. The nine still have to be chosen from fifteen."},
   {"text": "1 307 674 368 000", "feedback": "That is 15 factorial, which arranges all fifteen players. Only nine bat."},
   {"text": "1 816 214 400", "feedback": "Correct."}]'::jsonb,
 3, 'sub-counting'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): decide what kind of problem it is first. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability', 4, 21, 'Challenge',
 'A coin is tossed 10 times and lands heads 7 times. Should you conclude that it is biased?',
 '[{"text": "No, because 10 tosses is far too few to distinguish a biased coin from an ordinary run of luck", "feedback": "Correct."},
   {"text": "Yes, because 7 out of 10 is well above one half", "feedback": "A fair coin gives seven or more heads in ten tosses about one time in six. That is not unusual enough to accuse it of anything."},
   {"text": "Yes, but only if it happens twice in a row", "feedback": "Two short runs are still a short run. What is needed is many more tosses, not a repeat of a small experiment."},
   {"text": "Only if it lands heads on all 10 tosses", "feedback": "Even ten heads in a row happens to a fair coin about once in a thousand attempts, so it is suggestive rather than conclusive."}]'::jsonb,
 0, 'sub-experimental-prob'),

(12, 'MDM4U', 'Probability', 4, 22, 'Challenge',
 'A simulation of 10 000 coin tosses gives an experimental probability of 0.503 where the theory says 0.5. What does that show?',
 '[{"text": "The coin is biased by 0.003", "feedback": "Every finite run wanders a little from the long-run value. A gap this small over 10 000 trials is exactly what a fair coin produces."},
   {"text": "The theoretical probability of one half must be wrong for a coin that behaves like this", "feedback": "The theoretical value comes from the structure of the coin. A close experimental result supports it rather than undermining it."},
   {"text": "The trials must have been miscounted", "feedback": "No error is needed to explain a gap of three thousandths. Chance alone accounts for it."},
   {"text": "The result is entirely consistent with a fair coin; small departures are expected", "feedback": "Correct."}]'::jsonb,
 3, 'sub-experimental-prob'),

(12, 'MDM4U', 'Probability', 4, 23, 'Challenge',
 'A single card is drawn from a standard deck of 52. What is the probability that it is a heart OR a king?',
 '[{"text": "1/52", "feedback": "Only the king of hearts was counted, which is the INTERSECTION rather than the union."},
   {"text": "4/13", "feedback": "Correct."},
   {"text": "17/52", "feedback": "The two counts were added without the overlap being removed. The king of hearts belongs to both and was counted twice."},
   {"text": "13/52", "feedback": "Only the hearts were counted. The three kings in the other suits qualify as well."}]'::jsonb,
 1, 'sub-theoretical-prob'),

(12, 'MDM4U', 'Probability', 4, 24, 'Challenge',
 'An event has a probability of 0. What does that mean?',
 '[{"text": "It is unlikely but still possible", "feedback": "Unlikely events have small positive probabilities. Zero is reserved for the impossible."},
   {"text": "It is certain to occur every time", "feedback": "Certainty is a probability of 1, at the other end of the scale."},
   {"text": "The probability has not been calculated yet", "feedback": "Zero is a genuine answer rather than a placeholder."},
   {"text": "It cannot occur at all", "feedback": "Correct."}]'::jsonb,
 3, 'sub-theoretical-prob'),

(12, 'MDM4U', 'Probability', 4, 25, 'Challenge',
 E'A bus carries the basketball and hockey teams. There are 10 on the basketball team and 17 on the hockey team, and 3 students play on both.\nHow many seats are needed?',
 '[{"text": "30", "feedback": "The overlap was ADDED rather than subtracted, so those three have now been counted three times."},
   {"text": "21", "feedback": "The three were subtracted from both team totals rather than once from the sum, which removes them one time too many."},
   {"text": "24", "feedback": "Correct."},
   {"text": "27", "feedback": "The two teams were added without the overlap being taken off. The three who play both were counted twice."}]'::jsonb,
 2, 'sub-prob-sets'),

(12, 'MDM4U', 'Probability', 4, 26, 'Challenge',
 E'Of 200 students, 110 play an instrument. Among the 120 who play a sport, 80 play an instrument.\nAre playing a sport and playing an instrument independent?',
 '[{"text": "It cannot be determined without knowing how many play neither", "feedback": "Everything needed is here: the unconditional probability and the conditional one can both be computed from these figures."},
   {"text": "No: the probability of playing an instrument rises from 0.55 to about 0.67 once you know the student plays a sport", "feedback": "Correct."},
   {"text": "Yes, because a student can do both", "feedback": "Being able to do both is what makes them not mutually exclusive. Independence is a different and stronger condition about probabilities."},
   {"text": "Yes, because 0.55 and 0.67 are reasonably close", "feedback": "Independence requires them to be EQUAL, not close. Any gap at all means knowing one changes the other."}]'::jsonb,
 1, 'sub-conditional-prob'),

(12, 'MDM4U', 'Probability', 4, 27, 'Challenge',
 'Which expression gives the probability that both A and B occur, whether or not they are independent?',
 '[{"text": "P(A) plus P(B)", "feedback": "Adding is for a union, and even there the overlap has to be taken off."},
   {"text": "P(A) divided by P(B)", "feedback": "Division appears when isolating a conditional probability, not when combining two events."},
   {"text": "P(A) times P(B given A)", "feedback": "Correct."},
   {"text": "P(A) times P(B)", "feedback": "That is the shortcut for INDEPENDENT events only. When one affects the other it gives the wrong answer."}]'::jsonb,
 2, 'sub-conditional-prob'),

(12, 'MDM4U', 'Probability', 4, 28, 'Challenge',
 E'A bag holds 5 red and 3 blue marbles. Two are drawn WITHOUT replacement.\nWhat is the probability that both are red?',
 '[{"text": "5/8", "feedback": "That is the probability that the FIRST marble is red. The second draw still has to be accounted for."},
   {"text": "1/2", "feedback": "Neither draw has this probability, and the two do not combine to it either."},
   {"text": "5/14", "feedback": "Correct."},
   {"text": "25/64", "feedback": "The two draws were treated as independent. Without replacement the first marble is gone, so the second draw faces 4 reds out of 7."}]'::jsonb,
 2, 'sub-independent-events'),

(12, 'MDM4U', 'Probability', 4, 29, 'Challenge',
 E'The same bag holds 5 red and 3 blue marbles, but now the first marble is replaced before the second is drawn.\nWhat is the probability that both are red?',
 '[{"text": "25/8", "feedback": "Only the numerator was squared. A value larger than 1 cannot be a probability at all, which is the quickest way to catch this one."},
   {"text": "25/64", "feedback": "Correct."},
   {"text": "5/14", "feedback": "That is the answer WITHOUT replacement. Putting the marble back leaves the second draw facing the same eight marbles as the first."},
   {"text": "5/8", "feedback": "That is the probability for a single draw. Two draws multiply."}]'::jsonb,
 1, 'sub-independent-events'),

(12, 'MDM4U', 'Probability', 4, 30, 'Challenge',
 'How many different committees of 3 can be formed from 8 people?',
 '[{"text": "24", "feedback": "The 8 was multiplied by 3. Choosing three from eight is a combination, not a product."},
   {"text": "512", "feedback": "That is 8 cubed, which would allow the same person to be picked three times."},
   {"text": "56", "feedback": "Correct."},
   {"text": "336", "feedback": "That is the number of ordered arrangements. A committee is a set, so the same three people in a different order is the same committee."}]'::jsonb,
 2, 'sub-counting'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): complements, base rates, and choosing the right tool.
-- Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability', 4, 31, 'Advanced',
 'A simulation of a million coin tosses returns 0.4998 where the theory says 0.5. What is the best reading of that?',
 '[{"text": "The model is wrong by 0.0002", "feedback": "Every finite run lands near the true value rather than on it. Two ten-thousandths over a million trials is well inside the expected wobble."},
   {"text": "The simulation must have a fault", "feedback": "A simulation that returned exactly 0.500000 would be the suspicious one. Real randomness never lands that neatly."},
   {"text": "Running more trials would eventually give exactly 0.5", "feedback": "The results get closer on average but never settle on the value exactly. That is what a limit means here."},
   {"text": "Strong evidence that the model is right, since a gap this small over a million trials is exactly what chance produces", "feedback": "Correct."}]'::jsonb,
 3, 'sub-experimental-prob'),

(12, 'MDM4U', 'Probability', 4, 32, 'Advanced',
 E'A die is rolled four times.\nWhat is the probability of getting at least one six?',
 '[{"text": "671/1296", "feedback": "Correct."},
   {"text": "625/1296", "feedback": "That is the probability of getting NO six at all. The complement still has to be taken."},
   {"text": "2/3", "feedback": "The single-roll probability was multiplied by four. Probabilities cannot be added up like that, and this method breaks completely at seven rolls."},
   {"text": "1/6", "feedback": "That is the probability of a six on ONE roll. Four rolls give many more chances."}]'::jsonb,
 0, 'sub-theoretical-prob'),

(12, 'MDM4U', 'Probability', 4, 33, 'Advanced',
 'In the rule P(A or B) = P(A) + P(B) minus P(A and B), which condition on A and B covers ALL the cases in which the subtracted term vanishes?',
 '[{"text": "When A and B are mutually exclusive", "feedback": "Correct."},
   {"text": "When A and B are independent", "feedback": "Independent events usually have a non-zero overlap; in fact their overlap is the product of the two probabilities."},
   {"text": "When A and B are complementary", "feedback": "Complementary events do make the term vanish, but they carry an extra requirement: between them they must cover every outcome. That is one case rather than all of them."},
   {"text": "Always, because the overlap is counted only once anyway", "feedback": "It is counted twice by the two separate totals, which is exactly why the rule has to take it off."}]'::jsonb,
 0, 'sub-prob-sets'),

(12, 'MDM4U', 'Probability', 4, 34, 'Advanced',
 E'A and B are mutually exclusive, with P(A) = 0.4 and P(B) = 0.5.\nWhat are P(A and B) and P(A or B)?',
 '[{"text": "0.2 and 0.9", "feedback": "The two probabilities were multiplied to get the overlap, which is the rule for INDEPENDENT events. Mutually exclusive events have no overlap at all."},
   {"text": "0 and 0.7", "feedback": "The intersection is right but something was subtracted from the union anyway. With no overlap there is nothing to take off."},
   {"text": "0.2 and 0.7", "feedback": "Both errors at once: an overlap was invented by multiplying, and then subtracted."},
   {"text": "0 and 0.9", "feedback": "Correct."}]'::jsonb,
 3, 'sub-prob-sets'),

(12, 'MDM4U', 'Probability', 4, 35, 'Advanced',
 E'A disease affects 1 per cent of people. A test is correct 99 per cent of the time on both the sick and the healthy. Someone tests positive.\nRoughly what is the probability that they have the disease?',
 '[{"text": "About 99 per cent", "feedback": "That is the accuracy of the TEST, not the probability of disease given a positive result. The two are different questions."},
   {"text": "About 1 per cent", "feedback": "That is the probability before the test was taken. A positive result raises it considerably."},
   {"text": "About 98 per cent", "feedback": "Two accuracy figures were combined. The rarity of the disease is what has been left out."},
   {"text": "About 50 per cent", "feedback": "Correct."}]'::jsonb,
 3, 'sub-conditional-prob'),

(12, 'MDM4U', 'Probability', 4, 36, 'Advanced',
 'Why is the probability of disease after a positive result so much lower than the accuracy of the test?',
 '[{"text": "Because the disease is rare, so the 1 per cent of healthy people who test positive are as numerous as the sick who do", "feedback": "Correct."},
   {"text": "Because the test is not really 99 per cent accurate", "feedback": "It genuinely is. The surprise comes from the sizes of the two groups it is applied to."},
   {"text": "Because the sample of people tested is too small", "feedback": "The effect appears at any sample size, and gets no better with more people."},
   {"text": "Because 99 per cent accuracy means 99 per cent of positives are correct", "feedback": "That is exactly the confusion the question exists to break. Accuracy is about how the test performs on each group, not about what a positive result means."}]'::jsonb,
 0, 'sub-conditional-prob'),

(12, 'MDM4U', 'Probability', 4, 37, 'Advanced',
 'Three cards are dealt from a standard deck without replacement. Are the three draws independent?',
 '[{"text": "Yes, because every card in the deck is equally likely to be drawn on each deal", "feedback": "Each card is equally likely on any given draw, but the probabilities on the second draw depend on what came first."},
   {"text": "Only the first two are independent of each other", "feedback": "The second already depends on the first. There is no pair here that is independent."},
   {"text": "No, because each card removed changes what is left in the deck", "feedback": "Correct."},
   {"text": "Yes, because the deck was shuffled first", "feedback": "Shuffling makes the ORDER random. It does not put the dealt cards back."}]'::jsonb,
 2, 'sub-independent-events'),

(12, 'MDM4U', 'Probability', 4, 38, 'Advanced',
 E'A and B are independent, with P(A) = 0.6 and P(B) = 0.5.\nWhat is P(A or B)?',
 '[{"text": "0.8", "feedback": "Correct."},
   {"text": "1.1", "feedback": "The two were added without the overlap being taken off, which pushes the answer above 1 and so cannot be a probability at all."},
   {"text": "0.3", "feedback": "That is P(A and B), the overlap itself. The question asks for the union."},
   {"text": "0.6", "feedback": "That is P(A) on its own. The part of B outside A still has to be added."}]'::jsonb,
 0, 'sub-independent-events'),

(12, 'MDM4U', 'Probability', 4, 39, 'Advanced',
 E'A subdivision has 6 one-storey houses, 4 two-storey houses and 2 split-level houses, all in one row.\nIn how many distinguishable ways can they be arranged?',
 '[{"text": "479 001 600", "feedback": "That is 12 factorial, which treats every house as different. Houses of the same type are interchangeable."},
   {"text": "924", "feedback": "That places only the six one-storey houses and treats the remaining six as interchangeable with each other. A two-storey house and a split-level house are different types."},
   {"text": "48", "feedback": "The three group sizes were multiplied together. The count comes from a factorial divided by three factorials."},
   {"text": "13 860", "feedback": "Correct."}]'::jsonb,
 3, 'sub-counting'),

(12, 'MDM4U', 'Probability', 4, 40, 'Advanced',
 'When should a combination be used rather than a permutation?',
 '[{"text": "When the order of the chosen objects does not matter", "feedback": "Correct."},
   {"text": "When the order of the chosen objects matters", "feedback": "That is exactly when a PERMUTATION is needed. The two have been swapped."},
   {"text": "When the objects may be chosen more than once, so repeats are allowed", "feedback": "Both formulas assume each object is chosen at most once. Repetition needs a different count again."},
   {"text": "When the number of objects is large", "feedback": "The size of the problem has nothing to do with which formula is right."}]'::jsonb,
 0, 'sub-counting');

-- --- questions_mdm4u_u5.sql ---

-- ===========================================================================
-- MDM4U — Unit 5: Probability Distributions — 40 questions
-- ===========================================================================
-- Grade 12 Data Management, authored from the Jensen MDM4U lesson material
-- for this unit:
--
--   Lesson 1  Probability distributions
--   Lesson 2  Hypergeometric distributions
--   Lesson 3  Binomial distributions
--   Lesson 4  Geometric distributions
--   Lesson 5  The binomial theorem
--
-- Five lessons, six subtopics: EXPECTED VALUE is pulled out of Lesson 1 and
-- given a traffic light of its own, because it reappears in all three named
-- distributions and a student can compute every probability in the unit
-- correctly while still not knowing what the average of them means.
--
-- This is the last unit in the bank, and it is the one where naming the
-- right distribution matters more than any arithmetic. The three families
-- differ in exactly one respect each:
--
--   * HYPERGEOMETRIC — no replacement, so the probability changes trial by
--     trial; a fixed number of draws
--   * BINOMIAL — with replacement or from an effectively infinite pool, so
--     the probability is constant; a fixed number of trials
--   * GEOMETRIC — constant probability, but the number of trials is NOT
--     fixed; you stop at the first success
--
-- A student who reaches for the binomial formula on a card problem has made
-- the single most common mistake in the unit, and every hypergeometric
-- question here offers the binomial answer as a distractor.
--
-- The other mistakes that repeat:
--
--   * leaving out the final success factor in a geometric probability, so
--     the answer describes a run of failures and nothing more
--   * reporting the number of successes where the number of TRIALS was
--     asked for, and the reverse
--   * treating past failures as making the next success more likely
--   * taking the binomial coefficient as the whole coefficient, forgetting
--     the powers of the two terms
--
-- Feedback names the mistake and stops there.
--
-- Every probability, combination, expected value and coefficient in this
-- file was recomputed independently with exact integer arithmetic before
-- delivery. The geometric example reproduces the calculator screenshot in
-- the Jensen lesson, 0.0804, exactly.
--
-- FIGURES: one, on question 21.
--
--   * Q21 shows two geometric distributions side by side, one decaying
--     slowly and one collapsing at once, and asks which has the larger
--     probability of success per trial. Neither axis carries a number, so
--     no probability can be read and no expected value counted. The shape
--     is the whole content.
--
-- Rejected: the Jensen distribution tables with the probabilities filled
-- in. A table of P(x) values IS the answer to every question that could be
-- asked about it.
--
-- Also rejected: Pascal triangle diagrams. Printing the triangle answers
-- every coefficient question in the unit by inspection.
--
-- RUN ORDER: supabase_full_setup.sql -> this file -> figures_mdm4u.sql.
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

delete from questions where course_code = 'MDM4U' and unit = 'Probability Distributions';

insert into misconception_labels (tag, label) values
  ('sub-prob-distributions', 'Probability distributions'),
  ('sub-expected-value',     'Expected value'),
  ('sub-hypergeometric',     'Hypergeometric distributions'),
  ('sub-binomial',           'Binomial distributions'),
  ('sub-geometric',          'Geometric distributions'),
  ('sub-binomial-theorem',   'The binomial theorem')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10): what each distribution IS, and one short value each.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability Distributions', 5, 1, 'Easy',
 'What is a random variable?',
 '[{"text": "Any quantity whose value is unknown", "feedback": "Plenty of unknowns are fixed numbers waiting to be found. A random variable takes different values on different trials."},
   {"text": "The probability of an outcome", "feedback": "A probability is attached to a value of the random variable. It is not the variable itself."},
   {"text": "A variable whose value is the numerical outcome of a chance process", "feedback": "Correct."},
   {"text": "A variable chosen at random from the alphabet", "feedback": "The randomness is in the OUTCOME, not in which letter is used to write it down."}]'::jsonb,
 2, 'sub-prob-distributions'),

(12, 'MDM4U', 'Probability Distributions', 5, 2, 'Easy',
 'In any probability distribution, what must all the probabilities add up to?',
 '[{"text": "0", "feedback": "A total of zero would mean nothing can happen at all."},
   {"text": "100", "feedback": "That is the total in PERCENTAGES. The probabilities in a distribution are not written on that scale."},
   {"text": "The number of possible outcomes", "feedback": "That would make the total grow as the list of outcomes got longer. Something is certain to happen, however many ways there are for it to."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-prob-distributions'),

(12, 'MDM4U', 'Probability Distributions', 5, 3, 'Easy',
 'What does the expected value of a random variable describe?',
 '[{"text": "The largest outcome that can occur on any single trial", "feedback": "That is the maximum. An average sits somewhere in the middle of the possibilities."},
   {"text": "The number of trials that will be needed to get a success", "feedback": "That is a question a geometric distribution answers, and only for one particular kind of random variable."},
   {"text": "The long-run average outcome over many repetitions", "feedback": "Correct."},
   {"text": "The single outcome that is most likely to be observed", "feedback": "That is the MODE of the distribution. The two are often different, and the expected value need not even be a possible outcome."}]'::jsonb,
 2, 'sub-expected-value'),

(12, 'MDM4U', 'Probability Distributions', 5, 4, 'Easy',
 'What makes a distribution HYPERGEOMETRIC rather than binomial?',
 '[{"text": "The trials are independent of one another, so nothing drawn earlier changes the next draw", "feedback": "Independent trials with a constant probability are what make a distribution BINOMIAL."},
   {"text": "The probability of success is the same on every trial, since the pool is made whole again each time", "feedback": "A constant probability is the binomial condition. Removing an item changes the pool and so changes the probability."},
   {"text": "The number of trials is not fixed in advance, because you go on until the first success", "feedback": "That is the GEOMETRIC condition. A hypergeometric problem has a definite number of selections."},
   {"text": "The selections are made without replacement, so the probability changes from one trial to the next", "feedback": "Correct."}]'::jsonb,
 3, 'sub-hypergeometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 5, 'Easy',
 'A committee of 3 is chosen from a pool of 18 people. How many different committees are possible?',
 '[{"text": "5832", "feedback": "That is 18 cubed, which would allow the same person to be picked three times."},
   {"text": "816", "feedback": "Correct."},
   {"text": "4896", "feedback": "That counts ordered selections. A committee is a set, so the same three people in a different order is the same committee."},
   {"text": "54", "feedback": "The 18 was multiplied by 3. Choosing three from eighteen is a combination, not a product."}]'::jsonb,
 1, 'sub-hypergeometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 6, 'Easy',
 'What makes a distribution BINOMIAL?',
 '[{"text": "A number of trials that is not decided in advance, since you stop at the first success", "feedback": "That is the GEOMETRIC condition. A binomial problem always says how many trials there are."},
   {"text": "More than two possible outcomes on each trial, rather than a plain success or failure", "feedback": "A binomial trial has exactly two: success or failure. That is where the name comes from."},
   {"text": "A fixed number of independent trials, each with the same probability of success", "feedback": "Correct."},
   {"text": "Selections made without replacement, so that the pool shrinks with every draw", "feedback": "That changes the probability each time, which is the HYPERGEOMETRIC condition."}]'::jsonb,
 2, 'sub-binomial'),

(12, 'MDM4U', 'Probability Distributions', 5, 7, 'Easy',
 'A fair coin is tossed 10 times. What is the expected number of heads?',
 '[{"text": "0.5", "feedback": "That is the probability of a head on a single toss. It still has to be multiplied by the number of tosses."},
   {"text": "2", "feedback": "Nothing in the problem produces this. Multiply the number of trials by the probability of success."},
   {"text": "5", "feedback": "Correct."},
   {"text": "10", "feedback": "That is the number of TOSSES. The expected count of heads is that multiplied by the probability of a head."}]'::jsonb,
 2, 'sub-binomial'),

(12, 'MDM4U', 'Probability Distributions', 5, 8, 'Easy',
 'What does a GEOMETRIC random variable count?',
 '[{"text": "The number of successes in a fixed number of independent trials", "feedback": "That is a BINOMIAL random variable. The two count opposite things."},
   {"text": "The number of failures beforehand, with the success itself left out", "feedback": "The successful trial is included in the count, which is why the smallest possible value is 1 rather than 0."},
   {"text": "The probability of a success on any one of the individual trials", "feedback": "That is p, a fixed number rather than a random variable."},
   {"text": "The number of trials up to and including the first success", "feedback": "Correct."}]'::jsonb,
 3, 'sub-geometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 9, 'Easy',
 'The probability of success on each trial is 1/6. What is the expected number of trials until the first success?',
 '[{"text": "5", "feedback": "That would be the expected number of FAILURES before the success. The successful trial counts too."},
   {"text": "6", "feedback": "Correct."},
   {"text": "1/6", "feedback": "That is the probability itself. The expected waiting time is its reciprocal."},
   {"text": "36", "feedback": "The reciprocal was squared. Waiting time is one over p, not one over p squared."}]'::jsonb,
 1, 'sub-geometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 10, 'Easy',
 'In the expansion of a binomial raised to the power n, where do the coefficients come from?',
 '[{"text": "From the combinations, which are the entries of Pascal triangle", "feedback": "Correct."},
   {"text": "From the powers of the first term, read off one exponent at a time", "feedback": "The powers of each term step down and up through the expansion, but the numbers in front come from somewhere else."},
   {"text": "From the value of n alone, whichever term is being written", "feedback": "Every term would then have the same coefficient, and they plainly do not."},
   {"text": "They are all equal to 1, whatever the term", "feedback": "Only the first and the last are. The ones in between grow towards the middle."}]'::jsonb,
 0, 'sub-binomial-theorem'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20): one probability from each family, correctly set up.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability Distributions', 5, 11, 'Medium',
 E'A distribution has P(0) = 0.2, P(1) = 0.5, P(2) = 0.2 and one more outcome, x = 3.\nWhat must P(3) be?',
 '[{"text": "0", "feedback": "The three given values total 0.9, so something is still unaccounted for."},
   {"text": "0.1", "feedback": "Correct."},
   {"text": "0.9", "feedback": "The three given probabilities were added and reported. What is missing is the amount needed to reach 1."},
   {"text": "0.3", "feedback": "Neither the sum nor the shortfall comes to this. Add the three given values and take the total from 1."}]'::jsonb,
 1, 'sub-prob-distributions'),

(12, 'MDM4U', 'Probability Distributions', 5, 12, 'Medium',
 'What is the difference between a discrete and a continuous random variable?',
 '[{"text": "A discrete one takes smaller values than a continuous one does", "feedback": "Size has nothing to do with it. A count of grains of sand is discrete and enormous."},
   {"text": "A continuous one has more possible outcomes than a discrete one ever does", "feedback": "It does have infinitely many, but so can a discrete one: the number of trials to a first success has no upper limit."},
   {"text": "A discrete one always has finitely many outcomes, however wide the range of values it covers", "feedback": "Not always. A geometric random variable is discrete and its list of values runs on forever."},
   {"text": "A discrete one takes separated values; a continuous one can take any value in an interval", "feedback": "Correct."}]'::jsonb,
 3, 'sub-prob-distributions'),

(12, 'MDM4U', 'Probability Distributions', 5, 13, 'Medium',
 E'A game costs 2 dollars to play and pays 10 dollars with probability 0.15, nothing otherwise.\nWhat is the expected profit per play?',
 '[{"text": "8.00 dollars", "feedback": "That is the profit on a single winning play, which happens only 15 times in 100."},
   {"text": "-0.50 dollars", "feedback": "Correct."},
   {"text": "1.50 dollars", "feedback": "That is the expected PAYOUT. The 2 dollar cost still has to be taken off."},
   {"text": "-2.00 dollars", "feedback": "That is what you lose when you do not win. On average you win something back."}]'::jsonb,
 1, 'sub-expected-value'),

(12, 'MDM4U', 'Probability Distributions', 5, 14, 'Medium',
 E'A committee of 3 is chosen from 8 men and 10 women.\nWhat is the probability that exactly 2 are women, to four decimal places?',
 '[{"text": "0.4115", "feedback": "The binomial formula was used with p equal to 10 over 18. Each selection changes the pool, so the trials are not independent."},
   {"text": "0.4412", "feedback": "Correct."},
   {"text": "0.3431", "feedback": "That is the probability of exactly ONE woman. Check which group the 2 belongs to."},
   {"text": "0.1471", "feedback": "That is the probability of all THREE being women."}]'::jsonb,
 1, 'sub-hypergeometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 15, 'Medium',
 'A committee of 3 is chosen from 8 men and 10 women. What is the expected number of women on it?',
 '[{"text": "3", "feedback": "That is the size of the whole committee, which would need every member to be a woman."},
   {"text": "About 0.56", "feedback": "That is the proportion of women in the pool. It still has to be multiplied by the number of people being chosen."},
   {"text": "About 1.67", "feedback": "Correct."},
   {"text": "1.5", "feedback": "That is half the committee, which would be right only if the pool were evenly split. There are more women than men in it."}]'::jsonb,
 2, 'sub-hypergeometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 16, 'Medium',
 E'A test has 10 multiple-choice questions with 4 options each, and a student guesses every one.\nWhat is the probability of getting exactly 3 right, to four decimal places?',
 '[{"text": "0.3000", "feedback": "Three out of ten was reported as a probability. The chance of that particular count is a separate calculation."},
   {"text": "0.0563", "feedback": "That is the probability of getting NONE right."},
   {"text": "0.2500", "feedback": "That is the probability of getting a single question right, which is p rather than the answer."},
   {"text": "0.2503", "feedback": "Correct."}]'::jsonb,
 3, 'sub-binomial'),

(12, 'MDM4U', 'Probability Distributions', 5, 17, 'Medium',
 'On a 10-question test with 4 options each, what is the expected number a guessing student gets right?',
 '[{"text": "2.5", "feedback": "Correct."},
   {"text": "5", "feedback": "That would be right for a two-option test. With four options the chance on each question is a quarter."},
   {"text": "4", "feedback": "That is the number of OPTIONS per question, not a count of correct answers."},
   {"text": "0.25", "feedback": "That is the probability on a single question. It still has to be multiplied by the number of questions."}]'::jsonb,
 0, 'sub-binomial'),

(12, 'MDM4U', 'Probability Distributions', 5, 18, 'Medium',
 E'One bottle cap in six wins a prize. Kramer buys bottles until he wins.\nWhat is the probability that he buys exactly 5 bottles, to four decimal places?',
 '[{"text": "0.4019", "feedback": "That is the probability of five FAILURES in a row. The fifth bottle has to be the winner, so the last factor is one sixth rather than five sixths."},
   {"text": "0.1667", "feedback": "That is the probability of winning on a single bottle, with no waiting time attached."},
   {"text": "0.0001", "feedback": "That is one sixth raised to the fifth power, which would need all five caps to be winners."},
   {"text": "0.0804", "feedback": "Correct."}]'::jsonb,
 3, 'sub-geometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 19, 'Medium',
 'What is the coefficient of the term containing x squared times y cubed in the expansion of a binomial x plus y raised to the fifth power?',
 '[{"text": "10", "feedback": "Correct."},
   {"text": "5", "feedback": "That is the exponent, and also the coefficient of the second term. This term is further along the row."},
   {"text": "20", "feedback": "That entry belongs to the row for the sixth power, not the fifth."},
   {"text": "1", "feedback": "Only the first and last coefficients in a row are 1."}]'::jsonb,
 0, 'sub-binomial-theorem'),

(12, 'MDM4U', 'Probability Distributions', 5, 20, 'Medium',
 'What is the row of Pascal triangle used for expanding a binomial raised to the fifth power?',
 '[{"text": "1, 6, 15, 20, 15, 6, 1", "feedback": "That row belongs to the sixth power."},
   {"text": "1, 5, 10, 10, 5, 1", "feedback": "Correct."},
   {"text": "1, 4, 6, 4, 1", "feedback": "That row belongs to the fourth power. A fifth power expansion has six terms, not five."},
   {"text": "1, 5, 10, 5, 1", "feedback": "No row of Pascal triangle reads like this one. The middle of the row was recalled rather than worked out."}]'::jsonb,
 1, 'sub-binomial-theorem'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30): name the family before touching a formula. Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability Distributions', 5, 21, 'Challenge',
 E'The diagram shows two geometric distributions of the waiting time to a first success.\nWhich one comes from the larger probability of success per trial?',
 '[{"text": "They must be equal, since both start at their highest bar", "feedback": "Every geometric distribution has its tallest bar first. What separates them is how fast the rest fall away."},
   {"text": "B, because its bars collapse almost immediately", "feedback": "Correct."},
   {"text": "A, because its bars stretch further along the axis", "feedback": "A long tail means long waits are common, which is what happens when success is UNLIKELY on any given trial."},
   {"text": "A, because it has more bars of a visible height", "feedback": "Having many trials still in play is the mark of a small probability. A large one ends the wait quickly."}]'::jsonb,
 1, 'sub-prob-distributions'),

(12, 'MDM4U', 'Probability Distributions', 5, 22, 'Challenge',
 'A uniform probability distribution has 5 equally likely outcomes. What probability does each one carry?',
 '[{"text": "1", "feedback": "That is the TOTAL of all five together. Each individual one is a fifth of it."},
   {"text": "0.5", "feedback": "That would be right for two equally likely outcomes, not five."},
   {"text": "0.2", "feedback": "Correct."},
   {"text": "5", "feedback": "That is the number of outcomes. A probability can never exceed 1."}]'::jsonb,
 2, 'sub-prob-distributions'),

(12, 'MDM4U', 'Probability Distributions', 5, 23, 'Challenge',
 E'A lottery ticket costs 5 dollars. It pays 1000 dollars with probability 1 in 500 and nothing otherwise.\nWhat is the expected value of a ticket to the buyer?',
 '[{"text": "-3 dollars", "feedback": "Correct."},
   {"text": "2 dollars", "feedback": "That is the expected payout. The 5 dollar price still has to be taken off."},
   {"text": "-5 dollars", "feedback": "That is the loss on a losing ticket. On average a little comes back."},
   {"text": "995 dollars", "feedback": "That is the profit on the one winning ticket in 500, which is not an average over all of them."}]'::jsonb,
 0, 'sub-expected-value'),

(12, 'MDM4U', 'Probability Distributions', 5, 24, 'Challenge',
 'What does it mean for a game of chance to be FAIR?',
 '[{"text": "The expected value to each player is zero", "feedback": "Correct."},
   {"text": "Every player has the same chance of winning", "feedback": "Equal chances with unequal stakes is still unfair. Fairness weighs the prizes against the probabilities."},
   {"text": "The prize is equal to the cost of playing", "feedback": "That would be a disastrous game for the player unless winning were certain. The prize has to be larger than the cost to make up for losing."},
   {"text": "Both players play the same number of times", "feedback": "Playing an unfair game equally often just loses both players money at the same rate."}]'::jsonb,
 0, 'sub-expected-value'),

(12, 'MDM4U', 'Probability Distributions', 5, 25, 'Challenge',
 E'You are dealt a four-card hand from a standard deck of 52.\nWhat is the probability that exactly 2 are spades, to four decimal places?',
 '[{"text": "0.2135", "feedback": "Correct."},
   {"text": "0.4388", "feedback": "That is the probability of exactly ONE spade."},
   {"text": "0.3038", "feedback": "That is the probability of NO spades at all."},
   {"text": "0.2109", "feedback": "The binomial formula was used with p equal to a quarter. Each card dealt changes the deck, so the draws are not independent."}]'::jsonb,
 0, 'sub-hypergeometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 26, 'Challenge',
 'What is the expected number of spades in a four-card hand dealt from a standard deck?',
 '[{"text": "0.25", "feedback": "That is the proportion of the deck that is spades. It still has to be multiplied by the number of cards dealt."},
   {"text": "4", "feedback": "That is the size of the hand, which would need every card to be a spade."},
   {"text": "13", "feedback": "That is the number of spades in the whole deck, not the number expected in four cards."},
   {"text": "1", "feedback": "Correct."}]'::jsonb,
 3, 'sub-hypergeometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 27, 'Challenge',
 E'A student guesses all 10 questions on a test with 4 options each.\nWhat is the probability of getting at least one right, to four decimal places?',
 '[{"text": "0.7500", "feedback": "That is the probability of getting one particular question WRONG. Over ten questions the chance of at least one right is much larger."},
   {"text": "0.9437", "feedback": "Correct."},
   {"text": "0.0563", "feedback": "That is the probability of getting NONE right. The complement still has to be taken."},
   {"text": "0.2500", "feedback": "That is the probability on a single question. Ten questions give far more chances."}]'::jsonb,
 1, 'sub-binomial'),

(12, 'MDM4U', 'Probability Distributions', 5, 28, 'Challenge',
 E'One bottle cap in six wins. Kramer buys bottles until he wins.\nWhat is the probability that he needs 3 bottles or fewer, to four decimal places?',
 '[{"text": "0.4213", "feedback": "Correct."},
   {"text": "0.0804", "feedback": "That is the probability of needing exactly 5 bottles, which is not part of this question at all."},
   {"text": "0.5787", "feedback": "That is the probability of needing MORE than 3 bottles. The complement has been reported."},
   {"text": "0.5000", "feedback": "Nothing in the problem produces a half. Add the probabilities for one, two and three bottles."}]'::jsonb,
 0, 'sub-geometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 29, 'Challenge',
 'Why does a geometric distribution have no fixed number of trials?',
 '[{"text": "Because the trials continue until the first success, which could take any number of attempts", "feedback": "Correct."},
   {"text": "Because the probability of success changes from one trial to the next, as it does when drawing without replacement", "feedback": "It does not change; a constant p is one of the conditions. What varies is how long the wait turns out to be."},
   {"text": "Because the random variable is continuous rather than discrete", "feedback": "The number of trials is a whole number, so the variable is discrete. It simply has no upper limit."},
   {"text": "Because each trial has more than two possible outcomes", "feedback": "Each trial has exactly two, success or failure, just as in a binomial setting."}]'::jsonb,
 0, 'sub-geometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 30, 'Challenge',
 'In the expansion of the binomial 2x plus 3 raised to the fourth power, what is the coefficient of x squared?',
 '[{"text": "54", "feedback": "The 3 squared was included but the 2 squared was not. Both terms carry a coefficient here."},
   {"text": "24", "feedback": "The 2 squared was included but the 3 squared was not."},
   {"text": "216", "feedback": "Correct."},
   {"text": "6", "feedback": "Only the entry from Pascal triangle was used. The powers of 2x and of 3 both contribute as well."}]'::jsonb,
 2, 'sub-binomial-theorem'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40): the ones where naming the family IS the question.
-- Astro+.
-- ---------------------------------------------------------------------------

(12, 'MDM4U', 'Probability Distributions', 5, 31, 'Advanced',
 'Five cards are dealt from a deck and the aces among them are counted. Which distribution applies?',
 '[{"text": "Binomial", "feedback": "A binomial needs the probability to stay the same on every trial. Each card dealt changes what is left in the deck."},
   {"text": "Geometric", "feedback": "A geometric distribution counts trials until a first success. Here the number of cards is fixed at five and it is the successes that are counted."},
   {"text": "Uniform", "feedback": "A uniform distribution makes every outcome equally likely, and getting four aces is nowhere near as likely as getting none."},
   {"text": "Hypergeometric", "feedback": "Correct."}]'::jsonb,
 3, 'sub-prob-distributions'),

(12, 'MDM4U', 'Probability Distributions', 5, 32, 'Advanced',
 E'A distribution has P(0) = 0.1, P(1) = 0.3, P(2) = 0.4 and P(3) = 0.2.\nWhat is the expected value?',
 '[{"text": "6", "feedback": "The four values were added without being weighted by their probabilities."},
   {"text": "1.7", "feedback": "Correct."},
   {"text": "1.5", "feedback": "That is the plain average of 0, 1, 2 and 3, which ignores how likely each one is."},
   {"text": "2", "feedback": "That is the MOST LIKELY outcome. An expected value weighs every outcome rather than picking the tallest."}]'::jsonb,
 1, 'sub-expected-value'),

(12, 'MDM4U', 'Probability Distributions', 5, 33, 'Advanced',
 'Why is the expected value of a random variable often not one of its possible outcomes?',
 '[{"text": "Because the expected value is a probability rather than an outcome", "feedback": "It is measured in the units of the outcomes, not on a scale from 0 to 1."},
   {"text": "It always is a possible outcome", "feedback": "The expected number of heads in three coin tosses is 1.5, which no single set of three tosses can produce."},
   {"text": "Because it is a weighted average, and averages need not be attainable values", "feedback": "Correct."},
   {"text": "Because of rounding in the calculation", "feedback": "The figure can be exact and still impossible. An average family size of 2.4 children is arithmetic rather than error."}]'::jsonb,
 2, 'sub-expected-value'),

(12, 'MDM4U', 'Probability Distributions', 5, 34, 'Advanced',
 'When is a hypergeometric distribution well approximated by a binomial one?',
 '[{"text": "When the population is very large compared with the number of selections", "feedback": "Correct."},
   {"text": "When the number of selections is large", "feedback": "That makes the approximation WORSE, because more of the pool is removed as you go."},
   {"text": "When the probability of success is one half", "feedback": "The value of p does not decide how much removing an item disturbs the pool."},
   {"text": "Never, because the two describe completely different situations", "feedback": "They converge in the limit. Drawing ten people from a country is barely different from drawing them with replacement."}]'::jsonb,
 0, 'sub-hypergeometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 35, 'Advanced',
 E'A binomial distribution has 20 trials with a probability of success of 0.3.\nWhat are its mean and its variance?',
 '[{"text": "Mean 0.3 and variance 4.2", "feedback": "The probability was reported as the mean. It has to be multiplied by the number of trials first."},
   {"text": "Mean 6 and variance 4.2", "feedback": "Correct."},
   {"text": "Mean 6 and variance 6", "feedback": "The mean was reused as the variance. The variance multiplies the mean by the probability of FAILURE as well."},
   {"text": "Mean 6 and variance 2.05", "feedback": "That is the standard deviation. Squaring it gives the variance."}]'::jsonb,
 1, 'sub-binomial'),

(12, 'MDM4U', 'Probability Distributions', 5, 36, 'Advanced',
 E'A student needs AT LEAST 5 correct out of 10 guessed questions.\nWhich calculation gives that probability?',
 '[{"text": "The probability of exactly 5 correct", "feedback": "That leaves out 6, 7, 8, 9 and 10, all of which also clear the bar."},
   {"text": "The probability of 5 or fewer correct", "feedback": "That is the wrong side of the cut, and it includes the failures rather than the passes."},
   {"text": "1 minus the probability of 5 or fewer correct", "feedback": "This subtracts every score from 0 to 5. Re-read which scores the phrase AT LEAST 5 counts as successes."},
   {"text": "1 minus the probability of 4 or fewer correct", "feedback": "Correct."}]'::jsonb,
 3, 'sub-binomial'),

(12, 'MDM4U', 'Probability Distributions', 5, 37, 'Advanced',
 E'In Monopoly you leave jail by rolling doubles, which happens with probability 1 in 6.\nHow many rolls should you expect to need?',
 '[{"text": "1/6", "feedback": "That is the probability itself. The expected waiting time is its reciprocal, which has to be bigger than 1."},
   {"text": "3", "feedback": "Nothing in the problem produces this. The expected number of trials is one divided by the probability of success."},
   {"text": "6", "feedback": "Correct."},
   {"text": "36", "feedback": "That is the number of outcomes when two dice are rolled. The probability of doubles among them is 6 in 36, and the expected wait is the reciprocal of that."}]'::jsonb,
 2, 'sub-geometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 38, 'Advanced',
 E'A player has rolled five times without getting doubles.\nWhat is the probability that the sixth roll gives doubles?',
 '[{"text": "Lower than 1/6, because this run of dice is clearly unlucky", "feedback": "The dice are unchanged by what has happened. Nothing about the past alters the next roll."},
   {"text": "5/6, because five failures have already been used up", "feedback": "Failures are not a finite supply that can run out. Each roll starts afresh."},
   {"text": "1/6, exactly as on every other roll", "feedback": "Correct."},
   {"text": "Higher than 1/6, because a success is overdue", "feedback": "The dice have no memory of the five failures. This is the gambler fallacy, and it is what the whole lesson is built to break."}]'::jsonb,
 2, 'sub-geometric'),

(12, 'MDM4U', 'Probability Distributions', 5, 39, 'Advanced',
 'In the expansion of the binomial x plus 2 raised to the seventh power, what is the term containing x to the fourth?',
 '[{"text": "35 times x to the fourth", "feedback": "Only the entry from Pascal triangle was used. The 2 is raised to the third power in this term and contributes a factor of 8."},
   {"text": "70 times x to the fourth", "feedback": "The 2 was included only once rather than cubed. The power on the 2 matches the power missing from the x."},
   {"text": "560 times x to the fourth", "feedback": "The 2 was raised to the fourth power. Its exponent is 7 take away 4, which is 3."},
   {"text": "280 times x to the fourth", "feedback": "Correct."}]'::jsonb,
 3, 'sub-binomial-theorem'),

(12, 'MDM4U', 'Probability Distributions', 5, 40, 'Advanced',
 'How many terms are there in the expansion of a binomial raised to the power n?',
 '[{"text": "n plus 1", "feedback": "Correct."},
   {"text": "n", "feedback": "One short. The exponent on the first term runs all the way from n down to 0, which is one more value than n."},
   {"text": "2n", "feedback": "The two terms of the binomial were counted separately in every position. Each position contributes one term."},
   {"text": "n squared", "feedback": "The expansion grows in length one term at a time as the exponent rises, not by squaring."}]'::jsonb,
 0, 'sub-binomial-theorem');

-- --- figures_mdm4u.sql  (must be last) ---

-- ======================================================================
-- figures_mdm4u.sql — attaches figures to questions
-- ======================================================================
-- GENERATED by tools/make_figures.py — edit that script, not this file.
--
-- Run AFTER the question files for this course, and after any re-run of
-- one: the per-unit delete wipes the figure column with the rest of the
-- row. Safe to re-run on its own at any time.
--
-- The PNGs live in web/figures/ and ship inside every deploy. A null
-- figure renders no image, and a missing file shows a short "could not
-- load" line in the app rather than a broken icon.

update questions set figure = null where course_code = 'MDM4U';

update questions set figure = 'figures/mdm4u_stat_10.png'
 where course_code = 'MDM4U' and unit = 'Displays of Data' and sort_order = 10;
update questions set figure = 'figures/mdm4u_stat_17.png'
 where course_code = 'MDM4U' and unit = 'Displays of Data' and sort_order = 17;
update questions set figure = 'figures/mdm4u_stat_25.png'
 where course_code = 'MDM4U' and unit = 'Normal Distributions' and sort_order = 25;
update questions set figure = 'figures/mdm4u_venn_14.png'
 where course_code = 'MDM4U' and unit = 'Probability' and sort_order = 14;
update questions set figure = 'figures/mdm4u_geo_21.png'
 where course_code = 'MDM4U' and unit = 'Probability Distributions' and sort_order = 21;

-- Check: every figure attached, and none orphaned.
select unit, sort_order, figure from questions
 where course_code = 'MDM4U' and figure is not null
 order by unit, sort_order;
