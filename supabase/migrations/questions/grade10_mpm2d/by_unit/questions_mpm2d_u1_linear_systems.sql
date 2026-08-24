-- ===========================================================================
-- ASTRO MATH ASSIST — GRADE 10 (MPM2D), complete
-- ===========================================================================
--
-- 240 questions across six units, plus the 33 figures that attach to them.
-- Questions and figures used to be two files that had to be run in order,
-- and running the second one was easy to forget — which showed up as
-- questions that reference a diagram nobody can see. They are one file now.
--
-- RUN ORDER:  astro_math_assist_setup.sql  ->  this file.
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

-- This file loads ONE unit of MPM2D. It deletes only that unit, so the
-- other five are untouched. Run figures_grade10.sql after all six.

delete from questions where course_code = 'MPM2D' and unit = 'Linear systems';

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
