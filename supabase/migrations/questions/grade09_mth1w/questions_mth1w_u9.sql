-- ===========================================================================
-- MTH1W — Unit 9: Financial Literacy — 40 questions
-- ===========================================================================
-- Authored from the Jensen MTH1W lesson solutions for this unit:
--
--   Lesson 1  Simple interest
--   Lesson 2  Compound interest
--   Lesson 3  Appreciation and depreciation
--   Lesson 4  Budgeting
--   Lesson 5  Payment options and loan repayment
--
-- Every money figure in this file was recomputed rather than copied, because
-- two of the worked solutions in the source contain slips: the Rory example
-- in Lesson 1 solves for the total amount as though it were the interest,
-- and one of the Lesson 2 comparison tables is captioned semi-annual when
-- the rate shown is quarterly. The questions here use the corrected values.
--
-- The distractors are the slips the worked solutions keep correcting:
-- returning the total amount when the question asked for the interest,
-- applying a percentage rate to the ORIGINAL value every year instead of to
-- the current one, and dividing a loan principal by the number of payments
-- as though borrowing were free.
--
-- RUN ORDER: supabase_full_setup.sql -> this file. Safe to re-run on its own.
-- Levels: 1-10 Easy, 11-20 Medium, 21-30 Challenge, 31-40 Advanced.
-- No apostrophes anywhere in any string.
-- ===========================================================================

delete from questions where course_code = 'MTH1W' and unit = 'Financial literacy';

insert into misconception_labels (tag, label) values
  ('sub-simple-interest',    'Simple interest'),
  ('sub-compound-interest',  'Compound interest'),
  ('sub-appreciation',       'Appreciation and depreciation'),
  ('sub-budgeting',          'Budgeting'),
  ('sub-payment-options',    'Loans, credit and repayment')
on conflict (tag) do update set label = excluded.label;

insert into questions
  (grade, course_code, unit, unit_order, sort_order, difficulty,
   prompt, options, correct_index, misconception_tag)
values

