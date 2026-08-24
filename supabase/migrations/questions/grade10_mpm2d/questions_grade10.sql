-- ===========================================================================
-- ASTRO MATH ASSIST — GRADE 10 (MPM2D), complete
-- ===========================================================================
--
-- 240 questions across six units, plus the 33 figures that attach to them.
-- Questions and figures used to be two files that had to be run in order,
-- and running the second one was easy to forget — which showed up as
-- questions that reference a diagram nobody can see. They are one file now.
--
-- RUN ORDER:  supabase_full_setup.sql  ->  this file.
--
-- Safe to re-run on its own at any time: each unit is deleted and reinserted,
-- and the figures are reattached at the end. Student attempts are NOT touched
-- by this file — they live in attempts and unit_mastery, keyed on course, unit
-- and sort_order, so a corrected question keeps its history.
--
-- ---------------------------------------------------------------------------
-- The six units
-- ---------------------------------------------------------------------------
--   1  Linear systems                 40
--   2  Analytic geometry              40
--   3  Factoring                      40
--   4  Quadratics                     40
--   5  Solving quadratic equations    40
--   6  Trigonometry                   40
--
-- Each unit is 10 Easy, 10 Medium, 10 Challenge, 10 Advanced, in sort_order
-- 1-40. Easy and Medium are free; Challenge and Advanced need Astro+, and
-- that is enforced in the database, not in the app.
--
-- ---------------------------------------------------------------------------
-- The figures
-- ---------------------------------------------------------------------------
-- 33 PNGs, mostly Trigonometry. They live in web/figures/ and ship inside
-- every deploy, so this file only stores the path. A null figure renders no
-- image; a missing file shows a short "could not load" line rather than a
-- broken icon.
--
-- Every figure was measured against a ruler before it shipped: if a student
-- could get the answer by measuring the drawing instead of doing the
-- mathematics, the figure is wrong, however pretty it looks. Two were caught
-- and redrawn by that test.
--
-- ---------------------------------------------------------------------------
-- What a question owes the student
-- ---------------------------------------------------------------------------
-- Every wrong option is a SPECIFIC mistake, and its feedback names the
-- mistake without revealing the answer. "Not quite, try again" is not
-- feedback. Neither is anything that states the correct value.
-- ===========================================================================

delete from questions where grade = 10 and unit = 'Linear systems';

insert into misconception_labels (tag, label) values
  ('sub-elimination', 'Solving by elimination'),
  ('sub-linear-applications', 'Linear system applications'),
  ('sub-solving-by-graphing', 'Solving by graphing'),
  ('sub-substitution', 'Solving by substitution')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values
(10, 'MPM2D', 'Linear systems', 1, 1, 'Easy',
 'What is the solution of a linear system, on a graph?',
 '[{"text": "The y-intercept of the first line", "feedback": "That is where one line meets the y-axis, not where the two lines meet each other."}, {"text": "The origin", "feedback": "The origin is only the solution if both lines happen to pass through (0, 0)."}, {"text": "The point where the lines intersect", "feedback": "Correct."}, {"text": "The steeper of the two lines", "feedback": "A solution is a point, not a line. Look for where they cross."}]'::jsonb, 2, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 2, 'Easy',
 'Two lines have the same slope but different y-intercepts. How many solutions does the system have?',
 '[{"text": "None", "feedback": "Correct."}, {"text": "Two", "feedback": "Two straight lines can never cross at exactly two points."}, {"text": "Infinitely many", "feedback": "Infinitely many needs the SAME line twice — same slope AND same intercept."}, {"text": "One", "feedback": "Equal slopes make the lines parallel, so they never cross. Check the slopes again."}]'::jsonb, 0, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 3, 'Easy',
 'To graph 2x + y = 6 using slope and y-intercept, what does it rearrange to?',
 '[{"text": "y = 6x - 2", "feedback": "The slope is the coefficient of x, not the constant. They have been swapped."}, {"text": "y = 2x + 6", "feedback": "The 2x changes sign when it moves to the other side."}, {"text": "y = -2x - 6", "feedback": "Only the 2x moved, so only the 2x changes sign. The 6 stayed where it was."}, {"text": "y = -2x + 6", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 4, 'Easy',
 'Which point is the solution of the system y = 3x + 1 and y = -x + 5?',
 '[{"text": "(3, 2)", "feedback": "That point sits on the second line only. A solution has to satisfy BOTH equations."}, {"text": "(4, 1)", "feedback": "The coordinates are swapped. The first number is x, the second is y."}, {"text": "(1, 4)", "feedback": "Correct."}, {"text": "(0, 1)", "feedback": "That is the y-intercept of the first line, not the crossing point of the two."}]'::jsonb, 2, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 5, 'Easy',
 'In the system y = 2x - 3 and 3x + y = 7, what should replace y in the second equation?',
 '[{"text": "2x", "feedback": "The whole expression for y substitutes in, minus sign and all. The 3 cannot be left behind."}, {"text": "7", "feedback": "7 is the right side of the second equation, not an expression for y."}, {"text": "x", "feedback": "y equals the FULL right side of the first equation, not just x. All of it substitutes in."}, {"text": "2x - 3", "feedback": "Correct."}]'::jsonb, 3, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 6, 'Easy',
 'After substituting, 3x + (2x - 3) = 7 simplifies to which equation?',
 '[{"text": "6x - 3 = 7", "feedback": "3x + 2x is 5x. The coefficients add, they do not multiply."}, {"text": "5x - 3 = 4", "feedback": "Only the left side was simplified. The 7 does not change in this step."}, {"text": "5x - 3 = 7", "feedback": "Correct."}, {"text": "5x + 3 = 7", "feedback": "The minus sign in front of the 3 came through the brackets unchanged here."}]'::jsonb, 2, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 7, 'Easy',
 'When can two equations be added to eliminate a variable immediately?',
 '[{"text": "Whenever both equations contain the variable", "feedback": "Containing the variable is not enough — the coefficients must be opposites for adding to cancel it."}, {"text": "When that variable has equal coefficients", "feedback": "Equal coefficients need SUBTRACTION to cancel. Adding doubles them."}, {"text": "Only when the coefficients are 1 and -1", "feedback": "Any pair of opposites works, like 4y and -4y, not just 1 and -1."}, {"text": "When that variable has opposite coefficients", "feedback": "Correct."}]'::jsonb, 3, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 8, 'Easy',
 'Adding the equations 2x + 3y = 12 and 5x - 3y = 9 gives which result?',
 '[{"text": "7x = 21", "feedback": "Correct."}, {"text": "7x + 6y = 21", "feedback": "3y and -3y are opposites, so they cancel. That is the point of adding here."}, {"text": "3x = 21", "feedback": "2x + 5x is 7x. Check the x coefficients — they add, not subtract."}, {"text": "7x = 3", "feedback": "The right sides ADD as well: 12 + 9. Only the left side was combined."}]'::jsonb, 0, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 9, 'Easy',
 'Two numbers have a sum of 20. If one number is n, what is the other?',
 '[{"text": "20 - n", "feedback": "Correct."}, {"text": "n + 20", "feedback": "The two numbers ADD to 20. Adding 20 to n overshoots the total."}, {"text": "n - 20", "feedback": "That is negative whenever n is small. The other number is what REMAINS out of 20."}, {"text": "20n", "feedback": "A sum means addition. Multiplying the two would be a product of 20, a different problem."}]'::jsonb, 0, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 10, 'Easy',
 'Adult tickets cost 12 dollars and child tickets cost 8 dollars. Which expression is the money collected from a adult and c child tickets?',
 '[{"text": "20(a + c)", "feedback": "That charges every ticket 20 dollars. The two prices cannot be pooled."}, {"text": "12a + 8c", "feedback": "Correct."}, {"text": "12 + 8 + a + c", "feedback": "Each ticket price multiplies its COUNT. Adding everything ignores how many were sold."}, {"text": "8a + 12c", "feedback": "The prices are attached to the wrong groups. Adults pay 12."}]'::jsonb, 1, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 11, 'Medium',
 'Solve by substitution: y = 2x - 3 and 3x + y = 7. What is the solution?',
 '[{"text": "(2, 7)", "feedback": "7 is the right side of an equation, not the value of y. Finish by substituting x back."}, {"text": "(2, -1)", "feedback": "x is right. Substitute x = 2 back into y = 2x - 3 and watch the sign."}, {"text": "(2, 1)", "feedback": "Correct."}, {"text": "(1, 2)", "feedback": "The coordinates are swapped. Solve for x first, then find y from it."}]'::jsonb, 2, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 12, 'Medium',
 'Solve by substitution: x = y - 1 and x + 2y = 8. What is y?',
 '[{"text": "3", "feedback": "Correct."}, {"text": "7/3", "feedback": "The -1 moves to the right side as +1 before dividing: 3y = 9."}, {"text": "2", "feedback": "That is x. The question asks for y — read which variable is wanted."}, {"text": "9/2", "feedback": "Check the substitution: (y - 1) + 2y gives 3y - 1, not 2y - 1."}]'::jsonb, 0, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 13, 'Medium',
 'Solve by elimination: 3x + 2y = 19 and x + 2y = 13. What is x?',
 '[{"text": "5", "feedback": "That is y. Subtracting eliminates y and leaves 2x = 6 to solve for x."}, {"text": "3", "feedback": "Correct."}, {"text": "8", "feedback": "Adding the equations keeps y alive: 2y + 2y is 4y. EQUAL coefficients need subtraction."}, {"text": "16", "feedback": "The right sides subtract too: 19 - 13 = 6, so 2x = 6."}]'::jsonb, 1, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 14, 'Medium',
 'To eliminate y from 2x + 5y = 1 and 3x - 2y = 11, what should the equations be multiplied by?',
 '[{"text": "First by 5 and second by 2", "feedback": "That makes 25y and -4y — not opposites. The multipliers cross over: each equation takes the OTHER coefficient."}, {"text": "Nothing — just add them", "feedback": "5y and -2y do not cancel as they stand. They must be scaled to opposites first."}, {"text": "First by 2 and second by 5", "feedback": "Correct."}, {"text": "First by 3 and second by 2", "feedback": "That matches the x coefficients, which eliminates x, not y. Aim at the y column."}]'::jsonb, 2, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 15, 'Medium',
 'Solve: 2x + 5y = 1 and 3x - 2y = 11. What is the solution?',
 '[{"text": "(3, -1)", "feedback": "Correct."}, {"text": "(3, 1)", "feedback": "x is right. Substitute x = 3 into 2x + 5y = 1 and mind the sign: 5y = -5."}, {"text": "(2, 1)", "feedback": "Check by substituting into BOTH equations — the second gives 4, not 11."}, {"text": "(-1, 3)", "feedback": "The coordinates are swapped. x was solved first as 3."}]'::jsonb, 0, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 16, 'Medium',
 'Before eliminating, x/2 + y/3 = 4 should be rewritten as which equation?',
 '[{"text": "x + y = 24", "feedback": "The denominators divide INTO 6 — they do not simply vanish."}, {"text": "2x + 3y = 24", "feedback": "Multiplying by 6 gives 6/2 = 3 on x and 6/3 = 2 on y. The coefficients are crossed."}, {"text": "3x + 2y = 4", "feedback": "The right side multiplies by 6 as well. Every term does."}, {"text": "3x + 2y = 24", "feedback": "Correct."}]'::jsonb, 3, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 17, 'Medium',
 'A system has equations y = 3x + 2 and 6x - 2y = -4. How many solutions?',
 '[{"text": "Infinitely many", "feedback": "Correct."}, {"text": "Two", "feedback": "Two lines cannot cross exactly twice, whatever the system."}, {"text": "One", "feedback": "Rearrange the second: it is y = 3x + 2 again. The same line twice meets everywhere."}, {"text": "None", "feedback": "No solutions needs parallel but DIFFERENT lines. These are the same line."}]'::jsonb, 0, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 18, 'Medium',
 'Two numbers have a sum of 13 and a difference of 5. What is the larger number?',
 '[{"text": "9", "feedback": "Correct."}, {"text": "18", "feedback": "That is 2x. Divide by 2 to finish."}, {"text": "8", "feedback": "8 and 5 differ by 3, not 5. Set up x + y = 13 and x - y = 5 and add them."}, {"text": "4", "feedback": "That is the smaller number. Adding the two equations gives 2x = 18."}]'::jsonb, 0, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 19, 'Medium',
 'A cinema collected 296 dollars, from 30 tickets at 12 dollars for adults and 8 for children. How many adult tickets were sold?',
 '[{"text": "14", "feedback": "Correct."}, {"text": "16", "feedback": "That is the number of CHILD tickets. Check which count the question asks for."}, {"text": "30", "feedback": "That is every ticket sold. The adults are only part of the 30."}, {"text": "12", "feedback": "12 is the price of an adult ticket, not the count. Solve the system first."}]'::jsonb, 0, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 20, 'Medium',
 'Tree A is 120 cm tall and grows 15 cm per year. Tree B is 60 cm and grows 25 cm per year. After how many years are they the same height?',
 '[{"text": "10", "feedback": "That is the difference in growth rates, not the time. Divide the height gap by it."}, {"text": "4", "feedback": "Substitute back: at 4 years the heights are 180 and 160 — not equal yet."}, {"text": "6", "feedback": "Correct."}, {"text": "18", "feedback": "Check the setup: 120 + 15t = 60 + 25t leads to 60 = 10t."}]'::jsonb, 2, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 21, 'Challenge',
 'For what value of k does the system y = 4x - 1 and y = kx + 3 have no solution?',
 '[{"text": "3", "feedback": "3 is the intercept of the second line. Parallel is about slope, not intercept."}, {"text": "4", "feedback": "Correct."}, {"text": "-1", "feedback": "That is the intercept of the first line. Match the slopes."}, {"text": "-4", "feedback": "Opposite slopes cross once. No solution needs the SAME slope with different intercepts."}]'::jsonb, 1, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 22, 'Challenge',
 'Solve: 4x - 3y = 5 and 2x + y = 5. What is the solution?',
 '[{"text": "(0, 5)", "feedback": "Setting x = 0 satisfies only the second equation. Both must hold at once."}, {"text": "(1, 3)", "feedback": "Check in the first equation: 4 - 9 = -5, not 5."}, {"text": "(2, 1)", "feedback": "Correct."}, {"text": "(2, -1)", "feedback": "x = 2 is right. From 2x + y = 5, y = 5 - 4. Watch the sign."}]'::jsonb, 2, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 23, 'Challenge',
 'A jar holds 25 coins, all dimes and quarters, worth 4.30 dollars in total. Which system fits, with d dimes and q quarters?',
 '[{"text": "d + q = 4.30 and 0.10d + 0.25q = 25", "feedback": "The 25 counts coins and the 4.30 counts dollars. They are swapped."}, {"text": "d + q = 25 and 0.10d + 0.25q = 4.30", "feedback": "Correct."}, {"text": "d + q = 25 and 10d + 25q = 4.30", "feedback": "Using cents on the left needs cents on the right: 430, not 4.30. The units disagree."}, {"text": "d + q = 25 and 0.25d + 0.10q = 4.30", "feedback": "The values are attached to the wrong coins. A dime is 0.10."}]'::jsonb, 1, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 24, 'Challenge',
 'A jar holds 25 coins, all dimes and quarters, worth 4.30 dollars in total. How many quarters are in it?',
 '[{"text": "25", "feedback": "That is every coin. The quarters are only part of the 25."}, {"text": "18", "feedback": "Substitute back: 18 quarters alone is 4.50 dollars — already past the total."}, {"text": "13", "feedback": "That is the number of DIMES. Check which coin the question asks about."}, {"text": "12", "feedback": "Correct."}]'::jsonb, 3, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 25, 'Challenge',
 'A 40 percent solution is mixed with a 90 percent solution to make 100 mL of 60 percent solution. How much of the 90 percent solution is needed?',
 '[{"text": "50 mL", "feedback": "Equal parts average to 65 percent, not 60. Use 0.40w + 0.90s = 60 with w + s = 100."}, {"text": "40 mL", "feedback": "Correct."}, {"text": "90 mL", "feedback": "That reads the 90 percent label as a volume. Percent and millilitres are different columns."}, {"text": "60 mL", "feedback": "That is the amount of the WEAKER solution. The strong one fills the remaining 40."}]'::jsonb, 1, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 26, 'Challenge',
 'The length of a rectangle is 3 m more than twice its width, and the perimeter is 36 m. What is the width?',
 '[{"text": "11", "feedback": "Perimeter uses 2(l + w), not l + w. The 36 must be halved before substituting."}, {"text": "5", "feedback": "Correct."}, {"text": "13", "feedback": "That is the LENGTH. The width came out of 2(l + w) = 36 first."}, {"text": "6", "feedback": "That uses a length of just 2w and drops the extra 3 m the problem gives."}]'::jsonb, 1, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 27, 'Challenge',
 'A boat travels 24 km downstream in 2 hours and back upstream in 3 hours. What is the speed of the current?',
 '[{"text": "2 km/h", "feedback": "Correct."}, {"text": "12 km/h", "feedback": "That is the downstream speed, boat plus current together. Split it into the two parts."}, {"text": "10 km/h", "feedback": "That is the speed of the BOAT in still water. The current is the smaller unknown."}, {"text": "4 km/h", "feedback": "Downstream is b + c = 12 and upstream b - c = 8. Subtracting gives 2c = 4."}]'::jsonb, 0, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 28, 'Challenge',
 'Solve: 0.5x + 0.2y = 3.1 and x + y = 8. What is x?',
 '[{"text": "3", "feedback": "That is y. After clearing decimals, 5x + 2y = 31 minus 2(x + y) = 16 leaves 3x = 15."}, {"text": "5", "feedback": "Correct."}, {"text": "31", "feedback": "31 is the cleared right side, not the answer. Keep going after multiplying by 10."}, {"text": "3.1", "feedback": "Clearing the decimals multiplies EVERY term by 10, including the 3.1."}]'::jsonb, 1, 'sub-elimination'),
