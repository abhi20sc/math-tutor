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
