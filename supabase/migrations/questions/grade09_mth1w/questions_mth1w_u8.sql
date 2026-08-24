-- ===========================================================================
-- MTH1W — Unit 8: Data — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Measures of central tendency (including frequency tables)
--   Lesson 2  Measures of spread and boxplots
--   Lesson 3  Scatterplots and regression models
--
-- Three lessons but five distinct skills, so the unit splits into five
-- subtopics: the frequency-table version of an average is a separate skill
-- from the list version, and reading a boxplot is separate from computing
-- the quartiles that build it.
--
-- Every data set is written out in the prompt, so this unit is answerable
-- without figures. Where a boxplot would normally carry the information, the
-- prompt states the five-number summary instead.
--
-- The distractors are the slips the worked solutions keep correcting: taking
-- the middle of an UNORDERED list, averaging the distinct values of a
-- frequency table instead of weighting them, subtracting the quartiles the
-- wrong way round, and reading a correlation as a cause.
--
-- RUN ORDER: astro_math_assist_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Data';

insert into misconception_labels (tag, label) values
  ('sub-central-tendency', 'Mean, median and mode'),
  ('sub-frequency-tables', 'Averages from a frequency table'),
  ('sub-spread',           'Range, quartiles and interquartile range'),
  ('sub-boxplots',         'Boxplots and the five-number summary'),
  ('sub-scatterplots',     'Scatterplots and correlation')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 1, 'Easy',
 'Find the mean of the test scores 72, 85, 78, 90, 85, 88, 78, 85, 92, 75.',
 '[{"text": "82.8", "feedback": "Correct."},
   {"text": "85", "feedback": "That is the value that appears most often. The mean shares the total out evenly instead."},
   {"text": "82", "feedback": "The total is right, but it was rounded down rather than divided exactly."},
   {"text": "8.28", "feedback": "The total was divided by 100 rather than by the number of scores."}]'::jsonb,
 0, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 2, 'Easy',
 'Find the mode of the test scores 72, 85, 78, 90, 85, 88, 78, 85, 92, 75.',
 '[{"text": "85", "feedback": "Correct."},
   {"text": "92", "feedback": "That is the largest score. The mode is about frequency, not size."},
   {"text": "78", "feedback": "That value does repeat, but another one repeats more often."},
   {"text": "82.8", "feedback": "That is the mean. The mode is a value that actually appears in the list."}]'::jsonb,
 0, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 3, 'Easy',
 'A frequency table shows hourly wages: 17 dollars for 20 employees, 19 dollars for 8, 20 dollars for 5, 25 dollars for 7 and 30 dollars for 3. What is the modal wage?',
 '[{"text": "20 dollars", "feedback": "That wage is paid to only five employees. Look for the largest frequency, not the roundest wage."},
   {"text": "30 dollars", "feedback": "That is the highest wage. The mode is the one paid most often."},
   {"text": "17 dollars", "feedback": "Correct."},
   {"text": "19.93 dollars", "feedback": "That is the mean wage. The mode has to be a wage that actually appears in the table."}]'::jsonb,
 2, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 4, 'Easy',
 'In that same wage table (frequencies 20, 8, 5, 7 and 3), how many employees are there altogether?',
 '[{"text": "5", "feedback": "That is the number of different wage levels, not the number of people."},
   {"text": "43", "feedback": "Correct."},
   {"text": "111", "feedback": "The wages were added instead of the frequencies."},
   {"text": "20", "feedback": "That is the largest single frequency. All five have to be added."}]'::jsonb,
 1, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 5, 'Easy',
 'Find the range of the data set 12, 15, 18, 22, 27.',
 '[{"text": "15", "feedback": "Correct."},
   {"text": "27", "feedback": "That is the largest value. The range subtracts the smallest from it."},
   {"text": "18", "feedback": "That is the middle value. The range uses the two extremes."},
   {"text": "39", "feedback": "The two extremes were added. The range subtracts them."}]'::jsonb,
 0, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 6, 'Easy',
 'What does the interquartile range measure?',
 '[{"text": "The value that appears most often", "feedback": "That is the mode, which describes the centre rather than the spread."},
   {"text": "The spread of the middle half of the data", "feedback": "Correct."},
   {"text": "The difference between the largest and smallest values", "feedback": "That is the range. The interquartile range ignores the extremes."},
   {"text": "The average distance of each value from the mean", "feedback": "That is a different measure of spread. This one is built from quartiles."}]'::jsonb,
 1, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 7, 'Easy',
 'Which five values make up the summary a boxplot is drawn from?',
 '[{"text": "Q1, Q2, Q3, range and interquartile range", "feedback": "The quartiles are right, but a boxplot also needs the two extreme values."},
   {"text": "Mean, median, mode, range and interquartile range", "feedback": "Those are summary statistics, but a boxplot is built from positions in the ordered data."},
   {"text": "Minimum, Q1, median, Q3 and maximum", "feedback": "Correct."},
   {"text": "Minimum, mean, median, mode and maximum", "feedback": "The mean and mode never appear on a boxplot. The quartiles do."}]'::jsonb,
 2, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 8, 'Easy',
 'On a boxplot, what does the rectangular box span?',
 '[{"text": "From the median to the maximum", "feedback": "That is the upper half of the data. The box covers the middle half."},
   {"text": "From Q1 to Q3", "feedback": "Correct."},
   {"text": "From the mean to the median", "feedback": "The mean is never plotted on a boxplot."},
   {"text": "From the minimum to the maximum", "feedback": "That is the whole plot including the whiskers. The box is narrower."}]'::jsonb,
 1, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 9, 'Easy',
 'On a scatterplot, which variable goes on the x-axis?',
 '[{"text": "Whichever variable has the larger values", "feedback": "The size of the numbers does not decide it. The roles of the variables do."},
   {"text": "Whichever variable has more data points", "feedback": "Both variables have the same number of points, since they come in pairs."},
   {"text": "The independent variable", "feedback": "Correct."},
   {"text": "The dependent variable", "feedback": "That one goes on the vertical axis, because it responds to the other."}]'::jsonb,
 2, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 10, 'Easy',
 'On a scatterplot of hours studied against test score, the points run from the lower left to the upper right. What kind of correlation is this?',
 '[{"text": "Negative", "feedback": "That pattern runs from the upper left down to the lower right instead."},
   {"text": "No correlation", "feedback": "A clear direction in the points means there is a relationship to describe."},
   {"text": "It cannot be told from a scatterplot", "feedback": "The direction of the pattern is exactly what a scatterplot shows."},
   {"text": "Positive", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatterplots'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 11, 'Medium',
 'Find the median of the points scored: 0, 8, 6, 0, 3, 5, 3, 4, 2, 9, 12.',
 '[{"text": "4", "feedback": "Correct."},
   {"text": "5", "feedback": "That is the sixth value of the list as written. The list has to be sorted first."},
   {"text": "6", "feedback": "That is the position of the middle value, not the value sitting in that position."},
   {"text": "4.73", "feedback": "That is the mean. The median is an actual position in the ordered list."}]'::jsonb,
 0, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 12, 'Medium',
 'Find the mean of the points scored: 0, 8, 6, 0, 3, 5, 3, 4, 2, 9, 12. Round to two decimal places.',
 '[{"text": "5.20", "feedback": "The total is right, but it was divided by ten. The two zeros still count as players."},
   {"text": "4.73", "feedback": "Correct."},
   {"text": "4.00", "feedback": "That is the median of this set. The mean shares the total out evenly instead."},
   {"text": "52.00", "feedback": "That is the total. It still has to be divided by how many players there are."}]'::jsonb,
 1, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 13, 'Medium',
 'From the wage table (17 dollars for 20 employees, 19 for 8, 20 for 5, 25 for 7, 30 for 3), what is the mean wage, to two decimal places?',
 '[{"text": "22.20 dollars", "feedback": "The five different wages were averaged. Each one has to be weighted by how many people earn it."},
   {"text": "857.00 dollars", "feedback": "That is the total payroll per hour. It still has to be divided by the number of employees."},
   {"text": "19.93 dollars", "feedback": "Correct."},
   {"text": "18.08 dollars", "feedback": "Only the largest group was weighted; the other four wages were each counted once."}]'::jsonb,
 2, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 14, 'Medium',
 'From that same wage table, what is the median wage?',
 '[{"text": "22 dollars", "feedback": "That is the POSITION of the middle employee, not the wage that employee earns."},
   {"text": "17 dollars", "feedback": "That is the modal wage. Twenty employees earn it, but the middle position falls just past them."},
   {"text": "19 dollars", "feedback": "Correct."},
   {"text": "20 dollars", "feedback": "The middle position falls inside a smaller group than that. Build up the running totals."}]'::jsonb,
 2, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 15, 'Medium',
 'For the data set 8, 12, 15, 18, 22, 27, 30, 35, 40, what is Q1?',
 '[{"text": "15", "feedback": "That is one of the two middle values of the lower half. The two of them get averaged."},
   {"text": "13.5", "feedback": "Correct."},
   {"text": "12", "feedback": "That is the other middle value of the lower half. The two of them get averaged."},
   {"text": "22", "feedback": "That is the overall median, which is Q2 rather than Q1."}]'::jsonb,
 1, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 16, 'Medium',
 'For the data set 8, 12, 15, 18, 22, 27, 30, 35, 40, what is the interquartile range?',
 '[{"text": "32", "feedback": "That is the range, which uses the two extreme values rather than the quartiles."},
   {"text": "46", "feedback": "The two quartiles were added. The interquartile range subtracts them."},
   {"text": "22", "feedback": "That is the overall median, not a measure of spread."},
   {"text": "19", "feedback": "Correct."}]'::jsonb,
 3, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 17, 'Medium',
 'For the ordered data 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6, 7, 8, 9, 10, 10, 12, 15, 26, what is the median?',
 '[{"text": "5", "feedback": "Correct."},
   {"text": "6", "feedback": "That is one place past the middle. With nineteen values the middle sits at the tenth."},
   {"text": "26", "feedback": "That is the largest value, which is the maximum rather than the middle."},
   {"text": "3", "feedback": "That is the most common value, which is the mode rather than the middle one."}]'::jsonb,
 0, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 18, 'Medium',
 'For that same ordered data set of nineteen values, what is Q3?',
 '[{"text": "10", "feedback": "Correct."},
   {"text": "26", "feedback": "That is the maximum. Q3 is the middle of the upper half, not its top."},
   {"text": "12", "feedback": "That is one place past Q3. The upper half here has nine values, so its middle is the fifth of them."},
   {"text": "9", "feedback": "That is one place before Q3. Count the upper half again, starting just above the overall median."}]'::jsonb,
 0, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 19, 'Medium',
 'Two variables have a correlation coefficient of -0.9. What does that tell you?',
 '[{"text": "No linear correlation", "feedback": "That would need a value close to zero."},
   {"text": "A strong negative linear correlation", "feedback": "Correct."},
   {"text": "A weak negative linear correlation", "feedback": "The minus sign gives the direction, but the size tells the strength, and this one sits close to the extreme."},
   {"text": "A strong positive linear correlation", "feedback": "The strength is right, but the sign says the two variables move in opposite directions."}]'::jsonb,
 1, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 20, 'Medium',
 'Two variables have a correlation coefficient of 0.05. What does that tell you?',
 '[{"text": "A strong positive linear correlation", "feedback": "That would need a value close to one. This one sits close to zero."},
   {"text": "A strong negative linear correlation", "feedback": "That would need a value close to minus one, and this value is not even negative."},
   {"text": "Little or no linear correlation", "feedback": "Correct."},
   {"text": "A perfect correlation", "feedback": "That would need a value of exactly one or minus one."}]'::jsonb,
 2, 'sub-scatterplots'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 21, 'Challenge',
 'In the data set 0, 8, 6, 0, 3, 5, 3, 4, 2, 9, 12, the player with 12 points instead scores 20. Which measures of central tendency change?',
 '[{"text": "The mean and the median", "feedback": "The changed value is already the largest, so it stays at the top of the ordered list and the middle position is untouched."},
   {"text": "Only the mean", "feedback": "Correct."},
   {"text": "The median and the mode", "feedback": "Neither of those depends on how large the biggest value is, only on where it sits and how often values repeat."},
   {"text": "All three", "feedback": "Only one of the three uses the actual size of every value."}]'::jsonb,
 1, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 22, 'Challenge',
 'A set of five numbers has a mean of 20. One number is removed and the mean of the remaining four is 22. What was the number that was removed?',
 '[{"text": "18", "feedback": "Removing that value would barely move the mean. Work with the two totals instead."},
   {"text": "42", "feedback": "The two means were added. It is the totals behind them that have to be compared."},
   {"text": "12", "feedback": "Correct."},
   {"text": "2", "feedback": "That is the change in the mean, not the value that left the set."}]'::jsonb,
 2, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 23, 'Challenge',
 'In the wage table (17 dollars for 20 employees, 19 for 8, 20 for 5, 25 for 7, 30 for 3), one more employee is hired at 30 dollars an hour, taking that group from 3 people to 4. What happens to the modal wage?',
 '[{"text": "It stays at 17 dollars", "feedback": "Correct."},
   {"text": "There are now two modes", "feedback": "Two modes would need two groups tied for the largest frequency. These are not close."},
   {"text": "It rises slightly", "feedback": "The mode always equals a value from the table. It cannot drift between them."},
   {"text": "It becomes 30 dollars", "feedback": "Four people is still far short of the largest group in the table."}]'::jsonb,
 0, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 24, 'Challenge',
 'Every employee in the wage table is given a raise of 2 dollars an hour. What happens to the mean wage?',
 '[{"text": "It rises by 2 divided by the number of employees", "feedback": "That would be right if only one person got the raise. Everybody got it here."},
   {"text": "It stays the same", "feedback": "The total payroll grows, and the number of employees does not, so the average has to move."},
   {"text": "It doubles", "feedback": "The raise is added to each wage, not multiplied into it."},
   {"text": "It rises by exactly 2 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 25, 'Challenge',
 'Data set A is 50, 50, 50, 50, 50 and data set B is 10, 30, 50, 70, 90. What distinguishes them?',
 '[{"text": "Their spread: A has a range of 0 and B has a range of 80", "feedback": "Correct."},
   {"text": "Nothing, they are equivalent data sets", "feedback": "The centres agree, but one set is identical values and the other stretches widely."},
   {"text": "Their means", "feedback": "Both totals come to 250 across five values, so the means match."},
   {"text": "Their medians", "feedback": "The middle value of each ordered set is the same."}]'::jsonb,
 0, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 26, 'Challenge',
 'A data set has a range of 15 but an interquartile range of only 4. What does that suggest?',
 '[{"text": "The mean must equal the median", "feedback": "These two measures say nothing about where the mean sits."},
   {"text": "The data are evenly spread across the whole range", "feedback": "Even spreading would put the quartiles far apart, giving a much larger middle spread."},
   {"text": "The middle half is tightly packed, with a few values far out at the ends", "feedback": "Correct."},
   {"text": "The data set must contain a calculation error", "feedback": "Nothing is wrong. A middle spread smaller than the full spread is entirely normal."}]'::jsonb,
 2, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 27, 'Challenge',
 'A boxplot has the five-number summary minimum 1, Q1 3, median 5, Q3 10, maximum 26. What is the interquartile range?',
 '[{"text": "5", "feedback": "That is the median. The interquartile range is a distance between two quartiles."},
   {"text": "13", "feedback": "The two quartiles were added. The interquartile range subtracts them."},
   {"text": "25", "feedback": "That is the range, which uses the two extreme values rather than the quartiles."},
   {"text": "7", "feedback": "Correct."}]'::jsonb,
 3, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 28, 'Challenge',
 'For that boxplot (minimum 1, Q1 3, median 5, Q3 10, maximum 26), which whisker is longer and what does it tell you?',
 '[{"text": "Whisker length says nothing about the data", "feedback": "A whisker shows how far the outer quarter of the data reaches, which is exactly what spread means."},
   {"text": "The upper whisker, so the data stretch out at the high end", "feedback": "Correct."},
   {"text": "The lower whisker, so the data trail off at the low end", "feedback": "The lower whisker runs only from 1 to 3. Compare that with the gap above the box."},
   {"text": "They are the same length", "feedback": "Measure each one: the gap below the box and the gap above it are very different."}]'::jsonb,
 1, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 29, 'Challenge',
 'A line of best fit for hours studied (x) against test score (y) is y = 5.4x + 48. Predict the score for 8 hours of study.',
 '[{"text": "91.2", "feedback": "Correct."},
   {"text": "53.4", "feedback": "The slope was counted once instead of once for every hour studied."},
   {"text": "43.2", "feedback": "The starting value of 48 was left out of the prediction."},
   {"text": "427.2", "feedback": "The whole expression was multiplied by 8. Only the x term is."}]'::jsonb,
 0, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 30, 'Challenge',
 'A scatterplot rises steeply at first and then flattens out as x grows, never turning back downward. Which regression model is likely to fit it best?',
 '[{"text": "No model can fit a curved pattern", "feedback": "Regression is not limited to straight lines. Several curved models are available."},
   {"text": "Linear", "feedback": "A straight line rises at the same rate the whole way. This pattern changes its rate."},
   {"text": "Quadratic", "feedback": "A quadratic curve turns and comes back down. This one keeps rising while flattening."},
   {"text": "Logarithmic", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatterplots'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Data', 8, 31, 'Advanced',
 'A class of 20 students has a mean score of 70. A new student joins with a score of 91. What is the new mean?',
 '[{"text": "71.05", "feedback": "The extra marks were shared across the wrong number of students."},
   {"text": "74.55", "feedback": "The new total was divided by the old class size rather than the new one."},
   {"text": "80.5", "feedback": "That averages the old mean with the new score. The old mean already stands for twenty students."},
   {"text": "71", "feedback": "Correct."}]'::jsonb,
 3, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 32, 'Advanced',
 'A data set has a mean of 50 but a median of 30. What does this suggest about the data?',
 '[{"text": "A few unusually small values are pulling the mean downward", "feedback": "That would push the mean BELOW the median. Here the mean sits above it."},
   {"text": "The data are symmetric about their centre", "feedback": "Symmetric data have a mean and median that sit on top of each other."},
   {"text": "There must be a calculation error", "feedback": "Nothing is wrong. The two measures often disagree, and the gap is informative."},
   {"text": "A few unusually large values are pulling the mean upward", "feedback": "Correct."}]'::jsonb,
 3, 'sub-central-tendency'),