(10, 'MPM2D', 'Linear systems', 1, 29, 'Challenge',
 'Which check confirms that (2, 1) really solves a system of two equations?',
 '[{"text": "The two equations turn out to have different slopes", "feedback": "Different slopes promise A solution exists, not that (2, 1) is it."}, {"text": "Substituting (2, 1) makes the first equation true", "feedback": "One equation is not enough — a solution must satisfy the whole system."}, {"text": "Adding the two equations gives a true statement", "feedback": "Adding can hide errors that cancel. Substitute into each equation separately."}, {"text": "Substituting (2, 1) makes both equations true", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 30, 'Challenge',
 'Plan A costs 20 dollars plus 5 cents per minute. Plan B costs a flat 35 dollars. After how many minutes do they cost the same?',
 '[{"text": "700", "feedback": "That solves 20 + 0.05m = 55. The flat plan is 35 dollars."}, {"text": "15", "feedback": "15 is the price gap in dollars. Divide it by the per-minute rate to get minutes."}, {"text": "300", "feedback": "Correct."}, {"text": "3", "feedback": "The 5 cents must be written as 0.05 dollars — or the whole equation kept in cents. The units were mixed."}]'::jsonb, 2, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 31, 'Advanced',
 'For what value of k does the system 2x + ky = 6 and 4x + 6y = 12 have infinitely many solutions?',
 '[{"text": "2", "feedback": "Check: doubling 2x + 2y = 6 gives 4x + 4y = 12, whose y term disagrees with 6y."}, {"text": "3", "feedback": "Correct."}, {"text": "6", "feedback": "k = 6 makes the second equation NOT a multiple of the first. Doubling the first must reproduce the second exactly."}, {"text": "4", "feedback": "That matches the y term against the x coefficient of the second equation. Compare slot by slot: y term with y term."}]'::jsonb, 1, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 32, 'Advanced',
 'The lines y = 2x + 1, y = -x + 7 and y = ax + 4 all pass through one point. What is a?',
 '[{"text": "-1", "feedback": "That is the slope of the second line, not the third."}, {"text": "1", "feedback": "Find where the first two lines cross, then substitute that point into the third line — its intercept is 4, not 3."}, {"text": "2", "feedback": "That is the slope of the first line. Find where the first two cross, then fit the third through it."}, {"text": "1/2", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 33, 'Advanced',
 '5000 dollars is split between an account paying 4 percent and one paying 6 percent. The total interest for the year is 260 dollars. How much is in the 6 percent account?',
 '[{"text": "2000 dollars", "feedback": "That is the 4 PERCENT account. Check which account the question asks about."}, {"text": "260 dollars", "feedback": "260 is the interest earned, not an amount invested."}, {"text": "4333 dollars", "feedback": "That divides the whole 260 by 0.06, as if every dollar earned 6 percent. Only part of the 5000 sits in that account."}, {"text": "3000 dollars", "feedback": "Correct."}]'::jsonb, 3, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 34, 'Advanced',
 'For which values of k does 3x + ky = 7 and 6x + 4y = 14 have EXACTLY one solution?',
 '[{"text": "Every value of k", "feedback": "One value must be excluded: the one that makes the lines coincide."}, {"text": "Every value except k = 2", "feedback": "Correct."}, {"text": "No value of k", "feedback": "Most slopes differ from the second line. Only the matching one fails."}, {"text": "k = 2 only", "feedback": "k = 2 makes the second equation double the first — the same line, so infinitely many, not one."}]'::jsonb, 1, 'sub-solving-by-graphing'),
(10, 'MPM2D', 'Linear systems', 1, 35, 'Advanced',
 'A father is three times as old as his son. In 12 years he will be twice as old. How old is the son now?',
 '[{"text": "36", "feedback": "That is the FATHER. The son is a third of it."}, {"text": "12", "feedback": "Correct."}, {"text": "6", "feedback": "Check: in 12 years those ages are 18 and 30, which are not in a 2 to 1 ratio. Revisit the second equation."}, {"text": "24", "feedback": "The 12 years is added to BOTH ages: f + 12 = 2(s + 12), and the 2 multiplies the whole bracket."}]'::jsonb, 1, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 36, 'Advanced',
 '30 kg of an alloy that is 20 percent copper is melted with x kg of a 50 percent copper alloy to make a 30 percent alloy. What is x?',
 '[{"text": "45", "feedback": "Check: 45 kg of strong alloy pulls the mixture to 38 percent — too high. Solve 6 + 0.5x = 0.3(30 + x)."}, {"text": "10", "feedback": "That divides the copper shortfall by 0.3, the target percent."}, {"text": "30", "feedback": "Equal masses would average to 35 percent, overshooting 30. Less of the strong alloy is needed."}, {"text": "15", "feedback": "Correct."}]'::jsonb, 3, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 37, 'Advanced',
 'The lines y = x + 1 and y = -2x + 7 intersect at point P. What is P?',
 '[{"text": "(6, 7)", "feedback": "Setting the equations equal gives 3x = 6, not x = 6. The x terms collect on one side first."}, {"text": "(3, 2)", "feedback": "The coordinates are swapped. x came first from x + 1 = -2x + 7."}, {"text": "(2, 3)", "feedback": "Correct."}, {"text": "(2, -3)", "feedback": "Substitute x = 2 into y = x + 1. The y value is positive."}]'::jsonb, 2, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 38, 'Advanced',
 'A salesperson earns a base salary plus the same percent commission on sales. Selling 3000 dollars pays 460 dollars; selling 5000 pays 540. What is the base salary?',
 '[{"text": "80 dollars", "feedback": "80 is the extra pay from the extra 2000 in sales — the commission slice, not the base."}, {"text": "400 dollars", "feedback": "Check: a 400 base makes the rate 2 percent on week one but 2.8 on week two. The rate must be the same."}, {"text": "340 dollars", "feedback": "Correct."}, {"text": "460 dollars", "feedback": "That is a full pay cheque, base AND commission together."}]'::jsonb, 2, 'sub-substitution'),
(10, 'MPM2D', 'Linear systems', 1, 39, 'Advanced',
 'Which situation CANNOT be modelled by a system of two linear equations?',
 '[{"text": "Two phone plans with different flat fees and per-minute rates", "feedback": "Cost against minutes is a straight line for each plan — exactly a linear system."}, {"text": "Mixing two chemical solutions of different strengths", "feedback": "Mixture totals and concentration totals are both linear in the two volumes."}, {"text": "The ages of two different people now and in ten years", "feedback": "Ages grow by the same amount each year, which keeps every equation linear."}, {"text": "The area of a square compared with its side length", "feedback": "Correct."}]'::jsonb, 3, 'sub-linear-applications'),
(10, 'MPM2D', 'Linear systems', 1, 40, 'Advanced',
 'Solve: 2x + 7y = 3 and 3x - 2y = 17. What is the solution?',
 '[{"text": "(5, -1)", "feedback": "Correct."}, {"text": "(5, 1)", "feedback": "x = 5 is right. Then 7y = 3 - 10 = -7. Watch the sign when moving the 10."}, {"text": "(3, 17)", "feedback": "Those are the two right-hand sides, not the solution. The equations must be combined."}, {"text": "(-1, 5)", "feedback": "The coordinates are swapped. x was eliminated to first, giving 5."}]'::jsonb, 0, 'sub-elimination');


-- ==========================================================================
-- Unit 2: Analytic geometry
-- ==========================================================================

delete from questions where grade = 10 and unit = 'Analytic geometry';

insert into misconception_labels (tag, label) values
  ('sub-equation-of-circle', 'Equation of a circle'),
  ('sub-geometry-applications', 'Geometric properties of shapes'),
  ('sub-median-bisector-altitude', 'Medians, right bisectors and altitudes'),
  ('sub-midpoint-length', 'Midpoint and length of a line segment')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values
(10, 'MPM2D', 'Analytic geometry', 2, 1, 'Easy',
 'What is the midpoint of the segment from A(2, 3) to B(8, 7)?',
 '[{"text": "(5, 5)", "feedback": "Correct."}, {"text": "(3, 2)", "feedback": "That halves the DIFFERENCE of the endpoints. Both endpoints share in the average: add first, then halve."}, {"text": "(6, 4)", "feedback": "That is the run and the rise from A to B. Subtracting gives a displacement, not a point on the segment."}, {"text": "(10, 10)", "feedback": "The coordinates were added but not divided by 2. A midpoint is an average."}]'::jsonb, 0, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 2, 'Easy',
 'The run of a segment is 3 and the rise is 4. What is its length?',
 '[{"text": "7", "feedback": "3 + 4 adds the legs. The length is the hypotenuse: square, add, then square root."}, {"text": "12", "feedback": "3 times 4 is an area, not a distance. Use the Pythagorean theorem."}, {"text": "25", "feedback": "That is the length SQUARED. Take the square root at the end."}, {"text": "5", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 3, 'Easy',
 'What is the midpoint of the segment from (-1, 2) to (3, -4)?',
 '[{"text": "(1, 1)", "feedback": "Watch the signs in the y average: 2 + (-4) is negative, so halving it cannot leave a positive number."}, {"text": "(2, -2)", "feedback": "The x coordinates average to 1, not 2: -1 + 3 is 2, halved."}, {"text": "(2, -3)", "feedback": "That is half the DIFFERENCE of the endpoints. A midpoint averages them: add, then halve."}, {"text": "(1, -1)", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 4, 'Easy',
 'A median of a triangle joins a vertex to which point?',
 '[{"text": "The closest point on the opposite side", "feedback": "Closest point describes the altitude, which meets the side at a right angle."}, {"text": "The opposite vertex", "feedback": "Vertex to vertex is just a side of the triangle."}, {"text": "The midpoint of an adjacent side", "feedback": "A median crosses the triangle to the side OPPOSITE the vertex."}, {"text": "The midpoint of the opposite side", "feedback": "Correct."}]'::jsonb, 3, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 5, 'Easy',
 'A line has slope 2/3. What is the slope of a line perpendicular to it?',
 '[{"text": "3/2", "feedback": "The reciprocal alone is not enough — perpendicular slopes are NEGATIVE reciprocals."}, {"text": "2/3", "feedback": "Equal slopes make parallel lines, not perpendicular ones."}, {"text": "-2/3", "feedback": "The sign flipped but the fraction did not. Flip the fraction as well."}, {"text": "-3/2", "feedback": "Correct."}]'::jsonb, 3, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 6, 'Easy',
 'What is the equation of a circle centred at the origin with radius 6?',
 '[{"text": "x² + y² = 6", "feedback": "The right side is r SQUARED. The radius itself does not sit there."}, {"text": "x² + y² = 36", "feedback": "Correct."}, {"text": "x + y = 36", "feedback": "Both variables are squared in a circle equation. Without the squares this is a line."}, {"text": "x² + y² = 12", "feedback": "12 is the diameter, and the equation wants the radius squared: 6 times 6."}]'::jsonb, 1, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 7, 'Easy',
 'The circle x² + y² = 25 has what radius?',
 '[{"text": "12.5", "feedback": "The 25 is not halved — it is square rooted."}, {"text": "25", "feedback": "25 is r squared. The radius is its square root."}, {"text": "5", "feedback": "Correct."}, {"text": "10", "feedback": "10 would be the DIAMETER. The equation gives the radius directly, as the root of 25."}]'::jsonb, 2, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 8, 'Easy',
 'Is the point (3, 4) on the circle x² + y² = 25?',
 '[{"text": "Yes, because 3² + 4² = 25", "feedback": "Correct."}, {"text": "No, because 3² + 4² = 7", "feedback": "Check the squares: 3² is 9 and 4² is 16, and squares add, not their roots."}, {"text": "Yes, because 3 and 4 are both less than 25", "feedback": "Being small does not put a point ON a circle. Substitute into the equation."}, {"text": "No, because 3 + 4 is not 25", "feedback": "The coordinates are squared before adding. 9 + 16 makes the call."}]'::jsonb, 0, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 9, 'Easy',
 'An altitude of a triangle meets the opposite side at what angle?',
 '[{"text": "45 degrees", "feedback": "45 is a special case that rarely happens. The definition says perpendicular."}, {"text": "60 degrees", "feedback": "60 belongs to equilateral corners. An altitude is defined by the RIGHT angle it makes."}, {"text": "The same angle as at the vertex", "feedback": "The angle at the foot is fixed at 90, whatever the vertex angle is."}, {"text": "90 degrees", "feedback": "Correct."}]'::jsonb, 3, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 10, 'Easy',
 'Which tool decides whether two segments are parallel?',
 '[{"text": "Check whether they share an endpoint", "feedback": "Sharing a point makes segments MEET — the opposite of parallel."}, {"text": "Compare their slopes", "feedback": "Correct."}, {"text": "Compare their lengths", "feedback": "Equal lengths can point anywhere. Parallel is about direction, which slope measures."}, {"text": "Compare their midpoints", "feedback": "Midpoints locate centres, not directions."}]'::jsonb, 1, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 11, 'Medium',
 'What is the exact length of the segment from (-3, 5) to (7, -1)?',
 '[{"text": "√136", "feedback": "Correct."}, {"text": "√64", "feedback": "The squares of the run and the rise are added under the root, not subtracted."}, {"text": "136", "feedback": "That is the length squared. The square root finishes the job."}, {"text": "16", "feedback": "10 + 6 adds rise and run instead of squaring them. Pythagoras first."}]'::jsonb, 0, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 12, 'Medium',
 'Triangle ABC has A(2, 8), B(-4, 2), C(6, 0). The median from A goes to which point?',
 '[{"text": "(-1, 5)", "feedback": "That is the midpoint of AB. The median from A crosses to the midpoint of BC, the OPPOSITE side."}, {"text": "(4, 4)", "feedback": "That is the midpoint of AC. From A, the opposite side is BC."}, {"text": "(2, 2)", "feedback": "Average the endpoints of BC, x with x and y with y — add, then halve."}, {"text": "(1, 1)", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 13, 'Medium',
 'The median from A(2, 8) to (1, 1) has what slope?',
 '[{"text": "9", "feedback": "The coordinates SUBTRACT: 1 - 8 and 1 - 2, not 1 + 8."}, {"text": "-7", "feedback": "Both differences are negative, and a negative over a negative is positive."}, {"text": "7", "feedback": "Correct."}, {"text": "1/7", "feedback": "That is run over rise. Slope is rise over run: (1 - 8) over (1 - 2)."}]'::jsonb, 2, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 14, 'Medium',
 'The right bisector of the segment from (1, 3) to (7, 5) has what slope?',
 '[{"text": "-1/3", "feedback": "The sign flipped but the fraction did not. Flip the fraction as well: the reciprocal of 1/3 is 3."}, {"text": "3", "feedback": "The reciprocal was taken but the sign was not flipped. Perpendicular slopes are negative reciprocals."}, {"text": "-3", "feedback": "Correct."}, {"text": "1/3", "feedback": "That is the slope of the segment ITSELF. The bisector is perpendicular to it."}]'::jsonb, 2, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 15, 'Medium',
 'A right bisector of a segment must pass through which point?',
 '[{"text": "The vertex of the triangle", "feedback": "A right bisector belongs to a segment and needs no triangle at all."}, {"text": "The midpoint of the segment", "feedback": "Correct."}, {"text": "The origin", "feedback": "Only by coincidence. The defining point is the middle of the segment."}, {"text": "One of the endpoints", "feedback": "Through an endpoint at 90 degrees is a different line. Bisector means it CUTS the segment in half."}]'::jsonb, 1, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 16, 'Medium',
 'What is the equation of the circle centred at the origin passing through (-8, 6)?',
 '[{"text": "x² + y² = -28", "feedback": "Squares cannot be negative. The square of -8 is +64."}, {"text": "x² + y² = 10", "feedback": "10 is the radius. The equation carries the radius SQUARED."}, {"text": "x² + y² = 100", "feedback": "Correct."}, {"text": "x² + y² = 28", "feedback": "The coordinates square to 64 and 36 before adding — they do not add first."}]'::jsonb, 2, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 17, 'Medium',
 'Where is the point (5, -2) relative to the circle x² + y² = 25?',
 '[{"text": "On the circle, because 5² + (-2)² = 25", "feedback": "Check that sum: 25 + 4 is 29, not 25."}, {"text": "On the circle, because x = 5", "feedback": "One coordinate matching the radius means nothing on its own. Substitute BOTH into x² + y²."}, {"text": "Inside, because -2 is small", "feedback": "The y value squares to +4 and still counts. Compare 29 with 25."}, {"text": "Outside, because 25 + 4 is greater than 25", "feedback": "Correct."}]'::jsonb, 3, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 18, 'Medium',
 'Triangle with vertices (0, 0), (4, 0) and (2, 6) is best described as what?',
 '[{"text": "Isosceles, because two sides have equal length", "feedback": "Correct."}, {"text": "Scalene, because the vertices are all different", "feedback": "Different vertices are guaranteed in any triangle. Compare the side LENGTHS."}, {"text": "Right angled at (2, 6)", "feedback": "Check the slopes from (2, 6): 3 and -3 multiply to -9, not -1."}, {"text": "Equilateral, because it looks even", "feedback": "Looks are not a proof. The base is 4 but the other two sides are √40 — only TWO match."}]'::jsonb, 0, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 19, 'Medium',
 'M and N are midpoints of two sides of a triangle. The segment MN compares to the third side how?',
 '[{"text": "Perpendicular to it", "feedback": "A midsegment runs alongside the third side, never across it."}, {"text": "Parallel to it and half its length", "feedback": "Correct."}, {"text": "Parallel to it and equal in length", "feedback": "Equal length would make a parallelogram of the whole triangle. The midsegment is HALF."}, {"text": "Half its length but at a different slope", "feedback": "Same slope is the whole point — the midpoints preserve direction."}]'::jsonb, 1, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 20, 'Medium',
 'To verify the diagonals of a parallelogram bisect each other, what should be compared?',
 '[{"text": "The midpoints of the two opposite sides", "feedback": "The claim is about the diagonals, so their midpoints are what must coincide."}, {"text": "The slopes of each of the two diagonals", "feedback": "Slopes test parallel or perpendicular, not cutting in half."}, {"text": "The lengths of each of the two diagonals", "feedback": "Diagonals of a parallelogram are usually DIFFERENT lengths. Bisecting is about midpoints."}, {"text": "The midpoints of the two diagonals", "feedback": "Correct."}]'::jsonb, 3, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 21, 'Challenge',
 'What is the equation of the right bisector of the segment from (1, 3) to (7, 5)?',
 '[{"text": "y = -3x + 4", "feedback": "The line passes through the MIDPOINT (4, 4): substitute it to find the intercept."}, {"text": "y = -3x + 16", "feedback": "Correct."}, {"text": "y = 3x - 8", "feedback": "The sign of the slope flips as well as the fraction: perpendicular to 1/3 is -3."}, {"text": "y = (1/3)x + 8/3", "feedback": "That slope belongs to the segment itself. The bisector uses the negative reciprocal."}]'::jsonb, 1, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 22, 'Challenge',
 'Triangle has A(1, 7), B(-2, 1), C(6, 5). What is the equation of the altitude from A?',
 '[{"text": "y = -2x + 9", "feedback": "Correct."}, {"text": "y = -2x + 5", "feedback": "The altitude passes through A(1, 7): substituting x = 1 must give 7."}, {"text": "y = 2x + 5", "feedback": "The perpendicular slope keeps the flipped fraction AND the flipped sign: -2, not 2."}, {"text": "y = (1/2)x + 13/2", "feedback": "That line is PARALLEL to BC. An altitude is perpendicular to it."}]'::jsonb, 0, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 23, 'Challenge',
 'How many points do the line y = 7 and the circle x² + y² = 25 share?',
 '[{"text": "None", "feedback": "Correct."}, {"text": "Infinitely many", "feedback": "A line and a circle can share at most two points."}, {"text": "One", "feedback": "One point would need the line to just touch at y = 5 or y = -5."}, {"text": "Two", "feedback": "The circle only reaches heights between -5 and 5. A line at height 7 passes above it."}]'::jsonb, 0, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 24, 'Challenge',
 'Which point lies INSIDE the circle x² + y² = 40?',
 '[{"text": "(5, 4)", "feedback": "5² + 4² is 41, just past 40 — that point is OUTSIDE."}, {"text": "(6, 2)", "feedback": "36 + 4 lands exactly ON the circle, not inside it."}, {"text": "(3, 5)", "feedback": "Correct."}, {"text": "(7, 0)", "feedback": "49 alone already beats 40. Outside."}]'::jsonb, 2, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 25, 'Challenge',
 'Triangle has A(-1, 2), B(3, 4), C(5, 0). Where is its right angle?',
 '[{"text": "It has no right angle", "feedback": "One pair of sides here does meet at a right angle. Test the slopes at each vertex before ruling it out."}, {"text": "At A, because A has a negative coordinate", "feedback": "A negative coordinate says nothing about angles. Multiply slopes of the meeting sides."}, {"text": "At B, because the slopes of AB and BC multiply to -1", "feedback": "Correct."}, {"text": "At C, because C is on the x axis", "feedback": "Sitting on an axis does not create a right angle."}]'::jsonb, 2, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 26, 'Challenge',
 'A triangle has B(1, -6) and C(5, 2). The midsegment parallel to BC has what exact length?',
 '[{"text": "√80", "feedback": "That is BC itself. The midsegment is HALF that length — and halving a length is not the same as halving the number under the root."}, {"text": "6", "feedback": "That adds the rise 8 and the run 4 instead of squaring them, then halves. Use Pythagoras on BC first."}, {"text": "√40", "feedback": "Halving the number under the root does not halve the length. Write half of √80 as one root and simplify it properly."}, {"text": "√20", "feedback": "Correct."}]'::jsonb, 3, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 27, 'Challenge',
 'A line from a vertex meets the opposite side at its midpoint but NOT at 90 degrees. What is it?',
 '[{"text": "A right bisector", "feedback": "A right bisector needs the 90 degrees as well as the midpoint — and it need not pass through a vertex."}, {"text": "A median only", "feedback": "Correct."}, {"text": "An altitude", "feedback": "An altitude is defined by the right angle, which is exactly what this line lacks."}, {"text": "Both a median and an altitude", "feedback": "Both at once only happens in special triangles, and the 90 degrees is missing here."}]'::jsonb, 1, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 28, 'Challenge',
 'The circle x² + y² = 100 passes through (k, 6). What are the possible values of k?',
 '[{"text": "8 and -8", "feedback": "Correct."}, {"text": "64", "feedback": "64 is k SQUARED. The values of k are its roots."}, {"text": "8 only", "feedback": "A square root has two signs — the negative one squares to the same 64."}, {"text": "94", "feedback": "k² is 100 - 36 = 64. The 36 subtracts, and then the root is taken."}]'::jsonb, 0, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 29, 'Challenge',
 'To prove a quadrilateral is a parallelogram using slopes, what must be shown?',
 '[{"text": "All four sides of the quadrilateral have the same slope", "feedback": "All the same slope would flatten the shape onto one line."}, {"text": "The two diagonals of the quadrilateral have equal slopes", "feedback": "Equal-slope diagonals would be parallel and could never cross inside the shape."}, {"text": "Both pairs of opposite sides have equal slopes", "feedback": "Correct."}, {"text": "Only one pair of opposite sides has equal slopes", "feedback": "One pair only makes a trapezoid. A parallelogram needs both."}]'::jsonb, 2, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 30, 'Challenge',
 'The shortest distance from a point to a line is measured along which path?',
 '[{"text": "The perpendicular from the point to the line", "feedback": "Correct."}, {"text": "The segment to the nearest endpoint of the line", "feedback": "A line has no endpoints. The shortest route always meets it at 90 degrees."}, {"text": "A segment parallel to the line", "feedback": "A parallel path never reaches the line at all."}, {"text": "The segment to the y-intercept of the line", "feedback": "The y-intercept is just one point on the line, rarely the closest one."}]'::jsonb, 0, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 31, 'Advanced',
 'Triangle has A(0, 0), B(4, 4), C(8, 0). Which description fits it completely?',
 '[{"text": "Right angled AND isosceles", "feedback": "Correct."}, {"text": "Equilateral, with all three sides equal", "feedback": "AC is 8 but the other two sides are √32. Not all three match."}, {"text": "Right angled but not isosceles", "feedback": "AB² and BC² are both 32 — two equal sides make it isosceles as well."}, {"text": "Isosceles but not right angled", "feedback": "32 + 32 equals 64, which is AC². Pythagoras confirms a right angle at B too."}]'::jsonb, 0, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 32, 'Advanced',
 'The right bisectors of the three sides of a triangle all cross at one point. What is special about it?',
 '[{"text": "It is the midpoint of the longest side of the triangle", "feedback": "That only happens for right triangles, and only for the hypotenuse."}, {"text": "It is the same distance from each of the three sides", "feedback": "Equal distance from the SIDES belongs to the angle bisectors, a different centre."}, {"text": "It is the same distance from all three vertices", "feedback": "Correct."}, {"text": "It always lies inside the triangle, never outside it", "feedback": "For an obtuse triangle it falls outside. The equal-distance property is what always holds."}]'::jsonb, 2, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 33, 'Advanced',
 'Which point on the y-axis is the same distance from (2, 3) and (6, 1)?',
 '[{"text": "(0, 6)", "feedback": "Check the sign at the end: -24 = 4y gives a NEGATIVE y."}, {"text": "(4, 2)", "feedback": "That is the midpoint of the two points — it is equidistant but not on the y-axis."}, {"text": "(0, -6)", "feedback": "Correct."}, {"text": "(0, 2)", "feedback": "Substitute back: the distances to the two points are √5 and √37 — not equal. Set the squared distances equal and solve."}]'::jsonb, 2, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 34, 'Advanced',
 'Where does the line y = x + 2 meet the circle x² + y² = 10?',
 '[{"text": "(3, 1) and (-1, -3)", "feedback": "The coordinates are swapped: for each x, y is x + 2, so x = 1 gives y = 3."}, {"text": "(2, 4) and (-2, 0)", "feedback": "Substitute back: 4 + 16 is 20, not 10. Substitute y = x + 2 INTO the circle and solve the quadratic."}, {"text": "(1, 3) and (-3, -1)", "feedback": "Correct."}, {"text": "(1, 3) only", "feedback": "A line through the inside of a circle crosses it TWICE — the quadratic after substituting has two roots."}]'::jsonb, 2, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 35, 'Advanced',
 'In the triangle with A(2, 8), B(-4, 2), C(6, 0), what is the exact length of the median from A?',
 '[{"text": "√98", "feedback": "That uses the rise in place of both differences. The run from A to the midpoint is not the same as the rise."}, {"text": "√50", "feedback": "Correct."}, {"text": "50", "feedback": "50 is the squared length. Keep the square root."}, {"text": "√8", "feedback": "Both differences count: run 1 and rise 7 give 1 + 49 under the root."}]'::jsonb, 1, 'sub-midpoint-length'),
