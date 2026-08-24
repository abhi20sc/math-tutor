# TESTING — Astro Math Assist

Two halves.

**The SQL suite** covers everything that can be checked without a browser: the
paywall, the answer never reaching the client, teachers and consent, share
links, and the structure of the question bank. 62 assertions. Run it first —
if it is red, nothing below is worth your time.

**The manual pass** covers what only a person in a browser can see: the feel
of the wrong-answer loop, Stripe with a real card form, the layout on a phone,
and the one check that is worth doing twice — reading the network tab.

The old version of this file tested Grade 12 units, a "Change grade" menu, a
Hard difficulty band, teacher access codes, join codes and weekly parent
emails. None of those exist. If you find another instruction here that does
not match the app, the app is right and this file is wrong — say so.

---

## Part 1 — the SQL suite

Needs a local Postgres. **Never run it against the live project**: it inserts
fixture users and would leave them there.

```bash
dropdb --if-exists ama && createdb ama
psql -d ama -f tests/00_supabase_stub.sql
psql -d ama -f supabase/migrations/supabase_full_setup.sql
psql -d ama -f supabase/migrations/questions_grade10.sql
psql -d ama -f tests/test_ama.sql
```

The last file prints PASS or FAIL per check, a summary by block, and then
**raises an error if anything failed**. A clean run ends with
`All 62 checks passed.` — a run that ends any other way did not pass, even if
the output looks calm.

What the four blocks cover:

| Block | What it proves |
|---|---|
| **A** | The paywall. Locked levels listed honestly, refused on read *and* on write, no medals for them, and cancellation running to the end of the paid period |
| **B** | The answer never leaves the server. Options carry text and nothing else, `correct_index` is not even a column, `questions` returns zero rows to a signed-in student, plus the authoring rules |
| **C** | Teachers. The role cannot be self-granted, an invitation grants nothing until accepted, a second teacher gets nothing, leaving cuts access in the same second |
| **D** | Share links. Same token twice, first name only, no surname or email in the payload, revoke is instant, unknown token returns null rather than an error |

**It also prints a REVIEW section** listing wrong-option feedback that states
the correct answer. Those are not failures — they are authoring calls for
whoever writes the questions — but each one hands a student the answer they
were meant to work out.

If a check fails, read the detail column at the bottom before changing
anything. Several of these assert the *shape* of a refusal, and the schema is
deliberately inconsistent about that in one place: the dashboard functions
return **no rows** rather than raising when a teacher is not entitled, which
is safe but is not the same as an error.

---

## Part 2 — the manual pass

Roughly 30 minutes. Work top to bottom; later steps assume earlier ones
passed.

### Before you start

Three accounts. Create them as you go:

| Account | Purpose |
|---|---|
| `test-student@…` | Grade 10, the main account |
| `test-paid@…` | Grade 10, the one that buys Astro+ |
| `test-tutor@…` | Made a teacher from the SQL editor |

Turn off email confirmation while testing: Supabase → Authentication → Sign In
/ Providers → Email → uncheck **Confirm email**. **Turn it back on before real
students use this.**

Keep two windows open: the app, and the Supabase SQL editor.

---

### A — Setup

**A1. Run the setup file**, then the questions file, in that order. The setup
file drops and rebuilds `questions`, `profiles` and `staff_roles`.

**A2. Re-grant admin.** Setup cleared `staff_roles`, including you.

```sql
select grant_teacher_role('your@email.com', 'admin');
```

**A3. Check the bank loaded whole.**

```sql
select unit, difficulty, count(*)
from questions where grade = 10
group by 1, 2 order by 1, 2;
```

Expect 24 rows, every count exactly 10 — six units by four levels.

**A4. Everyone signs in once.** After any setup re-run, `profiles` is empty,
so every existing account must sign in before it reappears on a roster.

---

### B — The wrong-answer loop

This is the product. If any of B fails, nothing else matters.

**B1. Register** `test-student@…` as Grade 10. You should land in the app, not
on a "check your email" screen.

**B2. Try registering the same email again.** Expect a clear "that address
already has an account", not a confirmation screen. Supabase does not error on
a duplicate signup — it returns something that looks like success with an
empty `identities` list, and the app reads that.

**B3. Open a unit → Easy.** Tap a wrong option. It should:

- strike through and grey out
- become untappable
- show feedback naming the mistake, which scrolls itself into view
- **not** reveal which option is correct

**B4. Keep tapping wrong ones.** The correct answer must stay hidden until you
actually find it. Two wrong taps must not leave the answer inferable by
elimination.

**B5. Read four or five feedback strings.** None should contain the answer.
The SQL suite catches the blatant cases mechanically; your eye catches the
ones that give it away by implication.

**B6. First-try scoring.** Answer question 1 right on the first tap, question
2 wrong-then-right. The score must count one, not two.

---

### C — The network tab. Do not skip this.

The single most valuable check in this file, because it is the only one that
proves the thesis rather than trusting it.

In the app, open DevTools (**Cmd+Option+I**) → **Network**. Tap an answer.

**Find the `submit_answer` request → Response.** Expect exactly three things:
`was_correct`, `was_first`, and one `feedback` string. One — for the option
you tapped.

**Find the earlier `list_questions` request → Response.**

✅ **Pass:** each option contains only `text`. No `correct_index` anywhere. No
`feedback` on any option.

❌ **Fail:** if you can see `correct_index`, or four feedback strings, the app
is reading the questions table directly. Either `main.dart` did not get
replaced or the setup file did not run.

