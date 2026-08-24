-- ===========================================================================
-- SAMPLE QUESTION BANK — placeholder until the real material arrives
-- ===========================================================================
-- The old 200-question bank is retired. This file exists so every flow in
-- the app — levels, locks, medals, teacher dashboard, parent reports — stays
-- testable while the real Grade 10 material is being turned into questions.
--
-- Twelve questions, one unit, three per level including Advanced, so the
-- paywall has something real behind it. DELETE THIS UNIT the day the first
-- real unit loads; the delete at the top of each authored file will do it if
-- the unit name is reused, but do not reuse it — these are throwaway.
--
-- Conventions the real files must follow (see docs/AUTHORING_GUIDE.md):
--   * sort_order unique across the whole unit, 1..40 (1-10 Easy, 11-20
--     Medium, 21-30 Challenge, 31-40 Advanced)
--   * every wrong option is a named mistake; feedback never reveals the
--     answer
--   * misconception_tag is the SUBTOPIC slug, and misconception_label()
--     turns it into the subtopic name a teacher and parent read
--   * no apostrophes in any string — one ends the string and kills the file

delete from questions where grade = 10 and unit = 'Linear systems (sample)';

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty, prompt,
   options, correct_index, misconception_tag)
values

-- ------------------------------------------------------------------ Easy
(10, 'MPM2D', 'Linear systems (sample)', 1, 1, 'Easy',
 'Which point lies on the line y = 2x + 1?',
 '[{"text":"(1, 3)","feedback":"Correct."},
   {"text":"(1, 2)","feedback":"That is the 2 from 2x on its own. Substitute x = 1 into the whole right side."},
   {"text":"(3, 1)","feedback":"The coordinates are swapped. The first number is x, the second is y."},
   {"text":"(0, 2)","feedback":"When x = 0 the 2x part vanishes. Look at what is left."}]'::jsonb,
 0, 'sub-substitute-into-line'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 2, 'Easy',
 'Two lines cross at exactly one point. How many solutions does the system have?',
 '[{"text":"One","feedback":"Correct."},
   {"text":"None","feedback":"No solutions happens when the lines never meet. These ones cross."},
   {"text":"Two","feedback":"Two straight lines cannot cross twice. Picture it."},
   {"text":"Infinitely many","feedback":"That is what happens when the two lines are the same line."}]'::jsonb,
 0, 'sub-meaning-of-solution'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 3, 'Easy',
 'In the system y = x + 4 and y = 2x, what can be set equal?',
 '[{"text":"x + 4 and 2x","feedback":"Correct."},
   {"text":"x and 2x","feedback":"The 4 cannot be dropped. Both full right-hand sides equal y."},
   {"text":"y and x","feedback":"y and x are different quantities. It is the two expressions for y that match."},
   {"text":"x + 4 and y","feedback":"That is just restating the first equation. Use both."}]'::jsonb,
 0, 'sub-substitution-setup'),

-- ---------------------------------------------------------------- Medium
(10, 'MPM2D', 'Linear systems (sample)', 1, 11, 'Medium',
 'Solve by substitution: y = x + 4 and y = 2x. What is x?',
 '[{"text":"4","feedback":"Correct."},
   {"text":"-4","feedback":"Check the sign when moving x across. x + 4 = 2x leaves 4 = x."},
   {"text":"2","feedback":"That may come from dividing 4 by 2 too early. Collect the x terms first."},
   {"text":"8","feedback":"That is y, not x. The question asks for x."}]'::jsonb,
 0, 'sub-substitution-solve'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 12, 'Medium',
 'To eliminate y from 3x + 2y = 12 and 5x - 2y = 4, what should be done?',
 '[{"text":"Add the equations","feedback":"Correct."},
   {"text":"Subtract them","feedback":"Subtracting gives 2y minus negative 2y, which is 4y — y survives. Watch the signs."},
   {"text":"Multiply the first by 2","feedback":"The y coefficients are already opposites. No scaling is needed."},
   {"text":"Divide the second by 2","feedback":"That creates a fraction on x and still leaves y in both."}]'::jsonb,
 0, 'sub-elimination-choice'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 13, 'Medium',
 'Adding 3x + 2y = 12 and 5x - 2y = 4 gives which equation?',
 '[{"text":"8x = 16","feedback":"Correct."},
   {"text":"8x = 8","feedback":"The right sides add too: 12 + 4. Only the left was added."},
   {"text":"2x = 16","feedback":"3x + 5x is 8x. The x terms add, not subtract."},
   {"text":"8x + 4y = 16","feedback":"2y and -2y cancel. That is the whole point of adding here."}]'::jsonb,
 0, 'sub-elimination-add'),