(10, 'MPM2D', 'Analytic geometry', 2, 36, 'Advanced',
 'M(0, 0) and N(4, 2) are midpoints of two sides of a triangle whose third side is BC. What is the slope of BC?',
 '[{"text": "2", "feedback": "That is run over rise of MN. Slope is rise over run — and BC copies the slope of MN exactly."}, {"text": "1/2", "feedback": "Correct."}, {"text": "1/4", "feedback": "The midsegment is parallel to BC, so BC takes the SAME slope as MN, not half of it."}, {"text": "1", "feedback": "BC is twice as long as MN, but not twice as steep. A midsegment is parallel to the third side."}]'::jsonb, 1, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 37, 'Advanced',
 'The altitude from A(1, 7) of a triangle is y = -2x + 9. Which point lies on BOTH this altitude and the side BC, where BC is y = (1/2)x + 2?',
 '[{"text": "(2.8, 3.4)", "feedback": "Correct."}, {"text": "(2, 5)", "feedback": "That point is on the altitude only. Substitute into BOTH equations; BC gives 3, not 5."}, {"text": "(3.5, 3.75)", "feedback": "Set -2x + 9 equal to (1/2)x + 2 and collect the x terms carefully — they add to 2.5x, not 2x."}, {"text": "(1, 7)", "feedback": "That is vertex A. The foot of the altitude sits on BC, further down the line."}]'::jsonb, 0, 'sub-median-bisector-altitude'),
(10, 'MPM2D', 'Analytic geometry', 2, 38, 'Advanced',
 'A circle centred at the origin has the segment from (-3, 4) to (3, -4) as a diameter. What is its equation?',
 '[{"text": "x² + y² = 5", "feedback": "5 is the radius itself. Square it for the right side."}, {"text": "x² + y² = 100", "feedback": "100 is the DIAMETER squared. The equation uses the radius: half the diameter, then squared."}, {"text": "x² + y² = 50", "feedback": "That squares the diameter first and halves afterwards. The halving comes before the squaring."}, {"text": "x² + y² = 25", "feedback": "Correct."}]'::jsonb, 3, 'sub-equation-of-circle'),
(10, 'MPM2D', 'Analytic geometry', 2, 39, 'Advanced',
 'Quadrilateral PQRS has P(-2, 1), Q(3, 3), R(4, -1), S(-1, -3). The midpoints of both diagonals are the same point. What does that prove?',
 '[{"text": "PQRS is a rectangle", "feedback": "A rectangle needs right angles as well. Shared diagonal midpoints alone give a parallelogram."}, {"text": "PQRS is a parallelogram", "feedback": "Correct."}, {"text": "PQRS is a rhombus", "feedback": "A rhombus needs equal SIDES on top of the parallelogram property."}, {"text": "Nothing — every quadrilateral does this", "feedback": "Most quadrilaterals do not. Diagonals bisecting each other is exactly the parallelogram test."}]'::jsonb, 1, 'sub-geometry-applications'),
(10, 'MPM2D', 'Analytic geometry', 2, 40, 'Advanced',
 'Of the vertices A(2, 8), B(-4, 2), C(6, 0), which is closest to the origin?',
 '[{"text": "C, at distance 6", "feedback": "C is 6 from the origin, but another vertex is nearer. Work out each distance before choosing."}, {"text": "B, at distance √20", "feedback": "Correct."}, {"text": "B, at distance 2", "feedback": "That takes the coordinate nearer zero as the distance and ignores the -4."}, {"text": "A, because 2 is the smallest coordinate", "feedback": "One small coordinate is not distance. A is √68 away, the farthest of the three."}]'::jsonb, 1, 'sub-midpoint-length');


-- ==========================================================================
-- Unit 3: Factoring
-- ==========================================================================

delete from questions where grade = 10 and unit = 'Factoring';

insert into misconception_labels (tag, label) values
  ('sub-common-factoring', 'Common factoring'),
  ('sub-factoring-complex-trinomials', 'Factoring ax² + bx + c'),
  ('sub-factoring-simple-trinomials', 'Factoring x² + bx + c'),
  ('sub-multiplying-binomials', 'Multiplying binomials'),
  ('sub-special-products', 'Special products')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values
(10, 'MPM2D', 'Factoring', 3, 1, 'Easy',
 'Expand: (x + 3)(x + 2)',
 '[{"text": "x² + 5", "feedback": "The outer and inner products make a middle term. FOIL has four products, not two."}, {"text": "x² + 5x + 6", "feedback": "Correct."}, {"text": "x² + 6x + 5", "feedback": "The middle term is the SUM 3 + 2 and the last is the PRODUCT 3 times 2. They are swapped here."}, {"text": "x² + 6x + 6", "feedback": "The x terms add to 5x: 3x from the inner and 2x from the outer."}]'::jsonb, 1, 'sub-multiplying-binomials'),
(10, 'MPM2D', 'Factoring', 3, 2, 'Easy',
 'Expand: (x - 4)(x + 1)',
 '[{"text": "x² - 4x - 4", "feedback": "The middle term collects BOTH cross products: -4x plus 1x."}, {"text": "x² - 3x + 4", "feedback": "The last term is -4 times +1, and a negative times a positive stays negative."}, {"text": "x² - 3x - 4", "feedback": "Correct."}, {"text": "x² + 3x - 4", "feedback": "The -4 outweighs the +1: the middle term is -4x + x, which is negative."}]'::jsonb, 2, 'sub-multiplying-binomials'),
(10, 'MPM2D', 'Factoring', 3, 3, 'Easy',
 'Simplify: (3x)(4x)',
 '[{"text": "12x²", "feedback": "Correct."}, {"text": "12x", "feedback": "The variables multiply too: x times x is x squared."}, {"text": "7x", "feedback": "Both the coefficients and the variables were added instead of multiplied."}, {"text": "7x²", "feedback": "The coefficients MULTIPLY: 3 times 4. Adding them belongs to 3x + 4x."}]'::jsonb, 0, 'sub-multiplying-binomials'),
(10, 'MPM2D', 'Factoring', 3, 4, 'Easy',
 'What is the greatest common factor of 12x³ and 18x²?',
 '[{"text": "2x", "feedback": "2 divides both but is not the GREATEST number that does. 6 is."}, {"text": "6x³", "feedback": "The variable part takes the LOWEST power the terms share. 12x³ has x³ but 18x² does not."}, {"text": "36x²", "feedback": "36 is a common MULTIPLE of 12 and 18. The greatest common factor of them is 6."}, {"text": "6x²", "feedback": "Correct."}]'::jsonb, 3, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 5, 'Easy',
 'Factor: 5x + 20',
 '[{"text": "x(5 + 20)", "feedback": "x is not a factor of the plain number 20. Only the 5 is common to both terms."}, {"text": "5(x + 15)", "feedback": "That takes 5 away from the 20 instead of dividing it by the common factor."}, {"text": "5(x + 4)", "feedback": "Correct."}, {"text": "5(x + 20)", "feedback": "After removing the 5, the 20 divides by it too: 20 over 5 is 4."}]'::jsonb, 2, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 6, 'Easy',
 'Factor completely: 8x² - 6x',
 '[{"text": "2(4x² - 3x)", "feedback": "An x is still common inside the brackets. The greatest common factor includes it."}, {"text": "2x(4x - 6)", "feedback": "The 6x divides by the FULL common factor 2x, leaving 3, not 6."}, {"text": "x(8x - 6)", "feedback": "The 2 is still common inside. Take out the greatest common factor, 2x, in one step."}, {"text": "2x(4x - 3)", "feedback": "Correct."}]'::jsonb, 3, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 7, 'Easy',
 'To factor x² + 7x + 12, what two numbers are needed?',
 '[{"text": "Numbers that add to 12 and multiply to give 7", "feedback": "The roles are swapped: the middle coefficient is the SUM, the constant is the PRODUCT."}, {"text": "Numbers that add to 7 and multiply to 12", "feedback": "Correct."}, {"text": "Numbers that subtract to 7 and divide to 12", "feedback": "The pattern from expanding (x + m)(x + n) is add and multiply."}, {"text": "Numbers that both divide 7 without a remainder", "feedback": "7 is prime — this rule would find nothing. The pair works with 7 and 12 together."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 8, 'Easy',
 'Factor: x² + 7x + 12',
 '[{"text": "(x + 7)(x + 12)", "feedback": "Those are the coefficients themselves. Expanding gives x² + 19x + 84 — much too big."}, {"text": "(x + 1)(x + 12)", "feedback": "1 and 12 add to 13, not 7. Try the factor pairs of 12 until one sums to 7."}, {"text": "(x + 3)(x + 4)", "feedback": "Correct."}, {"text": "(x + 6)(x + 2)", "feedback": "6 and 2 multiply to 12 but add to 8. Both conditions must hold at once."}]'::jsonb, 2, 'sub-factoring-simple-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 9, 'Easy',
 'Which expression is a difference of squares?',
 '[{"text": "x² + 49", "feedback": "A SUM of squares does not factor over the integers. The pattern needs a subtraction."}, {"text": "x³ - 49", "feedback": "The powers must be squares too — x³ is not one."}, {"text": "x² - 49", "feedback": "Correct."}, {"text": "x² - 48", "feedback": "48 is not a perfect square. Both terms must be squares."}]'::jsonb, 2, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 10, 'Easy',
 'Factor: x² - 49',
 '[{"text": "(x - 7)(x + 7)", "feedback": "Correct."}, {"text": "(x - 7)(x - 7)", "feedback": "Both signs negative gives +49 at the end, not -49. The signs must differ."}, {"text": "(x + 7)(x + 7)", "feedback": "Two positive signs give +49 at the end and a middle term of +14x. A difference of squares has NO middle term."}, {"text": "(x - 49)(x + 1)", "feedback": "Those multiply to x² - 48x - 49. Take the square root of each term instead: x and 7."}]'::jsonb, 0, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 11, 'Medium',
 'Expand and simplify: (2x + 3)(x - 5)',
 '[{"text": "2x² - 7x - 15", "feedback": "Correct."}, {"text": "2x² - 10x - 15", "feedback": "The inner product 3x is missing. All four FOIL products count."}, {"text": "2x² + 7x - 15", "feedback": "The outer product -10x outweighs the inner +3x. The middle term is negative."}, {"text": "2x² - 7x + 15", "feedback": "+3 times -5 is -15. A positive times a negative stays negative."}]'::jsonb, 0, 'sub-multiplying-binomials'),