-- ---------------------------------------------------------------------------
-- EASY (1-10)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 1, 'Easy',
 'Calculate the simple interest on a loan of 10000 dollars at 5 percent per annum for 6 years.',
 '[{"text": "300 dollars", "feedback": "The rate was used as 0.005 rather than 0.05. Five percent is five hundredths."},
   {"text": "3000 dollars", "feedback": "Correct."},
   {"text": "500 dollars", "feedback": "That is one year of interest. The loan runs for six."},
   {"text": "13000 dollars", "feedback": "That is the total owed at the end. The question asks for the interest alone."}]'::jsonb,
 1, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 2, 'Easy',
 'In the simple interest formula I = P x r x t, what does P stand for?',
 '[{"text": "The percentage charged for the use of the money", "feedback": "That is r, the rate, which is written as a decimal."},
   {"text": "The principal, the amount invested or borrowed at the start", "feedback": "Correct."},
   {"text": "The profit made on the investment once it is cashed in", "feedback": "The profit is the interest itself, which is what the formula works out."},
   {"text": "The payment made each month until the whole loan is paid off", "feedback": "Monthly payments belong to a repayment formula. This one has no payments in it."}]'::jsonb,
 1, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 3, 'Easy',
 'Which formula gives the amount in an account when interest is compounded once a year?',
 '[{"text": "A = P(1 + r)^t", "feedback": "Correct."},
   {"text": "A = P(1 + rt)", "feedback": "That is the simple interest version, where the interest never earns interest of its own."},
   {"text": "A = P + rt", "feedback": "That adds a fixed dollar amount each year, which is linear growth rather than compounding."},
   {"text": "A = P(1 - r)^t", "feedback": "The minus sign shrinks the balance. That version models depreciation."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 4, 'Easy',
 'What is 1000 dollars worth after 3 years at 5 percent compounded annually?',
 '[{"text": "1157.63 dollars", "feedback": "Correct."},
   {"text": "1102.50 dollars", "feedback": "That is the balance after only two years."},
   {"text": "3375.00 dollars", "feedback": "The rate was applied as 50 percent rather than 5 percent."},
   {"text": "1150.00 dollars", "feedback": "That is simple interest. Under compounding, each year the interest earns interest too."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 5, 'Easy',
 'Which of these is an example of depreciation?',
 '[{"text": "Gold rising in value", "feedback": "Rising value is appreciation. Depreciation goes the other way."},
   {"text": "A new car losing value every year it is driven", "feedback": "Correct."},
   {"text": "A savings account earning interest", "feedback": "A growing balance is a kind of appreciation."},
   {"text": "A house rising in value over ten years", "feedback": "Rising value is appreciation. Depreciation goes the other way."}]'::jsonb,
 1, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 6, 'Easy',
 'A rookie card is worth 100 dollars now and is expected to gain 20 dollars in value every year. Which equation models its value after t years?',
 '[{"text": "A = 100 + 20t", "feedback": "Correct."},
   {"text": "A = 100(1.20)^t", "feedback": "That grows by 20 PERCENT each year. Here the gain is a fixed 20 dollars."},
   {"text": "A = 100 - 20t", "feedback": "The minus sign makes the value fall. This card is gaining value."},
   {"text": "A = 20 + 100t", "feedback": "The starting value and the yearly gain have swapped places."}]'::jsonb,
 0, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 7, 'Easy',
 'Which of these is a fixed expense in a monthly budget?',
 '[{"text": "A weekend trip", "feedback": "That is discretionary. You can cut it back without losing anything essential."},
   {"text": "Rent", "feedback": "Correct."},
   {"text": "Dining out", "feedback": "That is discretionary. You can cut it back without losing anything essential."},
   {"text": "Concert tickets", "feedback": "That is discretionary. You can cut it back without losing anything essential."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 8, 'Easy',
 'Max has a monthly income of 1146.99 dollars and monthly expenses of 900 dollars. What is his net profit for the month?',
 '[{"text": "2046.99 dollars", "feedback": "The two figures were added. Net profit subtracts expenses from income."},
   {"text": "900.00 dollars", "feedback": "That is what he spends, not what he has left."},
   {"text": "246.99 dollars", "feedback": "Correct."},
   {"text": "-246.99 dollars", "feedback": "The subtraction went the wrong way round. His income is larger than his expenses."}]'::jsonb,
 2, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 9, 'Easy',
 'In the monthly loan payment formula, what does r stand for?',
 '[{"text": "The total amount repaid by the end of the loan", "feedback": "That is what the formula helps you work out, not one of its inputs."},
   {"text": "The annual interest rate, the percentage charged for a year", "feedback": "The payments happen monthly, so the rate has to be scaled down to match them."},
   {"text": "The monthly interest rate, which is the annual rate divided by 12", "feedback": "Correct."},
   {"text": "The number of payments to be made across the whole term of the loan", "feedback": "That is n, the loan term counted in months."}]'::jsonb,
 2, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 10, 'Easy',
 'Why is cash or debit usually a better choice than credit for buying groceries?',
 '[{"text": "Because you spend only money you already have and pay no interest", "feedback": "Correct."},
   {"text": "Because debit cards give more rewards than credit cards", "feedback": "Rewards are usually a credit card feature. The advantage of debit lies elsewhere."},
   {"text": "Because credit cards never charge interest", "feedback": "They do charge interest on any balance not paid off in full."},
   {"text": "Because debit builds your credit score faster", "feedback": "Building a credit score is actually an argument FOR responsible credit card use."}]'::jsonb,
 0, 'sub-payment-options'),

