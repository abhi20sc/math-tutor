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