(9, 'MTH1W', 'Data', 8, 33, 'Advanced',
 'In a frequency table of test marks, 6 students scored 5, 4 students scored 7, and n students scored 10. The mean mark is exactly 7. What is n?',
 '[{"text": "n = 6", "feedback": "Substitute it back: the total comes to 118 across 16 students, which is above the target mean."},
   {"text": "n = 4", "feedback": "Correct."},
   {"text": "n = 2", "feedback": "Substitute it back: the total comes to 78 across 12 students, which falls short of the target mean."},
   {"text": "n = 10", "feedback": "That copies the mark rather than solving for the frequency."}]'::jsonb,
 1, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 34, 'Advanced',
 'Why does the mean of a frequency table use the sum of each value times its frequency, divided by the total frequency?',
 '[{"text": "Because the mode has to be found first", "feedback": "The three measures are found independently of one another."},
   {"text": "Because the values are not always whole numbers", "feedback": "Whole numbers or not, the issue is how many people sit behind each value."},
   {"text": "Because a frequency table is already sorted", "feedback": "Sorting matters for the median. It has nothing to do with how the mean is weighted."},
   {"text": "Because each value stands for several data points, not just one", "feedback": "Correct."}]'::jsonb,
 3, 'sub-frequency-tables'),

(9, 'MTH1W', 'Data', 8, 35, 'Advanced',
 'Find the interquartile range of 4, 7, 9, 12, 15, 18, 21, 24.',
 '[{"text": "27.5", "feedback": "The two quartiles were added. The interquartile range subtracts them."},
   {"text": "20", "feedback": "That is the range, which uses the two extreme values rather than the quartiles."},
   {"text": "13.5", "feedback": "That is the overall median. With eight values it falls between the fourth and fifth."},
   {"text": "11.5", "feedback": "Correct."}]'::jsonb,
 3, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 36, 'Advanced',
 'A data set currently has a maximum of 40. A single new value of 100 is added. Which is affected more, the range or the interquartile range?',
 '[{"text": "Neither changes", "feedback": "At least one measure has to react, because the largest value in the set has moved a long way."},
   {"text": "The range, because it depends only on the extreme values", "feedback": "Correct."},
   {"text": "The interquartile range, because it uses the middle half", "feedback": "Using the middle half is exactly what protects it from one extreme value."},
   {"text": "Both change by the same amount", "feedback": "One of the two is built from the extremes and the other deliberately avoids them."}]'::jsonb,
 1, 'sub-spread'),