**Re-run this on the deployed site after every deploy.** It is the one test
worth doing twice.

---

### D — Progress, resume, reset

**D1. Attempts are written.**

```sql
select unit, sort_order, chosen_index, was_correct,
       was_first_attempt, misconception_tag, answered_at
from attempts order by answered_at desc limit 10;
```

`was_first_attempt` true only on the first tap of a question, and
`misconception_tag` filled on wrong rows but **null** on correct ones —
tagging correct answers would poison every count in the teacher view.

**D2. Resume.** Answer 3 questions, **close the tab entirely**, reopen and
sign in. You should land back on question 4 without choosing anything, or see
the "Pick up where you left off" card if you were on the unit list.

**D3. Soft reset.** … menu → **Reset my progress**.

```sql
select * from progress_resets;   -- a row exists
select count(*) from attempts;   -- unchanged
```

✅ **Pass:** counters back to zero, resume card gone, **medals still there**,
attempts count unchanged. If the attempts count dropped, something is deleting
instead of timestamping.

---

### E — Medals

Medals are **per level**, not per unit. Ten questions per level.

**E1. Bronze.** Finish Easy scoring under 7 on the first try. Expect a Bronze
disc on the results screen and the line naming what Silver needs.

**E2. Upward only.** Redo the same level and do worse. The medal must stay
Bronze — it must not drop.

**E3. Silver, then Gold.** Redo for 7–8 first-try, then 9–10. Should upgrade
each time, and the chip should update without a reload.

**E4. Revisit shelf.** With a Bronze level outstanding, the amber shelf should
offer it back. Earn Silver on it and the shelf should drop it.

---

### F — Astro+ and Stripe

**F1. Locked levels are visible.** As the free account, open a unit. Challenge
and Advanced should be listed with their counts and a lock — not hidden. The
student is meant to see what a subscription buys.

**F2. Tapping a locked level** offers Astro+ rather than an error.

**F3. Buy it** as `test-paid@…` with card `4242 4242 4242 4242`, any future
expiry, any CVC. Return to the app: Challenge and Advanced should open.

**F4. Check the database agrees**, not just the screen:

```sql
select status, current_period_end from subscriptions
where student_id = (select id from auth.users where email = 'test-paid@…');
```

**F5. Cancel** through the billing portal. Confirm
`customer.subscription.deleted` fired, `current_period_end` populated, and
**access continues until that date** rather than stopping on the spot.

**F6. Then force the lapse** to test the other half:

```sql
select update_subscription_by_sid('sub_…', 'canceled', now() - interval '1 day');
```

Reload the app — Challenge should be locked again.

---

### G — Teacher and consent

**G1. Make a teacher.** One line, SQL editor. There is no button and no code:

```sql
select grant_teacher_role('test-tutor@…', 'teacher');
```

Sign in as that account. You should get the dashboard.

**G2. Create a class.** Name and grade only — there is no join code.

**G3. Invite the student by email.** They should see an invitation card on
their front screen naming the teacher and saying what would be visible.

**G4.** ❗ **Before they accept, check the roster.** ✅ **Pass: they are not on
it.** Inviting is not enrolling. Open their detail too — it should be empty,
not an error.

**G5. Accept**, reload the roster. They appear with real counts.

**G6. The student always knows.** Their account bar should read "… · in 1
class". A student should never have to go looking to learn that a teacher can
see their work.

**G7. Class progress tab.** Units ranked weakest first, and the questions most
got wrong opening up to show the modal wrong answer and its feedback. If this
is thin, it is because there are not enough wrong taps yet — not a bug.

**G8.** ❗ **Student leaves the class.** The roster should empty immediately,
and their detail should close in the same second.

---

### H — Share links

**H1. Create a link** from the student's report screen.

**H2. Open it in a private window**, signed out entirely. It should load.

**H3. Read what it says.** ❗ First name only. No surname, no email, no class
name, no teacher name. This is a public URL that can be forwarded anywhere.

**H4. Revoke it.** Reload the private window — it should stop working
immediately, not on the next session.

**H5. Reissue.** The new link works, the old one stays dead.

---

### I — Things that should fail

**I1. Double tap** the same wrong option fast. One attempt row, not two.

**I2. Tap two different options** in quick succession. The second is ignored
while the first is in flight.

**I3. Offline.** DevTools → Network → **Offline**. Tap an answer. Expect "that
answer could not be sent" — not a frozen screen, and not a silently accepted
answer.

**I4. Refresh mid-level.** Answer 2 of 10 and refresh. Back to question 3 with
the count intact.

---

### J — On a real phone

Not the simulator. Three things that have only ever gone wrong on hardware:

**J1. The mind map** on the report screen — labels overlapping, or running off
the edge.

**J2. A share link opened in mobile Safari private browsing.**

**J3. The password reset email** — tap the link on the phone and confirm it
returns to the app. This needs the Netlify URL registered in Supabase Auth
under allowed redirect URLs, and has not been verified.

---

## Deploy check

```bash
cd ~/Desktop/math_tutor
flutter build web --base-href /
```

Drag **`build/web`** — the folder containing `index.html` — to Netlify →
Deploys. Then **Cmd+Shift+R** on the live site; a normal reload serves the
cached old build.

Re-run **Part C** on the deployed site.

---

## If something hangs

Not a code problem, usually. Before debugging anything else:

```bash
df -h /
top -l 1 | head -10
```

Six hours went to this once: macOS produces silent hangs rather than errors
when the disk or RAM is full. Free space, reboot, try again.
