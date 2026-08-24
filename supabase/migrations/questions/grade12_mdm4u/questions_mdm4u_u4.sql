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