(10, 'MPM2D', 'Factoring', 3, 12, 'Medium',
 'Expand: (x + 4)²',
 '[{"text": "x² + 16", "feedback": "Squaring a binomial produces a middle term: 2 times x times 4. The square does not distribute onto each term."}, {"text": "x² + 8x + 8", "feedback": "The last term is 4 squared, which is 16."}, {"text": "x² + 4x + 16", "feedback": "The middle term is TWICE the product of x and 4."}, {"text": "x² + 8x + 16", "feedback": "Correct."}]'::jsonb, 3, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 13, 'Medium',
 'Factor completely: 21x³y² - 28x²y⁴ + 7x²y²',
 '[{"text": "7x²y²(3x - 4y²)", "feedback": "Removing the factor from the LAST term leaves 1, which must stay in the brackets — three terms in, three out."}, {"text": "7x²y²(3x - 4y² + 1)", "feedback": "Correct."}, {"text": "7x²y²(3x + 4y² + 1)", "feedback": "The common factor comes out positive, so the sign in front of each term is unchanged. The middle term is still subtracted."}, {"text": "7xy(3x²y - 4xy³ + xy)", "feedback": "A bigger factor is available: every term carries x² and y², not just x and y."}]'::jsonb, 1, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 14, 'Medium',
 'Factor: x² - 2x - 15',
 '[{"text": "(x + 5)(x - 3)", "feedback": "Those add to +2, not -2. The LARGER number takes the negative sign here."}, {"text": "(x - 5)(x - 3)", "feedback": "Two negatives multiply to +15, but the constant is -15. The signs must differ."}, {"text": "(x - 15)(x + 1)", "feedback": "-15 and 1 multiply correctly but add to -14. Both conditions must hold."}, {"text": "(x - 5)(x + 3)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-simple-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 15, 'Medium',
 'Factor: x² - 10x + 24',
 '[{"text": "(x - 4)(x - 6)", "feedback": "Correct."}, {"text": "(x - 12)(x + 2)", "feedback": "-12 and 2 multiply to -24, not +24. The constant is positive."}, {"text": "(x + 4)(x + 6)", "feedback": "A positive product with a NEGATIVE sum needs two negative numbers."}, {"text": "(x - 8)(x - 3)", "feedback": "-8 times -3 is 24, but they add to -11, not -10. Keep testing pairs until the sum matches too."}]'::jsonb, 0, 'sub-factoring-simple-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 16, 'Medium',
 'To factor 3x² + 10x + 8 by decomposition, the middle term splits using two numbers with what properties?',
 '[{"text": "Sum 10 and product 24", "feedback": "Correct."}, {"text": "Sum 13 and product 24", "feedback": "The 3 does not join the sum. It only enters through the product a times c."}, {"text": "Sum 8 and product 30", "feedback": "The sum matches the MIDDLE coefficient, 10. The product uses 3 times 8."}, {"text": "Sum 10 and product 8", "feedback": "The product target is a times c — 3 times 8 — once the leading coefficient is not 1."}]'::jsonb, 0, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 17, 'Medium',
 'Factor: 3x² + 10x + 8',
 '[{"text": "(x + 4)(x + 6)", "feedback": "The leading term must be 3x², so one factor carries the 3x."}, {"text": "(3x + 4)(x + 2)", "feedback": "Correct."}, {"text": "(3x + 2)(x + 4)", "feedback": "Check the middle term: 12x + 2x gives 14x, not 10x. Expand to verify."}, {"text": "(3x + 8)(x + 1)", "feedback": "That expands to a middle term of 11x. The split 6x + 4x is the one that groups."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 18, 'Medium',
 'Factor: 2x² - 7x + 6',
 '[{"text": "(2x - 6)(x - 1)", "feedback": "A common factor of 2 hides in (2x - 6) that the original does not have. Expand and compare."}, {"text": "(2x - 1)(x - 6)", "feedback": "That gives a middle term of -13x. The split of -7x is -3x and -4x."}, {"text": "(2x - 3)(x - 2)", "feedback": "Correct."}, {"text": "(2x + 3)(x + 2)", "feedback": "A positive constant with a NEGATIVE middle term needs both signs negative."}]'::jsonb, 2, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 19, 'Medium',
 'Factor: 9x² - 25',
 '[{"text": "(3x - 25)(3x + 1)", "feedback": "A difference of squares splits into root minus root and root plus root: 3x and 5."}, {"text": "(3x - 5)(3x + 5)", "feedback": "Correct."}, {"text": "(9x - 25)(9x + 25)", "feedback": "The square roots of the terms go in the brackets: √(9x²) is 3x, not 9x."}, {"text": "(3x - 5)²", "feedback": "A square produces a middle term -30x. This expression has no middle term."}]'::jsonb, 1, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 20, 'Medium',
 'Factor: x² + 12x + 36',
 '[{"text": "(x + 6)(x - 6)", "feedback": "That is the pattern for x² MINUS 36. Here the middle term +12x signals a perfect square."}, {"text": "(x + 4)(x + 9)", "feedback": "4 and 9 multiply to 36 but add to 13, not 12, so this pair misses the middle term."}, {"text": "(x + 6)²", "feedback": "Correct."}, {"text": "(x + 12)(x + 3)", "feedback": "Check the product: 12 times 3 is 36, but the sum is 15, not 12."}]'::jsonb, 2, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 21, 'Challenge',
 'Simplify: 2(6m² - mn + 4) - (7m² + 4mn - 2)',
 '[{"text": "5m² - 6mn + 10", "feedback": "Correct."}, {"text": "5m² + 2mn + 10", "feedback": "The subtraction flips EVERY sign in the second bracket, including +4mn to -4mn."}, {"text": "5m² - 5mn + 6", "feedback": "The 2 multiplies every term inside the first bracket, not just the 6m²."}, {"text": "12m² - 6mn + 10", "feedback": "The 7m² is subtracted as well; the m² terms do not pass through untouched."}]'::jsonb, 0, 'sub-multiplying-binomials'),
(10, 'MPM2D', 'Factoring', 3, 22, 'Challenge',
 'Factor completely: 6x² + 14x + 4',
 '[{"text": "(6x + 2)(x + 2)", "feedback": "The middle term is right, but this is not finished: a whole number still divides through one of the brackets. Look for a common factor before splitting the trinomial."}, {"text": "2(3x + 2)(x + 1)", "feedback": "Expand the brackets: the middle term becomes 5x, and doubled that is 10x, not 14x."}, {"text": "(3x + 1)(2x + 4)", "feedback": "The x-terms are right, but a whole number still divides one of these brackets. Completely factored means nothing is left that can be taken out."}, {"text": "2(3x + 1)(x + 2)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 23, 'Challenge',
 'Factor: 6x² + 13x - 5',
 '[{"text": "(3x - 5)(2x + 1)", "feedback": "Check: 3x - 10x gives -7x, not 13x. Try grouping 6x² + 15x - 2x - 5."}, {"text": "(3x + 1)(2x - 5)", "feedback": "Expand: the middle term comes out as -13x. The signs are on the wrong factors."}, {"text": "(6x - 1)(x + 5)", "feedback": "That gives a middle term of 29x. The split of 13x is 15x - 2x."}, {"text": "(3x - 1)(2x + 5)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 24, 'Challenge',
 'Factor: 4x² - 5xy - 6y²',
 '[{"text": "(4x + 6y)(x - y)", "feedback": "6y and -y do give -6y², but the outer and inner products then add to +2xy, and a factor of 2 is trapped in the first bracket."}, {"text": "(4x + 3y)(x - 2y)", "feedback": "Correct."}, {"text": "(4x - 6y)(x + y)", "feedback": "A common factor of 2 is trapped in the first bracket, and the product of the outside terms is wrong."}, {"text": "(4x - 3y)(x + 2y)", "feedback": "The middle term expands to +5xy with these signs. Flip them."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 25, 'Challenge',
 'Factor completely: 16x² + 26x - 12',
 '[{"text": "2(8x - 3)(x + 2)", "feedback": "Correct."}, {"text": "2(4x - 1)(2x + 6)", "feedback": "Another 2 still hides in (2x + 6), and the middle term does not check out."}, {"text": "2(8x + 3)(x - 2)", "feedback": "Expand: the middle term becomes -13x, doubled -26x. The signs are reversed."}, {"text": "(8x - 3)(2x + 4)", "feedback": "The common factor 2 belongs OUT FRONT, not inside (2x + 4)."}]'::jsonb, 0, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 26, 'Challenge',
 'Factor completely: 3x³ - 27x',
 '[{"text": "3x(x - 3)(x + 3)", "feedback": "Correct."}, {"text": "3x(x² - 9)", "feedback": "x² - 9 is a difference of squares and factors further. Completely means all the way."}, {"text": "3x(x - 3)²", "feedback": "(x - 3)² expands with a middle term -6x. The bracket x² - 9 needs (x - 3)(x + 3)."}, {"text": "3(x³ - 9x)", "feedback": "An x is still common inside. Remove 3x, then factor what remains."}]'::jsonb, 0, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 27, 'Challenge',
 'Factor: 25x² - 30x + 9',
 '[{"text": "(5x - 3)(5x + 3)", "feedback": "That pattern is for 25x² - 9 with NO middle term. Here -30x is exactly twice 5x times 3."}, {"text": "(5x - 3)²", "feedback": "Correct."}, {"text": "(25x - 9)(x - 1)", "feedback": "Perfect square trinomials factor from the roots of the outer terms: 5x and 3."}, {"text": "(5x + 3)²", "feedback": "The middle term of that square is +30x. The -30x needs the negative version."}]'::jsonb, 1, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 28, 'Challenge',
 'Expand: (3x - 2y)²',
 '[{"text": "9x² - 6xy + 4y²", "feedback": "The middle term DOUBLES the product of 3x and 2y: 12xy, not 6xy."}, {"text": "9x² - 12xy - 4y²", "feedback": "The last term is (-2y) squared, and a square is positive."}, {"text": "9x² + 12xy + 4y²", "feedback": "The middle term keeps the minus: 2 times 3x times -2y is negative."}, {"text": "9x² - 12xy + 4y²", "feedback": "Correct."}]'::jsonb, 3, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 29, 'Challenge',
 'Which trinomial does NOT factor over the integers?',
 '[{"text": "x² + 5x + 3", "feedback": "Correct."}, {"text": "x² - 5x + 6", "feedback": "-2 and -3 sum to -5 and multiply to 6, so this trinomial does factor."}, {"text": "x² + 4x + 3", "feedback": "1 and 3 do the job there."}, {"text": "x² + 5x + 4", "feedback": "1 and 4 add to 5 and multiply to 4 — it factors as (x + 1)(x + 4)."}]'::jsonb, 0, 'sub-factoring-simple-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 30, 'Challenge',
 'A rectangle has area x² + 9x + 20. Which dimensions fit?',
 '[{"text": "(x + 2) by (x + 10)", "feedback": "2 and 10 multiply to 20 but add to 12, not 9."}, {"text": "(x + 4) by (x + 5)", "feedback": "Correct."}, {"text": "(x + 4) by (x - 5)", "feedback": "A negative factor would make the last term -20. The area ends in +20."}, {"text": "(x + 9) by (x + 20)", "feedback": "Multiplying those gives x² + 29x + 180 — far too big. Factor the area instead."}]'::jsonb, 1, 'sub-factoring-simple-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 31, 'Advanced',
 'Factor completely: x⁴ - 16',
 '[{"text": "(x - 2)²(x + 2)²", "feedback": "That expands to (x² - 4)², which is x⁴ - 8x² + 16 — a middle term this expression does not have."}, {"text": "(x² - 8)(x² + 2)", "feedback": "The square roots of x⁴ and 16 are x² and 4. Start from (x² - 4)(x² + 4)."}, {"text": "(x² + 4)(x - 2)(x + 2)", "feedback": "Correct."}, {"text": "(x² - 4)(x² + 4)", "feedback": "x² - 4 is itself a difference of squares and splits again. Completely means twice here."}]'::jsonb, 2, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 32, 'Advanced',
 'Factor by grouping: x³ + 3x² + 2x + 6',
 '[{"text": "(x² + 3)(x + 2)", "feedback": "Expand it: the middle terms come out as 2x² + 3x, which is not what the polynomial shows."}, {"text": "(x² + 2)(x + 3)", "feedback": "Correct."}, {"text": "(x + 1)(x + 2)(x + 3)", "feedback": "Expanding that gives x³ + 6x² + 11x + 6. The x² coefficient here is 3."}, {"text": "(x² + 2x)(x + 3)", "feedback": "x² + 2x still holds a common x. The first group contributes x² only, the second the 2."}]'::jsonb, 1, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 33, 'Advanced',
 'For which value of k does x² + kx + 36 become a perfect square trinomial?',
 '[{"text": "36", "feedback": "The middle coefficient is twice the root of 36, not 36 itself."}, {"text": "12 or -12", "feedback": "Correct."}, {"text": "12 only", "feedback": "(x - 6)² works too. The middle term can carry either sign."}, {"text": "6 or -6", "feedback": "Twice the product of x and 6 is 12x. The 2 in 2ab is easy to drop."}]'::jsonb, 1, 'sub-factoring-simple-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 34, 'Advanced',
 'Simplify: (x + 5)(x - 5) - (x - 3)²',
 '[{"text": "6x - 16", "feedback": "The subtraction flips ALL of (x² - 6x + 9), turning +9 into -9: -25 - 9 is -34."}, {"text": "-34", "feedback": "The -(-6x) survives as +6x. Only the x² terms cancel."}, {"text": "2x² + 6x - 34", "feedback": "The x² from the first product and the x² from the square cancel each other."}, {"text": "6x - 34", "feedback": "Correct."}]'::jsonb, 3, 'sub-multiplying-binomials'),
(10, 'MPM2D', 'Factoring', 3, 35, 'Advanced',
 'Factor completely: 2x⁴ - 32',
 '[{"text": "2(x² - 4)(x² + 4)", "feedback": "One more step remains: x² - 4 splits into (x - 2)(x + 2)."}, {"text": "(2x² - 8)(x² + 4)", "feedback": "A 2 is trapped inside the first bracket. Common factor out front first."}, {"text": "2(x² + 4)(x - 2)(x + 2)", "feedback": "Correct."}, {"text": "2(x⁴ - 16)", "feedback": "x⁴ - 16 keeps factoring: it is a difference of squares twice over."}]'::jsonb, 2, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 36, 'Advanced',
 'The area of a square is 4x² + 12x + 9. What is its side length?',
 '[{"text": "2x² + 3", "feedback": "Rooting 4x² halves the EXPONENT: it gives 2x, not 2x²."}, {"text": "4x + 9", "feedback": "The side is the square ROOT of the area, and the root of 4x² is 2x."}, {"text": "2x + 9", "feedback": "The last term of the side is the root of 9, which is 3. Check: the middle term 12x is 2 times 2x times 3."}, {"text": "2x + 3", "feedback": "Correct."}]'::jsonb, 3, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 37, 'Advanced',
 'Factor completely: 12x² - 27',
 '[{"text": "3(2x - 3)²", "feedback": "That square has a middle term -36x when expanded times 3. No middle term exists here."}, {"text": "(6x - 9)(2x + 3)", "feedback": "A common factor of 3 is trapped in the first bracket. Take out the 3 before the squares pattern."}, {"text": "3(2x - 3)(2x + 3)", "feedback": "Correct."}, {"text": "3(4x² - 9)", "feedback": "4x² - 9 is a difference of squares and splits further."}]'::jsonb, 2, 'sub-common-factoring'),
(10, 'MPM2D', 'Factoring', 3, 38, 'Advanced',
 'Which product expands to 6x² - 7x - 20?',
 '[{"text": "(3x + 4)(2x - 5)", "feedback": "Correct."}, {"text": "(6x + 5)(x - 4)", "feedback": "That expands to a middle term of -19x. Split -7x as -15x + 8x and group."}, {"text": "(3x - 5)(2x + 4)", "feedback": "A common factor of 2 hides in (2x + 4), and 6x² - 7x - 20 has none."}, {"text": "(3x - 4)(2x + 5)", "feedback": "The middle term of that one is +7x. The signs sit on the wrong brackets."}]'::jsonb, 0, 'sub-factoring-complex-trinomials'),
(10, 'MPM2D', 'Factoring', 3, 39, 'Advanced',
 'x² - y² = 40 and x - y = 4. What is x + y?',
 '[{"text": "4", "feedback": "4 is x - y, which the question gave. The other bracket is what it asks for."}, {"text": "160", "feedback": "That multiplies the two givens. The factored form says 40 is already a PRODUCT of the two brackets."}, {"text": "10", "feedback": "Correct."}, {"text": "36", "feedback": "x² - y² FACTORS as (x - y)(x + y) — nothing subtracts from the 40."}]'::jsonb, 2, 'sub-special-products'),
(10, 'MPM2D', 'Factoring', 3, 40, 'Advanced',
 'Factor completely: x² y - 4y + x²z - 4z',
 '[{"text": "(x² + 4)(y - z)", "feedback": "Group as y(x² - 4) + z(x² - 4): the shared bracket is x² MINUS 4, and (y + z) collects."}, {"text": "x²(y + z) - 4(y + z)", "feedback": "That is the grouping STEP, not the factored result. Pull out the common bracket."}, {"text": "(x² - 4)(y + z)", "feedback": "x² - 4 keeps factoring — the difference of squares is still whole."}, {"text": "(x - 2)(x + 2)(y + z)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factoring-complex-trinomials');


-- ==========================================================================
-- Unit 4: Quadratics
-- ==========================================================================

delete from questions where grade = 10 and unit = 'Quadratics';

insert into misconception_labels (tag, label) values
  ('sub-completing-the-square', 'Completing the square'),
  ('sub-factored-form', 'Factored form'),
  ('sub-properties-of-quadratics', 'Properties of quadratics'),
  ('sub-vertex-form', 'Vertex form')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values