-- ---------------------------------------------------------------------------
-- MEDIUM (11-20)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 11, 'Medium',
 'Max invests 3240 dollars at 2.4 percent simple interest. How much interest does he earn in 20 years?',
 '[{"text": "155.52 dollars", "feedback": "The rate was used as 0.0024 rather than 0.024."},
   {"text": "77.76 dollars", "feedback": "That is one year of interest. The investment runs for twenty."},
   {"text": "1555.20 dollars", "feedback": "Correct."},
   {"text": "4795.20 dollars", "feedback": "That is the total value of the investment. The question asks for the interest alone."}]'::jsonb,
 2, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 12, 'Medium',
 'Rory invests 750 dollars at 10 percent per annum simple interest. How long until his investment is worth 1000 dollars?',
 '[{"text": "0.3 years", "feedback": "The rate was left out of the division. Interest is principal times rate times time."},
   {"text": "13.3 years", "feedback": "The whole 1000 was treated as interest. Only the 250 dollar GAIN is interest."},
   {"text": "2.5 years", "feedback": "The final value of 1000 was used as the principal. The principal is the amount actually invested."},
   {"text": "3.3 years", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 13, 'Medium',
 'What is 1000 dollars worth after 1 year at 6 percent compounded monthly?',
 '[{"text": "1060.90 dollars", "feedback": "That is the semi-annual result, where interest is added only twice."},
   {"text": "1061.36 dollars", "feedback": "That is the quarterly result, where interest is added four times."},
   {"text": "1061.68 dollars", "feedback": "Correct."},
   {"text": "1060.00 dollars", "feedback": "That is simple interest for the year. Compounding monthly adds a little more."}]'::jsonb,
 2, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 14, 'Medium',
 'At the same annual rate, which compounding frequency leaves you with the most money?',
 '[{"text": "Quarterly", "feedback": "That beats annual compounding, but there is a more frequent option on the list."},
   {"text": "They all give exactly the same amount", "feedback": "More frequent compounding means each period starts with a slightly larger balance."},
   {"text": "Daily", "feedback": "Correct."},
   {"text": "Annually", "feedback": "That adds interest only once a year, so the interest has the least chance to earn interest of its own."}]'::jsonb,
 2, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 15, 'Medium',
 'A car bought for 30000 dollars depreciates by 2000 dollars every year. How long until it is worth 10000 dollars?',
 '[{"text": "10 years", "feedback": "Correct."},
   {"text": "20 years", "feedback": "That is the size of the drop in dollars, not the number of years it takes."},
   {"text": "5 years", "feedback": "After that long the car would still be worth twice the target value."},
   {"text": "15 years", "feedback": "That divides the purchase price by the yearly loss. Only the DROP of 20000 has to be covered."}]'::jsonb,
 0, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 16, 'Medium',
 'A car worth 30000 dollars new is worth 21000 dollars after one year. By what percentage did it depreciate?',
 '[{"text": "21 percent", "feedback": "That reads the remaining value in thousands as a percentage."},
   {"text": "70 percent", "feedback": "That is the percentage of its value the car KEEPS. The question asks how much it lost."},
   {"text": "30 percent", "feedback": "Correct."},
   {"text": "9 percent", "feedback": "That is the drop in thousands of dollars, not a percentage of the original price."}]'::jsonb,
 2, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 17, 'Medium',
 'Arthur has a monthly income of 2100 dollars and monthly expenses totalling 2185 dollars. Is his budget balanced?',
 '[{"text": "No, he has a surplus of 85 dollars", "feedback": "The subtraction went the wrong way. His expenses are the larger of the two."},
   {"text": "No, he has a deficit of 185 dollars", "feedback": "Check the subtraction. The gap between the two totals is smaller than that."},
   {"text": "No, he has a deficit of 85 dollars", "feedback": "Correct."},
   {"text": "Yes, it is exactly balanced", "feedback": "The two totals differ. Subtract one from the other."}]'::jsonb,
 2, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 18, 'Medium',
 'Arthur needs to close an 85 dollar monthly gap. Which adjustment cuts only discretionary spending?',
 '[{"text": "Move somewhere with cheaper monthly rent", "feedback": "Rent is a fixed expense. It is not easy to minimise month to month."},
   {"text": "Cancel the car insurance he pays for every month", "feedback": "Insurance is a fixed expense, and cancelling it creates a much larger risk."},
   {"text": "Cut the amount of money he spends on food each month in half", "feedback": "Food is treated as a fixed expense, because it is essential."},
   {"text": "Reduce his entertainment and gym membership spending", "feedback": "Correct."}]'::jsonb,
 3, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 19, 'Medium',
 'Sarah borrows 15000 dollars at 6 percent compounded monthly over a 5 year term. What is her monthly payment?',
 '[{"text": "312.50 dollars", "feedback": "That spreads the loan over four years rather than five, and still ignores the interest."},
   {"text": "325.00 dollars", "feedback": "Five years of simple interest was added at the start rather than compounding on the falling balance."},
   {"text": "250.00 dollars", "feedback": "That divides the loan by the number of payments, which ignores the interest completely."},
   {"text": "289.99 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 20, 'Medium',
 'Jacob borrows 12000 dollars and repays it at 381.60 dollars a month for 3 years. How much does he repay in total?',
 '[{"text": "13737.60 dollars", "feedback": "Correct."},
   {"text": "4579.20 dollars", "feedback": "That is one year of payments. The term runs for three years."},
   {"text": "12000.00 dollars", "feedback": "That is only the amount he borrowed. The payments come to more than that."},
   {"text": "1737.60 dollars", "feedback": "That is the interest portion. The question asks for everything he hands over."}]'::jsonb,
 0, 'sub-payment-options'),

