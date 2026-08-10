# TESTING — Ontario Math Tutor

Covers all eight phases, all in the merged setup file.

Work top to bottom. If a step fails, stop there — later steps assume the
earlier ones passed.

Roughly 30 minutes for Part A through E.

---

## Before you start

Two accounts make this much easier. Create them as you go:

| Account | Purpose |
|---|---|
| `test-g12@…` | Grade 12, the main test account |
| `test-g9@…` | Grade 9, to prove grades are isolated |

Use real-looking addresses you control, or turn off email confirmation:
Supabase → Authentication → Sign In / Providers → Email → uncheck
**Confirm email**. Turn it back on before real students use this.

Keep two browser windows open: the app, and the Supabase SQL editor.

---

## Part A — Database setup

**A1. Run the setup file.**
SQL Editor → paste `supabase_full_setup.sql` → Run.

Expect two result grids. The first should be five rows, every one with
`rowsecurity = true`:

```
attempts, classes… no — expect exactly:
attempts | true
profiles | true
progress_resets | true
questions | true
unit_mastery | true
```

The second should list five function names: `award_medal`, `list_questions`,
`list_units`, `reset_progress`, `submit_answer`.

❌ *If you get "relation already exists"* — harmless, it means part of it was
already there. Read the error to check it is not something else.

**A2. Load the questions.**
SQL Editor → paste `questions_all_tagged.sql` → Run.

Expect 20 rows, and in every single one `questions = 10` and `tagged = 10`.
If `tagged` is ever less than `questions`, a tag went missing.

The second grid lists the tag vocabulary. Skim it for a slug that appears
once when it should appear twice — that usually means a typo.

**A3. Prove the security fix at the database level.**

This is the most important query in the file. Run it in the SQL editor:

```sql
select count(*) from questions;
```

That works, because the SQL editor runs as the owner. Now check what a
*student* can do — Supabase does not make this easy from the editor, so this
one is verified from the browser in step D4 instead. Do not skip D4.

**A4. Confirm the ramp is server-side.**

```sql
select sort_order, difficulty
from list_questions(12, 'Polynomial functions');
```

Expect ten rows, difficulty reading `Easy, Easy, Easy, Medium, Medium,
Medium, Medium, Hard, Hard, Hard` — in that order. Also confirm there is **no
`correct_index` column and no `feedback` key** anywhere in the output. The
options column should contain only `text`.

---

## Part B — Accounts and grades

**B1. Register.** Open the app. Create `test-g12@…` with grade **12**.
You should land in the app, not on a "check your email" screen.

**B2. Check the profile row.**

```sql
select id, email, grade from profiles order by created_at desc limit 5;
```

Your new account should be there with `grade = 12`.

**B3. Unit chips.** Five chips: Polynomial functions, Rational functions,
Exponential and logarithmic functions, Trigonometric functions (radians),
Rates of change and combining functions.

❌ *No chips at all* → `list_units` is not granted, or the questions did not
load. Re-run A2.

**B4. Change grade.** "…" menu → **Change grade** → Grade 9. Chips should
switch to the MTH1W units. Switch back to 12.

**B5. Prove it persisted.** Sign out, sign back in. Still Grade 12.
This is the test that separates "changed on screen" from "saved".

---

## Part C — The quiz, scoring and the ramp

**C1. Difficulty order.** Open Polynomial functions. Question 1 should show
**Easy**. Tap through — the difficulty pips at the top should never go
backwards.

**C2. Wrong answer behaviour.** Tap a wrong option. It should:
- strike through and grey out
- become untappable
- show feedback naming the mistake
- **not** reveal which option is correct

**C3. Keep trying.** Tap another wrong one. Same again. The correct answer
must stay hidden until you actually find it.

**C4. First-try scoring.** Start a fresh unit. Answer the first question
correctly on the **first** tap. Answer the second one wrong first, then
right. Finish the unit by any means.

The score should count only the first-try ones. If you got exactly one of
the first two right on the first tap, the score cannot be 2.

**C5. Feedback tone.** Read three or four feedback messages. None of them
should contain the correct answer. This is the product thesis — if a
distractor's feedback gives the answer away, that question needs rewriting.

---

## Part D — Progress, resume and the security fix

**D1. Attempts are being written.**

```sql
select unit, sort_order, chosen_index, was_correct,
       was_first_attempt, misconception_tag, answered_at
from attempts
order by answered_at desc
limit 10;
```

Expect a row per tap. Check specifically:
- `was_first_attempt` is `true` only on the first tap of each question
- `misconception_tag` is filled on wrong rows and **null** on correct ones

❌ *Tag null on a wrong row* → that question is untagged. Check A2.

**D2. Resume.** Answer 3 questions in a unit. **Close the tab entirely.**
Reopen the app and sign in.

You should land straight inside that unit, on question 4, without picking
anything. The "Pick up where you left off" card should have appeared if you
were on the unit list.

**D3. Chip counter.** Go back to the unit list. That unit's chip should read
`3/10`.

**D4. The security fix — do not skip this.**

In the app, open DevTools (**Cmd+Option+I**) → **Network** tab. Tap an answer.
Find the `submit_answer` request and open its **Response**.

You should see exactly three things: `was_correct`, `was_first`, and one
`feedback` string.

Now find the earlier `list_questions` request and read its response.

✅ **Pass:** options contain only `text`. No `correct_index` anywhere. No
`feedback` for any option.

❌ **Fail:** if you can see `correct_index` or all four feedback strings, the
app is still reading the questions table directly — the Dart file did not get
replaced, or the setup file did not run.

**D5. Grades are isolated.** Sign out. Register `test-g9@…` as Grade 9. Its
chips and progress should be completely independent — no medals, no resume
card, no counters carried over.