(10, 'MPM2D', 'Quadratics', 4, 1, 'Easy',
 'A table of values has constant SECOND differences but changing first differences. The relationship is what?',
 '[{"text": "Exponential", "feedback": "Exponential patterns multiply by a constant ratio instead."}, {"text": "Linear", "feedback": "Linear relationships have constant FIRST differences."}, {"text": "Neither linear nor quadratic", "feedback": "Constant second differences DO identify one of these families. Compare with how linear tables behave."}, {"text": "Quadratic", "feedback": "Correct."}]'::jsonb, 3, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 2, 'Easy',
 'For y = -3x² + 5x - 1, which way does the parabola open?',
 '[{"text": "Up, because b is positive", "feedback": "b shifts the parabola sideways — it never decides the direction."}, {"text": "Down, because the equation has three terms", "feedback": "The number of terms is irrelevant. Only the sign of a decides."}, {"text": "Down, because a is negative", "feedback": "Correct."}, {"text": "Up, because c is negative", "feedback": "The constant c places the y-intercept. The DIRECTION comes from a."}]'::jsonb, 2, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 3, 'Easy',
 'What is the vertex of y = (x - 3)² + 5?',
 '[{"text": "(3, 5)", "feedback": "Correct."}, {"text": "(3, -5)", "feedback": "k sits outside the bracket with its own sign, +5 here."}, {"text": "(-3, 5)", "feedback": "The form is (x - h): the bracket (x - 3) means h is +3. The sign inside flips."}, {"text": "(-3, -5)", "feedback": "Both signs are off: h comes from reversing the bracket, k reads directly."}]'::jsonb, 0, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 4, 'Easy',
 'What is the vertex of y = (x + 2)² - 7?',
 '[{"text": "(-2, -7)", "feedback": "Correct."}, {"text": "(2, -7)", "feedback": "(x + 2) is (x - (-2)), so h is NEGATIVE 2. The inside sign always flips."}, {"text": "(2, 7)", "feedback": "Both parts misread: the bracket flips its sign, the tail keeps its own."}, {"text": "(-2, 7)", "feedback": "The k value keeps its own sign: -7."}]'::jsonb, 0, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 5, 'Easy',
 'In y = a(x - h)² + k, what does the k control?',
 '[{"text": "The width of the parabola", "feedback": "Width and stretch belong to a."}, {"text": "The vertical shift, up or down", "feedback": "Correct."}, {"text": "The direction of opening", "feedback": "Opening up or down is the sign of a."}, {"text": "The horizontal shift", "feedback": "Left and right belongs to h, inside the bracket."}]'::jsonb, 1, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 6, 'Easy',
 'Compared with y = x², the graph of y = 3x² is what?',
 '[{"text": "Shifted up by 3", "feedback": "Adding 3 OUTSIDE the square shifts up. Multiplying stretches."}, {"text": "Narrower, stretched vertically", "feedback": "Correct."}, {"text": "Wider", "feedback": "a values BIGGER than 1 stretch the parabola upward, pulling it narrower. Wider comes from a between 0 and 1."}, {"text": "Shifted right by 3", "feedback": "Sideways shifts live inside the bracket with x."}]'::jsonb, 1, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 7, 'Easy',
 'What number completes the square for x² + 8x?',
 '[{"text": "4", "feedback": "4 is half of 8 — the number still needs to be squared."}, {"text": "64", "feedback": "Halve the 8 FIRST, then square what you get. Squaring the whole 8 skips the halving step."}, {"text": "8", "feedback": "The rule is half the x coefficient, squared. Not the coefficient itself."}, {"text": "16", "feedback": "Correct."}]'::jsonb, 3, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 8, 'Easy',
 'What are the x-intercepts of y = (x - 2)(x + 5)?',
 '[{"text": "-2 and -5", "feedback": "The first factor zeroes at +2. Set each bracket to zero and solve."}, {"text": "2 and 5", "feedback": "The second factor (x + 5) zeroes at x = -5, not +5."}, {"text": "-2 and 5", "feedback": "Each factor equals zero when x CANCELS it: x - 2 = 0 gives +2. The signs flip."}, {"text": "2 and -5", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 9, 'Easy',
 'The x-intercepts of a parabola are 1 and 7. What is the axis of symmetry?',
 '[{"text": "x = 3", "feedback": "That halves the distance between the intercepts."}, {"text": "x = 6", "feedback": "6 is the distance between them, not their middle."}, {"text": "x = 8", "feedback": "The axis is the AVERAGE of the intercepts, not their sum. Divide by 2."}, {"text": "x = 4", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 10, 'Easy',
 'What is the y-intercept of y = 2x² - 3x + 7?',
 '[{"text": "-3", "feedback": "-3 is the coefficient of x. The y-intercept is the value when x = 0, which leaves only the constant."}, {"text": "2", "feedback": "2 is the stretch factor a. Set x = 0 to find where the graph meets the y-axis."}, {"text": "7", "feedback": "Correct."}, {"text": "0", "feedback": "Substituting x = 0 does not wipe out the constant term. Only parabolas through the origin have a y-intercept of 0."}]'::jsonb, 2, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 11, 'Medium',
 'Describe the transformations taking y = x² to y = (x - 4)² - 3.',
 '[{"text": "Down 4 and right 3", "feedback": "The bracket number moves sideways and the tail number moves vertically — they are swapped here."}, {"text": "Left 4 and down 3", "feedback": "(x - 4) moves the graph toward POSITIVE x. The inside sign works in reverse."}, {"text": "Right 4 and down 3", "feedback": "Correct."}, {"text": "Right 4 and up 3", "feedback": "The -3 outside drops the graph. Outside signs read directly."}]'::jsonb, 2, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 12, 'Medium',
 'A parabola has vertex (2, -5) and opens up with a = 1. What is its equation in vertex form?',
 '[{"text": "y = (x + 2)² - 5", "feedback": "h = 2 enters the bracket with a FLIPPED sign: (x - 2)."}, {"text": "y = (x + 2)² + 5", "feedback": "Both signs are reversed. The bracket flips h; the tail copies k."}, {"text": "y = (x - 2)² - 5", "feedback": "Correct."}, {"text": "y = (x - 2)² + 5", "feedback": "k = -5 keeps its own sign outside the bracket."}]'::jsonb, 2, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 13, 'Medium',
 'What is the maximum value of y = -2(x + 1)² + 8, and where does it occur?',
 '[{"text": "8, at x = -1", "feedback": "Correct."}, {"text": "8, at x = 1", "feedback": "The bracket (x + 1) peaks when x = -1. The inside sign flips."}, {"text": "There is no maximum", "feedback": "a is negative, so the parabola opens down and the vertex is its highest point."}, {"text": "-2, at x = -1", "feedback": "-2 is the stretch factor. The maximum VALUE is k."}]'::jsonb, 0, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 14, 'Medium',
 'Convert by completing the square: y = x² + 6x + 4',
 '[{"text": "y = (x + 3)² - 5", "feedback": "Correct."}, {"text": "y = (x + 3)² + 4", "feedback": "Adding 9 inside means SUBTRACTING 9 outside: 4 - 9 is -5. The +4 cannot survive unchanged."}, {"text": "y = (x + 6)² - 32", "feedback": "The bracket takes HALF the x coefficient: 3, not 6."}, {"text": "y = (x + 3)² + 13", "feedback": "The 9 that completes the square is subtracted, not added: 4 - 9, not 4 + 9."}]'::jsonb, 0, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 15, 'Medium',
 'Convert: y = x² - 10x + 30',
 '[{"text": "y = (x + 5)² + 5", "feedback": "The bracket copies the sign of the x term: -10x gives (x - 5)."}, {"text": "y = (x - 5)² + 5", "feedback": "Correct."}, {"text": "y = (x - 5)² - 25", "feedback": "The +30 still counts: 30 - 25 leaves +5 outside."}, {"text": "y = (x - 10)² + 30", "feedback": "Half of 10 goes in the bracket, and the constant adjusts by its square."}]'::jsonb, 1, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 16, 'Medium',
 'What is the vertex of y = (x - 1)(x - 9)?',
 '[{"text": "(4, -15)", "feedback": "The axis is halfway between 1 and 9, which is 5, not 4."}, {"text": "(5, 16)", "feedback": "Substitute x = 5 into both brackets and multiply — one bracket comes out negative."}, {"text": "(5, -16)", "feedback": "Correct."}, {"text": "(1, 9)", "feedback": "Those are the x-intercepts bundled into a point. The vertex x is their average."}]'::jsonb, 2, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 17, 'Medium',
 'A parabola in factored form is y = 2(x + 3)(x - 1). What is its y-intercept?',
 '[{"text": "-6", "feedback": "Correct."}, {"text": "-3", "feedback": "The 2 out front multiplies too: 2 times 3 times -1."}, {"text": "6", "feedback": "Substituting x = 0 gives 2(3)(-1), and the product of a positive and a negative is negative."}, {"text": "2", "feedback": "2 is the stretch factor. Substitute x = 0 through the WHOLE equation."}]'::jsonb, 0, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 18, 'Medium',
 'Which equation has x-intercepts at -2 and 6 and opens downward?',
 '[{"text": "y = -(x - 2)(x + 6)", "feedback": "Those brackets zero at +2 and -6 — the intercepts flipped."}, {"text": "y = (x + 2)(x - 6)", "feedback": "The intercepts are right, but a positive a opens UP."}, {"text": "y = -(x - 2)(x - 6)", "feedback": "The first bracket zeroes at +2, not -2. An intercept of -2 needs (x + 2)."}, {"text": "y = -(x + 2)(x - 6)", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 19, 'Medium',
 'The points (1, 4) and (7, 4) lie on a parabola. What is the x-coordinate of its vertex?',
 '[{"text": "8", "feedback": "Equal heights sit symmetrically about the axis: AVERAGE the two x values."}, {"text": "4", "feedback": "Correct."}, {"text": "4.5", "feedback": "The method is right and the arithmetic slipped. Add the two x values and halve the total, carefully."}, {"text": "Cannot be determined", "feedback": "Equal y values are exactly enough — the axis must run midway between them."}]'::jsonb, 1, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 20, 'Medium',
 'First differences of a quadratic table are 3, 5, 7, 9. What are the second differences?',
 '[{"text": "2, constant", "feedback": "Correct."}, {"text": "3, constant", "feedback": "The second differences come from subtracting NEIGHBOURING first differences: 5 - 3 is 2."}, {"text": "4, constant", "feedback": "Each gap is 2: check 7 - 5."}, {"text": "They are not constant", "feedback": "5 - 3, 7 - 5 and 9 - 7 all give the same 2 — that constancy is the quadratic test."}]'::jsonb, 0, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 21, 'Challenge',
 'Convert: y = 2x² + 12x + 11',
 '[{"text": "y = 2(x + 3)² - 9", "feedback": "What leaves the bracket is 2 times 9, not 9. The stretch factor multiplies everything inside."}, {"text": "y = 2(x + 3)² - 7", "feedback": "Correct."}, {"text": "y = 2(x + 3)² + 2", "feedback": "The 9 completing the square sits INSIDE a bracket multiplied by 2, so 18 leaves the constant: 11 - 18 is -7."}, {"text": "y = 2(x + 6)² - 61", "feedback": "The 2 factors out FIRST: y = 2(x² + 6x) + 11, and half of 6 is 3."}]'::jsonb, 1, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 22, 'Challenge',
 'Convert: y = -x² + 8x - 10',
 '[{"text": "y = -(x + 4)² + 6", "feedback": "Factoring -1 from -x² + 8x gives (x² - 8x): the bracket is (x - 4)."}, {"text": "y = -(x - 4)² + 6", "feedback": "Correct."}, {"text": "y = -(x - 4)² - 26", "feedback": "The -16 inside the negative bracket ADDS 16 outside: -10 + 16 is +6."}, {"text": "y = (x - 4)² + 6", "feedback": "The negative on x² cannot vanish — the parabola opens down."}]'::jsonb, 1, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 23, 'Challenge',
 'A parabola has vertex (3, -2) and passes through (5, 6). What is a?',
 '[{"text": "2", "feedback": "Correct."}, {"text": "-2", "feedback": "The point (5, 6) sits ABOVE the vertex, so the parabola opens up and a is positive."}, {"text": "8", "feedback": "That stops after moving the -2 across. The squared bracket still divides it."}, {"text": "1/2", "feedback": "That divides the wrong way around once the bracket is squared. Isolate a step by step."}]'::jsonb, 0, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 24, 'Challenge',
 'Which equation matches a parabola with vertex (-1, 4) opening down, in vertex form?',
 '[{"text": "y = -3(x + 1)² - 4", "feedback": "k = 4 keeps its own sign outside: +4."}, {"text": "y = -3(x + 1)² + 4", "feedback": "Correct."}, {"text": "y = -3(x - 1)² + 4", "feedback": "h = -1 goes into the bracket sign-flipped: (x + 1)."}, {"text": "y = 3(x + 1)² + 4", "feedback": "A positive a opens UP. Opening down needs a negative stretch."}]'::jsonb, 1, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 25, 'Challenge',
 'y = x² - 4x + 7 has how many x-intercepts?',
 '[{"text": "Two, at 2 and 3", "feedback": "(2, 3) is one point — the vertex — not two intercepts."}, {"text": "Two, because every parabola crosses the x-axis", "feedback": "A parabola floating above the axis never crosses it. Complete the square to find the vertex first."}, {"text": "One, at x = 2", "feedback": "x = 2 is the AXIS of symmetry. The graph there sits at height 3, not 0."}, {"text": "None, because its vertex (2, 3) is above the x-axis and it opens up", "feedback": "Correct."}]'::jsonb, 3, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 26, 'Challenge',
 'A quadratic has x-intercepts -3 and 5 and passes through (1, -32). What is a in factored form?',
 '[{"text": "-2", "feedback": "Substitute (1, -32): both the y value AND the bracket product come out negative, and their quotient is positive."}, {"text": "1/2", "feedback": "-32 divides by -16 — the division went the wrong way."}, {"text": "-32", "feedback": "-32 is the y value of the point, not the stretch factor. Substitute and solve for a."}, {"text": "2", "feedback": "Correct."}]'::jsonb, 3, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 27, 'Challenge',
 'The parabola y = a(x - 2)² + 8 has x-intercepts. What must be true of a?',
 '[{"text": "a is between 0 and 1", "feedback": "Any positive a keeps the whole graph above the axis when the vertex is at height 8."}, {"text": "a is positive", "feedback": "A vertex ABOVE the axis with arms going up never comes down to cross it."}, {"text": "a is negative", "feedback": "Correct."}, {"text": "a can be anything except 0", "feedback": "The sign matters: only downward arms reach the axis from a vertex at +8."}]'::jsonb, 2, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 28, 'Challenge',
 'A ball follows h = -5(t - 2)² + 45. What is its maximum height, and when?',
 '[{"text": "45 m at t = -2 s", "feedback": "The bracket (t - 2) peaks at t = POSITIVE 2. Inside signs flip."}, {"text": "-5 m at t = 2 s", "feedback": "-5 is the stretch factor, not a height. The maximum height is k."}, {"text": "40 m at t = 2 s", "feedback": "That takes the stretch factor of 5 off the constant."}, {"text": "45 m at t = 2 s", "feedback": "Correct."}]'::jsonb, 3, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 29, 'Challenge',
 'Which quadratic has second differences of -6?',
 '[{"text": "y = -3x² + x", "feedback": "Correct."}, {"text": "y = 3x² - 6x", "feedback": "a = 3 gives second differences of +6. The sign of a carries through."}, {"text": "y = -3x + 6", "feedback": "That is a line — no second differences at all beyond zero."}, {"text": "y = -6x² + 1", "feedback": "Second differences equal 2a. For -6 that means a = -3, not -6."}]'::jsonb, 0, 'sub-properties-of-quadratics'),
(10, 'MPM2D', 'Quadratics', 4, 30, 'Challenge',
 'y = (x - 4)² and y = x² - 4 differ how?',
 '[{"text": "The first shifts down 4, the second right 4", "feedback": "The bracket number is the sideways move; the loose number is the vertical one."}, {"text": "The first shifts left 4, the second up 4", "feedback": "Both directions are reversed: inside the bracket flips, outside reads directly."}, {"text": "The first shifts right 4, the second shifts down 4", "feedback": "Correct."}, {"text": "They are the same graph", "feedback": "Expand the first: x² - 8x + 16. The middle term makes them different graphs."}]'::jsonb, 2, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 31, 'Advanced',
 'Convert: y = 3x² - 9x + 5',
 '[{"text": "y = 3(x - 3/2)² + 5", "feedback": "The completing term leaves the constant changed: 5 minus 3 times 9/4 is -7/4."}, {"text": "y = 3(x - 3/2)² - 7/4", "feedback": "Correct."}, {"text": "y = 3(x - 3/2)² - 9/4", "feedback": "What exits the bracket is 3 times 9/4 = 27/4, and 5 is 20/4: the tail is -7/4."}, {"text": "y = 3(x - 3)² + 5", "feedback": "The 3 factors out first, leaving x² - 3x inside — half of 3 is 3/2, not 3."}]'::jsonb, 1, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 32, 'Advanced',
 'A rectangular pen uses 40 m of fence. Its area is A = w(20 - w). What width gives the maximum area?',
 '[{"text": "20 m", "feedback": "w = 20 makes the OTHER side zero — no pen at all. The best width sits midway between the two zeros."}, {"text": "5 m", "feedback": "Compare areas: at w = 5 the pen is long and thin. The vertex sits midway between the zeros of w(20 - w)."}, {"text": "10 m", "feedback": "Correct."}, {"text": "40 m", "feedback": "40 is the whole fence. The two widths together use only part of it."}]'::jsonb, 2, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 33, 'Advanced',
 'A rectangular pen uses 40 m of fence, so its area is A = w(20 - w). What is the maximum area of that pen?',
 '[{"text": "400 m²", "feedback": "400 is 20 squared. Substitute the best width into w(20 - w) instead."}, {"text": "100 m²", "feedback": "Correct."}, {"text": "75 m²", "feedback": "That is the area at w = 5, not at the vertex."}, {"text": "200 m²", "feedback": "That multiplies the best width by the FULL 20. The other side of the pen is 20 minus w."}]'::jsonb, 1, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 34, 'Advanced',
 'A quadratic has vertex (1, -8) and one x-intercept at 3. Where is the other x-intercept?',
 '[{"text": "-3", "feedback": "Mirror across the axis x = 1, not across the y-axis. Measure how far 3 sits from the axis, then go that same distance the other way."}, {"text": "5", "feedback": "Intercepts mirror across the AXIS x = 1. Reflecting 3 puts the other one on the far side of the axis, not further right."}, {"text": "-1", "feedback": "Correct."}, {"text": "8", "feedback": "8 comes from the vertex height, which does not locate intercepts."}]'::jsonb, 2, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 35, 'Advanced',
 'Written in all three forms, y = x² - 2x - 8 is which of these?',
 '[{"text": "y = (x - 1)² - 9 and y = (x - 4)(x + 2)", "feedback": "Correct."}, {"text": "y = (x + 1)² - 9 and y = (x - 4)(x + 2)", "feedback": "The vertex form bracket copies half the -2x term: (x - 1)."}, {"text": "y = (x - 1)² + 9 and y = (x - 4)(x + 2)", "feedback": "The tail is -8 - 1 = -9. Completing the square SUBTRACTS the 1 that was added inside."}, {"text": "y = (x - 1)² - 9 and y = (x + 4)(x - 2)", "feedback": "Those factors zero at -4 and 2, but the intercepts are 4 and -2. Expand to check the middle sign."}]'::jsonb, 0, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 36, 'Advanced',
 'For what values of k does y = x² + kx + 25 touch the x-axis exactly once?',
 '[{"text": "10 only", "feedback": "The perfect square can be (x - 5)² as well. Both signs of k work."}, {"text": "10 and -10", "feedback": "Correct."}, {"text": "5 and -5", "feedback": "Touching once means a perfect square: the middle term is twice the root of 25, so k is 10 in size."}, {"text": "25", "feedback": "k copies twice the square root of the constant, not the constant."}]'::jsonb, 1, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 37, 'Advanced',
 'An arch is modelled by h = -0.5(x - 6)² + 18. How wide is the arch at ground level?',
 '[{"text": "36", "feedback": "Setting h = 0 gives (x - 6)² = 36, so x - 6 is plus or minus 6 — the 36 still needs its square root."}, {"text": "18", "feedback": "18 is the height at the top, not a width."}, {"text": "6", "feedback": "6 is the distance from the centre to ONE foot. The arch spans both sides of centre."}, {"text": "12", "feedback": "Correct."}]'::jsonb, 3, 'sub-vertex-form'),