-- ---------------------------------------------------------------------------
-- CHALLENGE (21-30)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 21, 'Challenge',
 'How long does 2000 dollars have to sit at 4 percent simple interest to earn 560 dollars in interest?',
 '[{"text": "14 years", "feedback": "The rate was halved somewhere. Divide the interest by the principal times the rate."},
   {"text": "7 years", "feedback": "Correct."},
   {"text": "3.5 years", "feedback": "The rate was doubled somewhere. Divide the interest by the principal times the rate."},
   {"text": "28 years", "feedback": "The rate was read as 1 percent rather than 4 percent. Divide the interest by the principal times the rate."}]'::jsonb,
 1, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 22, 'Challenge',
 'An investment of 1200 dollars grows to 1560 dollars in 5 years under simple interest. What is the annual rate?',
 '[{"text": "26 percent", "feedback": "The whole 1560 was treated as interest. Only the growth above the original investment is interest."},
   {"text": "3 percent", "feedback": "The gain was halved somewhere in the division."},
   {"text": "30 percent", "feedback": "That is the total percentage gain across all five years, not the annual rate."},
   {"text": "6 percent", "feedback": "Correct."}]'::jsonb,
 3, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 23, 'Challenge',
 'Bank A offers 4.8 percent compounded quarterly and Bank B offers 4.6 percent compounded monthly. For 5000 dollars over 3 years, which is better and by roughly how much?',
 '[{"text": "Bank B, by about 31 dollars", "feedback": "The more frequent compounding does not make up for the lower rate here."},
   {"text": "Bank A, by about 31 dollars", "feedback": "Correct."},
   {"text": "Bank A, by about 200 dollars", "feedback": "The direction is right, but the gap between the two is far smaller than that."},
   {"text": "They come out the same", "feedback": "Work each one out separately. The two totals differ by a modest amount."}]'::jsonb,
 1, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 24, 'Challenge',
 'You need 3000 dollars in 3 years. An account pays 3.2 percent compounded monthly. How much do you need to invest now?',
 '[{"text": "2712.00 dollars", "feedback": "That subtracts three years of simple interest instead of dividing by the growth factor."},
   {"text": "2905.64 dollars", "feedback": "Only one year of growth was divided out. The money has three years to grow."},
   {"text": "3300.00 dollars", "feedback": "That grows the target instead of working backwards from it. You need LESS than 3000 today."},
   {"text": "2725.74 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 25, 'Challenge',
 'A car bought for 30000 dollars keeps 70 percent of its value each year. What is it worth after 10 years?',
 '[{"text": "847.43 dollars", "feedback": "Correct."},
   {"text": "0 dollars", "feedback": "That treats the loss as a fixed 30 percent of the ORIGINAL price each year. It is 30 percent of the CURRENT value."},
   {"text": "21000.00 dollars", "feedback": "That is its value after one year."},
   {"text": "1210.61 dollars", "feedback": "That is its value after nine years. One more year of depreciation is still to come."}]'::jsonb,
 0, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 26, 'Challenge',
 'Over 10 years, which grows more: 100 dollars gaining 20 dollars a year, or 100 dollars gaining 20 percent a year?',
 '[{"text": "The fixed 20 dollars a year", "feedback": "A fixed gain adds the same amount every year. A percentage gain grows along with the value."},
   {"text": "They reach the same value", "feedback": "They match in the first year only. After that the percentage version pulls ahead."},
   {"text": "The percentage, but only after about 20 years", "feedback": "The crossover comes much sooner than that. Work out both at 10 years."},
   {"text": "The percentage, reaching about 619 dollars against 300 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 27, 'Challenge',
 'Max earns 1146.99 dollars a month and wants to save 20 percent of it. His rent is 500, food 250 and transport 50 dollars. How much is left for discretionary spending?',
 '[{"text": "232.29 dollars", "feedback": "Only 10 percent was set aside. He wants to save twice that."},
   {"text": "117.59 dollars", "feedback": "Correct."},
   {"text": "2.89 dollars", "feedback": "30 percent was set aside rather than 20."},
   {"text": "346.99 dollars", "feedback": "The savings were never set aside. Twenty percent of his income has to come off as well."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 28, 'Challenge',
 'Why should every dollar of income be accounted for in a budget, even the leftover money?',
 '[{"text": "So that income always works out to exactly zero on paper", "feedback": "The aim is not to reach zero. It is to give every dollar a job."},
   {"text": "Because fixed expenses change from one month to the next", "feedback": "Fixed expenses are the ones that stay steady. That is what makes them fixed."},
   {"text": "Because banks require you to hand in a complete budget before they will open an account", "feedback": "No bank asks for this. The reason is about your own money, not theirs."},
   {"text": "So that the leftover money is deliberately saved or invested rather than quietly spent", "feedback": "Correct."}]'::jsonb,
 3, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 29, 'Challenge',
 'Emma owes 5000 dollars on a credit card charging 18 percent compounded monthly. She plans to clear it in 2 years with equal monthly payments. What is each payment?',
 '[{"text": "249.62 dollars", "feedback": "Correct."},
   {"text": "283.33 dollars", "feedback": "That charges 18 percent on the full balance for both years. The balance falls as she pays it down."},
   {"text": "312.50 dollars", "feedback": "That spreads the debt over sixteen months rather than twenty-four, and still ignores the interest."},
   {"text": "208.33 dollars", "feedback": "That divides the balance by the number of payments, which ignores the interest completely."}]'::jsonb,
 0, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 30, 'Challenge',
 'Emma pays 249.62 dollars a month for 24 months to clear a 5000 dollar credit card balance. Roughly how much interest does she pay?',
 '[{"text": "About 900 dollars", "feedback": "Close, but work it out exactly: total the payments, then take off what she borrowed."},
   {"text": "About 1800 dollars", "feedback": "That charges 18 percent on the full 5000 for both years. The balance shrinks as she pays."},
   {"text": "None, because she clears the balance in full", "feedback": "Clearing a balance over time still costs interest along the way. Only paying immediately avoids it."},
   {"text": "About 990 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-payment-options'),

-- ---------------------------------------------------------------------------
-- ADVANCED (31-40)
-- ---------------------------------------------------------------------------

(9, 'MTH1W', 'Financial literacy', 9, 31, 'Advanced',
 'How long does any amount of money take to double at 5 percent simple interest?',
 '[{"text": "14 years", "feedback": "That rule of thumb belongs to COMPOUND interest. Simple interest takes longer."},
   {"text": "5 years", "feedback": "That copies the rate. Doubling means the interest has to grow to equal the principal."},
   {"text": "20 years", "feedback": "Correct."},
   {"text": "10 years", "feedback": "After that long the interest would equal only half the original amount."}]'::jsonb,
 2, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 32, 'Advanced',
 'Compare 5000 dollars over 10 years at 6 percent simple interest against 6 percent compounded annually. What is the difference?',
 '[{"text": "Compounding wins by about 3000 dollars", "feedback": "That is the whole simple interest amount, not the gap between the two methods."},
   {"text": "Simple interest wins by about 954 dollars", "feedback": "Compounding lets the interest earn interest, so it is the larger of the two."},
   {"text": "Compounding wins by about 954 dollars", "feedback": "Correct."},
   {"text": "They come out equal, because the rate is the same", "feedback": "The rate matches, but simple interest never pays interest on the interest already earned."}]'::jsonb,
 2, 'sub-simple-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 33, 'Advanced',
 'What is 2000 dollars worth after 4 years at 5 percent compounded quarterly?',
 '[{"text": "2439.78 dollars", "feedback": "Correct."},
   {"text": "2400.00 dollars", "feedback": "That is simple interest. Compounding adds a little more."},
   {"text": "2431.01 dollars", "feedback": "That compounds only once a year. Quarterly means four times."},
   {"text": "2441.79 dollars", "feedback": "That compounds monthly, which is more often than the question asks."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 34, 'Advanced',
 'If you double how often interest is compounded per year, does the interest you earn double?',
 '[{"text": "No, the gain is much smaller than that", "feedback": "Correct."},
   {"text": "It depends entirely on the size of the principal", "feedback": "The principal scales everything equally, so it does not change the comparison."},
   {"text": "Yes, exactly", "feedback": "The annual rate is split across more periods, so each period pays proportionally less."},
   {"text": "No, the interest is halved instead", "feedback": "More frequent compounding never lowers the total. It raises it slightly."}]'::jsonb,
 0, 'sub-compound-interest'),