(9, 'MTH1W', 'Data', 8, 37, 'Advanced',
 'Parallel boxplots compare resting pulse rates. Females: Q1 68, median 74, Q3 80. Males: Q1 62, median 70, Q3 76. What can you conclude?',
 '[{"text": "Nothing can be compared from boxplots", "feedback": "Comparing centre and spread across groups is exactly what parallel boxplots are for."},
   {"text": "The male rates are centred higher", "feedback": "Compare the two medians. The one for males sits four beats lower."},
   {"text": "The female rates are centred higher, and the two middle spreads are similar", "feedback": "Correct."},
   {"text": "The female rates are much more spread out", "feedback": "Work out each middle spread by subtracting the quartiles. They come out within two beats of each other."}]'::jsonb,
 2, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 38, 'Advanced',
 'On a boxplot, what fraction of the data lies below Q1?',
 '[{"text": "It depends on how many values are in the set", "feedback": "The quartiles are defined by fractions of the data, so this holds for every set no matter how large."},
   {"text": "One half", "feedback": "That fraction lies below the MEDIAN. Q1 sits lower than that."},
   {"text": "One quarter", "feedback": "Correct."},
   {"text": "Three quarters", "feedback": "That fraction lies below Q3, at the far end of the box."}]'::jsonb,
 2, 'sub-boxplots'),