(10, 'MPM2D', 'Quadratics', 4, 38, 'Advanced',
 'Two numbers add to 14. What is the largest their product can be?',
 '[{"text": "48", "feedback": "Close but under — that is 6 times 8. The true peak sits at the vertex of n(14 - n), where the two numbers are equal."}, {"text": "196", "feedback": "196 is 14 squared — but the two numbers ADD to 14, they are not both 14."}, {"text": "49", "feedback": "Correct."}, {"text": "14", "feedback": "14 is the sum, given. Find the vertex of the product n(14 - n)."}]'::jsonb, 2, 'sub-factored-form'),
(10, 'MPM2D', 'Quadratics', 4, 39, 'Advanced',
 'y = 2(x - 3)(x - 7) and y = 2(x - 5)² - 8 describe what?',
 '[{"text": "The same parabola, but only the first has x-intercepts", "feedback": "A graph either crosses the axis or not — its form on paper cannot change that."}, {"text": "Different parabolas with the same intercepts", "feedback": "The stretch factor is 2 in both, and the vertex (5, -8) matches the average of the intercepts 3 and 7."}, {"text": "Different parabolas with the same vertex", "feedback": "Expand both: 2x² - 20x + 42 twice over. Same everything."}, {"text": "The same parabola, in factored and vertex form", "feedback": "Correct."}]'::jsonb, 3, 'sub-completing-the-square'),
(10, 'MPM2D', 'Quadratics', 4, 40, 'Advanced',
 'A quadratic table has y values 5, 8, 13, 20 at x = 0, 1, 2, 3. What is y at x = 4?',
 '[{"text": "29", "feedback": "Correct."}, {"text": "25", "feedback": "The GAPS grow by 2 each time. Adding a constant 5 treats it as linear."}, {"text": "40", "feedback": "Twice 20 doubles the last value. Extend the difference pattern instead: 20 + 9."}, {"text": "27", "feedback": "The first differences are 3, 5, 7 — the next gap is not another 7, because second differences stay constant."}]'::jsonb, 0, 'sub-properties-of-quadratics');


-- ==========================================================================
-- Unit 5: Solving quadratic equations
-- ==========================================================================

delete from questions where grade = 10 and unit = 'Solving quadratic equations';

insert into misconception_labels (tag, label) values
  ('sub-quadratic-applications', 'Applications of quadratics'),
  ('sub-quadratic-formula', 'The quadratic formula'),
  ('sub-solving-by-completing-square', 'Solving by completing the square'),
  ('sub-solving-by-factoring', 'Solving by factoring'),
  ('sub-standard-form-analysis', 'Standard form analysis')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values
(10, 'MPM2D', 'Solving quadratic equations', 5, 1, 'Easy',
 'If (x - 3)(x + 5) = 0, what are the solutions?',
 '[{"text": "3 and -5", "feedback": "Correct."}, {"text": "-15", "feedback": "That multiplies the two numbers. The zero product rule gives one solution per factor."}, {"text": "-3 and 5", "feedback": "Each factor is zeroed by the OPPOSITE of its number: x - 3 = 0 gives +3."}, {"text": "3 and 5", "feedback": "The second bracket needs x = -5 to vanish. Watch its sign."}]'::jsonb, 0, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 2, 'Easy',
 'Why can each factor be set to zero when solving (x - 3)(x + 5) = 0?',
 '[{"text": "A product is zero only when at least one factor is zero", "feedback": "Correct."}, {"text": "Because both factors must equal zero at once", "feedback": "x cannot be 3 and -5 at the same time. EITHER factor being zero kills the product."}, {"text": "Because zero divides both sides", "feedback": "Dividing by zero is never allowed. The rule is about products, not division."}, {"text": "Because the brackets cancel each other", "feedback": "Brackets do not cancel across a multiplication. The zero on the right is what powers the rule."}]'::jsonb, 0, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 3, 'Easy',
 'What is the first step to solve x² + 4x = 21 by factoring?',
 '[{"text": "Divide both sides of the equation through by x", "feedback": "Dividing by x throws away the possible solution x = 0 and is not valid when x might be 0."}, {"text": "Factor x out of the left side straight away", "feedback": "The zero product rule needs a ZERO on one side first — factoring x² + 4x while 21 sits opposite proves nothing."}, {"text": "Move the 21 across so one side equals zero", "feedback": "Correct."}, {"text": "Take the square root of both sides right away", "feedback": "The left side is not a perfect square, and rooting a sum does not split it."}]'::jsonb, 2, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 4, 'Easy',
 'Solve: x² - 9 = 0',
 '[{"text": "x = 3 and x = -3", "feedback": "Correct."}, {"text": "x = 3 only", "feedback": "The negative root works too: (-3)² is also 9. Square roots come in pairs."}, {"text": "x = 81", "feedback": "81 is 9 squared. The equation asks what squares TO 9."}, {"text": "x = 4.5", "feedback": "Halving the 9 is not the inverse of squaring. Take the square root."}]'::jsonb, 0, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 5, 'Easy',
 'Solve: (x + 4)² = 25',
 '[{"text": "x = 21", "feedback": "25 - 4 subtracts before rooting. Square root the 25 first, then move the 4."}, {"text": "x = 1 and x = -9", "feedback": "Correct."}, {"text": "x = 5 and x = -5", "feedback": "That solves the bracket ITSELF equal to root 25. Finish by subtracting the 4 from each."}, {"text": "x = 1 only", "feedback": "The root of 25 is plus OR minus 5, giving two answers."}]'::jsonb, 1, 'sub-solving-by-completing-square'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 6, 'Easy',
 'In the quadratic formula, what expression sits under the square root?',
 '[{"text": "b² - 4ac", "feedback": "Correct."}, {"text": "b² + 4ac", "feedback": "The 4ac SUBTRACTS. The sign under the root decides everything about the roots."}, {"text": "4ac - b²", "feedback": "The b² leads. Reversed, the sign of the whole expression flips."}, {"text": "b - 4ac", "feedback": "The b is squared under the root. Without the square the formula fails."}]'::jsonb, 0, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 7, 'Easy',
 'For 2x² - 5x + 1 = 0, what are a, b and c?',
 '[{"text": "a = 2, b = -5, c = 1", "feedback": "Correct."}, {"text": "a = 2, b = 5, c = 1", "feedback": "b carries its SIGN: the term is minus 5x, so b is -5."}, {"text": "a = 2x², b = -5x, c = 1", "feedback": "a, b and c are the COEFFICIENTS only — the x parts stay behind."}, {"text": "a = 1, b = -5, c = 2", "feedback": "a belongs to x² and c is the constant. They are swapped here."}]'::jsonb, 0, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 8, 'Easy',
 'A quadratic equation can have at most how many real solutions?',
 '[{"text": "Unlimited", "feedback": "The degree of the equation caps how many roots exist."}, {"text": "Three", "feedback": "A parabola cannot cross a horizontal line three times — count the crossings a U shape allows."}, {"text": "Two", "feedback": "Correct."}, {"text": "One", "feedback": "One happens only when the discriminant lands exactly on zero — it is not the ceiling."}]'::jsonb, 2, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 9, 'Easy',
 'For y = x² - 6x + 2, the x-coordinate of the vertex is found by which calculation?',
 '[{"text": "x = -b over 2a, giving 3", "feedback": "Correct."}, {"text": "x = c over a, giving 2", "feedback": "c places the y-intercept, not the vertex."}, {"text": "x = b over 2a, giving -3", "feedback": "The formula NEGATES b: minus (-6) over 2 is positive 3."}, {"text": "x = -b over a, giving 6", "feedback": "The denominator is 2a, not a. Halve the 6."}]'::jsonb, 0, 'sub-standard-form-analysis'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 10, 'Easy',
 'A rocket is launched with h(t) = -4.9t² + 30t + 2. What does the 2 represent?',
 '[{"text": "The launch height, 2 metres", "feedback": "Correct."}, {"text": "The maximum height the rocket reaches", "feedback": "The maximum sits at the vertex, much higher than 2. Substitute t = 0 to see what the 2 means."}, {"text": "The time the rocket spends in the air", "feedback": "Time is t, the input. The 2 is the OUTPUT when t = 0."}, {"text": "The speed of the rocket at launch", "feedback": "The 30 carries the launch speed. The loose constant is the starting height."}]'::jsonb, 0, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 11, 'Medium',
 'Solve by factoring: x² + 4x - 21 = 0',
 '[{"text": "x = 3 and x = 7", "feedback": "One root is negative: the pair multiplies to MINUS 21, so signs differ."}, {"text": "x = -3 and x = 7", "feedback": "The factors are (x + 7)(x - 3): the pair 7 and -3 must ADD to +4."}, {"text": "x = 21 and x = -1", "feedback": "Those multiply to -21 but add to 20. Both conditions bind."}, {"text": "x = 3 and x = -7", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 12, 'Medium',
 'Solve: 2x² - 8x = 0',
 '[{"text": "x = 2 and x = 4", "feedback": "2 is the common coefficient taken out front, not a root. A constant factor never produces a solution."}, {"text": "x = 0 and x = -4", "feedback": "The bracket is (x - 4), zeroed at POSITIVE 4."}, {"text": "x = 4 only", "feedback": "Dividing by x silently discards x = 0 — a real solution. Factor 2x out instead."}, {"text": "x = 0 and x = 4", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 13, 'Medium',
 'Solve by completing the square: x² + 6x + 2 = 0',
 '[{"text": "x = -3 + √7 only", "feedback": "The square root carries both signs — two solutions."}, {"text": "x = -3 + √11 and x = -3 - √11", "feedback": "Moving the 2 across SUBTRACTS it from the completing constant — it was added instead."}, {"text": "x = -3 + √7 and x = -3 - √7", "feedback": "Correct."}, {"text": "x = 3 + √7 and x = 3 - √7", "feedback": "That reads the roots off the completed square with the 3 left as it stands."}]'::jsonb, 2, 'sub-solving-by-completing-square'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 14, 'Medium',
 'Solve: (x - 2)² = 18. Give exact answers.',
 '[{"text": "x = 2 + 3√2 only", "feedback": "Both signs of the root give solutions."}, {"text": "x = 2 + 3√2 and x = 2 - 3√2", "feedback": "Correct."}, {"text": "x = -2 + 3√2 and x = -2 - 3√2", "feedback": "The -2 in the bracket crosses over as +2."}, {"text": "x = 2 + 9 and x = 2 - 9", "feedback": "√18 is not 9 — that halves instead of rooting. Simplify √18 by pulling out its perfect square factor."}]'::jsonb, 1, 'sub-solving-by-completing-square'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 15, 'Medium',
 'Solve with the quadratic formula: 2x² + 3x - 2 = 0',
 '[{"text": "x = 1 and x = -4", "feedback": "The denominator is 2a = 4, not 2. Both roots shrink by half."}, {"text": "x = 1/2 and x = -2", "feedback": "Correct."}, {"text": "x = -1/2 and x = 2", "feedback": "The formula starts with MINUS b, and b here is +3 — the signs of both roots came out flipped."}, {"text": "x = 1/2 only", "feedback": "The plus and the minus of √25 each give a root."}]'::jsonb, 1, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 16, 'Medium',
 'How many real roots does x² - 6x + 9 = 0 have?',
 '[{"text": "None, because 36 - 36 = 0", "feedback": "Zero under the root is fine — it gives one real root, not none. NEGATIVE means none."}, {"text": "One, because b² - 4ac = 0", "feedback": "Correct."}, {"text": "One, at x = 9", "feedback": "The root is x = 3, from -b over 2a. 9 is the constant c."}, {"text": "Two, because it is a quadratic", "feedback": "A discriminant of exactly zero collapses the two roots into one."}]'::jsonb, 1, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 17, 'Medium',
 'How many real roots does x² + 2x + 5 = 0 have?',
 '[{"text": "Two, because 4 + 20 = 24", "feedback": "The 4ac SUBTRACTS: 4 - 20 is -16, and a negative under the root gives no real answers."}, {"text": "None, because b² - 4ac is negative", "feedback": "Correct."}, {"text": "Two, at 1 and 5", "feedback": "Those are coefficients, not roots. Check the discriminant first."}, {"text": "One, at x = -1", "feedback": "x = -1 is the vertex position. The graph there sits at height 4, above the axis."}]'::jsonb, 1, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 18, 'Medium',
 'What is the vertex of y = x² - 6x + 2?',
 '[{"text": "(3, 2)", "feedback": "The y of the vertex comes from SUBSTITUTING x = 3 into the whole equation, not from reading the constant."}, {"text": "(-3, 29)", "feedback": "x = -b over 2a is minus (-6) over 2 — positive 3."}, {"text": "(3, -7)", "feedback": "Correct."}, {"text": "(6, 2)", "feedback": "The 2a in the denominator halves the 6."}]'::jsonb, 2, 'sub-standard-form-analysis'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 19, 'Medium',
 'What is the axis of symmetry of y = 2x² + 8x - 1?',
 '[{"text": "x = -2", "feedback": "Correct."}, {"text": "x = -1", "feedback": "-1 is the y-intercept constant, nothing to do with the axis."}, {"text": "x = 2", "feedback": "x = -b over 2a keeps the minus: -8 over 4."}, {"text": "x = -4", "feedback": "The denominator is 2a = 4, not a = 2."}]'::jsonb, 0, 'sub-standard-form-analysis'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 20, 'Medium',
 'A ball follows h = -5t² + 20t. When does it land?',
 '[{"text": "t = 5", "feedback": "Substitute it back: at t = 5 the height comes out negative — underground."}, {"text": "t = 4", "feedback": "Correct."}, {"text": "t = 20", "feedback": "Factoring gives -5t(t - 4) = 0. The 20 is a coefficient, not a time."}, {"text": "t = 2", "feedback": "t = 2 is the PEAK, halfway through the flight. Landing means h = 0."}]'::jsonb, 1, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 21, 'Challenge',
 'Solve: 3x² - 5x - 2 = 0',
 '[{"text": "x = 2 and x = 1/3", "feedback": "The smaller root is NEGATIVE: 3x + 1 = 0 gives -1/3."}, {"text": "x = 5 and x = -2", "feedback": "Those use the coefficients directly. Factor by decomposition: -6x + x replaces -5x."}, {"text": "x = -2 and x = 1/3", "feedback": "The factors are (3x + 1)(x - 2): the signs land the other way."}, {"text": "x = 2 and x = -1/3", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 22, 'Challenge',
 'Solve: x² = 5x - 6',
 '[{"text": "x = 0 and x = 5", "feedback": "Setting x² = 0 and 5x - 6 = 0 separately is not solving the equation. Bring everything to one side first."}, {"text": "x = -2 and x = -3", "feedback": "Rearranged, the equation is x² - 5x + 6 = 0: the pair must add to +5."}, {"text": "x = 1 and x = 6", "feedback": "1 and 6 multiply to 6 but add to 7, not to the 5 the middle term needs."}, {"text": "x = 2 and x = 3", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 23, 'Challenge',
 'Solve by completing the square: 2x² - 12x + 10 = 0',
 '[{"text": "x = 1 as the only solution", "feedback": "The square root carries both signs, so one of the two solutions has been dropped."}, {"text": "x = 3 + √14 and x = 3 - √14", "feedback": "That adds the constant instead of subtracting it while completing the square. Watch the sign as the constant crosses the equals sign."}, {"text": "x = -1 and x = -5", "feedback": "After dividing by 2, (x - 3)² = 4 unwinds around POSITIVE 3."}, {"text": "x = 1 and x = 5", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-completing-square'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 24, 'Challenge',
 'Solve exactly: x² - 4x - 3 = 0',
 '[{"text": "x = 2 + √1 and x = 2 - √1", "feedback": "The c is MINUS 3, so the -4ac piece ADDS to b² instead of subtracting."}, {"text": "x = 2 + √7 and x = 2 - √7", "feedback": "Correct."}, {"text": "x = 4 + √7 and x = 4 - √7", "feedback": "The -b over 2a halves the 4 before the root joins: 2, not 4."}, {"text": "x = 2 + √28 and x = 2 - √28", "feedback": "The 2a divides the root as well — simplify the root by extracting its square factor first."}]'::jsonb, 1, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 25, 'Challenge',
 'For which values of k does x² + kx + 16 = 0 have exactly one real root?',
 '[{"text": "k = 4 and k = -4", "feedback": "One root needs the discriminant to vanish: k² equals 4 times 16, and the root of THAT is not 4."}, {"text": "k = 8 and k = -8", "feedback": "Correct."}, {"text": "k = 8 only", "feedback": "k² = 64 has two roots. Both signs make the discriminant zero."}, {"text": "k = 16", "feedback": "Set b² - 4ac to zero: k² = 4 times 16. The k does not copy c."}]'::jsonb, 1, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 26, 'Challenge',
 'Profit follows P = -2x² + 120x - 1000. What price x gives the maximum profit?',
 '[{"text": "-30", "feedback": "The two negatives cancel: -120 over -4 is positive."}, {"text": "60", "feedback": "That divided by a instead of by 2a. Here 2a is -4, so the denominator is twice what was used."}, {"text": "800", "feedback": "800 is the PROFIT at the best price, not the price itself."}, {"text": "30", "feedback": "Correct."}]'::jsonb, 3, 'sub-standard-form-analysis'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 27, 'Challenge',
 'For that profit model, what is the maximum profit?',
 '[{"text": "1000", "feedback": "Substitute x = 30 through every term — the constant still subtracts at the end."}, {"text": "800", "feedback": "Correct."}, {"text": "2600", "feedback": "The -2x² term is negative at x = 30 — it pulls the total DOWN, not up."}, {"text": "30", "feedback": "30 is the best PRICE. The profit is P evaluated there."}]'::jsonb, 1, 'sub-standard-form-analysis'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 28, 'Challenge',
 'Two consecutive positive integers have a product of 72. What are they?',
 '[{"text": "6 and 12", "feedback": "Those multiply to 72 but are not CONSECUTIVE. Solve n(n + 1) = 72."}, {"text": "36 and 36", "feedback": "Equal numbers are not consecutive, and the equation n(n + 1) = 72 rules them out."}, {"text": "8 and 9", "feedback": "Correct."}, {"text": "7 and 8", "feedback": "Check: 7 times 8 is 56, short of 72."}]'::jsonb, 2, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 29, 'Challenge',
 'A right triangle has legs x and x + 7, and hypotenuse 13. What is x?',
 '[{"text": "12", "feedback": "12 is the LONGER leg, x + 7. The question asks for x."}, {"text": "6", "feedback": "x² + (x + 7)² = 169 reduces to x² + 7x - 60 = 0 — factor it rather than estimating."}, {"text": "5", "feedback": "Correct."}, {"text": "13", "feedback": "13 is the hypotenuse, given. The legs are the unknowns."}]'::jsonb, 2, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 30, 'Challenge',
 'The ball with h = -5t² + 20t is at height 15 at which times?',
 '[{"text": "t = 1 only", "feedback": "A ball passes each height twice — once going up, once coming down."}, {"text": "t = 15", "feedback": "15 is the HEIGHT. Set -5t² + 20t = 15 and solve for t."}, {"text": "t = 1 and t = 3", "feedback": "Correct."}, {"text": "t = 2", "feedback": "t = 2 is the peak at height 20, above 15."}]'::jsonb, 2, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 31, 'Advanced',
 'A path of uniform width x surrounds an 8 m by 6 m garden. The total area including the path is 80 m². What is x?',
 '[{"text": "1", "feedback": "Correct."}, {"text": "8", "feedback": "x = -8 also solves the quadratic, but a width cannot be negative — and 8 comes from the wrong factor sign anyway."}, {"text": "2", "feedback": "The path adds to BOTH sides: (8 + 2x)(6 + 2x) = 80, with 2x on each dimension."}, {"text": "8/7", "feedback": "That drops the 4x² term while expanding and solves what is left as a linear equation."}]'::jsonb, 0, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 32, 'Advanced',
 'A rocket follows h = -4.9t² + 19.6t + 2. What is its maximum height?',
 '[{"text": "19.6 m", "feedback": "19.6 is the launch speed coefficient. The peak needs t = 2 substituted through the whole formula."}, {"text": "2 m", "feedback": "2 m is where it STARTED. The vertex is far above the launch pad."}, {"text": "31.4 m", "feedback": "The first term at t = 2 is -4.9 times 4 — using -9.8, doubling instead of squaring, inflates the height."}, {"text": "21.6 m", "feedback": "Correct."}]'::jsonb, 3, 'sub-standard-form-analysis'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 33, 'Advanced',
 'For that rocket, how long until it lands, to one decimal?',
 '[{"text": "4.0 s", "feedback": "At t = 4 the height is 2 m — still airborne. The +2 launch height stretches the flight past 4."}, {"text": "2.0 s", "feedback": "t = 2 is the PEAK. Landing means h = 0, on the way down."}, {"text": "4.1 s", "feedback": "Correct."}, {"text": "8.2 s", "feedback": "That doubles the landing time. The formula -b plus root over 2a already gives the full flight."}]'::jsonb, 2, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 34, 'Advanced',
 'Two positive numbers differ by 6 and multiply to 91. What is the smaller one?',
 '[{"text": "6", "feedback": "6 is the gap between them, given, not a value."}, {"text": "91/6", "feedback": "The product does not divide by the difference. Set up n(n + 6) = 91 and factor."}, {"text": "13", "feedback": "13 is the LARGER of the two numbers. The question asks for the smaller one."}, {"text": "7", "feedback": "Correct."}]'::jsonb, 3, 'sub-solving-by-completing-square'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 35, 'Advanced',
 'Which method is MOST efficient for solving x² - 10x + 25 = 0?',
 '[{"text": "The quadratic formula, because it always works", "feedback": "Always working is not the same as fastest. The pattern (x - 5)² = 0 reads off instantly."}, {"text": "Factoring, because it is a perfect square trinomial", "feedback": "Correct."}, {"text": "Completing the square", "feedback": "The square is ALREADY complete — that is what a perfect square trinomial means."}, {"text": "Graphing to estimate the roots", "feedback": "An estimate for an exact double root at 5 trades certainty for effort."}]'::jsonb, 1, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 36, 'Advanced',
 'A farmer fences three sides of a field against a wall with 60 m of fence. The area is 448 m². What are the possible widths?',
 '[{"text": "14 m and 16 m", "feedback": "Correct."}, {"text": "15 m", "feedback": "15 is the vertex width — the MAXIMUM area of 450, slightly more than 448."}, {"text": "28 m and 32 m", "feedback": "The length along the wall is 60 - 2w: the fence covers two widths and one length, not two of each."}, {"text": "14 m only", "feedback": "The quadratic w² - 30w + 224 factors with TWO positive roots. Both layouts really give 448."}]'::jsonb, 0, 'sub-quadratic-applications'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 37, 'Advanced',
 'For which values of k does 2x² + 4x + k = 0 have two distinct real roots?',
 '[{"text": "Any k less than 8", "feedback": "With a = 2 the 4ac term is 8k — the 16 divides by its full coefficient, not by 2."}, {"text": "Any k except 2", "feedback": "k = 3 gives a negative discriminant and no roots at all. It is a one-sided condition, not an exclusion."}, {"text": "k greater than 2", "feedback": "Two roots need b² - 4ac ABOVE zero: 16 - 8k > 0 pulls k downward."}, {"text": "k less than 2", "feedback": "Correct."}]'::jsonb, 3, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 38, 'Advanced',
 'Which quadratic equation has roots 4 and -6?',
 '[{"text": "x² - 2x - 24 = 0", "feedback": "Expand (x - 4)(x + 6) carefully — the middle term takes the sign of the LARGER number."}, {"text": "x² - 10x + 24 = 0", "feedback": "That one has roots 4 and 6. The -6 changes both the middle and last terms."}, {"text": "x² + 2x - 24 = 0", "feedback": "Correct."}, {"text": "x² + 2x + 24 = 0", "feedback": "The constant is the product 4 times -6, which is NEGATIVE 24."}]'::jsonb, 2, 'sub-solving-by-factoring'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 39, 'Advanced',
 'Applying the formula to x² + 3x - 5 = 0 gives which exact solutions?',
 '[{"text": "x = -3 + √29 and x = -3 - √29", "feedback": "Everything sits over 2a = 2, the root included."}, {"text": "x = (3 + √29)/2 and x = (3 - √29)/2", "feedback": "The formula opens with MINUS b, and b is +3."}, {"text": "x = (-3 + √11)/2 and x = (-3 - √11)/2", "feedback": "c is -5, so the -4ac term ADDS to b² rather than subtracting from it."}, {"text": "x = (-3 + √29)/2 and x = (-3 - √29)/2", "feedback": "Correct."}]'::jsonb, 3, 'sub-quadratic-formula'),