(9, 'MTH1W', 'Financial literacy', 9, 35, 'Advanced',
 'A house bought for 400000 dollars appreciates at 4 percent a year. What is it worth after 12 years, to the nearest dollar?',
 '[{"text": "592000 dollars", "feedback": "That adds 4 percent of the ORIGINAL price twelve times. Each year the percentage applies to the current value."},
   {"text": "416000 dollars", "feedback": "That is the value after one year only."},
   {"text": "615782 dollars", "feedback": "That compounds for eleven years rather than twelve."},
   {"text": "640413 dollars", "feedback": "Correct."}]'::jsonb,
 3, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 36, 'Advanced',
 'A laptop bought for 1500 dollars depreciates 25 percent a year. After how many whole years is it worth less than 500 dollars?',
 '[{"text": "3 years", "feedback": "Work out the value at that point: it is still above the 500 dollar mark, though not by much."},
   {"text": "4 years", "feedback": "Correct."},
   {"text": "5 years", "feedback": "It drops below the mark before that, so this is one year later than needed."},
   {"text": "2 years", "feedback": "After that long it is still worth well over 800 dollars."}]'::jsonb,
 1, 'sub-appreciation'),

(9, 'MTH1W', 'Financial literacy', 9, 37, 'Advanced',
 'Someone earns 3200 dollars a month but spends 3400 dollars. What is the most sensible first step?',
 '[{"text": "Stop paying rent until the budget recovers", "feedback": "Rent is a fixed expense with serious consequences if it goes unpaid."},
   {"text": "Cut discretionary spending such as dining out and entertainment", "feedback": "Correct."},
   {"text": "Nothing, a small monthly deficit is not a problem", "feedback": "A deficit repeats every month, so it compounds into a large shortfall over a year."},
   {"text": "Put the 200 dollar shortfall on a credit card each month", "feedback": "That turns a monthly gap into a growing debt that charges interest on top."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 38, 'Advanced',
 'A budget shows a surplus of 400 dollars a month. What is the best use of it?',
 '[{"text": "Nothing, a surplus means the budget was worked out wrongly", "feedback": "A surplus is the goal of a healthy budget, not an error in it."},
   {"text": "Save or invest it so it earns interest and covers unexpected costs", "feedback": "Correct."},
   {"text": "Leave it sitting in the chequing account and do not record it", "feedback": "Unrecorded money tends to get spent without a decision being made about it."},
   {"text": "Raise discretionary spending until the surplus is used up", "feedback": "That converts a real advantage into ordinary spending and leaves nothing for emergencies."}]'::jsonb,
 1, 'sub-budgeting'),

