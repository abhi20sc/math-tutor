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