(10, 'MPM2D', 'Solving quadratic equations', 5, 40, 'Advanced',
 'A triangle has base x cm and height (x - 3) cm, with area 27 cm². What is x?',
 '[{"text": "27", "feedback": "27 is the area that was given, not the base. Put base times height over 2 equal to 27 and solve for x."}, {"text": "-6", "feedback": "-6 solves the quadratic but a base cannot be negative. Take the positive root."}, {"text": "9", "feedback": "Correct."}, {"text": "6", "feedback": "That factors the quadratic as though the middle term were +3x, which flips the sign of both roots."}]'::jsonb, 2, 'sub-quadratic-applications');


-- ==========================================================================
-- Unit 6: Trigonometry
-- ==========================================================================

delete from questions where grade = 10 and unit = 'Trigonometry';

insert into misconception_labels (tag, label) values
  ('sub-cosine-law', 'Cosine law'),
  ('sub-similar-triangles', 'Similar triangles'),
  ('sub-sine-law', 'Sine law'),
  ('sub-trig-angles', 'Trig for angles'),
  ('sub-trig-ratios', 'The primary trig ratios'),
  ('sub-trig-side-lengths', 'Trig for side lengths')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values
(10, 'MPM2D', 'Trigonometry', 6, 1, 'Easy',
 'Two similar triangles have what in common?',
 '[{"text": "Equal sides and equal angles", "feedback": "Equal SIDES too would make them congruent. Similar allows different sizes."}, {"text": "Equal corresponding angles and proportional sides", "feedback": "Correct."}, {"text": "The same perimeter", "feedback": "Perimeters scale with the triangles. Only the angles are untouched by scaling."}, {"text": "Equal areas", "feedback": "Similar triangles usually have different areas — the shape matches, not the size."}]'::jsonb, 1, 'sub-similar-triangles'),
(10, 'MPM2D', 'Trigonometry', 6, 2, 'Easy',
 'Triangle DEF is similar to ABC with a scale factor of 3. Side AB is 4 cm. How long is DE?',
 '[{"text": "12 cm", "feedback": "Correct."}, {"text": "4 cm", "feedback": "Equal sides belong to congruent triangles. Similar ones scale."}, {"text": "7 cm", "feedback": "That adds the scale factor instead of multiplying by it. A scale factor stretches, it does not shift."}, {"text": "4/3 cm", "feedback": "Dividing shrinks — but DEF is the LARGER triangle here, three times ABC."}]'::jsonb, 0, 'sub-similar-triangles'),
(10, 'MPM2D', 'Trigonometry', 6, 3, 'Easy',
 'In a right triangle, the hypotenuse is which side?',
 '[{"text": "The horizontal side", "feedback": "Orientation on the page means nothing — rotate the triangle and the hypotenuse stays itself."}, {"text": "Either of the two sides that meet to form the right angle", "feedback": "Those are the legs. The hypotenuse faces the right angle from across the triangle."}, {"text": "The side opposite the smallest angle", "feedback": "Opposite the smallest angle sits the SHORTEST side."}, {"text": "The side opposite the right angle, always the longest", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-ratios'),
(10, 'MPM2D', 'Trigonometry', 6, 4, 'Easy',
 'Relative to angle θ in a right triangle, sin θ equals what?',
 '[{"text": "Opposite over hypotenuse", "feedback": "Correct."}, {"text": "Hypotenuse over opposite", "feedback": "The hypotenuse goes UNDERNEATH for sine."}, {"text": "Adjacent over hypotenuse", "feedback": "Adjacent over hypotenuse is COSINE. SOH: sine takes the opposite side."}, {"text": "Opposite over adjacent", "feedback": "That ratio is tangent, the TOA in the memory aid."}]'::jsonb, 0, 'sub-trig-ratios'),
(10, 'MPM2D', 'Trigonometry', 6, 5, 'Easy',
 'In a right triangle with the angle θ at one corner, the side touching θ that is not the hypotenuse is called what?',
 '[{"text": "The opposite side", "feedback": "Opposite means ACROSS from the angle, not touching it."}, {"text": "The adjacent side", "feedback": "Correct."}, {"text": "The hypotenuse", "feedback": "The hypotenuse also touches θ, but it is the special side facing the right angle — the question excludes it."}, {"text": "The base", "feedback": "Base describes position on the page, which changes when the triangle rotates."}]'::jsonb, 1, 'sub-trig-ratios'),
(10, 'MPM2D', 'Trigonometry', 6, 6, 'Easy',
 'A right triangle has legs 3 and 4 with hypotenuse 5. For the angle opposite the side of length 3, what is tan θ?',
 '[{"text": "3/4", "feedback": "Correct."}, {"text": "3/5", "feedback": "3/5 is sin θ — the hypotenuse crept into the tangent."}, {"text": "4/3", "feedback": "4/3 belongs to the OTHER acute angle. Opposite this angle is 3; adjacent is 4."}, {"text": "4/5", "feedback": "That is cos θ. Tangent never uses the hypotenuse."}]'::jsonb, 0, 'sub-trig-ratios'),
(10, 'MPM2D', 'Trigonometry', 6, 7, 'Easy',
 'Which tool finds a missing ANGLE from two known sides of a right triangle?',
 '[{"text": "The regular tan function used on its own", "feedback": "tan turns angles INTO ratios. Getting the angle back needs the inverse."}, {"text": "An inverse trig function such as tan⁻¹", "feedback": "Correct."}, {"text": "The Pythagorean theorem applied to the two sides", "feedback": "Pythagoras relates the three sides. It never mentions angles."}, {"text": "Doubling the ratio of the two known sides", "feedback": "No doubling rule connects ratios to angles. The inverse functions do that."}]'::jsonb, 1, 'sub-trig-angles'),
(10, 'MPM2D', 'Trigonometry', 6, 8, 'Easy',
 'In a right triangle, the hypotenuse is 10 cm and one angle is 35°. What is the side opposite that angle, to one decimal?',
 '[{"text": "8.2 cm", "feedback": "That used cos 35°. Opposite over hypotenuse calls for SINE."}, {"text": "7.0 cm", "feedback": "That used tan, which pairs opposite with the ADJACENT side, not the hypotenuse."}, {"text": "35.0 cm", "feedback": "35 is the angle. The side comes from 10 times sin 35°."}, {"text": "5.7 cm", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-side-lengths'),
(10, 'MPM2D', 'Trigonometry', 6, 9, 'Easy',
 'The sine law relates what quantities?',
 '[{"text": "Each side to the sine of its opposite angle", "feedback": "Correct."}, {"text": "The two legs and the hypotenuse", "feedback": "Legs and hypotenuse language belongs to RIGHT triangles. The sine law works on any triangle."}, {"text": "Each side to the sine of its adjacent angle", "feedback": "The pairing is strictly OPPOSITE: a with A, across the triangle."}, {"text": "The three angles only", "feedback": "Angles alone come from the 180° sum. The sine law brings the sides in."}]'::jsonb, 0, 'sub-sine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 10, 'Easy',
 'In a triangle with no right angle, when is the cosine law needed rather than the sine law?',
 '[{"text": "Whenever the triangle has an obtuse angle", "feedback": "An obtuse angle does not decide which law applies. What matters is which sides and angles are given."}, {"text": "When the triangle is small", "feedback": "Size is irrelevant. The choice of law rests on which parts are known."}, {"text": "When only angles are known", "feedback": "Only angles fixes the shape but not the size — no law finds sides from angles alone."}, {"text": "When no side has its opposite angle known", "feedback": "Correct."}]'::jsonb, 3, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 11, 'Medium',
 'Triangles are similar. One has sides 6 and x; the matching sides of the other are 9 and 12. What is x?',
 '[{"text": "9", "feedback": "6 + 3 borrows the additive gap between 6 and 9. Similarity scales by MULTIPLICATION: the factor is 9/6."}, {"text": "8", "feedback": "Correct."}, {"text": "4.5", "feedback": "That halves the 9 with no basis. Cross multiply the proportion 6/9 = x/12."}, {"text": "18", "feedback": "That multiplies 6 by 3. The scale factor is 12/9 in that direction — set up 6/9 = x/12."}]'::jsonb, 1, 'sub-similar-triangles'),
(10, 'MPM2D', 'Trigonometry', 6, 12, 'Medium',
 'Which condition proves two triangles are similar?',
 '[{"text": "Equal perimeters in both of the triangles", "feedback": "Perimeters can match on wildly different shapes."}, {"text": "One pair of equal corresponding angles only", "feedback": "One angle is shared by many shapes. Two pins the third down through the 180° sum."}, {"text": "Two pairs of equal corresponding side lengths", "feedback": "Equal sides without the contained angle proves nothing — and similarity wants proportional, not equal."}, {"text": "Two pairs of equal corresponding angles", "feedback": "Correct."}]'::jsonb, 3, 'sub-similar-triangles'),
(10, 'MPM2D', 'Trigonometry', 6, 13, 'Medium',
 'A 14 m ladder leans at 52° to the ground. How far is its base from the wall, to one decimal?',
 '[{"text": "22.7 m", "feedback": "That divides by cos instead of multiplying — and it comes out LONGER than the ladder itself, impossible for a leg."}, {"text": "11.0 m", "feedback": "That is the HEIGHT up the wall, from sin 52°. The ground distance is adjacent: cos."}, {"text": "8.6 m", "feedback": "Correct."}, {"text": "7.0 m", "feedback": "Halving the ladder assumes 60°. Use the cosine of the actual angle."}]'::jsonb, 2, 'sub-trig-side-lengths'),
(10, 'MPM2D', 'Trigonometry', 6, 14, 'Medium',
 'From 25 m away, the angle of elevation to the top of a tree is 41°. How tall is the tree, to one decimal?',
 '[{"text": "21.7 m", "feedback": "Correct."}, {"text": "25.0 m", "feedback": "Equal height and distance happens only at 45°. This angle is 41°."}, {"text": "16.4 m", "feedback": "sin pairs opposite with the HYPOTENUSE, but 25 m is the ground distance — adjacent. Use tan."}, {"text": "28.8 m", "feedback": "That divides by tan. The height is the OPPOSITE side and 25 m is the ADJACENT — rearrange the tan ratio for the opposite."}]'::jsonb, 0, 'sub-trig-side-lengths'),
(10, 'MPM2D', 'Trigonometry', 6, 15, 'Medium',
 'The side opposite a 32° angle is 8 cm. What is the hypotenuse, to one decimal?',
 '[{"text": "9.4 cm", "feedback": "Opposite and hypotenuse pair with SINE. cos would need the adjacent side."}, {"text": "4.0 cm", "feedback": "The hypotenuse is the LONGEST side — it cannot be shorter than the 8 cm leg."}, {"text": "4.2 cm", "feedback": "That MULTIPLIED by sin 32°. In sine, the hypotenuse sits on the BOTTOM of the ratio — isolating it means dividing."}, {"text": "15.1 cm", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-side-lengths'),
(10, 'MPM2D', 'Trigonometry', 6, 16, 'Medium',
 'A right triangle has opposite side 5 and adjacent side 12. What is the angle, to one decimal?',
 '[{"text": "22.6°", "feedback": "Correct."}, {"text": "24.6°", "feedback": "sin⁻¹ of 5/12 treats 12 as the hypotenuse, but 12 is the adjacent side here — 13 would be the hypotenuse."}, {"text": "0.4°", "feedback": "0.42 is the RATIO 5/12 itself. The inverse tan turns it into an angle."}, {"text": "67.4°", "feedback": "That is tan⁻¹ of 12/5 — the ratio upside down, giving the OTHER acute angle."}]'::jsonb, 0, 'sub-trig-angles'),