-- -------------------------------------------------------------- Challenge
(10, 'MPM2D', 'Linear systems (sample)', 1, 21, 'Challenge',
 'A system has equations 2x + 3y = 7 and 4x + 6y = 20. How many solutions?',
 '[{"text":"None","feedback":"Correct."},
   {"text":"One","feedback":"Double the first equation and compare it with the second before assuming they cross."},
   {"text":"Infinitely many","feedback":"That needs BOTH sides to scale by the same factor. Check the right sides."},
   {"text":"Two","feedback":"Two straight lines cannot meet exactly twice."}]'::jsonb,
 0, 'sub-parallel-vs-same-line'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 22, 'Challenge',
 'Tickets cost 8 dollars for adults and 5 for students. 30 tickets sold for 195 dollars. Which system fits?',
 '[{"text":"a + s = 30 and 8a + 5s = 195","feedback":"Correct."},
   {"text":"a + s = 195 and 8a + 5s = 30","feedback":"The 30 counts tickets and the 195 counts dollars. They are swapped."},
   {"text":"8a + 5s = 30 and a + s = 195","feedback":"Prices belong with the money total, counts with the ticket total."},
   {"text":"a + s = 30 and 5a + 8s = 195","feedback":"The prices are attached to the wrong groups. Adults pay 8."}]'::jsonb,
 0, 'sub-word-problem-setup'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 23, 'Challenge',
 'For the ticket system above, how many adult tickets were sold?',
 '[{"text":"15","feedback":"Correct."},
   {"text":"30","feedback":"That is every ticket. The adults are only part of the 30."},
   {"text":"10","feedback":"Check by substituting back: do the dollars reach 195?"},
   {"text":"25","feedback":"Substitute back into the money equation — 25 adults overshoots 195."}]'::jsonb,
 0, 'sub-word-problem-solve'),

-- --------------------------------------------------------------- Advanced
(10, 'MPM2D', 'Linear systems (sample)', 1, 31, 'Advanced',
 'For what value of k does the system y = 3x + 2 and y = kx + 5 have NO solution?',
 '[{"text":"3","feedback":"Correct."},
   {"text":"5","feedback":"5 is the intercept of the second line. No solution is about the slopes matching."},
   {"text":"-3","feedback":"Opposite slopes guarantee a crossing. Think about what makes lines never meet."},
   {"text":"Any value","feedback":"Most values of k make the lines cross once. Only one slope avoids it."}]'::jsonb,
 0, 'sub-parameter-parallel'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 32, 'Advanced',
 'The lines y = 2x + 1, y = -x + 7 and y = ax + 3 all pass through one point. What is a?',
 '[{"text":"0.5","feedback":"Correct."},
   {"text":"2","feedback":"That is the slope of the first line. Find the shared point first, then fit the third."},
   {"text":"1","feedback":"Substitute the crossing point of the first two lines into the third before choosing."},
   {"text":"-1","feedback":"That is the slope of the second line, not the third."}]'::jsonb,
 0, 'sub-concurrent-lines'),

(10, 'MPM2D', 'Linear systems (sample)', 1, 33, 'Advanced',
 'A and B mix 40 percent and 90 percent solutions to make 100 mL at 60 percent. How much of the 90 percent solution?',
 '[{"text":"40 mL","feedback":"Correct."},
   {"text":"60 mL","feedback":"That is the amount of the WEAKER solution. The strong one fills the rest."},
   {"text":"50 mL","feedback":"Equal parts of 40 and 90 average to 65, not 60. Check with the concentration equation."},
   {"text":"90 mL","feedback":"That reads the 90 percent label as a volume. Percent and millilitres are different columns."}]'::jsonb,
 0, 'sub-mixture-problems');

-- Sanity check
select difficulty, count(*)
from questions where unit = 'Linear systems (sample)'
group by difficulty
order by case difficulty when 'Easy' then 0 when 'Medium' then 1
         when 'Challenge' then 2 else 3 end;