---

## Part E — Medals and reset

**E1. Bronze.** Sign back in as the Grade 12 account. Finish a unit, tapping
some wrong answers deliberately so you score under 7/10.

Expect a **Bronze** disc animating in on the results screen, and the line
"Silver needs 7 of 10 on the first try."

**E2. It saved.**

```sql
select unit, medal, best_first_try, total_questions,
       hard_first_try, hard_total, times_completed
from unit_mastery
order by updated_at desc;
```

**E3. Medals only go up.** Redo the *same* unit and do **worse** — get most
wrong on the first tap. Finish it.

✅ **Pass:** the chip still shows Bronze. `times_completed` went to 2.
`medal` did not drop.

❌ **Fail:** if the medal disappeared, `award_medal` is overwriting instead of
comparing.

**E4. Silver.** Redo it and get 7, 8 or 9 right on the first tap. Should
upgrade to Silver, and the chip should update without a reload.

**E5. Gold needs the hard ones.** Get 9/10 first try but deliberately miss
one of the three **Hard** questions on the first tap.

✅ **Pass:** you get **Silver**, not Gold. Gold requires every Hard question
first try — this is the rule that stops a student bailing before question
eight and still looking strong.

**E6. Mastery header.** The bar above the chips should read "1 of 5 units
earned a medal", with one dot per unit and hollow rings for the rest.

**E7. Revisit shelf.** With at least one Bronze unit, the amber shelf should
appear saying that unit is worth another look. Earn Silver on it — the shelf
should drop it.

**E8. Soft reset.** "…" menu → **Reset my progress** → read the dialog →
Start again.

Then check both of these:

```sql
-- Position cleared: a reset row exists
select * from progress_resets;

-- But nothing was deleted
select count(*) from attempts;
```

✅ **Pass:** chips are back to zero, resume card gone, **medals still there**,
and the attempts count is unchanged from before the reset.

❌ **Fail:** if the attempts count dropped, something is deleting instead of
timestamping.

**E9. Reset is per grade.** Switch to Grade 9, do a couple of questions,
switch back to 12 and reset. Grade 9 progress should be untouched.

---

## Part F — Things that should fail

Quick, and the ones most likely to catch a real bug.

**F1. Double tap.** Tap the same wrong option twice fast. Only one attempt row
should be written.

**F2. Tap during grading.** Tap two different options in quick succession.
The second should be ignored while the first is in flight.

**F3. Offline.** DevTools → Network → set throttling to **Offline**. Tap an
answer. You should get "That answer could not be sent" — not a frozen screen
and not a silently accepted answer.

**F4. Refresh mid-question.** Answer 2 of 10, refresh the page. You should
return to question 3 with the count intact.

---

## Deploy check

Once A–F pass:

```bash
cd ~/Desktop/math_tutor
flutter build web --base-href /
open ~/Desktop/math_tutor/build/web
```

Drag the **`web`** folder to Netlify → Deploys. Then **Cmd+Shift+R** on the
live site — a normal reload serves the cached old build.

Re-run **D4** on the deployed site. It is the one test worth doing twice.

---

## Teacher and class tests

Everything is in the merged setup file now, so no extra SQL to run.

**T1. Create an access code.** SQL editor, once:
```sql
insert into teacher_invite_codes (code, label, max_uses)
values ('FAMILY-2026', 'set up by uncle', 5);
```

**T2. Become a teacher.** Register a fresh account, then **… → I am a teacher**
→ enter the code. The screen should switch to the dashboard with no sign-out.

**T3.** ❗ **As a student**, try a made-up code. Should say "That code is not
valid" — and the same message whether the code is unknown, spent or expired,
so nobody can probe for which codes exist.

**T4. Create a class**, note the join code.

**T5. Join it** from a student account: **… → My classes → Class code → Join**.

**T6.** The student's account bar should now read "… · in 1 class". A student
should never have to go looking to learn a teacher can see their work.

**T7. Invite by email** from the teacher side. The student should get an
invitation card on their front screen naming the teacher.

**T8.** ❗ Before they accept, check the roster. ✅ **Pass: they are not on it.**
Inviting is not enrolling.

**T9. Accept**, then reload the roster. They appear with real counts.

**T10. Mistakes tab.** Should rank misconceptions in plain English with how
many students hit each. This is the payoff — if it is thin, generate more
wrong answers first.

**T11.** ❗ **Student leaves the class.** Roster should empty immediately.

## Parent report tests

**P1.** As a student: **… → Weekly reports** → add an email. It should appear
as **waiting for them to agree**, not active.

**P2.** In the SQL editor:
```sql
select count(*) from reports_due(date_trunc('week', now())::date);
```
✅ **Pass: zero.** Pending is not consent.

**P3.** Confirm it manually, then re-check:
```sql
select confirm_report_recipient((select consent_token from report_recipients));
select count(*) from reports_due(date_trunc('week', now())::date);
```
Now one row, provided the student practised this week.

**P4. Read the payload.**
```sql
select jsonb_pretty(weekly_report(
  (select id from auth.users where email = 'test-g12@…'),
  date_trunc('week', now())::date));
```
Check it has per-unit rows, medals earned, a previous-week comparison, and
weak spots in plain English — and **no question text**. A report that reads
like a transcript is wrong.

**P5. Revoke**, and confirm `reports_due` returns to zero.

## If something hangs

Not a code problem, usually. Before debugging anything else:

```bash
df -h /
top -l 1 | head -10
```

Six hours went to this once: macOS produces silent hangs rather than errors
when the disk or RAM is full. Free space, reboot, try again.