(10, 'MPM2D', 'Trigonometry', 6, 17, 'Medium',
 'The side opposite angle θ is 7 and the hypotenuse is 10. What is θ, to one decimal?',
 '[{"text": "35.0°", "feedback": "A guess of half of 70 is not how ratios become angles. sin⁻¹(0.7) is the tool."}, {"text": "45.6°", "feedback": "cos⁻¹ answers a different question — 0.7 here is opposite over hypotenuse, which belongs to sin."}, {"text": "44.4°", "feedback": "Correct."}, {"text": "0.7°", "feedback": "0.7 is the ratio. Feed it to sin⁻¹ for the angle."}]'::jsonb, 2, 'sub-trig-ratios'),
(10, 'MPM2D', 'Trigonometry', 6, 18, 'Medium',
 'In triangle ABC, angle A = 40°, angle B = 75°, and b = 12 cm. What is side a, to one decimal?',
 '[{"text": "8.0 cm", "feedback": "Correct."}, {"text": "7.7 cm", "feedback": "The sin 75° divisor went missing. The sine law is a full proportion, not one product."}, {"text": "18.0 cm", "feedback": "The sines are flipped — the unknown side sits on top, multiplied by the sine of ITS OWN opposite angle."}, {"text": "12.0 cm", "feedback": "Side a faces the SMALLER angle, so it must come out shorter than 12."}]'::jsonb, 0, 'sub-sine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 19, 'Medium',
 'In triangle ABC, a = 9, b = 14 and angle B = 80°. What is angle A, to one decimal?',
 '[{"text": "39.3°", "feedback": "Correct."}, {"text": "0.6°", "feedback": "That is the sine RATIO, not the angle. The inverse sine still has to run."}, {"text": "39.1°", "feedback": "That rounds the sine ratio to two decimals before the inverse sine. Keep the digits until the end."}, {"text": "61.0°", "feedback": "That subtracts from 180 too early: find A from the sine law first, then any leftover angle."}]'::jsonb, 0, 'sub-sine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 20, 'Medium',
 'In triangle ABC, b = 7, c = 9 and angle A = 60°. What is side a, to one decimal?',
 '[{"text": "2.0 cm", "feedback": "Order of operations: only the 2bc multiplies cos A. That slip lands on a², and the square root has still to be taken."}, {"text": "8.2 cm", "feedback": "Correct."}, {"text": "67.0 cm", "feedback": "67 is a², the squared side. The square root finishes it."}, {"text": "11.4 cm", "feedback": "The -2bc cos A term was dropped — that is Pythagoras, which needs a right angle."}]'::jsonb, 1, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 21, 'Challenge',
 'A 1.8 m person casts a 2.4 m shadow while a tree casts a 14 m shadow. How tall is the tree?',
 '[{"text": "10.8 m", "feedback": "That rounds the scale factor 14/2.4 up to 6 before multiplying. Keep it exact until the end."}, {"text": "13.4 m", "feedback": "14 - 0.6 borrows the additive gap between 1.8 and 2.4. Similar triangles scale multiplicatively."}, {"text": "10.5 m", "feedback": "Correct."}, {"text": "18.7 m", "feedback": "That scales by 14/1.8 — mixing a height with a shadow. Match shadow to shadow: the factor is 14/2.4."}]'::jsonb, 2, 'sub-similar-triangles'),
(10, 'MPM2D', 'Trigonometry', 6, 22, 'Challenge',
 'From the top of an 80 m cliff, the angle of depression to a boat is 25°. How far is the boat from the base of the cliff, to the nearest metre?',
 '[{"text": "37 m", "feedback": "That multiplied by tan 25°. The 80 m height is OPPOSITE the angle at the boat — check which side of the tan ratio it sits on."}, {"text": "189 m", "feedback": "That is the line of sight TO the boat, the hypotenuse — not the distance along the water."}, {"text": "172 m", "feedback": "Correct."}, {"text": "80 m", "feedback": "Equal height and distance needs 45°. At 25° the boat sits much farther out."}]'::jsonb, 2, 'sub-trig-side-lengths'),
(10, 'MPM2D', 'Trigonometry', 6, 23, 'Challenge',
 'A right triangle has hypotenuse 15 and one leg 9. What is the angle opposite that leg, to one decimal?',
 '[{"text": "36.9°", "feedback": "Correct."}, {"text": "53.1°", "feedback": "cos⁻¹ gives the OTHER acute angle. Opposite over hypotenuse is a sine ratio."}, {"text": "0.6°", "feedback": "0.6 is the ratio 9/15. Push it through sin⁻¹."}, {"text": "31.0°", "feedback": "tan pairs the two LEGS — but 15 is the hypotenuse. Find the other leg first, or just use sin."}]'::jsonb, 0, 'sub-trig-angles'),
(10, 'MPM2D', 'Trigonometry', 6, 24, 'Challenge',
 'In triangle ABC, angle A = 35°, angle B = 65°, and a = 10 cm. What is side c, to one decimal?',
 '[{"text": "5.8 cm", "feedback": "The proportion is upside down: c = a sin C over sin A, with the unknown side on top."}, {"text": "15.8 cm", "feedback": "That found side b. Side c pairs with angle C, which is 180 - 35 - 65 = 80°."}, {"text": "17.2 cm", "feedback": "Correct."}, {"text": "10.0 cm", "feedback": "c faces the LARGEST angle, 80°, so it must be the longest side — longer than 10."}]'::jsonb, 2, 'sub-sine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 25, 'Challenge',
 'A triangle has sides 5, 7 and 10. What is the angle opposite the 10 side, to one decimal?',
 '[{"text": "138.0°", "feedback": "The denominator is 2ab — two times 5 times 7. The 2 was dropped."}, {"text": "68.2°", "feedback": "The sign was dropped: 25 + 49 - 100 is NEGATIVE 26, and the minus is what makes the angle obtuse."}, {"text": "27.7°", "feedback": "The side OPPOSITE the wanted angle goes in the subtracted spot: 10² is subtracted, not 5²."}, {"text": "111.8°", "feedback": "Correct."}]'::jsonb, 3, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 26, 'Challenge',
 'In triangle ABC, b = 6, c = 8 and angle A = 120°. What is side a, to one decimal?',
 '[{"text": "7.2", "feedback": "cos 120° is NEGATIVE 0.5, so the correction term flips to PLUS 48. Using +0.5 shrinks the side."}, {"text": "10.0", "feedback": "The cosine term was dropped. Pythagoras only survives at exactly 90°."}, {"text": "12.2", "feedback": "Correct."}, {"text": "148.0", "feedback": "148 is a squared. Root it."}]'::jsonb, 2, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 27, 'Challenge',
 'A triangle has two known sides and the angle BETWEEN them, no right angle. Which tool finds the third side?',
 '[{"text": "The cosine law", "feedback": "Correct."}, {"text": "The Pythagorean theorem", "feedback": "Pythagoras is the 90° special case of a more general rule — its correction term has been deleted."}, {"text": "The sine law", "feedback": "The sine law needs a side paired with its OPPOSITE angle — the contained angle breaks that pairing."}, {"text": "SOH CAH TOA", "feedback": "The primary ratios need a right angle, and this triangle has none."}]'::jsonb, 0, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 28, 'Challenge',
 'In triangle ABC, angle A = 90°, and sin B = 0.6. What is cos C?',
 '[{"text": "0.8", "feedback": "That comes from a Pythagorean step the question never needed. Think about how angles B and C are related here."}, {"text": "Cannot be found without the sides", "feedback": "The complementary relationship answers it with no sides at all."}, {"text": "0.4", "feedback": "Complementary angles do not subtract ratios from 1. Look at which sides cos C actually compares."}, {"text": "0.6", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-angles'),
(10, 'MPM2D', 'Trigonometry', 6, 29, 'Challenge',
 'A 10 m ladder is safe up to 75° from the ground. What is the highest it can safely reach, to one decimal?',
 '[{"text": "37.3 m", "feedback": "tan is opposite over ADJACENT and can exceed the ladder length — impossible for a height the ladder itself reaches."}, {"text": "9.7 m", "feedback": "Correct."}, {"text": "2.6 m", "feedback": "cos 75° gives the ground distance, about 2.6 m. Height is opposite: sin."}, {"text": "10.0 m", "feedback": "Reaching the full 10 m needs the ladder vertical at 90° — past the safe limit."}]'::jsonb, 1, 'sub-trig-side-lengths'),
(10, 'MPM2D', 'Trigonometry', 6, 30, 'Challenge',
 'Two right triangles share an acute angle of 37°. One has hypotenuse 5, the other 15. How do their sin 37° values compare?',
 '[{"text": "The larger triangle has triple the sine", "feedback": "Sides scale together, so the RATIO cancels the scale factor. That is why sin 37° means anything at all."}, {"text": "They are identical — the ratio depends only on the angle", "feedback": "Correct."}, {"text": "The larger triangle has one third the sine", "feedback": "Enlarging a triangle does not shrink its ratios. Both compute opposite over hypotenuse identically."}, {"text": "They cannot be compared without the sides", "feedback": "Similarity guarantees the comparison: equal angles force equal ratios."}]'::jsonb, 1, 'sub-trig-ratios'),
(10, 'MPM2D', 'Trigonometry', 6, 31, 'Advanced',
 'From a point, the angle of elevation to the top of a tower is 30°. Moving 20 m closer, it is 45°. What is the height of the tower, to one decimal?',
 '[{"text": "12.7 m", "feedback": "The tangents SUBTRACT in the denominator: the two right triangles share the height but differ in base by 20."}, {"text": "11.5 m", "feedback": "20 tan 30° treats the 20 m as the FULL distance to the tower. It is only the gap between the two viewpoints."}, {"text": "27.3 m", "feedback": "Correct."}, {"text": "20.0 m", "feedback": "At 45° the height equals the remaining distance — which is the height itself, not the 20 m walked."}]'::jsonb, 2, 'sub-trig-side-lengths'),
(10, 'MPM2D', 'Trigonometry', 6, 32, 'Advanced',
 'In triangle ABC, angle A = 100°, a = 14 and angle B = 35°. What is b, to one decimal?',
 '[{"text": "0.6", "feedback": "That is the ratio of the two sines alone. The 14 still multiplies it."}, {"text": "24.0", "feedback": "The proportion is inverted — that value comes out LONGER than 14, impossible opposite a smaller angle."}, {"text": "10.1", "feedback": "45 is angle C, from the 180° sum — the wrong partner for side b. Side b pairs with angle B."}, {"text": "8.2", "feedback": "Correct."}]'::jsonb, 3, 'sub-sine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 33, 'Advanced',
 'A triangle has sides 8, 11 and 15. What is its SMALLEST angle, to one decimal?',
 '[{"text": "31.8°", "feedback": "That rounds the cosine ratio to two decimals before taking the inverse. Round only at the end."}, {"text": "45.6°", "feedback": "That angle faces the 11. Opposite the 8 means the 8² is the subtracted square."}, {"text": "31.3°", "feedback": "Correct."}, {"text": "103.1°", "feedback": "That is the angle opposite the 15 — the LARGEST angle. The smallest faces the shortest side, 8."}]'::jsonb, 2, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 34, 'Advanced',
 'Two roads leave a town at 50° to each other. Cars drive 40 km down one and 65 km down the other. How far apart are they, to one decimal?',
 '[{"text": "76.3 km", "feedback": "That is Pythagoras, which needs 90° between the roads. At 50° the cosine term stays."}, {"text": "20.0 km", "feedback": "Order of operations: cos 50° multiplies ONLY the 2ab term. Applying it to the whole bracket is the classic cosine law slip."}, {"text": "49.8 km", "feedback": "Correct."}, {"text": "105.0 km", "feedback": "40 + 65 lays the roads end to end. They fan out at an angle, so the gap is shorter."}]'::jsonb, 2, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 35, 'Advanced',
 'A triangle problem gives sides a and b and angle A, opposite side a. Which tool starts the solution?',
 '[{"text": "The cosine law, because two sides are known", "feedback": "Two sides feed the cosine law only WITH the contained angle. Angle A here is opposite a, which is a sine law pairing."}, {"text": "Neither — more information is needed", "feedback": "A matched pair plus one more side is exactly the sine law setup for finding angle B."}, {"text": "SOH CAH TOA", "feedback": "No right angle was given, so the primary ratios cannot apply."}, {"text": "The sine law, because a side-opposite-angle pair is known", "feedback": "Correct."}]'::jsonb, 3, 'sub-sine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 36, 'Advanced',
 'To measure a river, a surveyor makes a small right triangle with a 1 m base and matching angles to a large one across the river with a 40 m base. The small height is 0.7 m. How wide is the river?',
 '[{"text": "0.7 m", "feedback": "0.7 m is the small model. The river copies the RATIO, at 40 times the size."}, {"text": "28 m", "feedback": "Correct."}, {"text": "40.7 m", "feedback": "That ADDS a height to a base length. Similar shapes multiply by the scale factor instead."}, {"text": "57.1 m", "feedback": "That divides 40 by 0.7 — inverting the ratio. The scale factor 40 multiplies the small height."}]'::jsonb, 1, 'sub-similar-triangles'),
(10, 'MPM2D', 'Trigonometry', 6, 37, 'Advanced',
 'In a right triangle one acute angle is 45° and the hypotenuse is 12. What is each leg, to one decimal?',
 '[{"text": "12.0", "feedback": "Legs are always SHORTER than the hypotenuse."}, {"text": "6.0", "feedback": "Halving the hypotenuse works at 30°, not 45°. Each leg is 12 sin 45°, about 0.707 of it."}, {"text": "17.0", "feedback": "That divides 12 by sin 45° — but 12 is the hypotenuse, the side everything else divides INTO."}, {"text": "8.5", "feedback": "Correct."}]'::jsonb, 3, 'sub-trig-angles'),
(10, 'MPM2D', 'Trigonometry', 6, 38, 'Advanced',
 'A triangle has sides 6, 6 and 10. What is the angle between the two equal sides, to one decimal?',
 '[{"text": "146.4°", "feedback": "That is the supplement of a base angle. The apex is not what is left when a base angle is taken from 180."}, {"text": "112.9°", "feedback": "Correct."}, {"text": "33.6°", "feedback": "That is a BASE angle, opposite one of the 6 sides. The apex angle faces the 10."}, {"text": "60.0°", "feedback": "Equal sides do not force 60° — that needs all THREE sides equal."}]'::jsonb, 1, 'sub-cosine-law'),
(10, 'MPM2D', 'Trigonometry', 6, 39, 'Advanced',
 'Solving a triangle, a student computes sin B = 1.2. What does this mean?',
 '[{"text": "Angle B is obtuse", "feedback": "Obtuse angles still have sines BELOW 1. Past 1 is impossible, full stop."}, {"text": "No such triangle exists with the given measurements", "feedback": "Correct."}, {"text": "Angle B is 90°", "feedback": "sin 90° is exactly 1. Nothing pushes sine past 1."}, {"text": "The calculator must switch to radians", "feedback": "Radians change nothing here — sine never exceeds 1 in any mode."}]'::jsonb, 1, 'sub-trig-ratios'),
(10, 'MPM2D', 'Trigonometry', 6, 40, 'Advanced',
 'A kite is on a 50 m string at 62° to the horizontal, held 1.2 m above the ground. How high is the kite above the ground, to one decimal?',
 '[{"text": "24.7 m", "feedback": "cos 62° gives the horizontal reach. The vertical uses sin."}, {"text": "51.2 m", "feedback": "The string is the hypotenuse — the kite can never sit higher than string plus hand."}, {"text": "45.3 m", "feedback": "Correct."}, {"text": "44.1 m", "feedback": "The hand height ADDS: the trig gives height above the hand, and the hand is 1.2 m up."}]'::jsonb, 2, 'sub-trig-side-lengths');


-- Sanity check: expect 6 units x 4 levels x 10.
select unit, difficulty, count(*)
from questions where grade = 10
group by unit, difficulty
order by min(unit_order),
  case difficulty when 'Easy' then 0 when 'Medium' then 1
       when 'Challenge' then 2 else 3 end;


-- ===========================================================================
-- FIGURES
-- ===========================================================================
-- Runs after the questions above, in the same file, because the per-unit
-- delete wipes the figure column along with the rest of the row.
-- ===========================================================================

update questions set figure = null where grade = 10;

update questions set figure = 'figures/trig_13.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 13;
update questions set figure = 'figures/trig_14.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 14;
update questions set figure = 'figures/trig_21.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 21;
update questions set figure = 'figures/trig_22.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 22;
update questions set figure = 'figures/trig_29.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 29;
update questions set figure = 'figures/trig_31.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 31;
update questions set figure = 'figures/trig_34.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 34;
update questions set figure = 'figures/trig_36.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 36;
update questions set figure = 'figures/trig_40.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 40;
update questions set figure = 'figures/sqe_40.png'
 where grade = 10 and unit = 'Solving quadratic equations' and sort_order = 40;
update questions set figure = 'figures/sqe_29.png'
 where grade = 10 and unit = 'Solving quadratic equations' and sort_order = 29;
update questions set figure = 'figures/sqe_31.png'
 where grade = 10 and unit = 'Solving quadratic equations' and sort_order = 31;
update questions set figure = 'figures/sqe_36.png'
 where grade = 10 and unit = 'Solving quadratic equations' and sort_order = 36;
update questions set figure = 'figures/trig_2.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 2;
update questions set figure = 'figures/trig_11.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 11;
update questions set figure = 'figures/trig_6.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 6;
update questions set figure = 'figures/trig_8.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 8;
update questions set figure = 'figures/trig_15.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 15;
update questions set figure = 'figures/trig_16.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 16;
update questions set figure = 'figures/trig_17.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 17;
update questions set figure = 'figures/trig_23.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 23;
update questions set figure = 'figures/trig_28.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 28;
update questions set figure = 'figures/trig_37.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 37;
update questions set figure = 'figures/trig_18.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 18;
update questions set figure = 'figures/trig_19.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 19;
update questions set figure = 'figures/trig_20.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 20;
update questions set figure = 'figures/trig_24.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 24;
update questions set figure = 'figures/trig_25.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 25;
update questions set figure = 'figures/trig_26.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 26;
update questions set figure = 'figures/trig_32.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 32;
update questions set figure = 'figures/trig_33.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 33;
update questions set figure = 'figures/trig_38.png'
 where grade = 10 and unit = 'Trigonometry' and sort_order = 38;
update questions set figure = 'figures/ag_27.png'
 where grade = 10 and unit = 'Analytic geometry' and sort_order = 27;

-- Check: every figure attached, and none orphaned.
select unit, sort_order, figure from questions
 where grade = 10 and figure is not null
 order by unit, sort_order;