(9, 'MTH1W', 'Data', 8, 39, 'Advanced',
 'Opening week revenue and lifetime gross revenue for a set of films have a correlation coefficient of 0.68. How should this be described?',
 '[{"text": "A moderate positive linear correlation", "feedback": "Correct."},
   {"text": "A strong negative correlation", "feedback": "The value is positive, so the two revenues rise together."},
   {"text": "Sixty-eight percent of the films sit exactly on the trend line", "feedback": "The coefficient measures how closely the points follow a line, not how many land on it."},
   {"text": "No correlation", "feedback": "That would need a value close to zero. This one is well away from it."}]'::jsonb,
 0, 'sub-scatterplots'),

(9, 'MTH1W', 'Data', 8, 40, 'Advanced',
 'Ice cream sales and drowning numbers show a strong positive correlation across the year. What does this establish?',
 '[{"text": "That buying ice cream causes drownings", "feedback": "A pattern in the data cannot by itself show which way, if either, the influence runs."},
   {"text": "That drownings cause ice cream sales", "feedback": "Reversing the claim does not fix it. Neither direction follows from the correlation alone."},
   {"text": "That the correlation must be a calculation error", "feedback": "The correlation is real. It is the causal reading of it that does not follow."},
   {"text": "Only that the two move together, possibly because of a third factor such as hot weather", "feedback": "Correct."}]'::jsonb,
 3, 'sub-scatterplots');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Data'
group by difficulty order by min(sort_order);
