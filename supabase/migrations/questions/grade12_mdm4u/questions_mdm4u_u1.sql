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
-- RUN ORDER: astro_math_assist_setup.sql -> this file -> figures_mdm4u.sql.
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