(9, 'MTH1W', 'Financial literacy', 9, 39, 'Advanced',
 'Sarah could take her 15000 dollar loan at 6 percent compounded monthly over 7 years instead of 5. What happens?',
 '[{"text": "Both the monthly payment and the total interest fall", "feedback": "Stretching a loan out means the balance carries interest for longer, so the total cost goes up."},
   {"text": "Both the monthly payment and the total interest rise", "feedback": "Spreading the same principal over more payments makes each one smaller, not larger."},
   {"text": "The monthly payment falls and the total interest stays the same", "feedback": "Interest is charged on the outstanding balance each month, so more months means more interest."},
   {"text": "The monthly payment falls but the total interest paid rises", "feedback": "Correct."}]'::jsonb,
 3, 'sub-payment-options'),

(9, 'MTH1W', 'Financial literacy', 9, 40, 'Advanced',
 'Jacob borrows 12000 dollars at 9 percent compounded monthly for 3 years, paying 381.60 dollars a month. How much interest does he pay in total?',
 '[{"text": "13737.60 dollars", "feedback": "That is everything he hands over. The interest is what is left after the loan itself is taken off."},
   {"text": "1080.00 dollars", "feedback": "That is one year of interest on the full balance. The loan runs for three years."},
   {"text": "1737.60 dollars", "feedback": "Correct."},
   {"text": "3240.00 dollars", "feedback": "That charges 9 percent on the full 12000 for all three years. The balance falls with every payment."}]'::jsonb,
 2, 'sub-payment-options');

select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions where course_code = 'MTH1W' and unit = 'Financial literacy'
group by difficulty order by min(sort_order);
